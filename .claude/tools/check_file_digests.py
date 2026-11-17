#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""원본/수정본 판별기 + 버전 식별 — 설치본을 버전별 레지스트리(digests/*.json)와 대조.

각 버전 레지스트리의 파일 sha256 과 설치 대상의 각 파일을 비교해:
    원본(PRISTINE) = 존재 + sha 일치 · 수정본(MODIFIED) = 존재 + sha 불일치 · 미설치(ABSENT).
여러 버전 레지스트리가 있으면 **가장 많이 일치하는 버전**을 설치 버전으로 식별한 뒤, 그 버전 기준으로
원본/수정본을 판정한다. 원본 수가 같으면 설치 플랫폼과 같은 판(posix = "platform": "posix" 인 레지스트리 ·
windows = platform 필드가 없는 레지스트리) → 미설치 적은 쪽 → 높은 버전 순으로 고른다.
MODIFIED 가 1건이라도 있으면 **수정본**, 하나도 없으면 **원본**.
ABSENT 는 수정본 신호가 아니다 — 하네스 부분설치·구버전 레지스트리 매칭의 정상값이라 별도 계수한다.
크로스플랫폼(stdlib·개행 정규화) — verify.sh/ps1 이 호출하고 단독 실행도 된다.

사용:
    python3 tools/check_file_digests.py [target] [--digests PATH] [--platform posix|windows] [--quiet]
      target     : 검사할 설치 루트(기본 ~/.claude)
      --digests  : 대조할 레지스트리 — 디렉터리(digests/, 전 버전) 또는 단일 <ver>.json.
                   기본: 패키지 digests/(전 버전) → 없으면 설치본 digests/.
      --platform : 설치 플랫폼(`--platform posix` · `--platform=posix` 꼴 둘 다). 점검기가 넘긴다
                   (setup-posix/verify.sh = posix · setup/verify.ps1 = windows). 기본: 실행 OS
                   (os.name == "nt" → windows · 그 밖 → posix).
exit 0 = 원본 · 1 = 수정본 · 2 = 레지스트리 없음/오류.
"""
import hashlib
import json
import os
import re
import sys

# ── Windows stdout 인코딩 방어 (cp949 크래시 차단 · 패키지 CLI 도구 표준) ──
# 파이프로 캡처되면 Python 은 콘솔 CP 가 아니라 ANSI(한국어=cp949)로 인코딩 →
# '—'(U+2014) 등 cp949 밖 문자에서 UnicodeEncodeError. UTF-8 로 못박아 안전
# (BADA_recall 훅과 동일 방어를 전 CLI 도구로 표준화).
if sys.platform == "win32":
    try:
        import ctypes
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
    except Exception:
        pass
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except Exception:
        pass


def _digest(path):
    # gen_file_digests.py 와 동일해야 정합(텍스트 CRLF/CR→LF 후 sha256 · 바이너리 raw).
    data = open(path, "rb").read()
    if b"\x00" not in data:
        data = data.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    return hashlib.sha256(data).hexdigest()


# MATLAB 모듈 몫(우산 스킬 · 헬퍼 둘) — 판 고르기의 1순위 수(_pick_key)에서 뺀다(지금은 MATLAB 모듈이 심고 지운다 · 옛 Extra+Matlab
# 레지스트리가 그 파일로 앞서지 않게). 파일별 판정(원본·수정·미설치)은 그대로 센다.
MATLAB_MODULE_DIRS = ("skills/skill_LKS_original_matlab-simulink/",)
MATLAB_MODULE_FILES = ("tools/mcp_register.py", "tools/polyspace_register.py")


def _matlab_marker():
    """MATLAB 줄 표지 — 이 도구가 든 패키지의 module.json markers.matlab_line(설치본 tools/ 에는 module.json 이 없어 기본값)."""
    path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "module.json")
    try:
        return str((json.load(open(path, encoding="utf-8")).get("markers") or {}).get("matlab_line") or "<!--profile:matlab-->")
    except (OSError, ValueError):
        return "<!--profile:matlab-->"


def _digests_of(path, marker):
    """그 파일이 맞을 수 있는 해시 — 원 바이트 · .md 는 MATLAB 줄(표지 줄)을 뺀 바이트도(공용 층이 MATLAB 꼴로 그 줄을 켠 설치본 ·
    gen_file_digests.py _installed_digest 와 같은 줄 빼기)."""
    out = {_digest(path)}
    if path.endswith(".md"):
        data = open(path, "rb").read()
        if b"\x00" not in data:
            text = data.replace(b"\r\n", b"\n").replace(b"\r", b"\n").decode("utf-8", "replace")
            if marker in text:
                kept = "\n".join(ln for ln in text.split("\n") if marker not in ln)
                out.add(hashlib.sha256(kept.encode("utf-8")).hexdigest())
    return out


def _vkey(v):
    base = re.match(r'(\d+)\.(\d+)\.(\d+)', v)
    t = tuple(int(x) for x in base.groups()) if base else (0, 0, 0)
    return t + ((1,) if "-rev" in v else (0,))


def _read_registry(path):
    # 레지스트리 형태(files·version 보유)만 통과 — 비레지스트리 json(notes 등)·파손은 None.
    try:
        reg = json.load(open(path, encoding="utf-8"))
    except Exception:
        return None
    if isinstance(reg, dict) and "files" in reg and "version" in reg:
        return reg
    return None


def _load_registries(digpath):
    """digpath = 디렉터리(전 *.json) 또는 단일 .json → [(version, reg), ...]."""
    regs = []
    if os.path.isdir(digpath):
        for fn in sorted(os.listdir(digpath)):
            if fn.endswith(".json"):
                reg = _read_registry(os.path.join(digpath, fn))
                if reg:
                    regs.append((reg["version"], reg))
    elif os.path.isfile(digpath):
        reg = _read_registry(digpath)
        if reg:
            regs.append((reg["version"], reg))
    return regs


def _classify(target, reg):
    pristine = modified = absent = 0
    mods, absents = [], []
    marker = _matlab_marker()
    core = 0
    for rel, ent in reg["files"].items():
        p = os.path.join(target, rel)
        if not os.path.exists(p):
            absent += 1
            absents.append(rel)
            continue
        if ent["sha256"] in _digests_of(p, marker):
            pristine += 1
            if not (rel.startswith(MATLAB_MODULE_DIRS) or rel in MATLAB_MODULE_FILES):
                core += 1
        else:
            modified += 1
            mods.append(rel)
    return pristine, modified, absent, mods, absents, core


def _pick_key(scored_item, want):
    """판 고르기 순서 — MATLAB 모듈 몫 뺀 원본 수 → 설치 플랫폼 판 → 미설치 적은 쪽 → 원본 수 → 높은 판."""
    reg, cls = scored_item
    return (cls[5], reg.get("platform") == want, -cls[2], cls[0], _vkey(reg["version"]))


PLATFORMS = ("posix", "windows")


def _take_platform(argv):
    """argv 에서 `--platform <값>` · `--platform=<값>` 을 꺼낸다(없으면 None). 값이 없거나 틀리면 종료 2."""
    val = None
    for i, a in enumerate(argv):
        if a == "--platform":
            if i + 1 >= len(argv):
                sys.stderr.write("--platform 다음에 posix 또는 windows 가 필요하다\n")
                sys.exit(2)
            val = argv[i + 1]
            del argv[i:i + 2]
            break
        if a.startswith("--platform="):
            val = a[len("--platform="):]
            del argv[i]
            break
    if val is not None and val not in PLATFORMS:
        sys.stderr.write("--platform 은 posix 또는 windows 만 허용(받은 값: {})\n".format(val))
        sys.exit(2)
    return val


def main():
    argv = [a for a in sys.argv[1:] if a != "--quiet"]
    quiet = "--quiet" in sys.argv[1:]
    digover = None
    if "--digests" in argv:
        i = argv.index("--digests")
        if i + 1 >= len(argv):
            sys.stderr.write("--digests 다음에 경로가 필요하다\n")
            sys.exit(2)
        digover = argv[i + 1]
        del argv[i:i + 2]
    platform = _take_platform(argv) or ("windows" if os.name == "nt" else "posix")
    want = "posix" if platform == "posix" else None   # 레지스트리 platform 필드 값(windows 판 = 필드 없음)
    target = os.path.expanduser(argv[0]) if argv else os.path.expanduser("~/.claude")

    pkg_dig = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "digests")
    installed_dig = os.path.join(target, "digests")
    digpath = digover or (pkg_dig if os.path.isdir(pkg_dig) else installed_dig)
    regs = _load_registries(digpath)
    if not regs:
        sys.stderr.write("레지스트리 없음: {}\n".format(digpath))
        sys.exit(2)

    # 가장 많이 일치하는 레지스트리로 식별(동률 → 설치 플랫폼 판 → 미설치 적은 쪽 → 높은 버전). 원본 수가
    # 1순위라 옛 판 설치본은 옛 판으로 식별되고, 한 플랫폼 판이 다른 판의 부분집합이어도 동률이면 설치 플랫폼 판이 뽑힌다.
    scored = [(reg, _classify(target, reg)) for _v, reg in regs]
    reg_sel, (pristine, modified, absent, mods, absents, _core) = max(scored, key=lambda s: _pick_key(s, want))
    ver = reg_sel["version"]
    prof = reg_sel.get("profile", "?")

    # 우리 버전 파일이 하나도 일치하지 않으면 원본으로 오보하지 않는다 — 식별 불가(exit 2).
    if pristine == 0:
        if not quiet:
            print("대상       : {}".format(target))
            print("레지스트리 : {} ({}개)".format(os.path.abspath(digpath), len(regs)))
            print("판정       : 식별 불가 — 우리 버전 파일이 하나도 일치하지 않음"
                  "  (원본 0 · 수정 {} · 미설치 {})".format(modified, absent))
        sys.exit(2)

    # 레지스트리는 그 버전이 설치해야 할 파일을 정확히 담으므로, 매칭된 레지스트리의
    # 미설치>0 은 "누락(불완전 설치)" 신호다 — 정상 결번은 자기 레지스트리서 0.
    incomplete = absent > 0 and modified == 0
    verdict = ("수정본(MODIFIED)" if modified else
               "불완전(INCOMPLETE)" if incomplete else "원본(PRISTINE)")
    if not quiet:
        print("대상       : {}".format(target))
        print("레지스트리 : {} ({}개)".format(os.path.abspath(digpath), len(regs)))
        print("식별 버전   : {}".format(ver))
        print("프로파일    : {}".format(prof))
        print("플랫폼      : 레지스트리 {} · 설치 {}".format(reg_sel.get("platform") or "필드 없음(windows·옛 판)", platform))
        print("판정       : {}  —  원본 {} · 수정 {} · 미설치 {}".format(
            verdict, pristine, modified, absent))
        # 설치본 헌법 스탬프(있으면) — CLAUDE.md 는 인라인 스탬프 줄이라 해시 제외, 스탬프 줄로 표시.
        cm = os.path.join(target, "CLAUDE.md")
        if os.path.exists(cm):
            for ln in open(cm, encoding="utf-8").read().splitlines()[:6]:
                m = re.search(r'지침 버전\s*([\d.]+).*최종수정\s*([\d-]+)', ln)
                if m:
                    print("헌법 스탬프  : 유지 {} · 최종수정 {}".format(m.group(1), m.group(2)))
                    break
        if mods:
            print("수정된 파일 :")
            for m in mods[:50]:
                print("  ~ " + m)
            if len(mods) > 50:
                print("  … 외 {}개".format(len(mods) - 50))
        if incomplete:
            print("누락된 파일 :")
            for a in absents[:50]:
                print("  - " + a)
            if len(absents) > 50:
                print("  … 외 {}개".format(len(absents) - 50))
    sys.exit(1 if (modified or incomplete) else 0)


if __name__ == "__main__":
    main()

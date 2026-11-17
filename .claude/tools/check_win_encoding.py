#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""정적 게이트 — 패키지 자체 Python 도구가 Windows cp949 콘솔/파이프에서 stdout
UnicodeEncodeError 로 죽지 않도록 UTF-8 stdout 방어를 강제한다.

왜: Windows 에서 stdout 이 파이프로 캡처되면 Python 은 콘솔 CP 가 아니라 시스템 ANSI
코드페이지(한국어=cp949)로 stdout 을 인코딩한다. 출력에 '—'(U+2014) 등 cp949 밖 문자가
있으면 UnicodeEncodeError 로 크래시 — 설치 verify 가 이를 무결성 FAIL 로 오계수한다.
이 게이트가 계열 전체를 Linux 패키징 단계에서 선제 차단한다. 표준 방어·기전 상세 = instruction-architecture
(installer-traps) · 버전업 완료게이트 = instruction-architecture §14.

규칙 — 패키지 자체 도구(tools/·setup/ 의 .py):
    텍스트모드 stdout 출력(print( 또는 sys.stdout.write) + cp949-불가 문자 보유
    → 표준 가드 reconfigure(encoding="utf-8") 필수(errors= 등 추가 kwargs 허용 —
    계약은 "stdout 을 UTF-8 로 재구성"이지 축자 호출형이 아니다). 없으면 FAIL.
    (sys.stdout.buffer.write 만 쓰는 훅은 이미 바이트-안전 → 텍스트출력 아님·면제.)
vendored 스킬 스크립트(components/skills/**)는 업스트림 소유라 WARN 만(비차단).

사용: python3 tools/check_win_encoding.py        exit 0=통과 · 1=FAIL
"""
import os
import re
import sys

# (이 게이트 자신도 표준 적용 — 아래 offender 목록에 '—'·'✗' 를 찍으므로.)
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

PKG = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
# errors="backslashreplace" 등 추가 kwargs 형도 UTF-8 재구성 계약을 충족한다(축자 매칭 X).
GUARD_RE = re.compile(r'reconfigure\(\s*encoding="utf-8"\s*[,)]')


def _noncp949(text):
    bad = set()
    for ch in text:
        if ord(ch) > 0x7F:
            try:
                ch.encode("cp949")
            except Exception:
                bad.add(ch)
    return bad


def _prints_text(text):
    # 텍스트모드 stdout 출력이 있나. buffer.write 는 바이트라 제외(안전).
    if re.search(r'(?<![\w.])print\(', text):
        return True
    if "sys.stdout.write(" in text:
        return True
    return False


def _scan(rel_root):
    hits = []
    base = os.path.join(PKG, rel_root)
    for dp, _dn, files in os.walk(base):
        if "__pycache__" in dp:
            continue
        for fn in sorted(files):
            if not fn.endswith(".py"):
                continue
            p = os.path.join(dp, fn)
            try:
                txt = open(p, encoding="utf-8").read()
            except Exception:
                continue
            if not _prints_text(txt):
                continue
            bad = _noncp949(txt)
            if not bad:
                continue
            if GUARD_RE.search(txt):
                continue
            hits.append((os.path.relpath(p, PKG), "".join(sorted(bad, key=ord))))
    return hits


def main():
    fails = _scan("tools") + _scan("setup")
    warns = _scan("components/skills")
    print("=== Windows stdout 인코딩 게이트 (cp949 크래시 방어) ===")
    if fails:
        print("FAIL — 패키지 도구에 UTF-8 stdout 가드 누락 (cp949 크래시 위험):")
        for rel, bad in fails:
            print("  x {}  (cp949-불가 {})".format(rel, bad))
        print('  → 각 파일 import 직후 표준 가드 삽입:')
        print('     for _s in (sys.stdout, sys.stderr):')
        print('         try: _s.reconfigure(encoding="utf-8")')
        print('         except Exception: pass')
    else:
        print("OK — 패키지 자체 도구(tools/·setup/) 전부 UTF-8 stdout 가드 보유.")
    if warns:
        print("주의 — vendored 스킬 스크립트({}건 · 업스트림 소유 · 해당 스킬 실행 시에만):"
              .format(len(warns)))
        for rel, bad in warns[:15]:
            print("  ~ {}  ({})".format(rel, bad))
        if len(warns) > 15:
            print("  … 외 {}건".format(len(warns) - 15))
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()

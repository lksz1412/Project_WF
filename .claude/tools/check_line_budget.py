#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""공식 제한 준수 게이트 — 상시 로드 파일·스킬 메타데이터가 Claude Code 공식 한계 안인지 확인한다.

임의로 정한 캡(구 36,000B/20,500자)은 폐기하고 **공식 문서가 명시한 수치만** 강제한다.

근거(공식 문서 · 2026-09 확인):
- CLAUDE.md — 4 MiB 초과 시 파일을 통째 스킵(하드) · "target under 200 lines"(권고).
  (code.claude.com/docs/en/memory · "loads a CLAUDE.md file of up to 4 MiB in full and skips a larger file")
- MEMORY.md(auto memory 색인) — 매 세션 "first 200 lines or 25KB, whichever comes first" 만 로드,
  초과분은 다음 로드에서 드롭(하드). (동 문서 · "This limit applies only to MEMORY.md.")
- .claude/rules/*.md — 매 세션 로드(CLAUDE.md 와 동급 우선순위) → CLAUDE.md 와 같은 잣대(200줄
  권고·4 MiB 하드)를 적용. 필요할 때 실리는 rules(경로 지정 rules·하위 폴더 rules)와 하위 폴더
  CLAUDE.md 는 파일당 글자 한도(200K context = 40,000자)를 넘으면 앞부분만 실린다 — 게이트 값은
  그대로. (동 문서 "Claude ignores the end of my subdirectory CLAUDE.md" · 2026-11-16 확인 ·
  이 패키지는 rules 를 배포하지 않음.)
- 스킬 SKILL.md frontmatter — name ≤ 64자 · description ≤ 1024자(공식 "characters" = 유니코드
  코드포인트 · 한글도 1자=1로 세며 바이트가 아니다). 본문 "under 5k tokens"(권고) · 번들 리소스
  무제한. (platform.claude.com Agent Skills overview · api/beta/skills) 1,024·64 는 Platform API
  규칙(name 은 소문자·숫자·하이픈만)이다 · Claude Code 목록은 description+when_to_use 를 1,536자에서
  자른다(code.claude.com/docs/en/skills · 2026-11-16 확인) — 게이트 값은 1,024·64 그대로.
- 스킬 목록 예산(알림 · FAIL 아님) — 매 턴 실리는 스킬 이름·설명 목록은 글자 예산을 넘으면 덜 쓰는
  스킬의 설명부터 뺀다 · 기본 예산 = 모델 context 의 1%(설정 `skillListingBudgetFraction` · 다른
  플러그인 스킬도 같은 예산을 나눠 씀). 이 패키지 스킬 설명 합계만 알림으로 보인다.
  (https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short · "The budget scales at
  1% of the model's context window" · 2026-11-16 확인)

사용: python3 tools/check_line_budget.py [--root <Settings_for_Claude 경로>]
종료코드: 0 = 전건 한도 이내, 1 = 위반(공식 한계 초과 또는 대상 파일 부재) 존재.
"""
import sys

# ── Windows stdout 인코딩 방어 (cp949 크래시 차단 · 패키지 CLI 도구 표준) ──
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

# 이 패키지 도구 계열의 floor 선언 — 3.10 미만은 명시 오류로 조용히 죽지 않고 즉시 종료.
if sys.version_info < (3, 10):
    sys.stderr.write(
        "오류: Python 3.10 이상이 필요하다 (현재: {}.{}.{}).\n".format(*sys.version_info[:3]))
    sys.exit(1)

import argparse
import re
from pathlib import Path

_MIB = 1024 * 1024
_KB = 1024

# 상시 로드 파일 = 공식 로드 한계(줄·바이트). CLAUDE.md 200줄은 공식 "권고", 4 MiB 는 공식 "하드 스킵".
# MEMORY.md 200줄/25KB 는 공식 auto-memory 로드 한계(초과분 드롭 = 하드).
FILE_BUDGETS = {
    "components/global/CLAUDE.md": {"lines": 200, "bytes": 4 * _MIB},
    "components/global/BADA_HUB/MEMORY.md": {"lines": 200, "bytes": 25 * _KB},
}

# 룰(.claude/rules/*.md) = 매 세션 CLAUDE.md 동급 로드 → 같은 잣대(200줄 권고·4 MiB 하드).
# 이 패키지는 rules 를 배포하지 않으므로 아래 glob 은 통상 0건(향후 배포 시 자동 검사).
RULE_BUDGET = {"lines": 200, "bytes": 4 * _MIB}
RULE_GLOB = "components/global/rules/**/*.md"

# 스킬 frontmatter 공식 하드 한계(문자 수).
SKILL_NAME_MAX = 64
SKILL_DESC_MAX = 1024

METRIC_LABEL = {"lines": "줄", "bytes": "바이트"}


def _measure(path):
    raw = path.read_bytes()
    text = raw.decode("utf-8-sig")
    return {"lines": len(text.splitlines()), "bytes": len(raw)}


def _frontmatter(text):
    """첫 `---` … `---` 블록을 반환(없으면 '')."""
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.S)
    return m.group(1) if m else ""


def _yaml_scalar(fm, key):
    """frontmatter 에서 key 의 스칼라 값을 문자수 판정용으로 뽑는다.
    단일행·따옴표·블록 스칼라(| >)의 들여쓴 연속행을 모두 흡수(다음 top-level `키:` 전까지)."""
    m = re.search(r"^" + re.escape(key) + r":[ \t]*(.*)$", fm, re.M)
    if not m:
        return None
    first = m.group(1)
    # 블록 스칼라 표식이면 이어지는 들여쓴 줄을 모은다.
    ind0 = first.strip()
    if ind0 in ("|", ">", "|-", ">-", "|+", ">+", ""):
        literal = ind0.startswith("|")   # | = 리터럴(개행 보존) · > = 폴드(공백 합치기)
        start = m.end()
        blk = []
        for ln in fm[start:].split("\n"):
            if ln[:1] in (" ", "\t") or ln.strip() == "":
                blk.append(ln)
            else:
                break
        if literal:
            # 리터럴 블록은 개행·내부 들여쓰기가 값의 일부 → 공통 들여쓰기만 제거하고
            # 개행을 보존해 문자수를 정확히 센다(폴드처럼 공백으로 접으면 개행·들여쓰기 누락).
            base = min((len(l) - len(l.lstrip()) for l in blk if l.strip()), default=0)
            val = "\n".join(l[base:].rstrip() for l in blk).strip("\n")
        else:
            val = " ".join(l.strip() for l in blk if l.strip())
    else:
        val = first.strip()
        # 인용부호 벗기기
        if len(val) >= 2 and val[0] == val[-1] and val[0] in ("'", '"'):
            val = val[1:-1]
    return val


def check_files(root):
    summary, violations = [], []
    for rel, limits in FILE_BUDGETS.items():
        path = root / rel
        if not path.is_file():
            violations.append("{}: 파일 없음".format(rel))
            summary.append("{} : 파일 없음(검사 불가)".format(rel))
            continue
        measured = _measure(path)
        parts = []
        for metric in ("lines", "bytes"):
            val, cap = measured[metric], limits[metric]
            parts.append("{} {}/{} (여유 {})".format(METRIC_LABEL[metric], val, cap, cap - val))
            if val > cap:
                violations.append("{}: {} {} > 공식 한도 {} (+{})".format(
                    rel, METRIC_LABEL[metric], val, cap, val - cap))
        summary.append("{} : {}".format(rel, " · ".join(parts)))
    return summary, violations


def check_skills(root):
    """돌려줌 = (줄 목록, 위반 목록, 설명 글자 합계)."""
    summary, violations = [], []
    desc_total = 0
    skill_dir = root / "components" / "skills"
    if not skill_dir.is_dir():
        return summary, violations, desc_total
    for sk in sorted(p for p in skill_dir.glob("*/SKILL.md") if p.is_file()):
        name_dir = sk.parent.name
        fm = _frontmatter(sk.read_text(encoding="utf-8-sig"))
        name = _yaml_scalar(fm, "name") or ""
        desc = _yaml_scalar(fm, "description") or ""
        nlen, dlen = len(name), len(desc)  # 공식 "characters" = 유니코드 코드포인트(한글도 1자=1)
        desc_total += dlen
        flags = []
        if nlen > SKILL_NAME_MAX:
            flags.append("name {} > {}".format(nlen, SKILL_NAME_MAX))
        if dlen > SKILL_DESC_MAX:
            flags.append("description {} > {}".format(dlen, SKILL_DESC_MAX))
        if not desc:
            flags.append("description 비어있음(공식 필수)")
        if flags:
            violations.append("skills/{}: {}".format(name_dir, " · ".join(flags)))
        summary.append("skills/{:44} name {:2}/{} · desc {:4}/{}".format(
            name_dir[:44], nlen, SKILL_NAME_MAX, dlen, SKILL_DESC_MAX))
    return summary, violations, desc_total


def check_rules(root):
    summary, violations = [], []
    files = sorted(p for p in root.glob(RULE_GLOB) if p.is_file())
    if not files:
        summary.append("(이 패키지는 rules 를 배포하지 않음 — 0건 · 향후 배포 시 CLAUDE.md 동급 검사)")
        return summary, violations
    for rf in files:
        measured = _measure(rf)
        parts = []
        for metric in ("lines", "bytes"):
            val, cap = measured[metric], RULE_BUDGET[metric]
            parts.append("{} {}/{} (여유 {})".format(METRIC_LABEL[metric], val, cap, cap - val))
            if val > cap:
                violations.append("{}: {} {} > 공식 한도 {} (+{})".format(
                    rf.relative_to(root), METRIC_LABEL[metric], val, cap, val - cap))
        summary.append("{} : {}".format(rf.relative_to(root), " · ".join(parts)))
    return summary, violations


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=None,
                     help="Settings_for_Claude 경로(기본: 이 스크립트 위치 기준 상위 디렉터리)")
    args = ap.parse_args()
    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parent.parent

    print("=== 공식 제한 준수 게이트 ===")
    fsum, fviol = check_files(root)
    print("[상시 로드 파일 — 공식 로드 한계]")
    for ln in fsum:
        print("  " + ln)
    rsum, rviol = check_rules(root)
    print("[룰(.claude/rules) — 공식 CLAUDE.md 동급: 200줄·4 MiB/파일]")
    for ln in rsum:
        print("  " + ln)
    ssum, sviol, desc_total = check_skills(root)
    print("[스킬 frontmatter — 공식 name≤{}자·description≤{}자(코드포인트 · 한글도 1자=1)]".format(
        SKILL_NAME_MAX, SKILL_DESC_MAX))
    for ln in ssum:
        print("  " + ln)
    print("[알림 — 스킬 목록 예산(FAIL 아님)] 이 패키지 스킬 {}종 설명 합계 {}자 · 기본 예산 = 모델 context 의 1% · "
          "다른 플러그인 스킬과 나눠 씀 · 넘으면 덜 쓰는 스킬 설명부터 빠짐".format(len(ssum), desc_total))

    violations = fviol + rviol + sviol
    if violations:
        print("\n[FAIL] 공식 한계 초과 {}건:".format(len(violations)))
        for v in violations:
            print(" -", v)
        return 1
    print("\n[PASS] 전건 공식 한계 이내.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

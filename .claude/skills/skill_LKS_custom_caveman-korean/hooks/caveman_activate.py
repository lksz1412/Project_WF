#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""SessionStart 훅 — 출력 압축(caveman) 모드를 세션 시작 시 Full 로 자동 활성화한다.

스킬은 작동 조건이 맞을 때 켜진다. 출력 압축은 특정 작업이 아니라 모든 응답에
걸려야 하므로 조건 매칭으로 켤 수 없어, 훅이 세션 시작·재개·clear·컴팩션·fork 마다 core skill
본문을 주입한다. 그때마다 stdout 으로 컨텍스트를 한 번 내보내는 것이 전부다 — 파일을 쓰지도
네트워크를 타지도 않는다.

이식: powershell 판(caveman-activate.ps1)을 stdlib Python 으로 옮긴 것.
os.path·__file__ 로 경로를 해소해 Windows·Linux·web 무관하게 동작한다.

계약
  - stdout(정상) = core SKILL.md 본문(SessionStart additionalContext 로 주입)
  - stdout(폴백) = JSON {"hookSpecificOutput": {...}} 최소 지침
  - fail-open : 어떤 예외가 나도 세션을 막지 않는다 — 폴백 출력 + exit 0.
    (훅이 죽어 세션이 안 열리는 것이 압축이 안 되는 것보다 나쁘다.)

stdlib 전용. UTF-8 전수 명시(Windows cp949 기본 인코딩 함정 회피).
"""
import json
import re
import sys
from pathlib import Path

MAX_BODY = 10000  # SKILL.md 본문 상한(additionalContext 안전 여유)
FALLBACK_CONTEXT = (
    "응답은 짧고 정확하게 쓴다. 기술 용어·code·API 이름·CLI command·exact error "
    "string은 원문을 유지한다. 보안 경고와 비가역 작업 확인은 충분한 평문으로 쓴다."
)
# 선두 frontmatter(--- ... ---) + 본문. \r\n·\n 양쪽 허용.
_FM_RE = re.compile(r"\A---\r?\n(?P<frontmatter>[\s\S]*?)\r?\n---\r?\n(?P<body>[\s\S]*)\Z")
_NAME_RE = re.compile(r"^name:[ \t]+(?!#)\S")
_DESC_RE = re.compile(r"^description:[ \t]+(?!#)\S")


def _write_fallback():
    payload = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": FALLBACK_CONTEXT,
        }
    }
    sys.stdout.buffer.write(json.dumps(payload, ensure_ascii=False).encode("utf-8"))
    sys.stdout.buffer.flush()


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    try:
        # 훅은 skill 내부 hooks/ 에 있으므로 SKILL.md 는 상위 디렉터리.
        core = Path(__file__).resolve().parent.parent / "SKILL.md"
        text = core.read_text(encoding="utf-8-sig")
        m = _FM_RE.match(text)
        if not m or not m.group("frontmatter").strip():
            raise ValueError("invalid leading frontmatter")
        lines = m.group("frontmatter").replace("\r\n", "\n").split("\n")
        names = [ln for ln in lines if ln.startswith("name:")]
        descs = [ln for ln in lines if ln.startswith("description:")]
        if len(names) != 1 or len(descs) != 1:
            raise ValueError("invalid required frontmatter keys")
        if not _NAME_RE.match(names[0]) or not _DESC_RE.match(descs[0]):
            raise ValueError("invalid required frontmatter keys")
        body = m.group("body")
        if not body.strip():
            raise ValueError("empty core body")
        if len(body) > MAX_BODY:
            raise ValueError("core body exceeds 10000 characters")
        # 개행 변환 없이 정확한 본문 바이트를 낸다 — Windows 텍스트모드 stdout 의 \n→\r\n 변환이
        # 주입 본문 결정성(및 verify 의 byte-exact 대조)을 깨는 것을 막는다(크로스플랫폼 동일 출력).
        sys.stdout.buffer.write(body.encode("utf-8"))
        sys.stdout.buffer.flush()
    except Exception:
        try:
            _write_fallback()
        except Exception:
            pass  # stdout 을 오염시키지 않고 세션 시작은 계속 허용한다.
    sys.exit(0)


if __name__ == "__main__":
    main()

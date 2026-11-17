---
description: 출력 압축 모드의 강도·스킬·커맨드 요약 카드를 보여준다
---

`skill:skill_LKS_custom_caveman-korean-help` 을 실행해 **참조 카드를 한 번 출력한다.**

일회성 표시다 — 모드를 바꾸지 않고, 파일을 쓰지 않고, 아무것도 지속시키지 않는다.
현재 강도가 무엇이든 그대로 둔다.

표시할 내용:

- 강도 3단계(`lite` · `full` · `ultra`)와 각각이 무엇을 줄이는지
- 켜지는 방식 — SessionStart 훅(`hooks/caveman_activate.py`)이 세션 시작·재개·clear·컴팩션·fork 직후 본문을 다시 넣는다(처음엔 Full · 앞서 고른 강도·해제가 대화에 보이면 유지 — clear 뒤처럼 안 보이면 Full)
- 커맨드 — `/caveman lite|full|ultra` · `/caveman-commit` · `/caveman-review` · `/caveman-help`
- 해제 — "stop caveman" · "normal mode" · "일반 말투로"
- 압축하지 않는 예외 — 보안 경고 · 비가역 작업 확인 · 순서가 중요한 다단계 설명 · **파일 산출물 전부**(계획서·Result·Ledger·handover 등 — 세션 응답에만 압축) · 결정 요청·검토 보고(헌법 평문·4-tier 우선) · Phase 정리 보고·최종 작업 보고(헌법 화면 글 — 말로) · 이론·기술 설명 요청(헌법 설명 · 짧은 사실 답은 압축)

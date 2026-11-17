---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_custom_caveman-korean-help
description: >
  Quick-reference card for all caveman modes, skills, and commands.
  One-shot display, not a persistent mode. Use when user invokes /caveman-help
  or says "caveman help", "what caveman commands", "how do I use caveman".
---

<!-- 베이스: blacknabis/cavemankorean(JuliusBrussee/caveman의 한국어 로컬라이즈 포크) — skills/caveman-help/SKILL.md. 수정: 본인 — 미포함 스킬(caveman-compress) 참조 제거. Korean Usage 절은 포크 원본 유래. Configure Default Mode는 이 배포판 훅이 기본 강도 Full 고정이라 원본 env var/config 방식을 미지원으로 정리하고 켜지는 방식(다시 넣기·강도 유지)과 커맨드 전환만 안내. 압축하지 않는 예외 절 추가(코어 스킬 Auto-Clarity·Boundaries 요약). More 섹션(외부 GitHub 링크)은 패키지에 부적절하여 제외. -->

## Caveman Help

Display this reference card when invoked. One-shot — do NOT change mode, write flag files, or persist anything. Output in caveman style.

## Modes

| Mode | Trigger | What change |
|---|---|---|
| Lite | `/caveman lite` | Drop filler. Keep sentence structure. |
| Full | `/caveman` | Drop articles, filler, pleasantries, hedging. Fragments OK. Default. |
| Ultra | `/caveman ultra` | Extreme compression. Bare fragments. Functional tables only when clearer than prose. |

Mode sticks until changed or session end.

## Korean Usage

- Keep user's language. 한국어로 물으면 한국어로 답한다.
- Lite: 자연스러운 한국어 유지, 군더더기만 제거.
- Full: 짧은 평서 중심. 문제. 원인. 조치. 순서.
- Ultra: 명사구/단문 위주. 조사는 의미가 안 흐릴 때만 생략. 접속사는 인과관계가 명확할 때만 생략. 발명형 약어와 인과 화살표는 쓰지 않음.
- Quick triggers: "원시인 모드", "짧게 말해", "토큰 아껴서 말해".
- 사용자의 주언어를 유지하고 영어 opening/status를 강제로 붙이지 않는다. 기술 용어, code, API 이름, CLI command, commit type, exact error string은 번역 요청 전까지 원문 유지.

## Hard Rules

- 압축 자체가 기술적 모호성을 만들면 해당 부분은 평문으로 충분히 쓴다.
- 도구 호출 중계 설명·장식용 표/emoji·긴 raw error dump를 쓰지 않고 가장 짧은 결정적 오류 줄만 인용한다.
- 진행 상황 표(스텝·토픽이 끝날 때마다 결과를 알리는 `| Step | 토픽 | 예상(시작 때) | 실제 | 실제/예상 | 결과 |` 표)는 정보 표라 장식용 표가 아니다 — 압축 중에도 그 표로 보고한다.
- 스타일 이름·활성화 사실·3인칭 caveman tag·정상 답변 뒤 `Caveman:` 재요약 금지. 사용자가 모드 자체를 물을 때만 예외.
- DB/API/HTTP 같은 표준 약어와 exact code·API token은 유지한다. 설명문에서 `cfg/impl/req/res/fn` 같은 약어를 새로 만들거나 인과 화살표를 쓰지 않는다. 인과가 명확할 때만 접속사를 생략하고, 한 단어면 충분할 때 한 단어만 쓰며 같은 사실은 한 번만 쓴다.

## Skills

| Skill | Trigger | What it do |
|---|---|---|
| skill_LKS_custom_caveman-korean | `/caveman` (lite·full·ultra) | 출력 압축 강도 전환·해제 (기본 압축 모드) |
| skill_LKS_custom_caveman-korean-commit | `/caveman-commit` | Terse commit messages. Conventional Commits. ≤50 char subject. |
| skill_LKS_custom_caveman-korean-review | `/caveman-review` | One-line PR comments: `L42: bug: user null. Add guard.` |
| skill_LKS_custom_caveman-korean-help | `/caveman-help` | This card. |

## Deactivate

Say "stop caveman", "normal mode", "일반 말투로", or "원래 말투로". Resume anytime with `/caveman`.

## Configure Default Mode

이 배포판은 SessionStart 훅이 세션 시작·재개·clear·컴팩션·fork(앞 대화를 이어받아 가른 세션) 직후 압축 규칙을 다시 넣는다 — 처음엔 **Full**, 앞서 고른 강도·해제가 대화에 보이면 **그대로 유지**(다시 넣는 것은 리셋이 아니다 · clear 뒤처럼 앞선 선택이 안 보이면 Full). 기본 강도(Full)는 고정이다 — 원본의 환경 변수(`CAVEMAN_LEVEL`)·설정 파일(`~/.config/caveman/config.json`) 방식은 이 배포판 훅이 읽지 않으므로 **지원하지 않는다**.

세션 중 강도 변경·해제는 커맨드로 한다: `/caveman lite|full|ultra`(또는 "짧게 말해"·"간결하게 말해"), 해제는 "stop caveman"·"normal mode"·"일반 말투로"·"원래 말투로".

## 압축하지 않는 예외

보안 경고 · 비가역 작업 확인 · 순서가 중요한 다단계 설명 · 압축이 기술적 모호성을 만들 때 · 사용자가 되묻거나 설명을 청할 때 · 결정 요청·검토 보고(헌법 평문·4-tier 우선) · Phase 정리 보고·최종 작업 보고(헌법 화면 글 — 말로) · 이론·기술 설명 요청(헌법 설명 · 짧은 사실 답은 압축) · **파일 산출물 전부**(코드·커밋·PR · 계획서·스텝 이력·Result·Ledger·handover 등 디스크에 쓰는 것 — 압축은 세션 응답에만). 원본 = 코어 스킬 `skill_LKS_custom_caveman-korean` Auto-Clarity·Boundaries.

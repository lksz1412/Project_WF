# 발주문 — 마스터 플랜 독립 검수 (Phase 0 · Step 7)

## 0. 고지 5항목
1. **역할**: 너는 「Devil Forever 애드온 모음집」 Phase 0 Step 7 의 **검수 sub(B)** 다. 3-세션 모델(master + 작업 A + 검수 B)에서 너의 책임은 아래 대상의 10라운드 검수 보고뿐이다. 고친 뒤 재확인도 이 세션이 한다.
2. **분업 경계**: 읽기 전용. 파일을 고치거나 만들지 않는다. 보고는 반환 글로 낸다(master 가 저장). commit 은 master.
3. **범위 밖 자의 작업 금지**: 수정안을 쓰지 않는다(수정안 칸 없음). 범위 밖 관찰은 목록만.
4. **허위 attribution 금지**: 사용자 원문과 다른 것을 사용자 말로 인용하지 않는다. 인용은 파일:줄 + 원문 그대로.
5. **규범 요지(주입)**:
   - refute mandate — 통과시키려 하지 말고 반증하라. 빈 통과 금지 — 중대·중간 0 이면 읽은 범위와 반증 시도를 적는다.
   - 등급: 중대(실행 불가·뜻 반전·큰 흐름 깸) / 중간(쓸 때 헷갈려 잘못 쓰게 됨 — 누가·어떤 상황에서·무엇을 잘못하는지 한 줄로 쓸 수 있을 때만) / 경미(문구·다듬기 — 판정을 안 바꾸는 표기·조사 지적은 세지 않음). 등급은 제안.
   - 전문 정독: 대상 파일(523행)은 ~260행 창 두 개로 첫 라운드에 head→tail 전독, 이후 라운드는 그 관점에 필요한 곳 + 기계 검사(grep·카운트). 창마다 읽은 범위를 적는다.
   - 금지 어휘(파일에 있으면 경미로): 정본·거울·문면·문안·전량·얕은 병합·발동·수권·사소차.
   - `rm -rf` 등 승인 창 명령 금지. 임시 파일은 `mktemp -d` 로.

## 1. 대상 (신규 · 갈래 ③ 구조 변경 · 프리셋 P5 · 고정 ③ = 연결)
- `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` (523행)

## 2. 연계 파일 (전문 · 대조용)
- 사용자 원문: `Codex/results/REQUEST_LEDGER.md`(R1–R28), `Codex/results/REQUEST_LEDGER_phase1.3.md`(R29–R72 요지), `Codex/results/handoffs/old-reference/R37-user-message.md` ~ `R72-user-message.md`, `Claude/results/REQUEST_LEDGER_phase0.md`(R73–R81).
- 조사 근거: `References/addon-survey/features.md`, `References/addon-survey/survey.md`, `References/addon-sources/INDEX.md`.
- 작업 기록: `Claude/results/handoffs/master-plan/iter_1/work_log.md` 의 실행 명령·판정 줄 부분만(이미 돌린 검사는 다시 돌리지 말고 기록으로 판정 · 기록이 없거나 어긋날 때만 실행. 예: ZIP 안 TOC·라이선스 파일 존재는 `unzip -l` 로 재확인 가능).
- 그 밖 Codex 기록 파일은 계획이 「Codex 기록」 으로 인용한 줄을 확인할 때만 그 파일을 연다.

## 3. 이미 정한 것 (재론 금지 — 이유가 틀렸다는 파일:줄 근거가 있을 때만 결함)
- 사용자 결정: 모음집(R60) · 전 직업(R61) · Hekili 기반(R62) · 공통 외관 구현 1페이즈·기능별 시작 애드온 수정 우선·안 되는 것만 개발(R63) · 기능마다 Phase(R64) · 목업 마지막(R55·R56) · 검수 먼저(R65) · 원천은 사용자 제공 ZIP(R75·R81 수령) · 네트워크 허용은 거부됨(R78·R79).
- master 결정: Step 1–5 = Codex 이력, 새 Step 은 6 부터 · 내부 기록 언어 영어 / 마스터 플랜 한국어 · 작업 자리 `Claude/`.

## 4. 라운드 (관점 10개 · 조기 종료 없음 · 순서대로)
고정 5 (P5 일반 문서):
- R1 형식 — 11 섹션 이름·순서(Summary / Current Ground Truth / Phase Range / Non-goals / Implementation Changes / Phase N / Implementation Interfaces / Test Plan / Assumptions / Correction History / Decisions Required), 간략 목차, 표 렌더 깨짐.
- R2 사실·참조 — 수치·버전·파일 경로·인용 줄·링크가 실물과 같나(경로 존재는 `ls`/`test -e` 로).
- R3 연결 — 안: 앞 절의 정의·결론을 뒤 절이 맞게 쓰나, 모순 없나 / 밖: 기대는 기존 파일(Codex 기록·References·조사)과 맞나.
- R4 완결성 — 정의·단계 빠짐, orphan(앞에서 도입했는데 안 쓰임 · 뒤에서 쓰는데 정의 없음) 0, 「멈출 일 미리 점검」 표 필수 항목(새 의존성·네트워크·파괴·권한·세션 전환·검증 미수렴·원래 결함·푸시·실측 불가·모델 미가용) 존재.
- R5 뜻·의도 — 사용자 요청 범위를 넓히거나 줄이거나 뒤집은 곳.
가변 5 (계획 Test Plan 389행):
- R6 사용자 원문 R1–R81 대조·누락 — 원문 하나하나를 계획 어디가 받는지. 받는 곳 없는 요청을 찾는다.
- R7 (적대) 사실/Codex 기록/A1 제안 구분 — Codex 기록이나 추정을 실측·사용자 결정처럼 쓴 곳.
- R8 기능 판정(필수/선택/제외)의 근거와 기본값 규칙 — features.md 줄·사용자 원문과 맞나, 사용자가 이미 정한 것을 선택지로 되돌린 곳은 없나.
- R9 컨테이너 검증과 사용자 PC 검증의 나눔 — 여기서 못 하는 것을 여기서 통과시킨다고 쓴 곳.
- R10 일정 합계와 Step 번호 정합 — 목차 Step 예상의 합 = 본문 합계, Step 번호 연속·중복 없음, Phase 표와 목차 일치(계산은 python 으로).

## 5. 보고 형식
- 첫 줄: `중대 n · 중간 m · 경미 k`
- 중대·중간마다: 라운드 · 파일:줄 · 무엇이 깨지나 · 근거(원문 인용 — 요약 아님 · 재현 출력) · 연결돼 보이는 곳.
- 경미: 한 줄씩 최대 5건, 나머지는 개수만.
- 라운드마다 읽은 범위(창별 줄)와 반증 시도 한 줄.
- 끝에 「지도 밖 연결」(계획이 기대는데 연계 파일에 없는 곳) 한 항목.

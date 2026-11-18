# 인계 — Devil Forever 애드온 모음집 · Claude 몫 v0.1.0

작성: 2026-11-18 21:18 KST · 작업 가지 `ccr-ba95560e-h298t2` · main 반영 `b8a7c50` 까지

## ⑤ 인계 사슬

1. `Codex/docs/HANDOVER_v0.1.0.md` — Codex 시기(Step 1–5)의 마지막 인계.
2. **이 파일** — Claude 가 이어받은 마스터 플랜(Phase 0–25)의 첫 인계. 이 세션은 컴팩션을 여러 번 겪었고, 그때마다 마스터 플랜·세부 계획서·Result 로 복구했다.

다음 세션은 이 파일 → 마스터 플랜 `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`(본문 전문) → `Claude/plans/…-phase25-세부계획.md` → 최신 Result `Claude/results/PHASE_24_mockup_RESULT.md` → `Claude/results/REQUEST_LEDGER_phase25.md`(그리고 앞 Phase 대장의 끝나지 않은 행) 순으로 읽는다.

## ① 받은 지시 (사용자 결정 — 원문은 요청 대장)

- R1–R72: Codex 대장(`Codex/results/REQUEST_LEDGER.md`, `REQUEST_LEDGER_phase1.3.md`, `Codex/results/handoffs/old-reference/R*-user-message.md`).
- R73–R87: `Claude/results/REQUEST_LEDGER_phase0.md`. 핵심: R83 「D4 만 나. 나머지는 전부 기본값.」, R86 실사용 검증은 Codex, R87 외관은 Codex · Claude 는 코드·기능 단의 작성·검토만 · 이번 세션 검수 강도는 master 가 정하되 10라운드를 넘지 않음.
- R88 GO · R90/R91 Phase 마다 작업 가지와 main 에 commit·push.
- R95–R108: 각 Phase 대장(`Claude/results/REQUEST_LEDGER_phase<ID>.md`). 근간 변경은 R100(툴팁·가방·퀘스트·지도 빠짐), R101(「애드온은 적을수록좋으니까」), R104(Hekili 추천 + 게임 기본 Cooldown Manager), R107(PitBull4 판 추가·TinyThreat·게임 기본 이름표·Aurora 는 Codex 판정·가벼운 상태띠·통합 편집기 없음·FHD/QHD/UHD 세 겉보기), R108 「계속 진행해」.
- R110 (`REQUEST_LEDGER_phase25.md`): 「1 Codex 비교로, 2 유지, 3 상태띠만, 4 감수, 5 감수 … 핸드오버까지 커밋푸쉬하도록」.
- R109 (`REQUEST_LEDGER_phase19.md:7`): 「코덱스는 퇴근 후에 컴퓨터를 써야할것 같아서 보류중이야. 일단 너부터 다 해와.」 — Codex 결과를 기다리지 않고 Claude 몫을 끝낸다. Codex 결과에 기대는 부분은 발주문과 대기로 남긴다.

## ② 작업 요약

- Phase 0–24 완료. Phase 마다 Result md+json 이 `Claude/results/PHASE_<ID>_*_RESULT.*` 에, 실행 대장이 `Claude/results/PHASE_0-25_EXECUTION_LEDGER.md` 에, Phase 끝 정리가 `Claude/plans/…-plan_이력.md` 에 있다.
- 만든 것:
  - Core `Collection/AddOns/!DevilForever_Core/`(등록 표·기본값 주입·테마 토큰·편집값·저장/복원 `/dfp`·테마 전환 `/dfp theme`).
  - 상태띠 `DevilForever_StatusStrip`, PitBull4 Forever 판, 각 기능 기본값 파일.
  - 설치 ZIP `outputs/collection/DevilForever-0.1.0.zip`(PitBull4 판), 확인용 ZIP `DevilForever-collection.zip`, 설치안내 `Collection/install/설치안내.md`.
- Codex 발주문 34개 `Collection/codex-briefs/`(실사용 검증 `phase<ID>.md` · 외관 `appearance-<ID>.md` · 마지막은 최종 목업 `appearance-24.md`).
- 시험: `Collection/tests/core/run.py`(108건), `Collection/tests/statusstrip/run.py`(20건).

## ③ 미완료 항목

1. **Codex 결과 전부** — `References/codex-verify/`·`References/codex-appearance/` 가 아직 없다(origin/main `b8a7c50` 기준). 사용자가 발주문을 Codex 에 넘기고 Codex 가 올려야 한다.
2. **Phase 24 대조** — 받은 목업을 Step 5 구획·세 preset·표시 문구와 대조해 채팅에 보인다(R46). 결과 대기.
3. **Phase 25 Step 40** — Codex 검증 결과에서 나온 코드 결함 정정(A2 coder + 같은 B). 결과 대기.
4. **Phase 25 Step 41** — 최종 묶음 고정(ZIP·manifest·SHA256), 복원 방법, 남은 미검증 목록. 설치안내에는 지금 설치 순서와 `/dfp` 되돌리기만 있다. 「모음집을 통째로 빼고 설치 전으로 돌리기」(지금 `AddOns`·`WTF` 를 다른 이름으로 비키고 1번 백업을 복사해 넣기 — 각 발주문 마지막 항목과 같은 방법)를 설치안내에 넣는 일이 남았다.
5. **R110 으로 정해진 것**(`REQUEST_LEDGER_phase25.md`): unit 기본판 = Codex 비교 결과로 정함 · 이름표 시전바 유지 · 시계는 상태띠만 — **미니맵 시계 숨김은 Step 40 에서 할 일(아직 안 함)** · Aurora 제약 감수 · 설정 복원 범위 위험 감수.
6. **그 밖의 결정 대기·기록**: unit 프레임 기본판(PitBull4 임시, FUF 대체), 이름표 시전바 유지(임시), 미니맵 시계와 상태띠 시계 중복, Aurora 를 쓸 때의 제약(이름표·Cooldown Manager·버프 스킨을 끌 수 없음, `questTextContrast`, GC 변경), Experience Forever 경험치 바를 숨길 수 없음, Phase 20 받아들인 위험(저장 변수 통째 복원이 다른 캐릭터에도 미침 · 공유 직업 profile 이 복원 때 갈라지고 되돌리기로 다시 합쳐지지 않음), PowerShell 해시 줄 미시험, 흑마법사 영혼 조각, Grid2 가 공격대 관리자를 숨김, Dominos_Cast 제외, ProfileManager 유지. 경미 목록은 각 `Claude/results/handoffs/phase<ID>/TRIAGE_phase<ID>.md`.

## ④ 다음 세션 주의점

- 이 컨테이너는 게임을 못 띄운다. 정적 검사·논리 검수 통과를 게임 통과로 적지 않는다.
- Codex 결과가 올라오면 먼저 `git fetch origin main` 으로 받아 `References/codex-verify/phase<ID>/` 를 Phase 별로 읽고, 결함은 Step 40 에서 같은 A·같은 B 유닛으로 고친다(Phase 가 바뀌었으니 새 서브).
- 외관 결과는 `Collection/` 에 합치기 전에 토큰·프레임 이름·등록 표 사용만 정적 대조한다(외관 판정은 Codex).
- 기록 도구: `Claude/tools/open_settings_phase.sh`, `Claude/tools/close_settings_phase.py`(「28b」 같은 Step 번호는 못 다룸 · 실행 뒤 Result 의 「Files Updated」·「Inputs」·「Non-Changes」 기본 문구를 고쳐야 함).
- Codex 발주문 규칙: 0번 = 백업 뒤 애드온을 따로 옮김 · 마지막 = 통째 복원 · 바꾼 원래 값 기록·되돌리기 · `/run` 한 줄 255바이트 이하 · 금지어(정본·거울·문면·문안·전량·발동·수권).
- master effort 는 앱에서 medium 을 고른다(`.claude/ENVIRONMENT.md`).

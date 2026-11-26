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

## 갱신 — 2026-11-20 (Phase 25 끝)

- 판: 0.1.5 (작업 가지 ccr-ba95560e-h298t2, main 반영). Codex 0.1.4 내용을 기본으로 합침(R122①).
- 구조: 제3자 원본은 References ZIP → `Collection/upstream`(extract.py), 고친 것은 `Collection/patches/*.patch`(patches.py verify/regenerate/reapply), 배포 ZIP 은 `build.py --install [--variant fuf]` 로 게임이 읽는 파일만. 빌드 전제: Collection/upstream 추출, GNU diff/patch.
- 0.1.5 ZIP 두 개는 127MB 라 저장소에 없음(gitignore) — 다시 만들려면 위 명령. sha256 은 Step 40d 이력.
- 남은 일: Result PHASE_25 「Open Issues」·「Decision Queue」.

## 갱신 — 2026-11-26 18:45 +0900 (Phase 27 진행 중 · 세션 전환)

작업 가지 `claude/phase27-local-20261124` · 워크트리 `D:/Projects/Project_WF/_local_only/claude-phase27` · 이 갱신의 커밋 = 9769efeb(Step 72 코드 포함 · 검수 전) · GitHub 에 같은 이름 가지로 푸시함(main 에 합치지 않음).

### ⑤ 인계 사슬
1. `Codex/docs/HANDOVER_v0.1.0.md`(Codex Step 1–5) → 2. 이 파일 본문(Phase 0–25) → 3. 「갱신 — 2026-11-20」(Phase 25 끝) → 4. **이 절**(Phase 27 중간 · 이 세션은 컴팩션 여러 번 · 마지막 컴팩션 뒤 복구 읽기 기록 = `Claude/results/Step 71 — …md`).
다음 세션 읽는 순서: 이 절 → 마스터 플랜 `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 본문 → Phase 27 세부 계획서 `Claude/plans/2026-11-18-devil-forever-addon-collection-phase27-세부계획.md`(Step 51–75 표) → 최신 스텝 이력 `Claude/results/Step 74 — DevilUI 6.1 Alpha 원본 설치.md`·`Step 71 — …`·`Step 70 — …`·`Step 69 — …` → 요청 대장 `Claude/results/REQUEST_LEDGER_phase27.md`(R154–R249) → 분업 기록 `Claude/results/handoffs/phase27/`(SESSIONS.md · TRIAGE_phase27.md · brief-*.md · iter_4/work_log-60.md 「Step 64」「Step 69」「Step 72」 · iter_4/work_log-70.md).

### ① 받은 지시 (이번 세션 끝 무렵 — 원문·전 행은 요청 대장)
- R232 Musca Auras 받기 → 1.21.0 넣음, 소리 끔(`WeakAurasSaved.soundsMuted`, 처음 설치 때만).
- R233–R237 Grid2 75%·글씨 키움 · 대화창 높이 · Details 를 3번 대화창 위(도미노스 끝~화면 오른쪽 끝)에 위=어그로·아래=딜 · 글씨 키움 → Step 69.
- R238–R244 버프·디버프 두 벌 문제 → 옛 Devil 조사·제안 4종(Step 70, `Claude/results/handoffs/phase27/proposal-70-auras.md`).
- R245 「뭔 개소리야 오른쪽 위로 왜 보내.」 — 오른쪽 위(게임 기본 버프 창)로 보내는 안은 전부 거절.
- R246 「적은 적한테 걸린 디버프가 바로 위에 오게 내캐릭터는 버프가 바로 위에 오게해.」 → 제안 4종 대체(사용자가 직접 고름).
- R247 「핏불 테두리 … 저주, 독, 마법에 따라 테두리 색 … 디버프는 해제가능한것만」 → 답함: PitBull4 Aura highlight 있음(`PitBull4/Modules/Aura/Highlight.lua`, 필터 `!H`) · Step 72 에서 켬.
- R248 「테마 13종 다시 만들라했다. 다 만들엇다는데 니가 검수좀해봐」 → Step 73 (아직 안 함).
- R249 「https://www.inven.co.kr/board/wow/1636 … https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=45 … 6.1 알파 … 진짜 찐 근본 … 우리것은 백업하고 저 설치하는거 컴퓨터 유즈로 설치해봐라」 → Step 74 설치 끝(EXE 는 실행 안 함 · 정적 추출본 복사) · 포럼 글 읽기 = Step 75(아직 안 함).
- 마지막 지시: 「바로 다음 세션에서 작업이어가려고한다.」 · 「다음세션한테 넘길 준비해줘.」

### ② 작업 요약 (이번 세션)
- Step 64 Musca Auras 1.21.0 + Step 69(Grid2·Details·글씨) 커밋 77b4e898, 18:31 게임에 설치(백업 `_local_only/claude-p27-backup-fe55b18b`).
- Step 70 조사·제안 4종(365d3cad) → R245/R246 로 대체. Step 71(고쳐 쓰기) 중단 기록(cfb5d3ef).
- Step 72 코드(같은 A2 a64ebefa708243db9, 게이트 전부 통과, **검수 전**) — 대상 = 디버프가 창 바로 위·버프 그 위(`PitBull4/Modules/Aura/Layout.lua` 에 `order = "debuffs_first"` 추가, `V2.lua` 에서 대상만 사용, `patches/PitBull4.patch` 다시 만듦) · 내 캐릭터 = 버프가 바로 위(그대로) · HideBlizzard `aura` 켬(오른쪽 위 게임 버프 창·무기 강화 창 숨김) · 해제 가능한 디버프 테두리(`highlight=true`, 필터 `{'!H','','',''}`, 종류별 색, style `border`, 보통·대상·데빌 파티 · 주시·소환수는 끔) · layout revision 8→9 · 점검표 §18. 상세·영향 지도·판정 줄 = `iter_4/work_log-60.md` 「Step 72」(1356행부터) · 원 출력 스크래치 `s72.dF1D`(휘발).
- Step 74 DevilUI 6.1 Alpha 원본을 게임에 설치(SPECIAL 변형) — 지금 게임 폴더는 Devil 6.1 Alpha 상태다. 우리 것 = `Interface/AddOns.BeforeDevil61Alpha-b3cc320e` · SavedVariables 3곳 `SavedVariables.BeforeDevil61Alpha-b3cc320e` · WTF 사본·되돌리는 순서 `_local_only/claude-p27-devil61-backup-b3cc320e/RESTORE.txt` · Fonts 에 2002.ttf·2002b.ttf·K_Damage.TTF 추가.

### ③ 미완료 항목
1. **Step 72 검수** — 같은 검수 B(a5573f01b964966e2)는 이 세션과 함께 끝난다 → 다음 세션은 새 `bada-a3-reviewer` 로 P1 코드 ② 검수(대상: brief-72.md 의 파일들 + work_log-60 「Step 72」 실행 출력 절 · 「이미 정한 것」 = TRIAGE_phase27.md 머리). 고침은 새 `bada-a2-coder`. 그 뒤 Step 72 스텝 이력 파일 작성·커밋.
2. **설치 보류** — 게임은 지금 Devil 6.1 Alpha. 사용자가 그걸 본 뒤 "되돌려" 하면: RESTORE.txt 순서로 우리 것을 되돌리고 → Step 72 를 포함한 새 stage(`stage_build.py`) → `install_local.ps1 -StagedAddOns … -BackupRoot D:/Projects/Project_WF/_local_only/claude-p27-backup-<8 hex>`(백업 폴더 이름 규칙 지킬 것 · 게임 꺼진 상태).
3. **Step 73** — Codex 테마 13종 검수: `_local_only/codex-hud-redraw-20261126`(별도 저장소, 가지 `codex/hud-redraw-20261126`, HEAD 9313a13a 2026-11-26 16:26 · 커밋 727d2425→9313a13a · Codex 계획 `Codex/plans/2026-11-26-devil-forever-hud-redraw-plan.md` · 결과 `References/codex-appearance/28-devil-structure/`(artwork·final-runtime·themes_13.png·report.json) · Codex 발주문 `Collection/codex-briefs/appearance-28-devil-structure.md`). 읽기만 · 합치지 않음 · `bada-b-auditor` P4 ③.
4. **Step 75** — Devil UI 포럼(board 1636) 글 읽기, 주장마다 URL.
5. 그 뒤: Steps 54/55(릴리스, ReleaseCatalog.json 다시 쓰기 — Hekili 빼고 Musca 넣기) · Step 56 재실행 · Step 57 Phase 닫기(Result md+json, 이력, push, merge — R67).
6. 결정 대기(최종 보고에서 한 번에): Musca 1.22.0 있음 · `WeakAurasSaved` 는 `/dfp` 저장·복원에 없음 · `/wa` 창 클릭 소리·접속마다 음소거 알림 · 주술사 묶음 Maelstrom 오라 미확인 · Grid2 글씨 한 번 바꿈이 사용자가 고른 12/14/18 도 바꿀 수 있음 · revision 이 PitBull4/Quartz/Dominos/SexyMap 을 한 번 다시 씀 · Grid2 0.64 배율 원인 미확정 · fhd Details 자리 빠듯 · Details 쌓기가 오른쪽 장식과 겹침 · 대화창 높이 문제 = 테마 그림 쪽(Codex) · Step 72 결정 대기 4건(무기 강화 표시가 이제 어디에도 없음 · 두꺼운 테두리 게임 미확인 · 파티 레이아웃 없는 프로필은 테두리 값만 생김 · 대상 디버프 칸이 최악 경우 크기로 잡혀 버프가 높게 뜸) · Step 74: 판 차이(게임 Interface 16001 vs Devil 60100 — 구버전 애드온 불러오기 필요·오류 가능) · SPECIAL 선택 · Config.wtf 안 덮음.

### ④ 다음 세션 주의점
- 이 세션의 서브(A2·B·A1)는 다시 부를 수 없다 → Phase 27 같은 역할로 새 서브를 띄우고 입력 파일을 전문으로 넘긴다(SESSIONS.md 에 새 행).
- 게임 폴더는 지금 **Devil 6.1 Alpha**. 사용자 확인 전에 설치·되돌리기 하지 않는다. `AddOns.BeforeDevilForever015-3434ca83`·Codex 백업 `live-015-pitbull-backup-3434ca83`·`!BugGrabber`·`BugSack`(원본)·옛 main 워크트리·다른 `_local_only` 워크트리는 손대지 않는다.
- 내려받은 EXE·코드는 실행하지 않는다(Devil 설치기 포함 — 정적 추출본 `work/old-reference-collection-0qlzzyxg/extracted-alpha-nsis` 를 씀).
- 비밀번호·계정·인증 코드 입력 금지 · 게임 플레이(전투·이동·파티·거래·대화·시스템 설정 변경) 금지 · Hekili 코드·패치·기본값 손대지 않음 · force-push·이력 조작 금지 · `v0.1.4` 태그·릴리스 수정 금지 · 사용자가 없을 때 컴퓨터 유즈 권한 다시 요청하지 않음 · 팝업 도구 금지 · 작업 중 정리 삭제 금지(정리는 끝에 한 번 — 스크래치 `s51.*`·`s72.*` 등과 `_local_only/claude-p27-stage-*`).
- 다운로드는 사용자 직접 승인 필요(R240 은 인벤 Devil 글 첨부만).
- master effort 는 앱에서 medium.

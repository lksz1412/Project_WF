# Work log — Phase 0 Step 6 master plan draft (A1, resumed session)

Session: A1 analyst resumed after the previous A1 (aa23e937b2a56ada3) was cut off. Compaction count in this session: 0. Previous A1 reads are not in this context, so every input was read again here. Recorded 2026-11-18 ~03:13 UTC.

Output file: `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` (523 lines after this pass; started from the previous draft of 439 lines and edited, not rewritten from zero — Ground Truth, constraints, structure map, Implementation Changes, Test Plan, Assumptions and D1–D5 text were kept and amended).

## 1. Files read (full, head→tail unless noted)

| File | Lines read |
|---|---|
| `Claude/results/handoffs/master-plan/brief.md` | 1–88 (full) |
| `Claude/results/handoffs/master-plan/SESSIONS.md` | 1–9 (full) |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` (previous draft) | 1–439 (full, two windows 1–357 / 358–439) |
| `Claude/results/REQUEST_LEDGER_phase0.md` | 1–28 (full, R73–R81) |
| `References/addon-survey/features.md` | 1–286 (full, windows 1–201 / 202–286) |
| `References/addon-survey/survey.md` | 1–153 (full) |
| `References/addon-sources/INDEX.md` | 1–81 (full) |
| `Codex/results/REQUEST_LEDGER.md` | 1–91 (full) |
| `Codex/results/REQUEST_LEDGER_phase1.3.md` | 1–90 (full) |
| `Codex/results/handoffs/old-reference/R37…R72-user-message.md` | all 36 files, full (printed in one command) |
| `Codex/docs/HANDOVER_v0.1.0.md` | 1–114 (full) |
| `Codex/plans/2026-11-17-devil-ui-forever-plan.md` | 1–370 (full) |
| `Codex/results/handoffs/old-reference/r44-plan-update/master-plan-candidate.md` | 1–450 (full, windows 1–229 / 230–450) |
| `Codex/results/handoffs/old-reference/r44-plan-update/requirements-coverage.md` | 1–92 (full) |
| `Codex/results/handoffs/old-reference/r44-plan-update/root-starting-addon-facts-and-r67.md` | 1–24 (full) |
| `Codex/docs/old-devil-reference-comparison.md` | 1–192 (full) |
| `Codex/docs/forever-clean-chat-research.md` | 1–116 (full) |
| `Codex/docs/devil-ui-old-4k-layout.md` | 1–105 (full) |
| `Codex/results/old-reference/a1-r36-source-evidence.md` | 1–118 (full) |
| `Codex/docs/guimagae-addon-public-facts-2026-11-18.md` | 1–60 (full) |
| `References/forever-addons/*/SOURCE.txt` (13) and `ANALYSIS.md` (13) | all full (7 + 17–19 lines each) |
| `References/addon-sources/{profilemanager,edit-mode-expanded,blizzmove,tiptac-reborn,bagnon,baganator,platynator,titan-panel,experience-forever,mapster,kaliels-tracker,aurora,leatrix-plus,bugsack}/ANALYSIS.md` | lines 1–17 filtered to the role / scope / Forever lines only (grep) — NOT a full read; used only to name each candidate's role, which matches features.md |
| `.claude/tools/banned_lexicon.json` | first 3,000 chars (category list and confirmed entries) |

Not read (not needed for decisions): `Codex/results/old-devil-layout/*`, V42 Lua bodies (only names searched, see §2).

## 2. Commands run and verdict lines

| Command (read-only unless noted) | Verdict |
|---|---|
| `wc -l` on brief inputs; `git log --oneline -3`; `git branch --show-current` | branch `ccr-ba95560e-h298t2`, HEAD `8d3f7d4` |
| `find References/forever-addons -maxdepth 2 -type f` | 13 folders, each ZIP + SOURCE.txt + ANALYSIS.md |
| For each start/candidate ZIP: `unzip -Z1` + `unzip -p <toc> | grep '^## Interface'` (no extraction) | 16001 present in: all 13 required (Details via `Details_Camelot.toc`), TipTac (`TipTac_Forever.toc`), Bagnon, Baganator, Platynator, Titan, Experience Forever, Mapster, Leatrix Plus, Kaliel's Tracker, BugSack, BugGrabber, XLoot, BlizzMove, TellMeWhen, Myslot, ProfileManager, Font Manager, Aurora, Edit Mode Expanded, BasicMinimap, LS Toasts, SpeedyAutoLoot, NugComboBar (Camelot), Questie (Forever/Camelot), VuhDo (Camelot), Skada (Forever/Camelot), ThreatClassic2, Bartender4. Reflux 1.17 upstream = 60000. kgPanels 1.4.7 upstream = no 16001 |
| `unzip -Z1 … | grep -i licen` | LICENSE files present: Chattynator, Dominos, Grid2, Hekili, Masque, Platynator, Baganator, Titan, TellMeWhen, XLoot, Aurora, Myslot, VuhDo, Questie, ThreatClassic2. Absent: Forever Unit Frames, ForeverThreat, Quartz, SexyMap, Masque Onyx, Bagnon, Mapster, Leatrix, Kaliel, BugSack, ProfileManager, Edit Mode Expanded, BlizzMove. Details only under Libs/. File names only; contents not read |
| `unzip -Z1 Hekili…zip` folder list | 9 class modules: Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock, Warrior (+Hekili, Hekili_Shared) |
| `unzip -Z1 Dominos-12.0.4.zip` folders | Dominos, Dominos_Cast, Dominos_Config, Dominos_Progress, Dominos_Roll, Masque_Dominos; Dominos_Progress TOC has 16001 |
| `unzip -Z1 ProfileManager.zip` | files include Providers.lua, Addons.lua, Keybinds.lua, GameSettings.lua, Presets.lua |
| TOC header loop over V42 `Interface/AddOns/*/` | 33 addons, all with 16001; list recorded in plan Ground Truth |
| `grep -n -i chocolate|tiptac|mapster|…` on V42 `!DevilUI.lua`, `minimap.lua`; `ls !DevilUI/Profile` | `!DevilUI.lua:7–45,164–187,222–237,1222–1223,1365–1372,1500–1503` name these SavedVariables; Profile folder has 15 profile files (ChocolateBar, TipTac, Mapster, Leatrix_Plus, BugSack, Broker_XPBar, Plater, Questie, …). Name search only, not a full read |
| `python3 -c "import lupa"` | ModuleNotFoundError — still not installed |
| `git ls-files` counts | V42 extracted 1,831 files tracked; References 311; SourceArchive 4,627 — these persist across sessions |
| `unzip -Zt` on 13 ZIPs; `du -sh` | References/forever-addons 23M, addon-sources 206M; Details largest (747 files, 47 MB uncompressed) |
| `cat .gitignore` | `work/`, `SourceArchive/`, `MacroLibrary/` are ignored yet tracked (force-added by Codex); no `Collection/` rule yet |
| Python sum of Step estimates | Step 6–61 = 3,930–6,585 min; Phase 12–19 = 870–1,425; without them 3,060–5,160; per class 45–85 → 9 classes 405–765; two default-excluded optional phases 180–285 |
| `grep` banned lexicon words on the plan | one hit inside the word `수정본`; replaced by `고친 판` (sed, 3 places) and one doubled phrase fixed with Edit. Re-grep: no hits |
| Python rewrite of the outline tree block only | tree now lists every Step with its estimate (brief §5 requirement) |

No network call, no extraction to disk, no file outside the two owned files was written (the `iter_1/` folder was created for this log).

## 3. Brief §2 list vs user originals

- All items in brief §2 match the originals (R44–R65 files, ledger rows R13–R17, R21–R25, R32–R34, R73).
- Nuance not in the brief list: R45 original also says 「외관이랑 채팅은 직접 만들더라도」; later R63 replaced that with "start addon first, develop only what fails". The plan follows R63.
- R1 original first message is not stored in the repo; only the Codex ledger summary (`Codex/results/REQUEST_LEDGER.md:5`: 단축키·체력/마나·미니맵, 「부가 기능 제외」). The plan quotes it as a Codex summary and explains how R44/R45/R60/R61/R77 widened scope (verbatim quotes taken from R44/R45/R60/R61 files and the R77 ledger row).
- R50 original names 「공격대프레임 애드온」 explicitly, so the raid phase is user-backed (a), not only Codex's choice.
- R76 asked for a Haiku sub survey; the delivered `survey.md`/`features.md` were produced by Codex after R80 (folder `References/addon-survey/`), so the plan labels them 「Codex 기록」. Ledger R76/R77 「반영 위치」 still points to `Claude/results/handoffs/addon-survey/…` — see Decision Queue 4.

## 4. Codex candidate: dropped / changed, with reasons

| Codex candidate element | In this plan | Reason |
|---|---|---|
| Phase 3.4/3.5 live-game Steps 41–46 | Per-phase user PC checklists + Phase 25 | Container cannot run the game; user checks after work (R46) |
| Variables N/T/V/G/U in estimates | "per class X min" with a 9-class example | Brief §5; Hekili ZIP has 9 class modules |
| Phase 1.2 Step 6–7 (requirements / start-product manifest) | Phase 1 Steps 8–11 | Sources are now received (R81); manifest is machine-built |
| 3.1 integration + 3.2 fix as two phases | Phase 23 (two Steps) | Same work unit; fewer phases |
| Reflux as save/restore start | ProfileManager v4.0 (Reflux V42 as comparison) | Forever file confirmed, per-addon selective apply; Reflux upstream TOC 60000 and V42 global-switch risk (Codex record). Coverage of our addons unknown → Step 50 |
| Texture upgrade inside theme phase | Phase 2 Step 14 | Base theme texture must be fixed before skins reuse it |
| Save/edit before raid/meters | After all feature phases (20–21) | They register every addon's settings |
| 13 features only | + 8 optional phases (12–19), 2 default-excluded, exclusion table | R77; default rule = ≥5/8 packages or already in V42 (R47), automation excepted by R1 |
| Requirements coverage table (72 rows) | Not reproduced; constraint table + ledger | Readability (brief §1); see Decision Queue 1 |
| Timestamp paragraphs, R17 macro paragraph, ImageGen mention | Dropped; Correction History points to Codex location | Brief §5 length rule; no image-generation tool decided |
| Old D1 (PC check + Hekili range together) | Split into D1 and D2; D3 chat, D4 license, D5 GitHub, D6 R13, new D7 feature set, D8 Codex research request | One question per item; R77/R80 |
| Source-waiting fallback column and long defer rule | Short exception rule | R81 sources received |

## 5. Decision Queue (for master — not user decisions)

1. Whether a separate requirement trace (R1–R81 → Phase/Step) file is wanted; the plan itself no longer carries the 72-row table.
2. Plan length is 523 lines (brief target 350–500 "안팎"); the tree expansion to one line per Step added ~45 lines. Trimming candidates: exclusion table, Test Plan rows.
3. D-numbers changed (old D1–D5 → new D1–D8). Any master notes or ledger rows referring to old D numbers need updating.
4. Ledger R76/R77 「반영 위치」 paths (`Claude/results/handoffs/addon-survey/…`) differ from the actual files (`References/addon-survey/…`).
5. ProfileManager coverage of our addons is unknown (Providers.lua / Addons.lua not read). If it covers little, Phase 20 grows (new-development share) — re-estimate at Step 50.
6. Info bar start: Titan Panel chosen by the "Forever-confirmed" rule; V42 ChocolateBar has DevilUI profile integration. R48 comparison is planned in Step 42; Codex request ① in D8 if a current ChocolateBar Forever file is wanted.
7. Phase 1 Step 9 will add one `.gitignore` line for `Collection/upstream/` — a root file change; master should confirm it is acceptable under the GO.
8. License contents (not just file presence) are unread; D4 default relies on Step 8 reading them.
9. URL reality of the 71 sources is unverified in this container (Codex record only).
10. Outline tree Phase 2 lines are not column-aligned (cosmetic).

## 6. Remaining work at return

- Independent review (B) of the plan (P5, ③ structure, 10 rounds) — Step 7.
- User review and answers to D1–D8, then renumbering if D7 changes the phase set — Step 7.
- No other A1 work pending.

## 검증 1 고침 (같은 A1 · 2026-11-18 · 처리표 M1–M9 + 경미 2)

Inputs re-read in full this round: `Claude/results/handoffs/master-plan/iter_1/audit_log.md` 1–160, `Claude/results/handoffs/master-plan/TRIAGE_phase0.md` 1–26, plan 85–523 (lines 1–84 = outline tree, written by this A1 earlier in this same context and re-checked by script). Cited lines were opened in the plan before editing (220, 226, 238, 239, 247, 253–261, 269–272, 288, 296, 305, 337, 372, 419, 469–471, 486–489, 512–521). Extra facts checked: `find Devilconfig !DevilUI -iname '*licen*'` → only `ACE3-LICENSE.txt` ×2; V42 AddOns folder count = 32; TOC `## Notes` of RangeDisplay, SkillUpForever, AdvancedInterfaceOptions, shPerformance, Broker_Money, Broker_Guild_Friends; `Codex/plans/2026-11-17-devil-ui-forever-plan.md:120` (자동 key mapping in Codex Non-goals). Scratch copy of the pre-fix plan: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_fix1.md`.

### 영향 지도

| 곳 (새 줄) | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 291 바꾼 곳 5 (기본값 규칙) | M1 대상 | 처리표 | 함께 고침 | 규칙을 ①(5/8 이상 또는 V42 동봉)·②(Forever 확인 시작 애드온) 와 예외 세 가지로 밝힘 |
| 246–247 D6 기본 제외 표 | 같은 규칙의 적용 자리 | 전문 정독 | 함께 고침 | 두 행을 「규칙 ① 에 걸리는 예외」 로 표시, 전리품 이유 보강 |
| 253 제외 표 버프·디버프 | 같은 규칙 | 전문 정독 | 함께 고침 | 규칙 예외로 표시 |
| 261–262 제외 표 AFK | 같은 규칙 (B 지적) | 전문 정독 | 함께 고침 | AFK 를 따로 떼어 「5/8 이지만 ② 미충족」 |
| 267–284 V42 동봉 애드온 분류 표 (새) | V42 32개 미분류 | ls + 스크립트 대조 | 함께 고침 | 32개 모두 분류, 기계 검사 missing 0 |
| 514 D6 내용 | 같은 규칙을 사용자에게 보이는 자리 | 전문 정독 | 함께 고침 | V42 분류 표 제외 항목도 고를 수 있다고 추가 |
| 132 Ground Truth V42 행 | 같은 사실 | 전문 정독 | 확인만 | 판 목록 그대로 맞음 |
| 489–492 D2 | M2·M3 대상 | 처리표 | 함께 고침 | 선택지 (다) 삭제, 상태 알림·CD 는 늘 Phase 8, Hekili 상태 알림은 제작자 선언·미검증으로 낮춤 |
| 226 기능 표 Phase 8 | 같은 전제 | 전문 정독 | 함께 고침 | 상태 알림·CD 가 모자라면 보완 모듈 `DevilForever_Combat` 로 같은 Phase 안 제한 개발, 한 기능으로 묶음(R44) |
| 462 Assumptions | M3 | 처리표 | 함께 고침 | 새 전제 행 추가 |
| 418 Test Plan Phase 8 | 같은 전제 | 전문 정독 | 함께 고침 | 가변 ③ 을 상태 알림·CD 빈 칸 검사로 |
| 108 Summary 「상태 알림과 CD 는 한 애드온」, 254 제외 표 CD 행 | 같은 뜻 | 전문 정독 | 확인만 | 그대로 맞음 |
| 원래 D5 (GitHub) 단락 | M4 대상 | 처리표 | 함께 고침 | 결정 항목에서 삭제 |
| 176 늘 지킬 제약 GitHub 행 | 같은 뜻 | 전문 정독 | 함께 고침 | R67 사실로: Phase 끝마다 작업 가지를 main 에 일반 push, 강제 push·이력 수정 없음 |
| 535 멈출 일 「푸시·외부 게시」 | 같은 뜻 | 전문 정독 | 함께 고침 | 같은 사실로 |
| D6–D8 → D5–D7 모든 참조 (28줄: 53, 104, 114, 166, 171, 216, 242, 254, 263, 281, 283, 297, 347, 352, 368–375, 508, 513, 519, 529, 538 등) | 번호 참조 | regex 전수 + 맥락 출력 확인 | 함께 고침 | 기계 치환 뒤 문맥을 한 줄씩 확인 |
| 476 Correction History R76–R81 행의 「D7·D8 추가」 | 기록 | 전문 정독 | 영향 없음(기록) | 그 당시 원본 기록 — 고치지 않음 |
| 141 Ground Truth GitHub 공개 행 | Codex 기록 | 전문 정독 | 영향 없음(기록) | Codex 시기 관찰 기록 |
| 238 기능 표 Phase 20 | M5 대상 | 처리표 | 함께 고침 | R17 삭제, 키·게임 설정을 R44 범위에 넣음(사용자가 고를 때만 복원) |
| 307 Non-goals 「키 자동 배정 (R17)」 | M5 연결 | 처리표 | 함께 고침 | 매크로 R14–R17 / 키 자동 배정은 R10·Codex 기록 `devil-ui-forever-plan.md:120` 로 근거 분리 |
| 424 Test Plan Phase 20 가변 ⑤ | 같은 뜻 | 전문 정독 | 함께 고침 | 「고르지 않은 범위 불변·매크로 미접촉」 |
| 393 Interfaces 저장·복원 행 | 같은 뜻 | 전문 정독 | 확인만 | 등록 변수만 다룬다는 약속과 충돌 없음 |
| 505–506 D4 | M6 대상 | 처리표 | 함께 고침 | V42 !DevilUI·Devilconfig 예외(고쳐 쓰고 공개 배포는 Phase 23), 대안 (가′) 와 비용 |
| 220·239 기능 표 Phase 2·21 쓰는 방식 | 같은 뜻 | 전문 정독 | 함께 고침 | 「D4 의 V42 예외」 표시 |
| 325 고치는 방식 4 (라이선스 허락 제품만) · 397 Interfaces 설치용 ZIP | 같은 규칙 | 전문 정독 | 확인만 | V42 예외는 D4 안에서 처리되어 모순 없음 |
| 391 Interfaces 등록 규약 | M7 대상 | 처리표 | 함께 고침 | 연결 폴더가 대신 등록, 등록하려고 원본을 고치지 않음 |
| 315 모음집 구성 개별 기능 애드온 | M7 연결 | 처리표 | 함께 고침 | 연결 폴더가 외관 연결과 Core 등록을 함께 맡음 |
| 324 고치는 방식 3 | M7 연결 | 처리표 | 함께 고침 | Core 등록도 연결 폴더 |
| 288 바꾼 곳 2 「각 기능 Phase 가 자기 설정을 등록」 | 같은 뜻 | 전문 정독 | 함께 고침 | 「연결 폴더로」 |
| 332 앞 Step 「등록할 항목」 | 같은 뜻 | 전문 정독 | 확인만 | 누가 등록하는지와 무관 |
| 220 기능 표 Phase 2 질감 문장 | M8 대상 | 처리표 | 함께 고침 | 컨테이너 렌더 = 1차 판정, PC 확인 뒤 확정, 렌더만으로 「개선 불요」 닫지 않음 |
| 24 목차 Step 14 | 같은 뜻 | 전문 정독 | 함께 고침 | 「질감 1차 평가(PC 확인 뒤 확정)」 |
| 438 검증 나눔 Phase 2 | M8 대상 | 처리표 | 함께 고침 | 컨테이너 칸에 1차 판정, PC 칸에 실제 배율 질감·흐림 |
| 287 바꾼 곳 1 (질감을 Step 14 로) · 538 이 환경 실측 불가 | 같은 주제 | 전문 정독 | 확인만 | 위치 결정은 그대로 유효 |
| 297 원천이 모자랄 때 | M9 대상 | 처리표 | 함께 고침 | R31: 지금은 PC 연결 없어 못 씀, Codex 가 대신, PC 연결되면 다운로드 한정 유효 |
| 173 늘 지킬 제약 원천 행 | 같은 뜻 | 전문 정독 | 함께 고침 | R31 조건 한 줄 |
| 520 D7 (Codex 조사 요청) 내용 | §11 원천 확보 자리 | 처리표 | 함께 고침 | R31 을 쓸 수 없는 이유 |
| 538 멈출 일 「원천 부족」 | §11 원천 확보 자리 | 처리표 | 함께 고침 | R31 사용 조건 |
| `Claude/results/REQUEST_LEDGER_phase0.md` R31 행 | 대장 | 처리표 | 확인만 | 상태 갱신은 master 몫 |
| 356 Phase N 표 Phase 0 상태 | 경미 2 | 처리표 | 함께 고침 | 「Step 6 끝 · Step 7 진행 중」 |
| 352 「아래 경로는 아직 없는 파일이다」 | 경미 2 연결 | 전문 정독 | 고치지 않음 | 처리표: 세부 계획서는 master 가 만든다 · 처리표 밖 경미 |
| 477 Correction History 새 행 | 기록 추가 | — | 함께 고침 | 이번 고침의 기록 |

### 판정 줄

- python (tree regex): Steps 56 (6–61, gaps 0); total 3930–6585; Phase 12–19 870–1425; without them 3060–5160 — unchanged from before (M1 changed no Phase; D4 (가′) adds 60–120 per Phase only if chosen, stated in D4 only).
- V42 classification coverage script: 32 folders, missing [].
- D references after renumbering: D5 = R13 only, D6 = feature set, D7 = Codex request; no remaining reference to the removed GitHub decision except the record row 476 and the new history row 477.
- Banned-lexicon grep: no hits.
- Plan length 540 lines (was 523).

Not changed (per triage): the other 11 minor findings.

## 재검증 1 고침 (같은 A1 · N1–N3)

Read in full: `TRIAGE_phase0.md` 「재검증 1」 section. Opened the cited plan lines before editing: 24–42 (tree), 104, 108, 158, 176, 220, 226, 239, 271, 288, 297, 302–304, 325, 397, 418, 462, 486–506, 535. New fact checked: V42 `kgPanels/kgPanels.toc` has `## X-License: All Rights Reserved` (Author kagaro); kgPanels and kgPanelsConfig carry only `ACE3-LICENSE.txt`. Scratch copy before this round: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_fix2.md`.

### 영향 지도 (고치기 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 226 기능 표 Phase 8 (쓰는 방식·하는 일) | N1 대상 | 처리표 | 함께 고침 | `DevilForever_Combat` = 표시 전용(남은 시간·CD·proc 아이콘), 추천·판단·회전 로직 없음, Hekili 와 「전투보조」 한 묶음 |
| 42 목차 Step 26 | N1 (Step 26 예상) | 처리표 | 함께 고침 | 보완 모듈이 필요하면 +60–180분 (조건부) |
| 104 예상 시간 합계 문장 | 같은 수치 | 전문 정독 | 함께 고침 | 조건부 추가분 목록에 보완 모듈 60–180분 |
| 303 Non-goals 자체 rotation | N1 대상 | 처리표 | 함께 고침 | 표시 전용 보완 모듈은 이 금지에 들지 않는다는 경계 |
| 302 Non-goals 같은 기능 두 애드온 | 같은 뜻 | 전문 정독 | 함께 고침 | Hekili 와 보완 모듈은 역할을 나누고 함께 켜고 끄는 한 묶음이라 이 금지와 충돌 없음을 한 구절로 |
| 108 Summary 「한 애드온이 맡는다」 | N1 대상 | 처리표 | 함께 고침 | 「한 기능(전투보조 묶음)」 으로 뜻 맞춤 |
| 158 늘 지킬 제약 | N1 대상 | 처리표 | 함께 고침 | 같은 뜻 |
| 462 Assumptions Hekili 상태 알림 | 같은 뜻 | 전문 정독 | 함께 고침 | 「표시 전용」 보완 모듈 |
| 418 Test Plan Phase 8 | 같은 뜻 | 전문 정독 | 함께 고침 | ③ 에 보완 모듈에 판단 로직이 없는지 |
| 490 D2 내용 | 같은 뜻 | 전문 정독 | 확인만 | 「Phase 8 이 맡는다」 — 묶음 정의와 충돌 없음 |
| 254 제외 표 CD 행 「Hekili 쪽 한 애드온」 | 같은 뜻 | 전문 정독 | 확인만 | 「Hekili 쪽」 이라 묶음 포함으로 읽힘 |
| 501–506 D4 | N2·N3 대상 | 처리표 | 함께 고침 | 사실(R67–R69: Phase 끝 main 반영 때 `Collection/` 의 고친 판도 공개)을 적고, 질문을 「고친 제3자 코드를 공개 저장소에 그대로 둘지」 로; 선택지별 main 반영과의 관계; V42 예외에 kgPanels·kgPanelsConfig(ARR 표기) 추가 |
| 176 늘 지킬 제약 GitHub 행 | N2 대상 | 처리표 | 함께 고침 | main 반영에 고친 판도 들어간다는 사실과 D4 연결 |
| 535 멈출 일 푸시·외부 게시 | N2 대상 | 처리표 | 함께 고침 | 「고친 판 공개 범위를 Phase 23 에서 정리」 는 사실과 어긋나므로 「무엇을 고칠지는 D4, Phase 23 은 설치 ZIP 범위만」 |
| 397 Interfaces 설치용 ZIP · 325 고치는 방식 4 | 같은 규칙 | 전문 정독 | 확인만 | 설치 ZIP·라이선스 허락 제품만 — 새 D4 와 맞음 |
| 220 기능 표 Phase 2 | N3 대상 | 처리표 | 함께 고침 | 「D4 의 V42 예외 — !DevilUI·kgPanels」 |
| 239 기능 표 Phase 21 | 같은 뜻 | 전문 정독 | 확인만 | Devilconfig 는 이미 예외 표기 |
| 271 V42 분류 표 Phase 2 행 | N3 대상 | 처리표 | 함께 고침 | !DevilUI·kgPanels·kgPanelsConfig 는 D4 V42 예외로 고쳐 씀, Masque·Onyx 는 받은 최신판 스킨으로만 |
| 131 Ground Truth 라이선스 파일 행 | 같은 사실 | 전문 정독 | 확인만 | 받은 ZIP 기준 실측 행 — V42 사실은 D4 에 적음 |
| 476–477 Correction History 기존 행 | 기록 | — | 영향 없음(기록) | 새 행만 추가 |
| `REQUEST_LEDGER_phase0.md` | 대장 | 처리표 | 확인만 | master 몫 |

### 판정 줄

- python (tree regex): Steps 56 (6–61, gaps 0); fixed total 3930–6585 unchanged; Step 26 fixed 90–150 unchanged — the support module is a conditional +60–180 written in the tree (Step 26) and in the total sentence (line 104), like the texture and per-class extras.
- Banned-lexicon grep: no hits. Plan length 544 lines.
- New fact used: V42 kgPanels TOC `X-License: All Rights Reserved` — written into D4.
- Not changed (per triage): minor 1·3·4·5·6.

## 재검증 2 고침 (같은 A1 · N1′ 원인 수정)

Read in full: `TRIAGE_phase0.md` 「재검증 2」 section. Opened plan lines 40–43, 104, 108, 158, 226, 253–254, 302–303, 418, 462, 489–494 before editing. Root cause per master: the R62 ban and the "what to display" list were one lump, so a default watch list read as banned. Fix = narrow the definition of the banned thing itself, not add sentences. Scratch copy before this round: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_fix3.md`.

### 영향 지도 (고치기 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 226 기능 표 Phase 8 | N1′ 대상 (정의를 두는 한 곳) | 처리표 | 함께 고침 | 금지 = 「무엇을 언제 쓰라고 정하는 추천·판단·회전 로직」, 허용 = 특성별 오라·proc·CD 정적 표시 목록; 목록 출처 ①→②→③; EventAlert 식 알림(중앙 아이콘·소리·강조, 끌 수 있게); Step 25 첫 확인 항목 |
| 303 Non-goals | N1′ 대상 | 처리표 | 함께 고침 | 금지 문장 자체를 좁힌 정의로 교체(덧댄 예외 문장 삭제) |
| 158 늘 지킬 제약 | N1′ 대상 | 처리표 | 함께 고침 | 「자체 rotation 엔진」 → 좁힌 정의 |
| 418 Test Plan Phase 8 ③ | N1′ 대상 | 처리표 | 함께 고침 | 검사 기준을 같은 정의로 |
| 462 Assumptions | N1′ 대상 | 처리표 | 함께 고침 | 보완 길 = 정적 표시 목록 ①→③, 감시 데이터 꼴은 Step 25 첫 확인 |
| 41 목차 Step 25 | 같은 뜻(지도 밖 연결) | 처리표 | 함께 고침 | 첫 확인 항목을 Step 이름에 |
| 42 목차 Step 26 | 시간 | 처리표 | 함께 고침 | 기본 목록을 새로 만들 때 직업 하나당 +15–30분(조건부) |
| 104 합계 문장 | 같은 수치 | 전문 정독 | 함께 고침 | 조건부 추가분에 같은 값 |
| 490 D2 내용 | 같은 뜻(경미 3 함께) | 전문 정독 | 함께 고침 | 상태 알림이 EventAlert 식으로 보인다는 점 |
| 108 Summary · 302 Non-goals 중복 금지 | 같은 주제 | 전문 정독 | 확인만 | 「표시 보완 모듈」·「한 묶음」 표현이 새 정의와 충돌 없음 |
| 253·254 제외 표 버프·CD 행 | 같은 주제 | 전문 정독 | 확인만 | Phase 8 이 맡는다는 표현 그대로 맞음 |
| 478 Correction History 이전 행 | 기록 | — | 영향 없음(기록) | 새 행만 추가 |

Time judgment: Step 25's fixed 90–150 already covers reading Hekili class modules, and the data-shape check is part of that read → no change. Writing per-spec default lists happens only when Hekili lacks the data and scales with class count → conditional +15–30 min per class on Step 26, not fixed.

### 판정 줄

- python (tree regex): Steps 56 (6–61, gaps 0); fixed total 3930–6585 unchanged; Step 25 = 90–150, Step 26 = 90–150 fixed. New conditional on Step 26: +15–30 min per class when per-spec default lists must be built (also written in line 104).
- No other place still states the old lumped ban: `grep rotation` → only the narrowed Non-goal line 303.
- Banned-lexicon grep: no hits. Plan length 545 lines.
- Not changed (per triage): minor 1·2·4.

## 재검증 3 고침 (같은 A1 · 진동 → 공통 원인 수정 · N1″a·N1″b·경미 1)

Read in full: `TRIAGE_phase0.md` 「재검증 3」 section. Opened plan lines 41–42, 104, 108, 158, 226, 302–304, 395, 418, 462–463, 492, 520–525 before editing. Common cause per master: the plan fixed a mechanism before Step 25 could know the facts. Fix = state only "확인 → 갈림길 → 갈래별 원천·검사" and close the no-source case with an exit that invents nothing. 226 is rewritten as a whole (not appended). Scratch copy before this round: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_fix4.md`. Note: triage 「520」 = the D7 content line, now 525 (D6 근거 is 520).

### 영향 지도 (고치기 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 226 Phase 8 「쓰는 방식」·「하는 일」 | N1″a·b 대상 (정의 한 곳) | 처리표 | 함께 고침 (통째 다시 씀) | Step 25 두 확인(감시 데이터·알림 꼴) → 갈래 1·2·3; 목록이 필요한 특성 = Step 11 표; 출처 ① Hekili → ② D7 자료 → ③ 「원천 없음」 표시·사용자 칸·최종 보고; R62 경계 유지 |
| 41 목차 Step 25 | 같은 뜻 | 처리표 | 함께 고침 | 두 확인 항목과 갈래 판정 |
| 42 목차 Step 26 | 경미 1 (목록 작성 Step 한 곳) | 처리표 | 함께 고침 | 목록 작성은 Step 26 한 곳, 조건부 시간은 갈래로 표시 |
| 104 합계 문장 | 같은 수치 | 처리표 | 함께 고침 | 42 와 같은 조건부 값·같은 Step |
| 395 Interfaces 직업 목록 | N1″a 연결 | 처리표 | 함께 고침 | Phase 8 이 이 표의 특성을 기준으로 목록 필요 특성을 정함 |
| 418 Test Plan Phase 8 ③ | N1″a·b 검사 | 처리표 | 함께 고침 | 알림 꼴 확인 · 빈 칸 = 「원천 없음」+D7 기록이면 통과, 지어낸 목록이면 실패 · 판단 로직 없음 |
| 462 Assumptions Hekili 상태 알림 | 같은 뜻 | 처리표 | 함께 고침 | Step 25 두 확인 → 갈래로 |
| 463 Assumptions 전 직업 지원 | 같은 뜻 | 처리표 | 함께 고침 | 지원 안 되는 특성은 갈래 3 출구로 |
| 492 D2 내용 | N1″b 약속 | 처리표 | 함께 고침 | EventAlert 식 꼴이 Hekili 에 없으면 갈래 2 의 보완 모듈이 맡는다 |
| 304 Non-goals Retail 지어내기 | N1″a 출구와 연결 | 처리표 | 함께 고침 | 주문·오라 목록도 포함, 원천 없으면 「원천 없음」 |
| 525 D7 내용 | N1″a 출처 ② | 처리표 | 함께 고침 | 요청 후보에 Phase 8 갈래 3 의 Forever 주문·오라 자료 추가 |
| 158 늘 지킬 제약 · 303 Non-goals | R62 경계 | 전문 정독 | 확인만 | 정의는 그대로 맞음 |
| 108 Summary · 302 Non-goals | 묶음 표현 | 전문 정독 | 확인만 | 「표시 보완 모듈」·「한 묶음」 충돌 없음 |
| 253·254 제외 표 | 같은 주제 | 전문 정독 | 확인만 | Phase 8 이 맡는다는 표현 유지 |
| 539·543 멈출 일 | 원천 부족 일반 규칙 | 전문 정독 | 확인만 | 일반 규칙과 Phase 8 출구가 같은 방향 |
| Correction History 이전 행 | 기록 | — | 영향 없음(기록) | 새 행만 추가 |

### 판정 줄

- python (tree regex): Steps 56 (6–61, gaps 0); fixed total 3930–6585 unchanged; Step 25 = 90–150, Step 26 = 90–150 fixed. Conditionals are now tied to the branches (갈래 2·3 → module 60–180; 갈래 3 → per-class list 15–30 min written in Step 26 only), same values in line 42 and 104.
- Old wording check: no remaining 「특성별 기본 목록」 or 「Step 25 에서 원천(게임…」 (list writing now only in Step 26).
- Banned-lexicon grep: no hits. Plan length 546 lines.
- Not changed (per triage): minor 2.

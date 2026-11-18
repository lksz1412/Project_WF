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

## R83 반영 (사용자 결정: 「D4 만 나. 나머지는 전부 기본값.」)

Read: `Claude/results/REQUEST_LEDGER_phase0.md` R83 row (user original quoted above); plan lines 1–4, 53, 104, 166, 176, 216, 220, 228–229, 239, 242, 271, 281, 283, 296–310 (Non-goals), 325, 352, 368–375, 397, 420, 467, 482–546 (Decisions Required + stop table) read in full before editing. `grep 재배포|라이선스|D4|D6|(가′)|우려|답에 따라` used afterwards to confirm coverage. Scratch copy before this round: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_r83.md`.

Principle kept (master note): D4 (나) removes "can't modify because of license"; it does not widen modification. 「고치는 방식 1–4」 and R63 stay; license contents are still read in Step 8 and recorded in manifest.

### 영향 지도 (고치기 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 3 머리 상태 줄 | 상태 | 지시 | 함께 고침 | 「사용자 결정 반영(R83) · 명시 GO 대기」 |
| 482–546 Decisions Required D1–D7 | 결정 기록 | 지시 | 함께 고침 | 각 D 를 「결정: …(R83)」 로, 열린 질문 없음, D4 는 (나)·설계 원칙 유지·(가′) 삭제 |
| 220·239·271 기능 표·V42 분류 「D4 의 V42 예외」 | D4 (가) 전제 | grep + 정독 | 함께 고침 | 예외 개념이 없어짐 → 표기 삭제(고쳐 쓰는 근거는 R47·R63 그대로) |
| 228·229 Phase 10·11 「(D4)」 | D4 (가) 전제 | grep + 정독 | 함께 고침 | 통째 사용 + 스킨 연결, 원본 수정은 「고치는 방식 4」 의 경우만 |
| 325 고치는 방식 4 「라이선스가 허락하는 제품만(D4)」 | D4 (가) 전제 | grep | 함께 고침 | 라이선스는 이 판단을 막지 않음(R83), 1–3 우선은 그대로 |
| 397 Interfaces 설치용 ZIP 「D4 가 막는 제품의 원본은 넣지 않는다」 | D4 (가) 전제 | grep | 함께 고침 | 고친 판은 넣음, 고치지 않은 제3자 원본을 함께 넣을지는 Phase 23 |
| 420 Test Plan Phase 10·11 ③ 「원본 무수정」 | D4 (가) 전제 | grep | 함께 고침 | 「1–3 으로 되는데 원본을 고쳤는지 (적대)」 |
| 467 Assumptions 옛 원형 자산 「D4 와 함께 판단」 | D4 (가) 전제 | grep | 함께 고침 | 라이선스 때문에 막지 않음·위험 사용자 감수·내용은 manifest 기록 |
| 176 늘 지킬 제약 GitHub 행 | D4 연결 | 정독 | 함께 고침 | main 반영에 고친 판도 라이선스와 관계없이 들어감(R83) |
| 540 멈출 일 「원래 있던 결함」 | D4 연결 | 지시 | 함께 고침 | 라이선스는 manifest 기록만·최종 보고에 목록 |
| 541 멈출 일 「푸시·외부 게시」 | D4 연결 | 지시 | 함께 고침 | 같은 사실 |
| 53·216 「D6 의 답으로 확정」 | D6 미결 전제 | grep | 함께 고침 | 「D6 결정(R83)으로 확정」 |
| 104 합계 문장 「D6 에서 빼면 …·두 개를 더 고르면 …」 | D6 미결 전제 | 정독 | 함께 고침 | 결정됐으므로 두 조건부 문장 삭제 |
| 166 늘 지킬 제약 R77 행 「애매 → 결정 대기 · D6」 | D6 미결 전제 | grep | 함께 고침 | 「작업 한정 · D6 결정(R83)」 |
| 242·281·283 기본 제외 표 제목·V42 분류 | D6 미결 전제 | grep | 함께 고침 | 「만들지 않음(R83) — 나중에 사용자가 고르면 붙인다」 |
| 352 Phase N 설명 「D6 의 답에 따라 Step 7 에서 다시 매긴다」 | D6 미결 전제 | grep | 함께 고침 | 번호 확정 |
| 368–375 Phase N 상태 「대기 (D6)」 | D6 미결 전제 | grep | 함께 고침 | 「대기」 |
| 226 「표시 범위는 D2」, 222 「D3」, 327·347 「D1」, 171·347 「D5」 | 참조 | grep | 확인만 | 결정된 D 를 가리키는 참조로 그대로 유효 |
| 297·526·538·543 「D7 형식」 | 참조 | grep | 확인만 | D7 결정 (가) 와 같은 뜻 |
| 131·137 Ground Truth 라이선스 행, 189·390·409 manifest 라이선스 | 사실·기록 항목 | grep | 확인만 | 정보 기록용으로 유지(지시) |
| 302–309 Non-goals | 무단 재배포 문구 | 정독 | 확인만 | 해당 문구 없음 |
| Correction History 이전 행 | 기록 | — | 영향 없음(기록) | 새 행만 추가 |
| `REQUEST_LEDGER_phase0.md` R83 행 | 대장 | — | 확인만 | 상태 갱신은 master |

### 판정 줄

- Total check: the only D4-related time was the (가′) conditional (+60–120 per Phase 2·21), which existed only in the D4 text and is now removed with (가′). The D6 conditionals (without Phase 12–19 → 3,060–5,160; two default-excluded features +180–285) were removed from line 104 because D6 is decided. Fixed total unchanged.
- python (tree regex): Steps 56 (6–61, gaps 0); total 3930–6585 — unchanged.
- Stale wording grep (`V42 예외`, `(가′)`, `우려`, `답에 따라`, `답으로`, `(D6)`, `기본값:`, `선택지:`, `D4 가 막`, `원본 무수정`, `D4 와 함께`) outside Correction History: 0 hits.
- Banned-lexicon grep: no hits. Plan length 532 lines.

## R86 반영 (사용자: 「실사용 검증은 코덱스가 할거야. 너는 작성만해. 코드 논리 검수까지만하고.」)

Read: ledger R86 row (with master's interpretation: syntax check belongs to logic review; harness = real-use side → removed). Plan lines read in full before editing: 14–19, 92–104, 114, 172, 191–192, 220, 265, 282, 306, 333–348, 381, 396, 405–453, 460–468, 487–489, 505, 523–528, plus `grep harness|PC 확인|확인 목록|사용자 PC|퇴근|checklists|실측 불가|Step 10|BugSack` for coverage. Scratch copy before this round: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_r86.md`.

### 영향 지도 (고치기 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 18 목차 Step 10 harness | 대상 | 지시 | 함께 고침 (삭제) | harness 는 실사용 검증 쪽(R86 · master 해석) |
| 모든 Step 번호 ≥ 11 (목차·본문·Test Plan·Assumptions·Phase N 표) | 번호 | regex 전수 | 함께 고침 | 빈 번호 없이 하나씩 당김; Correction History 기록 행은 제외 |
| 104 합계 | 수치 | 지시 | 함께 고침 | python 재계산, 「Step 6–60」, 대기 시간 문구를 Codex 로 |
| 114 Summary (2)(3) | 검증 분담 | 지시 | 함께 고침 | Claude = 작성·정적 검사·논리 검수, Codex = 실사용 검증 |
| 목차 각 「확인 목록」, 100 Step 설명 | 같은 뜻 | grep | 함께 고침 | 「Codex 발주문」 |
| 24 목차 Step 14 · 220 Phase 2 질감 | 같은 뜻 | grep | 함께 고침 | 「PC 확인」 → 「Codex 실사용 검증」 |
| 95–96 목차 Phase 25 · 341 · 381 Phase N | 지시 | grep | 함께 고침 | 「Codex 검증 결과 반영·고정」 |
| 172 늘 지킬 제약 R9 · 새 R86 행 | 같은 뜻 | grep | 함께 고침 | 첫 Codex 발주문에서 확인 · 분담 규칙 행 추가 |
| 191–192 구조 맵 | 같은 뜻 | grep | 함께 고침 | tools 에서 harness 삭제, checklists → `Collection/codex-briefs/`, 결과 자리 `References/codex-verify/` 추가 |
| 265·282 BugSack 행 | 같은 뜻 | grep | 함께 고침 | 「Codex 실사용 검증용 도구」 |
| 306 Non-goals | 같은 뜻 | grep | 함께 고침 | 설치·실사용 검증은 Codex, 오프라인 로드 harness 는 만들지 않음 |
| 333 뒤 Step · 338 Phase 1 · 339 Phase 23 | 같은 뜻 | grep | 함께 고침 | harness 삭제, 정적 대조로 |
| 343–348 사용자 PC 확인 목록 절 | 지시 | 지시 | 함께 고침 (통째 다시 씀) | 「Codex 실사용 검증 발주문」 |
| 396 Interfaces 확인 목록 | 같은 뜻 | grep | 함께 고침 | 발주문 → Codex → References → master |
| 408 Test Plan 이 문서 ④ | 같은 뜻 | grep | 함께 고침 | Claude 검증과 Codex 실사용 검증의 나눔 |
| 410 Test Plan 도구 행 | 대상 | grep | 함께 고침 | 「정적 검사·빌드 도구 (Step 9)」, 위험도 정적 검사 기준 |
| 427 Test Plan Phase 23 ① | 같은 뜻 | 정독 | 함께 고침 | 조합 로드 → 조합별 TOC·의존 정적 해석 |
| 429 Test Plan 확인 목록 행 | 같은 뜻 | grep | 함께 고침 | Codex 발주문 행 |
| 412 갈래 설명 「코드는 실행으로 볼 수 있는 것을 먼저 실행」 | 같은 뜻 | 정독 | 함께 고침 | 실행 대신 정적 검사 먼저, 실행 확인은 Codex |
| 435–451 검증 나눔 표 · 453 | 대상 | 지시 | 함께 고침 (통째) | 열 이름과 harness 칸 |
| 460·461·466·468 Assumptions | 같은 뜻 | grep | 함께 고침 | lupa = 문법 검사, Phase 1 Codex 발주문, Codex 가 돌림(D1) |
| 487–489 D1 | 지시 | 지시 | 함께 고침 | 「Codex 검증을 언제 돌릴지」, (가)·(ㄱ) 유지(R83·R86) |
| 505 D5 | 같은 뜻 | grep | 함께 고침 | 「Phase 1 Codex 발주문」 |
| 523 권한 · 528 실측 불가 | 같은 뜻 | 지시 | 함께 고침 | Codex 가 사용자 PC 에서 |
| 120 Ground Truth 「Codex 기록」 정의 | 기록 정의 | 정독 | 확인만 | 그대로 맞음 |
| Correction History 기존 행 | 기록 | — | 영향 없음(기록) | 번호 바꾸지 않음, 새 행만 |

### 판정 줄 (R86)

- Step 10 (harness, 120–240) removed; Steps ≥ 11 shifted by −1 everywhere except Correction History record rows (regex over `Step N`, `Step N–M`, and the Phase N table column).
- python (tree regex): Steps 55 (6–60, gaps 0); fixed total 3810–6345 min (≈ 64–106 h) = old 3930–6585 minus 120–240. Phase 12–19 (now Steps 33–48) still 870–1425. Highest Step reference in body = 60, none above.
- Phase N table ranges: 0:1–7, 1:8–10, 2:11–13, 3:14–15, 4:16–17, 5:18–19, 6:20–21, 7:22–23, 8:24–26, 9:27–28, 10:29–30, 11:31–32, 12:33–34, 13:35–36, 14:37–38, 15:39–40, 16:41–42, 17:43–44, 18:45–46, 19:47–48, 20:49–50, 21:51–52, 22:53–54, 23:55–56, 24:57–58, 25:59–60.
- Leftover grep (`harness`, `확인 목록`, `사용자 PC 확인`, `퇴근`, `checklists`, `3,930`, `Step 6–61`) outside history rows: only the intended new mentions (R86 constraint row 172 and Non-goal 307 naming harness as not built).
- Banned-lexicon grep: no hits. Plan length 535 lines.

## R86·R87 반영 (R87: 「검수 라운드지침은 이번 세션에 한해 니가 필요한만큼으로 수정해서 진행해 검수 방법은 너한테 일임한다. 대신 10라운드보다 무거워지면 안된다. 그리고 기존 애드온중 완성도가 높아서 굳이 개조를 할 필요가 없는것은 그대로 써. 그리고 UI 외관에 관련된것은 코덱스에 맡길게. 너는 코드단, 기능단의 작성, 검토만 진행해」)

R86 part was already applied in the section above (same fix round, continued here). Plan re-read in full for this round: header, tree, 100–115, 150–200, 210–300, 300–420, 455–535 (all sections). Scratch copy before R87: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_r87.md`. Edit script kept at `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/r87/apply.py`.

A1 design choice recorded: since skin/connection folders move to Codex (R87), the registration contract can no longer live in `DevilForever_Skin_*`. It becomes a static registration table inside Core (generated from manifest/TOC), so functional registration (save/restore targets, edit items, frame names) depends neither on original-code edits nor on Codex output.

### 영향 지도 (고치기 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 목차 전체 | Phase·Step·시간 | 지시 | 함께 고침 (통째) | 그대로 쓰는 Phase = Step 하나, 외관 Step 제거, Phase 2 를 코드 기반/외관으로, Step 6–41 |
| 목차 아래 Step 설명 문단 | 같은 뜻 | 정독 | 함께 고침 | 「그대로 사용」 Phase 와 하위 Step 규칙, Codex 몫은 시간 밖 |
| 예상 시간 합계 문단 | 수치 | 지시 | 함께 고침 | python 재계산, Codex 몫 목록 별도 |
| Summary 일하는 순서·이 환경의 한계 | 분담 | 지시 | 함께 고침 | R87 그대로 사용·외관 Codex |
| 늘 지킬 제약 R63 행·R50–R53 행 + 새 R87 행 3개 | 규칙 | 지시 | 함께 고침 | 분담·그대로 사용·검수 강도 예외 |
| 구조 맵 codex-briefs · 새 `References/codex-appearance/` | 자리 | 정독 | 함께 고침 | 외관 발주문·결과 자리 |
| 기능 Phase 정의 표 2–22 (쓰는 방식·하는 일) | 정의 한 곳 | 지시 | 함께 고침 (통째) | 첫 선택지 「그대로 사용」, 추정 표시, 외관은 Codex |
| 표 앞 판정 문단 | 같은 뜻 | 정독 | 함께 고침 | 쓰는 방식 규칙·Step 8 판정 |
| 바꾼 곳 1·2·4·6 | 같은 뜻 | 정독 | 함께 고침 | 질감·테마는 Codex, 등록 표, Step 32 |
| Non-goals | 범위 | 정독 | 함께 고침 | 외관 구현 안 함, 고칠 필요 없는 애드온 고치지 않음 |
| Implementation Changes 모음집 구성·고치는 방식·공통 단계·기능 아닌 Phase | 정의 | 지시 | 함께 고침 (통째) | 0 단계 그대로 사용, 외관 연결은 Codex, 판정 Step 8, Phase 2·24 분담 |
| 새 소절 「Codex 외관 발주문」 + Codex 몫 목록 | 지시 | 지시 | 함께 고침 | 언제·무엇·Claude 가 먼저 줄 인터페이스 |
| Codex 실사용 검증 발주문 절 | 같은 뜻 | 정독 | 함께 고침 | 「마지막 Step」 이 씀 |
| Phase N 표 Step 범위·이름 | 번호 | 지시 | 함께 고침 | 새 범위 |
| Interfaces 등록 규약·테마 토큰·목업 입력 + 새 외관 발주문 행 | 계약 | 정독 | 함께 고침 | 등록 표 정적 데이터, 토큰 인터페이스 Claude → Codex |
| Test Plan 검증 관점 표 | 지시 | 지시 | 함께 고침 (통째) | R87 예외 방식 |
| Phase 별 검증 나눔 표 | 같은 뜻 | 정독 | 함께 고침 (통째) | Codex 외관 열 추가 |
| Assumptions Step 49 · 스킨 API · 새 2행 | 같은 뜻 | 정독 | 함께 고침 | Step 32, 그대로 사용 추정, Codex 결과 |
| Decisions Required 「예외」 소절 | 지시 | 지시 | 함께 고침 | 이번 세션 한정·상한 10·master 기본 방식 |
| D2 「Step 24」·Assumptions Hekili 「Step 24」 등 Hekili Step 참조 | 번호 | grep | 함께 고침 | Step 18·19 |
| 멈출 일 새 의존성(렌더 라이브러리)·실측 불가 | 같은 뜻 | 정독 | 함께 고침 | 렌더는 Codex |
| D1·D3·D4·D5·D6·D7 결정 | 결정 기록 | 정독 | 확인만 | 분담만 바뀌고 결정 내용 그대로 |
| Correction History 이전 행 | 기록 | — | 영향 없음(기록) | 새 행만 추가 |

### 판정 줄 (R87)

- python (tree regex): Claude Steps 36 (6–41, gaps 0); fixed total 1910–3460 min (≈ 32–58 h). Phase 12–19 (Steps 24–31) = 230–385. Per class +45–85 (9 classes → +405–765). Conditional: Hekili 갈래 2·3 +60–180 (갈래 3 +15–30 per class); each 「그대로 사용」 guess that turns into 「고침」 at Step 8 +60–150.
- Before R87 (after R86): 3810–6345 over Steps 6–60. Difference comes from removing appearance work (Phase 2 panels/texture, skins, theme build, mockup render) to Codex and shrinking as-is feature Phases to one Step each.
- Phase N ranges: 0:1–7, 1:8–10, 2:11–12, 3:13, 4:14, 5:15, 6:16, 7:17, 8:18–20, 9:21, 10:22, 11:23, 12:24, 13:25, 14:26, 15:27, 16:28, 17:29, 18:30, 19:31, 20:32–33, 21:34–35, 22:36, 23:37–38, 24:39, 25:40–41.
- Step references in body checked against the new map (Hekili 18/19, ProfileManager 32, job table 10); old numbers remain only in Correction History record rows.
- Leftover grep (`harness`, `확인 목록`, `스킨 연결`, `렌더용`, `870`, Step 42–61) outside history rows: only intended mentions (R86 constraint row and Non-goal naming harness as not built).
- Banned-lexicon grep: no hits. Plan length 535 lines.

## 검증 2 고침 (R83·R86·R87 반영분 1회 검수 · M-a·M-b·경미 1–5)

Read in full: `TRIAGE_phase0.md` 「검증 2」. Opened plan lines 3, 5, 21–22, 126, 194, 227–228, 241, 259, 304, 314, 322, 328, 339–341, 395–399, 417, 421, 424, 433, 438, 535 before editing. Scratch copy: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/plan_before_v2.md`.

### 영향 지도 (고치기 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| 396 Interfaces 테마 토큰 | M-a 대상 | 처리표 | 함께 고침 | Core 가 토큰 위에 덮어쓰는 프레임별 편집값을 내주는 읽기 함수 |
| 399 Interfaces 편집 | M-a 연결 | 정독 | 함께 고침 | Phase 21 이 저장한 값을 Core 편집값으로 내준다 |
| 339·340 Codex 외관 발주문 표 「Claude 가 먼저 줄 것」 | M-a 대상 | 처리표 | 함께 고침 | 편집값 읽기 규약 포함, 외관 코드가 그 값을 적용해야 함 |
| 424 Test Plan Codex 결과 대조 | M-a 지도 밖 연결 | 처리표 | 함께 고침 | 토큰·편집값을 읽는지 |
| 227 기능 표 Phase 21 | M-a 연결 | 정독 | 함께 고침 | 저장한 값이 Core 편집값으로 외관에 걸린다 |
| 21 목차 Step 11 · 328 Phase 2 | M-b·M-a 대상 | 처리표 | 함께 고침 | Core 구성에 기본값 주입·편집값 읽기 추가, 시간 150–240 |
| 304 모음집 구성 Core | M-b 대상 | 처리표 | 함께 고침 | 같은 구성 |
| 395 Interfaces 등록 규약 | M-b 대상 | 처리표 | 함께 고침 | 등록 표에 기본값 파일 위치, Core 가 처음 로드 때 한 번 넣고 사용자 값 덮어쓰지 않음 |
| 314 쓰는 방식 2 · 322 그대로 사용 Phase · 421 Test Plan 기본값 행 | 같은 뜻 | 정독 | 함께 고침 | 기본값을 넣는 주체 = Core |
| 417 Test Plan Core 행 · 433 검증 나눔 Phase 2 | 같은 뜻 | 정독 | 함께 고침 | 기본값 주입·편집값 읽기 검사 항목 |
| 438 검증 나눔 Phase 21 | 같은 뜻 | 정독 | 확인만 | 「편집 창 외관」 그대로 맞음, Codex 실사용에 편집값이 화면에 걸리는지는 Phase 21 Codex 칸에 있음 |
| 535 「요청하는 지침 예외는 없다」 | 경미 1 | 처리표 | 함께 고침 | 「예외」 소절과 맞춤 |
| 3·5·126 R 범위 | 경미 2 | 처리표 | 함께 고침 | R87 까지 |
| 241 제외 표 버프 행 「Phase 15 앞 Step 에서 확인」 | 경미 3 | 처리표 | 함께 고침 | Codex 외관 발주문에서 확인 |
| 259 V42 분류 Phase 2 행 | 경미 4 | 처리표 | 함께 고침 | !DevilUI 기전은 Claude Core 참고, kgPanels 패널·Masque·Onyx 외관은 Codex |
| 194 완료 이력 Step 5 | 경미 5 | 처리표 | 함께 고침 | 설계는 Codex 공통 외관 발주문, 렌더는 Codex 목업 발주문(Phase 24) |
| 합계 문단 | 시간 | 지시 | 함께 고침 | Step 11 +30분 반영 |
| Correction History 이전 행 | 기록 | — | 영향 없음(기록) | 새 행만 |

### 판정 줄 (검증 2)

- Step 11 raised from 120–210 to 150–240 (default-injection + per-frame edit-value read added to Core).
- python (tree regex): Steps 36 (6–41, gaps 0); fixed total 1940–3490 min (≈ 32–58 h), up 30–30 from 1910–3460. Other conditionals unchanged.
- Banned-lexicon grep: no hits. Plan length 536 lines.

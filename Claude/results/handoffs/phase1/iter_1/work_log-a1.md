# work_log — A1 analyst, Phase 1 (Step 8 judgment, Step 10 class table, Phase 1 Codex brief)

Brief: `Claude/results/handoffs/phase1/brief-a1.md` (read 1–34 in full).
Temp dir: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/a1.bvZm` (scratch only; nothing deleted).

## Inputs read (file:line ranges)

| File | Lines | Purpose |
|---|---|---|
| `Claude/results/handoffs/phase1/brief-a1.md` | 1–34 | task |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` | 96–130, 131–182, 200–285, 300–352, 354–404, 446–527 | constraints, structure map, feature table, how-to-use 0–5, Codex briefs, interfaces, assumptions, decisions D1–D7 |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-phase1-세부계획.md` | 1–14 | Phase 1 steps |
| `Claude/results/REQUEST_LEDGER_phase0.md` | 1–35 | R-numbers |
| `Claude/results/REQUEST_LEDGER_phase1.md` | 1–6 | carried rows |
| `Collection/manifest.md` | 1–236 | package/folder facts |
| `Collection/manifest.json` | structure via python (roundtrip check: `json.dumps(indent=2, ensure_ascii=False)+"\n"` == file → True) | edit method |
| `References/forever-addons/*/ANALYSIS.md` (13) | each 1–17/19 | Codex record |
| `References/addon-sources/{tiptac-reborn,bagnon,platynator,aurora,titan-panel,kaliels-tracker,mapster,profilemanager,reflux,edit-mode-expanded,blizzmove,tellmewhen}/ANALYSIS.md` | each 1–17/19 | Codex record |

## Upstream targeted reads

(appended per unit below)

### Unit 1 — class/spec/resource sources (Step 10 input)

| File | Lines | What |
|---|---|---|
| `Collection/upstream/Hekili-v0.8.6/Hekili_Shaman/Hekili_Shaman.toc` | 1–16 | module TOC shape (LoadOnDemand, deps) |
| `.../Hekili_Shaman/Shaman.lua` | 1–120, 494–540 | header notes, NewClass, mana, totems |
| `.../Hekili/Engine/Schema/Spec/Kits.lua` | 1–156 (whole) | NewClass contract: specs = talent trees, `unsupported` disables displays (l.141) |
| `.../Hekili_*/[Class].lua` NewClass blocks (python extract, `newclass.py`) | Druid 34–65, Hunter 38–77, Mage 40–70, Paladin 37–58, Priest 45–67, Rogue 34–61, Shaman 48–69, Warlock 55–87, Warrior 39–52 | specs |
| RegisterResource lines | Druid 238–248, 322–324; Hunter 328–330; Mage 239–241; Paladin 258; Priest 234–236; Rogue 148, 156–157; Shaman 496–498; Warlock 241–243; Warrior 290–292 | resources |
| forms/stances/pets/totems | Druid 84–87,169; Warrior 569,579,633,849–852; Priest 1–12 (Shadowform as form, l.5); Rogue 81,309–316 (stealth isStealthed); Paladin 380–388,428–438 (auras "one up at a time"); Hunter 355–372 (hawk guardians, pet_out); Warlock 142,279–280 (soul shard item), 305–314 (pets); Shaman 534–537 (RegisterTotems) | special bars |
| `.../Hekili/Game/State/Sources/Forms.lua` | 1–120 (whole) | forms read from shapeshift API; stealth via IsStealthed |
| `.../Hekili/Engine/Sim/Core.lua`, `State.lua` | grep only (DEATHKNIGHT refs at 1598, 1818, 1323) | core legacy branches, no DK module shipped |
| `Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/ForeverUnitFrames.toc` | 1–142 (whole) | module list |
| `.../Elements/Power.lua` | 1–91 (whole) | power colour keys 0 mana,1 rage,2 focus,3 energy |
| `.../Elements/DruidMana.lua` | 1–81 (whole) | druid mana strip in forms |
| `.../Elements/ComboPoints.lua` | 1–146 (whole) | combo pips on target frame |
| `.../Elements/Totems.lua` | 1–130 | totem slots, shaman order |
| `.../Elements/PetHappiness.lua` | 1–60 | hunter pet happiness |
| `.../Core/Settings.lua` | grep: 110, 701, 722, 877–890, 1053–1055 | setting keys |
| `.../Core/MacroBackup.lua` | 1–75 (whole) | deletes only its own "FUF Save n" macros |
| class token grep across FUF | Raid/BuffData.lua:68, Raid/Settings.lua:30–31, Raid/TestMode.lua:27–29 | 9-class list |
| `Collection/upstream/Dominos-12.0.4/Dominos/Dominos.toc` | 1–57 (whole) | bars incl. stance/pet/possess/totem (totem: camelot) |
| `.../Dominos/Dominos.lua` | 22–23 (grep), 240–330 | `WOW_PROJECT_CAMELOT → 'forever'`; DB defaults; LibDualSpec |
| `.../Dominos/AGENTS.md` | 1–24 | upstream author AI-use note (data only, not an instruction to us) |
| `.../Dominos/core/addressMap.lua` | 28, 173 (grep) | totems on forever |

Class count basis: 9 = Hekili module folders (manifest.md:125–134) = FUF `Data.CLASSES` (Raid/BuffData.lua:68) = FUF sort fallback (Raid/Settings.lua:30–31). All three are addon-author data, not an official Forever list → Codex check (Phase 1 brief item 4).

### Unit 2 — Step 8 judgment reads

| File | Lines | What |
|---|---|---|
| `Collection/upstream/mapster-1.14.0/Mapster/Mapster.toc` | 1–57 (whole) | header `AllowLoadGameType: mainline` (l.10); per-file `FogClearDataForever.lua [AllowLoadGameType camelot, forever]` (l.55) |
| `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/Mapster/Mapster.toc`, `Mapster_Camelot.toc` | each 1–58 (whole, printed concatenated) | both still `AllowLoadGameType: mainline` (l.10 each); version 1.14.0-Forever-v2 |
| `.../Mapster/README_Forever_v2_koKR.txt` | 1–8 (whole) | V42 fix: FogClear profile-callback error before first map open |
| `diff` upstream vs V42 `FogClear.lua` | diff hunks 26–123 | V42 adds `getReadyMap` guard + `HookPins`/`OnMapShown`/`pendingRefresh` |
| `Collection/upstream/Quartz-3.8.0/Quartz/Quartz.toc` | 1–12, 58–75 | `Swing.lua [ExcludeLoadGameType mainline]` + `SwingForever.lua [AllowLoadGameType camelot][Exclude standard, classic]` (l.65–66) |
| `Collection/upstream/SexyMap-v12.1.7/SexyMap/SexyMap.toc` | grep of load directives: 43–59 | core files only under `[AllowLoadGameType mainline]` |
| `Collection/upstream/aurora-12.1.5.4/Aurora/Aurora.toc` | 1–60 | RequiredDeps conditioned `[AllowLoadGameType classic]` (l.8); author notes on camelot token (l.18–31) |
| `.../Aurora/Skin/init.lua` | 1–40 | author note: Forever = codename Camelot, mainline UI architecture, WOW_PROJECT_CAMELOT (18) since 70170 (l.10–16) |
| `Collection/tools/toclib.py`, `extract.py` | grep: toclib 35–37, 67, 83, 118, 197–211; extract 303, 322, 329, 463–464 | forever_load rule: Allow without forever/camelot → "no" |
| `Collection/upstream/profilemanager-ProfileManager_v4.0.zip/ProfileManager/ProfileManager.toc` | 1–28 (whole) | load order |
| `.../Core.lua` | 1–72 (whole) | `addon:RegisterProvider(id, provider)` public (l.70–72) |
| `.../Addons.lua` | 1–284 (whole) | AddOn enable/disable sets (C_AddOns), per character |
| `.../Presets.lua` | 1–204 (whole) | preset = map providerId → profile name; apply out of combat; reload flag |
| `.../Providers.lua` | 1–50, 400–620, 2962–3136; RegisterProviderDef ids at 621, 686, 922, 1407, 1603, 1675, 1767, 1965, 2179, 2336, 2435, 2576, 2679, 2778 | dedicated providers + AceDB registry scan (3060–3115) |
| `.../UI.lua` | 315–375; grep of events/ReloadUI | login apply per character (charPresets.applyOnLogin), new-character defaults; no spec-change event |
| AceDB use grep in start addons (own code, not Libs) | Dominos.lua, Prat addon.lua:159, Quartz.lua:54, GridCore.lua:124, Masque.lua:182, Mapster.lua:36, KT Config.lua:127, Hekili Options/Profile.lua:20, TipTac via LibFroznFunctions (ttOptions.lua:10) | which addons the AceDB scan can see |
| `work/.../AddOns/Devilconfig/Devilconfig.toc`, `_Camelot.toc`, `README_Forever_v7_koKR.txt`, `ForeverCompat.lua`, `Devilconfig.lua` | whole (15, 15, 7, 37, 216) | LDB launcher + AceConfig menu; no SavedVariables; no edit/save code |
| `work/.../AddOns/!DevilUI/!DevilUI.toc` | 1–14 | SV: DevilUIAccount; per char Devilinstall, DevilUILayout |
| `work/.../AddOns/!DevilUI/minimap.lua` | 930–1110; grep DevilUILayout uses | layout options window; movers unlock/lock; combat hides movers (1073–1080); chat+minimap only |
| `Collection/upstream/Hekili-v0.8.6/Hekili/UI/BarGlow.lua` | 1–30 | glows real action buttons (Dominos included) for the recommendation |
| `.../Hekili/Options/Options.lua` | grep: 415–506 (display defaults), 8861–9003 (Notify uses) | displays Primary/AOE/Cooldowns/Defensives/Interrupts; Notify = toggle/mode text |
| `.../Hekili/UI/UI.lua` | grep 94–231 | Notification panel = text panel |
| PlaySound grep in Hekili (non-Libs) | none | no sound alert path found |
| RegisterAuras/Abilities lines per class module | Druid 434/851, Hunter 382/590, Mage 284,698,895/377,753,984, Paladin 344/679, Priest 368/436,930, Rogue 224/503,1123,1352, Shaman 548/707 (maelstrom_weapon 571, clearcasting 667), Warlock 320,393/593,1126, Warrior 562/1008 | aura/CD data exists at class-kit level |
| `Collection/upstream/kaliels-tracker-8.11.1-forever/!KalielsTracker/*.toc` | base 1–16 (whole, header only, no files), Camelot 1–26 (whole) | base TOC is a stub; Camelot TOC requires `Blizzard_TransmogShared` |
| `Collection/upstream/tiptac-reborn-v26.11.11-release/TipTac/` | file list; `ttCore.lua` 249–260 (grep) | `TipTac.toc` 120105 + `TipTac_Forever.toc` 16001; anchor defaults |
| `Collection/upstream/Dominos-12.0.4/Dominos_Progress/Dominos_Progress.toc` | 1–22 (whole); data/ file list; grep pet | xp, reputation, honor, gold; no pet XP |
| `Collection/upstream/experience-forever-ExperienceForever2.0.4/ExperienceForever/ExperienceForever.lua` | grep 376, 1117–1121 | hunter pet XP bar |
| `Collection/upstream/Prat-3.0-3.9.117/Prat-3.0/` | file list; modules/*.lua default `on =` lines (grep); addon/addon.lua:71–76 | module defaults (History on l.35, ChatLog off l.33, Memory on l.45); Prat.IsForever |
| `Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/Settings.lua` | 145, 392–396, 700–701, 721–722 | enabled per frame, castbar default (player off), totems, combo |
| `.../Raid/Settings.lua` | 93 | raid `enabled` default true |
| `.../Core/Storage.lua` | 1–30 | `RegisterStorageProvider(name,{load,save})` |
| `.../Core/Init.lua` | 1–12 | global `ForeverUnitFrames` = ns.api |
| Forever-detection grep across start addons | per addon counts; Quartz Focus.lua:29, Aurora init.lua:15, Details class_damage.lua:2152, KT StaticPopup.lua:279 | which addons branch on Forever |
| `Collection/upstream/titan-panel-9.3.7/TitanRepair/TitanRepair.lua` | grep 333–670 | auto repair code present (Codex record: Forever auto-sell broken) |

## Outputs written

| File | How | Self-check |
|---|---|---|
| `Collection/data/classes.json` | generated by `$TMP/classes_gen.py` (scratch) | `json.load` ok; class_count 9, specs 28; every spec/resource/bar row has a `source` (file:line or "source missing") |
| `Collection/data/classes.md` | hand-written (Korean) | citations re-checked: Hunter.lua:4 and :14, Druid.lua:31–33, Priest.lua:286–291, Kits.lua:108–151/141 |
| `Collection/judgment.md` | hand-written (Korean) | plan row line fixed (Phase 21 row = plan:227, not 81); KT Camelot TOC l.20 = Dependencies (checked with `cat -A`); Prat Timestamps l.52 checked |
| `Collection/manifest.json` | `$TMP/set_how.py`: load → set `how_to_use` on 19 packages with a `use: start` phase → dump `indent=2, ensure_ascii=False` + "\n" (roundtrip asserted before write) | `$TMP/check_how.py`: before/after equal once `how_to_use` is nulled → True; `git diff` removed lines = 19 × `"how_to_use": null,` only; verdicts {settings 15, as-is 3, modify 1} |
| `Collection/codex-briefs/phase1.md` | hand-written (Korean) | opening 0 + items 1–7 (8 sections ≤ 10); each has 하는 법 · 기대 결과 · 결과 한 줄 양식; no game-input automation; BugSack/BugGrabber ZIP paths checked (`References/addon-sources/bugsack/BugSack-v12.1.9.zip`, `bug-grabber/!BugGrabber-v12.1.1.zip`) |

Banned-lexicon scan (`.claude/tools/banned_lexicon.json`, all categories) over the four Korean outputs and this log: 0 hits.

Not done / out of scope: no code, no plan edit (Decision Queue in `Collection/judgment.md` §6), no network, no commit, no deletes. `Collection/manifest.md` not regenerated (generated by extract.py; master/A2).

## Findings (4-tier) — summary

- Confirmed: Mapster header `AllowLoadGameType: mainline` in received copy and both V42 TOCs; V42 fixes FogClear only. Devilconfig has no SavedVariables and no edit/save code. ProfileManager: 14 dedicated providers + 2 native + AceDB registry scan; public `RegisterProvider`; no talent/spec-change event. FUF/ForeverThreat/SexyMap/Bagnon/Titan/Aurora build no AceDB in own code. Hekili displays are recommendation queues; Notify = toggle text; no PlaySound outside Libs. Dominos_Progress has no pet XP.
- Inferred: Forever client accepts `mainline` (Quartz.toc:65–66, SexyMap.toc:43, Aurora init.lua:10–16, V42 runtime fix) → tool's forever_load=no for Mapster likely false. Hekili aura/CD data usable as watch source (class-kit level). 9 classes = full Forever list.
- Not found: EventAlert-style centre alert in Hekili; Forever stance-bar content for paladin auras / hunter aspects / rogue stealth; hunter pet power; FUF spec data.
- Unverified (Codex): `_Forever`/`_Camelot` TOC suffix pick (TipTac, KT, Details); KT required dep `Blizzard_TransmogShared`; Mapster loadability; real class/spec list; resolution/UI scale.
| `.../ExperienceForever/ExperienceForever.lua` | grep 44, 59, 1488–1508 | showPetBar / showRepBar toggles; no XP-bar off toggle found (DQ 4 default changed to (다)) |

## DQ apply (master message: DQ 1–4 accepted, TRIAGE_phase1.md:21–29)

Reads for this change: `Claude/results/handoffs/phase1/TRIAGE_phase1.md` 1–29 (whole); master plan re-read head→tail: 1–100 (this pass), 100–130, 131–182, 184–199, 200–285, 286–299, 300–352, 354–404, 405–445, 446–527 (earlier passes this session + this pass); `Claude/results/PHASE_0-25_EXECUTION_LEDGER.md` 1–5 (whole); grep of `Claude/plans/*phase1*`, `Claude/docs/` for the same terms (0 hits).
Search terms (machine, after reading): Mapster, Dominos_Progress, Experience Forever, Devilconfig, Step 30/31/34/35, 30a/30b, 1,940 / 3,490 / 230–385 / 32–58, Edit Mode Expanded, BlizzMove, Broker_XPBar, 경험치, 편집 기전, 고쳐 씀.
Total recomputed by `$TMP/total.py` (parses outline Step lines 9–78; reproduces current 1,940–3,490 and 12–19 = 230–385 before the change).

### Impact map

| # | Place | Kind | Verdict | Reason |
|---|---|---|---|---|
| 1 | plan:224 feature table Phase 18 row | text | fix together | DQ1: as-is+settings → modify (FogClear guard), TOC only if Codex finds not loadable, auto-update off |
| 2 | plan:225 feature table Phase 19 row | text | fix together | DQ4: start → Experience Forever 2.0.4; Dominos_Progress → comparison (turned off: one function, one addon — Non-goals plan:290) |
| 3 | plan:227 feature table Phase 21 row | text | fix together | DQ2: 고쳐 씀 → new development; references: Devilconfig launcher, !DevilUI minimap.lua movers; EME/BlizzMove read at Step 34 |
| 4 | plan:43 outline 3장 heading "모두 그대로 사용 추정" | text | fix together | Phase 18 no longer as-is |
| 5 | plan:56–57 outline Phase 18 / Step 30 | text+estimate | fix together | 30a/30b, +60–150 (total 90–195) |
| 6 | plan:58–59 outline Phase 19 / Step 31 | text | fix together | start addon name; estimate unchanged 30–45 (same settings work, one addon) |
| 7 | plan:64–66 outline Phase 21 / Steps 34–35 | text+estimate | fix together | new development: 34 = 90–150, 35 = 180–300 (was 60–90, 120–210) |
| 8 | plan:80 note on multi-Step Phases | text | fix together | add Phase 18 (30a·30b) |
| 9 | plan:84 total paragraph | numbers | fix together | recompute fixed + 12–19 subtotal; conditional clause now applied |
| 10 | plan:259 V42 table row !DevilUI…(Phase 2) | text | fix together | minimap.lua movers also referenced by Phase 21 |
| 11 | plan:265 V42 table Broker_XPBar · Dominos_Progress | text | fix together | both comparison; start = Experience Forever (not V42) |
| 12 | plan:266 V42 table Mapster | text | fix together | V42 Mapster = source of FogClear guard |
| 13 | plan:268 V42 table Devilconfig | text | fix together | launcher pattern only |
| 14 | plan:273–281 "Codex 후보에서 바꾼 곳" list | text | fix together | add item 8 (Step 8 judgment changes) — master asked |
| 15 | plan:378 Phase N row 18 | text | fix together | Step 30 → 30a·30b |
| 16 | plan:379, 381 Phase N rows 19, 21 | text | confirm only | step numbers unchanged |
| 17 | plan:420 Test Plan 관점 row "원본을 고친 곳: 편집 (Phase 21 Devilconfig)…" | text | fix together | Phase 21 is new code now; Phase 18 FogClear is the modified original. Strength kept (1 logic review) — strength is master's call (R87 exception) |
| 18 | plan:436 Phase 별 검증 나눔 row 12–19 | text | fix together | split out 18 (logic review of FogClear + load check) |
| 19 | plan:438 row 21 | text | confirm only | already "코드 논리 검수 1회 / 편집·취소·되돌림" — fits new development |
| 20 | plan:109, 112, 113 Ground Truth rows naming Mapster/Dominos_Progress/Devilconfig | facts | confirm only — no effect | measured facts still true; Experience Forever 16001 is in `Collection/manifest.md:220` |
| 21 | plan:245 excluded table "소환수 경험치 → Phase 19" | text | confirm only | now satisfied by Experience Forever |
| 22 | plan:94 Summary, 290 Non-goals | text | confirm only — no effect | no addon names |
| 23 | plan:467–468 Correction History | record | add one row | master asked |
| 24 | plan:446–461 Assumptions | text | confirm only — no effect | "그대로 사용 추정" row stays generic |
| 25 | `Claude/plans/…plan_이력.md`, Phase 0 detail plan, `PHASE_0_master-plan_RESULT.*`, Step 6/7 result files, `REQUEST_LEDGER_*` | record | no effect (record) | historical records, not rewritten |
| 26 | `Claude/results/PHASE_0-25_EXECUTION_LEDGER.md` | record | no effect | only Phase 0 row |
| 27 | `Collection/codex-briefs/phase1.md` | text | fix together | add loadability item after 5; renumber 6→7, 7→8; item 8 says "0–7"; total 0 + 1–8 ≤ 10 |
| 28 | `Collection/judgment.md` §6 DQ1–4 | text | fix together | mark "accepted by master" |
| 29 | `Collection/judgment.md` §2 rows 18·19·21, §3 Phase 19 | text | fix together (one pointer each) | point to §6 decision; analysis text kept as Step 8 judgment |
| 30 | `Collection/manifest.json` how_to_use: Dominos reason; Experience Forever (null) | data | fix together | Dominos no longer Phase 19 start; Experience Forever = settings. `feature_phases`/`role` stay (A2 regenerates from plan table — TRIAGE DQ6) |
| 31 | `Collection/tools/extract.py:383` sets how_to_use None on regeneration | code | confirm only — out of scope | regeneration by A2 would wipe how_to_use → report to master |
| 32 | `Collection/data/classes.*` | — | no effect | no mention |

### DQ apply — done (after-change check against the map)

- Plan edits by `$TMP/plan_apply.py` (20 exact replacements, each asserted to occur once). New-file hunks: 43, 56–59, 65–67, 81, 85, 225–226, 228, 260, 266–267, 269, 283, 380, 422, 438–439, 472.
- `$TMP/total.py` after: fixed Steps 6–41 = 2,090–3,790 min (34.8–63.2 h), Phases 12–19 = 290–535; rows 30a 30–60, 30b 60–135, 31 30–45, 34 90–150, 35 180–300 — matches text at plan:85.
- Stale-phrase grep (Dominos_Progress 로 시작 / 고쳐 씀 / "Step 30 " / 1,940 / 230–385 / 모두 그대로 사용 추정 / 32–58): only the new Correction History row (plan:472, quoting the old values on purpose).
- Map rows "confirm only" re-read after edit: plan:109,112,113,245,379,381,438(row 21),446–461 — still true.
- Codex brief: sections 0–8 (≤10); new 6 = loadability; old 6→7, 7→8; "0–7"; "5·6번 설치 말고".
- judgment.md: §6 items 1–4 marked accepted with TRIAGE lines; §2 rows 18/19/21 and §3 Phase 19 point to §6.
- manifest.json: Dominos reason updated, Experience Forever how_to_use set (settings); `check_how.py` → only how_to_use differs; verdicts {settings 16, as-is 3, modify 1}.
- Banned-lexicon scan: 0 hits in the three edited Korean files.
- Open for master: (a) `extract.py:383` resets how_to_use to None on regeneration — A2 regeneration would erase these values; (b) Phase 21 review strength kept at "코드 논리 검수 1회" (plan:422); whether the new editor counts as a 3-round "새 구조 모듈" is master's call (R87 exception).

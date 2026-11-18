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

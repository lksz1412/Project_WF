# Work log — Phase 20 Step 32 (save/restore design) — A1 analysis

Output: `Claude/results/handoffs/phase20/design-32.md`. No addon code written. Scratch (volatile): `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/tmp.nDWM4gxG0g/reg.py` (lupa read of Registry.lua). Upstream/work files were read only, never executed (Registry.lua is our generated data file; read with `python3 -I` + lupa).

## Read (basis)

- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`: 115–160 (Reflux ground truth 122, constraints 141–143, 150), 225–240 (row 20 = 232), 280–320 (「바꾼 곳」 item 6 = 286, Non-goals 295–306, required bundle 312), 395–475 (Interfaces 398–412 incl. 407, 408; Test Plan 428; verification row 451; Assumptions 471); line 120 for R21.
- ProfileManager `Collection/upstream/profilemanager-ProfileManager_v4.0.zip/ProfileManager/`: `.extract-source.json` (whole), `ProfileManager.toc` 1–28 (whole), `Core.lua` 1–72 (whole), `Addons.lua` 1–284 (whole), `Providers.lua` 1–3136 (whole, in three reads), `Presets.lua` 1–204 (whole), `Commands.lua` 1–300 (whole), `Keybinds.lua` 1–393 (whole), `GameSettings.lua` 1–414 (whole), `UI.lua` partial: 100–420, 555–640, 1205–1230, 1620–1645, 3130–3155 + grep (ReloadUI, charPresets, newChar, spec/talent events, RegisterEvent, function addon:). UI.lua (6,316 lines) not read whole: logic sections and every ReloadUI/automation site found by grep were read; window layout code was not. `Libs/AceDB-3.0/AceDB-3.0.lua` logoutHandler 352–404 (grep + function body).
- PM grep: `CreateMacro|EditMacro|DeleteMacro|SetCVar|ResetCVar|SetBinding|C_EditMode.Save|SetActive|wipe(` over `*.lua` outside Libs → no macro API; SetCVar only GameSettings.lua:231; SetBinding only Keybinds.lua:239,249.
- Reflux V42 `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/Reflux/Reflux.lua` 1–567 (whole); upstream `Collection/upstream/reflux-1.17/Reflux/Reflux.toc` 1–5, diff upstream vs V42 Reflux.lua (first 80 diff lines: API aliases, init, DeepCopy).
- Core `Collection/AddOns/!DevilForever_Core/`: `!DevilForever_Core.toc` 1–19 (whole), `Core.lua` 1–268 (whole), `API.lua` 1–171 (whole), `Edit.lua` 1–264 (whole), `Defaults.lua` 1–509 (whole), `Theme.lua` 1–185 (whole), `Registry.lua` 1–80 (header + first entries) and all entries via lupa extraction (folder, bundle, use, version, foreverLoad, defaults, frames/editable counts, SV name/scope/split), `registry_extra.json` (Python summary of every addon entry: keys, counts, saved_variables, defaults), `Defaults/*.lua` grep for shape/profile/savedVariable/version + `Defaults/Dominos.lua` 1–30.
- `Collection/tools/genregistry.py` 1–390 (whole).
- `Collection/manifest.json` (Python summary of every package: name, role, version, verdict, feature phases, folders).
- Tests `Collection/tests/core/run.py` 1–200 + case-name grep; `fixtures/Registry_Test.lua` 1–40; `ls fixtures`.
- Ledgers: `Claude/results/REQUEST_LEDGER_phase8.md` 1–21 (whole: R94–R107; R101 :14, R107 :20); `REQUEST_LEDGER_phase19.md` 1–7 (whole; R109 :7).
- Phase 19: `Claude/results/handoffs/phase19/TRIAGE_phase19.md` 1–26 (whole); `phase19/iter_1/work_log-a2.md` 1–79 (whole). `Claude/results/handoffs/phase20/SESSIONS.md` (whole).
- Codex briefs: `Collection/codex-briefs/appearance-2-layouts.md` 1–35 (whole), `appearance-19.md` 1–38 (whole), `appearance-2.md` 1–36 (whole).
- Survey: `References/addon-survey/features.md` grep F68 (:111, :192); `survey.md` 85–95.
- Upstream facts used (read only):
  - LibDualSpec (Dominos copy) `Dominos-12.0.4/Dominos/libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` 34–100, 160–290, 485–572 + grep; `Dominos/Dominos.lua` 240–275; `Dominos/embeds.xml` (whole); `Dominos.toc` grep; `Dominos_Config` grep (no EnhanceOptions/LibDualSpec use).
  - Hekili `Engine/Sim/Events.lua` 375–415; `UI/UI.lua` 935–950; `Engine/Schema/Spec/Kits.lua` 1–30; grep of spec APIs.
  - Details `core/parser.lua` 6880–6965; `functions/loaddata.lua` 1–30, 55–72; grep of SV assignments.
  - AceDB:New sites (grep): Grid2 `GridCore.lua:124`, Hekili `Options/Profile.lua:20`, Prat `addon/addon.lua:159`, Quartz `Quartz.lua:54`, Masque `Masque.lua:182`, Mapster `Mapster.lua:36`, EF `ExperienceForever.lua:373`, Kaliel's `Core/System/Config.lua:127`, PitBull4 `Collection/AddOns/PitBull4/Main.lua:1389`, TipTac `ttCore.lua:1829` + LibFroznFunctions 2056–2081.
  - Plain SV sites (grep): Prat `modules/Scrollback.lua:77–82`, `modules/History.lua:128`; ForeverThreat `Core.lua:1543,1899`; FUF `Core/Boot.lua:27`; Aurora `config.lua:338,407`; SexyMap `SexyMap.lua:217–280` (grep lines).
  - Our addons: `DevilForever_ChatSetup` TOC + header 1–25, `DevilForever_FUFDefaults` TOC + header 1–30, `DevilForever_StatusStrip` TOC + `StatusStrip.lua` 680–700, `DevilForever_Castbars` TOC; slash grep over `Collection/AddOns` and upstream for `/dfp`, `/dfprofile` (0 hits).
  - `GetPhysicalScreenSize` users (grep file list).
- `.claude/tools/banned_lexicon.json` (head, categories) — Korean wording register; design written in English.

## Steps

1. Plan sections and user decisions read (above). 
2. PM read whole except UI layout code; mechanism table and coverage table built (§1). Finding: PM switches named profiles and keeps names only; no value snapshot, no registry scope, no spec switch; keybinds/game settings full and user-chosen.
3. Registry SV list extracted with lupa (Lua 5.5 runtime of lupa 2.8 for data reading only); every SV checked for AceDB vs plain by grep of upstream sources (§1.2).
4. Reflux mechanism and problems confirmed from source (§2.3); AceDB and Details logout writers confirmed (§2.2) → load-time restore decision.
5. Forever spec facts from LibDualSpec and Hekili comments (§2.1) → F68 via LibDualSpec link.
6. Placement trade-off (§3) → (b) recommended.
7. Data model, preset layer, commands, tests, file list written (§4–§9). Decision Queue 16 items (§11).
8. Self-check: two typos fixed in the design file (a stray CJK character in 확인 필요; a wrong plan line for R21 → PLAN:120).

## Tier notes

- [U] items for the Codex Phase 20 brief: handler order at ADDON_LOADED; `ACTIVE_TALENT_GROUP_CHANGED`/`GetNumSpecGroups`/`GetActiveSpecGroup` on Forever; `C_AddOns.GetAddOnMetadata`; `GetPhysicalScreenSize`; PM `SettingsPanel` path; SV file size; Details `keys` split.
- Not found: PM spec handling; LDS options in Dominos_Config; any `/dfp` slash conflict.

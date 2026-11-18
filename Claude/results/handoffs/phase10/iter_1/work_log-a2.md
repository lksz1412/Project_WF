# Work log — Phase 10 Step 22 (Details! 20261109 + Details_TinyThreat) — work A2

Raw output: scratchpad `step22.nsWj/` (volatile; the verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole, 28 lines); phase10 detail plan (whole); `Claude/results/handoffs/phase10/SESSIONS.md`
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 200–240 (feature table; rows 222–223 = Phase 10/11), 398–470 (Interfaces, Test Plan, verification split, Assumptions)
- `Claude/results/REQUEST_LEDGER_phase8.md` rows R101, R105–R107 (grep); `Claude/results/handoffs/phase2/TRIAGE_phase2.md` 1–40 (minor a = Details per-character SV); `Claude/results/PHASE_9_grid2_RESULT.md` 40–60; `Claude/results/handoffs/phase9/iter_1/work_log-a2.md` (whole, form)
- `Collection/judgment.md` 115–140 (Phase 9–12); `Collection/manifest.md` Details/ForeverThreat lines (grep 10, 13, 60–110); `Collection/manifest.json` Details package (Python dump)
- Core: `!DevilForever_Core.toc` (whole), `Defaults.lua` 1–509 (whole), `Edit.lua` 1–40, `Registry.lua` 1–40 + Details lines (grep); `registry_extra.json` (Python dump of ChatSetup/FUFDefaults/Grid2/Hekili/Quartz; round-trip check); `Collection/tools/genregistry.py` 1–130 + 200–270 (grep editable/size); `build.py` 1–80
- Bridge precedents: `Collection/AddOns/DevilForever_FUFDefaults/FUFDefaults.lua` (whole) + TOC; `DevilForever_ChatSetup/ChatSetup.lua` 1–60 + TOC; `Collection/tests/fufdefaults/run.py` (whole); `Collection/tests/core/run.py` 425–510
- Briefs (form): `Collection/codex-briefs/phase9.md`, `appearance-9.md` (whole); `phase1.md` 58–61 (Details 8 folders installed in Phase 1)
- Upstream Details (read only, never run) `U = Collection/upstream/Details-Details.20261109.15410.172/`: `Details/Details_Camelot.toc` (whole); `functions/loaddata.lua` 1–384 (whole); `functions/savedata.lua` 1–178 (whole); `functions/profiles.lua` 1–530, 1010–1030, grep of 531–2266 (default tables 531/1164/1370, keys); `core/parser.lua` 6700–6990; `startup.lua` 1–520, 740–830 + grep; `functions/chat_embed.lua` (grep); `frames/window_profiler.lua` 1–40; `frames/window_welcome.lua` 440–500, 1060–1095; `core/plugins_raid.lua` 1–230; `core/plugins.lua` 1–140, 290–340, InstallPlugin grep 160–206; `classes/class_instance.lua` 520–545, 770–800, 1160–1200, 1765–1995, 2084–2200, 3634–3670; `classes/include_instance.lua` 250–330; `frames/window_main.lua` 2629, 2822, 5410–5430 (grep); `functions/storage.lua` 60–120 (grep); `functions/slash.lua` 40–60; `frames/window_options2_sections.lua` 595–610
- `U/Details_TinyThreat/Details_TinyThreat_Camelot.toc` (whole), `Details_TinyThreat.lua` 1–160, 900–1018; other plugin `_Camelot.toc` deps (grep)

## Findings used
- SVs (Camelot TOC): account `_detalhes_global`, `__details_backup`, `__details_debug`; per character `_detalhes_database`. Not AceDB. Created by Details at its ADDON_LOADED (`parser.lua` 6721–6740 → `loaddata.lua` 20–60, 62–104: nil → copy of defaults, then missing keys filled two levels deep, then copied into the `Details` object).
- Profiles: `_detalhes_global.__profiles[<Name-Realm>]` (account), chosen by `_detalhes_database.active_profile` (`profiles.lua` 10–16, 82–97); `always_use_profile` puts a character on a shared profile (`loaddata.lua` 280–290). Window layout = profile `instances` (`profiles.lua` 199–480 ApplyProfile, 483–530 SaveProfile).
- Logout rewrites everything from memory: SaveConfig writes every `default_player_data` / `default_global_data` key from the `Details` object (`savedata.lua` 132–144), then SaveProfile rewrites the profile (`parser.lua` 6965–6969). → A Core defaults file (plain target, written at the first PLAYER_ENTERING_WORLD after Details already read its SVs) would be lost at logout and could, on a later fill-missing pass, write into `_detalhes_database` keys that Details had seeded itself. No Core defaults file shipped.
- Fresh-install state: one window, group mode, damage → damage done (`class_instance.lua` 2084–2190: `atributo = 1`, `sub_atributo = 1`, `modo = modo_grupo`; `startup.lua` 215–218 guarantees one window). Chat-tab embedding off by default (`profiles.lua` 1017–1023). Welcome wizard on account first run (`startup.lua` 748–753) offers "create second window" via `CreateInstance(true)` placed 50 px right of window 1 (`window_welcome.lua` 469–481).
- `Details.character_first_run = true` when `_detalhes_database.active_profile == ""` (`loaddata.lua` 294–300); set only, never cleared.
- Tiny Threat = RAID plugin `DETAILS_PLUGIN_TINY_THREAT`, installed at PLAYER_LOGIN (`Details_TinyThreat.lua` 28, 939; `plugins.lua` 317–330), enabled by default (`plugins.lua` InstallPlugin 195–206). Shown only by a window in plugin mode: `Details.RaidTables:EnableRaidMode(instance, name)` (`plugins_raid.lua` 61–122) — same call as the window's plugin menu (`window_main.lua` 5430) and the switch panel (`window_switch.lua` 106). Mode and last plugin persist through Details' own local config (`savedata.lua` 34–75) and are restored with a wait-for-plugin (`plugins_raid.lua` 41–57).
- Other bundled plugins are separate folders; Details_DataStorage is LoadOnDemand and Details handles its absence (`storage.lua` 86–90). No Details setting needed to keep them off — not installing them is the switch.

## Steps
1. Route decision: no Core defaults (above). Small bridge using Details' own calls, following the FUFDefaults/ChatSetup precedent: new `Collection/AddOns/DevilForever_DetailsSetup/` (`DetailsSetup.lua`, `DevilForever_DetailsSetup.toc` — Dependencies `!DevilForever_Core, Details`, OptionalDeps `Details_TinyThreat`, SavedVariablesPerCharacter `DevilForever_DetailsSetupDB`). Once per character, only in the session where `Details.character_first_run` is true, not on `always_use_profile`, only with exactly one window and Tiny Threat installed/enabled and not in use: `CreateInstance(true)`, place like the welcome wizard, `RaidTables:EnableRaidMode(window, PLUGIN)`. Result stored (created / not-applied / kept-existing / plugin-missing / window-limit / error). Details SVs never written.
2. `registry_extra.json`: `Details` — frames `details.damage` → `DetailsBaseFrame1`, `details.threat` → `DetailsBaseFrame2` (`window_main.lua` 2629); editable position + size (7–480, Details resize bounds 2822 / max_window_size 867) for both; SVs `_detalhes_global`, `_detalhes_database` split common; no `defaults`. `DevilForever_DetailsSetup` — SV split common. JSON round-trip of old file identical (`indent=2, ensure_ascii=True`); diff: 49 added, 0 removed.
3. `python3 -I Collection/tools/genregistry.py` ×2 → `wrote … (51516 bytes, sha256 765c666dab8ddeddeb45a40f691d0a1aa81e279eade8bc87112fc3c95c5904c9)` both.
4. New `Collection/tests/detailssetup/run.py` (18 cases, Details stand-in from the cited lines). Core tests before edit: `cases=61 passed=60 failed=1` (`generated_registry_lookup`: frame list lacks Details — expected). Edit in `Collection/tests/core/run.py`: frame-list sum includes Details + Details entry checks (2 frames, 4 SVs with scopes, no defaults, 4 editable), Details_TinyThreat no frames, DetailsSetup bridge SV per character. First run of the new check failed on my expected SV order (ASCII `__` before `_d`), expectation corrected → `61/61`.
5. Build ×2; old ZIP hash `12845c35…e8b06d` replaced in all briefs (18 occurrences in 18 files under `Collection/codex-briefs/`), old remaining 0; ZIP content lists in `phase2–9.md` (9 files, same sentence as the hash) gained `DevilForever_DetailsSetup/`.
6. Briefs `Collection/codex-briefs/phase10.md` (items 0–9), `Collection/codex-briefs/appearance-10.md`; cited Details line numbers re-checked by grep (parser 6965/6969, savedata 132–144, include_instance 255).

## Gates (final)
- `python3 -I Collection/tools/genregistry.py` ×2 identical (above); `--check` → `up to date (51516 bytes)` rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_ChatSetup Collection/AddOns/DevilForever_FUFDefaults Collection/AddOns/DevilForever_Castbars Collection/AddOns/DevilForever_DetailsSetup Collection/AddOns/PitBull4 Collection/tests/core/fixtures` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=204 failed=0`
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_DetailsSetup U/Details U/Details_TinyThreat` → `folders=4 unresolved=0 client_provided=0 optional_missing=8 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` (optional-missing = Details' embedded libs Ace3/LibSharedMedia/LibWindow/LibDBIcon/NickTag/LibDataBroker/LibGraph, TinyThreat → Ace3)
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=61 passed=61 failed=0`
- `python3 -I Collection/tests/detailssetup/run.py` → `lupa=2.8 cases=18 passed=18 failed=0`
- unchanged suites: `castbars` 16/16, `chatsetup` 13/13, `fufdefaults` 16/16, `pitbull4` 6/6
- `python3 -I Collection/tools/build.py` ×2 → `built folders=6 files=331 zip_entries=333` rc0, sha256 `d726a254197affceb9c8f3da892c97efb12ed76127d14ae988f000759a8e4846` both; ZIP lists `Interface/AddOns/DevilForever_DetailsSetup/DetailsSetup.lua` and its TOC
- `References/forever-addons/Details/Details-Details.20261109.15410.172.zip` sha256 `5002bdd5…92ad41` = manifest
- Defaults file logic test in `tests/core` with the real shape: not applicable (no Core defaults file).

## Decision Queue
1. Route: Core defaults injection not used for Details (logout rewrite); bridge addon `DevilForever_DetailsSetup` added instead (+1 addon against R101). Alternative: no bridge, Tiny Threat window made by hand (in-game step in the Codex brief). The bridge is new code → needs the code logic review per Test Plan.
2. Bridge acts only in the session where Details makes the character's settings. A character that already used Details (e.g. Phase 1 install on the user's PC) gets "kept-existing" and no threat window → phase10 brief item 0 moves Details SV files aside; for such characters in real use the user opens the window by hand.
3. Window 2 placement copies Details' welcome wizard (50 px right of window 1); final position is Codex appearance (R33 check in phase10 item 4 / appearance-10).
4. Phase 23 build list: recommend `Details` + `Details_TinyThreat` only; `Details_Compare2`, `Details_DataStorage` (LoD, raid history storage — Details runs without it), `Details_EncounterDetails`, `Details_RaidCheck`, `Details_Streamer`, `Details_Vanguard` left out (R101). Not decided here.
5. Registry editable `size` uses one range 7–480 for width and height (Core's size item has one min/max); Details itself bounds width 150–480, height 7–450.
6. `Collection/manifest.json` / `manifest.md` not touched (outside the template boundary list); the bridge enters the registry from its own TOC as earlier bridges did.
7. Phase 2 minor a (Details per-character SV seeded from account data): closed by not registering a Core defaults file for Details.

## DQ1 apply (master decision: drop the bridge — `Claude/results/handoffs/phase10/TRIAGE_phase10.md`, read whole)
Restore point: master commit `0392a27` (draft with bridge).
Read for the manual path: `U/Details/frames/window_main.lua` 5370–5440 (mode menu: Standard/Everything/Plugins lines 5408–5418, raid-plugin submenu → `RaidTables.EnableRaidMode` 5422–5431), `U/Details/locales/Details-enUS.lua` 487–491, 1031, 1662 and `Details-koKR.lua` 370, 1072, 1732 (labels, `new` slash word), `U/Details/functions/slash.lua` 40–60 (`/details new` → `CriarInstancia(nil, true)`), `U/Details_TinyThreat/enUS.lua` 7 (name "Tiny Threat").

Impact map:
| Place | Verdict |
|---|---|
| `Collection/AddOns/DevilForever_DetailsSetup/`, `Collection/tests/detailssetup/` | removed (`git rm -r`, master-approved) |
| `registry_extra.json` bridge entry | removed; Details entry kept |
| `Registry.lua` | regenerated |
| `tests/core/run.py` registry check | bridge SV check → bridge absent check |
| ZIP + hash in every brief, content lists in `phase2–9.md`, `phase6-rev.md` | hash replaced; `DevilForever_DetailsSetup/` removed from lists |
| `phase10.md` | rewritten: no bridge; item 2 = manual window 2 → Tiny Threat with menu path + check line; items renumbered (0–9 kept) |
| `appearance-10.md` | ZIP contents, "first-time setup" note, window-2 origin sentence |
| work log steps above (bridge) | no change (record) |

Commands and verdicts:
- `git rm -r -q Collection/AddOns/DevilForever_DetailsSetup Collection/tests/detailssetup` → AddOns now `!DevilForever_Core, DevilForever_Castbars, DevilForever_ChatSetup, DevilForever_FUFDefaults, PitBull4`
- `genregistry.py` ×2 → `wrote … (50995 bytes, sha256 e405ffca552c0da053a025f9350a68e6e5a8d4c833a0ee7c7b0672fbecccdcf6)` both; `--check` → `up to date (50995 bytes)` rc0
- `tests/core/run.py` → `lupa=2.8 cases=61 passed=61 failed=0`
- luacheck (Core, ChatSetup, FUFDefaults, Castbars, PitBull4, core fixtures) → `checked=203 failed=0`
- tocdeps (Core, Details, Details_TinyThreat) → `folders=3 unresolved=0 … optional_missing=8 … duplicates=0 load_on_demand=0`
- `build.py` ×2 → `built folders=5 files=329 zip_entries=331`, sha256 `d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820` both; `DetailsSetup` entries in ZIP 0
- briefs: old hash `d726a254…a8e4846` left 0, new hash 20 occurrences (18 earlier briefs + phase10 + appearance-10); `DetailsSetup` mentions in `Collection/codex-briefs/` 0

# Work log — Phase 5 Step 15 (SexyMap v12.1.7 functional settings) — work A2

Raw output: scratchpad `step15.7Pnm/` (volatile; verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole); phase5 detail plan (whole, 7 lines); `Claude/results/handoffs/phase5/SESSIONS.md` (whole); Phase 4 work log (whole, form)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 195–232 (feature table, row 212), 335–448 (Codex briefs, Phase list, Interfaces, Test Plan, verification split)
- `Collection/judgment.md` 1–58, 84–91 (Phase 5), 213–230 (4-1), 267–300 (4-5, 5, 6)
- `Collection/manifest.json` SexyMap and BasicMinimap packages (Python extract)
- Core: `!DevilForever_Core.toc`, `registry_extra.json`, `Defaults/Dominos.lua`, `Defaults/Prat-3.0.lua` (whole); `Defaults.lua` 1–395 (whole); `Core.lua` 1–268 (whole); `API.lua` 1–80; `Collection/tools/genregistry.py` 1–200; `luacheck.py` 1–60
- `Collection/tests/core/run.py` 1–200, 255–320, 370–402, 786–871
- `Collection/codex-briefs/appearance-3.md`, `phase3.md` (whole), `appearance-4.md` 1–60, `phase4.md` 1–30 (form)
- Upstream SexyMap (read only, never run): `SexyMap.toc` (whole); `Init_*.lua` (whole); `SexyMap.lua` 1–619 (whole); `Buttons.lua` 1–770 (whole); `Ping.lua` 1–127 (whole); `Shapes.lua` 226–374; `Borders.lua` 820–860; `Movers.lua` 105–140; `Clock.lua` 180–200; `Coordinates.lua` 222–245; `HudMap.lua` 300–322; `ZoneText.lua` 200–300; `CHANGELOG.md` 1–30; named `CreateFrame` grep (mainline files); `ls shapes media`
- Comparison: V42 `!DevilUI/minimap.lua` grep click/wheel/zoom/ping/track/LibDBIcon/button (1203 lines), 700–760, 1120–1203 (reset code 815–838 not used; only 813–817 seen while checking a cited range); BugSack LibDBIcon grep

## Findings used
- SV: `SexyMap2DB` account (`SexyMap.toc:17`), plain table, not AceDB. Created by SexyMap at its own ADDON_LOADED (`SexyMap.lua:325–331`): SV, then the character profile `SexyMap2DB["<name>-<realm>"]` (`<name> <surname>` with regional names; key computed at file load, `SexyMap.lua:37–45`). A string there (`"global"`) redirects to `SexyMap2DB.global` (334–341). Each module table is created only when missing (`core` 343–352, `buttons` `Buttons.lua:217–246`, others in each `OnInitialize`) → a partial table written before SexyMap's handler would block SexyMap's own defaults (e.g. `autoZoom` nil → `SexyMap.lua:502` compares nil) → written module tables must be complete.
- Core plain rules applied: fresh (SV nil at Core's first look, SexyMap's ADDON_LOADED) → waits, written over at the first PLAYER_ENTERING_WORLD (mode first-load); not fresh → fill-missing at SexyMap's ADDON_LOADED (Core's handler first, per Core assumption); new character with an existing SV → the whole profile entry is filled before SexyMap's setup; existing profile → user values kept; `"global"` string → conflict, kept. Not late-created (SexyMap creates the SV at its ADDON_LOADED).
- Profile key cannot be named by a static Core plain target → the defaults file computes it at load the way SexyMap does and builds the values table with it (code beyond a table: one function). Not registered (skip logged) when name/realm are unknown at load.
- Click: right click is caught by SexyMap's click frame (`SexyMap.lua:370–376, 391–396`) and opens settings when `rightClickToConfig` (default true, 347) → set false (A2 judgment, DQ1). Left button passes through (375) → Blizzard ping unchanged.
- Zoom: mouse wheel always on (`SexyMap.lua:516–524`); auto zoom-out 5 s default (348, 487–514) kept; zoom buttons `never` by default (`Buttons.lua:231–232`) kept.
- Ping: `Ping.lua` (who-pinged) is not in `SexyMap.toc` (27–60) → not loaded in this version (DQ2).
- Tracking icon: `MiniMapTracking` not in default `visibilitySettings` → `"hover"` (`Buttons.lua:448, 542`) → set `"always"` (V42 keeps the tracking button visible, `minimap.lua:414–419, 734`).
- Button tidy: LibDBIcon addon buttons fade to hover by default (`Buttons.lua:497–543, 754–758`); kept.
- Appearance left out of the values: `core.shape` (nil safe: `Shapes.lua:345–352`, `GetPosition` falls back to circle 329), scale, point, borders, clock/zone/coords; button angles/radius/scale are SexyMap's own values copied for table completeness. Square = `core.shape = 130871` (`Shapes.lua:228–232`) → Codex.

## Steps
1. Wrote `Collection/AddOns/!DevilForever_Core/Defaults/SexyMap.lua` (plain, one target `SexyMap2DB`, values `{[profileKey] = {core = …, buttons = …}}`; requirement values `core.rightClickToConfig = false`, `buttons.visibilitySettings.MiniMapTracking = "always"`; the rest SexyMap's own defaults).
2. Core TOC: `Defaults\SexyMap.lua` after `Defaults\Prat-3.0.lua`.
3. `registry_extra.json`: SexyMap (frames `sexymap.minimap`→`Minimap`, `sexymap.zonetext`→`SexyMapZoneTextButton`, `sexymap.clock`→`TimeManagerClockButton`, `sexymap.coordinates`→`SexyMapCoordFrame`; editable `sexymap.minimap` position; `SexyMap2DB` common; defaults path). Diff = additions only.
4. `python3 -I Collection/tools/genregistry.py` ×2 → `wrote … (39490 bytes, sha256 81df0821e2157cf86341084bde20057fee68b9466704bbfeb602e4f54dc5038a)` both, sha256sum identical; `--check` → up to date rc0.
5. Core tests first run: `cases=43 passed=42 failed=1` (`generated_registry_lookup`: frames were Dominos + Prat only). `run.py`: that expectation now includes SexyMap frames/SV/defaults path; SexyMap first-load stand-in (`SEXYMAP_INIT`, copy of SexyMap's setup logic, upstream not run) and 5 cases: `sexymap_defaults_fresh_written_at_world`, `sexymap_defaults_new_character_tables_complete`, `sexymap_defaults_existing_and_global_profile_kept`, `sexymap_defaults_regional_profile_key`, `sexymap_defaults_profile_key_unknown_not_registered`. Second run 47/48 (regional case: a Python callable is userdata to Lua → set the Lua function and reran the defaults file); third run 48/48.
6. Briefs `Collection/codex-briefs/appearance-5.md`, `Collection/codex-briefs/phase5.md` (items 0–9).
7. Snippet check (scratchpad `check.py`, Core harness, generated registry, SexyMap stand-in): item 2 → `true true applied first-load SexyMap2DB 28`; item 3 → `Hero-Realm table false always 5`; item 8 → `true false nil`; status log only the `info … waiting` line. Logic only, not the client.

## Gates (final)
- `python3 -I Collection/tools/genregistry.py` ×2 identical + `--check` → up to date (39490 bytes) rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_ChatSetup Collection/tests/core/fixtures` → `checked=12 failed=0` rc0
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/upstream/SexyMap-v12.1.7/SexyMap` → `folders=2 unresolved=0 client_provided=0 optional_missing=4 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` rc0 (optional_missing = Ace3, AceGUI-3.0-SharedMediaWidgets, LibSharedMedia-3.0 embedded; Blizzard_TimeManager client)
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=48 passed=48 failed=0` rc0
- `python3 -I Collection/tests/chatsetup/run.py` → `lupa=2.8 cases=13 passed=13 failed=0` (unchanged)
- `python3 -I Collection/tools/build.py` ×2 → `built folders=2 files=13 zip_entries=15` rc0, sha256 `ef42850c7e75178a1aa5695f275cd9533bb8e8bb1e96497818d0d33416ab7e9f` both
- `References/forever-addons/SexyMap/SexyMap-v12.1.7.zip` sha256 `1868eb71…143321` = manifest

## Decision Queue
1. Right click (A2 judgment): `rightClickToConfig = false` — a right click on the map does not open the settings window during play; `/sexymap` still opens it. Alternative: keep SexyMap's `true`.
2. Who-pinged name: `Ping.lua` is shipped but not listed in `SexyMap.toc`, so SexyMap 12.1.7 shows no pinger name; Blizzard ping itself works. Not added (no setting exists). If wanted: BasicMinimap comparison or a later Phase.
3. Tracking button `"always"`; every other button keeps SexyMap's default (zoom buttons hidden — wheel zoom; addon buttons on hover; calendar on hover, shown with invites; mail, clock, zone text always; addon compartment hidden).
4. Profile key in the defaults file: Core's plain target has no per-character key token, so the file computes SexyMap's key at load (same formula as `SexyMap.lua:37–45`). Alternative: a Core token for plain targets (Core change — master).
5. Copied SexyMap defaults: `core` (without `shape`) and `buttons` are written whole so SexyMap's "create when missing" setup is not blocked for a new character whose account already has `SexyMap2DB`. Without `shape` such a character keeps the Blizzard mask until the Codex fragment sets `core.shape`. When SexyMap's own ADDON_LOADED handler runs before Core's (order unconfirmed), a new character keeps SexyMap's values (right click on, tracking on hover) — phase5.md item 2 marks `fill-missing … 0` on a fresh install as failure.
6. Login-window timing: on the first install the values are written at the first PLAYER_ENTERING_WORLD; right click (read on click) works the same session, the tracking button visibility may need one /reload (read when SexyMap grabs the buttons) — phase5.md item 3 reloads first.
7. Load condition: SexyMap's core files load only under `[AllowLoadGameType mainline]` (`SexyMap.toc:43–58`); kept as judged; phase5.md item 1 checks `SexyMap ~= nil`.
8. Registered editable item: `sexymap.minimap` position only (SexyMap fixes the map size at 140×140, `SexyMap.lua:548`; size goes through `core.scale`). SexyMap re-anchors the map to `core.point` (`SexyMap.lua:574–581`) — appearance-5.md tells Codex to put position in the fragment, not to call `Minimap:SetPoint`.
9. Phase 20 link: `SexyMap2DB` is plain (ProfileManager does not see it — judgment.md Phase 5 (iii)); registered as common, account scope.
10. Manifest not edited (template §0 boundary; Phases 3–4 did the same).

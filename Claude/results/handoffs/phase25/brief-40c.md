# Brief — Phase 25 Step 40c — runtime burden fixes — work sub A2 (same session as 40b)

User rule (R117): judge by computation while the game runs, not by disk size. "Big but efficient is fine; small but doing countless operations is a failure." Keep every displayed value and update frequency the same for the player; remove duplicated or repeated work.

## Scope (in order)
1. PitBull4 fork `Modules/Aura/Forever.lua` (review 2 M1): rebuild `style_signature` only when settings/profile/font change (settings version compare); reconfigure the native aura container (SetUnit/layout/sort/UpdateAllAuras) only when unit, settings or restriction state change; remove the duplicate UpdateAll on combat start/end (Aura.lua:109-110 already does it).
2. `Modules/LuaTexts/Forever.lua` + `LuaTexts.lua` event loop (M4): cache classification per code string; normalise the event guid once outside the loop and compare with plain ==; read UnitGUID("pet") only when a pet text exists.
3. `Modules/HealthBar/HealthBar.lua`, `Modules/PowerBar/PowerBar.lua`, `ModuleHandling/BarModules.lua`, `Controls/BetterStatusBar.lua` (M3): one redraw per unit per frame (batch like upstream v4.2.50 guids_to_update); register only one of UNIT_POWER_UPDATE/UNIT_POWER_FREQUENT for the same handler; `LiveStatusBar:SetTexture` returns early when the path is unchanged; avoid duplicate GetRawValue/GetValue unit queries and per-call closures where a file-level function does.
4. `Modules/Aura/Update.lua`, `FilterTypes.lua`, `Highlight.lua`, `Filter.lua` (M2): no closure per field per aura — use the existing `Utils.SafeBoolean` style or a file-level helper; compute `is_aura_mine` once per entry during normalisation and reuse in sort/filter.
5. `Modules/AltManaBar/AltManaBar.lua` (M5): RegisterUnitEvent for "player","vehicle" as upstream; early return when the bar is hidden and the primary power is mana; no number→string→number round trip.
6. `Modules/CastBar/Forever.lua` (minor 6): the 0.15 s ticker runs only while any shown unit is casting/channeling.
7. R120 targetpet: add PitBull4 support for a "targetpet" singleton in the fork (GetBestUnitID, SINGLETON_CLASSIFICATIONS, any unit lists, events UNIT_PET / PLAYER_TARGET_CHANGED for refresh) and enable it in `Defaults/PitBull4.lua` (fresh profiles only, Core rule). Position: next to the target frame, appearance is Codex's.
8. R123-15 Totems shaman only: make the Totems module show only for SHAMAN in the fork (no box for paladin/priest), then enable it in Defaults/PitBull4.lua.
9. Core (M6): `Core:DBTable` builds the key string only on the fallback path; `Edit:Get`/`Presets:GetActive` avoid creating tables per call where a cached result is valid (invalidate on theme/preset/edit change callbacks); `DevilForever_Skin_Nameplates` caches the two styles (enemy/friendly) and recomputes only on those callbacks; skip SetSize/SetTexture/SetFont when unchanged.
10. Leftover handlers (minor 4): unregister ADDON_LOADED handlers once their work is done (Core, Appearance SharedMedia), Castbars retry loop bounded, ChatLayout 4 s timer only when managed.

Out of scope here: third-party addons other than our PitBull4 fork (TinyThreat, ExperienceForever, ProfileManager → Step 40d with the patch structure), Hekili (R122 ⑩ later), texture disk size.

## Boundaries & rules
As brief-40b §0 (no commit, no deletes, scratch temp, comments contract-only, CRLF preserved, impact map per change in work_log `Claude/results/handoffs/phase25/iter_3/work_log-a2.md`). The PitBull4 fork patch `Collection/patches/PitBull4.patch` must be regenerated to match the changed fork if the repo tooling expects it (check `Collection/tests/pitbull4/run.py`; the LICENSE line-ending case is 40d).

## Evidence required
For items 1–6 and 9: a before/after lupa probe (stubbed client API, label "probe (stubbed)") showing call counts or allocations per event for the same input — the Fable review's probe scripts may be reused/rewritten: /tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/probe.cF14/ (may be gone after the container restart; recreate). Plus behaviour tests: displayed values identical before/after for the probe inputs.

## Gates
core run.py (only genregistry case may fail), firststart, fufdefaults, pitbull4 run.py, Codex runner 8/8, luacheck on changed folders, new probe/behaviour tests.

## Return
`STEP40C_READY` or `BLOCKED: <reason>`; per item: files, change, probe before/after numbers, tests; Decision Queue.

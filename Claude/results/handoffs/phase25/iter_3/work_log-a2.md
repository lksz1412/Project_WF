# work_log — Phase 25 Step 40c — A2 coder (same session as 40b)

Scratch root: /tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad (each run in its own `mktemp -d`).
Plan: items 1–6 first (part 1), then 7–11 when called again (coordinator allowed the split).

## Read (basis)
- brief-40c.md (full, 1–40); iter_1/audit_log-step45-2.md 1–18 (full)
- PitBull4 fork: Modules/Aura/Forever.lua 1–311 (full), Aura.lua 85–150, Update.lua 1–260, 425–470, 530–560, 800–900, 960–1078; FilterTypes.lua 15–60, 870–890, 1540–1545; Highlight.lua 10–70; LuaTexts/Forever.lua 1–75 (full); LuaTexts.lua 36–110, 1330–1420; Utils.lua 1–110, 140–330; HealthBar.lua 1–451 (full); PowerBar.lua 1–291 (full); ModuleHandling/BarModules.lua 69–140, 485–600; Module.lua 340–400; Controls/BetterStatusBar.lua 730–745, 1250–1400; Options/LayoutEditor.lua 35–47
- scratch probe scripts from review 2: probe.cF14/probe_sig.py, sig.lua (reference only)

## Before copy
- `git archive HEAD Collection/AddOns/PitBull4 | tar -x -C <scratch>/pb4before.*` (HEAD fd4b6c9d) → "before" numbers via `python3 -I Collection/tests/pitbull4runtime/run.py --source <that copy>/Collection/AddOns/PitBull4`.

## Item 1 — Aura/Forever.lua (review 2 M1)
Impact map: Forever.lua update_group/style_signature/update_native/clear_native/OnEnable → fix; Aura.lua:109-110 REGEN UpdateAll (upstream, kept in file) → unregistered on Forever in our OnEnable (one deferred UpdateAll per transition stays: it runs after the combat state settled, as the existing user fix intends — my choice of which of the two to keep); Aura.lua OnProfileChanged / LibSharedMedia_Registered (called by name from Main.lua:1678, :1777) → wrapped to raise the settings version; ADDON_RESTRICTION_STATE_CHANGED → raises version then UpdateAll; AceConfigRegistry ConfigTableChange (fired after every options-dialog set) → raises version; Update.lua:851/866 callers → check only (same return values).
Change: settings_version; style_signature cached per (version, size, friendly, rule); container reconfigure skipped while version, unit, db, friendliness, frame width/height/level are the same and both groups are styled at that version; then only a new GUID behind the token calls UpdateAllAuras; clear_native resets the applied state.
Probe (stubbed), per update with the same unit/settings: before container_calls=17, UpdateAllAuras=1, GetFont=4, garbage 10.065 KB → after 0, 0, 0, 0.448 KB (stub bookkeeping). Combat start: UpdateAll per transition 2 → 1. Behaviour: new GUID → one UpdateAllAuras, layout kept; settings change → layout + button style applied once; cleared frame → full setup again.

## Item 2 — LuaTexts (M4)
Impact map: LuaTexts/Forever.lua TryForeverText → fix (classification per code string cached in `kinds`); LuaTexts.lua OnEvent loop → fix (pet GUID read once and only when the event config has pet; per text one SafeGUID; plain == on SafeGUID strings, nil never matches, as safe_guid_equal); timer OnUpdate power path (pet GUID already only on change) → check only.
Probe (stubbed): string.find per text update before 9.5 (readable) / 7.5 (restricted) → after 0 (first sight of a code only). OnEvent UNIT_HEALTH, 16 texts: SafeGUID 65 → 17, UnitGUID("pet") 16 → 0, SafeEqual 16 → 0. Behaviour: same texts updated (unit text only; pet event → pet text); restricted values shown identical ("1500 / 2000", "1500 / 2000", "Hero", "60").

## Item 3 — bars (M3)
Impact map: HealthBar UNIT_HEALTH/PLAYER_STATE_CHANGED (immediate UpdateForUnitID + queued) → queued only, the queue now also holds the frames IterateFramesForUnitID returns at event time (same coverage as the removed immediate path); PowerBar UNIT_POWER_UPDATE dropped (UNIT_POWER_FREQUENT kept: fires for every change), FREQUENT/DISPLAYPOWER/shapeshift → queue; HealthBar get_normalized_* and PowerBar get_power_value closures → file-level functions with arguments; LiveStatusBar SetTexture/SetAtlas(nil) → early return when unchanged (pool onRetrieve keeps texture_path true to the set texture); BarModules UpdateFrame GetRawValue+GetValue (value needed for colour) → check only, unchanged (my choice: removing it would change colours).
Probe (stubbed): HealthBar UNIT_HEALTH + UNIT_MAXHEALTH in one frame: Update 3 → 1; PowerBar one change (UPDATE + FREQUENT): Update 3 → 1, power events registered 2 → 1; LiveStatusBar SetTexture+SetAtlas(nil) ×10 same path: texture calls 40 → 2. Behaviour: other unit's event does not redraw the frame; texture change and atlas still applied.

## Item 4 — aura normalisation (M2)
Impact map: Update.lua safe_boolean/safe_number/safe_string/safe_dispel_name, FilterTypes.lua safe_boolean/safe_string, Highlight.lua safe_string/safe_dispel_name → file-level helpers (to_boolean, to_number, is_equal, pcall(tostring)); is_aura_mine → stored as entry.pb4_is_mine in normalize_aura_entry; sample and weapon entries clear it (computed on use); aura_sort and set_aura use aura_is_mine; set_aura's unchanged test uses the same is_mine. Filter.lua → check only (no closure, no ownership call). FilterTypes "Mine" filter (my_units without UnitIsUnit) → unchanged, different rule.
Probe (stubbed): normalize_aura_entry garbage per aura 2.172 KB → 0.005 KB. Behaviour: normalized fields identical, ownership stored.

## Item 5 — AltManaBar (M5)
Impact map: OnEnable → RegisterUnitEvent (LibUnitEvent, units player, vehicle) for UNIT_POWER_FREQUENT, UNIT_MAXPOWER, UNIT_DISPLAYPOWER; UNIT_POWER_UPDATE dropped; handler returns early while the player's primary power is mana (bar hidden by should_show_alt_mana; a change of primary power arrives via UNIT_DISPLAYPOWER → RefreshEvent); safe_plain_number without format/tonumber round trip (NaN still nil).
Probe (stubbed), druid, 10 player mana changes + 10 target events, primary mana: plain events 10 → 6 (+3 unit events), frame updates 10 → 0, string.format per GetValue 2 → 0. Behaviour: in a rage form the bar refreshes; value 0.7 unchanged.

## Item 6 — CastBar/Forever.lua (minor 6)
Impact map: OnEnable ticker → removed; ensureTicker started from UpdateFrame when a shown frame has a cast (events, wacky-frame updates and target changes all pass through UpdateFrame), cancelled by the ticker itself once no shown frame casts; OnDisable cancel unchanged.
Probe (stubbed): 10 s without casts: UpdateAll 66 → 0. Behaviour: casting → polled every tick; stops after the cast.

## Patch
`Collection/patches/PitBull4.patch` regenerated: same header + one bullet on these runtime changes; body `diff -ruN -x LICENSE a/PitBull4 b/PitBull4` (a = Collection/upstream v4.2.50, b = the fork) — LICENSE excluded so the LibPlayerSpells LICENSE line-ending case stays as it is for 40d (no other LICENSE differs).

## Gates (part 1)
- `python3 -I Collection/tests/core/run.py` → `cases=108 passed=107 failed=1` (genregistry_output_matches_file)
- `python3 -I Collection/tests/firststart/run.py` → `cases=22 passed=22 failed=0`
- `python3 -I Collection/tests/fufdefaults/run.py` → `cases=22 passed=22 failed=0`
- `python3 -I Collection/tests/pitbull4/run.py` → `cases=6 passed=5 failed=1` (patch_reproduces_the_copy: only the LICENSE file, 40d)
- `python3 -I Collection/tests/pitbull4runtime/run.py` → `cases=10 passed=10 failed=0`; with `--source <before copy>` → 10/10 (probes only)
- `python3 -I Collection/tools/luacheck.py Collection/AddOns/PitBull4` → `checked=186 failed=0`
- Codex runner `--output <scratch>/c40p1.8U6w/codex` → `PASS suites=8/8 expected_counted_cases=195`

## Decision Queue (part 1)
1. Item 1: the native CustomAuraContainer is assumed to follow its unit's auras itself after SetUnit (header of Aura/Forever.lua); UpdateAllAuras now runs only on setup and on a new GUID behind the same token. Needs a client check (if auras freeze in combat, the GUID test must become an UNIT_AURA trigger).
2. Item 1: of the two combat-transition updates the deferred one (next frame) is kept; Aura.lua's immediate one is unregistered on Forever.
3. Item 3: GetRawValue + GetValue both still run in the LiveStatusBar path (the value feeds the health gradient colour).
4. Patch body excludes LICENSE files (only LibPlayerSpells LICENSE differs, 40d).

# Part 2 (items 7–11, DQ1) — base 6555d822

Read: References/codex-appearance/25-codex-handoff/README.md (full), positions.json (full), Codex/results/CLAUDE_HANDOFF_phase30.md (full, 32 lines); PitBull4 Main.lua 108–120, 1855–1860, 1949–1962, 1997–2014; Utils.lua 186–240, 300–360; Modules/Totems/Totems.lua 1–60, 200–260; UnitFrameLayout.lua 533–631, 1448–1520; UnitFrame.lua 732–748; ModuleHandling/IndicatorModule.lua 1–20, 141–150; Presets/{fhd,qhd,uhd}.lua 438–470, 535–560; Grid2 GridFrame.lua 150–160, 245–275, 400; modules/IndicatorBorder.lua 10–55; Grid2Options profiles (from 40b); Core.lua 140–165, 270–318; Edit.lua 1–298 (full); Theme.lua 60–190; Profiles.lua 815–845; DevilForever_Skin_Nameplates/Appearance.lua 1–125 (full), NameplateProfiles.lua 1–38 (full); DevilForever_Appearance/SharedMedia.lua (full); DevilForever_Castbars/Castbars.lua 1–40, 95–165; DevilForever_ChatSetup/ChatLayout.lua 100–200; ForeverUnitFrames Elements/AuraContainers.lua 410–425, 540–555; Grid2 GridIndicatorAuras.lua 75–100; Quartz modules/BuffContainer.lua 1000–1012, 1040–1045.

## DQ1 — native aura container and UNIT_AURA
Evidence in the repo (no Blizzard source here): ForeverUnitFrames Elements/AuraContainers.lua:545 "The containers take UNIT_AURA for their unit themselves ... or has no aura events at all (target of target, on the frame's timer)", :415–421 (UpdateAllAuras only for non-UNIT_AURA refreshes); Grid2 GridIndicatorAuras.lua:77–79 (hidden containers do not register unit events); Quartz BuffContainer.lua:1007–1008 still calls UpdateAllAuras on UNIT_AURA. Client source not available → safety kept: Aura:UNIT_AURA marks the unit, the next update of that unit's container calls UpdateAllAuras (only that one native call, no reconfigure); wacky frames (frame.is_wacky: target of target etc., no aura events) call UpdateAllAuras on each of their updates, as before. Marks cleared after the throttled Aura:OnUpdate.
Probe (stubbed): UNIT_AURA then update → UpdateAllAuras 1, other container calls 0; next update without an event → 0; wacky update → 1.

## Item 7 — targetpet (R120)
Impact map: Utils.lua better_unit_ids (+targetpet), valid_singleton_unit_ids (+targetpet), classifications name ("%s %s" of L["Target"], L["Pet"]) → fix; Main.lua SINGLETON_CLASSIFICATIONS (+"targetpet": options list), PLAYER_TARGET_CHANGED (+CheckGUIDForUnitID("targetpet")); UNIT_PET("target") already reaches "targetpet" via unit .. "pet" (Main.lua:2010–2011) → check only; non_wacky list unchanged → targetpet is a wacky (polled) unit like targettarget; Defaults/PitBull4.lua units["대상의 소환수"] = {enabled, layout "대상의대상" (the target-of-target family: same enemy colours and name text), unit "targetpet"} (fresh profiles only, Core rule); Presets/{fhd,qhd,uhd}.lua PitBull4 units + "대상의 소환수" at Codex positions: fhd x170 y680 160×28, qhd x402 y994 160×32, uhd x718 y1540 190×36 (physical px, ×pixel at apply time like the other units; = 8 px left of the target, qhd 14 px / uhd 4 px lower); tests core/run.py PB4_UNITS_ON and pitbull4/run.py "units that are on" (+"대상의 소환수", counts unchanged); Core registry PitBull4 frames (10 editable frames) → not extended (DQ).
Test: GetBestUnitID/IsSingletonUnitID/IsWackyUnitGroup("targetpet") = targetpet/true/true, listed in SINGLETON_CLASSIFICATIONS, refreshed on target change; existing units unchanged. Frame shown only while the unit exists = PitBull4's singleton unit watch (client).

## Item 8 — Totems shaman only (R123-15)
Impact map: Totems.lua:216 → `if not MAX_CLASS_TOTEMS or (PitBull4.Compat.IsForever and player_class ~= "SHAMAN") then return end` (no module, so no box, for paladin/priest); Defaults/PitBull4.lua Totems global.enabled = true; Presets/{fhd,qhd,uhd}.lua: new PitBull4 fragment namespace "Totems" layouts["보통"] = {attach_to "root", location "out_left_top", totem_direction "h", line_break 4, size = slot/15, totem_spacing = gap·50/slot, text_size = text·50/(font·slot)} and layouts["보통"].indicator_root_outside_margin = 6/6/8 (Codex: slot 24/28/36, gap 4/4/6, text 12/14/18, margin 6/6/8; derivation: indicator scale = indicator_size 15 / TOTEM_SIZE 50 · size (UnitFrameLayout.lua:1494–1497), frame unit = 1 physical px under the preset layout scale, timer font = layout font 16/18/22 px · text_size · scale) → fhd size 1.6, spacing 8.33, text 1.5625; qhd 1.867, 7.14, 1.389; uhd 2.4, 8.33, 1.136; computed box fhd = x 438−6−108 = 324, y 620−6 = 614, 108×24 = Codex 324,614,108,24. Dominos totem bar unchanged.
Test: module created SHAMAN 1, PALADIN 0, PRIEST 0, WARRIOR 0 (before: paladin 1, priest 1).

## Item 11 — Grid2 party layout values (Codex)
Impact map: Presets/{fhd,qhd,uhd}.lua Grid2 fragments: existing values already equal Codex's outer box/cells/gap (PosX/PosY 24,164 / 40,164 / 80,240; frameWidth×frameHeight 96×32 / 120×44 / 154×56; Padding 4/4/6; 5 cells + 4 gaps = 176/236/304 high) → check only; frameBorder 1 → 2/3/4 (the border indicator, i.e. the dispel border, draws with Grid2Frame.frameBorder: modules/IndicatorBorder.lua:14) → fix; name text 12/14/18 → not set (DQ).
Real preset files run in lupa: fragments present for all three presets (Totems namespace, targetpet x = 170·pixel, margin, border 2/3/4), no errors.

## Item 9 — Core (M6)
Impact map: Core:DBTable key string only on the fallback path → fix; Edit:Get → cache of resolved values per frame key, valid while editVersion (every stored write; Edit:InvalidateCache for whole-table replacement, called by Profiles' core restore), Theme.version (new: every RegisterSet and active switch), Presets active name and Presets.version (new: every Register) are unchanged; returns a copy (contract unchanged); Presets:GetActive → no own allocation once DBTable is fixed; Skin_Nameplates/Appearance.lua: the two styles (enemy, friendly) with texture/font paths cached, dropped on Theme and nameplate Edit callbacks and on a preset change; SetSize / SetStatusBarTexture / SetFont only when the region does not already hold the value (size and font read back with GetSize/GetFont, texture by the region's GetTexture compared with what it read after our set, weak-keyed).
Probe (stubbed, real Core in lupa, `<scratch>/tools40c/probe_core.py` against HEAD copy vs working tree): DBTable('preset') 0.0781 → 0 KB/call; Edit:Get('nameplates.enemy') 0.8727 → 0.0842 KB/call; Presets:GetActive 0.0781 → 0 KB/call. Nameplate NAME_PLATE_UNIT_ADDED, same plate/style, per event: Edit:Get 1 → 0, Theme:Get 2 → 0, SetSize 1 → 0, SetStatusBarTexture 1 → 0, SetFont 1 → 0, garbage 4.379 → 3.871 KB (stub bookkeeping dominates). Behaviour: bar 90×10 at pixel 0.5 (180×20); nameplate edit → style recomputed; a plate the client resized gets its size again.

## Item 10 — leftover handlers (minor 4)
Impact map: Core.lua new Core:Off (removal after the running dispatch; event unregistered with its last handler); Core's own ready handler removes itself; SharedMedia.lua unregisters its events once registered; Castbars.lua PLAYER_REGEN_ENABLED retries bounded to the first 3 combat ends of a session while a FUF bar is missing (PLAYER_ENTERING_WORLD retries unchanged; header updated); ChatLayout.lua 4 s settle timer only when a managed layout exists (at world entry, or when one appears later: schedule() starts it), unmanaged state set at world entry.
Tests: Off during dispatch keeps the other handler; chat layout unmanaged → no timer at world entry; castbars 6 combat ends → 3 rounds of retries (6 timers) then none; SharedMedia events dropped after registering. Existing chatsetup (28) and castbars (16) suites pass.

## Patch
Regenerated again (same command, header bullet for targetpet/Totems added).

## Gates (final)
- `python3 -I Collection/tests/core/run.py` → `cases=108 passed=107 failed=1` (genregistry_output_matches_file)
- `python3 -I Collection/tests/firststart/run.py` → `cases=22 passed=22 failed=0`
- `python3 -I Collection/tests/fufdefaults/run.py` → `cases=22 passed=22 failed=0`
- `python3 -I Collection/tests/pitbull4/run.py` → `cases=6 passed=5 failed=1` (patch case: LICENSE only, 40d)
- `python3 -I Collection/tests/pitbull4runtime/run.py` → `cases=17 passed=17 failed=0`; `--source <before copy>` → 17/17
- chatsetup 28/28, castbars 16/16, statusstrip 20/20; verify_diagnostics exit 0
- `python3 -I Collection/tools/luacheck.py` (PitBull4, Core, Skin_Nameplates, Appearance, Castbars, ChatSetup) → `checked=220 failed=0`
- Codex runner `--output <scratch>/c40g.LMi7/codex` → `PASS suites=8/8 expected_counted_cases=195`
- line endings: every changed file keeps HEAD's ending (checked byte counts).

## Decision Queue (part 2)
5. DQ1: the container's own UNIT_AURA is stated by other addons' authors only; the aura-event safety (one UpdateAllAuras per aura event for that unit) stays until a client check.
6. Item 11 / Grid2 first-start template: the template func (Grid2Options profiles, e.g. ProfileClassic.lua sets Grid2Frame frameWidth/frameHeight, Modern/Blizzard also frameBorder and Grid2Layout Padding) runs after the preset fragments were written at Grid2's ADDON_LOADED, so on a fresh profile the template overwrites those Grid2Frame/Grid2Layout keys (the existing Codex preset values as well). Name text 12/14/18 lives in the template's text indicators (whole entries) and cannot be preset. Options: re-apply the Grid2 fragments after the first-start choice, or skip the dialog with a collection template.
7. Item 7: the targetpet frame is not added to Core's registry of editable frames (position edit via /dfp not available for it yet).
8. Item 8: Totems slot/text sizes assume the player layout's indicator_size stays at PitBull4's default 15; indicator_root_outside_margin is layout-wide (player layout auras are off in the defaults, so nothing else moves there).
9. Item 9: nameplate texture skip relies on the texture region's GetTexture reading back what it read after our set; unverified in the client.

## Fix 1 (review 1: iter_3/audit_log-40c.md, TRIAGE "Step 40c review 1")

Read: audit_log-40c.md (full), TRIAGE section (full); PitBull4 Modules/Aura/Options.lua 1–60, 1800–1820, 1940–1962, 2163–2185, 2640–2730; Modules/Aura/load.xml (Forever.lua loads last); Main.lua 940–950; Options/LayoutEditor.lua 1–40; Theme.lua 140–215; Grid2 GridCore.lua 123–202 (OnEnable → LoadConfig → UpdateDefaults → MakeDatabaseDefaults, then SetupTheme/Setup; ProfileChanged → LoadConfig, UpdateModules); Presets.lua fragment write 400–430.

### Impact map
| Place | Verdict | Reason |
|---|---|---|
| Aura/Forever.lua settings version | fix (C1) | Aura:UpdateAll and PitBull4:UpdateForLayout (what PitBull4.Options.UpdateFrames calls, LayoutEditor.lua:35–37) wrapped to raise the version; all aura option setters call one of them (Options.lua:1815, 2173, 2182 …; suppress_occ clears the frame itself); the combat watch calls the unwrapped UpdateAll (no rebuild on combat transitions); restriction change via UpdateAll; ConfigTableChange callback kept (harmless) |
| PitBull4 other UpdateForLayout callers | check only | only options code calls it (grep) |
| Theme.lua login restore | fix (M1) | goes through switch() — the one function for every active-set change (version, saved choice, listeners) |
| Defaults/Grid2.lua | fix (M2, option a) | post-hook on Grid2:MakeDatabaseDefaults (installed at Grid2's ADDON_LOADED): writes the active preset's Grid2Frame/Grid2Layout fragment values again into the current profile, only when the preset wrote them into that profile (preset.fragments record) and once per key (preset.grid2Template); runs before Grid2's SetupTheme/Setup/UpdateModules, so the values are used at once; text sizes inside the template's indicators stay (log) |
| Presets.lua fragment field intoExisting + Presets/{fhd,qhd,uhd}.lua PitBull4 main fragment (units, groups) | fix (m2) | unit/group entries only where the profile already holds that entry; fresh installs unchanged (Defaults made the entries first) |
| m1 Castbars cap, m3 nameplate font compare | log only | master |
| Collection/patches/PitBull4.patch | regenerated | same command |

### Tests
- pitbull4runtime `aura_option_setters_reach_the_native_container`: real Modules/Aura/Options.lua + Options/LayoutEditor.lua; zoom_aura setter restyles buttons, max_debuffs setter reaches both native groups; a following aura update and a combat transition rebuild nothing. Against the previous Forever.lua (HEAD 73baaf21 copy) it fails ("zoom icon … expected True, got False").
- pitbull4runtime `edit_cache_follows_theme_restored_at_login`: Edit:Get before PLAYER_LOGIN gives the base set's font, after the login restore the saved set's. On the previous Core: "Devil.ttf Devil.ttf" (the defect).
- firststart `grid2_preset_values_survive_first_start_template`: real Grid2Options Classic/Modern/Blizzard template functions after the real presets: frameWidth/frameHeight 96×32, frameBorder 2, Padding 4 kept, template name/indicators kept, one record per key; an existing profile gets only the template's value (66).
- firststart `pitbull4_preset_positions_only_into_existing_units`: fresh install gets the targetpet position; `/dfp preset fhd` on an existing profile creates no position-only unit entry and positions the existing unit.

### Gates
- core 107/108 (genregistry_output_matches_file) · firststart 24/24 · fufdefaults 22/22 · pitbull4 5/6 (patch case, LICENSE only, 40d) · pitbull4runtime 19/19 (and 19/19 with `--source` before copy) · chatsetup 28/28 · castbars 16/16 · statusstrip 20/20
- luacheck (PitBull4, Core, Skin_Nameplates, Appearance, Castbars, ChatSetup) `checked=220 failed=0`
- Codex runner `--output <scratch>/c40f1.JObh/codex` → `PASS suites=8/8 expected_counted_cases=195`
- line endings unchanged per file.

### Decision Queue (fix 1)
10. Every Aura:UpdateAll call (options, filter editor, font registration, restriction change) now rebuilds the native containers once; only the combat-transition update skips it.
11. In the harness the Grid2 preset fragments match only with Grid2's TOC version (4.1.13); the registry carries "4.1.13-forever", so a client without GetAddOnMetadata would skip them (pre-existing, Presets installedMatches).

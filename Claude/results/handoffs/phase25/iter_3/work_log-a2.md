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

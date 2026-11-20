# work_log — Phase 25 Step 40b — A2 coder

Scratch root: /tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad (each run in its own `mktemp -d`).

## Read (basis of the changes)
- brief-40b.md 1–59 (full)
- iter_1/audit_log-step44.md 1–19, audit_log-step45-2.md 1–18, audit_log-step45-3.md 1–12, TRIAGE_phase25.md 1–32 (full)
- !DevilForever_Core: Defaults.lua 1–524 (full), Presets.lua 1–504 (full), Defaults/SexyMap.lua 1–163 (full), Defaults/Grid2.lua 1–48 (full), Defaults/PitBull4.lua 1–509 (full), !DevilForever_Core.toc 1–27 (full), Core.lua 64–81, 147–164, 243–270, Profiles.lua 896–898, Presets/fhd.lua 440–500, 535–571 (fragment blocks), Registry.lua 1185–1215 (Skin_Nameplates entry), registry_extra.json 805–840, Defaults/Prat-3.0.lua 1–12
- Grid2: GridDefaults.lua 1–268 (full), GridDefaultsRetail.lua 1–41 (full), GridLayout.lua 140–175, 520–575, 845–860, GridLayoutLayouts.lua 20–40, GridRoster.lua 322–410 (grep), GridBlizFramesHide.lua 1–110, Grid2.toc 58–110 (module list), modules/StatusAuras.lua 182–189, modules/StatusHealth.lua 5, 181–183
- Grid2Options: GridProfiles.lua 1–147 (full), profiles/ProfileClassic.lua, ProfileModern.lua, ProfileBlizzard.lua (full, 81/89/90 lines), Grid2Options.toc (profile order 33–35)
- PitBull4: Main.lua 95–240, 315–420, 1700–1725 (grep), Utils.lua 140–330, 458–490, UnitFrame.lua 60–100, Options/Units.lua 450–470, Modules/Totems/Totems.lua 1–60, 200–330, 440–475, 540–600, 640–700, 790–940, Modules/HideBlizzard/HideBlizzard.lua 14–18, 255–280
- ForeverUnitFrames: Core/Commands.lua 60–140, Core/Settings.lua 135–155, Core/Config.lua 26–136 (grep), Core/UnitProfiles.lua 1–113, Core/Storage.lua 40–125, Core/Blizzard.lua 85–165
- DevilForever_FUFDefaults: FUFDefaults.lua 1–171 (full), .toc (full)
- DevilForever_Skin_Nameplates: .toc 1–10, Probe.lua 1–70 (full), SessionProbe.lua 1–167 (full)
- Review/0.1.4: tools/package.py 1–135 (full), tests/run.py 1–160 (full), tests/invoke_suite.py 1–24 (full), perf-probe-zip.json (full), packages/*/manifest.json (ExperienceForever, SexyMap, PitBull4 entries)
- Collection/tools/build.py 1–60, 100–240
- Collection/tests/core/run.py 1–230, 440–600, 1031–1330, 2318–2358; Collection/tests/fufdefaults/run.py 1–375; Collection/tests/install/verify_archives.py 160–200, verify_diagnostics.py 1–20; Collection/tests/pitbull4/run.py (grep 1–261)
- upstream diff (read only): SexyMap/Coordinates.lua, ExperienceForever/ExperienceForever.lua vs Collection/upstream copies

## Baseline
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=108 passed=107 failed=1` (FAIL genregistry_output_matches_file only). Item 7 fixture skip of `Presets/` (core/run.py:129) and the Prat / registry expectations (core/run.py:455–590, 1062–1077) are already current after merge f2d2d7ac — no test change needed for item 7 beyond the orphan file.

## Impact maps (written before each change)

Item 1 — party + raid = Grid2
| Place | Verdict | Reason |
|---|---|---|
| Defaults/Grid2.lua Grid2Layout values (layouts.party/arena, FrameDisplay) | fix together | the request; "Grouped" shows the window in party/arena/raid (GridLayout.lua 855–860); arena set to "By Group" because arena is a grouped type and PitBull4/FUF no longer draw party (my choice) |
| Defaults/Grid2.lua header | fix together | header described "raid groups only" |
| tests/core/run.py GRID2_LAYOUT | fix together | asserts the old values (count unchanged) |
| Defaults/PitBull4.lua groups enabled ×3 | fix together | party groups off, exists/layout kept |
| tests/core/run.py pitbull4 fresh case | fix together | one assertion added (groups exist, off) |
| tests/pitbull4/run.py defaults_spec_matches_the_copy | check only | asserts group names/unit_group only — passes |
| PitBull4 HideBlizzard (party = true default, HideBlizzard.lua:14–25) | check only | still hides Blizzard party frames in the PitBull4 variant |
| Presets/*.lua PitBull4 fragment groups (fhd.lua:453–456) | no impact | positions only, no `enabled` key |
| FUFDefaults.lua run() + header | fix together | FUF shows party by default (Settings.lua:145 `_ = true`); party off + hideBlizzardFrame on (Blizzard.lua:102–104,146: Blizzard party comes back when FUF party is off unless hideBlizzardFrame) |
| tests/fufdefaults/run.py (11 cases' expectations, 1 case renamed/rewritten) | fix together | they asserted "party untouched"; count kept 22 |
| Grid2 hideBlizzard.party | no change | GridBlizFramesHide.lua:42–53 indexes PartyFrame.PartyMemberFramePool without a nil check; not verified on Forever → Decision Queue |

Item 2 — healer indicators
| Place | Verdict | Reason |
|---|---|---|
| Defaults/Grid2.lua values | no change | GridDefaults.lua:85–96 template func runs on the new profile; ProfileClassic.lua:126/130/137, ProfileModern.lua:43–58, ProfileBlizzard.lua:209–228 assign whole i[]/m[] entries incl. border←debuffs-DispellableByMe, alpha←range, health-bar←heals-incoming; values pre-written would be overwritten |
| Defaults/Grid2.lua header | fix together | records the evidence |
| new test firststart grid2_first_start_templates_carry_healer_indicators | new | guards the three templates + preselect "1" (GridProfiles.lua:119,137) |

Item 5 — SexyMap appearance
| Place | Verdict | Reason |
|---|---|---|
| Defaults/SexyMap.lua (appearance merged into the Defaults spec) | fix together | M1: plain target not fresh → FillMissing adds point/scale into an existing profile (Defaults.lua:437) |
| Presets.lua AddFragment + header | fix together | fragments added from a file loaded after the preset files; same validation (fragmentProblem) |
| Presets.lua onAddonLoaded / root fresh path (397–410, 457–464) | check only | root fragment of a fresh SV waits for PEW; existing SV → "kept" + notice |
| !DevilForever_Core.toc order (SexyMap.lua after Presets\*.lua, line 24) | check only | AddFragment needs the presets registered first |
| tests/core/run.py sexymap_* (1240–1323) | check only | run without preset files → no fragment; all pass unchanged |

Item 6 — probes
| Place | Verdict | Reason |
|---|---|---|
| Skin_Nameplates TOC (SV line, Probe.lua, SessionProbe.lua, Notes) | fix together | the request |
| Registry.lua Skin_Nameplates savedVariables | fix together | registry SVs come from the TOC (genregistry.py:194–195) |
| Probe.lua / SessionProbe.lua files | kept on disk | Step 40d moves files; verify_archives.py:180 expects SessionProbe.lua in the archive |
| Review/0.1.4/tools/package.py probe ZIP | no change | builds DevilForever_PerfProbe from Review/0.1.4/diagnostics (perf-probe-zip.json, package.py:109–114) — does not use these files |
| install notes `/dfcheck`, `/dfappearance` (Collection/install/설치안내.md:9,52; Review packages 설치안내.md:14,57; feature-map.md:65,71) | check only → Decision Queue | describe commands that are no longer loaded |
| tests/install/verify_diagnostics.py | check only | loads Probe.lua/SessionProbe.lua directly — passes |

Item 7 — tests / Prat orphan
| Place | Verdict | Reason |
|---|---|---|
| core/run.py fixture skip `Presets/` (129), prat/registry expectations (455–590, 1062–1077) | no change needed | already current after the merge; 107/108 pass at baseline |
| Defaults/Prat-3.0.lua | removed | not in Core TOC, not in Registry.lua/registry_extra.json; only listed in the frozen 0.1.4 file receipt Review/0.1.4/addon-files.json:15,2330,4581 (a record, not a loader) |

Item 8 — manifest labels
| Place | Verdict | Reason |
|---|---|---|
| Review/0.1.4/packages/{fuf,one-session,pitbull4}/manifest.json ExperienceForever, SexyMap | fix together | package.py:95–97 ships these manifest files verbatim with the Collection/AddOns copies (edited bytes) |
| Collection/tools/build.py:193 (`"kind": "unmodified"` for every upstream folder) | no change (reverted my edit) | build.py ships upstream folders from Collection/upstream (upstream_index, build.py:64–74), i.e. unmodified bytes — a "modified" label there would be false; the source decision belongs to Step 40d |

## Commands and verdicts
- `python3 -I Collection/tests/fufdefaults/run.py` → `lupa=2.8 cases=22 passed=22 failed=0`
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=108 passed=107 failed=1` (FAIL genregistry_output_matches_file — Step 40d)
- `python3 -I Collection/tests/firststart/run.py` → `lupa=2.8 cases=7 passed=7 failed=0`
- same new suite against `git archive HEAD` sources (pre-change) → 5 FAIL incl. `existing profile without point/scale keys left as it is` (point/relpoint/x/y/scale/shape/borders added) — the M1 defect reproduced, fixed by this change
- `python3 -I Collection/tests/pitbull4/run.py` → `cases=6 passed=5 failed=1` (FAIL patch_reproduces_the_copy: `Modules/Aura/Libs/LibPlayerSpells-1.0/LICENSE` differs; PitBull4 fork, patch and upstream untouched by this step — not caused here; Codex runner excludes it as build-only)
- `python3 -I Collection/tests/install/verify_diagnostics.py` → exit 0 (both PASS lines)
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_FUFDefaults Collection/AddOns/DevilForever_Skin_Nameplates` → `checked=26 failed=0`
- `<scratch>/cx477.d2Y2/venv/bin/python Review/0.1.4/tests/run.py --output <scratch>/final.JDU0/codex` → `PASS suites=8/8 expected_counted_cases=195`
- Line endings: Presets.lua, Defaults/Grid2.lua, Defaults/PitBull4.lua, FUFDefaults.lua are CRLF in HEAD; restored to CRLF after editing, all gates rerun after that (verdicts above are the rerun).

## Decision Queue
1. Item 3 (targetpet) not done — PitBull4 has no singleton "targetpet": Utils.lua better_unit_ids (176–215) has no targetpet and its metatable only strips a trailing "target", so GetBestUnitID("targetpet") = false; MakeSingletonFrame (UnitFrame.lua:74–78) raises "Bad unit set" for it; SINGLETON_CLASSIFICATIONS (Main.lua:108–118) lacks it. A units entry would raise a Lua error at frame creation. Needs fork support (Step 40c: valid_singleton_unit_ids, better_unit_ids, SINGLETON_CLASSIFICATIONS, wacky update) before the default can be added. targettarget/targettargettarget/focustarget stay on.
2. Item 4 (Totems for shamans) not done — not provable that only shamans see it: Totems.lua:13–38 creates the module for PALADIN (Consecration 26573) and PRIEST (Shadowfiend 34433) as well; :216 returns only for other classes; :817–819 shows it when the spell is known; BuildFrames :658–676 shows a 0.5-alpha background box even with hide_inactive. Profile "Default" is shared by all characters (Defaults/PitBull4.lua:6–10), so a class-dependent default is not possible from Defaults. Options: (a) Step 40c fork gate to SHAMAN; (b) enable globally and accept the paladin/priest box; (c) keep off (current). Dominos totem bar kept.
3. FUF variant, Blizzard party frames: FUF party off is paired with `hideBlizzardFrame on`; if the client refuses either command the record says "error"/"sent" without read-back (FUF saves later). Grid2 hideBlizzard.party not set (unguarded PartyMemberFramePool, GridBlizFramesHide.lua:42–53) — client check needed if wanted.
4. FUF party switch is in the unit profile, which characters can share (UnitProfiles.lua:3–6): the first character with Grid2 turns it off for all sharing that profile; characters with a FUFDefaults record from before this step keep their FUF party frames (no re-run).
5. Arena layout set to "By Group" (my choice; brief said keep unless needed) because "Grouped" shows the window in arena and no unit-frame addon draws party there.
6. Grid2 "Empty" template (GridDefaultsRetail.lua) lacks the dispel border and incoming heals; a user who picks it gets the range fade only. Indicators not verified in the Forever client (statuses load: Grid2.toc 64–110).
7. Install notes still describe `/dfcheck` and `/dfappearance` (Collection/install/설치안내.md:9,52; Review/0.1.4/packages/*/설치안내.md:14,57; Collection/data/feature-map.md:65,71) — no longer loaded by default; needs a doc update or a separate diagnostics folder (Step 40d).
8. Collection/tools/build.py:193 still labels every upstream folder "unmodified" (true for what it ships: Collection/upstream bytes); with ExperienceForever/SexyMap edited in Collection/AddOns the build source decision (C1/M2) is Step 40d.
9. SexyMap appearance now reaches a new character only on a fresh SexyMap2DB or via `/dfp preset <name>` (Presets fragment rule); before, it reached any profile through fill-missing.

## Tests added / changed
- NEW Collection/tests/firststart/run.py (+ fixtures/Presets_Screens.lua; reuses core harness, own suite so the Codex runner counts stay 104/22): sexymap_appearance_fresh_install_from_active_preset (fresh SexyMap2DB gets the active preset's shape/anchor/x/y/scale + borders, functional values too, every preset has one SexyMap fragment) · sexymap_existing_profile_without_appearance_unchanged (M1: existing profile without point/scale keys byte-equal after the session, fragment "kept") · sexymap_new_character_on_existing_install_gets_no_appearance · sexymap_without_presets_registers_no_fragment · grid2_first_start_templates_carry_healer_indicators · nameplate_addon_loads_no_probe (TOC files, no SV line, registry SV empty, files kept on disk) · orphan_prat_defaults_absent
- CHANGED core/run.py: GRID2_LAYOUT (party/arena "By Group", FrameDisplay "Grouped"); pitbull4 fresh case + assertion party groups exist and are off
- CHANGED fufdefaults/run.py: stand-in records both party commands; expectations add the party step (record field `party`, calls RAID+PARTY); shared_profile_alt_keeps_party_on → party_value_in_the_used_unit_profile_decides (nothing stored → sent; Default stores enabled → kept; chosen profile decides; unknown chosen → Default); runs_once adds "record from before the party step → no commands"; command_error adds "hideBlizzardFrame command error → enabled-off not sent, party error"

## State for the next call
No commit made. Working tree changes listed by `git status --short` (13 tracked files + Collection/tests/firststart/ + this work_log).

## Fix 1 (review 1: audit_log-40b.md, TRIAGE "Step 40b review 1")

Read for this fix: audit_log-40b.md 1–10 (full), TRIAGE_phase25.md "Step 40b review 1" (full section), Commands.lua 1–238 (full), Profiles.lua 86–92, 231–246, 894–898, 940–960, 1060–1075, Core.lua 214–237, SexyMap/SexyMap.lua 335–356, 498–505, SexyMap/Borders.lua 827–854, tests/core/run.py 1331–1380, install notes (Collection/install/설치안내.md 1–70, Review/0.1.4/packages/pitbull4/설치안내.md 1–70; fuf/one-session identical in 1–70 by diff), Collection/data/feature-map.md 1–77 (grep 9, 46, 57, 60–72).

### Impact map
| Place | Verdict | Reason |
|---|---|---|
| NEW Core/Party.lua (TOC after Spec.lua) | fix (C1+M1 cause) | one owner decision across Grid2 "$char" and the unit-frame profile: both new this session → Grid2; one new → the new side follows the existing side's owner; neither → nothing; never writes an existing profile automatically |
| Defaults/Grid2.lua Grid2Layout values | fix together | back to the unit-frames-own-party values (party/arena "None", "Raid"); Party.lua writes the Grid2 values |
| Defaults/PitBull4.lua party groups | fix together | back to enabled = true; Party.lua switches them off |
| FUFDefaults.lua party step + header | fix together | commands only when Core.Party:FUFPartyOff() (fresh path), else record party = "unit-frames" |
| Commands.lua `/dfp party [grid2|unitframes]` + help + MAX_WORDS | fix (explicit command) | writes both sides for this character's profiles via Party:Set, combat refusal, lines incl. "/reload"; `/dfp party` alone shows the current owner; name follows the Commands.lua subcommand style |
| Presets.lua fragment field `profileKey` | fix (M2+M3) | per-character freshness (Profiles:KeyWasAbsent) and record key "<SV>@root:<profileKey>"; write deferred to PEW in both modes; merge only (no table created, no non-table replaced, non-table profile skips) |
| Profiles.lua WatchKey / KeyWasAbsent | fix together | the per-key snapshot must be taken before Defaults writes (Profiles' ADDON_LOADED handler runs first); cleared to false when the restore job writes the SV |
| Defaults/SexyMap.lua fragment + header | fix together | uses profileKey, values = the profile body |
| Presets kept notice (PEW, existing code) | check only | prints one line with "/dfp preset <name>" for kept/skipped fragments; per-character keys make it per character |
| Registry.lua Skin_Nameplates `savedVariables = {}` | fix (m1) | generator shape (other entries, e.g. Registry.lua:155) |
| firststart tests | fix (m4) | existing-install premise built from a previous session (CoreDB applied record) |
| install notes ×4, feature-map.md | fix (DQ 7 + upgrade line) | `/dfcheck`, `/dfappearance` described as not loaded by default; Grid2 party line; one `/dfp party` line for upgraders; one-session note keeps the string "/dfcheck comparison" that verify_archives.py:177 looks for |
| tests/core/run.py | reverted to HEAD | GRID2_LAYOUT and the PitBull4 case are again the Defaults values (the switch is Party.lua's) |
| tests/fufdefaults/run.py | fix together | Core stub gains Party:FUFPartyOff (TEST_partyOff); existing-install alt and no-Core cases expect raid only, party "unit-frames"; count 22 |
| m2 FUF read-back, m3 "modified" label, m5 upgrade notice | kept (log only) | master decision |
| targetpet, shaman-only Totems | deferred | Step 40c |

### Commands and verdicts
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=108 passed=107 failed=1` (FAIL genregistry_output_matches_file)
- `python3 -I Collection/tests/fufdefaults/run.py` → `lupa=2.8 cases=22 passed=22 failed=0`
- `python3 -I Collection/tests/firststart/run.py` → `lupa=2.8 cases=14 passed=14 failed=0`
- `python3 -I Collection/tests/pitbull4/run.py` → `cases=6 passed=5 failed=1` (patch_reproduces_the_copy, LICENSE file; untouched, as before)
- `python3 -I Collection/tests/install/verify_diagnostics.py` → exit 0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_FUFDefaults Collection/AddOns/DevilForever_Skin_Nameplates` → `checked=27 failed=0`
- `<scratch>/cx477.d2Y2/venv/bin/python Review/0.1.4/tests/run.py --output <scratch>/fix1.6dVG/codex` → `PASS suites=8/8 expected_counted_cases=195`
- CRLF kept: Commands.lua, Defaults/Grid2.lua, Defaults/PitBull4.lua, Presets.lua, Profiles.lua, FUFDefaults.lua, Skin_Nameplates TOC, three package 설치안내.md (every line CRLF); LF files stay LF; Party.lua new, LF.

### Tests (firststart, 14)
SexyMap: fresh install written per profile key · existing profile (CoreDB applied record) unchanged, "kept", one notice line with "/dfp preset fhd" · second character gets its own appearance merged into SexyMap's profile, two records · request with "global" choice → skipped, global untouched, no errors · request into a nil profile → SexyMap's full core kept + appearance · no presets → no fragment. Party: fresh install both load orders → Grid2 party + PitBull4 groups off; FUF fresh → FUFPartyOff true · existing installs (PitBull4 existing, Grid2 existing, both, FUF existing) → existing sides unchanged · new Grid2 profile follows an existing PitBull4 profile without party · command both directions (Grid2, PitBull4, FUF commands, /reload line, `/dfp party` view, help, unknown word) · combat refusal writes nothing. Plus Grid2 templates, nameplate TOC, Prat (unchanged).

### Decision Queue (fix 1)
10. One side new → the new side follows the existing owner (my reading of "change neither side"): it keeps an alt consistent after `/dfp party grid2` (shared PitBull4 Default off → the alt's new Grid2 profile shows party). Existing sides are never written automatically.
11. FUF "new" = ForeverUnitFramesDB nil at its ADDON_LOADED; a FUF profile restored from FUF's macro backup in that session counts as new (FUF's private Storage source is not readable).
12. Party settles once per session at the first look where Grid2 and exactly one unit-frame addon are loaded; both PitBull4 and FUF loaded (one-session misuse) → nothing.
13. `/dfp party` writes the saved-variable tables of the running addons; the frames change after /reload (printed). PitBull4/FUF profiles may be shared by other characters (printed).
14. M3 notice: "already" now only happens for a character whose own key was recorded (it has the appearance), so the notice covers kept/skipped.

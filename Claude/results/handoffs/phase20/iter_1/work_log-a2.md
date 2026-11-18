# Work log — Phase 20 Step 33 (save/restore module + preset layer in Core) — work A2

Raw output: scratchpad `step33.RAy6/` (volatile; the verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/phase20/design-32.md` (whole, 467); `DECISIONS_32.md` (whole, 9); `SESSIONS.md` (whole, 8)
- Core (whole): `!DevilForever_Core.toc` (19), `Core.lua` (268), `API.lua` (171), `Defaults.lua` (509), `Edit.lua` (264), `Theme.lua` (185); `registry_extra.json` (JSON data — Python dump of every folder's keys, `saved_variables`, `defaults`, `bundle`); `Registry.lua` (generated data — every addon's SV list via lupa)
- `Collection/tools/genregistry.py` (whole, 390); `build.py` 1–60
- `Collection/tests/core/run.py` (whole, 1297); fixtures `Registry_Test.lua` (whole), `Defaults_Example.lua` (whole); other suites grep (they stub Core, none load Core files)
- Briefs: `Collection/codex-briefs/phase14.md` (whole), `appearance-2-layouts.md` (whole), `phase19.md` (whole, latest form), grep of all briefs for ZIP sources/hashes (phase3/10/15 lines)
- Plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` lines 232, 407, 408, 428, 451
- `Claude/results/handoffs/phase19/iter_1/work_log-a2.md` (whole — gate commands precedent)
- Upstream (read only): LibDualSpec `Dominos-12.0.4/Dominos/libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` 40–100, 160–280, 505–545; `Dominos/Dominos.lua` 250–272; PM `Keybinds.lua` 1–30, 225–262, 290–390; `GameSettings.lua` 1–12, 45–60, 320–420; `Commands.lua` 140–160; PM AceDB-3.0 grep (db_registry 56, sv 341, parent 344, registry 347); PM `Providers.lua` 3060–3080
- `Collection/manifest.json` (Python: source ZIP + sha256 of Details, Dominos, Grid2, Quartz, SexyMap, ProfileManager)

## Baseline gates (before any edit)
- `python3 -I Collection/tests/<suite>/run.py`: core `cases=61 passed=61 failed=0`, castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`

## Steps
1. `Core.lua`: header contract line → 「changes no frame directly; writes registered saved variables only at load time after a user command」 (decision 3); new `Core.CopyData` (cycle-safe plain-data copy, returns copy + dropped count); new `Core.FindAceDB(sv)` (root AceDB object on that table, `db_registry`); `DB_LAYOUT.preset = {fragments = {}}` + layout comment.
2. `Edit.lua`: layer order token < registry default < active preset (`Core.Presets:GetValue`) < stored edit; header comment; new `Edit:FireChanged(frameKey, field)` (listeners, refused in combat).
3. New `Profiles.lua` (store `DevilForever_ProfilesDB`, requests, load-time save/restore jobs, merge/carry, version check, AceDB too-late check, `__before-restore`, report), `Presets.lua` (register/validate, active, restore, fragments requested/fresh, first-run pick), `Spec.lua` (LibDualSpec link/new/off), `Commands.lua` (`/dfprofile`, `/dfp`, PM pass-through).
4. TOC: `## SavedVariables: DevilForever_CoreDB, DevilForever_ProfilesDB`; order Core, Registry, Theme, Edit, Profiles, Defaults, Defaults\*, Presets, (Presets\* comment line), Spec, Commands, API. `API.lua`: header (registry fields, Presets/Profiles/Spec/commands, contract sentence) + `GetSavedVariables` returns `restore` ("skip" when absent), `shape`, `keys`.
5. `genregistry.py`: `apply_sv_options` (options split/restore/shape/keys; class ⇒ profile+acedb; profile ⇒ class; keys ⇒ non-empty distinct strings; keys only with restore keys; restore whole/keys/profile needs shape; unknown option stops); fields written only when given. `registry_extra.json` (round-trip of old file identical with `indent=2, ensure_ascii=True` → True): design §4.1 table — Dominos profile/acedb/class; Grid2, Hekili, Masque, PitBull4, Quartz, Prat3DB, EF whole/acedb; FUF, SexyMap, Aurora, StatusStrip, Details_Streamer whole/plain; Details `_detalhes_global` keys `__profiles`, `_detalhes_database` keys `active_profile`; diff `+69 −12` lines (new folder blocks Masque, Aurora, Details_Streamer).
6. `genregistry.py` → `wrote Collection/AddOns/!DevilForever_Core/Registry.lua (54749 bytes, sha256 6e0f7388dfb52f7d61502d4e5279bd61ad9ba52a1d2972fb70cece0a8e9b6d4f)`.
7. luacheck first run → `checked=18 failed=1` (`API.lua:82` — `]]` inside the header block comment ended it); fixed argument notation → `checked=18 failed=0`.
8. core tests after code + registry → `cases=61 passed=58 failed=3`, all expected from the design: `core_without_other_addons` (Core DB layout gains `preset`), `generated_registry_lookup` (SV dicts gain `restore`/`shape`), `genregistry_extra_applied_and_checked` (input `split class` alone now refused — design §4.1 rule). Expected values updated (9 SV dicts, layout set, extras input); → `cases=61 passed=61 failed=0`.
9. Tests (`Collection/tests/core/run.py` + fixtures `Registry_Profiles.lua`, `Defaults_Profiles.lua`, `Presets_Test.lua`): stubs `time`/`ReloadUI`/`print` sink/`C_AddOns.GetAddOnMetadata`/`LibStub` (fake AceDB-3.0, LibDualSpec-1.0)/`SlashCmdList`; `Session` takes `registry="profiles"`, `preset_files` (run after `Presets.lua`), dict globals converted to Lua tables. New cases T1–T28 (`profiles_t1…`, `presets_t18…`, `spec_t25…`, `genregistry_t28…`). First run → `cases=89 passed=81 failed=8`: preset files run before `API.lua` (TOC order) and `Presets:Register` called `Core:GetFrameKeys` (nil at that time) — a real load-order bug, fixed by reading `Core.Registry` directly in `Presets.lua`; then `presets_t27` failed because a Python lambda is not a Lua function for `type()` — stub now defined in Lua. → `cases=89 passed=89 failed=0`. T13 tightened (every command must say 「전투 중」; `cancel` and `spec new` now check combat first; `/dfp keys|game save|load` check combat before PM lookup).
10. Gates: `genregistry.py` ×2 → both `wrote … (54749 bytes, sha256 6e0f7388dfb52f7d61502d4e5279bd61ad9ba52a1d2972fb70cece0a8e9b6d4f)`; `--check` → `check Collection/AddOns/!DevilForever_Core/Registry.lua: up to date (54749 bytes)` rc0; luacheck (Core + core fixtures) → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=21 failed=0`; tocdeps (Core) → `folders=1 unresolved=0 client_provided=0 optional_missing=0 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` rc0; suites: core `89/89`, castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`.
11. `build.py` ×2 → `built folders=6 files=335 zip_entries=337`, sha256 `58f9e751b976a87b4469ffdc7c67a8d61dbdc67861b31ea7afdbbb409b5cdee9` both.
12. Briefs: old ZIP hash `0ee2aca3…727a7e49` (28 occurrences, 28 files) → `58f9e751…5cdee9`; after: old 0 occurrences; new hash in 29 files (28 + new `phase20.md`); diff = hash lines only (28 +/28 −, no other changed line); ZIP contents lists unchanged (same six folders). `phase1.md`, `appearance-2-layouts.md` carry no ZIP hash (before or after).
13. New `Collection/codex-briefs/phase20.md` (items 0–11; item 0 and item 11 follow `phase14.md`; moved folders → `forever_moved_phase20/`; full restore renames current folders aside and copies the backup back). `/run` byte lengths 175, 193, 117, 131, 117, 215, 81, 197, 157 (all ≤ 255); each `/run` body compiles as Lua 5.1 (lupa `loadstring`, 9/9 True); item 7 lines run in the test harness (generated registry) → outputs `1 true applied` / `t preset 적용 — 편집값을 지운 프레임 1개` / `CENTER 0 -200 t nil` — brief expectation corrected from `… t true nil` (a call in the middle of an argument list gives one value).
14. `Collection/codex-briefs/appearance-2-layouts.md`: new §5 addendum (decision 13: layer order, first-run pick, fragment header fields, Claude wraps into `Presets/<name>.lua`, when fragments are written). Banned words (정본·거울·문면·문안·전량·발동·수권) → 0 in `phase20.md` and `appearance-2-layouts.md`; confirmed terms of `.claude/tools/banned_lexicon.json` → 0 in both.

## Impact map (change → linked places)
| Place | Verdict |
|---|---|
| `Core.lua` header line 3 + `API.lua` closing sentence (contract) | changed together (decision 3) |
| `Core.lua` `DB_LAYOUT` (+`preset`) | changed; `tests/core` `core_without_other_addons` layout set changed with it; `Edit`/`Theme`/`Defaults` read their own keys only — no effect |
| `Edit.lua` `Get` layer | changed; header comment updated; existing Edit cases unchanged and pass (no preset registered → GetValue nil) |
| `API.lua` `GetSavedVariables` (+restore/shape/keys) | changed; callers: `Profiles`, `Spec`, `Presets` (not — reads Registry directly), `registry_frame_lists` test (tuples, unaffected) |
| `genregistry.py` options + `registry_extra.json` | changed; `Registry.lua` regenerated; `generated_registry_lookup` SV dicts (9) and `genregistry_extra_applied_and_checked` input changed |
| Core TOC (files, SavedVariables) | changed; `Registry.lua` Core entry gains `DevilForever_ProfilesDB`; tocdeps 0 unresolved; build includes new files |
| Defaults (`Suppress`, handler order) | check only — Profiles handler registered before Defaults' (TOC), Presets after; `Defaults.lua` not changed |
| ZIP + hash in 28 briefs | hash replaced only |
| Other suites (castbars, chatsetup, fufdefaults, pitbull4, statusstrip) | check only — they stub Core; all pass |
| `Claude/` records with the old hash | no change (record) |

## Gates (final)
- luacheck (Core + core fixtures) → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=21 failed=0`
- tests: core `lupa=2.8 cases=89 passed=89 failed=0` (61 existing + T1–T28), castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`
- `genregistry.py` ×2 identical (`54749 bytes, sha256 6e0f7388…6d4f`); `--check` → `up to date (54749 bytes)` rc0
- tocdeps (Core) → `folders=1 unresolved=0 … duplicates=0 load_on_demand=0` rc0
- `build.py` ×2 → `built folders=6 files=335 zip_entries=337`, sha256 `58f9e751b976a87b4469ffdc7c67a8d61dbdc67861b31ea7afdbbb409b5cdee9` both; old hash in briefs 0
- `/run` ≤ 255 bytes (max 215); banned words 0

## Deviations from design-32 (A2 judgment)
1. Registry `restore`/`shape`/`keys` are written only when the extras give them; absent `restore` = "skip" (`GetSavedVariables` returns "skip"). Keeps SV entries of unclassified SVs unchanged.
2. Generator rules beyond §4.1: `restore = profile` needs `split = class`; `restore` whole/keys/profile needs a `shape`; `keys` only with `restore = keys`, distinct strings; unknown option names stop the generator.
3. The pending request is removed at Core's ready step (taken into the session job), not at the first PLAYER_ENTERING_WORLD, so a crash mid-load cannot replay it.
4. Snapshot names: no spaces, ≤ 48 bytes, not starting with `__` (reserved for `__before-restore`).
5. Store root of the wrong type or unknown schema → whole module read-only (no session-only store); an unknown-schema snapshot is also refused by `/dfp delete`.
6. New public helpers: `Edit:FireChanged` (preset change → Edit listeners), `Core.FindAceDB`, `Profiles:WasFresh` (fresh-at-load is recorded in Profiles' handler because Defaults' handler may create an AceDB SV before Presets' handler runs), `Presets:Get/IsRegistered/PickForScreen/GetFragmentStatus`, `Profiles:CanRequest/SetPending/TakePresetRequest`.
7. Fresh-target fragment rule runs every session for unrecorded fragments of the active preset (also covers an addon installed later), not only at first install.
8. Class restore writes the saved profile names exactly: a name absent in the snapshot (AceDB-stripped) is set nil, namespace profiles of those names absent in the snapshot are set nil, and this character's LibDualSpec entry is set nil when the snapshot had none.
9. Core layout restore keeps the current `preset.active` when the saved preset name is not registered.
10. `/dfp show` also takes `[all|common|class] [only <Folder>]`.
11. Chat strings are Korean in code (no locale table); prefix `[DF 설정]`, no colour codes.
12. `Presets.lua` reads `Core.Registry` directly (preset files run before `API.lua` in TOC order).

## Decision Queue
1. Details `keys` choice (`__profiles`, `active_profile`) is still [U]; brief item 3 records 「Details 안 됨」 if `update_speed` does not return.
2. Fragment writes cannot be checked in game in Phase 20 (no preset files yet, R109); brief item 7 checks the Core layer only with a temporary preset.
3. Fragment `addonVersion` falls back to the registry version when `GetAddOnMetadata` is missing; registry versions of start packages are package versions (e.g. `ExperienceForever2.0.4`), so on a client without that API fragments would be skipped. Brief item 1 records whether the API exists.
4. Core TOC `## Version` stays `0.1.0` (not asked to bump); snapshot entries of our own addons compare against it.
5. Preset fragments have no undo slot (design gives `__before-restore` only to `/dfp restore`).
6. A read-only store prints its reason at every login.
7. Pending validity needs the player name at Core's ADDON_LOADED [U]; when unknown the request is dropped and reported.
8. `/dfp spec new` switches the profile to the copy and back (two Dominos profile-change callbacks), out of combat only.

## fix 1 (review → `Claude/results/handoffs/phase20/TRIAGE_phase20.md`, read whole, 33 lines)
Read for the fix: `Profiles.lua` 200–320 (requests), 540–937 (write, jobs, events) and header 1–45; `Commands.lua` 30–75, 110–175; `Presets.lua` Restore/onAddonLoaded/PEW handler (edited by anchored replace after the step-33 reading); `phase20.md` lines 12, 18 and item 3. Pre-fix copies of `Profiles.lua`, `Presets.lua`, `Commands.lua` in scratchpad `step33.RAy6/`.

| ID | Change |
|---|---|
| ①-1 | `SetPending` stores `keys` (char, realm, class, className). Key unknown at the ready step: a request armed ≤ `KEY_FALLBACK_AGE` (120 s) ago runs with the stored keys; `PLAYER_LOGIN` handler checks the character — unknown → 「확인하지 못함」 line, different → printed `!! 경고 … /dfp restore __before-restore 후 /dfp go`. Presets uses `request.keys` when the key is unknown. |
| ③-1 | `processRestore` sets `freshAtLoad[sv] = false` before writing → `WasFresh` false; fresh-mode fragments skip it. |
| ③-2 | `finishRestore`: when the source is `__before-restore`, entries (and core part) of the old slot not written now are kept with `carried = true`; user-snapshot sources keep the one-slot rule. |
| ③-3 | `characterRenames`: a saved profile name that is another character's own profile (name = that character key = its profileKeys target, not this character's) is written to a profile named after this character; profileKey and LibDualSpec entries mapped; backup reads the target names; rename line in the report. Class/shared names unchanged. |
| a | `phase20.md` item 0 「열두」 → 「열한」 (11 folders listed). |
| ②-a | First PEW without a request: one chat line when fragments of the active preset were kept/skipped. |
| ③-b | Version check moved to the ready step (`consider`); only passing folders are suppressed; the note travels with the item. |
| ③-c | `restorableKeys` = saved keys ∩ registry keys; dropped-key count reported. |
| ③-d | Requests carry `armed = false`; `/dfp go` sets `armed`, `armedAt`; un-armed requests are kept and reported at login, not used; age measured from `armedAt`. |
| ③-e | `Presets:Restore` with fragments sets `CoreDB.preset.unfinished`; cleared when that request runs; while set, each login prints 「… 아직 쓰이지 않음 — /dfp preset X 을 다시 하면 끝남」. |
| ③-f | `RequestRestore` refuses an `only` folder not in the registry (Core's own name allowed). |
| ③-g | `partArgs`: part words and `only` in any case, nothing after the folder; `MAX_WORDS` per command rejects extra words; `delete … YES` lower-cased. |
| ③-k | Tests: `profiles_fix_request_waits_for_go`, `profiles_fix_player_key_unknown_fallback`, `profiles_fix_restored_sv_not_fresh_for_fragments`, `profiles_fix_undo_of_undo_keeps_unwritten_entries`, `profiles_fix_class_restore_other_characters_own_profile`, `profiles_fix_suppress_after_version_and_keys_intersect`, `profiles_fix_command_arguments`, `presets_fix_unfinished_and_kept_lines`; T26 now runs the restore load after `/dfp go` with the fake PM; T14 adds `/dfp go` (requests need arming). |
| ②-b | accepted risk — not changed. |

Header comments updated with the behaviour: `Profiles.lua` (keys restore, character-named profiles, arming, key fallback, suppress after checks, WasFresh, undo carry), `Presets.lua` (unfinished, kept line), `Core.lua` DB layout (`preset.unfinished`).

### Impact map (fix 1)
| Place | Verdict |
|---|---|
| `Profiles.lua` pending/keys/armed, WasFresh, undo, class restore, suppress order, keys list, only validation | fixed |
| `Presets.lua` kept line, unfinished, request keys | fixed |
| `Commands.lua` parsing | fixed |
| `Core.lua` DB layout comment | fixed (comment) |
| `tests/core/run.py` | new cases + T14/T26 changed with the arming rule |
| `phase20.md` line 12 (arming, 600 s from go, key fallback), line 18 (count), item 3 (`/reload` without go check + result field) | fixed; other items re-read against the code — unchanged (item 5 lines, item 10 combat lines, item 2 report) |
| `appearance-2-layouts.md` §5 | check only — fragment rules unchanged |
| `design-32.md` | no change (record) |
| ZIP + hash in briefs | rebuilt; hash replaced |

### Gates (fix 1)
- luacheck (Core + core fixtures) → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=21 failed=0`
- tests: core `lupa=2.8 cases=97 passed=97 failed=0` (first run 96/97: new test read `suppressed` as a key — absent when nil; test fixed to `.get`), castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`
- `genregistry.py --check` → `check Collection/AddOns/!DevilForever_Core/Registry.lua: up to date (54749 bytes)` rc0 (registry inputs unchanged)
- tocdeps (Core) → `folders=1 unresolved=0 client_provided=0 optional_missing=0 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0`
- `build.py` ×2 → `built folders=6 files=335 zip_entries=337`, sha256 `a4bb880122b243f598e15f4aef24ca35624b7c9665d6fc5716ea416102d27fa5` both
- briefs: old `58f9e751…` 29 occurrences → 0 left (also 0 anywhere under `Collection/`); new hash in 29 files
- `/run` bytes 175, 193, 117, 131, 117, 215, 81, 197, 157 (≤ 255), all compile; banned words 0 in `phase20.md` and `appearance-2-layouts.md`

## fix 2 (re-check 1 → `TRIAGE_phase20.md` section 「Re-check 1」, lines 35–46, read whole)
Read for the fix: `Profiles.lua` header 1–45, `characterRenames` 592–604, `takePending` 792–830, Cancel 311, finishRestore backup 969; `Presets.lua` 24–40, 228–245, 372–388, 462–492; `phase20.md` line 12, item 3. Pre-fix copies: scratchpad `step33.RAy6/fix2_before/`.

| ID | Change |
|---|---|
| ③'-1 | Key unknown at load (fallback ≤ 120 s): save requests dropped; restore writes only account-scope common entries (+ Core layout part) — character-scope SVs and the whole class part skipped with 「캐릭터를 모름 — 건드리지 않음(캐릭터 확인 뒤 다시 /dfp go)」; preset request skips `section = profile` and character-scope fragments; `__before-restore` labelled `savedBy.char = "unknown"` (holds account-wide entries only, so any character can undo). Login check kept. |
| ③'-2/-3/-8 | `profilesOfOthers` = targets of other characters' `profileKeys` and LibDualSpec group entries; such a saved name is never written; `characterRenames` allocates a free target (`keys.char`, `keys.char (2)`, …) not used by others and not already a target of the entry; every rename reported; LDS groups of this character mapped. Shared class-named profiles used by others are now also protected (one rule). |
| ③'-4 | `preset.unfinished` cleared by any `Presets:Restore`, by any completed request, and by `/dfp cancel` of a preset request. |
| ③'-5 | Un-armed notice goes to `noticeLines` (printed, not stored in `last`), only when the logged-in character is the requester. |
| ③'-6 | Kept/skipped fragment line printed only when the set (ids + target keys) differs from `CoreDB.preset.keptNotice`. |
| ③'-7 | Contract wording in `Core.lua` header and `API.lua`: 「writes registered saved variables only at load time: after a user command, or preset values into saved variables that are new on disk」. |
Tests: new `profiles_fix2_key_unknown_alt_after_interrupted_reload` (B probe: Hero arms, Alt logs in at +60 s with name unknown at load), `profiles_fix2_save_refused_with_unknown_key`, `profiles_fix2_shared_character_named_profile` (Sage/Cara share "Sage - Realm" → "Sage - Realm (2)"), `profiles_fix2_other_characters_lds_profile` (Hero's LDS group-2 "Hero Heal" untouched; Sage gets two distinct targets), `profiles_fix2_unarmed_notice_and_unfinished_cleared`. Changed with the rules: `profiles_fix_class_restore_other_characters_own_profile` (shared "Warrior" used by Ally now renamed, not written); `presets_fix_unfinished_and_kept_lines` (stuck case is now a timed-out request, since cancel clears the flag; kept line not repeated). First run `100/102`: two test clock artifacts (next session at an earlier `TEST_time` → negative age); fixed in the tests.
Brief: `phase20.md` line 12 (narrowed fallback; un-armed notice only to the requester); item 3 note on the Dominos rename when another character shares the class profile.

### Impact map (fix 2)
| Place | Verdict |
|---|---|
| `Profiles.lua` takePending/startRestore/characterRenames/finishRestore/Cancel/PEW notice | fixed |
| `Presets.lua` key-unknown fragment skip, unfinished clearing, keptNotice | fixed |
| `Core.lua` header + DB layout comment, `API.lua` closing sentence | fixed (contract wording) |
| `Commands.lua` | check only — no change |
| `tests/core/run.py` | new cases + 2 cases changed with the rules |
| `phase20.md` line 12, item 3 | fixed; items 4–10 re-read — unchanged |
| `appearance-2-layouts.md` §5 | check only — fragment-to-fresh rule unchanged |
| ZIP + hash in briefs | rebuilt; hash replaced |

### Gates (fix 2)
- luacheck → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=21 failed=0`
- tests: core `lupa=2.8 cases=102 passed=102 failed=0`; castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`
- `genregistry.py --check` → `up to date (54749 bytes)` rc0
- tocdeps (Core) → `folders=1 unresolved=0 client_provided=0 optional_missing=0 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0`
- `build.py` ×2 → `built folders=6 files=335 zip_entries=337`, sha256 `b6392ea37d7cfefa123a3ef023ded82990c1be27826af6f54e23abc6bafd51c1` both
- hash: `a4bb8801…` 29 occurrences → 0 under `Collection/`; new hash in 29 files
- `/run` 175, 193, 117, 131, 117, 215, 81, 197, 157 bytes, all compile; banned words 0 (`phase20.md`, `appearance-2-layouts.md`)

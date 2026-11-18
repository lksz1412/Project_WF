# Work log — Phase 22 Step 36 (theme token-set switch interface + Codex alternate-theme brief) — work A2

Raw output: scratchpad `step36.EUeA/` (volatile; the verdict lines below are the record).

## Read (basis)
- Core (whole): `Theme.lua` (185), `Edit.lua` (276), `Presets.lua` (501), `Profiles.lua` (1112), `Commands.lua` (200), `Core.lua` (318), `!DevilForever_Core.toc` (24); `API.lua` header 1–135 and body 136–215 (whole)
- `Collection/codex-briefs/appearance-2.md` (whole, 36), `appearance-2-layouts.md` (whole, 52, incl. §5 addendum), `phase14.md` (whole, 77); `phase20.md` 1–25 and item 11 (latest brief form)
- Plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` lines 225–240 (row 22 = 234), 278–290 (item 4 = 284), 345–352 (349), 400–408 (405), 448–456 (row 22 = 452)
- `Collection/tests/core/run.py` 1–222 (harness), 576–745 and 845–862 (theme/edit cases), 1310–1420 (profiles helpers), 1569–1582, 1661–1680, 2140–2187; fixtures `Registry_Profiles.lua` (grep frames), `Presets_Test.lua` (grep p.bar)
- `Claude/results/handoffs/phase20/iter_1/work_log-a2.md` 1–120 (gate command precedent)
- `.claude/tools/banned_lexicon.json` (whole, via Python dump)
- grep: `RegisterSet|Theme:` in `Collection/AddOns` (no user outside Core); `References/` listing (no `codex-appearance/` yet)

## Baseline gates (before any edit)
- suites: core `cases=102 passed=102 failed=0`, castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`
- luacheck (Core + core fixtures) → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=21 failed=0`
- `genregistry.py --check` → `up to date (54749 bytes)`; ZIP sha256 `b6392ea3…bafd51c1`

## Findings (check of the four points)
1. Registration: `Theme:RegisterSet(name, values)` exists, same 20 token names, fallback to `devil` in `Get`. Gaps: fallback not reported; a name with spaces could be registered but not chosen by a one-word command; replacing the base set while an alternate is active changed resolved values without telling listeners.
2. Switching: persists via `switch()`, combat queue on `PLAYER_REGEN_ENABLED`, `Edit:Get` reads tokens live so edits and preset values stay on top (confirmed by test). Gap: an `"unchanged"` switch (and a queued switch to the already active set) did not save the choice — after a login where the saved set was not registered, choosing `devil` left the old name on disk.
3. Profiles: snapshot `core.theme` = `theme.active`, restore writes it at the ready step, `Theme` applies it at `PLAYER_LOGIN` (confirmed by test). No gap.
4. Command: none. Gap.
5. File shape: theme files belong in the Codex appearance folder (`<appearance>/Themes/<name>.lua` calling `RegisterSet`), the same place the `devil` values go (`appearance-2.md` 2-1, 2-5); assets live beside them; any addon file runs before `PLAYER_LOGIN`, so no Core TOC slot is needed (unlike preset fragments). A2 judgment — differs from the example `Core/Themes/<name>.lua`.

## Steps
1. `Theme.lua`: header contract (name rule, fallback report, base replacement notifies); `RegisterSet` refuses empty/space names and non-table values with an `error` log; non-base set logs `info "<n> tokens not set, base set values used: …"`; replacing the active or the base set fires `(activeName, activeName)` (held in combat); `SetActiveSet` saves on `"unchanged"`; `PLAYER_REGEN_ENABLED` saves a queued name equal to the active one. No look values added.
2. `Commands.lua`: `/dfp theme` (list with `(지금)`, `(전투 뒤 바뀜)`, missing count, saved-but-unregistered line), `/dfp theme <name>` (refused in combat like every other changing command; unknown name refused), `MAX_WORDS.theme = 2`, help line, `테마:` line in `/dfp status`, header line (theme switch at once). Uses only `ListSets`/`ListTokens`/`GetFromSet`/`GetSet`/`SetActiveSet` (no new public function → `API.lua` stays true).
3. Tests (`run.py`, 6 cases): `theme22_register_names_and_fallback_reported`, `theme22_base_replacement_notifies_active_alternate`, `theme22_switch_persists_and_combat_waits`, `theme22_edits_and_presets_overlay_new_tokens`, `theme22_snapshot_carries_active_theme`, `theme22_command_list_switch_and_refusals` → first run `cases=108 passed=108 failed=0`.
4. Build ×2 → `built folders=6 files=335 zip_entries=337`, sha256 `718c3f4a378867550e8d40ec27cccb99302470348ac4f2d090aac8f809cfd874` both.
5. Briefs hash: old `b6392ea3…` 29 occurrences in 29 files → 0; new hash in those 29 (diff = hash lines only: 29 +/29 −, other changed lines 0) + the two new briefs.
6. New `Collection/codex-briefs/appearance-22.md` (30 lines) and `phase22.md` (items 0–9; item 0 and item 9 follow `phase14.md`, moved folders → `forever_moved_phase22/`, full restore renames current folders aside and copies the backup back; test addon `DFThemeCheck` stands in for skins).
7. Brief simulation: test addon code from the brief + every `/run` line and `/dfp` step of items 1–7 run in the harness (profiles registry) → outputs matched except items 5 and 6 (a call in the middle of `print` gives one value, `GetSet` at the end gives two): expectations corrected to `true check_b check_a` and `false check_a nil`; note added for extra `devil>devil` lines when an appearance folder registers `devil`. errors `[]`.

## Impact map
| Place | Verdict |
|---|---|
| `Theme.lua` RegisterSet / SetActiveSet / REGEN handler | changed |
| `Theme.lua` header comment | changed with it |
| `Edit.lua` (reads `Theme:Get`) | check only — unchanged behaviour; overlay confirmed by new test |
| `Profiles.lua` (core layout `theme.active`) | check only — unchanged; snapshot chain confirmed by new test |
| `Commands.lua` | changed (theme, status, help, header) |
| `API.lua` header (Theme lines, Callbacks paragraph) | check only — function list still true; base-set notify not named there (outside boundary → Decision Queue 1) |
| `appearance-2.md` 2-1 | check only — still true; name rule and file shape given in `appearance-22.md` |
| existing tests (theme, callback error, t13 combat loop, status) | check only — all pass unchanged |
| other suites | check only — they stub Core; all pass |
| ZIP + hash in 29 briefs | rebuilt; hash replaced only |
| `Claude/` records with the old hash | no change (record) |

## Gates (final)
- luacheck (Core + core fixtures) → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=21 failed=0`
- suites: core `lupa=2.8 cases=108 passed=108 failed=0`, castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`
- `genregistry.py --check` → `check Collection/AddOns/!DevilForever_Core/Registry.lua: up to date (54749 bytes)` rc0
- tocdeps (Core) → `folders=1 unresolved=0 client_provided=0 optional_missing=0 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0`
- build ×2 → sha256 `718c3f4a…09cfd874` both; old hash in briefs 0
- `/run` lines: `phase22.md` 7, max 143 bytes, all ≤ 255, 7/7 compile (lupa `loadstring`); `appearance-22.md` 0
- banned words (정본·거울·문면·문안·전량·발동·수권 + other confirmed lexicon terms) → 0 in both briefs

## Decision Queue
1. `API.lua` header Callbacks paragraph does not say that replacing the base set also notifies (and is held in combat). Outside the write boundary — one-line addition for master if wanted.
2. Theme file shape: Codex appearance folder `Themes/<name>.lua` (not `Core/Themes/`), A2 judgment (Findings 5).
3. `/dfp theme <name>` in combat refuses (Commands rule "every changing command refuses in combat") instead of queueing; queueing stays available through `Theme:SetActiveSet`.
4. The Codex appearance folder (Phase 2) is not in the repository yet, so the verification uses the test addon `DFThemeCheck`; item 8 (theme screens) is `못 함` until it arrives. The three layouts cannot be switched in game yet (no `Presets/<name>.lua` files in Core, R109), so the brief checks the current resolution only; `appearance-22.md` asks Codex for theme × layout captures.
5. In combat, a queued switch is saved only after combat; a `/reload` during combat loses it.

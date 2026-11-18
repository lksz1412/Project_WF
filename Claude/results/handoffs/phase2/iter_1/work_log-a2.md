# work_log — A2 coder — Phase 2 Step 11 — DevilForever_Core

## Read (full unless a range is given)
- `Claude/results/handoffs/phase2/brief-a2.md` 1–end
- `Claude/results/handoffs/phase2/SESSIONS.md` 1–end
- `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 209–229 (feature table), 302–334 (Implementation Changes), 391–406 (Implementation Interfaces)
- `Claude/plans/2026-11-18-devil-forever-addon-collection-phase2-세부계획.md` 1–end
- `Collection/manifest.json` — DB-type data, read by Python: top-level keys, every package's name/role/feature_phases/how_to_use, every addon folder's TOC file/interface/forever_load/SavedVariables/SavedVariablesPerCharacter
- `Collection/judgment.md` 20–212 (§1–§3)
- `Collection/tools/toclib.py` 1–231, `luacheck.py` 1–96, `tocdeps.py` 1–139, `build.py` 1–60
- V42 `!DevilUI/!DevilUI.toc` 1–end; `!DevilUI.lua` 1–45, 164–240, 765–806, 967–976, 1096–1207; grep of InCombatLockdown/PLAYER_REGEN/IsEditModeActive in `!DevilUI.lua` and `minimap.lua`; `minimap.lua` 144–150, 973–1080
- Upstream (data only): `nugie-combo-bar-12.1.3/NugComboBar/Libs/AceDB-3.0/AceDB-3.0.lua` 89–125, 255–292 (charKey/classKey, copyDefaults) and grep of profileKeys/defaultProfile; `Dominos-12.0.4/Dominos/Dominos.lua` 250–262 (default profile = localized UnitClass)

## Environment
- lupa present: 2.8 (`python3 -c "import lupa;print(lupa.__version__)"`)

## Steps
1. `Collection/tools/genregistry.py` written: manifest `role == "start"` packages + own folders under `Collection/AddOns/` (TOC parsed by toclib) + optional `registry_extra.json`; TOC choice mirrors `toclib.tocs_for_interface`; sorted Lua literal, no timestamps; `--check` mode; extras validated (unknown folder / undeclared SV / bad field / min>max / defaults file missing or not in Core TOC / path outside Core → error rc2).
2. `Collection/AddOns/DevilForever_Core/`: `DevilForever_Core.toc` (16001, SV `DevilForever_CoreDB`), `Core.lua`, `Registry.lua` (generated), `Theme.lua`, `Edit.lua`, `Defaults.lua`, `API.lua`, `registry_extra.json` (`{"addons": {}}`).
3. `Collection/tests/core/run.py` + `fixtures/Registry_Test.lua`, `fixtures/Defaults_Example.lua` (example defaults file lives in tests only, not in the addon).
4. Fixes found by own test runs (before gates): lupa loadstring tuple handling and `lua51.lua_type` in the runner; Defaults no longer creates an empty `applied[folder]` before anything is written; `Core:DBTable` no longer replaces a stored `false`; internal helper renamed `Core.IsLoadedInClient` (was one letter-case away from public `Core:IsAddonLoaded`).

## Gates (raw output: scratchpad `gates.ccdg/`)
- `python3 -I Collection/tools/genregistry.py` (run 1) → rc0, sha256 610f45c947d0ea62b97f25a7416d5687aac2fa13431455fb1fbdccaa7f1e5701
- `python3 -I Collection/tools/genregistry.py` (run 2) → rc0, same sha256 → identical output; `--check` → "up to date (29712 bytes)" rc0
- `python3 -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_Core Collection/tests/core/fixtures` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=8 failed=0` rc0
- `python3 -I Collection/tools/tocdeps.py Collection/AddOns/DevilForever_Core` → `folders=1 unresolved=0 ...` rc0
- `python3 -I Collection/tools/tocdeps.py --role start Collection/AddOns` → `folders=67 unresolved=0 client_provided=8 optional_missing=62 no_interface_toc=2 forever_load_check=1 forever_load_no=0 duplicates=0 load_on_demand=17` rc0 (no line names DevilForever)
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=26 passed=26 failed=0` rc0
- Registry entries: 67 folders (66 start-package folders + DevilForever_Core)

## State for the next call
- All gates pass; nothing committed (master). No file outside the brief's write list was changed.

---

# Check 1 fix (C1, M1, M2, M3, minor 1, 4, 5)

## Read for this fix
- `Claude/results/handoffs/phase2/TRIAGE_phase2.md` 1–end
- `Collection/AddOns/DevilForever_Core/Defaults.lua` 1–260 (cited 14–39, 90–103, 131–208), `Core.lua` 140–220 (cited 145–155, 214), `Theme.lua` 1–12, 64–90, 140–185 (cited 8–9, 84, 164–167), `API.lua` 1–50, 125–140 (cited 10, 18–21, 47–49, 136–138)
- `Collection/tools/genregistry.py` 195–250 (cited 209–241); `Collection/tests/core/run.py` 240–262 (cited 247–258)
- upstream `platynator-547/Platynator/Core/Config.lua` 225–252 (addon fills its own defaults into its SV at init); AceDB-3.0.lua 255–292 (read earlier; regional branch 263–278)
- Repo-wide grep of `DevilForever_Core` outside upstream/work

## Impact map
| Place | What links | Verdict |
|---|---|---|
| folder `Collection/AddOns/DevilForever_Core/` → `!DevilForever_Core/` | C1(a) load order | fix (git mv not mine — plain move of an untracked new folder) |
| TOC file name `DevilForever_Core.toc` → `!DevilForever_Core.toc` | client matches TOC to folder (toclib.toc_matches_folder) | fix |
| `addonName` from `...` (Core.lua `loaded ~= addonName`) | becomes "!DevilForever_Core" automatically | check only |
| global `DevilForever_Core`, SV `DevilForever_CoreDB` | Lua identifiers cannot hold "!"; not tied to folder sort | no impact (kept) |
| genregistry `CORE_FOLDER`, docstring line 11, Registry.lua header line | path/name | fix |
| Registry.lua entry key `DevilForever_Core` | regenerated → `!DevilForever_Core` | fix (regenerate) |
| run.py `CORE_DIR`, `ADDON`, TOC path, test `GetAddonInfo(c, "DevilForever_Core")` | path/name | fix |
| Defaults.lua/API.lua/Edit.lua/Core.lua header comments naming "DevilForever_Core" | they name the global table | no impact |
| tocdeps/luacheck invocations in this log (Gates section above) | record of earlier runs | no impact (record); new runs use the new path |
| master plan, phase2 detail plan, judgment.md, PHASE_1 results, brief/SESSIONS/TRIAGE, master-plan diffs | name the folder | outside write list → reported to master (plans/judgment); records unchanged |
| build.py, tocdeps.py, toclib.py | scan folders generically | check only (gate run) |
| Defaults plain target flow (C1b) | locate/attempt, ADDON_LOADED/PLAYER_LOGIN/PLAYER_ENTERING_WORLD handlers, status states, header comment 14–39 | fix |
| Core.FillMissing | used by Defaults and initDB | check only; new Core.WriteOver beside it |
| Core.PlayerKeys (M1) | Defaults locate (char key, profile tokens) | fix; Defaults check only |
| Theme.RegisterSet notify (M2), Theme header 8–9, API header 47–49 | callback rule | fix |
| PLAYER_REGEN_ENABLED handler in Theme | flush of pending notify | fix |
| Defaults.Register + svScope (M3) | registry `defaults` and `savedVariables` | fix; test fixture registry gets `defaults` paths |
| AceDB target key (minor 1) | locate acedb branch | fix |
| genregistry editable checks (minor 4) | apply_extra; frames handled before editable | fix |
| API RegisterReadyCallback (minor 5) | API.lua 136–138 | fix |
| run.py cases relying on old behaviour (`defaults_plain_created_by_addon_at_login`, `defaults_addon_loaded_before_core`, `defaults_plain_absent_waits_then_skips`, character scope) | expected states change | fix |
| minor 2, 3 | not to be fixed | no change |

## Changes
- C1(a): `mv Collection/AddOns/DevilForever_Core Collection/AddOns/!DevilForever_Core`, TOC renamed `!DevilForever_Core.toc`; genregistry `CORE_FOLDER`, docstring, header, argparse text; run.py `CORE_DIR`, `ADDON`, Core lookup; Registry entry now `["!DevilForever_Core"]` (sorts first). Global `DevilForever_Core` and SV `DevilForever_CoreDB` kept.
- C1(b): `Defaults.lua` rewritten around plain-target freshness (header 1–52 states the rule): freshness = SV nil when Core first sees the target (its ADDON_LOADED, Core runs first); fresh → wait, at the next PLAYER_ENTERING_WORLD `Core.WriteOver` (new in Core.lua) writes spec values over this session's addon values, recorded, status mode "first-load" with the /reload note; still nil then → skipped, not recorded (createIfMissing creates); not fresh → fill-missing as before. PLAYER_ENTERING_WORLD settles on every firing (load-on-demand addons settle at the next one).
- M1: `Core.PlayerKeys` follows AceDB key setup incl. the RegionalUniqueNamesEnabled branch (ruleset realm, "<name> <surname>"), nil when the rule API or name parts are missing.
- M2: `Theme:RegisterSet` on the active set in combat sets a pending notify, delivered on PLAYER_REGEN_ENABLED; Theme header and API header "Callbacks" block state the rule.
- M3: `Defaults:Register` refused unless the registry entry exists, names `defaults`, and lists every target SV; scope taken from that entry (old account fallback removed). Refusals go to the status log.
- minor 1: AceDB key `<SV>[/ns]@char:<key>@profile:<p>` for character-scope SVs.
- minor 4: genregistry checks editable `frame` ∈ the folder's frame keys and `default` against kind and min/max (`valid_default`, same rules as Edit.lua validators).
- minor 5: `RegisterReadyCallback` already-ready path runs `fn` under pcall, error to the client error handler.
- Tests: fixtures registry gains `defaults` paths and `TestAceChar`; self-filling addon stub (Platynator-like, runs after Core's handler); new cases: self-fill fresh (+ later session not overwritten), self-fill existing, fresh still nil not recorded, registry rejections (3), regional key, regional without rule API waits, AceDB character key, theme RegisterSet in combat, genregistry editable frame/default checks; `defaults_plain_created_by_addon_at_login` and `registry_frame_lists` expectations updated.

## Gates after fix (raw output: scratchpad `fix1.XJVw/`)
- `python3 -I Collection/tools/genregistry.py` ×2 → rc0, both sha256 06b49e934478f6cf005b4bb688049649c78c1aab8fc8938be9b039e20b54d20c; `--check` → "up to date (29720 bytes)" rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` → `checked=8 failed=0` rc0
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core'` → `folders=1 unresolved=0` rc0
- `python3 -I Collection/tools/tocdeps.py --role start Collection/AddOns` → `folders=67 unresolved=0 ... duplicates=0` rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=35 passed=35 failed=0` rc0
- check only: `python3 -I Collection/tools/build.py --dry-run` → `folder !DevilForever_Core from Collection/AddOns`, `dry-run folders=1 files=8` rc0
- grep `AddOns/DevilForever_Core` in tools/tests/Core → none

---

# Recheck 1 fix (N1, N2, N3 header, minor b)

## Read for this fix
- `TRIAGE_phase2.md` section "Recheck 1" (to end)
- `!DevilForever_Core/Defaults.lua` 1–52, 155–290 (cited 19–26, 160–170, 182, 230–265, 286–288); `Core.lua` 160–200 (cited 173 = PlayerKeys nil returns)
- Next-frame timer evidence (grep, upstream data only): `C_Timer.After(0, …)` in `Details/frames/window_designer/designer_objects.lua:942,954`, `Details_EncounterDetails/frames.lua:519`; guarded form `if C_Timer and C_Timer.After then` in `questie-v12.10.0/Questie/Modules/QuestieMenu/QuestieTraceMenu.lua:48`, `xloot-12.23.0/XLoot_Master/Master.lua:231`; V42 Forever `!DevilUI/minimap.lua:1068` uses `C_Timer.After(0, …)` (read earlier). 227 non-lib upstream files use C_Timer.After.

## Impact map
| Place | Link | Verdict |
|---|---|---|
| Defaults.lua header 19–30 | rule text for fresh targets, assumptions (N3) | fix |
| Defaults.lua attempt plain branch 229–245 | freshness + when the first-load write is due (N1), late-created state (N2) | fix |
| Defaults.lua locatePlain 157–177 | target key for character scope reused by the late-created marker | fix (key helper split out) |
| Defaults.lua locateAce 182, locatePlain 162 | wait reason when player keys missing (minor b) | fix |
| Defaults.lua PEW handler 286–288 | first-world flag for N1 | fix |
| Defaults.lua applied/already status 249–267 | carries `lateCreated` from the persisted marker | fix |
| Core.lua PlayerKeys 145–185 | returns nil, reason (minor b) | fix; callers: Defaults only (grep) |
| Core.lua DB layout comment | new `defaults.lateCreated[folder][targetKey]` | fix (comment; created lazily via DBTable) |
| Theme/Edit/API | no use of PlayerKeys or Defaults internals | no impact |
| run.py stubs | C_Timer stub + next-frame runner | fix |
| run.py cases `defaults_plain_absent_waits_then_skips`, `defaults_fresh_still_nil_not_recorded` | expected "skipped" → "late-created" | fix |
| genregistry, Registry.lua, TOC | untouched | no impact (gen gates not rerun) |

## Changes
- N1: `Defaults.lua` — `firstLook` records per target {fresh, due}: due "world" when first seen before the session's first PLAYER_ENTERING_WORLD (`worldSeen`, set after the first PEW handler run), due "frame" when seen later and `C_Timer.After` exists (`nextFrame` guard; scheduled `attempt(folder, "frame")`), due nil (fill missing now) when the timer API is absent. Later PEWs never write a "frame" target.
- N2: fresh target with SV still nil when due → state "late-created", reason "addon creates its saved variable later; defaults need an addon-specific path", not recorded, marker `DevilForever_CoreDB.defaults.lateCreated[folder][targetKey] = true`; later sessions fill-missing with status `lateCreated = true`. `plainKey` helper split out of `locatePlain`.
- N3: Defaults header states both assumptions (Core loads first; Core's ADDON_LOADED handler before the target's).
- minor b: `Core.PlayerKeys` returns nil, reason; plain/AceDB waits carry "player key unavailable: <reason>" in status and an info line in the status log (once per new reason).
- Core.lua DB layout comment lists `lateCreated`.
- Tests: C_Timer stub + `next_frame`; new cases `defaults_load_on_demand_fresh_next_frame` (user change after the write kept), `defaults_load_on_demand_without_timer`, `defaults_late_created_across_sessions`, `defaults_player_keys_unavailable_logged`; two cases now expect "late-created"; regional-without-API case reads the first return value.

## Gates after recheck fix (raw output: scratchpad `recheck1.vXzd/`)
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` → `checked=8 failed=0` rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=39 passed=39 failed=0` rc0
- `python3 -I Collection/tools/genregistry.py --check` → up to date (29720 bytes) rc0 (registry inputs unchanged)

---

# Recheck 2 fix (N4, minor 2; minor 1 moot)

## Read for this fix
- `TRIAGE_phase2.md` section "Recheck 2" (to end)
- `!DevilForever_Core/Defaults.lua` 19–46 (header), 70–80, 225–360 (firstLook/nextFrame/attempt/handlers) — grep of nextFrame/firstLook/due/worldSeen/C_Timer/"frame"
- `API.lua` 1–55 (doc block) — re-read before editing

## Impact map
| Place | Link | Verdict |
|---|---|---|
| Defaults.lua header 19–39 | describes next-frame write and no-timer fallback | fix (text goes; mid-session = fill-missing, Suppress described) |
| Defaults.lua `nextFrame`, `firstLook`, "frame" phase in `attempt` | N4 root | fix (removed / due only "world") |
| Defaults.lua `attempt` final/create/mode lines | depend on due | fix |
| new `Defaults:Suppress` + `suppressed` table; `attempt` early exit; `GetStatus` | N4 | fix |
| PEW handler / `worldSeen` | login window | check only (kept) |
| API.lua doc block Defaults section | minor 2 | fix |
| Core.lua, Theme.lua, Edit.lua, genregistry, Registry.lua | no use of the removed parts | no impact |
| run.py C_Timer stub, `next_frame`, cases `defaults_load_on_demand_fresh_next_frame`, `defaults_load_on_demand_without_timer` | test the removed path | fix (stub removed, cases replaced) |
| other run.py cases | login-window path unchanged | check only (rerun) |

## Changes
- Defaults.lua: `nextFrame` and the "frame" phase removed; `firstLook(target)` gives due "world" only for a fresh target first seen before the first PLAYER_ENTERING_WORLD; fresh targets first seen later get missing keys only (waiting while their SV is nil, settled at the next PLAYER_ENTERING_WORLD: fill-missing, or late-created when still nil; createIfMissing creates). first-load mode only for due "world". New `Defaults:Suppress(folder[, reason])` (session table `suppressed`, attempt exits early, unsettled targets → state "suppressed", logged, GetStatus carries `suppressed`). Header: next-frame and no-timer text replaced by the mid-session rule and Suppress.
- API.lua: Defaults block documents GetStatus fields, states, mode, lateCreated, and Suppress.
- run.py: C_Timer stub and `next_frame` removed; `defaults_load_on_demand_fresh_next_frame` and `defaults_load_on_demand_without_timer` replaced by `defaults_load_on_demand_fresh_fill_missing_only` (same-frame writer value 42 kept, missing keys filled, mode fill-missing) and `defaults_suppress_before_login_overwrite` (restore value kept, nothing recorded, logged, bad folder refused).
- grep `C_Timer|next frame|next-frame` in Core and run.py → none.

## Gates after recheck 2 fix (raw output: scratchpad `recheck2.gUas/`)
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` → `checked=8 failed=0` rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=39 passed=39 failed=0` rc0
- `python3 -I Collection/tools/genregistry.py --check` → up to date (29720 bytes) rc0

---

# Step 12 — Codex briefs + install ZIP

## Read
- `Collection/codex-briefs/phase1.md` 1–75 (form)
- `Codex/docs/devil-ui-old-4k-layout.md` 1–105
- `Codex/results/old-devil-layout/layout-spec.json` (DB-type, Python): top-level keys, `tokens` in full, first entries of `actionGroups`/`elements`; `asset-manifest.json` keys and `licenseBoundary`
- master plan 88–96, 136–160, 335–356 (R21–R24, R34, R50–R53, appearance/verify brief rules)
- `Claude/results/REQUEST_LEDGER_phase2.md` line 3 (grep)
- V42 `!DevilUI.lua` 1174–1184, 1643–1644; `minimap.lua` 815–838 (exclusion lines confirmed)
- `!DevilForever_Core/Theme.lua` 24–43 (token names), `API.lua` 40–70
- `Collection/tools/build.py` options (60–144 grep)

## Steps
- `python3 -I Collection/tools/build.py --select '!DevilForever_Core'` → `ERROR selected folder not in manifest` (--select is for upstream folders; Collection/AddOns is always included)
- `python3 -I Collection/tools/build.py` ×2 → `built folders=1 files=8 zip_entries=10` rc0, both sha256 a502b46e3420ba1afca7ad66621a392fcf3e323d34215e08bf93662968736039 (replaces the tracked Phase 1 zip 9e37035f…)
- Wrote `Collection/codex-briefs/appearance-2.md` and `Collection/codex-briefs/phase2.md` (8 items 0–7)
- Snippet check (scratchpad `step12.o59n/check.py`, lupa harness with the generated registry, GetScript added to stub frames): probe → `True True`; item 2 → `true 20 devil 67 0`; item 4 → `0`; item 5 → `true applied`; item 6 → `true queued 1` then `4 0`. This checks the snippets run against Core logic only, not the client.

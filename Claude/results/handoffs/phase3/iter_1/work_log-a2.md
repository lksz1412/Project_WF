# Work log — Phase 3 Step 13 (Dominos 12.0.4 settings) — work A2

Raw output: scratchpad `step13.zZ8T/` (volatile; verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` 1–41 (whole)
- `Claude/results/handoffs/phase3/SESSIONS.md` (whole); phase3 detail plan (whole, 7 lines)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 201–215 (feature table incl. row 210), 388–404 (Implementation Interfaces), 428–448 (verification split), 145 (R47 line, grep)
- `Collection/judgment.md` 1–75 (head, Phase 3 section 68–74), 267–300 (4-5, 5, 6)
- `Collection/data/classes.md` (whole)
- `Collection/manifest.json` Dominos package (Python extract: fields + per-addon TOC data)
- Core: `API.lua` 1–168, `Core.lua` 1–268, `Defaults.lua` 1–395, `Edit.lua` 1–60, `!DevilForever_Core.toc`, `registry_extra.json`, `Collection/tools/genregistry.py` (whole), `tocdeps.py`/`luacheck.py`/`build.py` usage headers
- `Collection/tests/core/run.py` 1–260, 350–400, 600–640, 760–790; fixtures `Defaults_Example.lua`, `Registry_Test.lua` 1–30
- `Collection/codex-briefs/appearance-2.md`, `phase2.md` (whole, form)
- `Claude/results/handoffs/phase2/iter_1/work_log-a2.md` tail (gate commands)
- Ledger rows R1, R20–R23 (`REQUEST_LEDGER_phase0.md` 9–14), R86/R87 (33–34)
- Upstream Dominos (read only, never run): `Dominos.toc` (whole); `Dominos.lua` 1–420 (GAME_TYPE 18–35, OnInitialize 41–63, CreateDatabase 250–270, GetDatabaseDefaults 272–330, UpgradeDatabase), 555–575 (SetActionBarSize/NumBars/GetActionBarLength), 960–985 (IsGameType, `_G[AddonName]`), grep of profile readers 420–985; `core/migrations.lua` (whole); `core/barStates/Camelot.lua`, `Common.lua`, `module.lua` (whole); `bars/actionBar/bar.lua` 1–200 (paging defaults 30–94); `bars/actionBar/module.lua` (whole); `core/frame.lua` 90–130; `core/buttonBar.lua` 125–160; `bars/totemBar/module.lua` 1–60, `bar.lua` 28, 74–110 (grep); CreateClass/NewModule greps of bars; `plugins/buttonThemer.lua` 1–95; `plugins/slashCommands.lua` 25–45; `Dominos_Config/contextMenu/registry.lua` 70–90; `Dominos_Cast.toc` head; `Masque_Dominos` TOC + head of Lua; `libs/AceDB-3.0/AceDB-3.0.lua` profileKeys/initdb greps (294–327); `libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` 165–300 (storage)
- V42 `!DevilUI/Profile/Dominos.lua` 1–40, 940–990 + key greps (profile shape only)
- Layout count: grep `8×3` over Claude/Collection/Codex; `Codex/results/layout-design/preview-notes.md:7` (36 + 24 + 12 + 12 = 84)

## Findings used
- SV: `DominosDB` account (`Dominos.toc:9`), AceDB; `LoadSavedVariablesFirst: 1` (toc:10); migrations run at file load and only for an existing SV with `global.configVersion` (`migrations.lua` 207–245); a new DB is stamped schema 3 in `UpgradeDatabase`.
- Creation timing: `AceDB:New` in `OnInitialize` (Dominos' ADDON_LOADED); settings read in `OnEnable → Load` (PLAYER_LOGIN). Core fills at Dominos' ADDON_LOADED (creating `DominosDB` if nil) — either before or after AceDB:New the profile it fills is the one AceDB uses.
- Profile rule: `defaultProfileName = UnitClass('player')` (`Dominos.lua:255–256`) → Core `profile = "$className"`; AceDB writes `profileKeys[charKey]` (AceDB 318–321) so later sessions follow profileKeys. LibDualSpec state lives in namespace `LibDualSpec-1.0` char section, off by default (`LibDualSpec` 167–176, 270–274).
- Upstream defaults already give: `ab.count = 8`, `ab.length = NUM_ACTIONBAR_BUTTONS`, `showBindingText = true`, `modules['**'] = true` (stance/pet/possess/totem on), `possessBar = 1`, `splitTotemBars = false` (`Dominos.lua:274–329`); bar 1 paging for Forever: page2–6, WARRIOR battle/defensive/berserker 7/8/9, DRUID cat 7 / bear 9 / moonkin 10, ROGUE stealth 7, PRIEST shadowform 7 (`bar.lua:40–70`); Camelot states (`barStates/Camelot.lua`).
- Layout needs 84 buttons = 7 × 12 → `ab.count = 7` (A2 judgment, see DQ 1).

## Steps
1. Wrote `Collection/AddOns/!DevilForever_Core/Defaults/Dominos.lua` (acedb target, `profile = "$className"`, values `ab.count = 7`, `showBindingText = true`).
2. Core TOC: added `Defaults\Dominos.lua` after the `#` defaults marker (before `API.lua`).
3. `registry_extra.json`: Dominos entry — 14 frames (`dominos.bar1–7` → `DominosFrame1–7`, stance/pet/possess/totem/bags/menu/queue → `DominosFrame<id>`), editable position for all, spacing 0–32 for the 13 button bars (queue is a plain Frame; Dominos slider −16..32 but Core spacing ≥ 0), `DominosDB` split `class`, defaults path.
4. `python3 -I Collection/tools/genregistry.py` ×2 → `wrote ... (34930 bytes, sha256 8126c4c9aacab00e342d66cfeeca0866d3ab1c12ab225e09bbfa6d2a64e52cf8)` both, sha256sum identical; `--check` → up to date rc0.
5. First test run: `cases=39 passed=37 failed=2` (`generated_registry_lookup` expected split "common" and no frames; `defaults_register_rejected_by_registry` saw a 4th error because the real defaults file ran against the fixture registry).
6. `run.py`: harness skips `Defaults/*` TOC lines when the fixture registry is used; `generated_registry_lookup` expects split `class`, defaults path, and frames from Dominos only; new cases `dominos_defaults_fresh_class_profile`, `dominos_defaults_existing_profile_kept` (real file shape, generated registry).
7. Briefs: `Collection/codex-briefs/phase3.md` (items 0–9), `Collection/codex-briefs/appearance-3.md`.
8. Snippet check (scratchpad `check.py`, lupa harness, generated registry): item 2 → `true true applied fill-missing DominosDB@profile:Warrior 2`, status log empty; item 8 (Dominos not loaded) → `true false nil`. Logic only, not the client.

## Gates (final)
- `python3 -I Collection/tools/genregistry.py` ×2 identical + `--check` → up to date (34930 bytes) rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` → `checked=9 failed=0` rc0
- `python3 -I Collection/tools/tocdeps.py '<Core>' <U>/Dominos <U>/Dominos_Config <U>/Dominos_Cast <U>/Masque_Dominos Collection/upstream/Masque-12.1.8/Masque` → `folders=6 unresolved=0 client_provided=0 optional_missing=9 ... forever_load_no=0 duplicates=0 load_on_demand=1` rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=41 passed=41 failed=0` rc0
- `python3 -I Collection/tools/build.py` ×2 → `built folders=1 files=9 zip_entries=11` rc0, sha256 `4779964653b870247f4a381094b4f8870cb269627a699561537d5e61bb7b1bf4` both

## Decision Queue
1. `ab.count = 7` (A2 judgment from the 84-cell layout). Upstream is 8. AceDB strips values equal to defaults at logout, so an existing Dominos user on 8 bars has no raw `count` and gets 7 once (bar 8 hidden, its slot actions kept). Alternative: leave count out (8 bars, one spare for Codex to hide).
2. `showBindingText = true` equals the upstream default — kept as the explicit R1 value; it has no effect unless the user turned it off (then kept off).
3. Paging and class bars are left to Dominos' own defaults (not written); writing `frames[1].paging` would bypass Dominos' per-class metatable.
4. Dominos_Cast: state left as shipped (on when installed); Phase 7 decides. The brief installs it.
5. Spacing editable bounded 0–32 (Core rejects negatives; Dominos allows −16). Size/rows not registered: Dominos has scale and columns, no width/height or rows.
6. Codex layout values: brief asks for a `dominos-profile.fragment.lua` that Claude would put into the defaults file (version bump) — needs master OK as the contract.
7. Test harness change in `run.py` (skip real defaults files with the fixture registry; two expectations of `generated_registry_lookup` updated) — beyond "add cases"; needed for the real file in the TOC.
8. LibDualSpec / mid-session spec switch: a profile first used mid-session is filled at the next login (Core fills at load only).

---

# DQ apply (master decisions: DQ1 remove `ab.count = 7`; DQ6 approved; DQ3/4/5/7/8 accepted)

## Impact map
| Place | Link | Verdict |
|---|---|---|
| `Defaults/Dominos.lua` values + header comment | DQ1 root | fix (`ab` removed; comment names count 8 as Dominos default) |
| `run.py` `dominos_defaults_fresh_class_profile`, `dominos_defaults_existing_profile_kept` | expect `ab.count = 7` | fix (expect `{showBindingText = true}`) |
| `phase3.md` item 2 (`written` 2→1), item 3 (`8 12 …`, bars 1–8), item 7 (restore `SetActionBarSize(8, 12)`, bars 1–8), item 8 (bars 1–8), sha256 line | depend on count / ZIP | fix |
| `appearance-3.md` §1 count sentence (bar 8 hidden via `frames[8].hidden` in the fragment — `core/frame.lua:214` reads `sets.hidden`), sha256 line | DQ1/DQ6 | fix |
| `registry_extra.json` / `Registry.lua` (frames bar1–7) | no count value | no impact (bar 8 not registered; hidden by layout) — check only via `--check` |
| work_log earlier sections | record | no impact (record) |

## Gates (raw: scratchpad `step13.zZ8T/dq_*`)
- grep `count = 7|"count": 7` in Collection/AddOns, tests, codex-briefs → none
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` → `checked=9 failed=0` rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=41 passed=41 failed=0` rc0
- `python3 -I Collection/tools/genregistry.py --check` → up to date (34930 bytes) rc0
- `python3 -I Collection/tools/build.py` ×2 → `built folders=1 files=9 zip_entries=11` rc0, sha256 `39e4c40a5115652359f59256085e267f0114adeb1365509cc316f36c65d81310` both
- Brief sha256 lines replaced (phase3.md 1, appearance-3.md 1); old sha 4779964653… left in Collection/outputs → 0
- Snippet check: item 2 → `true true applied fill-missing DominosDB@profile:Warrior 1`; item 8 → `true false nil`

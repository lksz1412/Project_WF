# work_log — A2 coder — Phase 1 Steps 8 (extraction) + 9 (tools) — iter 1

Scratch (volatile, raw outputs): `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/a2.mzNt/`

## Files read as basis (file:line)

| File | Range | Why |
|---|---|---|
| `Claude/results/handoffs/phase1/brief-a2.md` | 1–28 (whole) | task |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` | 100–182, 200–229, 300–331 | Ground Truth, structure map, feature Phase table (rows 208–228 transcribed into `extract.py` FEATURE_PHASES), Implementation Changes |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-phase1-세부계획.md` | 1–14 (whole) | Step 8/9 gates |
| `References/addon-sources/INDEX.md` | 1–81 (whole) | name → package dir resolution |
| `References/forever-addons/Hekili/SOURCE.txt`, `References/addon-sources/{bartender4,pitbull-unit-frames-4-0}/SOURCE.txt` | whole | SOURCE.txt format; all 71 SOURCE.txt then machine-checked for the 4 fields (DB-like) |
| `.gitignore` | 1–20 (whole, before append) | append point |

## Step 9a — environment

- `pip install lupa` → `Successfully installed lupa-2.8`; `python3 -c "import lupa; print(lupa.__version__); from lupa import lua51"` → `2.8` / `lua51 ok`. Python 3.13.18. Installed into the container's system Python (not persistent across containers).
- `.gitignore`: appended one line `Collection/upstream/` (`git diff .gitignore` = +1 line at end, nothing else changed).

## Step 8 — extract.py

Files: `Collection/tools/toclib.py` (shared TOC parsing / addon-folder discovery), `Collection/tools/extract.py`.

| Command | Verdict |
|---|---|
| `python3 -I Collection/tools/extract.py` | rc=0 · `packages=39 start=13 comparison=26 addon_folders=98 missing_names=0 errors=0` (all 39 SHA256 = SOURCE.txt) |
| `python3 -I Collection/tools/extract.py` (rerun) | rc=0 · 39/39 `kept` · `sha256sum -c` of manifest.json + manifest.md from run 1 → both OK (idempotent) |
| `python3 -I Collection/tools/extract.py --no-extract` | rc=0 · same counts · manifest.json/.md sha256 OK |
| stray-TOC check (every `.toc` outside Libs belongs to a discovered addon folder) | `stray tocs 0` |
| embedded libs | 428 lib folders, 228 with LibStub major/minor found |
| safety probe (crafted ZIPs: `../evil.txt`, `/etc/evil`, `C:/evil`, `a\..\evil`, symlink mode) via `extract.extract_zip` | 5/5 rejected before any write · `escaped files: []` |

Manifest counts: 39 packages (13 start + 26 comparison), 98 addon folders, 0 missing comparison names; 2 brief comparison names already in the start set (Chattynator, Glass Forever). Folders without a 16001 TOC: PitBull4, PitBull4_DogTagTexts, Reflux, TitanClassic, TitanRegen (all comparison packages); all 13 start packages have a 16001 TOC in every folder.

## Step 9b — tools

Files: `Collection/tools/luacheck.py`, `Collection/tools/tocdeps.py`, `Collection/tools/build.py`, `Collection/AddOns/.gitkeep`.

| Command | Verdict |
|---|---|
| `python3 -I Collection/tools/luacheck.py <scratch>/luaprobe` (ok / syntax error / `goto` / BOM / `os.exit(3)` files) | rc=1 · `runtime=Lua 5.1 luajit=False lupa=2.8 checked=5 failed=2` (bad.lua, goto.lua fail as Lua 5.1 should; os.exit not run) |
| `python3 -I Collection/tools/luacheck.py Collection/upstream/Hekili-v0.8.6 Collection/upstream/Forever_Unit_Frames-0.65.2 --json <scratch>/luacheck_gate.json` | **GATE** rc=0 · `checked=322 failed=0` (cross-count `find -iname '*.lua'` = 322) |
| `python3 -I Collection/tools/tocdeps.py --role start --json <scratch>/tocdeps_start.json` | **GATE** rc=0 · `folders=37 unresolved=0 client_provided=0 optional_missing=43 no_interface_toc=0 duplicates=0 load_on_demand=13` |
| `python3 -I Collection/tools/tocdeps.py Collection/upstream/Hekili-v0.8.6/Hekili_Druid` (negative probe) | rc=1 · `UNRESOLVED Hekili_Druid (Hekili_Druid.toc) needs Hekili` + `... needs Hekili_Shared` |
| `python3 -I Collection/tools/tocdeps.py --role all` | rc=0 · `folders=98 unresolved=0 client_provided=8 optional_missing=175 no_interface_toc=5 duplicates=0 load_on_demand=26` |
| `python3 -I Collection/tools/build.py --dry-run` | **GATE** rc=0 · `dry-run folders=0 files=0 target=.../outputs/collection/DevilForever-collection.zip` |
| `python3 -I Collection/tools/build.py` | rc=0 · `built folders=0 files=0 zip_entries=2 -> outputs/collection/DevilForever-collection.zip` (placeholder: `Interface/`, `Interface/AddOns/`) |
| `python3 -I Collection/tools/build.py --select Masque Masque_Onyx --out-dir <scratch>/build1` (+ same to build2, `cmp`) | rc=0 · `built folders=2 files=171 zip_entries=173` · `identical` (deterministic) |
| `python3 -I Collection/tools/build.py --select NoSuchAddon --dry-run` | rc=1 · `ERROR selected folder not in manifest: NoSuchAddon` |
| `python3 -I -m py_compile Collection/tools/*.py` | `pycompile_ok` |

Mid-step fix (own code, before gates): tocdeps matched `Blizzard_DeprecatedSpellScript [AllowLoadGameType classic]` as a literal name; added `dep_name()` stripping the `[condition]` suffix; gates rerun after it (numbers above are post-fix).

## Decision Queue (my defaults; master/A1 decide)

1. `role` follows the brief literally (source set: `forever-addons` = start, others = comparison). Per-Phase use is in `feature_phases[{phase,use}]` from plan rows 208–228. Consequence: Chattynator/Glass Forever are role=start but phase-4 comparison; TipTac Reborn, Bagnon, Platynator, Aurora, Titan Panel, Kaliel's Tracker, Mapster, ProfileManager are role=comparison but Phase start addons.
2. Leatrix Plus, XLoot, BugSack, BugGrabber have no row in the feature table → `feature_phases: []`. Questie = Phase 17 `reference`.
3. "PitBull4 (references copy)" resolved to `References/addon-sources/pitbull-unit-frames-4-0` (v4.2.50, no 16001 TOC), not the V42 copy in `work/`.
4. Upstream dir name = References dir + SOURCE.txt version, sanitized; this gives odd names (`profilemanager-ProfileManager_v4.0.zip`, `experience-forever-ExperienceForever2.0.4`) because SOURCE.txt versions are irregular.
5. tocdeps TOC choice (TOCs whose Interface lists 16001; fallback plain `<Folder>.toc`) is my rule; which TOC the Forever client actually loads when several match (e.g. `Skada.toc`/`Skada_Camelot.toc`/`Skada_Forever.toc`) is unverified — real-load check is Codex's.
6. `embedded_libs` covers only top-level `Libs/`·`Lib/`·`Libraries/` folders; LibStub version by regex (228/428 found); nested libs (e.g. `PitBull4/Modules/Aura/Libs`) not listed.
7. `Collection/AddOns/.gitkeep` created so the folder exists in git (build skips it). `outputs/collection/DevilForever-collection.zip` placeholder written — commit or not is master's call.
8. lupa is not persistent (container is volatile); a setup-script line `pip install lupa` would be needed for later sessions — master's call.
9. Each upstream dir holds a marker `.extract-source.json` (sha256 + file list) used for idempotent skip; build.py excludes it.

## State for a possible fix round

All tools in `Collection/tools/`; upstream extracted (git-ignored) and regenerable with `python3 -I Collection/tools/extract.py`. No deletions made. No commit.

## Check 1 fix (M1, M2, minor 1) — impact map (written before editing)

Triage read: `Claude/results/handoffs/phase1/TRIAGE_phase1.md` (whole, 15 lines). Cited lines opened: `toclib.py:10-20,46-69` (L63 overwrites a repeated list key), `tocdeps.py:38-77` (L40 strips only a suffix), `extract.py:295-328` (L302 `has_target` ignores game-type restriction), `luacheck.py:52-70` (L61 accepts bytecode), `Mapster/Mapster.toc:1,9,10,54,55`, `Bartender4/Bartender4.toc:21-22` (prefix `[ExcludeLoadGameType vanilla]` / `[AllowLoadGameType vanilla]`), `!KalielsTracker/!KalielsTracker_Camelot.toc:21-22` (two OptionalDeps lines). Survey: header `## AllowLoadGameType`/`## ExcludeLoadGameType` exists in several upstream TOCs; per-line `[Allow|ExcludeLoadGameType ...]` brackets occur as prefix (header value) and suffix (file lines).

| Place | Reads | Decision |
|---|---|---|
| `toclib.parse_toc` | all TOC fields | change: merge repeated list keys; strip `[..LoadGameType ..]` groups from values and record them per line (`list_lines`); parse header Allow/ExcludeLoadGameType → `game_types`; compute `forever_load` |
| `toclib.required_deps` | Dependencies/RequiredDeps | check only (items now clean, merged) |
| `toclib.interface_numbers` | Interface | check only (items clean) |
| `toclib.tocs_for_interface` | Interface + new forever_load | change: among 16001 TOCs prefer forever_load != "no"; return flag when only "no" TOCs match |
| `extract.describe_addon` (L295-328) | parsed TOC → manifest | change: add `game_types`, `forever_load`, `list_lines` per TOC; folder `has_forever_loadable_toc` |
| `extract.write_markdown` | tocs deps / folder flags | change: per-TOC "Forever load" column; package column "Folders loadable on Forever" |
| `tocdeps.dep_name` / `analyse` | deps, OptionalDeps, tocs_for_interface | change: strip prefix and suffix conditions; report folders whose only 16001 TOCs are forever_load=no |
| `build.py` | manifest `addons[].folder/path` only | no impact (does not read TOC fields) |
| `luacheck.check` L61 | file bytes | change: reject chunks starting with `\x1b` (Lua bytecode) |
| `Collection/manifest.json/.md` | generated | regenerate with `extract.py --no-extract` |
| work_log earlier sections | records | no impact (record) |

forever_load rule (from triage): "yes" = no header restriction, or Allow list contains forever/camelot; "no" = Allow list without forever/camelot, or Exclude list contains forever/camelot. camelot = Forever is an inference (unverified; Codex real-load check). Per-line conditions on deps are recorded, not used to filter (whether Forever counts as `vanilla` etc. is unknown).

### Check 1 fix — changes

- `toclib.py`: TOC_FIELDS/LIST_FIELDS + `AllowLoadGameType`/`ExcludeLoadGameType`; `FOREVER_GAME_TYPES = {"forever","camelot"}` (camelot = Forever inferred, unverified); `_CONDITION_RE`; new `split_conditions()` (prefix or suffix `[..LoadGameType ..]` groups) and `forever_load()`; `parse_toc` merges repeated list keys (dedup, order kept), records `list_lines[field] = [{items, conditions}]`, adds `game_types {allow, exclude}` and `forever_load`; `tocs_for_interface` now returns status `matched` / `forever_load_no` / `no_interface` and drops forever_load=no TOCs when another 16001 TOC remains.
- `tocdeps.py`: `dep_name` uses `split_conditions` (prefix + suffix); new report list/counter `forever_load_no` and `FOREVER_LOAD_NO` line; docstring.
- `extract.py` `describe_addon`: per TOC `game_types`, `forever_load`, `list_lines`; folder `has_forever_loadable_toc`. `write_markdown`: package column "Folders with 16001 and forever_load≠no", addon table column "Forever load" + rule note.
- `luacheck.py`: file starting with `\x1b` → failure "precompiled Lua bytecode, not source", not passed to `loadstring`; docstring.
- `build.py`: unchanged (impact map: no TOC-field reads).
- Per-line conditions on deps are recorded only, not used to filter (my default — whether Forever matches `vanilla`/`classic` game types is unknown).

### Check 1 fix — gates (only those touching changed code)

| Command | Verdict |
|---|---|
| `python3 -I -m py_compile Collection/tools/*.py` | `pycompile_ok` |
| `python3 -I Collection/tools/extract.py --no-extract` | rc=0 · `packages=39 start=13 comparison=26 addon_folders=98 missing_names=0 errors=0`; second run sha256 of manifest.json/.md OK (stable) |
| `python3 -I Collection/tools/tocdeps.py --role start --json <scratch>/fix1_tocdeps_start.json` | rc=0 · `folders=37 unresolved=0 client_provided=0 optional_missing=43 no_interface_toc=0 forever_load_no=0 duplicates=0 load_on_demand=13` |
| `python3 -I Collection/tools/tocdeps.py --role all` | rc=0 · `folders=98 unresolved=0 client_provided=8 optional_missing=182 no_interface_toc=5 forever_load_no=1 duplicates=0 load_on_demand=26` · `FOREVER_LOAD_NO Mapster used Mapster.toc` · Aurora dep now `Blizzard_DeprecatedSpellScript` (condition stripped) · optional_missing 175→182 from merged repeated lines |
| `python3 -I Collection/tools/luacheck.py <scratch>/luaprobe` | rc=1 · `checked=5 failed=2` (bad.lua, goto.lua — unchanged) |
| `python3 -I Collection/tools/luacheck.py <scratch>/luaprobe_bin` (real `string.dump` bytecode, starts `\x1bLua`) | rc=1 · `FAIL ... bytecode.lua :: precompiled Lua bytecode, not source` · `checked=1 failed=1` |
| targeted manifest check (python over manifest.json) | Mapster.toc `game_types={allow:[mainline]}` `forever_load=no`, folder `has_forever_loadable_toc=False`; manifest.md row 219 shows `no`, package row 38 shows 0 loadable · `!KalielsTracker_Camelot.toc` OptionalDeps = 10 items from 2 lines (6 + 4, incl. Masque, RareScanner, TomTom, WoWFCzech) · `Bartender4.toc` OptionalDeps = 11 items from 2 lines with conditions `exclude vanilla` / `allow vanilla` (LibDualSpec-1.0 and LibClassicSpellActionCount-1.0 both present, no bracket text in items) |
| side observation (same check) | header game types elsewhere: VuhDo.toc allow standard → no (VuhDo_Camelot.toc yes, picked); TitanClassic/TitanRegen allow classic → no (no 16001 anyway); ForeverThreat allow camelot → yes; TitanAmmo allow forever → yes; Dominos/Baganator exclude only → yes |

Minors 2–5 not touched (per master).

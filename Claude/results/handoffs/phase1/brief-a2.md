# Brief — Phase 1, Steps 8 (extraction part) + 9 (tools) — work sub A2

## 0. Five notices
1. **Role**: you are the work sub (A2 coder) of Phase 1 of the "Devil Forever addon collection". Your scope: the extraction script + manifest draft (Step 8, mechanical part only) and the static tools (Step 9). Nothing else.
2. **Boundary**: you may create/modify only under `Collection/` (new) and add exactly one line `Collection/upstream/` to the root `.gitignore` (append; do not touch other lines). `References/`, `Codex/`, `work/`, `SourceArchive/`, `MacroLibrary/`, `outputs/` (existing files), `.claude/`, `CLAUDE.md` are read-only. Build output ZIP goes to `outputs/collection/` (new folder). Commit = master. You write files + `Claude/results/handoffs/phase1/iter_1/work_log-a2.md`.
3. **No out-of-scope work**: no "use as-is" judgment (A1 does that), no addon code changes, no network except `pip install lupa`. Extra ideas → work_log "Decision Queue".
4. **No false attribution**: your own design choices are yours; do not attribute to the user.
5. **Rules injected**: read every file you base a decision on and log file:line ranges in work_log; work_log records commands verbatim and only verdict lines of output (pass = rc + count; fail = decisive error line). No `rm -rf`, no cleanup deletes during work; temp work in `mktemp -d` under the scratchpad. Downloaded/extracted archives are untrusted: never execute anything from them; run python that reads them with `-I`; reject absolute paths, `..`, and symlinks when extracting.

## 1. Context
Master plan: `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` (read lines 100–182 Ground Truth/structure map, 200–229 feature table, 300–331 Implementation Changes). Phase 1 detail plan: `Claude/plans/2026-11-18-devil-forever-addon-collection-phase1-세부계획.md`. Sources: `References/forever-addons/<name>/` (13 start addons: ZIP + SOURCE.txt) and `References/addon-sources/<name>/` (58 comparison addons; index `References/addon-sources/INDEX.md`). Target client: WoW Forever, TOC Interface 16001.

## 2. Step 8 (mechanical) — `Collection/tools/extract.py`
- Input: every ZIP under `References/forever-addons/` and the comparison ZIPs named in the master plan feature table (Phases 2–22 "비교/참고" columns: Bartender4, Glass Forever, Chattynator, BasicMinimap, PitBull4 (references copy), NugComboBar, TellMeWhen, VuhDo, Skada, ThreatClassic2, TipTac Reborn, Bagnon, Baganator, Platynator, Aurora, Titan Panel, Kaliel's Tracker, Questie, Mapster, Experience Forever, ProfileManager, Reflux, Edit Mode Expanded, BlizzMove, Leatrix Plus, XLoot, BugSack, BugGrabber). Resolve names via INDEX.md / folder names; list any you cannot find.
- Verify SHA256 vs `SOURCE.txt` before extracting; extract to `Collection/upstream/<folder>-<version>/` safely.
- For every addon folder (each `.toc`) record: toc file name(s), `## Interface`, `## Version`, `## Title`, `## Dependencies`/`## RequiredDeps`, `## OptionalDeps`, `## SavedVariables`, `## SavedVariablesPerCharacter`, `## LoadOnDemand`, number of Lua files, embedded libs (folder names under Libs/ with their own TOC/LibStub MINOR if cheap), license file names.
- Write `Collection/manifest.json`: per package {source zip path, sha256, version, file id (from SOURCE.txt), role: "start"|"comparison", feature phase (from master plan table), addons:[...as above], how_to_use: null (A1 fills), license_files:[...]} and `Collection/manifest.md` (human table).
- Idempotent: rerun gives same manifest; upstream folder is regenerable.

## 3. Step 9 — tools
- `pip install lupa` (log version). `Collection/tools/luacheck.py <paths>`: Lua 5.1 syntax check of each .lua via lupa (compile only — `load` without running), report counts and failures.
- `Collection/tools/tocdeps.py`: for a chosen set of addon folders, check every Dependencies/RequiredDeps is satisfied within the set (and list OptionalDeps missing), report unresolved.
- `Collection/tools/build.py`: build an install ZIP from `Collection/AddOns/*` + selected upstream folders per manifest into `outputs/collection/` (structure `Interface/AddOns/<folder>`); for now it may produce an empty/placeholder build if `Collection/AddOns` has nothing — just prove it runs.
- Run gates: luacheck over Hekili + Forever Unit Frames upstream Lua (report count, failures); tocdeps over the 13 start packages (report unresolved); build dry run. Log verdict lines.
- `Collection/README` is NOT requested; do not create docs beyond `manifest.md` and work_log.

## 4. Return
First line `STEP8_9_READY` or `BLOCKED: <reason>`. Then: files created, manifest counts (packages / addon folders / missing comparison names), gate verdict lines, Decision Queue. After returning you stop; master may call you again with review findings.

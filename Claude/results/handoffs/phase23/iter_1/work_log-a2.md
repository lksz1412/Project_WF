# Work log — Phase 23 · A2 coder (Step 37 static integration check)

Scratch (volatile, raw outputs): `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/s37.RDAV/`
(helper scripts `combos.py`, `regcheck.py`, `tocfiles.py`, `install_combo.py`, `reg.py`; outputs `combos.txt`, `optional.txt`, `regcheck.txt`, `reg.txt`, `build.txt`, `build/`).
No code changed in Step 37. Only this log and `../integration-37.md` were written. `Collection/upstream/` was read only; nothing from it was executed (our own tools only parse its TOC text).

## Rule-file reading at start
Constitution and project instructions in context at session start (no compaction in this run).

## Ranges read (basis of the verdicts)

| File | Range | How |
|---|---|---|
| `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` | 200–549 (covers 213–234, 298, 312, 337, 411, 431, 453) | Read, full range. Lines 1–199 not read (not named in the brief) |
| `Claude/plans/…-phase23-세부계획.md` | 1–8 (whole file) | Read |
| `Claude/results/handoffs/phase23/SESSIONS.md` | whole | cat |
| `Collection/manifest.md` | 1–236 (whole) | Read |
| `Collection/manifest.json` | all packages: name, role, feature_phases, how_to_use, upstream_dir, addon folders; first addon record shape | Python (data file) |
| `Collection/AddOns/*/*.toc` | every TOC, whole (Core, Castbars, ChatSetup, FUFDefaults, StatusStrip, PitBull4 ×6) | cat |
| `Collection/AddOns/!DevilForever_Core/Registry.lua` | not read as text; `genregistry.py --check` = up to date, entries dumped from `genregistry.build()` (same bytes) | Python |
| `Collection/AddOns/!DevilForever_Core/registry_extra.json` | folder keys and SV option keys of all 16 entries; lines 939–950 | Python + grep |
| `Collection/tools/build.py` | 1–144 whole | cat -n |
| `Collection/tools/tocdeps.py` | 1–139 whole | cat -n |
| `Collection/tools/toclib.py` | 1–231 whole | Read |
| `Collection/tools/genregistry.py` | 1–431 whole | Read |
| `Collection/tools/extract.py` | 1–40, 60–130, grep of role/phase lines | sed + grep |
| Triage files (14) | whole: master-plan/TRIAGE_phase0, phase1, 2, 4, 6, 6-rev, 7, 10, 14, 15, 16, 19, 20, 22 | cat |
| Codex briefs `phase*.md` (17) | header + install block 1–12 of each; phase6-rev 16–20, 60–70; phase15 10, 50; phase20 9–10, 53–57; grep hits for install notes / Phase 23 / auto-update / Dominos_Cast / Cooldown Manager / Grid2 picker / reload | sed + grep. **Not read in full** (2041 lines total; read for install instructions as the brief scoped) |
| Codex briefs `appearance-*.md` | appearance-10 1–30; appearance-14 20–30; appearance-15:13; appearance-16:29, grep hits; appearance-22:30 | sed + grep (not full) |
| Core Lua | `Defaults/SexyMap.lua` 1–85, `Defaults/Dominos.lua` 1–25, `Defaults/Hekili.lua` 1–30, `Profiles.lua` 160–215, `Edit.lua` 44–80, `API.lua` 120–140, `Defaults.lua` 110–135, greps for registry consumers and `_G[` | sed/grep |
| `DevilForever_ChatSetup/ChatSetup.lua` | 1–30, grep Core | sed |
| `Collection/tests/core/run.py` | 40–75, 445–560 | sed |
| `Collection/data/unitframes-compare.md` | 1–68 whole | cat |
| `Claude/results/PHASE_*_RESULT.md` | «경미/최종 보고» lines of all; 38–46 of Phase 3, 5, 6-rev, 8, 10, 19 | grep/sed |
| `Claude/results/REQUEST_LEDGER_phase23.md` whole; `REQUEST_LEDGER_phase8.md` rows R101, R105–R107; `_phase19.md` R109 | | grep |
| `Claude/results/handoffs/phase16/{design-28a.md,DECISIONS_28a.md}`, `phase20/design-32.md` | grep hits only (clock, Streamer, Aurora) | grep |
| Upstream (read only) | `Dominos-12.0.4/Dominos/bars/actionBar/module.lua` 10–60; `ExperienceForever.lua` 80–84, 1200–1240; greps for XP-bar frames | sed/grep |

## Commands and verdict lines

| # | Command | Verdict line |
|---|---|---|
| 1 | `python3 -I Collection/tools/genregistry.py --check` | `check …/Registry.lua: up to date (54749 bytes)` rc=0 |
| 2 | `python3 -I $S/reg.py` (dump of `genregistry.build()`) | 73 registry entries; 39 of them in no install combination (see report §2) |
| 3 | `python3 -I $S/combos.py` (tocdeps.analyse on combos) | (a) required: folders=4 unresolved=0 · (b1) all, FUF: 32 / 0 · (b2) all, PitBull4: 31 / 1 (`DevilForever_Castbars needs ForeverUnitFrames`) · (b3) all + both unit frames: 33 / 0 · (b4) + Aurora + BugSack: 35 / 0, client=7 (Aurora Blizzard_Deprecated*) · (c) feature off: all 0 except FUF off → Castbars unresolved · single-folder off: FUF → Castbars, FUFDefaults; Quartz → Castbars; Core → ChatSetup, FUFDefaults; Details → Details_TinyThreat; Masque → Masque_Onyx. duplicates=0, no_interface=0, forever_load check/no=0 in every combo |
| 4 | `python3 -I $S/combos.py -v` | (b1) optional-missing = 21 standalone library / integration names (all embedded or not wanted), list in report §1 |
| 5 | `python3 -I $S/regcheck.py` | `sv/toc mismatches: 0` · registered-not-installed 39 · installed-not-registered 0 |
| 6 | `python3 -I $S/tocfiles.py` | `listed=118 missing=0` (files named in shipped TOCs and PitBull4 xml includes) |
| 7 | `sha256sum outputs/collection/DevilForever-collection.zip` + zip listing | `718c3f4a…fd874`; 6 folders (Core 18 files, Castbars 2, ChatSetup 2, FUFDefaults 2, StatusStrip 2, PitBull4 309) + 2 dir entries = 337; no manifest, no SHA list inside |
| 8 | `python3 -I Collection/tools/build.py --out-dir $S/build` | `built folders=6 files=335 zip_entries=337`; sha256 `718c3f4a…fd874` = committed ZIP (reproducible, current) |
| 9 | `build.py --dry-run --select <26 proposed upstream folders>` | `dry-run folders=32 files=2343` — 32 not 30: build always adds all 6 own folders (no exclude) |
| 10 | `python3 -I $S/install_combo.py` | (d1) proposed ZIP PitBull4 default: folders=30 unresolved=0 · (d2) FUF variant: folders=32 unresolved=0 |
| 11 | `git ls-files References \| grep -ci '\.zip$'` | 71 reference ZIPs already committed (public on main) |

## Step history
- Step 37 checks 1–9 done → `../integration-37.md`. Return state: INTEGRATION_READY. Step 38 resumes from the fix list F1–F6 there and the Decision Queue answers.

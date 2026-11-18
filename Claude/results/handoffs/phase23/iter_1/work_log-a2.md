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

---

# Step 38 — fixes F1–F6 (master decisions `../DECISIONS_37.md`, all DQ defaults accepted)

Input re-read: `DECISIONS_37.md` whole; `Collection/tools/extract.py` 130–553 (rest of file, before editing); `API.lua` 1–30, 140–215; `tests/core/run.py` 744–900; `codex-briefs/phase3.md` lines 7–24, 72, 79 (grep), phase20.md:17 context, phase15.md:10, 50, 53, appearance-16.md:29. Baseline before edits: tree clean at `69f3f8f`; `extract.py --no-extract` reproduced manifest.json byte-identical (git diff empty); all 6 suites pass; luacheck `checked=206 failed=0`.

## Impact map (what changed · verdict)

| Place | Verdict | What · why |
|---|---|---|
| `Collection/tools/extract.py` FEATURE_PHASES | fix | Phases 11–14, 16–18 start → `dropped`; ForeverThreat also `(10, comparison)` (plan 222). F2 |
| `Collection/tools/extract.py` OWN_FOLDERS + `collection_entries` + md section | fix | manifest gets our 6 folders (phases, variant, bundle, kind new/fork, PitBull4 base package/version/source ZIP/sha256/patch, TOC data, licence files); error when a Collection/AddOns folder is unlisted. F3 |
| `Collection/manifest.json` how_to_use of 9 packages | fix (hand data, kept across regeneration) | Hekili reason → R104; EF reason without the A2 note; ForeverThreat, TipTac, Bagnon, Platynator, Titan, Kaliel's, Mapster verdict `dropped` + reason. DQ6 |
| `Collection/manifest.json` / `manifest.md` | fix (regenerated by `extract.py --no-extract`) | role start 20 → 13; new `collection` section / table |
| `Collection/install.json` | new | single ship list: own, upstream by package, unit-frame variants pitbull4 (default) / fuf, notes path, version 0.1.0. F1 |
| `Collection/install/설치안내.md` | new | §7 draft as file (Korean). F5 |
| `Collection/tools/genregistry.py` | fix | upstream folder registered only if install.json ships it (any variant) or registry_extra names it; own folders take package/phases/variant/bundle/use from manifest collection (fork → use `modify`); REQUIRED_PHASES {2,20} (21 dropped). F2/F3 |
| `registry_extra.json` Details_Streamer | fix | entry removed (not shipped). DQ7 |
| `Registry.lua` | fix (regenerated) | 73 → 34 entries; PitBull4 package PitBull4, use modify, phases {6}, variant "6-rev" |
| `Collection/tests/core/run.py` generated_registry_lookup | fix together | asserts PitBull4 fork metadata, own-folder phases, 14 dropped/unshipped folders absent, Aurora present, 34 entries |
| `Collection/tools/build.py` | fix | `--install [--variant]`: install.json selection, manifest.json + 설치안내.md + SHA256SUMS.txt under `DevilForever-install/`; version must equal Core TOC; unlisted Collection/AddOns folder stops the build; default mode code path unchanged. F1 |
| `outputs/collection/DevilForever-collection.zip` | fix (rebuilt) | Registry.lua changed → new sha `6fc24622…`. DQ1 |
| `outputs/collection/DevilForever-0.1.0.zip` | new | install ZIP, PitBull4 build |
| 31 briefs (all `phase*.md` except phase1, all `appearance-*.md` except appearance-2-layouts) | fix together | sha `718c3f4a…` → `6fc24622…` (31 replacements); ZIP folder lists unchanged (same 6 folders) |
| `codex-briefs/phase3.md` :8, :21, :72 | fix | Dominos_Cast out of install list and addon-window lists; Progress/Roll reason "모음집에서 쓰지 않는다". F4 |
| `codex-briefs/phase15.md` :10, `phase20.md` :9, :17 | fix | Dominos_Cast out. F4 |
| `codex-briefs/phase7.md` item 7, phase8.md:9 | check only — no change | phase7 installs Dominos_Cast on purpose; phase8 already excludes |
| `codex-briefs/appearance-16.md` :29 | fix | `color.text.highlight` for split colours removed → one colour per FontString. F6 |
| `API.lua` header field list | check only — not changed (outside boundary) | new registry field `variant` not documented there → Decision Queue |
| Profiles/Spec/Presets/Edit registry consumers | check only | fewer entries; Details_Streamer leaves the restore set; tests pass |
| `Claude/docs/INDEX.md` structure map | not changed (master) | new `Collection/install.json`, `Collection/install/`, new ZIP |
| Results, triages, work logs, integration-37.md (old sha `718c3f4a…`) | no change (records) | |

## Commands and verdict lines (Step 38)

| # | Command | Verdict line |
|---|---|---|
| 1 | `python3 -I Collection/tools/extract.py --no-extract` (twice) | `packages=39 start=13 comparison=26 … addon_folders=98 … errors=0`; manifest.json sha `27b82881…` both runs |
| 2 | `python3 -I Collection/tools/genregistry.py` then `--check` | `wrote …/Registry.lua (38193 bytes, sha256 b183be0f…)` · `up to date (38193 bytes)` |
| 3 | tests: castbars / chatsetup / core / fufdefaults / pitbull4 / statusstrip | 16/16 · 13/13 · 108/108 · 16/16 · 6/6 · 20/20 passed, failed=0 |
| 4 | `python3 -I Collection/tools/luacheck.py Collection/AddOns` | `checked=206 failed=0` |
| 5 | old build.py (HEAD) exec'd with the real `__file__` → scratch | sha `6fc24622…` = new build.py default mode → default code path byte-identical |
| 6 | `build.py` ×2 into two scratch dirs + outputs | verification `6fc246227cb2ddc09adf3d3d6bb27fe63654d448729801a291985169cb2bac78` (×3); install `c99c618b9b6db01d087da6ca399510fba49e5e4fca6816ddf84101493517ccff` (×2); fuf variant `513aa01044170e7de1104da34d61518e15a124e11da69688c9f5d0914f040078` (scratch only) |
| 7 | unzip install ZIP → `sha256sum -c --quiet DevilForever-install/SHA256SUMS.txt` | OK; lines=2341, files=2342 (all but SHA256SUMS itself); install dir = manifest.json, SHA256SUMS.txt, 설치안내.md |
| 8 | manifest.json folders vs `Interface/AddOns` | equal, 30 (pitbull4) / 32 (fuf, SHA OK too) |
| 9 | `tocdeps.py <extracted>/Interface/AddOns` | pitbull4: `folders=30 unresolved=0 … duplicates=0`; fuf: `folders=32 unresolved=0 … duplicates=0` |
| 10 | negative: `--install --variant nope`, `--variant fuf` alone, `--install --select Masque` | three `ERROR …` lines, nothing written |
| 11 | old hash grep over `Collection/codex-briefs` | 0 files left; new hash in 31 files |
| 12 | `/run` byte length over all briefs + 설치안내.md | 0 over 255 |
| 13 | banned words (정본·거울·문면·문안·전량·발동·수권) over changed/new files | 0 hits |

Step 38 state: FIX_READY. Nothing committed (master).

---

# fix 1 — Step 38 review triage (`../TRIAGE_phase23.md`, B 0 / 2 / 6)

Input read: `TRIAGE_phase23.md` whole; `codex-briefs/phase20.md:18`; `References/forever-addons/Hekili/SOURCE.txt` whole; manifest.json start-package versions (Python); `API.lua` 3–9.

## Impact map

| Place | Verdict | What · why |
|---|---|---|
| `codex-briefs/phase20.md:18` | fix | 「열한 폴더」 → 「열 폴더」 (list at :17 has 10). M1 |
| `Collection/install/설치안내.md` 「설치 전」 | fix (rewritten as 「설치 순서」) | backup → move every addon except BugSack/!BugGrabber to `forever_moved_install/AddOns` → unzip → put back only non-duplicating addons, duplicate list (cast bar, XP/status bars, roll, other unit frames, raid frames, meters, bars/chat/minimap/profile addons); never unzip over existing folders. M2 |
| same file, auto-update line | fix | all ZIP addons on 「업데이트 무시」 is safest; PitBull4 must; Hekili/Grid2 Forever builds may be replaced by other-flavour files (확인 필요). m4 |
| same file, file check | fix | PowerShell `Get-Content … ForEach-Object … Get-FileHash` one-liner as the main check, `sha256sum -c` as the alternative. m5 — **not executed here** (no pwsh in this container; installing it is a new dependency) → Decision Queue |
| same file, FUF section | fix | documents `python3 -I Collection/tools/build.py --install --variant fuf` → `DevilForever-0.1.0-fuf.zip` and the swap. A2 DQ3 |
| `Collection/tools/build.py` | fix | `--name` rejected with `--install` (m1); shipped folder missing from the Core registry stops the build (m2); install-manifest upstream version from the source ZIP name after `<package>-` (Hekili `v0.8.6-forever`, Grid2 `4.1.13-forever`), else 16001 TOC version (EF `2.0.4`, ProfileManager `4.0`) (m6) |
| `Collection/manifest.json` Quartz how_to_use reason (+ regenerated manifest.md) | fix | Quartz alone owns cast bars; FUF bar hidden by Castbars, PitBull4 CastBar off, Dominos_Cast not shipped. m3 |
| `!DevilForever_Core/API.lua` header 6–7 | fix | `variant` field documented. A2 DQ1 |
| verification ZIP + install ZIP | fix (rebuilt) | API.lua is inside Core |
| 31 briefs | fix together | hash `6fc24622…` → `f89369f1…` |
| `Registry.lua`, extract.py, genregistry.py | check only — unchanged | genregistry --check up to date |
| `Claude/docs/INDEX.md` | master | A2 DQ2 |

## Commands and verdict lines

| # | Command | Verdict line |
|---|---|---|
| 1 | `extract.py --no-extract` | `packages=39 start=13 comparison=26 … errors=0` |
| 2 | `genregistry.py --check` | `up to date (38193 bytes)` |
| 3 | `build.py --install --name x --dry-run` | `ERROR --select and --name are not used with --install …` |
| 4 | `build.install_manifest(..., [('Details_Streamer', …)])` | `ERROR shipped folder Details_Streamer is not in the Core registry …` |
| 5 | install-manifest versions | Hekili `v0.8.6-forever`, Grid2 `4.1.13-forever`, Prat-3.0 `3.9.117`, Details `Details.20261109.15410.172`, EF `2.0.4`, ProfileManager `4.0`, FUF `0.65.2` |
| 6 | builds: outputs + two scratch dirs | verification `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef` (×3) · install `997379ea49a69a296a154d219ed7e3b726282565df62e2dec0dc0a929502139a` (×3) · fuf `4f54abc0c69e52709ce9d05b54ffa215dc8088b0f6aacace52638002e9de59ea` (×2, scratch only) |
| 7 | `sha256sum -c` on extracted install ZIPs | pitbull4 OK lines=2341 files=2342 · fuf OK lines=2275 files=2276; manifest folders = zip folders (30 / 32) |
| 8 | tocdeps on extracted trees | pitbull4 `folders=30 unresolved=0 … duplicates=0` · fuf `folders=32 unresolved=0 … duplicates=0` |
| 9 | tests castbars/chatsetup/core/fufdefaults/pitbull4/statusstrip | 16/16 · 13/13 · 108/108 · 16/16 · 6/6 · 20/20, failed=0 |
| 10 | `luacheck.py Collection/AddOns` | `checked=206 failed=0` |
| 11 | hash replace in briefs | files 31, replacements 31; old `6fc24622…` and `718c3f4a…` left in briefs: 0 |
| 12 | `/run` > 255 bytes; banned words | 0; 0 |

fix 1 state: FIX_READY. Nothing committed.

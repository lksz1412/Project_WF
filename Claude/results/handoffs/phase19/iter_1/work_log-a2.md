# Work log — Phase 19 Step 31 (Experience Forever 2.0.4) — work A2

Raw output: scratchpad `step31.iTyR/` (volatile; the verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole, 28 lines); `Claude/results/handoffs/phase19/SESSIONS.md` (whole); phase19 detail plan (whole, 7 lines)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 225–235 (row 231 = Phase 19), 395–415 (Interfaces 398–412), 445–452 (verification row 449 = "12–13, 17, 19"); grep of plan for `Dominos_Progress`/`D6` (lines 46, 63, 113, 154, 236, 271, 275, 288, 364, 515)
- `Collection/judgment.md` 170–215 (Phase 19 § 183–189), 280–300 (§6 item 4 at 291)
- Request ledgers (grep): R77/R83 `REQUEST_LEDGER_phase0.md:24,30`, R87 `phase0.md:34`, R101/R107 `REQUEST_LEDGER_phase8.md:14,20`, R47 (`Codex/results/handoffs/old-reference/r44-plan-update/baseline-request-ledger-r71-before-integration.md:40`, grep)
- `Collection/manifest.json` packages Experience Forever, Dominos, Details (Python dump)
- Core: `!DevilForever_Core.toc` (whole), `registry_extra.json` (whole), `Defaults.lua` 1–200 + `GetStatus` 462–501, `API.lua` 1–80 + 100–157, `Edit.lua` 1–60, `Core.lua` 139–143, `Registry.lua` EF/Dominos_Progress entries (grep)
- Tools: `Collection/tools/genregistry.py` (whole, 390), `build.py` (whole, 144)
- Tests: `Collection/tests/core/run.py` 425–485
- Briefs (form/precedent): `Collection/codex-briefs/phase14.md` (whole), `phase10.md` (whole), `appearance-10.md` (whole), `appearance-16.md` (whole), `appearance-2-layouts.md` 1–40 (whole); grep of all briefs for `Dominos_Progress`/`Dominos_` (phase3.md:8 excludes Dominos_Progress; phase7.md:10, phase8.md:9, phase15.md:10 install named Dominos folders only, none Dominos_Progress); `phase1.md` 51, 58 (no Dominos)
- `Claude/results/handoffs/phase10/iter_1/work_log-a2.md` (whole), `TRIAGE_phase10.md` (whole)
- Layout: `Codex/docs/devil-ui-old-4k-layout.md` 20–75; `Codex/results/old-devil-layout/layout-spec.json` elements (Python walk: `black-crossrail` 0,1804,3840×16; `long-action-cells` 445,1724,2950×80; `status-rail`)
- Upstream (read only, never run) `U = Collection/upstream/experience-forever-ExperienceForever2.0.4/`: `ExperienceForever/ExperienceForever.lua` 1–1965 (whole), `ExperienceForever.toc` (whole), `CHANGELOG.md` (whole, 39), `.extract-source.json` (whole); `U/../Dominos-12.0.4/Dominos_Progress/Dominos_Progress.toc` (whole)
- `.claude/tools/banned_lexicon.json` (head) — banned-word check below

## Findings used
- SV `ExperienceForeverDB` (TOC `## SavedVariables`, account). AceDB-3.0: `AceDB:New("ExperienceForeverDB", defaults, true)` in `OnInitialize` (373) — i.e. at the addon's ADDON_LOADED. All settings live in the AceDB `global` section (defaults table 39–106, every key under `global`); no profile / per-character data is used.
- Row items vs EF defaults: `showPetBar = true` (44, hunter only, 1117), `showRepBar = true` (59), `repFollowWatched = true` (60, follows the faction ticked in the game reputation panel), `hideDefaultXpBar = true` (82, fades `StatusTrackingBarManager`, 1215–1245). All functional row items are already the EF defaults → no Core defaults file (R101: only what is needed). Also: Core AceDB targets fill `profiles[...]` only (Defaults.lua 54–80), not the `global` section EF uses.
- No setting turns the XP bar itself off: confirmed by full read. Options table 1453–1958 has no such toggle; `ExperienceForeverFrame` is created in `CreateUI` (528) and nothing hides it (grep `MainFrame:Hide|Show|SetShown` → 0 hits). At max level it shows "Max Level" (296). Only disabling the addon removes it. (judgment.md §6-4 「근거 미발견」 → now confirmed by source.)
- Frames: `ExperienceForeverFrame` (528), `ExperienceForeverMinimapButton` (471); rep/pet/quest/rested bars unnamed children reachable via the AceAddon object (546–585, 613–618). EF re-applies rep/pet heights and rep colour about every second (446, 904, 913, 1125), textures on LSM callback (383, 727–741), fonts/heights on font settings (792–826); drag saves `location` (538–544, 637–649).
- Dominos_Progress: not LoD (TOC has no LoadOnDemand, `## Dependencies: Dominos`) → loads whenever its folder is installed. Not in the build (build.py takes only `Collection/AddOns/*` plus `--select`), not installed by any brief (phase3.md:8 excludes it explicitly). It is in `Registry.lua` because genregistry registers every folder of the Dominos start package.
- Build precedent: third-party as-is addons (Details, Dominos, Quartz, …) are not in the ZIP; Codex installs them from `References/` ZIPs (phase10.md). EF follows: `References/addon-sources/experience-forever/ExperienceForever.zip`.

## Steps
1. Route decision: no `Defaults/ExperienceForever.lua`, no Core TOC line (defaults already match the row; above).
2. `registry_extra.json`: new `ExperienceForever` entry — frames `experienceforever.bar` → `ExperienceForeverFrame`, `experienceforever.minimap` → `ExperienceForeverMinimapButton`; editable on the bar: position, size 4–4096, font 6–64; SV `ExperienceForeverDB` split common; no `defaults`. Round-trip of old file identical (`indent=2, ensure_ascii=True`) → `roundtrip identical: True`; diff `added 35 removed 0`.
3. `python3 -I Collection/tools/genregistry.py` ×2 → `wrote Collection/AddOns/!DevilForever_Core/Registry.lua (53977 bytes, sha256 be0d8cb770d187c87094bc319c2c46184c0b9b37046329222f8528a67e90d940)` both.
4. Core tests before edit: `lupa=2.8 cases=61 passed=61 failed=0`. After the registry change: `cases=61 passed=60 failed=1` (`generated_registry_lookup`: frame-name list now includes EF — expected). Edit `Collection/tests/core/run.py` `generated_registry_lookup`: frame-name sum includes ExperienceForever; new checks for EF frame names, editable items (bar only: font 6–64, position, size 4–4096), bundle/use/no defaults/account SV → `61/61`.
5. Build ×2; old ZIP hash `2460bd1d…5ef9df4` replaced in all briefs under `Collection/codex-briefs/` (26 files, 26 lines; diff = hash only); ZIP contents lists unchanged (same six folders).
6. Briefs `Collection/codex-briefs/phase19.md` (items 0–8) and `Collection/codex-briefs/appearance-19.md`; `/run` byte lengths 190, 192, 155, 157, 215, 122 (all ≤ 255); banned words (정본·거울·문면·문안·전량·발동·수권) 0 in both.

## Impact map (registry change → ZIP hash)
| Place | Verdict |
|---|---|
| `registry_extra.json` EF entry | changed (new) |
| `Registry.lua` | regenerated |
| `tests/core/run.py` frame-name sum | changed (EF frames added) + EF checks |
| ZIP + hash in 26 briefs | hash replaced; contents lists unchanged (no folder added/removed) |
| `Claude/` records with the old hash (Result/work logs) | no change (record) |
| `Collection/judgment.md` §6-4 「근거 미발견」 | no change (outside boundary; confirmation reported in Decision Queue) |
| `Collection/manifest.json` EF entry (`role start`, phase 19 start) | check only — already right; not touched (outside boundary list) |

## Gates (final)
- `genregistry.py` ×2 identical (step 3); `--check` → `check Collection/AddOns/!DevilForever_Core/Registry.lua: up to date (53977 bytes)` rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=14 failed=0`
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/upstream/experience-forever-ExperienceForever2.0.4/ExperienceForever` → `folders=2 unresolved=0 client_provided=0 optional_missing=0 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=61 passed=61 failed=0`
- unchanged suites: castbars `16/16`, chatsetup `13/13`, fufdefaults `16/16`, pitbull4 `6/6`, statusstrip `20/20`
- `python3 -I Collection/tools/build.py` ×2 → `built folders=6 files=331 zip_entries=333` rc0, sha256 `826a2ddc4e58587967a4d57bcdb90628d36d23a92a57018ca01592648fce094f` both; `Interface/AddOns/ExperienceForever` entries in ZIP 0
- `References/addon-sources/experience-forever/ExperienceForever.zip` sha256 `2bfdda87…5ecf15b85` = manifest
- Defaults-file logic test with the real shape: not applicable (no Core defaults file).

## Decision Queue
1. No Core defaults file for Experience Forever: its own defaults already give pet bar on, rep bar on (following the watched faction), game default XP bar hidden. Core AceDB targets could not reach EF's `global` section anyway.
2. EF has no setting that hides the XP bar itself (confirmed, source above). A max-level character keeps a full bar with "Max Level"; turning it off = disabling the addon.
3. Dominos_Progress: kept off by not shipping and not installing it (build has no Dominos folders; phase3/7/8/15 briefs name Dominos folders without Dominos_Progress; phase19 item 0 moves every other addon aside and item 5 checks it is not loaded). For Phase 23's install list: ship Dominos without `Dominos_Progress` (and without `Dominos_Roll`, D6). Registry still lists both because genregistry registers every folder of a start package — harmless static data; change only if Phase 20 should skip them.
4. Registry editable ranges are wider than EF's own sliders (width 200–1200, height 10–60, font 8–32 at 1689/1697/1891): size 4–4096 and font 6–64, because EF sliders do not bound `SetWidth`/`SetFont` and the UHD long top line is 2950 px. One size range covers width and height (Core size item has one min/max).
5. Appearance values that EF re-applies itself (rep/pet heights, textures, colours, font sizes) are asked from Codex as EF value fragments per layout; the route to inject them into `ExperienceForeverDB.global` (Core has no AceDB-`global` target) is open for the integration step.
6. `Collection/manifest.json` / `manifest.md` not touched (outside the template boundary list); EF entry already `role start`, phase 19 `start`; Dominos lists phase 19 `comparison`.

## fix 1 (review → `Claude/results/handoffs/phase19/TRIAGE_phase19.md`, read whole)
Impact map = triage table (registry_extra/Registry.lua, tests/core asserts, appearance-19 table + "values EF re-applies" bullet, phase19 items 2–4, ZIP + hash in all briefs; records no change).
- M1: `registry_extra.json` EF editable → `position` only (12 lines removed); `Registry.lua` regenerated; `tests/core/run.py` EF editable assert → `[("experienceforever.bar","position",None,None)]`; `appearance-19.md` table row → `position`, bullet now sends width/height/texture/colour/font size through EF value files and says why (Core size = width+height together, `Edit.lua:7`; EF re-applies height/font, 785–826).
- M2: `phase19.md` item 3 records the currently watched faction (name / 없음) first and restores it at the end; result line gains `원래 진영` and `원래 진영 되돌림`.
- m1: item 4 records whether the pet was out and re-summons it at the end; result line gains `처음 소환수`·`다시 부름`.
- m2: items 2 and 3 gain XP/reputation by killing mobs only (quest completion not used — irreversible).
- m3: checkbox described by position (평판 탭에서 진영을 누르면 나오는 칸), koKR name 확인 필요, result line gains `칸 이름`.
Gates:
- `genregistry.py` ×2 → `wrote … (53667 bytes, sha256 2d66dcd7824f5870494f6faca4ad9ec3824aac094349665b7ca02a82b3b248fa)` both; `--check` → `up to date (53667 bytes)` rc0
- `tests/core/run.py` → `lupa=2.8 cases=61 passed=61 failed=0`; castbars 16/16, chatsetup 13/13, fufdefaults 16/16, pitbull4 6/6, statusstrip 20/20
- luacheck (Core + core fixtures) → `checked=14 failed=0`; tocdeps (Core + EF) → `folders=2 unresolved=0 … duplicates=0 load_on_demand=0`
- `build.py` ×2 → `built folders=6 files=331 zip_entries=333`, sha256 `0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49` both
- briefs: old hash `826a2ddc…8fce094f` left 0; new hash 28 occurrences in 28 files
- `/run` bytes 190, 192, 155, 157, 215, 122 (≤255); banned words 0 in appearance-19.md and phase19.md
- Decision Queue item 4 (wide size/font ranges) is moot: those editable items are removed.

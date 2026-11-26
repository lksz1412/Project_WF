# Work log — Phase 27 Step 70 (A1 analyst): Devil buff/debuff layout survey and four proposals

Scratch root for raw outputs: `C:\Users\lksz1\AppData\Local\Temp\claude\712c5ac97757b4a3\5a41c91b-71c1-4f88-8d73-93b3933d99f1\scratchpad\a70\` (below: `<a70>`). Helper scratch: `…\scratchpad\a70helper\`.
Archive folder (new): `D:/Projects/Project_WF/_local_only/devil-inven-r240/archives/` (below: `<arc>`).
No addon code was changed. No EXE / installer / downloaded code was run. Nothing was deleted. No commit.

## 1. Read ranges (inputs the brief names)

| File | Range | How |
|---|---|---|
| `Claude/results/handoffs/phase27/brief-70.md` | 1–31 | full |
| `Codex/docs/old-devil-reference-comparison.md` | 1–193 | full |
| `Claude/results/handoffs/phase27/iter_4/devil-aura-images.md` | 1–429 | full |
| `Codex/results/old-reference/a1-static-source-evidence.md` | 1–61 | full |
| `Codex/results/old-reference/a1-r36-source-evidence.md` | 1–119 | full |
| `Collection/AddOns/!DevilForever_Core/Presets/uhd.lua` | 1–748 | full |
| `Presets/fhd.lua`, `Presets/qhd.lua` | machine check: after replacing every number and the preset name, all 748 lines equal `uhd.lua` (`[]` mismatch list) → read the value lines 455–458, 474–479, 494–512, 539–545, 598–599, 615–619, 694–698, 733 | A/B asymmetric (one full, the others = numeric diff) |
| `Presets/V2.lua` (the layout the base presets write) | 1–215 | full |
| `Collection/tests/layoutv2/run.py` | 1–765 | full |
| `Collection/codex-briefs/phase27-game-check.md` | 1–165 | full |
| `Claude/results/handoffs/phase27/iter_4/image-17-reading.md` | 1–16 | full |
| `Claude/results/handoffs/phase27/iter_4/work_log-60.md` | 640–690 (the Step 65 section the brief cites) | partial, as pointed |
| `Codex/results/old-reference/acquisition/catalog-v2.json` | queried with Python (JSON data): attachment URLs, file iframes of posts 1877/1865/1853/1008/2312/2582/8906 | data |
| `…/acquisition/r36/idx-45-attachment-inventory.json` | Python: all 172 rows (filename, client, date, downloads) | data |
| `…/acquisition/articles-compact-v2/idx-<n>.md` (34 files, 5,281 lines) | **not read in full.** Grep for 버프/디버프/오라/buff over all 34; read `idx-1865.md` 100–209 | partial — listed as unread |

Linked code read to answer "why two" and to place proposals:

| File | Range |
|---|---|
| `Collection/AddOns/PitBull4/Modules/Aura/Layout.lua` | 400–498 (managed `dfAuraGeometry` rule) |
| `Collection/AddOns/PitBull4/Modules/HideBlizzard/HideBlizzard.lua` | 1–80, 285–300 |
| `Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua` | 150–275 |
| `Collection/AddOns/ForeverUnitFrames/Core/Blizzard.lua` | 125–140 |

Old addon sources read (static, for defaults of missing keys):

| File | Range |
|---|---|
| `<arc>/post-45-DevilUI3.46/x-inner-DevilUI_3.46/Interface/addons/PitBull4_Aura/Aura.lua` | 1–95 |
| same `Options.lua` | 33–260 (SetDefaults: buff BOTTOMLEFT/BOTTOM/right_down 16 px, debuff BOTTOMRIGHT/BOTTOM/left_down, width 50 %, max 6/6) |
| same `Layout.lua` | grep lines 11–33 (growth → SetPoint, offset_y added as +y), 165–193 |
| same `PitBull4/Main.lua` | 60–140 (units default layout `L["Normal"]`, player/target/pet/focus enabled) |
| same `PitBull4/Localization/koKR.lua` | 604 `L["Normal"] = "보통"` |
| same `PitBull4/ModuleHandling/CustomModule.lua` 1–15, `Module.lua` 11–43 / 210–279 (grep) | custom module layout default `enabled = true`; global `enabled = true` |
| same `PitBull4_HideBlizzard/HideBlizzard.lua` | grep 15–21, 156–167 (`aura = false` default; `hiders:aura` hides `BuffFrame`) |
| 5.4THETA and 7.0.3 `PitBull4_Aura/Options.lua` | grep 44–155: same defaults as 3.46 |
| `<arc>/post-1865/x-Wkwlq.part1/Interface/addons/PitBull_Aura/Core.lua` | 505–594 (PitBull 3 defaults: `auraSide = "bottom"`, `split = false`, `buffSide = "bottom"`, `debuffSide = "right"`) |
| `<arc>/post-1008/x-Forever/WTF/Account/*/SavedVariables/Perl_Target.lua` | 1–36 full |

## 2. Commands and verdicts (raw outputs in scratch)

| Step | Command (summary) | Verdict |
|---|---|---|
| D1 | helper `bada-a4-helper` (one, low effort): download 54 files, hash, `bz l/t/x`, index | 53/54 downloaded, Content-Length = saved bytes for all 53; 546 `UI.zip` HEAD 404. Records `<arc>/archives.json` (54 records, 268,703,516 B saved), `<arc>/index.json` (71 roots). Inner EXE of 11218, 11361, 12174: `bz l` exit 2 "Cannot open archive" → not opened. 2312, 3.05, 3.28, 3.38, 3.52, 3.313 inner NSIS had 97–153 unsafe names → safe members only. X2 R3.4: 395 safe unit-frame/SavedVariables members extracted into `<arc>/post-45-X2_R3.4-unitframes/`. |
| D2 | `curl -sI` probes before dispatch (8 dated + 5 legacy URLs) | dated `upload/YYYY/MM/DD/addon/` works for 2010+, legacy `upload/wow/addonpds/file/` for 2008–2009 |
| P1 | `<a70>/luaparse.py` static Lua table-literal reader (no execution), tested on 3.46 PitBull4.lua and 3.28 PitBull.lua | parses; UTF-8 strings confirmed by bytes (`eb8c80…` = 대상의대상) |
| P2 | `<a70>/extract_pb.py` over 93 PitBull/PitBull4 profile files (`<a70>/pb_files.txt`) → `<a70>/pb_extract2.json` | 93 files, 200 profiles, 0 parse errors |
| P3 | first run looked up `units.player`; 2016+ profiles key singleton frames by label (`플레이어`, `대상`) with a `unit` field → fixed lookup (`unit` field first) and re-ran | corrected table `<a70>/pb_table2.txt` (847 lines, read in full; first-run table `pb_table.txt` superseded for 2016+ files: 2022, V42) |
| P4 | `<a70>/table_pb.py` dedupe by SHA256 | repeated bytes: 3.46 = 3.51 = post 4019; 4.01f = 4.0.6b = 4.1.0d; 4.2.0h = 4.3.0f; 5.1b = 5.2 = 5.3 = 5.4THETA; 6.0.3 SPECIAL = 6.1 Alpha SPECIAL; 6.0.3 STANDARD = 6.1 Alpha STANDARD = 9789 = 9880 |
| P5 | profileKeys per multi-profile file (`<a70>/pk.txt`) + installer switch lines (`/reflux switch …`) | used profiles: SV era = the Devil-designed profile (`Devil`/`Default`, profileKeys point there where present); 5.x–6.x `Normal`/`Wide`; 3461/12993 `Normal`/`Wide`/`WideX`; 10341 `ShapaNormal`/`ShapaWide`; 2022 `ShapaNormal`/`ShapaWide`/`ShapaWH` (`!DevilUI.lua:43,49,55`); V42 five variants. Untouched PB4-default profiles (`Default` with no aura keys, char names) not counted |
| P6 | addon folder lists `<a70>/folders.txt`, buff/unit-frame subset `<a70>/buffaddons.txt` | separate top-right provider per version: Buffalo, Bison, ElkBuffBars, ShinyBuffs, or none (game frame) |
| P7 | X-Perl `XPerl.lua` (post 1853) dump `<a70>/xperl.txt` | 1853 ships PitBull + Buffalo folders but the saved settings are X-Perl → unit-frame owner not decidable; excluded from tally |
| T1 | `<a70>/tally.py` → `<a70>/tally.txt` | 59 rows, 119 installed profiles (see proposal tables) |
| G1 | `<a70>/screenmap.py`: loads only the definitions of `run.py` (AST, no test loops) and calls `default_screen_map(mode, w, h, True)` → `<a70>/screenmap.json`, `<a70>/screenmap.txt` | ok; rectangles used in the proposal (repo code, not downloaded code) |
| W1 | ElvUI defaults: `gh api` tree of `tukui-org/ElvUI` at `c68510d056b961e846e0e9903b6335ed8ed8948f`, raw `ElvUI/Game/Shared/Defaults/Profile.lua` → `<a70>/web/elvui_Profile.lua` (3,861 lines, SHA256 `3d0bba9d…77f8`), read 1350–1400, 1628–1680, 2259–2345, 2605–2700 | player unit-frame buffs off, debuffs on; target buffs + debuffs above (debuffs attached to buffs); separate top-right `P.auras` buffs/debuffs |
| W2 | WebFetch Blizzard EU forum 185610, WoWInterface p=342531, Inven board 46/48074 | quotes in the proposal; Inven page has no Devil-post comments |

## 3. Findings kept here, not in the proposal body

- The first table run (P2) showed 2022/V42 target auras as PitBull4 defaults because of the unit lookup; corrected in P3. Any reader of `pb_table.txt` must use `pb_table2.txt`.
- `work_log-60.md` line ~659 read the 2022 "Normal" target as debuffs below — confirmed by P3 (`Normal`: buffs below, debuffs below the buffs). Its "loaf" reading (debuffs above, buffs at the side) also confirmed; loaf is not an installer profile (P5).

## Decision Queue (side findings, not acted on)

1. The collection's game buff frame: `HideBlizzard` keeps the PitBull4 default `aura = false` (`Defaults/PitBull4.lua:250–254` sets only `castbar = false`; `HideBlizzard.lua:13–25`), so the game's top-right buff/debuff frames stay on while the player frame also shows auras. Whether the user sees the top-right frame (and where it sits after SexyMap moves the minimap to the bottom) is not verified in game.
2. The FUF (ForeverUnitFrames) variant of the collection has its own `hideBlizzardAuras` setting (`ForeverUnitFrames/Core/Blizzard.lua:133–136`, `Settings.lua:401–402`); this survey covers the PitBull4 presets only.
3. Posts 11218, 11361, 12174 (2020–2023 packages with sample images) could not be opened statically by Bandizip (`Cannot open archive(0xa0000044)`); another static tool would be a new dependency.
4. The 34 compact post copies were not read in full (5,281 lines); only grep + `idx-1865.md` 100–209.
5. Known overlap Grid2 40-player window ↔ target debuff block stays pinned in `run.py:496–505`; proposals C and D change it (see proposal).

## Step 70 fix (review B: 0 critical · 1 medium · 4 minor)

Read before editing: `Claude/results/handoffs/phase27/proposal-70-auras.md` 1–217 (full, the version under review); `<a70>/tally.txt` (T pair line: above/split 39, above/together 9, below/split 50, below/together 8, below one row 6, below/above 2, left/above 3; SPECIAL × above 45); 5.4THETA SPECIAL `!DevilUI/Profile/PitBull4.lua` 2721–2724, 2960–2970, 2988–2997 (+ grep of profile starts: `Normal` 2722, `Wide` 2888) for the 240×65 source.

| Item | Change (proposal only) |
|---|---|
| M1 | Target evidence now on one basis (same shape): §2 bullet split into buff-side count 48/67 and same-shape counts 39/9/50/8/6; SPECIAL 45 = 39 split (PitBull4) + 6 together (PitBull 3). A title/장점 → 39; B title/장점 → 50 (67 only as the wider buff-below count); C 근거 → 9+8+6 = 23 (above 9); D 근거 and reasoning → 39, with a sentence that the corrected counts do not change the recommendation; comparison table row; §0 item 3; §6 확정 line. Table 4 row labelled "버프가 놓인 쪽 기준". Table 2 rows unchanged (check only). |
| Minor 1 | §0 item 2: code leaves the game frame on [확정]; visible in game [미검증]. |
| Minor 2 | 240×65 source added: 5.4THETA SPECIAL `PitBull4.lua:2966–2968` (Wide `대상`), `:2992–2996` (`보통`). |
| Minor 4 | New "이 문서에 나오는 말" box after the header: SPECIAL/STANDARD (folder names confirmed, look described as estimated), idx 번호, profileKeys, `/reflux switch`, 관리 규칙, 배치 판 번호; one line under table 4 saying what it compares. |
| Minor 3 | no change (as decided). |

Machine check after edit: grep for `45/45`, `통계 1위`, `대상 45`, `(67)` → only the B line that names 67 as the wider buff-below count remains.

## Step 71 — stopped by the user's pick

Read: `Claude/results/handoffs/phase27/brief-71.md` 1–21 (full); `proposal-70-auras.md` 1–30 (header, glossary, §0 — the rest was already in this session's context from the Step 70 fix, not re-read; no compaction happened). Not re-read: `brief-70.md`, `devil-aura-images.md`, `Presets/uhd.lua` (brief-71 asks for a re-read only after compaction).

Changed: `proposal-70-auras.md` — one note added at the very top: the user's choice of 2026-11-26 18:32 (R246: target debuffs directly above the target frame, buffs above them; player buffs directly above the player frame, debuffs above them; nothing to the top-right), the rejection of 18:30 (R245), and that proposals A–D and §5–§7 are superseded; §1–§4 stay as record. Nothing else in the proposal was rewritten (the Step 71 four-proposal rewrite had not started when the stop arrived).

Decision Queue (added):
6. R246 fixes the order only. Not decided: icon sizes, max counts, whether own debuffs stay larger, pet/focus aura shape, and turning the game buff/debuff frame off (PitBull4 HideBlizzard `aura`, now default false — `Defaults/PitBull4.lua:250–254`) so nothing shows top-right. Under R246 the player block is the current preset order; the target block is that order reversed (debuffs next to the frame) — the managed rule (`PitBull4/Modules/Aura/Layout.lua:467–481`) stacks debuffs above buffs for every rule today, so the target needs a per-unit order switch (estimated, not checked in code beyond those lines).

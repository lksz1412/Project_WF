# Step 58 diagnosis — 5 in-game defects (R158), read only

Work sub A · base `da7a8f1d` (Collection = `c34716a3`, the installed build) · nothing edited except this file · no commit.
Tiers: **확정** = code/data line quoted · **추정** = hypothesis with partial evidence (verification plan given) · **근거 미발견** = looked, not found.

## Read for this report (file : lines)

After the compaction notice I re-read the rule files `feedback_change_impact_analysis.md` 1–66, `feedback_confirmed_items_policy.md` 1–63, `feedback_full_file_read_required.md` 1–58, and the brief `brief-58-diag.md` 1–17.

| File | Lines |
|---|---|
| `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` | 52–82, 197 (grep -n), whole file earlier in this session (Step 51) — unchanged since `c34716a3` |
| `git show c64dcd7c:…/ThemeSwitcher.lua` | :31–32 (grep) · `git log` of that file (2 commits) |
| game `WTF/Account/LKZ1412/SavedVariables/!BugGrabber.lua` (read only) | 1–32 (all) |
| game `WTF/…/SavedVariables/Grid2.lua` (read only, data) | python: Grid2Layout anchor/PosX/PosY/ScaleSize/FrameDisplay, Grid2Frame frameWidth/Height, profileKeys |
| `References/codex-verify/phase27/screens/user-check-01.webp` | whole image (2000×1125), looked at for frame positions only |
| `Collection/AddOns/DevilForever_Appearance/Appearance.lua` | 1–192 (all) |
| `Collection/AddOns/DevilForever_Appearance/Composition.lua` | 1–174 (all) |
| `Collection/AddOns/DevilForever_Skin_Dominos/Skin.lua` | 1–176 (all) |
| `Themes/*/Composition/*.tga` | headers (python) + mean abs diff fhd vs qhd/uhd (python) |
| `!DevilForever_Core/Presets/uhd.lua` | 1–751 (all, in three reads) |
| `!DevilForever_Core/Presets/fhd.lua`, `qhd.lua` | grep -n hits :457, :459, :460, :495–497, :507, :543, :730 (same structure as uhd.lua) |
| `!DevilForever_Core/Presets/V2.lua` | 1–175 (all) |
| `!DevilForever_Core/Presets.lua` | 160–344, 595–631 (Register, GetActive, Restore, PickForScreen, first choice) |
| `!DevilForever_Core/Defaults/Grid2.lua` | 1–149 (all) |
| `!DevilForever_Core/Party.lua` | 1–160 (header, grid2Profile, OLD_GRID2_SPOT, moveGrid2), grep hits :359–428 |
| `PitBull4/Modules/Aura/Layout.lua` | 395–490 |
| `PitBull4/Main.lua` | 95–244 |
| `PitBull4/UnitFrame.lua` | 60–110 |
| `PitBull4/Utils.lua` | 160–249, grep hits :253–330 |
| `PitBull4/Options/Units.lua` | 450–470 |
| `Claude/results/REQUEST_LEDGER_phase27.md` | row R158 |
| `Claude/results/REQUEST_LEDGER_phase26.md` | row R148 (grep) |
| `Collection/tests/*` | file lists and case names (grep) to see which tests cover what |

---

## D1 — theme switcher not shown on the status strip

**Cause (확정).** `ThemeSwitcher.lua` stops at load with a Lua error, so it never registers its events and the panel stays hidden.
- The game's error log `!BugGrabber.lua:15–20` (session 56 = after the install, counter 3):
  `["message"] = "FontString:SetText(): Font not set\nLua Taint: DevilForever_Skin_StatusStrip"`
- The only `SetText` calls that run at file load are on two FontStrings that have no font yet:
  - `ThemeSwitcher.lua:77–78`: `local previousText = previous:CreateFontString(nil, "OVERLAY")` (no template)
  - `ThemeSwitcher.lua:81–82`: `previousText:SetText("◀")` / `followingText:SetText("▶")`
  - The first `SetFont` happens only later, inside `apply()` (`:197` `text:SetFont(font.path, font.size, font.flags or "")`).
- The client raises an error when `SetText` runs on a FontString with no font. Everything after `:81` never runs: the click scripts, `apply`, the event frame (`:223–232`) and the Theme/Edit callbacks. So the `panel:Hide()` at load is never undone — no arrows and no name.

**Whose change (확정).** It is older than Step 51. The same two lines exist in Codex's commit `d8b63f59` ("feat: add status strip theme switcher"; `c64dcd7c:…ThemeSwitcher.lua:31–32`). Step 51 kept them unchanged.
- It never showed up in game before because the game's earlier install had no `ThemeSwitcher.lua` (Step 52 dry run listed it as a new file).
- The tests did not catch it because their FontString stub accepts `SetText` without a font (`tests/statusstrip/run.py:73`).

**Not the cause (확정 by reading).** The preset → size path is fine for uhd:
- `ART.uhd = {height = 28, fontSize = 22, …}` matches `Presets/uhd.lua:272` (`["height"] = 28` · `["font"] = {["size"] = 22}`).
- The `SHIPPED` table equals the 21 files per preset in the stage (checked in Steps 51/52).

**Change proposed.**
- Give the two arrow FontStrings their text after the first `SetFont`: move `:81–82` into `apply()` right after the `SetFont` loop (`:196–199`).
  - Alternative: create them with a font template (`CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")`, as `StatusStrip.lua` does for its own texts — test `run.py:757` asserts that template).
  - Default = move into `apply()`, keeping the strip font (`font.path`) as the only font.
- Lock it in the test: the theme_switcher stub's `SetText` raises when `self.font` is nil, mimicking the client.

**Impact map**

| Place | Type | Found by | Impact | Reason |
|---|---|---|---|---|
| `ThemeSwitcher.lua:81–82` | the defect | error log + read | fix together | move after `SetFont` |
| `ThemeSwitcher.lua:196–199` (`SetFont` loop in `apply`) | ★ callee order | read | fix together | text set after the font |
| `ThemeSwitcher.lua:52` `name` FontString | ★ same pattern | grep `SetText(` | check only | `name:SetText` already runs after `SetFont` (`:209`) |
| `tests/statusstrip/theme_switcher.py` UI stub, `run.py:73` `Region:SetText` | ★ locked test | read | fix together (theme_switcher stub only) | add a font-not-set error to the stub the switcher test uses; `run.py`'s stub is shared with the standalone strip — check only |
| `Skin.lua` | neighbour | read | none | sets fonts before text (`:139–140`) |
| `DevilForever_StatusStrip/StatusStrip.lua` | ★ same API use | grep | check only | uses a font template (asserted in `run.py:757`) |
| twin copies | ★ | grep `ThemeSwitcher` | none | single copy |
| records (ledgers, Step 51 work_log) | record | — | none (record) | — |

**Tests:** `Collection/tests/statusstrip/theme_switcher.py` (after the stub change), `statusstrip/run.py`.

---

## D2 — bottom HUD art stretched, ornaments under Dominos borders

**Who draws it (확정).** `DevilForever_Appearance/Composition.lua` draws two surfaces on the root frame. The root has one unit per physical pixel (`Appearance.lua:159–163`):
- `<theme>/Composition/<preset>_top.tga` (2048×256), cut into 3×3 pieces by calibrated "lips" (`:103–116`);
- `<preset>_deck[_reviewed].tga` (2048×512), drawn as **one piece** over the whole deck: `deck = {x = 0, y = split, width = width, height = bottom - split, texture = deck}` (`:118`).

The art for fhd/qhd/uhd is essentially the same picture (python mean abs pixel difference fhd vs uhd only 6–10 of 255 for devil/horde/alliance/orc, decks and tops). It is mapped onto rectangles of a different aspect per preset.

| Preset | Deck rectangle | Texels → px (x / y) | Aspect stretch | Top middle column x / middle row y |
|---|---|---|---|---|
| fhd | 1920×214 | 0.938 / 0.418 | 2.24 | 1.913 / 0.727 |
| qhd | 2560×248 | 1.250 / 0.484 | 2.58 | 2.550 / 0.848 |
| uhd | 3840×332 | 1.875 / 0.648 | **2.89** | **3.826 / 1.176** |

How the table was computed: from `Composition.lua:83–87, 100–107` and the `appearance.*` edits, e.g. `uhd.lua:117–128` aux `y = -1636`/`h = 80`, `:17–24` chat1 `y = -1820`, `:184–195` status `-2124`/`28`, `:104–115` upper `445,-1724,2950×80`, and the lips at `Composition.lua:12`.

- **Why round things become ellipses on uhd (확정 numbers, 추정 that fhd looks right).** The same art is stretched 2.89:1 on uhd against 2.24:1 on fhd — about **1.29× wider** for the same features. In the top texture's middle column it is 3.83 px/texel across against 1.18 down (3.25:1, against 2.63:1 on fhd). Screw heads painted round at fhd become horizontal ellipses on uhd. Nothing keeps the aspect: the end columns are also scaled non-uniformly (uhd 1.79 / 0.73), and the deck has no slicing at all.
- **Why the ornaments around bars 1–3 sit under the Dominos borders.**
  - Drawing order (확정): the art is on frames with strata `BACKGROUND`, level 0 (`Composition.lua:51–52`, `Appearance.lua:37–38`), so every Dominos button, including its Masque Onyx border, draws above it.
  - Onyx's border is larger than the button (`uhd.lua:321–323`: `-- Onyx uses a 40-unit Normal relative to Masque's 36-unit button.` / `-- Only 112 of the texture's 128 pixels carry alpha…`).
  - Bars 1–3 sit in the `upper` band: `uhd.lua:333–335`, x = 445 / 1429 / 2413, y = −1724, 12 buttons at a fixed 80 px with an 82 px pitch.
  - 추정: the painted surround follows the texture's u-coordinates (middle column stretched 3.83×, `u` from 0.5), while the buttons follow a fixed pixel pitch. So the painted frames do not line up with the buttons, and the Onyx borders cover them.
  - Verification plan: crop the middle band (v 148–216) of `uhd_top.tga`, map it to x 445…3395, and overlay the 36-button grid of bars 1–3.

**What exists already (확정).** Lip-based 3×3 slicing of the top texture (`Composition.lua:103–116`) with the middle column starting at `u = 0.5` for families (`:112`). Per-preset lips (`:10–24`) and per-preset texture files. No aspect-keeping, no repetition, no per-preset re-layout of the art.

**Change proposed (no redraw here).** To keep the aspect:
1. **Fixed-aspect ends + repeated middle:** draw each end piece at a uniform scale (end width = texel width × the vertical px/texel of its row), and fill the middle with a repeated section. Use several middle pieces, or texture wrap `SetTexture(path, "REPEAT", "CLAMP")` with `SetTexCoord` u > 1 — wrap needs power-of-two widths of the repeated section. Apply the same to the deck, which today is one piece (`:118`) and needs its own 3-slice plus lips.
2. **Per-resolution art:** author `uhd_*`/`qhd_*` at their real rectangle aspect (3840×164 top, 3840×332 deck), stored anisotropically in 2048-wide files so they map back 1:1.
3. **Ornaments around the bars:** stop painting them into the background. Draw them as separate textures anchored to `DominosFrame1–3`, at a layer above the Onyx border (or leave margins so borders never overlap).

Default proposal: (1) for screws and edges, plus (3) for the bar surrounds. (2) is the most exact but needs new art (Codex/art task).

**Impact map**

| Place | Type | Found by | Impact | Reason |
|---|---|---|---|---|
| `Composition.lua:100–119` GetPlan pieces, `:122–137` paintSurfaces | the defect | read | fix together | aspect rules / deck slicing |
| `Composition.lua:10–24` lips | ★ same values | read | check only (or fix if the slicing changes) | calibrated per texture |
| `Themes/*/Composition/*_top.tga`, `*_deck*.tga` | ★ producer (art) | headers + diff | check only (fix if option 2) | art unchanged in options 1/3 |
| `Appearance.lua:44–58, 75–121` (individual shell when there is no plan) | ★ caller/fallback | read | check only | covered frames hidden when the plan is active (`Composition.lua:149–153`) |
| `DevilForever_Skin_Dominos/Skin.lua` + Dominos geometry `uhd.lua:331–345` | ★ neighbour (bar positions) | read | check only (fix if option 3 anchors to bars) | button pitch 82 px fixed |
| Masque Onyx skin (`MasqueDB` Onyx, `uhd.lua:739–749`) | neighbour | read | check only | border size drives the overlap |
| `tests/composition/run.py` (243 lines; `lips`/`_top.tga` hits) | ★ locked test | grep | fix together | asserts the current piece plan |
| `tools/build.py` deck exclusion rule (`_deck.tga` vs `_deck_reviewed.tga`) | ★ reader | Step 51 read | check only | file names unchanged in options 1/3 |
| fhd/qhd presets `appearance.*` | ★ same rule | grep | check only | same code path |

---

## D3 — Grid2 position, size and cell shape

**Where it is set (확정).**
- Package spot, base presets: `uhd.lua:730`, Grid2Layout `["anchor"]="BOTTOMRIGHT"…["PosX"]=-878*factor,["PosY"]=1398*factor`. Bottom-right corner at x 3840−878 = 2962, bottom 762 px from the top — right side, above the target frame (R148).
- V2 spot: `V2.lua:151–155`, `grid.values.PosX,grid.values.PosY=(xTarget+w-m.width)*factor,(m.height-m.gridBottom)*factor`. Right edge of the V2 target, bottom at `gridBottom` = 904 (uhd, `V2.lua:17`).
- These fragments are written into Grid2 only when a preset is loaded (`/dfp preset …` → `/dfp go`) or when the profile is new (`Defaults/Grid2.lua:92–119`).
- An existing window is moved only by `/dfp party on`, and only from the package's old spot (`Party.lua:104` `OLD_GRID2_SPOT = {…, uhd = {80, -240}}`, `:147–152`).
- Cell size: `uhd.lua:730` `["frameWidth"]=154,["frameHeight"]=56` with `["ScaleSize"]=pixel` (1 unit = 1 physical px); fhd 96×32 (`fhd.lua:730`), qhd 120×44 (`qhd.lua:730`).
  - Small on uhd (확정): 154×56 px on a 2160-px screen is 2.6 % of the height (fhd 32/1080 = 3.0 %).
  - Wide cells (확정): width:height = 2.75 (uhd), 3.0 (fhd), 2.7 (qhd).

**What the user's saved profile holds (확정, game WTF `Grid2.lua`, read only).**
- Grid2Layout `anchor "BOTTOMRIGHT"`, `PosX -190.58`, `PosY 260.62`, `ScaleSize 0.3556`. With factor 768/2160 = 0.3556 this is a bottom-right corner 536 px from the right and 733 px from the bottom. That is neither the uhd spot (878 / 1398) nor the V2 spot (904 from the top → 1256 from the bottom).
- `FrameDisplay "Raid"` — the window shows only in a raid, not in a party (the package default is `"Grouped"`, `Defaults/Grid2.lua:52`).
- frameWidth/Height 154/56.

**"Starts above the PitBull4 party frames" — 근거 미발견.** The saved spot is on the right, not at the PitBull4 party column (top-left, `uhd.lua:469` `position_x=52*pixel,position_y=-92*pixel`). The package's old spot `{80, -240}` TOPLEFT would be there, but the saved values are not that spot. The screenshot shows no Grid2 window (solo, PitBull4 config mode).
- Verification plan: ask which screen/action showed it (Grid2 options → layout test?), or read the Grid2 profile again after the user reproduces it.

**"Above the quest tracker" vs R148 — conflicting user instructions.**
- R148 (`REQUEST_LEDGER_phase26.md:23`, user original "그리드는 우측 적군 대상 위에 배치해") put Grid2 above the enemy target frame, which is what the presets do.
- R158 says "퀘스트 위에 생기라고 해놨는데".
- The quest tracker is Blizzard's default (the package does not move it — only `Skin_Nameplates/SessionProbe.lua:13` names it). In the screenshot its top is at about y 518 px (270 / 1125 × 2160), at the right edge.
- **Decision needed (평문):** move Grid2 to "bottom-right corner just above the quest tracker's top, growing up-left" (default if confirmed), or keep R148's spot. A 40-man window of 8×5 square cells of 88 px is about 720×450 px. Above the tracker it reaches y ≈ 70, where the buff icons sit (screenshot x ≈ 3170–3380, y ≈ 20–90) — needs a check, or a smaller cell for raid.

**Change proposed.**
- (a) New spot values in `Presets/{fhd,qhd,uhd}.lua:730` and in the V2 override (`V2.lua:151–155`). Anchor BOTTOMRIGHT, PosX = −margin, PosY = (screen height − tracker top) × factor.
- (b) Square cells: `frameWidth = frameHeight = S`. Default S ≈ 4 % of the screen height: fhd 44, qhd 58, uhd 88.
- (c) Existing characters: they get the new spot only through `/dfp preset <name>` + `/dfp go`. Optionally add the current package spots to `Party.lua`'s "old spot" list so `/dfp party on` moves them too.
- (d) Tell the user that `FrameDisplay "Raid"` in their profile hides Grid2 in party.

**Impact map**

| Place | Type | Found by | Impact | Reason |
|---|---|---|---|---|
| `Presets/{fhd,qhd,uhd}.lua:730` Grid2Frame/Grid2Layout | the values | read/grep | fix together | spot + cell size |
| `V2.lua:12–17` `gridBottom`, `:151–155` | ★ same rule (V2 spot) | read | fix together | V2 overrides the spot |
| `Party.lua:104` `OLD_GRID2_SPOT`, `:119–153` moveGrid2 | ★ reader of the spots | read | check only / fix if (c) | decides what `/dfp party on` moves |
| `Defaults/Grid2.lua:92–119` reapplyAfterTemplate | ★ reader of the fragment | read | check only | rewrites preset values after Grid2's template |
| `tests/layoutv2/run.py:351–480` (`_grid2_rects`, "Grid2 40-player window … above the target") | ★ locked test | grep + case names | fix together | asserts the R148 placement and overlap gaps |
| `tests/core/run.py`, `tests/firststart/run.py` (`Grid2Layout`/`PosY` hits) | ★ locked tests | grep | check only (fix where they pin values) | — |
| `codex-briefs/phase27-game-check.md:33, :38` expected y 304/452/762 · 347/541/904 | ★ same values | Step 52 | fix together | numbers change with the spot |
| Blizzard ObjectiveTrackerFrame | neighbour (not ours) | grep | check only | target edge for the spot |

---

## D4 — V2 as the layout, focus in the centre, unified auras

**How a preset is chosen today (확정).**
- First run: `Presets.lua:614–631` picks by screen height through `PickForScreen` (`:599–612`: ≥2000 "uhd", ≥1400 "qhd", else "fhd").
- V2 exists only as `layoutOnly` compare presets `fhd-v1/-v2`… (`V2.lua:57–58` `name=name .. "-v" .. version,layoutOnly=true`).
- `Restore` of a `layoutOnly` preset only queues its fragments and keeps the active preset (`Presets.lua:286–296`).
- The base presets are V1 geometry with `dfLayoutV2=false` (`V2.lua:43`). The user is on uhd-v2 now (screenshot: pet | player | focus | target | target-pet in one row).

**To make V2 the default for every screen (proposal).**
- Fold the V2 version-2 geometry into the base presets fhd/qhd/uhd: in `V2.lua`, apply the `version == 2` block (`:95–157`) to `base` before `Core.Presets:Register(base)` (`:56`). Keep `-v1` as the only compare preset, or drop the compare presets.
- The active name stays `fhd/qhd/uhd`, so `Composition.lua:7` (`presets = {fhd…}`), ThemeSwitcher `ART` and `Party.lua:104` keep working. Making the first choice "uhd-v2" would break all three — not proposed.
- Existing users get it through `/dfp preset uhd` → `/dfp go`.

**Focus position (확정 numbers).** `V2.lua:104–110` lays out `pet | gap | player | timerGap | focus | gap | target | gap | targetPet`, centred as a whole (`left=(m.width-total)/2`). On uhd:
- w = 512, cw = 356, gap = castHeight + 4 = 44.
- timerGap = ceil(4·36 + 3·(6·50/36)·36/50 + 16) = 178, from the Totems layout `uhd.lua:479` `size=36/15, totem_spacing=6*50/36`.
- total = 2402 → left 719, xFocus = 1809, so the focus centre is 1987 px against the screen centre 1920: **67 px right of centre** (screenshot: focus centre about 35 of 2000 px right).
- **Proposal:** xFocus = (W − cw)/2 (= 1742). xPlayer = xFocus − timerGap − w, xPet = xPlayer − gap − cw; on the right side, xTarget = xFocus + cw + timerGap, xTargetPet = xTarget + w + gap. This gives a symmetric row (uhd 652 … 3188). The player keeps the totem-timer space on its right.
- Choice (default stated): use timerGap on both sides of the focus (symmetric), or only on the player side (focus centred, row not symmetric). Default = both sides.

**Aura layouts now (확정).** In V2 every one of the five frames goes through `dfAuraGeometry` with `above=true,width=…` (`V2.lua:139–141`). `PitBull4/Modules/Aura/Layout.lua:454–473` then forces `anchor TOPLEFT, side TOP, growth right_up`, `width = rule.width`, and stacks debuffs above buffs. The counts and sizes still come from each layout's own Aura settings:

| Frame (layout) | Max buffs / debuffs | Size / my size (buff) | Debuff my size | Width (V2 rule) | Source |
|---|---|---|---|---|---|
| Player (`보통`) | 6 / 6 | 40 / 40 (uhd) | 64 | 512 | `uhd.lua:494–511` |
| Target (`대상`) | 14 / 16 | 40 / 40 | 64 | 512 | same loop |
| Focus (`소환수와 주시`) | 8 / 3 | 24 / 24 | 24 | 356 | `uhd.lua:574` copy of `데빌 파티` (`:537–543` `partyAura` size 24, `max_buffs=8,max_debuffs=3`) |
| Pet / target-pet (same layout) | 8 / 3 | 24 | 24 | 356 | unchanged by request |

- fhd: size 20, debuff my size 32 (`fhd.lua:497, :507`). qhd: 27 / 43 (`qhd.lua:497, :507`).
- Focus also has `top_margin` (`V2.lua:156`).
- So the three differ in counts (6/6, 14/16, 8/3) and icon size (40/64 vs 24).

**Proposal.**
- Give the focus its own Aura layout (it shares `소환수와 주시` with the pets, which must not change). For example, a new PitBull4 layout `주시` for the focus unit only, copied from the pet layout for frame look but with Aura = the same table as player/target.
- Make player and target use one Aura table too.
- **Decision (default stated):** unified counts = target's 14/16, size 40, my debuffs 64 (uhd; fhd 20/32, qhd 27/43). Alternative = player's 6/6.
- Width stays per frame (512 / 356); the focus therefore wraps into more rows.

**Impact map**

| Place | Type | Found by | Impact | Reason |
|---|---|---|---|---|
| `V2.lua:38–175` | the layout source | read | fix together | fold V2 into the base; centred focus; focus layout |
| `Presets/{fhd,qhd,uhd}.lua` PitBull4 fragments `:454–641` (units, layouts, Aura `:493–512`, `:574`, `dfAuraGeometry` `:587–591`) | ★ same values | read | fix together | new focus layout + unified Aura |
| `PitBull4/Modules/Aura/Layout.lua:433–478` | ★ consumer of `dfAuraGeometry` | read | check only | forces the V2 above-geometry; reads `size`/`max_*` |
| `Presets.lua:286–296` (layoutOnly), `:599–631` (first choice) | ★ preset selection | read | check only (fix only if the V2 compare presets are removed) | — |
| `Composition.lua:7`, ThemeSwitcher `ART`, `Party.lua:104` | ★ readers of the active preset name | read/grep | check only | names unchanged in the proposal |
| Quartz fragments in V2 (`V2.lua:142–150`) | ★ same geometry (cast bars under the frames) | read | fix together | they follow xFocus/xTarget |
| Grid2 V2 spot (`V2.lua:151–155`) | ★ same geometry | read | fix together with D3 | uses xTarget |
| `tests/layoutv2/run.py` (V2 lifecycle, five Aura owners, Grid2 placement), `tests/pitbull4runtime/run.py` (`dfAuraGeometry` hit), `tests/firststart/run.py` | ★ locked tests | grep + case names | fix together | geometry and aura assertions |
| `codex-briefs/phase27-game-check.md` item 6 | ★ check list | Step 52 | fix together | expectations change |

---

## D5 — target's target and target-pet's target

**Defined units (확정, `V2.lua:5–11` units table and `uhd.lua:455–467`):** player, target, pet, focus, `대상의 소환수` (targetpet), `대상의 대상` (targettarget), `대상의 대상의 대상`, `플레이어 아래 대상`, `플레이어 아래 대상의 대상`, `플레이어의 소환수의 대상` (pettarget), `…의 대상의 대상` (pettargettarget), `주시 대상의 대상` (focustarget), `주시 대상의 대상의 대상`.

**There is no target-pet's target unit anywhere (확정 + 근거 미발견 elsewhere).**
- grep for `targetpettarget` over `Presets/` and V2 finds none.
- In the V2 row the player-side pet has two chain frames below it (`V2.lua:133–134`) and the focus has two (`:135–136`). The target-pet has none: `place("대상의 소환수",xTargetPet,…)` at `:127`, with nothing placed below it.
- The screenshot shows the same: the area below the far-right target-pet frame is empty.
- PitBull4 can draw such a unit: `targetpettarget` resolves through the "…target" rule (`Utils.lua:165–179`, `:217`, `:242`). It is not in the options list `SINGLETON_CLASSIFICATIONS` (`Main.lua:108–120`), but `MakeSingletonFrame` accepts any id that passes `IsSingletonUnitID` (`UnitFrame.lua:73–78`).

**`대상의 대상` (target's target).**
- Defined and placed under the target in V2 (`V2.lua:130` `place("대상의 대상",xTarget,lower,…,"대상의대상")`), and visible in the screenshot's config mode under the target frame.
- In the base presets it has no `enabled` flag (`uhd.lua:459`). PitBull4's default for units is `enabled = false` (`Main.lua:196–197`), but the V2 fragment row inherits whatever the profile already holds (fragment `intoExisting` for base, version 1, `uhd.lua:612`).
- In real play a target-of-target frame shows only while the target has a target (wacky unit, `UnitFrame.lua:97`).
- So for `대상의 대상` the cause is 추정: either the user means the pair under the target-pet (mirroring the pet and focus chains), or it was hidden because the target had no target.
- Verification plan: ask, or read `PitBull4.lua` in the game WTF for `units["대상의 대상"].enabled` (read only).

**Change proposed.**
- Add `["대상의 소환수의 대상"]="targetpettarget"` and `["대상의 소환수의 대상의 대상"]="targetpettargettarget"` to `V2.lua` units (`:5–11`).
- Define the rows in the three presets like the pet chain (`uhd.lua:463, :466`: `layout="소환수와 주시 아래", dfCompanionChain=true`).
- Place them under the target-pet in V2: `place(…, xTargetPet, lower, small.size_x, small.size_y)` and `xTargetPet + small.size_x + 10`.
- Add them to the version-4 fragment list (`uhd.lua:619–623`) so existing profiles get them.
- Default: also set `enabled=true` explicitly on `대상의 대상` and `대상의 대상의 대상` rows in all presets.

**Impact map**

| Place | Type | Found by | Impact | Reason |
|---|---|---|---|---|
| `V2.lua:5–11` units, `:127–136` place calls | the layout | read | fix together | new chain under target-pet |
| `Presets/{fhd,qhd,uhd}.lua:455–467` units, `:612–623` fragment versions | ★ same rows | read | fix together | rows + delivery to existing profiles (a new fragment version) |
| `PitBull4/Utils.lua:165–249`, `UnitFrame.lua:60–110` | ★ callee (unit validity) | read | check only | `targetpettarget` accepted |
| `PitBull4/Main.lua:108–120` SINGLETON_CLASSIFICATIONS | ★ options list | read | check only | only the option drop-down; not needed for the frame |
| `Party.lua` | neighbour | read | none | party groups only |
| `tests/layoutv2/run.py`, `tests/pitbull4runtime/run.py` (`대상의 소환수` hits) | ★ locked tests | grep | fix together | row lists / overlap checks |

---

## Decisions needed (평문, defaults in brackets)

1. **D3 Grid2 spot:** "bottom-right above the quest tracker" (R158) or "above the enemy target" (R148, current code). The two user instructions conflict. [default: R158, the newer one]
2. **D3 cell size:** square S = fhd 44 / qhd 58 / uhd 88 px, same for party and raid. [default as listed; check the overlap with the top-right buff icons in a 40-man test]
3. **D4 focus centring:** symmetric row with the timer gap on both sides of the focus, or only on the player side. [default: both sides]
4. **D4 unified aura counts:** target's 14/16 with sizes 40 / 64 (uhd), or player's 6/6. [default: target's]
5. **D4 how V2 becomes default:** fold V2 into the base fhd/qhd/uhd presets (keep the `-v1` compare preset), or another way. [default: fold into base]
6. **D5 meaning:** add the target-pet chain (`대상의 소환수의 대상`, `…의 대상의 대상`) under the target-pet. [default: yes, mirroring the pet and focus chains]
7. **D2 approach:** code-side fixed-aspect 3-slice with repeated middle + bar surrounds as separate textures above the Onyx borders, or new per-resolution art. [default: code-side first; art later if still needed]

## Notes

- The game's `!BugGrabber.lua` also logs a SexyMap error from our `Defaults/SexyMap.lua:211` (`Minimap:SetPoint(): Invalid region point 1.2063…`, session 26, counter 32) and a Hekili error. Hekili is out of scope. The SexyMap error is outside this brief's five items; listed only.
- Nothing was written to the repo except this file, nothing in the game folder (WTF files read only), nothing committed.

# Theme switcher images — status strip (fhd · qhd · uhd)

Made by Claude (Phase 27 Step 51) to the spec `Collection/codex-briefs/appearance-26-theme-switcher.md` §1–§2.
Generator: `python -I Collection/tools/theme_switcher_art.py` (`--check` compares the files on disk byte for byte; `--preview <png>` writes the sheet below).

## Preview

`preview.png` (1756x800): per preset all 13 names and the 8 arrow states at 1:1 on the devil panel colour (`color.panel.background` 0.15/0.105/0.09), the assembled switcher (◀ name ▶, button + 4 px + name slot + 4 px + button) on the devil / horde / alliance panel colours, and a 4x nearest-neighbour row for fhd (switcher with `Skyborne (Alliance)` + all arrow states).
The panel colours are flat stand-ins for the strip; the in-game strip background is not reproduced.

## Font and licence

| Item | Value |
|---|---|
| Font | Allura Regular (`name` table: family `Allura`, full name `Allura Regular`, PostScript `Allura-Regular`) |
| Version | `Version 1.110` (unique id `1.110;GOOG;Allura-Regular`) |
| Copyright | `Copyright 2010 The Allura Project Authors (https://github.com/googlefonts/allura)` |
| Licence | SIL Open Font License 1.1 (`name` id 13/14 → https://scripts.sil.org/OFL) |
| Source file | `Collection/codex-briefs/assets/26-theme-switcher/Allura-Regular.ttf` (sha256 `9c142b2e515832c0dfc4ff8b8ea18f40314943bf937b72e2b23c4661bac14cc6`, checked by the generator) |
| Shipped licence | `Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/LICENSE-OFL.txt` = byte copy of `OFL.txt` (sha256 `c8cb4c94a558b6cb82ac5dc981a73a0b8aee35a5c52c8a7832fc0280c289ad49`); no TTF in AddOns |
| Font size used | fhd 20.75 · qhd 22.50 · uhd 26.50 px (largest size at which all 13 names, plus 1 px outline on every side, fit the name area; one size and one baseline per preset) |

## Look

Gold script: vertical gold ramp over the ink height (pale top, light highlight band at about 42 %, deep gold, darker lower edge), 1 px dark brown outline, soft dark shadow (1 px right/down, blur 0.8) inside the draw area.
Arrows: gold chevron with a small diamond behind it (prev points left, next is its mirror). hover = whole image 35 % toward white (a complete picture, shown with BLEND); pushed = 18 % darker and moved 1 px down; disabled = desaturated dark gold.

## Files (`Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/`)

All 63 TGAs: 32-bit uncompressed, image type 2, 8 alpha bits, bottom-left origin (descriptor byte 8), TGA 2.0 footer — the header layout of the TGAs in `DevilForever_Appearance`.
Everything outside the draw area (top-left corner) has alpha 0.

| File | Preset | Image | Canvas | Draw area | Bytes |
|---|---|---|---|---|---|
| `fhd/name_devil.tga` | fhd | name · Devil (`devil`) | 256x32 | 192x22 | 32812 |
| `fhd/name_alliance.tga` | fhd | name · Alliance (`alliance`) | 256x32 | 192x22 | 32812 |
| `fhd/name_horde.tga` | fhd | name · Horde (`horde`) | 256x32 | 192x22 | 32812 |
| `fhd/name_human.tga` | fhd | name · Human (`human`) | 256x32 | 192x22 | 32812 |
| `fhd/name_dwarf.tga` | fhd | name · Dwarf (`dwarf`) | 256x32 | 192x22 | 32812 |
| `fhd/name_gnome.tga` | fhd | name · Gnome (`gnome`) | 256x32 | 192x22 | 32812 |
| `fhd/name_nightelf.tga` | fhd | name · Night Elf (`nightelf`) | 256x32 | 192x22 | 32812 |
| `fhd/name_orc.tga` | fhd | name · Orc (`orc`) | 256x32 | 192x22 | 32812 |
| `fhd/name_tauren.tga` | fhd | name · Tauren (`tauren`) | 256x32 | 192x22 | 32812 |
| `fhd/name_troll.tga` | fhd | name · Troll (`troll`) | 256x32 | 192x22 | 32812 |
| `fhd/name_undead.tga` | fhd | name · Undead (`undead`) | 256x32 | 192x22 | 32812 |
| `fhd/name_skyborne.tga` | fhd | name · Skyborne (Alliance) (`skyborne`) | 256x32 | 192x22 | 32812 |
| `fhd/name_skyborne-horde.tga` | fhd | name · Skyborne (Horde) (`skyborne-horde`) | 256x32 | 192x22 | 32812 |
| `fhd/arrow_prev_normal.tga` | fhd | arrow prev · normal | 32x32 | 22x22 | 4140 |
| `fhd/arrow_prev_hover.tga` | fhd | arrow prev · hover | 32x32 | 22x22 | 4140 |
| `fhd/arrow_prev_pushed.tga` | fhd | arrow prev · pushed | 32x32 | 22x22 | 4140 |
| `fhd/arrow_prev_disabled.tga` | fhd | arrow prev · disabled | 32x32 | 22x22 | 4140 |
| `fhd/arrow_next_normal.tga` | fhd | arrow next · normal | 32x32 | 22x22 | 4140 |
| `fhd/arrow_next_hover.tga` | fhd | arrow next · hover | 32x32 | 22x22 | 4140 |
| `fhd/arrow_next_pushed.tga` | fhd | arrow next · pushed | 32x32 | 22x22 | 4140 |
| `fhd/arrow_next_disabled.tga` | fhd | arrow next · disabled | 32x32 | 22x22 | 4140 |
| `qhd/name_devil.tga` | qhd | name · Devil (`devil`) | 256x32 | 216x24 | 32812 |
| `qhd/name_alliance.tga` | qhd | name · Alliance (`alliance`) | 256x32 | 216x24 | 32812 |
| `qhd/name_horde.tga` | qhd | name · Horde (`horde`) | 256x32 | 216x24 | 32812 |
| `qhd/name_human.tga` | qhd | name · Human (`human`) | 256x32 | 216x24 | 32812 |
| `qhd/name_dwarf.tga` | qhd | name · Dwarf (`dwarf`) | 256x32 | 216x24 | 32812 |
| `qhd/name_gnome.tga` | qhd | name · Gnome (`gnome`) | 256x32 | 216x24 | 32812 |
| `qhd/name_nightelf.tga` | qhd | name · Night Elf (`nightelf`) | 256x32 | 216x24 | 32812 |
| `qhd/name_orc.tga` | qhd | name · Orc (`orc`) | 256x32 | 216x24 | 32812 |
| `qhd/name_tauren.tga` | qhd | name · Tauren (`tauren`) | 256x32 | 216x24 | 32812 |
| `qhd/name_troll.tga` | qhd | name · Troll (`troll`) | 256x32 | 216x24 | 32812 |
| `qhd/name_undead.tga` | qhd | name · Undead (`undead`) | 256x32 | 216x24 | 32812 |
| `qhd/name_skyborne.tga` | qhd | name · Skyborne (Alliance) (`skyborne`) | 256x32 | 216x24 | 32812 |
| `qhd/name_skyborne-horde.tga` | qhd | name · Skyborne (Horde) (`skyborne-horde`) | 256x32 | 216x24 | 32812 |
| `qhd/arrow_prev_normal.tga` | qhd | arrow prev · normal | 32x32 | 24x24 | 4140 |
| `qhd/arrow_prev_hover.tga` | qhd | arrow prev · hover | 32x32 | 24x24 | 4140 |
| `qhd/arrow_prev_pushed.tga` | qhd | arrow prev · pushed | 32x32 | 24x24 | 4140 |
| `qhd/arrow_prev_disabled.tga` | qhd | arrow prev · disabled | 32x32 | 24x24 | 4140 |
| `qhd/arrow_next_normal.tga` | qhd | arrow next · normal | 32x32 | 24x24 | 4140 |
| `qhd/arrow_next_hover.tga` | qhd | arrow next · hover | 32x32 | 24x24 | 4140 |
| `qhd/arrow_next_pushed.tga` | qhd | arrow next · pushed | 32x32 | 24x24 | 4140 |
| `qhd/arrow_next_disabled.tga` | qhd | arrow next · disabled | 32x32 | 24x24 | 4140 |
| `uhd/name_devil.tga` | uhd | name · Devil (`devil`) | 512x32 | 264x28 | 65580 |
| `uhd/name_alliance.tga` | uhd | name · Alliance (`alliance`) | 512x32 | 264x28 | 65580 |
| `uhd/name_horde.tga` | uhd | name · Horde (`horde`) | 512x32 | 264x28 | 65580 |
| `uhd/name_human.tga` | uhd | name · Human (`human`) | 512x32 | 264x28 | 65580 |
| `uhd/name_dwarf.tga` | uhd | name · Dwarf (`dwarf`) | 512x32 | 264x28 | 65580 |
| `uhd/name_gnome.tga` | uhd | name · Gnome (`gnome`) | 512x32 | 264x28 | 65580 |
| `uhd/name_nightelf.tga` | uhd | name · Night Elf (`nightelf`) | 512x32 | 264x28 | 65580 |
| `uhd/name_orc.tga` | uhd | name · Orc (`orc`) | 512x32 | 264x28 | 65580 |
| `uhd/name_tauren.tga` | uhd | name · Tauren (`tauren`) | 512x32 | 264x28 | 65580 |
| `uhd/name_troll.tga` | uhd | name · Troll (`troll`) | 512x32 | 264x28 | 65580 |
| `uhd/name_undead.tga` | uhd | name · Undead (`undead`) | 512x32 | 264x28 | 65580 |
| `uhd/name_skyborne.tga` | uhd | name · Skyborne (Alliance) (`skyborne`) | 512x32 | 264x28 | 65580 |
| `uhd/name_skyborne-horde.tga` | uhd | name · Skyborne (Horde) (`skyborne-horde`) | 512x32 | 264x28 | 65580 |
| `uhd/arrow_prev_normal.tga` | uhd | arrow prev · normal | 32x32 | 28x28 | 4140 |
| `uhd/arrow_prev_hover.tga` | uhd | arrow prev · hover | 32x32 | 28x28 | 4140 |
| `uhd/arrow_prev_pushed.tga` | uhd | arrow prev · pushed | 32x32 | 28x28 | 4140 |
| `uhd/arrow_prev_disabled.tga` | uhd | arrow prev · disabled | 32x32 | 28x28 | 4140 |
| `uhd/arrow_next_normal.tga` | uhd | arrow next · normal | 32x32 | 28x28 | 4140 |
| `uhd/arrow_next_hover.tga` | uhd | arrow next · hover | 32x32 | 28x28 | 4140 |
| `uhd/arrow_next_pushed.tga` | uhd | arrow next · pushed | 32x32 | 28x28 | 4140 |
| `uhd/arrow_next_disabled.tga` | uhd | arrow next · disabled | 32x32 | 28x28 | 4140 |

## Code lines changed

`Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` (106 → 236 lines, +136 / −6; CRLF kept):

| Lines (new file) | Change |
|---|---|
| 7–44 | `MEDIA` path, `ART` (bar height, font size, canvas sizes per preset), `SHIPPED` file table per preset, `shipped` lookup, `ARROW_STATES` |
| 55–56 | name Texture `nameArt` beside the name FontString (hidden until an image loads) |
| 61–76 | second Translation group on the image (0.12 s, OUT); `center()`, `settle()` / `settleArt()` |
| 83–93 | four state textures per arrow button, made once |
| 119–172 | `artSpec` (preset fhd/qhd/uhd and unchanged bar height + font size), `artPath` (file table), `showName`, `showArrows` (SetTexture result checked before SetNormal/Pushed/Disabled/HighlightTexture(…, "BLEND"); fallback clears all four and shows ◀ ▶), `dim` |
| 200–206 | in `apply()`: image choice, `Disable()` when `ListChoices` has ≤ 1 entry, else `Enable()` |
| 207–219 | both animation groups stopped, reset and played together |
| 225–232 | `PLAYER_REGEN_DISABLED` registered; alpha 0.45 in combat, 1 after; at `PLAYER_LOGIN` 0.45 when `Core.InCombat()` |

`Skin.lua`, `Theme.lua`, the TOC and the backgrounds are unchanged. Tests: `Collection/tests/statusstrip/theme_switcher.py` (client stubs for the new calls + image checks).

## Checks done (outside the game)

- `python -I Collection/tools/theme_switcher_art.py --check` → 63 TGA + licence, 0 differences (second process, same bytes).
- `python -I Collection/tests/statusstrip/theme_switcher.py` → 15 PASS lines: file set, headers, transparency outside the draw area, licence copy, Lua file table = disk, no OnUpdate/C_Timer/ticker; per preset image paths and tex coords, slide of image and text together, combat alpha, edited size/font → text, SetTexture false → text, file left out of the table → text, one choice → Disable, login in combat → 0.45.
- `python -I Collection/tests/statusstrip/run.py` (20/20), `python -I Collection/tests/core/run.py` (109/109).
- `python Collection/tools/extract.py` → status strip skin `license_files` = `Media/ThemeSwitcher/LICENSE-OFL.txt`; `genregistry.py --check` up to date; `patches.py verify` patches 7 / unmodified 20 / failures 0; `build.py --dry-run` files 2214 → 2278 (+63 TGA + licence).

## Checks not done

Everything in the game — waiting for Step 53: 13 names × 3 presets at 1:1 in the client, arrow normal/hover/pushed/disabled, hover not washed out (BLEND), slide both ways with clipping at the slot edge, `/reload` keeps theme and image, combat refusal tooltip, arrow dimming on entering/leaving combat, disabled look with one theme, text fallback after a bar edit or a file taken out of the table, English images on the Korean client; whether this client accepts texture objects in `SetNormalTexture`/`SetHighlightTexture(…, "BLEND")` and `SetTexture(nil)` for clearing.

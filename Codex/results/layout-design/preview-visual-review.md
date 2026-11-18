# Rendered preview: direct image observations

This is image-reader work, not the formal B audit or game validation. Full3840x2160 and native bottom3840x800 PNGs were inspected, followed by native small crops for glyphs, row counts, art and dividers. No render/source/spec changes were made.

## Frozen inputs and native-pixel check

- `layout-spec.json`: SHA256 `ff476a089c46df1bcd9c61a5344cad3d924c9ba0bdc7e03612bf7617291aaa04`.
- `preview-checks.json`: SHA256 `616010f81987cc7017ca8b8e4c8ca7afefcd0f5306b03bafe24f6205949c1cca`.
- `preview-notes.md`: SHA256 `74eae918c7c39a196bbeb636dcc686170b7f22dda4c681e9ea769a949ac997ee`.
- `preview-full-4k.png`: SHA256 `031e714c018085367ced7a9dcd14b55f9742573153b8c164ddee74e39fba86ac`.
- `preview-bottom-native.png`: SHA256 `48fe85d2a9f22623d1e1aa6dc05a18c5974c3e18c075cf1186af14ec11bc5675`.

Pillow independently confirmed both raster sizes and that the bottom file is pixel-identical to full-preview crop `[0,1360,3840,2160]`. Both PNG hashes match master READY. All boxes below use top-left full-preview pixels; visual bounds are approximate, not a replacement for exact spec coordinates.

## Directly visible counts and dimensions

| Region | Visible grid | Neutral icons / empty frames | Approximate painted extent |
|---|---|---|---|
| main_strip | 36 x 1 | 21 / 15 | `[430, 1688, 3411, 1768]` |
| bottom_bank | 8 x 3 | 3 / 21 | `[1850, 1808, 2514, 2056]` |
| floating_left | 4 x 3 | 2 / 10 | `[1145, 796, 1426, 1008]` |
| floating_right | 4 x 3 | 0 / 12 | `[2405, 796, 2686, 1008]` |

All84 action slots are visible;26 contain neutral diamonds and58 are empty frames. Counts and occupied positions match the original visible pattern. Generic key-example labels do not count as filled icons. The bottom bank positions are (row,column) (1,6), (2,2), (3,5); floating-left (1,3),(1,4); floating-right none.

Nominal proposed slots are80px (main/bottom) and68px (floating). Their visible recovered frame artwork appears about76x80 and65x68 after contain placement. Thus the main row visible horizontal gap is about7px, bottom bank about8px and floating banks about7px, while nominal logical gaps are3/4px. Vertical gaps remain about4px. These are **painted frame versus logical slot differences**, not a missing row or entire-image resize. The logical slot width must not be called an exact visible-frame width. Approximate frame estimates carry about +/-3px uncertainty.

## Visible quality checks

### placeholder_disclosure

Both upper and lower proposal legends are visibly present, unobscured, with Korean glyph shapes matching supplied known labels. Flat world background, identical neutral diamonds and grid map make the composition an evident proposal rather than a game screenshot.

### glyphs

Native crops show complete player/target, health/resource, map/title, status and generic key-example labels. No tofu boxes, missing strokes attributable to clipping, or label/plate crossing a frame were observed. This covers the short rendered labels only, not long bindings or user-distance readability.

### target_cue

All four dashed border edges are visible; distinct from the solid player frame. The added frame is also explained by the lower legend. Its presence is an intentional proposal, not original screenshot evidence.

Approximate visible bounds: `[2272, 1396, 2784, 1512]`.

### player_frame

Silver upper and blue lower resource-like strips, ornamented texture and short labels remain visible. No action slots or annotation plates obscure the bars.

Approximate visible bounds: `[1056, 1396, 1568, 1512]`.

### dock

Full-width dark rail/dock about392px tall. Main strip sits immediately above rail; no whole-canvas enlargement or aspect squeeze is visually apparent. Exact no-resize evidence is the mechanically matched native crop, not appearance alone.

Approximate visible bounds: `[0, 1768, 3840, 2160]`.

### panels

Two broad empty dark panels left of bank and one empty right chat placeholder remain. Their dividers and top/bottom edges are continuous. Shared left/middle seam is visibly broad because both4px borders meet; no lost divider observed.

Approximate panel bounds: `{"left": [8, 1800, 928, 2128], "middle": [928, 1800, 1840, 2128], "right": [2852, 1800, 3832, 2128]}`.

### map_adjacency

Neutral square-grid map is directly right of bottom bank and left of right dark panel, separated by narrow visible gaps. Map and chat top/bottom edges align. Bank is shorter than map; utility/bag placeholders fill its lower band. Location-title and central map labels are whole.

Approximate visible bounds: `[2520, 1800, 2848, 2128]`.

### bottom_controls

Eleven small square/line marks followed by five larger square outlines are visible below the bank; they read as deliberately abstract placeholders, not missing glyphs. Row stays above the bottom status strip.

### left_art

Winged stone creature art is exposed, with no blank box replacing it. It stands just before first main slot; approximate visible extent excludes transparent top padding in the160px placement box.

Approximate visible bounds: `[250, 1649, 426, 1780]`.

### right_art

Recovered winged figure art is exposed and does not materially hide the final slot interior. Art/slot bounding boxes overlap slightly by design. It is proposed art, not a reconstruction of the source screenshot obscured ornament.

Approximate visible bounds: `[3405, 1633, 3613, 1780]`.

### row_spacing

All three bank rows and both floating grids have separated frames; no merged rows, vanished cells, or displaced icon occupation was observed. Main row is continuous and not split into stacked central bars.

## Original Black appearance and proposal differences

The source lower concentration, dark dock, long button row, triangular frame accents, silver/blue unit bars and stone ornaments remain recognizable. Neutral contents, flat world and brighter simpler panel borders make this an intentional schematic proposal rather than a pixel-perfect source reproduction.

- **content** (declared_intentional_proposal_difference): World, original spells, bindings, numerical resources, chat messages and map terrain are replaced by flat/neutral/empty placeholders; no identity or functional behavior inferred.
- **slot_metrics** (declared_size_change_with_visible_extent_caveat): 80px logical main/bottom slots and68px floating slots are slightly smaller than original approximate82/85/70px buttons. Contained non-square recovered frame art appears about76x80 and65x68, so visible horizontal gaps are wider than nominal slot gaps. This is a logical-box versus painted-art distinction, not evidence of an accidentally scaled entire canvas.
- **bottom_bank_compaction** (declared_intentional_proposal_difference): Bottom bank is668x248 rather than original observed712x263. It ends about104px from bottom instead of94px; utility/bag strip occupies the space. Its right edge/map start shift left while bank->map->chat order remains.
- **border_fidelity** (declared_limitation_visible): Straight neutral gray4px borders look brighter/flatter and the shared seam more prominent than original dark beveled panel edges. This is visibly an approximation, consistent with notes that exact Devil2 eight-segment game edges were not rendered.
- **target** (declared_additional_proposal): Second target frame is added at right with dashed cue. Original image establishes only one large unit frame and does not establish its exact player/target identity.
- **decoration** (declared_uncertain_asset_match): Left/right recovered art is clearly present but not pixel-perfect with original visible silhouette/size. Original right art was partially occluded; source fidelity cannot be certified for its hidden extent.
- **out_of_core_elements** (declared_scope_omission): Source party-like tile, right meter overlay, top status icons, clipped side handle and dense status/message content are not present in this core preview. Reserved cast/totem/proc regions are not depicted as functioning features.

## Errors and pending checks

No definite clipped label, missing glyph, vanished asset, lost row/divider or control-covering overlay was observed in these frozen PNGs within assigned scope. Logical slot metrics must not be presented as exact painted frame dimensions.

No edit request is raised by this image-reading pass. The visible-frame-size caveat and border fidelity limit are recorded for accurate presentation of the proposal. This is not a formal-review PASS.

- Actual game raster/UI scale, addon acceptance, live interactions and persistence unverified.
- Actual monitor/viewing-distance readability and long binding labels unverified.
- Source large-unit identity and hidden right art remain unresolved.
- Exact Devil2 runtime border and offline statusbar shader fidelity unverified.

## Coverage and method limits

All edges/corners of the original full frame were inspected in the preceding original-image task; original uncertainty is retained. Current full preview and entire native bottom were both observed, then twelve native crops. Known labels from the spec were compared only for complete glyph shapes/clipping; no text/spell/key transcription or Paddle extraction was performed. Original chat/character identity was not transferred. No arbitrary redesign, runtime input or addon test was performed.

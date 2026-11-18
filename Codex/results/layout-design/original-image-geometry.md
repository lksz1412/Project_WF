# Original screenshot geometry

Source: `SourceArchive/2022-11-19/reference/black-bottom-original.jpg`, 3840 x 2160. SHA256: `A16712D8A0C64B2823D9562D14F5D51A2507117EA5B270A4C42E902EF581EA21`. Provenance record: `Codex/results/layout-design/reference-acquisition.json`.

All bounds are approximate **source-image pixels**, origin at top left, expressed as `[left, top, right, bottom]`. Right/bottom values indicate the outer boundary. Sizes include button frames; small triangular top markers may protrude a few pixels. These are visual estimates, not pixel-perfect measurements. Bottom clearance = 2160 minus lower boundary. No resizing, proportional conversion or new design was performed.

## Main observations

- The primary skill-button layout is a **single continuous 36-column x 1-row strip**, about `[421,1683,3481,1766]`, immediately above the black bottom rail. Outside button size is about 82 x 82 px; pitch 85 px and horizontal gap about 3 px. The row ends 394 px above the image bottom. It is not three visibly separated stacks.
- Below that row is a separate **8-column x 3-row bank**, about `[1845,1803,2557,2066]`. Outside button size is about 85 x 85 px; pitch 89 px and row/column gap about 4 px. Its third row ends about 94 px above the bottom, leaving the utility/bag row and status strip beneath.
- The two floating auxiliary banks are **4 columns x 3 rows each**, about `[1140,784,1437,1007]` and `[2404,784,2700,1007]`; button outside size about 70 x 70 px. They are well above the dock, over the world scene.
- The dark dock starts around y1767 and reaches the lower edge (height about 393 px). The main action row sits above this; irregular decoration reaches approximately y1619. The dock has framed translucent/dark panels with a stronger black fade near the bottom.
- The minimap is at the bottom, around `[2558,1800,2883,2131]`. The upper-right corner contains a three-icon status-like group, not a minimap.

## Visible icons versus empty framed slots

| Region | Grid | Visible icons | Empty frames | Occupied positions |
|---|---:|---:|---:|---|
| Main continuous strip | 36 x 1 | 21 | 15 | Columns 1-6, 9, 12-18, 20-21, 24-27, 31 |
| Bottom bank | 8 x 3 | 3 | 21 | Row/column (1,6), (2,2), (3,5) |
| Floating left | 4 x 3 | 2 | 10 | (1,3), (1,4) |
| Floating right | 4 x 3 | 0 | 12 | None |

Positions are counted from top left. A visible key label alone is not an icon. Empty frames show world/background through their interiors. No hidden action pages, bindings or spells are inferred.

## Complete region bounds and uncertainty

### main_action_row

- Observed/interpretive role: continuous action-button row.
- Bounds: `[421, 1683, 3481, 1766]`; width 3060 px, height 83 px.
- Confidence: high; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 394 px.
- One visually continuous row; no geometric evidence of three separate banks.
- Top triangular markers belong to the buttons and are not extra slots.
- Empty means visible frame with world/background showing through; key labels are not icon occupancy.

### bottom_aux_bank

- Observed/interpretive role: compact bottom action-button bank.
- Bounds: `[1845, 1803, 2557, 2066]`; width 712 px, height 263 px.
- Confidence: high; approximate boundary tolerance +/-5 px.
- Bottom clearance: about 94 px.
- Cells are [row,column] counted from top left.
- Black/transparent empty interiors remain framed.
- This bank sits below the main row, between a wide empty dark panel and the minimap.

### floating_left_bank

- Observed/interpretive role: left floating auxiliary button bank.
- Bounds: `[1140, 784, 1437, 1007]`; width 297 px, height 223 px.
- Confidence: high; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 1153 px.
- Separate from the bottom dock, over the game world.

### floating_right_bank

- Observed/interpretive role: right floating auxiliary button bank.
- Bounds: `[2404, 784, 2700, 1007]`; width 296 px, height 223 px.
- Confidence: high; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 1153 px.
- Same visible grid geometry and height as floating_left_bank.

### large_unit_frame

- Observed/interpretive role: player-like unit frame; exact player/target role not visually established.
- Bounds: `[1052, 1389, 1565, 1506]`; width 513 px, height 117 px.
- Confidence: high geometry / medium role; approximate boundary tolerance +/-5 px.
- Bottom clearance: about 654 px.
- Large silver/gray upper filled bar around [1057,1395,1558,1469].
- Blue lower resource-like bar around [1057,1470,1558,1500].
- Three small status icons immediately below, around [1057,1510,1151,1543].
- No distinct second large target health/resource frame is visible anywhere in this screenshot.
- Silver and blue color alone do not establish exact resource type or unit role.

### small_party_like_frame

- Observed/interpretive role: small party-like unit tile.
- Bounds: `[129, 1058, 289, 1186]`; width 160 px, height 128 px.
- Confidence: high geometry / medium role; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 974 px.
- Pink header, silver body, thin blue strip near bottom.
- Not contiguous with the larger lower-middle unit frame.

### bottom_dock

- Observed/interpretive role: full-width black/dark bottom dock and panel rail.
- Bounds: `[0, 1767, 3840, 2160]`; width 3840 px, height 393 px.
- Confidence: high; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 0 px.
- Horizontal black rail around y1767-1803; framed panel interiors start near y1803.
- Background is dark/translucent with a downward black fade, not a uniformly opaque rectangle.
- Main action row is immediately above this rail; some decorative art protrudes farther upward.
- Visible dock reaches the left, right and bottom image edges.

### left_dark_panel

- Observed/interpretive role: left chat/info placeholder-like panel.
- Bounds: `[8, 1802, 940, 2134]`; width 932 px, height 332 px.
- Confidence: high geometry / medium role; approximate boundary tolerance +/-5 px.
- Bottom clearance: about 26 px.
- Large framed dark region with no visible message list in this screenshot.
- Small controls/tabs lie on its left/top; purpose cannot be established from geometry alone.

### middle_dark_panel

- Observed/interpretive role: second chat/info placeholder-like panel.
- Bounds: `[940, 1802, 1846, 2134]`; width 906 px, height 332 px.
- Confidence: high geometry / medium role; approximate boundary tolerance +/-5 px.
- Bottom clearance: about 26 px.
- Mostly empty dark framed region; shares a vertical divider with left_dark_panel.

### minimap

- Observed/interpretive role: square minimap.
- Bounds: `[2558, 1800, 2883, 2131]`; width 325 px, height 331 px.
- Confidence: high; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 29 px.
- Square map interior approximately [2564,1807,2876,2123].
- Location label sits above the map around [2645,1763,2800,1793].
- Clock sits inside lower map; coordinates/status extend below map into bottom strip.
- No minimap is visible at the upper-right corner.

### right_message_panel

- Observed/interpretive role: right chat panel with visible message lines.
- Bounds: `[2884, 1802, 3837, 2134]`; width 953 px, height 332 px.
- Confidence: high; approximate boundary tolerance +/-5 px.
- Bottom clearance: about 26 px.
- Text is present but was not transcribed.
- Several small communication buttons lie at the left edge of this panel and along its lower edge.

### utility_controls

- Observed/interpretive role: small monochrome utility control row.
- Bounds: `[1848, 2070, 2257, 2123]`; width 409 px, height 53 px.
- Confidence: medium; approximate boundary tolerance +/-6 px.
- Bottom clearance: about 37 px.
- Visible controls: 11.
- Controls differ in silhouette; not equal-size framed action slots.

### bag_like_controls

- Observed/interpretive role: five framed bag-like controls.
- Bounds: `[2261, 2068, 2557, 2129]`; width 296 px, height 61 px.
- Confidence: high geometry / medium role; approximate boundary tolerance +/-5 px.
- Bottom clearance: about 31 px.
- Visible controls: 5.
- Approximate outside size 58-60 px; one short horizontal row.

### bottom_info_strip

- Observed/interpretive role: thin information/status strip.
- Bounds: `[8, 2130, 3837, 2160]`; width 3829 px, height 30 px.
- Confidence: high; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 0 px.
- Visible indicators and short labels; not transcribed.
- Some content touches the bottom image edge; no beyond-frame continuation inferred.

### right_overlay_panel

- Observed/interpretive role: floating dark report/meter-like panel.
- Bounds: `[3281, 1362, 3840, 1677]`; width 559 px, height 315 px.
- Confidence: high geometry / medium role; approximate boundary tolerance +/-5 px.
- Bottom clearance: about 483 px.
- Header and small controls at top; mostly empty translucent dark body.
- Panel meets the right image boundary; hidden/beyond-frame extent is unknown.
- It visually overlaps/obscures part of the right decorative asset.

### left_decor

- Observed/interpretive role: stone gargoyle/winged-creature decorative asset.
- Bounds: `[245, 1619, 425, 1778]`; width 180 px, height 159 px.
- Confidence: medium; approximate boundary tolerance +/-12 px.
- Bottom clearance: about 382 px.
- Clearly visible sculpture at the left end of main button row; irregular outline.
- Bounds separate visible art from background only approximately.

### right_decor_visible

- Observed/interpretive role: partly occluded dark creature/stone decorative asset.
- Bounds: `[3466, 1618, 3674, 1778]`; width 208 px, height 160 px.
- Confidence: medium-low; approximate boundary tolerance +/-20 px.
- Bottom clearance: about 382 px.
- Only exposed portion bounded; upper/left extent is occluded by report panel and buttons.
- No hidden shape or symmetric reconstruction inferred.

### top_right_icon_group

- Observed/interpretive role: three status-like icons and right-pointing marker.
- Bounds: `[3152, 58, 3350, 133]`; width 198 px, height 75 px.
- Confidence: high geometry / medium role; approximate boundary tolerance +/-5 px.
- Icon bodies roughly 51-53 px square; horizontally separated.
- Not an auxiliary 4x3 action bank and not a minimap.

### left_clipped_handle

- Observed/interpretive role: partly clipped vertical side panel/handle.
- Bounds: `[0, 412, 22, 675]`; width 22 px, height 263 px.
- Confidence: medium visible bounds / unknown full extent; approximate boundary tolerance +/-5 px.
- Visible narrow strip and triangular toggle only.
- Underlying panel full width/purpose cannot be recovered from this frame.

### left_social_like_button

- Observed/interpretive role: isolated small portrait/social-like button.
- Bounds: `[23, 1657, 64, 1715]`; width 41 px, height 58 px.
- Confidence: high geometry / low role; approximate boundary tolerance +/-4 px.
- Bottom clearance: about 445 px.
- Distinct from main action row and from decorative creature.

## Health/resource and decorative limits

The large lower-middle silver/blue unit frame is player-like, but its precise player/target assignment is not established from geometry alone. A small party-like tile is separately visible on the left. **A second large target health/resource frame is not visible anywhere in this frame.** This is a statement about the screenshot, not about hidden frames or profile settings. Color alone does not verify exact resource type.

A left stone winged-creature ornament is visible beside the first main button. A right dark ornament is only partly exposed behind the report panel/buttons. No hidden right-hand geometry is reconstructed. No large top-center ornamental HUD frame or separate circular health/mana orbs are visible in the full-frame scan. The upper scene contains world geometry and floating scene labels, which were not treated as HUD decoration.

## Full-frame coverage

Top, bottom, left and right edges and all four corners were inspected in the original full image. top_left: performance/status overlay; no action-button bank/minimap. top_edge: title-like overlay near middle; otherwise world scene. top_right: three small status-like icons; no minimap. left_edge: clipped vertical handle plus small party-like tile and bottom controls. center: world scene with the two floating 4x3 banks. right_edge: world scene and dark report/meter panel meeting boundary. bottom_left: decorative creature, long action row, two large dark panels. bottom_middle: 8x3 bank, utility/bag controls and minimap. bottom_right: partly occluded decoration, chat panel and tiny lower controls. bottom_edge: status strip and black dock reach edge.

## Verification and unverified items

The four button-bank counts were rechecked on native-pixel crops, including the complete main row in three overlapping sections. Box ordering, within-frame bounds, slot totals and occupied counts were checked mechanically in the JSON. Text recognition, addon/configuration attribution, keybindings, spell identity, exact colors/alpha, and recovered-profile comparison were not performed. Coordinates remain visual estimates. This report is direct image-reader observation and interpretation; it is not attributed to an external analyst.

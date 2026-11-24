# Brief — Step 58 round 3 (same work sub A): bottom HUD art keeps its shape; bar 1–3 surrounds above Dominos

User's words (R158): "테마가 좁은 화면에서 작성한것을 가로로 늘려놨더니 이미지가 깨져서 나사를 표현하려고 했던 것들이 타원이 되고, 스킬단축바1~3번을 둘러싼애들의 이미지가 도미노스 테두리에 가려 제대로 깔끔하게 보이지 않는다."
(R160): "스킬바 1~3 을 둘러싼 곳에 문제가 있는거 같은데? 특히 좌측 변 테두리와 스킬바 간의 간극 이질감 같은게 발생하는데? 여전히 도미노스가 테두리 위에 올라가서 굉장히 못생기게 가려져 버리는것도 여전하고."
Screenshots: `References/codex-verify/phase27/screens/user-check-01..05.webp` (uhd).

Your own diagnosis (diag-58.md D2 + round-1 report): Composition.lua draws a 2048×256 top texture as a 3×3 slice and a 2048×512 deck as one piece; fhd/qhd/uhd art is nearly the same picture; uhd stretches ~1.29× sideways; frames on strata BACKGROUND level 0 under Dominos + Masque Onyx borders; bar surrounds don't line up with the 82 px button pitch.

Decision (master default, user may still ask for new per-resolution art instead): **cut the existing art into pieces with a deterministic dev tool and rebuild the composition so nothing is drawn with a different scale across x and y.**
1. Dev tool (not shipped), deterministic: cut each preset's top and deck art into elements — corner/end caps, rivets/screws, separator joints, plain repeatable bar/edge strips, panel fills, the action-bar surround pieces (left cap, right cap, top/bottom edge strip). Output TGA like the existing media (32-bit, type 2, alpha). Record source rectangles in a table the code reads.
2. Composition: end caps, rivets, joints at a uniform scale (same px-per-texel on x and y, chosen from the screen height); fill the remaining length by tiling/repeating the plain strips (TexCoord repeat or several textures), and place joints/rivets at the real positions of the chat, action bar, minimap panels — not where the stretched picture had them.
3. Action bars 1–3 surround: built from the surround pieces, sized to the actual DominosFrame1–3 rectangles (read at runtime after Dominos layout, and on its layout change) with an even margin on all sides (fix the left-edge gap); drawn on a frame strata/level ABOVE the Dominos buttons and the Masque Onyx borders, but never taking mouse input; combat-safe (no protected calls).
4. Themes: the 13 themes share this composition (each theme its own art per preset) — keep that working; if a theme lacks a piece, fall back to the current stretched drawing for that theme only and log once.
5. Tests: px-per-texel equal on x and y for every fixed piece in fhd/qhd/uhd; surround rectangle = Dominos bar rectangle + margin on all four sides; surround strata/level above the Dominos button + Onyx border; no mouse; composition tests updated; art --check covers the new TGA.

Gates: composition, statusstrip, core, themes/appearance suites, luacheck, art check, extract + genregistry --check, patches verify, build dry-run both variants. Work log: "Round 3" section in iter_2/work_log-58.md (impact map, commands + verdict lines, read ranges, choices). If something cannot be made clean with cut pieces (e.g. the picture has no plain strip to tile), stop that part and report it with the file/rectangle instead of guessing. No commits, no deletes, no popups, nothing in the game folder.

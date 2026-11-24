# Brief — Phase 27 Step 58 diagnosis (same work sub A) — READ ONLY

The user checked the installed 0.1.5 PitBull4 build (commit c34716a3, installed from stage `_local_only/claude-p27-stage-255f4725`) in game on a **uhd** screen, PitBull4 and theme only. Their words (original, R158):

> 상태띠에 테마 변경 관련 버튼 이 하나도 없다. 그리고 테마가 좁은 화면에서 작성한것을 가로로 늘려놨더니 이미지가 깨져서 나사를 표현하려고 했던 것들이 타원이 되고, 스킬단축바1~3번을 둘러싼애들의 이미지가 도미노스 테두리에 가려 제대로 깔끔하게 보이지 않는다. 리로드시 유지는 된다. 그리드 시작점이 왜 파티 핏불위에 생기냐. 퀘스트 위에 생기라고 해놨는데? 그리고 uhd에서 너무 작게 뜬다. 또한 피통이 너무 가로로 길쭉해. 정사각형으로 나왔으면 좋겠어. V2로 확정하되 주시대상 핏불이 정가운데에 들어오게 하고, 버프, 디버프 위치도 내 캐릭터나 대상 캐릭터와 동일 수준으로 떴으면 좋겠다. V2 면 이제 내 캐릭터 대상캐릭터 주시 대상이 모두 버프 디버프 나오는 형상이 통일되어야할것 같은데 지금 셋이 다 다르네? 소환수는 지금 형태 그대로 뜨는게 맞으니까 건드리지 말고. 그런데 대상의 소환수의 대상, 대상의 대상은 왜 안뜨냐? 핏불이랑 테마만 확인했다.

Do NOT edit anything in this round. Read the code and report, per item:

- **D1 theme switcher missing**: why are the ◀ ▶ arrows and the name not shown on the status strip (uhd preset)? Trace `DevilForever_Skin_StatusStrip` load order (.toc), `ThemeSwitcher.lua` creation/parent/anchor/show conditions, the SHIPPED table and media paths vs the installed files (stage folder), the preset → switcher size path. Say whether it is our Step 51 change or older.
- **D2 bottom HUD theme art stretched**: which addon/files draw the bottom HUD frame art (screws, the ornaments around Dominos action bars 1–3); how the texture size/aspect is set per preset (fhd/qhd/uhd) and why it stretches sideways on a wide screen; why the ornaments end up under the Dominos button borders (frame strata/level, draw layer, anchor). Do not redraw art; say what change would keep the aspect (e.g. fixed-aspect pieces + repeated middle, or per-resolution art) and what exists already.
- **D3 Grid2**: where the Grid2 anchor/position for uhd and V2 is set (presets, `Defaults/Grid2.lua`, V2.lua), why it ends up above the PitBull party frames instead of above the quest tracker (Objective tracker, right side), why it is small on uhd (scale/cell size), and where cell width/height are set (user wants square cells).
- **D4 V2 as the layout**: how a preset is chosen by default (fhd/qhd/uhd vs *-v2), what would make V2 the default for every screen; where the focus frame position is set (user: exact horizontal centre of the screen); how player/target/focus aura (buff/debuff) layouts are defined in PitBull4 layouts in V2 and how they differ now (list the exact settings for each of the three); pet frames stay unchanged.
- **D5 target's target and target-pet's target**: are these PitBull4 units defined/enabled in the presets (fhd/qhd/uhd/V2)? Why would they not show (disabled, not in layout, hidden by config mode, anchored off-screen)?

For each item give: cause with file:line and the quoted code line(s); the change you propose (files, values); anything that needs a choice (state your default); an impact map (place · impact = fix together / check only / none · reason) per `feedback_change_impact_analysis`; which tests cover it. Hekili is out of scope. Write the report to `Claude/results/handoffs/phase27/iter_2/diag-58.md` and also return it.

Rules: no edits to repo or game files except that report file; no commits; no deletes; no popups; read files in full when you judge from them, and record the files and line ranges you read in the report. If your earlier context was compacted, re-read the inputs you need in full.

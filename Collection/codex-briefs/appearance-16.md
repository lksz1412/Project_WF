# Codex 외관 발주문 — Phase 16 (상태 띠 · DevilForever_StatusStrip)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53·R87). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로이고, 세 겉보기 값의 꼴은 `Collection/codex-briefs/appearance-2-layouts.md` 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/16/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef` — `!DevilForever_Core` + `DevilForever_StatusStrip`). Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트와 세 겉보기(`References/codex-appearance/2-layouts/`) 위에 얹는다. 띠가 게임에서 무엇을 보이는지는 실사용 검증 `Collection/codex-briefs/phase16.md` 결과(`References/codex-verify/phase16/`)를 먼저 본다.
- 띠 애드온은 외관을 하나도 정하지 않는다: 색·질감·바탕이 없고, 글자는 게임 글꼴 객체 `GameFontHighlightSmall` 그대로다. 띠 코드는 Core 의 토큰·편집 값을 읽지 않는다(Core 없이도 돈다). 그래서 외관은 모두 Codex 의 Skin 애드온이 입힌다.

## 1. 만들 것

- 띠 프레임 `DevilForever_StatusStripFrame` 을 Step 5 아래 상태 띠 자리에 앉힌다: 높이 28px, 화면 맨 아래 8px 여백 바로 위, 3840×2160 에서 y 2124–2152(`Codex/docs/devil-ui-old-4k-layout.md:27–29`). 상태 글자 크기는 그 해상도에서 고른 글꼴의 22px(`devil-ui-old-4k-layout.md:73`). FHD·QHD·UHD 세 겉보기마다 `statusstrip.bar` 의 위치·크기·글꼴·색·간격 값을 따로 정한다(R107 ⑥). 크기는 `appearance-2-layouts.md` 2절 순서대로 그 해상도에서 따로 정하고 비율을 곱하지 않는다.
- 여섯 칸 글자 모두에 같은 글꼴·색을 입힌다(편집 항목은 띠 하나에만 있다). 색은 글자 프레임 하나에 한 색이다 — 골드 칸 글자는 색 코드 없는 평문(`1,234g 05s 07c`)이고 동전 색(g·s·c 를 따로 칠하는 것)은 넣지 않는다. 스킨은 골드 칸 글자 전체에 한 색을 입힐 수 있다. 칸마다 다른 색·글꼴이 필요하면 판단과 이유를 보고서에 적는다 — 등록 표에 칸마다 편집 항목을 더하는 것은 Claude 몫이다.
- 바탕·테두리·칸 사이 구분선은 Codex 의 Skin 애드온이 만든 자기 질감(또는 kgPanels 판)으로 띠 뒤에 둔다. 띠 애드온의 프레임에 질감을 더하지 않는다.
- 참고만: V42 `!DevilUI/Profile/ChocolateBar.lua`(ChocolateBar·Broker 플러그인은 모음집에 넣지 않는다).

## 2. 수단 — 작은 Skin 애드온

- 새 폴더 `DevilForever_Skin_StatusStrip/`: TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, DevilForever_StatusStrip`(띠 애드온을 끄면 스킨도 함께 꺼진다).
- 값은 Core 약속으로만 읽는다: 질감·글꼴·색은 `DevilForever_Core.Theme:Get(token)`, 겉보기마다 다른 값은 `DevilForever_Core.Edit:Get("statusstrip.bar")`. 바뀜은 `Theme:RegisterCallback`·`Edit:RegisterCallback` 로 받는다(Core 는 전투 중 콜백을 보내지 않는다 — `API.lua` 머리 주석 「Callbacks」).
- 값을 입히는 곳(띠 애드온의 공개 함수 — 전역 표 `DevilForever_StatusStrip`, 설명은 `Collection/AddOns/DevilForever_StatusStrip/StatusStrip.lua` 머리 주석):

| 편집 값 (`statusstrip.bar`) | 입히는 곳 |
|---|---|
| `position`, `size` | `DevilForever_StatusStrip:GetFrame()` (띠 프레임 하나. 띠 애드온은 처음에 UIParent 맨 아래 왼쪽·오른쪽 두 점, 높이 20 으로 붙여 둔다 — `ClearAllPoints` 뒤 새 자리로 옮긴다) |
| `font`, `color` | `DevilForever_StatusStrip:GetFontString(key)` 여섯 개 — key 는 `gold`·`bags`·`durability`·`clock`·`latency`·`fps` |
| `spacing` | `DevilForever_StatusStrip:SetSpacing(px)` (0 이상 숫자. 칸 배치를 다시 한다. 이번 접속 동안만. `LAYOUT` 콜백 안에서 불러도 된다 — 새 간격은 바로 기억되고, 배치는 겹쳐 돌지 않고 지금 배치가 끝난 뒤 한 번 더 돈다. 그 두 번째 배치 안에서 다시 부른 배치는 버려진다) |

- 등록 표(`registry_extra.json`)에 이미 있는 것: frame key `statusstrip.bar`(토큰 기본값 글꼴 `font.number`, 색 `color.text.normal`, 간격 `spacing.default`)와 칸마다 `statusstrip.gold`·`statusstrip.bags`·`statusstrip.durability`·`statusstrip.clock`·`statusstrip.latency`·`statusstrip.fps`. 편집 항목은 `statusstrip.bar` 의 `position`, `size`(8–8192, 너비·높이 같은 범위), `font`(크기 6–64), `color`, `spacing`(0–128).
- 쓸 수 있는 토큰(`Theme.lua` 의 토큰 목록): 글자 `font.number`·`font.size.normal`(작게 하려면 `font.size.small`)·`color.text.normal`(글자 하나 — FontString 하나에 색 하나), 바탕 `color.panel.background`·`color.panel.border`·`texture.panel`·`border.size`, 구분선 `color.divider`·`texture.divider`, 간격 `spacing.default`. `color.text.disabled` 와 장식·상태 막대 질감은 쓰지 않는다.
- 칸 배치: 띠 애드온은 켜진 칸만 왼쪽부터 `gold, bags, durability, clock, latency, fps` 순서로 붙이고(첫 칸은 띠 왼쪽에서 간격만큼, 다음 칸은 앞 칸 오른쪽에서 간격만큼), 배치할 때마다 `DevilForever_StatusStrip:RegisterCallback(owner, fn)` 의 `fn("LAYOUT", shownKeys)` 를 부른다(shownKeys = 보이는 칸 key 목록 사본). 구분선은 이 콜백에서 보이는 칸 사이에 둔다. 글자 프레임은 보호 프레임이 아니라서 이 콜백에서 다시 붙여도 된다. 칸이 켜지고 꺼지는 것은 사용자가 `/dfstatus` 로 정한다 — 스킨은 칸을 켜거나 끄지 않는다.
- 값 콜백은 없다(1초마다 부르면 비용이 든다). 글자는 띠 애드온이 이미 넣으므로 스킨이 값을 읽을 일은 없다. 값에 따라 색을 바꾸는 것(내구도 낮음 경고 등)은 이번 판에 넣지 않는다 — 넣으려면 새 토큰이 필요하다(Core 변경). 필요하다고 보면 보고서에 제안만 적는다.

## 3. 지킬 것 (taint·보호 프레임)

- **보호 프레임과 띠의 고정점을 섞지 않는다**: Dominos 막대 같은 보호 프레임을 띠 프레임에 붙이지 않고, 띠 프레임을 보호 프레임 고리에 붙이지 않는다. 전투 중 보호 프레임이 기대는 일반 프레임을 옮기면 「동작 차단」 오류가 나는 경우가 있다(이 클라이언트에서 그대로인지는 확인 필요 — 게임에서 본다). 띠는 UIParent 나 Skin 애드온 자기 프레임에만 붙인다.
- 띠는 마우스를 받지 않는다(`EnableMouse(false)`). 스킨도 띠와 그 위 질감에 마우스를 켜지 않는다 — 띠 자리 아래의 버튼이 눌려야 한다. 풍선 도움말(툴팁)은 이번 판에 없다.
- `hooksecurefunc`·`HookScript` 를 블리자드 프레임에 걸지 않는다. 보안 템플릿·`SetCVar` 를 쓰지 않는다. 띠 애드온 파일은 고치지 않는다.
- 띠 프레임에 `SetScript("OnShow", …)`·`SetScript("OnHide", …)` 를 걸지 않는다 — 띠 애드온이 이 두 자리로 1초 타이머를 켜고 끈다(덮어쓰면 타이머가 멈추지 않거나 다시 켜지지 않는다). 띠가 보이고 숨는 때를 알아야 하면 띠 프레임에 `HookScript("OnShow", …)`·`HookScript("OnHide", …)` 를 쓴다(우리 애드온 프레임이라 블리자드 프레임 금지와 부딪히지 않는다).
- 띠 층(strata)은 `LOW` 다. 다른 창 아래로 들어가야 할 자리라면 그대로 두고, 바꿀 이유가 있으면 보고서에 적는다.

## 4. 겹침 (같은 정보를 두 번 보이지 않게)

| 정보 | 다른 자리 | 이번 판 |
|---|---|---|
| 시계 | SexyMap 기본값이 미니맵 시계(`TimeManagerClockButton`)를 늘 보이게 둔다(`Collection/AddOns/!DevilForever_Core/Defaults/SexyMap.lua:70`) | 둘 다 둔다. 하나를 끄는 것이 낫다고 보면 어느 쪽을 왜 끌지 보고서에 제안만 적는다 — 정하는 것은 사용자다 |
| 좌표·지역 이름 | SexyMap (`sexymap.zonetext`·`sexymap.coordinates`) | 띠에 넣지 않았다 |
| 경험치·평판 | Phase 19 | 띠에 넣지 않았다 |

## 5. 올릴 것 · 받아들이는 기준 (`References/codex-appearance/16/`)

- `AddOns/DevilForever_Skin_StatusStrip/`(TOC·Lua·자산), `layouts/fhd.lua`·`qhd.lua`·`uhd.lua` 의 `statusstrip.bar` 값, `assets.md`, `report.md`(고른 토큰·값, 구분선을 둔 방법, 칸마다 다른 외관이 필요한지 판단, 미니맵 시계 겹침 제안, 세 겉보기 게임 갈무리 — 칸을 하나 끈 모습과 전투 중 모습 포함, 남은 문제). 칸마다 편집 항목을 더하자고 하면 `registry_extra.fragment.json` 으로 제안한다.
- 기준: `appearance-2.md` 4절 + `appearance-2-layouts.md` 4절 + 4K 에서 띠가 y 2124–2152 자리(28px)에 앉음 + 세 겉보기 모두 여섯 칸이 띠 안에 다 들어감(가장 긴 골드 칸 `100,000g 00s 00c` 기준) + `/dfstatus <칸> off` 뒤 구분선이 빈자리 없이 다시 놓임 + 전투 중 차단·Lua 오류 0 + 띠와 그 위 질감이 클릭을 막지 않음 + 보호 프레임과 띠의 고정점이 섞이지 않음 + 띠 애드온 파일 변경 0.

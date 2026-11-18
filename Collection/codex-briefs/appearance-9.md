# Codex 외관 발주문 — Phase 9 (공격대 프레임 · Grid2 4.1.13-forever)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/9/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `12845c356942b655ef9a56e86aa7a00e088e8a7a8a61a6a10078a7e77de8b06d`) + Grid2 원본 `References/forever-addons/Grid2/Grid2-4.1.13-forever.zip`(`Grid2`·`Grid2Options`·`Grid2LDB`). Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.

## 1. 만들 것

- 공격대 창(Grid2 창)의 자리·배율, 단추 크기·간격, 체력 막대 질감·방향, 이름 글꼴, 테두리·배경, 아이콘(역할·디버프·버프) 크기와 자리. 자리는 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md`)에서 Codex 가 정하되 중앙 시야와 파티 프레임(unit 프레임 애드온 몫)을 가리지 않게 한다. Grid2 는 공격대일 때만 보인다(혼자·파티는 unit 프레임 애드온).
- Grid2 자체 외관 수단이 먼저다: 처음 켜질 때 고르는 프로필 틀(Classic·Modern·Blizzard — `Grid2Options/profiles/`, 기본 틀 Empty 는 `Grid2/GridDefaultsRetail.lua`), Grid2 테마(프로필의 `themes` — 조건별로 바뀌는 외관 묶음, `Grid2/GridCore.lua:236–294`), LibSharedMedia-3.0 질감·글꼴 이름 등록(`GridCore.lua:130–139`). 어느 틀 위에 외관을 얹을지 Codex 가 정해 보고서에 적는다(Phase 9 검증은 Modern 으로 한다).

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음 · Grid2 항목)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `grid2.layout` | `Grid2LayoutFrame` | position · size(단추 하나의 너비·높이, 10–200) · spacing(단추 사이 `Padding`, 0–20) |

창은 Grid2 가 로드될 때 만든다(`Grid2/GridLayout.lua:218`). 공격대 묶음 머리는 `Grid2LayoutHeader<n>`(51), 단추는 그 아래 보안 단추(`SecureUnitButtonTemplate`, 29·60)이고 이름은 클라이언트가 붙인다(`Grid2LayoutHeader<n>UnitButton<m>`) — 등록 표에는 창 하나만 넣었다. 범위는 Grid2 설정 창 범위를 따랐다(단추 너비·높이 최소 10·권장 최대 200, Padding 0–20 — `Grid2Options/modules/themes/GridGeneral.lua:147–180, 580–594`).

## 3. 값을 어디에 두나

- Grid2 설정은 AceDB 저장 변수 `Grid2DB` 에 캐릭터마다의 프로필로 있다(`GridCore.lua:124`). 단추 모양은 이름공간 `Grid2Frame`(키 `frameWidth`·`frameHeight`·`frameBorder`·`frameBorderColor`·`frameTexture`·`iconSize`·`orientation` 등 — `GridFrame.lua:246` 이후), 창·배치는 이름공간 `Grid2Layout`(`ScaleSize`·`Padding`·`Spacing`·`horizontal`·`anchor`·`groupAnchor`·`PosX`·`PosY`·`BorderTexture`·`BackgroundTexture`·`Border*`·`Background*` — `GridLayout.lua:153–190`), 표시자 모양(글꼴·크기·자리)은 최상위 프로필의 `indicators` 에 있다.
- 외관 코드가 `Grid2DB` 를 직접 쓰거나 Grid2 창·단추에 `SetPoint`·`SetSize` 를 직접 걸지 않는다. Grid2 설정으로 되는 값은 **값 제안 파일** `grid2-profile.fragment.lua`(Lua 표 하나, `{namespaces = {Grid2Frame = {...}, Grid2Layout = {...}}, indicators = {...}}` 꼴, Grid2 키 이름 그대로)로 낸다. 주의: 처음 켜짐 창에서 틀을 고르면 그 틀이 몇 키를 덮어쓴다(예 Modern: `Grid2Frame` 의 `iconSize`·`frameWidth`·`frameHeight`·`frameBorder`·`frameBorderDistance`·`displayZoomedIcons`·`orientation`·`frameBorderColor`, `Grid2Layout` 의 `BackgroundTexture`·`BorderTexture`·`horizontal`·`Padding`, 그리고 `indicators` 전부 — `Grid2Options/profiles/ProfileModern.lua:4–76`). 그래서 이 키들은 Core 기본값 주입으로 넣어도 틀 고르기 뒤 사라진다 — 제안 파일에 어떤 키가 틀과 겹치는지 표시하면 Claude 가 넣는 길을 정한다.
- 기능 설정은 바꾸지 않는다: `Grid2Layout` 의 `layouts`(혼자·파티·투기장 「None」, 공격대 「By Group」)·`FrameDisplay`(「Raid」), 최상위 `hideBlizzard`, 표시자에 걸린 상태와 그 순서(`statusMap` — 역할·해제 가능 디버프·버프·지속 치유의 뜻), 단추 클릭(왼쪽 = 대상, 오른쪽 = 메뉴, 클릭 시전 없음 — R97). 단추의 `unit` 속성은 마우스오버 매크로가 쓰므로 단추를 다른 프레임으로 가리거나 마우스를 막지 않는다.

## 4. 올릴 것 (`References/codex-appearance/9/`)

- 새 폴더 `AddOns/DevilForever_Skin_Grid2/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, Grid2`) — LibSharedMedia 등록과 Grid2 설정에 없는 부분만, `grid2-profile.fragment.lua`, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(고른 틀·값, 4K 게임 화면 갈무리 경로 — 10명 이상 공격대 또는 Grid2 설정 창의 배치 시험 보기 하나, 해제 가능 디버프 테두리 하나, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + Grid2 파일 수정 0 + 3절의 기능 설정 변경 0 + `Grid2DB` 직접 쓰기 0.

# Codex 외관 발주문 — Phase 5 (미니맵 · SexyMap v12.1.7)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/5/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `718c3f4a378867550e8d40ec27cccb99302470348ac4f2d090aac8f809cfd874`, `!DevilForever_Core`(SexyMap 기본값 파일 `Defaults/SexyMap.lua` 포함) + `DevilForever_ChatSetup`) + SexyMap 원본 `References/forever-addons/SexyMap/SexyMap-v12.1.7.zip`. Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.

## 1. 만들 것

- 사각 미니맵의 모양·자리·크기·테두리(R34). Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md:50`): 사각 미니맵 `2596,1820` 304×304, 중앙 8×3 묶음 오른쪽.
- 사각 모양은 SexyMap 자체 기능이다: `core.shape = 130871`(`Interface\BUTTONS\WHITE8X8`, 「Square」 — `SexyMap/Shapes.lua:228–232`). 이 값이면 SexyMap 이 `GetMinimapShape()` 를 `"SQUARE"` 로 돌려줘(`Shapes.lua:313–318`) 미니맵 단추들이 사각 가장자리를 따라 놓인다. V42 의 사각 기전(`!DevilUI/minimap.lua:707, 740–746`)은 참고만 하고, 그 파일의 초기화 코드 815–838 은 쓰지 않는다.
- 테두리·배경은 SexyMap 테두리 모듈과 프리셋(`Borders.lua:827–846`, `BorderPresets.lua` — 사각 프리셋은 `shape = 130871` 인 것들)이 SexyMap 자체 스킨 수단이다. 모자라면 Skin 폴더에서 그린다.
- 시계·지역 글자·좌표의 글꼴·색·자리, 미니맵 단추의 반지름·각도·배율(`buttons.radius`·`scale`·`dragPositions`).

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음 · SexyMap 항목)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `sexymap.minimap` | `Minimap` | position |
| `sexymap.zonetext` | `SexyMapZoneTextButton` (`ZoneText.lua:248–260`) | 없음 |
| `sexymap.clock` | `TimeManagerClockButton` | 없음 |
| `sexymap.coordinates` | `SexyMapCoordFrame` (`Coordinates.lua:281`) | 없음 |

프레임은 SexyMap 이 PLAYER_LOGIN 의 각 모듈 OnEnable 때 만든다. `tokens` 칸은 비어 있다 — 필요한 토큰 연결은 조각 파일로 제안한다.

## 3. 값을 어디에 두나

- SexyMap 저장 값(`SexyMap2DB["<이름>-<서버>"]` 의 모듈 표 `core`·`buttons`·`borders`·`clock`·`zonetext`·`coordinates`·`movers`)에 있는 것은 **값 제안 파일** `sexymap-profile.fragment.lua`(Lua 표 하나, `{core = {...}, buttons = {...}, borders = {...}, …}` 꼴, SexyMap 키 이름 그대로)로 낸다. Claude 가 `Defaults/SexyMap.lua` 의 캐릭터 프로필 표에 넣는다(처음 한 번, 사용자 값 우선).
- **모듈 표는 빠짐없이**: SexyMap 은 모듈 표가 없을 때만 자기 기본 표를 만든다(`SexyMap.lua:343–352`, 각 모듈 `OnInitialize`). 조각에 새 모듈 표(`borders` 등)를 넣으면 그 모듈의 `OnInitialize` 기본 표 키를 모두 담는다(`Borders.lua:828–846`, `Clock.lua:183–193`, `ZoneText.lua:206–217`, `Coordinates.lua:226–239`, `Movers.lua:114–121`). `core`·`buttons` 는 Claude 파일의 키를 그대로 두고 바꿀 값만 적는다 — `core.rightClickToConfig`·`buttons.visibilitySettings.MiniMapTracking` 은 기능 값이라 바꾸지 않는다.
- 자리는 `core.point`·`relpoint`·`x`·`y`(UIParent 기준)로 낸다. SexyMap 은 이 값이 있으면 `Minimap:SetPoint` 를 다시 걸어 되돌리므로(`SexyMap.lua:574–581`) 외관 코드가 `Minimap:SetPoint` 를 직접 부르지 않는다. 크기는 SexyMap 이 140×140 으로 고정하므로(`SexyMap.lua:548`) `core.scale`(0.2–3.0)로 맞춘다.
- 클릭·휠 확대·자동 축소(5초)·핑·추적 단추·단추 숨김 규칙은 바꾸지 않는다(기능 기본값 · Claude 몫).

## 4. 올릴 것 (`References/codex-appearance/5/`)

- 새 폴더 `AddOns/DevilForever_Skin_SexyMap/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, SexyMap`) — SexyMap 설정에 없는 부분만, `sexymap-profile.fragment.lua`, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(고른 값, 4K 게임 화면 갈무리 경로, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + SexyMap 파일 수정 0 + 기능 값(3절 마지막 줄) 변경 0.

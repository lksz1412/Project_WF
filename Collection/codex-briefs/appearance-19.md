# Codex 외관 발주문 — Phase 19 (경험치·평판 바 · Experience Forever 2.0.4)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53·R87). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로이고, 세 겉보기 값의 꼴은 `Collection/codex-briefs/appearance-2-layouts.md` 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/19/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49` — `!DevilForever_Core`) + Experience Forever 원본 `References/addon-sources/experience-forever/ExperienceForever.zip`(`ExperienceForever`). Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트와 세 겉보기(`References/codex-appearance/2-layouts/`) 위에 얹는다. 막대가 게임에서 무엇을 보이는지는 실사용 검증 `Collection/codex-briefs/phase19.md` 결과(`References/codex-verify/phase19/`)를 먼저 본다.
- 경험치·평판·사냥꾼 소환수 경험치는 Experience Forever 하나가 맡는다. `Dominos_Progress` 는 쓰지 않으므로 스킨하지 않는다. 게임 기본 경험치 막대(`StatusTrackingBarManager`)는 Experience Forever 가 투명하게 해 둔다(`ExperienceForever/ExperienceForever.lua:1215–1245`) — 스킨은 그것을 다시 보이게 하거나 손대지 않는다. 아래 줄 번호는 모두 `ExperienceForever/ExperienceForever.lua` 다.

## 1. 만들 것

- 막대 셋(경험치·평판·소환수)을 Step 5 설계의 **긴 윗줄·검은 띠 범위 안**에 앉힌다. UHD 기준 자리: 검은 가로 띠 x 0·y 1804·3840×16(`Codex/results/old-devil-layout/layout-spec.json` 의 `black-crossrail`), 긴 윗줄 x 445·y 1724·2950×80(`Codex/docs/devil-ui-old-4k-layout.md:52`). 띠 안에 넣을지, 긴 윗줄 폭에 맞춘 얇은 줄로 띠와 겹쳐 둘지는 Codex 가 정한다. 긴 윗줄의 행동단축바 버튼(Phase 3)을 가리지 않는다.
- 높이 계산에 쓸 사실: Experience Forever 기본값은 막대 높이가 글자 크기를 따른다(`autoBarSize`, 47) — 경험치 막대 `fontSize + 16` = 30, 평판·소환수 막대 `글자 크기 + 4` = 14(776–778), 막대 사이 2px(557, 873). 셋을 다 켜면 62px 로 띠(16px)보다 높다. 경험치 막대 위·아래에 글자 칸이 막대 밖으로 붙는다(`topLeft`… `bottomRight`, 357–367, 기본 내용 21–31). 띠에 맞추려면 Experience Forever 의 높이·글자 값을 바꿔야 한다 — 어떤 값으로 맞췄는지 보고서에 적는다.
- FHD·QHD·UHD 세 겉보기마다 값을 따로 정한다(R107 ⑥). 크기는 `appearance-2-layouts.md` 2절 순서대로 그 해상도에서 정하고 비율을 곱하지 않는다.
- 미니맵 단추 `ExperienceForeverMinimapButton`(471)은 미니맵(Phase 5)의 다른 단추와 같은 결로 맞춘다. 숨기는 것이 낫다고 보면 제안만 적는다(숨김은 Experience Forever 설정 `minimap.hide` — 정하는 것은 사용자다).

## 2. 프레임과 값을 거는 곳

| key (등록 표) | 전역 프레임 | 편집 항목 |
|---|---|---|
| `experienceforever.bar` | `ExperienceForeverFrame` (경험치 막대 — 평판·소환수 막대의 부모) | position |
| `experienceforever.minimap` | `ExperienceForeverMinimapButton` | 없음 |

- 이름 없는 하위 프레임은 애드온 객체로 닿는다: `local E = LibStub("AceAddon-3.0"):GetAddon("ExperienceForever")` → `E.ProgressBar`·`E.QuestBar`·`E.RestedBar`(경험치 막대를 덮는 세 StatusBar, 546–553), `E.RepBar`·`E.RepText`(556–562), `E.PetBar`·`E.PetText`(579–585), `E.Texts[<칸 이름>]`(613–618). 층(strata)은 `BACKGROUND`(12) — 검은 띠 질감과 쌓이는 순서를 정해 보고서에 적는다.
- Experience Forever 가 스스로 다시 거는 값(스킨이 직접 걸어도 덮인다): 평판·소환수 막대 높이와 평판 색은 약 1초마다(`Update`, 446·904·913·1125), 막대 질감은 LibSharedMedia 등록 때마다(383, 727–741), 막대 색은 시작·색 설정 때(748–771), 글꼴과 막대 높이는 시작·글꼴 설정 때(792–826). 그래서 **너비·높이·질감·색·글자 크기는 Experience Forever 자기 값으로** 겉보기마다 정해 값 제안 파일(3절)에 낸다 — 등록 표의 편집 항목은 위치 하나뿐이다(Core 의 size 편집은 너비·높이를 함께 걸고, 높이·글꼴은 Experience Forever 가 다시 정해 편집값이 남지 않기 때문). 스킨이 실행 중에 거는 것은 `experienceforever.bar` 의 위치와 그 위 장식 질감뿐이다.
- 위치: 사용자가 막대를 끌면 Experience Forever 가 자리를 자기 값(`location`)에 저장한다(538–544, 637–649). 스킨이 `Edit:Get` 위치를 접속마다 다시 걸면 끈 자리가 다음 접속에서 돌아간다. 위치를 편집값으로 걸지, Experience Forever 값으로 두고 막대를 잠글지(`lockBar`)는 Codex 가 정하고 이유를 적는다.

## 3. 값을 어디에 두나

- Experience Forever 설정은 AceDB 의 `global` 칸 하나다(계정 공통, 캐릭터·프로필 구분 없음 — `ExperienceForeverDB.global`, 373, 기본값 39–106). 외관 코드가 이 저장 변수를 직접 쓰거나 Experience Forever 함수 `SetPosition`·`ResetPosition` 을 부르지 않는다(둘 다 저장 값을 쓴다).
- 겉보기마다 다른 Experience Forever 값은 **값 제안 파일** `experienceforever-global.fragment.<fhd|qhd|uhd>.lua`(Lua 표 하나, `ExperienceForeverDB.global` 의 키 이름 그대로)로 낸다. 쓸 수 있는 키: `barWidth`·`barHeight`·`repBarHeight`·`petBarHeight`·`autoBarSize`, `fontName`·`fontSize`·`fontOutline`·`repFontSize`·`petFontSize`, `barTexture`·`repBarTexture`·`petBarTexture`(LibSharedMedia 이름 — 새 질감은 스킨이 LSM 에 등록), `baseColor`·`questColor`·`restedColor`·`repColor`·`petColor`·`repUseStandingColour`, 테두리 `showBorder`·`showRepBorder`·`showPetBorder` 와 그 색, `location`. 넣는 길은 Claude 가 정한다.
- 기능 설정은 바꾸지 않는다: `showPetBar`·`showRepBar`·`repFollowWatched`·`repFactionID`·`hideDefaultXpBar`·`petShowText`·`repShowText`·`repKillsInText`·`repAutoPerKill`·`repPerKill*`. 글자 칸의 내용(`slots`·`showLabels`·`separator`)도 기본 그대로가 기준이다 — 띠에 맞추려면 바꿔야 한다고 보면 어느 칸을 왜 바꿀지 보고서에 제안만 적는다.

## 4. 수단 · 올릴 것 · 받아들이는 기준 (`References/codex-appearance/19/`)

- 새 폴더 `AddOns/DevilForever_Skin_ExperienceForever/`: TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, ExperienceForever`(Experience Forever 를 끄면 스킨도 꺼진다). 값은 `DevilForever_Core.Theme:Get(token)`·`DevilForever_Core.Edit:Get("experienceforever.bar")` 로만 읽고 바뀜은 `RegisterCallback` 으로 받는다. Experience Forever 의 `OnInitialize`(372)가 막대를 만든 뒤에 건다.
- 막대를 Dominos 막대 같은 보호 프레임에 붙이지 않고 보호 프레임을 막대에 붙이지 않는다. `hooksecurefunc`·`HookScript` 를 블리자드 프레임에 걸지 않는다. Experience Forever 파일은 고치지 않는다.
- 올릴 것: 스킨 폴더(TOC·Lua·자산), `layouts/fhd.lua`·`qhd.lua`·`uhd.lua` 의 `experienceforever.bar` 값, `experienceforever-global.fragment.<fhd|qhd|uhd>.lua`, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(고른 수단·값, 높이를 맞춘 방법, 위치 결정과 이유, 미니맵 단추 제안, 세 겉보기 게임 갈무리 — 막대 셋이 다 보이는 것(사냥꾼이 없으면 둘)과 전투 중 하나, 남은 문제).
- 기준: `appearance-2.md` 4절 + `appearance-2-layouts.md` 4절 + UHD 에서 막대가 긴 윗줄·검은 띠 범위 안 + 행동단축바 버튼 가림 0 + Experience Forever 파일 수정 0 + 3절 기능 설정 변경 0 + `ExperienceForeverDB` 직접 쓰기 0 + 게임 기본 경험치 막대 손댐 0 + 전투 중 차단·Lua 오류 0.

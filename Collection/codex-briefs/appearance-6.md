# Codex 외관 발주문 — Phase 6 (기본 unit·직업 자원 · Forever Unit Frames 0.65.2)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/6/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49`) + FUF 원본 `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`. Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.

## 1. 만들 것

- 내 프레임·대상·대상의 대상·소환수·주시·파티·우두머리 프레임의 자리·크기·막대 질감·글꼴·테두리·초상화. 자리는 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md`)의 중앙 묶음 둘레에서 Codex 가 정한다.
- 연계 점·토템 아이콘·드루이드 마나 띠·소환수 만족도 아이콘의 자리·크기·색(켜고 끄기는 바꾸지 않는다 — 2절 끝).
- FUF 자체 스킨 수단이 먼저다: 설정 `theme`(12개: CLASSIC·WOOD·TECH·PARCHMENT·RUNESTONE·GLASS·COMIC·FROST·PIXEL·SWISS·CONSOLE·PITWALL — `Core/Settings.lua` 의 `Settings.THEMES`, 겉모습은 `Libs/LibForeverThemes` 와 `Core/Themes.lua`), 그리고 프로필의 외관 설정(`barTexture`·`fontFace`·`fontSize`·`fontOutline`·`borderStyle`·`borderSize`·`borderColor`·`backgroundColor`·`cornerRadius`·`shadow*`·`width`·`height`·`x`·`y`·`portraitMode` 등, 키와 범위는 `Core/Settings.lua`, FUF 기본 모습은 `Core/Preset.lua`). 모자란 부분만 Skin 폴더에서 그린다. FUF 는 `/fuf unlock` 으로 프레임을 끌어 옮기는 자체 이동 손잡이가 있다.

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음 · ForeverUnitFrames 항목)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `fuf.player` `fuf.target` `fuf.pet` `fuf.focus` | `ForeverUnitFrames_player` / `_target` / `_pet` / `_focus` | position · size |
| `fuf.targettarget` `fuf.boss1` | `ForeverUnitFrames_targettarget` / `_boss1`(우두머리 1–5 한 줄의 첫째 — 자리는 줄 전체) | position |
| `fuf.party` | `ForeverUnitFramesParty`(파티 머리 프레임) | position · size(구성원 하나) |
| `fuf.targettargettarget` `fuf.pettarget` `fuf.focustarget` `fuf.boss2`–`boss5` `fuf.raid` | 같은 꼴 이름 · `ForeverUnitFramesRaid` | 없음 |

프레임은 FUF 가 PLAYER_LOGIN 때 만든다(`Units/Single.lua` `Single.Create`, `Units/Party.lua` 의 머리 프레임). 크기 편집 범위는 등록 표에서 8–600 하나로 묶였다(FUF 자체 범위: 너비 40–600, 높이 8–200). Grid2 가 켜지면 FUF 공격대 프레임은 캐릭터마다 꺼진다(`DevilForever_FUFDefaults`) — 공격대 외관은 Grid2 를 끈 경우만 쓰인다. 파티 프레임은 늘 FUF 것이다.

## 3. 값을 어디에 두나

- FUF 는 설정을 계정 공용 프로필 표 `ForeverUnitFramesDB.profiles.<이름>` 에 기본값과 다른 값만 두고, 저장할 때마다 그 표를 통째로 다시 쓴다(`Core/UnitProfiles.lua` `Write`, `Core/Storage.lua` `Save`). 그래서 외관 코드가 이 표를 직접 쓰거나 프레임에 `SetPoint`·`SetSize` 를 직접 걸지 않는다(FUF 가 자기 값으로 되돌린다).
- FUF 설정으로 되는 값은 **값 제안 파일** `fuf-profile.fragment.lua`(Lua 표 하나, `{general = {...}, player = {...}, target = {...}, …}` 꼴, FUF 키 이름·범위 그대로, 색은 `{r, g, b, a}`)로 낸다. 이 값을 FUF 에 넣는 길(FUF `/fuf set` 은 색을 받지 않는다 — `Core/Commands.lua:28`)은 Claude 쪽이 따로 정한다.
- 기능 설정은 바꾸지 않는다: 각 프레임 `enabled`·`powerEnabled`·`healPrediction`·`rangeFade`·`buffsEnabled`·`debuffsEnabled`·`comboPoints`·`totemsEnabled`·`druidMana`·`petHappiness`·`fsrEnabled`, 공격대 `enabled`. 시전바(`castbarEnabled` 등)는 Phase 7 몫이라 이번에 손대지 않는다.

## 4. 올릴 것 (`References/codex-appearance/6/`)

- 새 폴더 `AddOns/DevilForever_Skin_ForeverUnitFrames/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, ForeverUnitFrames`) — FUF 설정에 없는 부분만, `fuf-profile.fragment.lua`, 고른 FUF `theme` 한 줄, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(고른 값, 4K 게임 화면 갈무리 경로, 직업 자원 표시를 본 직업, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + FUF 파일 수정 0 + 3절의 기능 설정 변경 0 + `ForeverUnitFramesDB` 직접 쓰기 0.

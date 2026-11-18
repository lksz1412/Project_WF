# Codex 외관 발주문 — Phase 6-rev (기본 unit·직업 자원 두 번째 판 · PitBull4 v4.2.50-forever.1)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로이고, 겉보기는 FHD·QHD·UHD 셋을 처음부터 만든다(`appearance-2-layouts.md`, R107 ⑥). 게임 입력을 자동으로 보내는 도구는 쓰지 않는다. FUF 판 외관(`appearance-6.md`)과 따로 만든다 — 어느 판을 기본으로 묶을지는 Phase 23 에서 정한다.

- 결과를 올릴 자리: `References/codex-appearance/6-rev/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef`, 안의 `PitBull4/` 가 우리가 고친 PitBull4). Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다. 볼 때는 FUF 묶음(`ForeverUnitFrames`·`DevilForever_FUFDefaults`·`DevilForever_Castbars`)을 끈다.
- 출발점: V42 Devil profile 「Wide」 의 외관 값 — `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/!DevilUI/Profile/PitBull4.lua` 의 `profiles.Wide` 와 `namespaces.<모듈>.profiles.Wide`. 기능 값은 이미 `Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua` 에 들어갔고, 나머지(아래 1절의 종류, 164곳)가 외관 몫이다. 그 값은 옛 화면용이라 그대로 쓰지 않고 세 겉보기 크기 순서(R21·R22)로 다시 정한다.

## 1. 만들 것

- 내 프레임·대상·대상의 대상·대상의 대상의 대상·주시·주시 대상의 대상·소환수 프레임과 파티·파티원 대상·파티원 소환수 묶음의 자리(`anchor`·`relative_point`·`relative_to`·`position_x/y`)·`scale`·크기 배수(`size_x/size_y`)·묶음 간격(`vertical_spacing`·`horizontal_spacing`·`direction`). 자리는 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md`)의 중앙 묶음 둘레에서 Codex 가 정한다.
- 배치(layout) 넷의 겉보기: `대상`(대상) · `보통`(플레이어) · `파티`(파티, 주시 대상, 소환수) · `대상의대상`(대상의 대상 둘, 주시 대상의 대상 둘, 소환수의 대상, 파티원 대상·소환수). **배치는 여러 프레임이 함께 쓴다** — 배치 값(`size_x`·`size_y`·`bar_texture`·`bar_padding`·`bar_spacing`·`indicator_*`·`level`·`strata`·`font`·`font_size`)을 바꾸면 그 배치를 쓰는 프레임이 모두 바뀐다. 프레임 하나만 다르게 할 때는 그 unit 의 크기 배수·`scale` 을 쓴다.
- 모듈 겉보기(namespace 별, 배치마다): 체력·자원·드루이드 마나 막대의 `size`·`position`·`texture`·`background_alpha`, 테두리(`Border`: 질감·색·크기), 배경(`Background`), 초상화(`Portrait`: 켜기·`style`·`side`·`fallback_style` — Devil 은 대상·보통·파티 배치에서 켬; 초상화 켜고 끄기는 FUF 의 `portraitMode` 처럼 외관 몫), 연계 점·소환수 만족도·전투·휴식·파티장·공격대 징표·PvP·위상 아이콘의 `attach_to`·`location`·`position`·`size`, 오라의 크기(`layout.buff/debuff` 의 `size`·`my_size`·`width*`·`offset_*`·`growth`·`anchor`·`row_spacing`·`frame_level`)·남은 시간 표시(`cooldown`·`cooldown_text`·`texts`)·강조 모양, LuaTexts 글자의 `location`·`position`·`size`·`font`, 자원 색(`profile.colors.power`).
- PitBull4 자체 겉보기 수단이 먼저다: 배치 편집기(`/pb` → 배치 편집기), LibSharedMedia 질감·글꼴 이름, 테두리 질감. Devil profile 이 쓴 이름 중 막대 질감 `Glamour7`, 테두리 `Devil`, 글꼴 `데미지 글꼴`·`굵은 글꼴` 은 `!DevilUI` 미디어가 등록하던 것이라 이 모음집에 없다 — 토큰(`texture.statusbar`·`font.number` 등)으로 바꾸거나 Skin 폴더에서 LibSharedMedia 에 등록한다(R52).
- Forever 디버프 경로의 제약(V42 고침, `Collection/AddOns/PitBull4/Modules/Aura/Forever.lua`): 디버프 필터가 「없음」 인 배치는 디버프를 블리자드 `CustomAuraContainer` 가 그린다 — 그 경로에서는 남은 시간 색이 고정 색이고 Masque·오라 강조가 쓰이지 않으며 기본 테두리·글꼴을 쓴다. 위치·너비·성장 방향·내 것/다른 사람 것 크기·글자 설정은 반영된다.

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음 · PitBull4 항목)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `pb4.player` `pb4.target` `pb4.targettarget` `pb4.focus` `pb4.pet` | `PitBull4_Frames_플레이어` / `_대상` / `_대상의 대상` / `_주시 대상` / `_플레이어의 소환수` | position |
| `pb4.party` | `PitBull4_Groups_파티`(파티 머리 프레임) | position |
| `pb4.targettargettarget` `pb4.focustarget` `pb4.partytarget` `pb4.partypet` | `PitBull4_Frames_대상의 대상의 대상` / `_주시 대상의 대상` · `PitBull4_Groups_파티원 대상` / `_파티원 소환수` | 없음 |

프레임 이름은 우리 기본값이 넣은 한국어 unit 이름으로 정해지고 클라이언트 언어와 상관없다. 프레임은 PitBull4 가 로드·프로필 바꿈 때 만든다(`UnitFrame.lua` `MakeSingletonFrame`, `GroupHeader.lua` 머리 프레임). 크기는 배치 값이라 편집 항목에 넣지 않았다 — 값 제안 파일로 낸다(3절). 공격대 프레임은 Grid2(Phase 9)라 PitBull4 에 없다. 우두머리 프레임은 블리자드 기본 것이 남는다.

## 3. 값을 어디에 두나

- PitBull4 는 설정을 `PitBull4DB`(AceDB-3.0, 공용 프로필 `Default`, 모듈은 `PitBull4DB.namespaces.<모듈>.profiles.Default`)에 두고 자리·크기를 DB 값으로 다시 건다. 그래서 외관 코드는 `PitBull4DB` 를 직접 쓰거나 프레임에 `SetPoint`·`SetSize`·`SetScale` 을 직접 걸지 않는다(PitBull4 가 자기 값으로 되돌린다). unit 버튼은 보호 프레임이라 전투 중 자리를 바꿀 수 없다.
- 값은 **겉보기마다 값 제안 파일** `pitbull4-profile.<fhd|qhd|uhd>.fragment.lua` 로 낸다: Lua 표 하나 `{profile = {units = {...}, groups = {...}, layouts = {...}, colors = {...}}, namespaces = {<모듈 id> = {global = {...}, layouts = {<배치> = {...}}}}}` 꼴, PitBull4 키 이름·범위 그대로, 색은 `{r, g, b, a}`. 이 값을 PitBull4 에 넣는 길(겉보기 preset 층·Phase 20 되돌리기)은 Claude 쪽이 정한다.
- 기능 값은 바꾸지 않는다(`Defaults/PitBull4.lua` 가 정한 것): unit·묶음의 `enabled`·`unit`·`unit_group`·`layout`·`exists`, 배치의 `exists`, `made_units`·`made_groups`, 모듈의 `global.enabled`, 배치별 모듈 `enabled`(초상화 제외), 오라의 `max_buffs`·`max_debuffs`·필터·`highlight`·`enabled_weapons`, LuaTexts 의 `code`·`events`·`attach_to`·`exists`·`enabled`·`first`, `HideBlizzard` 값, `lock_movement`·`frame_snap`·`minimap_icon.hide`. 시전바(CastBar 모듈)는 꺼 두었다 — 시전바 외관은 Quartz(Phase 7).

## 4. 올릴 것 (`References/codex-appearance/6-rev/`)

- 필요할 때만 새 폴더 `AddOns/DevilForever_Skin_PitBull4/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, PitBull4`) — PitBull4 설정으로 안 되는 부분만(예: 질감·글꼴의 LibSharedMedia 등록), 겉보기별 값 제안 파일 셋, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(고른 값, 겉보기별 게임 화면 갈무리 경로, 직업 자원 표시를 본 직업, FUF 판 외관과 견준 한 줄, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + `Collection/AddOns/PitBull4/` 파일 수정 0 + 3절의 기능 값 변경 0 + `PitBull4DB` 직접 쓰기 0.

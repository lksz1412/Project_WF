# Codex 외관 발주문 — Phase 8 (직업 전투보조 · Hekili v0.8.6-forever + 게임 기본 Cooldown Manager)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로이고, 세 겉보기(FHD·QHD·UHD)는 `Collection/codex-briefs/appearance-2-layouts.md` 를 따른다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/8/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `12845c356942b655ef9a56e86aa7a00e088e8a7a8a61a6a10078a7e77de8b06d`) + Hekili 원본 `References/forever-addons/Hekili/Hekili-v0.8.6-forever.zip`(sha256 `8063fd78c988af76c6a74653c21ff9f268546c44320922688ea2f7dd3d4c45e3`). Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.
- 담당 나눔(R104): Hekili 는 **다음 행동 추천만**(맨 위 가운데 Primary 표시창 + 추천 능력의 단축바 버튼 빛남). 상태 알림·쿨다운은 **게임 기본 Cooldown Manager** 가 보인다. 새 알림 제품은 붙이지 않는다.

## 1. 만들 것

- Hekili 표시창의 자리·아이콘 크기·테두리·글꼴(단축키·쿨다운 숫자)·확대(zoom)와 단축바 빛남 색(`barGlow.colorNow`·`colorNext`). 평소 보이는 것은 Primary 하나다(AOE 는 dual/reactive 모드, Cooldowns·Defensives·Interrupts 는 그 토글을 「따로」 로 켰을 때만 — 자리만 정해 둔다).
- Cooldown Manager 창 넷의 자리·아이콘/막대 모양·글꼴·테두리. 자리는 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md`)의 중앙 묶음 둘레에서 정하되 중앙 시야와 Quartz 시전바·FUF 프레임·Dominos 바를 가리지 않게 한다.
- 수단: Hekili 는 Masque 그룹 「Hekili」(`Hekili/UI/UI.lua:1403–1408`, Onyx 스킨을 그대로 쓸 수 있다)와 Hekili 설정 값, 필요하면 공개 표시 style API `Hekili:RegisterDisplayStyle`(`Hekili/UI/Styles.lua:41–58`). Hekili 크기 값은 화면 물리 픽셀 단위다(`Hekili:GetScale()` = 물리 1픽셀, `UI.lua:51–53`) — 세 겉보기마다 따로 정한다.

## 2. 프레임 이름

| key | 전역 프레임 | 편집 항목 | 등록 |
|---|---|---|---|
| `hekili.primary` | `HekiliDisplayPrimary` (버튼 `Hekili_Primary_B<n>`) | position · size(10–500) | `registry_extra.json` Hekili 항목에 넣음 |
| `hekili.aoe` `hekili.cooldowns` `hekili.defensives` `hekili.interrupts` | `HekiliDisplayAOE` / `…Cooldowns` / `…Defensives` / `…Interrupts` | position | 같음 |
| `hekili.notification` | `HekiliNotification` (화면 가운데 글 — 일시정지·토글 알림만) | position | 같음 |
| (Codex 가 key 를 정함) | `EssentialCooldownViewer` · `UtilityCooldownViewer` · `BuffIconCooldownViewer` · `BuffBarCooldownViewer` | Codex 제안 | 게임 프레임이라 우리 등록 표에 애드온 항목이 없다 — Codex 의 Skin 폴더 조각(`registry_extra.fragment.json`)에 그 폴더 이름으로 넣는다 |

## 3. 값을 어디에 두나 · 지킬 것

- Hekili 설정은 AceDB 저장 변수 `HekiliDB` 의 공유 프로필 「Default」 에 있다(`Hekili/Options/Profile.lua:20`). 표시창 값은 `displays.<Primary|AOE|…>` 아래 `x`·`y`(화면 위 가운데 기준)·`numIcons`·`frameStrata`, 그림 값은 `displays.<id>.classic.*`(`primaryWidth`·`primaryHeight`·`zoom`·`queue.*`·`border`·`glow`·글꼴 칸 — `Hekili/UI/Styles/Classic.lua:67–92`), 알림 글은 `notifications.*`, 빛남 색은 `barGlow.colorNow`·`colorNext`.
- 외관 코드가 `HekiliDB` 를 직접 쓰거나 Hekili 프레임에 `SetPoint`·`SetSize` 를 걸지 않는다(Hekili 가 다시 그리면 되돌아간다). Hekili 설정으로 되는 값은 **값 제안 파일** `hekili-profile.fragment.lua`(`{profile = {...}}`, Hekili 키 그대로, 겉보기마다 하나: `fhd`·`qhd`·`uhd`)로 낸다 — Claude 가 Core 기본값 주입(채워지지 않은 키만)으로 넣는다.
- 기능 설정은 바꾸지 않는다: `enabled`, `displays.*.enabled`, `toggles.*`(단축키·`value`·`separate`·`mode`), `barGlow.enabled`·`follow`·`combatOnly`, `specs`·`packs`, `notifications.enabled`.
- Cooldown Manager: 창을 숨기지 않는다(`Hide`·`SetShown(false)`·숨긴 부모로 옮기기 금지) — Hekili 가 창마다 `IsVisible` 과 자식 아이템을 읽어 전투 상태를 맞추고, 숨긴 창은 읽기를 멈춘다(`Hekili/Game/State/Sources/Presence/CooldownViewer.lua:6–12, 46, 478`). 아이템 프레임의 `cooldownID`·`layoutIndex` 를 바꾸지 않는다. 자리는 게임 편집 모드(Edit Mode)로 정할 수 있으면 그 길을 쓰고 값을 보고서에 적는다 — 코드로 옮겨야 하면 전투 밖에서만 하고 `ADDON_ACTION_BLOCKED` 가 없는지 본다. CVar(`cooldownViewerEnabled` 등)는 코드에서 쓰지 않는다. 무엇을 보일지(특성별 주문 고르기)는 게임의 Cooldown Settings 몫이라 건드리지 않는다.

## 4. 올릴 것 (`References/codex-appearance/8/`)

- `AddOns/DevilForever_Skin_Hekili/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, Hekili`) — Masque·style 쪽 코드와 Hekili 설정에 없는 부분만.
- `AddOns/DevilForever_Skin_CooldownManager/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core` — 게임 기능이라 애드온 의존이 없다. 이름이 다르면 보고서에 적는다).
- `hekili-profile.fragment.lua`(겉보기 셋), `registry_extra.fragment.json`(Cooldown Manager 창 key·편집 항목), `assets.md`, `report.md`(고른 값, 세 겉보기 갈무리 경로 — 전투 중 Hekili 추천·단축바 빛남·Cooldown Manager 넷이 함께 보이는 장면, 겹침 처리, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + Hekili 파일 수정 0 + 3절 기능 설정 변경 0 + `HekiliDB` 직접 쓰기 0 + Cooldown Manager 창 숨김·CVar 쓰기 0.

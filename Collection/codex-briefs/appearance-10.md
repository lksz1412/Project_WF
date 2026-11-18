# Codex 외관 발주문 — Phase 10 (데미지 미터·어그로 미터 · Details! 20261109 + Tiny Threat)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/10/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49` — `!DevilForever_Core`) + Details 원본 `References/forever-addons/Details/Details-Details.20261109.15410.172.zip`(`Details`·`Details_TinyThreat`). Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.
- 처음 한 번 설정(캐릭터마다 · 손으로): 모음집은 Details 기본값을 넣지 않으므로 창 2 는 사람이 만든다. 대화창에 `/details new`(`Details/functions/slash.lua:50–51`)로 창 2 를 열고, 창 2 제목 줄의 모드 단추에 마우스를 올려 「플러그인」(Plugins) → 하위 메뉴 「Tiny Threat」 를 누른다(`Details/frames/window_main.lua:5416–5431`). `/run local w=Details:GetInstance(2); print(w:GetMode(), w.current_raid_plugin)` 가 `4 DETAILS_PLUGIN_TINY_THREAT` 이면 된 것이다. 그 뒤로는 Details 가 이 창을 저장·복원한다. 외관 작업 전에 이 설정을 해 두고, 보고서에 한 줄로 적는다.

## 1. 만들 것

- 창 1(데미지)·창 2(위협, Tiny Threat)의 자리·크기, 제목 줄·막대 질감·글꼴·줄 높이·테두리·배경. 자리는 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md`)에서 Codex 가 정하되 **세 번째 대화창 자리를 차지하지 않고**(R33) 중앙 시야를 가리지 않는다. 두 창을 붙일지(Details 창 묶기) 떼어 둘지도 Codex 가 정한다. 위협은 게임 기본 이름표의 위협 색(Phase 14)과 같은 정보를 두 번 크게 보이지 않게 창 2 를 작게 둘 수 있다 — 판단과 이유를 보고서에 적는다.
- Details 자체 외관 수단이 먼저다: 스킨 등록 `Details:InstallSkin(name, table)`(`Details/functions/skins.lua:8`, 기본 스킨 「Minimalistic」 316)과 창마다 `instance:ChangeSkin(name)`(`frames/window_main.lua:6624`), LibSharedMedia-3.0 질감·글꼴 이름, Details 옵션 창의 창별 값(줄 `row_info`·제목 줄·배경 — `classes/include_instance.lua:255` 이후). 어느 수단을 쓸지 Codex 가 정해 보고서에 적는다.

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음 · Details 항목)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `details.damage` | `DetailsBaseFrame1` | position · size(7–480) |
| `details.threat` | `DetailsBaseFrame2` | position · size(7–480) |

창 바탕은 `DetailsBaseFrame<번호>`(`frames/window_main.lua:2629`), 창 2 는 위의 「처음 한 번 설정」 으로 사람이 연다. Tiny Threat 의 그림은 플러그인 프레임 `Details_TinyThreat`(`Details_TinyThreat/Details_TinyThreat.lua:28`)이 창 2 안쪽 왼쪽 위에 붙어 그린다(`Details/core/plugins_raid.lua:201`) — 줄 높이·글꼴은 창 2 의 줄 설정을 따른다. 크기 범위는 Details 의 창 크기 한계(너비 150–480, 높이 7–450 — `frames/window_main.lua:2822`, `functions/profiles.lua:867`)를 하나로 묶은 것이라 너비 150 미만·높이 450 초과는 Details 가 막는다.

## 3. 값을 어디에 두나

- Details 설정은 Details 자체 형식이다(AceDB 아님): 창 모양은 계정 저장 변수 `_detalhes_global.__profiles[<캐릭터>-<서버>].instances[<창 번호>]`, 캐릭터마다의 창 상태는 `_detalhes_database`. Details 는 로그아웃 때 두 변수를 자기 메모리 값으로 다시 쓴다(`Details/core/parser.lua:6965–6969`, `functions/savedata.lua:132–144`, `functions/profiles.lua:483–530`) — 그래서 외관 코드가 저장 변수를 직접 쓰면 남지 않는다. 창 자리·크기도 Details 가 프로필에 저장한다.
- 외관 코드가 `_detalhes_global`·`_detalhes_database` 를 직접 쓰거나 Details 창에 `SetPoint`·`SetSize` 를 직접 걸지 않는다. 스킨 등록으로 되는 값은 새 폴더 안의 스킨 표로, 창별 값(자리·크기·줄 설정)은 **값 제안 파일** `details-instances.fragment.lua`(Lua 표 하나, `{[1] = {...}, [2] = {...}}` 꼴, Details 창 키 이름 그대로)로 낸다 — 넣는 길(Details 자체 함수 호출 또는 프로필 가져오기 `Details:ImportProfile`, `functions/profiles.lua:2056`)은 Claude 가 정한다.
- 기능 설정은 바꾸지 않는다: 창 1 의 표시(데미지 → 준 피해, `atributo = 1`·`sub_atributo = 1`)와 값·정렬, 창 2 의 모드(플러그인 모드 4)와 플러그인(`DETAILS_PLUGIN_TINY_THREAT`), Tiny Threat 의 위협 계산 설정(`plugin_database.DETAILS_PLUGIN_TINY_THREAT`), 대화창 탭 넣기(`chat_tab_embed.enabled = false`).

## 4. 올릴 것 (`References/codex-appearance/10/`)

- 새 폴더 `AddOns/DevilForever_Skin_Details/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, Details`) — 스킨 등록과 Details 설정에 없는 부분만, `details-instances.fragment.lua`, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(고른 수단·스킨 이름·값, 4K 게임 화면 갈무리 경로 — 전투 중 창 둘이 보이는 것 하나, 세 대화창과 함께 보이는 것 하나, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + Details·Tiny Threat 파일 수정 0 + 3절의 기능 설정 변경 0 + Details 저장 변수 직접 쓰기 0 + 세 번째 대화창 자리 겹침 0.

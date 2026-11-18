# Codex 외관 발주문 — Phase 2 (공통 외관)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 아래 「지켜야 할 약속」 만 지키면 나머지는 Codex 판단이다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/2/` (저장소). `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반 코드: `Collection/AddOns/!DevilForever_Core/`(설치 ZIP `outputs/collection/DevilForever-collection.zip`, sha256 `d726a254197affceb9c8f3da892c97efb12ed76127d14ae988f000759a8e4846`). 공개 함수는 `API.lua` 맨 위 주석 한 곳에 있다.

## 1. 만들 것

- 패널·구분선·검은 가로 띠·양끝 장식·글꼴·배치. 기준은 Step 5 설계 `Codex/docs/devil-ui-old-4k-layout.md` 와 `Codex/results/old-devil-layout/`(`layout-spec.json` 의 `tokens`·`elements`·`actionGroups`, `proposed-geometry.json`, `asset-manifest.json`). 요점: 3840×2160, 버튼 외곽 80px(아이콘 64·여백 8·간격 2), 낮은 구획 304px, 상태띠 28px, 바닥 여백 8px, 검은 띠 16px, 대화창 3개(960·960·938)·중앙 8×3 구획 670·사각 미니맵 304, 긴 윗줄 2950×80, 양끝 장식 256×256(demon 왼쪽·angel 오른쪽), 공유 이음새 2px.
- 시각 기준은 인벤 idx45 의 네 번째 샘플(R34). 대화창 3개는 반투명 배경(R23), 제목바·왼쪽 버튼더미·튀어나온 입력 테두리 없는 깔끔한 채팅(R24). 기본 대화창의 수신·송신·분류·입력은 그대로 두고 외관만 바꾼다(위 설계 문서 「기본 채팅과 외형 담당의 역할을 나눈다」).
- 크기는 4K 에서 버튼 크기 → 줄·간격 → 아래부터 쌓은 높이 순서로 정하고 화면 비율로 환산하지 않는다(R21·R22). 실제 UI scale 은 Phase 1 실사용 검증 결과(`References/codex-verify/phase1/`)를 본다.
- 장식·패널은 마우스 입력을 막지 않는다(입력 통과).
- 질감이 실제 게임 배율에서 구리면 더 나은 질감으로 바꿔도 된다(R52). 바꾼 이유를 보고서에 한 줄로 적는다.
- 새 폴더 이름은 `DevilForever_` 로 시작한다(기본 제안 `DevilForever_Appearance` — 다른 이름을 쓰면 보고서에 적는다). TOC 는 `## Interface: 16001` 과 `## Dependencies: !DevilForever_Core`. bash 에서 이 경로를 다룰 때는 `!` 때문에 작은따옴표로 감싼다(예: `ls 'Collection/AddOns/!DevilForever_Core'`).

## 2. 지켜야 할 약속 (Claude 가 정적 대조하는 것)

1. **값은 토큰으로만**: 색·질감 경로·글꼴·두께·간격은 코드에 박지 않고 테마 토큰으로 읽는다. 토큰 값은 우리 폴더 Lua 에서 `DevilForever_Core.Theme:RegisterSet("devil", { ... })` 로 로드 때 한 번 넣는다(이름 없는 키·종류가 틀린 값은 버려지고 Core 상태 기록에 남는다). 토큰 이름 20개(`Theme.lua` 의 `Theme.TOKENS`):
   `color.panel.background` `color.panel.border` `color.divider` `color.accent` `color.text.normal` `color.text.highlight` `color.text.disabled` (색 `{r, g, b, a}` 0–1) · `texture.panel` `texture.divider` `texture.ornament.left` `texture.ornament.right` `texture.statusbar` (경로) · `font.normal` `font.header` `font.number` (경로) · `font.size.small` `font.size.normal` `font.size.header` `border.size` (크기) · `spacing.default` (수). 토큰이 모자라면 새 이름을 보고서에 제안한다(Core 에 추가하는 것은 Claude 몫).
2. **읽는 함수**: `DevilForever_Core.Theme:Get(token)`, 프레임별 값은 `DevilForever_Core.Edit:Get(frameKey)` — 토큰 위에 사용자 편집값(position·size·font·color·rows·spacing)을 덮은 결과다. 외관 코드는 이 결과를 화면에 건다. 바뀜은 `Theme:RegisterCallback(owner, fn(new, old))`·`Edit:RegisterCallback(owner, fn(frameKey, field, value))` 로 받는다. 처음 적용은 PLAYER_LOGIN 에서 `Get` 으로 읽어 한다(저장된 테마 세트가 그때 되살아난다).
3. **전투 중 보호 프레임 금지**: Core 콜백은 전투 중 오지 않는다. 우리 코드도 `InCombatLockdown()` 이 참이면 보호된 프레임(행동단축바·unit 버튼 등)의 위치·크기·표시를 바꾸지 않고 `PLAYER_REGEN_ENABLED` 뒤에 한다.
4. **프레임 이름은 등록으로**: 외관을 받는 프레임은 다른 애드온을 고치지 않고 `registry_extra.json` 의 `frames` 칸으로 알린다. 우리 폴더 몫을 보고서와 함께 조각 파일로 낸다: `{"addons": {"<우리 폴더>": {"frames": [{"key": "appearance.chat1", "frame": "<전역 프레임 이름>", "tokens": {"color": "color.text.normal"}}], "editable": [{"frame": "appearance.chat1", "field": "rows", "min": 1, "max": 40}]}}}`. `key` 는 `Edit:Get` 에 쓰는 이름, `editable` 은 사용자가 바꿀 수 있는 항목(Phase 21 편집 창이 읽는다).
5. **다른 애드온은 고치지 않는다**: 시작 애드온·`!DevilForever_Core` 의 파일을 수정하지 않는다. 대화창은 기본 API·공개 스킨 API 로만 다룬다.
6. **V42 초기화 코드는 가져오지 않는다**: V42 `!DevilUI/!DevilUI.lua` 1174–1184(채팅 메시지 그룹·채널을 지우고 다시 넣는 부분), 1643–1644(`useUiScale`·`uiScale` 강제), `!DevilUI/minimap.lua` 815–838(채팅창 그룹·이름·잠금 재설정과 추가 창 구성). 채팅 필터·채널 분담과 UI scale 은 건드리지 않는다.

## 3. 올릴 것 (`References/codex-appearance/2/`)

- `AddOns/<우리 폴더>/` 코드 전부(TOC·Lua·자산).
- 자산 목록 `assets.md`: 파일마다 출처·라이선스 메모. Onyx 는 `License.txt:1–15` 의 개인 사용 허용·재배포 제한을 적고, 권리가 확인 안 된 Devil 자산·글꼴은 「미확인」 으로 적는다(`asset-manifest.json` 의 `licenseBoundary`).
- `registry_extra.fragment.json`(위 2-4).
- 보고서 `report.md`(짧게): 고른 토큰 값 표(토큰 이름 → 값), 바꾼 질감과 이유(R52), 실제 게임에서 본 해상도·UI scale·화면 갈무리 경로, 남은 문제.

## 4. 받아들이는 기준 (Claude 정적 대조)

`python3 -I Collection/tools/luacheck.py` 실패 0, `python3 -I Collection/tools/tocdeps.py` 미해결 의존 0, 색·경로·글꼴 값이 토큰 등록 한 곳에만 있고 나머지는 `Theme:Get`·`Edit:Get` 로 읽음, 전투 중 보호 프레임 변경 없음(`InCombatLockdown` 가드), 다른 애드온 파일 수정 0, V42 초기화 코드 없음. 실사용(로드·전투·화면)은 Phase 2 실사용 검증 발주문 `Collection/codex-briefs/phase2.md` 와 함께 본다.

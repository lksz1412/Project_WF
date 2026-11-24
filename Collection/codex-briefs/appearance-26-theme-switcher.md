# Codex 외관 발주문 — Phase 26 (상태띠 테마 넘김 이미지)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 이미지를 만들고 코드에 반영하는 일은 Codex 가 하고, Claude 는 이 기획만 쓴다(R131). 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 기반: Codex 브랜치 `codex/live-015-pitbull-20261124`(head `d8b63f59`). 테마 넘김은 G77-75·G77-76 으로 이미 들어가 있다 — 상태띠 오른쪽 끝에 「◀ 테마 이름 ▶」, 옛 라디오 주파수 다이얼·가로 룰렛 같은 넘김(`Codex/results/REQUEST_LEDGER_phase31.1.md:84–85`). 코드는 `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua`(106줄).
- 바꾸는 것: 이름 글자와 두 화살표의 겉보기만. 사용자 요청 — 「영문 필기체」 를 이미지로 만들어 전환하고, 화살표도 멋들어진 이미지로(R131). 상태띠 배경은 그대로 두고 화살표와 테마 이름은 금색 필기체 느낌(R130 ⑥).

## 1. 만들 것

**이름 이미지 13장 × 겉보기 3** — `Theme.lua:27–33` 의 CHOICES 순서·id 그대로, 영문 표기만 쓴다(한글판 클라이언트도 같은 영문 이미지): devil `Devil` · alliance `Alliance` · horde `Horde` · human `Human` · dwarf `Dwarf` · gnome `Gnome` · nightelf `Night Elf` · orc `Orc` · tauren `Tauren` · troll `Troll` · undead `Undead` · skyborne `Skyborne (Alliance)` · skyborne-horde `Skyborne (Horde)`.

**화살표 이미지 8장 × 겉보기 3** — 이전·다음 각각 normal · hover · pushed · disabled. hover 는 normal 위에 겹쳐도 홀로 완결된 그림(빛 번짐만 있는 조각이 아님), disabled 는 채도를 뺀 어두운 금색.

**글꼴·색**: 금색 영문 필기체(script). 서체 선택·획 장식·금속 질감은 Codex 판단이고, 고른 서체와 사용 허락 근거를 색인에 적는다. 배경 투명(알파 채널), 바깥 그림자·외곽선은 투명 영역 안에서만.

**크기** — 상태띠 프레임 배율이 물리 픽셀 단위라(`Skin.lua:132`) 아래 값이 곧 화면 픽셀이다. 자리 크기 계산식은 `ThemeSwitcher.lua:65–66`(이름 칸 = 글꼴 크기 × 12, 버튼 = max(띠 높이, 글꼴 크기 + 6)), 값은 각 preset `statusstrip.bar`(`Presets/<fhd|qhd|uhd>.lua:272`).

| 겉보기 | 띠 높이 | 글꼴 크기 | 이름 칸 | 화살표 버튼 | 이름 캔버스 | 화살표 캔버스 |
|---|---|---|---|---|---|---|
| fhd | 22 | 16 | 192×22 | 22×22 | 256×32 | 32×32 |
| qhd | 24 | 18 | 216×24 | 24×24 | 256×32 | 32×32 |
| uhd | 28 | 22 | 264×28 | 28×28 | 512×32 | 32×32 |

캔버스는 2의 거듭제곱(이미 실린 TGA 가 모두 그렇다 — Crests 256×256, divider 64×16, Composition top 2048×256). 그림은 캔버스 왼쪽 위에서 위 「이름 칸」·「화살표 버튼」 크기 안에만 그리고 나머지는 투명으로 둔다 — 코드가 SetTexCoord 로 그 영역만 쓴다. 이름이 길어도(`Skyborne (Alliance)`) 칸 안에 들어가야 하며 칸 밖으로 넘치거나 늘려 맞추지 않는다.

**형식·자리·이름**: 32bit 무압축 TGA(type 2, 알파 포함 — 기존 `DevilForever_Appearance` TGA 와 같은 형식). 자리는 `Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/<fhd|qhd|uhd>/`(새 폴더), 파일 `name_<theme id>.tga` · `arrow_<prev|next>_<normal|hover|pushed|disabled>.tga`. 상태띠 스킨 안에 두는 이유(Claude 판단): 이 이미지는 테마 토큰이 아니라 넘김 칸 전용이고, 쓰는 코드(`ThemeSwitcher.lua`)와 같은 애드온에 두면 `DevilForever_Appearance` 의 toc·`Crests.lua` 표를 건드리지 않는다.

## 2. 코드 반영 — `ThemeSwitcher.lua` 만 고친다

1. 이름 FontString(`:12`) 자리에 Texture 를 두고, 화살표 글자 ◀▶(`:27–32`) 대신 버튼 normal·highlight·pushed·disabled 텍스처를 건다. FontString 은 지우지 않고 대체용으로 남긴다.
2. 겉보기는 `Core.Presets:GetActive()` 로 고른다(같은 방식 = `DevilForever_Appearance/Composition.lua:68–69`). fhd·qhd·uhd 가 아니거나, 그 겉보기·테마의 파일이 코드 안 「실린 파일 표」 에 없으면 지금처럼 글자로 보인다(한글판이면 한글 이름 — `GetDisplayName`). 파일이 있는지 게임 안에서 찾지 않고 표로만 판정한다.
3. 텍스처 교체는 `apply()` 안에서만 — 테마 변경·preset 편집·로그인·전투 끝 때(`:96–106`). OnUpdate·타이머·매 프레임 일을 더하지 않는다(R117).
4. 넘김 동작 유지: 0.12초 가로 이동(`:15–18`, `:87–92`, ±8 픽셀)이 이름 이미지에도 그대로 걸리고, 이름 칸 바깥은 잘린다(`:10`).
5. 전투 중 거절 유지: `Theme:Cycle` 이 전투 중 false 를 돌려주면 안내 말풍선(`:34–48`). 버튼 크기·클릭 자리(`:71–76`)·좌클릭만(`:53`)·말풍선 문구는 바꾸지 않는다. disabled 그림은 고를 테마가 하나 이하일 때(`ListChoices` 가 1개 이하)만 쓴다.
6. 상태띠 배경, 다른 칸(`Skin.lua` 의 글자·구분선), `Theme.lua` 의 순서·순환은 고치지 않는다. 새 애드온을 만들지 않는다.

## 3. Codex 가 돌릴 확인

- 13 이름 × 3 겉보기 원배율 갈무리(줄이거나 늘리지 않음), 화살표 normal·hover·pushed·disabled 갈무리.
- 양방향 넘김 동작(이름이 칸 안에서 미끄러지고 칸 밖은 잘림), `/reload` 뒤 같은 테마·같은 이미지, 전투 중 클릭 거절과 말풍선, 파일 하나를 표에서 뺐을 때 글자 대체, 한글판 클라이언트에서 영문 이미지.
- 올릴 자리: `References/codex-appearance/26-theme-switcher/`(새 폴더) — 갈무리와 `index.md`(그림마다 파일·겉보기·테마·상태 한 줄, 실은 TGA 목록과 크기, 서체 근거, 고친 코드 줄, 못 한 확인).

## 4. Claude 가 나중에 하는 정적 확인

Codex 결과가 올라오면 Claude 가 TGA 39 + 24 개의 경로·이름이 표와 맞는지, 헤더 크기(위 표 캔버스)·type 2·32bit, 코드의 실린 파일 표와 실제 파일이 같은지, 글자 대체 분기와 매 프레임 일이 없는지를 본다. 게임 동작 검증은 아니다.

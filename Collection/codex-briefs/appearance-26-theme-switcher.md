# Codex 외관 발주문 — Phase 26 (상태띠 테마 넘김 이미지)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 이미지를 만들고 코드에 반영하는 일은 Codex 가 하고, Claude 는 이 기획만 쓴다(R131). 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 기반: Codex 브랜치 `codex/live-015-pitbull-20261124`(head `d8b63f59`). 테마 넘김은 G77-75·G77-76 으로 이미 들어가 있다 — 상태띠 오른쪽 끝에 「◀ 테마 이름 ▶」, 옛 라디오 주파수 다이얼·가로 룰렛 같은 넘김(`Codex/results/REQUEST_LEDGER_phase31.1.md:84–85`). 코드는 `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua`(106줄).
- 바꾸는 것: 이름 글자와 두 화살표의 겉보기만. 사용자 요청 — 「영문 필기체」 를 이미지로 만들어 전환하고, 화살표도 멋들어진 이미지로(R131). 상태띠 배경은 그대로 두고 화살표와 테마 이름은 금색 필기체 느낌(R130 ⑥).

## 1. 만들 것

**이름 이미지 13장 × 겉보기 3** — `Theme.lua:27–33` 의 CHOICES 순서·id 그대로, 영문 표기만 쓴다(한글판 클라이언트도 같은 영문 이미지): devil `Devil` · alliance `Alliance` · horde `Horde` · human `Human` · dwarf `Dwarf` · gnome `Gnome` · nightelf `Night Elf` · orc `Orc` · tauren `Tauren` · troll `Troll` · undead `Undead` · skyborne `Skyborne (Alliance)` · skyborne-horde `Skyborne (Horde)`.

**화살표 이미지 8장 × 겉보기 3** — 이전·다음 각각 normal · hover · pushed · disabled. 화살표는 테마마다가 아니라 겉보기마다 한 벌이다. hover 는 홀로 완결된 그림(빛 번짐만 있는 조각이 아님 — 2절 1), disabled 는 채도를 뺀 어두운 금색.

**색**: 금색 영문 필기체(script). 획 장식·금속 질감은 Codex 판단. 배경 투명(알파 채널), 바깥 그림자·외곽선은 투명 영역 안에서만.

**서체 (R132)** — 후보는 모두 SIL Open Font License 1.1(`Claude/results/handoffs/phase26/script-font-candidates.md:5–13`). 기본 Great Vibes, 대안 Allura · Alex Brush(굵은 획을 원할 때). 사용자가 다른 후보를 고르면 그것을 쓴다. 고른 서체의 `OFL.txt` 를 이미지 옆 `Media/ThemeSwitcher/LICENSE-OFL.txt` 로 이름을 바꿔 싣고(manifest 를 만드는 `Collection/tools/extract.py` 가 하위 폴더까지 `LICENSE_RE`(`:158`, `^(licen[cs]e|copying|unlicense)([._-].*)?$`)로 사용 허락 파일을 찾는데 `OFL.txt` 는 안 걸리고 `LICENSE-OFL.txt` 는 걸린다), TTF 파일은 싣지 않는다(이미지로만 쓴다). 서체 이름·판·저작권 줄을 색인에 적는다.

**크기** — 상태띠 프레임 배율이 물리 픽셀 단위라(`Skin.lua:132`) 아래 값이 곧 화면 픽셀이다. 자리 크기 계산식은 `ThemeSwitcher.lua:65–66`(이름 칸 = 글꼴 크기 × 12, 버튼 = max(띠 높이, 글꼴 크기 + 6)), 값은 각 preset `statusstrip.bar`(`Presets/<fhd|qhd|uhd>.lua:272`).

| 겉보기 | 띠 높이 | 글꼴 크기 | 이름 칸 | 화살표 버튼 | 이름 캔버스 | 화살표 캔버스 |
|---|---|---|---|---|---|---|
| fhd | 22 | 16 | 192×22 | 22×22 | 256×32 | 32×32 |
| qhd | 24 | 18 | 216×24 | 24×24 | 256×32 | 32×32 |
| uhd | 28 | 22 | 264×28 | 28×28 | 512×32 | 32×32 |

캔버스는 2의 거듭제곱(이미 실린 TGA 가 모두 그렇다 — Crests 256×256, divider 64×16, Composition top 2048×256). 그림은 캔버스 왼쪽 위에서 위 「이름 칸」·「화살표 버튼」 크기 안에만 그리고 나머지는 투명으로 둔다 — 코드가 SetTexCoord(0, 오른쪽, 0, 아래) 로 그 영역만 쓴다: 이름 fhd 192/256 × 22/32 = 0.75 × 0.6875 · qhd 216/256 × 24/32 = 0.84375 × 0.75 · uhd 264/512 × 28/32 = 0.515625 × 0.875, 화살표 fhd 22/32 = 0.6875 · qhd 24/32 = 0.75 · uhd 28/32 = 0.875(가로·세로 같음). 이름이 길어도(`Skyborne (Alliance)`) 칸 안에 들어가야 하며 칸 밖으로 넘치거나 늘려 맞추지 않는다.

**형식·자리·이름**: 32bit 무압축 TGA(type 2, 알파 포함 — 기존 `DevilForever_Appearance` TGA 와 같은 형식). 자리는 `Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/<fhd|qhd|uhd>/`(새 폴더), 파일 `name_<theme id>.tga` · `arrow_<prev|next>_<normal|hover|pushed|disabled>.tga`. 상태띠 스킨 안에 두는 이유(Claude 판단): 이 이미지는 테마 토큰이 아니라 넘김 칸 전용이고, 쓰는 코드(`ThemeSwitcher.lua`)와 같은 애드온에 두면 `DevilForever_Appearance` 의 toc·`Crests.lua` 표를 건드리지 않는다.

## 2. 코드 반영 — `ThemeSwitcher.lua` 만 고친다

1. 이름 FontString(`:12`) 옆에 Texture 를 두고, 화살표 글자 ◀▶(`:27–32`) 대신 버튼 텍스처를 건다 — 상태마다 텍스처 객체를 처음 한 번만 만들어 두고 다시 쓰며(apply() 마다 새로 만들지 않는다), `SetTexture` 결과를 보고(2 참고), 모두 성공한 뒤에 `SetNormalTexture(객체)` · `SetPushedTexture(객체)` · `SetDisabledTexture(객체)` · `SetHighlightTexture(객체, "BLEND")` 로 붙인다(경로를 바로 넘기면 실패를 알 수 없다). hover 를 BLEND 로 거는 이유: 버튼 highlight 의 기본 겹침은 더하기(ADD)라 완결된 금색 그림을 겹치면 하얗게 날아간다(Claude 판단 — 게임 안 확인은 3절). FontString 셋(이름 `:12`, 화살표 `:27–28`)은 지우지 않고 대체용으로 남기며, 이미지가 보이는 동안 숨긴다. 대체할 때는 이름 이미지를 숨기거나 버튼 텍스처를 비우고(normal·pushed·disabled·highlight 모두) 해당 FontString 을 다시 보인다.
2. 겉보기는 `Core.Presets:GetActive()` 로 고른다(같은 방식 = `DevilForever_Appearance/Composition.lua:68–69`). 다음 가운데 하나면 지금처럼 글자로 보인다(한글판이면 한글 이름 — `GetDisplayName`): 겉보기가 fhd·qhd·uhd 가 아님 · 사용자 편집으로 `statusstrip.bar` 의 띠 높이나 글꼴 크기(`:62–66`)가 1절 표의 그 겉보기 값과 다름(편집이 있으면 합성 그림을 버리는 `Composition.lua:73–76` 과 같은 생각) · 그 파일이 코드 안 「실린 파일 표」 에 없음 · `SetTexture` 가 false 를 돌려줌(`Composition.lua:131` 과 같음). 파일이 있는지는 표와 `SetTexture` 결과로만 판정한다. 이름은 테마마다, 화살표는 겉보기마다 판정한다 — 화살표 한 벌이 빠지면 그 겉보기 화살표 둘이 ◀▶ 글자로 돌아간다.
3. 텍스처 교체는 `apply()` 안에서만 — 테마 변경·preset 편집·로그인·전투 끝 때(`:96–106`). OnUpdate·타이머·매 프레임 일을 더하지 않는다(R117).
4. 넘김 동작 유지: 0.12초 가로 이동(`:15–18`, `:87–92`, ±8 픽셀)이 이미지와 글자에 함께 걸린다 — 둘을 담은 부모 하나에 애니메이션 묶음 하나, 또는 둘에 묶음 하나씩 두고 같이 시작. 이름 칸 바깥은 잘린다(`:10`).
5. 전투 중 거절 유지: `Theme:Cycle` 이 전투 중 false 를 돌려주면 안내 말풍선(`:34–48`). 버튼 크기·클릭 자리(`:71–76`)·좌클릭만(`:53`)·말풍선 문구는 바꾸지 않는다. disabled 그림은 고를 테마가 하나 이하일 때(`ListChoices` 가 1개 이하)만 — `apply()` 에서 `Button:Disable()`, 그 밖에는 `Button:Enable()`. 전투 중에는 화살표를 켜 둔 채 지금처럼 거절과 말풍선으로 알린다(전투 중 겉보기를 바꿀지는 사용자 질문이 열려 있어 이 기본값으로 둔다).
6. 상태띠 배경, 다른 칸(`Skin.lua` 의 글자·구분선), `Theme.lua` 의 순서·순환은 고치지 않는다. 새 애드온을 만들지 않는다.

## 3. Codex 가 돌릴 확인

- 13 이름 × 3 겉보기 원배율 갈무리(줄이거나 늘리지 않음), 화살표 normal·hover·pushed·disabled 갈무리.
- 양방향 넘김 동작(이름이 칸 안에서 미끄러지고 칸 밖은 잘림), `/reload` 뒤 같은 테마·같은 이미지, 전투 중 클릭 거절과 말풍선, 파일 하나를 표에서 뺐을 때와 띠 높이·글꼴 크기를 편집했을 때 글자 대체, hover 가 하얗게 날아가지 않음, 고를 테마가 하나일 때 disabled(시험용 설치에서 테마 하나만 등록되게 잠시 바꿔 확인하거나 시험 도구로 그 상태를 만든다 — 어느 쪽인지 Codex 가 정해 색인에 적는다), 한글판 클라이언트에서 영문 이미지.
- 올릴 자리: `References/codex-appearance/26-theme-switcher/`(새 폴더) — 갈무리와 `index.md`(그림마다 파일·겉보기·테마·상태 한 줄, 실은 TGA 목록과 크기, 서체와 사용 허락, 고친 코드 줄, 못 한 확인).

## 4. Claude 가 나중에 하는 정적 확인

Codex 결과가 올라오면 Claude 가 TGA 39 + 24 개의 경로·이름이 표와 맞는지, 헤더 크기(위 표 캔버스)·type 2·32bit, 코드의 실린 파일 표와 실제 파일이 같은지, 글자 대체 분기(겉보기·편집 크기·표·`SetTexture` 결과)와 매 프레임 일이 없는지, `LICENSE-OFL.txt` 가 있고 TTF 가 없는지를 본다. manifest 는 손으로 고치지 않는다 — 다음에 `extract.py` 로 다시 만든 `Collection/manifest.json` 의 상태띠 스킨 `license_files`(지금 빈 목록)에 `Media/ThemeSwitcher/LICENSE-OFL.txt` 가 들어갔는지 Claude 가 본다. 게임 동작 검증은 아니다.

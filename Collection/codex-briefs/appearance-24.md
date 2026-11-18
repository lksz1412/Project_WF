# Codex 외관 발주문 — Phase 24 (최종 목업)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 목업은 Codex 가 만든다(R87). 모든 가능한 작업을 닫은 뒤의 마지막 일이고(R55), Codex 일은 지금 보류라 작업이 끝난 뒤에 한다(R109). 목업은 게임을 띄워 찍는 것이 아니라 설계 좌표와 실제 외관 결과로 그리는 그림이다. 게임 검증이 아니다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/24/`. `Collection/` 은 고치지 않는다.
- 이 발주문을 쓴 때(2026-11-18) 저장소에는 `References/codex-appearance/` 폴더가 아직 없다 — 3절 입력 가운데 `References/codex-appearance/` 아래 것만 Codex 가 앞 외관 발주문으로 올릴 자리이고, Step 5 설계와 `Collection/` 의 파일은 이미 있다. 시작할 때 다시 본다(3절).

## 1. 만들 것 — 세 겉보기마다 (R107 ⑥)

겉보기 = `fhd` 1920×1080 · `qhd` 2560×1440 · `uhd` 3840×2160. 파일 이름은 `<겉보기>-<테마>-<종류>.png`(테마 기본 `devil`).

| 종류 | 파일 | 내용 |
|---|---|---|
| 전체 화면 | `<겉보기>-devil-full.png` | 그 해상도 그대로(줄이거나 늘리지 않음). 혼자 있는 상태의 기본 설치 화면 |
| 하단 원배율 | `<겉보기>-devil-bottom.png` | 화면 맨 아래부터 위 체력·마나 묶음 위 경계까지를 1:1 픽셀로 자른 것. UHD 는 y 1440–2160(3840×720, `Codex/docs/devil-ui-old-4k-layout.md:26–35`), FHD·QHD 는 그 겉보기 preset 의 같은 경계 |
| 단축키 확대 | `<겉보기>-devil-keys-x<배수>.png` | 중앙 8×3 묶음과 긴 윗줄 몇 칸의 단축키 글자. 정수 배수, 가장 가까운 픽셀 확대(부드럽게 하지 않음). 배수는 Codex 가 정하고 파일 이름과 색인에 적는다. 키 글자는 `Codex/results/old-devil-layout/text-metrics.json` 의 `checks` 에 있는 예시 키 16개(「C-S-1」·「1」·「A-1」 등, 글자는 `sampleGlyphs`)만 쓰고 키 이름을 지어내지 않는다 |
| 직업 자원 예시 | `<겉보기>-devil-class-<직업>.png` | unit 프레임 둘레를 잘라 4직업(2절 표) |
| unit 프레임 비교 | `<겉보기>-devil-unit-pitbull4.png` · `<겉보기>-devil-unit-fuf.png` | 같은 자리를 PitBull4 판과 FUF 판으로 한 장씩 |
| 테마 비교 | `<겉보기>-<대안 테마>-full.png` · `<겉보기>-<대안 테마>-bottom.png` | Phase 22 대안 테마마다(`References/codex-appearance/22/`). 없으면 그림을 만들지 않고 색인에 「대안 테마 없음」 |

## 2. 모든 그림에 걸리는 약속

1. **표시 문구**: 모든 그림에 「목업 — 실제 게임 화면 아님」 을 눈에 보이게 넣는다. 전체 화면은 Step 5 설계의 표시 자리(`Codex/results/old-devil-layout/layout-spec.json` 의 `proposal-label`, UHD x 24·y 20·500×40, 28px)에 이 문구를 쓰고, 잘라 낸 그림은 그 그림 안 모서리에 넣는다.
2. **게임 화면처럼 꾸미지 않는다**: 배경은 Step 5 의 조용한 중성 gradient(`layout-spec.json` 의 `world-context`, `notGameCapture`)다. 어떤 갈무리도 그림에 쓰지 않는다 — 게임 세계 갈무리뿐 아니라 `References/codex-appearance/*/` 보고서에 들어 있는 게임 갈무리도 잘라 붙이거나 밑그림으로 쓰지 않는다(`layout-spec.json` 의 `rendererContract.referenceScreenshotInRenderedScene` = false). 실제 캐릭터 이름·수치·대화·주문 그림·키 설정도 넣지 않는다. 아이콘·글자·막대 채움은 중립 자리표시(`layout-spec.json` 의 `rendererContract.placeholders`)다. 자원 수치는 예시 값이다.
3. **설계 좌표와 실제 결과만 쓴다**: FHD·QHD 자리는 세 겉보기 preset(`References/codex-appearance/2-layouts/layouts/<fhd|qhd|uhd>.lua`)에서 읽는다. UHD 자리는 `uhd.lua` 가 있으면 그 값, 없으면 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md:26–35, 45–56`, `proposed-geometry.json`)다. 둘이 다르면 preset 값을 쓰고 다른 자리를 색인에 적는다. 각 기능 외관 결과에서는 코드와 조각 파일(`*.fragment.*`·`layouts/*.lua`)에 적힌 자리·크기 값, 자산, 토큰 값만 읽는다 — 보고서의 갈무리는 읽지 않는다(2절 2). 색·질감·글꼴은 테마 토큰 세트 값(토큰 이름 20개 = `Collection/codex-briefs/appearance-2.md:20`)과 실제 자산만 쓴다. 없는 자산·글꼴을 다른 것으로 바꾸지 않는다(`Codex/docs/devil-ui-old-4k-layout.md:91`).
4. **대화창 3개**: 반투명 배경, 제목바·왼쪽 버튼더미·튀어나온 입력창 없는 깔끔한 모습(R23·R24). 자리는 `Collection/codex-briefs/appearance-4.md:10` 그대로다.
5. **셋째 대화창 = idx11218 미터기 자리**: 오른쪽 셋째 창(UHD `2902,1820` 938×304)은 대화창이다(R32·R33). Details 창은 그 자리에 두지 않는다(`Collection/codex-briefs/appearance-10.md:11`).
6. **아래부터 쌓기, 비율 환산 금지**(R21·R22): 바닥 여백 → 상태띠 → 낮은 구획 → 검은 띠 → 긴 윗줄 → 보조줄 → unit 묶음 순서다. UHD 값에 비율을 곱해 FHD·QHD 를 그리지 않는다 — 그 겉보기 preset 값을 쓴다(UHD 자리는 2절 3 대로).
7. **기본 설치 묶음만**: `Collection/install.json` 의 `own`·`upstream` 과 unit 프레임 기본판 `pitbull4`(`install.json:5`, `Collection/install/설치안내.md:28`)만 보인다 — Dominos·Prat·SexyMap·Quartz·Hekili(+게임 기본 Cooldown Manager)·Details+Tiny Threat·Experience Forever·상태 띠·PitBull4. 이 가운데 자리가 없는 구역은 3절 「입력이 없을 때」 대로 한다. Grid2 는 공격대일 때만 보이므로(`Collection/codex-briefs/appearance-9.md:10`) 전체 화면에 그리지 않는다. Aurora 는 설치 ZIP 에 없으니 그리지 않는다. FUF 는 1절의 비교 그림에만 쓴다(`References/codex-appearance/6/`). unit 프레임 기본판은 Phase 23 에서 임시로 PitBull4 로 정해 두었고(`Collection/install/설치안내.md:28`) Codex 비교 결과에 따라 바뀔 수 있다.

**직업 자원 예시** — 자원은 `Collection/data/classes.md` 표 그대로(지어내지 않음):

| 직업 | 보일 것 | 근거 |
|---|---|---|
| WARRIOR | Rage, 태세 3개(Dominos 태세 바) | `classes.md:25` |
| ROGUE | Energy, ComboPoints | `classes.md:28` |
| SHAMAN | Mana, 토템 4칸(Dominos 토템 바) | `classes.md:30` |
| DRUID (표범 형태) | Energy·ComboPoints, 변신 중 마나 띠 | `classes.md:33` |

자원 요소마다 읽는 결과가 다르다 — unit 프레임 안의 자원(Rage·Energy·Mana·ComboPoints·마나 띠)은 PitBull4 결과(`References/codex-appearance/6-rev/`), 태세 바·토템 바는 Dominos 결과(`References/codex-appearance/3/`)다. 요소마다 3절 「입력이 없을 때」 와 같은 규칙을 따른다: 결과가 있으면 그 결과대로 그리고, 결과는 없지만 Step 5 설계나 그 겉보기 preset 에 좌표가 있으면 그 좌표의 빈 테두리 + 「외관 미완 — 설계 좌표만」, 둘 다 없으면 그리지 않고 색인에 「자리 없음 — 못 그림」 으로 적는다. Step 5 설계는 태세·토템 바의 자리를 정하지 않았다(`Codex/docs/devil-ui-old-4k-layout.md:60`). 지어내지 않는다.

## 3. 입력 목록 — 시작할 때 있는지 본다

| 입력 | 자리 | 쓰는 곳 |
|---|---|---|
| Step 5 설계 | `Codex/docs/devil-ui-old-4k-layout.md`, `Codex/results/old-devil-layout/`(`layout-spec.json`·`proposed-geometry.json`·`asset-manifest.json`·`text-metrics.json`) | UHD 좌표·쌓기·자산·표시 자리 |
| 공통 외관 2 · 세 겉보기 2-layouts | `References/codex-appearance/2/`, `References/codex-appearance/2-layouts/` | `devil` 토큰 세트·패널·장식, 세 preset |
| 기능 외관 | `References/codex-appearance/<ID>/` — 3 Dominos · 4 Prat · 5 SexyMap · 6-rev PitBull4 · 7 Quartz · 8 Hekili·Cooldown Manager · 10 Details · 16 상태 띠 · 19 Experience Forever | 각 구역의 자리·스킨 |
| 비교용 | `References/codex-appearance/6/`(FUF), `References/codex-appearance/22/`(대안 테마) | unit 비교, 테마 비교 |
| 설치·직업 | `Collection/install.json`, `Collection/data/classes.md` | 보일 묶음, 자원 예시 |
| manifest·프레임 이름 | `Collection/manifest.json`·`Collection/manifest.md`, `Collection/AddOns/!DevilForever_Core/registry_extra.json` | 들어간 애드온과 그 판 확인, 구역마다 어느 프레임인지(등록 key → 전역 프레임 이름) 색인에 적기 |

- **입력이 없을 때**: 모습을 지어내지 않는다.
  - 외관 결과는 없지만 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md:26–35, 45–56`, `layout-spec.json` 의 `elements`)나 그 겉보기 preset 에 좌표가 있는 구역(대화창 3개·중앙 묶음·미니맵·긴 윗줄·보조줄·unit 묶음 둘·장식·검은 띠·상태띠)은 그 좌표의 빈 테두리로만 그리고 「외관 미완 — 설계 좌표만」 을 그 안에 쓴다.
  - 외관 결과도 좌표도 없는 구역(예: Quartz 시전바·Hekili·Cooldown Manager·Details·Experience Forever — Step 5 설계에도 그 겉보기 preset 에도 자리가 없으면)은 그리지 않고 상자도 짐작해 넣지 않는다. 색인에 「자리 없음 — 못 그림」 으로 적는다.
- `2-layouts` 가 없으면 FHD·QHD 는 설계 좌표 자체가 없다 — 그 겉보기 그림은 만들지 않고 색인에 「설계 좌표 없음 — 못 만듦」 으로 적는다. UHD 는 Step 5 좌표로 만든다.

## 4. 올릴 것 (`References/codex-appearance/24/`)

- 1절의 PNG 파일들.
- `mockup-index.md`: 그림마다 한 줄 — 파일 · 겉보기 · 테마 · unit 프레임 판 · 종류 · 쓴 입력(ID 와 파일) · 구역마다 프레임(등록 key → 전역 프레임 이름) · 「외관 미완」 구역 · 「자리 없음」 구역 · preset 과 Step 5 가 다른 자리(UHD) · 확대 배수 · 표시 문구 자리. 만들지 않은 그림(「대안 테마 없음」·「설계 좌표 없음 — 못 만듦」)도 그림마다 한 줄로 적는다. 끝에 없던 입력 목록과 남은 문제.

## 5. Claude 가 나중에 하는 확인 (알림용)

Codex 결과가 올라오면(R109) Claude 가 그림을 Step 5 구획(`Codex/docs/devil-ui-old-4k-layout.md:26–35, 45–56`)·세 preset 값·표시 문구와 대조하고, 색인과 그림이 맞는지 본 뒤 이 채팅에 보인다(R46). 이 대조는 게임 동작 검증이 아니다.

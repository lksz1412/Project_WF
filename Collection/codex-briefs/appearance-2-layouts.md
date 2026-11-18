# Codex 외관 발주문 덧붙임 — Phase 2 세 겉보기 (FHD · QHD · UHD)

받는 쪽: Codex. 보내는 쪽: Claude 세션. `Collection/codex-briefs/appearance-2.md` 에 덧붙인다 — 그 문서의 1–4절(만들 것·지켜야 할 약속·올릴 것·받아들이는 기준)은 그대로이고, 아래만 더한다. 근거: 사용자 결정 R107 ⑥ 「UI 는 유저가 AI 를 써서 수정하게 만들자. 대신 AI 로 처음부터 FHD, QHD, UHD 세가지 겉보기로 만들기로 하고, 그건 코덱스에 넘기기로 하자.」 통합 UI 편집기는 만들지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/2-layouts/`. `Collection/` 은 고치지 않는다.
- 이 덧붙임은 Phase 2 공통 외관과 **이미 낸·앞으로 낼 기능 외관 발주문 전부**(`appearance-3.md` … `appearance-8.md` 와 그 뒤)에 걸린다: 각 Skin 폴더의 값 제안 파일·편집값도 겉보기 셋으로 낸다.

## 1. 세 겉보기

| 이름 | 화면 | 기준 |
|---|---|---|
| `uhd` | 3840×2160 | Step 5 설계 그대로(`Codex/docs/devil-ui-old-4k-layout.md`, `Codex/results/old-devil-layout/`): 버튼 외곽 80px(아이콘 64·여백 8·간격 2), 낮은 구획 304px, 상태띠 28px, 바닥 여백 8px, 검은 띠 16px, 대화창 3개·중앙 8×3·사각 미니맵·긴 윗줄·양끝 장식 |
| `qhd` | 2560×1440 | 같은 순서로 그 해상도에서 따로 정함(2절) |
| `fhd` | 1920×1080 | 같은 순서로 그 해상도에서 따로 정함(2절) |

## 2. 크기를 정하는 순서 (R21·R22 — 세 겉보기 모두)

1. **버튼 크기부터**: 그 해상도·실제 UI scale(`References/codex-verify/phase1/` 결과)에서 아이콘과 단축키 글자를 함께 읽을 수 있는 버튼 외곽·아이콘·여백·간격을 먼저 정한다.
2. **줄·간격**: 그 버튼으로 중앙 8×3 묶음·긴 윗줄·보조줄의 폭·높이를 낸다(예: UHD `8×80+7×2=654`, `3×80+2×2=244`).
3. **아래부터 쌓은 높이**: 바닥 여백 → 상태띠 → 낮은 구획(대화창·미니맵·중앙 묶음 높이를 맞춤) → 검은 띠·긴 윗줄 → 위 unit 묶음 순서로 쌓아 각 높이를 낸다. 대화창·미니맵 폭은 남는 가로 폭에서 정한다.
4. **금지**: UHD 값에 화면 비율(0.5·0.667 등)을 곱해 FHD·QHD 를 만들지 않는다. 전체 화면에서 차지하는 비율은 다 정한 뒤 보고값으로만 적는다.
- Hekili 처럼 물리 픽셀로 크기를 받는 애드온 값(`appearance-8.md` 1절)은 UI 단위로 바꿔 적지 말고 그 해상도의 물리 픽셀로 정한다.

## 3. 값의 꼴 — Core 편집값·테마 토큰 약속으로

- 겉보기 하나 = **편집값 preset** 파일 하나: `layouts/<fhd|qhd|uhd>.lua` 가 Lua 표 하나를 낸다 — `{name = "uhd", screen = {3840, 2160}, uiScale = <쓴 값>, edits = {["<frame key>"] = {position = {...}, size = {...}, font = {...}, rows = n, spacing = n}}}`. field 이름·값 꼴은 `Collection/AddOns/!DevilForever_Core/Edit.lua` 머리 주석 그대로(position `{point, relativeTo, relativePoint, x, y}`, size `{width, height}`, font `{path, size, flags}`, color `{r, g, b, a}`, rows 정수, spacing 수), frame key 는 등록 표(`registry_extra.json` 과 각 Skin 폴더 조각)의 key, 값은 그 편집 항목의 min·max 안.
- 색·질감 경로·글꼴 경로처럼 해상도와 무관한 값은 테마 토큰 세트(`Theme:RegisterSet`) 하나에 두고 세 겉보기가 함께 쓴다. 해상도마다 달라야 하는 크기 토큰(`font.size.*`·`border.size`·`spacing.default`)은 preset 의 frame 별 값으로 덮는다. 그래도 토큰이 겉보기마다 달라야 하면 보고서에 제안한다(Core 변경은 Claude 몫).
- 기능 애드온 설정으로만 되는 값(예: Quartz·Hekili 프로필 값)은 그 Phase 의 값 제안 파일을 겉보기마다 하나씩 낸다(`<애드온>-profile.fragment.<fhd|qhd|uhd>.lua`).
- preset 을 고르고 적용하는 길(처음 로드 때 화면 크기로 고를지, 사용자가 고를지, 사용자 편집값 밑에 깔 층)은 Core 에 아직 없다 — Codex 는 데이터와 그 값을 읽어 거는 외관 코드만 내고, 고르는 방식은 보고서에 제안한다. Core 쪽 적용 층은 Claude 가 붙인다.
- 나중에 사용자는 AI 에게 말해 이 preset·편집값을 고친다(R107 ⑥). 그래서 preset 파일은 사람이 읽을 수 있게 frame key 별로 묶고, 값마다 무엇의 자리·크기인지 짧은 주석을 단다.

## 4. 올릴 것 · 받아들이는 기준

- `layouts/fhd.lua`·`layouts/qhd.lua`·`layouts/uhd.lua`, 겉보기별 값 제안 파일, `report.md`: 겉보기마다 표 하나(버튼 외곽·아이콘·여백·간격 → 줄 폭·높이 → 아래부터 쌓은 높이, 마지막 칸에 보고용 화면 비율), 실제 게임 갈무리(그 해상도로 띄울 수 있으면 셋 다 — 못 띄우면 `못 함` 과 이유), 남은 문제.
- 기준: `appearance-2.md` 4절 + preset 의 frame key 가 모두 등록된 key + 값이 등록 범위 안 + 보고 표에 계산 순서가 보이고 비율 곱하기가 없음 + 세 겉보기 모두 같은 코드로 적용(겉보기마다 코드 분기 없음).

# Codex 외관 발주문 — Phase 22 (대안 테마 1–2개)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 테마 설계·판단은 Codex 에 맡긴다(R51·R53·R87). 아래 「지켜야 할 약속」 만 지키면 나머지는 Codex 판단이다. `appearance-2.md` 2절(값은 토큰으로만·읽는 함수·전투 중 보호 프레임 금지·다른 애드온 고치지 않기)은 그대로 걸린다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/22/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반 코드: `Collection/AddOns/!DevilForever_Core/`(설치 ZIP `outputs/collection/DevilForever-collection.zip`, sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef`). 테마 부분은 `Theme.lua`, 공개 함수는 `API.lua` 맨 위 주석.

## 1. 만들 것

- 기본 테마 `devil` 옆에 고를 수 있는 완성 테마 1–2개. 테마 하나는 질감·글꼴·막대·장식이 한 컨셉으로 맞아야 한다 — 색만 바꾼 것은 테마로 치지 않는다(R53).
- 후보 「네온 보컬 스테이지」·「백자와 먹빛」 은 Codex 기록에 있던 제안이고 사용자가 고른 것이 아니다. 받을지, 바꿀지, 몇 개(1 또는 2)를 낼지 Codex 가 정한다.

## 2. 지켜야 할 약속 (Claude 가 정적 대조하는 것)

1. **테마 = 토큰 세트 하나**: `Theme.TOKENS` 의 이름 20개를 그대로 쓴다 — `color.panel.background` `color.panel.border` `color.divider` `color.accent` `color.text.normal` `color.text.highlight` `color.text.disabled`(색 `{r, g, b, a}` 0–1) · `texture.panel` `texture.divider` `texture.ornament.left` `texture.ornament.right` `texture.statusbar`(경로) · `font.normal` `font.header` `font.number`(경로) · `font.size.small` `font.size.normal` `font.size.header` `border.size`(크기) · `spacing.default`(수). 20개를 모두 채운다. 빠진 토큰은 `devil` 값으로 읽히고 Core 상태 기록에 `Theme:<이름>` 줄로 남는다.
2. **파일 꼴과 등록**: 공통 외관 폴더(`appearance-2.md` 의 기본 제안 `DevilForever_Appearance`) 안에 테마마다 `Themes/<이름>.lua` 한 파일. 그 파일은 로드 때 `DevilForever_Core.Theme:RegisterSet("<이름>", { ["color.accent"] = {...}, ... })` 를 한 번 부른다. 자산은 `Themes/<이름>/` 아래에 두고, TOC 에서 `devil` 세트를 넣는 파일 다음 줄에 적는다. 이름은 영어 소문자·숫자·밑줄만(빈칸이 있으면 Core 가 거절한다). `devil` 을 다시 등록하지 않는다.
3. **고르는 길**: 사용자는 `/dfp theme` 로 목록을 보고 `/dfp theme <이름>` 으로 바꾼다(바로 적용, 전투 중에는 거절). 고른 테마는 저장되어 `/reload`·재접속 뒤에도 남고, 설정 저장본(`/dfp save`)에도 들어간다. Codex 는 고르는 코드를 만들지 않는다.
4. **모든 스킨이 따라온다**: 공통 외관과 모든 `DevilForever_Skin_*` 폴더는 `Theme:RegisterCallback(owner, fn(new, old))` 를 받으면 `Theme:Get`·`Edit:Get` 을 다시 읽어 다시 건다. 콜백은 전투 중 오지 않는다. 보호된 프레임은 `InCombatLockdown()` 이 참이면 바꾸지 않고 `PLAYER_REGEN_ENABLED` 뒤에 한다. 테마 이름으로 코드를 나누지 않는다 — 모든 차이는 토큰 값에서 온다.
5. **세 겉보기 모두**: 테마마다 FHD·QHD·UHD 세 겉보기(R107 ⑥, `appearance-2-layouts.md`)에서 맞아야 한다. 층 순서는 테마 토큰 < 등록 표 기본값 < 지금 preset 값 < 사용자 편집값이다. 그래서 preset 이 그 프레임의 글꼴 크기·간격을 주면 테마의 `font.size.*`·`spacing.default` 는 가려진다(글꼴은 키마다 덮인다 — 경로는 테마, 크기는 preset). 테마마다 크기가 달라야 하면 보고서에 제안한다.
6. **토큰이 모자라면**: 컨셉에 필요한 값(예: 장식 크기, 막대 배경 질감)이 20개로 안 되면 새 토큰 이름·종류·쓰는 곳을 보고서에 제안한다. Core 에 넣는 것은 Claude 몫이다.

## 3. 올릴 것 (`References/codex-appearance/22/`)

- `AddOns/<공통 외관 폴더>/Themes/` 의 파일·자산과 바뀐 TOC.
- `assets.md`: 새 자산마다 출처·라이선스 메모(확인 안 된 것은 「미확인」).
- `report.md`: 테마마다 컨셉 한 문단, 토큰 값 표(이름 → 값), 테마 × 겉보기 갈무리(띄울 수 없는 해상도는 `못 함` 과 이유), 제안 토큰, 남은 문제.

## 4. 받아들이는 기준

`python3 -I Collection/tools/luacheck.py` 실패 0, `python3 -I Collection/tools/tocdeps.py` 미해결 의존 0, 테마마다 토큰 20개(상태 기록에 빠진 토큰 줄 없음), 색·경로·글꼴 값은 `RegisterSet` 한 곳에만, 스킨이 콜백으로 다시 거는지, 전투 가드, 다른 애드온·Core 파일 수정 0. 실사용은 `Collection/codex-briefs/phase22.md` 와 함께 본다.

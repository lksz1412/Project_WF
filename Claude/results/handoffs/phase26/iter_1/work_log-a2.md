# work_log — A2 writer · Phase 26 Step 46

산출: `Collection/codex-briefs/appearance-26-theme-switcher.md`(새 파일).

## 읽은 범위 (Codex 브랜치 `origin/codex/live-015-pitbull-20261124` = d8b63f59)
- `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua:1–106`(전문)
- `…/DevilForever_Skin_StatusStrip.toc:1–8`(전문), `…/Skin.lua:1–159`(전문)
- `Collection/AddOns/!DevilForever_Core/Theme.lua:1–80, 145–200`
- `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua:272`(statusstrip.bar 한 곳씩 · grep 수 1)
- `Collection/AddOns/!DevilForever_Core/Presets.lua:224–231`
- `Collection/AddOns/DevilForever_Appearance/` 파일 목록, `DevilForever_Appearance.toc:1–13`, `Crests.lua:1–17`, `Composition.lua:1–10, 68–69`
- TGA 헤더 5개(Crests/human 256×256, devil/divider 64×16, devil/left_cap 256×256, devil/Composition/fhd_top 2048×256, Media/line 8×8 — 모두 type 2·32bit)
- `Codex/results/REQUEST_LEDGER_phase31.1.md:84–85`(G77-75·76)
- 저장소: `Collection/codex-briefs/appearance-24.md:1–65`(전문), `appearance-22.md:1–12`

## 계산
이름 칸 = font.size×12, 버튼 = max(height, font.size+6) (`ThemeSwitcher.lua:65–66`)
fhd 22/16 → 192×22, 22 · qhd 24/18 → 216×24, 24 · uhd 28/22 → 264×28, 28.

## 내 판단(사용자 결정 아님)
- 자산 자리 = 상태띠 스킨 `Media/ThemeSwitcher/<preset>/`
- 2의 거듭제곱 캔버스 + 왼쪽 위 배치 + SetTexCoord
- 겉보기 선택 = `Core.Presets:GetActive()`, 실린 파일 표로 대체 판정
- disabled = ListChoices 1개 이하일 때만

## 게이트
- 금지어 grep(두 파일) rc=1
- 인용 경로 7개 Codex 브랜치에 있음(git cat-file ok) · 새 자리 2개(`…StatusStrip/Media/ThemeSwitcher/`, `References/codex-appearance/26-theme-switcher/`)는 없음 확인 → 새 산출로 표기
- 수치: 위 계산 = preset 272줄 값 · 줄 번호 인용은 ThemeSwitcher 원문 대조

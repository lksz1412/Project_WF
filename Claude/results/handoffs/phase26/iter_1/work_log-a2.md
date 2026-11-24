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

## fix 1 (검수 1 — 중간 3 · 경미 6, 처리 = TRIAGE_phase26.md:6–12)
읽음: `iter_1/audit_log.md:1–7`, `TRIAGE_phase26.md:1–12`, `script-font-candidates.md:1–15`(전문), Codex 브랜치 `Composition.lua:60–85, 125–135`, `Collection/manifest.json` 의 `license_files` 자리(grep — 상태띠 스킨 빈 목록).

영향 지도
| 곳 | 판정 | 이유 |
|---|---|---|
| 브리프 1절 화살표 줄 | 함께 고침 | m2 화살표 = 겉보기마다 한 벌, hover 는 2절 1 로 연결 |
| 브리프 1절 글꼴·색 줄 | 함께 고침 | M3 서체 단락 새로(R132 후보·기본 Great Vibes·OFL.txt·TTF 안 실음) |
| 브리프 1절 캔버스 줄 | 함께 고침 | m5 SetTexCoord 수치(0.75×0.6875 등) |
| 브리프 1절 크기 표 | 확인만 | M1 판정이 이 표 값을 기준으로 씀 — 값 그대로 |
| 브리프 2절 1 | 함께 고침 | M2 BLEND 와 이유, m3 FontString 숨김·다시 보임 |
| 브리프 2절 2 | 함께 고침 | M1 편집 크기 대체, m4 SetTexture false, m2 판정 단위 |
| 브리프 2절 3 | 영향 없음 | 교체 시점 그대로(apply 안) — Disable/Enable 도 apply 안 |
| 브리프 2절 4 | 함께 고침 | m6 이미지·글자 함께 이동 |
| 브리프 2절 5 | 함께 고침 | m1 Disable()/Enable(), 전투 중 기본값 |
| 브리프 2절 6 | 영향 없음 | 고치지 않는 범위 그대로 |
| 브리프 3절 확인·색인 | 함께 고침 | 새 대체 조건·hover·disabled 확인, 색인에 서체 사용 허락 |
| 브리프 4절 | 함께 고침 | 대체 분기 넷, OFL.txt·TTF 확인, manifest license_files 갱신 |
| 이 work_log 앞 절 | 영향 없음(기록) | 당시 기록 |

게이트: 금지어 grep(두 파일) rc=1 · 새 인용 경로 `script-font-candidates.md`(저장소), `Collection/manifest.json`(Codex 브랜치) 있음 · 수치 192/256=0.75, 22/32=0.6875, 216/256=0.84375, 24/32=0.75, 264/512=0.515625, 28/32=0.875 · 분량 47줄.

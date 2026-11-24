# Step 51 — 테마 넘김 그림·코드 (Claude 제작)

Phase 27 · 2026-11-24 20:19–20:40 +0900

[Phase 27 착수 — 마스터 플랜 재독] 마스터 플랜 본문 1–564 (Read 1–239, 240–409, 409–564), 2026-11-24 20:00 무렵 origin/main `c64dcd7c` 판으로 읽음. Step 51 착수 전 Phase 27 세부 계획서 1–26 다시 읽음.

## 수행
- 발주문 `Collection/codex-briefs/appearance-26-theme-switcher.md` 의 Codex 몫(그림 §1·코드 §2)을 Claude 가 했다(R152–R154). 작업 A(bada-a2-coder) → 검수 B(bada-a3-reviewer) 한 유닛.
- 만든 것: 그림 생성 도구 `Collection/tools/theme_switcher_art.py`(배포 안 함 · TTF sha256 확인 · 같은 입력이면 같은 바이트 · `--check`·`--preview`), TGA 63장 `Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/<fhd|qhd|uhd>/`, `LICENSE-OFL.txt`, 미리보기 `References/codex-appearance/26-theme-switcher/preview.png`·`index.md`.
- 고친 것: `ThemeSwitcher.lua`(106 → 236줄), 시험 `Collection/tests/statusstrip/theme_switcher.py`(+8 PASS 묶음), `extract.py` 로 다시 만든 `manifest.json`·`manifest.md`(상태띠 스킨 `license_files` 한 줄).

## 근거·판단
- 읽은 범위(master): 발주문 1–60(Phase 26 때 전문), 세부 계획서 1–26, 작업 A 반환 글, `ThemeSwitcher.lua:159–162`·`:228–231`(검수 인용 대조), 미리보기 PNG 육안(시각 판정). 작업 A 의 읽은 범위 = `Claude/results/handoffs/phase27/iter_1/work_log-51.md` 「읽은 범위」 절, 검수 B = `iter_1/audit_log-51.md` 「읽은 범위」.
- 서브 모델 확인: 작업 A 기록 `agentType bada-a2-coder`, 모든 assistant 행 `claude-opus-5-5` · effort medium.
- 영향 지도 요약 — 전 행은 work_log-51 「Impact map」 절:

| 곳 | 영향도 | 이유 |
|---|---|---|
| `ThemeSwitcher.lua` | 함께 고침 | 발주문 §2 |
| `Skin.lua`·`Theme.lua`·Presets | 확인만 | 값을 읽기만 함, 바꾸지 않음 |
| 시험 `theme_switcher.py` | 함께 고침 | 새 분기 고정 |
| `manifest.json/md` | 함께 고침(extract.py 재생성) | 사용 허락 파일 등록 |
| build.py·설치기·ReleaseCatalog | 확인만 | .tga·.txt 포함, 파일 수 필터 없음(검수 B 확인) |

- 정한 것: 화살표 = 갈매기꼴 + 마름모, hover = 35% 밝게 완결 그림, pushed = 18% 어둡고 1 px 아래, disabled = 채도 뺌(작업 A 판단). 화살표 글자 대체 때 `SetTexture(nil)`(작업 A 판단 — 게임 확인 항목).
- 검수 결과 중대·중간 0 → 고침 없이 유닛 끝. 경미 4 는 `TRIAGE_phase27.md` → 최종 보고.

## 변경·생성 파일
`Collection/tools/theme_switcher_art.py` · `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` · `…/Media/ThemeSwitcher/**`(63 TGA + LICENSE-OFL.txt) · `Collection/tests/statusstrip/theme_switcher.py` · `Collection/manifest.json` · `Collection/manifest.md` · `References/codex-appearance/26-theme-switcher/{preview.png,index.md}` · 기록 `Claude/results/handoffs/phase27/{brief-51.md,brief-51-review.md,SESSIONS.md,TRIAGE_phase27.md,iter_1/work_log-51.md,iter_1/audit_log-51.md}`.

## 게이트
work_log-51 「Commands」 판정 줄: art --check problems=0 · luacheck 2/0 · theme_switcher 15 PASS · statusstrip 20/20 · core 109/109 · extract errors=0 · genregistry up to date · patches verify 7/20/0(스크래치 래퍼 — `patches.py:140` os.devnull 이 Windows 에서 실패, 원래 있던 문제) · build --dry-run 2214 → 2278. 검수 B: 중대 0 · 중간 0 · 경미 4 · 서브 토큰 작업 A 382,551 / 검수 B 236,962(네 종류 나눔은 서브 기록에 있음) · 시간 21분.

## 다음
Step 52 — PitBull4판 빌드와 게임 폴더 설치(백업 먼저), 확인표.

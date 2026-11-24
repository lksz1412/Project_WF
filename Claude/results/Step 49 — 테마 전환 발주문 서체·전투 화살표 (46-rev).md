# Step 49 — 테마 전환 발주문 서체·전투 화살표 (Phase 26 · Step 46-rev)

## 수행
- R134(Claude 가 조사해 정함)·R135(추천대로, 글꼴 샘플 둘) 반영. 같은 A2 writer 가 `Collection/codex-briefs/appearance-26-theme-switcher.md` 를 고침(기본 서체 Allura · 대안 Alex Brush · 실측 표, 전투 중 화살표 SetAlpha 0.45, 게임 확인 목록 1항목). 같은 B 재확인 중대 0 · 중간 0 · 경미 2 → master 가 문구 두 곳 직접 고침.
- 샘플 `Claude/results/handoffs/phase26/font-sample-allura.png`, `font-sample-alexbrush.png` 를 사용자에게 보냄.
- Hekili 질문 조사: 모음집 판은 Forever 갈래판(TOC `Title: Hekili Forever`, `Author: defzach`). 원작(Hekili 저장소 thewarwithin `Events.lua`)은 UNIT_AURA 를 player·target(1513), UNIT_COMBAT 을 player(2026) 로만 등록하고 CLEU 를 받음(2016). Dominos 1~14 nil 미확인 루프는 원작에도 있음(2210-2213).

## 근거·판단
- 읽은 범위: 발주문 전문(A·B 보고), `ThemeSwitcher.lua` 28-106, `Theme.lua` 200-222, Hekili TOC 1-20, 원작 Events.lua 2206-2216 + grep, Forever 판 `Player.lua` 186-192.
- 서체 실측: PIL 12.3.0, 13 이름 맨 글자 getbbox 로 칸에 맞는 최대 크기·x 높이 (스크래치 `fonts.1795503924`).
- 영향 지도: 발주문 한 파일 — 함께 고침 = 줄 16–28·48·54 / 확인만 = 1절 크기 표·2절 1–4·6·3절 (B 확인) / 영향 없음(기록) = Step 46 이력·TRIAGE 앞 절.

## 변경·생성 파일
- `Collection/codex-briefs/appearance-26-theme-switcher.md`, 샘플 PNG 2장, `TRIAGE_phase26.md`, `REQUEST_LEDGER_phase26.md`(R134·R135), phase26 세부계획 Step 47 행(범위 확대).

## 게이트
- B 재확인 0/0, 금지어 grep rc=1(A 보고).

## 다음
- 사용자 서체 선택(기본 Allura). Step 47 GO 대기.

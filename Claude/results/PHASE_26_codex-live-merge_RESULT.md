# PHASE 26 — Codex 실게임판 합치기·테마 전환 그림·검토·고침 RESULT

## Summary
Codex 실게임 조정판(d8b63f59)을 작업 가지에 합치고, 검토만 요청(R133)으로 찾은 문제를 사용자 결정(R134–R146)대로 Step 47 에서 고쳐 0.1.5 두 판을 다시 만들었다. 테마 전환 그림은 Codex 발주문(서체 Allura·전투 중 화살표 흐림·서체 파일 동봉)으로 넘겼다.

## Step Range
Step 46, 47, 48, 49

## Inputs
origin/codex/live-015-pitbull-20261124 @d8b63f59 · 사용자 결정 R130–R147 (`REQUEST_LEDGER_phase26.md`)

## Files Created
`Collection/codex-briefs/appearance-26-theme-switcher.md` · `Collection/codex-briefs/assets/26-theme-switcher/`(Allura TTF·OFL) · `Collection/codex-briefs/phase26-step47-check.md` · `Collection/patches/Grid2.patch` · 검토·검수 기록 `Claude/results/handoffs/phase26/`

## Files Updated
Core(Party·Commands·Presets·V2·fhd·qhd·uhd·Defaults PitBull4/Grid2/Quartz) · Skin_Dominos · Grid2 2 · PitBull4 1 · Quartz 1 · 패치 2 · 시험 5 · extract.py · manifest · ReleaseCatalog.json · 설치안내.md · feature-map.md

## Read Coverage
각 Step 이력 「근거·판단」(Step 46·47·48·49) 과 handoffs/phase26 의 work_log·audit_log 읽은 범위 절. master 원문 대조 줄은 TRIAGE_phase26.md 각 절 머리.

## Execution Evidence
`Claude/results/handoffs/phase26/iter_1~3`(brief·work_log·audit_log) · `TRIAGE_phase26.md` · `SESSIONS.md`

## Validation·Gate·Confirmed
시험 13개 통과(core 109 · firststart 27 · …) · patches verify 7/20/0 · genregistry up to date · build 두 번 같은 해시 · ZIP PitBull4판 1a9516de… · fuf판 a50fe2d1… · catalog --check 일치 · Step 47 검수 중대·중간 2→1→0.

## Non-Changes
Hekili(R144 ⑥ 보류) · ThemeSwitcher.lua(Codex 몫) · References·Codex 기록.

## Open Issues
Hekili 단축키 오류·공격대 부담(보류) · detailslayout 시험의 커밋 안 된 참조 파일 · performance 시험이 HEAD 에서도 실패 · 게임 확인 전부 Codex.

## Decision Queue
Grid2 기본 자리를 화면 위 가운데로 둔 것(시선 이동·인원 따라 폭 변화) — 사용자 판단.

## Next Step
Codex 게임 확인·테마 그림 → 결과 반영 → R128 두 판 따로 올리기.

## Step Records
`Claude/results/Step 46 …`, `Step 47 — Codex 실게임판 합치기·파티 동시 운용·Quartz 사냥꾼·재빌드.md`, `Step 48 — 코드 검토 셋 (자체·수정, 원본, Quartz 스윙).md`, `Step 49 — 테마 전환 발주문 서체·전투 화살표 (46-rev).md`

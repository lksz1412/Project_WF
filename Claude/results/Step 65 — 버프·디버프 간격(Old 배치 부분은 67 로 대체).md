# Step 65 — 버프·디버프 간격(Old 배치 부분은 67 로 대체)

Phase 27 · 2026-11-25 ~ 2026-11-26 (끝 23:13 +0900)

## 수행
- R212·R214: Old 배치에서 버프를 각 창 위로 옮기는 코드를 만들었으나 R226(Old 폐기)로 그 부분은 Step 67 에서 지움. 남긴 것 = PitBull4 패치 `Modules/Aura/Layout.lua` 의 디버프 시작 위치(실제로 찬 버프 줄 + 간격 — uhd 46 px → 4 px). 데빌 샘플(`SourceArchive/2022-11-19/extracted/Interface/addons/!DevilUI/Profile/PitBull4.lua`)은 프로필마다 배치가 달라 New 규칙 유지.
- Combined review (same B, code ③ 3 rounds, brief `brief-6468-review.md`): critical 0 · medium 0 · minor 4. Commit `d3a8f50b` → stage `claude-p27-stage-9dcf9f2d` (25 folders · 2,054 files · clean · verified) → installed with the game closed, RC=0, backup `D:/Projects/Project_WF/_local_only/claude-p27-backup-fd219cb7`. Command lines: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` section of this step.

## 근거·판단
- 읽은 범위(master): 같은 작업 A 보고, 같은 검수 B 보고(묶음), 인용 대조는 해당 사용자 요청 처리 때(요청 대장 R212–R231 근거 칸).
- 영향 지도 전 행 = `iter_4/work_log-60.md` 「Step 65」 절. 경미 4건(소환수 막대 상수 전제 · 예전 두 창 Details 는 `/dfdetails apply` 필요 · ReleaseCatalog.json 에 Hekili 남음(게시 때 다시 씀) · 코덱스 방법 B 는 texcoord 먼저)은 최종 보고.

| 곳 | 영향도 | 이유 |
|---|---|---|
| 아래 변경 파일 | 함께 고침 | 이 스텝 요청 |
| 지난 Step 이력·Result | 영향 없음(기록) | 당시 기록 |

## 변경·생성 파일
`PitBull4/Modules/Aura/Layout.lua` · `patches/PitBull4.patch` · 시험 layoutv2

## 게이트
work_log 판정 줄(layoutv2 46 PASS · core 107 · firststart 29 · chatsetup 47 · statusstrip 20 · theme_switcher 17 · detailslayout 통과 · luacheck 0 · patches verify 0 실패 · build dry-run 25/2057 · 27/2001 · verify_archives rc=0). 설치 RC=0.

## 다음
사용자 게임 확인(확인표 §13–§15) · Musca Auras 다운로드 승인 · Details 자리 확인.

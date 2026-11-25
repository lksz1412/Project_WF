# Step 66 — 데빌 기준 구조·코덱스 전달서

Phase 27 · 2026-11-25 ~ 2026-11-26 (끝 23:13 +0900)

## 수행
- R216–R221·R225·R229: 데빌 배치를 기준으로 목표 구조를 코드에 고정 — 대화 칸 셋 같은 폭·2 px 이음, 테두리 6/8/12 px, 대화 글 칸·미니맵을 패널 안쪽에, 소환수·토템 막대 오른쪽 끝 = 플레이어 창 오른쪽 끝, 토템 시간은 막대 왼쪽, 대화 시간 표시 기본 끔. 코덱스 전달서 `Collection/codex-briefs/appearance-28-devil-structure.md`(13 테마 다시 그리기, 해상도별 숫자, 테마별 어긋남 표, 부품 방식 권장).
- Combined review (same B, code ③ 3 rounds, brief `brief-6468-review.md`): critical 0 · medium 0 · minor 4. Commit `d3a8f50b` → stage `claude-p27-stage-9dcf9f2d` (25 folders · 2,054 files · clean · verified) → installed with the game closed, RC=0, backup `D:/Projects/Project_WF/_local_only/claude-p27-backup-fd219cb7`. Command lines: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` section of this step.

## 근거·판단
- 읽은 범위(master): 같은 작업 A 보고, 같은 검수 B 보고(묶음), 인용 대조는 해당 사용자 요청 처리 때(요청 대장 R212–R231 근거 칸).
- 영향 지도 전 행 = `iter_4/work_log-60.md` 「Step 66」 절. 경미 4건(소환수 막대 상수 전제 · 예전 두 창 Details 는 `/dfdetails apply` 필요 · ReleaseCatalog.json 에 Hekili 남음(게시 때 다시 씀) · 코덱스 방법 B 는 texcoord 먼저)은 최종 보고.

| 곳 | 영향도 | 이유 |
|---|---|---|
| 아래 변경 파일 | 함께 고침 | 이 스텝 요청 |
| 지난 Step 이력·Result | 영향 없음(기록) | 당시 기록 |

## 변경·생성 파일
`Presets/{fhd,qhd,uhd,V2}.lua` · `Presets.lua` · `Defaults/SexyMap.lua` · `DevilForever_ChatSetup/Chattynator.lua` · `DevilForever_Appearance/Themes/horde.lua` · 코덱스 전달서 · 시험 · 확인표 §14 · 설치 안내

## 게이트
work_log 판정 줄(layoutv2 46 PASS · core 107 · firststart 29 · chatsetup 47 · statusstrip 20 · theme_switcher 17 · detailslayout 통과 · luacheck 0 · patches verify 0 실패 · build dry-run 25/2057 · 27/2001 · verify_archives rc=0). 설치 RC=0.

## 다음
사용자 게임 확인(확인표 §13–§15) · Musca Auras 다운로드 승인 · Details 자리 확인.

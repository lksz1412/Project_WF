# Step 64 — 헤키리 빼기(Musca Auras 는 다운로드 승인 대기)

Phase 27 · 2026-11-25 ~ 2026-11-26 (끝 23:13 +0900)

## 수행
- R208·R223: Hekili 를 설치 묶음에서 뺌(`install.json` `not_shipped`, build·extract·registry·Core TOC·프리셋·시험·문서). 게임 폴더 Hekili 11 폴더는 master 가 `_local_only/claude-p27-removed-hekili-e540a46b` 로 옮김. Musca Auras(1.21.0, CurseForge file 9801355, ~7.8 MB) 는 사용자 본인의 다운로드 승인이 없어 받지 않음 — 최종 보고에서 요청.
- Combined review (same B, code ③ 3 rounds, brief `brief-6468-review.md`): critical 0 · medium 0 · minor 4. Commit `d3a8f50b` → stage `claude-p27-stage-9dcf9f2d` (25 folders · 2,054 files · clean · verified) → installed with the game closed, RC=0, backup `D:/Projects/Project_WF/_local_only/claude-p27-backup-fd219cb7`. Command lines: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` section of this step.

## 근거·판단
- 읽은 범위(master): 같은 작업 A 보고, 같은 검수 B 보고(묶음), 인용 대조는 해당 사용자 요청 처리 때(요청 대장 R212–R231 근거 칸).
- 영향 지도 전 행 = `iter_4/work_log-60.md` 「Step 64」 절. 경미 4건(소환수 막대 상수 전제 · 예전 두 창 Details 는 `/dfdetails apply` 필요 · ReleaseCatalog.json 에 Hekili 남음(게시 때 다시 씀) · 코덱스 방법 B 는 texcoord 먼저)은 최종 보고.

| 곳 | 영향도 | 이유 |
|---|---|---|
| 아래 변경 파일 | 함께 고침 | 이 스텝 요청 |
| 지난 Step 이력·Result | 영향 없음(기록) | 당시 기록 |

## 변경·생성 파일
`install.json` · `tools/{build,extract}.py` · manifest · `!DevilForever_Core/{registry_extra.json,Registry.lua,.toc}` · 프리셋 · 시험 · 문서

## 게이트
work_log 판정 줄(layoutv2 46 PASS · core 107 · firststart 29 · chatsetup 47 · statusstrip 20 · theme_switcher 17 · detailslayout 통과 · luacheck 0 · patches verify 0 실패 · build dry-run 25/2057 · 27/2001 · verify_archives rc=0). 설치 RC=0.

## 다음
사용자 게임 확인(확인표 §13–§15) · Musca Auras 다운로드 승인 · Details 자리 확인.

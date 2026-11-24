# Step 58 — 사용자 확인 결함 고침 (1~4회차)

Phase 27 · 2026-11-25 06:19–07:13 +0900

## 수행
- 진단(읽기만, 같은 작업 A): D1 테마 넘김이 파일 적재 때 `SetText` 를 글꼴보다 먼저 불러 오류("Font not set")로 멈춤 · D2 하단 HUD 그림이 모든 해상도에서 옆으로 늘어남·맨 뒤층 · D3 Grid2 자리·칸 · D4 주시 대상 위치·오라 표 · D5 대상 소환수 사슬 없음. master 가 인용 줄 원문 대조(ThemeSwitcher.lua:77–82·:197, BugGrabber :15, V2.lua:100–112).
- 1회차(a2531127): 테마 넘김 오류 고침 · New/Old 버전 넘김(R159) · Grid2 = 퀘스트 목록 위 끝·왼쪽 끝(R159) · 정사각형 칸 · 주시 대상 = 내 캐릭터와 대상 사이 가운데(R159) · 세 창 오라 표 하나 · 대상 소환수 사슬 · 설치 도구 `-AllowRunningGame`. 설치(backup 767a1dcc). 검수 B: 중대 0·중간 1(확인표 x 측정식)·경미 5.
- 2회차(5389bbf9, R160): 버전 넘김이 실제 적용 배치를 보임(revision 표시) · New/Old 전환 때 Grid2 칸도 씀 · 토템 타이머를 내 캐릭터 창 위로 · 확인표 측정식. 설치(backup a48b4467). 검수 B 재검증: 중대·중간 0·경미 2.
- 3회차(HUD 그림 잘라 붙이기): 작업 A 가 손대기 전에 멈춤 — 그림이 테마마다 손그림 한 장이라 반복 조각 없음, 모든 해상도가 이미 늘어남. 사용자 결정 R162: 그림은 Codex, Claude 는 코드·위치 → Step 59.
- 4회차(87e617fd, R161): Grid2 정사각형 칸 두 배(88/116/176). 40인 창 겹침은 줄이지 않고 시험에 고정(사용자 판단 대기). 설치(backup 65cdb3bf, 게임 꺼짐 상태).

## 근거·판단
- 읽은 범위(master): diag-58.md 보고 글, ThemeSwitcher.lua 74–84·192–200, V2.lua 100–112, SexyMap.lua 205–214, BugGrabber 저장 파일 grep, 검수 보고 2건, 작업 A 반환 글(1~4회차·stage 3회), feedback_flow_interruption 전문(컴팩션 뒤).
- 영향 지도 전 행 = `iter_2/work_log-58.md` 「Round 1–4」 절. 요약:

| 곳 | 영향도 | 이유 |
|---|---|---|
| Presets/{fhd,qhd,uhd}.lua · V2.lua | 함께 고침 | Grid2·주시·오라·사슬·버전 |
| ThemeSwitcher.lua · theme_switcher_art.py · Media | 함께 고침 | 오류·버전 넘김 |
| Defaults/PitBull4.lua · Party.lua | 함께 고침 | 새 layout 이름·Grid2 자리 |
| install_local.ps1 | 함께 고침 | 게임 켠 채 설치 |
| 시험 3종 · 확인표 · 설치안내 | 함께 고침 | 기대값 |
| SexyMap.lua | 영향 없음 | 34b9125d 에서 이미 고침 |

- 4회차는 숫자 치환(① 치환): 시험 고정값과 layoutv2 겹침 고정으로 기계 대조, master 가 바뀐 값 3개 확인.
- 정한 것: 개발 중에는 New/Old 전환이 설정을 덮어씀(R162) · 버전 완료 때 버전별 저장으로 바꿈(뒷일).

## 변경·생성 파일
커밋 a2531127 · 5389bbf9 · 87e617fd (Collection 20 파일 남짓 + 시험) · 기록 brief-58-*.md, iter_2/*, TRIAGE, 요청 대장 R158–R162 · git 밖: stage 679e45f3·16cc495f·02eb8f3e, backup 767a1dcc·a48b4467·65cdb3bf.

## 게이트
매 회차 layoutv2 30 PASS · firststart 28→29/29 · core 109/109 · statusstrip 20/20 · theme_switcher rc=0 · luacheck 0 · genregistry · patches 7/20/0 · build dry-run 2284/2228 · 설치 RC=0 ×3. 검수 중대·중간 1→0. 사용자 확인: 테마 넘김·New 배치·Grid2 칸 반영 확인(R160–R161), 크기 피드백 반영.

## 다음
Step 59 — HUD 부품 조립 코드 + Codex 부품 규격서. 사용자 확인 남은 것: 두 배 Grid2 칸과 그 겹침, 확인표 2·3·4·5·7·8번.

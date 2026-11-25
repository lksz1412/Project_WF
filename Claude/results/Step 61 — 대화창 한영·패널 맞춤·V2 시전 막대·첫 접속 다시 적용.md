# Step 61 — 대화창 한영·패널 맞춤·V2 시전 막대·첫 접속 다시 적용

Phase 27 · 2026-11-25 20:20–20:59 +0900 (시작 = R169 받은 때)

## 수행
- 사용자 게임 확인(R169–R185)에서 나온 아홉 가지를 같은 작업 A(a64ebefa708243db9)가 한 변경으로 고쳤다: (a) 한영 전환 — Chattynator 입력창 배율이 1 이 아니면 한글 입력이 막힘(R172 사용자 시험으로 확정) → 배율 1, 높이·앵커·글꼴 크기를 배율값으로 계산 (b/c) 글 영역 = 테마 대화 패널 안쪽 사각형, 탭 줄은 그 위(R173 과 R175 가 동시에 안 맞아 R175 우선) (d) 전장 3종 2번 창 (e) 파티찾기 이름 채널 전부 3번 창 (f) PitBull4 내 캐릭터·대상 이름 글자 = 프리셋 크기 × 본 프레임 높이 / 소환수 프레임 높이 (g) V2 Quartz 내 캐릭터 막대를 내 캐릭터 아래 줄로, 주시 대상 오라는 소환수와 같은 규칙 (h) 떠 있던 막대 = 프리셋 CastBar 조각이 PitBull4 시전 막대를 켰던 것 → Old·New 모두 끔 (i) 설치 뒤 첫 접속에 쓰던 New/Old 프리셋을 판(revision)마다 한 번 다시 적용(V2 판 2→3, V1 판 1 신설, 모음집이 쓴 profile 만).
- 같은 검수 B(a5573f01b964966e2) code ③ 3라운드: 중대 0 · 중간 1 · 경미 2. M1(모음집이 쓴 적 없는 PitBull4 profile 도 Old 로 덮어씀) master 원문 확인(`Presets/V2.lua:195–222`) → 같은 A 고침(`dfLayoutV2` 가 boolean 일 때만) → 같은 B 재확인 중대·중간 0 · 경미 1.
- 커밋 `2f2513c1` → stage `claude-p27-stage-968fed33`(36 폴더 · 2,350 파일 · clean · verified) → 게임 꺼진 상태 설치 RC=0, 백업 `D:/Projects/Project_WF/_local_only/claude-p27-backup-608d134c`(AddOns + WTF).
- 사용자 질문 답: Codex C 드라이브 세션 채팅 논의(R164·R165), 파티찾기 2 채널 검색(R178 — 자동 넘김 근거 없음, Forever 사용자 채널은 내부 서버마다 따로라는 포럼 보고, master 원문 확인), 주시 대상 오라 위치(R180).

## 근거·판단
- 읽은 범위(master): A 보고 다섯 번, B 보고 두 번, 인용 대조 `Presets/V2.lua:95–165, 195–222`, `Defaults/PitBull4.lua:190–215`, `DevilForever_ChatSetup/Chattynator.lua` grep(파티찾기 판정), Chattynator `Display/Main.lua` SetScale grep, 블리자드 포럼 글 2370263 본문(Chrome), 사용자 화면 네 장(배치 확인용).
- 영향 지도 전 행·명령 판정 줄 = `iter_4/work_log-60.md` 「Step 61 fix」·「continued (items f-i)」·「Step 61 review fix (M1)」. 처리표 = `TRIAGE_phase27.md` 「Step 61 review」.

| 곳 | 영향도 | 이유 |
|---|---|---|
| Chattynator Display/Main.lua·Core/Fonts.lua·패치 | 함께 고침 | 입력창 배율 |
| ChatSetup/Chattynator.lua | 함께 고침 | 패널 맞춤·전장·파티찾기 |
| Presets fhd/qhd/uhd·V2.lua | 함께 고침 | 이름 크기·시전 막대·오라·다시 적용 |
| ThemeSwitcher New/Old 판정 | 확인만 | revision 3 고정 시험 갱신 |
| 지난 Step 이력·Result | 영향 없음(기록) | 당시 기록 |

- 정한 기본값(최종 보고): 탭 줄은 R175 우선(테마 띠 가운데에 못 맞춤 — 수치는 work_log) · 다시 적용은 Quartz 막대 자리·Grid2 칸도 그 판 값으로 되돌림(R162 개발 중 덮어쓰기) · 시스템 메시지 1번 창.

## 변경·생성 파일
`Collection/AddOns/Chattynator/{Display/Main.lua,Core/Fonts.lua}` · `Collection/patches/Chattynator.patch` · `DevilForever_ChatSetup/Chattynator.lua` · `!DevilForever_Core/Presets/{fhd,qhd,uhd,V2}.lua` · `Collection/tests/{chatsetup/run.py,layoutv2/run.py,statusstrip/theme_switcher.py}` · `Collection/codex-briefs/phase27-game-check.md` §6·§10·§11 · `Collection/install/설치안내.md` · 기록 `brief-61-review.md` · `TRIAGE_phase27.md` · `iter_4/diag-61.md` · `iter_4/work_log-60.md`. git 밖: stage·백업, 게임 AddOns 36 폴더.

## 게이트
work_log 판정 줄: chatsetup 43/43 · layoutv2 45 PASS · core 109/109 · firststart 29/29 · statusstrip 20/20 · pitbull4 6/6 · pitbull4runtime 20/20 · castbars 16/16 · luacheck failed=0 · extract errors=0 · genregistry up to date · patches 8/0 · build dry-run 36/2353 · 38/2297. 검수 C+M 1 → 0. 설치 RC=0. 서브 토큰(알림 누적값): A 860,272 → 334,323(컴팩션 뒤 새 셈) · B 721,686 → 731,548.

## 다음
사용자 게임 확인(확인표 §10·§11). 첫 접속에서 다시 적용 한 줄과 자동 /reload 한 번이 보여야 한다. 확인되지 않은 것: 타이머 콜백의 ReloadUI, 테마 그림 안쪽 테두리 두께.

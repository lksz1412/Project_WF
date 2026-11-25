# Step 62 — 대화창 자리·한영·첫 접속 예약·토템·이름 가운데

Phase 27 · 2026-11-25 21:00–21:29 +0900

## 수행
- 사용자 확인(R186–R198)에서 나온 여섯 가지를 같은 작업 A 가 진단 → 한 변경으로 고침: (c) 1번 창 영수증 없음(Chattynator 최소 크기 240×140 으로 커져 영수증 불일치) · 2·3번 창은 패널 사각형에 안쪽 여백 없이 놓여 화면 끝까지 → 탭 줄 가운데 = 테마 띠 가운데, 글 칸 좌우·아래 = 패널 안쪽(이음매 한 칸), 최소 크기는 위로 키움, 이미 만든 세 창도 한 번 다시 놓음(FIT_VERSION 2) (a) 접속 뒤 입력창 배율 0.99→1 한 번 (b) 타이머에서 부른 ReloadUI 가 실행되지 않음(저장 설정의 pending 근거) → 첫 접속은 예약만 하고 한 줄 안내(/dfp go), 버전 전환은 자기 종류 예약을 넘겨받아 막히지 않음, 판 V2 3→4 · V1 1→2 (d) 레벨·이름을 한 글자열로 가운데 (e) New 에서 Dominos 토템 막대를 플레이어 아래 가운데 (f) 플레이어 오라 올림 제거, PitBull4 토템 시간은 토템 막대 오른쪽(PitBull4 패치에 루트 표시 오프셋).
- 같은 검수 B code ③ 3라운드: 중대 0 · 중간 1 · 경미 2. M1(Old 프로필이 안내대로 버전 전환을 누르면 New 가 들어감) master 원문 확인 → 같은 A 가 안내·확인표를 /dfp go 만 쓰도록 고침 → 문구 수정이라 master 확인(`V2.lua:252`, 남은 문구 0).
- 커밋 `adf8004a` → stage `claude-p27-stage-2f30c961`(36 · 2,350 · clean · verified) → 게임 꺼진 상태 설치 RC=0, 백업 `D:/Projects/Project_WF/_local_only/claude-p27-backup-bbd878f0`.
- 사용자 질문 조사(R199–R204): 헤키리 토템·버프 표시 — 깊은 조사 서브(A1) 결과를 master 가 인용 원문 대조(`Hekili/Options/Options.lua:7858–7866`, 원본 커밋 a18bd35 메시지, 원본 298789ac69 `UI.lua:903–912`).

## 근거·판단
- 읽은 범위(master): A 보고 세 번, B 보고, 인용 대조 `ThemeSwitcher.lua:250–262`, `Presets/V2.lua:252`, 확인표 :70 · :115–116, 위 헤키리 원문.
- 영향 지도 전 행·수치·명령 판정 줄 = `iter_4/work_log-60.md` 「Step 62」·「Step 62 review fix (M1)」. 처리표 = `TRIAGE_phase27.md` 「Step 62 review」.

| 곳 | 영향도 | 이유 |
|---|---|---|
| ChatSetup/Chattynator.lua | 함께 고침 | 창 자리·한영 |
| Presets fhd/qhd/uhd·V2·Presets.lua | 함께 고침 | 이름·토템·오라·예약 |
| ThemeSwitcher.lua | 함께 고침 | 예약 넘겨받기 |
| PitBull4 UnitFrameLayout.lua·패치 | 함께 고침 | 루트 표시 오프셋 |
| Profiles.lua 요청 대기 | 확인만 | 거절 문구 그대로 |
| 지난 Step 이력 | 영향 없음(기록) | 당시 기록 |

- 정한 기본값(최종 보고): 첫 접속 덮어쓰기는 예약 + /dfp go 한 번(R185 의 「손 작업 없이」 를 다 채우지 못함 — 타이머 ReloadUI 불가 근거) · 이전 규칙에서 끌어 옮긴 창도 한 번 다시 놓임 · 패널 안쪽 여백 = 이음매 한 칸(dwarf·devil 그림 표본) · qhd UI 1.0 에서 탭 줄 최대 12 px 위.

## 변경·생성 파일
`DevilForever_ChatSetup/Chattynator.lua` · `!DevilForever_Core/Presets/{fhd,qhd,uhd,V2}.lua` · `!DevilForever_Core/Presets.lua` · `DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` · `PitBull4/UnitFrameLayout.lua` · `patches/PitBull4.patch` · 시험 `chatsetup` · `layoutv2` · `statusstrip/theme_switcher.py` · `codex-briefs/phase27-game-check.md` §6·§10–§12 · `install/설치안내.md` · 기록 `brief-62-review.md` · `TRIAGE_phase27.md` · `work_log-60.md`.

## 게이트
work_log 판정 줄: chatsetup 45/45 · layoutv2 45 PASS · theme_switcher 20 · core 109 · firststart 29 · statusstrip 20 · pitbull4 6 · pitbull4runtime 20 · castbars 16 · patches 4/4 · luacheck 0 실패 · patches verify 8/0 · extract 0 · genregistry · build dry-run 36/2353 · 38/2297. 검수 C+M 1 → 0. 설치 RC=0.

## 다음
사용자 게임 확인: 첫 접속 안내 줄 → `/dfp go` → 세 창 자리·탭·한영·토템·이름. 확인되지 않은 것: 한영 원리, 테마 그림 안쪽 테두리, Dominos 토템 버튼 실제 크기.

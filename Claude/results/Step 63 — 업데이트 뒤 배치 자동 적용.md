# Step 63 — 업데이트 뒤 배치 자동 적용

Phase 27 · 2026-11-25 21:50–21:47 +0900

## 수행
- R205("처음 설치한 사람한테 명령어를 치라고 한다고?"): 같은 작업 A 가 적용 기전을 먼저 코드로 찾음(work_log 「Step 63 … mechanism」 — 대기 요청은 Core 준비 단계에서, 조각은 각 대상 애드온 ADDON_LOADED 에서 Core 가 먼저 씀, 새 설치는 fresh 경로로 아무것도 필요 없음) → 모음집이 쓴 PitBull4 profile 의 배치 판이 낮으면 같은 접속에서 PitBull4·Quartz 에 쓰고, 이미 적재된 Dominos·Grid2 몫은 다음 접속에 저절로(`layoutRevision.due`), 명령·다시 불러오기 없음. 첫 접속 예약·/dfp go 안내 제거.
- 같은 검수 B code ③: 중대 0 · 중간 1(사이에 사용자가 고른 버전을 미룬 몫이 다음 접속에 덮어씀) → master 원문 확인(`Presets.lua:691–695,765`) → 같은 A 고침(사용자 요청이 오면 `due` 버림, :694) → 같은 B 재확인 중대·중간 0 · 경미 1.
- 커밋 `7c64e649` → stage `claude-p27-stage-4d8f225a`(36 · 2,350 · clean · verified) → 게임 꺼진 상태 설치 RC=0, 백업 `D:/Projects/Project_WF/_local_only/claude-p27-backup-22f11ec7`.

## 근거·판단
- 읽은 범위(master): A 보고 두 번, B 보고 두 번, `Presets.lua` due grep(:691–695,765).
- 영향 지도 전 행·명령 판정 줄 = `iter_4/work_log-60.md` 「Step 63」 세 절. 처리표 = `TRIAGE_phase27.md` 「Step 63 review」.

| 곳 | 영향도 | 이유 |
|---|---|---|
| Presets.lua 준비 단계·ADDON_LOADED | 함께 고침 | 자동 적용 |
| Presets/V2.lua 첫 접속 예약 | 함께 고침 | 제거 |
| 확인표 :70·:115–116·:126 · 설치 안내 | 함께 고침 | 명령 안내 제거 |
| ThemeSwitcher·Profiles 대기 요청 | 확인만 | 그대로 |

- 경미(최종 보고): 판정이 profiles.Default 만 봄 · Quartz 꺼짐이면 그 몫은 나중에 안 옴 · due 지우기가 캐릭터를 안 봄.

## 변경·생성 파일
`!DevilForever_Core/Presets.lua` · `Presets/V2.lua` · 시험 `layoutv2` · `statusstrip/theme_switcher.py` · 확인표 · 설치 안내 · 기록 `brief-63-review.md` · `TRIAGE_phase27.md` · `work_log-60.md`.

## 게이트
layoutv2 45 PASS · theme_switcher 20 · core 109 · firststart 29 · statusstrip 20 · chatsetup 45 · pitbull4 6 · pitbull4runtime 20 · castbars 16 · patches 4/4 · luacheck 0 실패 · build dry-run 36/2353 · 38/2297. 검수 C+M 1 → 0. 설치 RC=0.

## 다음
사용자 게임 확인(명령 없이 첫 접속에 PitBull4·Quartz, 다음 접속에 토템 막대·Grid2). Step 64 는 R209·R211 조사 뒤.

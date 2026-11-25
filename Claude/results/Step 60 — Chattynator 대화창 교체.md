# Step 60 — Chattynator 대화창 교체

Phase 27 · 2026-11-25 19:24–19:55 +0900

## 수행
- 사용자 결정: 새 채팅창 자체 개발은 하지 않고 Chattynator 237 을 고쳐 쓴다(R166·R167). 창 배정 = 1번 일반 대화·채널 1–3, 2번 귓속말·길드·배틀넷 귓속말·공격대·파티, 3번 파티 찾기 채널(있으면).
- 같은 작업 A(정의 bada-a2-coder, a64ebefa708243db9)가 `brief-60.md` 대로 만들었다: Chattynator 237 을 두 판 모두에 싣고(ZIP SHA-256 은 SOURCE.txt 와 같음), Devil Forever 스킨을 패치(`Collection/patches/Chattynator.patch`)로 넣고, `DevilForever_ChatSetup/Chattynator.lua` 가 손대지 않은 Chattynator profile 에 세 창을 한 번 채운다(메시지 저장 꺼짐, 파티 찾기 채널은 나중에 들어가도 3번 창으로). Chattynator 가 켜져 있으면 기본 대화창 스킨·배치는 쉰다.
- 같은 검수 B(정의 bada-a3-reviewer, a5573f01b964966e2) code ③ 3라운드: 중대 0 · 중간 1 · 경미 4. M1(이미 Chattynator 를 쓰던 profile 의 스킨이 바뀜)을 master 가 원문에서 확인 → 같은 A 가 한 번에 고침(스킨 기본값도 손대지 않은 profile 에만 + 문서·목록·Prat 역할) → 같은 B 재확인 중대·중간 0 · 경미 1.
- 커밋 `e4b74671` → stage `D:/Projects/Project_WF/_local_only/claude-p27-stage-125df0c0`(36 폴더 · 2,350 파일 · clean · verified) → 게임이 꺼진 상태에서 `install_local.ps1` 설치 RC=0, 백업 `D:/Projects/Project_WF/_local_only/claude-p27-backup-98788f31`.

## 근거·판단
- 읽은 범위(master): Codex 기록 두 세션(01a1e8f5 대화 전문 추출본 596–1738 · 01a1ec3b 255–491), `Codex/docs/forever-clean-chat-research.md` 1–116, `References/addon-survey/survey.md` 54–63, Chattynator 237 `Chattynator.toc` 1–70 · `Core/Initialize.lua` 1–256 · `Core/Messages.lua` 1–1493 · `Core/Overrides.lua` 1–251 · `Display/Main.lua` 1–310 · `Core/Constants.lua` 20–40 · `Skins/Main.lua` 20–76, `DevilForever_Skin_NativeChat/Skin.lua` 1–151, 게임 WTF `chat-cache.txt` 1–400(읽기만), 세부 계획서 1–28, 마스터 플랜 236 · 508–524, 검수 보고 두 번, A 보고 두 번, 인용 대조 `Skins/Main.lua:20–62` · `Skins/DevilForever.lua:186–196`.
- 작업 A 읽은 범위·영향 지도 전 행 = `Claude/results/handoffs/phase27/iter_4/work_log-60.md` 「Impact map」·「Review fix」. 검수 처리표 = `TRIAGE_phase27.md` 「Step 60 review」.

| 곳 | 영향도 | 이유 |
|---|---|---|
| Chattynator 폴더·패치·manifest·install.json·registry | 함께 고침 | 새로 싣는 애드온 |
| ChatSetup(세 창 seed)·ChatLayout·NativeChat 스킨 | 함께 고침 | 대화창 담당이 바뀜 |
| 설치안내.md·feature-map.md·verify_archives.py·extract.py(Prat 역할) | 함께 고침 | 실제로 싣는 것과 맞춤(검수 뒤) |
| V2.lua(New/Old 전환) | 확인만 | 대화창 항목 없음 |
| 지난 Step 이력·Result | 영향 없음(기록) | 당시 기록 |

- 정한 기본값(최종 보고에 싣는다): 시스템·전리품·돈·오류는 1번 창 · 길드 Discord 는 2번 창 · 탭 이름 GENERAL / 파티·길드 / 파티 찾기 · 이미 Chattynator 를 쓰던 profile 은 창·스킨 그대로 · 스킨 기본값은 창이 처음 그대로이고 스킨도 기본 dark 일 때만.

## 변경·생성 파일
`Collection/AddOns/Chattynator/`(upstream + `Skins/DevilForever.lua` + TOC 한 줄) · `Collection/patches/Chattynator.patch` · `DevilForever_ChatSetup/{Chattynator.lua,ChatSetup.lua,ChatLayout.lua,DevilForever_ChatSetup.toc}` · `DevilForever_Skin_NativeChat/Skin.lua` · `!DevilForever_Core/{Registry.lua,registry_extra.json}` · `Collection/{install.json,manifest.json,manifest.md}` · `Collection/tools/extract.py` · `Collection/tests/{chatsetup/run.py,install/verify_archives.py}` · `Collection/install/설치안내.md` · `Collection/data/feature-map.md` · `Collection/codex-briefs/phase27-game-check.md` §10 · 기록 `brief-60.md` · `brief-60-review.md` · `TRIAGE_phase27.md` · `iter_4/work_log-60.md`. git 밖: stage·백업 폴더, 게임 `Interface/AddOns` 36 폴더.

## 게이트
work_log-60 판정 줄: chatsetup 39/39 · core 109/109 · luacheck failed=0 · extract errors=0 · genregistry up to date · patches verify 8/0 · build dry-run pitbull4 36 폴더 / fuf 38 폴더. 검수 C+M 1 → 0, 경미 남음 5(앞 4 + manifest.md:51 비교 목록 이름표). 설치 RC=0. 서브 토큰: 작업 A 이번 두 발주 713,166 → 747,554(누적 알림 값) · 검수 B 642,159 → 670,187.

## 다음
사용자 게임 확인(확인표 §10). 확인되지 않은 것: AFK/DND 메시지 창, fhd 창 높이와 Chattynator 최소 크기 240×140, Forever 의 채널 정보 함수, 파티 찾기 채널 존재.

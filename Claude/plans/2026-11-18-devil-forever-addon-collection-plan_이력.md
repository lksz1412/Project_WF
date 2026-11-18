# 마스터 플랜 이력 — Devil Forever 애드온 모음집

## Phase 0 Correction History (옮긴 시각 2026-11-18 13:11:22 +0900 · 마스터 플랜에서 그대로 옮김)

| 날짜 | 반영 | 근거 |
|---|---|---|
| 2026-11-17 ~ 18 | Codex 시기 계획·개정 기록 (현행 370행 계획, 450행 후보, 요구 대응표, 시간 기록이 붙은 단락들) | Codex 기록 위치: `Codex/plans/2026-11-17-devil-ui-forever-plan.md`, `Codex/results/handoffs/old-reference/r44-plan-update/` |
| 2026-11-18 | Claude 세션이 마스터 플랜을 새로 씀: Step 6 부터 새 번호, 질감 개선을 공통 외관으로, 저장·편집을 기능 Phase 뒤로, 사용자 PC 확인 목록 | R73·R75 · 이 문서 Phase Range 「바꾼 곳과 이유」 1–4 |
| 2026-11-18 | R76–R81 반영: 원천 수령 완료로 Phase 1 을 해제·manifest·정적 분석으로 바꿈, R77 조사로 선택 기능 Phase 8개 추가와 제외 표, 저장·복원 시작 애드온을 ProfileManager 로, 결정 항목 D7·D8 추가, Phase·Step 번호를 25·61 까지로 다시 매김 | R76·R77·R80·R81 · 「바꾼 곳과 이유」 5–7 |
| 2026-11-18 | 검증 1(Step 7 독립 검수) 반영: 기본값 규칙을 ①·② 두 조건과 예외 세 가지로 밝히고 V42 동봉 32개 분류 표 추가, D2 에서 상태 알림·CD 를 빼는 선택지 삭제와 Hekili 상태 알림 전제·보완 길, 원래 D5(GitHub)를 R67 사실로 옮기고 D6–D8 을 D5–D7 로, 키·게임 설정을 저장·복원 범위로, D4 에 V42 !DevilUI·Devilconfig 예외, 등록 규약을 연결 폴더가 맡게, 질감 판정을 PC 확인 뒤 확정으로, R31 처리 | `Claude/results/handoffs/master-plan/TRIAGE_phase0.md` 검증 1 M1–M9·경미 2 |
| 2026-11-18 | 재검증 1 반영: Phase 8 보완 모듈을 표시 전용·「전투보조」 한 묶음으로 경계 짓고 Step 26 에 조건부 +60–180분, D4 를 「고친 제3자 코드를 공개 저장소에 둘지」 로 다시 쓰고 Phase 끝 main 반영과 맞춤, V42 예외에 kgPanels·kgPanelsConfig 추가 | `TRIAGE_phase0.md` 재검증 1 N1–N3 |
| 2026-11-18 | 재검증 2 반영(원인 수정): R62 금지 대상을 「무엇을 언제 쓰라고 정하는 추천·판단·회전 로직」 으로 좁히고 특성별 오라·proc·CD 정적 표시 목록을 표시 설정 데이터로 허용, 목록 출처 순서·EventAlert 식 알림·Step 25 첫 확인 항목·조건부 시간 추가 | `TRIAGE_phase0.md` 재검증 2 N1′ |
| 2026-11-18 | 재검증 3 반영(진동 → 공통 원인 수정): Phase 8 을 「Step 25 확인(감시 데이터·알림 꼴) → 갈래 1–3 → 갈래별 원천·검사」 로 다시 쓰고, 원천이 없을 때 「원천 없음」 표시·D7 요청·최종 보고로 닫음. 목록 작성 Step 을 Step 26 한 곳으로 | `TRIAGE_phase0.md` 재검증 3 N1″a·N1″b·경미 1 |
| 2026-11-18 | 사용자 결정 반영: D4 = (나) 라이선스와 관계없이 필요하면 고쳐 공개(위험 사용자 감수, 고치는 방식 1–4 는 그대로), D1·D2·D3·D5·D6·D7 = 기본값. D4 (가) 를 전제로 쓴 표기(V42 예외·원본 무수정·설치 ZIP 제외)와 D6 미결 문구를 정리하고 Decisions Required 를 결정 기록으로 바꿈 | R83 · `Claude/results/REQUEST_LEDGER_phase0.md` R83 행 |
| 2026-11-18 | R86 반영: 실사용 검증은 Codex, Claude 는 코드 작성·정적 검사·코드 논리 검수까지. 오프라인 로드 harness(옛 Step 10) 삭제로 Step 11 이후를 하나씩 당겨 Step 6–60 으로, 사용자 PC 확인 목록을 Codex 실사용 검증 발주문으로, D1 을 Codex 검증 시점으로, Phase 25 를 Codex 검증 결과 반영·고정으로 | R86 · `Claude/results/REQUEST_LEDGER_phase0.md` R86 행 |
| 2026-11-18 | R87 반영: 검수 강도 예외(이번 세션 · 상한 10라운드)와 Test Plan 재작성, 「그대로 사용(수정 없음)」 을 쓰는 방식 첫 선택지로 두고 Step 8 판정·그대로 쓰는 Phase 를 Step 하나로, UI 외관(Phase 2 외관 구현·스킨·Phase 22·24)을 Codex 외관 발주문으로 넘기고 Claude Phase·Step 을 Step 6–41 로 다시 셈. 등록 규약을 Core 등록 표(정적 데이터)로 | R87 · `Claude/results/REQUEST_LEDGER_phase0.md` R87 행 |
| 2026-11-18 | 검증 2 반영: Core 에 기본값 주입(처음 한 번·사용자 값 보존)과 토큰 위 프레임별 편집값 읽기 규약을 넣고 Codex 외관 발주문·받아들임 기준에 반영, Step 11 을 150–240분으로, 예외 문구·R 범위·R87 분담 표기 정리 | `TRIAGE_phase0.md` 검증 2 M-a·M-b·경미 1–5 |

## Phase 0 끝 정리

Phase 0(Step 6–7): Codex 기록을 넘겨받아 마스터 플랜을 새로 썼다. 독립 검수 10라운드 + 재검증 4회(중대·중간 9→3→1→2→0, 재검증 3 에서 진동 판정 뒤 Phase 8 원인 수정), 사용자 결정 R83·R86·R87 반영, 반영분 1회 검수(중간 2 → 고침 → master 확인). R88 명시 GO. Result = `Claude/results/PHASE_0_master-plan_RESULT.md`.

## Phase 1 Correction History (옮긴 시각 2026-11-18 13:52:04 +0900)

| 날짜 | 반영 | 근거 |
|---|---|---|
| 2026-11-18 | Step 8 판정 반영: Phase 18 Mapster 「그대로 사용 + 설정」 → 「고침」(V42 FogClear 오류 막기 옮김, TOC 는 Codex 가 로드 불가를 확인할 때만), Step 30 → 30a·30b(+60–150분) · Phase 19 시작 애드온 Dominos_Progress → Experience Forever(Dominos_Progress 는 비교) · Phase 21 「편집·저장 기전을 고쳐 씀」 → 「새 개발」(Devilconfig 실행 단추 패턴·!DevilUI 이동 손잡이 참고, Step 34 에서 Edit Mode Expanded·BlizzMove 정독), Step 34–35 를 180–300분에서 270–450분으로 · 고정 합계 1,940–3,490분 → 2,090–3,790분, 선택 기능 12–19 230–385분 → 290–535분 · 개요·V42 분류 표·바꾼 곳 8·Phase N 표·Test Plan 두 표 함께 고침 | Step 8 판정 `Collection/judgment.md` 4-1·4-3·Phase 19·§6 · master 결정 `Claude/results/handoffs/phase1/TRIAGE_phase1.md:21–27` |

## Phase 1 끝 정리

Phase 1(Step 8–10): 원천 해제·manifest·정적 도구·쓰는 방식 판정·직업 표·Codex 발주문. 판정으로 행 18·19·21 변경. Result = `Claude/results/PHASE_1_sources-tools_RESULT.md`.

## Phase 2 끝 정리 (2026-11-18 14:33:42 +0900)

Phase 2(Step 11–12): !DevilForever_Core 와 Codex 발주문 2건. 이 Phase 의 마스터 플랜 고침 = Core 폴더 이름 바꿈(단어 치환). Result = `Claude/results/PHASE_2_core_RESULT.md`.

## Phase 3 끝 정리 (2026-11-18 14:45:51 +0900)

행동단축바는 Dominos 12.0.4 를 그대로 쓰고 기본 설정은 단축키 글자 표시 하나만 넣었다(바 개수·페이지 전환·직업 특수 바는 Dominos 자체 기본값). 등록 표에 바 1–7·특수 바 프레임과 위치·간격 편집 항목을 올렸다. Codex 외관·실사용 검증 발주문을 썼다. Result = `Claude/results/PHASE_3_dominos_RESULT.md`.

## Phase 4 끝 정리 (2026-11-18 15:06:40 +0900)

대화창은 기본 창·기본 입력을 그대로 두고 Prat 3.9.117 을 그대로 쓴다. 기본 설정은 채팅 기록 되살리기 끔·Memory 모듈 끔 두 가지. 세 창 분담(D3 가)은 새 작은 애드온 DevilForever_ChatSetup 이 캐릭터 첫 접속 때 한 번만 창 두 개를 열어 채널 묶음을 옮긴다(빈 창 수를 먼저 세고 모자라면 아무것도 바꾸지 않음). Codex 외관·실사용 검증 발주문을 썼다. Result = `Claude/results/PHASE_4_prat-chat_RESULT.md`.

## Phase 5 끝 정리 (2026-11-18 15:16:44 +0900)

미니맵은 SexyMap v12.1.7 을 그대로 쓴다. 기본 설정은 지도 오른쪽 클릭으로 설정창이 열리지 않게(/sexymap 으로는 열림)와 추적 버튼 늘 보이기 두 가지이고, SexyMap 이 모듈 표를 통째로 만드는 방식이라 그 표를 SexyMap 기본값과 함께 채운다. 사각 모양·위치·테두리는 Codex 몫. Codex 발주문을 썼다. Result = `Claude/results/PHASE_5_sexymap_RESULT.md`.

## Phase 6 끝 정리 (2026-11-18 15:34:25 +0900)

체력·직업 자원은 Forever Unit Frames 0.65.2 를 그대로 쓴다. FUF 기본값이 계획 행(체력·자원·프레임 오라·치유 예측·거리 흐림, 마나·토템 강제 없음)을 이미 채워 기본값 파일은 두지 않았다. Grid2 가 로드된 캐릭터에서 FUF 공격대 창만 한 번 끄는 연결 애드온 DevilForever_FUFDefaults 를 만들었다(FUF 자체 명령 사용, 사용자 값은 건드리지 않음). 파티 창은 FUF 몫으로 두고 Grid2 는 공격대만 보이게 Phase 9 에서 맞춘다. 9개 직업 자원은 classes.md 와 맞고 흑마법사 영혼의 조각만 FUF 에 표시가 없다. Result = `Claude/results/PHASE_6_fuf_RESULT.md`.

## Phase 7 끝 정리 (2026-11-18 15:54:49 +0900)

시전바는 Quartz 3.8.0 이 내·대상·주시·소환수 시전바를 맡고, 게임 기본 시전바는 Quartz 자체 설정으로 숨긴다. 같은 자리의 FUF 시전바는 새 연결 애드온 DevilForever_Castbars 가 이번 접속 동안만 숨긴다(저장 값을 바꾸지 않아 계정 공유 프로필 문제가 없음, Quartz 모듈을 끄면 바로 FUF 로 넘어감). Dominos_Cast 는 모음집 설치본에서 빼기로 했다(Phase 23). Quartz 의 차단 글자 모듈은 Forever 에서 로드되지 않을 것으로 보여 차단은 빨간 실패 막대로만 보인다. Result = `Claude/results/PHASE_7_quartz_RESULT.md`.

## Phase 8 끝 정리 (2026-11-18 16:52:59 +0900)

직업 전투보조: Hekili 는 다음 행동 추천만 맡고(추천 기술 단축바 버튼 강조 켬), 상태 알림·쿨은 게임 기본 재사용 대기시간 관리자가 맡는다(R104). 28개 특성 중 힐러 4개는 Hekili 미지원이라 쿨 관리자 표시만 받는다. Forever 는 전투 중 버프 정보를 애드온에 숨긴다는 사실을 원천에서 확인했다. 근간 재논의(R105–R107)로 계획을 고쳤다(PitBull4 비교판 추가, 어그로는 Details, 편집기 대신 세 해상도 배치 등). Result = `Claude/results/PHASE_8_hekili_RESULT.md`.

## Phase 6-rev 끝 정리 (2026-11-18 17:35:26 +0900)

PitBull4 Forever 판을 만들었다: 최신 v4.2.50 에 V42 제작자의 Forever 수정분(72파일)을 옮기고 옛 데빌 배치 설정의 기능 값을 기본값으로 넣었다. FUF 와 비교표를 만들었고 기본으로 넣을 쪽은 Phase 23 에서 정한다. 검수에서 Core 기본값 규칙의 결함(AceDB 가 기본값과 같은 사용자 값을 지우는 탓에 기존 프로필을 덮어쓸 수 있음)이 나와 Core 를 고쳤다(Phase 2-rev): 이제 새 프로필에만 쓴다. Result = `Claude/results/PHASE_6-rev_pitbull4_RESULT.md`.

## Phase 9 끝 정리 (2026-11-18 17:44:27 +0900)

공격대창은 Grid2 4.1.13-forever 를 그대로 쓴다. 기본 설정은 공격대에서만 보이기(솔로·파티·투기장은 비움, 창도 공격대일 때만)와 블리자드 공격대 창 숨기기. 파티는 유닛 프레임 담당. Grid2 칸은 SecureUnitButton 이라 마우스오버 매크로 대상이 된다(원본 확인, 게임 확인은 Codex). 표시기(역할·해제 디버프·지속 치유)는 Grid2 첫 실행 템플릿 그대로. Result = `Claude/results/PHASE_9_grid2_RESULT.md`.

## Phase 10 끝 정리 (2026-11-18 17:57:59 +0900)

Phase 10 끝: 데미지·어그로 미터는 Details + Details_TinyThreat 를 그대로 쓴다(R107 ②). 연결 애드온은 애드온 수를 줄이려고(R101) 빼고, 어그로 창은 처음 한 번 손으로 연다(/details new → 창 2 모드 버튼 → Plugins → Tiny Threat). Result = `Claude/results/PHASE_10_details_threat_RESULT.md`.

## Phase 14 끝 정리 (2026-11-18 18:09:02 +0900)

Phase 14 끝: 이름표는 게임 기본을 쓰고 애드온을 넣지 않는다(R107 ③). Codex 확인·외관 발주문을 썼고, 검수에서 나온 복원 경로 문제를 고치면서 앞 Phase 발주문 10개의 되돌리기 문장도 백업 통째 복원으로 맞췄다. Result = `Claude/results/PHASE_14_nameplates_RESULT.md`.

## Phase 15 끝 정리 (2026-11-18 18:27:38 +0900)

Phase 15 끝: Aurora 를 쓸지는 Codex 가 정한다(R107 ④). Codex 확인·외관 발주문을 썼다. Aurora 가 접속마다 게임 설정 하나(questTextContrast)를 4 로 바꾸고 이름표·Cooldown Manager 스킨은 끌 수 없다는 점을 원천에서 확인해 발주문에 넣었고, 되돌리는 길을 애드온 없이 치는 한 줄로 바꿨다. Result = `Claude/results/PHASE_15_aurora_RESULT.md`.

## Phase 16 끝 정리 (2026-11-18 19:02:11 +0900)

새 작은 애드온 DevilForever_StatusStrip(골드·가방 빈칸·내구도·시계·지연·FPS). Result = `Claude/results/PHASE_16_statusstrip_RESULT.md`.

## Phase 19 끝 정리 (2026-11-18 19:15:42 +0900)

Phase 19 끝: 경험치·평판·사냥꾼 소환수 경험치 막대는 Experience Forever 를 그대로 쓴다. 기본값이 이미 계획과 같아 Core 기본값 파일을 만들지 않았고(애드온 수·파일 수 최소), 같은 기능의 Dominos_Progress 는 넣지 않는다. Result = `Claude/results/PHASE_19_experience_RESULT.md`.

## Phase 20 끝 정리 (2026-11-18 20:17:34 +0900)

설정 저장·복원을 Core 안 모듈로(Profiles·Presets·Spec·Commands), PM 은 키·게임 설정. Result = `Claude/results/PHASE_20_profiles_RESULT.md`.

## Phase 22 끝 정리 (2026-11-18 20:30:29 +0900)

Phase 22 끝: 대안 테마는 Codex 가 만들고, Claude 는 테마를 바꿔 끼우는 Core 인터페이스를 점검해 작은 빈틈을 메우고(빠진 토큰 알림·이름 규칙·저장·전투 중 미룸) `/dfp theme` 명령을 더했다. 후보 컨셉 둘은 Codex 기록일 뿐이고 고르는 것은 Codex 다. Result = `Claude/results/PHASE_22_themes_RESULT.md`.

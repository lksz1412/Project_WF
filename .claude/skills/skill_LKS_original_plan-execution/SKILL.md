---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_original_plan-execution
description: >
  Use when a substantial task begins — both for authoring the plan and for
  executing it after GO. Covers the six plan-save conditions, the 11-section
  master plan template, cumulative step numbering, chapter→Phase→step
  granularity, the pre-writing inventory check, load-bearing premise
  verification, post-GO auto-progress, plan re-read enforcement, the 5-stage
  loop, step history, Result/Ledger standards, verification gates, and phase
  audits.
  본격(장기·다단계) 작업의 계획 착수 시(① 절)와 GO 직후(② 절) 모두 로드한다.
  트리거: 계획서, 마스터플랜, 11-section, 계획 수립, 세부 계획서, Decisions Required,
  본격 작업 착수, GO, Phase 실행, Result, Ledger, 스텝 이력, 검증 게이트, 5-stage.
metadata:
  type: method
---

# Plan Execution (계획 저작·단계 실행)

본격(장기·다단계) 작업의 계획서를 표준 양식으로 저작해 저장하고, GO 이후 각 Phase 를 5-stage 루프로 실행하며 실시간 이력(스텝 이력·Result·Ledger)을 남기는 절차. 계획 착수 시에는 「① 계획 착수 시」를, GO 직후에는 「② GO 직후」를 따른다.

## 적용 조건

다음 중 하나라도 해당하면 본격 작업 전에 계획서를 `Claude/plans/YYYY-MM-DD-<topic>-plan.md`로 저장한다. 대화로만 계획을 말하고 장기 작업을 시작하지 않는다.

1. 문서·논문·복잡한 자료 검토·재구성 작업<!--ih--> (LaTeX은 `skill:skill_LKS_original_visual-design` 참조)<!--/ih-->
2. 여러 원천 파일 대조 작업
3. phase·장 구조가 있는 장기 작업
4. 절차·알고리즘·의존식 등 논리 전개가 복잡한 작업
5. 사용자가 계획서, 원본, 검수, 인계, phase, 장기 작업 언급
6. 여러 세션 결과를 나중에 비교·통합해야 하는 작업

**사용자가 계획서·마스터플랜을 세우라고 명시 지시하면("계획 세워서 진행해" 류) 위 1~6 해당 여부·과제 규모·정형성과 무관하게 본 절을 따른다 — 명시 지시를 경량·정형(A3) 등급 판정으로 무효화하지 않는다.**

GO 이후의 Phase 실행·스텝 이력·Result/Ledger 기록·검증 gate 설계에도 같은 스킬을 적용한다.

## 핵심 원칙

계획은 대화가 아니라 **저장된 문서**다 — 마스터 플랜·페이즈별 세부 계획서를 표준 양식(11-section·cumulative step·챕터→Phase→step)으로 저작해 `Claude/plans/` 에 남기고, 실행 전 load-bearing 전제를 실물과 대조한다(1g). GO 뒤에는 그 문서를 다시 읽어 그대로 실행하고, 실행한 사실을 스텝 이력·Result·Ledger 로 남긴다.

### 세 문건 — 실행 통제 + 컴팩션 복구 위키/도서관

본 스킬이 생산하는 세 문건은 이중 역할: (1) 실행 통제, (2) 컴팩션 복구용 위키/도서관 — 오토컴팩션으로 대화 맥락이 소실되어도 AI가 이 문건들을 직접 읽어 환각 없이 복구. 복구 시 아래 순서대로 읽는다.

| 문건 | 역할 | 저장 위치 |
|---|---|---|
| 마스터 플랜 | 전체 청사진 — 지금 기획(11 섹션 전부 · Phase 구성·범위·non-goals·구현·Test Plan·결정 등 · 세부 스텝 목록만 두지 않음 · Correction History 는 Phase 끝에 이력 파일로 옮김 · Phase 끝 정리는 이력 파일 · 1b 「이력 파일」) | `Claude/plans/YYYY-MM-DD-<topic>-plan.md` · 이력 파일 = 같은 폴더 `YYYY-MM-DD-<topic>-plan_이력.md`(마스터 플랜 파일 이름의 `.md` 앞에 `_이력`) |
| 페이즈별 세부 계획서 | 각 Phase 세부 step 분할 — 마스터 플랜 Phase Range 확장 · 스텝 목록·Gate·진행 체크·작업 내용(1e) | Phase 마다 별도 파일 `Claude/plans/YYYY-MM-DD-<topic>-phase<ID>-세부계획.md` |
| 스텝 이력 | cumulative step 완료 시 즉시 기록 — step 하나 = 파일 하나 · 다음 세션이 이어받을 수 있게 결론·결정(전 행·명령 출력은 work_log 를 가리킴) | `Claude/results/Step <N> — <제목>.md` |

**컴팩션 복구:** 컴팩션·세션 재개(fork 포함) 직후 새 편집 전 한 순서 — **복구 읽기 순서(헌법·소통·흐름 memory 다시 읽기 · 방법론 스킬 둘 다시 부르기 → 6-check(대기열 사용자 메시지 대조부터) → 마스터플랜 본문(이력 파일 아님) → 현재 Phase 세부계획 → 최신 `Step <N>` → 최신 Result → 분업 중이면 세션 대장·지금 Phase 처리표)**(6-check·마스터플랜부터의 나머지 읽기는 master 몫 — 서브는 규칙 파일 재독 뒤 그 대신 자기 발주문·받은 메시지·발주문이 입력으로 정한 파일·기록[대상·연계 파일 + 자기 work_log·실행 출력 절처럼 발주문이 정한 기록]을 전문으로 다시 읽고, 요청 대장·계획 문건에 쓰지 않으며 발주문 밖 기록을 읽지 않는다) 원본 = `memory:feedback_compaction_recovery`(재개 시 훅이 결정론적으로 주입) · 복구 읽기(규칙 파일 재독 + 6-check)로 읽은 파일·줄 범위는 그 스텝 이력 「근거·판단」에 적는다(아래 2c).

**인계(handover) 문건:** 인계 기록의 우선순위·기록 5항목·저장 위치·chain 규율 **원본 = `memory:feedback_handover`**. 저장 위치는 `Claude/docs/HANDOVER_<vN.N.N>.md` — 계획서(`Claude/plans/`)·스텝 이력·Result(`Claude/results/`)와 함께 `Claude/` 로 격리한다(프로젝트 루트 `docs/` 아님).

**tier 별 작업 언어:** 마스터 플랜·Result 는 사용자가 읽으므로 한글. 세부계획서·스텝 이력(내부 tier)의 언어는 「1f-1 작업 언어 판정」으로 프로젝트마다 1회 정한다(referent 언어 기준 · 산출물 본문 언어 아님).

## 실행 방법

### ① 계획 착수 시

#### 1a. 적용 조건 확인 후 저장

상단 `## 적용 조건`을 확인한 뒤, 해당하면 본격 작업 전에 계획서를 `Claude/plans/YYYY-MM-DD-<topic>-plan.md`로 실제 저장하고 장기 작업을 시작한다. 구조화 메타데이터가 필요하면 같은 이름의 `.json` companion을 생성한다.

#### 1b. 11-section 양식

섹션명·순서 그대로 보존. 임의로 Context/Objective/Scope 등으로 바꾸지 말 것.

Summary / Current Ground Truth / Phase Range / Non-goals / Implementation Changes / Phase N — <phase name> / Implementation Interfaces / Test Plan / Assumptions / Correction History / Decisions Required

- **간략 목차(마스터 플랜 머리)**: 11 섹션 앞에 큰 틀을 한눈에 보이는 간략 목차 트리(챕터 → Phase → 주요 Step 과 Step 마다 예상 시간 — `memory:feedback_communication_style` 원칙 6 「예상을 내는 때」)를 두고, 실행 중 사용자 지침 수정이 들어오면 어느 단계에 편입되는지(편입 규칙 = 1j)를 그 트리에 표시한다 — 초안을 사용자에게 가져갈 때(1x) 목차부터 보인다(사용자가 따로 요청하지 않아도 · 섹션 이름·순서는 그대로).
- **「Phase N — <phase name>」 절**: 절 이름·순서는 그대로 두고, 내용은 Phase 목록 표(Phase · 세부 계획서 파일 · Step 범위 · 상태)다 — 스텝 목록·Gate 는 1e 의 세부 계획서 파일에 두고, Phase 끝 정리는 처음부터 아래 이력 파일에 쓴다(다른 절 — 범위·Non-goals·구현·Test Plan·Assumptions·Decisions Required 등 — 은 그대로 지금 기획을 담는다).
- **이력 파일 — 마스터 플랜은 지금 기획만**: 마스터 플랜에는 지금 기획(11 섹션)만 둔다. Correction History 절에는 Phase 동안 갱신을 쌓고, Phase 가 끝날 때 한 번 그 줄들을 같은 폴더 이력 파일 `YYYY-MM-DD-<topic>-plan_이력.md`(마스터 플랜 파일 이름의 `.md` 앞에 `_이력`)로 옮긴 뒤(지우지 않고 옮김 · 옮긴 글 그대로) 본문에는 이력 파일을 가리키는 줄을 두고, Phase 가 끝날 때의 Phase 끝 정리는 마스터 플랜에 쓰지 않고 처음부터 이력 파일에 쓴다. 이력 파일을 읽는 때 = 마스터 플랜을 작성·갱신할 때 · 사용자가 제시안을 요청할 때 — Phase 착수 재독(1z)·컴팩션 복구 때는 마스터 플랜 본문만 읽는다.
- **판 이력 — 프로젝트 운용 문서와 따로**: 프로젝트 `CLAUDE.md`(매 턴 실리는 프로젝트 운용 문서)에는 지금 지킬 규칙·경계·구조만 둔다. 판·릴리스 이력(각 판이 무엇을 왜 바꿨나)은 따로 둔 판 요약 파일(예 `VERSION_HISTORY.md` · 자리·이름은 프로젝트가 정함)에 적고, 프로젝트 `CLAUDE.md` 에는 그 파일을 가리키는 한 줄과 읽는 때만 둔다. 판 이력 파일 = 운용 문서가 가리키는 그 판 요약 파일이다(전문 정독) — 판마다 상세 기록(`CHANGELOG.md` 등)은 판 이력 파일이 아니라 필요한 판 항목만 읽는다. 판 이력 파일을 읽는 때 = 마스터 플랜을 작성·갱신할 때(1f 5) · 사용자가 제시안(계획 초안·기획 의견·방향 제안)을 요청할 때 — 지난 판에서 정한 것을 뒤집거나 되풀이하지 않으려고. 운용 문서에서 뺀다는 것은 매 턴 싣지 않는다는 뜻이다 — 다른 규칙이 읽으라고 정한 때(고치기 전 영향 지도의 기록 찾기 — `memory:feedback_change_impact_analysis` · 판 끝에 새 판 항목을 적을 때 · 사용자가 지목한 문건 정독·인계 chain 확인 발췌 — `memory:feedback_session_entry_reading`)는 그대로 읽는다. 위 마스터 플랜 이력 파일(`…-plan_이력.md` — 이 계획을 고친 이력)과 판 이력(프로젝트의 판마다 바뀐 것)은 다른 파일이다 — 섞어 적지 않는다.
- **「늘 지킬 제약」 소절**: Current Ground Truth 아래에 소절 「늘 지킬 제약」을 두고 늘 지킬 사용자 명령을 처리 갈래와 함께 적는다(섹션 이름·순서는 그대로 · 갈래 = 2c-2 · 양식 = `references/record-formats.md` 「늘 지킬 제약」 절).
- **작업 종류별 프로파일**: 코드 작업은 11 섹션 전부 채운다. 문서·설정·덱 등 비코드 작업은 코드용 3 섹션 — Implementation Changes(Phase N 과 겹치면 접기)·Implementation Interfaces("해당 없음" 명시)·Test Plan(프로젝트의 실제 게이트로 대체) — 을 접을 수 있다(순서·이름은 보존, 빈 채움 강제 금지).
- **Test Plan 「검증 관점」 표**: Test Plan 에 검증 대상마다 한 행씩 「검증 관점」 표를 둔다 — **검증 대상 · 갈래(① 치환 · ② 국소 변경 · ③ 구조 변경 · ④ 기계적 변경 · 코드면 「코드 ②」처럼) · 고정 5 프리셋(P1 코드 · P2 지침·규범 문서 · P3 설치기·스크립트·도구 · P4 시각 · P5 일반 문서 · P6 데이터 가운데 하나) · 고정 ③ 신규=연결/수정=연계 · 가변 5(그 대상의 핵심 위험)**. 검수 sub 는 이 표가 지정한 갈래·관점으로 검수를 돈다(검수 서브가 스스로 고르지 않는다 · 「갈래」 칸 = 계획 때 시작값 — master 가 검증 발주 전에 실제 diff 로 판정을 다시 걸어 무거운 쪽으로만 올리고 이 표를 고친다 · 갈래마다 판정 질문·검수 강도·범위 원본 = `memory:feedback_chunked_review` 「검수 구분」) — 표가 없으면 계획 단계 미완이다. 관점 정의·프리셋 표(P1~P6) = `skill:skill_LKS_original_review-chunking` · 검증 절차(③ 구조 변경 = 관점 10개로 10라운드 · ①·②·④ = 갈래별 검수) = 헌법 §3 · `memory:feedback_chunked_review`.
- 사용자 결정 요청은 본문에 섞지 말고 별도 `## Decisions Required` 섹션으로 분리한다.
- **§11 「멈출 일 미리 점검」 필수 표**: `## Decisions Required` 에 실행 중 멈출 수 있는 일을 미리 적는 표를 **필수**로 둔다 — 새 의존성·설치 · 네트워크·외부 호출 · 파괴·비가역(삭제·덮어쓰기·force push·정리) · 권한 · 세션 전환 · 검증 미수렴 · 원래 있던 결함 · 푸시·외부 게시 · 이 환경에서 실측 불가 · 모델 미가용 — 항목마다 대책(기본값)을 적는다. 사용자의 **명시 GO 가 그 대책의 승인**이다(표가 없으면 계획 단계 미완 · 헌법 자가 판정). 실행 중에는 이 표의 대책대로 무중단 진행한다 — 무엇에서 멈추나는 다시 적지 않고 원본을 따른다(정지 조건 목록 원본 = 헌법 「GO 후」 · 파괴·비가역·blocking 의 사전 확인 시점과 실행 중 멈춤 = `memory:feedback_flow_interruption` 「사전 확인(원본)」 · 복원 지점 절차 = `memory:feedback_workspace_git_safety`).
- **지침 예외는 「예외」로 따로 등재**: 지침 규칙에 예외를 두려면 `## Decisions Required` 에 「예외」로 따로 적어 결정받는다 — 멈출 일 표의 한 칸에 묻어 두지 않는다.
- **용어 두 뜻 확인**: 사용자 용어가 두 뜻으로 읽히면 지침의 정의를 따르고, 지침에 없으면 §11 에서 확인한다(예: 「서브세션」 = 이 세션의 서브에이전트).
- **우회 설계 전 실측**: 도구·환경 제약 한 줄(문서 문구·지난 세션 기억)을 근거로 계획에 우회 설계(다른 경로·수동 절차·범위 축소)를 넣기 전에, 그 제약이 이 세션에서 실제로 걸리는지 실측해 Current Ground Truth 에 적는다(1g 전제 검증과 같은 결 · 서브 모델·정의 쪽 예 = `memory:feedback_session_division` 「서브의 정의·방어」).
- **병렬화 승인 채널**: 병렬(동시 다중 유닛·fan-out)이 유용한 페이즈는 여기 `## Decisions Required` 에서 비용과 함께 제안하고 **사용자 sign-off** 를 받는다 — 이 계획서에서는 그 sign-off 가 병렬 승인이다(그 밖 승인 경로 = 사용자발 명시 지시 · 원본 = `memory:feedback_session_division` 「승인 2경로」 · 모델이 실행 중 저작하는 페이즈별 세부계획서의 자체 결정 블록은 승인 채널이 아니다 — self-authorization 금지). 실행 중 병렬 필요가 새로 생기면 안 묻고 직렬로 진행하고 결정 대기에 기록만 한다(무중단 우선 · 병렬 규범 = `memory:feedback_session_division`).
- **참고 원문 위치**: 계획서가 참고하는 원문(사용자 자료·명세·원천 파일·외부 문서)이 있으면 Current Ground Truth 에 그 원문의 위치(파일 경로·URL·쪽·줄)를 적는 세부 항목 하나를 둔다.
- **구조 맵**: 폴더·파일·문서 구조 맵을 계획서(Current Ground Truth 또는 상단 별도 §)에 두고, 파일·폴더를 추가·삭제·이동·이름변경하는 작업은 **그 자리에서 즉시 맵을 갱신**한다(갱신 안 하면 미완). 이후 구조 확인은 grep·find 재조사가 아니라 이 맵을 1차 참조 — 매 작업 재조사로 토큰을 반복 소모하지 않는다. 규율·이유 상세 = `skill:skill_LKS_original_project-scaffold`.

#### 1c. Cumulative step numbering

step 번호는 phase를 넘어가도 1부터 재시작하지 않고 전체 단조 증가 (Phase A가 Steps 1-12 → Phase B는 Step 13부터). 이어받는 작업은 직전 ledger 또는 결과 문건의 Next Step 번호부터 연결. 이유: 다중 세션 병행 시 step 번호가 절대 좌표가 되어야 복구·비교·인계가 가능하다.

#### 1d. 챕터 → Phase → step 입도 (1챕터 = 1Phase 금지)

챕터 안에서 Phase로 나누고 → Phase 달성을 위해 세부 step으로 쪼갠다 → step 번호는 전체 단조 누적. 한 챕터를 1개 Phase로 뭉개지 말 것. Phase ID는 `<챕터>.<n>` (예: Phase 1.1, 1.2 ... 2.1 ...).

#### 1e. 페이즈별 세부 계획서

각 Phase 착수 시 해당 Phase의 세부 계획서를 **Phase 마다 별도 파일**로 작성한다(Phase 크기와 무관 · `Claude/plans/YYYY-MM-DD-<topic>-phase<ID>-세부계획.md`). 마스터 플랜의 Phase Range를 여러 step으로 분할하여 구체적 작업 단계 설정 — 그 Phase 의 스텝 목록(스텝마다 예상 시간)·Gate·진행 상황 체크·작업 내용은 이 파일에 채우고, Phase 진행은 이 파일을 보고 한다. 마스터 플랜의 `## Phase N` 절에는 Phase 목록(Phase 마다 세부 계획서 경로·Step 범위·상태)을 두고, Phase 가 끝날 때 그 Phase 작업 내용 정리는 처음부터 이력 파일에 쓴다(1b 「이력 파일」) — 세부 스텝 전부를 마스터 플랜에 넣지 않는다(Step 착수 때는 그 Phase 파일만 다시 읽어 마스터 플랜 전체를 다시 읽는 토큰을 줄인다 — Phase 착수·컴팩션 복구 때는 지금처럼 마스터 플랜 본문도 다시 읽는다 · 이력 파일은 아님). 세부 계획서는 모든 Phase 것을 미리 다 쓸 필요는 없다 — 진행 중인 Phase 파일만 최신 유지(마스터 플랜에는 세부 step 을 적지 않는다).

#### 1f. 계획서 작성 전 확인 (7단계)

1. 활성 프로젝트·작업 폴더 확인
2. 원천 파일·참고 파일·기존 문건 목록 확인
3. 각 원천의 경로·크기·행/페이지 수 확인
4. 관련 원천은 전문 정독 대상(종류로 빼지 않음) · DB성 자료·실험 데이터만 Python 으로 필요한 값 추출
5. 기존 계획서·결과서·ledger·handover 존재 여부 · 프로젝트 판 이력 파일(운용 문서가 가리키는 판 요약 파일)이 있으면 전문 정독(1b 「판 이력」)
6. 이어받는 작업이면 직전 ledger Next Step + 마지막 gate 확인
7. 안 읽은 범위는 미검독 표시 (추정 금지). 결과를 Current Ground Truth에 반영.

#### 1f-1. 작업 언어 판정 (프로젝트 진입 시 1회 · 스텝마다 재판정 금지)

내부 tier(세부계획서·스텝 이력)를 한글로 쓸지 영어로 쓸지 프로젝트 진입 시 1회 정하고, 마스터 플랜 §Current Ground Truth(또는 프로젝트 CLAUDE.md)에 한 줄로 고정한다. 마스터 플랜·Result 는 사용자가 읽는 tier 이므로 이 판정과 무관하게 한글이다.

1. **카테고리 사전 검토(먼저 볼 쪽만 정한다 · 확정 아님)**: 코딩·학술 문건 → 영어 적절성 먼저 검토 / 통상 작문·발표자료·웹페이지 → 한글 적절성 먼저 검토 / 둘 다 아니면 곧바로 2.
2. **확정 = referent 시험.** 내부 tier 언어는 그 문건이 지칭·조작할 대상(referent)의 언어를 따른다 — **산출물 본문 언어가 아니다**(본문 한글은 렌더링 표면일 뿐). 기계 프록시 = 라벨·식별자·파일명·기호·API 가 ASCII/영어면 영어 / 작업 대상이 한국어 낱말·문장 자체면 한글. 확인 시험 = 스텝 이력 한 줄을 시험 삼아 써 본다: 한글 인용이 불가피하면 한글, 영어 라벨·기호만으로 써지면 영어.
3. **카테고리만으로 확정하지 않는다.** 학술이어도 본문이 한글이어도 referent 가 영어면 영어 tier 다(그 역도 같다 — 카테고리는 순서일 뿐 확정자는 referent 시험).
4. **용어·기호·단위·인용키·경로는 언어 정책 대상 밖** — 어느 tier 든 원문 verbatim.
5. **영어 tier → 한글 산출물 렌더링 지점에 금지 어휘 규범 적용** — 정착 표준어가 없으면 한자 조어를 짓지 말고 영어 원어를 알파벳 그대로 쓴다(원본 = `tools/banned_lexicon.json` 의 `non_korean_sino_neologism` 카테고리 · `feedback_communication_style` 배제 5범주 ⑤).
6. **한 프로젝트 안에서 tier 언어를 섞지 않는다.**
7. **영어 tier 로 학술 작업 시 인용 검증 게이트 동반** — 영어 학술 문체는 유창함이 날조를 덮으므로 DOI·URL 실제 해소를 기계로 확인한다(`skill:skill_LKS_original_source-research` 모드 A).

이 판정은 마스터 플랜 작성 시점(1f 확인 직후)에 내려 §Current Ground Truth 에 고정하고, 이후 스텝마다 다시 판정하지 않는다(구조 맵을 매번 재조사하지 않는 것과 같은 결).

#### 1g. 실행 전 load-bearing 전제 검증

계획서 실행 직전, Current Ground Truth·Assumptions의 load-bearing 전제를 실제 인벤토리와 대조. "없다/신규 작성" 가정 파일이 실제 존재하는지 Glob/Read로 확인. 거짓이면 즉시 STOP → Correction History로 재baseline 후 실행. 이유: 정독·컴팩션 복구로도 잡히지 않는 별개 실패 클래스다 — 잘못된 전제 위에 세운 Phase·Step·Non-goals 가 전부 어긋난다.

#### 1h. Phase/step 유연성 (최소 기준점)

명시된 phase/step 수·범위는 최소 기준점. 검토 필요 시 step 확장·신규 phase 추가 가능. "계획서에 N step이니 N step 안에 끝내야 한다" 압력 / silent 누락 금지 (명시적 deferral + 결정 대기(Decision Queue · 원본 = `memory:feedback_confirmed_items_policy`) 등재는 OK).

#### 1x. 계획 피드백 게이트 — 초안 완성 후·실행 전 (무조건 1회 이상 · 정지)

마스터 플랜 초안(§1~§11)을 다 쓴 직후 **바로 실행으로 넘어가지 않는다.** 초안을 사용자에게 평문으로 가져와, §11 `Decisions Required` 질문으로 피드백을 받고 **계획서를 최소 1회 갱신한 뒤**, 갱신본에 대한 **사용자의 명시적 GO** 를 받고서야 「② GO 직후」로 넘어간다. 이 **명시 GO 는 §11 「멈출 일 미리 점검」 표의 대책 승인을 겸한다**(그 표 없이 GO 로 넘어가지 않는다 · 1b) — 실행 중에는 그 대책대로 무중단 진행한다(멈추는 때 = 1b 의 원본 포인터).

- **무조건 ≥1회**: [초안 제시 → §11 질문 → 사용자 피드백 → 계획 갱신 → 명시 GO] 사이클을 본격 작업마다 예외 없이 최소 1회 수행한다. 물을 게 없어 보여도 §11 로 확인받는다(피드백이 "변경 없음"이면 그 확정·GO 를 계획에 반영하는 것도 갱신이다). 이미 확정된 항목을 다시 묻는 게 아니라 남은 열린 결정만 §11 로 확인하는 1회 사이클이라 「결정 재질의 금지」(`memory:feedback_user_decision_no_requery`)와 충돌하지 않는다.
- **금지 — 명시 GO 없이 실행**: (a) 계획 세우기 전 사용자가 "바로 진행해" 라고 해도 계획을 건너뛰지 않는다. (b) 초안을 세운 뒤 이 게이트·명시 GO 없이 실행에 착수하지 않는다. **"사용자가 진행하라 해서 그렇게 들었다"는 이 게이트를 건너뛴 변명이 되지 않는다 — 지시 오해가 아니라 게이트 불이행이다.**

### ② GO 직후

#### 1i. GO 후 끝까지 자동 진행

GO 사인("진행", "GO", "이대로 가자") 시 마지막 phase까지 자동 진행. 매 phase 종료마다 GO 재요청 정지 금지. 정지 조건 목록의 원본은 헌법 「GO 후」 8조건이고, 실행 문맥에서는 그중 넷을 다음과 같이 구체화한다:

1. **계획서 명시 Decision Gate** — 일반 nonblocking 선택은 "전부 진행" GO로 면제할 수 있지만, 사용자만 결정할 수 있는 blocking Decision Gate는 "전부 진행"에도 면제되지 않는다.
2. **새 의존성** — 계획서 정정이 필요하므로 멈춘다.
3. **confirmed FAIL gate** — 정정 시도 후에도 FAIL 이 유지되는 경우다.
4. **두 통제문서 지시 모순** — 정지한다(원본 = 헌법 「GO 후」) · 멈춰 있는 동안 이미 하던 일은 더 제한적인 쪽으로만 둔다.

결정 대기 항목은 보통 blocker가 아님 — 진행 막지 않으며 회신 시 추후 반영 기록 후 계속. 범위 확장은 답변 없이 진행하지 않으며, 사용자 명시 GO("Phase A만")는 그 범위로 한정 — 사용자가 준 피드백·지시로 범위가 바뀌는 것은 정지가 아니라 1j 로 편입한다. **병렬 승인 요청도 blocker 아님** — 미승인 병렬 필요는 안 묻고 직렬 진행(무중단 우선)하고 결정 대기에 기록만 하며, 병렬 신규 제안은 이미 예정된 정지점에서만 이후 페이즈 대상으로 한다. **파괴·비가역도 그 자체로는 blocker 아님** — 복원 지점 먼저 → 진행 → 기록이 기본이고, 멈추는 때는 원본이 정한 경우뿐이다(원본 = `memory:feedback_flow_interruption` 「사전 확인(원본)」 · 복원 지점 = `memory:feedback_workspace_git_safety`). **작업 중 받은 사용자의 추가 지시도 정지가 아니다** — 진행 중 작업을 수정·정정·병행 검토하라는 지시이므로 계획에 편입(1j)해 이어 가고, 사용자가 **명시적으로 중단하라고 한 경우만** 정지다.

#### 1j. 실행 중 받은 피드백 = 계획에 편입한 뒤 스킬 로직대로 진행

마스터 플랜·세부 계획서를 따라 실행하던 도중 사용자 피드백·수정 요청을 받으면, **그것을 즉흥 처리하고 끝내지 말고 기존 계획에 편입한 뒤 이 스킬의 절차(5-stage 루프·스텝 이력)대로 이어간다.**

**금지:** 실행 중 받은 피드백을 **계획서 갱신도 스텝 이력 저장도 없이** 바로 작업하고 종료하는 것. 피드백은 새 작업 단위이지 계획 밖 즉흥 처리 대상이 아니다.

**경중 3단 판정 — 편입 입도를 정한다:**

| 경중 | 판정 기준 | 편입 방식 |
|---|---|---|
| **경미** | 오타·1-line 수정·문구 다듬기 등 범위·구조 무변 | 별도 Phase/Step 신설 없이 즉시 처리 · 해당 자연 작업 단위 ledger 행에 "사용자 피드백 반영" 사유 1줄 |
| **중간** | 기존 산출물의 국소 수정·항목 추가(범위·의존성 무변) | **cumulative 번호로 새 Step append**(1c — 리셋 없음). 세부 계획서에 그 Step 추가 |
| **중대** | 범위·구조·의존성·새 산출물을 바꾸는 피드백 | **신규 Phase 추가**(진행 중/예정 chapter 에 `<챕터>.<n>`) · 이미 **완료된 Phase 를 고치는 피드백이면 `Phase N-rev`**(2b 규약 · 스텝 번호는 누적 그대로 · 해당 Phase Result 에 Addendum) |

**편입 절차(공통):**
1. **기존 계획서에 편입한다 — 새 계획서를 따로 만들지 않는다.** 마스터 플랜의 Phase Range·해당 세부 계획서에 신규 Phase/Step 을 적는다.
2. 피드백이 **기존 전제·범위·Non-goals 를 바꾸면** Correction History 에 재baseline 을 기록한다(1g).
3. 편입 사실(무엇을 어느 Phase/Step 으로 넣었는지)을 그 Step 이력 파일에 남긴다 — "기억으로" 넘어가지 않는다.
4. 그 뒤 **2a 5-stage 루프**(계획 저장 → 실행 → Result → 검증 → ledger)와 단위 루프(2f)대로 진행한다. 피드백이라는 이유로 이 절차를 건너뛰지 않는다.

**정지는 그대로:** 피드백이 사용자만 결정할 수 있는 blocking 을 새로 열면 1i 정지 조건에 따라 멈추고 **평문으로** 확인한다(팝업 금지 = `memory:feedback_flow_interruption`). 그 외엔 편입 후 무중단 진행.

#### 1z. 재독 강제 — 계획서는 쓰는 것이 아니라 따르는 것이다

계획서를 만들어 두고 읽지 않으면 없는 것과 같다.

| 시점 | 반드시 하는 것 |
|---|---|
| **매 Phase 착수 시** | **마스터 플랜 본문을 다시 읽는다**(이력 파일은 아님 · 지난 Phase 요청 대장 파일은 끝나지 않은 행을 이어 적을 때만 — 1b · 2c-2). 요약·기억으로 대체하지 않는다. 읽은 사실을 해당 Phase 첫 Step 이력 파일에 `[Phase N 착수 — 마스터 플랜 재독]` 으로 기록한다 · 요청 대장 새 파일을 열어 앞 Phase 의 끝나지 않은 행만 이어 적는다(2c-2) · 분업 중이면 처리표 새 파일이 앞 Phase 머리 「이미 정한 것」 을 이어 받고(`references/record-formats.md` 「검수 발견 처리표」) 세션 대장에 새 절을 연다(`skill:skill_LKS_original_multi-session-orchestration` 「다시 부르는 법 · 세션 대장」) |
| **매 Step 착수 시** | **해당 Phase 의 세부 계획서를 다시 읽고** 시작한다(그 Phase 파일 — 마스터 플랜 전체를 다시 읽는 것이 아니다) |
| **매 Step 완료 시** | `Claude/results/Step <N> — <제목>.md` 를 즉시 생성 (Phase 종료를 기다리지 않는다) |
| **사용자 결정·지시를 받았을 때** | 그 메시지를 받은 그 턴 안에서(다음 발주·편집 전) 요청 대장 행을 적는다(그 메시지의 답은 같은 턴의 마지막 글 · 결정 원본·이력 = 요청 대장 · 그 결정이 기획 내용[마스터 플랜에 담긴 것 무엇이든]을 바꾸면 마스터 플랜의 그 자리를, 스텝이 바뀌거나 새 작업이면 그 Phase 세부 계획서 Step · Ledger 행을 고치고 대장 행의 반영 칸에 표시) — 원본 = 2c-2 |
| **매 Phase 종료 시** | Result 12항목(md+json 쌍) + Ledger 갱신. Result 없이 다음 Phase 진입 금지 · 화면에는 그 Phase 정리 보고를 말(평문)로 올린다(Result 문건은 파일 기록 · 정리 보고는 화면 글 — 하나가 다른 하나를 대신하지 않음 · 마지막 Phase 면 이어서 최종 작업 보고 · 원본 = `memory:feedback_communication_style` 원칙 6) · 마스터 플랜 Correction History 를 이력 파일로 한 번 옮기고 Phase 끝 정리는 이력 파일에 쓴다(1b 「이력 파일」) |

**금지** — 계획서를 작성만 하고 읽지 않은 채 작업하는 것. 작업을 먼저 하고 나중에
계획서를 만들어 앞뒤를 맞추는 것. 선행 계획서가 있는데 열어보지 않고 새로 시작하는 것.

#### 2a. 5-stage 루프

각 phase는 이 루프를 독립적으로 돌아야 한다:

`plan saved → execution → result saved → validation → ledger update`

- 금지: 결과 저장 없이 다음 phase 진입 / validation 누락 후 ledger만 갱신 / ledger만 갱신하고 result 없음.

#### 2b. Result 저장 = 다음 Phase 진입 절대 전제

매 Phase 종료 시 `Claude/results/PHASE_<phase-id>_<topic>_RESULT.md`에 result 문건(같은 이름 `.json` 쌍 동반 — 필수, 2d) + ledger 갱신. result 저장 없이 다음 Phase 진입 절대 금지. 대화에만 남기면 컴팩션 시 소실. result에 Read Coverage(실제 읽은 파일·행 범위) 명시 = 정독 사후 증명(서브가 읽은 범위는 master 가 서브 기록과 기계 대조한 것을 적는다 — `skill:skill_LKS_original_multi-session-orchestration` 「master의 통합 책임」).

**완료 Phase 사후 수정 규약(`Phase N-rev`)**: 이미 종료된 Phase 에 사후 추가·수정이 생기면 새 Phase 로 만들지 말고 **`Phase N-rev`** 로 표기한다 — 해당 Step 이력 파일의 Phase 란을 `N-rev` 로 적고, 그 Phase Result 에 **Addendum**(결과 보호 원칙 — 덮어쓰기 X)을 단다. 스텝 이력은 **누적 번호 그대로** 잇는다(리셋 없음). 이렇게 out-of-band 추가도 추적 가능하게 남긴다.

#### 2c. 스텝 이력 — step 완료 시 즉시 기록

cumulative step 하나 마칠 때마다 Phase 종료 기다리지 않고 즉시 `Claude/results/Step <N> — <제목>.md` **한 파일로** 저장한다. 단일 통합 파일(`<plan-name>_STEP_LOG.md` 류)이 아니다 — **step 하나 = 파일 하나.** `<N>` 은 마스터 플랜 전체를 통틀어 **Phase 무관 단조 누적**(리셋·되돌림 금지, 파일명 번호가 절대 좌표). 다음 세션이 **이 파일만 읽고 이어받을 수 있게** 결론·결정(무엇을 왜 정했나)을 적는다(한 줄 요약 금지) — 영향 지도 전 행은 다시 적지 않고 지도를 만든 쪽의 커밋되는 기록(작업 A 면 그 work_log · master 면 그 발주문 또는 이 스텝 이력 · 스크래치에 두지 않음)을 가리키고, 명령 출력은 그 실행을 적은 기록의 판정 줄을 가리킨다(스크래치 경로는 명령 원 출력에만 — 스크래치는 휘발이라 판정 근거는 판정 줄)(기록 꼴 원본 = `skill:skill_LKS_original_multi-session-orchestration` 「세션 2 — 작업 sub」). 5항목:

- **수행** / **근거·판단** / **변경·생성 파일** / **게이트**(게이트 결과 — 명령 출력은 work_log 를 가리킴) / **다음**
- **근거·판단** 에 **읽은 범위**를 적는다 — 그 스텝에서 판단의 근거로 읽은 파일·줄 범위(서브가 읽었으면 그 서브 work_log·보고의 범위 — 서브의 컴팩션 뒤면 규칙 파일 재독 + 서브 몫 재독 범위 · 컴팩션·세션 재개 뒤면 복구 읽기[규칙 파일 재독 + 6-check] 범위 포함). 없으면 그 스텝은 미완이다(규범 원본 = `memory:feedback_full_file_read_required` 「읽은 범위를 기록한다」).
- 스텝 이력·요청 대장·진행 보고에 적는 시각은 적기 직전에 시계(`date`)로 확인한 값이다 — 어림 표기(`15:0x` 류)로 적지 않는다. 커밋 전에 master 가 자기 기록에서 어림 꼴(`\d:\dx`)을 찾아 고친다(훅·알림이 아니라 master 가 직접 읽는 확인). 스텝 이력·요청 대장에 화면에 낸 답·진행 표를 적을 때는 그 글이 화면에 나간 시각을 세션 기록의 글 행에서 확인해 적는다 — 없으면 「답 없음」.
- 무언가를 고친 스텝이면 **근거·판단** 에 **영향 지도 요약 표**(① 치환 한 줄 꼴 포함 · `memory:feedback_change_impact_analysis` · 곳 · 영향도[함께 고침/확인만/영향 없음] · 이유 — 전 행[유형·찾은 방법 포함]은 지도를 만든 쪽의 커밋되는 기록 — 작업 A 면 그 work_log · master 면 그 발주문 또는 이 스텝 이력 — 에 두고 요약 표는 그 자리를 가리킴 · 스크래치에 두지 않음)를 둔다 — 표가 없으면 그 스텝은 미완이다(`memory:feedback_change_impact_analysis`).

**병렬 스텝 예외 (병렬은 승인 시에만·default 직렬 — 헌법 §1-병렬 게이트):** 승인된 병렬 스텝을 서브에이전트로 실행하는 경우, 각 서브 산출물 파일 + 그 묶음을 통합하는 스텝 이력 파일 하나로 기록할 수 있다 — 병렬 스텝마다 개별 `Step <N> — <제목>.md` 를 강제하지 않는다. 단 통합 스텝 파일이 각 서브 산출물의 경로·결과를 담아 다음 세션이 전부 이어받을 수 있어야 한다(복구 가능성이 기준, 파일 개수 아님). 직렬 스텝은 그대로 step 하나 = 파일 하나.

#### 3계층 기록 — 목적이 다르다, 대체 불가

| 계층 | 시점 | 단위 | 무게 | 목적 |
|---|---|---|---|---|
| Result 문건 | Phase 완료 시 1회 | Phase | 무거움(12항목) | Phase 종합 보고(파일 · 화면의 Phase 정리 보고는 1z) + 진입 게이트 |
| 자연 단위 ledger 행 | 자연 작업 단위 완료 시 | 자연 단위 | 중간 | 품질 검수 — 복붙=완료 방지 |
| 스텝 이력 | cumulative step 완료 시 | step 하나 = 파일 하나 | 5항목 · 결론·결정·지도 요약 | 컴팩션 대비 — 다음 세션이 이 파일만으로 이어받기(결론·결정 기준 · 전 행·출력은 work_log 를 가리킴) |

#### 2c-2. 사용자 요청 대장 (사용자 발화 추적 — 실행 기록과 별개 축)

본격 작업에서는 사용자 발화(요청·지시·결정·수정)를 Phase 마다 파일 `Claude/results/REQUEST_LEDGER_phase<ID>.md` 에 한 행씩(번호·일시·받은 시각·요지·반영 위치·마스터 플랜 반영·세부 계획서 반영·상태·근거) 쌓아 지침 반영 여부·위치를 추적한다 — Phase 착수 때 새 파일을 열고 앞 Phase 파일의 끝나지 않은 행만 이어 적는다(번호 그대로 · Phase 구분 없는 작업은 파일 하나) · 행 삭제 없이 상태만 갱신한다. 모델·설정·결정을 답하거나 제안하기 전에 지금 Phase 대장 파일을 먼저 본다(지난 Phase 파일을 읽는 때 = `references/record-formats.md`). 「늘 지킬 제약」(마스터 플랜 Current Ground Truth 아래 소절)에 적는 사용자 명령마다 처리 갈래(일반 규칙=지침 반영 계획 / 작업 한정=근거 원문 / 애매=결정 대기)를 정해 적는다 — 갈래 없이 「제약」으로만 두지 않는다. 양식·컬럼·상태 기호·갈래 원본 = `references/record-formats.md`.

**적는 시점 = 받은 그 자리에서(원본).** 사용자 결정·지시를 받으면 다음 발주·편집에 앞서 이 대장 행을 적고(그 메시지의 답은 이 기록과 하던 일을 그 턴에서 이은 뒤 그 턴의 마지막 글로 — 원본 = `memory:feedback_communication_style` 원칙 6), 결정의 원본·이력은 이 대장 한 행이다 — 대장을 마스터 플랜에 통째로 옮겨 적지 않는다(결정 대장 사본을 두지 않음 · 문건 성격이 다름). 그 결정이 기획 내용(범위·Phase 구성·Non-goals·구현·Test Plan·Assumptions·Decisions Required 등 마스터 플랜에 담긴 것 무엇이든)을 바꾸면 마스터 플랜의 그 자리(전제·범위가 바뀌면 Correction History 도)를, 스텝이 바뀌거나 새 작업이 생기면 그 Phase 세부 계획서 Step(1j)·Ledger 행(Ledger 가 있을 때)을 같은 자리에서 고치고, 대장 행의 「마스터 플랜 반영」·「세부 계획서 반영」 칸에 표시한다(행은 지우지 않고 이력으로 남긴다). Phase 끝·나중으로 미뤄 몰아 쓰지 않는다 — 그 사이 컴팩션이 오면 적지 않은 결정은 요약으로만 남아 복구 근거가 사라진다(복구 때 대조 = `memory:feedback_compaction_recovery` 6-check 1). 컴팩션 직후 대조에서 찾은 빠진 요청도 같다 — 그 대장 한 행은 세션 기록 원문 옮기기라 6-check 를 마치기 전에 적고, 그 밖 편집은 6-check 뒤다(master 몫 — 컴팩션된 서브는 요청 대장·계획 문건에 쓰지 않는다 · 원본 = `memory:feedback_compaction_recovery` 「핵심 원칙」 머리 문단).

#### 2d. Result 12항목 · 2e. Ledger 12-column

- **Result = 12항목**(항목 목록 원본 = `references/record-formats.md`). **Read Coverage 에 실제 읽은 행/페이지를 명시하지 못하면 "정독했다"는 주장은 무효.** Result 는 스텝 이력을 가리키고 다시 적지 않는다 — 그 Phase 의 종합(결론·게이트 결과·남은 것)과 스텝 이력 경로만 적는다(Read Coverage 의 범위 명시는 그대로 · 항목별 꼴 = `references/record-formats.md`). Phase result 는 **md + json 쌍 저장(필수)** — json 은 같은 내용의 기계 판독본(컴팩션 복구·게이트 검사용).
- **Ledger = 12-column**(열 목록 원본 = `references/record-formats.md`). 장기 작업(phase≥3 또는 step≥20)에서 `Claude/results/PHASE_<range>_EXECUTION_LEDGER.md` 에 둔다. **검증·재검증의 비용(중대·중간 수·서브 비용 네 종류[캐시 안 된 입력·캐시 쓰기·캐시 읽기·출력]·시간)은 그 Phase 행의 Validation 열에 적는다**(열을 늘리지 않고 기존 열에 · Ledger 가 없는 짧은 작업은 그 검증·재검증 스텝 이력의 「게이트」 항목에 · 자리 원본 = `references/record-formats.md` · 규범 원본 = `memory:feedback_chunked_review`).
- 항목·열 목록·컬럼 정의·정정 문건 필수 항목·완료 주장 검증표 상세 = `references/record-formats.md`.

#### 2f. 단위 구성 루프 (자연 작업 단위별 — 통째 배치 금지)

step 안에서 산출물을 구성하는 **단위 루프 규범** — 자연 작업 단위별 6단계(정독→구성·수정→자체검수→앞 단위·기반 정합→빌드·검증→ledger 사유) · 통째 배치 완료 금지(검수 입도 = 자연 단위) · 복붙·무수정 ≠ 완료 · 완결성 orphan 0(앞 도입·뒤 사용) · 통합 산출물 규율(recap 비계 0) · 단위별 8항목 체크리스트 — **규범 원본 = `memory:feedback_unit_loop` · 본 스킬은 그 규범을 집행하는 절차·양식을 소유한다.**

## 검증

- 저작 게이트 = 1f 작성 전 확인 7단계 완료 · 1g load-bearing 전제 대조(거짓 전제 = STOP·재baseline) · 1b 섹션명·순서 보존.
- 계획서 실물(`Claude/plans/YYYY-MM-DD-<topic>-plan.md`) 존재가 본격 작업 착수의 전제다 — 대화 본문만으로는 미완.

### 3a. Gate 설계 — 확인 가능한 조건만

Gate = 명령(실행 가능) + 증거(외부 검증 가능) + 범위(정량적). "적절해 보임" 류 정성 판단은 gate가 아님. 정성 판단 불가피 시 판단의 구성 요소를 명시적 항목으로 분해 (예: "부호·단위·독립변수·boundary condition 명시 + 4-tier 분류").

### 3b. 완료 주장 유형별 검증표

완료 주장(테스트 통과·lint·빌드·버그 수정·회귀·sub 완료·요구사항)마다 "실제 필요한 증거 vs 불충분한 근거"를 대조한다 — **불충분한 근거로 완료 주장 시 gate 미통과.** 유형별 증거 표 원본 = `references/record-formats.md`.

### 3c. Phase audit — 10차원 × 3-Pass

매 phase = [작업 commit] + [검토·정정 commit] 페어. 한 commit에 작업+검토 뭉치면 누적 오류 묻힘.

10차원(**코드 phase 한정**): 1. 시그니처 호환성 2. 사용자 요청 3. 데이터 흐름 lifecycle 4. 워커 lifecycle 5. 시그널·슬롯 정합 6. 컨벤션+인라인 라벨 잔존 7. 에러 처리/silent failure 8. 프레임워크 API 정확성 9. 메모리 흐름 10. 데이터 구조 contract (+ phase 특화)

문서·설정·덱 phase는 코드 10차원 대신 **문서 렌즈셋(이 목록이 원본)**을 쓴다: 사실 정합 · 출처/번호/카운트 일치 · orphan 0(앞 도입·뒤 사용) · 라벨·용어 잔존 · follow-ability · usability. 적용되는 축만 돌리고 해당없는 축은 1회만 "N/A" 로 명시(매 항목 반복 금지).

코드 10차원과 이 문서 렌즈셋은 §3 검증의 **가변 5 관점 후보에 든다** — 그 프로젝트의 핵심 위험에 해당하는 항목을 마스터 플랜 Test Plan 「검증 관점」 표의 가변 5 로 골라 올린다(가변 5 후보 목록 원본 = `memory:feedback_chunked_review` 「가변 5」 · 고정 5 프리셋 P1~P6 은 대상 종류로 따로 고름).

**Phase audit = 그 Phase 산출물의 §3 검증을 가리킨다 — 더하는 검증이 아니다.** 유닛에서 검증(그 갈래의 검수 — ③ 10라운드 · 그 밖 갈래별 한 번)·재확인을 이미 마친 산출물은 그 검증 기록(처리표 · Ledger Validation 열)이 곧 Phase audit 이고 다시 돌리지 않는다. A1·A2 본격 산출물 가운데 유닛 검증을 거치지 않은 것만 Phase audit 가 그 검증을 한 번 돈다(A3·A4 산출물은 자체검수 1회가 그 검증이라 10라운드를 새로 돌리지 않고 · master 경량 산출물은 대상이 아니다 · 등급 연동 원본 = `memory:feedback_chunked_review` 「적용 조건」) — 3-Pass = Pass 1 발견(그 갈래의 검수 · 범위 = 바뀐 단위 + 영향 지도 단위 · 넓게 나열, false positive 허용) → Pass 2 확정·수정(master 가 인용 줄을 원문에서 확인해 중대·중간을 재현·확인 → 영향 지도 → 같은 작업 A 가 한 발주로 수정) → Pass 3 재검증(같은 검수 B · 회귀 없음 확인, 본문 정독 의무) — 갈래·종료·재검증 범위 규범 = 헌법 §3·`memory:feedback_chunked_review`.

소규모 phase(변경량 <30라인 + 단순)도 result 보고서(Read Coverage 포함)는 필수다. commit·push·merge 타이밍은 CLAUDE.md 원본(품질·원천·git)을 따른다.

## 예외·금지

- 간단한 상태 확인·단일 명령·단순 질문에는 불요(적용 조건 6항 중 하나라도 걸리면 저장 · 애매하면 저장 쪽). 단, 사용자 요구 시 무조건 문서로 저장한다.
- 섹션명을 Context/Objective/Scope 등으로 임의 개명하지 않는다(1b).

### 4. 결과 문건 보호

이전 phase의 result·ledger·handover·계획서 같은 이력 기록물은 immutable history로 취급하여 덮어쓰기·삭제를 금지한다. 정정 시 새 문건을 생성한다. 사용자 원천 자료는 기본적으로 보존하되, 사용자가 원천 자료의 갱신·삭제를 명시하면 그 지시를 따른다.

정정 패턴(Addendum / Supersession / Correction)의 파일명·사용 시점, 그리고 정정 문건 필수 항목 원본 = `references/record-formats.md`. 사용자 별도 지시가 없으면 원천 자료는 읽기 전용 사본으로 작업한다. 작업물 보호 일반 규범(git 폴더 운용·git 밖 사본·파괴 전 복원 지점·침범 시 복원/중지)의 원본 = `memory:feedback_workspace_git_safety`.

## 관련 문건

- `skill:skill_LKS_original_multi-session-orchestration` — 유닛 분업 운용·서브 스폰(도구·모델·effort 배정·5항목 고지)
- `skill:skill_LKS_original_review-chunking` — 검증 절차(갈래별 검수 — ③ 구조 변경 10라운드 · ①·②·④ 한 번 · 3c Phase audit 가 가리키는 §3 검증)
- `skill:skill_LKS_original_project-scaffold` — `Claude/plans/` 저장 위치 · 구조 맵 유지·갱신
- `skill:skill_LKS_original_ocr-image-extraction` — 이미지 판독·추출 (OCR 엔진 교차검증 포함)
- `skill:skill_LKS_original_visual-design` — LaTeX 문서 작업 <!--profile:inhouse-->
- 관련 memory: `memory:feedback_unit_loop`(단위 루프 규범 원본), `memory:feedback_compaction_recovery`(컴팩션 복구 6-check·읽기 순서), `memory:feedback_handover`(인계 기록), `memory:feedback_confirmed_items_policy`(4-tier 보고), `memory:feedback_full_file_read_required`(정독·Read Coverage), `memory:feedback_post_edit_runtime_verification`(런타임 검증), `memory:feedback_planning_vs_execution`(기획 단계에서 명시적 GO 대기), `memory:feedback_flow_interruption`(계획은 md·자동 EnterPlanMode 금지), `memory:feedback_code_ownership_scope`(편집 시 본체 보존), `memory:feedback_code_comment_discipline`(코드 주석 규율)

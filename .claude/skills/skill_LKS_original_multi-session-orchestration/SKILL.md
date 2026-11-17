---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_original_multi-session-orchestration
description: >
  Use when a substantial task (code change, document build, data build)
  warrants dividing work across subagents, and again just before the unit
  spawns one — the 3-session unit of master (context/plan/integration/commit)
  + implementation sub + audit sub, the same two subs kept through fix and
  re-check (the implementation sub waits for the audit report). Covers role
  boundaries, single-unit
  operation with fan-out held back, iteration limits, operating parameters,
  file-based handoff, the tool/model mapping per session stage, per-subagent
  effort, and the mandatory 5-item role/boundary/no-false-attribution notice
  on every spawn. Not for lightweight one-off tasks.
  본격 작업의 유닛 설계 시(① 절)와 첫 서브 스폰 직전(② 절) 모두 로드한다.
  트리거: 분업, 유닛, 3세션, 서브에이전트, 서브 스폰, spawn, 모델 배정, effort,
  sub prompt, 고지 의무, 검수 sub, 파일 기반 인계.
metadata:
  type: method
---

# Multi-Session Orchestration (유닛 운용·서브 스폰)

본격 작업(사용자 코드 변경이 포함된 작업, 대형 문서 빌드, 데이터 빌드)을 서브에이전트로 분업할 때의 상세 레이어 — 세션별 역할, 3세션 흐름, 반복 파라미터, 파일 기반 인계, 그리고 서브를 실제로 스폰할 때의 도구·모델 배정과 고지 의무. 본격 공정의 상위 원칙은 헌법 §1 세션 분업이다. 유닛을 설계할 때는 「① 유닛 설계」를, 첫 서브를 스폰하기 직전에는 「② 첫 스폰 직전」을 따른다.

## 적용 조건

경량 작업(1-line fix, 정보 조회, 파일 정독, 메모리 갱신)은 master 가 직접 처리하고, A3·A4 등급(정형 실무·단순 수정·반복 검수·기계 작업)은 단일 서브로 처리한다 — 둘 다 이 3-세션 모델을 강제하지 않는다. **경량인지 애매하면 본격으로 취급하고, 사용자가 계획서·마스터플랜 수립을 명시 지시한 작업은 규모와 무관하게 경량이 아니다**(헌법 「방법론 필수」 ③과 동일 규범). 검수가 찾은 결함의 고침은 한 줄이어도 경량도 A3(단순 수정)도 아니다 — 같은 A 가 고치고 같은 B 가 확인한다(원본 = `memory:feedback_session_division` 「적용 조건」).

A1·A2 등급 본격 작업(사용자 코드 변경이 포함된 작업, 대형 문서 빌드, 데이터 빌드)을 서브에이전트로 분업할 때 적용한다. 서브를 생성하고 모델·effort 를 배정하고 sub prompt 를 쓰는 시점에는 「② 첫 스폰 직전」을 함께 적용한다.

## 핵심 원칙

### 왜 3세션인가

단일 세션이 작업 + 검수를 모두 하면 자기 결과를 자기가 검사하는 셈이라 같은 blind spot으로 누락이 남는다(예: 컨벤션 전제가 통째로 누락). 세션을 분리하면 cross-check가 강제된다.

이 모델은 master(총괄) + 작업 sub + 검수 sub 의 3세션으로 구성한다. 검수 sub 는 코드 품질·정합 검사와 사용자 사양·의도 대조를 함께 수행한다 — 사양 대조를 위해 별도 세션을 더 두지 않으면서 두 검증을 모두 유지한다.

### 자의 병렬 억제 — 동시 1 유닛이 기본 (병렬은 승인 시에만·기본 직렬)

이 3-세션 한 벌 = **1 유닛{master + 작업 sub (+검수 sub)}** 이고, **동시에는 1 유닛만 운용하는 것이 기본**이다. 유닛을 여러 개로 동시에 늘리는 **fan-out(유닛 복수화)은 승인(마스터플랜 §11 sign-off·사용자발 명시) 시에만** — 모델 자의로 늘리지 않는다. **게이트 = "(carve-out 아닌) 유닛을 2개 이상 동시 운용"**: 한 유닛의 A·B 는 번갈아 돌아 동시에 도는(live) 서브가 ≤1개 → **동시에 도는 (carve-out 아닌) 서브 수 = 동시 운용 유닛 수**이고(B 를 기다리는 A·끝난 서브는 돌지 않아 세지 않는다 · 셈 원본 = `memory:feedback_session_division` 「병렬」), **청크 병렬처럼 서브를 2개 이상 동시에 돌리는 것은 곧 유닛 복수(fan-out)**라 같은 게이트다(자의 금지·승인 시에만·기본 직렬 · "유닛 내부 동시 다중 서브"라는 범주는 없다 · 판정은 개념 자기분류 아닌 도는 서브 수 관측). 단 **작업↔검수 sub 의 cross-check 는 게이트 밖이다** — 검수가 작업 산출을 받아 뒤이어 도는 **순차** 역할 분업이지 동시 병렬이 아니다(1 유닛의 정상 구성 · 도는 서브 ≤1). 규범 원본 = 헌법 §1 · `memory:feedback_session_division`.

### 스폰은 명세·모델·경계를 실은 위임이다

모델은 난이도가 아니라 업무 종류(A1~A4·B)로 고정 배정하고(원본 = 헌법 「모델·아티팩트 운용」), 모든 spawn prompt 에 5항목 고지를 싣는다(원본 = `memory:feedback_session_division`).

## 실행 방법

### ① 유닛 설계

#### 세션 1 — master (총괄, 사용자가 직접 대화하는 세션)

- 전체 맥락 보유: 작업 지시문 원문, 인계, 사용자 답변·정정, 이미지에서 추출한 코드, 매뉴얼.
- 계획(Plan)·주의할 점(Cautions)·확인할 점(Checkpoints) 보유.
- 사용자와의 모든 검토·확인·GO 사인 교환 담당.
- 본격 작업·검수는 직접 수행하지 않고 서브에 위임한다.
- 서브 결과를 받아 최종 통합 + 최종 검수 책임.
- **Commit 권한 = master 전용.** 작업/검수 sub는 commit 권한이 없다 — 작업 sub 는 변경·work_log 작성만 하고, 검수 sub 는 검수 보고를 반환 글로 돌려준다(읽기 전용 정의라 파일을 쓰지 않는다 · master 가 받아 핸드오프 폴더 `iter_<n>/audit_log.md` 에 저장). 스텝이 끝나면(스텝 체계가 없는 작업은 작업 토픽이 끝나면) master 는 사용자 매번 명시 없이 스텝 끝 commit 을 자율 수행한다(스텝 도중에는 커밋하지 않는다 — 예외 = 위험 전 복원 지점 커밋 · 세션을 넘기기 전 인계 커밋 · 원본 = 헌법 「품질·원천·git」). commit·push·merge 타이밍은 CLAUDE.md 원본을 따른다. **커밋 규칙 나누기** — 같은 컨테이너에서 Agent 도구로 띄운 서브(작업·검수)는 파일을 함께 보므로 커밋하지 않는다. 다른 컨테이너·다른 도구·다른 AI 로 도는 작업자(`create_session`·워크트리·Codex 등)는 자기 브랜치·워크트리에만 커밋·푸시하고(메시지에 자기 출처), 통합(작업) 브랜치 반영은 master 만 한다(검토 뒤 merge·cherry-pick).

#### 세션 2 — 작업 sub (Implementation)

- 입력: master가 정리한 작업 명세(변경 대상 파일·라인·로직, 보존 규칙, 컨벤션). 고침 때는 검수 보고 원문(파일:줄 + 원문 인용)·고칠 곳 판정(영향 지도)·「이미 정한 것」 — 보고를 입력 삼아 고치지 않고, 보고가 가리킨 파일을 직접 열어 고친다(그 파일을 context 에 전문으로 갖지 않은 A — 새 세션·컴팩션 뒤 — 는 먼저 전문으로 읽는다).
- 출력: 산출물·구성 결과(코드 변경분 / 문서 절 / 데이터 블록) 모두 diff, 그리고 work_log(실행 출력 절 = 실행한 명령과 판정 줄 · 판단 근거로 읽은 파일·줄 범위). **work_log 기록 꼴(원본)** — 명령은 그대로 적고, 출력은 판정에 쓰는 줄만 적는다(통과 = rc·개수 한 줄 · 실패 = 결정적 오류 줄) · 원 출력이 필요하면 스크래치 파일 경로만 적고 붙여 넣지 않는다(스크래치는 휘발이라 세션이 바뀌거나 컨테이너가 회수되면 원 출력을 다시 볼 수 없을 수 있다 — 판정 근거는 work_log 에 적은 판정 줄이다) · 읽은 범위 기록은 줄이지 않는다. 영향 지도를 만든 작업 sub 는 그 전 행(곳·유형·찾은 방법·영향도·이유)을 work_log 에 두고(스크래치 경로에 두지 않음 · master 가 만든 지도는 그 발주문 또는 그 스텝 이력), master 스텝 이력은 요약 표로 그 자리를 가리킨다(`skill:skill_LKS_original_plan-execution` 2c).
- 자체검수: 검수가 붙는 작업이면 발주문이 정한 게이트만 본다 — 코너 케이스·폴백·경계 조건 찾기는 검수(세션 3) 몫이고, 검수가 없는 작업이면 자체검수에 함께 넣는다.
- 반환 뒤: 서브는 반환하면 멈추고 master 는 이 세션을 닫지 않는다 — 보고가 오면 master 가 이 세션을 다시 불러 넘긴다(이어받을 상태는 반환 글·work_log 에 · 아래 「3세션 흐름과 반복」).
- 도구: Edit, Write, Read, Grep, Bash(검증).
- 권한 영역: 무변경 영역(예: UI 껍데기 / 사용자 코드 보존 영역)을 명시받아 그 밖은 손대지 않는다.

#### 세션 3 — 검수 sub (Quality Audit + Spec Review, 겸임)

- 입력: **대상 파일 + 연계 파일**(세션 2 가 만들거나 고친 파일 + 영향 지도에서 「함께 고침」·「확인만」 곳이 든 파일 — 전부 새로 쓴 산출물이면 그 산출물이 기대는 기존 파일 + 사양 대조에 필요한 사용자 사양 문건 — 작업 지시문·인계·이미지 본문·매뉴얼 가운데 해당하는 것)을 **파일 단위 전문**으로 · 발주문 안의 「이미 정한 것」과 영향 지도 표 · 작업 기록은 그 대상의 실행 출력 절 경로만. 패키지 전체·대상 밖 기록(작업 기록 전부·앞 보고 전부)은 넘기지 않는다(원본 = `memory:feedback_chunked_review` 「검수 입력」).
- 출력: 검수 리포트 — 결함마다 파일:줄 + 원문 인용(결론 요약 아님) · 큰 파일은 창(~500줄)을 차례로 읽고(창마다 서브를 두지 않는다) 창마다 발견·읽은 범위. 두 축을 함께 다룬다.
  - **품질·정합 축**: linter(예: ruff/F821) 경고, cold import, 시그니처 정합, 시그널 connect 정합, silent failure, 컨벤션 준수, 누락된 변경 식별.
  - **사양·의도 축**: 사용자 의도 vs 실제 구현 차이, 인계가 명시한 미완료 항목의 처리 여부, 사용자 정정 사항(추가 지시·Q&A)의 반영 여부.
- 도구: Read, Grep, Bash(linter/test), 필요 시 WebFetch.
- 검토 subagent: 정의 이름으로 띄운다 — 검수 B = `bada-a3-reviewer`(기본) · 고가치·reference·기계검증 약한 산출물이면 그 검수 B 자체를 `bada-b-auditor` 로 띄워 10라운드 전부를 돈다(적대 관점 = 그 10라운드 가운데 한 라운드 · 적대용 서브를 따로 띄우지 않는다 · 둘 다 읽기 전용 · 모델·effort 는 정의가 고정 · 아래 「② 첫 스폰 직전」 표). prompt 에 그 라운드의 관점 하나 + refute mandate + "빈 통과 금지"(발견은 등급으로 적는다) 명시. 관점·청크 상세는 `skill:skill_LKS_original_review-chunking`.

#### master의 통합 책임

- 세션 2·3 결과를 순차로 수신(검수는 작업 산출을 입력받아 뒤이어 돈다 — 동시 실행 아님).
- 충돌·차이가 있으면 master가 결정한다 — 사용자 의도와 우선순위에 맞춰. 단순 병합 금지.
- 최종 결과(변경분 + 검수 통과 + 사양 대조 OK)를 사용자에게 보고.
- 서브가 적은 읽은 범위·실행 판정 줄은 서브 기록(`subagents/agent-<agentId>.jsonl` 의 `Read`·`Bash` 도구 호출과 결과 — `Read` 가 실제로 보인 줄 범위와 잘림 표시[「PARTIAL view」 등] · `Bash` 결과 끝 줄)과 기계로 대조한다 — 다시 돌리지 않는다(명령 = `references/model_effort_sample.md` 「서브 기록 대조」 · 어긋나면 그 서브 산출을 열화 반환으로 다룬다).
- 스텝 끝(스텝 체계가 없는 작업은 작업 토픽 끝) → 스텝 끝 commit(master가 직접). commit·push·merge 타이밍은 CLAUDE.md 원본을 따른다.

#### 3세션 흐름과 반복

```
1  메인 (총괄)
2   | brief
3   ▶
4  작업 sub A ⇄ 검수 sub B  ← 끝까지 같은 A·B · 재작업 왕복 (재작업 왕복 max_iter=5 — 진동 판정과 다른 셈 · 넘기면 master 가 다시 보고 계속 여부를 정함 · 사용자에게 묻지 않음 · 정지 아님) · 검수 라운드 회계는 별도(§3)
5   | 최종 결과 (검수 통과 + 사양 대조 OK)
6   ▶
7  메인 (총괄) — 통합 + 사용자 보고
```

**같은 A ↔ 같은 B 왕복**(규범 원본 = `memory:feedback_session_division` 「같은 A ↔ 같은 B」):

1. master 가 작업 A 에 발주 → A 가 만들고 work_log 와 함께 반환한다(반환하면 멈춤 · master 는 A 를 닫지 않고 다시 부를 때까지 둔다).
2. master 가 검수 B 에 발주한다(입력 = 대상 파일 + 연계 파일 전문 · 위 「세션 3」) → B 가 보고한다.
3. master 가 B 의 인용 줄을 원문에서 확인해 중대·중간을 재현·확인하고, 영향 지도로 고칠 곳을 판정한다(요약으로 결론 내지 않는다).
4. master 가 **같은 A 를 다시 불러** B 보고 원문 + 고칠 곳 판정 + 「이미 정한 것」을 넘긴다 → A 가 그 파일을 직접 읽고 한 번에 고친다. 진짜 단순한 단어 치환·오탈자는 A 를 부르지 않고 master 가 직접 고치고 master 확인으로 끝낸다.
5. master 가 **같은 B 를 다시 불러** 바뀐 단위 + 영향 지도 단위를 전문으로 재확인하게 한다(범위 원본 = `memory:feedback_chunked_review` 「재검증」) → 남은 중대·중간이 있으면 4 로(아래 진동 규칙).
6. 재확인에서 남은 중대·중간이 0 이면(검수[그 갈래의 검수 — ③ 10라운드 · 코드 ③ 3라운드 · 그 밖 한 번]에서 중대·중간이 0 이면 3~5 를 건너뛰고) 그 유닛은 끝난다 — 경미는 목록으로 모아 최종 보고에 싣고, 끝난 A·B 는 돌지 않아 병렬 셈에 들지 않는다. 같은 Phase 안의 다음 유닛도 같은 역할 세션을 다시 부른다(context 크기와 관계없이 · 컴팩션되면 그 세션이 입력을 다시 전문으로 읽고 이어 감 · Phase 가 바뀌면 새 서브 — 아래 · 원본 = `memory:feedback_session_division` 「같은 A ↔ 같은 B」).

새 세션을 띄우는 때 넷(역할 세션이 없음 · 끊김 · 예산 바닥 · Phase 바뀜 — 컴팩션은 새 세션 사유가 아니다)과 그때 넘길 입력의 원본 = `memory:feedback_session_division` 「같은 A ↔ 같은 B」(검수 B 입력 = `memory:feedback_chunked_review` 「검수 입력」). 컴팩션된 세션을 계속 쓰면 편집·판정 전에 발주문이 입력으로 정한 파일·기록을 전부 다시 전문으로 읽고 그 범위를 적게 한다. B 가 없는 작업(A3·A4)은 작업 서브의 자체 확인 그대로다.

**다시 부르는 법 · 세션 대장.** 끝난 서브는 새로 띄우지 않고 그 서브에 이어 보낸다 — 이 런타임은 `SendMessage`(받는 곳 `to` = 띄울 때 준 이름, 없으면 띄운 결과의 `agentId` · 보내면 그 서브가 자기 기록에서 이어 깬다 · 실물 = `references/model_effort_sample.md` 「다시 부르기 · 서브 상태」). 새 Agent 호출은 새 세션이라 다시 부르기가 아니다. 부를 서브는 핸드오프 폴더의 세션 대장 `SESSIONS.md` 에 Phase 마다 새 절로 적는다(Phase 가 바뀌면 새 절을 열고 그 Phase 의 새 서브를 적는다 · 앞 절의 서브는 다시 부르지 않는다) — 역할 · 정의 이름 · 이름·`agentId` · 맡은 대상 · 읽은 영역 · 컴팩션 횟수 · 마지막 context(토큰) · 상태(도는 중·대기·끝). master 가 띄우거나 다시 부를 때마다 그 자리에서 고치고(휘발 스크래치에 두지 않는다), master 컴팩션 뒤 복구 읽기에서 이 대장의 지금 Phase 절로 A·B 를 찾는다(`memory:feedback_compaction_recovery` 「복구 읽기 순서」).

**두 회계는 별개 축이다** — **검수 라운드는 검증 축**(그 갈래의 검수 · ③ = 관점 10개로 10라운드 · 검수 뒤 같은 A 가 고치고 같은 B 가 재검증 · 규범 원본 = `memory:feedback_chunked_review` 「검수 구분」·「재검증」 · 기록 자리 = `skill:skill_LKS_original_plan-execution` 의 `references/record-formats.md` · 절차 = review-chunking)으로 세고, **max_iter=5 는 작업 sub 재작업 왕복**(검수 발견을 반영한 재투입)의 한도다. 결함 없는 라운드 진행은 max_iter 를 소모하지 않는다. 재검증에서 중대·중간이 직전보다 줄지 않으면(진동) 멈춰 사용자 개입을 요청하지 않고 덧대기를 멈춰 공통 원인(구조·설계) 수정으로 전환한다. 왕복 5회를 넘기면 master 가 그 유닛의 결함 추세·원인을 다시 보고 계속할지(원인 수정으로 계속 · 그 결함이 걸린 산출을 만들지 않고 최종 보고로 넘김)를 정한다 — 사용자에게 묻지 않는다 — 원인 수정 뒤에도 남으면 그 결함과 추세 데이터를 Result·최종 보고에 싣고, 그 결함이 걸린 산출은 만들지 않고 최종 보고에서 결정한다(진동 규범 원본 = `memory:feedback_chunked_review`).

#### 운용 파라미터

- **중간 보고 빈도:** 스텝·토픽이 끝날 때마다 master 는 사용자에게 진행 표 하나(Step·토픽·예상(시작 때)·실제·실제/예상·결과 · 표 아래 합계·남은 순서 줄 없음 · 행은 그때 끝난 스텝만 · 표 밖 멘트 없음)로 짧게 알리고(스텝 완료 시 보고 · 그 턴의 마지막 글로 · 모아 내지 않는다) — 보고는 알림이지 승인을 묻는 질문·정지가 아니다(사용자 답을 기다려 일을 멈추지 않는다 · 형식 원본 = `memory:feedback_communication_style` 원칙 6 · 정지 조건에 걸리면 그때는 멈춘다). Phase 가 끝날 때마다 그 Phase 정리 보고는 표가 아니라 말(평문)로 올린다(같은 원칙 6). 의사결정 요청과 검수 종합은 사용자가 지시한 업무를 끝까지 수행한 뒤 최종 보고(마스터 플랜이 있으면 그 전부가 끝난 뒤의 최종 작업 보고)에서 한 번에 낸다(검수 결과 + 평문 결정 요청 · 결정 요청은 진행 표에 섞지 않는다). 잦은 중단은 자동화의 의의를 퇴색시킨다.
- **턴 도중 사용자 메시지 · 기다리는 턴:** 턴 도중 도착한 사용자 메시지(앱이 도구 결과 뒤에 싣는다)는 그 턴 안에서 답한다(답 = 그 물음의 답만 · 그 턴의 마지막 글로 — 도구 호출 사이 글은 화면에 남지 않는다 · 원본 = `memory:feedback_flow_interruption` 「사용자의 추가 지시는 정지가 아니다」 · `memory:feedback_communication_style` 원칙 6). 세션 기록의 대기열(`queue-operation` enqueue 행)은 스텝이 끝날 때 한 번 대조해, 전달되지 않은 메시지가 있으면 그 턴 안에서 답한다(컴팩션·재개 뒤 대조 = `memory:feedback_compaction_recovery` 6-check ①). 서브를 띄우고 그 반환을 기다리는 턴의 마지막 글은 한 줄 「Phase <Phase>, Step <Step>, <작업> 작업 진행중」이다 — 그 턴에 사용자 메시지 답·진행 표가 있으면 그것들을 먼저 쓰고 그 한 줄을 맨 끝에 둔다(형식 원본 = `memory:feedback_communication_style` 원칙 6).
- **즉시 보고 트리거 — 위험 '지적'과 실제 '침범'을 구분한다:** 검수가 ① 사용자 컨벤션 충돌 / ② 사양 모호 / ③ 보호영역 침범 **위험**(아직 침범 없음) / ④ 본격 재설계 요구를 **지적**하면, 그 회차를 끝내고 다음 회차 진입 전까지 본 작업 단위는 끝까지 수행하되 종합 보고 시 명시한다 — 단일 지적으로 즉시 stop 하지 않는다(무중단 원칙 우선). 단 지적이 "이 다음 행위가 침범을 일으킨다"로 특정되면 그 행위는 실행하지 않고 우회·보류한다(알고 침범하지 않는다 — 침범 후 복원은 예방의 대체가 아니다). 반면 진행(작업 sub·master)이 **실제 침범**을 일으켰으면(보호 대상의 무허가 수정·삭제 발생) 회차 끝을 기다리지 않고 즉시 `memory:feedback_workspace_git_safety` ⑤대로 처리한다: (git·복원 지점 있음) 침범 없는 직전 커밋으로 복원 후 재진행(복원 사실은 종합 보고에 명시) / (비-git·복원 지점 없음·복원 불완전) 그 작업 단위 중지·보고 — 헌법 GO-후 정지 조건 「보호영역 침범」의 실행절차(무중단 원칙은 '위험 지적'에만 적용되고 '실제 침범'에는 우선하지 않는다). 서브가 침범을 일으켰으면 아래 「서브 실패·열화 반환 복구」대로 master 에 사실 반환(침묵 흡수 금지)·master 가 복원 후 brief 를 좁혀 같은 역할에 재-dispatch 한다.
- **서브 실패·열화 반환 복구:** 서브가 에러·타임아웃·빈/절단 반환·brief 범위 밖 산출·확신에 찬 오답으로 돌아오면, 그 결과를 침묵 흡수하거나 "서브가 이렇게 했을 것"이라 추정으로 보충하지 않는다(컴팩션 환각의 서브판 — 근거는 서브 반환 실물뿐). 원인을 명시하고 brief 를 좁혀 같은 역할에 재-dispatch 한다(살아 있으면 그 서브를 다시 불러 · master 직접은 재-dispatch 가 안 될 때만 사유를 적고 · 검수 발견 고침은 그때도 같은 A — 원본 = `memory:feedback_session_division` 「서브 열화 반환 복구」). clean 도 max_iter 도달도 아닌 비정상 종료는 clean 으로 세지 않는다.
- **격리(isolation):** feature branch 또는 worktree로 master 작업본을 격리 보호한다. master는 git reset으로 롤백 권한을 보유한다(롤백은 ⑤ 침범 복원 절차나 사용자 지시로). 이 격리·롤백은 `memory:feedback_workspace_git_safety`(위험 전 commit ②·침범 복원 ⑤)의 유닛 문맥 적용이다.
- **컨텍스트 전달(파일 기반):** 서브는 본 대화 컨텍스트를 가지지 않으므로 prompt가 self-contained여야 한다. 인계 문건·라인 인용·보존 규칙을 모두 prompt에 포함한다.
- **핸드오프 저장 위치 — 루트 하나:** 유닛이 주고받는 파일은 전부 `Claude/results/handoffs/<task-name>/` 아래에 둔다. Phase 단위 Result 문건과 구분되도록 이 폴더에 모으고, 다른 루트를 새로 만들지 않는다. 레이아웃:
  - `brief.md`
  - `iter_<n>/work_log.md`
  - `iter_<n>/audit_log.md`(검수 서브의 반환 글을 master 가 받아 그대로 저장)
  - `SESSIONS.md`(세션 대장 — 위 「다시 부르는 법 · 세션 대장」)
  - `TRIAGE_phase<ID>.md`(검수 발견 처리표 — Phase 마다 새 파일 · 머리에 「이미 정한 것」 누적 목록 · 검증마다 master 판정·「무엇을·왜」 · 양식 = `skill:skill_LKS_original_plan-execution` 의 `references/record-formats.md`)
  - `review.md`
  - `LOG_MANIFEST.md`(로그를 수집하는 경우 — `references/log_collection.md`)
- **핸드오프도 파일로, 본인 컨텍스트에 남기지 않는다:** master가 sub에게 넘기는 내용·sub가 master에게 돌려주는 내용은 전부 파일로 남긴다 — 작업 sub 는 산출·work_log 를 스스로 파일에 쓰고, 읽기 전용 검수 sub 는 반환 글로 돌려주면 master 가 받는 즉시 핸드오프 폴더에 원문 그대로 저장한다. 이후 판단·발주는 그 파일과, 그 파일이 인용한 줄을 원문에서 확인한 것을 근거로 하고(보고 요약만으로 결론 내지 않는다), master 자신의 대화 컨텍스트에 원문을 다시 붙여넣어 쌓아두지 않는다. 컨텍스트를 불필요하게 채우면 이후 판단 품질이 떨어지고 컴팩션 위험도 커진다.
- **검수 관점 원천:** `skill:skill_LKS_original_review-chunking`의 프리셋 표(P1~P6) + 가변 5 후보. 검증 규범(갈래별 검수 — ③ 구조 변경 = 관점 10개로 10라운드 · 조기 종료 없음 · 다 본 뒤 한 번에 고침 · 재검증)의 원본은 `memory:feedback_chunked_review` 이다(헌법 §3 = 요지 · 절차 = review-chunking) — 이 목록은 관점 원천이지 그 절차의 대체·완화가 아니다.
- **fix는 발견 전체를 한 서브에이전트에 묶어서 디스패치:** 검수에서 발견된 결함들을 건별로 개별 서브에이전트에 디스패치하지 않는다 — 서브 spawn 자체의 오버헤드(컨텍스트 재구성 비용)가 발견 1건 처리 비용보다 커지고, 서로 연관된 발견들을 따로 고치면 회귀가 나기 쉽다. 검증 1회(그 갈래의 검수)에서 나온 발견 전체를 하나의 fix 디스패치로 묶어 **이번 검증에 붙은 작업 sub 하나**(산출을 여러 작업 sub 가 만들었어도 · 그 sub 가 없으면 같은 역할 하나)에 되돌려 한 번에 처리한다(진짜 단순한 단어 치환·오탈자만 master 직접). fix 발주서에는 검수 보고 원문(파일:줄 + 원문 인용)과 앞 검증·수정에서 「이미 정한 것」 목록(무엇을·왜 — 처리표 `TRIAGE_phase<ID>.md` 머리의 누적 목록과 그 절들에서)과 §2-연계·영향의 영향 지도(연결된 곳·영향도)를 함께 실어(작업 sub 는 보고를 입력 삼지 않고 그 파일을 직접 읽고 고친다), 이미 정한 것을 근거 없이 되돌리거나 눈앞 한 곳만 고치는 것을 막는다(규범 원본 = `memory:feedback_chunked_review` · `memory:feedback_change_impact_analysis`).

#### 세션 시작·인계 정독 (신규·재개·인계 세션 진입 시)

세션 진입 정독 규율(정독 의무·인계 chain 실물 확인·멀티트랙 인계·프로젝트-local 우선·신규 문건 양식/위치 사전 확인)의 원본 = `memory:feedback_session_entry_reading`(헌법 「세션 시작」 줄이 always-on 참조). 위 「핸드오프 저장 위치」는 그 진입 정독을 전제로 한 분업 문맥의 인계 레이아웃이다.

#### 로그 저장 (적용 = 훈련 데이터를 수집할 때만)

그 작업에서만 `references/log_collection.md` 를 읽고 따른다(그 밖의 작업에서는 `LOG_MANIFEST.md` 를 만들지 않는다).

### ② 첫 스폰 직전

#### 도구·모델 매핑 — 세션 단계별 배정

역할별 모델 배분(Master·A1~A4·B·폴백의 정의·배정 대상·금지, 난이도가 아니라 업무 종류로 고정 배정)은 **CLAUDE.md "모델·아티팩트 운용" 지침을 원본으로 따른다.** 아래는 그 배분을 3-세션 흐름의 각 단계에 매핑한 것이다 — 모델·effort 는 **정의 파일**(`subagent_type`)이 고정하고, Agent 호출 인자 `model` 은 넘기지 않는다(아래 「모델·effort 지정」 절):

| 단계 | 역할 | 정의(subagent_type) | 모델·effort |
|---|---|---|---|
| 작업 sub — 코드 구현 | 설치기·도구·스크립트 | `bada-a2-coder` | Opus 5.5 · medium |
| 작업 sub — 문서 저작 | 지침·문서 편집 | `bada-a2-writer` | Opus 5.5 · medium |
| 작업 sub — 이미지 판독 | OCR·판독 | `bada-image-reader` | Opus 5.5 · medium |
| 작업 sub — 정형 | 정형 실무·단순 수정 | `bada-a3-worker` | Opus 5.5 · medium |
| 검수 sub(반복 중) | 품질·정합 + 사양·의도 대조(그 라운드의 관점 하나 · refute mandate · 빈 통과 금지) | `bada-a3-reviewer`(읽기 전용) | Opus 5.5 · medium |
| 심층·적대 감사(B) | read-only 문제 발견 · findings 는 master 삼각검증(과대 적발 필터) | `bada-b-auditor`(읽기 전용) | Opus 5.5 · high |
| 설계·계획 초안·논리 전개(A1) | 진단·설계·마스터플랜 초안·고등 물리 논리(구현 X) · master가 발주문마다 판단 범위를 분명히 해 단계 투입(장기 자율 금지 · 일을 context 크기로 미리 나누지 않음) | `bada-a1-analyst` | Opus 5.5 · high |
| 저부하 helper | 전처리·포맷 변환·집계 등(carve-out) | `bada-a3-helper` | Opus 5.5 · low |
| 검색·단순 기계 | 인터넷 검색·대용량 기계 추출·머지 | `bada-a4-helper` | Opus 5.5 · low |
| 최종 통합·검수(완성품) | 반복 종료 후 통합·최종 판단 | — (master 직접) | Opus 5.5 · medium |
| (분류 애매) | 어느 역할에도 안 맞음 | `bada-fallback`(쓰기 가능) | Opus 5.5 · medium |

#### 저부하 하향 helper — A1·A2 진행 중 정형·기계 하위작업

A1·A2 본체 작업 중 판단이 필요 없는 정형·기계 하위작업(자료 전처리·포맷 변환·정규화 선작업·집계·파일 분할/병합·대량 단순 치환)이 나오면, 높은 effort 로 도는 상급 등급 서브(A1·A2)가 직접 처리해 생기는 토큰 낭비를 없애기 위해 그 하위작업만 하급 등급 helper(A3·A4 정의 · Opus 5.5 · **low effort**)에 위임한다. 규범 원본(4경계·판정·계수·fan-out 게이트 정합)은 `memory:feedback_session_division` 의 「저부하 하향 위임 carve-out」이고 헌법 §1-병렬 줄이 요지다 — 아래는 스폰 절차다.

1. **하향 판정 3문** — ⓐ 판단을 요하는가 · ⓑ 결과가 본체 논리에 직접 들어가는가 · ⓒ 기계로 검증 가능한가. 판단 불요·부속·기계검증 가능이면 A3/A4 로 하향한다. 판단·설계·본체 구현·검수는 하향하지 않는다(역방향 금지).
2. **스폰 방식** — 상급 서브가 직접 하급 helper 를 스폰하는 nested 를 우선하고(서브는 기본으로 대화 아래 3층까지 서브를 띄울 수 있다 · 층 수 = env `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` · 층 한도에 닿은 서브에는 `Agent` 도구가 빠진다 · 공식 문서 `sub-agents`), 런타임이 nested 를 지원하지 않으면 master 중재로 fallback 한다.
3. **묶음·독립성·직렬화** — 여러 저부하 하위작업은 한 helper 에 묶어 스폰 오버헤드를 줄인다. 동시 다중 helper 는 서로 다른 독립 하위작업일 때만 두고(빨리 끝내려는 속도용 N-way 분할 금지), 같은 파일·상태를 건드리면 순서 의존을 지켜 직렬화한다.

이 helper 는 OCR 위임과 동렬의 carve-out 이라 유닛 수에 계수하지 않으므로 동시 다중 helper 생존이 fan-out 게이트를 건드리지 않는다 — 단 이는 위 4경계를 모두 충족할 때뿐이며, **동급·상급(A1·A2·B)의 동시 스폰은 이 예외가 아니라 fan-out 게이트가 그대로 적용된다**(승인 시에만).

#### 모델·effort 지정 — 거는 곳과 고를 수 있는 값

서브의 모델·effort 는 **서브 정의 파일**(`components/agents/bada-*.md` → 설치 뒤 `~/.claude/agents/`)의 frontmatter 로 건다. Agent 도구에는 정의 이름(`subagent_type`)으로 띄우고 호출 인자 `model` 은 넘기지 않는다 — 넘기면 그 별칭이 정의를 이기고, 별칭 `opus` 는 master 가 Opus 면 master 모델로 풀려 정의의 모델·effort 를 대신하지 못한다. effort 는 모델이 아니라 **에이전트 단위** 라, 모델이 같아도 effort 가 다르면 정의를 나눈다(예: 둘 다 Opus 5.5 인 `bada-a3-worker` medium / `bada-a3-helper` low).

**표 1 — 거는 곳 × 받는 값** (근거 = 공식 문서 `sub-agents`·`model-config` · 이 세션 실측)

| 거는 곳 | model 에 넣을 수 있는 값 | effort | 비고 |
|---|---|---|---|
| Agent 도구 호출 인자 `model` | 별칭 4개 — `sonnet`·`opus`·`haiku`·`fable` | 호출 인자 `effort` 가 있다(판 조건 = `references/model_effort_sample.md` 「정의 파일 형식」) — 넘기지 않는다(넘기면 정의 파일 `effort` 를 이긴다 · 다시 부를 때도 그 값이 남는다) | 정의 파일로 띄울 때는 넘기지 않는다(넘기면 별칭이 정의를 이긴다) · Fable 도 사용자 요청 때 Fable 정의 이름으로 띄우고 이 인자를 넘기지 않는다 |
| 서브 정의 파일 frontmatter (`~/.claude/agents/<이름>.md`) | 별칭 · **전체 ID**(`claude-opus-5-5` 등) · `inherit`(=master 모델) | `low`·`medium`·`high`·`xhigh`·`max` | 전체 ID·effort 가 먹는 Claude Code 판 = `references/model_effort_sample.md` 「정의 파일 형식」 · 폴더는 **세션 시작 때 있어야** 읽힌다 · 호출 = `subagent_type`(공식 문서 `sub-agents`) |
| `create_session` 의 `model` | 전체 ID | 칸 없음 → 모델 기본 effort | 새 세션(새 컨테이너) · 부른 세션에 답을 못 보냄 → 결과는 커밋·푸시로 받는다 · 사용자 지목 때만 |
| 설정 `model` · `--model` · `/model` | 별칭 · 전체 ID | 설정 `modelSettings`(모델별 · 판 조건 = references) · `effortLevel`(사용자 설정 파일의 최상위 키는 Opus 5.5 에 안 걸림 · project·local·managed·`--settings` 의 최상위는 모든 모델) · `/effort` | master 용(공식 문서 `model-config`) |
| Workflow `agent()` | 별칭 · 전체 ID(전체 ID 미검증) | `effort` 옵션 | 사용자가 지목할 때만(흐름 보호) |
| 다시 부르기 — `SendMessage` 의 `to` | 띄울 때 준 이름 또는 `agentId` | 칸 없음(띄울 때의 정의 그대로) | 끝난 서브를 자기 기록에서 이어 깨운다 · 새 서브가 아니다(아래 「다시 부르는 법 · 세션 대장」) |
| env `CLAUDE_CODE_SUBAGENT_MODEL` · `CLAUDE_CODE_EFFORT_LEVEL` | 모든 서브 모델 | 모든 서브·master 의 effort — 정의 파일을 이긴다 | **쓰지 않는다**(역할별 배분을 덮는다 · 공식 문서 `model-config`) |
| env `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` | (`1` 이면) 정의 파일 `model` 을 무시하고 모든 서브를 `CLAUDE_CODE_SUBAGENT_MODEL` 로 띄운다 · 호출 인자 `model` 도 못 넘긴다 | — | **쓰지 않는다**(정의 파일로 거는 배분을 덮는다 · 공식 문서 `sub-agents`) |

**표 2 — 고를 수 있는 값**

| 항목 | 값 |
|---|---|
| 전체 ID — 이 패키지 배분 | Opus 5.5 `claude-opus-5-5`(master = medium · 역할별 서브 전부) |
| 전체 ID — 배분 밖(쓰임이 따로 정해짐) | Sonnet 4.6 `claude-sonnet-4-6`(`env` 의 `ANTHROPIC_DEFAULT_SONNET_MODEL` 핀 · 서브로는 사용자가 명시 지시할 때만) · Fable 5.2 `claude-fable-5-2`(사용자 요청 시에만 · 정의 `bada-fable-analyst`·`bada-fable-auditor` 로 띄움) · Haiku 는 별칭 `haiku`(서브로는 사용자가 명시 지시할 때만 · 빌드 날짜가 붙은 ID 는 지시 없이 적지 않는다 — 헌법) |
| 별칭이 풀리는 모델 | `opus` = master 가 Opus 면 **master 모델**(아니면 최신 Opus) · `sonnet` = `ANTHROPIC_DEFAULT_SONNET_MODEL` 이 먹으면 그 값, 아니면 최신 Sonnet(Anthropic API = Sonnet 5.5 · 제공자에 따라 더 이른 판) · `haiku` = 최신 Haiku(Anthropic API = Haiku 5.5 · 다른 제공자는 Haiku 4.5) · 생략·`inherit` = master 모델 |
| effort 단계 | `low`·`medium`·`high`·`xhigh`·`max` — Opus 5.5 = 전부(기본 **medium**) · Opus 4.8 = 전부(기본 high) · Sonnet 4.6 = `xhigh` 없음(주면 high) · Haiku 5.5 = 전부(기본 medium) · Fable 5.2 = 전부(공식 문서 `model-config` — 판이 바뀌면 그 문서로 다시 확인) |
| 모델 우선순위 | 호출 인자 `model` > 정의 파일 `model` > `CLAUDE_CODE_SUBAGENT_MODEL` > master 모델 — env `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` 가 켜지면 정의 파일 `model`·호출 인자 `model` 을 무시한다 |
| effort 우선순위 | `CLAUDE_CODE_EFFORT_LEVEL` > 호출 인자 `effort` > 정의 파일 `effort` > 세션 effort |

**표 3 — 이 패키지 역할별 정의** (`components/agents/bada-*.md` · 이름은 사용자 동명 정의와 겹치지 않게 `bada-` 접두)

| 정의 이름 | 역할 | model | effort | 도구 |
|---|---|---|---|---|
| `bada-a1-analyst` | A1 분석·설계·계획 초안 | `claude-opus-5-5` | `high` | 전부 |
| `bada-b-auditor` | B 적대 감사(읽기 전용) | `claude-opus-5-5` | `high` | 읽기 전용 |
| `bada-a2-coder` | A2 코드(설치기·도구·스크립트) | `claude-opus-5-5` | `medium` | 전부 |
| `bada-a2-writer` | A2 지침·문서 편집 | `claude-opus-5-5` | `medium` | 전부 |
| `bada-image-reader` | 이미지 판독 | `claude-opus-5-5` | `medium` | 전부 |
| `bada-a3-worker` | A3 정형 실무·단순 수정 | `claude-opus-5-5` | `medium` | 전부 |
| `bada-a3-reviewer` | A3 반복 검수(검증 1회 = 그 갈래의 검수 · ③ = 10라운드) | `claude-opus-5-5` | `medium` | 읽기 전용 + 기계 검사용 셸 |
| `bada-a3-helper` | 저부하 helper | `claude-opus-5-5` | `low` | 전부 |
| `bada-a4-helper` | A4 검색·기계 | `claude-opus-5-5` | `low` | 전부 |
| `bada-fallback` | 배정 폴백(역할 미매칭 · 쓰기 가능) | `claude-opus-5-5` | `medium` | 전부 |

배분 밖 정의(사용자가 Fable 을 요청할 때만):

| 정의 이름 | 역할 | model | effort | 도구 |
|---|---|---|---|---|
| `bada-fable-analyst` | Fable 분석·설계·검토 초안 | `claude-fable-5-2` | `high` | 전부 |
| `bada-fable-auditor` | Fable 적대·설계 감사(읽기 전용) | `claude-fable-5-2` | `high` | 읽기 전용 |

정의 파일 형식 한 개·`create_session` 호출·**실제로 뜬 모델 확인 명령(`resolvedModel`)** 은 `references/model_effort_sample.md` 에 있다. 서브가 돌아오면 그 명령으로 정의 이름과 실제 모델을 확인하고, 배분표와 다르면 그 결과를 쓰지 않는다 — 멈춰 사용자에게 보고하고, 원인(정의가 안 읽힘 등)을 바로잡은 뒤 다시 발주한다(임의 대체 금지 원본 = 헌법 「배정 폴백·장애」 줄). effort 는 Agent 결과 기록에는 없고, 세션 기록(jsonl)의 assistant 행 `effort`·`perTurnEffort` 칸에 남는다(서브 = 같은 세션 폴더 `subagents/agent-<agentId>.jsonl` · master = 세션 jsonl · 확인한 판 = references) — 정의 파일과 이 칸으로 확인하고 `/tasks` 에서도 본다.

**방어 지침** — ① 모델·effort 를 「못 건다·없다」고 단정하기 전에 위 표 1·2 를 본다(호출 인자 한 곳의 제약을 방법 전체의 부재로 말하지 않는다). ② 도구 제약 한 줄(예: 「정의 폴더는 세션 시작 때 있어야 읽힌다」)로 우회를 설계하기 전에 실측한다 — 그 세션에서 정의가 실제로 읽히는지·서브가 무슨 모델로 떴는지(`resolvedModel`)를 확인한 뒤 판단한다. 모델·설정·결정을 답하기 전에 요청 대장부터 보는 규범(계획 실행 스킬)과 같은 결이다.

#### ★ sub spawn 시 5항목 고지 의무

master 가(서브가 helper 를 띄울 때는 그 서브도) sub를 spawn할 때마다 prompt 첫 머리에 다음 5항목을 명시한다. 각 항목의 규범 원본은 `memory:feedback_session_division`(요지 = 헌법 §1)이고, prompt 에 실을 실제 문장은 아래 「sub prompt 표준 머리말 예」를 쓴다.

1. **본 sub 의 역할** — 작업 sub / 검수 sub 중 무엇인지.
2. **분업 경계** — 담당 범위·무변경 영역·commit 권한의 소재.
3. **brief 범위 밖 자의 작업 금지.**
4. **허위 attribution 금지.**
5. **필요 memory 맥락 주입** — 서브는 헌법은 상속하나 native 메모리 색인·본문은 상속하지 않는다.

**이유:** 이 고지가 없으면 작업 sub 가 brief 밖의 문건·commit 을 자의로 만들고 그것을 사용자가 한 일로 잘못 표기한다. 스폰 prompt 에 경계·자의 작업 금지·허위 attribution 금지를 미리 적으면 그 발생 자체를 막는다.

#### sub prompt 표준 머리말 예

- "너는 [작업명] [단계명]의 [작업/검수] sub 다. 3-세션 모델(master + 작업 + 검수) 분업 안에서 본 sub의 책임은 [구체 범위] 뿐이다."
- "범위 밖 작업(새 문건 / 새 표준 / 새 commit / 새 메모리 / brief 미명시 파일)을 자의로 추가하지 말 것. 발견 시 work_log 의 Decision Queue(결정 대기 목록)에 목록만, master 결정 후 진행."
- "보고문 / commit message / work_log에 사실과 다른 attribution을 쓰지 말 것. 너의 자의 결정·변경은 너의 출처로 명시."
- "작업 sub의 경우: \"commit 권한은 master. 너는 변경 + work_log 작성만.\" 작업 sub에게 commit을 위임하지 않는다(같은 컨테이너 Agent 서브 = 커밋 안 함 · `create_session`·다른 도구·다른 AI 의 작업자는 자기 브랜치·워크트리에만 커밋·푸시하고 통합 브랜치 반영은 master)."
- "작업 sub 의 경우: 반환하면 이 세션은 멈춘다 — 검수 보고가 오면 master 가 이 세션을 다시 불러 넘기고 이 세션이 이어 받아 고친다. 그래서 반환 글과 work_log 에 이어받을 상태(바뀐 파일·남은 일·읽은 범위)를 남긴다. 고칠 때는 보고가 가리킨 파일을 직접 열어 고치고(그 파일을 context 에 전문으로 갖지 않았으면 먼저 전문으로 읽는다), work_log 에 판단 근거로 읽은 파일·줄 범위를 적는다. work_log 에 명령은 그대로 · 출력은 판정 줄만(통과 = rc·개수 · 실패 = 오류 줄 · 원 출력은 스크래치 경로만)."
- "검수 sub 의 경우: 입력 = 아래 대상 파일 + 연계 파일 전문(그 밖의 기록은 읽지 않는다) · 큰 파일은 창(~500줄)을 차례로 읽고 창마다 발견·읽은 범위를 적는다 · 결함마다 파일:줄 + 원문 인용(요약 아님) · 고친 뒤 재확인도 이 세션이 한다."
- "작업 중 정리하려고 지우지 마라(`rm -rf` 등 승인 목록 명령은 창이 떠 연속 작업이 끊긴다 · `rm -f` 도 정리엔 쓰지 않는다). 새 실행은 스크래치 아래 새 폴더(`mktemp -d`). 정리는 master 가 전체 작업 끝에 한 번에 한다. 스킬 절차가 보안·정합 때문에 요구하는 삭제(예: 외부 문서를 푼 폴더의 심볼릭 링크 제거)는 정리가 아니므로 그대로 한다 — 임시·중간 산출물을 치우는 단계는 스킬 절차에 있어도 정리다." (흐름 보호 — 모든 sub prompt 에 필수)
- "이 sub가 따라야 할 memory 규범이 있으면 그 요지를 여기에 싣는다(서브는 native 메모리 미상속): 예 \"검수 시 feedback_chunked_review 규범 적용 — 검수 구분(발주문이 정한 갈래대로 · 범위 = 바뀐 단위 + 영향 지도 단위 · ③ 구조 변경 = 관점 10개[고정 5 프리셋 + 가변 5] · 라운드 하나 = 관점 하나로 검수 범위 전체 1회 · 검증 1회 = 10라운드[조기 종료 없음 · 한 라운드 적대] / ② 국소 변경 = 바뀐 줄 + 지도 「함께 고침」·「확인만」 줄 한 번 검수 + 적대 항목 하나 + 연계 확인 / ① 치환 = 바뀐 줄 뜻 확인·유의어 자리 판정 한 번 / ④ 기계적 변경 = 실행 게이트 + 바뀐 줄 / 코드 = 실행 출력 먼저 · 코드 ③ 은 연계·뜻·적대 3라운드) · 영향 지도 대조·「지도 밖 연결」 찾기 · refute mandate · 빈 통과 금지. 필요하면 그 memory 파일을 Read 해 정독하라.\""

## 검증

### 검수 방향 선택

| 검수 방향 | 적합 상황 |
|---|---|
| 일반 결함 검수 | 구현 결함 / 코드 품질 / 표면 issue 발굴이 목적일 때. |
| 설계·적대 검수 | 구현 접근·설계 결정·trade-off 가정을 도전할 때. 본격 재설계·후보 발굴 또는 사양 모호 의심 시. |

두 방향은 같은 대상에 순차 적용 가능하다 — 일반 결함을 잡고, 이어서 설계 의문을 제기.

### 스폰 직전 체크

spawn 직전 체크 — ① 배정 모델이 업무 등급(A1~A4·B)과 일치(배분 밖 정의[Fable]는 사용자 요청일 때 그 정의) ② 모델·effort 는 역할별 정의 이름(`subagent_type`)으로 걸고 Agent 호출 인자 `model` 은 넘기지 않는다(서브가 돌아오면 정의 이름·`resolvedModel` 로 실제 모델을 확인해 배분표와 대조 · 다르면 그 결과를 쓰지 않고 멈춰 보고·재발주) ③ 5항목 고지 전부 포함 ④ brief 에 담당 범위·무변경 영역 명시. 하나라도 빠지면 스폰하지 않고 prompt 를 보완한다.

## 예외·금지

- 경량 작업(1-line fix·정보 조회·파일 정독·메모리 갱신)은 master 가 직접, A3·A4 등급(정형·기계)은 단일 서브로 처리한다. 이 3-세션 모델을 강제하지 않으며, 스폰 대상도 아니다(경량·등급 판정의 한정어는 위 「적용 조건」과 동일 — 애매하면 본격 · 계획 수립 명시 지시는 규모 무관 경량 배제).
- 이 모델은 사용자 산출물을 만드는 본격 작업에 적용한다.
- 지정 모델 런타임 장애 시 임의 대체(silent substitution) 금지 — 정지·사용자 보고(원본 = 헌법 「모델·아티팩트 운용」 · 미설치 도구만 부재 패싱 — 런타임 장애·일시 미가용은 부재가 아니다·정지·보고).

## 관련 문건

- 헌법 §1 세션 분업 — 본업 공정 상위 원칙 · 헌법 「모델·아티팩트 운용」 — 역할별 모델 배분·폴백·장애 규범 원본
- `memory:feedback_session_division` — 5항목 고지·분업 규범 원본
- `skill:skill_LKS_original_review-chunking` — 검수 sub의 라운드·관점·청크 운용 상세
- `skill:skill_LKS_original_plan-execution` — 계획 저작·Phase 실행·Result/Ledger 기록
- 관련 `memory:feedback_flow_interruption` — 멀티에이전트는 Workflow가 아니라 Agent 도구로
- 「핸드오프도 파일로」·「fix는 묶어서 디스패치」 두 규율은 외부 Superpowers 방법론에서 이식했다.

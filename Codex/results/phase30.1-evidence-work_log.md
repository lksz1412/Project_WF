# Phase 30.1 · 근거와 링크 복원 작업 기록

작업: A2 문서. 기준 브랜치 `codex/claude-phase25-handoff`, 기준 커밋 `477eb06`. 원본 작업 트리는 읽기 전용이다. Claude/와 Collection/은 수정하지 않는다. root의 sync 계획·현재 원문 대장은 수정하지 않는다. Git add·commit·push 및 게임 실행은 수행하지 않는다.

## 변경 목록과 영향 지도 (수정 전)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| Phase29.1·29.2 결과, Step40·60·61 및 연결 Step62 | 같은 값·근거·쌍둥이 | 원본 문서 전문·JSON 필드와 누락 링크 검색 | 함께 고침 | 누락 문건을 Codex/results로 복원, 과거 검사 사실 보존 |
| Codex/plans의 기존 adoption·audit 계획 | 가리키는 곳·사용자 표면 | 같은 범위 링크 검사 | 함께 고침 | root가 기존 계획의 근거 링크 복구 허용. 새 sync 계획은 확인만 |
| Codex/results, Review, References의 깨진 주소 | 같은 값·용어 전수·가리키는 곳 | 427개 Markdown 인라인 주소 1265건 전수 검사 | 함께 고침 | 동일 실물로 연결하거나 로컬 전용으로 표기 |
| Codex requirement-trace 문서·기계 JSON | 읽는·파싱하는 쪽 | Codex 요청 R111–149 전수 검색·문맥 정독 | 함께 고침 | Codex 요청만 CR111–149 및 새 대장으로 연결 |
| 원본 D 문서와 root의 새 원문 대장 | 입력을 만드는 쪽 | 실물 존재·범위 및 식별자 대조 | 확인만 | 원본과 사용자 발화는 수정하지 않음 |
| Claude/, Collection/data/ 및 upstream | 보호 범위·쌍둥이 | 검사 결과와 실제 주소 대조 | 확인만 | 직접 쓰기 금지. 위치와 대체 주소를 인계 |
| 기존 문서의 과거 검수 결과·외부 조사 시점 | 기록 | 전문 읽기 | 영향 없음 | 당대 판정·Claude 실제 요청 번호 보존 |
| 호출·피호출 함수 | 코드 연결 | 문서·데이터만 변경 | 없음 | 실행 코드 변경 없음 |
| 잠근 시험 | 기존 검사 | root 제공 sync-link-scan.py 전문 | 함께 실행 | 전체 실제 파일 범위의 전후 링크 검사, JSON 파싱과 금지 영역 diff 검사 |

## 1차 검사

`python ../sync-link-scan.py --tracked-only --output Codex/results/phase30.1-links-before.json` → exit 0. Markdown 427개, 내부 주소 등장 1265건, 깨진 대상 104개·등장 129건. 계획의 이전 수치와 일치한다.

검사기는 fenced code를 빼고 인라인 링크·이미지 주소를 읽는다. URL decode와 fragment 제거 뒤 상대 경로를 문서 폴더에 붙인다. 추적 파일·상위 폴더 집합에서 존재를 확인한다. 외부 URL과 빈 fragment 주소는 제외한다. Git에 없는 로컬 파일은 디스크 존재 여부와 관계없이 공개 링크로 세지 않는다. Markdown 문법 전체·heading anchor·외부 웹 유효성 검사는 아니다.

## 단위 결과

- 시작 전 규칙·계획·원본 읽기 완료 범위는 아래 읽기 기록에 계속 추가한다.
- 초기 작업 명령에서 출력 묶음이 잘린 구간을 재조회했다. Python 기본 cp949 때문에 JSON 읽기 및 화면 출력 오류 2건이 있었으며 UTF-8 명시 후 전수 목록을 다시 얻었다. 파일 변경·누락 없음.

## 읽은 범위

- 활성 Codex home의 `AGENTS.md`: 1–153행. 최초 출력 잘림의 45–106행을 재조회. 현재 발주문과 받은 메시지 전문.
- 상위 작업 폴더의 `AGENTS.md`와 두 sync 계획 전문. 정확한 끝행은 아래 원본 범위 표에 기록했다.
- file-reading/change-control/review-chunking/communication-decisions SKILL.md 전문. full_file_read_required, change_impact_analysis, code_ownership_scope, workspace_git_safety, communication_style, confirmed_items_policy, flow_interruption, chunked_review, review_chunk_discipline 정책 전문. 묶음 출력 잘림 부분은 재조회. banned_lexicon.json 전문.
- `../sync-link-scan.py`: 1–35행 전문. `References/codex-appearance/8/report.md`, `19/report.md`: 전문.
- 원본의 Phase29.1·29.2 md/json, Step60 2건, Step61, Step62, Step40 collection integration md/json: 전문.

## 결정 대기

없음. 현재 인계 근거 복원과 링크 수정은 승인 범위다. 실제 게임 검증 및 과거 외부 주소의 최신성 확인은 미수행이다.

## 단위 1 · 누락 근거 복원

13개 원본을 복원했다. 발주 9개 외 Phase29.2의 Step62 연결과 Phase29.1·29.2의 세부계획 및 29.1 대장을 함께 복원했다. 원본 바이트 SHA-256과 복원본의 최종 SHA-256을 `phase30.1-restored-evidence.json`에 구분했다. 외관 8·19 보고서가 기준 Git 파일 집합에 있음을 확인했다. 역사 결과의 PASS는 당대 기록이며 새 시험 판정으로 사용하지 않는다.

## 단위 2 · 링크와 요청 연결

공개 파일 집합에 없는 로컬 실행·ZIP·외부 작업 자료 링크 115자리를 처리했다. 같은 통합 문건이나 저장소 실물로 연결할 수 있는 곳은 상대 링크로 고쳤고, 나머지는 원래 라벨과 ‘로컬 전용’을 남겼다. 코드 인용 속 스캐너 매치 2건은 보존했다. `phase30.1-link-changes.json`에 각 파일·행·처리를 기록했다. 공개 JSON의 로컬 경로는 SHA-256 앞 16자리로 구분해 실제 경로를 싣지 않는다.

요청 추적표 문서·JSON의 Codex 39개 식별자를 CR111–CR149와 새 원문 대장으로 연결했다. JSON의 옛 primarySource는 legacyPrimarySource로 보존하고 현 primarySource는 실제 새 heading 행과 anchor로 바꿨다. ledgerFiles·otherSources는 당시 자료 목록으로 보존한다. 같은 요청을 쓰는 Step44·Phase26.1·화면 검토와 findings JSON의 현재 연결을 함께 맞췄다. 과거 작업 로그의 원문·읽기 범위 및 실제 Claude R110은 보존했다. 소스 생성기 검색에서 requirement-trace를 생성하는 저장소 Python/PowerShell 코드는 찾지 못했다. 문서와 JSON은 독립 저작 기록으로 처리했다.

## 상세 읽기 기록

아래 범위는 수정 전 전문을 읽고 변경 후 diff 문맥을 확인한 대상이다. 줄 수는 최종 작업본을 기준으로 제시하며, 과거 읽기 범위 표를 새로 수행했다고 주장하지 않는다.

| 파일 | 범위 | 사용 |
|---|---|---|
| `Codex/plans/2026-11-19-devil-forever-audit-and-installer-phase26.1-세부계획.md` | 1–61 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/plans/2026-11-19-devil-forever-audit-and-installer-plan.md` | 1–165 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/PHASE_26-28_EXECUTION_LEDGER.md` | 1–12 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/PHASE_28.2_local-trial-delivery_RESULT.md` | 1–45 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/PHASE_29.3_runtime-performance_RESULT.md` | 1–49 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/PHASE_29_EXECUTION_LEDGER.md` | 1–9 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 44 — 요청과 실제 기능 대조.md` | 1–36 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 45 — 배포 기준 ZIP 검증.md` | 1–37 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 46 — 기능별 반증 시험.md` | 1–39 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 47 — 결함 보정과 재시험.md` | 1–39 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 48 — 검토한 ZIP과 기능 기준 확정.md` | 1–35 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 49 — Windows 단일 실행 파일 검증.md` | 1–27 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 51 — Windows 파일 적용 엔진.md` | 1–27 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 52 — 파일 복원과 관리 제거.md` | 1–27 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 53 — Windows 설치 화면과 명령줄.md` | 1–16 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 54 — Windows 로컬 배포본.md` | 1–22 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 55 — 배포본 중단과 충돌 시험.md` | 1–28 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 56 — 현재 Windows 격리 확인과 청정 환경 대기.md` | 1–11 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 58 — 로컬 시험판 전달.md` | 1–12 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 59 — 채팅 그림과 설치 묶음 갱신.md` | 1–39 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 63 — 프리셋과 소환수 단축바 갱신 줄이기.md` | 1–33 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 64 — FUF 비교 배치 반복 조회 줄이기.md` | 1–31 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 65 — 0.1.2 성능 개선과 설치 검증.md` | 1–56 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 66 — 유닛 프레임 동작 비교.md` | 1–21 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 67 — 행동 추천과 전투 미터기.md` | 1–23 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 68 — 기능별 후보와 반복 비용.md` | 1–27 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/Step 69 — 실제 게임에서 확인할 성능 비교.md` | 1–39 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/audit-installer/requirement-trace.md` | 1–199 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/handoffs/old-reference/r44-plan-update/a1-final-return.md` | 1–19 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/handoffs/old-reference/step5-a1-final-return.md` | 1–25 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| `Codex/results/ui-review-2026-11-19/review.md` | 1–203 | 원문 전문과 링크·식별자 변경 문맥 대조 |
| 원본 작업본 `Codex/results/PHASE_29.1_addon-evidence_RESULT.md` | 1–45 | 복원 입력 전문 |
| 원본 작업본 `Codex/results/PHASE_29.2_addon-adoption_RESULT.md` | 1–45 | 복원 입력 전문 |
| 원본 작업본 `Codex/results/Step 60 — 상위 애드온 1차 등급과 자체 성능 검수.md` | 1–71 | 복원 입력 전문 |
| 원본 작업본 `Codex/results/Step 60 — 후보별 배포 원본 대조.md` | 1–92 | 복원 입력 전문 |
| 원본 작업본 `Codex/results/Step 61 — 최소 선택 설치 구성.md` | 1–33 | 복원 입력 전문 |
| 원본 작업본 `Codex/results/Step 62 — 채택 권고 독립 검수.md` | 1–31 | 복원 입력 전문 |
| 원본 작업본 `Codex/results/REQUEST_LEDGER_phase29.1.md` | 1–8 | 복원 입력 전문 |
| 원본 작업본 `Codex/plans/2026-11-19-devil-forever-addon-adoption-phase29.1-세부계획.md` | 1–7 | 복원 입력 전문 |
| 원본 작업본 `Codex/plans/2026-11-19-devil-forever-addon-adoption-phase29.2-세부계획.md` | 1–12 | 복원 입력 전문 |
| 원본 작업본 `Claude/results/Step 40 — Codex collection integration.md` | 1–45 | 복원 입력 전문 |

기계 데이터는 JSON parser로 top-level key·요청 ID 151개·CR39개·소스 위치·후속 연결·openItems 및 featureCoverage의 관련 요청 필드 전부를 확인했다. 모든 9천여 줄을 prose 정독했다고 주장하지 않는다. UI 검토 문서는 1행부터 끝까지 3개 구간으로 읽었다. trace Markdown은 1–40,41–85,86–130,131–160,161–195행으로 읽고 출력 잘림의 R71행을 재조회했다. Step68은 최초 묶음 출력 잘림 뒤 단독 전문 재조회했다. step46 work log는 1–86,87–176,177–257행, step47 work log는 1–60,61–140행으로 읽었다.

## 실행 출력과 제한

- baseline: rc0, 427/1265/104/129 (문서/내부주소 등장/깨진 대상/깨진 등장).
- 복원 직후: rc0, 442/1286/98/117.
- 링크 보정 뒤 전체: rc0, 442/1192/2/2 (최종 새 보고 추가 뒤 별도 재계수).
- 원래 477eb06의 source cohort 427개를 고정하고 현재 파일 집합으로 목적지를 확인: rc0, 427/1172/2/2.
- `git diff --name-only -- Claude Collection`: 출력 없음. 보호 범위 변경 0.
- 실제 게임·외부 자료 재조회·과거 제품 시험 재실행·Git add/commit/push: 수행하지 않음.
- 과거 자료의 인용까지 처리해 링크 0을 만드는 방식은 사용하지 않았다. 잔여 2건은 검사기 한계와 역사 원문 보존을 함께 밝힌다.

## 최종 기계 게이트

종료0. 요청151개 unique, Codex CR39개 heading·행·파일 일치, Claude 실제 R110 주 출처 유지, 원본13개 SHA-256 동일, 변경·신규 JSON 파싱 통과, Claude/Collection 변경0, root sync 계획 변경0. `git diff --check` 종료0. 새 인계 포함 최종 443/1213/2/2이다. 독립 검수와 Git stage는 master 몫으로 남긴다. 원시 usage는 미관측이다.

## 추가 지시 · Review 채팅 결정 연결

변경 전 영향: `Review/0.1.4/evidence/chat-decision.md` 1–9행 전문을 읽었다. 3행의 Codex 채팅 선택 번호만 CR112 heading 링크로 함께 고침. 소비자는 현재 인계·requirement-trace와 새 원문 대장이다. Claude·Collection은 확인만. 제품 코드·잠근 시험·쌍둥이 생성물 없음. 부모의 명시 추가 범위이며 같은 링크 검사로 확인한다.

## 적용 원본의 정확한 읽기 범위

| 설치본 기준 파일 | 범위 |
|---|---|
| `skill_LKS_original_file-reading/SKILL.md` | 1–20 |
| `skill_LKS_original_change-control/SKILL.md` | 1–23 |
| `skill_LKS_original_review-chunking/SKILL.md` | 1–138 |
| `skill_LKS_original_communication-decisions/SKILL.md` | 1–21 |
| `skill_LKS_original_file-reading/references/policies/feedback_full_file_read_required.md` | 1–57 |
| `skill_LKS_original_change-control/references/policies/feedback_change_impact_analysis.md` | 1–65 |
| `skill_LKS_original_change-control/references/policies/feedback_code_ownership_scope.md` | 1–83 |
| `skill_LKS_original_project-scaffold/references/policies/feedback_workspace_git_safety.md` | 1–81 |
| `skill_LKS_original_communication-decisions/references/policies/feedback_communication_style.md` | 1–87 |
| `skill_LKS_original_communication-decisions/references/policies/feedback_confirmed_items_policy.md` | 1–62 |
| `skill_LKS_original_communication-decisions/references/policies/feedback_flow_interruption.md` | 1–66 |
| `skill_LKS_original_review-chunking/references/policies/feedback_chunked_review.md` | 1–139 |
| `skill_LKS_original_review-chunking/references/policies/feedback_review_chunk_discipline.md` | 1–39 |
- 상위 작업 폴더 AGENTS.md: 1–80행.
- sync 마스터 계획: 1–102행.
- sync Phase30.1 계획: 1–8행.
- 외관8 보고: 1–31행.
- 외관19 보고: 1–23행.
- 금지 어휘 등재부: 1–75행.
- 사용한 링크 검사기(로컬 전용): 1–32행.

Review 보정 뒤 최종 수치: 같은427개 1173주소·2대상·2등장, 새 문서 포함 443개·1214주소·2대상·2등장. Review 링크의 새 heading 실재 확인. 앞 1172/1213은 이 한 링크 추가 전 중간 측정이다.

## 독립 검수 수정 · 번호 범위 세 곳

| 곳 | 영향도 | 변경·근거 |
|---|---|---|
| `Codex/results/audit-installer/requirement-trace.md:184` | 함께 고침 | `CR149~151이` → `CR149·R150·R151이`. CR149 뒤 R150·R151은 기존 번호이므로 범위를 구분. |
| `Codex/results/audit-installer/requirement-trace.json:8819` | 함께 고침 | `CR149~151이` → `CR149·R150·R151이`. CR149 뒤 R150·R151은 기존 번호이므로 범위를 구분. |
| `Codex/plans/2026-11-19-devil-forever-audit-and-installer-phase26.1-세부계획.md:37` | 함께 고침 | `CR114·CR145–R150` → `CR114·CR145–CR149·R150`. CR149 뒤 R150·R151은 기존 번호이므로 범위를 구분. |

연계 필수 칸: 같은 값 검색은 위 세 입력 전체에서 수행. 읽는 쪽은 추적표 Markdown·JSON과 기존 계획이며 원문 대장·역사 로그는 확인만. 입력 생성·코드 호출·잠근 시험·생성 사본은 없음(문서 번호 표기만). 복원 파일과 링크는 영향 없음. 이번 읽기는 세 입력의 기존 전문을 유지한 상태에서 수정 문맥 md182–186·json8816–8823·계획35–39행, 이 작업 기록1–145행을 직접 재확인했다.

검증: 각 구표기 해당 자리1건을 교체해 잔재0, 새표기 각 해당 자리1건. 세 파일의 인라인 링크 목록 전후 동일, JSON 파싱 종료0, 복원13파일의 기록된 최종 SHA-256 전부 동일. 링크 전수 재실행·복원 manifest 갱신은 하지 않았다. stage·commit 없음.

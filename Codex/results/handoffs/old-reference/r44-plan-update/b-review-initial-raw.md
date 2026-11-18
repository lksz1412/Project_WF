중대 0 · 중간 1(제안) · 경미 0. 열 관점 검토 완료. R60 추가 반영과 root 통합은 미완이며 현재본의 최종 수용을 주장하지 않는다.

1. **M1 — 개정 후에도 변경 전 canonical 좌표를 가리켜 역사 근거의 추적이 깨진다. 이번 개정에서 생긴 연계 문제다.**

   대상: `Codex/results/handoffs/old-reference/r44-plan-update/master-plan-candidate.md:412`

   > 원래Step2/최초계획 검수의 당시 상태는 canonical253–260행에 보존돼 있고 현재Step5목표/P4를대신하지 않는다. 실제Step3/4수용과Step5설계상태는현행본문에반영했다.

   연결: `requirements-coverage.md:11`

   > 표의 약칭: canonical은 `Codex/plans/2026-11-17-devil-ui-forever-plan.md`, currentdetail은 같은 폴더의 `2026-11-17-devil-ui-forever-phase1.3-세부계획.md`, candidate는 이 폴더의 `master-plan-candidate.md`다.

   같은 대응표 28·29·31행은 `canonicalmacro201`, 39행은 `canonical역사352`를 근거로 쓴다. 예를 들어 31행 원문은 다음과 같다.

   > | R17 | 완료반환·보존유지 — 원본라이브러리·색인만;필요할때원문찾기 | Codex/results/REQUEST_LEDGER.md:21 | 현재 보존/응답 기록; 새 제작 단계 없음; canonicalmacro201; 기존대장R17 | 게임import/키배정/원형가공0;현재A1raw미독 |

   현재 370행 baseline의 201행은 다음 문장으로 시작한다.

   > 최종 승인 범위는 `D:\Projects\Project_WF\MacroLibrary\` 안의 private 라이브러리다.

   그러나 합류 대상인 후보의 201행은 다음 내용이다.

   > | 데미지·어그로 |선택된 기존 제품, 각 표시 영역 한 담당 |특정 제품/판본/Forever 호환 미확정. 둘 다 설치/on 필수 아님. 세 번째 채팅 자리는 유지 |

   baseline 352행은 2022 목표 철회 기록이지만 후보 352행은 `G-reuse` 시험 행이다. baseline 253–260행의 Step2 검수 표도 후보의 그 좌표에는 없다. 후보 408·416행의 `canonical37행`·`canonical338–370행` 역시 변경 전 좌표다.

   **실제 사용상 영향:** root가 후보를 같은 canonical 경로에 반영한 뒤 후속 작업자나 검수자가 이 대응표로 R17 보존 범위·R25 철회·Step2 역사 검수를 확인하면 다른 기능표나 시험 행에 도달한다. 현재 후보 폴더에서의 독해가 아니라 **계획된 canonical 교체 이후의 근거 소비 계약**에서 발생하는 문제다. root가 byte 동일 baseline 보존 사본을 만들었다는 메시지는 확인했으나, 현재 후보·대응표의 위 별칭은 그 보존 사본을 가리키지 않는다. 자료 유실이나 이미 발생한 잘못된 실행을 주장하는 것은 아니다.

   후보 144행의 다음 문구도 같은 합류 경계에서 확인할 연결이다.

   > 전수 대응은 같은 폴더 requirements-coverage.md/.json에 고정한다.

   지금 후보 폴더에서는 맞지만 canonical의 `plans/` 위치로 옮기면 같은 폴더가 달라진다. 이는 root의 통합 작업으로 처리할 수 있는 위치 연결이며 별도 결함으로 중복 계수하지 않았다.

R60은 검수 중 새로 들어온 명확화다. `R60-user-message.md:1`:

> 단일 애드온이 아니라 애드온 모음집이 목표인거지 ㅇㅋ?

후보 56·182·184·298·358행은 기존 제품의 폴더/TOC 유지, 선택 기능별 실제 AddOn 분리, 선택 제품 부재 시 core 유지, disabled 제품/adapter의 미로드를 명시하므로 **단일 monolith 목표라는 의미상 결함은 발견하지 못했다.** 다만 frozen 후보·대응표·JSON은 R1–59까지여서 R60의 명시적 모음집 목표와 현재 총 60요청 연결은 아직 반영되지 않았다. 이는 `supplement-r60-collection.md:6`이 이미 정한 같은 A1 후속 반영이며, 검수 전 누락으로 소급 계수하지 않았다. 과거 59요청 gate 결과도 현재 60요청 완료 근거로 쓰지 않았다.

| 라운드 | 관점·실제 재독 범위 | 반증 시도·판정 |
|---|---|---|
| 1 | 형식·11절·표·누적 Step. 아래 첫 읽기 전체 및 저장 gate 22+8 | 1–22 번호, tree/Phase 표, 최초 1–5 예상, 조건부 비용과 live 비용의 혼합을 대조했다. 새 결함 없음. |
| 2 | 사실·참조. 후보 74–96, 204–226; 수용 보고·근거 전체 | 구판 metadata·정적 source·도구 probe를 현재 작동/이식 성공으로 확대하는지 확인했다. 자체 미구현·권리·Leatrix core·부분 profile 한계가 유지된다. 새 결함 없음. |
| 3 | 변경 전후 연계. 후보 134–147, 278–284, 406–418; 대응표 11·28·29·31·39; baseline 전체 | 역사 좌표와 합류 후 소비 위치를 추적했다. M1 중간 제안 1건. Step5 이월 기록은 root의 미완 통합 조건으로 명시돼 있으며 완료됐다고 쓰지 않는다. |
| 4 | 정의·완결성·추적. 후보 287–320; 대응표 1–13, 69–75; JSON 59레코드 | 요구별 상태·근거·Phase/Step·산출·검증의 orphan을 대조했다. 번호 열거를 구현 완료로 쓰지 않는다. R60 후속 반영은 별도 미완이다. 새 결함 없음. |
| 5 | 요청 뜻·범위·승인. 후보 50–66, 98–128, 452–456; R42–60 원문 | 최신 기능 제작 의도를 옛 조사-only로 취소하거나 게임 적용 승인으로 확대하는지 확인했다. 기능 제작의 계획 gate와 live 승인이 분리된다. 새 결함 없음. |
| 6 | 독립 AddOn·단일 combat·native 입력. 후보 181–204, 298–299, 358·362·369 | 표시 toggle만으로 독립 선택을 대체하는지, 상태/CD와 토템 입력을 중복 담당시키는지 확인했다. 모음집 의미·core 단독·실제 미로드 계약이 있다. 새 결함 없음. |
| 7 | 필수 저장/복원·편집. 후보 229–234, 301–303, 355–360 | default/user 값 혼동, absent provider entry 삭제, unknown schema silent reset, 다른 namespace 변경을 반증했다. 범위별 복원·실패 snapshot·지원값 제한·persistence 시험이 연결된다. 새 결함 없음. |
| 8 | **적대:** R48 비교·R49 재사용 단위·V42. 후보 60, 213–226, 258, 295–296, 352·470; R36 근거 24–38 | 자체 미구현을 외부 우위로 둔갑시키거나, 필터 reset/installer/uiScale을 snippet과 함께 가져오도록 유도하는지 확인했다. 동일 요구 비교·caller/callee/lifecycle·전체/부분 구분·미독 한계가 유지된다. 새 결함 없음. |
| 9 | 외부 raid/meter 스타일·update·조작·테마. 후보 237–252, 293, 299–300, 307, 363·365·469 | 모든 제품의 skin 가능성 보장, click casting/경보 의미 손상, provider 부재 시 hook 잔존, 두 제안의 사용자 최종선택 오인을 확인했다. 지원면·버전·실패 style 보류와 동일 geometry가 명시된다. 새 결함 없음. |
| 10 | 기능 우선·최종 목업 마지막·이월·전체 요구·보호 경계. 후보 14–45, 153–165, 326–341, 79·93·284·308·350·454·475; R55–60 | 목업의 제작 자체가 15–16 뒤인지, Step5 P4를 완료 처리하는지, R13 전체를 live로 미루는지 대조했다. 최종 17 제작·전달, early Step6 안정 자료 참고, live19 재확인이 구분된다. R60 반영 미완 외 새 결함 없음. |

첫 읽기와 복구 범위는 다음과 같다. 아래 경로는 모두 실제로 연 출력 범위다.

- 활성 발주 `r44-plan-update/b-review-activation.md` 1–66.
- 후보 1–100 / 101–200 / 201–300 / 301–390 / 391–475.
- 대응표 1–40 / 41–75.
- canonical baseline 1–100 / 101–200 / 201–290 / 291–370.
- Phase1.3 detail 1–95 / 96–190 / 191–279.
- `REQUEST_LEDGER.md` 1–45 / 46–91; `REQUEST_LEDGER_phase1.3.md` 1–45 / 46–64의 검수 당시 입력.
- `R42-user-message.md`부터 `R60-user-message.md`까지 각각 1행 전문. 최초 scalar 처리로 한 글자만 출력됐던 R42–59는 배열로 다시 출력해 원문 전체를 복원한 뒤 사용했다.
- `supplement-r60-collection.md` 1–6.
- `old-devil-reference-comparison.md` 1–96 / 97–192.
- `a1-r36-source-evidence.md` 1–60 / 61–118.
- `forever-clean-chat-research.md` 1–60 / 61–116.
- `guimagae-addon-public-facts-2026-11-18.md` 1–60.
- `devil-ui-old-4k-layout.md` 1–58 / 59–105.
- `r44-plan-update/work_log.md`는 지정된 세 실행 출력 절 **68–85만** 읽었다. 그 밖의 옛 로그·반환은 판단 입력으로 열지 않았다.

JSON은 데이터 조회로 다뤘다.

- `requirements-coverage.json`: schema·최상위 필드·대표 R1, **R1–59 전 레코드의 status/disposition/sources/phaseSteps/artifactOrEvidence/validation**, 대응 MD 및 원문 연결을 조회했다. R42 이후 source에 `ledgerRow` 대신 `original`이 있는 경우의 조회 오류와 출력에서 잘린 R49–52는 좁힌 조회로 복원했다.
- `change-map.json`: baseline/outputs/inputReceipts/diffSummary/phaseStepMap/requestCoverage/impactMap/deferredStep5/r13Boundary/rootToolObservation/mechanicalGate/limitations를 조회했다. `unifiedDiff`는 691개 string 및 7개 hunk 경계를 조회하고, 의미 비교는 실제로 전문을 읽은 양쪽 문서로 했다. 691개 diff 행을 별도로 전독했다고 주장하지 않는다.
- `DESIGN_READY.json`: 상태·actualStatuses·limits·next·geometryProposal·designGate. render/pixels/P4/game은 모두 NOT_RUN인 입력으로 소비했다.
- `mechanical-result.json`의 22개, `mechanical-recheck-r13.json`의 8개 기록을 모두 읽었다. 원 명령의 rc1은 검사 후 CP949 출력 실패, bounded recheck는 rc0라는 로그 정정을 적용했다. 시험을 재실행하지 않았다.

복구 규칙의 실제 전문 범위:

- `C:/Users/USER/.codex/AGENTS.md` 1–153. 출력 누락 구간 47–104를 별도 복원.
- `D:/Projects/AGENTS.md` 1–80.
- 설치된 `C:/Users/USER/.agents/skills/` 아래:
  - `skill_LKS_original_review-chunking/SKILL.md` 1–138; `feedback_chunked_review.md` 1–76 / 77–139, 잘린 109–112 복원; `feedback_review_chunk_discipline.md` 1–39.
  - `skill_LKS_original_file-reading/SKILL.md` 1–20; `feedback_full_file_read_required.md` 1–57.
  - `skill_LKS_original_change-control/SKILL.md` 1–23; `feedback_change_impact_analysis.md` 1–65; `feedback_code_ownership_scope.md` 1–83.
  - `skill_LKS_original_plan-execution/SKILL.md` 1–100 / 101–195 / 196–291; `feedback_unit_loop.md` 1–73; `feedback_planning_vs_execution.md` 1–40; `references/record-formats.md` 1–91.
  - `skill_LKS_original_multi-session-orchestration/SKILL.md` 1–100 / 101–200 / 201–292; `feedback_session_division.md` 1–61 / 62–102; `references/model_effort_sample.md` 1–157.
  - `skill_LKS_original_communication-decisions/SKILL.md` 1–21; `feedback_communication_style.md` 1–87, 잘린 48–87 별도 복원; `feedback_flow_interruption.md` 1–66; `feedback_confirmed_items_policy.md` 1–62; `feedback_user_decision_no_requery.md` 1–46; `feedback_execute_explicit_choice_not_judgment.md` 1–64.
  - `skill_LKS_original_project-scaffold/SKILL.md` 1–81; `feedback_workspace_git_safety.md` 1–81.
  - `skill_LKS_original_session-recovery/SKILL.md` 1–21; `feedback_compaction_recovery.md` 1–98; `feedback_session_entry_reading.md` 1–40.

영향 지도 밖 연결 탐색에서는 별도 새 파일을 요구할 연결을 발견하지 못했다. M1은 이미 지정된 baseline·후보·대응표 사이의 연결이다. baseline 보존 사본 존재는 root 메시지로 받은 사실이며 그 사본을 새로 독립 정독·해시 검증했다고 보고하지 않는다.

파일 변경·Git·network·CUA·게임/private 접근·원본 코드 실행·시험 재생은 하지 않았다. 이 검수는 bounded 보고와 계획의 의미 대조이며 raw source 재감사가 아니다. 실제 runtime model/effort·usage·context 수치·검수 벽시계 시간은 미관측이다. 같은 B로 반환 후 대기한다.
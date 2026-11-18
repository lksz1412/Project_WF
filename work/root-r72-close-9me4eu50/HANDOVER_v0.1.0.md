# Project_WF 인계 v0.1.0 — 계획 초안 고정·GitHub 게시

작성 시각: 2026-11-18T09:34:20.578742+09:00

**재개 지점은 최신 계획 초안의 독립 문서 검수다. 게임용 기능 구현을 시작하지 않는다.** 작업 원본은 `D:/Projects/Project_WF`, 저장소는 https://github.com/lksz1412/Project_WF 이다. 사용자 R72가 다른 세션 재개를 요청했다. 이 문서는 첫 정식 인계이며, 아래의 실제 작업 기록을 잇는다.

## 1. 받은 지시와 현재 목표

목표는 옛 **데빌UI 블랙 하단집중형을 기반으로 한 전체 직업 공용 애드온 모음집**이다. 사용자에게 받은 시각 기준은 인벤 idx45의 실제 네 번째 샘플, 보조 기준은 idx11218의 미터기를 제외한 모습이다. 오른쪽 구획도 세 번째 채팅창이다. 세 반투명 채팅창·얇은 구분선·아래 사각 미니맵·양끝 장식과 구획을 유지한다. 4K 화면에서 버튼 크기→행/간격→아래부터 쌓인 높이를 정한다. 원사진/화면 전체의 비율 환산을 하지 않는다. 2022 FanFix 배치는 철회·동결됐고 현재 목표로 쓰지 않는다.

최신 작업 방식은 다음과 같다. 원문은 `Codex/results/REQUEST_LEDGER.md`, `REQUEST_LEDGER_phase1.3.md`와 `handoffs/old-reference/R<n>-user-message.md`에 있다.

| 사용자 지시 | 현재 적용 |
|---|---|
| R44/R60: 단일 애드온이 아닌 모음집 | 필수 외관/관리 묶음은 허용하되 기능 제품은 폴더·TOC(게임 로드 목록)와 수명을 갖고 독립 선택 가능하게 한다. 단순 표시 토글만으로 대신하지 않는다. |
| R61/R62: 전체 직업 공용·직업 기능은 Hekili 기반 | 주술사는 우선 실제 확인할 직업이다. 실제 Forever 직업/특성·자원·Hekili 기능 지원을 확인하며 전체 직업/치유 추천 지원을 창작하지 않는다. |
| R63/R64: 공통 외관을 구현1로, 기능마다 한 Phase | 기존 시작 애드온을 기능별 하나씩 배정해 수정/최신화/검증부터 한다. 해결되지 않은 실제 부족만 개발한다. |
| R44: 저장/복원·사용자 커스터마이징 필수 | 기존 Reflux/profile 및 Devilconfig 편집 기능부터 수정한다. 상태/proc·재사용 대기시간·선택 추천은 Hekili 전투보조 한 제품 역할이다. |
| R47–50: 전체/부분 재사용 구분·더 나은 자체 구현 유지·외부 기능도 외관 통일 | 아직 없는 자체 구현을 우수하다고 하지 않는다. 외부 공격대/미터기 기능·입력·경보 의미를 보존하며 설정/스킨/필요 연결을 수정한다. |
| R51/R52: 같은 구획의 대안 테마 1–2안·필요하면 데빌 질감 개선 | 현재 제안은 두 테마이나 최종 사용자 선택은 아니다. 실제 품질을 보고 개선하며 원본은 보존한다. |
| R55/R56: 가능한 작업 전부 뒤 최종 목업 | 최신 미래 수신 단계는 Step39다. 지금 새 목업을 만들지 않는다. |
| R65: 마스터플랜 먼저 사용자 검수 | 초안 독립 검수→실제 원문 대조/통합→사용자 검수·피드백 반영·명시 GO 뒤 기능 구현. Git 게시 승인은 기능 구현 GO가 아니다. |
| R67–70: 지정 저장소 main에 작업물 전부, 매크로도 ID만 추상화, README만으로 대체 금지 | 원본 ZIP·work·중간 결과까지 게시했다. 원본 D:는 보존하고 공개용 사본의 계정/캐릭터/개인 경로만 가명 처리했다. |
| R71/R72: 한 묶음 마감·commit/push·핸드오버 | 이번 마감점은 계획 초안 작성과 자체 검사다. 최신 독립 검수와 사용자 검수는 다음 세션으로 남긴다. |

매크로는 원본4파일/44개·6487B를 도서관처럼 보관한다. 게임으로 옮기기/주문 변환은 취소됐으며 새로 실행하지 않는다. R68은 익명화한 Git 공개 사본을 허용했다. 원문 명령·조건·오타·빈 본문·순서는 그대로다. 비매크로 Retail 설정은 R13에 따라 안정된 저장 상태를 확인한 뒤 필요한 뜻만 읽기 참고하며 자동 이식하지 않는다.

## 2. 실제 작업과 고정된 현재 상태

| 작업 | 실제 상태·근거 |
|---|---|
| 옛 원형 조사 Step3 | 기록상 수용: 독립10관점 중대0/중간0/경미1. 34글·확보50고유그림, 미관찰2. X2 전체4217 중 부적합288로 전체 추출 차단, 안전46개만 회수. `Codex/docs/old-devil-reference-comparison.md`, Step3 이력/수용 기록. |
| 현재 채팅 조사 Step4 | 기록상 수용0/0/0. 공식4후보/관련46선택 소스/48근거칸, 실제게임10항목 전부 미수행. `Codex/docs/forever-clean-chat-research.md`, Step4 이력/수용 기록. |
| 새 원형 배치 Step5 | 설계 입력·자산/명세와 자체 설계검사30/30까지만 있다. 최신 4K 렌더·픽셀 검증·새 이미지 판독·독립 시각 검수·게임 검증은 미수행이다. `Codex/docs/devil-ui-old-4k-layout.md`, `Codex/results/old-devil-layout/DESIGN_READY.json`. |
| 계획 개정 | 최신 작업 파일은 `Codex/results/handoffs/old-reference/r44-plan-update/master-plan-candidate.md`와 요구 대응표 MD/JSON·change-map.json·work_log.md다. 현재72요구/13기능 Phase/최종 목업39 구조를 작성했다. 최종 자체검사 고정값은 아래 후속 기록에서 확정한다. |
| 현재 canonical | `Codex/plans/2026-11-17-devil-ui-forever-plan.md`는 여전히 **옛370행**이다. 최신 개정 후보를 승격하지 않았다. 옛 목업 선행·주술사 한정·자체 제작 우선 문구를 현재 실행 지시로 따르지 않는다. |
| 최신 독립 검수 | 최신72요구 초안은 아직 검수하지 않았다. 이전475행/59요구 대상 B 검수는 중대0/중간1 M1(승격 후 옛 행 좌표 깨짐)이었다. 같은 A1이 불변 baseline 경로로 수정했으나 새 범위의 B 확인은 아직이다. |
| 게임용 구현 | 이 모음집을 위한 기능 코드/설치/설정/게임 입력/전투 검증은 시작하지 않았다. 저장소에는 참고 원본 코드와 분석/이전 렌더 스크립트가 포함돼 있다. |

기능별 시작점은 공통외관=V42 !DevilUI의 필요한 기전/자산, 행동단축바=Dominos, 미니맵=SexyMap, 3채팅=Prat, 기본 상태/직업자원=Forever Unit Frames, 시전바=Quartz, 저장/범위복원=Reflux, 사용자 편집=Devilconfig, 직업 전투보조=Hekili Forever, 공격대=Grid2, 데미지=Details!, 어그로=ForeverThreat, 대안테마=수정된 공통외관 기반이다. 정확한 범위/판본/예상/검증은 최신 후보 표를 읽는다. 이름 배정은 현재 PC 작동 보장이 아니다.

Root가 확인한 최신 공식 파일 단서는 Grid2 9637467(4.1.13-forever), ForeverThreat 9671243(1.12.3), Details! 9521145, Hekili 9665215(v0.8.6-forever)다. `root-starting-addon-facts-and-r67.md`의 원천/한계를 따른다. Reflux 지정5파일은 A1과 root가 실제 전문으로 읽었다. 일반 switch는 전체 AceDB 목록 및 emulated `_G`·로그아웃 복원/ReloadUI로 연결되며, save는 저장 묶음을 비우고 현재 emulated 값을 다시 채운다. 이를 그대로 안전한 모음집 범위복원으로 간주하지 않는다. allowlist·다른 직업/미설치 entry 보존 등은 기존 기능 수정/검증과 입증된 부족 보완 대상이다. 실행한 것은 아니다.

## 3. 미완료 항목과 다음 작업

1. 최신 A1 고정본과 실제 자체검사 출력을 확인한 뒤 독립 B의 **문서 구조 변경 P5 10관점** 검수를 수행한다. 새 범위는 모음집/전직업/Hekili, 외관 구현1/기능별 Phase/기존 수정 우선, 범위복원/편집, 공개 사본·원천 보호, 불변 근거/요구 추적/비용/최종39 연결이다. 과거 원본·CRC·설계검사를 반복하지 않는다.
2. B의 인용을 root가 실제 원문에서 확인하고 중대/중간만 같은 A가 한 번에 수정, 같은 B가 변경/연계 범위를 재확인한다. 이전 M1은 같은 문제를 현재 경로와 대조한다. 최신 원문을 읽지 않고 옛 B의 0/1 결과를 새 초안에 적용하지 않는다.
3. 수용 뒤 root가 canonical·현재 Phase1.3 세부계획·INDEX·요청 대장·세션/처리표를 맞춘다. Correction History는 별도 계획 이력 파일로 원문 그대로 옮긴다. 기존 Result는 덮어쓰지 않고 12항목 MD/JSON addendum을 만든다. Step5는 연구/설계 인계만 닫고 렌더/P4는 `VISUAL_USER_DEFERRED_TO_STEP39`로 명시한다. 기존 `DESIGN_READY`의20파일 중 세부계획279행은 보존 사본으로 연결하고 현재 운영 파일 변경을 따로 기록한다.
4. 사용자에게 실제 저장된 마스터플랜·기능별 시작 애드온/순서 표를 제시해 검수받는다. 피드백 반영·명시 GO 전에 기능 구현/목업/설치를 시작하지 않는다.

현재 미래 누적 Step은1–46, 실제1–5 이력은 보존된다. 최종 목업39는 가능한 기능/연계검사/수정 이후다. 후보의 고정 미래 추정1915–3465분에 실제 직업/검사/시각 사례 및 입증된 부족의 변수가 추가된다. 실제 직업 수/범위를0으로 가정하지 않는다. 이 인계는 구현이나 검수 완료 선언이 아니다.

## 4. 다음 세션 주의점·Git 운영·읽을 파일

### Git와 원본 보호

- 최초 전체 공개 snapshot은 main `b1b658ff6d8185671cb59dcf00f7bf6ef0e8d807`,20,062파일/649,177,449B다. 원본 payload19,692개와 기존 원격367파일, 공개 검증 기록을 포함한다. 원격 지침 커밋 `a27493a87381ebe6c4877d00aa6e9d06c5a05982`를 보존했다. `.gitignore`는 두 규칙을 함께 유지하고 원래 local 파일도 별도 보존했다. 실행 모드30개도 원격과 일치한다. force push/merge/이력 삭제는 하지 않았다.
- D: 원본 저장소의 작업 가지는 `master`, 기존 HEAD는 `4aab0466b358c718cd765404ab09d1b6a8bcc09a`다. `origin`은 지정 GitHub이며 main을 fetch했다. **원본 개인 식별자가 있는 D:를 그대로 강제 staging해서 공개하지 않는다.** 익명화한 공개용 Git 사본을 사용했다.
- 공개용 사본 위치는 `%USERPROFILE%/Documents/Codex/2026-11-17/new-chat-2/work/github-publish-eb16ef0c93f04f7eaa7bb57fed190118/repo`다. 그 사본의 main이 GitHub main을 추적한다. 이전 local snapshot `44e06f99a15c1a819d1cfe78501f83abe6b7f0be`는 `local-snapshot-20261118` 가지에 남아 있다. D:의 개인 원본과 public 사본을 혼동해 checkout/reset/덮어쓰기 하지 않는다.
- 이전 private publisher controller는 같은 parent 폴더에 있다. 최초 source-only 사본을 가정한 도구라 현재 원격367파일/추가 기록이 있는 사본에 그대로 재실행하지 않는다. 갱신은 원격 파일·실행 모드·ignore 합성을 보존한 변경 범위 복사/개인 식별자 추상화로 수행한다. Git은 root 몫이다.
- 공개 사본은 계정/캐릭터/개인 경로만 추상화한다. 게임의 공통 지명/아이템명이나 옛 배포자의 공개 기본 프로필을 개인 ID로 오인해 고치지 않는다. 매크로4파일/44개와 ZIP15개는 실제 byte 동일을 확인했다. 역방향 ID 대응표는 공개하지 않는다.
- 이 문서 포함 인계 커밋/최종 푸시는 마지막 단계에서 수행한다. 실제 최신 값은 원격 main과 이 채팅의 최종 커밋 링크로 확인한다. 현재 문서의 `b1b658f`는 그 전 전체 snapshot 기준이다.

### 먼저 읽을 현재 파일

| 파일 | 역할 |
|---|---|
| 이 HANDOVER_v0.1.0.md | 최신 목적·미완·안전한 재개 순서 |
| `Codex/docs/INDEX.md` | 구조 맵·기록 위치 |
| `Codex/results/handoffs/old-reference/r44-plan-update/resume-after-publication-r70.md` 및 `r71-checkpoint-and-ledger-source.md` | 마지막 작업 발주/한 묶음 마감 경계 |
| `.../master-plan-candidate.md`, `requirements-coverage.md/.json`, `change-map.json`, `work_log.md` | 실제 최신 초안·요구별 연결·검사 출력 |
| `.../baseline-master-plan-before-R44.md` | 불변370행/SHA703AFF3F268D678193ACDB074AAFE8EC6191477AF7A5AAE43D5583DFA6E24D79. 옛201/253–260/352행 근거는 이 파일이다. |
| `.../baseline-step5-detail-at-design-ready.md` | 불변279행/SHADD11E621123EFBE1C162FBB18634AC4A9A2186C79E0AA5130AFCA1CBA4FA56EF. |
| `.../baseline-request-ledger-r71-before-integration.md` | R71까지88행/SHA0f39335b0ab8add70407417d4eced19245762051ddb9ff54821e492ff9f6f6cf. root 상태 갱신 전 원문 행 보존. R72는 별도 원문 파일. |
| `Codex/results/REQUEST_LEDGER_phase1.3.md`, 이전 `REQUEST_LEDGER.md`, `R71/R72-user-message.md` | 실제 요청/승인/대체·마감/인계 지시 |
| `.../b-review-initial-raw.md`, `handoffs/old-reference/TRIAGE_phase1.3.md`, `SESSIONS.md` | 이전 검수 원문·root 확정 M1·같은 A/B 역할 기록 |
| `Codex/results/PHASE_1.3_old-reference-clean-chat_RESULT.md/.json`와 세부계획 | 옛 원형/채팅 수용과 Step5 미완 기록, 덮어쓰지 않고 addendum |
| `Codex/results/handoffs/old-reference/github-publish/` | 전체 게시 범위·검증·main 게시 결과 |

`...`는 `Codex/results/handoffs/old-reference/r44-plan-update/`다. 실제 최신 계획의 검증 입력은 원문·연계 파일만 지정한다. B에게 옛 로그 전체/원본 패키지 전체를 무차별로 읽히지 않는다. 활성 AGENTS와 적용되는 규칙/스킬은 새 세션의 실제 경로로 전문 읽고 복구한다. 이 인계는 그 읽기를 대신하지 않는다. 실제 transcript 경로가 제공되지 않아 숨은 대기열 완전성은 미검증이다. 가장 최근 로그를 임의로 현재 transcript라고 고르지 않는다.

같은 Phase의 A1은 `/root/old_reference`, B는 `/root/old_reference_audit`, 게시 정형 worker는 `/root/publish_snapshot`이었다. 설정 모델은 sol/high(A1/B), sol/medium(게시 worker)이고 실제 model/effort/usage/context는 미관측이다. 새 세션에서 실제 재사용 가능 여부를 확인하며, 사용할 수 없으면 해당 역할을 새로 배정하고 지정 입력을 전문으로 읽힌다.

C:의 `step5-asset-mechanics.py`는 처음 쓰기 전 존재 여부를 확인하지 못했던 과거 경로 문제다. D: 사본과 현재 byte는 동일하지만 이전 파일 부재/덮어쓰기·복원 완료를 주장하지 않는다. 추가 수정/삭제하지 않는다. 자세한 근거는 `devil-ui-old-4k-layout.md`와 `root-asset-script-check.json`이다.

## 5. 현재 handover chain

정식 인계1 = 이 문서다. 앞선 작업별 연결은 `handoffs/forever-ui/recovery-checkpoint.md`와 계획 Result → source-analysis/Step1 → old-reference/iter_1 Step3 수용 → iter_2 Step4 수용 → iter_3 Step5 설계 고정 → r44-plan-update의 개정 후보와 이전 B M1 → github-publish의 전체 main 게시 → 이번 R71/R72 초안 고정/인계다. 원본 이력과 이전 스냅샷은 삭제하지 않는다.

인계 고정 후 실제 A1 반환/검사·파일 해시와 최종 게시 확인은 아래 절에 이어 적는다.

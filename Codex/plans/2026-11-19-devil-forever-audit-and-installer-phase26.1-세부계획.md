# Phase 26.1 — 요구·배포 기준 대조

2026-11-19 · R151 실행 승인 · D:/Projects/Project_WF

[마스터 플랜](2026-11-19-devil-forever-audit-and-installer-plan.md) · [현재 구현 결과](../../Claude/results/Step%2040%20%E2%80%94%20Codex%20collection%20integration.md)

## 목표

Step 44–45에서 감사할 사용자 요구와 배포 실물을 고정한다. 이 단계의 비교 기준은 현재 Step 40의 오프라인 설치 묶음이다. 새 감사 결과를 반영한 배포 기준은 Step 48에서 정하고, 설치기 계약은 그 기준을 소비한다. 게임 검증과 Step 41 판단은 기존 확인표와 실제 접속 결과를 따른다.

## 스텝

| Step | 예상 | 작업 | 완료 조건 | 상태 |
|---|---:|---|---|---|
| 44 | 45–90분 | Codex·Claude의 요청 원문, 계획·이력, 검토 결과를 현재 기능 트리에 연결한다. 요청별 출처·수정/철회 관계·게임 확인 필요 여부를 적는다 | 요청 번호 순서·누락·중복 검사. 각 적용 중인 요구에 지목 가능한 원문·기능 담당·소비 코드나 설치 경로가 있거나 확인 부족 사유가 있다. 폐기된 산출물도 기존 요청을 가리킨다 | [대조·독립 재검 통과](../results/Step%2044%20%E2%80%94%20요청과%20실제%20기능%20대조.md) |
| 45 | 45–90분 | 기본 빌더의 PitBull4·Forever Unit Frames·단일 접속 비교 ZIP을 별도 출력에서 생성하고 Step 40 기준과 비교한다. 현재 매니페스트, 레이아웃, 출처 파일, 검증 기록을 묶는다 | 변형별 전체 해시·파일 목록·필수 의존성·실제 배치 입력 확인. 차이가 있으면 멤버 파일까지 좁힌다. 세 ZIP과 감사 입력의 사용 범위를 기록한다 | 재빌드와 ZIP 검사 통과. 감사 입력으로 정리 대기 |

## 기준 확인 결과

- Codex와 Claude의 요청 대장 24개에서 R1–R150의 단독 행을 확인했다. 중복 기록된 번호 13개와 여러 번호를 묶은 범위행 2개는 Step 44에서 원문과 대조한다. [요청 번호와 대장 위치](../../_local_only/phase26-1-baseline-20261119/request-catalog.json)
- 현재 D: 작업본에서 다시 만든 PitBull4, Forever Unit Frames, 단일 접속 비교 ZIP의 전체 SHA-256이 Step 40의 기존 세 ZIP과 각각 일치했다. ZIP 내부 해시 대조, Lua 5.1 구문 검사, 필수 애드온 의존성 검사도 통과했다. [ZIP 대조](../../_local_only/phase26-1-baseline-20261119/baseline.json) · [검사 출력](../../_local_only/phase26-1-baseline-20261119/verification.txt)

## Step 44 입구와 판정

1. `Codex/results/REQUEST_LEDGER*.md`와 `Claude/results/REQUEST_LEDGER*.md`의 현행 대장을 확인한다. 오래된 별도 저장본은 원문과 변경 시점을 찾는 데 쓴다. 범위 요약행과 단일 요청을 구분하고, 중복 출처가 일치하는지 원문으로 판단한다.
2. 현재 기능 트리의 공통 설정, 하단 조작, 대화, 전투, 그룹·기록, 성장·퀘스트 순으로 확인한다. 서로 다른 기능을 하나의 요청이 바꿨으면 같은 요청 번호를 연결한다. 마스터 플랜·결과·인계에서 완료라고 표기해도, 어떤 시험을 통과했는지 따로 확인한다.
3. 요청은 현재 적용, 이전 지시를 대체, 철회, 결정 대기 중 하나로 표시한다. 실행 근거는 소스/설정, 실제 ZIP, 오프라인 호출, 게임 관측 순으로 적고, 수행한 범위만 판정한다.
4. 자료 구조는 요청 ID, 원문 경로와 줄, 결정의 후속 관계, 기능 트리 항목, 코드·프리셋, ZIP 변형과 해시, 확인 근거, 열린 항목으로 맞춘다. 가독성이 필요한 보고서는 문서, 비교용 데이터는 JSON으로 남긴다.

| 첫 대조 구간 | 확인할 차이 | 자료 |
|---|---|---|
| R44·R60·R61, R107·R148 | 선택 가능한 모음집과 공통 Core의 경계. 전 직업 범위와 실제 추천이 준비된 특성 범위 | [기능 트리](../../Collection/data/feature-map.md) · [Hekili 지원표](../../Collection/data/hekili-support.md) |
| R23·R34·R112 | 원본의 채팅 세 공간, 앞선 Phase 4의 Prat 구성과 이후 네이티브 채팅 선택 | [초기 Phase 4 결과](../../Claude/results/PHASE_4_prat-chat_RESULT.md) · [네이티브 창 위치](../../Collection/AddOns/DevilForever_ChatSetup/ChatLayout.lua) · [현재 설치 목록](../../Collection/install.json) |
| R100·R101·R104 | 기본 퀘스트 추적기·Cooldown Manager·Hekili의 담당. 위치 제안과 실제 사용하는 배치 값 | [기본 UI 확인 좌표](../../References/codex-verify/one-session-review.md) · [Cooldown Manager 입력](../../References/codex-appearance/8/report.md) |
| R107·R110·R140 | PitBull4는 초기 시험판이며, 최종 기본판은 실제 비교 결과를 따른다. 이름표 시전 유지, 소환수 표시와 시계 소유권 대조 | [Phase 25](../../Claude/plans/2026-11-18-devil-forever-addon-collection-phase25-세부계획.md) · [현재 설치 목록](../../Collection/install.json) |
| R134–R143 | 문양·종족 외관·핏불과 소환수 영역. 마지막 적용 목업과 동일한 실행 파일 확인 | [외관 결과](../../Claude/results/Step%2040%20%E2%80%94%20Codex%20racial%20appearance.md) · [적용 목업](../../References/codex-appearance/24/racial-appearance/index.md) |
| R114·R145–R150 | 오프라인 좌표·코드, 실접속 일괄 확인, 전면 감사와 설치기 요청의 실행 범위 | [현행 단계 대장](../../Claude/results/REQUEST_LEDGER_phase25.md) · [Phase 26 요청](../../Codex/results/REQUEST_LEDGER_phase26.md) |

## Step 45의 배포 계약

| 입구 | 검증 |
|---|---|
| `Collection/install.json` → `Collection/tools/build.py --install --variant <name> --out-dir <isolated-path>` | 세 변형의 폴더 목록과 구조를 실제 ZIP 안 manifest 및 파일 목록에서 읽는다. `one-session`은 진단용으로 판단하고 첫 설치기의 기본 ZIP에 섞지 않는다 |
| 새 ZIP → Step 40 기존 ZIP | 바이트 단위 해시, ZIP 개별 파일 해시, 스크립트 버전, 각 변형을 이어받는 기능 목록을 대조한다. 빌드는 현재 D: 작업 트리를 입력으로 한다. HEAD와 작업 트리가 같은 상태라고 기록하지 않는다 |
| 코드와 프리셋 → 화면 | 기준 ZIP의 실제 설정과 기존 호출 검증을 함께 대조한다. 목업에만 생긴 좌표와 게임에 표시된 상태는 따로 근거를 붙인다 |
| 오류와 차이 → Step 46 | 증거 경로·실행 조건·재현 순서·영향받는 설정을 전달한다. 기존 ZIP과 설치 폴더에 쓰지 않는다 |

## 검토 계획

| 대상 | 관점 | 수용 조건 |
|---|---|---|
| 요청·자료 목록 | P5 · ③. 파일 연결, 후속 결정 누락, 동일 ID의 중복 기록, 근거 단계 과장, 예전 계획의 우선순위 혼입 | 요청 하나에서 결정과 실제 대상까지 찾아갈 수 있다. 요청 번호 존재 검사로 요구 대조가 끝났다고 판정하지 않는다 |
| 배포 코드와 ZIP을 연결하는 기록 | P3 · ④. SHA-256 대조, 현재·이전 위치, 변형 분리, 모듈 목록, 실행 결과 | 실제 빌드 출력과 판정 일치. 차이가 있을 때 기준이나 파일을 덮어쓰지 않는다 |

Step 44와 45를 순서대로 마감하고, 독립 검수자는 같은 자료로 누락과 잘못 채택한 과거 결정을 반증한다. 이 계획의 시험 산출물은 `_local_only/phase26-1-baseline-20261119/`에 남긴다.

## 실행 경계

R150에서 시험용 기준 ZIP을 격리 경로에서 재생성했다. R151의 실행 승인에 따라 요청과 구현을 대조하고 배포 기준을 감사 입력으로 고정한다. 이후 결함 수정과 Windows 11 x64 오프라인 설치기 제작은 마스터 플랜 순서를 따른다. 실제 게임 디렉터리 쓰기와 외부 게시는 별도 승인 범위다.

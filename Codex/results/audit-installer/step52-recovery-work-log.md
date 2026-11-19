# Step 52 복원과 관리 항목 제거 작업 기록

2026-11-19 · 역할 설정 bada-a2-coder / gpt-6.1-sol high. 실제 모델·사용량 미관측. 기존 기록과 승인 ZIP을 사용하는 같은 Phase27.2 작업 A다.

## 변경 전 영향 지도

| 위치 | 영향과 처리 |
|---|---|
| Models·InstallationStore | 함께 고침. 복원 원본 위치와 연결된 원 실행을 기록하고 current active의 권위 연결을 유지 |
| InstallerEngine·공개 CLI | 함께 고침. plan의 rollback/remove, 실제 명령과 동일 결과를 연결 |
| 새 복원 엔진 단위 | 함께 작성. 완료 적용·제거, 미완 적용·복원, 완료 후 반복을 실제 지문으로 판정 |
| 승인 계약·catalog·ZIP | 확인만. 기본판과 대체판의 값과 파일을 유지 |
| 기존 Step51 시험 | 확인만. 같은 API와 파일 기록을 소비. 새 회복 시험은 실제 공개 EXE로 구동 |
| 게임·WTF·원본 vendor·다른 작업자 파일 | 범위 밖. 새 격리 게임 대역만 사용 |

## 정독

Phase27.2 1–27, Contract 1–140, Step51 결과 1–27, Step51 로그 1–83, rollback-implementation-notes 1–16, InstallerEngine 1–339, InstallationStore 1–175, Models 1–137, Snapshots 1–80, WindowsPaths 1–177, ApprovedPackage 1–210, Program 1–63행을 전문으로 다시 읽었다. 변경 전 사본·해시는 새 step52-recovery 스크래치의 before.json에 있다.

## 단위 1 · 복원 목표와 파일 연결

복원 계획은 미완 rollback을 우선하고, 같은 원 실행과 연결된 두 기록만 한 회복 흐름으로 허용한다. 현재 active의 ID·동작·전체 내용과 같은 journal의 AfterActive가 연결되어야 한다. 완료 복원은 최신 rollback 포인터를 유지하고 같은 명령을 반복할 때 물리 목표를 대조한다.

원래 실행의 before 백업은 이동하지 않는다. 새 rollback의 stage에 파일별 해시를 검증해 복사하고, 현재 파일은 새 displaced로 이동한다. 복사 중단을 위해 임시 파일은 별도의 work에 flush하고 stage 파일 경로에 완성본만 옮긴다. stage가 올바른 파일의 일부만 가진 경우에는 같은 목표의 나머지 파일을 이어서 복사할 수 있다.

## 단위 2 · 제거와 중단 상태

제거는 관리 기준과 같은 폴더만 before로 옮기고 사용자 수정 폴더는 실제 상태로 보존한다. 제거 이전의 실제 파일 지문과 관리 기준을 모두 기록한다. 제거를 복원하면 당시 사용자 수정도 그대로 남고 verify는 원래 관리 기준과의 차이를 계속 보고한다.

원본→백업, 준비→대상 두 이동이 같은 대상을 공유하므로 폴더의 전체 초기·목표·현재·보관본을 묶어 판정한다. 이미 목표 파일과 active가 함께 확정된 경우는 원래 완료 기록만 마무리한다. 미완 rollback은 같은 실행 ID와 goal을 이어가며 이미 끝난 폴더와 남은 폴더를 구분한다. 새로 끼어든 사용자 파일은 미리보기 충돌로 남긴다.

첫 빌드는 경고 0·오류 0이었다. 실제 공개 CLI 시험은 새 recovery-cli 스크래치에서 진행한다.

## 실제 구동과 최종 연결 확인

실행 명령은 `python -X utf8 -B -I Collection/tests/installer/recovery.py --exe <scratch>/artifacts/bin/DevilForever.Installer/debug/DevilForeverSetup.exe --packages _local_only/phase26-work-r151-20261119/step47-candidate-02/archives --scratch <scratch>`다. `runtime-01.log`의 판정은 공개 EXE 33회 호출, 흐름 5개 통과다.

- 실제 PitBull4→FUF→PitBull4 전환, 이전 FUF 복원과 반복 rollback의 전체 대상 지문 동일.
- 수정 폴더 보존 제거, 새 사용자 폴더가 생겼을 때 복원 충돌과 쓰기 0건, 충돌 폴더를 별도 보존한 뒤 실제 제거 전 상태 복원.
- 명시 인수한 미관리 폴더의 원래 파일 복귀와 원본 before 백업 유지.
- 이미 active가 확정된 미완 journal 마감, active 확정 전 상태를 기록 대역으로 만든 뒤 실제 설치 파일 복원.
- 한 폴더가 아직 남은 미완 rollback 상태를 실제 디렉터리 이동으로 구성한 뒤 같은 ID로 완료, 반복 때 새 기록·파일 쓰기 0건.

원명령과 JSON은 `_local_only/phase26-work-r151-20261119/step52-recovery-v6ixgox9/recovery-cli-d4uevaf0/calls.json`, 판정은 같은 경로 result.json에 있다. journal 경계는 격리 대상에서 구성했으며 실제 프로세스를 강제 종료한 시험으로 보고하지 않는다.

최종 연결 보정으로 준비가 끝난 뒤 실제 이동 전에 active의 원래 전체 해시를 다시 확인한다. 원자 교체 도중 남을 수 있는 정확한 `active.json.<32자리 hex>.tmp` 일반 파일은 보존한 채 읽는다. 그 내용으로 active를 추정하거나 파일을 지우지 않는다. 그 밖의 미확인 이름과 링크는 기존 거부 규칙을 따른다. 제거를 반복할 때 이전부터 보존한 폴더도 목록에 표시한다.

이 세 변경은 최종 EXE로 별도 확인했다. 원자 임시 파일을 둔 상태에서 조회·복원 무변경, 실제 설치·수정폴더 보존 제거의 active 해시 확인 호출, 반복 제거의 보존 목록과 전체 파일 무변경이 통과했다. 공개 호출 9개, 판정 3개이며 `final-linked-check.json`·`final-linked-check.log`에 기록했다. 최종 빌드는 경고 0·오류 0이다. 기존 대형 시험은 이 연결 확인에서 반복하지 않았다.

## 반환 경계

현재 엔진의 여섯 공개 동작을 CLI와 같은 Request/Result API로 호출할 수 있다. GUI는 백그라운드 Task에서 Execute를 호출할 수 있으며 진행률 콜백은 아직 추가하지 않았다. 청정 Windows·정식 단일 파일 배포·실제 게임 적용은 후속 단계다. 원 ZIP·계약·카탈로그·게임·Git commit은 수정하지 않았다. 같은 B의 독립 검수 대기다.

## 독립 B 보정 · journal 지문 키의 연결

B는 Before/After 키 집합이 다르거나 RestoreSources가 After에 없는 폴더를 가리킨 기록이 읽기를 통과해 rollback plan에서 KeyNotFoundException을 내는 결함을 확인했다. 수정 전 Store와 이 기록은 새 step52-key-fix 스크래치에 보존했다.

| 위치 | 처리와 연결 |
|---|---|
| Store.ValidateJournal | 함께 고침. Before/After 키 집합의 정확한 일치, rollback source의 목표 키·존재 상태, 다른 작업의 source 금지를 사전 검증 |
| Recovery BuildResume·BuildReverse | 확인만. 검증한 같은 키를 인덱싱한다. 정상 생성되는 실제 기록은 동일 키 집합이며 소비 계약 유지 |
| 새 journal 키 시험 | 함께 작성. 실제 생성된 35폴더 기록을 기반으로 손상시킨 pending과 정상 pending을 공개 CLI로 읽어 구조 결과·쓰기 0건 확인 |
| 기존 ZIP·파일 적용·넓은 복원 시험 | 영향 없음. 기존 통과 결과를 반복하지 않음 |

보정 전에 Store 1–222, Models 1–138, Recovery 1–425와 이 작업 기록 전문을 다시 읽었다.

Before/After의 정확한 키 집합을 비교하고 RestoreSources의 각 폴더가 After에 있으며 실제 존재 목표인지 확인한다. rollback 이외의 실행에는 RestoreSources를 허용하지 않는다. 기존 invalid-record 분기로 구조화한 종료2를 반환한다.

`dotnet build ... --no-restore --artifacts-path <기존 scratch>/artifacts`는 경고 0·오류 0이다. `python -X utf8 -B -I Collection/tests/installer/journal_keys.py --exe <scratch>/artifacts/bin/DevilForever.Installer/debug/DevilForeverSetup.exe --template-game <실제 생성된 35폴더 기록의 게임 대역> --scratch <새 key-fix scratch>`가 종료0이었다. 키 불일치, 목표 키 누락, 존재하지 않는 복원 목표, 비복원 실행의 source 네 조건에서 invalid-record/blocked/종료2였고, 정상 pending 계획은 ready/종료0이었다. 다섯 조건 모두 파일·디렉터리 목록과 해시 전후 차이가 0이다.

원출력은 `step52-key-fix-n3rrf5dd/runtime.log`, 실제 명령·JSON은 `journal-key-cases-t7kn9yay/result.json`에 있다. 넓은 설치/복원 시험은 반복하지 않았다. 같은 B 재확인에 반환한다.

## B 시험 입력 보정

위 다섯 시험 중 missing-restore-target·absent-restore-target는 복제한 Moves가 이전 실행 ID를 가리켜 이동 경로 검사에서 먼저 거절됐다. 의도한 source/After 연결을 확인한 근거로 이 두 기존 판정은 사용할 수 없다. 원래 로그는 보존한다.

두 시험의 Moves를 새 rollback ID에 맞추고 대상 PitBull4의 이동을 제거했다. missing은 Before/After 양쪽에서 PitBull4를 뺀 같은 키 집합, absent는 같은 키 집합에서 존재하지 않는 목표를 사용한다. 반환 코드와 함께 정확한 `복원 원본 경로가 잘못되었습니다.` 진단도 요구한다. 소유 수정은 이 시험과 기록 두 파일이며 제품 코드는 바꾸지 않았다. 두 조건만 재실행한다.

최종 `journal_keys.py --case missing-restore-target --case absent-restore-target`는 종료0이다. 두 조건 모두 의도한 `invalid-record`·정확한 source 진단·종료2였고, 대상 및 관리 파일·디렉터리 지문이 그대로였다. 원출력은 `step52-test-reason-bdzj5m6a/runtime-final.log`, 실제 JSON과 fixture의 키 개수·목표 존재 여부는 `journal-key-cases-i102mnzb/result.json`이다. 이전 다섯 조건 전체와 대형 시험은 반복하지 않았다.

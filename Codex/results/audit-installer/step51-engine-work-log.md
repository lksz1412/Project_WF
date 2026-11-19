# Step 51 파일 적용 엔진 작업 기록

2026-11-19 · 역할 설정 `bada-a2-coder` / gpt-6.1-sol high. 실제 실행 모델·사용량은 미관측이다. 작업 영역은 설치기 신규 C#·프로젝트와 전용 시험, 이 기록이다.

## 변경 전 영향 지도

| 위치 | 연결과 영향 | 처리 |
|---|---|---|
| Contract.md와 ReleaseCatalog.json | 공개 입구·상태·정확한 SHA·폴더를 정하는 입력 | 확인만. 계약과 카탈로그를 embedded resource로 소비 |
| 새 C# 프로젝트·CLI·엔진 | 조회·계획·적용의 입력부터 Windows 파일·기록까지 | 함께 작성. GUI가 같은 공개 Request/Result API를 호출할 수 있게 구성 |
| 원 ZIP과 빌더 | 실제 포장·파일별 해시·명시 디렉터리의 입력 생산자 | 확인만. 승인 스트림에서 길이·전체 해시·내부 manifest·파일 해시 확인 |
| active/journal과 디렉터리 지문 | Step52 복원·제거가 기대는 계약 | 함께 작성. 이전·예정 활성 기록과 이동 전후 지문·위치를 기록 |
| 전용 시험 | 정상 CLI·미리보기·충돌·상태 보존을 실제 입구로 호출 | 함께 작성. 기존 Lua/게임 시험은 재실행하지 않음 |
| 기존 AddOns·WTF·다른 작업자의 파일 | 보호할 원천과 범위 밖 결과 | 새 격리 대상만 사용. 게임·vendor·기존 소스 변경 없음 |

## 정독 입력

활성 AGENTS 1–153행, file-reading/change-control SKILL 각각 1–20/23행, 작업물 보호 1–81행, 영향 지도 1–65행, 실행 검증 1–46행, 코드 범위 1–83행, 주석 1–41행, 전문 읽기 1–57행, 소통·흐름·금지어 원본을 전문으로 읽었다.

마스터 1–165행, Phase27.2 1–27행, Contract 1–140행, ReleaseCatalog 1–101행, Phase27.1 결과 1–45행, scratch core-task-prep/engine-review-cases/acceptance-matrix 각 1–12/27/16행을 전문으로 읽었다. 실제 ZIP·manifest는 구조 데이터로 전수 검사한다.

## 기록 위치

새 실행과 원출력은 `_local_only/phase26-work-r151-20261119/step51-engine-vk2kfcmc/`에 보존한다. 제품 코드의 구동·판정은 아래 자연 단위가 끝날 때 적는다.

## 단위 1 · 실행 입구와 입력

카탈로그를 실행 파일에 포함하고 CLI와 `InstallerEngine.Execute(InstallerRequest)`를 같은 입구로 연결했다. 승인 ZIP을 단일 읽기 스트림으로 잡아 길이·SHA-256, 매니페스트, 내부 목록과 파일별 해시를 확인한다. 준비 위치의 파일을 다시 읽어 검증한다. 대상의 볼륨과 128비트 파일 ID로 경로를 식별한다. ReFS에서 64비트 파일 인덱스의 유일성이 보장되지 않는 원문을 확인하고 FileIdInfo를 사용했다. [Microsoft 파일 ID 설명](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/ns-fileapi-by_handle_file_information)

초기 컴파일의 지역 변수 초기화 오류를 고쳤고 `dotnet build`는 경고 0·오류 0으로 끝났다. 권한 검사에서 부모 디렉터리의 DELETE_CHILD를 일괄 요구하던 부분은 실제 이동할 기존 폴더의 DELETE 접근 검사와 새 항목 생성 권한으로 나눴다. 원본·관리 영역·수정 파일을 먼저 쓰는 잠금 파일은 만들지 않으며 대상 ID 기반 OS named mutex를 사용한다.

## 단위 2 · 계획과 파일 기록

미리보기는 현재 관리 파일·디렉터리 목록, 새 ZIP의 승인 식별, 선택 인수 폴더와 활성 기록 해시를 확인값에 묶는다. 기존 사용자 폴더는 기본 충돌이고, 반대 판의 미관리 또는 수정 폴더는 전체 적용을 막는다. 같은 판·같은 내용이면 새 기록을 만들지 않는다.

새 실행의 장부를 준비 전부터 기록하고 각 폴더 이동의 의도를 저장·flush한 뒤 같은 볼륨에서 이동한다. 설치 후 전체 파일·디렉터리 지문을 확인한 뒤 active와 완료 장부를 확정한다. 준비 또는 이동 실패는 복원 필요 상태로 남긴다. 복원·제거의 실행 입구와 중단 회복은 Step52로 이어질 기반 기록을 갖췄다.

초기 실제 설치 후 verify에서는 JSON 역직렬화 후 정렬 비교자의 차이로 일부 폴더를 다름으로 판단했다. 파일 수와 정확한 경로별 해시를 대조하도록 고쳐 해당 실제 흐름을 다시 실행했다.

## 실제 구동

명령 `python -X utf8 -B -I Collection/tests/installer/run.py --exe <scratch>/artifacts/bin/DevilForever.Installer/debug/DevilForeverSetup.exe --packages _local_only/phase26-work-r151-20261119/step47-candidate-02/archives --scratch <scratch>`가 종료 0이었다. `runtime-02.log`의 판정은 9개 통과, 공개 EXE 호출 23개다.

- 조회·반복 미리보기의 대상 파일·디렉터리 지문 동일과 확인값 재현.
- 실제 PitBull4 ZIP 설치·verify 성공, 기존 애드온과 `WTF` 샘플 보존.
- 같은 판 반복에서 새 파일·기록·백업 0개.
- 수정한 관리 폴더의 차단, 미리보기 이후 생긴 겹침과 오래된 확인값의 무변경 차단.
- 명시한 한 폴더만 인수하고 원본 파일을 실행별 before에 보관.
- 소유 미확인 반대판 폴더에서 게임·관리 영역 쓰기 0건.
- `Interface`가 없는 새 경로에 실제 FUF ZIP 설치·verify 성공.
- 비교판과 변조 ZIP의 사전 거부.

전체 명령과 반환 JSON은 `public-cli-nuo4t03w/calls.json`, 최종 판정은 같은 위치의 `result.json`에 있다. 이 시험은 새로 생성한 게임 대역에만 적용했다.

## 최종 입력·결과 대조

해당 정상 구동 후 손상 기록의 null 자료와 해당 명령에 사용할 수 없는 옵션을 명시 차단했다. 최종 `dotnet build ... --no-restore --artifacts-path <scratch>/artifacts`는 경고 0·오류 0이다. 이 변경의 직접 확인으로 최종 EXE에서 손상된 관리 기록과 무관한 옵션 세 개를 실행했다. `final-guard-check.json`은 3개 차단·대상 파일 지문 동일을 기록한다. 정상 설치 시험 9개는 이 입력 검증과 연결되지 않은 기존 실행 결과를 재사용했다.

최종 전문 정독 범위는 프로젝트 1–12, Program 1–63, Models 1–137, WindowsPaths 1–177, Snapshots 1–80, ApprovedPackage 1–210, InstallationStore 1–174, InstallerEngine 1–339, 전용 시험 1–159행이다. `source-freeze.json`에 실제 SHA-256과 행 수를 기록했다. `git diff --check`는 종료 0이다.

## 다음 상태

Step51의 조회·미리보기·적용·검증을 실제 호출로 확인했다. 공개 `rollback`·`remove`와 이 두 동작의 미리보기는 `not-implemented`로 차단하며 Step52 같은 A의 후속 작업이 필요하다. 중단 상태는 기록하고 새 적용을 막지만 복원 실행은 아직 구현하지 않았다. Windows Forms·단일 사용자 배포·실제 게임·청정 Windows는 다음 단계의 확인 대상이다. 계약·카탈로그·원 ZIP·기존 애드온 소스·게임·Git commit은 바꾸지 않았다. 독립 B 검수에 반환한다.

## 독립 B 보정 · active와 완료 실행 연결

부모가 실제 설치 대역에서 사용자의 새 파일을 active 지문에만 추가한 뒤 verify와 FUF 전환 plan이 모두 ready가 되는 것을 재현했다. journal의 AfterActive는 원상태였고 active의 실행 ID·동작만 같은 상태였다. 수정 전 사본은 새 `step51-ledger-fix-` 스크래치의 before.json에 있다.

| 위치 | 영향과 처리 |
|---|---|
| InstallationStore.Read의 active 연결 | 함께 고침. 실행 ID·동작뿐 아니라 typed JSON으로 읽은 active 전체를 같은 journal의 AfterActive와 대조 |
| inspect/verify/plan/apply | 연결 확인. 동일 Read를 호출하므로 불일치 기록을 쓰기 전에 invalid-record로 차단 |
| 실제 installed record와 Step52 중단 회복 | 확인만. 파일 이동 뒤 active 확정 직후의 journal이 아직 completed가 아니어도 예정 active가 같으면 읽을 수 있음 |
| 전용 시험 | 함께 고침. active만 변조한 기존 실제 설치 대역에서 verify와 전환 plan의 거부, 파일 지문 0차이와 정상 설치본 verify |
| ZIP·카탈로그·다른 코드 | 영향 없음. 승인 입력과 파일 적용 흐름 보존 |

보정 입력으로 InstallationStore 1–174, Models 1–137, Snapshots 1–80, 전용 시험 1–159, 이 작업 기록 전문과 부모의 두 재현 출력·원래 active 데이터를 대조했다.

Read는 같은 typed 역직렬화 객체의 active 전체와 해당 journal.AfterActive를 기존 JSON 직렬화기로 대조한다. 경로·대상 ID·판·해시·대소문자가 보존된 폴더/파일 키·디렉터리·보존 이유·완료 포인터를 모두 포함한다. journal 상태가 verifying인 조건은 그 자체로 거부하지 않아 active 교체 후 완료 기록 전 중단을 후속 복원에서 판정할 수 있다.

`dotnet build ... --no-restore --artifacts-path <이전 scratch>/artifacts`는 경고 0·오류 0이다. 신규 `record_link.py`를 부모의 실제 재현 대역과 정상 설치 대역에 공개 EXE로 실행했다. verify와 FUF plan 모두 invalid-record/blocked/종료2로 바뀌었고, PitBull4/User-only.txt를 포함한 대상·관리 파일/디렉터리 지문은 전후 같았다. 정상 설치본 verify는 ready/종료0이다. 판정 3개 통과이며 `step51-ledger-fix-n_h90ial/runtime.log`와 `record-link-5drt6da5/result.json`에 원출력을 보존했다.

별도 새 record 대역에 target과 같은 active/AfterActive, verifying journal을 둔 독립 reader 호출은 unfinished-run/recovery-required/종료3이었다. 이는 기록 입력의 합성 검증이며 실제 중단 복원 실행으로 보고하지 않는다. 결과는 같은 scratch의 pending-reader.json이다. 이전 대형 설치·ZIP 시험은 반복하지 않았다.

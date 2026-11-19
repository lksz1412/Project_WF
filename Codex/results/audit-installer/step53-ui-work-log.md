# Step 53 Windows 설치 화면 작업 기록

2026-11-19 · bada-a2-coder / gpt-6.1-sol high 역할 설정. 실제 사용량은 미관측이다. 새 Phase27.3에서 같은 소스 담당자가 화면과 CLI 진입을 연결한다.

## 변경 전 영향 지도

| 위치 | 연결과 처리 |
|---|---|
| Program.cs·프로젝트 | 함께 고침. no-args의 창 실행과 기존 인자의 CLI·종료 코드, WinExe 콘솔 연결, STA·DPI·일반 사용자 manifest |
| 새 UI·표시·콘솔 연결 코드 | 함께 작성. 같은 InstallerEngine Request/Result를 한 Task로 소비, 경로·선택 변경 시 token 해제 |
| 기존 Models·Engine·Contract·catalog | 확인만. 명령·오류 코드·정확한 unmanaged-overlap 폴더명만 화면 선택으로 전달 |
| 새 사용 안내 | 함께 작성. 실제 창·명령과 설치·검증·복원/제거의 입구 연결 |
| 기존 공개 CLI 시험 | 연결 확인. 리디렉션된 JSON과 비성공 종료 코드를 실제 하위 프로세스에서 확인 |
| 게임·프로필·기존 ZIP·다른 작업자의 파일 | 영향 없음. 새 시험용 게임 경로만 사용 |

## 읽은 범위

마스터 1–165, Phase27.3 1–22, Contract 1–140, Phase27.2 결과 1–45, Step52 1–27, Program 1–64, csproj 1–12, Models 1–138, Engine 1–342, 준비 windows-ui-flow 1–27행을 전문으로 읽었다. visual-design SKILL과 core/accessibility/desktop/verification 본문도 전문 정독했다. Program·csproj 이전 사본은 새 step53-ui 스크래치의 before.json에 있다.

## 단위 1 · 진입점과 같은 엔진

인자가 없으면 STA Windows Forms 창을 열고 인자가 있으면 기존 CLI를 호출한다. WinExe에서 표준 출력이 없을 때 부모 콘솔을 연결하며 기존 리디렉션 핸들은 보존한다. manifest는 asInvoker·PerMonitorV2·긴 경로를 사용한다. 엔진·catalog·contract를 바꾸지 않고 UI에서 defaultVariant의 파일명을 읽는다.

경로·ZIP·작업·교체 선택이 바뀌면 token을 해제한다. 실제 unmanaged-overlap의 폴더명만 인수 선택으로 쓰고, 인수 선택 후 새 미리보기를 요구한다. 한 Task에서 같은 Execute를 호출하며 처리 중 입력·이중 실행을 막는다. 닫기 요청은 작업 결과가 나올 때까지 대기한다.

## 단위 2 · 화면과 결과

시스템 팔레트·글꼴, DPI와 크기 조절을 사용하는 TableLayoutPanel에 입력·결과·실행을 배치했다. 인수할 수 있는 행만 checkbox로 표시하고, 상태는 텍스트로도 알린다. 확인이 차단된 결과를 설치 없음으로 단정하지 않는다. 공유용 복사는 실제 루트와 자세한 오류 경로를 제외하고 작업·상태·판·관리 상대 이름과 오류 종류를 사용한다.

셀을 행에 붙이기 전에 ReadOnly를 설정한 초기 코드에서 WinForms 예외가 났다. 실제 Form 시험의 ThreadException 출력으로 원인을 확인하고 셀을 붙인 뒤 속성을 설정하도록 고쳤다. `ui-smoke-diagnostic.json`에 이전 실패를 보존했고, `ui-smoke-repaired.json`에서 해당 정상 미리보기를 다시 확인했다.

## 실제 호출과 판정

`dotnet build Collection/tests/installer/ui_smoke/UiSmoke.csproj --no-restore --artifacts-path <scratch>/artifacts-diagnostic`의 최종 판정은 경고 0·오류 0이다. 원출력은 `build-ui-loop.log`다.

실행 명령은 `<scratch>/artifacts-diagnostic/bin/UiSmoke/debug/UiSmoke.exe <새 게임 대역> <승인 PitBull4 ZIP>`이다. 실제 WinForms Application.Run 루프에서 Form을 생성하고 실제 엔진의 미리보기 결과를 받았다. 처음의 수동 DoEvents 시험은 첫 Form 폐기 후 context를 잃어 간헐적으로 잘못 판정했으므로, 최종 판정은 Application.Run과 cross-thread 검사 아래의 결과를 사용한다.

최종 UI 시험 다섯 조건은 두 개의 새 대역에서 모두 통과했다.

- 실제 승인 ZIP의 미리보기와 처리 중 입력 차단.
- 입력·작업 변경 시 확인값 해제와 작업별 ZIP 활성 상태.
- 공유 결과의 코드·상대 이름 포함 및 개인 경로 제외.
- 실제 작업 중 닫기 대기와 완료 뒤 종료.
- 선언된 기존 폴더의 checkbox 선택이 새 실제 인수 계획으로 연결됨.

`ui-smoke-loop.json`은 두 번 모두 종료0·표준 오류 없음이다. 화면을 표시해 크기·배치를 관측한 결과로 세지 않으며 부모의 Windows 화면 확인과 연결한다.

동일 최종 WinExe를 subprocess에서 stdout/stderr 리디렉션으로 실행했다. inspect는 JSON/종료0, 관리 기록 없는 verify는 JSON/종료2, help는 종료0과 명령 목록이었다. `redirected-cli-complete.json`에 명령과 결과를 보존했다. 실제 파일 적용·복원은 앞 Phase의 엔진을 재사용하며 이 화면 시험에서 게임에 적용하지 않았다.

## 반환 상태

최종 개발 앱은 `_local_only/phase26-work-r151-20261119/step53-ui-j304hi8m/artifacts-diagnostic/bin/DevilForever.Installer/debug/DevilForeverSetup.exe`다. 사용자용 단일 파일 게시와 청정 Windows는 후속 단계다. 부모의 실제 화면 관측과 독립 B 검수를 기다린다. 게임·프로필·기존 ZIP·Git commit은 수정하지 않았다.

## 독립 B·실제 화면 보정

B는 성공한 인수 선택이 남아 같은 입력의 다음 미리보기가 invalid-replace-choice가 되는 결함과, 공유 결과의 알 수 없는 설치 상태를 없음으로 쓰는 결함을 확인했다. 부모의 실제 창에서는 행별 ReadOnly 조작의 예외와 게임 폴더 라벨의 줄바꿈도 확인했다. 이전 소유 파일은 새 step53-reviewfix 스크래치의 before.json에 있다.

| 위치 | 영향과 처리 |
|---|---|
| RunRequest·RenderResult | 함께 고침. 성공한 쓰기 뒤 인수·후보를 비우며, 이전에 알려진 잘못된 선택은 행에서 해제 가능 |
| grid 편집·AddRow | 함께 고침. per-cell ReadOnly 쓰기를 제거하고 CellBeginEdit에서 후보 열·행만 허용. 인수 불가 행은 빈 셀 표시 |
| 필드 레이아웃 | 함께 고침. 라벨 열을 AutoSize로 맞춰 자연 폭 확보 |
| 공유 결과 | 함께 고침. blocked/recovery-required의 package 미확인은 명시하고 정상 none과 구분 |
| 실제 Form 시험 | 함께 고침. 인수 선택·실제 설치·같은 입력 재미리보기·선택 초기화, 두 창 폭의 라벨과 공유 상태를 확인 |
| 엔진·CLI·catalog·계약 | 확인만. 같은 실행 API와 기존 명령을 소비 |

보정 전 Form 1–335, InstallerText 1–84, Form 시험 1–122, 이 기록 전문을 다시 읽었다.

성공한 apply/rollback/remove 뒤 인수 선택과 후보를 비웠다. 실패 뒤 남은 기존 후보의 invalid-replace-choice는 해당 행에서 선택 해제가 가능하다. 완료 결과의 인수 행은 다시 편집 후보로 표시하지 않는다. shared report에서 blocked 또는 recovery-required의 package가 없으면 설치 미확인으로 쓰고, 정상 none은 기존 없음 표시를 유지한다.

실제 창에서 재발한 셀 ReadOnly 조작은 모든 per-cell 쓰기를 제거했다. CellBeginEdit에서 실제 후보 열·행만 편집 가능하게 하며 인수 불가 행은 빈 text cell로 둔다. 필드 라벨 열도 고정 폭에서 AutoSize로 바꿨다.

`dotnet build Collection/tests/installer/ui_smoke/UiSmoke.csproj --artifacts-path <새 reviewfix>/artifacts --configfile <기존 offline config> -p:NuGetAudit=false`는 경고0·오류0이다. `<reviewfix>/artifacts/bin/UiSmoke/debug/UiSmoke.exe <새 게임 대역> <실제 승인 ZIP>`는 실제 WinForms message loop에서 종료0·표준 오류 없음이었다. 실행 원문은 `step53-reviewfix-vkngg5dm/ui-actual-install.json`에 있다.

기존 Form 흐름에 실제 인수 설치와 같은 입력의 후속 미리보기를 추가했다. 실제 설치 완료 후 두 인수 집합이 비워지고 후속 미리보기는 no-change, 실행 버튼 비활성으로 끝났다. shared report의 blocked/null·recovery-required/null·정상 none과 개인 경로 미포함을 확인했다. 두 창 폭 880·1100에서는 라벨의 자연 폭이 확보됐다. 이 측정은 실제 화면을 눈으로 확인한 결과와 구분하고 부모의 새 앱 물리 관측에 연결한다.

현재 앱은 `step53-reviewfix-vkngg5dm/artifacts/bin/DevilForever.Installer/debug/DevilForeverSetup.exe`다. 기존 엔진·CLI의 코드는 보정하지 않았다. 같은 B 재검수에 반환한다.

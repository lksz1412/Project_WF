# Step 55 — 배포본 중단과 충돌 시험

Phase 28.1 · 2026-11-19 13:47–13:54 +0900 · 예상 90–180분

Step 54의 실물 EXE와 승인 PitBull4 ZIP을 격리 경로에서 사용했다. 같은 소스를 복제한 시험 실행 파일에서 각 기록·이동 경계에 프로세스를 종료시키고, 실제 배포 EXE로 이어서 실행했다. [배포 파일 지문](../../_local_only/phase26-work-r151-20261119/DevilForever-Windows-x64-0.1.0-local-test/release-files.json)

## 실제 결과

| 조건 | 결과 |
|---|---|
| 실제 배포 EXE 강제 종료 | 사용자 원본을 백업한 직후 시험 프로세스만 종료했다. 실행 상태 `applying`, 완료 이동 4건에서 다시 실행해 원래 파일을 복원했고 백업을 확인했다 |
| 설치 준비·첫 이동 뒤 종료 | 대역의 원상태와 파일 해시를 복원 |
| 설치 활성 기록 교체 뒤 종료 | 새 배치와 활성 기록은 이미 일치했다. 완료 기록을 마감 |
| 제거 이동·활성 기록 경계 종료 | 원래 파일 복원 또는 이미 일치하는 제거의 기록 마감 |
| 복원 이동·활성 기록 경계 종료 | 같은 실행 ID의 목표까지 재개 |
| 운영체제 경쟁 잠금·잠긴 폴더·디렉터리 연결 | 종료 2로 차단. 시험 대상 파일과 연계 대상의 지문 보존 |
| 실행 중 프로세스 검사 | 만든 시험 프로세스가 있을 때 종료 2와 파일 쓰기 0을 확인. 테스트 프로세스 종료 확인 |
| 변경된 ZIP과 가용 공간 0 분기 | 종료 2와 파일 쓰기 0을 확인. 공간 값은 시험 사본의 입력으로 주입했다 |

[실제 종료와 복원](../../_local_only/phase26-work-r151-20261119/step55-final-terminated/interrupted-result.json) · [경계 일곱 곳의 기록](../../_local_only/phase26-work-r151-20261119/step55-final-fixture/cases/crash-matrix.json) · [잠금·경로·ZIP·공간 시험](../../_local_only/phase26-work-r151-20261119/step55-final-guards/guards-result.json) · [경쟁 잠금](../../_local_only/phase26-work-r151-20261119/step55-final-contention-03/result.json) · [시험용 실행 중 검사](../../_local_only/phase26-work-r151-20261119/step55-final-process/guard-result.json)

## 배포 안내 보정

Windows 앱을 PowerShell에서 직접 호출하면 출력과 종료 코드를 기다리지 않는 환경을 확인했다. `Start-Process -Wait`와 명시 출력 리디렉션으로 배포 EXE의 도움말과 종료 0을 확인하고 안내에 넣었다. 안내만 바뀐 최종 전달 폴더에는 검증한 EXE와 기본 ZIP을 해시로 대조해 복제했다. [PowerShell 실행 기록](../../_local_only/phase26-work-r151-20261119/step55-final-powershell/result.json) · [실행 안내](../../Collection/Installer/사용안내.md)

## 게이트

같은 검수자가 열람한 실제 강제 종료와 시험 사본의 종료 경계, 운영체제 잠금과 주입한 공간 시험, 배포 폴더의 전체 SHA-256을 대조했다. 중대·중간·경미 0건이다. 검수 사용량 미관측. 청정 Windows와 실게임은 별도의 관측 항목이다.

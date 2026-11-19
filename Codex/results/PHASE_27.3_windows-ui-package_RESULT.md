# Phase 27.3 — 설치 화면과 로컬 배포본 결과

## Summary

Windows Forms와 명령줄이 같은 엔진에 연결됐다. Windows x64 자체 포함 EXE, 기본 PitBull4 ZIP과 사용자 안내를 로컬 배포 폴더에 빌드했다. FUF는 승인 해시가 맞는 선택 ZIP으로 사용할 수 있다.

## Step Range

53–54. [설치 화면](Step%2053%20%E2%80%94%20Windows%20설치%20화면과%20명령줄.md) · [로컬 배포](Step%2054%20%E2%80%94%20Windows%20로컬%20배포본.md)

## Inputs

Phase 27.2 엔진, Phase 27.3 계획과 설치 계약, 실제 Step 48 ZIP 두 개, Windows x64 개발 환경을 사용했다.

## Files Created

Windows 화면·공개 CLI, [사용 안내](../../Collection/Installer/사용안내.md), [빌드 명령](../../Collection/Installer/Publish-Installer.ps1), 격리된 배포 폴더와 두 역할의 실행 기록.

## Files Updated

Windows 시작·프로젝트 배포, 화면과 파일 계약의 연결, 실행 대장과 마스터 이력.

## Read Coverage

화면과 명령줄, 안내와 앱 증거, 배포 스크립트 및 실물 파일·로그를 스텝마다 정독·대조했다.

## Execution Evidence

실제 WinForms 시험과 인수 이후 재미리보기, 실제 배포 실행 파일의 창·CLI를 확인했다. 배포본의 기본 ZIP 검색·설치·검증, 선택 FUF 미리보기, 비교판 차단을 확인했다. 다른 출력 디렉터리에서 같은 실행 파일의 SHA-256을 재생성했다.

## Validation and Gate

Step 53–54 통과. 화면의 두 독립 발견과 실제 표시 예외를 보정했고 배포본 파일과 실행을 대조했다. 최종 미해결 중대·중간 0건이다.

## Open Issues

실패 경계별 시험과 별도 청정 Windows, 실제 게임은 Phase 28에서 확인한다.

## Decision Queue

배포 기본 폴더는 PitBull4를 포함하고 FUF를 선택 입력으로 둔다. 이 구성과 전체 SHA-256은 로컬 배포표에 기록했다.

## Next

실제 배포본과 같은 소스의 시험 사본으로 중단과 파일 보호를 반증한다.

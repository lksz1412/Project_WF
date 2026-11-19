# Phase 27.1 — Windows 실행 방식과 설치 계약 결과

## Summary

Windows 11 x64에서 .NET을 자체 포함한 단일 실행 파일을 일반 사용자 토큰으로 검증했다. 두 승인 ZIP, 공통 명령과 화면, 쓰기 전 조건과 복원 기록의 계약을 기록했다.

## Step Range

49–50. [도구 실행 검증](Step%2049%20%E2%80%94%20Windows%20단일%20실행%20파일%20검증.md) · [설치와 복원 계약](Step%2050%20%E2%80%94%20Windows%20설치와%20복원%20계약.md)

## Inputs

마스터와 Phase 27.1 세부계획, 두 실제 승인 ZIP과 카탈로그, 기존 ZIP 빌더 구조, 개발 PC의 실행 시험을 사용했다.

## Files Created

[설치기 계약](../../Collection/Installer/Contract.md) · [작업 기록](audit-installer/step50-contract-work-log.md) · [파일 엔진 계획](../plans/2026-11-19-devil-forever-audit-and-installer-phase27.2-세부계획.md)

## Files Updated

마스터의 소스 경로 및 독립 실행 확인을 현재 결과와 연결했다. 실행 대장에 구현 차례를 적었다.

## Read Coverage

사양·입력·실행·파일 이동 시험과 독립 검수의 범위는 두 Step 결과와 Step 50 작업 기록에 있다.

## Execution Evidence

시험 실행 파일 51,675,286바이트, 종료 0. Windows Forms와 Core가 내장되었다. 두 승인 ZIP의 카탈로그·내부 매니페스트·폴더와 해시 목록이 계약과 일치했다. 실제로 설치하는 제품 코드는 Phase 27.2에서 검증한다.

## Validation and Gate

Step 49–50 통과. 설치 계약은 더 과거의 복원으로 넘어가지 않는 작업 ID와 사전 차단 시 관리 영역을 포함한 파일 쓰기 0건으로 보정했다. 같은 검수자의 최종 미해결 중대·중간은 0건이다.

## Open Issues

실제 설치·갱신·복원·제거와 Windows 화면은 다음 단계의 시험 대상이다. 별도 청정 Windows 호스트 시험과 실제 게임 확인도 남아 있다.

## Decision Queue

파일 계약에 필요한 명령과 기본값은 승인된 실행 범위에서 정했다.

## Next

Step 51에서 확인값에 연결된 미리보기와 파일 적용을 Windows의 새 격리 게임 구조에서 실제로 실행한다.

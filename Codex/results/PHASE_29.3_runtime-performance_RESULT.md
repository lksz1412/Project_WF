# Phase 29.3 자체 Lua 성능 개선과 로컬 0.1.2 결과

## Summary

프리셋, 소환수 단축바, FUF 비교 배치에서 반복하는 일을 줄였다. 아스트라 재검과 로컬 설치 시험을 통과한 0.1.2다. 기본 설치판은 PitBull4다.

## Step Range

Step 63–65.

## Inputs

[승인된 세부계획](../plans/2026-11-19-devil-forever-addon-adoption-phase29.3-세부계획.md), 이전 0.1.1 ZIP 세 개, 동봉 Dominos와 FUF, 기존 Windows 설치기 빌드 환경.

## Files Created

[Step 65 검증 기록](Step%2065%20%E2%80%94%200.1.2%20성능%20개선과%20설치%20검증.md), [설치기 묶음](../../_local_only/perf-package-0.1.2/final-build/DevilForever-Windows-x64-0.1.2/), [한 접속 비교 ZIP](../../_local_only/perf-package-0.1.2/final-build/archives/DevilForever-0.1.2-one-session.zip).

## Files Updated

자체 Lua와 영향 시험, 버전 자료·설치 카탈로그, 한 접속 확인표, 마스터 플랜의 동봉 애드온 비교 순서.

## Read Coverage

마스터 플랜 1–140행과 세부계획 1–43행을 기준으로 진행했다. 변경 코드 및 동봉 모듈 근거 범위는 [Step 63](Step%2063%20%E2%80%94%20프리셋과%20소환수%20단축바%20갱신%20줄이기.md), [Step 64](Step%2064%20%E2%80%94%20FUF%20비교%20배치%20반복%20조회%20줄이기.md), Step 65의 확인 범위에 기록했다.

## Execution Evidence

프로필 전환 전체 갱신 39→1, 소환수 교체 중 무관한 바의 글꼴 갱신 20→0, FUF 진단 조회 117→1. 동봉 FUF의 내부 묶음 함수는 별도 시험에서 비교 배치의 설정 알림을 116→10으로 줄였다. [Step 65 근거](Step%2065%20%E2%80%94%200.1.2%20성능%20개선과%20설치%20검증.md)

## Validation

독립 첫 검수의 소환수 예약 결함 한 건을 고쳤다. 재검에서 중대·중간·경미 0건이었다. 세 ZIP 대조와 공개 설치 명령 9건, 두 단독판의 0.1.1→0.1.2→0.1.1을 통과했다. [ZIP 해시](../../_local_only/perf-package-0.1.2/final-build/archives/release-receipt.json)

## Non-Changes

동봉 외부 애드온과 테마 자산은 이전 ZIP과 바이트가 같다. 게임 경로 대신 새 시험 폴더에서 EXE를 실행했다. 원격 저장소와 실제 게임은 이번 시험 범위 밖이다.

## Open Issues

실제 게임 프레임 시간, 전투·파티 배치, 퀘스트 글자 크기는 미측정이다. 실제 청정 Windows 시험도 남아 있다.

## Decision Queue

FUF는 비교판에서 유지한다. 순위에 든 후보와 기존 동봉 앱은 기능별로 대조한 뒤 최선 조합을 고르고, 확인된 반복 비용을 줄이는 방향으로 정했다. 동봉 애드온 소스 수정 후보는 코드 근거와 실제 반복 비용을 함께 확인한다.

## Next

[기능별 비교 목록](../plans/2026-11-19-devil-forever-addon-adoption-plan.md#동봉-애드온과-같은-기능-후보의-비교-순서) 순서대로 각 후보의 결과와 채택 판단을 기록한다. 실제 화면은 [같은 접속 확인표](../../References/codex-verify/one-session-review.md)를 사용한다.

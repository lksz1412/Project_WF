# Phase 26.2 — 기능 재검토와 배포 기준 결과

## Summary

Claude와 이전 Codex의 로컬 묶음을 실제 Lua와 ZIP으로 재검토했다. 채팅의 수신 구독·입력 기록·자동 배치, FUF 비교 프로필의 실행 연결, Hekili와 게임 기본 재사용 대기시간 표시의 안내를 보정했다. 세 ZIP을 새로 빌드하고 설치기의 입력은 두 단독판으로 정했다.

## Step Range

46–48. [기능 반증](Step%2046%20%E2%80%94%20기능별%20반증%20시험.md) · [결함 보정](Step%2047%20%E2%80%94%20결함%20보정과%20재시험.md) · [새 ZIP 기준](Step%2048%20%E2%80%94%20검토한%20ZIP과%20기능%20기준%20확정.md)

## Inputs

Phase 26.1의 요구 추적·이전 ZIP, Step 40의 통합 실물, 마스터와 Phase 26.2 세부계획, 이 작업 트리의 코드와 원본 애드온을 사용했다.

## Files Created

[실제 발견](audit-installer/step46-findings.json) · [검토 ZIP 목록](audit-installer/reviewed-packages.json) · [설치기 카탈로그](../../Collection/Installer/ReleaseCatalog.json) · [Hekili 현행 안내](../../Collection/data/hekili-current.md)

## Files Updated

채팅·FUF Lua·자동 시험, 기능 트리, 설치 안내, 단일 접속 확인표와 마스터의 현행 기준. 정확한 수정 범위와 영향은 각 스텝 기록에 있다.

## Read Coverage

Step 46–48 기록과 각각의 작업 기록에 원문·코드·읽은 행 범위를 적었다. Step 48 검수 입력은 검토 JSON 1–191행, 카탈로그 1–101행, 접속 확인표 1–52행, 마스터 1–165행, 실제 ZIP 검사 출력 1–9행과 채팅 출력 1–29행이었다.

## Execution Evidence

세 ZIP의 파일별 해시와 Lua 5.1 코드 4,110개를 확인했다. 채팅은 28개, FUF는 21개 시험에서 통과했다. FUF의 배치 값 696개를 두 배율과 세 해상도에서 비교했다.

## Validation and Gate

Step 46–48 통과. 실물 ZIP 세 개, 설치기 카탈로그 두 항목과 게임 확인표를 독립 검수했다. Step 48의 중간 한 건을 같은 작업자가 보정하고 같은 검수자가 확인했다. 최종 미해결 중대·중간 0건이다.

## Open Issues

화면 배율, 4K 퀘스트 가독성, 모음집의 실제 채팅 표시와 사용, 전투, 파티·공격대, 기본과 대체 유닛 프레임의 최종 선택은 [한 접속 확인표](../../References/codex-verify/one-session-review.md)에서 확인한다. 설치기의 일반 PC 검증은 Phase 28이다.

## Decision Queue

추가 해상도 이름과 4K 단독 배포 선택은 결정 대기로 두었다. 세 해상도 및 13개 테마의 현재 실물로 진행한다.

## Next

Phase 27.1에서 Windows 자체 포함 실행 확인과 설치기 계약을 기본 설치·검증·복원·제거 흐름으로 잇는다.

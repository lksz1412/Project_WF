# PHASE 23 — 모음집 연계 검사·정정 RESULT

## Summary

모음집 전체를 정적으로 대조했다(필수 묶음만·전부 켬·하나씩 끔, FUF 판·PitBull4 판). 해석 안 되는 의존 0(FUF 판 전용 연결 애드온 1건은 의도). 고친 것: 설치용 ZIP(`DevilForever-0.1.0.zip`, 안에 manifest·SHA256SUMS·설치안내 — 계획 411행), 빠진 Phase 의 등록 항목 정리(73 → 34), 우리 폴더·PitBull4 고친 판을 manifest 에 기록, 발주문 3개에 남은 Dominos_Cast 제거, 설치 안내(백업 → 기존 애드온 모두 옆으로 옮김 → 풀기 → 겹치지 않는 것만 되돌림). unit 프레임 기본 동봉은 임시로 PitBull4(FUF 판은 명령 하나로 만들 수 있음) — Codex 비교 결과(R109 보류)가 오면 확정한다.

## Step Range

Step 37(점검)·38(정정)

## Inputs

마스터 플랜 213–234·298·312·337·403·411·431·453행, manifest·TOC·등록 표·도구, Phase 별 처리표 14개, 발주문

## Files Created

Collection/install.json, Collection/install/설치안내.md, outputs/collection/DevilForever-0.1.0.zip, handoffs/phase23/integration-37.md·DECISIONS_37.md·TRIAGE_phase23.md

## Files Updated

tools build/extract/genregistry, manifest.json·md, registry_extra.json·Registry.lua, API.lua 머리 주석, tests/core/run.py, 발주문(phase3·15·20·appearance-16 문구 + 31개 해시), 확인용 ZIP, 마스터 플랜 구조 맵

## Read Coverage

Step 37·38 이력 Basis, A2 work_log, B 검수 보고의 읽은 범위(TRIAGE 기록)

## Execution Evidence

Step 37·38 이력, work_log-a2.md 판정 줄

## Validation·Gate·Confirmed

정적 대조 + 정정분 코드 논리 검수 1회 + 적대: 중간 2 → 고침 → 0. 시험 모두 통과, 두 설치 판 SHA 대조 OK. 게임 안 조합 로드는 미검증(Codex 발주문).

## Non-Changes

시작 애드온 원본 무변경(PitBull4 는 6-rev 고친 판 그대로)

## Open Issues

unit 프레임 기본(임시 PitBull4) 확정 · 이름표 시전바 유지(임시) · 미니맵 시계와 띠 시계 겹침 — 최종 보고. PowerShell 해시 확인 줄은 이 컨테이너에서 실행 못 함(확인 필요). 경미 2(TRIAGE_phase23.md).

## Decision Queue

DECISIONS_37.md 1–9(모두 기본값 적용)

## Next

Phase 24 최종 목업 발주문

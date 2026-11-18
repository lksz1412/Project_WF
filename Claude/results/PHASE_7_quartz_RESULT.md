# PHASE 7 — Quartz 시전바 정리 RESULT

## Summary

시전바는 Quartz 3.8.0 이 내·대상·주시·소환수 시전바를 맡고, 게임 기본 시전바는 Quartz 자체 설정으로 숨긴다. 같은 자리의 FUF 시전바는 새 연결 애드온 DevilForever_Castbars 가 이번 접속 동안만 숨긴다(저장 값을 바꾸지 않아 계정 공유 프로필 문제가 없음, Quartz 모듈을 끄면 바로 FUF 로 넘어감). Dominos_Cast 는 모음집 설치본에서 빼기로 했다(Phase 23). Quartz 의 차단 글자 모듈은 Forever 에서 로드되지 않을 것으로 보여 차단은 빨간 실패 막대로만 보인다.

## Step Range

Step 17

## Inputs

마스터 플랜 기능 표 행·judgment.md·manifest·upstream 시작 애드온

## Files Created

Collection/AddOns/DevilForever_Castbars/**, registry_extra.json, Registry.lua, Collection/tests/castbars/run.py, Collection/tests/core/run.py, Collection/codex-briefs/appearance-7.md, phase7.md, outputs/collection/DevilForever-collection.zip

## Files Updated

Registry.lua·TOC·설치 ZIP

## Read Coverage

master read review report, triage; tests rerun. A2 read ranges in Claude/results/handoffs/phase7/iter_1/work_log-a2.md (Quartz modules, CastBarTemplate, FUF Castbar/Shape/Single/Init).

## Execution Evidence

Step 17 이력·work_log 판정 줄

## Validation·Gate·Confirmed

1 logic review (B, rerun after restart): 0/1/3 → M1+minor1 fixed → master check

## Non-Changes

시작 애드온 원본·References·Codex 무변경

## Open Issues

FUF 시험 모드 미리보기가 숨겨짐(경미 2). Quartz 주시 프레임이 Forever 에 없을 수 있음(경미 3, Phase 23). 차단 글자 없음(Interrupt 모듈 mainline 제외). Dominos_Cast 설치본 제외는 Phase 23 빌드에서.

## Decision Queue

Quartz Buff 모듈 유지(가)

## Next

Phase 8 Step 18 — Hekili 원천 정독·직업 지원표·갈래 판정

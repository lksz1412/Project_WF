# PHASE 19 — Experience Forever 경험치·평판 바 RESULT

## Summary

Phase 19 끝: 경험치·평판·사냥꾼 소환수 경험치 막대는 Experience Forever 를 그대로 쓴다. 기본값이 이미 계획과 같아 Core 기본값 파일을 만들지 않았고(애드온 수·파일 수 최소), 같은 기능의 Dominos_Progress 는 넣지 않는다.

## Step Range

Step 31

## Inputs

마스터 플랜 기능 표 행·judgment.md·manifest·upstream 시작 애드온

## Files Created

registry_extra.json (EF entry), Registry.lua, tests/core/run.py, codex-briefs/phase19.md, codex-briefs/appearance-19.md, 26 earlier briefs (hash), install ZIP

## Files Updated

Registry.lua·TOC·설치 ZIP

## Read Coverage

[Phase 19 start — master plan re-read 1-549.] Master triangulated ExperienceForever.lua:44,59,82,373, registry_extra.json:880-903, Edit.lua:7. A2 read ranges + impact map: handoffs/phase19/iter_1/work_log-a2.md (initial + fix 1). Triage: TRIAGE_phase19.md.

## Execution Evidence

Step 31 이력·work_log 판정 줄

## Validation·Gate·Confirmed

설정 Phase — 등록·발주문 ② 국소: B 한 번+적대(중간 2) → 같은 A 고침 → 같은 B 재확인 0/0/0

## Non-Changes

시작 애드온 원본·References·Codex 무변경

## Open Issues

EF 는 경험치 막대 자체를 끄는 설정이 없다(만렙도 막대가 남음 · 끄려면 애드온을 끔). Codex 가 낼 EF 값 파일(전역 설정)을 넣을 길은 아직 없음 — Phase 20/23. Phase 23 설치 목록: Dominos 에서 Dominos_Progress·Dominos_Roll 빼기.

## Decision Queue

A2 DQ1 기본값 파일 없음 · DQ2 막대 끄기 없음 · DQ3 설치 목록 · DQ5 EF 값 주입 길 — TRIAGE_phase19.md

## Next

Phase 20 (Steps 32-33) settings save/restore — ProfileManager scope + preset restore.

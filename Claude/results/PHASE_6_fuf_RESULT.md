# PHASE 6 — Forever Unit Frames 설정·직업 자원 RESULT

## Summary

체력·직업 자원은 Forever Unit Frames 0.65.2 를 그대로 쓴다. FUF 기본값이 계획 행(체력·자원·프레임 오라·치유 예측·거리 흐림, 마나·토템 강제 없음)을 이미 채워 기본값 파일은 두지 않았다. Grid2 가 로드된 캐릭터에서 FUF 공격대 창만 한 번 끄는 연결 애드온 DevilForever_FUFDefaults 를 만들었다(FUF 자체 명령 사용, 사용자 값은 건드리지 않음). 파티 창은 FUF 몫으로 두고 Grid2 는 공격대만 보이게 Phase 9 에서 맞춘다. 9개 직업 자원은 classes.md 와 맞고 흑마법사 영혼의 조각만 FUF 에 표시가 없다.

## Step Range

Step 16

## Inputs

마스터 플랜 기능 표 행·judgment.md·manifest·upstream 시작 애드온

## Files Created

Collection/AddOns/DevilForever_FUFDefaults/**, registry_extra.json, Registry.lua, Collection/tests/fufdefaults/run.py, Collection/tests/core/run.py, Collection/codex-briefs/appearance-6.md, phase6.md, outputs/collection/DevilForever-collection.zip

## Files Updated

Registry.lua·TOC·설치 ZIP

## Read Coverage

master read review report, TRIAGE_phase6.md decisions, FUFDefaults.lua party grep (0), tests rerun; A2 read ranges in Claude/results/handoffs/phase6/iter_1/work_log-a2.md (Commands.lua 1–143, Storage.lua, UnitProfiles.lua, Boot.lua 1–93, Settings.lua).

## Execution Evidence

Step 16 이력·work_log 판정 줄

## Validation·Gate·Confirmed

1 logic review (B): 0/1/5 → design change raid-only + minors 2,4 → master check

## Non-Changes

시작 애드온 원본·References·Codex 무변경

## Open Issues

흑마법사 영혼의 조각 표시 없음(R61 빈칸 후보). FUF 플레이어 시전바 기본 켜짐 — Phase 7 에서 Quartz 와 정리. 경미 3(api-missing 영구), 5(Grid2 로드 여부만 봄) → 최종 보고. Phase 9: Grid2 는 공격대만.

## Decision Queue

FUF 외관 조각을 넣을 길(FUFDefaults 확장·storage provider·FUF 가져오기 문자열)은 Codex 결과 받은 뒤 결정

## Next

Phase 7 Step 17 — Quartz 기본 설정·중복 시전바 정리

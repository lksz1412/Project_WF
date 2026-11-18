# PHASE 5 — SexyMap 기본 설정·발주문 RESULT

## Summary

미니맵은 SexyMap v12.1.7 을 그대로 쓴다. 기본 설정은 지도 오른쪽 클릭으로 설정창이 열리지 않게(/sexymap 으로는 열림)와 추적 버튼 늘 보이기 두 가지이고, SexyMap 이 모듈 표를 통째로 만드는 방식이라 그 표를 SexyMap 기본값과 함께 채운다. 사각 모양·위치·테두리는 Codex 몫. Codex 발주문을 썼다.

## Step Range

Step 15

## Inputs

마스터 플랜 기능 표 행·judgment.md·manifest·upstream 시작 애드온

## Files Created

Collection/AddOns/!DevilForever_Core/Defaults/SexyMap.lua, registry_extra.json, Registry.lua, TOC, Collection/tests/core/run.py, Collection/codex-briefs/appearance-5.md, phase5.md, outputs/collection/DevilForever-collection.zip

## Files Updated

Registry.lua·TOC·설치 ZIP

## Read Coverage

master read Defaults/SexyMap.lua code lines, upstream SexyMap.lua 37–45; A2 read ranges in Claude/results/handoffs/phase5/iter_1/work_log-a2.md (SexyMap.lua 325–352, Buttons.lua 217–246, toc 17, 43–58).

## Execution Evidence

Step 15 이력·work_log 판정 줄

## Validation·Gate·Confirmed

master check (R87: defaults table + key derivation matching upstream)

## Non-Changes

시작 애드온 원본·References·Codex 무변경

## Open Issues

SexyMap 은 mainline 조건으로만 핵심 파일을 로드 — Codex 확인. 핑 보낸 사람 표시는 이 판에 없음. 저장·복원은 Phase 20 연결 코드 필요.

## Decision Queue

Codex 조각 sexymap-profile.fragment.lua 병합은 결과 받은 뒤

## Next

Phase 6 Step 16 — Forever Unit Frames 기본 설정·직업 자원 대조·발주문

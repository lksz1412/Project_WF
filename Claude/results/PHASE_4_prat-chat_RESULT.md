# PHASE 4 — Prat 대화창·세 창 분담 RESULT

## Summary

대화창은 기본 창·기본 입력을 그대로 두고 Prat 3.9.117 을 그대로 쓴다. 기본 설정은 채팅 기록 되살리기 끔·Memory 모듈 끔 두 가지. 세 창 분담(D3 가)은 새 작은 애드온 DevilForever_ChatSetup 이 캐릭터 첫 접속 때 한 번만 창 두 개를 열어 채널 묶음을 옮긴다(빈 창 수를 먼저 세고 모자라면 아무것도 바꾸지 않음). Codex 외관·실사용 검증 발주문을 썼다.

## Step Range

Step 14

## Inputs

마스터 플랜 기능 표 행·judgment.md·manifest·upstream 시작 애드온

## Files Created

Collection/AddOns/DevilForever_ChatSetup/**, Collection/AddOns/!DevilForever_Core/Defaults/Prat-3.0.lua, registry_extra.json, Registry.lua, TOC, Collection/tests/chatsetup/run.py, Collection/tests/core/run.py, Collection/codex-briefs/appearance-4.md, phase4.md, outputs/collection/DevilForever-collection.zip

## Files Updated

Registry.lua·TOC·설치 ZIP

## Read Coverage

master read ChatSetup.lua 129–143, 158–162, V42 !DevilUI.lua 1155–1163, review report; A2 read ranges + API evidence table in Claude/results/handoffs/phase4/iter_1/work_log-a2.md; triage Claude/results/handoffs/phase4/TRIAGE_phase4.md.

## Execution Evidence

Step 14 이력·work_log 판정 줄

## Validation·Gate·Confirmed

1 logic review (B): 0/1/5 → M1·minor2 fixed → master check

## Non-Changes

시작 애드온 원본·References·Codex 무변경

## Open Issues

경미 1(임시 창 위치 겹침 — Codex 조각으로 확정), 3(창 생성 뒤 /reload 필요), 4(설치 전 캐릭터의 창 1 묶음 이동), 5(Core 의존·api-missing 재시도 없음) → 최종 보고. R24 깔끔한 채팅에 비춰 Prat 글자 모듈(시간 표시 등) 유지 여부는 사용자 확인 후보.

## Decision Queue

Codex 조각(chat-windows.fragment.lua, prat-profile.fragment.lua) 병합은 결과 받은 뒤

## Next

Phase 5 Step 15 — SexyMap 기본 설정·발주문

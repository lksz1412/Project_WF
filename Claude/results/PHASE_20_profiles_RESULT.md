# PHASE 20 — 설정 저장·복원 RESULT

## Summary

설정 저장·복원을 필수 묶음인 `!DevilForever_Core` 안에 넣었다(애드온 수 그대로 · R101). ProfileManager 는 키 설정·게임 설정 저장·복원용으로 그대로 쓰고 `/dfp keys|game` 로 이어 준다(R44). 등록 표의 저장 변수만 골라 스냅샷으로 저장하고, 범위(전체·공통·직업)·애드온을 골라 복원한다. 복원은 `/dfp go` 뒤 다시 불러올 때 쓴다(다른 애드온이 접속 끝에 값을 덮어쓰는 문제 때문). 세 겉보기(FHD·QHD·UHD) preset 으로 되돌리기 층과, 애드온 값 파일(예: Experience Forever 전역 값)을 넣는 길을 만들었다(R107 ⑥). 특성(이중 특성) 전환에 Dominos 프로필을 따라가게 하는 연결도 있다.

## Step Range

Step 32(설계)·33(구현)

## Inputs

마스터 플랜 232·407·408·428·451행, ProfileManager v4.0 원천, V42 Reflux 기전, Core 전체

## Files Created

Core/Profiles.lua·Presets.lua·Spec.lua·Commands.lua, tests/core fixtures 3개, codex-briefs/phase20.md, handoffs/phase20/design-32.md·DECISIONS_32.md·TRIAGE_phase20.md

## Files Updated

Core.lua·Edit.lua·API.lua·TOC·registry_extra.json·Registry.lua·genregistry.py·tests/core/run.py·appearance-2-layouts.md(§5)·발주문 29개 해시·설치 ZIP

## Read Coverage

Step 32·33 이력의 Basis, A1·A2 work_log, B 검수 보고의 읽은 범위(TRIAGE 기록)

## Execution Evidence

Step 32·33 이력, work_log-a2.md 판정 줄(fix 1·fix 2 포함)

## Validation·Gate·Confirmed

새 구조 모듈 3라운드(연계·뜻·적대) 중간 4 → 고침 → 재확인 중간 3(새 코드 · 줄어듦) → 고침 → 재확인 0. 시험 Core 102/102. 게임 안 동작은 미검증(Codex 발주문 phase20).

## Non-Changes

시작 애드온 원본·ProfileManager 원본 무변경, 매크로·키 자동 배정 없음

## Open Issues

받아들인 위험: 계정 공통 저장 변수를 통째로 복원하면 다른 캐릭터 몫도 함께 돌아감. 공유 직업 프로필은 다른 캐릭터가 쓰면 복원 때 이 캐릭터 이름 프로필로 갈라짐(되돌리기로 다시 붙지 않음 — Dominos 설정에서 직접). 확인 필요: 불러올 때 캐릭터 이름을 아는지, Details 일부 키 복원, GetAddOnMetadata, 이중 특성 전환 이벤트, 스냅샷 크기. 경미 7건(TRIAGE_phase20.md).

## Decision Queue

배치 Core 안(결정함), PM 유지(결정함), 설계 §11 기본값 수용(결정함)

## Next

Phase 22 대안 테마

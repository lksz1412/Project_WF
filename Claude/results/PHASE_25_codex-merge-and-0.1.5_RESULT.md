# PHASE 25 — Codex 결과 반영·0.1.5 고정 RESULT

## Summary

Phase 25: Codex 0.1.4 검토판을 감사(Step 44)하고 Fable 독립 검수 세 번(Step 45)을 거쳐 Codex 가지를 기본으로 합쳤다(40a). 파티·공격대를 Grid2 로 통일하고 파티 담당을 기록·맞춤(40b), 실행 부담을 줄이고 적 소환수·주술사 토템을 넣고(40c), 제3자 원본+patch 구조와 단일 빌드로 0.1.5 ZIP 두 판을 만들었다(40d). 게임 안 동작은 Codex 한 접속 확인 전까지 미검증이다.

## Step Range

Step 44, 45, 40a–40d, 41

## Inputs

Codex 가지 codex/review-0.1.4(72e520a·adfd3c8·477eb06), codex/claude-phase25-handoff(47b7b86), 사용자 결정 R110–R125

## Files Created

Collection/AddOns/!DevilForever_Core/Party.lua, Collection/tools/patches.py, catalog.py, Collection/patches/{Details,Experience_Forever,ProfileManager,SexyMap}.patch, tests firststart/pitbull4runtime/thirdparty/patches, Claude/results/Step 44·45·40b·40c·40d·41 이력

## Files Updated

Core(Presets·Profiles·Edit·Theme·Core·Commands·Registry·Defaults/Grid2·PitBull4·SexyMap·Presets/*), PitBull4 포크·patch, Skin_Nameplates, Appearance SharedMedia, Castbars, ChatLayout, FUFDefaults, install.json(0.1.5), manifest, build/extract/genregistry, 설치안내, 마스터 플랜·Phase 25 세부계획·요청 대장

## Read Coverage

각 Step 이력의 근거 칸과 audit log 의 master 확인 줄(Step 44: install.json:4, build.py:298-300, SexyMap.lua:144-151 등; 40b: FUFDefaults.lua:126-129, Party.lua:175-182 등; 40c: Aura/Forever.lua:281-283·354-356, Theme.lua:209-211; 45: Composition.lua:55 등). 서브 범위는 각 work_log·audit_log.

## Execution Evidence

Claude/results/handoffs/phase25/iter_1~4 work_log·audit_log, TRIAGE_phase25.md

## Validation·Gate·Confirmed

core 108/108, genregistry --check rc0, pitbull4 6/6, firststart 24/24, fufdefaults 22/22, pitbull4runtime 19/19, thirdparty 8/8, patches 4/4, chatsetup 28/28, castbars 16/16, statusstrip 20/20, Codex runner 8/8, luacheck 0 fail, build 두 번 동일, verify_archives 0.1.5 통과. 검수: 40b C+M 4→2→1→1→0, 40c 3→1→0, 40d 0·0·3.

## Non-Changes

References·Codex 기록·Review/0.1.4 영수증은 고치지 않음. Hekili 는 손대지 않음(R122⑩).

## Open Issues

게임 안 확인 전부(Codex 한 접속 확인표: 저장·복원·preset·CDM 강조·Grid2 파티·토템·기존 SexyMap·네이티브 오라 컨테이너 UNIT_AURA·이름표 텍스처). 경미: 설치안내 올리기 목록에 DevilForever_PerfProbe 누락, patches.py reapply 링크 검사, 빌드 전제(GNU diff/patch) 안내. 0.1.5 ZIP(127MB)은 저장소 한도 초과로 미커밋.

## Decision Queue

0.1.5 ZIP 을 GitHub 릴리스로 올릴지(공개 범위 승인) · unit 기본판(R110①, 게임 비교 뒤) · Hekili 논의(R122⑩) · 선택 애드온 안내(R123-16) · 낱개 틀 전환·적응형 배치(R122⑦⑬, Codex 의견 받음).

## Next

사용자: 릴리스 승인·Codex 한 접속 확인 → 결과로 결함 정정(다음 판).

## Addendum — Step 41-rev (2026-11-20)

Grid2 이름 글자 12/14/18, 설치기 카탈로그를 0.1.5 ZIP 에서 생성, 예비 그림 36개 제외(R127). ZIP 해시가 바뀌었다: 기본판 174149f8…a40e, FUF판 f563aaba…15de(Step 41-rev 이력). 검수 0·0·2. 릴리스는 두 개로 나눠 올린다(R128, Codex).

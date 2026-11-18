# 발주문 — 새 마스터 플랜 초안 (Phase 0 · Step 6)

## 0. 고지 5항목

1. **역할**: 너는 「Devil Forever 애드온 모음집」 Phase 0(마스터 플랜 재수립) Step 6 의 **작업 sub(A1 · 분석·설계·계획 초안)** 다. 3-세션 모델(master + 작업 A + 검수 B) 안에서 너의 책임은 아래 산출물 두 개를 쓰는 것뿐이다.
2. **분업 경계**: 쓰는 파일은 `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 와 `Claude/results/handoffs/master-plan/iter_1/work_log.md` 둘뿐이다. `Codex/`·`SourceArchive/`·`work/`·`MacroLibrary/`·`outputs/`·`.claude/`·루트 `CLAUDE.md` 는 읽기만 한다(수정·삭제·이동 금지). commit 권한은 master. 너는 파일 작성 + work_log 만.
3. **범위 밖 자의 작업 금지**: 새 문건·새 표준·commit·메모리·위 두 파일 밖 파일을 만들지 않는다. 게임 애드온 코드·설치·렌더·이미지 생성 하지 않는다. 네트워크로 새 자료를 받지 않는다(이 컨테이너는 CurseForge·인벤 접근이 막혀 있다 — 아래 3절). 추가 작업 후보는 work_log 의 「Decision Queue」 에 적기만 한다.
4. **허위 attribution 금지**: 사용자가 말하지 않은 것을 사용자 결정으로 쓰지 않는다. 너의 설계 판단은 「A1 제안」 으로, 사용자 원문 근거는 요청 번호(R<n>)와 원문 파일로 적는다. Codex 가 정한 것은 「Codex 기록」 으로 적는다.
5. **따를 규범 요지(주입)**:
   - 전문 정독: 아래 입력 파일은 head→tail 전부 읽는다. 읽은 파일·줄 범위를 work_log 에 적는다. sample·grep 만 보고 정독했다고 쓰지 않는다.
   - 4-tier 보고: 사실은 확정(근거 파일:줄·URL) / 근거 미발견 / 추정 / 미검증 으로 나눈다. Codex 문서에 적힌 내용은 Codex 가 관찰했다는 기록일 뿐이다 — 이 컨테이너에서 다시 확인하지 않은 것은 「Codex 기록」 으로 표시한다.
   - 쉬운 말: 지금 사람들이 쓰는 한국어. 죽은말·한자 조어 금지(예: 정본·거울·문면·문안·전량·발동·수권 쓰지 않음). 기술 용어(AddOn, TOC, profile, taint, API 등)는 영어 원어 그대로, 두문자어는 첫 출현에 풀어 쓴다.
   - 흐름 보호: `rm -rf` 등 승인 창이 뜨는 명령을 쓰지 않는다. 작업 중 정리하려고 지우지 않는다. 임시 파일은 `mktemp -d` 로 스크래치 아래 새 폴더에.
   - 압축 말투(조사 생략·명사 나열) 를 파일에 쓰지 않는다. 파일은 보통 문장으로 쓴다.

## 1. 왜 다시 쓰나 (master 판단)

Codex 가 남긴 최신 후보 `Codex/results/handoffs/old-reference/r44-plan-update/master-plan-candidate.md`(450행)는 내용 요소는 대부분 담았지만 사람이 읽을 수 없다 — 띄어쓰기 없이 낱말을 붙여 쓴 압축문, 같은 단서를 여러 곳에 되풀이, 과거 기록(옛 Step 번호·타임스탬프 원문)이 본문 절반, 46 Step·1915~3465분 추정에 변수 N/T/V/G/U 가 섞여 일정이 보이지 않는다. 사용자는 "시킨 일을 체계적으로 못하고 헤맸다"고 판단해 Codex 를 멈췄다(R73). 새 계획은 **사용자가 한 번 읽고 검수할 수 있는 문서**여야 한다.

## 2. 사용자가 정한 것 (재질문 금지 · 원문 확인 필수)

원문 = `Codex/results/REQUEST_LEDGER.md`(R1–R28), `Codex/results/REQUEST_LEDGER_phase1.3.md`(R29–R72 요지), `Codex/results/handoffs/old-reference/R37-user-message.md` ~ `R72-user-message.md`(R37–R72 사용자 원문 그대로), `Claude/results/REQUEST_LEDGER_phase0.md`(R73). 원문을 직접 읽고 아래 목록이 맞는지 확인하라 — 이 목록은 master 의 요약이고 원문이 우선한다.

- 최종 목표 = WoW Forever(클라이언트 `_forever_`, 관찰판 1.60.1.70938, koKR) 용 **애드온 모음집**(단일 애드온 아님 · R60). 필수 외관 묶음은 하나로 묶어도 되나 기능은 각각 따로 켜고 끌 수 있는 별도 AddOn(R44).
- 시각 기준 = 인벤 idx45 네 번째 샘플(R34), 보조 idx11218 의 미터기 자리를 세 번째 대화창으로(R32·R33). 반투명 대화창 3개(R23), 깔끔한 채팅(제목바·좌측 버튼·못생긴 입력창 없음 · R24). 4K 화면, 버튼 크기→줄·간격→아래부터 쌓은 높이, 화면 비율 환산 금지(R21·R22). 2022 FanFix 기준은 철회(R25).
- 전 직업 공용(R61), 직업별 기능은 Hekili 기반(R62), 주술사 상태+재사용 대기시간은 한 애드온(R44).
- 설정 저장/복원과 사용자 UI 편집 필수(R44).
- 전투 알림·데미지 미터·어그로 미터는 기존 제품 활용 가능(R45), 단 외관을 고칠 각오(R50). 기존 패키지(V42 Forever 판)에서 쓸 것은 가져온다(R47). 우리 것이 낫다면 유지, 저쪽이 완성도 높을 때만 가져온다(R48). 통째로 가져올 것과 기능만 가져올 것을 정한다(R49).
- 대안 테마 1~2개(구획 유지 · 예: 보컬로이드 같은 의외의 컨셉 · R51), 데빌 질감이 구리면 개선(R52), 디자인 판단 위임(R50·R53).
- **순서**: 공통 외관 조성 = 구현 1페이즈, 기능마다 시작 애드온 하나를 배정해 수정·최신화부터, 안 되는 것만 개발(R63), 기능마다 페이즈 하나(R64), 목업은 가능한 작업을 다 한 뒤 마지막(R55·R56), 지시 목록을 순서대로·누락 없이(R57·R58).
- 완성 목업을 채팅에 제시(R46) — 사용자는 출근 중이라 인게임 확인 불가.
- 마스터 플랜을 먼저 사용자 검수(R65).
- 매크로 44개는 원본 보관(도서관)만, 게임 이동·변환 취소(R14–R17). GitHub main 공개는 R67–R70 으로 이미 허용·완료(Codex 기록).

## 3. 이 컨테이너에서 master 가 실측한 사실 (2026-11-18 00:57 UTC)

- 런타임 = 원격 Linux 컨테이너. 게임·Windows·D: 드라이브 없음. 남는 것은 git 에 커밋된 것뿐.
- 네트워크: `www.curseforge.com`·`api.curseforge.com`·`wow.inven.co.kr`·`www.wowinterface.com` → 연결 거부(curl 코드 000). `github.com` → 403. 패키지 저장소(npm·PyPI)만 열려 있다. **즉 Hekili Forever·Forever Unit Frames·Grid2·ForeverThreat·최신 Details!/SexyMap/Quartz 를 지금 받을 수 없다.**
- `lupa` 미설치, `lua` 실행기 없음(PyPI 로 `lupa` 설치는 가능할 것 — 미검증).
- 저장소에 있는 애드온 원천(읽기 전용):
  - V42 Forever 판(인벤 idx13140): `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/` — !DevilUI, Devilconfig, Reflux, Dominos(+Cast/Config/Progress/Roll), PitBull4, Masque(+Dominos/Onyx), kgPanels(+Config), Leatrix_Plus, Mapster, TipTac, Castbars, ChocolateBar, RangeDisplay 등.
  - Prat 3.9.117: `work/clean-chat-step4-fx5q4nxu/extracted-prat-3.9.117-release/Prat-3.0`.
  - 2022 묶음: `SourceArchive/2022-11-19/extracted/Interface/addons/`(Details, Dominos, SexyMap, Quartz 등 · 옛 판).
  - 2009/Alpha/X2/1932/3461 옛 원형: `work/old-reference-collection-*`, `work/old-reference-r36-*`, `SourceArchive/*/originals`.
- 사용자 PC 쪽(Codex 기록): 원본 작업 폴더 `D:/Projects/Project_WF`, 게임 4K.

## 4. 읽을 입력 (전문 정독)

필수:
1. 위 2절의 사용자 원문 파일 전부.
2. `Codex/docs/HANDOVER_v0.1.0.md`(114행) — Codex 마지막 상태.
3. `Codex/plans/2026-11-17-devil-ui-forever-plan.md`(370행 · Codex 의 현행 계획) — 참고만.
4. `Codex/results/handoffs/old-reference/r44-plan-update/master-plan-candidate.md`(450행) — 내용 요소를 빠짐없이 옮기기 위한 대조용. 문장을 베끼지 말고 다시 쓴다.
5. `Codex/results/handoffs/old-reference/r44-plan-update/requirements-coverage.md`(92행) — 요구 대응표.
6. `Codex/results/handoffs/old-reference/r44-plan-update/root-starting-addon-facts-and-r67.md`(24행) — 시작 제품 공식 파일 단서.
7. `Codex/docs/old-devil-reference-comparison.md`(192행), `Codex/docs/forever-clean-chat-research.md`(116행), `Codex/docs/devil-ui-old-4k-layout.md`(105행), `Codex/results/old-reference/a1-r36-source-evidence.md`(118행) — 연구 결과(원형·채팅·4K 설계·V42 실물 근거).
8. `Codex/docs/guimagae-addon-public-facts-2026-11-18.md`(60행) — R39–R43 관련.

필요할 때만(판단 근거로 쓰면 그 범위를 work_log 에): `Codex/results/old-devil-layout/` 의 layout-spec·DESIGN_READY, V42 애드온 TOC·Lua 파일.

## 5. 산출물 요구

`Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` — 한국어 마스터 플랜.

형식:
- 머리에 **간략 목차 트리**(챕터 → Phase → 주요 Step, Step 마다 예상 시간). 실행 중 사용자 지시가 들어오면 어디에 편입되는지 한 줄 규칙.
- 그 다음 11 섹션을 이 이름·순서 그대로: Summary / Current Ground Truth / Phase Range / Non-goals / Implementation Changes / Phase N — <phase name> / Implementation Interfaces / Test Plan / Assumptions / Correction History / Decisions Required.
- Current Ground Truth 안에: 실측 사실과 Codex 기록을 구분한 표, 참고 원문 위치 항목, 소절 「늘 지킬 제약」(사용자 명령마다 처리 갈래: 작업 한정=근거 원문 / 일반 규칙 / 애매=결정 대기), 구조 맵(폴더·파일 역할 — `Claude/` 가 새 작업 자리, `Codex/` 는 보존 기록), 작업 언어 한 줄(내부 기록 = 영어 · 대상이 Lua·TOC·API 식별자라서 / 마스터 플랜·Result = 한국어).
- Step 번호는 누적: Codex 의 실제 Step 1–5(원본 분석·2022 배치 철회·옛 원형 대조·채팅 조사·4K 설계)는 완료 이력으로 표에 한 줄씩만 남기고, 새 Step 은 **6** 부터. 이번 마스터 플랜 작성이 Step 6, 독립 검수·사용자 검수 반영이 Step 7 이다(Phase 0). 실행 Step 은 8 부터.
- 「Phase N」 절은 Phase 목록 표(Phase · 세부 계획서 파일 경로 · Step 범위 · 상태)만. 세부 스텝 목록은 Phase 착수 때 별도 파일 `Claude/plans/2026-11-18-devil-forever-addon-collection-phase<ID>-세부계획.md` 에 쓴다고 적는다.
- Test Plan 에 「검증 관점」 표(검증 대상 · 갈래[① 치환 ② 국소 변경 ③ 구조 변경 ④ 기계적 변경 · 코드면 「코드 ③」 등] · 고정 5 프리셋[P1 코드 · P2 지침 · P3 설치기·도구 · P4 시각 · P5 일반 문서 · P6 데이터 중 하나] · 고정 ③ 신규=연결/수정=연계 · 가변 5 = 그 대상의 핵심 위험). 이번 마스터 플랜 자체(P5 · ③ 구조)도 한 행으로 넣는다. 각 기능 Phase 의 코드 산출물 행, 최종 목업(P4) 행 포함.
- Decisions Required 에: 사용자가 실제로 정해야 하는 열린 질문만(이미 정한 것 재질문 금지) — 각 질문에 내용·근거·선택지·기본값. 그리고 필수 표 「멈출 일 미리 점검」(새 의존성·설치 / 네트워크·외부 호출 / 파괴·비가역 / 권한 / 세션 전환 / 검증 미수렴 / 원래 있던 결함 / 푸시·외부 게시 / 이 환경에서 실측 불가 / 모델 미가용 — 항목마다 기본 대책). 지침 예외가 필요하면 「예외」 로 따로.

내용 설계 — A1 이 판단해 채우되 아래 master 방향을 따른다:
- **원천 확보가 첫 관문이다.** 이 컨테이너는 CurseForge 를 못 연다. 기능별 시작 애드온의 현재 Forever 판 파일을 어떻게 얻는지(사용자가 ZIP 을 저장소에 올림 / 환경 네트워크 허용 요청 / 사용자 PC Remote 연결) 를 Phase 1 준비 Phase 에 넣고, §11 에서 사용자가 고르게 한다. 원천이 없는 기능은 그 Phase 를 막지 말고 순서를 뒤로 미루는 규칙을 둔다.
- **게임 검증은 사용자 PC 몫**이다. 이 컨테이너에서 할 수 있는 검증(정적 분석, Lua 문법 검사, 오프라인 harness, 렌더 목업)과 사용자 PC 에서만 되는 검증(로드·전투·taint·저장)을 Phase 마다 나눠 적는다. 사용자 PC 검증은 Phase 마다 짧은 체크리스트로 묶어 사용자가 퇴근 후 한 번에 돌릴 수 있게 하는 방안을 A1 제안으로 검토하라.
- **산출물 자리**: 모음집 코드가 저장소 어디에 생기는지(예: `Collection/AddOns/<폴더>` + manifest) 를 정한다. 외부 원본 애드온은 원본을 보존하고 수정본을 별도 자리에 두는 방식.
- 기능 Phase 목록은 Codex 후보의 13 기능(공통 외관 / 행동단축바 Dominos / 미니맵 SexyMap / 3 채팅 Prat / 기본 unit·직업 자원 FUF / 시전바 Quartz / 저장·복원 Reflux / 사용자 편집 Devilconfig / 직업 전투보조 Hekili / 공격대 Grid2 / 데미지 Details! / 어그로 ForeverThreat / 대안 테마) 을 출발점으로 쓰되, 순서·묶음·시작 제품 배정이 사용자 원문과 맞는지 다시 판단하고 바꾼 곳은 이유를 적는다. 한 기능 = 한 Phase 원칙(R64)을 지킨다. 대안 테마는 R51 원문이 「제시해줄래」 이므로 목업 단계와의 관계를 판단해 적는다.
- **예상 시간**: Step 마다 분 단위 어림. 미지수(직업 수 등)는 범위로 적되 변수 기호를 늘어놓지 말고 "직업 하나당 X분" 처럼 읽히게.
- 길이: 350~500행 안팎 목표. 같은 말을 여러 곳에 되풀이하지 않는다. 과거 기록 원문(Codex 의 타임스탬프 단락)을 옮겨 붙이지 않는다 — Correction History 에 "Codex 기록 위치" 한 줄로 가리킨다.

## 6. work_log

`Claude/results/handoffs/master-plan/iter_1/work_log.md` 에: 읽은 파일·줄 범위(파일마다) · 실행한 명령과 판정 줄 · 원문 대조 결과(2절 목록과 원문이 다른 곳) · Codex 후보에서 버린 것/바꾼 것과 이유 · Decision Queue · 반환 시 남은 일.

## 7. 반환

반환 글 첫 줄 `PLAN_DRAFT_READY` 또는 `BLOCKED: <이유>`. 이어서 산출 파일 행 수, Step·Phase 수, 총 예상 시간 범위, Decision Queue 요지. 반환하면 멈춘다 — 검수 보고가 오면 master 가 너를 다시 불러 고치게 한다.

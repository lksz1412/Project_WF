# Devil Forever 애드온 모음집 — 마스터 플랜

초안 · 2026-11-18 · Phase 0 Step 6 산출 · 사용자 결정 반영(R83·R86·R87) · 명시 GO 받음(R88) · 실행 중

이 문서는 Codex 가 남긴 계획을 이어받아 다시 쓴 마스터 플랜이다. 사용자가 한 번 읽고 검수할 수 있도록 같은 말을 되풀이하지 않고, 과거 기록은 위치만 가리킨다. 사용자 원문 근거는 요청 번호(R1–R87)로 적고, Codex 가 정하거나 관찰한 내용은 「Codex 기록」, 이 계획을 쓴 분석 서브(A1)의 설계 판단은 「A1 제안」 으로 구분한다.

## 간략 목차

```text
1장 계획·준비
  Phase 0  마스터 플랜 재수립
    Step 1–5 Codex 이력 (원본 분석·2022 배치 철회·옛 원형 대조·채팅 조사·4K 설계) [완료 이력]
    Step 6   새 마스터 플랜 초안 + R76·R77 조사 반영        90–150분
    Step 7   독립 검수·사용자 결정(R83·R86·R87) 반영·GO     90–150분
  Phase 1  준비 — 받은 원천 정리·도구·「쓰는 방식」 1차 판정
    Step 8   ZIP 해제·manifest·TOC/의존 추출·시작 애드온 정독과 「쓰는 방식」 1차 판정 120–240분
    Step 9   모음집 작업 자리·정적 검사 도구·묶음 빌드 스크립트 30–60분
    Step 10  Forever 직업·특성·자원 목록                    45–90분
2장 필수 기능 (한 기능 = 한 Phase · 그대로 쓸 수 있으면 그대로)
  Phase 2  공통 외관 [구현 1] — 코드 기반은 Claude, 외관 구현은 Codex
    Step 11  Core(등록 표·기본값 주입·테마 토큰·편집값 읽기·프레임 이름 목록) 구현 150–240분
    Step 12  정적 검사·논리 검수 반영·Codex 공통 외관 발주문 45–90분
  Phase 3  행동단축바 — Dominos (그대로 사용 추정)
    Step 13  설정 기본값·manifest 등록·Codex 발주문         30–60분 (+직업 하나당 10–15분)
  Phase 4  대화창 3개 — Prat (그대로 사용 추정)
    Step 14  설정 기본값·manifest 등록·Codex 발주문(모듈·세 창 분담) 45–90분
  Phase 5  미니맵 — SexyMap (그대로 사용 추정)
    Step 15  설정 기본값·manifest 등록·Codex 발주문         30–60분
  Phase 6  기본 unit·직업 자원 — Forever Unit Frames (그대로 사용 추정)
    Step 16  설정 기본값·manifest 등록·Codex 발주문·직업 자원 대조 45–90분 (+직업 하나당 15–30분)
  Phase 7  시전바 — Quartz (그대로 사용 추정)
    Step 17  설정 기본값·manifest 등록·Codex 발주문·중복 시전바 끄기 30–60분
  Phase 8  직업 전투보조 — Hekili
    Step 18  원천 정독(감시 데이터·알림 꼴 확인)·지원표·갈래 판정 90–150분
    Step 19  표시 설정·(갈래 2·3 이면 보완 모듈)·정적 검사  60–120분 (+갈래 2·3 이면 60–180분, 갈래 3 의 특성별 목록 작성은 이 Step 에서 직업 하나당 15–30분)
    Step 20  직업별 점검·Codex 발주문                       45–75분 (+직업 하나당 20–40분)
  Phase 9  공격대 프레임 — Grid2 (그대로 사용 추정)
    Step 21  설정 기본값·manifest 등록·Codex 발주문         30–60분
  Phase 10 데미지 미터 — Details! (그대로 사용 추정)
    Step 22  설정 기본값·manifest 등록·Codex 발주문         30–60분
  Phase 11 어그로 미터 — ForeverThreat (그대로 사용 추정)
    Step 23  설정 기본값·manifest 등록·Codex 발주문         30–60분
3장 선택 기능 (R77 · D6 결정 R83 · Step 8 판정: Phase 18 은 고침, 나머지는 그대로 사용·설정)
  Phase 12 툴팁 — TipTac Reborn
    Step 24  설정 기본값·manifest 등록·Codex 발주문         30–45분
  Phase 13 가방 — Bagnon
    Step 25  설정 기본값·manifest 등록·Codex 발주문         30–45분
  Phase 14 이름표 — Platynator
    Step 26  설정 기본값·manifest 등록·Codex 발주문         30–60분
  Phase 15 기본 창 스킨 — Aurora (외관 기능이라 Claude 몫은 등록과 발주문뿐)
    Step 27  manifest 등록·Codex 외관 발주문                20–40분
  Phase 16 정보 바 — Titan Panel
    Step 28  설정 기본값·manifest 등록·Codex 발주문(LDB 정보 구성) 30–60분
  Phase 17 퀘스트·목표 추적기 — Kaliel's Tracker
    Step 29  설정 기본값·manifest 등록·Codex 발주문         30–45분
  Phase 18 세계지도 — Mapster (고침: V42 FogClear 오류 막기 옮김)
    Step 30a FogClear 차이·로드 조건 정독·고침 설계·설정 기본값 30–60분
    Step 30b FogClear 고침·정적 검사·논리 검수 반영·Codex 발주문(자동 업데이트 끄기 포함) 60–135분
  Phase 19 경험치·평판 바 — Experience Forever (비교: Dominos_Progress)
    Step 31  설정 기본값·manifest 등록·Codex 발주문         30–45분
4장 관리 기능·테마
  Phase 20 설정 저장·복원 (필수 묶음) — ProfileManager
    Step 32  지원 범위 확인·범위 복원 설계                  60–90분
    Step 33  범위 복원 구현·정적 검사·Codex 발주문          120–210분
  Phase 21 사용자 UI 편집 (필수 묶음) — 새 개발 (참고: V42 Devilconfig 실행 단추·!DevilUI 이동 손잡이)
    Step 34  Edit Mode Expanded·BlizzMove·!DevilUI minimap.lua 정독·편집 항목·저장 설계 90–150분
    Step 35  편집 창·저장·미리보기·취소·기본값 구현·정적 검사·Codex 발주문 180–300분
  Phase 22 대안 테마 1–2개 — 외관 구현은 Codex
    Step 36  토큰 세트 전환 인터페이스 확인·Codex 대안 테마 발주문 30–60분
5장 묶기·보여 주기·고정
  Phase 23 모음집 연계 검사·정정
    Step 37  전체 묶음 연계 정적 검사 (조합·저장·편집 등록) 90–150분
    Step 38  발견 결함 정정·해당 연계 재검사                60–120분
  Phase 24 최종 목업 (R55: 가능한 작업을 다 한 뒤) — 목업 제작은 Codex
    Step 39  Codex 목업 발주문·받은 목업 대조·채팅 제시     45–90분
  Phase 25 Codex 검증 결과 반영·고정
    Step 40  Codex 검증 결과로 남은 결함 정정               60–120분 (+결과 묶음 하나당 30–60분)
    Step 41  최종 묶음 고정·복원 방법·인계                  30–60분
```

「그대로 사용」 으로 판정된 기능 Phase 는 Step 하나(설정 기본값 파일 + manifest 등록 + Codex 발주문)다. Step 8 에서 「고침」·「새 개발」 로 판정된 기능은 그 Phase 에 하위 Step(예: Step 13a 읽기·설계, 13b 수정·정적 검사)을 붙이고 60–150분을 더한다. Phase 2·8·20·21·23·25 는 처음부터 코드 작업이 있어 Step 이 둘 이상이다. Step 8 판정으로 Phase 18 이 「고침」 이 되어 Step 30a·30b 를 두었고, Phase 21 은 「새 개발」 로 Step 34–35 를 다시 잡았다(Correction History). 외관 작업(Phase 2 외관 구현·각 기능 스킨·Phase 22 테마·Phase 24 목업)은 Codex 몫이라 시간에 넣지 않았다(Implementation Changes 「Codex 몫 목록」). 세부 Step 은 Phase 착수 때 세부 계획서에 쓴다.

**실행 중 새 사용자 지시가 들어오면**: 요청 대장에 다음 R 번호로 적고, 그 지시가 다루는 기능의 Phase 에 넣는다 — 아직 시작하지 않은 Phase 면 그 Phase 의 세부 계획서에, 이미 끝난 Phase 면 Phase 23 의 정정 목록에, 특정 기능이 아닌 일하는 방식에 관한 지시면 「늘 지킬 제약」 표에 넣는다. 범위나 순서가 바뀌면 다음 Phase 를 시작하기 전에 이 문서의 Correction History 에 한 줄 남긴다.

**예상 시간 합계 (Claude 몫)**: Step 6–41 의 고정 부분은 2,090–3,790분(약 35–63시간)이다 — Step 8 판정 반영: Phase 18 고침의 하위 Step 30a·30b 로 +60–150분, Phase 21 을 새 개발로 다시 잡아 Step 34–35 가 180–300분에서 270–450분으로 +90–150분. 그중 선택 기능 Phase 12–19 가 290–535분이다. 여기에 Forever 직업 하나당 45–85분(행동단축바 10–15 + unit·자원 15–30 + Hekili 20–40)이 더해지고, 받은 Hekili 묶음에 직업 모듈이 9개 들어 있으므로 직업이 9개라면 405–765분이 늘어난다(직업 수는 Step 10 에서 확인한다). 조건부로 더해지는 것: Phase 8 이 Step 18 판정에서 갈래 2·3 으로 가면 보완 모듈 60–180분(갈래 3 이면 Step 19 에서 직업 하나당 15–30분 더), Step 8 판정(Phase 18 고침·Phase 21 새 개발)은 위 고정 부분에 넣었고, 그 뒤 기능 Phase 정독에서 다른 기능이 「고침」·「새 개발」 로 바뀌면 그 Phase 하나당 60–150분. Codex 몫(외관 구현·질감 판정과 개선·각 기능 외관 연결·대안 테마·최종 목업·실사용 검증·새 자료 조사)과 그 결과를 기다리는 시간은 넣지 않았다(R86·R87 — Implementation Changes 「Codex 몫 목록」).

## Summary

**목표**: WoW Forever(클라이언트 폴더 `_forever_`, Codex 가 관찰한 판 1.60.1.70938, koKR) 에서 쓰는 **애드온 모음집**을 만든다. 하나의 큰 애드온이 아니다(R60). 외관에 필요한 것은 하나의 필수 묶음으로 둘 수 있지만, 기능은 각각 따로 켜고 끌 수 있는 별도 AddOn 이다(R44). 모든 직업이 같이 쓰는 공용 모음집이며(R61), 직업별 기능은 Hekili 를 기반으로 한다(R62). 상태 알림과 재사용 대기시간(cooldown, CD)은 한 기능 — Hekili 와, 필요하면 그 표시 보완 모듈을 함께 켜고 끄는 「전투보조」 묶음 — 이 맡는다(R44). 설정 저장·복원과 사용자의 UI 편집은 필수다(R44). 어떤 기능을 넣을지는 통합 UI 애드온들이 갖춘 기능을 조사해 다시 짰다(R77 — Phase Range 의 기능 표).

**시각 기준**: 인벤 자료실 idx45 의 네 번째 샘플 그림(R34)이 기준이고, idx11218 은 오른쪽 미터기 자리를 세 번째 대화창으로 바꾼 모습으로 참고한다(R32·R33). 반투명 배경의 대화창 3개(R23), 제목바·왼쪽 버튼·튀어나온 입력창 없는 깔끔한 채팅(R24), 4K 화면에서 버튼 크기 → 줄과 간격 → 아래부터 쌓은 높이 순서로 정하고 화면 비율로 환산하지 않는다(R21·R22). 2022 FanFix 기준은 철회됐다(R25).

**일하는 순서**(R63·R64·R55·R87): 공통 외관을 첫 구현 Phase 로 연다(코드 기반은 Claude, 외관 구현은 Codex) → 기능마다 시작 애드온 하나를 배정하고, 완성도가 높아 고칠 필요가 없으면 그대로 쓴다 → 모자란 것만 설정·고침으로 맞추고, 그래도 안 되는 부분만 새로 개발한다 → 모음집 전체를 함께 검사한다 → 마지막에 Codex 가 만든 완성 목업을 이 채팅에 보여 준다(R46).

**이 환경의 한계와 대응**: 이 세션은 원격 Linux 컨테이너라 게임을 실행할 수 없고 CurseForge 에도 접속하지 못한다. 그래서 (1) 시작 애드온과 참고 애드온의 원본 ZIP 71개는 사용자가 Codex 로 받아 저장소 `References/` 에 올렸고(R75·R80·R81), 새 조사가 필요하면 Codex 에 맡긴다(R80 — Decisions Required D7), (2) 이 세션(Claude)은 코드·기능 단의 작성, 정적 검사(Lua 문법 검사·TOC/의존 대조), 코드 논리 검수(검수 B)까지만 한다(R86·R87). UI 외관(패널·장식·질감·글꼴·배치·스킨·테마·목업)은 Codex 가 「Codex 외관 발주문」 을 받아 만든다(R87), (3) 게임 로드·전투·taint(보호된 UI 를 애드온 코드가 건드려 전투 중 동작이 막히는 현상)·저장·실제 화면 같은 실사용 검증은 Codex 가 사용자 PC 에서 한다(R86). Phase 마다 Codex 가 그대로 실행할 수 있는 「Codex 실사용 검증 발주문」 을 쓰고, 결과는 Codex 가 `References/codex-verify/` 에 올린다.

## Current Ground Truth

### 사실 구분 표

「실측」 은 이 컨테이너에서 다시 확인한 것이고, 「Codex 기록」 은 Codex 가 사용자 PC 나 그때의 네트워크에서 관찰했다고 적은 것이다(이 컨테이너에서 다시 확인하지 않았다).

| 항목 | 내용 | 구분 · 근거 |
|---|---|---|
| 런타임 | 원격 Linux 컨테이너. 게임·Windows·D: 드라이브 없음. 저장소에 커밋된 것만 남는다 | 실측(master, 2026-11-18 00:57 UTC) · `.claude/ENVIRONMENT.md` |
| 네트워크 | curseforge·inven·wowinterface 연결 거부, github.com 403, 패키지 저장소(npm·PyPI)만 열림. 조사 사이트 허용 요청은 승인 화면에서 거부됐다(모바일 앱에서 승인 불가) | 실측(master) · R78·R79 |
| Lua 도구 | `lua` 실행기 없음, Python `lupa` 미설치(import 실패). PyPI 로 설치 가능한지는 미검증 | 실측(master·A1, 2026-11-18) |
| 저장소 상태 | 작업 가지 `ccr-ba95560e-h298t2`, HEAD `8d3f7d4`(Codex 의 원천·조사 커밋을 받은 상태) | 실측(A1) · R81 |
| 받은 원천 | `References/forever-addons/` 에 시작 애드온 13개(Hekili v0.8.6-forever, Forever Unit Frames 0.65.2, Dominos 12.0.4, SexyMap v12.1.7, Quartz 3.8.0, Prat-3.0 3.9.117, Grid2 4.1.13-forever, Details 20261109, ForeverThreat 1.12.3, Masque 12.1.8, Masque Onyx 12.1.6, Chattynator 237, Glass Forever 1.1.6), `References/addon-sources/` 에 참고 애드온 58개. ZIP 71개 `unzip -t` 실패 0, `SOURCE.txt` SHA256 불일치 0, 13개 모두 TOC(애드온이 로드할 파일 목록) 의 Interface 칸에 16001 | 실측(master, R81) · 받은 페이지 URL 의 실재는 이 컨테이너에서 다시 확인하지 못함(미검증) |
| 선택 기능 후보의 TOC | TipTac Reborn(`TipTac_Forever.toc`)·Bagnon·Baganator·Platynator·Aurora·Titan Panel·Kaliel's Tracker·Mapster·Leatrix Plus·ProfileManager·Edit Mode Expanded·BugSack·Dominos_Progress·Dominos_Roll ZIP 안 TOC 에 16001 표기. Reflux 정식판 1.17 은 60000 | 실측(A1, ZIP 안 TOC 머리 줄만 읽음 · 압축 해제 없음) |
| Hekili 직업 모듈 | 받은 Hekili 묶음에 Druid·Hunter·Mage·Paladin·Priest·Rogue·Shaman·Warlock·Warrior 9개 모듈 폴더 | 실측(A1, ZIP 파일 목록). Forever 의 실제 직업 목록이라는 근거는 아니다(Step 10) |
| 라이선스 파일 | Grid2·Hekili·Dominos·Masque·Platynator·Baganator·Aurora·XLoot 등은 ZIP 안에 LICENSE 파일 있음. Forever Unit Frames·ForeverThreat·Quartz·SexyMap·Masque Onyx 는 없음. Details 는 Libs 아래에만 있음 | 실측(A1, 파일 이름만 확인 · 내용 미독) |
| 저장소 안 V42 Forever 판 | `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/` (git 에 1,831파일 커밋됨). !DevilUI 1.1-Forever-v42, Devilconfig, Reflux 1.17-Forever-v1, Dominos 12.0.3(+Cast·Config·Progress·Roll), PitBull4, Masque, Masque_Onyx 11.2.8, kgPanels 1.30.0, Castbars, TipTac 26.09.03, ChocolateBar v3.3.5, Broker_XPBar, Mapster, Leatrix_Plus 1.60.30, BugGrabber·BugSack, RangeDisplay 등. 모두 TOC Interface 에 16001 | 실측(A1, TOC 머리 줄) |
| V42 가 맡긴 설정 | `!DevilUI/Profile/` 에 ChocolateBar·TipTac·Mapster·Leatrix_Plus·BugSack·Broker_XPBar·Plater·Questie·Dominos·PitBull4·kgPanels 등의 profile 파일이 있고, core 가 이 저장 변수들을 다룬다(`!DevilUI.lua:7–45,164–187`) | 실측(A1, 파일 목록과 이름 검색만 · 전문 정독 아님). core 전문 정독은 Codex 기록(`a1-r36-source-evidence.md:9`) |
| 2022 묶음 | `SourceArchive/2022-11-19/extracted/Interface/addons/` 의 SexyMap·Quartz·Details 는 Forever 판이 아니다 | 실측(A1, 앞 세션) |
| 현재 제작물 | 모음집 코드·설치·렌더 목업 모두 없음 | 실측(저장소에 해당 폴더 없음) · Codex 기록(`Codex/docs/HANDOVER_v0.1.0.md:38`) |
| 클라이언트·화면 | `_forever_` 1.60.1.70938, koKR, 사용자 화면 4K(R21). 실제 렌더 해상도·UI scale 은 미검증 | Codex 기록(`Codex/plans/2026-11-17-devil-ui-forever-plan.md:55–56`) |
| 시작 애드온 라이선스 표기 | Grid2 zlib/libpng, Hekili GPLv3, Details!·ForeverThreat All Rights Reserved | Codex 기록(`root-starting-addon-facts-and-r67.md:6–9`) |
| Reflux 동작 | 전역 전환이 AceDB 전체와 다른 변수까지 바꾸고 ReloadUI 를 부르며, save 가 비어 있는 항목을 지운다 — 그대로는 범위 복원으로 안전하지 않다 | Codex 기록(`master-plan-candidate.md:229`) |
| 옛 원형·채팅·4K 설계 | idx45 네 번째 샘플 확정(34개 글·그림 50개 대조), 채팅 후보 4개 비교(게임 검증 10개 미수행), 3840×2160·버튼 80px·하단 구획 304px·상태띠 28px 좌표 제안(PNG 렌더 미수행) | Codex 기록(`old-devil-reference-comparison.md:3–5,63–76` · `forever-clean-chat-research.md:3,36–45,101` · `devil-ui-old-4k-layout.md:16,26–58,93–99`) |
| 기능 조사 | 통합 UI 8개(ElvUI·TukUI·EllesmereUI·SpartanUI·GW2 UI·NDui·RealUI·BenikUI)의 기능 70개 대조, 기능별 단독 대표 애드온과 Forever 파일 표기. 설치·실행 시험 없음 | Codex 기록(`References/addon-survey/features.md:3,25,119–194`, `survey.md:1–20`) |
| GitHub 공개 | R67–R70 에 따라 main 에 작업물 전부 공개 | Codex 기록(`Codex/docs/HANDOVER_v0.1.0.md:23,57`) |
| 매크로 | 원본 4파일·44개를 `MacroLibrary/` 에 보관만 한다. 게임으로 옮기기·변환은 취소 | 사용자 R14–R17 · Codex 기록(`Codex/plans/2026-11-17-devil-ui-forever-plan.md:201`) |

### 참고 원문 위치

- 사용자 원문: `Codex/results/REQUEST_LEDGER.md`(R1–R28), `Codex/results/REQUEST_LEDGER_phase1.3.md`(R29–R72 요지), `Codex/results/handoffs/old-reference/R37-user-message.md` ~ `R72-user-message.md`(원문 그대로), `Claude/results/REQUEST_LEDGER_phase0.md`(R73–R87).
- Codex 최종 상태와 마지막 후보 계획: `Codex/docs/HANDOVER_v0.1.0.md`, `Codex/results/handoffs/old-reference/r44-plan-update/master-plan-candidate.md`, `requirements-coverage.md`.
- 연구 결과: 옛 원형 `Codex/docs/old-devil-reference-comparison.md`, 채팅 `Codex/docs/forever-clean-chat-research.md`, 4K 설계 `Codex/docs/devil-ui-old-4k-layout.md` 와 `Codex/results/old-devil-layout/`, V42 코드 근거 `Codex/results/old-reference/a1-r36-source-evidence.md`, 귀마개 조사 `Codex/docs/guimagae-addon-public-facts-2026-11-18.md`.
- 원천·조사(Codex 기록): `References/addon-sources/INDEX.md`(71개 목록), 각 애드온 폴더의 `SOURCE.txt`(받은 URL·file ID·SHA256)와 `ANALYSIS.md`, `References/addon-survey/survey.md`(기능별 후보), `features.md`(통합 UI 기능표), `evidence/`(관측 JSON).

### 늘 지킬 제약

갈래: **작업 한정** = 이 프로젝트에만 걸리며 근거 원문을 적는다 / **일반 규칙** = 일하는 방식 전반 / **애매 → 결정 대기** = Decisions Required 로 보낸다.

| 사용자 명령 | 갈래 | 근거 · 적용 |
|---|---|---|
| 단일 애드온이 아닌 모음집, 기능은 각각 따로 선택 | 작업 한정 | R44·R60. 선택은 「표시 끄기」 가 아니라 AddOn 자체를 켜고 끄는 것 |
| 전 직업 공용, 직업별 기능은 Hekili 기반, 상태+CD 는 한 애드온 | 작업 한정 | R61·R62·R44. 「한 애드온」 은 Hekili 와 그 표시 보완 모듈을 함께 켜고 끄는 「전투보조」 한 기능으로 지킨다. 무엇을 언제 쓰라고 정하는 추천·판단·회전 로직은 새로 만들지 않는다(특성별로 보여 줄 오라·proc·CD 의 정적 목록은 표시 설정 데이터로 허용 — Phase 8 기능 표). 주술사는 먼저 확인할 직업(R7)이지 전용 대상이 아니다 |
| 설정 저장·복원, 사용자 UI 편집 필수 | 작업 한정 | R44 |
| 시각 기준 idx45 네 번째 샘플, 11218 미터기 자리는 세 번째 대화창 | 작업 한정 | R32–R34. 2022 FanFix 철회(R25), idx2958 은 역사 비교(R27·R28) |
| 반투명 대화창 3개, 깔끔한 채팅 | 작업 한정 | R23·R24 |
| 4K, 버튼 크기 → 줄·간격 → 아래부터 쌓은 높이, 화면 비율 환산 금지 | 작업 한정 | R21·R22 |
| 기존 제품 활용 가능, 단 외관을 고칠 각오 | 작업 한정 | R45·R50 |
| 기존 패키지에서 쓸 것은 가져옴, 우리 것이 나으면 유지, 통째/기능만 구분 | 작업 한정 | R47·R48·R49. 아직 없는 자체 구현을 더 낫다고 하지 않는다 |
| 공통 외관 = 구현 1페이즈, 시작 애드온 수정·최신화 먼저, 안 되는 것만 개발, 기능마다 Phase 하나 | 작업 한정 | R63·R64. Phase 2 는 코드 기반(Claude)과 외관 구현(Codex)으로 나눈다(R87) |
| 완성도가 높아 고칠 필요가 없는 기존 애드온은 그대로 쓴다 | 작업 한정 | R87. 「쓰는 방식」 첫 선택지가 「그대로 사용(수정 없음)」 이고 Step 8 에서 기능마다 판정한다 |
| UI 외관은 Codex, Claude 는 코드·기능 단의 작성·검토만 | 작업 한정 | R87. 외관이 기댈 코드 인터페이스(테마 토큰·등록 규약·프레임 이름 목록)는 Claude 가 먼저 만들고 「Codex 외관 발주문」 으로 넘긴다 |
| 이번 세션의 검수 강도는 master 가 대상마다 정하되 10라운드를 넘지 않는다 | 작업 한정 | R87 · Decisions Required 「예외」 |
| 통합 UI 들이 갖춘 기능을 조사해 기능 얼개를 다시 짠다 | 작업 한정 | R77. 얼개는 Phase Range 기능 표, 무엇을 만들지는 D6 결정(R83 — 기본값) |
| 목업은 가능한 작업을 다 한 뒤 마지막, 완성 목업은 채팅에 제시 | 작업 한정 | R55·R56·R46 |
| 디자인 판단 위임, 대안 테마 1–2개 제시, 질감이 구리면 개선 | 작업 한정 | R50·R51·R52·R53. 판단과 구현은 R87 에 따라 Codex 가 외관 발주문으로 맡는다 |
| 기존 CurseForge 15개 조합은 참고만 | 작업 한정 | R4 |
| 매크로는 원본 보관만, 게임 이동·변환 없음 | 작업 한정 | R14–R17 |
| 본서버 retail WTF(게임 설정 저장 폴더)의 비매크로 설정 참고 | 작업 한정 | R13. 읽기 참고만, 자동 이식 없음. 받는 방법은 D5 |
| 새 Forever 환경이라 옛 설정 없음, 사용자가 기존 애드온 정리 예정 | 작업 한정 | R9·R10. 첫 Codex 실사용 검증 발주문(Phase 1)에서 현재 상태를 확인한다 |
| 실사용 검증은 Codex 가 하고, Claude 는 작성과 코드 논리 검수까지 | 작업 한정 | R86. Claude = 코드 작성 + 정적 검사(Lua 문법 검사·TOC/의존 대조) + 코드 논리 검수(검수 B). 게임 로드·전투·taint·저장·실제 화면은 Codex 가 사용자 PC 에서 발주문대로 한다. 오프라인 로드 harness 는 만들지 않는다(실사용 검증 쪽 · master 해석) |
| 원천은 저장소 `References/` 의 ZIP 을 쓰고 원본 ZIP 은 고치지 않음, 새 조사·내려받기는 Codex 에 맡김 | 작업 한정 | R75·R80·R81. 이 컨테이너의 네트워크 허용은 다시 요청하지 않는다(R78·R79). R31 의 Computer Use 다운로드는 사용자 PC 가 연결될 때만(「원천이 모자랄 때」) |
| 지시 목록을 순서대로, 누락 없이 | 일반 규칙 | R57·R58. 이 문서의 Step 순서와 요청 대장 대응으로 지킨다 |
| 마스터 플랜 먼저 사용자 검수, 지침 준수 | 일반 규칙 | R65·R59. 검수·명시 GO 전 실행 없음 |
| 작업물을 GitHub main 에 올림 | 작업 한정 | R67 「작업물 깃헙 메인에 올려」·R68–R70 「빼는거 없이 다 올려」. 작업은 지정 작업 가지에서 하고, Phase 가 끝날 때마다 작업 가지를 main 에 일반 push 로 반영한다(master 몫 · 강제 push·이력 수정 없음). 이 main 반영에는 `Collection/` 의 고친 판도 라이선스와 관계없이 그대로 들어간다(D4 결정 (나) — 위험은 사용자 감수, R83). 무엇을 고칠지는 「시작 애드온을 고치는 방식」 1–4 를 따른다 |

### 구조 맵

| 경로 | 역할 |
|---|---|
| `Claude/` | 새 작업 자리. `plans/`(마스터 플랜·Phase 세부 계획서), `results/`(요청 대장·Result·발주·작업 기록), `docs/`(인계·구조 맵) |
| `Codex/` | Codex 시기 기록 보존. 고치지 않는다 |
| `References/forever-addons/<애드온명>/` | 시작 애드온 원본 ZIP·`SOURCE.txt`·`ANALYSIS.md`(R75·R81). 읽기 전용 |
| `References/addon-sources/<이름>/` | 참고 애드온 원본 ZIP 58개와 분석. 읽기 전용 |
| `References/addon-survey/` | 기능 조사 문서와 관측 JSON(Codex 기록). 읽기 전용 |
| `Collection/upstream/<이름>-<판>/` | 원본 ZIP 을 스크립트로 푼 해제본. 언제든 ZIP 에서 다시 만들 수 있으므로 커밋하지 않는다(A1 제안, Step 8) |
| `Collection/AddOns/<폴더>/` | 모음집 애드온 — 우리가 새로 만든 애드온과, 고친 시작 애드온 (A1 제안, Step 9 에서 만든다) |
| `Collection/manifest.json` | 애드온마다 역할(필수 묶음/개별 기능)·시작 애드온·원본 판·file ID·SHA256(파일 내용 해시)·라이선스·고쳤는지 여부·의존·저장 변수 |
| `Collection/patches/<애드온>.patch` | 해제본 대비 고친 내용(기계로 만든다) |
| `Collection/tools/` | 해제·Lua 문법 검사·TOC/의존 대조·묶음 빌드 스크립트 |
| `Collection/codex-briefs/` | Phase 마다의 Codex 실사용 검증 발주문(R86)과 Codex 외관 발주문(R87) |
| `References/codex-appearance/` | Codex 가 올린 외관 코드·자산·목업(R87). 받으면 `Collection/` 에 합치기 전에 Claude 가 인터페이스 대조만 한다 |
| `References/codex-verify/phase<ID>/` | Codex 가 올린 실사용 검증 결과(결과 표·BugSack 오류 문구·필요하면 스크린샷). 읽기 전용 |
| `outputs/collection/` | 사용자에게 줄 설치용 ZIP |
| `work/`·`SourceArchive/`·`MacroLibrary/`·`outputs/`(기존 파일) | Codex 시기 원천·작업 사본·매크로 보관. 읽기만 |

**작업 언어**: 내부 기록(Phase 세부 계획서·스텝 이력·발주·작업 기록)은 영어로 쓴다 — 다루는 대상이 Lua·TOC·API 식별자이기 때문이다. 마스터 플랜·Result 는 한국어로 쓴다. Codex 실사용 검증 발주문은 Codex 가 그대로 실행할 수 있게 한국어로 쓰고 경로·명령·식별자는 원어로 둔다(A1 제안).

## Phase Range

### 완료 이력 (Codex)

| Step | 내용 | 상태 · 기록 위치 |
|---|---|---|
| 1 | 2022 공개 원본 확보·정적 분석 | 완료 · `Codex/plans/2026-11-17-devil-ui-forever-phase1.1-세부계획.md` |
| 2 | 2022 첫 이미지 기준 배치 | R25 로 철회·동결 · 같은 파일 |
| 3 | 자료실 전수 대조·옛 원형 확정(idx45 네 번째 샘플) | 독립 검수 수용(중대 0·중간 0·경미 1) · `Codex/docs/old-devil-reference-comparison.md` |
| 4 | Forever 채팅 해결법 조사 | 독립 검수 수용(0/0/0), 게임 검증 미수행 · `Codex/docs/forever-clean-chat-research.md` |
| 5 | 새 원형 4K 배치 설계 | 설계·자체 검사 30/30, 렌더·독립 검수 미수행 → 설계는 Phase 2 의 Codex 공통 외관 발주문으로, 렌더는 Phase 24 의 Codex 목업 발주문으로 넘긴다(R87) · `Codex/docs/devil-ui-old-4k-layout.md` |

### 기능 범위가 넓어진 경위

R1 의 첫 요청은 단축키·체력/마나·미니맵이었고 「부가 기능 제외」 였다(Codex 대장 `REQUEST_LEDGER.md:5` 의 요지 — 첫 메시지 원문은 저장소에 없다). 그 뒤 사용자가 범위를 넓혔다: R44 「기능적인건 전부 따로 선택할수 있어야지. 그리고 설정 저장 복원도 당연히 필요하고 ui를 유저가 수정 가능하게 커스터마이징도 열어 줘야하고」, R45 「이벤트 얼럿같은 것은 기존것을 그냥 적용해도 되잖아? 데미지 미터기 어그로미터기 같은것도」, R60 「애드온 모음집이 목표」, R61 「직업별 전부로하자 공용 애드온으로」, R77 「보통의 통합 애드온 ui들에서 갖추고 있는 기능들을 조사해서 우리가 어떤기능을 포함해야하는지도 다시 얼개를 짜고」. 그래서 원래 13개 기능은 사용자 원문으로 정해진 **필수 기능**으로 두고, R77 조사에서 나온 기능은 **선택 기능**(사용자가 D6 에서 만들지 고름)과 **제외**로 나눴다. R1 의 「부가 기능 제외」 는 경매·우편 같은 편의 기능에는 아직 유효하다고 보고(A1 판단) 그 기능들은 기본값을 제외로 두었다.

### 기능 Phase 정의 (이 표 한 곳에서만 정의한다)

판정: (a) 필수 = 사용자 원문으로 정해진 기능 / (b) 선택 = R77 조사로 올린 기능, D6 결정(R83)으로 확정. 시작 애드온은 받은 원천 가운데 Forever 판이 확정된 것에서 골랐고(survey.md·features.md 의 「Forever 표기 확인」 과 위 TOC 실측), 고른 이유와 비교 대상을 함께 적는다.

**쓰는 방식 (R87)**: 첫 선택지는 「그대로 사용(수정 없음)」 이다. 완성도가 높아 고칠 필요가 없으면 그대로 쓰고, Claude 는 설정 기본값 파일과 manifest 등록, Codex 발주문만 쓴다. 모자라면 설정 → 원본 수정 → 새 개발 순으로만 넓힌다(Implementation Changes 「시작 애드온을 쓰는 방식」). 판정은 Step 8 에서 시작 애드온을 정독한 뒤 기능마다 하고 manifest 에 적는다. 아래 「쓰는 방식」 칸의 「추정」 은 지금의 A1 추정이며 Step 8 판정으로 바뀔 수 있다. 외관(스킨·배치·질감·글꼴)은 어느 기능이든 Codex 외관 발주문으로 넘긴다.

| Phase | 기능 (판정) | 시작 애드온 · 원천 | 쓰는 방식 | 이 Phase 가 하는 일 (Claude 몫 · 외관은 Codex) | 근거 |
|---|---|---|---|---|---|
| 2 | 공통 외관 (a) | V42 !DevilUI 1.1-Forever-v42 의 패널·배치 저장 기전, V42 kgPanels 1.30.0, Masque 12.1.8 + Masque Onyx 12.1.6(`References/forever-addons/`), 옛 원형 자산 | 기능만 가져옴. 설치기 전체·채팅 필터 초기화(core 1174–1184, minimap.lua 815–838)·uiScale 변경(core 1643–1644)은 빼고 | Claude: `DevilForever_Core`(등록 표·테마 토큰 인터페이스·외관 프레임 이름 목록)를 V42 기전을 참고해 만든다. Codex 공통 외관 발주문: Step 5 설계(3840×2160, 버튼 80px, 하단 구획 304px, 상태띠 28px, 대화창 3개·미니맵·중앙 8×3·긴 윗줄·양끝 장식)로 패널·구분선·장식·글꼴을 만들고, 장식이 마우스 입력을 막지 않게 하며, 질감을 실제 게임 배율에서 판정해 필요하면 개선한다(R52) | R63·R34·R21·R22·R52·R87 · Codex 기록 `a1-r36-source-evidence.md:24–38` |
| 3 | 행동단축바 (a) | Dominos 12.0.4 (Dominos·Cast·Config·Masque_Dominos 동봉). 비교: Bartender4 4.19.0 | 그대로 사용 + 설정 (추정) | 바 개수·페이지 전환·직업 특수 바(stance·form 등)·단축키 표시 같은 기능 설정 기본값. 키 자동 배정은 하지 않는다. 배치·크기·스킨은 Codex. Dominos 를 고른 이유: 옛 Alpha 원형과 V42 가 모두 Dominos 를 썼고 V42 에 Dominos profile 이 있다(R47) | R1·R22·R47 · Codex 기록 `old-devil-reference-comparison.md:91` |
| 4 | 대화창 3개 (a) | Prat-3.0 3.9.117. 비교: Glass Forever 1.1.6·Chattynator 237 (기록 방식 참고만) | 그대로 사용 + 설정 (추정) | 기본 대화창과 기본 입력은 그대로 둔다. 켤 Prat 모듈과 core 의 메시지·입력 hook·History·ChatLog 부수 동작을 판정하고, 세 창 분담(D3)을 기본값으로 넣는다. 미터기를 세 번째 창 자리에 두지 않는다. 버튼·탭·입력 테두리·글꼴 외관은 Codex. Prat 을 고른 이유: Glass 는 instance 안 표시 한계, Chattynator 는 대화창 자체를 바꾼다(Codex 기록) | R23·R24·R33 · Codex 기록 `forever-clean-chat-research.md:59,74–78,88–99` |
| 5 | 미니맵 (a) | SexyMap v12.1.7. 비교: BasicMinimap v12.1.6, V42 minimap.lua 의 사각 지도 기전 | 그대로 사용 + 설정 (추정) | 클릭·확대·핑·추적 아이콘·버튼 정리 같은 기능 설정. 사각 모양·위치·테두리는 Codex | R1·R34 |
| 6 | 기본 unit·직업 자원 (a) | Forever Unit Frames 0.65.2. 비교: V42 PitBull4 4.2.49-Forever-v42, NugComboBar 12.1.3(연계 점수) | 그대로 사용 + 설정 (추정) | 모든 직업 공통의 체력과 직업마다 다른 주·보조 자원을 Step 10 직업 표와 대조해 맞게 보이는지 설정한다. 프레임 위 버프·디버프·치유 예측·거리 흐림도 FUF 설정 범위다. 모든 직업에 마나·토템을 강제하지 않는다. Phase 9 가 켜지면 파티·공격대 표시는 끈다 | R1·R61 · features.md:52–53,180–181 |
| 7 | 시전바 (a) | Quartz 3.8.0. 비교: V42 Castbars Forever-2 | 그대로 사용 + 설정 (추정) | 내/대상 시전바, 시전·취소·차단 표시. 기본 시전바·Dominos_Cast·FUF 시전바와 겹치지 않게 한쪽만 남긴다 | Codex 기록 `Codex/plans/2026-11-17-devil-ui-forever-plan.md:137` |
| 8 | 직업 전투보조 (a) | Hekili v0.8.6-forever (직업 모듈 9개 동봉). 비교: TellMeWhen 12.1.5 (알림 방식 참고만) | 그대로 사용 + 표시 설정. Step 18 의 갈래 판정에 따라 표시 전용 보완 모듈 `DevilForever_Combat` 을 새로 개발(Step 19) | **확인(Step 18)**: Step 10 직업·특성 표의 특성마다 ㉠ Hekili 직업 모듈에 오라·proc·CD 감시 데이터가 있는지 ㉡ Hekili 가 상태 알림을 어떤 꼴로 보이는지(R6 의 EventAlert 식 — 화면 중앙 아이콘·소리·강조 — 이 있는지)를 원천에서 확인하고, 「직업 × 특성 × (상태 알림 / proc / CD / 다음 행동 추천)」 지원표를 만든다. **갈림길**: 갈래 1 = ㉠·㉡ 이 모두 있으면 Hekili 설정만으로 맞춘다. 갈래 2 = ㉡ 이 없으면 보완 모듈이 전 특성의 알림 꼴(각각 끌 수 있게)을 맡는다. 갈래 3 = 어떤 특성에 ㉠ 이 없으면 보완 모듈이 그 특성의 정적 표시 목록을 갖는다. **갈래 3 의 원천**: ① Hekili 직업 모듈 데이터 → ② 없으면 D7 로 Forever 주문·오라 자료(예: 공개 DB 페이지)를 받아 Step 19 에서 목록 작성 → ③ 그것도 없으면 Retail 로 지어내지 않고 그 특성을 「원천 없음」 으로 표시해 사용자가 고르는 칸만 열어 두고, 최종 보고에 그 특성 목록을 싣는다. 사용자가 추가·삭제한 항목은 어느 갈래에서나 우선한다. **경계**: R62 로 금지되는 것은 「무엇을 언제 쓰라고 정하는 추천·판단·회전 로직」 뿐이고 정적 표시 목록은 표시 설정 데이터다. 다른 알림 제품은 붙이지 않는다. Hekili 와 보완 모듈은 「전투보조」 한 기능으로 함께 켜고 끄는 한 묶음이다(R44). 직업별 점검은 주술사부터 한다(R7). 표시 범위는 D2. 표시 위치·크기·스킨은 Codex | R5·R6·R44·R61·R62 |
| 9 | 공격대 프레임 (a) | Grid2 4.1.13-forever (Grid2·Grid2Options·Grid2LDB). 비교: VuhDo v3.221 | 그대로 사용 + 설정 (추정) | 역할·해제 가능 디버프·마우스오버·클릭 시전·지속 치유 표시자 같은 기능 의미는 바꾸지 않고 기본값만 넣는다. 외관은 Codex | R45·R50 · Codex 기록 `root-starting-addon-facts-and-r67.md:6,11` |
| 10 | 데미지 미터 (a) | Details 20261109 (`Details_Camelot.toc` 16001). 비교: Skada v2.6.7 | 그대로 사용 + 설정 (추정) | 값·정렬 의미 보존, 기본 표시 항목. 세 번째 대화창 자리를 차지하지 않는 위치와 스킨은 Codex | R45·R50·R33 |
| 11 | 어그로 미터 (a) | ForeverThreat 1.12.3. 비교: ThreatClassic2 2.77-forever | 그대로 사용 + 설정 (추정) | 위험도 표시 의미 보존, profile 기본값. 이름표의 위협 색(Phase 14)과 같은 정보를 두 번 크게 보이지 않게 나눈다. 위치·스킨은 Codex | R45·R50 |
| 12 | 툴팁 (b) | TipTac Reborn v26.11.11 (`TipTac_Forever.toc`). 참고: V42 TipTac 26.09.03 과 `!DevilUI/Profile/TipTac.lua` | 그대로 사용 + 설정 (추정) | 표시 위치(마우스 옆/고정), 아이템 비교 툴팁 같은 기능 설정. 배경·테두리·글꼴은 Codex | features.md:54,135,203 · R47·R50 |
| 13 | 가방 (b) | Bagnon 12.1.11 (BagBrother·Bagnon_Bank·Bagnon_Config). 비교: Baganator 862 (한 창·분류 보기) | 그대로 사용 + 설정 (추정) | 한 창 가방·은행 보기와 메뉴줄 가방 버튼 연결. 외관은 Codex | features.md:55–56,136–137 |
| 14 | 이름표 (b) | Platynator 547. 참고: `!DevilUI/Profile/Plater.lua`(Plater 자체는 V42 에 없음) | 그대로 사용 + 설정 (추정) | 체력·시전·위협 색 표시 기능. 위협 상태 표시(features F37)를 여기서 받는다. 데빌 토큰 적용은 Codex | features.md:57,80,138 |
| 15 | 기본 창 스킨 (b) | Aurora 12.1.5.4 | 그대로 사용 (추정) | 기능이 곧 외관이라 Claude 몫은 manifest 등록과 Codex 외관 발주문뿐이다. 기본 버프 창이 범위에 드는지, 다른 애드온 창에 스킨이 두 번 걸리지 않는지는 Codex 가 본다 | features.md:68,149,216 · R50·R87 |
| 16 | 정보 바 (b) | Titan Panel 9.3.7. 참고: V42 ChocolateBar v3.3.5·Broker 플러그인과 `!DevilUI/Profile/ChocolateBar.lua` | 그대로 사용 + 설정 (추정) | 시간·지연·골드·화폐 같은 정보와 Devilconfig·BugSack 같은 LDB(LibDataBroker, 정보 표시 공용 규약) 버튼 구성. Step 5 하단 상태띠(28px)에 앉히는 외관은 Codex. Titan 을 고른 이유: Forever 판이 확인됐고 ChocolateBar 는 V42 판만 있다(R48 비교는 Step 8) | features.md:58,139,204,239 · R47·R48 |
| 17 | 퀘스트·목표 추적기 (b) | Kaliel's Tracker 8.11.1-forever. 참고: Questie v12.10.0(퀘스트 도우미, V42 profile 있음) | 그대로 사용 + 설정 (추정) | 추적 항목 기능 설정. 위치·외관(중앙 시야를 가리지 않게)은 Codex | features.md:81,162,230 |
| 18 | 세계지도 (b) | Mapster 1.14.0. 참고: V42 Mapster 1.14.0-Forever-v2(FogClear 오류 막기의 원천)와 `!DevilUI/Profile/Mapster.lua` | 고침 (Step 8 판정): V42 의 FogClear 오류 막기를 받은 판에 옮긴다. TOC 머리말 `AllowLoadGameType: mainline` 은 Codex 가 게임 애드온 목록에서 로드 불가를 확인할 때만 고친다 | 좌표·미탐색 영역 같은 기능 설정. 미니맵(Phase 5)과 담당을 나눈다. 고친 판이라 Codex 발주문에 자동 업데이트 끄기를 넣는다. 크기·투명도는 Codex | features.md:63,144,209 · R47 · `Collection/judgment.md` 4-1 · master 결정 `Claude/results/handoffs/phase1/TRIAGE_phase1.md:24` |
| 19 | 경험치·평판 바 (b) | Experience Forever 2.0.4. 비교: Dominos_Progress (Dominos 12.0.4 묶음 안 별도 AddOn — 소환수 경험치 없음), V42 Broker_XPBar | 그대로 사용 + 설정 (Step 8 판정) | 경험치·평판·사냥꾼 소환수 경험치(`showPetBar`) 표시 기능 설정. 같은 기능을 두 애드온이 맡지 않게 Dominos_Progress 는 끈다. Step 5 설계의 긴 윗줄·검은 띠 범위 안 배치는 Codex | features.md:59–60,140–141,190,219 · R47 · `Collection/judgment.md` Phase 19 · master 결정 `TRIAGE_phase1.md:27` |
| 20 | 설정 저장·복원 (a, 필수 묶음) | ProfileManager v4.0. 비교: V42 Reflux 1.17-Forever-v1 | 설정 + 모자란 범위 복원만 새 개발 | 등록 표의 저장 변수만 다루는 범위 복원. 공통 배치·외관 설정과 직업·특성별 설정을 나눠 저장하고 특성이 바뀌면 그 profile 로 전환한다(features F68). 설치되지 않은 애드온 항목은 지우지 않고, 알 수 없는 판의 데이터는 조용히 초기화하지 않는다. 키 설정과 게임 설정(ProfileManager 의 `Keybinds.lua`·`GameSettings.lua`)도 R44 의 「설정 저장 복원」 범위에 넣는다 — 사용자가 직접 정한 값을 저장했다가 사용자가 고를 때만 되돌리며, 키 자동 배정·매크로 이식과는 다르다. 매크로는 다루지 않는다(R14–R17). Reflux 에서 바꾼 이유는 Phase Range 「바꾼 곳」 6 | R44 · survey.md:89–93 |
| 21 | 사용자 UI 편집 (a, 필수 묶음) | 새 개발. 참고: V42 Devilconfig 1.0-Forever-v42 (LDB 실행 단추·전투 중 거절 패턴), V42 `!DevilUI/minimap.lua` 의 이동 손잡이·잠금·전투 중 숨김. 비교: Edit Mode Expanded 12.1-026, BlizzMove v3.8.8 (Step 34 에서 정독) | 새 개발 (Step 8 판정: Devilconfig 에는 편집·저장 기전이 없다) — 편집 창과 저장 | 위치·크기·글꼴·색·줄 수·간격을 편집하고 저장하는 기능. 저장한 값은 Core 가 「토큰 위에 덮어쓰는 프레임별 값」 으로 내주고 외관 코드(Codex)가 그 값을 읽어 화면에 건다. 각 애드온이 실제로 지원하는 항목만 보여 준다. 적용 전 미리보기, 취소, 기본값으로 되돌리기. 보호된 프레임 편집은 전투 밖에서만. 편집 창의 외관은 Codex | R44·R47 · survey.md:99–103 · `Collection/judgment.md` 4-3 · master 결정 `TRIAGE_phase1.md:25` |
| 22 | 대안 테마 1–2개 (a) | Phase 2 Core 의 테마 토큰 인터페이스 | 외관 구현은 Codex | Claude: 테마 토큰 세트를 바꿔 끼우는 인터페이스가 다른 애드온 스킨에도 같이 걸리는지 확인하고 Codex 대안 테마 발주문을 쓴다. Codex: 단순 색 바꾸기가 아니라 질감·글꼴·막대·장식이 한 컨셉으로 맞는 테마 1–2개 | R51·R53·R87 |

**만들지 않는 기능 — D6 결정(R83) · 나중에 사용자가 고르면 Phase 19 뒤에 붙인다**

| 기능 | 시작 애드온 | 기본값을 제외로 둔 이유 |
|---|---|---|
| 편의 자동화(자동 수리·자동 판매·퀘스트 자동 제출·빠른 전리품 획득) | Leatrix Plus 1.60.31-forever (V42 에 1.60.30 동봉) | 규칙 ① 에 걸리는 예외(V42 동봉). R1 의 「부가 기능 제외」 에 가장 가깝다. V42 에서 Leatrix 가 대화창 버튼 옵션도 맡아(Codex 기록 `forever-clean-chat-research.md:82`) Prat 과 같은 영역을 두 애드온이 맡을 위험이 있다 |
| 전리품 창·주사위 | Dominos_Roll (Dominos 12.0.4 묶음, V42 에도 동봉). 비교: XLoot 12.23.0 | 규칙 ① 에 걸리는 예외(V42 동봉). 통합 UI 확인 수 3/8(features.md:93)이고, Dominos 묶음에 이미 들어 있어 사용자가 켜기만 하면 되며 `!DevilUI/Profile/` 에도 따로 맞춘 설정이 없어 외관 Phase 를 따로 두지 않는다(A1 판단) |

**제외한 기능 (features.md:241–286 의 나머지)**

| 기능 | 처리 | 이유 |
|---|---|---|
| 버프·디버프 표시 | 별도 Phase 없음 (규칙 예외) | 규칙 ①(7/8·6/8)에 걸리지만 예외로 둔다. 프레임 위 오라는 Phase 6, 상태 알림은 Phase 8(R44 「두가지가 하나의 애드온」), 기본 버프 창 외관은 Phase 15 의 Codex 외관 발주문에서 확인. 전용 시작 후보 중 Forever 확정은 알림 도구 TellMeWhen 뿐이라 R44 와 겹친다 |
| 재사용 대기시간 관리자·버튼 위 CD 숫자 | 별도 Phase 없음 | R44 가 CD 를 Hekili 쪽 한 애드온에 두었다. 숫자 표시 대표 OmniCC 는 Forever 미확인(features.md:142) → 필요하면 D7 |
| 위협 상태 표시 | Phase 11·14 가 맡음 | 같은 정보를 두 애드온이 맡지 않는다 |
| 지속 치유 추적·치유 예측·거리 흐림 | Phase 6·9 의 설정 범위 | FUF·Grid2 가 프레임 안 표시자로 갖고 있다(features.md:163,180–181) |
| 한 창 가방·화폐 정보·소환수 경험치 | Phase 13·16·19 의 범위 | 같은 기능의 세부 항목이다 |
| 글꼴 교체·말풍선 글꼴 | Phase 2·4 의 범위 | 공통 외관 토큰과 Prat 의 말풍선 글꼴(features.md:191)로 처리 |
| 우편 모두 열기·획득 전리품 알림·전문기술·아이템 수량·여러 평판 대시보드 | 제외 | R1 「부가 기능 제외」, 통합 UI 확인 수 1–2/8. Postal 은 Forever 미확인 |
| Mythic+ 타이머·Skyriding 화면·비행 모드 | 제외 | Forever 에 그 콘텐츠가 있다는 근거 미발견, 대표 후보 Forever 미확인 |
| AFK 화면 | 제외 | 확인 수 5/8 이지만 Forever 파일 표기가 확인된 시작 애드온이 없다(features.md:171) — 규칙 ② 미충족 |
| 비네트·커서 효과·게임패드 배치·친구 목록·Party Mode | 제외 | 장식·특수 입력 기능으로 요청 근거가 없고 확인 수 1–2/8 이거나 Forever 후보 미확인 |
| 전투 문자 | 제외 | 대표 후보(MSBT·NSCT) 모두 Forever 미확인(features.md:177) → 원하면 D7 |
| 공격대 유틸리티(준비 확인·징표) | Phase 6·10 의 범위에서 켤지 판정 | FUF·Details 가 일부를 갖고 있다(features.md:182) |
| 오류 수집·표시 | 기능 Phase 아님 | Codex 실사용 검증용 도구(BugSack + BugGrabber, D1) |

**V42 동봉 애드온 분류 (32개 폴더 전부 · 실측 목록)**

| V42 폴더 | 가는 곳 |
|---|---|
| !DevilUI · kgPanels · kgPanelsConfig · Masque · Masque_Onyx | Phase 2 (공통 외관 — !DevilUI 의 기전은 Claude 가 Core 를 만들 때 참고하고(그 `minimap.lua` 이동 손잡이는 Phase 21 편집 창도 참고), kgPanels·kgPanelsConfig 패널과 Masque·Onyx 스킨(받은 최신판)은 Codex 외관 구현이 쓴다 · R87) |
| Dominos · Dominos_Config · Masque_Dominos | Phase 3 (받은 Dominos 12.0.4 로 최신화) |
| Dominos_Cast · Castbars | Phase 7 의 비교·중복 정리 대상 |
| PitBull4 | Phase 6 의 비교 대상 |
| TipTac · TipTacItemRef · TipTacOptions · TipTacTalents | Phase 12 (TipTac Reborn 으로 최신화, 설정 참고) |
| ChocolateBar · Broker_Money · Broker_Guild_Friends · shPerformance | Phase 16 (정보 바와 그 위에 올리는 LDB 정보 — 골드·길드/친구·FPS·지연·메모리) |
| Broker_XPBar · Dominos_Progress | Phase 19 의 비교 대상 (시작은 받은 Experience Forever 2.0.4 — Step 8 판정) |
| Mapster | Phase 18 (FogClear 오류 막기를 받은 Mapster 1.14.0 에 옮기는 원천) |
| Reflux | Phase 20 의 비교 대상 |
| Devilconfig | Phase 21 (실행 단추 패턴만 참고 · 편집·저장은 새 개발) |
| Dominos_Roll · Leatrix_Plus | 만들지 않는 기능 (D6 결정 · 위 표) |
| !BugGrabber · BugSack | Codex 실사용 검증용 도구 (D1) |
| RangeDisplay · RangeDisplay_Options (대상 거리 숫자) · SkillUpForever (전문기술 숙련 정보) · AdvancedInterfaceOptions (숨은 게임 옵션 창) | 제외 — 규칙 ① 에는 걸리지만 CurseForge Forever 판이 확인되지 않아 ② 미충족. 나중에 원하면 사용자가 고르고 D7 경로로 Forever 판 조사 |

**Codex 후보에서 바꾼 곳과 이유 (A1 제안)**

1. **질감 개선(R52)을 대안 테마에서 공통 외관(Phase 2)으로 옮겼다.** 데빌 기본 테마의 질감은 공통 외관 자체이므로 처음 만들 때 판정해야 뒤의 스킨이 고친 자산을 그대로 쓴다. 판정과 개선은 R87 에 따라 Codex 공통 외관 발주문에 들어간다.
2. **저장·복원과 사용자 편집을 다른 기능 Phase 뒤(20·21)로 옮겼다.** 두 기능은 다른 모든 애드온의 설정을 다룬다. 다른 애드온이 생긴 뒤에 만들어야 다시 고칠 일이 줄어든다. 대신 Phase 2 에서 등록 규약(Implementation Interfaces)을 먼저 정해 각 기능 Phase 가 Core 의 등록 표에 자기 저장 변수·편집 항목을 적어 둔다.
3. **대화창을 미니맵보다 앞(Phase 4)에 두었다.** R24 에서 가장 강하게 지적된 부분이다.
4. **대안 테마(R51 「제시해줄래」)는 관리 기능 뒤(Phase 22)에 두고, 보여 주는 것은 최종 목업(Phase 24)에서 한다.** R55 에 따라 목업은 그 뒤다. R87 로 테마 구현과 목업은 Codex 가 맡고 Claude 는 토큰 인터페이스와 발주문만 쓴다. 컨셉 후보 「네온 보컬 스테이지」·「백자와 먹빛」 은 Codex 기록의 제안이며 사용자 선택이 아니다. Codex 가 대안 테마 발주문을 받아 다시 판단한다.
5. **R77 조사로 선택 기능 Phase 8개(12–19)를 새로 넣었다.** 기본값 규칙: ① 통합 UI 8개 중 5개 이상이 갖춘 기능이거나 V42 가 이미 담고 있던 기능(R47)이고, ② survey.md·features.md 에서 Forever 파일 표기가 확인된 시작 애드온이 받은 원천에 있으면(R63) 만든다. ①·② 를 갖췄어도 이미 다른 Phase 가 맡는 기능(위협 상태 표시·직업 자원·글꼴 등)은 그 Phase 범위로 넣는다. 그 밖은 만들지 않는다. 규칙에 걸리지만 만들지 않는 예외는 세 가지이고 이유는 위 표에 있다: 편의 자동화(R1), 전리품 창·주사위(묶음에 들어 있어 켜기만 하면 됨), 버프·디버프 표시(R44 와 겹침). AFK 화면(5/8)은 ② 가 없어 만들지 않는다. V42 동봉 애드온 32개는 모두 「V42 동봉 애드온 분류」 표에서 어디로 가는지 적었다.
6. **저장·복원 시작 애드온을 Reflux 에서 ProfileManager 로 바꿨다.** ProfileManager 는 Forever 판이 확인됐고(survey.md:91) 지원 애드온별로 골라서 적용하는 흐름이 범위 복원 요구와 가장 가깝다. Reflux 정식판은 Forever 판이 확인되지 않았고(TOC 60000) V42 판은 전역 전환 문제가 있다(Codex 기록). ProfileManager 가 우리 애드온들을 얼마나 지원하는지는 아직 모른다 — Step 32 에서 `Providers.lua`·`Addons.lua` 를 읽고 모자라면 Reflux 의 기전을 참고해 그 부분만 만든다.
7. **원천 확보 단계를 「수령 완료 → 해제·manifest·정적 분석」 으로 바꿨다(R81).** 원천 대기 때 쓰던 대체 시작점 열과 긴 미루기 규칙은 아래 짧은 예외 규칙으로 줄였다.
8. **Step 8 판정으로 세 기능의 쓰는 방식을 바꿨다(A1 판단 · master 결정 `TRIAGE_phase1.md:21–27`).** 세계지도(Phase 18)는 V42 가 고친 FogClear 오류 막기를 받은 Mapster 에 옮기는 「고침」 이다. 경험치·평판 바(Phase 19)는 Dominos_Progress 에 소환수 경험치가 없어 Experience Forever 로 시작한다. 사용자 UI 편집(Phase 21)은 V42 Devilconfig 에 편집·저장 기전이 없어 「새 개발」 이다. 근거는 `Collection/judgment.md` 4-1·4-3·Phase 19.

### 원천이 모자랄 때 (남은 예외)

시작 애드온 ZIP 은 모두 받았다. 그래도 어떤 Phase 가 저장소에 없는 파일(예: 더 새 판, 비교용 원천)이 꼭 필요하다고 판단되면 그 Phase 를 「원천 대기」 로 두고 다음 Phase 를 먼저 한다. 필요한 파일은 D7 형식의 Codex 조사 요청으로 최종 보고에 적어 사용자에게 넘긴다. R31(일반 다운로드가 안 되면 Computer Use 로 받아도 된다)은 이 클라우드 세션에 사용자 PC 연결이 없어 지금은 쓸 수 없고, 그 몫은 Codex 경로(R80)가 맡는다. 사용자 PC 가 이 세션에 연결되면 R31 은 다운로드에 한해 그대로 유효하다. 파일이 들어오면 지금 하던 Phase 가 끝난 직후 그 Phase 로 돌아간다. 순서를 바꿀 때마다 진행 표와 Phase N 표의 상태 칸에 적는다.

## Non-goals

- 사용자 검수·명시 GO 전 구현·설치·렌더 (R65).
- 단일 거대 애드온, 표시 토글만으로 흉내 낸 「선택」, 같은 기능을 두 애드온이 동시에 맡는 구성(Hekili 와 그 표시 보완 모듈은 역할을 나눠 함께 켜고 끄는 한 묶음이라 여기에 들지 않는다).
- 무엇을 언제 쓰라고 정하는 자체 추천·판단·회전 로직(rotation 엔진)과 직업마다 별도 UI 를 만드는 것 (R62). 특성별로 보여 줄 오라·proc·CD 를 적은 정적 표시 목록은 표시 설정 데이터라 여기에 들지 않는다.
- Forever 에 없는 직업·특성·자원·주문·오라를 Retail 목록으로 지어내는 것, 확인하지 않은 직업을 지원 완료로 적는 것 (R61). 원천이 없으면 「원천 없음」 으로 표시한다(Phase 8 갈래 3).
- 2022 배치·V42 설치기 통째 이식, 사용자 채팅 필터·uiScale·전체 WTF 초기화.
- 이 세션이 UI 외관(패널·장식·질감·글꼴·배치·각 기능 스킨·대안 테마·목업)을 구현하는 것 (R87 — Codex 몫, Claude 는 외관이 기댈 코드 인터페이스와 발주문만).
- 완성도가 높아 고칠 필요가 없는 기존 애드온을 고치는 것 (R87).
- 이 세션이 사용자 PC 를 원격으로 조작하거나 게임에 직접 설치하는 것, 오프라인 로드 harness 를 만드는 것(설치·실사용 검증은 Codex 가 발주문대로 한다 — R86).
- 매크로 이동·변환(R14–R17), 키 자동 배정(새 환경이라 옮겨 올 키가 없다 — R10, Codex 기록 `Codex/plans/2026-11-17-devil-ui-forever-plan.md:120`), 제외 표에 둔 기능과 경매 같은 요청하지 않은 부가 기능 (R1·R4).
- 원본 ZIP·`References/`·Codex 기록·Step 5 설계 파일 수정·정리 삭제. 이 컨테이너의 네트워크 허용 재요청(R78·R79).

## Implementation Changes

### 모음집 구성 (A1 제안)

- **필수 묶음**: 공통 외관(`DevilForever_Core` — 등록 표, 처음 로드 때 기본 설정을 한 번 넣고 사용자 값은 덮어쓰지 않는 기본값 주입, 테마 토큰과 프레임별 편집값을 내주는 읽기 함수, 외관 프레임 이름 목록, 그리고 Codex 가 만드는 패널·구분선·장식·글꼴), Masque 와 Onyx 스킨, 설정 저장·복원(Phase 20), 사용자 UI 편집(Phase 21). R44 의 「외관을 위한 애드온들 가져다쓴것들 필수 적인건 하나로 묶더라도」 와 「설정 저장 복원도 당연히 필요」 를 묶음 단위로 옮긴 것이다. 폴더는 각자 따로 두고 manifest 에서 필수로 표시한다.
- **개별 기능 애드온**: Phase 3–19 의 기능. 각자 자기 폴더·TOC·저장 변수를 갖고 따로 켜고 끈다. 외관 연결 폴더 `DevilForever_Skin_<애드온>`(그 애드온을 의존으로 둠)은 Codex 가 만들며, 그 애드온이 꺼져 있으면 로드되지 않는다.
- **이름**: 우리가 새로 만드는 폴더는 `DevilForever_` 로 시작한다. 고친 시작 애드온은 원래 폴더 이름을 유지하고 manifest 에 「고침」 으로 표시한다(원래 이름이어야 다른 애드온의 의존이 깨지지 않는다). 사용자 관례가 따로 있으면 그것을 따른다.

### 시작 애드온을 쓰는 방식 (R63·R87)

다음 순서에서 앞 단계로 되면 뒤로 가지 않는다.

0. **그대로 사용(수정 없음)**: 받은 최신 Forever 판이 요구를 채우면 고치지 않는다(R87). Claude 는 설정 기본값 파일과 manifest 등록, Core 등록 표의 그 애드온 항목만 쓴다.
1. **최신화**: 받은 최신 Forever 판을 기준으로 삼는다. 저장소 안 옛 판(V42 동봉본 등)과 다르면 차이를 기록하고 최신판을 쓴다. V42 의 profile 은 설정값 참고로만 쓴다.
2. **설정으로 해결**: profile·옵션 값으로 되는 것은 설정으로 한다. 기본 설정은 Core 의 기본값 주입이 처음 로드될 때 한 번 넣어 주고, 사용자가 바꾼 값은 덮어쓰지 않는다.
3. **외관 연결**: 외관은 원본을 건드리지 않고 그 애드온이 공개한 스킨·테마 API 나 Masque 로 맞춘다. 이 연결 폴더는 Codex 가 외관 발주문을 받아 만든다(R87).
4. **원본 수정(fork)**: 0–3 으로 안 될 때만 한다. 라이선스는 이 판단을 막지 않는다(D4 결정 (나) — 위험은 사용자 감수, R83). 각 제품의 라이선스 내용은 Step 8 에서 읽어 manifest 에 기록만 한다. 원본 폴더를 고치므로 CurseForge 앱 자동 업데이트가 덮어쓴다 — Codex 발주문에 그 애드온의 자동 업데이트를 끄라는 항목을 넣고, manifest 에 원본 판을 고정한다.
5. **새로 개발**: 그 기능이 요구를 끝내 못 채우는 부분만, 무엇이 왜 안 되는지 적은 뒤 그 부분만 만든다. 우리 구현이 더 나으면 유지하고 아니면 원래 것을 쓴다(R48).

### 기능 Phase 의 단계

- **판정(Step 8)**: `Collection/upstream/` 해제본에서 시작 애드온의 TOC·로드 순서·저장 변수·옵션을 정독하고, 요구(「늘 지킬 제약」, 위 기능 표의 「이 Phase 가 하는 일」)와 대조해 기능마다 「그대로 사용 / 설정 / 고침 / 새 개발」 을 판정해 manifest 에 적는다(R49·R87).
- **그대로 사용·설정 Phase (Step 하나)**: 설정 기본값 파일(Core 의 기본값 주입이 읽는다) → Core 등록 표에 저장 변수·편집 항목·외관 프레임 이름 적기 → manifest 갱신 → 정적 검사(Lua 문법·TOC/의존 대조) → Codex 실사용 검증 발주문과 Codex 외관 발주문 작성 → 설치용 ZIP 다시 빌드.
- **고침·새 개발이 있는 Phase**: 하위 Step 두 개(예: Step 13a 읽기·설계, 13b 수정·정적 검사·검수 B 논리 검수·발주문)로 늘리고 60–150분을 더한다. 뒤 번호는 밀지 않는다.

### 기능이 아닌 Phase

- **Phase 1 준비**: Step 8 은 `References/` 의 ZIP 을 읽기 전용으로 두고, 시작 애드온과 비교 대상 ZIP 을 스크립트로 `Collection/upstream/` 에 푼다(경로 검사·링크 차단·SHA256 대조). 풀면서 TOC·의존·저장 변수·라이브러리 판·라이선스 파일을 기계로 뽑아 manifest 초안을 만들고, 위 「판정」 을 한다. Step 9 는 `Collection/` 자리와 `.gitignore` 한 줄(해제본 제외), `lupa` 설치(Lua 5.1 문법 검사용), TOC/의존 대조와 묶음 빌드 스크립트. Step 10 은 Hekili 직업 모듈·FUF 원천으로 직업·특성·자원 표를 만든다.
- **Phase 2 공통 외관**: Claude 는 Step 11 에서 Core(등록 표·기본값 주입·테마 토큰과 프레임별 편집값 읽기 함수·외관 프레임 이름 목록)를 V42 !DevilUI 기전을 참고해 만들고, Step 12 에서 검수 B 반영 뒤 Codex 공통 외관 발주문을 쓴다. 외관 구현은 Codex 몫이다(R87). R63 의 「공통 외관 = 구현 1페이즈」 순서는 지킨다 — 외관이 기댈 인터페이스를 먼저 만든다.
- **Phase 23 연계**: 필수 묶음만 켠 상태, 전부 켠 상태, 개별 기능을 하나씩 뺀 상태를 TOC·의존·등록 표·저장 변수 이름으로 정적 대조하고, 같은 조합의 실제 로드는 Codex 발주문으로 넘긴다. 발견한 결함을 고친다.
- **Phase 24 최종 목업**: 모든 가능한 작업을 닫은 뒤(R55) Claude 가 Codex 목업 발주문을 쓴다: 4K 전체 화면, 하단 원배율 잘라 보기, 단축키 글자 확대, 직업별 자원 표시 예시, 데빌 기본 테마와 대안 테마 비교, 모든 그림에 「목업 — 실제 게임 화면 아님」. Codex 가 올린 목업을 Claude 가 Step 5 구획·표시 문구와 대조한 뒤 이 채팅에 제시한다(R46).
- **Phase 25 고정**: Codex 실사용 검증 결과에서 나온 코드 결함을 고치고, 최종 묶음 ZIP·manifest·복원 방법·남은 미검증 목록을 고정한다.

### Codex 외관 발주문 (R87)

외관은 Codex 가 만든다. Claude 는 외관이 기댈 코드 인터페이스를 먼저 만들고, 아래 때에 발주문(`Collection/codex-briefs/appearance-<ID>.md`)을 쓴다. Codex 결과는 `References/codex-appearance/<ID>/` 에 올라오고, Claude 는 `Collection/` 에 합치기 전에 토큰·프레임 이름·등록 표 사용이 인터페이스와 맞는지만 정적 대조한다.

| 때 | 발주문 내용 | Claude 가 먼저 줄 것 |
|---|---|---|
| Phase 2 끝 (Step 12) | 공통 외관: 패널·구분선·장식·글꼴·배치(Step 5 설계), 장식 입력 통과, 질감 판정·개선(R52) | 테마 토큰 목록, 프레임별 편집값 읽기 규약(외관 코드는 토큰 위에 이 값을 덮어 적용), 외관 프레임 이름 목록, 등록 규약, Step 5 설계·자산 manifest 위치, 빼야 할 V42 초기화 코드 목록 |
| 각 기능 Phase 끝 (Step 13–31) | 그 애드온의 외관 연결 폴더 `DevilForever_Skin_<애드온>`: 배치·크기·스킨·글꼴 | 그 애드온의 프레임 이름·스킨 API·설정 키 목록, 그 프레임의 편집 항목(편집값 읽기 규약대로 적용) |
| Phase 22 (Step 36) | 대안 테마 1–2개 | 토큰 세트를 바꿔 끼우는 인터페이스 |
| Phase 24 (Step 39) | 최종 목업 | 모든 기능의 manifest·토큰·테마 목록, 직업 자원 표 |

**Codex 몫 목록 (Claude 시간 합계에 넣지 않음)**: Phase 2 외관 구현과 질감 판정·개선, 각 기능의 외관 연결 폴더, Phase 15 기본 창 스킨의 외관 판정, Phase 22 대안 테마, Phase 24 최종 목업, 모든 Phase 의 실사용 검증(R86), 새 자료 조사(D7).

### Codex 실사용 검증 발주문 (R86)

- 이 세션(Claude)의 검증은 코드 작성 + 정적 검사(Lua 문법 검사·TOC/의존 대조) + 코드 논리 검수(검수 B)까지다. 게임 로드·전투·taint·저장·실제 화면은 Codex 가 사용자 PC 에서 한다.
- 각 기능 Phase 의 마지막 Step 이 그 Phase 의 발주문(`Collection/codex-briefs/phase<ID>.md`)을 쓴다. Codex 가 추가 판단 없이 그대로 실행할 수 있게 쓰고, 항목은 10개 이하, 항목마다 「하는 법 · 기대 결과 · 결과 한 줄 양식」 을 적는다. 결과를 올릴 자리는 `References/codex-verify/phase<ID>/` 다(결과 표·BugSack 오류 문구·필요하면 스크린샷).
- 발주문 맨 앞은 늘 같다: 게임 종료 → `_forever_/Interface/AddOns` 와 `_forever_/WTF` 백업 → 설치용 ZIP 풀기 → 게임 실행 후 BugSack 으로 Lua 오류 수집(D1).
- 첫 발주문(Phase 1)에는 현재 설치된 애드온 상태(R9), 클라이언트 판 번호, 실제 해상도와 UI scale, 직업 목록 확인, R13 retail 설정 참고 항목(D5)을 넣는다.
- 언제 묶어 보낼지는 D1 을 따른다. 사용자가 발주문을 Codex 에 넘기고, Codex 가 결과를 올리면 master 가 그 Phase 기록에 옮긴다. 결과를 기다리느라 다음 Phase 를 멈추지 않는다. 결과에서 나온 결함은 그 기능 Phase 가 진행 중이면 그 안에서, 끝났으면 Phase 23 또는 25 에서 고친다.

## Phase N — Phase 목록

세부 스텝 목록은 Phase 를 시작할 때 별도 파일 `Claude/plans/2026-11-18-devil-forever-addon-collection-phase<ID>-세부계획.md` 에 쓴다. 아래 경로는 아직 없는 파일이다. 선택 기능 Phase(12–19)는 D6 결정(R83)으로 확정돼 번호는 이 표 그대로다. Step 8 판정으로 「고침」 이 된 Phase 는 하위 Step(예: 13a·13b)을 붙이고 뒤 번호는 밀지 않는다.

| Phase | 세부 계획서 | Step | 상태 |
|---|---|---|---|
| 0 마스터 플랜 재수립 | `…-phase0-세부계획.md` | 1–7 | 진행 중 (1–5 Codex 완료 이력 · Step 6 끝 · Step 7 진행 중) |
| 1 준비 | `…-phase1-세부계획.md` | 8–10 | 대기 (GO 뒤) |
| 2 공통 외관 | `…-phase2-세부계획.md` | 11–12 | 대기 |
| 3 행동단축바 | `…-phase3-세부계획.md` | 13 | 대기 |
| 4 대화창 3개 | `…-phase4-세부계획.md` | 14 | 대기 |
| 5 미니맵 | `…-phase5-세부계획.md` | 15 | 대기 |
| 6 unit·직업 자원 | `…-phase6-세부계획.md` | 16 | 대기 |
| 7 시전바 | `…-phase7-세부계획.md` | 17 | 대기 |
| 8 직업 전투보조 | `…-phase8-세부계획.md` | 18–20 | 대기 |
| 9 공격대 | `…-phase9-세부계획.md` | 21 | 대기 |
| 10 데미지 미터 | `…-phase10-세부계획.md` | 22 | 대기 |
| 11 어그로 미터 | `…-phase11-세부계획.md` | 23 | 대기 |
| 12 툴팁 | `…-phase12-세부계획.md` | 24 | 대기 |
| 13 가방 | `…-phase13-세부계획.md` | 25 | 대기 |
| 14 이름표 | `…-phase14-세부계획.md` | 26 | 대기 |
| 15 기본 창 스킨 | `…-phase15-세부계획.md` | 27 | 대기 |
| 16 정보 바 | `…-phase16-세부계획.md` | 28 | 대기 |
| 17 퀘스트·목표 추적기 | `…-phase17-세부계획.md` | 29 | 대기 |
| 18 세계지도 | `…-phase18-세부계획.md` | 30a·30b | 대기 |
| 19 경험치·평판 바 | `…-phase19-세부계획.md` | 31 | 대기 |
| 20 저장·복원 | `…-phase20-세부계획.md` | 32–33 | 대기 |
| 21 사용자 편집 | `…-phase21-세부계획.md` | 34–35 | 대기 |
| 22 대안 테마 (외관은 Codex) | `…-phase22-세부계획.md` | 36 | 대기 |
| 23 연계 검사·정정 | `…-phase23-세부계획.md` | 37–38 | 대기 |
| 24 최종 목업 (제작은 Codex) | `…-phase24-세부계획.md` | 39 | 대기 |
| 25 Codex 검증 결과 반영·고정 | `…-phase25-세부계획.md` | 40–41 | 대기 |

`…` 는 `Claude/plans/2026-11-18-devil-forever-addon-collection` 이다. Phase 가 끝날 때마다 그 Phase 의 Result 를 `Claude/results/` 에 남기고, 끝난 Phase 정리는 `Claude/plans/2026-11-18-devil-forever-addon-collection-plan_이력.md` 로 옮긴다.

## Implementation Interfaces

| 연결 | 주는 쪽 → 받는 쪽 | 약속 |
|---|---|---|
| 원천 해제 | `References/**/*.zip` → Step 8 스크립트 → `Collection/upstream/` | ZIP 은 읽기만 한다. `SOURCE.txt` 의 SHA256 과 맞는지 먼저 보고, 경로 검사·링크 차단 뒤 푼다. 같은 ZIP 이면 같은 해제본이 나온다 |
| manifest | Step 8·각 Phase → `Collection/manifest.json` | 애드온마다 폴더·역할(필수/개별)·시작 애드온·원본 판·file ID·SHA256·라이선스 파일·고침 여부(설정/스킨/fork/새 개발)·의존·저장 변수 이름 |
| 등록 규약 (A1 제안) | 각 기능 Phase → `DevilForever_Core` 의 등록 표 | 애드온마다 ① 외관을 받을 프레임 이름 ② 편집 가능한 항목(종류·범위·기본값) ③ 저장·복원 대상 저장 변수 이름과 공통/직업별 구분 ④ 설정 기본값 파일 위치를 Core 의 등록 표(정적 데이터 · manifest 에서 만든다)에 적는다. Core 는 ④ 를 처음 로드 때 한 번 넣고 사용자가 바꾼 값은 덮어쓰지 않는다. 등록하려고 원본을 고치지 않고, 외관 연결 폴더(Codex)에도 기대지 않는다. Core 가 없으면 각 애드온은 자기 기본 동작·외관으로 동작한다 |
| 테마 토큰 | Phase 2 Core(Claude) → Codex 외관 코드 | 색·질감 경로·글꼴·테두리 두께를 이름 있는 토큰으로 주는 인터페이스, 토큰 위에 덮어쓰는 프레임별 편집값(Phase 21 이 저장한 위치·크기·글꼴·색·줄 수·간격)을 주는 읽기 함수, 토큰 세트를 바꿔 끼우는 함수(Phase 22). 외관 코드는 토큰과 편집값을 읽어 적용하고 값을 직접 박지 않는다 |
| Codex 외관 발주문 | 각 Phase → 사용자 → Codex → `References/codex-appearance/<ID>/` → Claude 정적 대조 → `Collection/` | Implementation Changes 「Codex 외관 발주문」 표의 때·내용 |
| 저장·복원 | 등록된 저장 변수 → Phase 20 | 등록된 변수만 사본·복원한다. 없는 애드온 항목은 남겨 둔다. 판이 다른 데이터는 사용자에게 알리고 건드리지 않는다 |
| 편집 | 등록된 편집 항목 → Phase 21 → Core 편집값 → Codex 외관 코드 | 미리보기 → 적용 → 취소/기본값. 저장한 값은 Core 가 프레임별 편집값으로 내준다. 전투 중에는 보호된 프레임을 바꾸지 않고 전투가 끝나면 적용한다 |
| 직업 목록 | Step 10 → Phase 3·6·8 | 직업·특성·주/보조 자원·특수 바를 원천 위치와 함께 적은 표. 근거 없는 칸은 미확인으로 둔다. Phase 8 은 이 표의 특성마다 감시 데이터·알림 꼴을 확인한다 |
| Codex 실사용 검증 | 각 Phase 발주문 → 사용자 → Codex → `References/codex-verify/phase<ID>/` → master | 항목 번호·결과(통과/실패/못 함)·실패 때 오류 문구 한 줄 |
| 설치용 ZIP | `Collection/tools/` 빌드 → `outputs/collection/DevilForever-<판>.zip` | `Interface/AddOns/` 아래 폴더 구조 그대로. manifest 와 SHA256 목록을 함께 넣는다. 고친 판은 라이선스와 관계없이 넣고(D4 결정 (나)), 고치지 않은 제3자 원본까지 함께 넣을지는 Phase 23 에서 정리한다 |
| 목업 입력 | Step 5 설계 + 실제 구현 토큰·자산 → Codex 목업 발주문(Phase 24) | 설계 좌표·실제 자산만 쓴다. 게임 캡처처럼 꾸미지 않는다 |

## Test Plan

### 검증 관점

이번 세션의 검수 강도는 Decisions Required 「예외」(R87)를 따른다: 원본 코드를 고친 곳·새 코드 = 같은 검수 B 가 코드 논리 검수 1회, 새 구조 모듈 = 3라운드, 그대로 쓰는 애드온 = 검수 없음(manifest·TOC 정적 대조만). 어느 대상도 10라운드를 넘지 않는다. 고정 5 프리셋: P1 코드, P3 설치기·도구, P4 시각, P5 일반 문서, P6 데이터. 고정 관점 ③ 은 새로 만든 것이면 「연결」, 고친 것이면 「연계」 다.

| 검증 대상 | 강도 | 프리셋 | 고정 ③ | 볼 것 (적대 항목 표시) |
|---|---|---|---|---|
| 이 마스터 플랜 (Step 6–7) | ③ 구조 10라운드 (Step 7 에서 진행) | P5 | 연결 | ① 사용자 원문 R1–R87 대조·누락 ② 사실/Codex 기록/A1 제안 구분 (적대: Codex 기록을 실측처럼 쓴 곳) ③ 기능 판정과 기본값 규칙 ④ Claude 몫과 Codex 몫(실사용 검증·외관)의 나눔 ⑤ 일정 합계와 Step 번호 정합 |
| 원천 해제·manifest·「쓰는 방식」 판정 (Step 8) | ④ 기계적 — 실행 게이트 + 판정 표 한 번 | P6 | 연결 | ① ZIP 과 SHA256 일치 ② 판·file ID 가 `SOURCE.txt` 와 같은지 ③ 안전 해제(경로·링크) ④ 라이선스 기록 ⑤ 「그대로 사용」 판정의 근거가 원천 정독에 있는지 (적대) |
| 정적 검사·빌드 도구 (Step 9) | 새 코드 — 코드 논리 검수 1회 | P3 | 연결 | 호출·데이터 흐름·입출력·nil 처리 + 적대: 정적 검사 통과를 게임 통과처럼 적는지 |
| 직업 목록 (Step 10) | 다음 단계가 쓰는 분석 표 — 기계 게이트 + 자체검수 1회 | P6 | 연결 | 원천 위치 표기, Retail 목록 섞임 (적대), 자원·특수 바 누락, 미확인 칸 |
| 새 구조 모듈: Core·등록 표·테마 토큰 인터페이스 (Phase 2) | 3라운드 (연계·뜻·적대) | P1 | 연결 | 등록 표가 manifest·TOC 와 맞는지, 토큰·프레임 이름 목록이 Codex 외관이 쓸 만큼 정해졌는지, Core 가 없을 때 각 애드온이 자기 기본으로 도는지, 기본값 주입이 사용자 값을 덮어쓰지 않는지, 편집값이 토큰 위에 맞게 덮이는지, 등록하려고 원본을 고치지 않았는지 (적대), V42 에서 빼기로 한 초기화 코드가 섞였는지 |
| 새 구조 모듈: Hekili 보완 모듈 (Phase 8, 갈래 2·3 일 때) | 3라운드 (연계·뜻·적대) | P1 | 연결 | Step 18 갈래 판정이 원천과 맞는지, EventAlert 식 알림 꼴과 끄기, 빈 칸은 「원천 없음」 표시 + D7 요청 기록이면 통과·지어낸 목록이면 실패, 추천·판단 로직이 없는지 (적대 · R62), Hekili 를 끄면 함께 꺼지는지 |
| 새 구조 모듈: 저장·복원 (Phase 20) | 3라운드 (연계·뜻·적대) | P1 | 연계 | 등록 표의 변수만 다루는지, 없는 애드온 항목 보존, 판이 다른 데이터를 지우는지 (적대), 공통/직업·특성별 나눔과 전환, 사용자가 고르지 않은 범위의 키·게임 설정·필터 불변·매크로 미접촉 |
| 새 코드·원본을 고친 곳: 편집 창·저장 (Phase 21, 새 개발), Mapster FogClear 고침 (Phase 18), 그 밖에 Step 8 뒤 「고침」·「새 개발」 로 판정된 기능 | 코드 논리 검수 1회 | P1 | 연결(새 코드) · 연계(고친 곳) | 호출·데이터 흐름·저장 변수·이벤트·nil 처리 + 적대 하나(편집은 전투 중 보호 프레임 변경) |
| 그대로 쓰는 기능의 설정 기본값 파일 (Phase 3–19) | 검수 없음 — manifest·TOC 정적 대조만 | P6 | 연계 | 기본값 키 이름이 원본 저장 변수와 맞는지, manifest·등록 표의 기본값 파일 위치(덮어쓰지 않는 주입은 Core 검수 몫) |
| 모음집 연계 (Phase 23) | 연계 정적 대조 + 정정분은 코드 논리 검수 1회 | P1 | 연계 | 조합별 TOC·의존 해석, 등록 누락, 의존 순서, 한 기능 두 애드온 중복 (적대), 설치용 ZIP 내용과 manifest 일치 |
| Codex 발주문 (실사용 검증·외관, 각 Phase) | ② 국소 — 같은 B 한 번 + 적대 하나 | P5 | 연결 | 백업이 맨 앞인지, 항목마다 기대 결과·결과 양식·올릴 자리, Codex 가 추가 판단 없이 실행할 수 있는지, 외관 발주문에 토큰·프레임 목록·Step 5 설계가 함께 가는지, 위험한 조작 요구 (적대) |
| Codex 가 올린 외관 코드·목업 (Phase 2·12–19·22·24) | 정적 대조만 (외관 판정은 Codex) | P4 | 연계 | 토큰·편집값을 읽어 적용하는지, 프레임 이름·등록 표를 인터페이스대로 쓰는지, 원본을 고쳤는지, 목업에 「목업 — 실제 게임 화면 아님」 표시와 Step 5 구획 |

갈래는 계획 때의 시작값이며 실제 diff 를 보고 무거운 쪽으로만 올리되 10라운드를 넘지 않는다. 실제 실행 확인은 Codex 실사용 검증 몫이다(R86).

### Phase 별 검증 나눔

| Phase | Claude 검증 (작성·정적 검사·코드 논리 검수) | Codex 실사용 검증 발주문의 핵심 | Codex 외관 발주문 |
|---|---|---|---|
| 1 | ZIP 해시·안전 해제, 판정 표, 도구 설치 확인, V42 애드온으로 문법 검사·TOC 대조 도구 시험 | 현재 애드온 상태, 클라이언트 판, 실제 해상도·UI scale, 직업 목록, R13 참고, BugSack 설치(D1) | 없음 |
| 2 | Core 문법·TOC/의존 대조, 등록 표·기본값 주입·토큰·편집값 읽기 3라운드 | Core 로드, 등록 표 반영, 기본값이 처음 한 번만 들어가는지, 재접속 뒤 유지 | 공통 외관 구현·질감(R52) |
| 3–7, 9–11 | 설정 기본값 파일·manifest·TOC 정적 대조(그대로 사용) | 각 기능 동작(키 글자·페이지·특수 바 / 입력·한글·세 창 분담 / 지도 클릭·핑 / 체력·자원·오라 / 시전·차단 / 클릭 시전·값 / 미터 값), 끄기, 재접속 | 각 기능 외관 연결 |
| 8 | 지원표·갈래 판정과 원천 대조, 보완 모듈이 있으면 3라운드 | 직업별 알림·추천 표시, 전투 중 taint 오류 | 표시 위치·크기·스킨 |
| 12–17, 19 | 설정 기본값 파일·manifest·TOC 정적 대조 | 그 기능의 표시·조작, 끄기, 재접속 | 각 기능 외관 연결 |
| 18 | FogClear 고침 코드 논리 검수 1회, 설정 기본값·TOC 정적 대조 | 애드온 목록에서 사용 가능 여부, 지도를 처음 열기 전 프로필을 바꿔도 오류 없음, 미탐색 영역·좌표, 끄기, 재접속, 자동 업데이트 끔 | 지도 외관 연결 |
| 20 | 3라운드 (가짜 데이터로 저장 변수 다루는 코드 논리) | 실제 저장·복원·재접속, 특성 전환 | 없음 |
| 21 | 코드 논리 검수 1회 | 편집·취소·되돌림, 전투 중 편집 | 편집 창 외관 |
| 22 | 토큰 세트 전환 인터페이스 정적 대조 | 테마 전환 뒤 화면 | 대안 테마 1–2개 |
| 23 | 조합별 TOC·의존·등록 표 정적 대조, ZIP·manifest 대조 | 전체 묶음 설치와 조합별 실제 로드 | 없음 |
| 24 | 받은 목업의 구획·표시 문구 대조 | 없음 (목업은 게임 검증이 아니다) | 최종 목업 |
| 25 | 정정분 정적 검사·논리 검수 | 고친 항목 재확인 | 필요하면 외관 정정 |

정적 검사와 코드 논리 검수의 통과는 게임 통과가 아니다. TOC 의 16001 표기도 「그 판에서 로드하겠다는 제작자 표기」 일 뿐이다. Codex 실사용 검증 결과가 올라오기 전까지 게임 동작은 미검증으로 적는다.

## Assumptions

| 전제 | 상태 · 다음 확인 |
|---|---|
| 받은 ZIP 이 공식 배포 파일 그대로다 | 해시·`unzip -t` 는 실측 통과(R81), 받은 URL 의 실재는 미검증(Codex 기록) |
| PyPI 에서 `lupa` 를 설치해 Lua 5.1 문법 검사를 돌릴 수 있다 | 미검증 → Step 9 |
| Forever 직업은 Hekili 모듈과 같은 9개다 | 추정(ZIP 모듈 폴더 수만 실측) → Step 10 과 Phase 1 Codex 발주문 |
| Hekili 가 R44 의 상태 알림·CD 를 맡을 수 있다 | 제작자 선언(focus·proc·CD 관련 옵션 — Codex 기록 `root-starting-addon-facts-and-r67.md:9`)만 있고 미검증. `features.md:158` 은 오라 감시·알림을 Hekili 유형으로 확정하지 않았다 → Step 18 의 두 확인(감시 데이터·알림 꼴) 뒤 Phase 8 기능 표의 갈래 1–3 중 하나로 간다 |
| Hekili Forever 가 모든 Forever 직업을 지원한다 | 근거 미발견. 제작자는 지원 특성만 ActionPack 을 둔다고 표기(Codex 기록 `root-starting-addon-facts-and-r67.md:9`) → Step 18 지원표. 감시 데이터가 없는 특성은 Phase 8 갈래 3 의 출구(D7 자료 또는 「원천 없음」)로 |
| ProfileManager 가 모음집 애드온들의 저장을 다룰 수 있다 | 미검증 → Step 32. 모자라면 그 부분만 새 개발 |
| 선택 기능 시작 애드온이 Masque·스킨 API 로 외관을 바꿀 수 있다 | 미검증 → Codex 외관 발주문 결과 |
| 「그대로 사용」 으로 추정한 기능이 실제로 고칠 필요가 없다 | 추정(R87) → Step 8 판정. 「고침」 이 되면 그 Phase 에 하위 Step 과 60–150분이 붙는다 |
| Codex 가 외관 발주문과 실사용 검증 발주문을 받아 결과를 `References/` 에 올려 준다 | R86·R87 · 시점은 D1 결정 |
| 사용자 화면 4K, UI scale 미상 | 4K 는 사용자 확정(R21), UI scale 은 미검증 → Phase 1 Codex 발주문 |
| 옛 원형 자산(Devil 테두리·Onyx·장식 그림)을 개인용 모음집에 써도 된다 | Onyx 라이선스는 개인 사용 허용·재배포 제한(Codex 기록 `devil-ui-old-4k-layout.md:101`), 나머지는 미검증. 라이선스 때문에 막지 않는다(D4 결정 (나) — 위험은 사용자 감수, R83). 내용은 Step 8 manifest 에 기록 |
| Codex 가 Phase 발주문을 사용자 PC 에서 돌려 결과를 올려 준다 | R86 · 시점은 D1 결정 |

## Correction History

Phase 0–1 의 고침 기록은 `Claude/plans/2026-11-18-devil-forever-addon-collection-plan_이력.md` 로 옮겼다. Phase 2 부터의 고침을 아래에 쌓는다.

| 날짜 | 반영 | 근거 |
|---|---|---|

## Decisions Required

사용자가 R83(「D4 만 나.  나머지는 전부 기본값.」)으로 D1–D7 을 모두 정했다. **남은 열린 질문은 없다.** 그 전에 이미 정해진 것(모음집·전 직업·Hekili 기반·공통 외관 먼저·기능마다 Phase·시작 애드온 수정 먼저·목업 마지막·시각 기준·원천은 사용자가 올린 ZIP)도 그대로다. 실행 중 새로 애매한 것이 생기면 합리적 기본값으로 진행하고 결정 대기에 적어 최종 보고에서 한 번에 묻는다.

**D1 — Codex 실사용 검증을 언제 돌릴지**
- 결정: (가)·(ㄱ) — 작업한 날마다 그날 끝난 Phase 의 Codex 실사용 검증 발주문을 한 묶음으로 넘겨 Codex 가 사용자 PC 에서 돌리고, 오류 수집 애드온(BugSack + BugGrabber, 둘 다 Forever 판 확인)을 검증용으로 함께 설치한다. 결과를 기다리느라 작업을 멈추지 않는다(R83 기본값 · R86 으로 검증하는 쪽이 Codex 로 바뀜).
- 근거: R46(출근 중 인게임 확인 불가), R86(실사용 검증은 Codex), 이 컨테이너는 게임 실행 불가.

**D2 — Hekili 표시 범위**
- 결정: (가) — 상태 알림·CD 와 다음 행동 추천을 모두 표시하고 추천은 따로 끌 수 있게 한다(R83). 상태 알림·CD 는 R44 에 따라 직업 전투보조(Phase 8)가 맡고, EventAlert 식(화면 중앙 아이콘·소리·강조, 각각 끌 수 있게)으로 보인다 — Hekili 에 그 꼴이 없으면 Phase 8 갈래 2 의 보완 모듈이 맡는다. Hekili 가 상태 알림을 어디까지 하는지는 미검증이다(Assumptions, Step 18).
- 근거: R6(「이벤트 얼럿을 품은 애드온」), R44(「두가지가 하나의 애드온으로 봐야지」), `root-starting-addon-facts-and-r67.md:9`(Codex 기록), `features.md:158`.

**D3 — 대화창 3개의 역할(채널 분담)**
- 결정: (가) — 왼쪽 첫 창 = 일반·거래·외치기 등 공개 채널, 왼쪽 둘째 = 길드·파티·공격대·귓속말, 오른쪽 = 전투·획득·시스템 메시지. 게임 안에서 사용자가 바꾸면 그 값을 유지한다(R83).
- 근거: R10(새 환경이라 지킬 기존 필터 없음), R23, R24.

**D4 — 고친 제3자 코드를 공개 저장소에 둘지**
- 결정: (나) — 라이선스와 관계없이 필요하면 어느 제품이든 원본을 고치고, 고친 판도 Phase 끝마다 main 에 그대로 공개한다. 라이선스 위험은 사용자가 감수한다(R83).
- 바뀌지 않는 것: 이 결정은 「라이선스 때문에 못 고치는 것」 을 없앨 뿐 원본을 더 많이 고치라는 뜻이 아니다. R63 「기존 것 수정 먼저·안 되는 것만 개발」 과 「시작 애드온을 고치는 방식」 1–4(설정·스킨·연결 폴더로 되면 원본을 고치지 않음)는 그대로다. 각 제품의 라이선스 내용은 Step 8 에서 읽어 manifest 에 기록한다(정보 기록용). 설치 ZIP 에 고치지 않은 제3자 원본까지 넣을지는 Phase 23 에서 정리한다.
- 근거: R67·R69(작업물 전부 main 공개), `root-starting-addon-facts-and-r67.md:7–8`(Codex 기록 — Details!·ForeverThreat All Rights Reserved), Ground Truth 「라이선스 파일」 실측, V42 kgPanels TOC 의 `X-License: All Rights Reserved`(실측).

**D5 — R13 retail 설정 참고 파일을 받을 방법**
- 결정: (가) — Phase 1 Codex 발주문에 「원하면 지정한 설정 파일 몇 개를 계정·캐릭터 이름을 지운 뒤 `References/retail-wtf/` 에 올리기」 를 선택 항목으로 넣는다. 올라오지 않으면 R13 은 대기로 두고 다른 작업은 막지 않는다(R83).
- 근거: R13, 이 컨테이너는 사용자 PC 를 읽을 수 없음.

**D6 — 기능 얼개: 선택 기능을 무엇까지 만들지**
- 결정: (가) — 선택 기능 Phase 12–19(툴팁·가방·이름표·기본 창 스킨·정보 바·퀘스트·목표 추적기·세계지도·경험치·평판 바)를 만들고, 편의 자동화·전리품 창과 제외 표·V42 분류 표의 제외 항목은 만들지 않는다(R83). Phase·Step 번호와 합계는 이 문서 그대로 확정이다.
- 근거: R77 원문, `References/addon-survey/features.md:241–286`, 기본값 규칙(「바꾼 곳과 이유」 5).

**D7 — Codex 조사 요청**
- 결정: (가) — 지금은 요청하지 않는다. Phase 가 실제로 막히면 그때 최종 보고에 복사해 쓸 수 있는 지시문으로 적는다(R83). 후보: ① V42 ChocolateBar 의 현재 Forever 판(정보 바 비교용) ② 버튼 위 CD 숫자(OmniCC 등)와 전투 문자 애드온의 Forever 판 ③ Forever 의 직업·특성 공식 목록 ④ 받은 71개 URL 의 실재 확인 ⑤ Phase 8 갈래 3 이 되면, 감시 데이터가 없는 특성의 Forever 주문·오라 자료(예: 공개 DB 페이지). 원천이 없어서 막힌 Phase 는 「원천이 모자랄 때」 규칙대로 순서만 미룬다.
- 근거: R80(새 자료는 Codex 에), 이 컨테이너는 외부 사이트를 열 수 없고 사용자 PC 연결도 없어 R31 의 Computer Use 다운로드도 지금은 쓸 수 없다.

### 예외 (R87 · 이번 세션 한정)

사용자 원문: 「검수 라운드지침은 이번 세션에 한해 니가 필요한만큼으로 수정해서 진행해 검수 방법은 너한테 일임한다. 대신 10라운드보다 무거워지면 안된다」(R87). 이번 세션에 한해 검수 강도는 master 가 대상마다 정하고, 상한은 10라운드다. master 기본 방식:
- 원본 코드를 고친 곳·새 코드 = 같은 검수 B 가 코드 논리 검수 1회(호출·데이터 흐름·저장 변수·이벤트·nil 처리 + 적대 항목 하나).
- 새 구조 모듈(Core 등록 규약·저장/복원·Hekili 보완 모듈)만 3라운드(연계·뜻·적대).
- 그대로 쓰는 애드온 = 검수 없음(manifest·TOC 정적 대조만).
Test Plan 「검증 관점」 표가 이 방식이다.

### 멈출 일 미리 점검

| 항목 | 기본 대책 (명시 GO = 이 대책 승인) |
|---|---|
| 새 의존성·설치 | 컨테이너에 PyPI `lupa`(Lua 5.1 문법 검사용)만 설치한다(렌더는 R87 로 Codex 몫). 게임 쪽 새 필수 의존(라이브러리 애드온)은 manifest 에 적고 시작 애드온이 원래 요구하는 것만 넣는다. 그 밖의 새 애드온은 결정 대기 |
| 네트워크·외부 호출 | 원천은 `References/` 의 ZIP 만 쓴다(R75·R81). 패키지 저장소 외 외부 호출 없음. 네트워크 허용 변경은 요청하지 않는다(R78·R79). 새 자료는 D7 대로 Codex 조사 요청으로 넘긴다 |
| 파괴·비가역 | 원본 ZIP·`References/`·`Codex/`·`work/`·`SourceArchive/`·`MacroLibrary/` 는 읽기만. 해제는 `Collection/upstream/` 에 새로 하고, 고친 애드온은 `Collection/` 에만 쓰며, 덮어쓰기 전 커밋으로 복원 지점을 둔다. 작업 중 정리 삭제 없음 |
| 권한 | 저장소 쓰기만 쓴다. 사용자 PC 쓰기(설치·검증)는 Codex 가 발주문대로 한다(백업 먼저 · R86) |
| 세션 전환 | 같은 Phase 안에서는 같은 작업 A·검수 B 를 다시 부른다. 세션을 넘길 때는 인계 문건과 커밋·push 를 먼저 한다 |
| 검증 미수렴 | 같은 B 재검증에서 중대·중간이 줄지 않으면 원인 수정으로 바꾸고, 끝내 남으면 그 산출은 고정하지 않고 최종 보고에서 묻는다 |
| 원래 있던 결함 | V42·옛 원천의 결함(예: 3461 의 없는 CAN_Chat.lua 참조, Codex 기록)은 고치지 않고 기록만 한다. 제3자 애드온의 라이선스 내용은 Step 8 manifest 에 기록만 하고(D4 결정 (나) — 위험은 사용자 감수, R83), 최종 보고에 목록으로 싣는다 |
| 푸시·외부 게시 | 스텝마다 작업 가지에 커밋하고, Phase 끝마다 작업 가지를 main 에 일반 반영한다(R67). 강제 push·이력 수정 없음. main 반영에는 고친 판도 라이선스와 관계없이 그대로 들어간다(D4 결정 (나), R83). 무엇을 고칠지는 「고치는 방식」 1–4 대로이고, Phase 23 은 설치 ZIP 에 넣을 범위만 정리한다 |
| 이 환경에서 실측 불가 | 게임 로드·전투·taint·저장·실제 4K 화면은 Codex 실사용 검증 발주문으로, 외관은 Codex 외관 발주문으로 넘기고(R86·R87), 결과가 올라오기 전까지 미검증으로 적는다. 정적 검사·논리 검수 통과를 게임 통과로 쓰지 않는다 |
| 모델 미가용 | 지정 모델·effort 서브를 쓸 수 없으면 다른 모델로 바꾸지 않고 멈춰서 알린다 |
| 원천 부족 (남은 예외) | 「원천이 모자랄 때」 규칙대로 그 Phase 만 미루고 D7 형식으로 요청을 적는다. R31 의 Computer Use 다운로드는 사용자 PC 가 이 세션에 연결된 경우에만 쓴다(지금은 연결 없음). 끝까지 없으면 그 Phase 는 「원천 없음」 으로 남기고 최종 보고에서 묻는다 |

지침 예외는 위 「예외 (R87 · 이번 세션 한정)」 하나뿐이다.

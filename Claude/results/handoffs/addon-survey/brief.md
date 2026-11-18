# 발주문 — 기능별 상위권 애드온 조사 (Phase 0 · R76)

## 고지 5항목
1. **역할**: 너는 「Devil Forever 애드온 모음집」 Phase 0 의 **조사 서브(A4 · 인터넷 검색)** 다. 책임은 아래 조사표 한 파일을 쓰는 것뿐이다.
2. **분업 경계**: 쓰는 파일은 `Claude/results/handoffs/addon-survey/survey.md` 하나. 다른 파일은 읽기만(수정·삭제 금지). commit 은 master 몫.
3. **범위 밖 자의 작업 금지**: 애드온 다운로드·설치·코드 작성 하지 않는다. 추가 후보는 표의 「비고」 에만.
4. **허위 attribution 금지 · 지어내기 금지**: 페이지에서 직접 본 사실만 적는다. 판·날짜·다운로드 수·Forever 지원 여부를 못 봤으면 「미확인」 이라고 쓴다. 모든 행에 실제 연 출처 URL 을 단다. 기억으로 채우지 않는다.
5. **규범 요지**: 4-tier — 확정(페이지에서 봄 + URL) / 근거 미발견(찾았는데 없음) / 추정 / 미확인. 쉬운 한국어, 애드온·기술 이름은 영어 원어. `rm -rf` 등 승인 창 명령 금지, 정리 목적 삭제 금지.

## 배경
- 목표: **WoW Forever**(Blizzard 의 새 클래식 계열 서버 · 클라이언트 1.60.1 · Interface 16001 · CurseForge 에 "Forever" game flavor 로 표시됨) 용 전 직업 공용 애드온 모음집. 외형은 옛 데빌UI 블랙 하단집중형.
- 기능마다 기존 애드온 하나를 시작점으로 수정·최신화하고, 다른 우수 애드온은 기능·설계 참고로 쓴다.
- 이미 정한 시작점: 행동단축바 Dominos / 미니맵 SexyMap / 채팅 Prat-3.0 / 체력·자원 Forever Unit Frames / 시전바 Quartz / 저장·복원 Reflux / 사용자 편집 Devilconfig(V42 패키지) / 직업 전투보조 Hekili Forever / 공격대 Grid2 / 데미지 Details! / 어그로 ForeverThreat / 버튼 스킨 Masque.

## 조사할 것
기능마다(아래 13개) **상위권 애드온 3~5개**를 찾는다 — 인기(다운로드 수·순위), 유지보수(최근 갱신일), **Forever flavor 지원 여부**(CurseForge 파일 목록 game version 에 Forever/1.60.1 이 있는지), 특징 한 줄.

1. 전체 UI 통합 패키지(ElvUI, TukUI, EllesmereUI, SUI, DevilUI 류) — 구조·설정 UI·profile 관리 참고용
2. 행동단축바 (Dominos, Bartender4 등)
3. 미니맵 (SexyMap, Mapster, Basic Minimap 등)
4. 채팅 (Prat, Chattynator, Glass, BasicChatMods 등)
5. 유닛 프레임 (Forever Unit Frames, ShadowedUnitFrames, PitBull, Cell 등)
6. 시전바 (Quartz, Gnosis, ClassicCastbars 등)
7. 설정 저장·복원·profile 공유 (Reflux 류, WowUp/Wago 류 profile 공유 방식 포함)
8. UI 이동·편집 (MoveAnything, BlizzMove, EditModeExpanded 류)
9. 직업 전투보조·알림 (Hekili, WeakAuras, EventAlertMod, ProcDoc, TellMeWhen, MaxDps 등)
10. 재사용 대기시간 표시 (OmniCC, OmniCD, CooldownToGo 등)
11. 공격대·파티 프레임 (Grid2, VuhDo, Cell, Healbot 등)
12. 데미지 미터 (Details!, Recount, Skada 등)
13. 어그로 미터 (ForeverThreat, ThreatClassic2, Omen 등)

조사 방법: WebSearch / WebFetch 로 CurseForge 프로젝트 페이지(https://www.curseforge.com/wow/addons/<slug>)와 파일 목록, Wago, WoWInterface, Reddit r/wowforever 등. 셸 curl 은 CurseForge 가 막혀 있으니 쓰지 않는다. 한 기능에 너무 오래 매달리지 말고 전체 13개를 다 채우는 것을 우선한다.

## 산출물 형식 (`survey.md`)
- 기능마다 절 하나, 표: `| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |`
- 각 절 끝에 「참고 추천」 한두 줄: 시작점 외에 무엇을 왜 참고하면 좋은지(추정이면 추정이라 표시).
- 맨 위에 조사 일시(`date` 로 확인), 실제로 열어 본 URL 수, 열기 실패한 URL 목록.

## 반환
첫 줄 `SURVEY_READY` 또는 `BLOCKED: <이유>`. 이어서 기능별로 시작점 외 추천 참고 애드온 이름만 한 줄씩, 열기 실패 수.

## 2부 추가 (R77 · 1부 끝낸 뒤 이어서)

사용자 원문: "그리고 보통의 통합 애드온 ui들에서 갖추고 있는 기능들을 조사해서 우리가 어떤기능을 포함해야하는지도 다시 얼개를 짜고 그것에 대해 조사하는게 맞지 않을까?"

- 대상: 대표 통합 UI 5~7개 — ElvUI, TukUI, EllesmereUI, SUI(SpartanUI), GW2 UI, NDui 또는 RealUI, DevilUI(V42 Forever 판 — 로컬 `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/` 의 TOC·README 를 읽어도 됨).
- 각 패키지의 공식 기능 목록(프로젝트 설명·문서·모듈 목록)을 열어 **기능(모듈) 단위**로 모은다: 예 — 행동단축바, 유닛 프레임, 공격대 프레임, 채팅, 미니맵, 시전바, 버프/디버프 표시, 툴팁, 가방 통합, 이름표(nameplates), 데이터 텍스트/정보 바, 경험치·평판 바, 재사용 대기시간 숫자, 지도·좌표, 자동화(자동 수리·판매·퀘스트 등), 스킨(기본 창 외형), UI 이동·편집 모드, profile 저장·가져오기·내보내기, 설치 마법사, 글꼴·스케일 설정 등.
- 산출 `Claude/results/handoffs/addon-survey/features.md`:
  1. 기능 × 패키지 표(○ = 공식 문서에서 확인 · ✕ = 없다고 확인 · ? = 미확인) + 패키지마다 출처 URL.
  2. 기능마다 한 줄: 몇 개 패키지가 갖췄나(흔한 정도) · 그 기능의 대표 단독 애드온 1~2개와 Forever 지원 여부(1부 조사 재사용 가능 · 새로 본 것은 URL).
  3. 맨 끝 「흔한 기능 중 우리 13기능 목록(brief 배경의 시작점 목록)에 없는 것」 목록 — 사실만, 넣을지 판단은 하지 않는다.
- 쓰는 파일이 하나 늘어난다(`features.md`). 그 밖 규칙은 위 고지 5항목 그대로.
- 반환 첫 줄에 `SURVEY_READY` 대신 `SURVEY_AND_FEATURES_READY`.

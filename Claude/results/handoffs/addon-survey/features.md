# 통합 애드온 UI 기능 조사표 (Phase 0 · R77 · 2부)

- 조사 일시: 2026-11-18 01:05 UTC (1부와 같은 세션)
- 열어 본 URL (본문 확인): **3** — https://github.com/tukui-org/ElvUI · https://github.com/siweia/NDui · https://github.com/Benik/BenikUI
- 열기 실패 URL:
  - https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/game/modules (HTTP 403)
  - https://github.com/Gordon-Kammerer/GW2_UI (HTTP 404 · 발주문 예시 아님, 저자가 짐작한 주소라 실제 저장소 주소가 아닐 수 있음)
  - https://github.com/SpartanUI/SpartanUI (HTTP 404 · 같은 사유)
  - 1부 실패 5건(curseforge·gamertagmythras·gfinityesports·warcraft.wiki.gg)은 재시도하지 않음
- 로컬 파일 확인: `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/` 의 `!DevilUI`, `Devilconfig` (TOC·Lua·README 일부 — 읽기만)
- 표기: ○ = 페이지 또는 로컬 파일에서 직접 확인 · ✕ = 없다고 확인 · ? = 미확인
- 주의: 이번 조사는 **패키지 공식 페이지 3곳 + 로컬 파일**뿐이다. TukUI · EllesmereUI · SUI · GW2 UI 는 열지 못해 전부 「?」다. ElvUI 의 모듈 목록은 페이지 본문이 짧아 확인하지 못했고(검색 요약에만 언급), 전부 「?」로 둔다.

## 1. 기능 × 패키지 표

| 기능 (모듈) | ElvUI | TukUI | EllesmereUI | SUI | GW2 UI | NDui | BenikUI (ElvUI 플러그인) | DevilUI (로컬) |
|---|---|---|---|---|---|---|---|---|
| 행동단축바 | ? | ? | ? | ? | ? | ? | ○ (레이아웃 3종) | ○ (Devilconfig 가 `/dom` 명령 호출 — 로컬 코드) |
| 유닛 프레임 | ? | ? | ? | ? | ? | ○ (oUF 파티·공격대·네임플레이트) | ○ (레이아웃 3종) | ? |
| 공격대·파티 프레임 | ? | ? | ? | ? | ? | ○ | ○ (파티 프로필) | ? |
| 채팅 | ? | ? | ? | ? | ? | ○ (스팸 필터·귓속말 초대만 확인 — 채팅창 교체는 미확인) | ○ (채팅 데이터텍스트 옆 버튼) | ? |
| 미니맵 | ? | ? | ? | ? | ? | ? | ? | ○ (`minimap.lua` 존재 — 로컬 파일) |
| 시전바 | ? | ? | ? | ? | ? | ? (FAQ 차단 색 언급만) | ? | ? |
| 버프·디버프 표시 | ? | ? | ? | ? | ? | ○ (오라 감시) | ? | ? |
| 툴팁 | ? | ? | ? | ? | ? | ? | ? | ? |
| 가방 통합 | ? | ? | ? | ? | ? | ○ (cargBags 기반 한 통) | ? | ? |
| 이름표 (nameplates) | ? | ? | ? | ? | ? | ○ (대상·마우스오버 강조) | ? | ? |
| 데이터 텍스트·정보 바 | ? | ? | ? | ? | ? | ○ (정보바: 자동 판매·수리·침공 타이머) | ○ (대시보드: ms·fps·가방·내구도·음량·화폐 등) | ? |
| 경험치·평판 바 | ? | ? | ? | ? | ? | ? | ○ (옆 퍼센트 알림기) | ? |
| 재사용 대기시간 숫자 | ? | ? | ? | ? | ? | ? | ? | ? |
| 지도·좌표 | ? | ? | ? | ? | ? | ? | ? | ? |
| 자동화 (자동 판매·수리 등) | ? | ? | ? | ? | ? | ○ (정보바 항목) | ? | ? |
| 스킨 (기본 창 외형) | ? | ? | ? | ? | ? | ○ (기본 UI 재스킨) | ○ (프레임 장식·그림자) | ? |
| UI 이동·편집 모드 | ? | ? | ? | ? | ? | ? | ? | ? |
| profile 저장·가져오기 | ? | ? | ? | ? | ? | ? | ? | ○ (Reflux·load_Profile 파일 — 로컬 파일) |
| 설치 마법사 | ? | ? | ? | ? | ? | ? | ○ (단계 건너뛰기 가능) | ? |
| 글꼴·스케일 설정 | ? | ? | ? | ? | ? | ? | ○ (기본 글꼴 교체) | ? |
| 인게임 설정 패널 | ? | ? | ? | ? | ? | ○ | ? | ○ (`/dom config`·Devilconfig 로컬) |
| 버프 외 AFK·비행 모드 | ? | ? | ? | ? | ? | ? | ○ | ? |

출처 URL (패키지마다):
- ElvUI: https://github.com/tukui-org/ElvUI (열었음 — README 「User Interface replacement AddOn」 한 줄뿐, 모듈 목록 없음)
- TukUI · EllesmereUI · SUI · GW2 UI: 미확인 (열지 못함)
- NDui: https://github.com/siweia/NDui (열었음 — README 기능 목록. WebFetch 요약이라 원문 문구는 인용부호 표기)
- BenikUI: https://github.com/Benik/BenikUI (열었음 — 페이지 기능 목록. ElvUI 의 플러그인이라 독립 패키지가 아님)
- DevilUI: 로컬 파일 `!DevilUI/!DevilUI.toc`, `Devilconfig/Devilconfig.toc`, `Devilconfig/_Devilconfig.lua`, `Devilconfig/README_Forever_v7_koKR.txt` (외부 URL 아님)

## 2. 기능마다 한 줄

- **행동단축바**: 본 패키지 중 3곳에서 확인(BenikUI 레이아웃, DevilUI 의 Dominos 호출). 대표 단독 애드온 Dominos(1부 시작점) — Forever 지원 **미확인**(1부 열기 실패). Bartender4 — 미확인.
- **유닛 프레임**: 확인 2곳(NDui, BenikUI). 대표 단독 애드온 PitBull4(로컬 `PitBull4` 폴더 있음 — DevilUI 세트에 포함, Forever 지원 미확인), ShadowedUnitFrames — 미확인.
- **공격대·파티 프레임**: 확인 2곳(NDui, BenikUI). 대표 단독 Grid2(시작점) · Cell — Forever 지원 미확인(1부 열기 실패).
- **채팅**: 확인 2곳이나 NDui 는 스팸 필터 수준. 대표 단독 Prat-3.0(시작점) · Chattynator — 미확인.
- **미니맵**: 확인 1곳(DevilUI 로컬). 대표 단독 SexyMap(시작점) · Mapster(로컬 `Mapster` 폴더 있음) — Forever 지원 미확인.
- **시전바**: 확인 0곳(NDui 는 차단 색 언급만). 대표 단독 Quartz(시작점) · Castbars(로컬 `Castbars` 폴더 있음) — 미확인.
- **버프·디버프 표시**: 확인 1곳(NDui). 대표 단독 WeakAuras — 미확인.
- **툴팁**: 확인 0곳. 대표 단독 TipTac(로컬 `TipTac` 폴더 있음) — 미확인.
- **가방 통합**: 확인 1곳(NDui). 대표 단독 Bagnon/Baganator — 미확인(발주문·1부 조사 범위 밖, 새로 찾지 않음).
- **이름표**: 확인 1곳(NDui). 대표 단독 — 미확인(이번 조사에서 단독 애드온 미조사).
- **데이터 텍스트·정보 바**: 확인 2곳(NDui, BenikUI). 대표 단독 Broker 계열(로컬 `Broker_XPBar`·`Broker_Money`·`Broker_Guild_Friends`·`ChocolateBar` 폴더 있음) — Forever 지원 미확인.
- **경험치·평판 바**: 확인 1곳(BenikUI). 대표 단독 — 미확인.
- **재사용 대기시간 숫자**: 확인 0곳. 대표 단독 OmniCC · OmniCD(발주문 10번) — 미확인, 이번 조사에서 열지 않음.
- **지도·좌표**: 확인 0곳. 단독 대표 — 미확인.
- **자동화(자동 판매·수리)**: 확인 1곳(NDui). 대표 단독 — 미확인.
- **스킨(외형)**: 확인 2곳(NDui, BenikUI). 대표 단독 Masque(시작점, 로컬 `Masque`·`Masque_Dominos`·`Masque_Onyx` 폴더 있음) — Forever 지원 미확인.
- **UI 이동·편집**: 확인 0곳. 대표 단독 MoveAnything · BlizzMove · EditModeExpanded(발주문 8번) — 미확인.
- **profile 저장·가져오기**: 확인 1곳(DevilUI 로컬). 대표 단독 Reflux(시작점, 로컬 `Reflux` 있음) — Forever 지원 미확인.
- **설치 마법사**: 확인 1곳(BenikUI). 단독 대표 — 미확인.
- **글꼴·스케일**: 확인 1곳(BenikUI). 단독 대표 — 미확인.
- **인게임 설정 패널**: 확인 2곳(NDui, DevilUI 로컬 Devilconfig). 단독 대표 Devilconfig(시작점 · 로컬 V42) — Forever 지원: 로컬 TOC 에 `## Interface: 16001` 확인(로컬 파일 사실).

## 3. 흔한 기능 중 우리 13기능 목록에 없는 것 (사실만 — 넣을지는 판단하지 않음)

발주문 배경의 시작점 목록: 행동단축바 · 미니맵 · 채팅 · 체력·자원(유닛 프레임) · 시전바 · 저장·복원 · 사용자 편집 · 직업 전투보조 · 공격대 · 데미지 · 어그로 · 버튼 스킨(Masque). 이 목록에 없고 이번 조사에서 2곳 이상 확인된 기능:

- 데이터 텍스트·정보 바 (NDui, BenikUI)
- 가방 통합 (NDui 확인 · 1곳)
- 이름표 nameplates (NDui 확인 · 1곳)
- 툴팁 (확인 0곳 — 목록 밖이지만 발주문 예시 기능)
- 버프·디버프 표시 (NDui 확인 · 1곳 — 직업 전투보조와 겹칠 수 있음)
- 설치 마법사 (BenikUI 확인 · 1곳)
- 글꼴·스케일 설정 (BenikUI 확인 · 1곳)
- 경험치·평판 바 (BenikUI 확인 · 1곳)
- 자동화(자동 판매·수리) (NDui 확인 · 1곳)
- 재사용 대기시간 숫자 · 지도·좌표 · UI 이동·편집 (발주문 예시로 나왔으나 이번 조사에서 확인 0곳)
- 인게임 설정 패널 (NDui · DevilUI 로컬 — 시작점 Devilconfig 가 이미 이 역할)

## 미완 항목

1. TukUI · EllesmereUI · SUI · GW2 UI 의 기능 목록은 전부 「?」. 세션 네트워크 허용 도메인 추가 후 재조사 필요.
2. ElvUI 모듈 목록 미확인 — 공식 설정 메뉴 또는 프로젝트 문서 확인 필요.
3. 1부와 2부 모두 Forever 지원 여부는 페이지에서 확인하지 못했다.

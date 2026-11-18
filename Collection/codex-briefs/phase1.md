# Codex 실사용 검증 발주문 — Phase 1 (준비 · 현재 상태 확인)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 이 발주문은 추가 판단 없이 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 아래의 게임 안 동작은 모두 사람이 하듯 직접 한다.

- 결과를 올릴 자리: `References/codex-verify/phase1/` (저장소)
- 결과 표 파일: `References/codex-verify/phase1/result.md` — 항목마다 아래 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 늘 `통과` / `실패` / `못 함` 중 하나다. 실패면 마지막 칸에 오류 문구 한 줄.
- 이번 Phase 에는 설치용 ZIP 이 아직 없다. 그래서 「ZIP 풀기」 단계는 없다.

## 0. 시작 (늘 같음)

- 하는 법:
  1. 게임을 완전히 종료한다(런처까지 닫음).
  2. 게임 설치 폴더의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사해 둔다. 폴더 이름 예: `forever_backup_20261118/AddOns`, `forever_backup_20261118/WTF`.
  3. 복사본의 폴더 수·파일 수가 원래와 같은지 본다.
- 기대 결과: 두 백업 폴더가 원래와 같은 폴더 수·파일 수로 생긴다. 이것이 끝나기 전에는 아래 항목을 하지 않는다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | AddOns 폴더 수=<n> | WTF 파일 수=<n>`

## 1. 지금 설치된 애드온 목록 (R9)

- 하는 법: `_forever_/Interface/AddOns` 안의 폴더 이름을 모두 텍스트 파일 `References/codex-verify/phase1/addons.txt` 에 한 줄에 하나씩 적는다(Windows 명령 창이면 그 폴더에서 `dir /b /ad > addons.txt`). 그다음 게임을 켜고 캐릭터 선택 화면의 「애드온」 창을 열어, 목록에서 꺼져 있거나 「오래된 애드온」 으로 표시된 이름을 같은 파일 끝에 `[꺼짐]`·`[오래됨]` 표시와 함께 덧붙인다. 아무것도 지우거나 끄지 않는다 — 사용자가 직접 정리한다.
- 기대 결과: 목록 파일이 생긴다. 사용자가 정리 중이라 무엇이 남아 있든 그대로 적으면 통과다.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 폴더 수=<n> | 꺼짐=<n> | 오래됨=<n> | 목록=References/codex-verify/phase1/addons.txt`

## 2. 클라이언트 판 번호

- 하는 법: 캐릭터로 접속한 뒤 대화 입력창에 `/run print(GetBuildInfo())` 를 직접 쳐서 나온 네 값을 그대로 옮겨 적는다(판, 빌드 번호, 날짜, Interface 번호).
- 기대 결과: 판은 `1.60.1`, 빌드는 `70938` 이었다는 앞선 기록이 있다. Interface 번호는 `16001` 이어야 한다. 다르면 다른 값 그대로 적는다(실패가 아니라 기록).

결과 한 줄 양식: `2 | <통과/실패/못 함> | 판=<값> | 빌드=<값> | 날짜=<값> | Interface=<값>`

## 3. 실제 해상도와 UI scale

- 하는 법: 같은 캐릭터로 대화 입력창에 다음을 직접 친다.
  `/run print(GetPhysicalScreenSize()); print(GetScreenWidth(), GetScreenHeight()); print(GetCVar("useUiScale"), GetCVar("uiScale"), UIParent:GetEffectiveScale())`
  그리고 게임 메뉴 → 설정 → 그래픽에서 「해상도」 와 「창 모드」 값을, 인터페이스(또는 그래픽) 설정에서 「UI 배율」 사용 여부와 값을 읽는다.
- 기대 결과: 물리 해상도 `3840 2160`(사용자 화면 4K, R21). UI scale 은 알려진 값이 없다 — 나온 값 그대로 적으면 통과.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 물리 해상도=<w>x<h> | 화면 단위=<w>x<h> | useUiScale=<0/1> | uiScale=<값> | 실효 배율=<값> | 창 모드=<전체/창/전체 창>`

## 4. 직업·특성 목록이 `Collection/data/classes.md` 와 맞는지

- 하는 법: 저장소의 `Collection/data/classes.md` 「직업별 표」 를 연다. 게임의 캐릭터 만들기 화면에서 고를 수 있는 직업을 모두 적고 표의 9개(WARRIOR·PALADIN·HUNTER·ROGUE·PRIEST·SHAMAN·MAGE·WARLOCK·DRUID)와 비교한다(캐릭터는 만들지 않고 화면만 본다). 이미 있는 캐릭터가 있으면 그 캐릭터의 특성 창을 열어 특성 나무 세 개의 이름을 적고 표의 특성 이름과 비교한다. 드루이드가 있으면 「야성」 나무 하나에 표의 feral·guardian 두 특성이 함께 드는지 본다.
- 기대 결과: 직업 9개가 표와 같다. 특성 나무는 직업마다 3개.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 게임 직업 수=<n> | 표에 없는 직업=<이름 또는 없음> | 게임에 없는 표 직업=<이름 또는 없음> | 특성 확인한 직업=<목록> | 특성 이름이 다른 곳=<직업:나무 또는 없음>`

## 5. 오류 수집 애드온 BugSack·BugGrabber 설치 (D1 ㄱ)

- 하는 법: 게임을 종료한다. 저장소의 `References/addon-sources/bugsack/` 와 `References/addon-sources/bug-grabber/` 에 있는 ZIP(BugSack v12.1.9, BugGrabber v12.1.1)을 풀어 나온 `BugSack` 과 `!BugGrabber` 폴더를 `_forever_/Interface/AddOns` 에 넣는다. 같은 이름 폴더가 이미 있으면 덮지 말고 그 판 번호를 적은 뒤 그대로 둔다. 게임을 켜고 애드온 창에서 둘이 켜져 있는지 본 뒤 접속해 대화 입력창에 `/bugsack` 을 직접 친다.
- 기대 결과: 두 애드온이 「사용 가능」 이고, `/bugsack` 으로 BugSack 창이 열린다. 접속 직후 잡힌 오류가 있으면 그 문구를 `References/codex-verify/phase1/bugsack.txt` 에 그대로 복사한다(오류가 있어도 이 항목은 설치가 됐으면 통과).

결과 한 줄 양식: `5 | <통과/실패/못 함> | BugSack=<사용 가능/오래됨/안 보임> | BugGrabber=<사용 가능/오래됨/안 보임> | 창 열림=<예/아니오> | 접속 때 오류 수=<n>`

## 6. 받은 시작 애드온 넷이 「사용 가능」 으로 뜨는지 (TOC 로드 조건 확인)

- 하는 법: 게임을 종료한다. 저장소 `References/addon-sources/tiptac-reborn/`·`References/addon-sources/kaliels-tracker/`·`References/addon-sources/mapster/`·`References/forever-addons/Details/` 의 ZIP 을 풀어 나온 폴더를 모두 `_forever_/Interface/AddOns` 에 넣는다(TipTac 은 4폴더, Details 는 8폴더). 같은 이름 폴더가 이미 있으면 덮지 말고 그 판 번호만 적은 뒤 그대로 둔다. 게임을 켜고 캐릭터 선택 화면의 애드온 창에서 TipTac·Kaliel's Tracker·Details·Mapster 가 어떻게 표시되는지 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 BugSack 창(`/bugsack`)에 이 넷의 오류가 있으면 문구를 `References/codex-verify/phase1/bugsack.txt` 에 덧붙인다.
- 기대 결과: 넷 다 「사용 가능」(오래된 애드온·의존 없음 표시가 없음). 하나라도 다르면 두 번째 칸은 `실패` 로 하고, 그 애드온 칸에 화면에 뜬 표시 문구를 그대로 적는다.

결과 한 줄 양식: `6 | <통과/실패/못 함> | TipTac=<사용 가능/오래됨/의존 없음/안 보임> | KalielsTracker=<…> | Details=<…> | Mapster=<…> | 이 넷의 오류 수=<n>`

## 7. (선택) 본서버 retail 설정 파일 올리기 (R13 · D5 가)

- 하는 법: 사용자가 원할 때만 한다. 본서버의 `_retail_/WTF` 에서 애드온·인터페이스 설정 파일 몇 개(예: `Account/<계정>/SavedVariables/` 안의 애드온별 `.lua`, `Config.wtf`)를 골라 복사한다. 매크로 파일(`macros-cache.txt`, `macros-local.txt` 등)은 넣지 않는다. 복사본에서 계정 이름·캐릭터 이름·서버 이름을 모두 `ACCOUNT`·`CHAR`·`REALM` 같은 자리 표시로 바꾼 뒤(파일 이름과 폴더 이름도) `References/retail-wtf/` 에 올린다. 원본 `_retail_/WTF` 는 건드리지 않는다.
- 기대 결과: 사용자가 원하면 지운 이름이 남아 있지 않은 사본이 올라온다. 원하지 않으면 `못 함` 이 아니라 `통과 | 안 함` 으로 적는다.

결과 한 줄 양식: `7 | <통과/실패/못 함> | <올림/안 함> | 파일 수=<n> | 이름 지움 확인=<예/아니오>`

## 8. 결과 올리기

- 하는 법: 위 0–7 의 결과 줄을 `References/codex-verify/phase1/result.md` 에 순서대로 적고, `addons.txt`, (있으면) `bugsack.txt`, 필요하면 화면 갈무리(애드온 창·설정 창)를 같은 폴더에 넣어 저장소에 올린다. 게임 설정을 바꿨다면(5·6번 설치 말고) 무엇을 바꿨는지 한 줄로 덧붙인다.
- 기대 결과: `References/codex-verify/phase1/` 에 `result.md` 와 `addons.txt` 가 있다.

결과 한 줄 양식: `8 | <통과/실패/못 함> | 올린 파일=<목록> | 커밋=<해시>`

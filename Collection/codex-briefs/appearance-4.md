# Codex 외관 발주문 — Phase 4 (대화창 3개 · Prat-3.0 3.9.117)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/4/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `2460bd1de6dd86f71dc15f7a990144fe2a45b7da2561eb88dd0a7fcbe5ef9df4`, `!DevilForever_Core` + `DevilForever_ChatSetup`) + Prat 원본 `References/forever-addons/Prat-3.0/Prat-3.0-3.9.117.zip`. Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.

## 1. 만들 것

- 대화창 세 개의 반투명 배경·얇은 구분선, 버튼·탭·입력 테두리·글꼴(R23·R24 — 제목바·왼쪽 버튼·튀어나온 입력창 없는 깔끔한 채팅). Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md:47–51`): 왼쪽 첫 창 `0,1820` 960×304, 왼쪽 둘째 `962,1820` 960×304, 오른쪽 셋째 `2902,1820` 938×304. 셋째 자리는 대화창이다 — 미터기(Phase 10)를 두지 않는다(R33).
- 채널 분담은 Claude 몫이고 이미 들어 있다: `DevilForever_ChatSetup` 이 캐릭터의 첫 접속에 한 번만 창 둘을 새로 만든다(첫 창 = `ChatFrame1` 공개 채널, 둘째 = 길드·파티·공격대·인스턴스·귓속말, 셋째 = 시스템·오류·경험치·명예·평판·숙련·전리품·돈·화폐). 어느 `ChatFrame<n>` 이 둘째·셋째인지는 캐릭터마다 저장 변수 `DevilForever_ChatSetupDB.windows`(`public`·`group`·`system` = 창 번호)에 있다. 외관 코드는 그 번호로 창을 찾고, 메시지 그룹·채널을 바꾸지 않는다.
- 창을 만들 때 넣는 자리는 임시 값이다(첫 창 오른쪽 40px 옆, 오른쪽 끝 8px 안, 첫 창 크기). 최종 자리·크기는 아래 3절의 조각 파일로 낸다.

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음 · Prat-3.0 항목)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `prat.chatframe1` … `prat.chatframe10` | `ChatFrame1` … `ChatFrame10` | 없음 (Phase 21 에서 정함) |
| `prat.editbox1` … `prat.editbox10` | `ChatFrame1EditBox` … `ChatFrame10EditBox` | 없음 |
| `prat.tab1` … `prat.tab10` | `ChatFrame1Tab` … `ChatFrame10Tab` | 없음 |

`ChatFrame2` 는 전투 기록 창이다(손대지 않음). 목록은 Prat 이 다루는 창 열 개다(`Prat-3.0/addon/addon.lua:78–89`). `tokens` 칸은 비어 있다 — 필요한 토큰 연결은 조각 파일로 제안한다.

## 3. 값을 어디에 두나

- Prat 자체 외관 설정이 곧 스킨 수단이다: Buttons(`modules/Buttons.lua:174–271, 353–441`), ChatTabs(`ChatTabs.lua:350–441, 586–594`, 기본 꺼짐), Editbox(`Editbox.lua:204–230` 기본값, `334–440`), Font(`Font.lua:235–281`), Frames(`ChatFrames.lua:286–327`). 이 값은 `Prat3DB.namespaces["Prat_<모듈>"].profiles.Default` 에 있다. 쓸 값은 **값 제안 파일** `prat-profile.fragment.lua`(Lua 표 하나, `{Prat_Buttons = {...}, Prat_Editbox = {...}, …}` 꼴, Prat 키 이름 그대로)로 낸다. Claude 가 `Defaults/Prat-3.0.lua` 에 넣는다(처음 한 번, 사용자 값 우선). 모듈 켜기·끄기를 바꾸려면 `on` 을 조각에 넣고 report.md 에 이유를 적는다. History·Memory 의 값은 바꾸지 않는다(Claude 기능 기본값).
- 창 세 개의 자리·크기는 **`chat-windows.fragment.lua`**(`{public = {point, x, y, width, height}, group = {…}, system = {…}}`, UIParent 기준)로 낸다. Claude 가 `DevilForever_ChatSetup` 의 첫 접속 배치에 넣는다 — 실행 중 외관 코드가 창을 옮기지 않는다(사용자가 옮긴 자리를 덮지 않게).
- 입력창의 Enter·한글 입력·화살표 동작은 바꾸지 않는다. 입력 투명도·마우스를 숨기는 설정을 쓰면 report.md 에 적는다.

## 4. 올릴 것 (`References/codex-appearance/4/`)

- 새 폴더 `AddOns/DevilForever_Skin_Prat/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, Prat-3.0`) — 배경·구분선 같은 Prat 설정에 없는 부분만, `prat-profile.fragment.lua`, `chat-windows.fragment.lua`, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(창→역할 대응, 고른 값, 4K 게임 화면 갈무리 경로, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + Prat 파일 수정 0 + 메시지 그룹·채널 변경 0.

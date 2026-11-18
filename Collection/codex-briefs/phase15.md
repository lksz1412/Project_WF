# Codex 실사용 검증 발주문 — Phase 15 (기본 창 스킨 · Aurora 12.1.5.4 사용 판정)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/aurora` 입력은 모두 사람이 하듯 직접 한다. 기본 창의 질감·글꼴·색을 어떻게 맞출지는 이 Phase 에서 정하지 않는다(외관 단계 몫 — `appearance-15.md`).

- 결과를 올릴 자리: `References/codex-verify/phase15/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄. 2번의 창 표는 `windows.md`, 3번의 옵션 출력은 `options.txt`, 4·5번의 겹침 표는 `overlap.md`, 8번의 판정은 `decision.md`, 오류 문구는 `bugsack.txt` 에 따로 둔다.
- 이 Phase 가 정하는 것: **Aurora 를 모음집에 쓸지 말지를 Codex 가 정한다**(R107 ④ 「외향은 코덱스로 넘겨. 오로라는 그치가 결정하게 넘겨.」). 애드온은 적을수록 좋다(R101) — 게임 기본 창 그대로도 되면 애드온을 하나 더 넣지 않는 쪽이 먼저다. 지금 모음집 묶음에는 Aurora 가 없다. 쓰기로 하면 Claude 가 나중에 등록한다.
- 설치 ZIP (sha256 은 0번에서 모두 본다):
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef` (안에는 `Interface/AddOns/!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문은 `!DevilForever_Core` 를 늘 넣고, `PitBull4` 는 4번에서만 넣는다).
  - Aurora 원본 `References/addon-sources/aurora/Aurora-12.1.5.4.zip`, sha256 `bd8b36a06ba2b5d2e6621aafa607c4c7ec856c9e001cd678e33035f61acacf3c` (`References/addon-sources/aurora/SOURCE.txt:7`). 안의 `Aurora` 폴더 하나. 설정 창은 Aurora 안에 들어 있고 따로 된 설정 애드온 폴더는 없다(TOC 는 `Aurora/Aurora.toc` 하나).
  - 4번에서만: Prat `References/forever-addons/Prat-3.0/Prat-3.0-3.9.117.zip`(sha256 `d72baef9c99bb1583b269abd85088bcb957d9a0d8ca57c323144442875084db1`, `Prat-3.0`), Details `References/forever-addons/Details/Details-Details.20261109.15410.172.zip`(sha256 `5002bdd5c3e92dd59bffa3ebdfc867f980b09ed629c51dab056fb5442f92ad41`, `Details`·`Details_TinyThreat`), Grid2 `References/forever-addons/Grid2/Grid2-4.1.13-forever.zip`(sha256 `f198bc3ce2d02e023f81052074a2e9aa4ba41819931bd302ff7429dac9515393`, `Grid2`·`Grid2Options`·`Grid2LDB`), Dominos `References/forever-addons/Dominos/Dominos-12.0.4.zip`(sha256 `2dbcf9857a91b772a42200369386fc17f875530ffd47984b555ecdb8e11bef1a`, `Dominos`·`Dominos_Config`), SexyMap `References/forever-addons/SexyMap/SexyMap-v12.1.7.zip`(sha256 `1868eb714b8c9ea4efaa615109bfd457a0c3bb625f0b2a1f1befdadfc9143321`, `SexyMap`), Quartz `References/forever-addons/Quartz/Quartz-3.8.0.zip`(sha256 `2a76cdda6b53e7eb26472c0b8b6bf8f50c02388f8f515e6746c5e14657d5ed70`, `Quartz`), FUF `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`(sha256 `cc50d16b5d926240a4dc48e7e6f9e4ee7fbb5107c14ebb734a685542e50e1a80`, `ForeverUnitFrames`), Hekili `References/forever-addons/Hekili/Hekili-v0.8.6-forever.zip`(sha256 `8063fd78c988af76c6a74653c21ff9f268546c44320922688ea2f7dd3d4c45e3`, 안의 열한 폴더 모두).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- Claude 가 Aurora 코드에서 읽은 것(게임에서 확인 안 됨 — 아래 항목이 그것을 본다): Aurora 는 이 클라이언트를 「Forever(Camelot)」 로 알아보고 Forever 용 스킨 목록만 불러온다(`Aurora/Aurora.toc:1,36`, `Aurora/Skin/init.lua:17`). 처음 켤 때 안내 창을 띄우고(`Aurora/aurora.lua:327–329`), 접속·`/reload` 때마다 CVar `questTextContrast` 를 4 로 바꾼다(`Aurora/Skin/init.lua:342–344`). 게임 전체의 Lua 메모리 정리 방식(GC)을 바꾸고(`Aurora/Skin/init.lua:198–266`), 5분마다 메모리 전체 정리를 한 번 돌린다(`Aurora/integration.lua:479–480,322`). UI scale 은 바꾸지 않는다(`Aurora/Skin/init.lua:56,70` — 기본 꺼짐).

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase15/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 위 ZIP 열 개의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에서 `BugSack`·`!BugGrabber` 를 뺀 모든 애드온 폴더를 백업과 다른 폴더 `forever_moved_phase15/AddOns` 로 옮긴다(스킨을 바꾸는 애드온이 섞이지 않게 — 지우지 않는다. 백업 폴더에는 아무것도 더 넣지 않는다). 그 뒤 모음집 ZIP 의 `!DevilForever_Core` 와 Aurora ZIP 의 `Aurora` 두 폴더만 넣는다. BugSack·!BugGrabber 가 켜져 있는지 본다. `_forever_/WTF/Config.wtf` 를 따로 한 부 더 복사해 둔다(7번에서 비교한다).
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 모두 같고, AddOns 에 `!DevilForever_Core`·`Aurora`·`BugSack`·`!BugGrabber` 넷만 있다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치=<10개 중 n개 · 다른 것=<이름/없음>> | 옮긴 애드온 수=<n>(옮긴 곳=<경로>) | AddOns 남은 폴더=<목록> | Config.wtf 사본=<경로> | BugSack 켜짐=<예/아니오>`

## 1. 로드 — Aurora 끈 상태의 원래 값, 켠 뒤 로드

- 하는 법: (가) 캐릭터 선택 화면 애드온 창에서 **Aurora 를 끄고**(「오래된 애드온 불러오기」 는 켜지 않는다) 접속한다. 아래 첫 줄을 쳐서 원래 값을 적는다(8·9번에서 이 값과 비교한다). 이어서 둘째 줄을 쳐서 `questTextContrast` 의 게임 기본값을 적는다(`없음` 이 나오면 이 클라이언트에 `GetCVarDefault` 가 없거나 기본값을 주지 않는 것). 2번에서 볼 일곱 창(캐릭터 창·주문책·가방·퀘스트 목록·지도·설정 창·화면 오른쪽 위 버프 아이콘)을 하나씩 열어 갈무리를 남긴다(이름 `before_<창>.png`). (나) 캐릭터 선택으로 나가 Aurora 를 켜고 다시 접속한다. 애드온 창에서 Aurora 의 표시(사용 가능 / 오래됨 / 다른 결과)를 본다. 대화창에 Aurora 가 찍는 줄(판 번호·클라이언트 판·해상도와 UI scale)을 옮겨 적고, 안내 창이 떴는지 본다(뜨면 읽고 닫는다). 첫 줄을 다시 치고, `/aurora skinaudit` 를 친 뒤 출력 전체를 적는다.
  `/run print(Aurora ~= nil, GetCVar("questTextContrast"), GetCVar("useUiScale"), GetCVar("uiScale"), UIParent:GetScale(), GetBuildInfo())`
  `/run print("qtc", GetCVar("questTextContrast"), "default", GetCVarDefault and GetCVarDefault("questTextContrast") or "없음")`
- 기대 결과: (가) 첫 값 `false`, (나) 첫 값 `true`. (나) 의 `questTextContrast` 는 `4` 로 바뀌어 있을 수 있다(위 코드 근거 — 바뀌었는지가 결과다). UI scale 두 값과 `UIParent:GetScale()` 은 (가) 와 같다. `skinaudit` 출력에 `[Forever/Camelot]` 표시가 있다(없으면 Aurora 가 이 클라이언트를 Forever 로 보지 않은 것 — 그대로 적는다). 실패한 스킨 수는 보인 그대로 적는다.

결과 한 줄 양식: `1 | <통과/실패/못 함> | Aurora 표시=<사용 가능/다른 결과> | 끈 상태 출력=<줄> | 켠 상태 출력=<줄> | questTextContrast=<원래→켠 뒤> · 기본값=<값/없음> | 안내 창=<뜸/안 뜸> | 대화창 줄=<옮긴 줄> | skinaudit=<Forever 표시 예/아니오 · 실패 n개> | 갈무리(끈 상태)=<7개 파일 이름>`

## 2. 어떤 기본 창에 스킨이 걸리는지

- 하는 법: Aurora 를 켠 채로 1번의 일곱 창을 다시 하나씩 열고 같은 자리에서 갈무리를 남긴다(`after_<창>.png`). 창마다 1번 갈무리와 견주어 「걸림(바탕·테두리·버튼이 Aurora 의 평평한 어두운 꼴로 바뀜) / 일부만 / 안 걸림」 을 `windows.md` 표에 적는다. 이 클라이언트의 창 이름을 알려고 다음 줄을 한 번 친다(`true` 인 이름이 이 클라이언트에 있는 창이다):
  `/run for _,n in ipairs({"CharacterFrame","PlayerSpellsFrame","SpellBookFrame","ContainerFrame1","QuestLogFrame","QuestMapFrame","WorldMapFrame","SettingsPanel","BuffFrame"}) do print(n,_G[n]~=nil) end`
  버프 아이콘은 버프가 둘 이상 있을 때 본다(음식·물약·직업 버프 등).
- 기대 결과(Claude 가 코드로 본 예상 — 결과는 보인 그대로): 캐릭터 창 걸림(`Aurora/Skin/Interface/AddOns/Blizzard_UIPanels_Game/Camelot/CharacterFrame.lua:139`). 가방 걸림(`.../Mainline/ContainerFrame.lua:294`). 지도 걸림(`.../Mainline/WorldMapFrame.lua`). 주문책·퀘스트 목록은 이 클라이언트가 어느 창을 쓰는지에 달렸다(확인 필요 — 위 줄의 출력과 함께 적는다). **설정 창은 안 걸림**이 예상이다(Forever 목록에서 설정 창 스킨 줄이 꺼져 있다 — `AddOns_Forever.xml:414–417`). **버프 아이콘은 아이콘 테두리만 잘라 내고 바탕은 그대로**다(`Blizzard_BuffFrame/Mainline/Blizzard_BuffFrame.lua:12–31`) — 기본 버프 창이 Phase 15 범위에 드는 근거가 이 항목이다.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 캐릭터=<걸림/일부/안 걸림> | 주문책=<…·창 이름> | 가방=<…> | 퀘스트=<…·창 이름> | 지도=<…> | 설정=<…> | 버프=<…> | 창 이름 출력=<true 인 이름들> | 파일=windows.md·after_*.png`

## 3. 중요한 옵션 — 원래 값 기록, 바꿔 보기, 되돌리기

- 하는 법: 무엇도 바꾸기 전에 아래 두 줄을 치고 출력 전체를 `options.txt` 에 옮긴다(이것이 원래 값이다). `/aurora` 로 설정 창을 연다(Features·Appearance·Privacy·Performance 네 화면). 창 이름과 항목 이름을 보인 그대로 적는다. 「Backdrop opacity」(배경 불투명도, `alpha`)를 바꿔 보고 바로 바뀌는지 본다. 「Chat Frames」 를 끄고 `/reload` 뒤 대화창이 기본 꼴로 돌아오는지 본다. 끝나면 바꾼 항목을 모두 원래 값으로 되돌리고 두 줄을 다시 쳐서 처음 출력과 같은지 본다.
  `/run local c=AuroraConfig or {} for _,k in ipairs({"bags","banks","chat","loot","mainmenubar","fonts","tooltips","chatBubbles","characterSheet","objectiveTracker","alpha","colorMode","gcMode","hasAnalytics"}) do print(k,tostring(c[k])) end`
  `/run local c=AuroraConfig or {} local h=c.customHighlight or {} print("hl",tostring(h.enabled),h.r,h.g,h.b,"grad",tostring(c.buttonsHaveGradient),"ack",tostring(c.acknowledgedSplashScreen))`
- 기대 결과: 처음 설치라면 코드의 기본값과 같다 — `bags`·`banks`·`chat`·`loot`·`fonts`·`tooltips`·`chatBubbles`·`characterSheet`·`objectiveTracker` 는 `true`, `mainmenubar` 는 `false`, `alpha` 는 `0.5`, `colorMode` 는 `Normal`, `gcMode` 는 `smooth`, `hasAnalytics` 는 `true`(`Aurora/config.lua:13–56`). 불투명도는 다시 불러오지 않고 바뀌고, 다른 항목은 `/reload` 가 있어야 바뀐다(`Aurora/gui.lua:423,525`). `fonts` 가 켜져 있으면 koKR 에서 게임 글꼴을 `Fonts/2002.ttf` 로 바꾼다(`Aurora/Skin/init.lua:94–95`) — 글꼴이 바뀌는지 적는다. 되돌린 뒤 출력이 처음과 같다.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 원래 값=<기본값과 같음/다른 키=값> | 설정 창=<열림/안 열림·문구> | 불투명도=<바로 바뀜/안 바뀜> | 대화창 끔=<기본 꼴로 돌아옴/아님> | 글꼴 바뀜=<예/아니오> | 되돌림 뒤 같음=<예/아니오> | 파일=options.txt`

## 4. 모음집 애드온 창에 스킨이 두 번 걸리는지

- 하는 법: 게임을 종료한다. 위 4번용 ZIP 에서 적힌 폴더만 `_forever_/Interface/AddOns` 에 넣는다(Prat·Details·Grid2·Dominos·SexyMap·Quartz·FUF·Hekili). FUF 와 PitBull4 는 함께 켜지 않는다 — 먼저 FUF 로 보고, 다음에 게임을 종료해 모음집 ZIP 의 `PitBull4` 를 넣은 뒤 애드온 창에서 `ForeverUnitFrames` 를 끄고 `PitBull4` 를 켜서 unit 프레임만 다시 본다. 접속해 2초쯤 뒤 대화창에 `Aurora:` 로 시작하는 경고 줄이 찍히면 옮겨 적는다(Prat 이 있으면 대화창 스킨을 끄라는 경고가 예상이다 — `Aurora/compatibility.lua:39–42,229–231`). 애드온마다 그 창(Prat 대화창 3개, Details 창 둘, Grid2 파티·공격대 묶음, Dominos 단축바·메뉴줄, SexyMap 미니맵, Quartz 시전바, FUF/PitBull4 unit 프레임, Hekili 표시창)을 띄우고, Aurora 를 끈 상태(애드온 창에서 끄고 다시 접속)와 켠 상태를 갈무리로 견준다. 그 애드온 자기 꼴 위에 Aurora 꼴(평평한 어두운 바탕·잘린 아이콘·그라데이션 버튼)이 덧씌워지면 「두 번 걸림」 이다. 두 번 걸리면 3번의 Aurora 옵션 가운데 그것을 끄는 옵션을 꺼 보고(예: Prat → 「Chat Frames」, Dominos → 「Main Menu Bar」) `/reload` 뒤 다시 본다. 끌 옵션이 없으면 「끌 옵션 없음」 으로 적는다. `overlap.md` 에 애드온마다 한 줄씩 적는다.
- 기대 결과: 애드온마다 「안 걸림 / 두 번 걸림 → <옵션> 끔으로 풀림 / 두 번 걸림·끌 옵션 없음」 중 하나가 적혀 있다. 어느 창도 Aurora 때문에 빈 창·깨진 창이 되지 않는다. 끈 옵션은 `options.txt` 에 3번의 원래 값과 함께 「바꿈」 으로 적고 9번 전에 원래 값으로 되돌린다.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 경고 줄=<옮긴 줄/없음> | Prat=<결과> | Details=<결과> | Grid2=<결과> | Dominos=<결과> | SexyMap=<결과> | Quartz=<결과> | FUF=<결과> | PitBull4=<결과> | Hekili=<결과> | 끈 옵션=<목록/없음> | 파일=overlap.md`

## 5. 게임 기본 이름표 · Cooldown Manager 에 겹침 (옵션으로 못 끄는 스킨)

- 하는 법: Aurora 에는 이름표 스킨이 있고(`Aurora/Skin/Interface/AddOns/Blizzard_NamePlates/Mainline/Blizzard_NamePlates.lua:138–213`), Phase 8 이 쓰는 게임 Cooldown Manager 스킨도 있다(`Blizzard_CooldownViewer/Blizzard_CooldownViewer.lua:185`). 둘 다 Aurora 옵션에 끄는 칸이 없다(`Aurora/config.lua:13–56` 의 옵션 목록에 없음 — 3번 설정 창에서도 이름표 항목이 없는지 본다). 몹이 여럿 있는 곳에서 지금 적 이름표가 켜져 있는지 꺼져 있는지 적은 뒤 적 이름표를 켜고 Aurora 켬/끔 두 상태로 이름표 갈무리를 남긴다. `References/codex-appearance/14/AddOns/DevilForever_Skin_Nameplates/` 가 저장소에 있으면 그것을 넣고 셋째 상태(Phase 14 스킨 + Aurora)도 본다. 없으면 「Phase 14 스킨 없음」 으로 적는다. 이어서 `phase8.md` 5번대로 Cooldown Manager 를 켜고 같은 두 상태를 견준다. 끝나면 이름표 켜짐을 처음 적은 상태로 되돌린다.
- 기대 결과: 이름표와 Cooldown Manager 각각 「Aurora 만 걸림 / Phase 14 스킨과 둘 다 걸림 / 안 걸림」 이 적혀 있고, 이름표는 어느 쪽 스킨 하나를 남길지 하나를 고른다(Aurora 이름표 스킨은 옵션으로 못 끄므로 「Phase 14 스킨만」 을 고르면 그 이유와 함께 8번 판정에 넣는다). 이름표의 체력·위협 색 뜻은 바뀌지 않는다.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 이름표=<Aurora 만/둘 다/안 걸림> | Phase 14 스킨=<있음·결과/없음> | 남길 이름표 스킨=<Aurora/Phase 14/게임 기본>·이유=<한 줄> | 색 뜻 바뀜=<예/아니오> | Cooldown Manager=<결과> | 갈무리=<파일 이름들>`

## 6. 성능·오류 느낌 — BugSack, 전투 중 차단

- 하는 법: 4번 애드온을 모두 켠 채(FUF 판) 몹 여럿과 몇 번 싸운다. 전투 중에 가방·캐릭터 창·지도를 열고 닫아 본다. 싸우기 전·후와 접속 5분·10분 뒤에 아래 줄을 친다(Aurora 는 5분마다 메모리 정리를 한 번 돌린다 — 그 때 화면이 잠깐 멈추는지 본다). 끝나면 `/aurora skinaudit` 를 다시 치고, `/bugsack` 에서 오류 수와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 수를 센다. 끊김·느려짐은 느낀 그대로 한 줄로 적는다.
  `/run if UpdateAddOnMemoryUsage then UpdateAddOnMemoryUsage() end print("Aurora KB", GetAddOnMemoryUsage and GetAddOnMemoryUsage("Aurora"), "all KB", collectgarbage("count"), "FPS", GetFramerate())`
- 기대 결과: Aurora 에서 나온 Lua 오류 0, 차단 오류 0. 출력은 보인 그대로 적는다(`Aurora KB` 가 `nil` 이면 이 클라이언트에 그 함수가 없는 것 — 확인 필요로 적는다). 오류가 있으면 문구 전체를 `bugsack.txt` 에 복사한다.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 오류 수=<n>(Aurora 것=<n>) | 차단 오류 수=<n> | 메모리·FPS=<전/후/5분/10분 출력> | 5분 정리 때 멈춤=<느낌/없음> | skinaudit 실패=<n> | 느낌=<한 줄>`

## 7. `/reload` · 재접속 뒤 유지

- 하는 법: 3번 설정 창에서 「Backdrop opacity」 를 원래와 다른 값으로 바꾼다. `/reload` 뒤 3번 첫 줄의 `alpha` 값과 창 바탕을 본다. 게임을 완전히 종료했다가 다시 접속해 다시 본다. 같은 계정의 다른 캐릭터로도 본다(Aurora 설정은 계정 공통 저장이 예상이다 — `Aurora/Aurora.toc:11`). 안내 창이 다시 뜨는지 본다. 게임을 종료한 상태에서 `_forever_/WTF/Account/<계정>/SavedVariables/Aurora.lua` 가 생겼는지, `_forever_/WTF/Config.wtf` 를 0번 사본과 비교해 바뀐 줄(`questTextContrast` 등)을 적는다. 클라이언트 판 번호는 1번 출력에 있다(Aurora 코드에 「Forever 1.60.1.69977 까지는 저장값을 버렸고 70009 부터 남긴다」 는 주석이 있다 — `Aurora/config.lua:21–25`). 끝나면 불투명도를 원래 값으로 되돌린다.
- 기대 결과: `/reload` 뒤와 재접속 뒤 모두 바꾼 값이 남고, 다른 캐릭터에서도 같고, 안내 창은 다시 뜨지 않는다. 저장 파일과 바뀐 줄은 보인 그대로 적는다.

결과 한 줄 양식: `7 | <통과/실패/못 함> | 바꾼 값=<원래→새> | reload 뒤=<남음/돌아감> | 재접속 뒤=<남음/돌아감> | 다른 캐릭터=<같음/다름/캐릭터 없음> | 안내 창 다시=<뜸/안 뜸> | Aurora.lua=<있음/없음> | Config.wtf 바뀐 줄=<줄/없음> | 되돌림=<예/아니오>`

## 8. 판정 — Aurora 사용 / 안 씀

- 하는 법: 0–7 결과를 보고 `decision.md` 에 판정을 쓴다. 맨 위 한 줄은 `Aurora 사용` 또는 `Aurora 안 씀` 과 이유 한 줄이다. 이유는 R101(애드온은 적을수록 좋다)에 대어 쓴다: Aurora 가 더하는 것(2번에서 걸린 기본 창 수와 그 차이가 눈에 띄는지) ↔ 드는 것(애드온 하나 더, 4번의 두 번 걸림과 끈 옵션, 5번의 옵션으로 못 끄는 이름표·Cooldown Manager 스킨, 1번의 `questTextContrast` 변경, 게임 전체 GC 방식 변경과 6번 결과). 아래에 「사용」 이면 켜 둘 옵션·끌 옵션 목록(3번 설정 창의 이름 그대로)과 남길 이름표 스킨(5번), 「안 씀」 이면 기본 창을 어떻게 둘지 한 줄을 적는다.
- 기대 결과: `decision.md` 첫 줄이 위 두 꼴 가운데 하나이고 이유가 R101 에 대어 적혀 있다.

결과 한 줄 양식: `8 | <통과/못 함> | 판정=<Aurora 사용/Aurora 안 씀> | 이유=<한 줄> | 끌 옵션=<목록/없음> | 이름표 스킨=<Aurora/Phase 14/게임 기본> | 파일=decision.md`

## 9. 오류·결과 올리기 · 전체 되돌리기

- 하는 법: `/bugsack` 을 열어 이번 검증 동안 쌓인 오류를 모두 센다(있으면 문구 전체를 `bugsack.txt` 에). `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 도 센다. 0–9 의 결과 줄을 `References/codex-verify/phase15/result.md` 에 순서대로 적고 `windows.md`·`overlap.md`·`options.txt`·`decision.md`·`bugsack.txt`(있으면)·갈무리와 함께 저장소에 올린다. 게임을 끄기 전에 3·4·7번에서 바꾼 Aurora 옵션과 5번의 이름표 켜짐을 원래 값으로 되돌린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase15`, `WTF_after_phase15`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다). `forever_moved_phase15/AddOns` 는 백업에 이미 같은 것이 있으니 그대로 둔다. 되돌린 뒤 게임을 한 번 켜고 접속해 `/run print(GetCVar("questTextContrast"))` 가 1번 (가) 의 값과 같은지 본다. 다르면 1번 (가) 의 값(이 사용자의 원래 값)을 넣는 `/run SetCVar("questTextContrast", <1번 (가) 의 값>)` 을 치고 `/reload` 뒤 같은 줄로 다시 본다(지금 AddOns 에 Aurora 가 없는지도 본다 — 있으면 다시 4 로 바뀐다).
- 기대 결과: 오류 0, `References/codex-verify/phase15/result.md` 가 있다, 되돌린 뒤 AddOns 폴더 목록이 백업과 같고 `questTextContrast` 가 1번 (가) 의 값이다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 옵션·이름표 되돌림=<예/아니오> | 백업 되돌림=<예/아니오> | questTextContrast=<(가) 값 그대로/되돌림 줄((가) 값)로 넣음 · 값> | 커밋=<해시>`

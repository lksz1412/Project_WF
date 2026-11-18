# 통합 UI 공식 기능 조사

조사일: **2026-11-18**. 기록 기준 시각: **2026-11-18 11:11 KST**. 개별 페이지 취득 시각은 미측정이다. 실제 본문을 열어 읽은 서로 다른 최종 URL은 **74개**다. 공식 저장소 모듈 목록 API 응답을 포함하며, 재열기·검색 결과·다운로드 주소는 중복 계수하지 않았다. 도구가 제공한 캐시 본문을 포함하므로 페이지의 파일 표기를 최신 전체 이력 전수확인으로 확대하지 않는다.

열기 실패 URL **9개**:

- [실패 주소](https://www.curseforge.com/wow/addons/real-ui): tool reports inaccessible; actual project realui succeeds.
- [실패 주소](https://github.com/tukui-org/ElvUI/tree/main/ElvUI): restricted URL fetch failure.
- [실패 주소](https://github.com/tukui-org/Tukui/tree/Live/Tukui): restricted URL fetch failure.
- [실패 주소](https://github.com/tukui-org/ElvUI/tree/main/ElvUI/Core/Modules): restricted URL fetch failure.
- [실패 주소](https://github.com/tukui-org/Tukui/tree/Live/Tukui/Modules): restricted URL fetch failure.
- [실패 주소](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Core/Modules): 404; 실제 Game/Shared/Modules 경로로 보완.
- [실패 주소](https://www.curseforge.com/wow/addons/bug-sack): 본문 접근 실패; 실제 bugsack 주소로 보완.
- [실패 주소](https://www.curseforge.com/wow/addons/nugcombobar): 본문 접근 실패; 실제 nugie-combo-bar 주소로 보완.
- [실패 주소](https://www.curseforge.com/wow/addons/speedy-auto-loot): 본문 접근 실패; 실제 speedyautoloot 주소로 보완.

[전체 관측 기록](evidence/features-sources.json) · [기능별 셀·원문 위치](evidence/features-catalog.json) · [후속 원본 수집용 제품 목록](evidence/features-addons.json). 모든 확정 표시는 실제 공식 본문의 관측이다. 미확인 셀은 존재 여부를 판정하지 못했다는 뜻이다.

## 읽는 법

○ = 공식 설명·문서 또는 뜻이 명확한 공식 모듈 목록에서 확인. ✕ = 공식적으로 없다고 명시한 경우. ? = 미확인. 이번에 명시적 부재 근거를 확보한 셀이 없어 ✕는 사용하지 않았다. 모듈 이름만으로 세부 동작을 추정하지 않는다. 예를 들어 일반 cooldown 모듈에서 숫자 표시를, 지도 모듈에서 좌표를 확정하지 않았다.

각 ○는 원문 URL로 연결되며 링크 제목과 JSON의 `location`에 확인 위치를 둔다. **ᵇ**는 ElvUI 기반 제공, **ᵉ**는 BenikUI 자체 확장·배치·장식이다. BenikUI는 ElvUI를 요구하므로 기반 기능을 독립 구현으로 세지 않는다. 숫자는 **확인된 구성 수/8개 비교 대상**이며 ?를 미보유 0으로 바꾼 비율이 아니다. 프레임·가방 등의 하위 범위 차이는 비고에 남긴다.

기능 설명의 Retail·다른 게임 판 구성과 Forever 배포 파일 표기를 구분한다. **설치·게임 실행·실제 작동 시험은 수행하지 않았다.**

## 패키지와 공식 원문

| 패키지 | 실제 연 공식 설명·소스 | 관측 범위·의존 |
|---|---|---|
| ElvUI | [저장소](https://github.com/tukui-org/ElvUI) · [공유 모듈](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules) · [프레임 요소](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements) | 공유 모듈 구성 확인. Forever 폴더 존재를 배포 파일 지원·작동으로 쓰지 않음. |
| TukUI | [저장소](https://github.com/tukui-org/Tukui) · [Live 모듈](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live) | Live branch 목록; 설명은 Dragonflight/Wrath/Classic Era. Forever 파일 표기 미확인. |
| EllesmereUI | [공식 프로젝트](https://www.curseforge.com/wow/addons/ellesmereui) · [공식 저장소](https://github.com/EllesmereGaming/EllesmereUI) | Description / Included Modules. 최근 파일 목록에 v9.8.8 Forever 행. |
| SpartanUI | [공식 프로젝트](https://www.curseforge.com/wow/addons/spartan-ui) · [공식 저장소](https://github.com/spartanui-wow/SpartanUI) · [모듈 목록](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules) | Overview와 현재 README의 자체 행동단축바 설명. 최근 파일 목록에 9.0.5 Forever 행. |
| GW2 UI | [공식 프로젝트](https://www.curseforge.com/wow/addons/gw2-ui) · [공식 저장소](https://github.com/Mortalknight/GW2_UI) | Features. 최근 파일 목록에 12.1.9 Forever 행. 원문이 일부 기능의 게임 판 차이를 명시. |
| NDui | [공식 프로젝트](https://www.curseforge.com/wow/addons/ndui) · [공식 저장소](https://github.com/siweia/NDui) | Main Features / FAQ. 이번 파일 목록에서는 Retail 10.2.8만 관측; Forever 미확인. |
| RealUI | [공식 프로젝트](https://www.curseforge.com/wow/addons/realui) · [공식 저장소](https://github.com/RealUI/RealUI) | What's included / Setup. 최근 파일 목록에 4.2.6 Forever 행. |
| BenikUI | [공식 프로젝트](https://www.curseforge.com/wow/addons/benikui) · [공식 저장소](https://github.com/Benik/BenikUI) | ElvUI 확장. CurseForge는 ElvUI v16.00+ 요구, development README는 v14.00+로 다름. 현행 요구 판 근거는 CurseForge. 최근 파일 목록에 v5.20 Forever 행. |

## 기능 × 패키지

| 기능 | ElvUI | TukUI | EllesmereUI | SpartanUI | GW2 UI | NDui | RealUI | BenikUI |
|---|---|---|---|---|---|---|---|---|
| F01 공통 외관·테마 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Skins") | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Modern Visual Design L228–229") | [○](https://www.curseforge.com/wow/addons/spartan-ui "Overview/Artwork L228") | [○](https://www.curseforge.com/wow/addons/gw2-ui "hand-painted replacement L212–220") | [○](https://www.curseforge.com/wow/addons/ndui "Main Features L182") | [○](https://www.curseforge.com/wow/addons/realui "Skins L182") | [○](https://www.curseforge.com/wow/addons/benikui "Features L240–245")ᵉ |
| F02 행동단축바 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "ActionBars") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "ActionBars") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L235") | [○](https://github.com/spartanui-wow/SpartanUI "Action Bars L239–240") | [○](https://www.curseforge.com/wow/addons/gw2-ui "HUD L230") | [○](https://www.curseforge.com/wow/addons/ndui "FAQ L218–219") | [○](https://www.curseforge.com/wow/addons/realui "Action bars L177") | [○](https://www.curseforge.com/wow/addons/benikui "Layouts L245; ElvUI base bars")ᵉ |
| F03 유닛 프레임 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "UnitFrames") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "UnitFrames") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L236") | [○](https://www.curseforge.com/wow/addons/spartan-ui "Player Frames L229") | [○](https://www.curseforge.com/wow/addons/gw2-ui "Unit frames L231") | [○](https://www.curseforge.com/wow/addons/ndui "oUF/FAQ L184,218–219") | [○](https://www.curseforge.com/wow/addons/realui "HuD L175") | [○](https://www.curseforge.com/wow/addons/benikui "Layouts L245; base frames")ᵉ |
| F04 파티 프레임 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Groups "Party.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/UnitFrames/Groups?ref=Live "Party.lua") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L238") | [○](https://www.curseforge.com/wow/addons/spartan-ui "Party Frames L230") | [○](https://www.curseforge.com/wow/addons/gw2-ui "Unit frames and groups L231") | [○](https://github.com/siweia/NDui "PartyFrames L187–188") | [○](https://www.curseforge.com/wow/addons/realui "Group frames L176") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Groups "Party.lua")ᵇ |
| F05 공격대 프레임 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Groups "Raid.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/UnitFrames/Groups?ref=Live "Raid.lua") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L238") | [○](https://www.curseforge.com/wow/addons/spartan-ui "Raid Frames L231") | [○](https://www.curseforge.com/wow/addons/gw2-ui "Raid grids L231") | [○](https://www.curseforge.com/wow/addons/ndui "RaidFrame L184–185") | [○](https://www.curseforge.com/wow/addons/realui "Group frames L176") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Groups "Raid.lua")ᵇ |
| F06 채팅 기능 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Chat") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "ChatFrames") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L249") | [○](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules "Chatbox") | [○](https://www.curseforge.com/wow/addons/gw2-ui "Map/chat/tooltips L236") | [○](https://www.curseforge.com/wow/addons/ndui "Chat L187,230–231") | [○](https://www.curseforge.com/wow/addons/realui "chat placement L195") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Chat")ᵇ |
| F07 미니맵 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Maps "Minimap.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Maps?ref=Live "Minimap.lua") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L247") | [○](https://www.curseforge.com/wow/addons/spartan-ui "Minimap L237") | [○](https://www.curseforge.com/wow/addons/gw2-ui "Map/chat/tooltips L236") | [○](https://www.curseforge.com/wow/addons/ndui "FAQ L224–225") | ? | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Maps "Minimap.lua")ᵇ |
| F08 시전바 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "CastBar.lua") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "HUD L230") | [○](https://www.curseforge.com/wow/addons/ndui "FAQ L221–222") | [○](https://www.curseforge.com/wow/addons/realui "HuD L175") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "CastBar.lua")ᵇ |
| F09 버프 표시 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Auras") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "Auras") | ? | [○](https://www.curseforge.com/wow/addons/spartan-ui "Buff Management L238") | [○](https://www.curseforge.com/wow/addons/gw2-ui "aura indicators L231") | [○](https://www.curseforge.com/wow/addons/ndui "Auras watcher L183") | [○](https://www.curseforge.com/wow/addons/realui "Auras L179") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Auras")ᵇ |
| F10 디버프 표시 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "RaidDebuffs.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/UnitFrames?ref=Live "Debuffs.lua") | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "dispel colors L231") | [○](https://www.curseforge.com/wow/addons/ndui "Raid debuffs L185") | [○](https://www.curseforge.com/wow/addons/realui "Group frames/Auras L176,179") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "RaidDebuffs.lua")ᵇ |
| F11 툴팁 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Tooltip") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "Tooltips") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Blizz UI Element Reskins L242") | [○](https://www.curseforge.com/wow/addons/spartan-ui "Custom Tooltips L236") | [○](https://www.curseforge.com/wow/addons/gw2-ui "Map/chat/tooltips L236") | ? | [○](https://www.curseforge.com/wow/addons/realui "Tooltips L183") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Tooltip")ᵇ |
| F12 가방·인벤토리 UI | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Bags") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "Inventory") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L252") | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "Character/inventory L234") | [○](https://www.curseforge.com/wow/addons/ndui "One-container L188") | [○](https://www.curseforge.com/wow/addons/realui "Inventory L181") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Bags")ᵇ |
| F13 한 창 가방 통합 | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/ndui "One-container L188") | ? | ? |
| F14 이름표 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Nameplates") | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L237") | [○](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules "Nameplates") | ? | [○](https://www.curseforge.com/wow/addons/ndui "Nameplate L184,186") | [○](https://www.curseforge.com/wow/addons/realui "Nameplates L178") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Nameplates")ᵇ |
| F15 데이터 텍스트·정보 바 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "DataTexts") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "DataTexts") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/ndui "Infobars L192") | [○](https://www.curseforge.com/wow/addons/realui "Infobar L180") | [○](https://www.curseforge.com/wow/addons/benikui "Dashboards/datatexts L247–257")ᵉ |
| F16 경험치 바 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars "Experience.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live "ExperienceBar.lua") | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "vertical xp statusbars L260; base bar plus notifier")ᵉ |
| F17 평판 바 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars "Reputation.lua") | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "vertical rep statusbars L260; base bar plus notifier")ᵉ |
| F18 재사용 대기시간 숫자 | ? | ? | ? | ? | ? | ? | ? | ? |
| F19 재사용 대기시간 관리자 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L239") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "Cooldown Manager presets L179") | ? |
| F20 세계지도 UI | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Maps "Worldmap.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Maps?ref=Live "Worldmap.lua") | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "world map L236") | ? | ? | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Maps "Worldmap.lua")ᵇ |
| F21 지도 좌표 | ? | ? | ? | ? | ? | ? | ? | ? |
| F22 자동 수리 | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "quality of life L237") | [○](https://www.curseforge.com/wow/addons/ndui "Infobars L192; FAQ L227–228") | ? | ? |
| F23 자동 판매 | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/spartan-ui "Auto Sell L233") | ? | [○](https://www.curseforge.com/wow/addons/ndui "Infobars L192") | ? | ? |
| F24 퀘스트 자동 제출 | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/spartan-ui "Auto turn in L234") | ? | ? | ? | ? |
| F25 기본 창 스킨 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules "Skins") | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Blizz UI Element Reskins L242") | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "Blizzard window skins L237") | [○](https://www.curseforge.com/wow/addons/ndui "Main Features L182") | [○](https://www.curseforge.com/wow/addons/realui "Skins L182") | [○](https://www.curseforge.com/wow/addons/benikui "Blizzard frame decors L240")ᵉ |
| F26 UI 이동·편집 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/General "Movers.lua") | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Unlock Mode L218–222") | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "Move HUD L239") | ? | ? | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/General "Movers.lua")ᵇ |
| F27 profile 저장·전환 | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "save profiles / spec switch L239") | ? | [○](https://www.curseforge.com/wow/addons/realui "Setup L187–188") | ? |
| F28 profile 가져오기·내보내기 | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "Setup L188") | ? |
| F29 설치 마법사 | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "Setup wizard L186") | [○](https://www.curseforge.com/wow/addons/benikui "Installation L215–218")ᵉ |
| F30 글꼴 모듈·교체 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/General "Fonts.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live "Fonts") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/ndui "font outlines FAQ L210–211") | ? | [○](https://www.curseforge.com/wow/addons/benikui "font replacement L242")ᵉ |
| F31 화면 요소 스케일·크기 편집 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "resize L220; width/height L222") | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "scale every frame L239") | ? | ? | ? |
| F32 직업 자원 표시 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "ClassBars.lua") | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Resource Bars L240") | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "class powers L230") | [○](https://www.curseforge.com/wow/addons/ndui "Classbar L189") | [○](https://www.curseforge.com/wow/addons/realui "class resources L175") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "ClassBars.lua")ᵇ |
| F33 전투·버프 알림 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "AuraBuff Reminders L241") | ? | ? | [○](https://www.curseforge.com/wow/addons/ndui "event alerts L191") | ? | ? |
| F34 회전·다음 능력 추천 | ? | ? | ? | ? | ? | ? | ? | ? |
| F35 데미지 미터 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Damage Meter L251") | ? | ? | ? | ? | ? |
| F36 순위형 어그로 미터 | ? | ? | ? | ? | ? | ? | ? | ? |
| F37 위협 상태 표시 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars "Threat.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live "ThreatBar.lua") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/ndui "Nameplate tank threat color L186") | [○](https://www.curseforge.com/wow/addons/realui "Nameplate threat coloring L178") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars "Threat.lua")ᵇ |
| F38 퀘스트·목표 추적기 | ? | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live "ObjectiveTracker.lua") | [○](https://www.curseforge.com/wow/addons/ellesmereui "Quest Tracker L250") | [○](https://www.curseforge.com/wow/addons/spartan-ui "Auto-Hide Objectives L235") | [○](https://www.curseforge.com/wow/addons/gw2-ui "Questing L233") | ? | [○](https://www.curseforge.com/wow/addons/realui "objective tracker L183") | ? |
| F39 지속 치유(HoT) 추적 | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/spartan-ui "HoT Tracking L232") | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "your HoTs L176") | ? |
| F40 우편 모두 열기 | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/spartan-ui "Open All Mail L239") | ? | ? | ? | ? |
| F41 화면 가장자리·비네트 효과 | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/spartan-ui "Vignette Effects L240") | ? | ? | ? | ? |
| F42 커서 시각 효과 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Cursor Effects L243") | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "global cooldown cursor ring L237") | ? | ? | ? |
| F43 Mythic+ 타이머 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Mythic+ Timer L245") | ? | ? | ? | ? | ? |
| F44 Skyriding 전용 화면 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Skyriding HUD L246") | ? | ? | ? | ? | ? |
| F45 친구 목록 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Friends List L248") | ? | ? | ? | ? | ? |
| F46 Party Mode 모듈(세부 미확인) | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Party Mode L254") | ? | ? | ? | ? | ? |
| F47 자리비움(AFK) 모듈 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc "AFK.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live "AFK.lua") | ? | [○](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules "AFKEffects.lua") | [○](https://www.curseforge.com/wow/addons/gw2-ui "AFK screen L237") | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "AFK Mode L253")ᵉ |
| F48 비행 전용 모드 | ? | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "Flight Mode L254; Request Stop L259")ᵉ |
| F49 캐릭터 정보 창 | ? | ? | ? | [○](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules "ImprovedCharacterScreen.lua") | [○](https://www.curseforge.com/wow/addons/gw2-ui "hero panel L234") | ? | ? | ? |
| F50 전리품 주사위 UI | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc "LootRoll.lua") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "loot roll bars L234") | ? | ? | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc "LootRoll.lua")ᵇ |
| F51 획득 전리품 알림 | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "loot feed L234") | ? | ? | ? |
| F52 빠른 전리품 획득 | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "fast loot L237") | ? | ? | ? |
| F53 전투 문자 | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "combat text L183") | ? |
| F54 오류 수집·표시 | ? | ? | ? | ? | ? | [○](https://github.com/siweia/NDui "Default AddOns L203–206; bundled error collector") | [○](https://www.curseforge.com/wow/addons/realui "error catcher L183") | ? |
| F55 게임패드 전용 배치 | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "Forever gamepad layout L224") | ? | ? | ? |
| F56 치유·흡수량 예측 표시 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "HealPrediction.lua") | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "incoming heals/absorbs L176") | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements "HealPrediction.lua")ᵇ |
| F57 거리 밖 프레임 흐림 | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "range fading L176") | ? |
| F58 공격대 유틸리티 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc "RaidUtility.lua") | [○](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live "RaidUtilities.lua") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/ndui "Raid Toolbar L190") | ? | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc "RaidUtility.lua")ᵇ |
| F59 전문기술 대시보드 | ? | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "Professions Dashboard L249")ᵉ |
| F60 화폐 정보 표시 | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/realui "currencies in Infobar L180") | [○](https://www.curseforge.com/wow/addons/benikui "Tokens Dashboard L248")ᵉ |
| F61 아이템 수량 대시보드 | ? | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "Items Dashboard L251")ᵉ |
| F62 여러 평판 대시보드 | ? | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "Reputations Dashboard L250")ᵉ |
| F63 사용자 배경 패널 | ? | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "Custom Panels L252")ᵉ |
| F64 분리된 초상화 | ? | ? | ? | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/benikui "Detached portraits L255")ᵉ |
| F65 모듈별 선택 사용 | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Modular Addon System L226–227") | [○](https://www.curseforge.com/wow/addons/spartan-ui "modular description L218") | [○](https://www.curseforge.com/wow/addons/gw2-ui "module disable L221") | [○](https://www.curseforge.com/wow/addons/ndui "disable features FAQ L218–219") | ? | ? |
| F66 펫 경험치 바 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars "PetExperience.lua") | ? | ? | ? | ? | ? | ? | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars "PetExperience.lua")ᵇ |
| F67 기본 말풍선 편집 | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc "ChatBubbles.lua") | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "colored chat bubbles L236") | ? | ? | [○](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc "ChatBubbles.lua")ᵇ |
| F68 특성별 배치·profile 전환 | ? | ? | ? | ? | [○](https://www.curseforge.com/wow/addons/gw2-ui "profiles switch with specialization L239") | ? | [○](https://www.curseforge.com/wow/addons/realui "DPS/Tank and Healing follow specialization L187") | ? |
| F69 데이터 바 모듈(세부 미확인) | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Included Modules L253") | ? | ? | ? | ? | ? |
| F70 편의 기능 모듈(세부 미확인) | ? | ? | [○](https://www.curseforge.com/wow/addons/ellesmereui "Quality of Life L244") | [○](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules "Convenience") | ? | ? | ? | ? |

ᵇ 셀은 해당 ElvUI 원문과 BenikUI의 의존 설명을 함께 근거로 한다. ᵉ 셀도 기반 ElvUI와 함께 사용하는 구성이다. 채팅 기능 확인은 **채팅 3창 구성 확인**과 다르며 8개 패키지의 정확한 3창 구성은 미확인이다. ElvUI의 모듈 목록은 해당 기능 단위의 존재 근거이고 옵션·플레이 중 세부 동작은 미검증이다.

공식 저장소에서 이름만 추가 관측한 EllesmereUI의 세부 미확인 항목은 [저장소 모듈 목록](https://github.com/EllesmereGaming/EllesmereUI)의 ForeverEssentials, GroupFinder, LoadoutManager, Quickdraw, SimpleLootCouncil이다. 구체 동작·설치 범위 근거가 부족해 세부 기능으로 확대하지 않았다. 구현 보조 파일·모호한 내부 이름은 기능 수로 만들지 않았다.

## 기능별 확인 수와 대표 단독 애드온

파일 지원은 각 제품 공식 프로젝트의 **Recent Files에 실제 표시된 Forever 행** 기준이다. 전체 파일 이력을 조사하거나 실제 작동을 검증한 것이 아니다. 단독 대표는 기능을 따로 참고할 제품이며 통합 패키지의 모든 세부 범위와 같다는 뜻은 아니다. `미확인·시도`는 연결한 원문에서 같은 범위의 단독 대표 근거를 확보하지 못한 경우다.

| 기능 | 확인된 패키지 수 | 단독 대표·Forever 표기 URL | 범위·미확인 |
|---|---:|---|---|
| F01 공통 외관·테마 | 7/8 | [Aurora](https://www.curseforge.com/wow/addons/aurora) (Forever 표기 확인 · 12.1.5.4)<br>[Masque](https://www.curseforge.com/wow/addons/masque) (Forever 표기 확인 · 12.1.8) | 확인 범위는 아래 제품 설명표 참조. |
| F02 행동단축바 | 8/8 | [Dominos](https://www.curseforge.com/wow/addons/dominos) (Forever 표기 확인 · 12.0.4) | 확인 범위는 아래 제품 설명표 참조. |
| F03 유닛 프레임 | 8/8 | [Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames) (Forever 표기 확인 · 0.65.2) | 확인 범위는 아래 제품 설명표 참조. |
| F04 파티 프레임 | 8/8 | [Grid2](https://www.curseforge.com/wow/addons/grid2) (Forever 표기 확인 · 4.1.13-forever) | 확인 범위는 아래 제품 설명표 참조. |
| F05 공격대 프레임 | 8/8 | [Grid2](https://www.curseforge.com/wow/addons/grid2) (Forever 표기 확인 · 4.1.13-forever) | 확인 범위는 아래 제품 설명표 참조. |
| F06 채팅 기능 | 8/8 | [Prat 3.0](https://www.curseforge.com/wow/addons/prat-3-0) (Forever 표기 확인 · 3.9.117) | 채팅 존재·편집 범위만 확인; 사용자 지정 채팅 3창 구성은 전부 미확인. |
| F07 미니맵 | 7/8 | [SexyMap](https://www.curseforge.com/wow/addons/sexymap) (Forever 표기 확인 · v12.1.7) | 확인 범위는 아래 제품 설명표 참조. |
| F08 시전바 | 5/8 | [Quartz](https://www.curseforge.com/wow/addons/quartz) (Forever 표기 확인 · 3.8.0) | 확인 범위는 아래 제품 설명표 참조. |
| F09 버프 표시 | 7/8 | [TellMeWhen](https://www.curseforge.com/wow/addons/tellmewhen) (Forever 표기 확인 · 12.1.5) | 확인 범위는 아래 제품 설명표 참조. |
| F10 디버프 표시 | 6/8 | [TellMeWhen](https://www.curseforge.com/wow/addons/tellmewhen) (Forever 표기 확인 · 12.1.5) | 확인 범위는 아래 제품 설명표 참조. |
| F11 툴팁 | 7/8 | [TipTac Reborn](https://www.curseforge.com/wow/addons/tiptac-reborn) (Forever 표기 확인 · v26.11.11-release) | 확인 범위는 아래 제품 설명표 참조. |
| F12 가방·인벤토리 UI | 7/8 | [Bagnon](https://www.curseforge.com/wow/addons/bagnon) (Forever 표기 확인 · 12.1.11) | 가방 기능 확인과 한 창 통합 확인은 다르므로 F13을 따로 둠. |
| F13 한 창 가방 통합 | 1/8 | [Baganator](https://www.curseforge.com/wow/addons/baganator) (Forever 표기 확인 · 862) | 한 창 보기와 분류 보기를 공식 설명에서 확인. |
| F14 이름표 | 6/8 | [Platynator (Nameplates)](https://www.curseforge.com/wow/addons/platynator) (Forever 표기 확인 · 547) | 확인 범위는 아래 제품 설명표 참조. |
| F15 데이터 텍스트·정보 바 | 5/8 | [Titan Panel](https://www.curseforge.com/wow/addons/titan-panel) (Forever 표기 확인 · 9.3.7) | SpartanUI의 DataBarHost 이름만으로 정보 텍스트 기능을 확정하지 않음. |
| F16 경험치 바 | 3/8 | [Experience Forever](https://www.curseforge.com/wow/addons/experience-forever) (Forever 표기 확인 · ExperienceForever2.0.4) | 확인 범위는 아래 제품 설명표 참조. |
| F17 평판 바 | 2/8 | [Experience Forever](https://www.curseforge.com/wow/addons/experience-forever) (Forever 표기 확인 · ExperienceForever2.0.4) | 확인 범위는 아래 제품 설명표 참조. |
| F18 재사용 대기시간 숫자 | 0/8 | [OmniCC](https://www.curseforge.com/wow/addons/omni-cc) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | 일반 Cooldowns 모듈명만으로 숫자 표시를 확정하지 않음. |
| F19 재사용 대기시간 관리자 | 2/8 | [TellMeWhen](https://www.curseforge.com/wow/addons/tellmewhen) (Forever 표기 확인 · 12.1.5) | RealUI는 관리자 preset 제공 확인이며 독립 관리자 엔진 구현으로 세지 않음. |
| F20 세계지도 UI | 4/8 | [Mapster](https://www.curseforge.com/wow/addons/mapster) (Forever 표기 확인 · 1.14.0) | 확인 범위는 아래 제품 설명표 참조. |
| F21 지도 좌표 | 0/8 | [Mapster](https://www.curseforge.com/wow/addons/mapster) (Forever 표기 확인 · 1.14.0) | 지도 모듈 존재만으로 좌표를 확정하지 않음. |
| F22 자동 수리 | 2/8 | [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) (Forever 표기 확인 · 1.60.30-forever) | 확인 범위는 아래 제품 설명표 참조. |
| F23 자동 판매 | 2/8 | [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) (Forever 표기 확인 · 1.60.30-forever) | 확인 범위는 아래 제품 설명표 참조. |
| F24 퀘스트 자동 제출 | 1/8 | [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) (Forever 표기 확인 · 1.60.30-forever) | 확인 범위는 아래 제품 설명표 참조. |
| F25 기본 창 스킨 | 6/8 | [Aurora](https://www.curseforge.com/wow/addons/aurora) (Forever 표기 확인 · 12.1.5.4) | 확인 범위는 아래 제품 설명표 참조. |
| F26 UI 이동·편집 | 4/8 | [BlizzMove](https://www.curseforge.com/wow/addons/blizzmove) (Forever 표기 확인 · v3.8.8) | 확인 범위는 아래 제품 설명표 참조. |
| F27 profile 저장·전환 | 2/8 | [ProfileManager](https://www.curseforge.com/wow/addons/profilemanager) (Forever 표기 확인 · ProfileManager_v4.0.zip)<br>[Reflux](https://www.curseforge.com/wow/addons/reflux) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | ProfileManager는 여러 지원 애드온 preset, Reflux는 profile 저장·전환 범위. |
| F28 profile 가져오기·내보내기 | 1/8 | [ProfileManager](https://www.curseforge.com/wow/addons/profilemanager) (Forever 표기 확인 · ProfileManager_v4.0.zip)<br>[Myslot](https://www.curseforge.com/wow/addons/myslot) (Forever 표기 확인 · v6.3.1) | ProfileManager는 preset 문자열, Myslot은 행동단축바·매크로·키 바인딩 문자열 범위. |
| F29 설치 마법사 | 2/8 | [Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames) (Forever 표기 확인 · 0.65.2) | 공격대 프레임의 역할·외관·클릭 시전 설정 마법사 범위. |
| F30 글꼴 모듈·교체 | 4/8 | [Font Manager](https://www.curseforge.com/wow/addons/font-manager) (Forever 표기 확인 · FontManager-1.1.7.zip) | 확인 범위는 아래 제품 설명표 참조. |
| F31 화면 요소 스케일·크기 편집 | 2/8 | [BlizzMove](https://www.curseforge.com/wow/addons/blizzmove) (Forever 표기 확인 · v3.8.8) | 대표는 기본 창 크기 편집 범위; 전체 패키지 스케일과 동일 범위라는 뜻은 아님. |
| F32 직업 자원 표시 | 6/8 | [NugComboBar](https://www.curseforge.com/wow/addons/nugie-combo-bar) (Forever 표기 확인 · 12.1.3) | 연계 점수 등 직업 자원. 원문은 Live/Classic 목록을 구분; Forever 파일 표기와 자원별 실제 작동은 별개. |
| F33 전투·버프 알림 | 2/8 | [TellMeWhen](https://www.curseforge.com/wow/addons/tellmewhen) (Forever 표기 확인 · 12.1.5) | 확인 범위는 아래 제품 설명표 참조. |
| F34 회전·다음 능력 추천 | 0/8 | [Hekili Forever](https://www.curseforge.com/wow/addons/hekili-forever) (Forever 표기 확인 · v0.8.6) | 오라 감시·알림을 Hekili 유형 회전 추천으로 확정하지 않음. |
| F35 데미지 미터 | 1/8 | [Details! Damage Meter](https://www.curseforge.com/wow/addons/details) (Forever 표기 확인 · Details.20261109.15410.172) | 확인 범위는 아래 제품 설명표 참조. |
| F36 순위형 어그로 미터 | 0/8 | [ForeverThreat - Threat Meter for WoW Forever](https://www.curseforge.com/wow/addons/foreverthreat-threat-meter-for-wow-forever) (Forever 표기 확인 · ForeverThreat-1.12.3) | 위협 바·이름표 위협 색상을 플레이어별 순위 미터로 확정하지 않음. |
| F37 위협 상태 표시 | 5/8 | [ForeverThreat - Threat Meter for WoW Forever](https://www.curseforge.com/wow/addons/foreverthreat-threat-meter-for-wow-forever) (Forever 표기 확인 · ForeverThreat-1.12.3) | 확인 범위는 아래 제품 설명표 참조. |
| F38 퀘스트·목표 추적기 | 5/8 | [Kaliel's Tracker](https://www.curseforge.com/wow/addons/kaliels-tracker) (Forever 표기 확인 · 8.11.1-forever) | 퀘스트·업적·목표 추적기. 패키지의 자동 숨김 등 세부 범위는 별도. |
| F39 지속 치유(HoT) 추적 | 2/8 | [Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames) (Forever 표기 확인 · 0.65.2) | 공격대 셀의 지속 치유·보호막 모서리 표시자를 공식 설명에서 확인. |
| F40 우편 모두 열기 | 1/8 | [Postal](https://www.curseforge.com/wow/addons/postal) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | 확인 범위는 아래 제품 설명표 참조. |
| F41 화면 가장자리·비네트 효과 | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/leatrix-plus) | Leatrix 화면 테두리는 확인했으나 같은 비네트 효과인지는 미확인. |
| F42 커서 시각 효과 | 2/8 | [Forever Enhanced Cursor](https://www.curseforge.com/wow/addons/forever-enhanced-cursor) (Forever 표기 확인 · 1.0.2) | 두 패키지 효과의 구체 범위는 다름: 일반 커서 효과 / 글로벌 재사용 대기시간 링. |
| F43 Mythic+ 타이머 | 1/8 | [Mythic + Timer](https://www.curseforge.com/wow/addons/mythic-timer) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | GW2 UI의 Mythic+ 정보·보스 시간 기록을 던전 제한시간 타이머와 같다고 확정하지 않음. Retail 기능과 Forever 작동 구분. |
| F44 Skyriding 전용 화면 | 1/8 | [Skyriding/Dragonriding Glider](https://www.curseforge.com/wow/addons/glider) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | 확인 범위는 아래 제품 설명표 참조. |
| F45 친구 목록 | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/ellesmereui) | 동일 범위 단독 제품·Forever 표기 근거 미확인. |
| F46 Party Mode 모듈(세부 미확인) | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/ellesmereui) | 공식 이름의 모듈 존재만 확인; 게임 파티 프레임과 합치지 않음. |
| F47 자리비움(AFK) 모듈 | 5/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/benikui) | GW2 UI는 화면, BenikUI는 모드, ElvUI/TukUI/SpartanUI는 공식 모듈 이름 범위. |
| F48 비행 전용 모드 | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/quartz) | Quartz는 비행 진행바이며 별도 비행 정보 애드온 필요; 같은 비행 모드 대표로 확정하지 않음. |
| F49 캐릭터 정보 창 | 2/8 | [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) (Forever 표기 확인 · 1.60.30-forever) | Leatrix는 기본 캐릭터 창의 내구도/음량 확장 범위. |
| F50 전리품 주사위 UI | 3/8 | [XLoot](https://www.curseforge.com/wow/addons/xloot) (Forever 표기 확인 · 12.23.0) | XLoot Group의 Need/Greed/Pass 주사위 프레임 범위. |
| F51 획득 전리품 알림 | 1/8 | [LS: Toasts](https://www.curseforge.com/wow/addons/ls-toasts) (Forever 표기 확인 · 120105.06)<br>[XLoot](https://www.curseforge.com/wow/addons/xloot) (Forever 표기 확인 · 12.23.0) | LS: Toasts의 loot 알림과 XLoot Monitor/Toast의 획득 알림 범위. |
| F52 빠른 전리품 획득 | 1/8 | [Speedy AutoLoot](https://www.curseforge.com/wow/addons/speedyautoloot) (Forever 표기 확인 · 125)<br>[Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) (Forever 표기 확인 · 1.60.30-forever) | 두 공식 설명에서 빠른 자동 전리품 획득 확인; Leatrix는 판별 옵션 차이 조건 유지. |
| F53 전투 문자 | 1/8 | [MikScrollingBattleText](https://www.curseforge.com/wow/addons/mik-scrolling-battle-text) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측)<br>[Nameplate Scrolling Combat Text](https://www.curseforge.com/wow/addons/nameplate-scrolling-combat-text) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | MSBT는 피해·치유 문자, Nameplate Scrolling Combat Text는 피해 문자이며 치유 미포함을 공식 명시. |
| F54 오류 수집·표시 | 2/8 | [BugSack](https://www.curseforge.com/wow/addons/bugsack) (Forever 표기 확인 · v12.1.9) | BugSack은 BugGrabber 의존. 수집·표시 구성과 독립 엔진 수는 다름. |
| F55 게임패드 전용 배치 | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/gw2-ui) | 동일 범위 단독 제품·Forever 표기 근거 미확인. |
| F56 치유·흡수량 예측 표시 | 3/8 | [Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames) (Forever 표기 확인 · 0.65.2) | 체력 바의 들어오는 치유·흡수 보호막 표시를 공식 설명에서 확인. |
| F57 거리 밖 프레임 흐림 | 1/8 | [Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames) (Forever 표기 확인 · 0.65.2) | 범위 밖 유닛 프레임의 투명도 조절을 공식 설명에서 확인. |
| F58 공격대 유틸리티 | 4/8 | [Details! Damage Meter](https://www.curseforge.com/wow/addons/details) (Forever 표기 확인 · Details.20261109.15410.172)<br>[Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames) (Forever 표기 확인 · 0.65.2) | 공격대 도구. Forever Unit Frames는 준비 확인·역할 투표·징표 등 구체 목록 확인. |
| F59 전문기술 대시보드 | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/benikui) | 동일 범위 단독 제품·Forever 표기 근거 미확인. |
| F60 화폐 정보 표시 | 2/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/titan-panel) | RealUI는 정보 바, BenikUI는 화폐 대시보드 범위. |
| F61 아이템 수량 대시보드 | 1/8 | [MikScrollingBattleText](https://www.curseforge.com/wow/addons/mik-scrolling-battle-text) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | 획득 알림에 현재 인벤토리의 해당 아이템 총수 표시; 상시 대시보드 형식과는 다름. |
| F62 여러 평판 대시보드 | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/experience-forever) | Experience Forever는 한 평판 바 범위; 동시 여러 평판 대표로 확정하지 않음. |
| F63 사용자 배경 패널 | 1/8 | [kgPanels](https://www.curseforge.com/wow/addons/kg-panels) (Forever 미확인 · 이번 최근 파일 목록에 표기 미관측) | 사용자 UI 패널 생성 기능 확인. |
| F64 분리된 초상화 | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/forever-unit-frames) | 동일 범위 단독 제품·Forever 표기 근거 미확인. |
| F65 모듈별 선택 사용 | 4/8 | [XLoot](https://www.curseforge.com/wow/addons/xloot) (Forever 표기 확인 · 12.23.0) | 각 XLoot 모듈을 개별 활성화·비활성화하는 기능 확인. |
| F66 펫 경험치 바 | 2/8 | [Experience Forever](https://www.curseforge.com/wow/addons/experience-forever) (Forever 표기 확인 · ExperienceForever2.0.4) | 확인 범위는 아래 제품 설명표 참조. |
| F67 기본 말풍선 편집 | 3/8 | [Prat 3.0](https://www.curseforge.com/wow/addons/prat-3-0) (Forever 표기 확인 · 3.9.117) | 확인 범위는 아래 제품 설명표 참조. |
| F68 특성별 배치·profile 전환 | 2/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/reflux) | 동일 범위 단독 제품·Forever 표기 근거 미확인. |
| F69 데이터 바 모듈(세부 미확인) | 1/8 | 미확인 · [시도 원문](https://www.curseforge.com/wow/addons/ellesmereui) | 공식 모듈 존재만 확인. 이름을 자동화·경험치·평판 등 세부 기능으로 확대하지 않음. |
| F70 편의 기능 모듈(세부 미확인) | 2/8 | [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) (Forever 표기 확인 · 1.60.30-forever) | 독립형 편의 기능 모음; 통합 패키지 모듈의 미확인 세부 동작과 같다고 단정하지 않음. |

| 단독 애드온 | 실제 확인한 기능 범위 | Forever 파일 목록의 관측 |
|---|---|---|
| [Dominos](https://www.curseforge.com/wow/addons/dominos) | 행동단축바 | Forever 표기 확인 · 12.0.4 |
| [SexyMap](https://www.curseforge.com/wow/addons/sexymap) | 미니맵 | Forever 표기 확인 · v12.1.7 |
| [Prat 3.0](https://www.curseforge.com/wow/addons/prat-3-0) | 채팅·말풍선 글꼴 | Forever 표기 확인 · 3.9.117 |
| [Quartz](https://www.curseforge.com/wow/addons/quartz) | 시전바 | Forever 표기 확인 · 3.8.0 |
| [Bagnon](https://www.curseforge.com/wow/addons/bagnon) | 가방·은행 UI | Forever 표기 확인 · 12.1.11 |
| [TipTac Reborn](https://www.curseforge.com/wow/addons/tiptac-reborn) | 툴팁 | Forever 표기 확인 · v26.11.11-release |
| [Titan Panel](https://www.curseforge.com/wow/addons/titan-panel) | 정보 바·플러그인 | Forever 표기 확인 · 9.3.7 |
| [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) | 모듈형 편의 기능; 게임 판에 따라 옵션 차이 있음 | Forever 표기 확인 · 1.60.30-forever |
| [Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames) | 유닛·공격대 프레임; 설정 마법사·지속 치유·흡수/치유·거리 흐림 | Forever 표기 확인 · 0.65.2 |
| [Grid2](https://www.curseforge.com/wow/addons/grid2) | 파티·공격대 프레임 | Forever 표기 확인 · 4.1.13-forever |
| [OmniCC](https://www.curseforge.com/wow/addons/omni-cc) | cooldown 숫자; 공식 설명은 Classic 전용 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [Mapster](https://www.curseforge.com/wow/addons/mapster) | 세계지도·좌표 | Forever 표기 확인 · 1.14.0 |
| [Reflux](https://www.curseforge.com/wow/addons/reflux) | profile 저장·전환 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [BlizzMove](https://www.curseforge.com/wow/addons/blizzmove) | 기본 창 이동·크기 | Forever 표기 확인 · v3.8.8 |
| [TellMeWhen](https://www.curseforge.com/wow/addons/tellmewhen) | 오라·cooldown 추적·알림 | Forever 표기 확인 · 12.1.5 |
| [Details! Damage Meter](https://www.curseforge.com/wow/addons/details) | 데미지 미터·공격대 도구 | Forever 표기 확인 · Details.20261109.15410.172 |
| [ForeverThreat - Threat Meter for WoW Forever](https://www.curseforge.com/wow/addons/foreverthreat-threat-meter-for-wow-forever) | 대상/주시 대상 위협 순위 | Forever 표기 확인 · ForeverThreat-1.12.3 |
| [Platynator (Nameplates)](https://www.curseforge.com/wow/addons/platynator) | 이름표 | Forever 표기 확인 · 547 |
| [Aurora](https://www.curseforge.com/wow/addons/aurora) | 기본 창 스킨 | Forever 표기 확인 · 12.1.5.4 |
| [Postal](https://www.curseforge.com/wow/addons/postal) | 우편 모두 열기 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [Masque](https://www.curseforge.com/wow/addons/masque) | 버튼 스킨 엔진; 지원 애드온 필요 | Forever 표기 확인 · 12.1.8 |
| [Experience Forever](https://www.curseforge.com/wow/addons/experience-forever) | 경험치·평판·펫 경험치 바 | Forever 표기 확인 · ExperienceForever2.0.4 |
| [Font Manager](https://www.curseforge.com/wow/addons/font-manager) | 글꼴 변경 | Forever 표기 확인 · FontManager-1.1.7.zip |
| [Forever Enhanced Cursor](https://www.curseforge.com/wow/addons/forever-enhanced-cursor) | 커서 효과 | Forever 표기 확인 · 1.0.2 |
| [BugSack](https://www.curseforge.com/wow/addons/bugsack) | 오류 표시; BugGrabber 의존 | Forever 표기 확인 · v12.1.9 |
| [Hekili Forever](https://www.curseforge.com/wow/addons/hekili-forever) | 다음 능력 추천 | Forever 표기 확인 · v0.8.6 |
| [Skyriding/Dragonriding Glider](https://www.curseforge.com/wow/addons/glider) | Skyriding 자원·속도 바 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [Mythic + Timer](https://www.curseforge.com/wow/addons/mythic-timer) | Mythic+ 타이머 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [Myslot](https://www.curseforge.com/wow/addons/myslot) | 막대·매크로·키 바인딩을 문자열로 가져오기/내보내기 | Forever 표기 확인 · v6.3.1 |
| [ProfileManager](https://www.curseforge.com/wow/addons/profilemanager) | 여러 지원 애드온 설정 preset 저장·문자열 공유 | Forever 표기 확인 · ProfileManager_v4.0.zip |
| [Baganator](https://www.curseforge.com/wow/addons/baganator) | 한 창 또는 분류형 가방·은행 | Forever 표기 확인 · 862 |
| [NugComboBar](https://www.curseforge.com/wow/addons/nugie-combo-bar) | 연계점수 등 직업 자원; Live와 Classic 목록 차이 명시 | Forever 표기 확인 · 12.1.3 |
| [Kaliel's Tracker](https://www.curseforge.com/wow/addons/kaliels-tracker) | 퀘스트·업적·목표 추적기 | Forever 표기 확인 · 8.11.1-forever |
| [Questie](https://www.curseforge.com/wow/addons/questie) | 공식 프로젝트·Forever 파일 표기 관측; 이 본문에서 추적기 기능 대표 확정 안 함 | Forever 표기 확인 · v12.10.0 |
| [XLoot](https://www.curseforge.com/wow/addons/xloot) | 전리품 창·그룹 주사위·획득 알림·빠른 획득 | Forever 표기 확인 · 12.23.0 |
| [LS: Toasts](https://www.curseforge.com/wow/addons/ls-toasts) | 기본 알림 대체; FAQ에서 loot toast 확인 | Forever 표기 확인 · 120105.06 |
| [MikScrollingBattleText](https://www.curseforge.com/wow/addons/mik-scrolling-battle-text) | 피해·치유 등 스크롤 전투 문자, 아이템 소지 수량 획득 알림 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [Nameplate Scrolling Combat Text](https://www.curseforge.com/wow/addons/nameplate-scrolling-combat-text) | 이름표 위치 피해 문자; 치유 제외 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [kgPanels](https://www.curseforge.com/wow/addons/kg-panels) | 사용자 UI 배경 패널 | Forever 미확인 · 이번 최근 파일 목록에 표기 미관측 |
| [Speedy AutoLoot](https://www.curseforge.com/wow/addons/speedyautoloot) | 빠른 자동 전리품 획득 | Forever 표기 확인 · 125 |

BugSack의 오류 수집 의존 제품은 [BugGrabber](https://www.curseforge.com/wow/addons/bug-grabber)이며 최근 파일 목록에 v12.1.1 Forever 행을 확인했다. Titan Panel은 공식 본문에 **Forever에서 자동 회색 아이템 판매가 작동하지 않는 문제**를 명시하므로 이 문서의 자동 판매 대표로 사용하지 않았다. Leatrix Plus도 판에 따라 일부 옵션이 다르다는 원문 조건을 보존한다.

## 흔한 기능 중 아래 13개 목록에 없는 것

원래 13개 목록: **공통 외관 / 행동단축바 / 미니맵 / 채팅 3창 / 체력·직업 자원 / 시전바 / 설정 저장·복원 / 사용자 UI 편집 / 직업 전투보조(Hekili) / 공격대 프레임 / 데미지 미터 / 어그로 미터 / 대안 테마**.

아래는 위 목록에 별도 이름으로 없는 관측 기능이다. ‘흔함’의 수치 기준은 지정되지 않았으므로 확인 수만 보이며, 채택 판단은 하지 않는다. 공통 외관·전투보조 같은 넓은 범주와 겹칠 수 있는 부분은 기능명을 구체적으로 남겼다. ᵇ가 포함된 수는 독립 구현 수가 아니다.

| 실제 확인 기능 | 확인된 구성 수 | 공식 URL |
|---|---:|---|
| 버프 표시 | 7/8 | [EL](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules) · [TU](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live) · [S](https://www.curseforge.com/wow/addons/spartan-ui) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [N](https://www.curseforge.com/wow/addons/ndui) · [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 디버프 표시 | 6/8 | [EL-elements](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements) · [TU-unit](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/UnitFrames?ref=Live) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [N](https://www.curseforge.com/wow/addons/ndui) · [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 툴팁 | 7/8 | [EL](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules) · [TU](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live) · [E](https://www.curseforge.com/wow/addons/ellesmereui) · [S](https://www.curseforge.com/wow/addons/spartan-ui) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 가방·인벤토리 UI | 7/8 | [EL](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules) · [TU](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live) · [E](https://www.curseforge.com/wow/addons/ellesmereui) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [N](https://www.curseforge.com/wow/addons/ndui) · [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 한 창 가방 통합 | 1/8 | [N](https://www.curseforge.com/wow/addons/ndui) |
| 이름표 | 6/8 | [EL](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules) · [E](https://www.curseforge.com/wow/addons/ellesmereui) · [S-mod](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules) · [N](https://www.curseforge.com/wow/addons/ndui) · [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 데이터 텍스트·정보 바 | 5/8 | [EL](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules) · [TU](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules?ref=Live) · [N](https://www.curseforge.com/wow/addons/ndui) · [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 경험치 바 | 3/8 | [EL-bars](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars) · [TU-misc](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 평판 바 | 2/8 | [EL-bars](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 재사용 대기시간 관리자 | 2/8 | [E](https://www.curseforge.com/wow/addons/ellesmereui) · [R](https://www.curseforge.com/wow/addons/realui) |
| 세계지도 UI | 4/8 | [EL-map](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Maps) · [TU-map](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Maps?ref=Live) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 자동 수리 | 2/8 | [G](https://www.curseforge.com/wow/addons/gw2-ui) · [N](https://www.curseforge.com/wow/addons/ndui) |
| 자동 판매 | 2/8 | [S](https://www.curseforge.com/wow/addons/spartan-ui) · [N](https://www.curseforge.com/wow/addons/ndui) |
| 퀘스트 자동 제출 | 1/8 | [S](https://www.curseforge.com/wow/addons/spartan-ui) |
| 위협 상태 표시 | 5/8 | [EL-bars](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars) · [TU-misc](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live) · [N](https://www.curseforge.com/wow/addons/ndui) · [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 퀘스트·목표 추적기 | 5/8 | [TU-misc](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live) · [E](https://www.curseforge.com/wow/addons/ellesmereui) · [S](https://www.curseforge.com/wow/addons/spartan-ui) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [R](https://www.curseforge.com/wow/addons/realui) |
| 지속 치유(HoT) 추적 | 2/8 | [S](https://www.curseforge.com/wow/addons/spartan-ui) · [R](https://www.curseforge.com/wow/addons/realui) |
| 우편 모두 열기 | 1/8 | [S](https://www.curseforge.com/wow/addons/spartan-ui) |
| 화면 가장자리·비네트 효과 | 1/8 | [S](https://www.curseforge.com/wow/addons/spartan-ui) |
| 커서 시각 효과 | 2/8 | [E](https://www.curseforge.com/wow/addons/ellesmereui) · [G](https://www.curseforge.com/wow/addons/gw2-ui) |
| Mythic+ 타이머 | 1/8 | [E](https://www.curseforge.com/wow/addons/ellesmereui) |
| Skyriding 전용 화면 | 1/8 | [E](https://www.curseforge.com/wow/addons/ellesmereui) |
| 친구 목록 | 1/8 | [E](https://www.curseforge.com/wow/addons/ellesmereui) |
| Party Mode 모듈(세부 미확인) | 1/8 | [E](https://www.curseforge.com/wow/addons/ellesmereui) |
| 자리비움(AFK) 모듈 | 5/8 | [EL-misc](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc) · [TU-misc](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live) · [S-mod](https://api.github.com/repos/spartanui-wow/SpartanUI/contents/Modules) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 비행 전용 모드 | 1/8 | [B](https://www.curseforge.com/wow/addons/benikui) |
| 전리품 주사위 UI | 3/8 | [EL-misc](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc) · [G](https://www.curseforge.com/wow/addons/gw2-ui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 획득 전리품 알림 | 1/8 | [G](https://www.curseforge.com/wow/addons/gw2-ui) |
| 빠른 전리품 획득 | 1/8 | [G](https://www.curseforge.com/wow/addons/gw2-ui) |
| 전투 문자 | 1/8 | [R](https://www.curseforge.com/wow/addons/realui) |
| 오류 수집·표시 | 2/8 | [N-repo](https://github.com/siweia/NDui) · [R](https://www.curseforge.com/wow/addons/realui) |
| 게임패드 전용 배치 | 1/8 | [G](https://www.curseforge.com/wow/addons/gw2-ui) |
| 공격대 유틸리티 | 4/8 | [EL-misc](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc) · [TU-misc](https://api.github.com/repos/tukui-org/Tukui/contents/Tukui/Modules/Miscellaneous?ref=Live) · [N](https://www.curseforge.com/wow/addons/ndui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 전문기술 대시보드 | 1/8 | [B](https://www.curseforge.com/wow/addons/benikui) |
| 화폐 정보 표시 | 2/8 | [R](https://www.curseforge.com/wow/addons/realui) · [B](https://www.curseforge.com/wow/addons/benikui) |
| 아이템 수량 대시보드 | 1/8 | [B](https://www.curseforge.com/wow/addons/benikui) |
| 여러 평판 대시보드 | 1/8 | [B](https://www.curseforge.com/wow/addons/benikui) |
| 펫 경험치 바 | 2/8 | [EL-bars](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars) · [B](https://www.curseforge.com/wow/addons/benikui) |

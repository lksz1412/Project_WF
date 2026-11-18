# 기능별 「쓰는 방식」 판정 (Step 8)

작성: A1 분석 서브, 2026-11-18. 이 문서의 판정은 모두 **A1 판단**이다. 사용자 결정은 요청 대장 번호(R…)로만 적는다.

경로 줄임: `U/` = `Collection/upstream/`, `V42/` = `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/`, `M` = `Collection/manifest.md`.

근거 구분: **확정** = 파일:줄을 직접 읽은 사실 / **근거 미발견** = 찾았으나 없음 / **추정** = 읽은 사실에서 A1 이 끌어낸 판단 / **미검증** = 게임 안에서만 알 수 있어 Codex 실사용 검증으로 넘김.

판정 갈래(마스터 플랜 「시작 애드온을 쓰는 방식」 0–5, R63·R87):

| 판정 | 뜻 |
|---|---|
| `as-is` | 고치지 않는다. 기본 설정과 manifest·Core 등록만 쓴다 |
| `settings` | 원본은 그대로 두고 설정 기본값으로 맞춘다 |
| `modify` | 원본 코드를 고친다(고친 판은 `Collection/AddOns/` 에, 원래 폴더 이름 유지) |
| `new` | 새 코드를 만든다(우리 폴더 `DevilForever_*`) |

한 Phase 에 둘 이상이 섞이면 가장 넓은 쪽을 그 Phase 의 판정으로 적고 섞인 내용을 칸에 쓴다.

## 1. 판정 수

| 단위 | as-is | settings | modify | new | 합 |
|---|---|---|---|---|---|
| 기능 Phase 2–22 | 1 (15) | 14 (3·4·5·6·7·9·10·11·12·13·14·16·17·19) | 1 (18) | 5 (2·8·20·21·22) | 21 |
| manifest 시작 패키지 (`how_to_use` 를 적은 것) | 3 (Masque·Masque Onyx·Aurora) | 15 | 1 (Mapster) | 0 | 19 |

시작 패키지에 `new` 가 없는 까닭: 새 코드는 시작 애드온 안이 아니라 우리 새 폴더(`!DevilForever_Core`, `DevilForever_Combat` 등)에 들어간다. Phase 2·8·20·21·22 의 `new` 는 그 새 폴더 몫이다.

## 2. 요약 표

| Phase | 기능 | 시작 애드온 | 판정 | 한 줄 이유 |
|---|---|---|---|---|
| 2 | 공통 외관 | V42 !DevilUI 기전(참고) · Masque 12.1.8 · Masque Onyx 12.1.6 · V42 kgPanels | new | Core(등록 표·기본값 주입·토큰)는 없다. Masque·Onyx 는 as-is |
| 3 | 행동단축바 | Dominos 12.0.4 | settings | 태세·소환수·빙의·토템 바가 다 있고 Forever 분기가 있다 |
| 4 | 대화창 3개 | Prat-3.0 3.9.117 | settings | 모듈 켜기·끄기로 된다. 세 창 채널 분담(D3)은 Prat 기본값이 아니라 기본 대화창 설정이라 Core 기본값 주입이 맡는다 |
| 5 | 미니맵 | SexyMap v12.1.7 | settings | 기능은 설정으로 된다. 저장 방식이 AceDB 가 아니라 Phase 20 에 연결 코드가 필요 |
| 6 | unit·직업 자원 | Forever Unit Frames 0.65.2 | settings | 직업 자원 요소가 다 있다(직업 표 대조). 공격대·시전바 겹침은 설정으로 끈다 |
| 7 | 시전바 | Quartz 3.8.0 | settings | Forever 전용 휘두르기 모듈이 있다. FUF·Dominos_Cast 와 겹침은 설정 |
| 8 | 직업 전투보조 | Hekili v0.8.6-forever | new | Hekili 는 settings, EventAlert 식 알림 꼴을 Hekili 에서 찾지 못해 보완 모듈 `DevilForever_Combat` 쪽(갈래 2 쪽 근거). Step 18 에서 확정 |
| 9 | 공격대 프레임 | Grid2 4.1.13-forever | settings | Forever 판, 기능 의미 보존 |
| 10 | 데미지 미터 | Details 20261109 | settings | `Details_Camelot.toc` 로 로드(미검증) |
| 11 | 어그로 미터 | ForeverThreat 1.12.3 | settings | Forever 전용 |
| 12 | 툴팁 | TipTac Reborn v26.11.11 | settings | `TipTac_Forever.toc` 로 로드(미검증) |
| 13 | 가방 | Bagnon 12.1.11 | settings | 기능 설정 |
| 14 | 이름표 | Platynator 547 | settings | 기능 설정 |
| 15 | 기본 창 스킨 | Aurora 12.1.5.4 | as-is | 기능이 곧 외관. Forever 용 스킨 목록을 따로 로드한다 |
| 16 | 정보 바 | Titan Panel 9.3.7 | settings | 자동 판매는 켜지 않는다(Codex 기록: Forever 에서 안 됨) |
| 17 | 퀘스트·목표 추적기 | Kaliel's Tracker 8.11.1-forever | settings | Camelot TOC 가 필수 의존을 하나 둔다(미검증) |
| 18 | 세계지도 | Mapster 1.14.0 | modify | V42 가 고친 FogClear 오류 막기를 받은 판에 옮긴다. TOC 로드 조건은 Codex 결과를 보고 정한다(§6-1 master 수용) |
| 19 | 경험치·평판 바 | Experience Forever 2.0.4 (Step 8 때 Dominos_Progress) | settings | Dominos_Progress 에 소환수 경험치가 없어 시작 애드온을 바꿈(§6-4 master 수용) |
| 20 | 설정 저장·복원 | ProfileManager v4.0 | new | 프로필 전환·AddOn 묶음은 settings, AceDB 가 아닌 애드온 연결과 특성 전환은 새 코드 |
| 21 | 사용자 UI 편집 | 새 개발 (참고: V42 Devilconfig·!DevilUI minimap.lua) | new | Devilconfig 에는 편집·저장 기전이 없다(§6-2 master 수용) |
| 22 | 대안 테마 | Phase 2 Core 토큰 인터페이스 | new | 시작 애드온 없음 |

## 3. Phase 별 판정

각 Phase 는 (i) 요구 (ii) 시작 애드온이 채우는 근거 (iii) 빈 곳 (iv) 넣을 기본 설정 (v) Codex 에 넘길 외관 순서로 적는다. 요구는 마스터 플랜 기능 표(`Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md:208–228`)의 「이 Phase 가 하는 일」 이다.

### Phase 2 — 공통 외관 · new

- (i) `!DevilForever_Core`: 등록 표, 처음 로드 때 한 번 넣는 기본값 주입, 테마 토큰·프레임별 편집값 읽기 함수, 외관 프레임 이름 목록(R63·R87).
- (ii) Masque 는 버튼 스킨 엔진이고(`M:135`, SV `MasqueDB`, `U/Masque-12.1.8/Masque/Masque.lua:182`), Onyx 는 Masque 의존 스킨이다(`M:136`). 둘 다 16001 TOC(확정). Dominos·Hekili 가 Masque 를 OptionalDeps 로 둔다(`M:111,124`, 확정).
- (iii) Core 자체가 없다(확정 — `Collection/AddOns/` 는 `.gitkeep` 뿐). V42 !DevilUI 의 배치 저장은 대화창·미니맵 두 가지만 다룬다(`V42/!DevilUI/minimap.lua:930–949`, SV `DevilUILayout` per character `V42/!DevilUI/!DevilUI.toc:8`, 확정). 마스터 플랜이 빼라고 한 설치기·채팅 필터 초기화·uiScale 변경은 그대로 뺀다.
- (iv) Masque: 그룹별 스킨 이름 정도만(키 이름은 Phase 2 정독 때 — 지금 읽지 않음).
- (v) 패널·구분선·장식·글꼴·배치, Masque 스킨 선택, 질감 판정(R52) — 마스터 플랜 그대로 Codex 공통 외관 발주문.
- Masque·Masque Onyx 패키지 판정: as-is.

### Phase 3 — 행동단축바 · settings

- (i) 바 개수·페이지 전환·직업 특수 바·단축키 표시. 키 자동 배정 없음.
- (ii) 확정: Dominos 는 태세 바·소환수 바·빙의 바를 늘 로드하고(`U/Dominos-12.0.4/Dominos/Dominos.toc:43–46`), 토템 바는 `camelot` 에서 로드한다(`Dominos.toc:48–52`). `WOW_PROJECT_CAMELOT` 를 `'forever'` 로 본다(`Dominos/Dominos.lua:22–23`). LibDualSpec 이 있으면 특성마다 프로필을 바꾼다(`Dominos.lua:258–262`). 기본 프로필 이름이 직업 이름이다(`Dominos.lua:255`). Hekili 의 추천 강조가 Dominos 버튼을 찾는다(`U/Hekili-v0.8.6/Hekili/UI/BarGlow.lua:8`).
- (iii) 근거 미발견: 성기사 오라·사냥꾼 상·도적 은신이 Forever 태세 바에 뜨는지(`Collection/data/classes.md` 「원천 없음」). 실사용 검증 몫.
- (iv) `DominosDB` profile 키(`Dominos.lua:274–325`, 확정): `ab.count`(기본 8), `showBindingText`, `showMacroText`, `showCounts`, `showTooltipsCombat`, `possessBar`, `splitTotemBars`, `sticky`, `alignmentGrid`, `frames`. 값은 Phase 3 에서 Step 5 설계(버튼 80px·중앙 8×3)와 맞춘다.
- (v) 바 위치·크기·간격·Masque 스킨.

### Phase 4 — 대화창 3개 · settings

- (i) 기본 대화창·입력은 그대로, 켤 Prat 모듈 판정, 세 창 분담(D3), 미터기를 세 번째 창 자리에 두지 않음.
- (ii) 확정: Prat 은 Forever 를 따로 안다(`U/Prat-3.0-3.9.117/Prat-3.0/addon/addon.lua:74`). 모듈 기본값: History 켜짐(`modules/History.lua:35`), ChatLog 꺼짐(`modules/ChatLog.lua:33`), Memory 켜짐(`modules/Memory.lua:45`), Timestamps 켜짐(`modules/Timestamps.lua:52`), Fading 켜짐(`modules/Fading.lua:33`). SV `Prat3DB`(`addon/addon.lua:159`).
- (iii) 추정: 세 창의 채널 분담은 기본 대화창의 메시지 그룹 설정이라 Prat 모듈 기본값으로 정해지지 않는다. Core 의 기본값 주입(처음 한 번, 사용자 값은 덮지 않음)이 맡는 것이 맞다. Memory 모듈이 대화창 설정을 기억해 다시 거는 동작과 겹치는지는 Phase 4 정독 몫.
- (iv) `Prat3DB` 의 모듈별 `on`. 「깔끔한 채팅」(R24) 쪽으로 무엇을 끌지는 Phase 4 에서 정한다.
- (v) 버튼·탭·입력 테두리·글꼴.

### Phase 5 — 미니맵 · settings

- (i) 클릭·확대·핑·추적 아이콘·버튼 정리.
- (ii) 확정: 핵심 파일이 `[AllowLoadGameType mainline]` 아래에만 있다(`U/SexyMap-v12.1.7/SexyMap/SexyMap.toc:43,47,50,53,58`). 추정: 받은 판이 Forever 표기 판인데 Forever 용 다른 파일이 없으므로 제작자는 Forever 를 mainline 에 든다고 본다(아래 4-1 참고).
- (iii) 확정: 저장이 자체 방식(`SexyMap2DB` 를 직접 다룸, `U/SexyMap-v12.1.7/SexyMap/SexyMap.lua:217–231`)이라 ProfileManager 가 보지 못한다 → Phase 20 연결 코드 목록에 넣는다.
- (iv) `SexyMap2DB` 의 키는 Phase 5 정독 때.
- (v) 사각 모양·위치·테두리.

### Phase 6 — 기본 unit·직업 자원 · settings

- (i) 체력과 직업마다 다른 주·보조 자원을 직업 표와 맞게, 프레임 위 오라·치유 예측·거리 흐림, Phase 9 가 켜지면 파티·공격대 표시 끔.
- (ii) 확정: 자원 막대(`U/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Elements/Power.lua:13–18`), 드루이드 변신 중 마나(`Elements/DruidMana.lua:3–8`), 콤보 점(`Elements/ComboPoints.lua:3–5`), 토템(`Elements/Totems.lua:56–64`), 사냥꾼 소환수 만족도(`Elements/PetHappiness.lua:3–9`), 치유 예측·거리 요소(`ForeverUnitFrames.toc:45,75`). 직업 표 9개 직업의 자원 칸이 모두 FUF 요소로 덮인다(`Collection/data/classes.md`).
- (iii) 확정: FUF 는 자체 공격대 프레임(`Raid/`)과 시전바를 갖는다(`ForeverUnitFrames.toc:32–38,53`). `MacroBackup` 은 옛 판이 만든 자기 백업 매크로(「FUF Save n」)만 지운다(`Core/MacroBackup.lua:59–74`) — 새 환경이라 지울 것이 없고 사용자 매크로는 건드리지 않는다(R14–R17 과 충돌 없음, 추정). 저장값이 부호화된 문자열이라(`Core/Storage.lua:3–9,114`) Core 의 기본값 주입이 SV 표를 직접 쓰기 어렵다(추정) — Phase 6 에서 FUF 의 프리셋 가져오기 경로(`Core/Preset.lua`, 아직 읽지 않음)를 볼 것.
- (iv) 키(확정, `Core/Settings.lua`): 프레임별 `enabled`(145), `castbarEnabled`(394–395 · 기본값 player 꺼짐), `totemsEnabled`(701), `comboPoints`(722), `druidMana`(1053); 공격대 `enabled`(`Raid/Settings.lua:93`, 기본 켜짐 → Grid2 를 쓰면 끔).
- (v) 프레임 배치·크기·글꼴·질감.

### Phase 7 — 시전바 · settings

- (i) 내/대상 시전바, 시전·취소·차단. 겹치는 것 정리.
- (ii) 확정: Forever 전용 휘두르기 모듈(`U/Quartz-3.8.0/Quartz/Quartz.toc:66`), Focus 모듈이 Forever 를 따로 안다(`modules/Focus.lua:29`). SV `Quartz3DB`(`Quartz.lua:54`).
- (iii) 확정: 겹치는 후보 셋 — FUF 대상 시전바 기본 켜짐(`FUF Core/Settings.lua:395`), Dominos_Cast(`M:112`), 기본 시전바. Quartz 의 `Interrupt`·`Range`·`EnemyCasts` 는 mainline 에서 로드되지 않는다(`Quartz.toc:69–71`) → Forever 에서는 안 뜬다고 추정(4-1). 그러면 요구 (i) 의 「차단」 표시를 `Interrupt` 모듈이 맡지 못한다 — 기본 시전바 모듈이 차단을 보이는지는 Phase 7 정독과 Codex 실사용 검증 몫(미검증).
- (iv) `Quartz3DB` 모듈 켜기 — Phase 7 정독 때. 기본 방침(A1 판단): 시전바는 Quartz 하나, FUF `castbarEnabled` 대상 쪽 끔, Dominos_Cast 끔.
- (v) 위치·크기·스킨.

### Phase 8 — 직업 전투보조 · new (Hekili 는 settings)

첫 확인만이다. 지원표는 Step 18.

- ㉠ 오라·proc·CD 감시 데이터: **추정(있음)**. 직업 모듈마다 `RegisterAuras`·`RegisterAbilities` 가 직업 공용 kit 에 있다(예: 주술사 `U/Hekili-v0.8.6/Hekili_Shaman/Shaman.lua:548`(오라), 707(능력), `maelstrom_weapon` 571, `clearcasting` 667; 다른 직업 줄은 work_log). 이 자료는 시뮬레이션용이라 「무엇을 보여 줄지」 목록이 아니고, 특성별로 어느 것을 볼지는 Step 18 에서 고른다. 치유 특성 4개는 `unsupported` 라 표시창이 꺼진다(`Hekili/Engine/Schema/Spec/Kits.lua:141`) → 그 특성은 갈래 3 후보.
- ㉡ EventAlert 식(화면 중앙 아이콘·소리·강조) 알림 꼴: **근거 미발견**. 표시창은 추천 대기열 다섯 개(Primary·AOE·Cooldowns·Defensives·Interrupts, `Hekili/Options/Options.lua:415–506`)이고, 알림 창(`HekiliNotification`)은 토글·모드 바뀜 글만 띄운다(`Options.lua:8861,8938,9003`). Libs 밖에 `PlaySound` 가 없다. 추천 능력의 단축바 버튼을 빛나게 하는 기능은 있다(`UI/BarGlow.lua:1–10`).
- 판정(A1 판단): Hekili 패키지는 settings, 기능 Phase 는 new(보완 모듈 `DevilForever_Combat`). 마스터 플랜의 갈래 2 쪽 근거다. 「추천 로직을 새로 만들지 않는다」(R62)는 그대로 — 보완 모듈은 표시만.
- (iv) `HekiliDB`(`Hekili/Options/Profile.lua:20`): `displays.*`, `notifications.enabled`(`Options.lua:8861`), `barGlow`(`UI/BarGlow.lua:5`). 추천은 따로 끌 수 있게(D2).
- (v) 표시창 위치·크기·스킨.

### Phase 9 — 공격대 프레임 · settings

- (ii) 확정: Forever 판(`M:121–123`, 16001 만), 선택 의존 Clique(`M:121`), SV `Grid2DB`(`U/Grid2-4.1.13-forever/Grid2/GridCore.lua:124`).
- (iii) 빈 곳 미발견(기본값만). FUF 공격대 끄기는 Phase 6 키로.
- (iv) `Grid2DB` 프로필 — Phase 9 정독 때.
- (v) 외관 전부.

### Phase 10 — 데미지 미터 · settings

- (ii) 확정: 하위 모듈마다 `_Camelot.toc` 가 따로 있다(`M:60–110`). ProfileManager 에 Details 전용 연결이 있다(`ProfileManager/Providers.lua:686`).
- (iii) 미검증: Forever 클라이언트가 `_Camelot` 접미사 TOC 를 고르는지(4-5).
- (iv) `_detalhes_global`·`_detalhes_database` — Phase 10 정독 때.
- (v) 위치(세 번째 대화창 자리 피함)·스킨.

### Phase 11 — 어그로 미터 · settings

- (ii) 확정: 16001·16002 TOC(`M:118–119`), SV `ForeverThreatDB`.
- (iii) 확정: AceDB 가 아니고 ProfileManager 전용 연결도 없다(AceDB 검색 결과·`Providers.lua` 연결 목록) → Phase 20 연결 코드 목록.
- (iv) Phase 11 정독 때. (v) 위치·스킨.

### Phase 12 — 툴팁 · settings

- (ii) 확정: `TipTac_Forever.toc`(16001)과 `TipTac.toc`(120105)가 따로 있다(`M:164–165`). 위치 기본값 키 `anchorWorldUnitType`·`anchorWorldUnitPoint`·`anchorFrameUnitType`(`U/tiptac-reborn-v26.11.11-release/TipTac/ttCore.lua:249–260`). AceDB 를 LibFroznFunctions 로 쓴다(`TipTacOptions/ttOptions.lua:10`) → ProfileManager AceDB 검색에 잡힐 것(추정).
- (iii) 미검증: `_Forever` 접미사 TOC 를 클라이언트가 고르는지(4-5).
- (v) 배경·테두리·글꼴.

### Phase 13 — 가방 · settings

- (ii) 확정: 모두 16001 TOC(`M:184–188`), SV `BrotherBags`·`Bagnon_Sets`.
- (iii) 확정: AceDB 아님 → Phase 20 연결 코드 목록. 메뉴줄 가방 버튼 연결은 Phase 13 정독 때.
- (v) 외관 전부.

### Phase 14 — 이름표 · settings

- (ii) 확정: 16001 TOC(`M:190`), ProfileManager 전용 연결(`Providers.lua:2435`). 위협 색 설정 파일이 있다(`U/platynator-547/Platynator/CustomiseDialog/ColorsConfiguration.lua` — 파일 이름 검색만, 추정).
- (v) 데빌 토큰 적용.

### Phase 15 — 기본 창 스킨 · as-is

- (ii) 확정: Forever 용 스킨 목록을 따로 로드한다(`U/aurora-12.1.5.4/Aurora/Aurora.toc:34`). 필수 의존 줄은 classic 에서만 걸린다(`Aurora.toc:8`, 제작자 설명 25–27). 제작자 메모: Forever 는 코드명 Camelot, mainline UI 구조(`Aurora/Skin/init.lua:10–16`).
- (iii) SV `AuroraConfig` 는 AceDB 가 아님 → Phase 20 연결 목록(작은 것).
- (iv) 없음(기본값 그대로). (v) 범위·중복 스킨 판정은 Codex.

### Phase 16 — 정보 바 · settings

- (ii) 확정: 16001 TOC 14개 폴더(`M:192–207`), `TitanClassic`·`TitanRegen` 은 Forever 에서 안 뜬다(`M:196,203`).
- (iii) Codex 기록: Forever 에서 회색 아이템 자동 판매가 안 된다(`References/addon-sources/titan-panel/ANALYSIS.md:7`). 기본값에서 자동 판매를 켜지 않는다(A1 판단). AceDB 아님 → Phase 20 연결 목록.
- (iv) `TitanSettings`·`TitanAll` — Phase 16 정독 때. Devilconfig·BugSack LDB 버튼.
- (v) 상태띠 28px 외관.

### Phase 17 — 퀘스트·목표 추적기 · settings

- (ii) 확정: 기본 TOC 는 머리말만 있고 파일 목록이 없다(`U/kaliels-tracker-8.11.1-forever/!KalielsTracker/!KalielsTracker.toc:1–16`). 실제 내용은 `_Camelot.toc` 에 있다(1–26). ProfileManager 전용 연결(`Providers.lua:2336`). SV `KalielsTrackerDB`(`Core/System/Config.lua:127`).
- (iii) 미검증: `_Camelot.toc` 가 필수 의존 `Blizzard_TransmogShared` 를 둔다(`!KalielsTracker_Camelot.toc:20`). Forever 에 그 기본 애드온이 없으면 로드되지 않는다(4-5).
- (v) 위치·외관.

### Phase 18 — 세계지도 · modify

4-1 의 확인 결과. 받은 판에 V42 의 FogClear 오류 막기를 옮겨 넣는 것을 「고침」 으로 판정한다(A1 판단). TOC 머리말은 Codex 결과 전까지 고치지 않는다.

- (iii) 빈 곳: Mapster Lua 코드에 Forever 분기가 없다(Forever 검색 0건, work_log). 미니맵(Phase 5)과 담당 나눔.
- (iv) `MapsterDB`(`U/mapster-1.14.0/Mapster/Mapster.lua:36`) — 좌표·미탐색 영역 키는 Phase 18 정독 때.
- (v) 크기·투명도.
- 고친 판은 CurseForge 자동 업데이트가 덮으므로 Codex 발주문에 자동 업데이트 끄기를 넣는다(마스터 플랜 「쓰는 방식」 4).

### Phase 19 — 경험치·평판 바 · settings

아래는 Step 8 때(시작 애드온 Dominos_Progress)의 판정이다. master 가 §6-4 (다) 를 받아 시작 애드온은 Experience Forever 2.0.4 로 바뀌었다 — 판정 settings 는 그대로, 경험치·평판·소환수 경험치 설정 키는 Step 31 에서 정독한다(`ExperienceForeverDB`, `showPetBar`·`showRepBar` 는 `ExperienceForever.lua:44,59`).

- (ii) 확정: 자료 모듈이 경험치·평판·명예·골드다(`U/Dominos-12.0.4/Dominos_Progress/Dominos_Progress.toc:13–18`). Forever 에서 테두리 그림을 따로 쓴다(`progressBar/bar.lua:19`).
- (iii) 확정: 소환수 경험치가 없다(Dominos_Progress 검색 0건). 비교 대상 Experience Forever 는 사냥꾼 소환수 경험치 막대를 갖는다(`U/experience-forever-ExperienceForever2.0.4/ExperienceForever/ExperienceForever.lua:1117–1121`). → 결정 대기 4.
- (v) 긴 윗줄·검은 띠 안 배치.

### Phase 20 — 설정 저장·복원 · new (ProfileManager 는 settings)

- (i) 등록 표의 저장 변수만 다루는 범위 복원, 공통/직업·특성별 나눠 저장, 특성이 바뀌면 그 프로필로, 없는 애드온 항목 보존, 판이 다른 데이터는 알리고 건드리지 않음, 키·게임 설정 포함, 매크로 제외(R44·R14–R17).
- (ii) 프로필 전환·프리셋·AddOn 묶음·캐릭터별 로그인 적용이 있다(4-2 표, 확정).
- (iii) AceDB 가 아닌 여섯 애드온과 Core, 범위 복원, 특성 전환(4-2 A1 판단 1–3).
- (iv) `ProfileManagerDB`(`ProfileManager/Core.lua:62–66`): `presets`, `settings.fontSize`·`settings.scale`, `minimap.hide`; 캐릭터별 `charPresets`, 새 캐릭터 기본값 `newCharDefault`·`newCharKeybinds`·`newCharAddons`·`newCharSettings`(`UI.lua:343–358`). 무엇을 기본으로 둘지는 Step 32.
- (v) ProfileManager 창과 새 범위 복원 창의 외관.
- 근거와 판단: 4-2.

### Phase 21 — 사용자 UI 편집 · new

- (i) 위치·크기·글꼴·색·줄 수·간격 편집과 저장, 미리보기·취소·기본값, 보호된 프레임은 전투 밖에서만, 각 애드온이 실제로 지원하는 항목만(R44·R47).
- (ii) Devilconfig 에는 편집·저장이 없다. !DevilUI 배치 창이 대화창·미니맵의 이동·잠금과 전투 중 숨김을 갖는다(4-3 표, 확정).
- (iii) 편집 창, 항목 목록(Core 등록 표 ②), 저장, 미리보기·취소·기본값 전부(4-3 A1 판단).
- (iv) 시작 애드온의 기본값 없음(Devilconfig 는 저장 변수가 없다).
- (v) 편집 창 외관.
- 근거와 판단: 4-3.

### Phase 22 — 대안 테마 · new

시작 애드온이 없다. Phase 2 Core 의 토큰 세트 바꿔 끼우기 함수가 다른 애드온 스킨에도 걸리는지 확인하는 일과 Codex 대안 테마 발주문(마스터 플랜 그대로).

## 4. 따로 확인한 것

### 4-1. Phase 18 Mapster 의 TOC 로드 조건

| 사실 | 근거 | 구분 |
|---|---|---|
| 받은 판 머리말 `## AllowLoadGameType: mainline` | `U/mapster-1.14.0/Mapster/Mapster.toc:10` | 확정 |
| 같은 TOC 가 파일 하나에 `[AllowLoadGameType camelot, forever][ExcludeLoadGameType standard]` 를 건다 — 제작자가 Forever 에서 로드되기를 기대한 표시 | `Mapster.toc:55` | 확정(줄) · 추정(뜻) |
| V42 사본의 두 TOC(`Mapster.toc`, `Mapster_Camelot.toc`) 도 머리말이 똑같이 `mainline` 이다. V42 에 Forever 로 로드되게 바꾼 TOC 는 없다 | `V42/Mapster/Mapster.toc:10`, `V42/Mapster/Mapster_Camelot.toc:10` | 확정 |
| V42 는 FogClear 가 지도를 처음 열기 전 프로필 콜백에서 오류를 내던 것을 고쳤다(1.14.0-Forever-v2) | `V42/Mapster/README_Forever_v2_koKR.txt:1–5`, `FogClear.lua` 차이(`getReadyMap`, `HookPins`, `OnMapShown`, `pendingRefresh`) | 확정 |
| 다른 제작자들은 Forever 를 mainline 안으로 다룬다: Quartz 는 `Swing.lua` 를 mainline 에서 빼고 `SwingForever.lua` 를 camelot 에서 넣는다. SexyMap 은 핵심 파일을 mainline 에서만 로드하는데 Forever 판으로 배포됐다. Aurora 제작자는 Forever 가 mainline UI 구조라고 적었다 | `U/Quartz-3.8.0/Quartz/Quartz.toc:65–66`, `U/SexyMap-v12.1.7/SexyMap/SexyMap.toc:43`, `U/aurora-12.1.5.4/Aurora/Skin/init.lua:10–16` | 확정(줄) · 추정(뜻) |
| 우리 해제 도구는 「Allow 에 forever·camelot 이 없으면 no」 로 판정해 Mapster 를 `forever_load=no` 로 적었다 | `Collection/tools/toclib.py:35–37,67`, `M:219` | 확정 |

A1 판단: Forever 클라이언트가 `mainline` 을 자기 것으로 받아들일 가능성이 높다(추정, 위 세 제작자의 로드 조건과 V42 의 실제 오류 수정이 근거). 그렇다면 `forever_load=no` 는 도구 규칙이 만든 잘못된 「no」 다. 게임 안 확인은 미검증이다.

제안(결정 대기 1): 시작 애드온은 받은 Mapster 1.14.0 그대로 두고, ① FogClear 오류 막기를 V42 에서 옮기는 고침, ② Codex 가 게임 AddOns 목록에서 Mapster 가 「사용 가능」 으로 뜨는지 확인, ③ 안 뜰 때만 고친 판 TOC 머리말에 `camelot` 을 더한다. 도구의 `mainline` 판정은 「no」 대신 「확인 필요」 로 바꾸는 것을 master 에 제안한다.

### 4-2. Phase 20 ProfileManager

| 사실 | 근거 | 구분 |
|---|---|---|
| 전용 연결(provider) 14개: Chattynator, Details, BlizzardEditMode, DandersFrames, MSUF, DBM, ElvUI, TotalRP3, ArcUI, KalielsTracker, Platynator, EnhanceQoL, CursorTrail, VuhDo. 자체 프로필 2개: Baganator, MoveAny | `ProfileManager/Providers.lua:621,686,922,1407,1603,1675,1767,1965,2179,2336,2435,2576,2679,2778,3001,3006` | 확정 |
| 그 밖에는 AceDB-3.0 에 등록된 DB 를 모두 찾아 프로필 이름 단위로 바꾼다 | `Providers.lua:3060–3115` (`AceDB.db_registry` 순회) | 확정 |
| 우리 모음집에서 AceDB 검색에 잡힐 것: Dominos·Prat·Quartz·Grid2·Masque·Mapster·Hekili·TipTac(LibFroznFunctions 경유) | AceDB 생성 줄: `Dominos.lua:256`, `Prat addon.lua:159`, `Quartz.lua:54`, `GridCore.lua:124`, `Masque.lua:182`, `Mapster.lua:36`, `Hekili Options/Profile.lua:20`, `TipTac ttOptions.lua:10` | 확정(줄) · 추정(실제 잡힘) |
| 전용 연결로 잡힐 것: Details, Kaliel's Tracker, Platynator | `Providers.lua:686,2336,2435` | 확정 |
| 잡히지 않는 것: Forever Unit Frames, ForeverThreat, SexyMap, Bagnon, Titan Panel, Aurora, 우리 Core | 이 여섯은 자체 코드에서 AceDB 를 만들지 않는다(검색 0건)·전용 연결 없음 | 확정(검색 결과) |
| 다른 애드온이 연결을 더할 수 있는 공개 함수가 있다: `ProfileManager:RegisterProvider(id, provider)` | `ProfileManager/Core.lua:70–72` | 확정 |
| FUF 는 저장 연결을 받는 공개 함수가 있다: `ForeverUnitFrames.RegisterStorageProvider(name, {load, save})` | `FUF Core/Storage.lua:24–29`, `Core/Init.lua:5–7` | 확정 |
| 프리셋 = 「연결 id → 프로필 이름」 표. 적용은 전투 밖에서만, 일부는 UI 재시작 요구 | `Presets.lua:61–71,125–157`, `Providers.lua:2967` | 확정 |
| 캐릭터별 로그인 적용·새 캐릭터 기본값이 있다 | `UI.lua:339–375` | 확정 |
| 특성(talent) 바뀜 이벤트를 받는 코드가 없다 | `UI.lua`·`Commands.lua`·`Keybinds.lua`·`GameSettings.lua` 이벤트 검색 — `PLAYER_LOGIN`·`PLAYER_ENTERING_WORLD`·`PLAYER_REGEN_ENABLED`·`UPDATE_BINDINGS` 만 | 근거 미발견 |
| AddOn 켜기·끄기 묶음(캐릭터별)을 저장·적용한다 — 「기능을 AddOn 단위로 켜고 끔」(R44·R60)과 맞는다 | `Addons.lua:109–170,227–275` | 확정 |
| 키 설정·게임 설정 저장 | `Keybinds.lua`(393줄)·`GameSettings.lua`(414줄) — 파일만 확인, 내용 미독 | 미검증 |

A1 판단: ProfileManager 자체는 고치지 않는다(settings). 새 코드(우리 폴더)가 맡을 것:
1. AceDB 가 아닌 여섯 애드온과 Core 의 연결(provider)을 `ProfileManager:RegisterProvider` 로 등록한다. FUF 는 `RegisterStorageProvider` 를 쓸 수 있는지 Phase 20 에서 본다.
2. 등록 표의 저장 변수만 다루는 범위 복원 — ProfileManager 는 「프로필 이름 바꾸기」 이지 저장 변수 사본·복원이 아니다. 공통/직업별 나눠 저장, 없는 애드온 항목 보존, 판이 다른 데이터 건드리지 않음은 새 코드.
3. 특성이 바뀌면 그 특성 프로필로 바꾸기(features F68). 단 Dominos 는 LibDualSpec 으로 스스로 한다(`Dominos.lua:258–262`) — 겹치지 않게 나눈다.

### 4-3. Phase 21 Devilconfig (V42)

| 사실 | 근거 | 구분 |
|---|---|---|
| Devilconfig 는 LDB 실행 단추(launcher) + AceConfig 메뉴다. 메뉴 단추는 다른 애드온 설정창 열기(Dominos·TipTac·kgPanels·!DevilUI 배치 창), Dominos 바 9·10 보이기·숨기기, !DevilUI 설치 안내 열기뿐이다 | `V42/Devilconfig/Devilconfig.lua:1–216` 전문 | 확정 |
| 저장 변수가 없다 | `V42/Devilconfig/Devilconfig.toc:1–15` (SavedVariables 줄 없음) | 확정 |
| `ForeverCompat.lua` 는 옛 API 와 새 API 를 잇는 작은 함수 모음(메타데이터·옵션창 열기·그라데이션·창 크기·해상도)이다 | `V42/Devilconfig/ForeverCompat.lua:1–37` | 확정 |
| 실제 이동·크기 편집과 저장은 !DevilUI 의 배치 창에 있고, 대화창·미니맵만 다룬다. 전투가 시작되면 이동 손잡이를 숨긴다 | `V42/!DevilUI/minimap.lua:973–1058, 1073–1080`, SV `DevilUILayout`(`!DevilUI.toc:8`) | 확정 |

A1 판단: Devilconfig 에는 「편집·저장 기전」 이 없으므로 마스터 플랜 기능 표의 「편집·저장 기전을 고쳐 씀」(마스터 플랜 227행) 은 원천과 맞지 않는다. Phase 21 은 new 다. Devilconfig 에서 가져올 것은 LDB 실행 단추와 「전투 중이면 거절」 패턴뿐이고, 이동 손잡이·잠금·전투 중 숨김은 !DevilUI `minimap.lua` 를 참고한다. Core 등록을 읽게 하려면: 편집 창이 Core 등록 표 ②(편집 가능한 항목)를 읽어 항목을 만들고, 저장값을 Core 의 프레임별 편집값으로 넘기는 코드를 새로 쓴다. 비교 대상 Edit Mode Expanded·BlizzMove 는 이번에 읽지 않았다. → 결정 대기 2.

### 4-4. Phase 8 Hekili (첫 확인)

3장 Phase 8 절에 적었다. 요약: ㉠ 추정(있음, 직업 kit 단위), ㉡ 근거 미발견 → 갈래 2 쪽. 치유 특성 4개는 Hekili 표시가 꺼진다.

### 4-5. 로드 조건·의존이 의심스러운 애드온

| 애드온 | 의심 | 근거 | 구분 · 넘길 곳 |
|---|---|---|---|
| Mapster | 머리말 `mainline` → 도구가 no | 4-1 | 추정 · 결정 대기 1 |
| TipTac Reborn (4폴더) | Forever 용이 `_Forever.toc`, 기본 TOC 는 120105 뿐. 클라이언트가 `_Forever` 접미사를 고르지 않으면 「오래된 애드온」 으로 뜬다 | `M:164–183` | 미검증 · 결정 대기 3 |
| Kaliel's Tracker | 기본 TOC 는 빈 머리말, `_Camelot.toc` 만 실제 파일. 그 TOC 가 `Blizzard_TransmogShared` 를 필수 의존으로 둔다 | `!KalielsTracker.toc:1–16`, `!KalielsTracker_Camelot.toc:20` | 미검증 · 결정 대기 3 |
| Details (8폴더) | Forever 용이 `_Camelot.toc`, 기본 TOC 는 120105 | `M:60–110` | 미검증 · 결정 대기 3 |
| Questie (참고 대상) | `Questie_Camelot.toc` 와 `Questie_Forever.toc` 를 둘 다 둔다 — 제작자도 어느 접미사인지 둘 다 대비했다는 뜻(추정). 기본 TOC Interface `00000` | `M:210–212` | 참고 |
| Aurora | manifest 의 「Deps (required)」 칸에 Blizzard_Deprecated* 가 보이지만 실제로는 classic 조건이 붙어 있다 | `Aurora.toc:8` · `M:191` | 확정 · 도구 표시 문제(결정 대기 5) |
| Hekili | OptionalDeps 에 ConsolePort·ElvUI·WeakAuras — 선택 의존이라 없어도 로드된다 | `M:124` | 확정 · 문제 없음 |
| Hekili 직업 모듈 | `LoadOnDemand: 1`, 의존 Hekili·Hekili_Shared — Hekili 가 직업에 맞는 모듈을 불러온다 | `U/Hekili-v0.8.6/Hekili_Shaman/Hekili_Shaman.toc:8,10` | 확정 |
| Dominos_Config, Grid2Options, TipTacOptions 등 | `LoadOnDemand: 1` 설정 모듈 — 설정창을 열 때 로드 | `M:113,123,174` | 확정 · 문제 없음 |
| Grid2 | `LoadOnDemand: 0` 이 적혀 있다(0 = 아님) | `M:121` | 확정 · 문제 없음 |

## 5. manifest 에 적은 것

`Collection/manifest.json` 의 시작 패키지 19개(`feature_phases` 에 `use: start` 가 있는 것)의 `how_to_use` 칸에 `{"verdict", "reason", "judgment_md_section"}` 을 적었다. 다른 칸은 바꾸지 않았다(바꾸기 전후 `json.dumps(indent=2, ensure_ascii=False)` 비교로 `how_to_use` 칸 말고는 같음을 확인 — work_log). 비교·참고용 패키지(Chattynator·Glass Forever·Bartender4 등)와 검증 도구(BugSack·BugGrabber)는 `null` 그대로 두었다. `manifest.md` 는 `extract.py` 가 만드는 파일이라 손대지 않았다 — 표에 판정을 보이려면 도구를 다시 돌려야 한다(결정 대기 5).

## 6. 결정 대기 (master 에게)

1. **[master 수용 — `Claude/results/handoffs/phase1/TRIAGE_phase1.md:24`, 마스터 플랜 반영 2026-11-18] Phase 18 시작 애드온**: 받은 Mapster 1.14.0 을 유지하고 V42 FogClear 오류 막기를 옮기는 「고침」 으로 바꾸는 것(4-1). 마스터 플랜 기능 표 Phase 18 행의 「그대로 사용 + 설정 (추정)」 → 「고침(FogClear 오류 막기), TOC 는 Codex 결과 뒤」. 고침 Phase 라 하위 Step(30a·30b)이 붙는다(마스터 플랜 「기능 Phase 의 단계」).
2. **[master 수용 — `TRIAGE_phase1.md:25`, 마스터 플랜 반영 2026-11-18 · Step 34 에서 Edit Mode Expanded·BlizzMove 정독] Phase 21 쓰는 방식**: 「편집·저장 기전을 고쳐 씀」 → 「새 개발(편집 창·저장), Devilconfig 는 실행 단추 패턴만, 이동 손잡이는 !DevilUI minimap.lua 참고」(4-3). 비교 대상(Edit Mode Expanded·BlizzMove) 정독을 Step 34 에 넣을지.
3. **[master 수용 — `TRIAGE_phase1.md:26`, `Collection/codex-briefs/phase1.md` 6번으로 넣음(시작 0 + 항목 1–8)] Phase 1 Codex 발주문에 넣을지**: TOC 접미사 확인 한 항목 — 게임 AddOns 목록에서 TipTac(`_Forever`), Kaliel's Tracker·Details(`_Camelot`), Mapster(`mainline`) 가 「사용 가능」 으로 뜨는지. 지금 발주문(`Collection/codex-briefs/phase1.md`)은 brief 가 정한 것만 담았다(시작 0 + 항목 1–7). 넣는다면 5번 다음에 두고 뒤 번호를 하나씩 민다(시작 0 + 항목 1–8). 붙일 문구: 「하는 법: 게임을 종료하고, 저장소 `References/addon-sources/tiptac-reborn/`·`kaliels-tracker/`·`mapster/` 와 `References/forever-addons/Details/` 의 ZIP 을 풀어 나온 폴더를 `_forever_/Interface/AddOns` 에 넣는다(같은 이름 폴더가 있으면 덮지 말고 판 번호만 적는다). 게임을 켜고 캐릭터 선택 화면의 애드온 창에서 TipTac·Kaliel's Tracker·Details·Mapster 가 어떻게 표시되는지 본다. 기대 결과: 넷 다 「사용 가능」(오래된 애드온 표시 없음). 결과 한 줄 양식: `6 | <통과/실패/못 함> | TipTac=<사용 가능/오래됨/안 보임> | KalielsTracker=<…> | Details=<…> | Mapster=<…>`」
4. **[master 수용 (다) — `TRIAGE_phase1.md:27`, 마스터 플랜 반영 2026-11-18] Phase 19 소환수 경험치**: Dominos_Progress 에 없다. (가) 그대로 두고 최종 보고에 적음 (나) 비교 대상 Experience Forever 를 소환수 경험치 막대만 함께 켬 (다) 시작 애드온을 Experience Forever 로 바꿈. 마스터 플랜은 소환수 경험치를 Phase 19 범위에 넣었다(「제외한 기능」 표의 「한 창 가방·화폐 정보·소환수 경험치 — Phase 13·16·19 의 범위」). Experience Forever 는 `showPetBar`(기본 켜짐, `ExperienceForever.lua:44`)·`showRepBar`(59) 켜기·끄기가 있으나 경험치 막대 자체를 끄는 설정은 찾지 못했다(근거 미발견) — (나) 로 가면 경험치 막대가 둘이 될 수 있다. A1 기본값 (다): 경험치·평판·소환수 경험치를 한 애드온이 다 갖고 Forever 판이 확인된 Experience Forever 를 시작 애드온으로 바꾸고, Dominos_Progress 는 비교 대상으로 둔다(추정 판단 — Phase 19 Step 31 에서 두 애드온을 정독해 다시 본다). 판정은 어느 쪽이든 settings.
5. **도구(master·A2 몫)**: `toclib.py` 의 `mainline` 판정을 「no」 대신 「확인 필요」 로, `manifest.md` 의 「Deps (required)」 칸에 조건(`[AllowLoadGameType …]`)을 함께 보이게, `how_to_use` 를 manifest.md 표에 보이게 — 세 가지 모두 `extract.py`/`toclib.py` 수정이라 A1 범위 밖.
6. **manifest `role` 칸**: TipTac Reborn·Bagnon·Platynator·Aurora·Titan·Kaliel's·Mapster·ProfileManager 는 기능 Phase 의 시작 애드온인데 `role` 이 `comparison` 이다(`M:30–40`). 받은 위치(`References/addon-sources/`) 기준으로 붙은 값으로 보인다(추정). 뜻을 「받은 위치」 로 둘지 「모음집 역할」 로 고칠지.

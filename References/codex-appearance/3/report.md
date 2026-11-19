# 행동단축바 사전 준비

7개 바의 대응은 1·2 중앙의 4×3 두 묶음, 3·4·5 긴 12칸 세 줄연결, 6·7 좌우 4×3이다. 8번은 발주문대로 hidden=true다. numBars·numButtons·paging·키 배정은 조각에 넣지 않았다. 각 바의 저장 위치는 해당 바의 실효 배율로 환산한다. ActionButton1의 실제 너비와 hit inset으로 native 크기를 읽어 48/56/80px 버튼 목표를 계산한다. Masque/Onyx 스킨의 실제 외곽·아이콘 크기는 접속 후 확인한다.

Dominos 자체 프로필 산식에 맞춰 표준 Core fragment profile=$className·addonVersion=12.0.4를 썼다. 기존 앵커는 false로 명시해 위치 제안을 적용할 때 이전 anchoring이 되살아나지 않게 했다. 중앙 아래의 메뉴·가방은 네이티브 버튼 크기를 물리 단위로 보존하는 scale=1/UIParent배율 제안이다. 태세·소환수·빙의·토템은 보조줄을 공유하는 초안이며, 복합 소환수/태세가 동시에 있는 캐릭터는 실사용 점검 대상이다. 6·7 좌우 묶음은 Step 5의 세부 좌표가 없어 기능 발주문이 허용한 배치 제안으로 위 unit 경계보다 높은 양 끝에 두었다.

실행 중 skin은 HotKey 글꼴/색만 적용한다. SetFramePoint·SetFrameScale 같은 바 이동 함수를 반복 호출하지 않는다. 글꼴은 실제 FontString effective scale로 나눠 물리 글자 목표를 맞춘다. Masque 그룹 스킨 선택은 설치 후보의 저장값 준비 단계가 맡는다.

근거는 appearance-3 전문, Dominos core/frame.lua 1–1263·buttonBar.lua 1–375·bars/actionBar/bar.lua 1–485·button.lua 1–241·plugins/buttonThemer.lua 1–127·stanceBar·petBar·queueStatusBar 전문과 Core Defaults/Dominos.lua 전문이다. 실제 source 길이는 최종 대조에서 기록한다.

게임 갈무리 및 실사용 결과는 미검증이다. 원본 애드온·게임 설정 파일을 이 단계에서 변경하지 않았다.

물리 단위 보정: native button 크기×frameScale÷(pixelFactor/UIParent배율)가 목표 버튼 크기다. class/totem과 pet/possess는 공통 aux origin을 겹쳐 쓰지 않는다. pet/possess는 FHD(1350,758), QHD(1810,1074), UHD(2480,1680)의 긴 윗줄 위 별도 영역에 둔다. native 줄의 실제 개수·전체 외곽은 접속 확인 대상이며, 서로 배타라는 가정을 하지 않는다.

Masque native profile 제안 `masque-dominos-profile.fragment.lua`는 해당 addon 상위 그룹의 SkinID=Onyx·Inherit=false만 설정한다. 다른 addon 그룹과 기존 하위 그룹의 Inherit=false 선택은 강제로 바꾸지 않는다. pinned Masque.lua 전체·Core/Groups.lua 전체, Onyx Skins.lua 등록 DB의 Onyx ID를 확인했다. 기존 사용자 하위 그룹의 현재 상속 상태에 따른 효과는 live 확인 대상이다.

메뉴·가방·queue 고정 폭 추정을 native 측정값 fit으로 수정한다. 영향 연결: menuBar.lua·bagBar.lua·queueStatusBar.lua(전문, 확인만)→native 버튼 크기 입력→3개 Dominos profile(함께 고침)→Core preset 조립(부모 확인). 기존 기능 버튼 on/off·oneBag/keyRing 선택은 고치지 않는다. 잠근 시험은 새 lower-profile Lua 실행에서 세 슬롯 외곽을 실제 제안값으로 대조한다.

## 소환수 열 교정 착수 영향 지도

사용자 후속 교정. 아래 좌표는 Codex 제안, 게임 실측 아님. 사전 보존은 parent before-pet-alignment-c3fea913 및 새 scratch의 References 사본.

|곳|연결 유형|찾는 법|영향도|이유|
|---|---|---|---|---|
|24 feature JSON pet/petTarget/quartz.pet·새 dominos.pet|같은 값·입력 생성|전체 JSON·관련 키 전수 검색|함께 고침|한 열 원천|
|3 Dominos3조각|소비·호출·쌍둥이|전문3개·실 petBar/ButtonBar|함께 고침|첫 native pet slot/NUM/count/Hit/Masque extent|
|6-rev PB4 3조각·7 Quartz3조각|소비·쌍둥이|전문·generator|함께 고침|pet 및 petTarget 좌표/크기 전파|
|6 FUF3조각|쌍둥이|동일generator 출력|함께 고침|발주 예외, 같은 pet좌표만|
|generate-feature-fragments.py|입력 생성|전문|확인/필요분 고침|기능8/9/10 출력은 금지라 호출wrapper로 쓰기범위 제한|
|check-feature/lower|잠근 시험·호출/피호출|전문|함께 고침|실 PB4 Refix oracle·Dominos ButtonBar 소비|
|PB4 UnitFrame·Dominos petBar/ButtonBar/Masque|피호출·원천|원문 전문|확인만|native API/기능/visibility 보존|
|parent renderer/조립/Core Defaults|소비·범위 밖|부모 계약 전달·정형key|확인만|master 담당, 개인profile 덮기 금지|
|이전 보고·게임·Git|이력·보호|경계대조|영향 없음|이전 결과 문구 보존, 신규 절만 기록|


## 소환수 열 교정 결과

최신 원천은 24/feature-positions.json의 pet/petTarget/dominos.pet/quartz.pet이다. 아래 표는 Codex 제안이며 실게임 실측이 아니다. 앞 절의 소환수 오른쪽 좌표는 당시 초안으로 보존했고 이번 소환수 열로 대체한다. possess는 기존 오른쪽 위치를 유지한다.

|해상도|petTarget [x,y,w,h]|pet|Dominos pet 기술바|Quartz pet|
|---|---|---|---|---|
|FHD|12,674,240,24|12,704,240,32|12,744,238,22|12,772,240,24|
|QHD|184,992,280,24|184,1018,280,40|184,1060,278,26|184,1088,280,24|
|UHD|384,1538,360,34|384,1582,360,42|384,1632,358,34|384,1672,360,28|

QHD focus cast 끝988→petTarget992, 각 pet 요소 gap2, Quartz 끝1112→긴 줄1118까지6px. 나머지 해상도도 기능 JSON의 모든 다른 rect와 pet4종 교차0. Main Dominos7개 바와 class/totem/possess의 기존 값은 보존했다.

Dominos pet은 PetActionBar.actionButtons[1], 없으면 PetActionButton1의 실제 GetSize/GetHitRectInsets와 NUM_PET_ACTION_SLOTS를 읽는다. native slot/개수가 없으면 해당 pet 조각을 빼며 가짜 버튼 치수를 넣지 않는다. player ActionButton 치수로 pet을 계산하지 않는다. Onyx40/36×alpha112/128의 visible envelope를 기준으로 scale/pitch/첫 버튼 anchor를 계산한다. 10개 정사각 native 슬롯일 때22/26/34px×10+gap2×9=238/278/358px이다. 다른 개수는 같은 예약폭/높이 안에 맞춘다. JSON petActionLayout은 slotCountSource/expectedSlots(제안10)/physicalGap/nativeButtonSource/masqueNormalUnits/masqueBaseUnits/alphaCoverage와 rect 의미를 공유한다.

showEmptyButtons/hidden·PetHasActionBar·GetPetActionInfo·키·스킬·possessBar·기존 state driver를 고치지 않았다. 제안값 반환만 하며 native profile에 직접 쓰거나 기존 사용자 설정을 재주입하지 않는다. 기존 사용자 profile 키 보존은 master Defaults 병합 계약을 그대로 따른다.

## 교정 실행 판정과 한계

`python References/codex-appearance/2/Tests/check-feature-proposals.py` rc0 PASS Lua5.1 36회 평가. 실제 Collection/AddOns/PitBull4/UnitFrame.lua singleton Refix를 실행한 oracle은 player/target의 기존 크기와 pet/petTarget의 위 표 크기·좌표에 일치한다. 배율 factor.35/.64에서 각각 확인. PB4 크기가 native 소비 산식에서 임의로 커지는 오류는 재현되지 않았다. native 전체 애드온·오라·초상화 부속 외곽·실게임 hit/글자 겹침은 미측정이다.

`python References/codex-appearance/2/Tests/check-lower-proposals.py` rc0 PASS 6세션. 실제 Dominos core/buttonBar.lua Layout 및 bars/petBar.lua NumButtons/AcquireButton/OnAttachButton/GetDisplayConditions/KEYBOUND_DISABLED를 실행했다. 30unit/inset1의 테스트 native slot과 NUM10에서 표의 alpha 외곽·첫 좌표·gap2 일치, 9/10번 스킬없음 숨김·PetHasActionBar=false 전부숨김·true복귀·native 첫슬롯 fallback·미존재시 조각보류 확인. 30unit/inset1/NUM10은 stub 입력이며 실제 게임 측정값이 아니다. 개인 설정·기능 writer 실행 없음.

추가 Python/Lua 비교 rc0 PASS 12개 PB4/FUF/Quartz/Dominos before/after profile의 pet/petTarget/Pet 하위만 바뀜, JSON pet4종과 다른 feature rect 교차0. FUF는 발주 예외에 따라 같은 generator pet 좌표만 반영했고 자동주입 금지는 그대로다. raw는 `_local_only/pet-alignment-vx6m6avg/{features.txt,lower.txt,preservation.txt}`. 생성기는 승인 폴더3/6/6-rev/7만 허용하는 wrapper로 실행하여8/9/10 쓰기0.

근거 원행: Dominos petBar.lua14–16 실제 native 슬롯 선택,75–90 개수/표시/스킨 등록,124–132 KEYBOUND_DISABLED; buttonBar.lua199–216 Hit inset/size,230–288 Layout; PB4 UnitFrame.lua571–603 layout×classification size/scale와 UIParent 상대좌표; 기존 Masque Core/Core.lua118–147,159–169 및 Normal.lua230–237의 실제36unit 기준/40unit 레이어 산식, 원본 Onyx128² alpha bbox8..120. 새 게임 관측이나 사용자 디자인 승인으로 기록하지 않는다.

### 이번 전문 정독 범위

동일 세션 적용 정책은 앞 A의 변경 영향/소유/주석/런타임·시각 원본 그대로이며 이후 compaction/resume 없음. 현재 발주·사용자 AGENTS 전문을 적용했다. JSON은 전체 설정 데이터, FUF 및 다른 Quartz 대응 조각은 기계 파싱으로 전체 before/after 꼴·값을 대조했다. 기존 보고·관련 코드 전문 범위(현재 완료 파일 기준 행수):

|파일|범위|
|---|---|
|`Collection/codex-briefs/appearance-3.md`|1–33|
|`Collection/codex-briefs/appearance-6-rev.md`|1–36|
|`Collection/codex-briefs/appearance-7.md`|1–33|
|`Collection/upstream/Dominos-12.0.4/Dominos/bars/petBar.lua`|1–192|
|`Collection/upstream/Dominos-12.0.4/Dominos/core/buttonBar.lua`|1–369|
|`Collection/AddOns/PitBull4/UnitFrame.lua`|1–917|
|`Collection/upstream/Quartz-3.8.0/Quartz/modules/Pet.lua`|1–131|
|`References/codex-appearance/3/dominos-profile.fragment.fhd.lua`|1–120|
|`References/codex-appearance/3/dominos-profile.fragment.qhd.lua`|1–120|
|`References/codex-appearance/3/dominos-profile.fragment.uhd.lua`|1–120|
|`References/codex-appearance/6-rev/pitbull4-profile.fhd.fragment.lua`|1–35|
|`References/codex-appearance/6-rev/pitbull4-profile.qhd.fragment.lua`|1–35|
|`References/codex-appearance/6-rev/pitbull4-profile.uhd.fragment.lua`|1–35|
|`References/codex-appearance/7/quartz-profile.fragment.qhd.lua`|1–20|
|`References/codex-appearance/3/AddOns/DevilForever_Skin_Dominos/Skin.lua`|1–44|
|`References/codex-appearance/3/layouts/qhd.lua`|1–1|
|`References/codex-appearance/2/Tests/generate-feature-fragments.py`|1–150|
|`References/codex-appearance/2/Tests/check-feature-proposals.py`|1–106|
|`References/codex-appearance/2/Tests/check-lower-proposals.py`|1–159|
|`References/codex-appearance/3/report.md`|1–91|
|`References/codex-appearance/6-rev/report.md`|1–29|
|`References/codex-appearance/7/report.md`|1–29|

실제 GUI/게임 보호 프레임/색·글꼴 육안 검증 미수행. 변경 사본은 parent before-pet-alignment-c3fea913와 scratch 사전 References/ 사본에 보존. 반환 뒤 편집 중지, 독립 B 인계.

## 원본 장식 alpha 회피 최종 좌표

최신 공유 원천 JSON에 부모/B가 alpha>0 및 nonpet/공통 셸 여백을 검색해 전달한 위치를 적용했다. 앞 소환수 열 표는 첫 교정 당시 기록이며 현재 배치는 아래 표가 우선한다. 크기·간격·native 표시 조건은 그대로다. 이 A는 원본 art alpha 검색 결과를 직접 검증했다고 주장하지 않는다. master renderer의 실제 art alpha clearance gate가 그 검증을 담당한다.

|해상도|petTarget [x,y,w,h]|pet|Dominos pet 기술바|Quartz pet|
|---|---|---|---|---|
|FHD|218,420,240,24|218,450,240,32|218,490,238,22|218,518,240,24|
|QHD|256,738,280,24|256,764,280,40|256,806,278,26|256,834,280,24|
|UHD|212,1470,360,34|212,1514,360,42|212,1564,358,34|212,1604,360,28|

최종 cast 하단은 FHD542(다음 focusTarget548), QHD858(866), UHD1632(부모 art visible1640). UHD 열 오른쪽572는 focus580과8px 분리된다. actual native 소비 최소 재시험: PB4 Refix24 oracle(player/target/pet/petTarget)·Quartz pet LibWindow6·Dominos actual ButtonBar/PetBar6,3해상도×factor.35/.64 모두 rc0 PASS. input fixture native slot30/inset1/count10은 실게임 관측값이 아니다. unrelated Hekili/Grid2/Details/StatusStrip 소비 시험을 반복하지 않았다. FUF는 같은 pet 좌표만 전파했고 자동주입 보류 유지.

`python _local_only/pet-art-verify-m_qo3s6i/check_correction.py` rc0 PASS, raw는 같은 폴더 runtime.txt. 첫 scratch runner가 UTF-8 지정 누락으로 rc1 cp949 decode 실패했으며 UTF-8을 명시하고 새 scratch에서 위 시험으로 정정했다. 제품 profile 오류로 통과를 주장하지 않았다. 별도 전체표 대조는 rc0 PASS12 profiles의 x/y만 변경·크기/내부 간격/비pet rect/조건 모두 보존·pet4종×3해상도 feature 교차0, raw `_local_only/pet-art-clearance-u4ab_xy6/preservation.txt`.

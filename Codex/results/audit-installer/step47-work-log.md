# Step 47 작업 A 기록

상태: 작업 A 구현·실행 완료, 독립 B 검수 대기. Git·게임·WTF·기존 ZIP·vendor는 수정하지 않았다.

## 변경 전 영향 지도

| 곳 | 필수 유형·찾는 방법 | 영향도·이유 |
|---|---|---|
| ChatSetup/ChatLayout/toc | 같은 규칙·식별자 전수 rg, 생성 이벤트·공개 함수·저장 DB 전문 | 함께 고침: 두 창 선확보·검증·원복·관리 좌표 영수증 |
| chatsetup/run.py, install/run.py 채팅 부분 | 잠근 시험·호출자·대역 입력 전문 | 함께 고침: 실패 보존과 배치 변경 실제 Lua 호출 |
| Core Edit/Presets, Appearance 픽셀 입력 | 앞단 입력 생성·프리셋 알림·배율 계약 | 확인만: 기존 callback과 UIParent 변환 사용 |
| NativeChat Skin, SessionProbe, Registry, install.json | 소비자·호출자·배포 구조 rg, NativeChat 전문 | 확인만: windows ID·created callback 유지, 새 영수증은 additive |
| FUFDefaults/toc/test | 같은 규칙·공개 API·잠근 시험·입력 대역 | 함께 고침: 세 해상도 native preset 입구 |
| FUF Init/Config/Storage/UnitProfiles/Commands/Boot 및 제안 3개 | 불려가는 쪽·입력 생성·기존 활성 profile·저장 수명 | 확인만: vendor 변경·SV 선기록 금지 |
| 과거 ZIP·Step46 기록·References proposal | 쌍둥이 사본과 과거 기록 검색 | 영향 없음: 과거 기록과 입력 보존, 새로운 runtime만 변경 |
| feature-map·설치 안내·접속 확인표 | 사용자 표면·같은 결정 이웃 문건 | 확인만: root 담당 |

단위 1은 routing transaction과 실패 시험, 단위 2는 receipt/reflow와 연계 시험, 단위 3은 FUF native 입구·기존값 보존 시험이다. 변경 전 사본은 before-step47 아래 root 보존본, install/run.py 사본은 scratch extra-backup.json으로 해시 확인한다. 실제 게임 성공은 미검증이다.

## 읽은 범위

복구: 활성 C:/Users/lksz1/.codex/AGENTS.md 1–154, 발주문·부모 메시지 전부, Step46 work-log 1–257, findings의 F46-01–06 구조·관측값. full-file/unit-loop/flow/session-division/impact/runtime/scope/comment 정책 전문. ChatSetup 1–265, ChatLayout 1–54, toc 1–10, chatsetup/run.py 1–449, install/run.py 1–207, NativeChat Skin 1–150, Core Edit 1–276. 마스터 계획·현행 Phase26.2는 이어 읽고 변경 경계를 대조한다.

## 실행

착수 시점에는 수정 후 시험을 실행하지 않았다. 최종 실행은 아래 실제 명령·판정 표를 따른다.

## 단위 1 · 채팅 routing transaction

두 목적 창과 메시지 추가/제거 API를 먼저 확보한다. 목적 구독을 읽어 확인한 후 source 구독을 제거하며, 명시 false·무효 처리·예외·두 번째 창 실패는 created로 기록하지 않는다. source 원복을 먼저 검증한 뒤 본인이 새로 만든 창의 추가 구독을 지우며, 비어 있는 자체 생성 창만 native FCF_Close 후보가 된다. 원복 실패는 rollback-failed로 남겨 목적 구독을 무작정 지우지 않는다. ChatFrame2와 기존 수동 분할은 보존한다.

원본 public geometry도 실패 시 이전 anchor/size로 되돌리고 읽어 확인한다. 위치·메시지 필터를 포함한 hidden slot을 먼저 검사하며, native allocator가 있으면 Open 호출 전에 후보가 예약한 빈 슬롯인지 대조한다. allocator가 없는 대역에서는 Open 반환 ID를 검증하지만 클라이언트 함수 자체가 기존 슬롯을 먼저 변경하는 동작은 외부에서 완전히 원복한다고 주장하지 않는다. default 템플릿 이름과 VOICE는 native reserved 수·실제 allocator를 함께 확인한다.

부모가 Forever 70938 mirror 원문을 직접 확인해 제공한 계약은 FCF_OpenNewWindow가 true 인자에서 기본 그룹을 추가하지 않으며, 초기화는 기존 입력·구독 기록도 비운다는 것이다. 이 A는 외부 호출하지 않았다. 기본 이름은 id1 GENERAL/id2 COMBAT_LOG/id3 VOICE/이후 CHAT_NAME_TEMPLATE:format(id)이다. 근거 URL은 부모 확인으로 구분한다: https://github.com/Gethe/wow-ui-source/blob/bebcb6bf309cf41b41bd74f8ca651e6a105b2676/Interface/AddOns/Blizzard_ChatFrameBase/Mainline/FloatingChatFrame.lua#L653-L699 및 #L917-L939. 실제 클라이언트 실행은 미검증이다.

## 단위 2 · 관리 위치 영수증

created 때 각 역할 ID·anchor·상대점·x/y·width/height·자체 scale·dock 상태를 저장한다. Core의 chat 편집 알림, 화면/배율 이벤트와 reload에서 영수증과 현재 geometry가 같은 역할만 새 프리셋에 맞춘다. 수동 이동·크기·dock 변경·실제 닫힘은 관리에서 해제한다. 도킹 public이 다른 탭 선택으로 숨겨진 경우에는 관리 기록을 유지한다. 필터는 변경하지 않는다. legacy created에 영수증이 없으면 자동 이동하지 않으며 read-only GetLayoutStatus로 상태만 제공한다. 같은 목표 geometry면 쓰기0이다. 새 reflow 배치 실패는 이전 geometry를 검증 원복하고 실패 상태를 남긴다.

## 추가 영향 지도 · 역할 ID 소비

| 곳 | 필수 유형·찾은 방법 | 영향도·이유 |
|---|---|---|
| NativeChat/Skin.lua·Nameplates/SessionProbe.lua | 부모가 실패 windows의 소비 경로를 찾음. 두 파일 전문 및 same identifier rg | 함께 고침: created에서만 저장 group/system ID를 역할로 사용. public1 fallback 유지 |
| chatsetup/run.py·install/verify_diagnostics.py | 잠근 시험·호출자·대역 입력 전문 | 함께 고침: 실패·in-progress·interrupted·no-free-window의 재사용 ID를 역할로 취급하지 않음 |
| db.windows·기존 실패 진단 | 입력 생성·쌍둥이 값·과거 기록 | 확인만: 진단 windows는 유지하며 소비 조건만 수정 |

부모가 이 세 파일의 추가 소유를 허용했다. 수정 전 사본과 해시는 scratch consumer-0..2.before 및 consumer-before-sha256.json에 있다. install/run.py는 읽기·실행만 했고 수정하지 않았다.

## 단위 3 · FUF native 비교 배치

기존 active/legacy/profile/raid에 geometry를 선기록하지 않는다. FUF native 공개 표면은 storage provider 등록과 slash command이며 프로필 clone/switch/원형 restore/readback 공개 API가 없다. 기존 Custom을 자동 수정·자동 원복한다고 주장하지 않는다.

새 LayoutPresets.lua는 원안의 세 해상도 물리 좌표 표와 공통 정수 변환을 제공한다. NativeLayout.lua가 해당 데이터를 실제 TOC 경로에서 읽어 geometry에 한정된 native set 명령 116개를 만든다. general theme/font/color와 enabled·오라·시전·raid는 이 입구의 변경 대상에서 제외한다.

명시 입구는 /fuf에서 현재 프로필을 별도 이름 DF Compare fhd, DF Compare qhd 또는 DF Compare uhd로 Save As·선택한 후 /dffuf layout fhd|qhd|uhd이다. 20초 대기 뒤·전투 밖·native 버전0.65.2·선택한 비교 이름·실제 최소 화면1920x1080/2560x1440/3840x2160을 검증한다. 더 큰 3862x2160은 허용한다. 부족/미확인 화면과 나머지 거절 조건은 현재 호출 전송0으로 기록·출력한다. 프리셋/배율 변경을 FUF에 자동 재적용하지 않으며 다시 명시 실행해야 한다.

명령은 공개 slash handler를 통해서만 보낸다. 예외·명시 false·전투/active 변경은 partial-failure이며 비교 프로필에 일부 변경이 남을 수 있다. 공개 readback이 없으므로 전송 완료는 sent-unverified, verified=false이다. silent native 거절을 런타임에서 성공으로 검증할 수 없다. 원래 프로필로 돌아갈 때는 /fuf의 native 프로필 선택을 사용한다. 비교 프로필을 원래 개인 프로필로 간주하지 말아야 한다.

실제 native Registry/Settings/Preset/Config/UnitProfiles/Storage/Commands를 대역에서 호출했다. 세 해상도 x2배율의 696 Config.Get 값이 계획한 정수 값과 같고 원래 Custom·Default/legacy·raid·themeSets/themeColors를 보존했다. native UnitProfiles.Switch를 통해 Custom width211로 복귀했다. adapter 로딩이 빈 SV의 macro read와 Storage waiting을 건너뛰지 않는 시험도 통과했다. 여기의 macro API는 시험 대역이며 게임 매크로에는 접근하지 않았다. 실제 프레임·secure 상태·스크린샷·보호 실행은 미검증이다.

## 실제 명령·판정

모든 명령은 D:/Projects/Project_WF에서 실행했다. 원출력은 _local_only/phase26-work-r151-20261119/step46-a/step47-nc88blh9/에 보존한다.

| 명령 | 판정 줄 | 원출력 |
|---|---|---|
| python -X utf8 -B -I Collection/tests/chatsetup/run.py | rc0; lupa=2.8 cases=24 passed=24 failed=0 | chat-voice-final.log |
| python -X utf8 -B -I Collection/tests/fufdefaults/run.py | rc0; lupa=2.8 cases=21 passed=21 failed=0; Native FUF geometry: 3 presets x2 scales; 696 native Config.Get values verified; original profiles preserved | fuf-report-final.log |
| python -X utf8 -B -I Collection/tests/install/run.py | rc0; Chat first layout: 3 resolutions × 2 scales; three roles, public dock and combat log preserved; PitBull4: actual RefixSizeAndPosition ran in Lua; eight unit rectangles x3 match the install layouts | install-final.log |
| python -X utf8 -B -I Collection/tests/install/verify_diagnostics.py | rc0; ten stages, pet present/absent/restricted, mixed-variant guard, coordinates and reports, no frame or setting writes | diagnostics-final.log |

처음 chat 실행은 기존 시험의 no-free-window DB exact 비교와 예외가 그대로 밖으로 퍼진다는 옛 기대 두 건 때문에 rc1(11/13)이었다. 새로운 원복 계약에 맞게 해당 기대를 수정하고 보존 시험을 추가한 뒤 통과했다. 화면 guard 추가 뒤 FUF 첫 실행은 pixel NaN이어도 유효한 새 physical-screen fallback이 동작해 옛 대역 기대 한 건이 rc1(19/20)이었다. pixel-unavailable 시험에서 fallback 입력도 없는 조건으로 바로잡고 통과했다. 제품 실패와 대역 기대의 변경을 구분한다. 최종 입력과 파일 해시는 changed-file-sha256.json에 있다.

부모의 독립 좌표 대조 _local_only/phase26-work-r151-20261119/step46-root/fuf-coordinates-parity.json은 raw 표 정리 뒤에도 기존 원안의 geometry 696값과 같다는 별도 근거다. 이 A의 실제 native 호출 시험과 혼동하지 않는다.

## 범위·다음

기존 ZIP·manifest·vendor·게임·WTF·매크로·Git commit/push는 변경하지 않았다. 새 ZIP 포함/해시 검사는 부모의 Step48 배포 작업에서 수행해야 한다. 실게임 PASS는 주장하지 않는다. 추가 해상도·Aura 항상 켜기·최종 유닛 프레임 선택·경험치 native 변경을 임의 구현하지 않았다. 코드 구조 변경이므로 독립 B의 연계·뜻·적대 검수에 반환한다.

## 최종 정독 범위

초기 코드 전문과 수정 diff를 대조했으며 변경 후 본문·호출 시그니처를 자연 단위별 확인했다. Core Edit는 실제 276행 전문, Presets 소비 callback은 기존 계약과 입력 표면을 확인했다. native Settings/Preset은 설정 DB로 전체 Lua 평가하고 필요한 geometry key의 registry 정의·scope·Validate를 실제 조회했다. Settings의 algorithm ownSizes·blocklist·shields·manaWarn 관련 본문을 읽었다. Settings 문건 전체 prose를 전독했다고 세지 않는다. Registry·Config·Storage·UnitProfiles·Commands·Init·Boot 전문과 세 원안 fragment/report 전문을 읽었다.

| 수정 파일 | 최종 읽은 본문 범위 |
|---|---|
| Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua | 1–324 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_ChatSetup/ChatLayout.lua | 1–181 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_ChatSetup/DevilForever_ChatSetup.toc | 1–10 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/tests/chatsetup/run.py | 1–688 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_FUFDefaults/FUFDefaults.lua | 1–171 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_FUFDefaults/LayoutPresets.lua | 1–68 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_FUFDefaults/NativeLayout.lua | 1–114 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_FUFDefaults/DevilForever_FUFDefaults.toc | 1–10 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/tests/fufdefaults/run.py | 1–579 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_Skin_NativeChat/Skin.lua | 1–151 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/AddOns/DevilForever_Skin_Nameplates/SessionProbe.lua | 1–167 (원문 또는 생성 본문과 해당 수정 diff) |
| Collection/tests/install/verify_diagnostics.py | 1–104 (원문 또는 생성 본문과 해당 수정 diff) |

master 계획 1–164, Phase26.2 당시 전문과 현재 1–38, NativeChat Skin 1–151, SessionProbe 1–167, diagnostics fixture 1–104, install/run.py 1–207을 입력·출력 소비 관점에서 읽었다. 현재 작업의 plan과 Step46 기록을 현행 적용 경계와 대조했다.

## 독립 B 보정 · 변경 전 지도

B는 숨김 기본명 슬롯의 메시지·입력 이력이 opener에서 지워진 뒤 실패 원복으로 복구되지 않는 결함과, 앞 역할 reflow 실패가 뒤 역할 성공에 덮이는 결함 두 건을 확정했다. 이번 추가 쓰기는 ChatSetup/ChatLayout/chatsetup 시험/이 기록뿐이다. 사전 사본·해시는 step46-a/step47-reviewfix-sa2lbbua/{0..3.before,before.json}에 있다.

| 곳 | 유형·찾는 방법 | 영향도·이유 |
|---|---|---|
| ChatSetup free 선택·activation·rollback | 같은 규칙/호출자/입력: 전문, native FCF opener/name/show/close 정독 | 함께 고침: Clear/ClearHistory를 호출하는 opener를 없애고 검증된 정확한 슬롯을 native name/show API로 활성화, 실패 시 name/show/tab/geometry 원복 |
| ChatLayout apply/GetLayoutStatus | 출력 소비·호출체인 전문 | 함께 고침: 역할별 결과와 최악 상태 집계, 실패가 후속 성공에 덮이지 않음 |
| chatsetup/run.py | 잠근 시험·native API 대역 입력 전문 | 함께 고침: message/draft/input history, 전후 슬롯 상태와 앞/뒤 역할 실패 반증 |
| install/run.py 채팅 verify | 동일 대역을 사용하는 직접 소비자 | 확인만·실행: 이름·show API fixture 변경은 공통 STUBS에서 공급 |
| 기존 ZIP·후속 문서·FUF·Skin/SessionProbe | 쌍둥이/기록/외부 소비 rg | 영향 없음: 이번 소유 밖, role-ID/기존 status 필드 계약 유지 |

새 native 원문을 Invoke-WebRequest로 scratch에 받으려 했으나 DNS 오류 rc1이었다. web 도구의 고정 commit 원문으로 필요한 함수·호출 순서를 정독했다. GetHistoryLines는 사용 개수가 아니라 용량이므로 이력 없음 판정으로 쓰지 않는다. 이번 수정은 이력 API를 읽거나 복사하지 않고 이력 삭제 경로 자체를 호출하지 않는 방식이다.

## 독립 B 보정 · 결과

FCF_OpenNewWindow와 FCF_Close 호출을 제거했다. free 후보에서 정확한 두 프레임을 순서대로 선택하고 양쪽 API·tab·geometry를 먼저 저장한다. native FCF_SetWindowName, FCF_CheckShowChatFrame, SetChatWindowShown으로 활성화하며 원래 font/color/lock·메시지·입력 초안·입력 이력은 초기화하지 않는다. native 탭과 메시지 수신은 유지하고 기존 place 경로로 비도킹 위치를 설정한다. 다른 후보가 먼저 있는 native allocator에도 의존하지 않아, 보호한 사용자 슬롯을 건너뛸 수 있다.

실패 시 native 이름·저장 표시 상태·프레임/tab 표시·크기·모든 anchor를 되돌린다. source 구독 원복이 실패한 경우는 목적 창을 숨기지 않는다. 목적 창의 남은 수신 경로·이름·표시를 유지하고 rollback-failed를 기록한다. public 복원도 공통 all-anchor helper로 바꿨다. B 발주 두 건과 부모가 연결 확인한 원복 실패 시 수신 경로 보호가 이번 변경 범위다.

reflow 결과는 current < applied < failed-restored < restore-failed 순서로 집계한다. GetLayoutStatus의 기존 필드는 유지하며 roles 표에 적용/해제/복원 실패 결과를 추가한다. 앞 public 실패와 마지막 system 실패를 각각 주입했으며 뒤 성공이 전체 실패를 지우지 않는다.

같은 최종 fixture의 두 반증을 변경 전 사본에 실행했다. before-reproduction.json에서 메시지 보존 기대1이 실제0, failed-restored 기대가 실제applied로 각각 RED였다. 보정 후 최종 chat suite는 rc0, lupa=2.8 cases=28 passed=28 failed=0이다. 메시지/입력초안/입력 이력은 정상·구독 추가 실패·둘째 활성화 실패 모두 보존됐다. source Add 실패 뒤 목적 GUILD가 보이는 상태를 유지하고 public 다중 anchor 복원도 통과했다.

실행 명령은 python -X utf8 -B -I Collection/tests/chatsetup/run.py이며 원출력은 step46-a/step47-reviewfix-sa2lbbua/chat-final-28.log다. 직접 연계만 실행한 명령은 python -X utf8 -B - (stdin에서 runpy.run_path('Collection/tests/install/run.py')['verify_chat'](Path('Collection').resolve()))이며 rc0, Chat first layout: 3 resolutions × 2 scales; three roles, public dock and combat log preserved 및 Chat existing message filter retained, including the Appearance-disabled fallback 두 판정 줄을 얻었다. 원출력은 install-chat-final.log다. 전체 Core/FUF/ZIP 시험은 이번 보정에서 반복하지 않았다.

보정 정독: ChatSetup 1–324, ChatLayout 1–181, chatsetup/run.py 1–688, 이 work-log 보정 전 전문을 다시 읽고 수정 본문·호출체인을 대조했다. native 고정 commit bebcb6bf309cf41b41bd74f8ca651e6a105b2676의 FloatingChatFrame.lua 653–700(opener),916–953(name),1142–1172(fade),1421–1460(button side),1537–1550(undock),1606–1610(tab),1633–1663(close),1913–1915(show)를 web 원문으로 정독했다. 직접 활성화는 native의 파괴적 초기화·docking을 생략하고 비도킹 두 창의 name/show와 기존 geometry를 사용한다. actual client event·protected state·입력 동작은 미검증이며 실제 표시를 대역 PASS로 주장하지 않는다. before.json·after-final.json에 각 사본/최종 해시와 행 수를 보존했다.

추가 파일·FUF·원본 vendor·기존 ZIP·설치 안내·게임·WTF·매크로·Git 변경은 하지 않았다. 같은 B 재확인에 반환한다.

## Step48 보정 · 최신 설치 묶음 링크

수정 전 영향 지도: one-session-review.md의 최신 설치 묶음 링크와 비교판 파일명은 함께 고침(현재 한 접속 절차의 배포 입력). Step48 결과와 reviewed-packages.json은 입력 생성·같은 ZIP 이름·해시 소비 기준으로 확인만. 마스터의 Step48 연결·원래 접속 절차·historical Step40 원문·ZIP 실물은 확인만/영향 없음이며 수정하지 않는다. 같은 표현 검색과 상대 경로 해석으로 연결을 확인한다. 사전 사본/해시는 D:/Projects/Project_WF/_local_only/phase26-work-r151-20261119/step46-a/step48-linkfix-6wbbhmee/0.before·1.before·before.json에 보존했다.

최신 설치 묶음은 Step48 결과로, 실제 ZIP 경로·해시는 reviewed-packages.json으로 연결했다. 같은 문단에 기본 DevilForever-0.1.0.zip 및 비교 DevilForever-0.1.0-one-session.zip을 명시했다. 문건은 7행만 달라지고 나머지 접속·백업·비교 절차는 유지한다.

검증 명령: python -X utf8 -B -I _local_only/phase26-work-r151-20261119/step46-a/step48-linkfix-6wbbhmee/verify.py. 판정 rc0, changed-line=7 only; latest Step48/JSON links=2; ZIP names/artifacts=2; remaining procedure and prior work-log preserved. 원출력은 같은 scratch의 verify.log다. ZIP 재빌드·내용 수정·게임·Git·네트워크 호출은 수행하지 않았다.

이번 정독 범위: References/codex-verify/one-session-review.md 1–52, Codex/results/audit-installer/step47-work-log.md 1–134, Codex/plans/2026-11-19-devil-forever-audit-and-installer-plan.md 1–165, Codex/results/Step 48 — 검토한 ZIP과 기능 기준 확정.md 1–31. reviewed-packages.json은 전체 파싱해 packages 세 변형·zip/localArtifact/sha256·installerAccepted와 gameObserved를 확인했다. 수정 문단의 실제 파일명·상대 링크를 수용 기준과 대조했고 같은 B 재확인에 반환한다.

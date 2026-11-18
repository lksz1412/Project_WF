# Forever 채팅 외형·기본 입력 보존 조사 — Step4

상태: Step4 분석·자체 G4·독립 10관점 검수 수용 완료(중대0·중간0·경미0). 설치·게임 설정·게임용 코드는 작성하거나 적용하지 않았다. 모든 실제 게임 검증은 미수행이다.

사용자가 원하는 것은 **독립 대화창 세 개의 분류와 기본 입력은 유지하면서 버튼·제목·입력창 장식과 과도한 글자 크기를 줄이는 것**이다. 옛 배포본의 채널 분담·창 번호를 복사하지 않는다. 시각 기준은45실제샘플4이며11218의 오른쪽 미터기는 세 번째 대화창으로 유지할 위치다.13140은 현재 수정 구성 참고다.4K에서는 버튼·행·간격을 아래부터 쌓으며 전체 화면 비율을 환산하지 않는다. 근거: REQUEST_LEDGER_phase1.3.md:10–27, 수용된 Step3 보고서:5/188–192.

**분석 권고:** 기본 대화창 세 개와 기본 입력을 유지하는 작은 외형 테마를 우선 설계한다. 현재 소스에서 버튼·탭·입력 테두리·폰트·크기를 줄이는 기전이 확인됐다. 기존 제품을 쓴다면 Prat를 조건부 대안으로 두되, 아래의 메시지·입력 개입과 부가 기능을 함께 평가해야 한다. 어느 후보도 지금 설치하거나 작동 보장으로 채택한 것은 아니다.

## 원천과 판정 범위

조사일은2026-11-18이다. 공식 배포 페이지·파일별 정보와 연결된 공식 저장소의 실제 릴리스 코드를 대조한다. 최근12개월은 발견 범위이며 현재 배포되는 관련 구판도 날짜를 남겨 다룬다. 제작자 지원 표기, 실제 source의 기전, 이 PC에서의 작동은 각각 다르다. 표의 **코드 확인**은 정적으로 읽은 기전이며 실제 작동 통과가 아니다. 선언은 제작자 표기, 제안은 A1 설계 판단, 미검증은 시험하거나 확인하지 않은 부분이다.

CurseForge 네 main 주소의 일반 GET과 네 파일별 다운로드 요청은403이었다. 공개 web 원문과 공식 GitHub 릴리스로 정상 대체했으며 실패 기록을 보존했다. 확보한 세 GitHub ZIP는 별도 안전 추출·손상 검사 뒤 정적 독해만 했다. Chattynator ZIP는 확보하지 못했다. 원문 위치·취득 시각·URL·해시와 파일별 읽은 범위는 `clean-chat-source-evidence.md`, `clean-chat-code-read-coverage.json`, `clean-chat-acquisition/`에 있다. CF(CurseForge) ZIP와 GitHub ZIP의 바이트 동일성이 확인되지 않은 경우 따로 표시한다.

## BasicChatMods에서 실제 확인한 범위

[공식 파일 v12.1.2](https://www.curseforge.com/wow/addons/basic-chat-mods/files/9632459)는2026-11-15, file9632459, Forever·1.60.1을 명시한다. main의v12.1.1/10월22일 표기는 오래된 캐시다. [공식 GitHub 릴리스](https://github.com/funkydude/BasicChatMods/releases/tag/v12.1.2)의 ZIP를 읽었고, 동봉release.json은 forever/interface16001을 명시한다. tag commit은`5be793bade7743834b3fae361638f86aa370d31d`. ZIP52,927B·SHA256(파일 내용 해시)`748D2447E1932E5543126208A9E4BBB22AB3A6ECE7FA2C4B0D92C5AF1EFB775C`, 안전 추출38파일/145,398B다. CF ZIP와의 바이트 동일성은 미검증이다.

TOC(파일 로드 목록)64행, core208행, config852행과 관련 모듈10개를 끝까지 읽었다. 아래경로는 해당GitHub릴리스의BasicChatMods폴더다.13파일의 정확한 해시·읽은 행은 근거 기록에 있다. mainline/classic 로드 조건이 있어 두 버튼·fade 구현을 모두 읽었지만 현재 Forever가 선택하는 분기와 이 PC 작동은 미검증이다.

| 요구 | 코드에서 확인한 것 | 한계 |
|---|---|---|
|기본 창·입력·세 역할 |BasicCore125–155는 기존ChatFrame1–10,158–185는 임시 창도 처리 |대화창을 새 transcript로 교체하지 않지만 원하는 세 역할을 자동 구성하는 것은 아님 |
|좌측 버튼 |buttons9–27/Classic9–30에 메뉴·일부 소셜/음성·창 ButtonFrame 숨김과 재표시 hook |분기별 버튼 대상 다름, 전체 상태에서의 작동 미검증 |
|탭·제목 |fade50–60/163–195의 hover·알림·이동·resize 상태별 alpha |평소 숨기고 필요할 때 표시하는 기전. 항상 숨김과 다르며 스크롤 복귀 버튼은 별도 |
|입력창 |editbox10/14–27: 기본 입력 유지, classic chatStyle, 위/아래 배치·기본 테두리 제거·scale |입력창 자체 제거 아님. chatStyle 변경·실제 한글 입력 상태는 별도 검증 |
|폰트·크기 |font19–20/config443–543: 본문·입력 글꼴/outline·6–20크기, koKR 경로 |큰 한 가지 폰트 강제 아님. 실제4K 가독성·font 존재는 미검증 |
|창 위치·크기 |core199–204의 화면 가장자리 clamp 해제,resize10–15의 최소100×10 |native 잠금·저장·재접속 보존은 별도 검증 |
|분류·필터 |읽은 core·외형 모듈 경로에는 창별 group/channel 초기화 호출이 없음 |미독 부가 모듈까지 포함한 전체 동작·현재 필터 보존의 통과 주장 아님 |
|배경·클릭 |fade16–29는 기존 배경 alpha를 이용 |Devil 구획의 별도 반투명 배경·입력 통과는 작은 테마 제안과 후속 확인 영역 |

**통째 적용의 부수 동작은 남는다.** BasicCore129–130/172–173은 키 편집 모드를 바꾸며, 기존 historyBuffer 문자열을 다시 처리하고 새 문자열 추가를 hook한다. history6에서 History 옵션을 꺼도 곧바로 반환하지 않고61–107의 재시작 직전 최대5줄 저장 경로가 등록된다. 이는 config157–197의 선택적 일반 채팅 로그 옵션과도 다르다. 따라서 “비시각 모듈을 끄면 표시·입력·저장 부작용이 모두 없다”고 판단하지 않는다. 이 작업에서 실제 채팅 기록이나 개인 데이터를 읽거나 저장 기능을 실행하지 않았다.

이 후보는 **기본 창을 유지한 채 외형을 줄이는 구체적 기전**을 보여 준다. 다만 통째 설치를 순수 외형 변경으로 권하지 않는다. 원본 코드를 복제하거나 fork를 만드는 발주도 아니다.

## 네 후보의 정확한 현재 배포·원천

다음 파일은 모두 Forever·1.60.1 표기를 확인한 파일이다. 날짜는 파일 등록일이며 프로젝트 전체 최종 수정일과 다르다. 취득 시각·공식 주소·해시는 `clean-chat-acquisition/CURRENT_ACQUISITION.json`과 보존 영수증에 있다. BCM은 BasicChatMods의 약칭이다.

| 제품·저자 표기 | 정확한 CF 파일·날짜 | 실제 정적 원천 | 확인 한계 |
|---|---|---|---|
|BCM / Funkeh |[9632459·v12.1.2](https://www.curseforge.com/wow/addons/basic-chat-mods/files/9632459),2026-11-15 |공식 funkydude/BasicChatMods 릴리스·commit5be793b…,52,927B |main 캐시v12.1.1과 구별. CF ZIP 바이트는 미확보 |
|Prat / TOC의 QartemisT·기존Sylvanaar |[9509040·3.9.117](https://www.curseforge.com/wow/addons/prat-3-0/files/9509040),2026-11-08 |[공식 릴리스](https://github.com/Legacy-of-Sylvanaar/prat-3-0/releases/tag/3.9.117),commit3b02cf8…,1,547,917B |release.json Forever16001·TOC 일치, CF ZIP 바이트 동일성 미검증 |
|Glass Forever / Rethz, 원저자mixxorz |[9653501·1.1.6](https://www.curseforge.com/wow/addons/glass-forever/files/9653501),2026-11-16 |[공식 v1.1.6-forever tag](https://github.com/NelsonAbrantes/Glass-Forever/tree/b1c9309654449523fbb55b21e94f536db1cea3e8),276,298B |배포 ZIP 대신 tag source. README42에서 필요한 libraries가 빠졌다고 명시, 설치 준비본 아님 |
|Chattynator / plusmouse |[9648836·237](https://www.curseforge.com/wow/addons/chattynator/files/9648836),2026-11-16 |제작자 설명·파일 정보만 확보 |공식 연결 저장소/API404·다운로드403. commit·구현 미확보 |

세 ZIP는 `SourceArchive/current-chat-2026-11-18/originals/`에 보존했으며 source/copy 해시3/3이 같다. BCM·Prat는 공식 release, Glass는 tag source임을 구별한다. CF와 GitHub 바이트가 같다는 뜻은 아니다. 이미 통과한 손상 검사·추출은 재실행하지 않았다. Chatty의 마지막 정상 CDN(Content Delivery Network, 배포 파일 서버) 확인에서도 실제 링크·공식 경로 규칙을 찾지 못해 임의 주소를 만들지 않았다. 정상 공개 파일이 없다는 단정은 하지 않는다.

## 기본 창·분류·입력 보존 비교

아래 **코드 확인**은 정적으로 읽은 해당 기전, **선언**은 제작자 설명, **미검증**은 아직 확인되지 않은 부분이다. 이 표의 기전 확인을 요구 전체 충족이나 실제 게임 통과로 읽지 않는다. Prat는18파일, Glass는8파일을 전문으로 읽었으며 전체 애드온 감사는 아니다. 파일별 해시·행과 짧은 원문 인용은 근거 기록에 있다.

| 요구 | BCM | Prat | Glass Forever | Chattynator |
|---|---|---|---|---|
|기본 메시지창·입력 |**코드 확인:** 기존 창·입력 유지. 키·버퍼 변경 있음 |**코드 확인:** 기존 창·입력 유지, 메시지 proxy·이벤트·송신 전 처리에 개입 |**코드 확인:** docked 메시지는 새 renderer, 분리창은 native로 돌려주는 혼합. 입력 컴포넌트는 미독 |**선언:** 대화창을 새 창으로 완전히 교체 |
|독립 세 역할·전투·임시 창 |**미검증:** 기존10창·임시창 경로는 있음 |**미검증:** 전투창 제외·임시창 등록 경로는 있음 |**미검증:** 분리·재결합·전투창2 처리 경로는 있음 |**근거 미확보:** 구현을 받지 못함 |
|창별 group/channel 분류 |**미검증:** 읽은 외형 경로에서 reset 없음, 전체 보존 보장 아님 |**미검증:** event filter 호출은 있으나 전체 분류 동등성 미확인 |**코드 확인:** 초기 Guild/Party 제안을 수락하면 General 분류를 옮김. 자동 무조건 reset과 구별 |**미검증:** 계정 공통 설정 선언만 있음 |

Prat의 `addon/addon.lua:71–76`은 Forever를 명시적으로 구분한다. 같은 파일411–448은 수신·입력·링크 hook,467–523은 입력 처리,581–741은 원래 handler를 proxy로 부른 뒤 메시지를 재구성한다.437행의 DummyFrame은 출력 포착용이며 새 화면 transcript로 해석하지 않았다. `MessageEventHandler.lua:41–46`의 event filter 처리만으로 창별 group/channel 보존을 입증하지 않는다. 미독 `chatsections.lua`, `Memory.lua`와 다른 formatter까지 포함한 전체 동등성은 미검증이다.

Glass의 `UIManager.lua:560–568/750–763/1042–1051`은 별도 메시지 표시와 기본 창 숨김을 연결한다.669–800에는 분리창·전투창 처리,876–887에는 임시창 처리가 있다. `DefaultTabs.lua:61–81/129–134`는 사용자가 생성 제안을 누른 경우만 Guild/Party group을 새 창으로 옮기며,153–169는 조건부 whisper mode 변경이다. 이 배포자 분담을 사용자 채널 선택으로 채택하지 않는다.

## 외형 요구별 비교

| 요구 | BCM | Prat | Glass Forever | Chattynator |
|---|---|---|---|---|
|좌측 버튼·스크롤 복귀 |**코드 확인:** 버튼 숨김·분기 차이·복귀 상태 처리 |**코드 확인:** 메뉴/소셜/voice/channel/minimize 개별 선택. ModernAPI에서 화살표 분기 다름 |**선언:** 버튼·외형 제공, 생성 연결/defaultfalse는 확인. 상세 컴포넌트 미독 |**근거 미확보:** 정확한 버튼 정책 |
|탭·제목 |**코드 확인:** hover·알림·조정 중 표시 |**코드 확인:** 창별 숨김/항상 표시·alpha·질감·글자 크기. ChatTabs 기본off, 알림 예외 |**선언:** custom 탭 style/fade. 알림 때 dock 표시 연결 확인 |**근거 미확보:** 정확한 탭·hover 정책 |
|입력 테두리·배경·위치 |**코드 확인:** 기본 입력 테두리 제거/위아래/scale; chatStyle 변경 |**코드 확인:** 기존 입력에 별도 backdrop, 위/아래/free/lock·색·edge/inset. Alt/화살표 동작도 바꿈 |**선언:** 입력 style. chatStyle 강제 변경은 코드 확인, 입력 구현 미독 |**미검증:** 기본 입력 보존·장식 제어 |
|폰트·글자·outline |**코드 확인:** 본문·입력6–20, koKR 경로 |**코드 확인:** 본문 창별4–100·face/outline, 입력face 별도 |**선언:** 폰트/크기, 기본값만 코드 확인 |**선언:** 폰트/크기 |
|창 크기·위치·잠금·저장 |**코드 확인:** min100×10·가장자리. 저장/잠금은 미검증 |**코드 확인:** resizebounds/가장자리, 입력free/lock 저장. 기본 대화창 잠금·재접속은 미검증 |**선언:** EditMode·크기/위치, 분리창 저장 hook 확인. 상세 조절·재접속 미검증 |**선언:** 자유 이동/크기. 잠금/저장 미검증 |
|반투명 배경·클릭 통과 |**미검증:** 기존 배경 alpha 기전만 확인 |**미검증:** 배경 texture/color/alpha는 확인 |**선언:** 메시지 배경. 클릭 통과 미검증 |**근거 미확보:** 요구한 정확한 배경/입력 통과 |

Prat의 외형 근거는 `Buttons.lua:174–271/353–441`, `ChatTabs.lua:350–441/586–594`, `Editbox.lua:334–440/486–516/540–635`, `Font.lua:235–281`, `ChatFrames.lua:286–327`이다. 입력창을 없애는 기능과 장식만 줄이는 기능은 다르다. 입력 alpha·마우스를 숨겼다가 활성화하는 hook이 있으므로 실제 Enter·한글 IME(Input Method Editor, 한글 조합 입력)·포커스 확인이 필요하다. Free 입력 위치는 루프에서 공통 저장값을 쓰므로 세 입력창을 각기 자유 배치한다고 확대하지 않았다.

**부가 기능은 외형과 별도다.** Prat는 core부터 메시지·입력·링크 처리에 개입하고 여러 모듈이 기본on이다. History33–45의 `savehistory=false`는 명령 기록의 기본값일 뿐, 미독 ChatLog·Scrollback을 포함한 저장 부작용0의 증거가 아니다. Glass도 기본 데이터에 history/whisper/spam/arrow 옵션이 켜져 있으며 해당 구현은 이번에 전독하지 않았다. Chatty는 제작자가 입력 기록·2,500개 이상 메시지의 세션 간 보존과 계정 공통 설정을 선언한다. 기존 hyperlink·복사·기록 동작의 동등성은 후속 검증이며, 실제 개인 채팅 데이터를 열거나 저장하지 않았다.

**Glass의 현재 명시 한계:** instance 안에서 일부 메시지 text가 애드온에 숨겨져 emote·timestamp·icon을 적용할 수 없고 긴 메시지가 다음 메시지와 겹칠 수 있다고 제작자가 적었다. [현재 공식 설명](https://www.curseforge.com/wow/addons/glass-forever), 보존원문 sourceL209–211. 이 한계는 직접 재현한 시험 결과가 아니며, 미독 renderer를 읽은 것처럼 설명하지 않는다. 깔끔한 외형만 보고 기본창 보존의 우선 후보로 삼기 어려운 이유다.

## 현재 V42가 실제로 맡긴 채팅 구성

현재 참고 통합본에는 **Leatrix Plus1.60.30**이 있고 `!DevilUI/load_Profile.xml:9`가 해당 profile을 부른다. TOC 세 개·XML 두 개·199행 profile을 끝까지 읽었다. profile124의 NoChatButtons=On,153의 ShowChatMenuButton=Off,184의 UnclampChat=On은 저장 옵션이다. MoreChatFontSizes/MoveChatEditBoxToTop/UseEasyChatResizing은Off여서 저장된 font20을 현재 적용 크기로 단정하지 않는다.

Leatrix core22,111행은 이번 판단의 근거로 채택하지 않았다. 먼저 전문으로 읽었던 Library1,437행도 함수 정의가 core에서 실제 활성화됨을 증명하지 않는다. 따라서 V42가 어느 옵션을 선언·포함하는지는 확인했지만 버튼·탭·입력·필터 보존이 실제로 구현·작동한다고 확정하지 않는다. 반대로 미독을 이유로 불가능하다고도 하지 않는다. Step3에서 확인한 V42 설치기의 group/channel·uiScale 초기화는 현재 사용자 설정 보존 설계와 구별한다. V42는 여전히 참고용이고 목표 외형은45샘플4다.

## 권고할 담당 구조와 남은 검증

**우선안은 작은 native 외형 테마다.** 기존 대화창·입력·메시지 분류를 엔진으로 유지하고 외형만 한 곳에서 담당하도록 설계한다. 현재 BCM·Prat 소스가 기본창에 폰트·테두리·버튼·크기 조절을 적용하는 기전을 보여 주므로, 화면 전체를 교체해야만 깔끔해진다는 근거는 없다. 다만 새 테마가 현재 PC API(Application Programming Interface, 애드온이 사용하는 게임 기능)에서 전부 가능하고 작동한다는 판정은 아니다. 다음은 설계 범위이며 이번에 구현하지 않았다.

| 영역 | 우선안 담당 | 기존 제품을 택하는 대안 |
|---|---|---|
|메시지 분류·송신·입력 |기본 채팅 엔진·기존 창별 설정 |동일 보존 기준으로 검증. 옛 창번호/채널 reset/import 제외 |
|버튼·탭·입력 장식·폰트·허용 크기 |작은 테마 한 개 |Prat 한 개를 조건부 외형 담당으로 검토. 같은 영역의 BCM/Glass/Leatrix 중첩 제어 배제 |
|Devil 반투명 사각 구획·얇은 구분선 |비입력 장식 담당 한 곳 |Prat가 제어하는 입력/탭/폰트는 다시 제어하지 않고 부족한 구획만 연결 |
|창 위치·잠금·저장 |기본 창의 저장 체계와 외형 담당의 연결 |입력·EditMode·전투·재접속 검증 뒤 확정 |

Prat는 조절 폭과 명시적 Forever 분기가 있어 **기존 애드온을 활용하는 조건부 대안**으로 남긴다. 외형 검토 대상은 Buttons·ChatTabs·Editbox·Font·Frames이며 ChatTabs는 기본off다. 이 구성을 그대로 적용하라는 뜻은 아니며 입력 키 정책·History/ChatLog/Scrollback/Memory·formatter를 따로 판정해야 한다. 모듈을 줄여도 core의 메시지·입력 hook이 남으므로 무부작용을 보장하지 않는다. BCM은 특히 History off로도 남는 reload 저장 경로 때문에 같은 수준의 무부작용 대안으로 단정하지 않는다. Glass는 혼합 renderer와 instance 한계, Chatty는 교체 선언과 미확보 구현이 있어 우선안으로 강제하지 않는다. 이는 A1의 설계 판단이며 제품 지원 불가 판정이나 새 source fork 요청이 아니다.

숨김의 기본 설계는 평상시 장식을 줄이고 입력·알림·스크롤 복귀·설정 조작이 필요한 순간 접근할 수 있게 하는 것이다. 항상 숨김과 hover/알림 표시의 선택은 구별한다. 사용자 필터를 모르는 상태에서 길드·파티 등 분담을 만들지 않고, 기존 값이 있으면 보존한다. X2의1/2/3과 Alpha의1/3/4를 복사하지 않으며 현재 전투창2와 세 독립 메시지 역할을 구별한다.4K 버튼·행·간격은 아래부터 쌓는 후속 배치에 연결한다.

다음 게임 검증10개는 모두 **미수행**이며 `clean-chat-runtime-gates.json`의 actualResult도 전부 NOT_RUN이다. Step4의 문서·source 확인을 이 시험의 통과로 세지 않는다.

| 검증 | 필요한 확인 |
|---|---|
|실제4K·배율 |실제 render/UI scale과 하단 높이, 전체 비율 자동 이식 없음 |
|세 독립 역할 |세 창·docking·전투창·임시 귓말의 역할 충돌 없음 |
|분류 보존 |창별 group/channel 전후 대조와 허용/제외 메시지의 실제 도착 |
|기본 입력 |Enter·slash·채널 변경·Escape·화살표/history·한글 조합·focus |
|장식 상태 |평상시·hover·입력·알림·스크롤 복귀와 설정 접근 |
|글꼴·크기 조정 |한글 가독성·outline·resize/move/lock |
|저장·재접속 |reload/relogin 뒤 배치·분류 유지, uiScale/profile reset 없음 |
|링크·마우스 |item/hyperlink·선택한 복사 기능·장식 클릭 통과 |
|전투·오류 |전투 진입/종료·임시 창에서 Lua/taint/금지 동작 없음 |
|단일 담당·복원 |동일 영역 중첩 없음, 실패 부분은 승인된 백업으로 복원 |

실제 확인 범위는 공식 네 후보의 파일·설명, 확보한 세 소스와 V42의 제한된 로드/profile, 선택46개 파일의 전문 독해다. 모든 제품 파일·현재 API·미독 모듈·개인 필터를 검사했다는 뜻은 아니다. `clean-chat-requirement-matrix.json`은12요구×4후보48칸에서 근거와 한계를 따로 보존한다. Chatty 구현 미확보·CF/GitHub 바이트 동일성·Leatrix core·실제 세 창/입력/필터·자산 사용권한은 미확인으로 남긴다. 독립 검수 전 전달용 최종 수용을 주장하지 않는다.

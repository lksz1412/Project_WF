# 대화창 외관 사전 준비

후속 사용자 지시로 앞선 native 우선 설계를 적용했다. 현재 설치 후보는 `DevilForever_Skin_NativeChat`이다. Prat skin과 namespace 제안은 비교 기록으로 보존한다. 새 native skin의 근거로 `Codex/docs/forever-clean-chat-research.md:1–116` 전문을 읽었다.

native skin은 역할 창의 글꼴과 기본 장식 alpha만 다룬다. 평상시 탭·좌측 버튼을 줄이고 hover·입력 focus·알림·위로 스크롤한 상태에서 접근을 되살린다. 기존 OnEnterPressed·OnTextChanged를 교체하지 않고 메시지·입력 내용을 읽지 않는다. Combat log2와 임시창은 제외한다. Blizzard client 구조가 아직 실측되지 않은 버튼·입력 장식은 존재할 때만 처리한다.

`python -I References/codex-appearance/4/AddOns/DevilForever_Skin_NativeChat/Tests/run.py`는 실제 공통 Core와 Lua5.1 Frame stub에서 exit0이다. 기존 send/IME script·분류 표 보존, idle/hover/focus/alert/scroll, 전투 지연, 위치·크기 변경0, 중복 hook0을 확인했다. 실제 한글 조합·native 프레임 구조·전투 검증은 접속 후 확인한다.

public·group·system 역할을 각각 왼쪽 첫 창·왼쪽 둘째 창·오른쪽 셋째 창에 놓는 세 해상도 값이다. ChatFrame 번호는 저장 변수 windows에서 읽고 전투 기록 창 2는 제외한다. 자리·크기 조각은 UIParent 배율이 확정된 최초 배치 시점에 계산한다. 부모 조립 단계가 ChatSetup의 첫 생성 경로에 연결한다.

Prat namespace 값은 좌측 버튼 더미와 평상시 탭 질감, 입력 테두리를 줄인다. ChatTabs는 기본 꺼짐이어서 on=true를 제안했다. 탭은 평상시 투명하고 마우스를 올리면 나타난다. 스크롤 복귀 알림은 기존 기능을 유지한다. skin은 입력 문자·history·화살표·포커스·채널 분담을 다루지 않는다.

공통 appearance.chat1/2/3의 font를 실제 역할 창에 적용한다. 현재 native skin의 글자 크기는 물리 목표×PixelUtil factor÷각 대상 frame 실효 배율로 맞춘다. 첫 PLAYER_ENTERING_WORLD 후 4초에 한 번 더 적용해 ChatSetup의 3초 생성 지연 뒤를 처리한다. 기존 창의 자리는 runtime에서 덮어쓰지 않는다.

## 영향 지도

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| appearance-4·2-layouts | 같은 규칙 | 전문 | 확인만 | 역할/초기 배치/세 해상도 계약 |
| ChatSetup.lua 1–233 | 입력 생성·호출 흐름 | 전문 | 확인만 | 생성 지연과 windows 역할 map |
| Prat Buttons 1–445·Font 1–330·ChatTabs 1–598·Editbox 1–646·ChatFrames 1–335 | 실제 소비처 | 전문 | 확인만 | namespace key·탭/글꼴/배경 API |
| 이 폴더의 profile·chat-windows 조각과 Skin.lua | 생성본·호출자 | 신규 작성 | 함께 작성 | master 통합 입력 |
| Core Defaults/Prat-3.0.lua 1–38 | 쌍둥이 기능값 | 전문 | 확인만 | History·Memory와 충돌 없음 |
| 기존 ChatSetup 시험 | 잠근 시험 | API·기존 suite 경로 확인 | 확인만 | 기능 생성 코드 수정 없음 |

세 해상도 게임 화면·한글 입력·hover·재접속 확인은 남아 있다. first-placement 조각만 미리 평가해 UI scale을 값으로 저장하지 말고 실제 배치 시점에 평가해야 한다.

최종 native production 연결은 optional `DevilForever_ChatSetup:RegisterWindowsCreated(owner,apply)`가 성공 직후 호출하도록 받는다. 4초 timer보다 늦은 전투 지연 생성도 Lua5.1에서 확인했다. Prat 비교 코드는 candidate에 포함하지 않는다.

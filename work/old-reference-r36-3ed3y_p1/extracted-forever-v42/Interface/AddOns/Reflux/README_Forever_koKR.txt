Reflux 1.17-Forever-v1
WoW Forever 1.60.1 / Interface 16001

/reflux help
명령 도움말을 표시합니다.

/reflux switch 프로필 이름
로드된 AceDB 애드온들을 해당 프로필로 전환한 뒤 UI를 다시 불러옵니다.
등록된 에뮬레이션 설정이 있으면 함께 복원합니다.

/reflux switchexact PitBull4DB 프로필 이름
PitBull4의 프로필만 전환합니다.

/reflux create 프로필 이름
Reflux의 에뮬레이션 설정을 저장할 프로필 묶음을 만들고 활성화합니다.
이 명령 자체는 다른 애드온의 AceDB 프로필을 전환하지 않습니다.

/reflux add 저장변수이름
AceDB가 아닌 애드온의 저장 변수를 에뮬레이션 목록에 추가합니다.
이미 AceDB 프로필이 있는 PitBull4DB 등은 이 목록에 추가할 필요가 없습니다.

/reflux save
현재 Reflux 프로필에 에뮬레이션 설정을 저장합니다.
/reflux save addons
현재 애드온 켜짐/꺼짐 상태도 함께 저장합니다.

/reflux copy 원본 프로필 이름
원본을 현재 AceDB 프로필로 복사하고 UI를 다시 불러옵니다.
/reflux snapshot 새 프로필 이름
현재 설정을 새 이름으로 복사하고 현재 AceDB 프로필을 유지합니다.

/reflux ignore 저장변수이름
/reflux unignore 저장변수이름
프로필 작업에서 제외할 애드온의 저장 변수를 지정하거나 해제합니다.

WTF 파일이 없어도 애드온 로드 시 RefluxDB를 생성합니다.
/reload 또는 정상 종료 후 계정 SavedVariables 폴더에 Reflux.lua가 저장됩니다.
전투 중에는 프로필 변경 명령을 실행하지 않습니다.
전체 변경 및 검증 정보: PitBull4/README_Forever_koKR.txt

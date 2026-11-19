# 오프라인 외관 준비

상태: Codex 배치 제안. 실제 클라이언트 검증 전이다.

## 착수 전 영향 지도

| 곳 | 유형 | 찾는 법 | 영향도 | 이유 |
|---|---|---|---|---|
| 해당 appearance 발주문·Step5 설계 | 같은 규칙·값 | 전문 재독·관련 frame key 검색 | 확인만 | 기능 값·직업 자원·공격대 역할 보존 |
| 24/feature-positions.json | 입력 생성·같은 좌표 | Python으로 해상도/키/사각형 추출 | 확인만 | 물리 픽셀 제안 원본 |
| 새 profile 조각·공통 LSM 등록 | 소비·호출/피호출 | 실제 기본값 schema·공개 API 대조 | 함께 작성 | 애드온 native 설정으로 배치 |
| 세 해상도 대응 조각 | 쌍둥이 | 동일 생성기로 제작 | 함께 작성 | 좌표 역할 누락 방지 |
| Collection defaults·원본 애드온 | 호출·원천 | 읽기만 | 확인만 | 부모가 후보 병합, 원본 변경 금지 |
| 신규 Lua5.1 실행 점검 | 잠근 시험 | 실제 생성 조각을 로드해 수치 대조 | 함께 작성 | 미측정 game 영역은 통과로 보고하지 않음 |


## 준비한 값과 남은 배치

세 해상도별 global 조각은 검증된 native 키인 fontName·fontOutline·막대3종 질감과 원래 의미 색만 제공한다. 글자 크기를 바꾸면 autoBarSize=true에서 높이도 변하므로 fontSize/repFontSize/petFontSize는 포함하지 않았다. barWidth/Height·location·slots·showLabels·기능값도 그대로다. 세 조각의 값이 같은 것은 화면마다의 배치가 끝났다는 뜻이 아니다. 공통 Appearance의 LSM 등록이 선행돼야 한다.

24 JSON의 experience.main/reputation/pet 세 가로 사각형은 공간 대안이다. native 2.0.4는 세 막대를 세로로 쌓으므로 현재 runtime이 가로3분할됐다고 보고하지 않는다. 검은 띠10/12/16px 안에서 원래 본문 상하 슬롯과 rep/pet 문구를 모두 가독성 있게 보이는 native 저장값 조합은 없다. 필요한 변경은 원본 CreateFrames의 RepBar·PetBar SetPoint(대략556–585), Update의 재배치/표시(대략873–913), ApplyBarSizes/ApplyFontSettings(대략776–826), 상하 Texts slot anchor(357–367)다. 지금 발주 범위의 skin은 primary 위치/장식만 허용하므로 child 재앵커는 구현하지 않았다. 부모에게 경계를 보고했고 부모가 geometry·slot을 보존한 외관 조각만 먼저 준비하도록 지시했다.

근거: appearance-19 전문, upstream ExperienceForever.lua global DB:39–107의 native 키/타입을 데이터로 조회했다. 전체 경험치 계산·설정 UI 코드를 정독·실행했다고 주장하지 않는다. 폰트/질감은 선언값 평가까지 확인하고 실제 LSM 적용·긴 숫자 폭·전투 중 표시를 접속 후 확인한다. 미니맵 단추 숨김 제안은 기능 기본값으로 실행하지 않는다.

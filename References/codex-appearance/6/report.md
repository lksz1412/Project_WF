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


## 구현과 제한

CLASSIC 테마를 바탕으로 FUF native 정수 설정을 제안한다. widths/heights/font/x/y는 physicalPx×pixelFactor/UIParentEff를 반올림한다. Single.Size가 footer·TOP portrait·spacing을 높이에 더하므로 LEFT/OFF portrait, footer0·내부 spacing0으로 외곽을 유지했다. player는 unitUpper, target은 unitLower다. party는 4명 세로 배치, pet은 오른쪽 첫 열, target은 다음 열로 두며 enabled·partyShowPets·partyTargets는 바꾸지 않는다. native border extent와 반올림 때문에 child 실제 x는 목표에서 몇px 달라질 수 있어 접속 검사 대상이다. boss는 5개 열의 자리만 미리 정했다. 기능·오라 개수/필터·시전바 설정은 바꾸지 않았다.

근거: appearance-6 전문, upstream FUF Core/Layout.lua:1–230, Units/Single.lua:1–367, Party.lua:1–362, PartyTargets.lua:1–196, PartyPets.lua:1–359 전문. Settings.lua는 설정 DB로 Python에서 width/height/x/y/font/theme/spacing/party child 키·범위를 추출했고 미독 algorithm을 읽었다고 보고하지 않는다. Preset.lua의 원래 모양을 확인했다.

## 실행

`python -I References/codex-appearance/2/Tests/check-feature-proposals.py` → exit0, Lua5.1 24회 평가(3해상도×factor .35/.64×4기능) PASS. PitBull4 실제 singleton 위치 함수·Quartz 실제 LibWindow RestorePosition, Hekili source 수식·FUF 정수 오차 범위를 대조했다. native 전체 애드온 실행·보호 프레임·화면 갈무리는 미수행이다.

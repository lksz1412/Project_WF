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

PitBull4 네 singleton과 주시 대상의 대상/소환수의 대상, 세 party group의 native 좌표·크기 배수를 제안한다. profile.units/groups/layouts와 namespaces 반환 계약이다. 기능 unit/layout/exists/enabled 및 오라/텍스트 스크립트는 전혀 넣지 않는다. layout scale=pixelFactor/UIParentEff, native position_x/y=physicalOffset×pixel로 계산한다. unit scale=1이며 공유 파티 layout의 pet/focus 크기 차이는 unit size_x/y로 표현한다. Fonts는 ChatFontNormal:GetFont()의 실제 baseline으로 font_size 배수를 계산한다. 4개 공유 layout은 native LSM 이름 Devil Forever devil을 쓴다. 모듈별 오라/Portrait/텍스트 위치의 기존 native 모양은 유지한다. user 선택 FUF/PB4 비교는 게임에서만 가능하다.

근거: appearance-6-rev 전문, Core Defaults/PitBull4.lua:1–512, PitBull4 UnitFrame.lua:1–917 및 GroupHeader.lua:1–2025 전문. SingletonUnitFrame:RefixSizeAndPosition과 GroupHeader 공식이 같고, source의 direction=down_right·vertical_spacing을 사용했다.

## 실행

`python -I References/codex-appearance/2/Tests/check-feature-proposals.py` → exit0, Lua5.1 24회 평가(3해상도×factor .35/.64×4기능) PASS. PitBull4 실제 singleton 위치 함수·Quartz 실제 LibWindow RestorePosition, Hekili source 수식·FUF 정수 오차 범위를 대조했다. native 전체 애드온 실행·보호 프레임·화면 갈무리는 미수행이다.

## 소환수 열 교정

PB4 pet/petTarget와 Quartz pet을 같은 x 열로 옮겼다. 좌표·근거·영향 지도·명령/판정·미관측 한계는 `../3/report.md`의 소환수 열 교정 절을 함께 본다. PB4 player/target 크기·다른 singleton/모듈 기능 값은 보존했다. 이번 실제 PB4 Refix 및 Quartz LibWindow oracle은3해상도×factor.35/.64에서 통과했다.

## 원본 장식 회피 최종 위치

pet 묶음을 부모/B 전달 좌표로 평행이동했다. 현재 좌표 표와 실제 최소 소비 시험·한계는 ../3/report.md의 원본 장식 alpha 회피 최종 좌표 절. 크기·간격·기능값은 보존.

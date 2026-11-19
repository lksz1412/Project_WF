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

Hekili brief의 top-centre/physical 설명과 실제 pinned UI.lua가 달랐다. UI.lua:1097는 UIParent CENTER raw x/y를 쓰고 GetScale:51는 PixelUtil.GetNearestPixelSize(1,pixelFactor,1)을 반환한다. 따라서 source에 맞춰 centre offset×pixel, Classic frame (primary+2)×nativeScale을 환산한다. keybindings/delays font는 native SetFont가 직접 읽으므로 fontPx×pixel이다. Classic 외형 설정은 style 현재값을 강제로 바꾸지 않으며 enabled/toggles/barGlow/specs/packs는 넣지 않았다. numIcons=1은 발주문이 허용한 외형값으로 다음 행동 하나만 보인다. 다른 표시창은 기존 separate/dual 토글이 켤 때만 표시된다. CDM은 별도 계획·등록 조각을 준비하며 실제 Edit Mode 저장 구조 확인 전 자동 위치 적용을 보류한다.

근거: appearance-8 전문, upstream Hekili UI/UI.lua:1–1692, UI/Styles/Classic.lua:1–1378, UI/Styles.lua:1–85 전문. Classic width에 포함된2 UI unit 외곽까지 시험 공식에 포함했다. 실제 Hekili 전체 엔진·추천 업데이트 실행을 통과했다고 주장하지 않는다.

## 실행

`python -I References/codex-appearance/2/Tests/check-feature-proposals.py` → exit0, Lua5.1 24회 평가(3해상도×factor .35/.64×4기능) PASS. PitBull4 실제 singleton 위치 함수·Quartz 실제 LibWindow RestorePosition, Hekili source 수식·FUF 정수 오차 범위를 대조했다. native 전체 애드온 실행·보호 프레임·화면 갈무리는 미수행이다.

Masque native profile 제안 `masque-hekili-profile.fragment.lua`는 해당 addon 상위 그룹의 SkinID=Onyx·Inherit=false만 설정한다. 다른 addon 그룹과 기존 하위 그룹의 Inherit=false 선택은 강제로 바꾸지 않는다. pinned Masque.lua 전체·Core/Groups.lua 전체, Onyx Skins.lua 등록 DB의 Onyx ID를 확인했다. 기존 사용자 하위 그룹의 현재 상속 상태에 따른 효과는 live 확인 대상이다.

## 게임 기본 Cooldown Manager

layouts/*.lua에 네 viewer의 물리 사각형을 담았다. 이는 Core preset/import 표가 아닌 순수 배치 제안이다. 실제 네이티브 Edit Mode 저장 형식과 재배치 수명은 미확인이라 자동 SetPoint/size를 넣지 않았다. 14의 읽기전용 Probe.lua에서 viewer별 실제 point/scale/size를 받을 수 있다. Hekili가 읽는 IsVisible·cooldownID·layoutIndex와 CVar는 건드리지 않는다. 게임 확인 전에 viewer가 실제로 배치됐다고 보고하지 않는다.

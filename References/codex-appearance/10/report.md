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

기존 창 1/2만 대상으로 native window_scale, libwindow, posicao.normal 및 모양 값을 제안한다. window_scale=pixelFactor/UIParentEff, libwindow x/y=physicalOffset×pixel, normal w/h=physical 목표다. legacy centre x/y도 같은 화면 centre 기준×pixel로 동기화했다. source의 RestoreMainWindowPosition→RestoreLibWindow 실제 두 함수 본문을 Lua5.1에서 실행해 크기/좌표를 대조했다. row 높이22/24/28, font16/18/22px, title 높이24/26/30px다. 클래스색·정렬·수치·mode·plugin·chat_tab_embed는 조각에 넣지 않는다. 두 창은 분리해 system chat 위쪽 빈 영역에 놓는다.

**적용 시점:** Details 초기화가 끝나고 창2가 존재하는 뒤, 부모가 native 설정/공개 restore 경로로 적용한다. `_detalhes_global`·`_detalhes_database` 직접 쓰기나 창2 자동 생성·모드 변경은 하지 않았다. Tiny Threat 선택은 게임에서 아직 검증하지 않았다. native titlebar의 바깥쪽 실제 외곽과 가장 긴 줄은 live 검사 대상이다.

근거: appearance-10 전문, upstream Details/classes/include_instance.lua:1–502 및 core/windows.lua:1–1575 전문. 새 source의 row_info.texts와 legacy font fallback 관계는 source 데이터에서 확인했고 legacy compatibility를 제거하지 않았다. functions/skins.lua는 전체2842행을 읽지 않았으므로 InstallSkin 런타임 코드는 이 작업에서 만들지 않았다. 공통 LSM 이름을 쓰는 native profile값만 제공한다.

## 실행

`python -I References/codex-appearance/2/Tests/check-feature-proposals.py` → exit0, Lua5.1 36회 평가(3해상도×factor .35/.64×6기능) PASS. compile 대상 신규6개 Lua 실패0. native 전체 애드온·보호 프레임·화면 갈무리는 미수행이다.

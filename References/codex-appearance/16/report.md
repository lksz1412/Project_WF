# 상태띠 사전 준비

세 preset이 statusstrip.bar 위치·크기·font·spacing을 물리 픽셀로 제공한다. skin은 Strip의 공개 GetFrame·GetFontString·ListItems·SetSpacing과 LAYOUT 콜백만 사용한다. strip은 UIParent에 직접 붙이고 실효 배율을 PixelUtil pixel factor에 맞춰 목표 글자 크기를 유지한다. 셸의 appearance.status 바탕이 뒤에 있고, 여섯 칸 사이의 구분선은 skin 자신의 마우스 비활성 holder에 둔다. 빈 칸을 끄면 LAYOUT의 shownKeys로 선을 다시 놓는다.

Strip의 OnShow/OnHide 스크립트·항목 on/off·시계24시간 값은 수정하지 않는다. 전투에서는 테마/preset/배율 변경 적용을 끝까지 미루고 PLAYER_REGEN_ENABLED에서 갱신한다. 띠 strata LOW를 보존하며 보호된 바와 서로 anchoring하지 않는다.

근거는 appearance-16 전문, StatusStrip.lua1–714 전문, Core registry_extra의 statusstrip 항목과 API/Edit/Theme 전문이다. 가장 긴 골드 문자열과 6개 칸의 실제 FontString 폭, 전투·clickthrough는 접속 후 확인한다.

게임 갈무리 및 실사용 결과는 미검증이다. 원본 애드온·게임 설정 파일을 이 단계에서 변경하지 않았다.

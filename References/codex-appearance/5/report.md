# 미니맵 사전 준비

sexymap-profile.fragment.<해상도>.lua는 새 native profile을 만들 때 Defaults에 합치는 모듈 body다. core.shape=130871로 사각 모양을 쓰고 네이티브140px에 대상 크기와 UIParent 실효 배율을 적용해 core.scale을 계산한다. core.point/relpoint/x/y 저장값을 SexyMap 자체 SetupMap이 읽으므로 skin이 Minimap:SetPoint를 다시 걸지 않는다.

SexyMap2DB의 캐릭터 값이 문자열 global인 기존 설정은 Defaults의 보존 흐름을 따른다. Core 등록 시점에 그 저장 변수를 조회하면 아직 로드되기 전이어서 자동 root fragment는 만들지 않았다. 별도 sexymap-profile.deferred.*.lua는 실제 SV가 읽힌 이후 값을 만드는 함수 제안이며 설치 후보 자동 적용 대상에서 보류한다. 이 함수는 캐릭터의 global 선택을 문자열로 유지하고 global 모듈 값에 제안하며, 이름을 못 읽으면 로그와 nil로 거절한다.

scale은 `(304/140)×pixelFactor/UIParent 실효 배율`로 정한다. 예를 들어 factor0.355556·배율0.64이면 UHD scale1.20635다. UI 옵션 슬라이더 상한3.0과 실제 SetupMap 저장값 적용(clamp 없음)은 별도이며, 앞선 factor1 가정의 scale3.392857은 폐기했다. 원본619행을 읽어 경로를 확인했다. 이 값의 실제 미니맵 클릭·회전·확대 동작은 접속 후 시험한다.

R110의 시계 never는 부모가 기능 Defaults에서 반영한다. 이 조각은 기능 값 rightClickToConfig·autoZoom·추적 단추 규칙을 포함하지 않는다. 새로운 모듈표를 만들지 않아 원본 clock/zonetext/borders 기본값의 필수키를 누락하는 경로도 없다.

실물 자산 대조에서 `Borders_Classic.lua`가 새 캐릭터에 `Blue Rune Circles`를 자동 설치하며 사각 shape 값을 덮는 경로를 찾았다. 새 시험판 조립에서 네이티브 `borders` 초기값에 빈 장식·`applyPreset=false`를 함께 넣어 사각 모양을 보존한다. 이미 저장한 테두리와 전역 프로필은 이전과 같이 보존한다. 사각 마스크 `WHITE8X8`은 클라이언트 파일이다. 미니맵 지형 타일은 ZIP에 없다.

근거는 appearance-5 전문, SexyMap.lua1–619·Shapes.lua1–387·Clock.lua 전문, Core Defaults/SexyMap.lua 전문이다.

게임 갈무리 및 실사용 결과는 미검증이다. 원본 애드온·게임 설정 파일을 이 단계에서 변경하지 않았다.

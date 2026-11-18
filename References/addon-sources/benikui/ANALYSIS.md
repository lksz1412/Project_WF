# BenikUI — 분석

기록일: 2026-11-18. 공식 설명·모듈 목록 및 배포 메타데이터를 근거로 정리했다.

**확인한 역할·기능:** 공식 기능표에서 확인한 범위: 공통 외관·테마, 행동단축바, 유닛 프레임, 파티 프레임, 공격대 프레임, 채팅 기능, 미니맵, 시전바, 버프 표시, 디버프 표시.

**문서에 나온 범위·조건:** ElvUI를 요구하는 확장이다. 기반 ElvUI 기능과 BenikUI 자체 장식·대시보드를 독립 구현으로 함께 세지 않는다.

**비교 참고 분석(추정):** 기반 ElvUI의 기능과 확장 패키지 자체의 대시보드·장식을 나누어 비교하는 사례가 된다. 이 평가는 설계 비교이며 성능·코드 품질·실제 호환성 시험 결과는 아니다.

**Forever 지원 관측:** 확정: 보존한 배포 파일에 Forever / 1.60.1 표기. 실제 게임 작동은 미검증이다.

**함께 보존한 원본:** [ElvUI_BenikUI_5.20.zip](ElvUI_BenikUI_5.20.zip) · v5.20 · [SOURCE와 SHA256](SOURCE.txt).

**공식 근거:** [공식 원문1](https://www.curseforge.com/wow/addons/benikui) · [공식 원문2](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Groups) · [공식 원문3](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules) · [공식 원문4](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Maps) · [공식 원문5](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/UnitFrames/Elements) · [공식 원문6](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/General) · [공식 원문7](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/DataBars) · [공식 원문8](https://api.github.com/repos/tukui-org/ElvUI/contents/ElvUI/Game/Shared/Modules/Misc) · [보존 파일의 메타데이터](https://www.curseforge.com/wow/addons/benikui/files/9170538). 확인 위치: 공식 기능·모듈 목록; features-catalog의 해당 package 셀.

**연결된 조사:** [통합 UI 기능·단독 대표 조사](../../addon-survey/features.md).

원본 ZIP은 압축해제·개명·재포장하지 않았다. 압축 내부 코드의 검독·설치·게임 실행은 수행하지 않았다.

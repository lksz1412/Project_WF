# BugGrabber — 분석

기록일: 2026-11-18. 공식 설명·모듈 목록 및 배포 메타데이터를 근거로 정리했다.

**확인한 역할·기능:** 게임에서 생긴 Lua 오류를 모아 표시 애드온에 전달한다. 일반 사용자의 상위 표시 화면으로 BugSack을 안내하며, 표시 애드온이 없으면 기본 채팅에 오류를 출력한다고 설명한다.

**비교 참고 분석(추정):** 오류 수집 엔진과 BugSack 같은 표시 화면을 분리하는 구조의 참고가 된다. 이 평가는 설계 비교이며 성능·코드 품질·실제 호환성 시험 결과는 아니다.

**Forever 지원 관측:** 확정: 보존한 배포 파일에 Forever / 1.60.1 표기. 실제 게임 작동은 미검증이다.

**함께 보존한 원본:** [!BugGrabber-v12.1.1.zip](%21BugGrabber-v12.1.1.zip) · v12.1.1 · [SOURCE와 SHA256](SOURCE.txt).

**공식 근거:** [공식 원문1](https://www.curseforge.com/wow/addons/bug-grabber) · [보존 파일의 메타데이터](https://www.curseforge.com/wow/addons/bug-grabber/files/9277326). 확인 위치: Description L180–185.

**연결된 조사:** [통합 UI 기능·단독 대표 조사](../../addon-survey/features.md).

원본 ZIP은 압축해제·개명·재포장하지 않았다. 압축 내부 코드의 검독·설치·게임 실행은 수행하지 않았다.

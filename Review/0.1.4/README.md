# Devil Forever 0.1.4 검토판

이 브랜치의 `Collection/AddOns`에는 실제 한 접속 비교 ZIP의 애드온 파일 2,558개를 담았다. 기본 PitBull4판과 FUF판은 같은 파일 중 각 묶음에서 쓰는 부분을 선택한다. ZIP별 포함 파일과 해시는 `addon-files.json`에 있다. 각 ZIP에 들어간 설치 안내·목록·해시는 `packages`에서 확인한다.

- [기본 PitBull4, FUF, 한 접속 비교의 ZIP과 해시](trial-receipt.json)
- [기능·성능 시험 8개](functional-tests.json)
- [Quartz 프로필 27건과 이전 동작 대조 9건](quartz-default-tests.json)
- [Core에서 AceDB와 Quartz를 이어 실행한 15건](packaged-quartz-through-core.json)
- [별도 프레임 시간 도구](diagnostics/DevilForever_PerfProbe)와 [시험 결과](perf-probe-tests.json)
- [아스트라 6.2의 코드·사용 패턴 검수](astra-review.md)

GitHub의 0.1.4 릴리스에는 검증한 ZIP 세 개와 별도 프레임 시간 도구를 담았다. 검토 기준은 여기 적힌 파일과 [0.1.4 릴리스](https://github.com/lksz1412/Project_WF/releases/tag/v0.1.4)의 파일이다. 실제 게임의 기능과 프레임 시간을 최종 비교할 때 쓸 시험판이다.

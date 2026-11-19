# Devil Forever 0.1.4 검토판

이 브랜치의 `Collection/AddOns`에는 실제 한 접속 비교 ZIP의 애드온 파일 2,558개를 담았다. 기본 PitBull4판과 FUF판은 같은 파일 중 각 묶음에서 쓰는 부분을 선택한다. ZIP별 포함 파일과 해시는 `addon-files.json`에 있다. 각 ZIP에 들어간 설치 안내·목록·해시는 `packages`에서 확인한다.

새 체크아웃에서 작업을 이어갈 때는 [작업 인계](HANDOVER.md)에 있는 준비, 기능 시험, 재조립 및 재검수 순서를 따른다.

- [기본 PitBull4, FUF, 한 접속 비교의 ZIP과 해시](trial-receipt.json)
- [기능·성능 시험 8개](functional-tests.json)
- [Quartz 프로필 27건과 이전 동작 대조 9건](quartz-default-tests.json)
- [Core에서 AceDB와 Quartz를 이어 실행한 15건](packaged-quartz-through-core.json)
- [별도 프레임 시간 도구](diagnostics/DevilForever_PerfProbe)와 [시험 결과](perf-probe-tests.json)
- [아스트라 6.2의 코드·사용 패턴 검수](astra-review.md)
- [추가 후보 ZIP과 검토 기준](candidates/README.md)

검토 기준은 이 브랜치의 소스와 해시 목록이다. 게임에서 쓸 시험 ZIP 세 개와 프레임 시간 측정 도구 ZIP은 [GitHub 0.1.4 릴리스](https://github.com/lksz1412/Project_WF/releases/tag/v0.1.4)에서 받는다. 실제 게임의 기능과 프레임 시간은 후속 확인 항목이다.

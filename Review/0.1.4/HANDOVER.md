# Devil Forever 0.1.4 작업 인계

검토 브랜치는 `codex/review-0.1.4`다. 0.1.4 공개 시험판의 태그는 `v0.1.4`다. 설치된 게임이나 이전 작업자의 컴퓨터에서 파일을 가져오지 않고 이 체크아웃에서 검토를 시작할 수 있다.

[Claude의 다음 판 작업에 필요한 원문·배치·검증 인계](../../Codex/results/CLAUDE_HANDOFF_phase30.md)

## 입력과 기준

- 실제 제품 소스는 [Collection/AddOns](../../Collection/AddOns)다. 한 접속 비교판의 전체 소스를 기준으로 기본 PitBull4판과 FUF판을 나눈다. [판별 파일 목록](addon-files.json) · [원본 ZIP 해시](trial-receipt.json)
- 화면은 진영·종족·데빌 13종의 승인 목업과 사용자 설계 기준을 따른다. 배치 또는 색을 바꿀 때는 실제 해상도별 좌표와 목업을 먼저 대조한다. [화면 설계 기준](../../Codex/docs/ui-design-criteria.md) · [모바일 승인 목업](../../outputs/devil-forever-mobile-orc-rail.html) · [화면과 좌표](../../References/codex-appearance/24/mockup-index.md)
- 채팅 입력과 메시지 처리는 게임 기본 기능을 따른다. 프로젝트는 공개·그룹·시스템 창의 배치와 스킨을 담당한다. [채팅 결정과 Prat 자료](evidence/chat-decision.md) · [기능과 담당 애드온](../../Collection/data/feature-map.md)
- 선택 후보 ZIP은 [candidates](candidates/README.md)에 있다. 선택 후보의 도입은 실제로 겹치는 창, 한국어 동작, 프레임 시간의 확인을 거친다.

## 체크아웃에서 실행

저장소 루트에서 Python 3.12 환경을 사용한다. 새 환경에는 아래 시험 의존성을 설치한다.

```text
python -m pip install -r Review/0.1.4/requirements.txt
python Review/0.1.4/tools/package.py verify-source
python Review/0.1.4/tests/run.py --output ../review-014-tests
python Review/0.1.4/tools/package.py build work/review-014-archives
python Collection/tests/install/verify_archives.py work/review-014-archives --version 0.1.4 --reviewed-chat
python Review/0.1.4/tools/verify-quartz.py work/review-014-archives
python Review/0.1.4/tools/verify-probe.py --zip work/review-014-archives/DevilForever-FrameTimeProbe.zip
```

각 출력 폴더에는 새 경로를 지정한다. 기능·성능 시험 출력은 체크아웃 밖에 둔다. [시험 목록과 기존 빌드 전용 제외 항목](tests/README.md) 첫 소스 확인은 수정 전 기준에 사용한다. 기능·성능 시험은 체크아웃의 현재 소스를 복사한 임시 트리에서 실행한다. 패키지 빌드는 현재 소스로 세 변형과 측정 도구를 만들고 내부 파일 해시를 다시 계산한다. 재조립 ZIP의 압축 설정과 순서는 게시한 원본과 달라질 수 있다. [공개 ZIP](https://github.com/lksz1412/Project_WF/releases/tag/v0.1.4)을 그대로 내려받았을 때는 다음 명령으로 원본 네 개의 해시를 대조한다.

```text
python Review/0.1.4/tools/package.py verify-release <공개 ZIP을 저장한 폴더>
```

승인 테마의 외관을 바꿀 때는 그림 시험 의존성까지 설치하고, 새 증거 폴더 이름을 지정한다.

```text
python -m pip install -r Review/0.1.4/requirements-art.txt
python References/codex-appearance/22/tools/pack-reviewed-chat.py --verify-approved --evidence work/review-014-pixels
python References/codex-appearance/22/tools/pack-reviewed-chat.py --verify-runtime --evidence work/review-014-art-runtime
```

[검토 그림을 만든 렌더러](../../References/codex-appearance/22/tools/approved-chat-renderers)와 [종족·진영 그림 원본](../../References/codex-appearance/22/racial-masters)이 이 브랜치에 있다. `--verify-approved`와 `--verify-runtime`은 기존 그림을 검사한다. 이전 렌더러는 승인 당시의 그림 조건을 읽는 입력이다. 그림을 새로 만들 때에는 패킹 도구의 출력을 새 폴더로 지정한 뒤 게임에서 쓰는 결과와 비교한다. [테마 결과와 출처](../../References/codex-appearance/24/composed-final/index.md)

[새 체크아웃 검증 결과](evidence/handoff-verification.md)

## 이어서 검토할 순서

| 순서 | 코드와 기준 | 확인할 동작 |
|---|---|---|
| 1 | [TinyThreat](../../Collection/AddOns/Details_TinyThreat/Details_TinyThreat.lua) | 숨김 뒤 다음 전투에 들어가도 타이머가 다시 생기지 않는지, 전투 중 다시 켜면 정상 조회하는지 확인 |
| 2 | [PitBull4](../../Collection/AddOns/PitBull4/Main.lua) | 긴 프레임에서 파생 유닛 조회가 한꺼번에 몰리는 것을 줄인 뒤 표시 갱신과 대상 전환을 대조 |
| 3 | [ExperienceForever](../../Collection/AddOns/ExperienceForever/ExperienceForever.lua) · [ProfileManager](../../Collection/AddOns/ProfileManager/Providers.lua) | 표시 변화가 없는 경우의 반복 갱신, 로그인 때 공급자 재등록을 줄이고 기존 설정과 기능을 확인 |
| 4 | [Appearance 합성](../../Collection/AddOns/DevilForever_Appearance/Composition.lua) | 합성판 아래에서 가려지는 그리기를 줄이는 경우 합성 이미지 실패와 개인 배치 경로도 검증 |

0.1.4의 기존 반복을 기준으로 확인할 때 사용하는 명령이다. 수정 전에는 TinyThreat 조회 1,200회, 합성 전 임시 텍스처 31개, PitBull4의 긴 프레임에서 조회 66회를 다시 확인할 수 있다. 이 값들은 Lua 시험 환경의 호출 수다.

```text
python Review/0.1.4/tools/reproduce-astra-runtime.py
python Review/0.1.4/tools/reproduce-astra-pitbull.py
```

이전 시험 결과와 아직 실제 게임에서 확인할 항목은 [아스트라 재검수](astra-review.md), [한 접속 확인표](../../References/codex-verify/one-session-review.md), [프레임 시간 비교](evidence/frame-time.md)에 있다. 4K 퀘스트 글자, 전투 중 새 이름표, 공격대 힐러 입력과 실제 프레임 시간은 후속 게임 시험이 필요하다.

# Phase 29.5 로컬 0.1.4 시험판과 프레임 시간 측정

## 요약

Devil Forever의 기본 PitBull4, FUF, 한 접속 비교용 0.1.4를 로컬 시험 묶음으로 준비했다. 새 Quartz 기본 프로필에서 유닛 프레임과 겹치는 별도 오라 막대를 끈다. 다른 캐릭터와 공유하는 기본 프로필과 모듈에 남은 기존 설정을 보호한다. 기본 게임과 모음집의 프레임 시간을 같은 파일로 기록하는 도구를 별도로 준비했다.

## 진행 범위

[세부계획](../plans/2026-11-19-devil-forever-addon-adoption-phase29.5-세부계획.md)의 Step 70–72.

## 입력

로컬 0.1.3 ZIP 세 개, [앞 단계의 후보 비교와 패치](PHASE_29.4_bundled-addon-comparison_RESULT.md), 기존 기능 시험과 승인 목업.

## 생성한 파일

| 파일 | 사용 |
|---|---|
| [기본판](../../_local_only/runtime-release-0.1.4-reviewed/archives/DevilForever-0.1.4.zip) | PitBull4를 쓰는 기본 모음집 |
| [FUF 판](../../_local_only/runtime-release-0.1.4-reviewed/archives/DevilForever-0.1.4-fuf.zip) | Forever Unit Frames만 쓰는 변형 |
| [한 접속 비교판](../../_local_only/runtime-release-0.1.4-reviewed/archives/DevilForever-0.1.4-one-session.zip) | 같은 접속에서 두 유닛 프레임을 번갈아 확인 |
| [프레임 시간 측정 도구](../../_local_only/runtime-release-0.1.4/DevilForever-FrameTimeProbe.zip) | 기본 게임과 모음집의 프레임 간격을 같은 코드로 기록 |

## 갱신한 기록

실행 대장, 요청 대장, 마스터 플랜과 [한 접속 확인표](../../References/codex-verify/one-session-review.md)에 연결했다. ZIP 내부 변경과 사용한 설정은 작업 기록과 해시 목록에 있다.

## 읽은 범위

마스터 플랜, 29.5 세부계획, 직전 29.4 결과, 두 대장과 Step 70–72의 근거를 대조했다. Lua 호출과 시험 내용의 구체적인 확인 범위는 Step 기록과 검수 결과에 있다.

## 실행 근거

이전 모음집에서 검증한 13종 테마, 미니맵 좌표와 경험치 표시 개선을 새 ZIP에 함께 담았다. 최종 ZIP 세 개에서 좌표 표시를 끄면 위치 조회가 0회였고, 다시 켤 때 타이머는 하나였다. 경험치 표시 시험은 같은 11,000을 그리고 화면 갱신은 한 번이었다. 이 횟수는 Lua 실행 대역에서 확인했다. 프레임 측정 도구는 대기 중 프레임 콜백을 사용하지 않는다. 첫 프레임에서는 시작 기준만 잡으며, 측정이 끝나면 최근 12회 요약을 보관한다. [이전 개선 재시험](../../_local_only/runtime-release-0.1.4-reviewed/trial-addon-tests.json)

## 검증

실제 ZIP에서 전체 Core 로드 목록을 따라 Quartz 프로필 27건을 확인했다. 공용 프로필 보존 옵션을 끈 상태에서 이전 기본값 동작을 확인한 시험 9건도 통과했다. Core에서 AceDB와 Quartz까지 이어 실행한 시험은 15건이다. 오라 갱신 요청은 막대를 켠 경우 41회, 끈 경우 0회였으며 두 경우 모두 시전 모듈 네 개가 대역에서 활성 상태였다. [프로필 시험](../../_local_only/runtime-release-0.1.4-reviewed/quartz-default-tests.json) · [연결 시험](../../_local_only/runtime-release-0.1.4-reviewed/packaged-quartz-through-core.json)

기능과 성능 회귀 8개 묶음과 측정 도구의 Lua 시험 8건을 통과했다. [기능·성능 회귀](../../_local_only/runtime-release-0.1.4-reviewed/functional-tests.json) · [측정 도구 시험](../../_local_only/runtime-release-0.1.4/perf-probe-tests.json) · [ZIP 해시](../../_local_only/runtime-release-0.1.4-reviewed/trial-receipt.json) · [측정 도구 해시](../../_local_only/runtime-release-0.1.4/perf-probe-zip.json)

세 묶음의 Lua 파일 1,345개, 1,291개, 1,477개를 각각 검증했다. 실패, 누락된 필수 의존성, 중복 경로는 모두 0건이다. [압축 파일 검사](../../_local_only/runtime-release-0.1.4-reviewed/archive-output-2_mwofzw/verify_archives.log)

아스트라가 처음 지적한 다섯 건을 수정했고, 최신 ZIP을 읽어 독립 재검한 결과 남은 결함은 중대·중간·경미 각각 0건이다. [독립 재검 기록](Step%2072%20%E2%80%94%200.1.4%20기능%20회귀와%20한%20접속%20준비.md#독립-재검)

## 적용 범위

산출물은 지금 로컬에서 사용하는 시험판이다. 공식 설치 카탈로그와 별도로 보관하고, 게임과 연결한 확인은 다음 접속에서 진행한다.

## 실제 게임에서 확인할 조건

4K 퀘스트 글자 가독성, 소환수 창·시전바·이름표·전투 중 표시 정확도, 실제 프레임 시간은 게임에서 확인한다.

## 결정 기록

기본 PitBull4와 FUF 비교판을 유지했다. FUF의 숨은 프레임 추가 최적화는 보이는 상태로 돌아올 때의 게임 내 동작을 확인할 후보로 두었다.

## 실행 준비

같은 장면의 기본 게임과 모음집을 비교하고, 차이가 반복되면 Hekili·Details·유닛 프레임을 각각 확인한다. [한 접속의 화면 확인](../../References/codex-verify/one-session-review.md) · [프레임 시간 비교 순서](../../_local_only/runtime-release-0.1.4/한%20접속%20성능%20비교.md)

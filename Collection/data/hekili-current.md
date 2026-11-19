# Hekili와 게임 기본 쿨다운 관리자의 현행 역할

Forever용 모음집은 **Hekili로 다음 행동을 추천**하고, **게임 기본 Cooldown Manager로 상태 알림과 재사용 대기시간을 표시**한다. 사용자가 R104에서 확정한 방향이다. [요청 대장](../../Claude/results/REQUEST_LEDGER_phase8.md) · [실사용 확인 항목](../codex-briefs/phase8.md)

| 기능 | 담당과 입구 |
|---|---|
| 다음 행동 추천 | Hekili의 Primary 창. 추천한 행동이 단축바에 있으면 새 프로필의 기본값으로 해당 버튼을 강조한다. Hekili 설정에서 추천과 강조를 조절한다. [Hekili 기본값](../AddOns/!DevilForever_Core/Defaults/Hekili.lua) |
| 상태와 재사용 대기시간 | 게임 기본 Cooldown Manager의 핵심·보조·버프 아이콘·버프 막대. 실제 표시 여부와 위치는 게임 편집 모드에서 확인한다. [접속 확인표](../../References/codex-verify/one-session-review.md) |
| 단축바에 보이는 남은 시간 숫자 | 게임 기본 `countdownForCooldowns` 설정. Dominos 버튼의 실제 숫자는 접속 때 확인한다. [확인 방법](../codex-briefs/phase8.md) |

## 설치 모듈과 추천 범위

세 시험 ZIP에는 Hekili 본체, 공용 모듈과 Forever 직업 9개의 모듈이 있다. 이전 코드 조사에서 특성 28개 중 추천 24개와 미지원 4개를 확인했다. 특성별 실제 추천과 기술 ID는 접속 검사 항목이다. [설치 목록](../install.json) · [출처별 특성표](hekili-support.md)

| 추천이 없는 특성 | 사용하는 표시 |
|---|---|
| 성기사 신성, 사제 신성, 주술사 복원, 드루이드 회복 | 게임 기본 Cooldown Manager의 상태와 재사용 대기시간 |

Step 18 지원표의 특성별 코드 근거는 참고할 수 있다. 그 문서의 `DevilForever_Combat` 보완 모듈 제안과 기본 Cooldown Manager 도입 결정 대기는 이후 R104에서 바뀌었다. 배포 목록은 현재 역할을 기준으로 한다.

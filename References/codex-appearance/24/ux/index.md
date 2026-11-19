# 상태별 배치와 세 테마 비교

같은 캐릭터를 기준으로 탐험·전투·파티·공격대·입력 상태를 놓고 확인하는 목업이다. 좌표는 왼쪽 위 기준의 물리 픽셀이다. 점선은 배치 목표를 표시한다.

설치 ZIP의 Onyx 빈 슬롯·공통 패널·구분선·유닛 막대 이미지를 사용한다. 게임에서 그리는 스킬·지역 지도 타일·초상은 이 오프라인 그림에서 자리를 비워 두었다. [상태별 그림에 들어간 파일과 SHA256](asset-provenance.json)

| 해상도 | 퀘스트 | 전투 | 파티 | 공격대 | 채팅·도움말 | 소환수 |
|---|---|---|---|---|---|---|
| 1920×1080 | [탐험](fhd-quest.png) | [시전·재사용 대기](fhd-combat.png) | [파티 열](fhd-party.png) | [40칸 Grid2](fhd-raid.png) | [입력](fhd-input.png) | [전체](fhd-pet.png) · [원배율](fhd-pet-alignment.png) |
| 2560×1440 | [탐험](qhd-quest.png) | [시전·재사용 대기](qhd-combat.png) | [파티 열](qhd-party.png) | [40칸 Grid2](qhd-raid.png) | [입력](qhd-input.png) | [전체](qhd-pet.png) · [원배율](qhd-pet-alignment.png) |
| 3840×2160 | [탐험](uhd-quest.png) | [시전·재사용 대기](uhd-combat.png) | [파티 열](uhd-party.png) | [40칸 Grid2](uhd-raid.png) | [입력](uhd-input.png) | [전체](uhd-pet.png) · [원배율](uhd-pet-alignment.png) |

## 4K에서 목표 글자와 단축바를 구분한다

| 해상도 | 제목/목표 글자 | 목표창 가독성 원배율 |
|---|---:|---|
| FHD | 24/20px | [Devil](fhd-devil-objectives.png) · [Horde](fhd-horde-objectives.png) · [Alliance](fhd-alliance-objectives.png) |
| QHD | 28/24px | [Devil](qhd-devil-objectives.png) · [Horde](qhd-horde-objectives.png) · [Alliance](qhd-alliance-objectives.png) |
| UHD | 36/30px | [Devil](uhd-devil-objectives.png) · [Horde](uhd-horde-objectives.png) · [Alliance](uhd-alliance-objectives.png) |

목표창은 오른쪽 안쪽, 우두머리 프레임은 그 오른쪽이다. 미터기와 행동단축바는 목표창보다 아래에 둔다. 도움말 자리안은 목표창과 단축바를 피한다. 글자 예시는 1:1로 잘라냈으며 게임 목표창과 연결하기 전 기준이다.

## 테마와 해상도 비교

[데빌·호드·얼라이언스 하단 적용](themes-comparison.png) · [테마 4K 원배율](themes-uhd-native-details.png) · [단축바·미니맵 1:1 비교](resolution-native-comparison.png)

| 테마 | 질감과 장식 | 글자·신호 |
|---|---|---|
| 데빌 | 지하 예배당의 첨두 아치·현무암과 잿빛 금속 | 뼈빛 본문, 가는 금속 경계 |
| 호드 | 검게 그을린 철, 적갈색 가죽, 쐐기와 엄니 | 아이보리 본문, 두 픽셀 철제 테두리 |
| 얼라이언스 | 청남색 직물, 황동과 은철, 방패받침과 깃 장식 | 차가운 백색 본문, 가는 황동 경계 |

테마 비교판은 4K 하단을 같은 비율로 줄였다. 원배율 비교판은 세 해상도에서 행동 단축바와 미니맵을 1:1로 잘라냈다. Onyx의 빈 슬롯 외곽은 48/56/80픽셀이다. 스킬이 배정되면 아이콘 영역은 Masque에서 약 43.89/51.20/73.14픽셀로 계산된다. 프리셋에 기재한 36/44/64픽셀과의 차이는 실게임에서 기록한다.

## PitBull4 크기와 소환수 열

| 해상도 | 플레이어 / 대상 | 소환수 | 기술바 슬롯 | 네 줄의 왼쪽 x |
|---|---|---|---|---:|
| FHD | 240×48 / 340×56px | 240×32px | 22px × 10, 간격 2px | 218 |
| QHD | 280×56 / 400×64px | 280×40px | 26px × 10, 간격 2px | 256 |
| UHD | 390×72 / 554×84px | 360×42px | 34px × 10, 간격 2px | 212 |

PitBull4 프레임 크기는 후보의 실제 Lua 배치 함수에서 얻었다. 소환수의 대상 → 소환수 → Dominos 기술바 → Quartz 시전바 순서다. 기술바 목업은 슬롯의 위치를 보여 준다. 게임에서는 배정된 소환수 기술만 표시된다. 세 테마 장식 픽셀과 네 줄이 겹치는지 별도로 검사했다.

4K에서 소환수 프레임과 기술바의 왼쪽은 x212에 맞지만 플레이어보다 868px 왼쪽이다. 이전 채팅에서 지정한 그림 및 소환수가 나온 참고 화면과 대조한 결과와 플레이어 위로 옮기는 안을 기록했다. [원본과 현재 목업](pet-reference-comparison.png)

## 이름표 체력 막대와 이름 원배율

| 해상도 | 후보 체력 막대 | 이름 | 예시 |
|---|---:|---:|---|
| FHD | 180×20px | 18px | [적·아군](fhd-nameplates.png) |
| QHD | 220×24px | 22px | [적·아군](qhd-nameplates.png) |
| UHD | 280×30px | 28px | [적·아군](uhd-nameplates.png) |

목업은 후보 ZIP에 담긴 이름표 크기 표를 읽었다. 게임은 표시할 체력·위협 색, 위치, 시전바를 맡는다. 그림 속 체력과 색은 보기용 예시다. 실제 접속에서 적용 가능한 막대와 픽셀 수를 같은 기준으로 읽는다.

## 이번에 조정한 배치

- FHD 시전바와 쿨다운 줄 사이 여백을 확보했다. 왼쪽 주시 시전바는 단축바 옆의 빈 칸으로 이동했다. 쿨다운 네 프레임은 점선으로 표시하고 시전바는 후보 설정에 들어간다.
- 세 해상도의 Details 창을 넓혔다. FHD에서는 오른쪽 단축바와 쿨다운 구역 사이에 놓았다. UHD에서 두 창의 왼쪽을 셋째 채팅창과 맞췄다.
- 중앙 8×3 아래에 메뉴·가방·대기열의 위치를 구분했다. Dominos 프리셋으로 폭을 계산했다. 실제 게임이 제공하는 그림은 접속에서 확인한다.
- 파티와 공격대는 별도 상태로 확인한다. 보이는 프레임의 겹침을 18개 화면에서 대조했다. 목표창과 도움말, 기본 쿨다운 창의 실제 연결은 한 번의 접속 때 확인한다.

[기준 목업](../mockup-index.md) · [배치 좌표](../feature-positions.json) · [테마 자산과 적용](../../22/report.md) · [한 번의 접속 검증](../../../codex-verify/one-session-review.md)

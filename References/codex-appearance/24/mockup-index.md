# Devil Forever 배치 목업

[현재 하단 외관 적용 목업 · 진영 2종·종족 10종·데빌](racial-appearance/index.md)

[이전 공통 하단 외관 비교](composed-final/index.md)

2026-11-19 · 화면 좌상단 원점 · 물리 픽셀

| 해상도 | Devil 전체 | 하단 1:1 | 단축키 2배 | Horde 전체 / 하단 | Alliance 전체 / 하단 |
|---|---|---|---|---|---|
| FHD · 1920×1080 | [전체](fhd-devil-full.png) | [하단](fhd-devil-bottom.png) | [단축키](fhd-devil-keys-x2.png) | [전체](fhd-horde-full.png) / [하단](fhd-horde-bottom.png) | [전체](fhd-alliance-full.png) / [하단](fhd-alliance-bottom.png) |
| QHD · 2560×1440 | [전체](qhd-devil-full.png) | [하단](qhd-devil-bottom.png) | [단축키](qhd-devil-keys-x2.png) | [전체](qhd-horde-full.png) / [하단](qhd-horde-bottom.png) | [전체](qhd-alliance-full.png) / [하단](qhd-alliance-bottom.png) |
| UHD · 3840×2160 | [전체](uhd-devil-full.png) | [하단](uhd-devil-bottom.png) | [단축키](uhd-devil-keys-x2.png) | [전체](uhd-horde-full.png) / [하단](uhd-horde-bottom.png) | [전체](uhd-alliance-full.png) / [하단](uhd-alliance-bottom.png) |

[탐험·전투·파티·공격대·입력·소환수 목업 18장과 테마 비교](ux/index.md)

[행동 단축바·미니맵 세 해상도 1:1 비교](ux/resolution-native-comparison.png)

| 해상도 | 전사 분노·태세 | 도적 기력·연계 점 | 주술사 마나·토템 | 드루이드 표범 기력·연계 점·마나 |
|---|---|---|---|---|
| FHD | [전사](fhd-devil-class-warrior.png) | [도적](fhd-devil-class-rogue.png) | [주술사](fhd-devil-class-shaman.png) | [드루이드](fhd-devil-class-druid-cat.png) |
| QHD | [전사](qhd-devil-class-warrior.png) | [도적](qhd-devil-class-rogue.png) | [주술사](qhd-devil-class-shaman.png) | [드루이드](qhd-devil-class-druid-cat.png) |
| UHD | [전사](uhd-devil-class-warrior.png) | [도적](uhd-devil-class-rogue.png) | [주술사](uhd-devil-class-shaman.png) | [드루이드](uhd-devil-class-druid-cat.png) |

| 플레이어·대상 배치 | PitBull4 | Forever Unit Frames |
|---|---|---|
| FHD | [PitBull4](fhd-devil-unit-pitbull4.png) | [Forever Unit Frames](fhd-devil-unit-fuf.png) |
| QHD | [PitBull4](qhd-devil-unit-pitbull4.png) | [Forever Unit Frames](qhd-devil-unit-fuf.png) |
| UHD | [PitBull4](uhd-devil-unit-pitbull4.png) | [Forever Unit Frames](uhd-devil-unit-fuf.png) |

## 배치 근거

- 세 대화창, 중앙 8×3과 위 36칸, 보조 구역, 사각 미니맵, 두 체력·자원 구획의 좌표는 [프리셋](../2-layouts/layouts/)에서 읽었다. UHD의 아래 구획은 기존 Step 5 위치다. 위 유닛 프레임부터 바닥까지 FHD y620~1080, QHD y908~1440, UHD y1440~2160이다. 각 영역 좌표는 [기하 검사](geometry-checks.json)에 있다.
- 기본 화면에는 Dominos의 실제 빈 Onyx 슬롯, 사각 미니맵 영역, Details 두 창의 준비된 자리를 배치했다. 기본 그림은 스킬이나 키 배정이 없는 상태다. 배치에 사용한 좌표는 [기능별 좌표](feature-positions.json)와 Dominos 프로필에 있다.
- 패널·장식·막대와 버튼 테두리는 **설치 ZIP에서 직접 읽은 이미지**를 사용했다. Onyx의 `Textures/Base/Frame.tga`는 빈 상태에 남는 레이어다. 유색 외곽 사이의 설계값은 2px이고, 렌더의 희미한 가장자리를 포함하면 완전 투명한 열은 FHD/QHD/UHD에서 각각 1/0/1px이다. 임의 스킬 칸은 제거했다. [ZIP 자산과 SHA256](asset-provenance.json)
- 데빌·호드·얼라이언스에 각각 제작한 양끝 장식과 패널·구분선·막대 이미지를 읽는다. PitBull4와 소환수 열은 같은 후보가 계산한 프레임 경계를 사용한다. [테마 적용 화면의 4K 원배율 디테일](ux/themes-uhd-native-details.png)
- 고정 프리셋에서 Dominos의 일반 8번 바는 숨김이다. 기본 화면과 탐험·전투 목업에서 해당 구역에 가짜 빈 슬롯 여덟 칸을 그리던 것을 제거했다. 직업별 태세·토템은 해당 목업에서 별도 상태로 확인한다.
- 단축키 확대에만 Step 5에서 측정한 글꼴과 예시 문자열 16개를 넣었다. 이 글꼴은 목업 전용이다. 일반 그림은 키 배정을 가정하지 않는다. 직업별 예시는 실제 패키지 막대 텍스처와 PitBull4 연계 점 `default.tga`를 사용했다.
- 두 유닛 프레임 그림은 같은 역할 좌표를 비교한다. Forever Unit Frames 그림은 준비한 CLASSIC 레이아웃과 패키지 자산으로 그렸으며, 실제 사용 중인 프로필이나 캐릭터 초상을 읽어 그린 것은 아니다. [한 번의 접속 확인표](../../codex-verify/one-session-review.md)

## 등록 이름과 표시

| 구역 | 등록 키와 게임 프레임 | 목업에 사용한 입력 |
|---|---|---|
| 셸과 세 대화창 | `appearance.chat1`–`chat3` → `DevilForever_ChatPanel1`–`3`. 실제 대화창 번호는 `DevilForever_ChatSetupDB.windows`에 있는 역할별 `ChatFrame` | 2 셸·테마, 2-layouts 프리셋, 4 [창 설정](../4/report.md) |
| 행동단축바와 미니맵 | `dominos.bar1`–`7` → `DominosFrame1`–`7`, `dominos.stance` → `DominosFrameclass`, `dominos.totem` → `DominosFrametotem`, `sexymap.minimap` → `Minimap` | 3 [단축바](../3/report.md), 5 [미니맵](../5/report.md), 2-layouts |
| 플레이어·대상 | `pb4.player`·`pb4.target` → `PitBull4_Frames_플레이어`·`PitBull4_Frames_대상`. 비교판 `fuf.player`·`fuf.target` → `ForeverUnitFrames_player`·`ForeverUnitFrames_target` | 6-rev [PitBull4](../6-rev/report.md), 6 [Forever Unit Frames](../6/report.md), 24 좌표표 |
| 추천·미터기·상태띠 | `hekili.primary` → `HekiliDisplayPrimary`, `details.damage`·`details.threat` → `DetailsBaseFrame1`·`DetailsBaseFrame2`, `statusstrip.bar` → `DevilForever_StatusStripFrame` | 8 [Hekili](../8/report.md), 10 [Details](../10/report.md), 16 [상태띠](../16/report.md) |

UHD 하단은 Step 5와 같은 `y=1440`부터다. 미니맵 지형과 메뉴·가방·대기열의 그림, 캐릭터 초상은 게임에서 받는다. ZIP에 없는 그림 대신 구역만 표시했다. [세 해상도 이름표와 전투 화면](ux/index.md)

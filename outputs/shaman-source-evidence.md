# Forever 주술사·UI 후보 근거표

확인일: 2026-11-17. 현재 지원·후기 검색 범위: 2026-09-01~2026-11-17. 외형 원천만 2022년 자료를 별도로 사용했다. UI(User Interface)는 게임 화면의 버튼·상태창·미니맵을 뜻한다. 아래 확정은 **해당 페이지의 표기 또는 보고가 확인됐다는 뜻**이며 실제 게임 정상 작동 판정은 아니다.

## 원래 외형과 현재 지원 선언

| 번호 | 원천·날짜·유형 | 짧은 원문 인용 | 확인한 내용 | 한계·계획 반영 |
|---|---|---|---|---|
| S1 | [Devil UI Black FanFix 원문](https://www.inven.co.kr/board/wow/1636/31588), 마른가지, 2022-11-14·11-19 수정, 제작자 배포글 | “16:10, 4k 모니터에 최적화 되어 있습니다.” | Dominos·PitBull·Quartz·SexyMap·ChocolateBar_FanFix의 조합과 프로필 설정 안내 | 확정: 조합 설명. 첫 이미지의 정확한 좌표·폰트·텍스처와 ZIP 내부는 미검증. 2560×1440에 숫자를 그대로 복사하지 않음. 원문의 폴더 삭제 안내는 실행 지침으로 채택하지 않음 |
| S2 | [Dominos](https://www.curseforge.com/wow/addons/dominos), Tuller, 2026-11-17, 공식 프로젝트 | “Customizable action bar paging” | Forever flavor의 12.0.4 파일, 배치·paging·keybind·Masque 지원 설명 | 확정: 배포·기능 선언. 앱 제공 12.0.4와 일치. 기존 11.0.5의 정상 작동이나 이전 프로필 호환은 미검증 |
| S3 | [SexyMap](https://www.curseforge.com/wow/addons/sexymap), Funkeh, 2026-11-05, 공식 프로젝트 | “Minimap moving” | Forever flavor의 v12.1.7 파일, 미니맵 이동·테두리·버튼·zoom 설정 설명 | 확정: 배포·기능 선언. 설치되지 않았던 후보. 원래 loaf 프로필 확보·가져오기와 Questie 아이콘·클릭은 미검증 |
| S4 | [Quartz](https://www.curseforge.com/wow/addons/quartz), nevcairiel, 파일 2026-11-13, 공식 프로젝트 | “Modular casting bar.” | 원본 프로젝트의 Forever flavor 3.8.0, player·target castbar와 optional modules 설명 | 확정: 배포·기능 선언. 앱 제공 3.8.0와 일치. 페이지 Last Update 11-14와 파일 날짜 11-13은 서로 다른 항목. Quartz [Updated]·Redux로 임의 변경하지 않음 |
| S5 | [PitBull Unit Frames 4.0](https://www.curseforge.com/wow/addons/pitbull-unit-frames-4-0), ckknight 외, 표시된 마지막 갱신 2026-06-14, 공식 프로젝트 | “Classic Era/Vanilla is supported in `v4.3.x-vanilla` releases.” | 현재 보이는 flavors는 Retail·MoP Classic·Classic·Classic TBC, Forever 표기 미발견 | 근거 미발견: Forever 지원 선언. 서비스 중단·작동 불가 판정이 아님. 단순히 Classic 파일을 골라 설치하지 않음 |
| S6 | [Forever Unit Frames](https://www.curseforge.com/wow/addons/forever-unit-frames), StephanTxC, 0.65.0·2026-11-17, 공식 프로젝트 | “Unit frames built for WoW: Forever” | Forever·1.60.1 선언. 위치·폰트·체력/자원·프로필·토템·전투 aura·party/raid 기능 설명 | 확정: 제작자 선언. 원본 Devil 외형 재현 가능성·한국어·전투 작동은 미검증. 전체 테마 일괄 적용·click-casting 자동 설정을 채택하지 않고, 후보 선택 gate에서 범위를 제한 |
| S7 | [원본 Hekili](https://www.curseforge.com/wow/addons/hekili), Hekili, 현재 열람, 공식 프로젝트 | “Hekili is not compatible with the Midnight (12.0) expansion.” | Retail flavor만 표시. 현재 포에버 목록에 있던 The War Within 프로젝트와 Forever fork는 별개 | 확정: 원본의 명시 문구. 이 한 줄로 Forever 전체의 addon API(Application Programming Interface, 애드온이 호출하는 게임 기능) 지원을 판정하지 않음 |
| S8 | [Hekili Forever](https://www.curseforge.com/wow/addons/hekili-forever), defzach, 2026-11-16 갱신, fork 제작자 설명 | “Shaman (Enhancement, Elemental)” / “a buff to refresh or a proc to use” | 고양·정기를 지원 대상으로 명시. Focus 알림·추천 queue·첫 추천 glow를 함께 평가할 수 있음. 원본 작성자 허락을 받았다는 것은 fork 제작자의 주장 | 확정: 선언. 복원 healing 추천 지원은 이 목록에서 근거 미발견. `Hekili` 폴더와 `HekiliDB`를 재사용하므로 구버전과 동시 설치·설정 충돌 확인 필요. 문서의 beta 설치 경로를 실제 `_forever_` 경로로 무조건 적용하지 않음 |
| S9 | [Hekili Forever v0.8.5 파일](https://www.curseforge.com/wow/addons/hekili-forever/files/9640496), defzach, 2026-11-16, 공식 release notes | “Supported game versions” / “1.60.1” | `Hekili-v0.8.5-forever.zip`. 토템 mana cost·Totemic Focus·정기 Revelation charge 처리 수정 설명. 일부 전투 mana 변화의 관측 한계도 서술 | 확정: 배포·수정 설명. 수정됐다는 발표를 추천 정확성 검증으로 세지 않음. 전투 중 자원·proc·토템 교체·학습 rank와 추천 변화를 실제 검증 |
| S10 | [EventAlert](https://www.curseforge.com/wow/addons/event-alert), 공개 프로젝트, 현재 열람(표시된 마지막 갱신 2019-11-07) | “the time left on the proc” | 중앙 아이콘·효과 이름·남은 시간·소리 설명. Forever flavor 미발견 | 사용자에게 필요한 효과 알림을 정의하는 역사 자료. Hekili와의 코드 계보를 주장하지 않음. EventAlertMod의 Forever 작동도 확인하지 않았으며 대체 설치 확정 안 함 |

## 실제 주술사 경험과 반론

| 번호 | 원천·기간·작성자/유형 | 짧은 원문 인용 | 관찰 | 한계·계획 반영 |
|---|---|---|---|---|
| U1 | [포에버 주술사 40레벨 이후 후기](https://www.inven.co.kr/board/wow/6567/23257?vtype=pc), 내밥, 2026-11-14 12:09, 한국어 1인칭 본문 | “정술 고술 다 해봄” | 레벨업하며 두 특성을 경험한 글쓴이는 재미 저하와 PvP 불만을 보고 | 검색 캐시에 표시된 본문은 확인. 직접 열기는 502·모바일 cache miss로 실패, 댓글은 미확인. UI 제품 평가나 전체 주술사 합의로 쓰지 않음 |
| U2 | [Shaman Totems Setup](https://www.reddit.com/r/wowforever/comments/1xtmxel/shaman_totems_setup/), 2026-11 중순, OkKindheartedness278·S_B_C_R, 1인칭 질문·답변 | “I am playing WoW Forever on a controller” | 질문자는 토템 수·버튼 부담을 호소. 고양을 쓰는 답변자는 자주 쓰는 기본 세트와 상황별 토템을 구분 | 원문 표시 2d ago와 검색 5 days ago가 달라 정확한 작성일 미확인. controller 경험을 키보드 배치 정답으로 옮기지 않음. 토템 슬롯·상황별 접근·기존 단축키 표시를 검증 항목으로 채택 |
| U3 | [Which Healer classes are decent?](https://www.reddit.com/r/wowforever/comments/1xxogd5/which_healer_classes_are_decent/), 검색 댓글 날짜 2026-11-16·원문 18h ago, GreatValueUser, 복원 사용자 댓글 | “I am running a resto shaman and so far no issues” | 치유 화면 편의와 mouseover click casting을 권하는 긍정 경험 | 1인 경험, 실제 레벨·전투 로그·사용 addon 미제시. 새 단축키·매크로 제작 요구로 확대하지 않음. 복원 선택 시 party/raid·치유 대상 선택·mana 표시 별도 gate |
| U4 | [Feedback on Riptide](https://www.reddit.com/r/classicwow/comments/1xx0gdm/feedback_on_riptide/), 2026-11 중순·열람상 21h ago, CantEvenSmokeWeed 본문과 Bohya 답글 | “UI doesn't even show targets that have Riptide” | Forever 표기가 있는 글. 56레벨 주술사는 복원 전환 후 Riptide 사용감 불만, 댓글은 raid형 party frame의 추적 문제 제기 | 1인칭 불만과 UI 주장. 실제 설정·사용 파일·재현 미제시. 치유 기능 수치나 버그의 확정 근거로 쓰지 않음 |
| U5 | [같은 글의 반론](https://www.reddit.com/r/classicwow/comments/1xx0gdm/feedback_on_riptide/), 같은 기간, 본문 작성자의 답글 | “This is actually solvable in the base UI!” | 기본 Cooldown Manager의 buff 설정으로 표시 가능하다는 반론 | U4와 함께 보존. 두 주장 중 하나를 runtime 사실로 확정하지 않음. 복원 적용 때 실제 Riptide 표시를 먼저 시험하고 부족할 때만 추가 도구 검토 |
| U6 | [같은 글의 고양 경험](https://www.reddit.com/r/classicwow/comments/1xx0gdm/feedback_on_riptide/), 같은 기간, TheStormGoose·Volker-Vollgas | “Enh shaman main - it feels amazing.” | 고양 사용감·dungeon 경험을 긍정하는 댓글과, 60레벨에서 mana·토템 이동·cooldown 부담을 호소하는 댓글이 공존 | 긍정·부정을 합쳐 ‘고양 평가’ 점수로 만들지 않음. 특성·레벨·상황 차이가 있으므로 본인의 mana·토템·시전 흐름을 선택 기준으로 사용 |

U4~U6의 직접 인용 합계는 같은 URL 전체에서 25단어 이하로 제한했다. 공개 작성자명은 외부 근거 구분용이며 사용자 PC의 계정·캐릭터 식별자는 수집하지 않았다. 댓글의 추천·조회 수는 현재 도구가 안정된 수치로 제공하지 않아 인기 가중치를 계산하지 않았다.

## 판단과 빈칸

- **확정:** 공식 프로젝트에서 Dominos·SexyMap·Quartz·Forever Unit Frames·Hekili Forever의 Forever 배포 표기를 확인했다. 한국어·영어의 실제 주술사 경험도 찾았다. 이는 배포 사실·공개 보고 존재 확인이다.
- **근거 미발견:** 이번 한·영 검색 범위에서 Hekili Forever를 직접 사용한 주술사의 충분한 독립 후기를 찾지 못했다. PitBull의 명시 Forever 지원, Hekili Forever의 복원 healing 추천 지원도 확인하지 못했다.
- **추정·설계 판단:** 원본 외형과 행동 흐름을 복원하되 토템·mana·치유 대상 정보를 가리지 않는 구성이 필요하다. 제작자 지원 선언과 사용 후기만으로 최종 provider를 보장할 수 없어 프로필·게임 gate로 선택한다.
- **미검증:** 모든 후보의 이 PC 전투 작동, 폰트·텍스처·정밀 좌표, 성능, 기존 설정·keybind·macro 유무, 원본 ZIP의 실제 내용. 설치·설정 적용·게임 조작은 수행하지 않았다.

## 검색 범위와 접근 한계

처음에는 `포에버 주술사 헤키리`, `Forever shaman Hekili`, `WoW Forever shaman UI totem restoration`에 위 시간창을 붙여 발견 검색했다. 이후 Inven과 Reddit의 토템·복원·고양·정기 글과 공식 프로젝트·release를 좁혀 읽었다. 일반 추천 모음·guide·다른 Retail/Classic 경험은 Forever 사용자 후기로 세지 않았다. Hekili Forever 댓글 URL은 도구에서 접근 불가, Inven 일부 글은 502 또는 cache miss였다. 재검색으로 확보한 한국어 본문 캐시의 한계를 U1에 남겼다. 추가 후기 탐색은 종료했으며 원문 열기 실패를 부재 증거로 바꾸지 않았다.

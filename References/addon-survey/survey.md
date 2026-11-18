# 기능별 대표 인기 후보 조사

조사 일시: **2026-11-18 KST(한국 표준시)**. 최종 관측 기록: **10:43 KST**. 개별 URL의 정확한 취득 시각은 미측정이다.
실제로 본문을 열어 읽은 서로 다른 URL 수: **42개**(같은 최종 URL 재열기는 1개, 검색 결과·다운로드 주소 제외).

열기 실패한 URL 목록(3개):

- https://www.curseforge.com/wow/addons/cooldown-count — 본문 접근 실패. 검색으로 찾은 정상 제품 주소 `/cooldowncount`는 열어 아래 표에 사용했다.
- https://www.tukui.org/elvui — 본문 접근 실패. 공식 GitHub 저장소는 열어 사용했다.
- https://www.tukui.org/tukui — 본문 접근 실패. 공식 GitHub 저장소는 열어 사용했다.

전체 후보의 동일 시점 인기 순위를 측정한 결과가 아니라, 요청의 예시와 공식 페이지의 공개 인기 지표·기능 관련성으로 선정한 **대표 인기 후보**다. Reflux·MoveAnything·Omen처럼 갱신이 오래된 후보도 기존 설계의 비교 대상으로 포함했다. 현재 설치 권고 순위는 아니다.

UI(User Interface)는 게임 조작·정보 화면, HUD(Heads-Up Display)는 화면 위 상태 표시, API(Application Programming Interface)는 프로그램 간 정보 전달 규칙을 뜻한다.

웹 도구가 반환한 페이지 표시값을 기록했다. 페이지마다 캐시 시점이 달라 인기 지표가 실시간 또는 같은 순간의 값임을 뜻하지 않는다.

최근 갱신일은 CurseForge 프로젝트의 **Last Update**, 다운로드 수는 **프로젝트 전체 누적 Downloads**이며 Forever 전용 수치가 아니다. GitHub는 별도로 **star 수**를 표시하고 다운로드와 직접 비교하지 않는다. 제작자는 CurseForge의 **By** 표기를 옮겼으며, GitHub 저장소 소유자를 제작자로 대신 쓰지 않았다.

Forever 지원은 실제 연 프로젝트의 **Recent Files(최근 파일 목록)**에서 파일에 Forever가 명시된 경우만 확인으로 적었다. 전체 파일 이력의 전수 확인은 아니므로 **미확인은 미지원 판정이 아니다**. 특징은 공식 프로젝트 소개·설명의 요약이며 게임 내 작동을 시험한 결과가 아니다. 근거 등급은 관측한 셀에 적용하며 별도 미확인 셀까지 확정한다는 뜻이 아니다. 관측 위치와 행 연결은 [조사 근거](evidence/survey-sources.json)에 있다.

## 1. 전체 UI 통합 패키지

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| SpartanUI | wutname1 | 표기 확인: 9.0.5 / Forever (Recent Files) | Nov 15, 2026 | 누적 5,254,875 (프로젝트 전체) | 화면 아래 중심 배치와 선택 사용이 가능한 모듈 구성; 플레이어·파티·공격대 프레임 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/spartan-ui) | 확정(페이지에서 봄) |
| GW2 UI | Mortalknight | 표기 확인: 12.1.9 / Forever (Recent Files) | Nov 16, 2026 | 누적 2,738,400 (프로젝트 전체) | 손으로 그린 외관의 모듈형 UI; HUD·유닛 프레임·가방·퀘스트 추적기를 통합. | [공식 프로젝트](https://www.curseforge.com/wow/addons/gw2-ui) | 확정(페이지에서 봄) |
| NDui | siweia | 미확인 | Nov 8, 2026 | 누적 725,408 (프로젝트 전체) | 오라 감시·프레임·이름표·채팅 필터·가방·정보 바를 함께 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/ndui) | 확정(페이지에서 봄); Forever 미확인 |
| ElvUI | 미확인 | 미확인 | 미확인 | GitHub star 716 (다운로드 수 미확인) | 기본 UI를 교체하는 애드온으로 공식 저장소에서 소개; 세부 모듈 구성은 이 조사에서 미확인. | [공식 저장소](https://github.com/tukui-org/ElvUI) | 확정(페이지에서 봄); 제작자·갱신일·Forever 미확인 |
| TukUI | 미확인 | 미확인 | 미확인 | GitHub star 57 (다운로드 수 미확인) | 공식 저장소 Live 가지를 Dragonflight·Wrath·Classic Era용으로 소개; 세부 기능은 미확인. | [공식 저장소](https://github.com/tukui-org/Tukui) | 확정(페이지에서 봄); 제작자·갱신일·Forever 미확인 |

참고 추천: 추정: GW2 UI의 모듈별 해제 방식과 SpartanUI의 화면 아래 배치는 통합 UI의 구성·배치 비교에 참고하기 좋다.

## 2. 행동단축바

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Dominos | Tuller | 표기 확인: 12.0.4 / Forever (Recent Files) | Nov 17, 2026 | 누적 23,126,451 (프로젝트 전체) | 이동 가능한 단축바에 배치·페이지 전환·표시 조건과 Masque 외관 설정을 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/dominos) | 확정(페이지에서 봄) |
| Bartender4 | nevcairiel | 표기 확인: 4.19.0 / Forever (Recent Files) | Nov 17, 2026 | 누적 82,976,564 (프로젝트 전체) | 행동·태세·소환수 등 관련 바의 크기·투명도·매크로 조건별 표시를 조정. | [공식 프로젝트](https://www.curseforge.com/wow/addons/bartender4) | 확정(페이지에서 봄) |
| Button Forge | AlternativeTheory | 미확인 | Aug 12, 2026 | 누적 999,090 (프로젝트 전체) | 기본 바와 독립적인 추가 단축바를 행·열 단위로 생성. | [공식 프로젝트](https://www.curseforge.com/wow/addons/button-forge) | 확정(페이지에서 봄); Forever 미확인 |

참고 추천: 추정: Bartender4의 매크로 조건별 표시와 Button Forge의 독립 추가 바를 Dominos 외 설계 대안으로 참고할 만하다.

## 3. 미니맵

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| SexyMap | Funkeh | 표기 확인: v12.1.7 / Forever (Recent Files) | Nov 5, 2026 | 누적 37,528,935 (프로젝트 전체) | 미니맵 이동·테두리·버튼 숨김·확대/축소와 추적용 HUD를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/sexymap) | 확정(페이지에서 봄) |
| Mapster | nevcairiel | 표기 확인: 1.14.0 / Forever (Recent Files) | Nov 3, 2026 | 누적 10,926,154 (프로젝트 전체) | 세계지도 중심: 크기·투명도·좌표·미탐색 영역 표시를 조정하며 미니맵 대체 제품과 범위가 다름. | [공식 프로젝트](https://www.curseforge.com/wow/addons/mapster) | 확정(페이지에서 봄) |
| BasicMinimap | Funkeh | 표기 확인: v12.1.6 / Forever (Recent Files) | Oct 22, 2026 | 누적 1,189,803 (프로젝트 전체) | 미니맵 이동·크기·사각/원형·버튼 숨김과 테두리 색상을 조정. | [공식 프로젝트](https://www.curseforge.com/wow/addons/basic-minimap) | 확정(페이지에서 봄) |

참고 추천: 추정: BasicMinimap은 최소 미니맵 설정 구성을, Mapster는 별도 세계지도·좌표 기능을 비교하는 참고자료로 유용하다.

## 4. 채팅

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Prat 3.0 | QTartemis | 표기 확인: 3.9.117 / Forever (Recent Files) | Nov 17, 2026 | 누적 35,585,874 (프로젝트 전체) | 메시지 필터와 채팅 화면 변경을 제공하는 채팅 확장. | [공식 프로젝트](https://www.curseforge.com/wow/addons/prat-3-0) | 확정(페이지에서 봄) |
| Chattynator | plusmouse | 표기 확인: 237 / Forever (Recent Files) | Nov 17, 2026 | 누적 2,906,250 (프로젝트 전체) | 채팅 프레임을 교체하며 테마·위치/크기·타임스탬프와 세션 간 메시지 이력을 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/chattynator) | 확정(페이지에서 봄) |
| Glass Forever | Rethz | 표기 확인: Glass Forever 1.1.6 / Forever (Recent Files) | Nov 16, 2026 | 누적 4,901 (프로젝트 전체) | 나타났다 사라지는 간결한 채팅 화면; 설정 profile을 텍스트로 내보내고 가져오기 가능. | [공식 프로젝트](https://www.curseforge.com/wow/addons/glass-forever) | 확정(페이지에서 봄) |
| BasicChatMods | Funkeh | 표기 확인: v12.1.1 / Forever (Recent Files) | Oct 22, 2026 | 누적 780,638 (프로젝트 전체) | 채팅 창을 화면 가장자리까지 이동하고 모듈을 선택적으로 켜거나 끄는 구성. | [공식 프로젝트](https://www.curseforge.com/wow/addons/basic-chat-mods) | 확정(페이지에서 봄) |

참고 추천: 추정: 시작 채팅 애드온 외 BasicChatMods의 선택형 모듈과 화면 가장자리 이동을 참고하면 필요한 채팅 변경의 최소 범위를 비교하기 좋다.

## 5. 유닛 프레임

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Forever Unit Frames | StephanTxC | 표기 확인: Forever Unit Frames 0.65.2 / Forever (Recent Files) | Nov 17, 2026 | 누적 50,940 (프로젝트 전체) | 플레이어·대상·주시·소환수·파티·공격대 프레임에 오라·위협·거리·해제 표시를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/forever-unit-frames) | 확정(페이지에서 봄) |
| Shadowed Unit Frames | Shadowed103 | 미확인 | Jan 18, 2026 | 누적 19,506,697 (프로젝트 전체) | 여러 유닛을 한꺼번에 설정하며 바 높이·순서와 프레임 높이를 조정. | [공식 프로젝트](https://www.curseforge.com/wow/addons/shadowed-unit-frames) | 확정(페이지에서 봄); Forever 미확인 |
| PitBull Unit Frames 4.0 | ckknight | 미확인 | Jun 14, 2026 | 누적 5,678,362 (프로젝트 전체) | 유닛 프레임 패키지; 공식 설명에서 레이아웃 제작 및 파티·공격대 프레임 안내를 연결. | [공식 프로젝트](https://www.curseforge.com/wow/addons/pitbull-unit-frames-4-0) | 확정(페이지에서 봄); Forever 미확인 |

참고 추천: 추정: Shadowed Unit Frames의 여러 유닛 동시 설정을 Forever Unit Frames 외 설정 화면 설계의 비교 대상으로 참고할 만하다.

## 6. 시전바

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Quartz | nevcairiel | 표기 확인: 3.8.0 / Forever (Recent Files) | Nov 14, 2026 | 누적 32,890,535 (프로젝트 전체) | 모듈형 시전바 애드온. | [공식 프로젝트](https://www.curseforge.com/wow/addons/quartz) | 확정(페이지에서 봄) |
| Gnosis (Castbars and Timers) | elchefe12345 | 미확인 | Nov 8, 2026 | 누적 2,370,508 (프로젝트 전체) | 세밀한 설정이 가능한 시전바 및 단일 타이머 애드온. | [공식 프로젝트](https://www.curseforge.com/wow/addons/gnosis) | 확정(페이지에서 봄); Forever 미확인 |
| Classic Castbars | Wardz__ | 미확인 | Jul 11, 2026 | 누적 22,924,090 (프로젝트 전체) | 적 시전바를 조정하는 애드온. | [공식 프로젝트](https://www.curseforge.com/wow/addons/classiccastbars) | 확정(페이지에서 봄); Forever 미확인 |

참고 추천: 추정: Gnosis의 시전바·타이머 결합과 Classic Castbars의 적 시전바 중심 범위를 Quartz 외 비교 대상으로 참고할 수 있다.

## 7. 설정 저장·복원·profile 공유

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Reflux | moonfann | 미확인 | Oct 20, 2014 | 누적 359,769 (프로젝트 전체) | 여러 애드온의 AceDB profile을 함께 전환하며, 그 밖 애드온의 profile 모방도 사용자 설정으로 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/reflux) | 확정(페이지에서 봄); Forever 미확인 |
| Myslot | oishii1992 | 표기 확인: v6.3.1 / Forever (Recent Files) | Nov 14, 2026 | 누적 5,433,479 (프로젝트 전체) | 단축바·매크로·키 설정을 텍스트로 공유; 가져오기 전 자동 백업과 선택 적용을 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/myslot) | 확정(페이지에서 봄) |
| ProfileManager | Lanaiba | 표기 확인: ProfileManager_v4.0.zip / Forever (Recent Files) | Nov 15, 2026 | 누적 10,748 (프로젝트 전체) | 지원 애드온 profile·Edit Mode 배치·키 설정을 한 창에서 저장·전환하고 preset을 문자열로 공유. | [공식 프로젝트](https://www.curseforge.com/wow/addons/profilemanager) | 확정(페이지에서 봄) |

참고 추천: 추정: Myslot의 가져오기 전 자동 백업과 ProfileManager의 지원 애드온별 선택 적용은 설정 복원·공유 흐름 비교에 참고할 만하다.

## 8. UI 이동·편집

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| MoveAnything | Resike | 미확인 | Apr 30, 2022 | 누적 18,532,402 (프로젝트 전체) | 화면 요소의 이동·크기·숨김·투명도와 프레임 그룹 등을 편집. | [공식 프로젝트](https://www.curseforge.com/wow/addons/move-anything) | 확정(페이지에서 봄); Forever 미확인 |
| BlizzMove | kiatra_ | 표기 확인: v3.8.8 / Forever (Recent Files) | Nov 7, 2026 | 누적 12,834,755 (프로젝트 전체) | 기본 창 제목을 끌어 이동하고 Ctrl+휠로 크기를 조정; 하위 창 분리도 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/blizzmove) | 확정(페이지에서 봄) |
| Edit Mode Expanded | Teelo | 표기 확인: 12.1-026 / Forever (Recent Files) | Nov 14, 2026 | 누적 1,604,006 (프로젝트 전체) | 기본 Edit Mode에서 다룰 수 있는 프레임 범위를 확장. | [공식 프로젝트](https://www.curseforge.com/wow/addons/edit-mode-expanded) | 확정(페이지에서 봄) |

참고 추천: 추정: BlizzMove의 창 제목 드래그·크기 조정과 Edit Mode Expanded의 기본 편집 모드 확장을 UI 이동 방식의 비교 대상으로 참고할 수 있다.

## 9. 직업 전투보조·알림

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Hekili Forever | defzach | 표기 확인: v0.8.6 / Forever (Recent Files) | Nov 17, 2026 | 누적 57,804 (프로젝트 전체) | 공격·방어 전문화의 우선순위/회전 보조; 아이콘 대기열과 Timeline 표시를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/hekili-forever) | 확정(페이지에서 봄) |
| WeakAuras | Stanzilla | 미확인 | Nov 16, 2026 | 누적 255,763,730 (프로젝트 전체) | 오라·자원·재사용 대기시간·전투 이벤트 등 조건에 따라 사용자 그래픽·소리·텍스트 표시를 구성. | [공식 프로젝트](https://www.curseforge.com/wow/addons/weakauras-2) | 확정(페이지에서 봄); Forever 미확인 |
| TellMeWhen | Cybeloras | 표기 확인: 12.1.5 / Forever (Recent Files) | Nov 12, 2026 | 누적 27,685,883 (프로젝트 전체) | 재사용 대기시간·강화 효과 등 전투 정보에 시각·청각·텍스트 알림을 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/tellmewhen) | 확정(페이지에서 봄) |

참고 추천: 추정: Hekili 외 WeakAuras의 조건별 표시와 TellMeWhen의 여러 감각 알림을 참고하면 회전 추천과 상태 알림을 나누어 비교하기 좋다.

## 10. 재사용 대기시간 표시

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| OmniCC | Tuller | 미확인 | Dec 14, 2025 | 누적 65,937,859 (프로젝트 전체) | 기술·아이템의 재사용 대기시간을 아이콘 위 숫자 텍스트로 표시. | [공식 프로젝트](https://www.curseforge.com/wow/addons/omni-cc) | 확정(페이지에서 봄); Forever 미확인 |
| OmniCD | Treebonker | 미확인 | Aug 28, 2026 | 누적 34,009,222 (프로젝트 전체) | 파티원의 기술 재사용 대기시간과 차단 바를 추적; 개인 아이콘 숫자 표시와 범위가 다름. | [공식 프로젝트](https://www.curseforge.com/wow/addons/omnicd) | 확정(페이지에서 봄); Forever 미확인 |
| CooldownCount | dakikifr | 미확인 | Mar 27, 2026 | 누적 1,382,430 (프로젝트 전체) | 기술·아이템 아이콘의 재사용 대기시간 숫자 표시를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/cooldowncount) | 확정(페이지에서 봄); Forever 미확인 |

참고 추천: 추정: OmniCC/CooldownCount의 아이콘 숫자 표시와 OmniCD의 파티 기술 추적을 별도 기능으로 참고하면 표시 대상과 정보 범위를 비교하기 좋다.

## 11. 공격대·파티 프레임

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Grid2 | michaelsp | 표기 확인: 4.1.13-forever / Forever (Recent Files) | Nov 15, 2026 | 누적 15,619,119 (프로젝트 전체) | 파티·공격대 프레임을 격자 형태로 제공하는 모듈형 애드온. | [공식 프로젝트](https://www.curseforge.com/wow/addons/grid2) | 확정(페이지에서 봄) |
| VuhDo | humfras | 표기 확인: v3.221 / Forever (Recent Files) | Nov 17, 2026 | 누적 30,352,311 (프로젝트 전체) | 클릭 치유·강화/약화 효과 관리·주 탱커 관리를 제공하는 공격대 프레임. | [공식 프로젝트](https://www.curseforge.com/wow/addons/vuhdo) | 확정(페이지에서 봄) |
| Cell | enderneko | 미확인 | Aug 9, 2026 | 누적 4,512,024 (프로젝트 전체) | 파티·공격대 등의 레이아웃 전환과 클릭 시전·다양한 상태 표시기를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/cell) | 확정(페이지에서 봄); Forever 미확인 |

참고 추천: 추정: Grid2 외 Cell의 역할별 레이아웃 전환과 VuhDo의 클릭 치유·효과 관리를 공격대 프레임 설정 구성의 비교 대상으로 참고할 만하다.

## 12. 데미지 미터

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| Details! Damage Meter | Terciob | 표기 확인: Details.20261109.15410.172 / Forever (Recent Files) | Nov 18, 2026 | 누적 376,870,604 (프로젝트 전체) | 피해·치유 전투 분석에 사용자 표시와 전투 요약·차트·사망 기록 등의 도구를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/details) | 확정(페이지에서 봄) |
| Recount | Resike | 미확인 | Jul 10, 2025 | 누적 121,704,573 (프로젝트 전체) | 피해·치유 기록을 그래프로 표시하는 전투 미터. | [공식 프로젝트](https://www.curseforge.com/wow/addons/recount) | 확정(페이지에서 봄); Forever 미확인 |
| Skada Damage Meter | zarnivoop | 표기 확인: v2.6.7 / Forever (Recent Files) | Nov 15, 2026 | 누적 39,882,640 (프로젝트 전체) | 전투 구간별 통계와 설정 가능한 여러 창을 제공하는 모듈형 미터. | [공식 프로젝트](https://www.curseforge.com/wow/addons/skada) | 확정(페이지에서 봄) |

참고 추천: 추정: Details! 외 Skada의 모듈형·여러 창 구성과 Recount의 그래프 표시를 미터 화면의 정보 배치 비교에 참고할 수 있다.

## 13. 어그로 미터

| 애드온 | 제작자 | Forever 지원(파일 목록에 Forever/1.60.1 표기 여부) | 최근 갱신일 | 인기 지표(다운로드 수 등) | 특징 한 줄 | 출처 URL | 근거 등급 |
|---|---|---|---|---|---|---|---|
| ForeverThreat | Loyftwa | 표기 확인: ForeverThreat-1.12.3 / Forever (Recent Files) | Nov 17, 2026 | 누적 239,736 (프로젝트 전체) | 대상/주시의 위협 순위·탱커 감지·어그로 경고와 위협 증가량 표시를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/foreverthreat-threat-meter-for-wow-forever) | 확정(페이지에서 봄) |
| ThreatClassic2 | dfherr | 표기 확인: 2.77-forever / Forever (Recent Files) | Nov 7, 2026 | 누적 13,634,705 (프로젝트 전체) | 대상의 파티·공격대 위협 목록과 위협 임계값 소리/화면 경고를 제공. | [공식 프로젝트](https://www.curseforge.com/wow/addons/threatclassic2) | 확정(페이지에서 봄) |
| Omen Threat Meter | Xinhuan | 미확인 | Sep 1, 2022 | 누적 18,827,656 (프로젝트 전체) | Blizzard 위협 정보 API에 기반한 다중 대상 위협 미터로 소개됨. | [공식 프로젝트](https://www.curseforge.com/wow/addons/omen-threat-meter) | 확정(페이지에서 봄); Forever 미확인 |

참고 추천: 추정: ForeverThreat 외 ThreatClassic2의 위협 임계값 경고와 표시 스타일 설정을 비교할 만하다. Omen은 위협 정보 표시의 기존 설계 참고용이며 Forever 지원은 미확인이다.

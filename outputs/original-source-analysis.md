# Devil UI Black 하단집중형 — 구버전 원본 분석

원본 ZIP 두 개를 확보해 검사했고, **하단집중형의 실제 배치 설정과 외형 자산을 찾았다.** 단순히 비슷한 화면을 새로 그리는 것보다 근거가 좋아졌다. 배포본의 선택 프로필 이름은 `loaf`이며 행동단축바, 체력·자원창, 하단 배경, 미니맵, 버튼 스킨에 그 이름의 설정이 남아 있다. 이는 배포자의 내장 설정이며 사용자의 과거 개인 설정은 아니다.

**지금 다시 만들 부분은 전체 애드온 엔진보다 작은 테마·설정 연결부다.** 하단 패널의 구조·테두리·버튼 스킨은 원본을 참고할 수 있고, 행동단축바·미니맵·시전은 현재판 후보가 맡도록 구성할 수 있다. 체력·마나 표시의 현재 provider와 시전바의 정확한 원래 배치는 아직 확정하지 못했다. 이번 결과는 정적 분석이며 설치·게임 실행·화면 일치 판정은 하지 않았다.

## 확보한 원본과 검증

출처는 [2022년 Black FanFix 10.0.2 배포글](https://www.inven.co.kr/board/wow/1636/31588)과 그 글의 [공개 Drive 폴더](https://drive.google.com/drive/folders/1QMZiceFpizZ5dHxTkG2UemZAYKaQFdg7)다. 기준은 사용자가 확정한 첫 스크린샷이다. 원문 재열람 범위·취득 시각·파일 ID는 `Codex/results/source-analysis/acquisition-notes.md`, `acquisition.json`에 보관했다.

| 원본 | 취득한 크기 | 압축 내부 파일 | 압축 해제 크기 | 검사 |
|---|---:|---:|---:|---|
| [Interface.zip](https://drive.google.com/file/d/1EfG94R6Sfo8aJvsAqxqVxQx15rmjsduB/view) | 31,392,260 bytes | 4,604 | 120,721,846 bytes | 전체 CRC 오류 0, 위험 경로 0 |
| [Fonts.zip](https://drive.google.com/file/d/1pZ1NafrEgkH4T4JnSEa4q78Ihn24aoow/view) | 35,611,779 bytes | 10 | 47,177,990 bytes | 전체 CRC 오류 0, 위험 경로 0 |

CRC(Cyclic Redundancy Check)는 ZIP 각 항목의 손상 검사다. 취득 기록과 크기·SHA-256(파일 내용의 해시) 2/2 일치, 추출 파일 해시 4,614/4,614 일치를 확인했다. 해시는 **확보한 바이트를 고정하는 값**이며 제작자가 공개한 체크섬과 비교한 인증은 아니다. 해시 전체와 5,394항목의 원래 경로는 `archive-inventory.json`에 있다. 경로탈출·절대경로·symlink·중복/대소문자 충돌을 추출 전에 검사했고, 원본 Lua는 실행하지 않았다.

보관 위치는 `D:\Projects\Project_WF\SourceArchive\2022-11-19\originals\`, 추출 위치는 같은 폴더의 `extracted\Interface\addons\`와 `extracted\Fonts\`다. 이후 아래 경로는 별도 표시가 없으면 **추출 Interface의 addons 아래 상대경로**이며 행 번호는 원본 파일 기준이다. 대형 원본은 Git 추적에서 제외했다.

## 하단집중형이 적용되는 연결

1. `!DevilUI/!DevilUI.toc:8–13`이 핵심 Lua·프로필 목록·라이브러리·자산 등록을 읽도록 선언한다. `!DevilUI/load_Profile.xml:2–20`에는 배포 프로필 파일 19개가 나열된다. 실제 존재 17개, `Profile/InvenRaidFrames3.lua`와 `Profile/Omen.lua` 두 참조는 파일이 없다. 현재 게임에서 어떤 오류가 날지는 실행하지 않았다.
2. `nibProfileLoader/nibProfileLoader.lua:7–10`에는 화면 설명과 `ProfileName = "loaf"`, `UseClassProfiles = false`가 명시된다. 새 캐릭터 확인의 예 선택은 같은 파일 `48–55`의 `SlashCmdList.REFLUX(RefluxArg)`로 이어진다. 주술사만 별도 프로필을 선택하는 상태가 아니다. TOC `4–6`에는 캐릭터 확인 기록과 Reflux 의존이 있다.
3. `Devilconfig/Devilconfig.lua:84–100`의 메뉴도 `name = "하단집중형"`과 `/reflux switch loaf`를 연결한다. 같은 파일 `51–70`은 왼쪽 센터바를 Dominos 7·9, 오른쪽을 8·10으로 구분한다. 이 두 독립 선택부와 실제 loaf 설정이 서로 맞는다.
4. `Reflux/Reflux.lua:67–93`은 등록된 AceDB 데이터베이스에 `db:SetProfile(profile)`을 호출하고, `402–433`의 switch 분기는 해당 이름을 선택한 뒤 화면을 재시작하도록 작성됐다. SexyMap은 다른 형식의 자체 저장 구조를 사용한다. `SexyMap/SexyMap.lua:232–250,353–379`가 선택한 프로필을 캐릭터 테이블에 복사해 쓰므로, 원문의 별도 SexyMap loaf 복사 안내와 일치한다. Reflux 한 번으로 모든 설정이 완성된다고 보지 않는다.

압축 전체 경로에서 대소문자를 구분하지 않고 `WTF` 경로 요소를 확인한 결과 0개였다. **WTF 폴더는 없지만 애드온 안에 배포용 설정이 있다.** `!DevilUI/Profile/*.lua`의 관련 7파일은 함수가 아닌 literal table 데이터로 끝까지 파싱해 필요한 값을 추출했다. 수만 행을 사람이 전독했다고 주장하지 않는다. 원래 공개 캐릭터별 매핑은 보고서에 옮기지 않았다.

또 하나의 초기화 경로도 남아 있다. `!DevilUI/!DevilUI.lua:42–58`은 `ShapaNormal/ShapaWide/ShapaWH`를 선택하며 `165–195`는 첫 진입 이벤트에서 해상도별 UI scale, 오류 표시 등의 설정을 바꾼다. TOC에 여전히 포함되어 있어 **비활성 코드로 단정할 수 없다.** loaf 선택부와 병존하는 오래된 초기화이므로 실제 이벤트·설정 적용 결과는 미검증이다. 이 경로를 새 구성의 설치기로 그대로 쓰는 것은 권하지 않는다.

## 원래 모습과 현재 구현 역할

저장 좌표는 UI 좌표·anchor·scale을 함께 해석해야 한다. 아래 값은 원본 설정의 증거이며 현재 2560×1440 화면의 pixel 측정값이 아니다. 정확한 첫 이미지 비교는 다음 Step2 범위다.

| 영역 | 원본에서 찾은 실물과 근거 | 재사용·현재판·직접 제작의 구분 |
|---|---|---|
| 행동단축바·좌우 센터바 | `!DevilUI/Profile/Dominos.lua:935–1876`의 loaf. 3·4번은 각각 12버튼/4열/scale1.1, 7–10번은 각각 6버튼/2열/scale0.9. 9·10번은 CENTER 상대 좌우 x 약 ±332.267. 개별 anchor·paging도 보관됨 | **설정 참고 재사용.** 기존 계획의 현재 Forever Dominos 후보에서 다시 구성한다. 구판 데이터 전체를 곧바로 가져오는 호환성은 미검증. 버튼 엔진을 새로 만들 필요는 현재 근거상 없음 |
| 단축키 글자·버튼 테두리 | `Dominos/Dominos.lua:60–79,211–220,557–564`에 binding 갱신과 글자 표시 설정. `!DevilUI/Profile/Masque.lua:29–119`의 Dominos 그룹은 `Onyx Classic`. `Masque_Onyx/Skins.lua:203–214,567–604`가 글자 anchor·Frame-Classic 자산 정의 | **스킨 규격·자산 확보.** 단축키 표시와 실제 키 배정은 별개다. 사용자의 키를 새로 배정하지 않는다. 현재 Masque/Onyx 사용 가능 여부·의존 추가는 이후 선택 때 검증; 이번 설치 대상 확정 아님 |
| 본인·대상 체력/마나 | `!DevilUI/Profile/PitBull4.lua:16252–16410`의 loaf. player 저장 x=-340/y=-204, target x≈338/y=-204, 관련 layout 폭280·Glamour7. HealthBar `13008–13029`, PowerBar `12090–12106`, Border `14563–14666`에 크기·배경·Devil 테두리 설정 | **배치·style 기준 회수.** PitBull 구판 엔진의 현재 작동은 미검증. 기존 계획의 Forever Unit Frames 후보가 이 모양을 구현하는지 먼저 판단한다. 부족할 경우에만 별도 작은 unit frame 설계를 구체화한다. 지금 새 health/mana 엔진 제작 확정 아님 |
| 미니맵 | `!DevilUI/Profile/SexyMap.lua:3–147`: BOTTOM/BOTTOM, x≈352.145/y≈16.385, scale1.26; 버튼·clock·zone·border 설정. 소비 코드 `SexyMap/SexyMap.lua:575–600`은 크기140와 위치·scale 적용 | **현재 SexyMap 설정으로 재구성할 기준 확보.** shape130871, edge137057, background137056은 client File ID이며 동봉 이미지 경로가 아니다. 좌표만 복사해서 동일한 그림이 된다고 보장하지 않는다 |
| 시전바 | `!DevilUI/Profile/Quartz.lua:1–104`의 프로필은 sugar/sugar2/Default이며 **loaf 없음**. sugar2 Player는 BOTTOM/x≈11.111/y≈277.778. `Quartz/Quartz.lua:60–64,76–107`과 modules/Player·Target은 AceDB와 module 설정을 소비. PitBull loaf에도 대상 CastBar 설정 존재(`12512–12538`) | **현재 Quartz 후보는 유지, 정확한 원형은 미확정.** sugar2 값을 loaf의 실제 화면값으로 단정하지 않는다. loaf 이름 전환과 기본값의 관계, PitBull 대상 시전바와의 중복은 이후 화면·게임에서 확인. 시전 엔진 자체 제작은 현재 필요 근거 미발견 |
| 블랙 하단 배경·구획 | `!DevilUI/Profile/kgPanels.lua:23–775`의 global.layouts.loaf에 8패널. `하단이미지`는 width="100%"/height="162"/BOTTOM/black gradient. chat1은 별도 scale1.59. 여러 구획이 Devil2 테두리 사용. 프로필 `1566–1568`은 layout="loaf" | **가장 직접적인 재현 근거.** 단순 검정 영역을 추측해서 만드는 단계가 아니다. 원래 geometry·색·테두리를 작은 장식 코드에 옮기는 설계가 가능하다. 162는 해당 한 패널의 UI 높이이며 전체 테마 높이나 pixel 수가 아니다 |
| 장식·statusbar 그림 | `!DevilUI/media/sharedmedia.lua:6–20`에 angel/demon/Minimap, Devil/Devil2/Devil3/roth, Glamour7 등 등록. 해당 TGA 파일 모두 존재. kgPanels 좌우 패널은 angel/demon을 참조(`211–304,399–492`) | **파일과 참조 연결 확보.** angel/demon 패널은 bg_color.a=0, bg_alpha=1, bg_style=NONE이므로 참조 사실과 실제 렌더 결과를 구분한다. 현재 screenshot의 노출 정도는 미검증. 등록·레이어·비율을 필요한 범위만 새로 연결 |
| 폰트·하단 정보줄 | Fonts.zip에는 TTF7개·slug3개. ChocolateBar loaf의 `fontPath="Fonts\\2002.TTF"`·크기12.5·하단 bar 설정(`!DevilUI/Profile/ChocolateBar.lua:350–371`). Devil 별도 K_Damage 폰트도 존재 | **폰트 파일 확보, 정확한 모든 글꼴 매핑은 미확정.** 동일 이름 K_Damage.TTF가 두 위치에서 크기가 다르므로 임의 통합하지 않는다. 정보줄의 잡다한 broker 기능 전체는 복원 요구에 포함하지 않음 |

8패널의 소비 경로도 확인했다. `kgPanels/kgPanels.lua:442–518,692–733,804–817,839–900,907–996`은 프로필의 layout을 선택하고 패널 생성, mouse 설정, anchor/scale/백분율 크기, 자산·gradient를 적용하도록 작성됐다. 자산 이름은 `fetchArt`(`365–385`)가 LibSharedMedia 등록과 연결한다. 따라서 위 블랙 배경 결론은 애드온 이름만 보고 한 추측이 아니다. 다만 이 구판 코드를 현재 client에서 실행해 검증한 것은 아니다.

배포 프로필 파싱 중 ChocolateBar에서 중복 키 1개를 찾았다. 위치는 **Wide 프로필**(두 번째 정의 종료 3796행)로 loaf 밖이다. 파서는 Lua table의 뒤 대입값을 유지했다. 이를 숨기거나 loaf 설정 손상으로 확대하지 않았다. 상세 key와 행 범위는 `layout-evidence.json`, `profile-extract.json`에 있다.

단축키에 관한 회수 범위도 구분한다. **회수한 것은 버튼 배열·크기와 키 글자의 위치/스킨이며 사용자의 실제 키 할당표는 아니다.** `Dominos/core/bindableButton.lua:35–46,125–136`은 게임의 `GetBindingKey` 결과를 짧은 글자로 표시한다. Dominos의 두 Bindings XML을 구조 파싱한 결과는 명령 정의이고 사용자별 키 목록이 아니다(비어 있지 않은 실행 본문 0개; 기본 ALT 항목은 modified click). 배포 Dominos/Masque 테이블에서 확인한 binding 관련 값도 표시 옵션이다. 실제 과거 사용자 키 배정은 이번 원본에서 근거 미발견이며 새 키를 임의 배정하지 않는다. 개인 키·매크로 보관함은 열거나 변경하지 않았다.

## 구버전을 통째로 적용하면 안 되는 이유

| 핵심 구성 | 원본 표기 버전 | Interface 표기 | 근거 |
|---|---|---|---|
| !DevilUI / Devilconfig / nibProfileLoader | 1.1 / 1.0 / 버전값 없음 | 70100 / 60100 / 50100 | 각 TOC 전체 |
| Dominos / SexyMap / Quartz | 10.0.9 / v10.0.7 / 3.7.1 | 100002 / 100002 / 100002 | 각 TOC 1–8 |
| PitBull4 | v4.2.24 | 100002 | PitBull4_Mainline.toc:1–17; 일반 PitBull4.toc:1–5는 retail-only 경고용 |
| kgPanels / ChocolateBar | 1.4.2 / v3.8.5 | 100000 / 90207 | 각 TOC 1–11 |
| Masque / Masque_Onyx / Reflux | 10.0.2 / 10.0.2 / 9.2.5 | 100002 / 100002 / 90205 | 각 TOC 전체 |

서로 다른 시기의 코드·설정이 한 배포물에 섞여 있다. Interface 숫자는 역사적 선언이며 현재 Forever 지원·불지원 판정 그 자체가 아니다. 최신 후보의 배포 선언과 실제 이 PC 작동은 기존 `shaman-source-evidence.md`에서 구별해 두었다. 이번에는 최신 API 문서를 새로 조사하거나 호환성을 실행 판정하지 않았다.

구체적인 정적 위험은 다음과 같다.

- `!DevilUI/!DevilUI.lua:173–195`는 오류 표시와 애드온 버전 확인을 0으로 바꾸고 UI scale을 강제한다. `60–104`는 채팅 초기화도 포함한다. 새 복원 작업의 최소 범위를 넘는 설정이다.
- 같은 파일 `34,110,120,133`에는 `resilution` 표기와 WIDE2 호출/WIDEHIGH 정의의 불일치가 있다. 정적 불일치이며 현재 실제 실패를 재현했다고 말하지 않는다.
- `!DevilUI/minimap.lua:7–13,20–37`은 미니맵 위치·입력을 직접 제어한다. 별도의 SexyMap 소비 코드도 같은 frame을 제어한다. 새 구성에서는 미니맵 담당을 하나로 정해야 한다. 구판 둘의 최종 적용 순서와 결과는 미검증이다.
- 프로필 목록의 누락 파일 2개와 Quartz loaf 부재가 있다. 구판 설치기로 모든 구획이 자동 완성된다는 가정은 성립하지 않는다. TOC만 새 숫자로 바꾸는 것으로 해결됐다고 보고하지 않는다.

## 직접 만들 부분과 남은 확인

**설계 판단:** 새로 만들 범위의 중심은 ① 원래 panel·border·statusbar 자산 등록 ② 8패널 중 필요한 하단 구획을 그리는 작은 장식부 ③ 현재 애드온의 프로필·anchor를 안전하게 맞추는 제한된 설정 연결이다. 장식은 입력을 받지 않는 원본 설정을 참고한다. Reflux의 모든 애드온 일괄 전환, 채팅 reset, 오류 숨김, 해상도별 강제 초기화를 그대로 복사할 이유는 없다. 기존 애드온이 담당하는 버튼·미니맵·시전 로직과 중복되는 엔진은 만들지 않는 안이다.

체력·마나는 별도 판단이다. 원래 layout·module style은 회수했으나 Forever Unit Frames가 그 style을 어느 정도 지원하는지는 이번 ZIP으로 확인할 수 없다. 후보 설정만으로 부족하다는 실제 근거가 생길 때 작은 custom unit frame의 표시·입력·전투 제한·유지보수 범위를 설계해야 한다. 원래 PitBull의 aura·text script 전체 이식을 기본값으로 삼지 않는다. 주술사 토템은 Dominos loaf에 totem1 설정(`1659–1668`)이 있다는 것까지만 확인했으며 현재 소환·교체·자원 표시 작동으로 세지 않는다.

**권리 확인:** 파일 확보와 재배포 권한은 별개다. Quartz.toc:6은 GPL v2, SexyMap.toc:19와 kgPanels.toc:9는 제한적인 권리 표기를 담고 있다. Devil 자산과 Fonts.zip 전체에 공통으로 적용되는 재배포 허용 문서는 이번 조사에서 근거 미발견이다. 원본 보관·배치 분석은 완료했지만 모든 파일을 새 이름의 공개 통합팩으로 배포해도 된다는 결론은 내리지 않았다. 현재판 프로젝트를 따로 설치하고 작은 자체 연결부를 유지하는 방식이 기술적으로도 관리 범위를 줄인다.

남은 확인은 명확하다. 첫 이미지와 실제 회수 설정의 관계를 Step2에서 정밀 비교하고, 현재 화면의 해상도·UI scale을 확인해야 한다. 이어 승인된 구현 단계에서 현재 후보별 설정 수용 여부, 한글·단축키 글자, 체력/마나·시전의 전투 정확성, 토템 접근, 미니맵 입력, 재접속 후 유지·오류를 검증한다. 시전바 프로필 불일치와 병존 초기화는 특히 확인해야 한다. 이 단계를 거치기 전 재현률·완성도 비율이나 현재 정상 작동을 숫자로 제시하지 않는다.

이번에 하지 않은 작업: 원본/현재 애드온 실행, 게임 폴더 변경, CurseForge 변경, 사용자 매크로·Retail WTF 열람, 정밀 screenshot 측정, 구현·설치·공개 배포. 정적 원본 분석은 그 승인 경계 안에서만 진행했다.

근거 탐색과 검수 입력: `Codex/results/source-analysis/source-map.md`, `read-coverage.md`, `analysis-gates.json`. 독립 문서 검수는 이 작성본을 대상으로 별도로 수행한다.

검수 상태 — 2026-11-17 21:32:48 +09:00: 지정한 10관점·10라운드 독립 검수 완료. 중대0·중간0·경미0이며 원문은 `Codex/results/handoffs/source-analysis/iter_1/audit_log.md`에 보존했다. 정적 분석 보고서에 대한 판정이며 게임 호환성·실제 화면 재현·설치 시험은 포함하지 않는다.

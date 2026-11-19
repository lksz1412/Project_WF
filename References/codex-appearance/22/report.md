# 대안 테마 ink

이 문서는 초기 Ink·Stage 시안의 제작 기록이다. 현재 로컬 후보의 테마는 호드·얼라이언스·데빌이다. [새 도입안과 종족 확장](race-theme-review.md)

검은 금속 기본판과 함께 먹빛 종이 결과 평평한 막대의 `ink` 한 벌을 준비했다. 글꼴은 클라이언트의 본문·이름용 경로를 읽는다. 색 값과 20개 토큰은 공통 외관 `Themes/ink.lua`에 있다. 최신 로컬 시험판은 세 테마 모두 사용자 참고 자료의 `demon.tga`와 `angel.tga`를 양끝에 둔다. 원본에 백색을 곱해 그림 고유색과 알파를 보존한다.

테마를 고르는 기존 명령은 `/dfp theme ink`다. 같은 공통 runtime과 FHD·QHD·UHD preset을 사용한다. 전투 중 실제 변환은 Core와 공통 셸에서 전투 종료까지 기다린다.

Lua 5.1 실행에서 테마 전환·저장된 테마 복원·전투 지연 전환을 통과했다. 게임 갈무리와 실제 글꼴 출력은 접속 후 확인할 항목이다. 자산과 실행 명령·정독 범위는 `../2/assets.md`와 `../2/report.md`에 있다.

native 채팅의 흰 메시지색·채널색을 그대로 둘 때 밝은 종이 면에서는 읽기 어려워, 종이 질감의 tint를 어두운 먹빛으로 바꾸고 공통 글자·경계는 밝게 맞췄다. 실제 native 메시지의 색/내용을 바꾸지 않는다. 셸과 이번 Skin의 callback은 두 테마를 따르지만 PB4/Quartz/Grid2/Details/XP의 native profile 조각은 `Devil Forever devil` 이름을 고정 참조한다. native 프로필의 자동 테마 전환은 아직 연결하지 않았으며 완료로 세지 않는다. `Devil Forever ink` LSM 이름은 별도 등록돼 있어 후속 검증된 프로필 경로가 선택할 수 있다.


## stage 추가 착수 영향 지도

사용자 후속 지시로 두 번째 대안 stage를 준비한다. 색·그림은 Codex 구현 제안이며 사용자 선택·게임 실측값이 아니다. 기존 Devil/Ink는 보존한다.

| 곳 | 필수 연결 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| Themes/stage.lua·stage_*.tga | 같은 값·새 입력 생성 | 기존20 token·Media 매핑 전문/검색 | 함께 작성 | 별도 질감/선/양끝/막대/기본 글꼴 |
| SharedMedia.lua·TOC | 읽는/호출하는 쪽 | 두 파일 전문 및 devil/ink/stage 검색 | 함께 고침 | theme 등록과 stage media 이름 로드 |
| Appearance.lua·Core Theme/Edit/Commands | 호출/피호출 | shell와 공개 계약 전문, Commands 전체 | 확인만 | 기존 Theme callback·사용자 edit 우선·전투 guard·명령을 그대로 사용 |
| Tests/run.py | 잠근 시험 | 전문 | 함께 고침 |3preset×3theme·실제 slash·원복·재시작·LSM |
| stage generator·22 asset preview/대비 표 | 입력 생성·검증 소비 | 신규 제작 | 함께 작성 | 자체 자산 재현·renderer용 값/권리 메모 |
| devil.lua·ink.lua·기존 TGA | 쌍둥이/인접 테마 | 전문 및 before hash | 확인만 | 기존 두 테마 바이트 보존 |
| native profile/theme 경로 | 범위 밖 소비처 | 부모 통합 계약·source 조회 | 확인만 | 자동 재색상은 사용자 custom 보존 공개 경로만 짧게 판단 |
| 기존 기록·게임/WTF/키/메시지 | 기록/원천 | 경계 대조 | 영향 없음 | 덮어쓰기·게임 조작 안 함 |

새 scratch: D:\Projects\Project_WF\_local_only\stage-theme-zgqz7rkr. 이전 parent 복구본 before-offline-design-491ea21b도 읽기/복구 지점으로 남긴다.

## Stage · 네온 무대

보라색 직조 패널과 청색 테두리, 상단이 밝은 막대에 무대 모니터와 믹서 그림을 넣었다. `Themes/stage.lua`가 20개 값의 원본이고 `stage-tokens.json`은 사본이다. 백자와 먹빛 테마는 종이 질감, 황갈색 경계, 평평한 막대, 백자와 벼루 그림을 쓴다. [세 테마 비교](../24/ux/themes-comparison.png)

기존 `/dfp theme stage`로 전환, `/dfp theme devil` 또는 `ink`로 복귀. 전투 중 slash는 기존 Commands에서 거절한다. Theme 직접 API queue는 기존 경로 그대로다. 글꼴은 게임 기본 경로를 참조하고 별도 글꼴 바이트를 배포하지 않는다. 본문 STANDARD_TEXT_FONT, 제목/숫자 UNIT_NAME_FONT. 값 층위는 기존 사용자 Edit가 최상위다.

| 토큰 | 값 |
|---|---|
| `texture.statusbar` | `"Interface\\AddOns\\DevilForever_Appearance\\Media\\stage_bar.tga"` |
| `color.text.normal` | `[0.94, 0.96, 0.99, 1]` |
| `font.size.header` | `32` |
| `font.number` | `"UNIT_NAME_FONT"` |
| `font.size.small` | `22` |
| `font.size.normal` | `28` |
| `texture.ornament.left` | `"Interface\\AddOns\\DevilForever_Appearance\\Themes\\stage\\monitor.tga"` |
| `color.panel.background` | `[0.22, 0.12, 0.36, 1]` |
| `font.header` | `"UNIT_NAME_FONT"` |
| `color.accent` | `[0.2, 0.75, 0.83, 1]` |
| `texture.divider` | `"Interface\\AddOns\\DevilForever_Appearance\\Media\\stage_divider.tga"` |
| `color.text.highlight` | `[0.86, 0.96, 1, 1]` |
| `color.panel.border` | `[0.39, 0.59, 0.96, 1]` |
| `texture.ornament.right` | `"Interface\\AddOns\\DevilForever_Appearance\\Themes\\stage\\mixer.tga"` |
| `color.text.disabled` | `[0.7, 0.73, 0.78, 1]` |
| `color.divider` | `[0.61, 0.33, 0.78, 1]` |
| `font.normal` | `"STANDARD_TEXT_FONT"` |
| `spacing.default` | `8` |
| `border.size` | `2` |
| `texture.panel` | `"Interface\\AddOns\\DevilForever_Appearance\\Media\\stage_panel.tga"` |

`stage-asset-preview.png`와 `stage-index.json`은 최초 Stage를 만들 때 기록한 자료다. 최신 슬롯의 그림·색은 비교 목업에서 확인한다. 실제 게임의 글꼴, 캐릭터 배경과 채널별 글자 대비는 접속 때 확인한다.

대비 계산은 실제 panel RGBA와 Stage 색을 흰 배경 위에 합성한 가장 밝은 픽셀 기준이다. 기본 12.679:1, 강조 12.255:1, 비활성 7.130:1, 테두리 4.797:1이다. 한국어 글꼴 렌더와 기존 채널색은 실제 접속에서 확인한다. [대비 계산값](stage-contrast.json)

## 실행 판정

- `python References/codex-appearance/22/tools/generate_stage_assets.py` → rc0, PASS 자산5·본문 최소7.111:1·경계6.305:1. Pillow getdata deprecation 경고1(실패 없음).
- `python References/codex-appearance/2/AddOns/DevilForever_Appearance/Tests/run.py` → rc0, PASS Lua5.1 3preset×3theme·20token·실제 Commands `/dfp theme` 목록/전환/원복·ink/stage 저장 복원·17개 셸·사용자 color/font 편집 보존·전투 slash 거절/기존 API queue·.35/.64 배율·중복 프레임0·실제 upstream LSM 등록. raw: `_local_only/stage-theme-zgqz7rkr/runtime.txt`.
- `stage integrity` Python 실행 → rc0, PASS RGBA/power-of-two5·Lua compile2·기존 Devil/Ink+Media SHA256 11개 일치. raw: `_local_only/stage-theme-zgqz7rkr/integrity.txt`.

테스트는 실제 Core/Theme/Edit/Presets/API/Commands 소스를 WoW Frame 대역에서 실행했다. nativeSentinel은 테스트 데이터 보존 점검일 뿐 실제 사용자 설정을 읽거나 게임에서 확인한 결과가 아니다. 실제 설치 후보 전체 lint/tocdeps/ZIP·native chat/상태/맵 통합 검증은 master 담당. 이 패스에서 실행했다고 주장하지 않는다.

## native 재색상 연결의 한계

소스에서 확인한 Quartz `ApplySettings()`는 현재 native db.profile를 다시 읽고 모듈 활성 상태까지 적용한다. 재색상 전용 호출로 쓰지 않는다. Grid2 `ReloadTheme(force)`는 자체 역할/직업/그룹 theme를 선택하고 secure 경로를 거친다. 공통 stage를 여기에 강제 대응시키지 않는다. PB4 CustomTextModule의 문서화된 `GetFont(frame)`는 해당 layout DB의 폰트/크기를 읽어 frame:GetFont로 보낸다. 사용자 값과 테마 소유 값을 구분하는 변경 계약으로 보지 않는다.

공통 LSM의 Register는 기존 이름을 덮지 않으며 SetGlobal은 전체 mediatype override다. 따라서 이번에는 stage 이름 3종을 추가 등록하는 데 그쳤다. 현재 profile의 `Devil Forever devil` 선택을 자동으로 바꾸지 않는다. Details에서 이번 읽은 window_api.lua는 API 설명 창이며 skin 보존 API의 근거가 아니다. Details skin/XP 전체 적용 엔진은 이 패스에서 정독·실행하지 않아 custom 보존 공개 bridge 존재 여부를 미확인으로 남긴다. XP의 이전 조각은 fontName/질감 선언에 한정됐고 geometry/slots를 건드리지 않았다는 기존 보고서를 그대로 따른다. 5종 모두 임의 hook·native DB rewrite·LSM global override를 추가하지 않았다.

## 반환

수정 파일·해시는 `stage-index.json`, 세부 읽기/명령/판정은 `work_log.md`. 독립 B가 이 A의 stage 구현·등록·시험과 영향 지도를 직렬 검수한다. 실제 게임·CVar·키·메시지·다른 애드온 저장 설정 쓰기는 없음.

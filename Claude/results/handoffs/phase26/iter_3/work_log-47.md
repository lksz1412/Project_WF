# Step 47 work_log — A2 coder (작업 A)

기준: 작업 트리 /home/user/Project_WF, 가지 ccr-ba95560e-h298t2 @27a75e16(9c46a837 위 brief 커밋). 커밋 안 함(master 몫).
발주문: `Claude/results/handoffs/phase26/iter_3/brief-47.md` 전문 1-41.

## 바뀐 파일

| 파일 | 무엇 |
|---|---|
| `Collection/AddOns/!DevilForever_Core/Party.lua` | 전면 재설계(아래 「설계 판단」) — 로그인 대조·FUF 지연 단계·자동 알림 전부 삭제, `/dfp party on|off` 만 씀 |
| `Collection/AddOns/!DevilForever_Core/Commands.lua` | `/dfp party [on|off]` (옛 낱말 `unitframes`=on · `grid2`=off 별칭), 도움말·머리 주석 |
| `Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua` | 파티 그룹 3개에 show_when(파티+공격대, 솔로 아님 — 그룹마다 새 표), 소환수 그룹 `use_pet_header=true`, 주석 |
| `Collection/AddOns/!DevilForever_Core/Defaults/Grid2.lua` | 새 프로필 Grid2Layout: party/arena "By Group", FrameDisplay "Grouped", `minimapIcon={hide=true}`(m13) · MakeDatabaseDefaults 감싸기에서 템플릿 Modern(없으면 Classic) 미리 고름(m12, 창 안 뜸) · 주석 |
| `Collection/AddOns/!DevilForever_Core/Defaults/Quartz.lua` | Quartz3DB Swing 이름공간 새 대상 `dfStandStill = 0.5` |
| `Collection/AddOns/!DevilForever_Core/Presets.lua` | 조각 키 `replace`(목록 키는 병합 대신 통째 교체 — M1) · alignPixel 서명 칸을 kind별 표 `SIGNATURE_FIELDS`(groups 11칸 — m3) · layoutOnly 비교 배치 이름과 화면 해상도 계열이 다르면 주의 한 줄(m2) |
| `Collection/AddOns/!DevilForever_Core/Presets/V2.lua` | V1·V2 PitBull4 루트 조각에 `replace={"dfAuraGeometry"}`(M1) · Quartz Pet 막대도 복사, V2 에서 소환수 프레임 아래로(m1, dfGeometry 는 안 붙임 — 런타임 재배율 대상 아님) · Swing 조각에서 `dfFollowPlayer` 제거(쓰는 곳이 없어짐) |
| `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` | 파티 그룹 4개 show_when raid*=true · "파티원 소환수" = 완전한 그룹(partypet, dfPartyRole "partypet", use_pet_header, layout 대상의대상, 파티원 대상 열 오른쪽: fhd x=368 / qhd 476 / uhd 668, y·크기·간격은 파티원 대상과 같음) · v3 addedGroups 목록에 소환수 추가 |
| `Collection/AddOns/Quartz/modules/SwingForever.lua` (→ `patches/Quartz.patch` regenerate) | 사냥꾼만 PLAYER_SWING 등록 · 원거리(Ranged)만 · Enum 없거나 키 없으면 2 · 멈춤 구간 텍스처(마지막 dfStandStill 초, 0/nil = 없음, 주기보다 길면 막대 전체) · 늦은 사격: 0 지나면 다음 사격까지 가득 찬 채 유지, 한 주기 넘게 밀리면 숨김 · Unlock/Lock 미리보기 · Player.Bar ApplySettings 훅을 조건 없이(m3 배율 어긋남) · 옵션 「멈춤 구간(초)」 |
| `Collection/AddOns/PitBull4/UnitFrameLayout.lua` (→ `patches/PitBull4.patch`) | dfOutside 인데 dfOffset·dfHeight 가 숫자가 아니면 바깥 배치 안 함(m4) |
| `Collection/AddOns/DevilForever_Skin_Dominos/Skin.lua` | 전투 중 Layout 으로 미뤄진 꼬리 배치를 전투 뒤 apply 에서 다시(m6, `tailPending`) |
| `Collection/AddOns/Grid2/GridBlizFramesHide.lua`, `GridFrame.lua` (→ 새 `patches/Grid2.patch`) | m11 훅 존재 확인(UpdateUnitEvents·RaidFrameManager_UpdateShown 둘 다) · m9 UNIT_FACTION 은 유닛을 모아 공용 함수 하나로 다음 프레임에 |
| `Collection/tools/extract.py` | PATCHED 에 `"Grid2": ["Grid2"]` |
| `Collection/manifest.json`, `manifest.md` | `extract.py --no-extract` 재생성: Grid2 patched + (내가 만든 차이 아님) Core lua_files 20→21·Skin_StatusStrip 1→2 — Codex 병합 때 manifest 를 다시 만들지 않아 낡아 있던 값 |
| `Collection/patches/Grid2.patch` (새), `PitBull4.patch`, `Quartz.patch` | `patches.py regenerate`(Grid2 머리글은 다른 패치 꼴로 손으로 씀) |
| `Collection/Installer/ReleaseCatalog.json` | `catalog.py --write` |
| `Collection/tests/firststart/run.py` | 파티 절 전면 교체(7 case) + 소환수 그룹 preset case + Grid2 템플릿 미리 고름 case · 옛 `pitbull4_managed_party_roles…` case 삭제(옛 설계 검사) |
| `Collection/tests/core/run.py` | Grid2 새 프로필 기대값(GRID2_LAYOUT) |
| `Collection/tests/layoutv2/run.py`, `quartz.lua` | Swing 검사 교체(사냥꾼만·멈춤 구간·늦은 사격·미리보기·Enum 대체·배율 따라감) · V2 오라 규칙 키·Pet 막대 검사 · 스텁 RegisterEvent 기록 |
| `Collection/tests/patches/run.py` | 패치 개수를 manifest 선언 수에서 셈 + patches/ 의 *.patch 가 모두 선언됐는지 |

## 설계 판단 (내 판단)

**파티 담당 재설계**
- 「담당 하나」 기록을 버림. Grid2 는 늘 파티·공격대를 그리고(새 프로필 Defaults), 유닛 프레임 파티는 그 위의 켜기/끄기 스위치(기본 켬).
- 하위 그룹 켜짐은 처음 설치(Defaults·preset 값 enabled=true)와 `/dfp party on|off` 때만 씀. 로그인 때 Party.lua 는 아무것도 비교·기록하지 않음(이벤트 핸들러 없음). 옛 기록 `DevilForever_CoreDB.party.owner` 는 지우지 않고 읽지도 않음(저장 키 보존).
- `/dfp party on|off` 뜻: 전투 밖, 유닛 프레임 애드온이 정확히 하나일 때 — PitBull4 는 파티 그룹(unit_group party/partytarget/partytargettarget/partypet) 전부 enabled=on, 단 dfPartyRole="hidden"(이전 판 소환수) 은 꺼진 채; FUF 는 FUF 명령(on: `set party enabled on` / off: `hideBlizzardFrame on`+`enabled off`) 뒤 1초 읽어 보기 한 줄; Grid2 가 켜져 있으면 이 캐릭터 Grid2 를 파티 보이게(None→By Group, Raid/Never→Grouped, 그 밖은 둠). 이 프로필을 쓰는 모든 캐릭터에 적용, 화면은 /reload 뒤.
- 알림 개수(A4): 실제 바꾼 그룹 수만 (「파티 그룹 N개 끔」, 바꾼 것 없으면 「이미 모두 꺼짐/켜짐」).
- 옛 낱말 `unitframes`/`grid2` 는 on/off 별칭으로 남김(설치안내에 적힌 명령이 계속 동작하게).
- FUF 판: 같은 스위치. 첫 설치는 FUF 기본(파티 켬) 그대로라 지연 단계가 없어짐.
- 소환수 그룹: 발주문대로 `use_pet_header=true`(SecureGroupPetHeaderTemplate, 있는 소환수만). 이 헤더는 소환수를 빈칸 없이 채워 쌓으므로 소환수가 없는 파티원이 끼면 그 아래 소환수가 한 칸 위로 올라가 주인 줄과 어긋날 수 있음 → 결정 대기 1.
- `/dfp preset fhd` 같은 명시 preset 복원은 preset 값대로 파티 그룹을 다시 켬(명시 명령의 한 갈래로 봄). V1/V2 비교 배치는 groups 를 쓰지 않음.

**M1**: V2.lua 에서 키를 하나씩 덮는 대신 조각 키 `replace` 를 Presets 에 두어 dfAuraGeometry 를 통째 교체 — V1 에 앞으로 키가 늘어도 V2 가 물려받지 않음. 기존 test 로 V1 복귀 때 size_ratio·avoid_frame 이 돌아오는 것도 확인.

**Quartz**: 늦은 사격 처리에서 「다음 PLAYER_SWING 까지 가득 찬 채」에 상한을 둠 — 한 주기 넘게 밀리면(자동 사격이 멈춘 것으로 봄) 숨김. 끝없이 가득 찬 막대가 남지 않게 하려는 내 판단. dfFollowPlayer 는 훅 조건에서 빠져 쓰는 곳이 없어져 V2 조각·시험에서 지움(이미 저장된 값은 무해하게 남음). 옵션 이름은 L[] 대신 한글 글자 그대로(AceLocale 의 없는 키는 오류 처리기를 부름).

**Grid2 템플릿(m12)**: 원본도 같은 자리에서 Grid2Options 를 불러오므로 그 불러오기를 앞당겨 Modern(없으면 Classic) 색인을 넣음. 둘 다 없으면 원래대로 창.

## 영향 지도

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| Party.lua 전체 | 고친 곳 | 전문 1-522 정독 | 함께 고침 | 재설계 |
| Commands.lua 6-8, 43, 242-250 | 부르는 쪽 | grep `Party` 전 AddOns | 함께 고침 | 명령 낱말·도움말 |
| Party:GetState/Describe/Set 다른 호출 | 부르는 쪽 | grep `Party:`·`.Party` | 영향 없음 | Commands 와 시험 외 없음 |
| Defaults/PitBull4.lua 40-60(옛 주석·groups) | 같은 값 | 발주문 + 전문 1-120 | 함께 고침 | 공격대 show_when·소환수 헤더 |
| Defaults/PitBull4.lua 552 groupLayouts · 583 | 같은 값 | grep dfPartyRole | 확인만 | 소환수 layout 대상의대상 그대로 맞음 |
| Defaults/Grid2.lua 40-55 | 같은 값(Party 가 쓰던 Grid2 값) | 전문 정독 | 함께 고침 | Grid2 늘 파티·공격대 |
| Presets fhd/qhd/uhd 469-472, 619 | preset 셋 | grep 같은 줄 3파일 | 함께 고침 | A1·A3 |
| Presets/V2.lua 63 (groups=nil) | 같은 값 | 전문 정독 | 확인만 | 비교 배치는 groups 안 씀 |
| Presets.lua writeFragment 464-485 | 불려 가는 쪽 | 전문 1-646 | 함께 고침 | M1 replace · m3 서명 |
| Presets.lua Restore 267-271 | 고친 곳 | 전문 | 함께 고침 | m2 |
| Core.lua WriteOver 266-285 | 불려 가는 쪽 | 읽음 | 영향 없음 | 계약 그대로, replace 는 Presets 쪽 |
| PitBull4 Aura/Layout.lua 400-480 | 소비하는 쪽 | 읽음 | 확인만 | rule 키 소비 확인 |
| PitBull4 GroupHeader.lua 40-110, 555-720, Main.lua 205-260, Utils.lua 481 | 소비하는 쪽 | 읽음 | 확인만 | show_when·use_pet_header 처리 |
| Grid2 GridDefaults.lua 60-110, Grid2Options GridProfiles.lua 100-150, profiles/*.lua 등록부 | 불려 가는 쪽 | 읽음 | 확인만 | 템플릿 색인·이름 |
| Grid2LDB.lua 37-41, GridUtils.lua 398-411, GridLayout.lua 150-200 | 소비하는 쪽 | grep minimapIcon | 확인만 | Grid2Layout 프로필 minimapIcon |
| Grid2 GridBlizFramesHide.lua 55-100, GridFrame.lua 40-50·296-330 | 고친 곳 | 읽음 | 함께 고침 | m11·m9 |
| SwingForever.lua 1-355 | 고친 곳 | 전문 | 함께 고침 | C 전체 |
| Defaults/Quartz.lua 1-73 | 같은 값·배율 | 전문 | 함께 고침(새 대상) / 확인만(applyScale) | dfStandStill · Player 재배율이 훅으로 Swing 에 닿음 |
| V2.lua 42-43·142 dfFollowPlayer | 같은 값 | grep | 함께 고침 | 쓰는 곳 없어짐 |
| Hekili Rows.lua 175-192 | 같은 값(0/1/2) | 읽기만 | 확인만 | Hekili 안 건드림 |
| UnitFrameLayout.lua 432-452 | 고친 곳 | 읽음 | 함께 고침 | m4 |
| Skin_Dominos Skin.lua 1-172 | 고친 곳 | 전문 | 함께 고침 | m6 |
| tools/extract.py PATCHED·manifest | 생성 경로 | 읽음 | 함께 고침 | 새 Grid2 패치 |
| tests/patches 개수 | 시험 | 실행 | 함께 고침 | 발주문 E |
| tests firststart·core·layoutv2 | 시험 | 실행 | 함께 고침 | 새 동작 |
| DevilForever_FUFDefaults/FUFDefaults.lua 5-7 주석 | 같은 개념 | grep party | 확인만 | 「파티는 Party.lua」 여전히 맞음 |
| `Collection/install/설치안내.md` 57-58·66, `Collection/data/feature-map.md` 58·72 | 사용자 문서(ZIP 동봉) | grep `dfp party` | 확인만 → 결정 대기 2 | 발주문에 없는 파일이라 안 고침. 지금 문장은 옛 설계·Grid2 고르기 창 설명 |
| Review/0.1.4/… 설치안내 | 기록 | grep | 영향 없음(기록) | 지난 판 기록 |

## 실행한 명령과 판정 줄

(작업 트리 `Collection/` 에서. 원 출력은 스크래치 `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/` 아래 — 판정은 아래 줄)

- `python3 -I tests/castbars/run.py` → cases=16 passed=16 failed=0
- `python3 -I tests/catalog/run.py` → cases=4 passed=4 failed=0 skipped=0
- `python3 -I tests/chatsetup/run.py` → cases=32 passed=32
- `python3 -I tests/composition/run.py` → cases=8 passed=8
- `python3 -I tests/core/run.py` → cases=109 passed=109
- `python3 -I tests/firststart/run.py` → cases=24 passed=24
- `python3 -I tests/fufdefaults/run.py` → cases=22 passed=22
- `python3 -I tests/layoutv2/run.py` → rc=0, PASS 줄 15
- `python3 -I tests/patches/run.py` → cases=4 passed=4 (작업 전 3/4)
- `python3 -I tests/pitbull4/run.py` → 6/6 · `pitbull4runtime` → 20/20 · `statusstrip` → 20/20 · `thirdparty` → 8/8
- `python3 -I tests/detailslayout/run.py` → FileNotFoundError `References/codex-appearance/10/details-instances.fragment.fhd.lua` (작업 전과 같음 — 아래 「남긴 항목」)
- `python3 tests/performance/run.py --dominos-zip ../outputs/collection/DevilForever-0.1.5.zip` → AssertionError `before["appearance"] == (40 if edited else 39)` (run.py:189). HEAD 원본(`git archive HEAD` 사본 + upstream 복사, 스크래치 tmp.sjEsRZjtmN)으로 빌드해 돌려도 같은 줄에서 실패 → 이번 변경 전부터의 실패
- `tests/installer/run.py` → 못 돌림: `--exe`(Windows 설치기 실행 파일) 필요, 이 컨테이너에 없음
- `python3 -I tools/patches.py verify` → verify patches=7 unmodified=20 failures=0
- `python3 -I tools/genregistry.py --check` → up to date (58497 bytes), rc=0
- `python3 -I tools/build.py --install` ×2 → 둘 다 sha256=49ce6677cc6e9ab24a8b0054add10a4e2ba1557d07b9494209dd6f4811df2c3f (files=2214)
- `python3 -I tools/build.py --install --variant fuf` ×2 → 둘 다 sha256=640faa198b516b2c63e90b4ff9151ab06bce6a26e1dc0aa8ed7d76b4ee9e55a9 (files=2158) (스크래치 out-dir 두 번도 같은 해시)
- `python3 -I tools/catalog.py <두 ZIP> --write` → wrote 2 packages · `--check` → matches (pitbull4 49ce6677cc6e, fuf 640faa198b51), rc=0
- `python3 -I tools/luacheck.py <바뀐 Lua 15개>` → checked=15 failed=0
- 탐침(스크래치 `s47/probe_tail.py`): Skin_Dominos 전투 중 Layout 뒤 PLAYER_REGEN_ENABLED → 지금 판 OK, HEAD 판 `after combat 12`(다시 안 함) — m6 수정 전후 실측
- M1 시험이 옛 동작을 잡는지: V2.lua 의 `f.replace` 를 잠시 빼고 layoutv2 실행 → `AssertionError: ('플레이어', {'size_ratio': 0.7, …})`, 되돌림 확인(grep 1)

## 판단 근거로 읽은 파일·줄 범위

- brief-47.md 1-41 · audit_log-48-1.md 1-127 · -48-2.md 1-181 · -48-3.md 1-126 (전문)
- Core: Party.lua 1-522, Commands.lua 1-262, Presets.lua 1-646, Presets/V2.lua 1-147, Presets/fhd.lua 1-60·440-750(qhd·uhd 는 469-472·619 grep), Defaults/PitBull4.lua 1-120·539-600, Defaults/Grid2.lua 1-123, Defaults/Quartz.lua 1-73, Defaults.lua 1-140, Core.lua 260-300
- PitBull4: GroupHeader.lua 40-110·555-720, Main.lua 205-260, Options/Units.lua 1055-1085, Modules/Aura/Layout.lua 400-480, UnitFrameLayout.lua 432-452, Utils.lua 470-490
- Grid2: GridDefaults.lua 60-110, GridDefaultsRetail.lua 25-50, GridBlizFramesHide.lua 50-100, GridFrame.lua 40-50·296-330, GridLayout.lua 150-200, GridUtilsCmd.lua 1-15·145-170(grep), Grid2LDB.lua 25-60, Grid2Options/GridProfiles.lua 100-150, profiles/ProfileModern.lua 1-20·80-95, ProfileClassic.lua 70-85, Grid2.toc 1-20, Grid2Options.toc 1-10·33-35
- Quartz: SwingForever.lua 1-355, Latency.lua 70-100(grep), Hekili Rows.lua 175-192, Hekili Sources/Swing.lua 1-20
- Skin_Dominos Skin.lua 1-172 · DetailsLayout Layout.lua 1-120 · References/codex-appearance/10/report.md 전문
- 도구·시험: patches.py 1-140, extract.py 100-180·426-470, catalog.py 1-40, build.py(grep), luacheck.py 1-25, tests/firststart/run.py 1-120·360-900·940-975, tests/core/run.py 1100-1140·1359-1380, tests/layoutv2/run.py 1-215, quartz.lua 1-127, tests/patches/run.py 85-125, tests/detailslayout/run.py 1-150, tests/catalog/run.py 110-140, tests/performance/run.py 1-40
- install.json 전문, install/설치안내.md 55-70, data/feature-map.md 56-75(grep)

## 결정 대기

1. 소환수 그룹 헤더: 발주문대로 `use_pet_header=true`(있는 소환수만, 빈칸 없이 채움). 주인 줄과 1:1 로 맞추려면 `use_pet_header` 없이(PitBull4 기본 「Gaps for missing pets」 — 없는 소환수 자리는 비움) 가 맞음. 어느 쪽인지.
2. 사용자 문서 `Collection/install/설치안내.md` 57-58·66, `Collection/data/feature-map.md` 58·72 가 옛 설계(새 설치 = Grid2 만, 유닛 프레임 파티 꺼짐, `/dfp party grid2|unitframes`, 접속 때 되돌림, Grid2 고르기 창)를 적고 있음 — 발주문에 없는 파일이라 안 고침. 새 문장(Grid2 는 늘 파티·공격대, `/dfp party on|off`, 접속 때 안 되돌림, Grid2 템플릿은 Modern 자동) 을 누가 쓸지.
3. 배치 겹침 확인 필요(코드로 계산한 추론): fhd 에서 Grid2 창은 TOPLEFT (24, -164)·물리 px, PitBull4 파티는 (26, -46)~약 -358 세로 4칸. 둘이 동시에 보이면 왼쪽 위에서 겹칠 수 있음. Grid2 위치는 preset Grid2Layout PosX/PosY(외관 몫)라 안 바꿈.
4. 이전 판에서 올린 설치: 로그인 때 아무것도 안 하므로 옛 기록 unitframes 였던 캐릭터는 Grid2 파티가 꺼진 채, grid2 였던 프로필은 PitBull4 파티가 꺼진 채 남음. `/dfp party on` 한 번이면 둘 다 보임. 한 번만 맞추는 이전 처리가 필요하면 지시 바람.
5. 기존 Quartz 프로필에는 `dfStandStill` 이 없어 멈춤 구간이 안 보임(Defaults 는 새 프로필에만 씀). Quartz Swing 옵션에서 넣거나 새 프로필. Codex 확인 메모에 「멈춤 구간 기본 0.5초는 게임에서 Codex 가 실측해 정함」을 적어야 함(코드 주석엔 안 씀) — master 몫.
6. 명시 `/dfp preset <fhd|qhd|uhd>` + go 는 preset 값대로 파티 그룹을 다시 켬(`/dfp party off` 뒤라도). 그대로 둘지.

## 남긴 항목과 이유

- m7(Grid2Roster 비밀값 GUID 갱신), m8(AuraSlot 재사용 안 함), m10(StatusRange 원시값) — 발주문이 「추정이니 남김」으로 정함.
- detailslayout 시험: 기대값을 `References/codex-appearance/10/details-instances.fragment.{fhd,qhd,uhd}.lua` 에서 읽는데 이 파일들은 저장소에 커밋된 적이 없음(그 시험을 넣은 477eb062 는 같은 폴더의 report.md 만 커밋, `git log --all` 로 해당 경로 이력 없음). 경로 오타가 아니라 Codex 환경에만 있던 파일 → 발주문대로 고치지 않음. 고치려면 기대값을 시험 안에 넣거나 그 파일을 커밋해야 함.
- performance 시험: 이번 변경 전(HEAD)부터 run.py:189 에서 실패 — 범위 밖이라 안 고침.
- Hekili·ThemeSwitcher 손대지 않음. 판 0.1.5 그대로.

## 이어받을 상태

- 검수 보고가 오면 이 세션이 위 파일을 직접 열어 고침. 스크래치: `s47/rep.py`(CRLF 보존 치환기), `s47/probe_tail.py`, 빌드 사본 `tmp.xbbmX6IaOu`·`tmp.sjEsRZjtmN`(HEAD 기준선).
- `outputs/collection/DevilForever-0.1.5*.zip` 은 이번 소스로 다시 빌드됨(.gitignore 대상).

## 고침 1 (검수 1 · audit_log-47-1.md · TRIAGE 「Step 47 review 1」)

읽은 것: `iter_3/audit_log-47-1.md` 전문, `TRIAGE_phase26.md` 44-55, 검수 B probe `scratchpad/probes/p4.py` 전문, Grid2 GridLayout.lua 110-135·195-205·460-500·655-700·800-840·995-1035(배치 계산), Presets fhd/qhd/uhd Grid2Layout·Hekili 줄(grep), Defaults/PitBull4.lua 539-625, Presets.lua 495-560(판 비교), `install/설치안내.md` 전 줄 grep(Grid2·파티·party·공격대·PitBull·Quartz), `data/feature-map.md` 같은 grep.

### 바꾼 파일 (고침 1)

| 파일 | 무엇 |
|---|---|
| `Presets/{fhd,qhd,uhd}.lua` | Grid2Layout `anchor="TOP"`, `PosX=0`, `PosY` = -140/-164/-212 ×factor(화면 위 가운데, Hekili 줄 바로 아래) · 소환수 그룹 `use_pet_header` 뺌 · 파티 그룹 조각을 version 3 → 5 로 올려 조각 목록 맨 끝(v4 뒤)으로 옮김 |
| `Defaults/PitBull4.lua` | 소환수 그룹 `use_pet_header` 뺌(빈칸 모드) |
| `Party.lua` | `/dfp party on|off` 가 PitBull4 파티 그룹마다 enabled + show_when(파티·공격대, 솔로 아님)을 새 설계로 · 「파티원 소환수」 dfPartyRole hidden → unit_group/dfPartyRole "partypet", 없는 배치 값만 활성 preset 의 소환수 그룹에서(profile dfPixel 비율로), dfGeometry.groups 서명 추가 · 저장된 값(위치·크기 등)은 그대로 · 알림: 바꾼 그룹 수 + 「그중 N개는 공격대에서도」 + 소환수 바꿈 한 줄 · 접속 때 자동 실행 없음 그대로 |
| `Presets.lua` | 명시 preset 복원 출력에 「PitBull4 파티 그룹도 켬(끄려면 그 뒤 /dfp party off)」(켜진 파티 그룹을 쓰는 조각이 있을 때) |
| `Quartz/modules/SwingForever.lua` (→ Quartz.patch) | 모듈 `defaults.profile.dfStandStill = 0.5`(Core 기본과 같은 값) · 머리 주석 |
| `install/설치안내.md` | :11 0.1.5 바뀐 점에 파티 동시 운용·Quartz 사냥꾼 스윙 · :57 Grid2 고르기 창 안 뜸(Modern 자동)·유닛 프레임 파티 함께 켜짐·미니맵 단추 숨김·이전 판은 `/dfp party on` 한 번 · :58 FUF 파티 꺼짐 문장 고침 · :66 새 설계(on/off·별칭·업그레이드 맞춤·접속 때 안 되돌림·preset 복원 때 다시 켜짐) |
| `data/feature-map.md` | :58 파티와 공격대 = Grid2 + 유닛 프레임 파티 동시, `/dfp party on|off`, Grid2 Modern 자동 · :72 `/dfp party on|off` |
| `tests/layoutv2/run.py` | 기본 preset 화면 지도 시험(아래 표의 사각형 계산, Grid2 공격대 40명·파티 창이 어느 사각형과도 안 겹침, 4 화면) · dfStandStill 두 기본값 같음 |
| `tests/firststart/run.py` | 0.1.5 꼴 저장값 `/dfp party on` 시험(B probe p4 꼴 + 사용자 위치 보존·서명·두 번째 실행·off·다음 접속·preset 복원 줄) · preset 없는 소환수 변환 시험 · use_pet_header 없음 · receipt 5 |
| `Installer/ReleaseCatalog.json` | 다시 씀 |

### 영향 지도 (고침 1)

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| Presets 셋 Grid2Layout 값 | 같은 값 3파일 | grep | 함께 고침 | 중간 1 |
| Defaults/Grid2.lua reapplyAfterTemplate | 소비 | 읽음 | 확인만 | Grid2Layout 조각 값을 그대로 다시 씀 — 새 anchor 포함 |
| Grid2 GridLayout.lua GetFramePosition·PlaceHeaders | 소비 | 읽음 | 확인만 | anchor TOP + groupAnchor TOPLEFT → 창 가운데 정렬, 열은 왼쪽부터 |
| Party.lua setPB4·pb4Count·Describe | 고친 곳 | 전문 | 함께 고침 | 중간 2 |
| Defaults/PitBull4.lua applyScale(서명 형식) | 소비 | 539-625 읽음 | 확인만 | 소환수 서명을 같은 11칸·tostring·"|" 꼴로 |
| Presets.lua recordedVersion·dueFragments(판 비교) | 판 비교 | 495-560 | 확인만 | 같은 키 receipt 는 마지막에 쓴 조각 판 → v5 를 맨 끝에 둬 새 설치 receipt=5, 다음 접속 모두 「already」. 이전 설치(receipt 4)는 v5 가 「kept」 한 번 알림(`/dfp preset` 안내) |
| V2.lua 조각 복사 | 소비 | 읽음 | 확인만 | groups 조각은 V1/V2 에 복사 안 됨 |
| firststart receipt 4 기대 | 시험 | grep | 함께 고침 | 5 |
| SwingForever defaults ↔ Defaults/Quartz.lua | 같은 값 | grep | 함께 고침(시험으로 묶음) | 경미 2 |
| 설치안내·feature-map | 사용자 문서 | 전 줄 grep | 함께 고침 | 경미 4 |
| Review/0.1.4 문서 | 기록 | grep | 영향 없음(기록) | |

### 중간 1 좌표 계산

계산 근거: 물리 px, 왼쪽 위 원점. PitBull4 단위·그룹 = 저장된 profile(새 설치 + 기본 preset) 값 ÷ dfPixel, 크기 = 레이아웃 크기 × 단위 배율. 그룹은 4칸(party1-4) + 칸 사이 vertical_spacing. 오라 = 레이아웃 Aura 값으로 잡은 덮개(모든 약화 효과가 내 것, my_size 기준 최악), 렌더러 실측 아님. Quartz = 막대 + 왼쪽 아이콘(h + icongap). Hekili = CENTER 오프셋 + primaryWidth 정사각형. appearance/statusstrip 편집값 = AppearanceRoot TOPLEFT 기준. Details = Layout.lua 표. Grid2 공격대 40명 최대 = 8열×5칸, 폭 8×frameWidth+7×Padding, 높이 5×frameHeight+4×Padding (vertical, groupAnchor TOPLEFT, Spacing 0). Grid2 파티 = 1열×5칸. 기계 확인 = `tests/layoutv2/run.py` 끝 블록(fhd·qhd·uhd·uhd 3862), 결과 줄:
- fhd 1920: Grid2 (562, 140, 796, 176) — 49개 사각형과 겹침 0, 아래로 가장 가까운 것까지 141 px
- qhd 2560: (786, 164, 988, 236) — 겹침 0, 268 px
- uhd 3840: (1283, 212, 1274, 304) — 겹침 0, 564 px
- uhd 3862: (1294, 212, 1274, 304) — 겹침 0, 564 px
위로는 Hekili 줄(fhd y 64-120 · qhd 80-144 · uhd 112-192)과 20 px 띄움.


#### fhd 1920x1080

| 프레임 | x | y | 폭 | 높이 | Grid2 공격대 40 과 겹침 |
|---|---|---|---|---|---|
| **Grid2 공격대 40명 최대** | 562 | 140 | 796 | 176 | — |
| **Grid2 파티(5칸)** | 912 | 140 | 96 | 176 | — |
| auras 대상 | 1225 | 457 | 256 | 174 | 없음 |
| auras 주시 대상 | 1225 | 566 | 334 | 15 | 없음 |
| auras 플레이어 | 439 | 547 | 256 | 84 | 없음 |
| auras 플레이어의 소환수 | 517 | 566 | 334 | 15 | 없음 |
| details 1 | 1320 | 466 | 372 | 168 | 없음 |
| details 2 | 1320 | 650 | 372 | 106 | 없음 |
| edit appearance.action | 880 | 860 | 410 | 192 | 없음 |
| edit appearance.aux | 260 | 748 | 398 | 48 | 없음 |
| edit appearance.chat1 | 0 | 860 | 438 | 192 | 없음 |
| edit appearance.chat2 | 440 | 860 | 438 | 192 | 없음 |
| edit appearance.chat3 | 1486 | 860 | 434 | 192 | 없음 |
| edit appearance.minimap | 1292 | 860 | 192 | 192 | 없음 |
| edit appearance.ornamentLeft | 12 | 706 | 96 | 96 | 없음 |
| edit appearance.ornamentRight | 1812 | 706 | 96 | 96 | 없음 |
| edit appearance.ribbon | 0 | 850 | 1920 | 10 | 없음 |
| edit appearance.seam1 | 438 | 860 | 2 | 192 | 없음 |
| edit appearance.seam2 | 878 | 860 | 2 | 192 | 없음 |
| edit appearance.seam3 | 1290 | 860 | 2 | 192 | 없음 |
| edit appearance.seam4 | 1484 | 860 | 2 | 192 | 없음 |
| edit appearance.status | 0 | 1052 | 1920 | 22 | 없음 |
| edit appearance.unitLower | 338 | 680 | 340 | 56 | 없음 |
| edit appearance.unitUpper | 438 | 620 | 240 | 48 | 없음 |
| edit appearance.upper | 61 | 802 | 1798 | 48 | 없음 |
| edit statusstrip.bar | 0 | 1052 | 1920 | 22 | 없음 |
| group 파티 | 26 | 46 | 218 | 312 | 없음 |
| group 파티원 대상 | 252 | 46 | 108 | 281 | 없음 |
| group 파티원 대상의 대상 | 252 | 73 | 108 | 281 | 없음 |
| group 파티원 소환수 | 368 | 46 | 108 | 281 | 없음 |
| hekili AOE | 792 | 64 | 56 | 56 | 없음 |
| hekili Cooldowns | 1072 | 64 | 56 | 56 | 없음 |
| hekili Defensives | 1212 | 64 | 56 | 56 | 없음 |
| hekili Interrupts | 652 | 64 | 56 | 56 | 없음 |
| hekili Primary | 932 | 64 | 56 | 56 | 없음 |
| quartz Focus | 1218 | 603 | 185 | 15 | 없음 |
| quartz Pet | 202 | 518 | 246 | 14 | 없음 |
| quartz Player | 817 | 636 | 266 | 18 | 없음 |
| quartz Target | 1213 | 748 | 268 | 20 | 없음 |
| unit 대상 | 1225 | 631 | 256 | 72 | 없음 |
| unit 대상의 대상 | 1225 | 711 | 123 | 29 | 없음 |
| unit 대상의 대상의 대상 | 1358 | 711 | 123 | 29 | 없음 |
| unit 주시 대상 | 1225 | 510 | 178 | 56 | 없음 |
| unit 주시 대상의 대상 | 1319 | 572 | 84 | 23 | 없음 |
| unit 주시 대상의 대상의 대상 | 1225 | 572 | 84 | 23 | 없음 |
| unit 플레이어 | 439 | 631 | 256 | 72 | 없음 |
| unit 플레이어 아래 대상 | 439 | 711 | 123 | 29 | 없음 |
| unit 플레이어 아래 대상의 대상 | 572 | 711 | 123 | 29 | 없음 |
| unit 플레이어의 소환수 | 517 | 510 | 178 | 56 | 없음 |
| unit 플레이어의 소환수의 대상 | 517 | 572 | 84 | 23 | 없음 |
| unit 플레이어의 소환수의 대상의 대상 | 611 | 572 | 84 | 23 | 없음 |

#### qhd 2560x1440

| 프레임 | x | y | 폭 | 높이 | Grid2 공격대 40 과 겹침 |
|---|---|---|---|---|---|
| **Grid2 공격대 40명 최대** | 786 | 164 | 988 | 236 | — |
| **Grid2 파티(5칸)** | 1220 | 164 | 120 | 236 | — |
| auras 대상 | 1633 | 668 | 342 | 229 | 없음 |
| auras 주시 대상 | 1633 | 816 | 434 | 18 | 없음 |
| auras 플레이어 | 585 | 787 | 342 | 110 | 없음 |
| auras 플레이어의 소환수 | 691 | 816 | 434 | 18 | 없음 |
| details 1 | 1946 | 780 | 330 | 180 | 없음 |
| details 2 | 1946 | 972 | 330 | 100 | 없음 |
| edit appearance.action | 1244 | 1186 | 474 | 224 | 없음 |
| edit appearance.aux | 474 | 1056 | 462 | 56 | 없음 |
| edit appearance.chat1 | 0 | 1186 | 620 | 224 | 없음 |
| edit appearance.chat2 | 622 | 1186 | 620 | 224 | 없음 |
| edit appearance.chat3 | 1946 | 1186 | 614 | 224 | 없음 |
| edit appearance.minimap | 1720 | 1186 | 224 | 224 | 없음 |
| edit appearance.ornamentLeft | 80 | 998 | 176 | 176 | 없음 |
| edit appearance.ornamentRight | 2304 | 998 | 176 | 176 | 없음 |
| edit appearance.ribbon | 0 | 1174 | 2560 | 12 | 없음 |
| edit appearance.seam1 | 620 | 1186 | 2 | 224 | 없음 |
| edit appearance.seam2 | 1242 | 1186 | 2 | 224 | 없음 |
| edit appearance.seam3 | 1718 | 1186 | 2 | 224 | 없음 |
| edit appearance.seam4 | 1944 | 1186 | 2 | 224 | 없음 |
| edit appearance.status | 0 | 1410 | 2560 | 24 | 없음 |
| edit appearance.unitLower | 570 | 980 | 400 | 64 | 없음 |
| edit appearance.unitUpper | 690 | 908 | 280 | 56 | 없음 |
| edit appearance.upper | 237 | 1118 | 2086 | 56 | 없음 |
| edit statusstrip.bar | 0 | 1410 | 2560 | 24 | 없음 |
| group 파티 | 34 | 60 | 284 | 406 | 없음 |
| group 파티원 대상 | 326 | 60 | 142 | 364 | 없음 |
| group 파티원 대상의 대상 | 326 | 92 | 142 | 364 | 없음 |
| group 파티원 소환수 | 476 | 60 | 142 | 364 | 없음 |
| hekili AOE | 1088 | 80 | 64 | 64 | 없음 |
| hekili Cooldowns | 1408 | 80 | 64 | 64 | 없음 |
| hekili Defensives | 1568 | 80 | 64 | 64 | 없음 |
| hekili Interrupts | 928 | 80 | 64 | 64 | 없음 |
| hekili Primary | 1248 | 80 | 64 | 64 | 없음 |
| quartz Focus | 1620 | 862 | 249 | 21 | 없음 |
| quartz Pet | 240 | 834 | 286 | 14 | 없음 |
| quartz Player | 1088 | 907 | 358 | 24 | 없음 |
| quartz Target | 1617 | 1054 | 358 | 24 | 없음 |
| unit 대상 | 1633 | 897 | 342 | 96 | 없음 |
| unit 대상의 대상 | 1633 | 1005 | 166 | 39 | 없음 |
| unit 대상의 대상의 대상 | 1809 | 1005 | 166 | 39 | 없음 |
| unit 주시 대상 | 1633 | 742 | 236 | 74 | 없음 |
| unit 주시 대상의 대상 | 1756 | 824 | 113 | 30 | 없음 |
| unit 주시 대상의 대상의 대상 | 1633 | 824 | 113 | 30 | 없음 |
| unit 플레이어 | 585 | 897 | 342 | 96 | 없음 |
| unit 플레이어 아래 대상 | 585 | 1005 | 166 | 39 | 없음 |
| unit 플레이어 아래 대상의 대상 | 761 | 1005 | 166 | 39 | 없음 |
| unit 플레이어의 소환수 | 691 | 742 | 236 | 74 | 없음 |
| unit 플레이어의 소환수의 대상 | 691 | 824 | 113 | 30 | 없음 |
| unit 플레이어의 소환수의 대상의 대상 | 814 | 824 | 113 | 30 | 없음 |

#### uhd 3840x2160

| 프레임 | x | y | 폭 | 높이 | Grid2 공격대 40 과 겹침 |
|---|---|---|---|---|---|
| **Grid2 공격대 40명 최대** | 1283 | 212 | 1274 | 304 | — |
| **Grid2 파티(5칸)** | 1843 | 212 | 154 | 304 | — |
| auras 대상 | 2450 | 1080 | 512 | 334 | 없음 |
| auras 주시 대상 | 2450 | 1301 | 608 | 24 | 없음 |
| auras 플레이어 | 878 | 1254 | 512 | 160 | 없음 |
| auras 플레이어의 소환수 | 1034 | 1301 | 608 | 24 | 없음 |
| details 1 | 2902 | 1280 | 460 | 260 | 없음 |
| details 2 | 2902 | 1552 | 460 | 136 | 없음 |
| edit appearance.action | 1924 | 1820 | 670 | 304 | 없음 |
| edit appearance.aux | 760 | 1636 | 654 | 80 | 없음 |
| edit appearance.chat1 | 0 | 1820 | 960 | 304 | 없음 |
| edit appearance.chat2 | 962 | 1820 | 960 | 304 | 없음 |
| edit appearance.chat3 | 2902 | 1820 | 938 | 304 | 없음 |
| edit appearance.minimap | 2596 | 1820 | 304 | 304 | 없음 |
| edit appearance.ornamentLeft | 229 | 1548 | 256 | 256 | 없음 |
| edit appearance.ornamentRight | 3348 | 1548 | 256 | 256 | 없음 |
| edit appearance.ribbon | 0 | 1804 | 3840 | 16 | 없음 |
| edit appearance.seam1 | 960 | 1820 | 2 | 304 | 없음 |
| edit appearance.seam2 | 1922 | 1820 | 2 | 304 | 없음 |
| edit appearance.seam3 | 2594 | 1820 | 2 | 304 | 없음 |
| edit appearance.seam4 | 2900 | 1820 | 2 | 304 | 없음 |
| edit appearance.status | 0 | 2124 | 3840 | 28 | 없음 |
| edit appearance.unitLower | 916 | 1536 | 554 | 84 | 없음 |
| edit appearance.unitUpper | 1080 | 1440 | 390 | 72 | 없음 |
| edit appearance.upper | 445 | 1724 | 2950 | 80 | 없음 |
| edit statusstrip.bar | 0 | 2124 | 3840 | 28 | 없음 |
| group 파티 | 52 | 92 | 400 | 546 | 없음 |
| group 파티원 대상 | 460 | 92 | 200 | 492 | 없음 |
| group 파티원 대상의 대상 | 460 | 138 | 200 | 492 | 없음 |
| group 파티원 소환수 | 668 | 92 | 200 | 492 | 없음 |
| hekili AOE | 1640 | 112 | 80 | 80 | 없음 |
| hekili Cooldowns | 2120 | 112 | 80 | 80 | 없음 |
| hekili Defensives | 2360 | 112 | 80 | 80 | 없음 |
| hekili Interrupts | 1400 | 112 | 80 | 80 | 없음 |
| hekili Primary | 1880 | 112 | 80 | 80 | 없음 |
| quartz Focus | 2430 | 1364 | 376 | 28 | 없음 |
| quartz Pet | 192 | 1604 | 370 | 18 | 없음 |
| quartz Player | 1637 | 1440 | 534 | 30 | 없음 |
| quartz Target | 2428 | 1636 | 534 | 30 | 없음 |
| unit 대상 | 2450 | 1414 | 512 | 144 | 없음 |
| unit 대상의 대상 | 2450 | 1568 | 251 | 58 | 없음 |
| unit 대상의 대상의 대상 | 2711 | 1568 | 251 | 58 | 없음 |
| unit 주시 대상 | 2450 | 1189 | 356 | 112 | 없음 |
| unit 주시 대상의 대상 | 2633 | 1309 | 173 | 45 | 없음 |
| unit 주시 대상의 대상의 대상 | 2450 | 1309 | 173 | 45 | 없음 |
| unit 플레이어 | 878 | 1414 | 512 | 144 | 없음 |
| unit 플레이어 아래 대상 | 878 | 1568 | 251 | 58 | 없음 |
| unit 플레이어 아래 대상의 대상 | 1139 | 1568 | 251 | 58 | 없음 |
| unit 플레이어의 소환수 | 1034 | 1189 | 356 | 112 | 없음 |
| unit 플레이어의 소환수의 대상 | 1034 | 1309 | 173 | 45 | 없음 |
| unit 플레이어의 소환수의 대상의 대상 | 1217 | 1309 | 173 | 45 | 없음 |

### 실행한 명령과 판정 줄 (고침 1)

- `python3 -I tools/patches.py regenerate --package Quartz` → wrote Quartz.patch (7883 bytes) · `verify` → patches=7 unmodified=20 failures=0
- `python3 -I tools/genregistry.py --check` → up to date, rc=0
- `python3 -I tools/luacheck.py AddOns/!DevilForever_Core AddOns/Quartz/modules/SwingForever.lua` → checked=22 failed=0
- suites: castbars 16/16 · catalog 4/4 · chatsetup 32/32 · composition 8/8 · core 109/109 · firststart 25/25 · fufdefaults 22/22 · layoutv2 rc=0(마지막 PASS 줄 「stand-still default … 0.5」, Grid2 배치 PASS 4줄) · patches 4/4 · pitbull4 6/6 · pitbull4runtime 20/20 · statusstrip 20/20 · thirdparty 8/8
- detailslayout: 같은 FileNotFoundError(앞 판과 같음, 고치지 않음) · performance·installer: 앞 판과 같은 이유로 판정 대상 밖
- 새 Grid2 배치 시험이 옛 값을 잡는지: 옛 PosX/PosY 로 먼저 돌려 `AssertionError: ('fhd', 1920, (24.0, 164.0, 796, 176), ['group 파티원 대상', … 'group 파티원 소환수'] …)` 확인한 뒤 preset 값을 바꿈
- `build.py --install` ×2 → sha256=d4ff55b4fc43ae520915d23da6a806e84b4a277ddee92b39b18a343f2410f43f 두 번 같음(files=2214)
- `build.py --install --variant fuf` ×2 → sha256=ffb88ff2172fdb98936aed05930da366936a2945b5563a8251f519b22405d4e4 두 번 같음(files=2158)
- `catalog.py <두 ZIP> --write` → 2 packages · `--check` → matches (pitbull4 d4ff55b4fc43, fuf ffb88ff2172f), rc=0

### 결정 대기 (고침 1 뒤 — 앞 목록을 대신함)

1. Grid2 자리(화면 위 가운데, Hekili 바로 아래)는 코드 값 계산으로만 겹침 0 — 게임 화면 확인은 Codex 몫. 같은 자리에 게임 기본 글자(오류 메시지 줄·공격대 경보 글자)가 뜰 수 있음(preset 프레임 아님, 미검증).
2. 오라 덮개는 계산 추정(렌더러 실측 아님).
3. 늦은 사격이 한 주기 넘게 밀리면 숨기는 동작(경미 5) — 유지, Codex 게임 확인 항목.
4. 멈춤 구간 0.5초 실값 — Codex 실측, Codex 확인 메모 몫.
5. 이전 판 설치: v5 조각이 「kept」 로 한 번 알림(`/dfp preset … 으로 쓸 수 있음`)을 띄울 것으로 봄(Presets.lua 판 비교 경로를 읽고 한 추정, 시험 안 함) — 업그레이드 안내로 둠. Grid2 의 이전 프로필 위치·미니맵 단추는 바꾸지 않음(`/dfp party on` 은 Grid2 파티 보이기만).

### 이어받을 상태 (고침 1)

남은 일 없음. 스크래치: `s47/dump_preset.py`(preset 값 덤프), `s47/rects.md`(위 표 원본), `s47/{fhd,qhd,uhd}.json`.

## 고침 2 (재검증 1 · audit_log-47-2.md · TRIAGE 「Step 47 re-check 1」)

읽은 것: `iter_3/audit_log-47-2.md` 전문, `TRIAGE_phase26.md` 57-64, Party.lua 전문(현재 판), Presets.lua 520-600·660-700, Grid2 GridLayout.lua 1005-1015(GetFramePosition), 설치안내.md:57·:66.

### 바꾼 파일

| 파일 | 무엇 |
|---|---|
| `Party.lua` | `/dfp party on` 에서 Grid2 창이 활성 preset(fhd/qhd/uhd)의 예전 기본 자리(`OLD_GRID2_SPOT` — anchor TOPLEFT, fhd 24,-164 · qhd 40,-164 · uhd 80,-240 물리 px)에 1 px 안으로 있을 때만 그 preset 의 Grid2Layout 자리(anchor·PosX·PosY)로 옮김. anchor 가 저장돼 있지 않으면(AceDB 가 Grid2 기본 TOPLEFT 를 지움) TOPLEFT 로 봄. 이미 새 자리(1 px 안)면 말 없음. 그 밖(사용자가 옮긴 값)은 그대로 두고 「Grid2 창 위치는 직접 정한 값이라 그대로 — PitBull4 파티와 겹치면 Grid2 에서 옮기세요」 한 줄. `off` 와 접속 때는 옮기지 않음. 물리 px 환산 = PosX/PixelUtil 계수(없으면 화면 높이로 계산, 그것도 없으면 옮기지 않음) · 머리 주석 |
| `Presets.lua` | `partyGroupsOnly`(PitBull4 파티 그룹만 든 조각) · 그 조각의 「kept」 기록 문구와 접속 알림을 `/dfp party on` 안내 한 줄로(「PitBull4 파티 그룹(공격대 표시·파티원 소환수)은 이전 설정 그대로 — 전투 밖에서 /dfp party on 으로 맞춤」). 다른 조각은 그대로 `/dfp preset` 안내, 개수는 그 조각들만 셈 |
| `install/설치안내.md` :57 | 업그레이드 문장을 실제 동작에 맞춤(예전 기본 자리의 Grid2 창만 옮김 · 명령 친 캐릭터만 · 직접 옮긴 창은 그대로·한 줄 알림 · 미니맵 단추는 예전 설정 그대로) |
| `tests/firststart/run.py` | `party_command_moves_grid2_only_from_the_earlier_default_spot`(새 설치=새 자리·줄 없음 / anchor 없음+옛 값 → 옮김 / 1 px 안 오차 → 옮김 / 사용자 값 → 유지·알림 / off 는 안 옮김 / 다음 접속 안 옮김) · `party_groups_kept_notice_points_to_party_command`(receipt 4 → `/dfp party on` 안내, `/dfp preset fhd` 안내 없음, 다음 접속엔 안 뜸) |
| `Installer/ReleaseCatalog.json` | 다시 씀 |

### 영향 지도

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| Party:Set Grid2 단계 | 고친 곳 | 전문 | 함께 고침 | 중간 1 |
| Presets fhd/qhd/uhd Grid2Layout(새 자리) | 같은 값 | 고침 1 grep | 확인만 | 옮길 자리를 preset 조각에서 그대로 읽음(값 중복 없음) |
| 옛 자리 값(24,-164 / 40,-164 / 80,-240) | 같은 값 | 고침 1 이전 판 preset·audit_log-47-1 인용 | 함께 고침(상수) | 판정 기준 |
| Grid2 GetFramePosition | 소비 | 읽음 | 확인만 | PosX/s 쓰임 — 물리 px = PosX/계수 |
| Presets onAddonLoaded kept · PLAYER_ENTERING_WORLD 알림 | 고친 곳 | 읽음 | 함께 고침 | 경미 1 |
| firststart 다른 party 시험(PixelUtil·preset 없는 세션) | 시험 | 실행 | 확인만 | 계수·preset 없으면 옮기지 않음 — 그대로 통과 |
| 설치안내.md :57·:66 | 문서 | 읽음 | :57 함께 고침 · :66 확인만 | :66 은 PitBull4 쪽 문장이라 맞음 |

### 실행한 명령과 판정 줄

- `python3 -I tools/patches.py verify` → patches=7 unmodified=20 failures=0
- `python3 -I tools/genregistry.py --check` → up to date
- `python3 -I tools/luacheck.py AddOns/!DevilForever_Core` → checked=21 failed=0
- suites: castbars 16/16 · catalog 4/4 · chatsetup 32/32 · composition 8/8 · core 109/109 · firststart 27/27 · fufdefaults 22/22 · layoutv2 rc=0 · patches 4/4 · pitbull4 6/6 · pitbull4runtime 20/20 · statusstrip 20/20 · thirdparty 8/8 · detailslayout 같은 FileNotFoundError(그대로) · performance·installer 판정 밖(앞과 같은 이유)
- 첫 실행에서 PixelUtil 없는 시험 세션이 `GetPhysicalScreenSize` nil 호출로 4건 실패 → 함수 확인을 넣고 다시 27/27
- `build.py --install` ×2 → sha256=36ef3c83a9f0d7414f97d4a1c31148cb46125cfa7a7a400299e38dd50937184d 같음(files=2214)
- `build.py --install --variant fuf` ×2 → sha256=a4fbb2fb3ef3c5a6edace30a900af039a090b298e721a8ecbbd143399905e2ff 같음(files=2158)
- `catalog.py --write` → 2 packages · `--check` → matches (pitbull4 36ef3c83a9f0, fuf a4fbb2fb3ef3), rc=0

### 결정 대기 (고침 2 뒤)

1. Grid2 를 화면 위 가운데에 둔 것 자체(시선 이동·인원 따라 좌우로 넓어짐) — 사용자 판단(master 최종 보고).
2. 위 가운데 게임 글자(오류 줄·공격대 경보)와 겹침 — Codex 게임 확인(경미 2 유지).
3. Grid2 창 옮기기는 명령을 친 캐릭터의 Grid2 프로필만(Grid2 는 캐릭터마다 따로). 다른 캐릭터는 각자 `/dfp party on`.
4. 앞 절의 늦은 사격 숨김·멈춤 구간 실값 — Codex.

### 이어받을 상태

남은 일 없음.

## Step 50 (Phase 26-rev · R148 「그리드는 우측 적군 대상 위에 배치」)

기준: 커밋 a362870f 위 작업 트리. 읽은 것: 발주 메시지, Presets fhd/qhd/uhd 「대상」 단위 줄·Grid2Layout 줄(grep), 고침 1 좌표 표(`s47/rects.md` — 대상·대상 오라·주시·Details·Hekili·Quartz 대상 행), Grid2 GridLayout.lua 1005-1015(GetFramePosition → SetPoint(anchor, UIParent, anchor, PosX/s, PosY/s)), 460-500(PlaceHeaders), 800-830(UpdateSize: 창 크기 = 내용), `codex-briefs/phase26-step47-check.md` 전문, 설치안내.md·feature-map.md 「위 가운데」 grep.

### 판단: 기준점 BOTTOMRIGHT

- Grid2 창은 UIParent 의 같은 이름 점에 붙고(GetFramePosition), 크기는 내용에 맞춰 바뀜(UpdateSize). 그래서 고정되는 것은 기준점 쪽 모서리이고 반대쪽으로 자람.
- **BOTTOMRIGHT** 로 정함. 아래 끝이 대상 오라 칸 위에 고정되어 창이 위로 자라고(대상 쪽으로 안 내려옴), 오른쪽 끝이 대상 프레임 오른쪽 끝에 고정되어 화면 안쪽(왼쪽)으로 자람.
- 대상 프레임은 TOPRIGHT 기준(오른쪽 끝에서 -439/-585/-878 물리 px)이라, 같은 오른쪽 오프셋을 PosX 로 쓰면 3862 폭처럼 화면이 넓어져도 대상과 오른쪽 끝이 함께 움직임.
- BOTTOM(가운데) 기준은 화면 가운데에서 재므로 폭이 바뀌면 대상과 어긋나 버림. BOTTOMLEFT 기준은 오른쪽으로 자라 fhd 에서 화면 밖(1225+796 > 1920)으로 나감.
- 세로 자리: 아래 끝 = 대상 오라 덮개 위 끝 − 8 px. 덮개는 약화 효과 16개가 모두 내 것인 높이로 잡은 추정이었음. [고침에서 정정: 이 덮개는 최악이 아니었음. 주시 대상이 보일 때의 회피 규칙(오른쪽 70 px 기둥, 0.7배)과 그룹별 상한(내 것 16 + 남의 것 16)을 빼먹어 실제 최악보다 낮았음 — 「Step 50 고침」 절]
- groupAnchor 는 TOPLEFT 그대로 둠. 창 안 칸 순서만 정하는 값이고, 창이 커지는 방향은 위 anchor 가 정함.

### 값 (물리 px × factor)

| preset | 대상 프레임 (x,y,폭,높이) | 대상 오라 덮개 위 끝 | Grid2 anchor · PosX · PosY | Grid2 공격대 40명 (x,y,폭,높이) | 오라 위 간격 |
|---|---|---|---|---|---|
| fhd 1920 | (1225, 631, 256, 72) | 457 | BOTTOMRIGHT · -439 · +631 | (685, 273, 796, 176) | 8 |
| qhd 2560 | (1633, 897, 342, 96) | 668 | BOTTOMRIGHT · -585 · +780 | (987, 424, 988, 236) | 8 |
| uhd 3840 | (2450, 1414, 512, 144) | 1080 | BOTTOMRIGHT · -878 · +1088 | (1688, 768, 1274, 304) | 8 |
| uhd 3862 | (2472, 1414, 512, 144) | 1080 | (같은 값) | (1710, 768, 1274, 304) | 8 |

- 파티 창(1열 5칸)은 같은 오른쪽 아래 모서리에 붙음. fhd 기준 (1385, 273, 96, 176).
- 그 밖의 49개 preset 사각형과 겹침 0 — `tests/layoutv2/run.py` 끝 블록이 계산함. 사각형 종류·계산법은 「고침 1」 표와 같음.
- 가까운 사각형:
  - Details 1 (fhd 1320,466~) 은 Grid2 아래 끝 449 보다 아래라 겹치지 않음.
  - 주시 대상 (1225,510~) 도 아래.
  - Hekili 줄 (y 64~120) 은 Grid2 위 끝 273 보다 위.
- 시험 단언:
  - 겹침 0.
  - 화면 안.
  - 공격대 40명 창과 파티 창이 가로로 대상 프레임 범위와 겹침.
  - 세로로 아래 끝 ≤ 대상 오라 위 끝 ≤ 대상 프레임 위 끝.
  - 두 창의 오른쪽 끝 = 대상 오른쪽 끝, 아래 끝이 서로 같음.

### 바꾼 파일

| 파일 | 무엇 |
|---|---|
| `Presets/{fhd,qhd,uhd}.lua` | Grid2Layout `anchor="BOTTOMRIGHT"`, `PosX=-439/-585/-878*factor`, `PosY=631/780/1088*factor` |
| `Party.lua` | 옛 자리 이동 알림 「…preset 의 자리(오른쪽, 대상 프레임 위)」. 옛 기본 자리 판정(OLD_GRID2_SPOT)은 그대로 두고, Step 47 의 위 가운데 자리는 배포 안 됐으니 넣지 않음. 옮겨 갈 자리는 preset 에서 읽으므로 자동으로 새 자리 |
| `tests/layoutv2/run.py` | `_grid2_rects` 가 화면 높이를 받음(BOTTOM 기준 계산) · 「대상 위」 단언 · PASS 줄 |
| `tests/firststart/run.py` | 새 설치·옛 자리 이동 기대값 ("BOTTOMRIGHT", -439, 631) |
| `install/설치안내.md` :11·:57 | Grid2 자리 = 오른쪽 적 대상 프레임 바로 위, 인원 따라 위·왼쪽으로 넓어짐 · 업그레이드 문장의 옮겨 가는 자리 |
| `data/feature-map.md` :58 | 같은 자리 설명 |
| `codex-briefs/phase26-step47-check.md` 1번 | 확인할 것을 새 자리·겹침 상대(대상·대상 오라·주시·Details)로 바꿈 |
| `Installer/ReleaseCatalog.json` | 다시 씀 |

### 영향 지도

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| Presets 셋 Grid2Layout | 같은 값 | grep | 함께 고침 | R148 |
| Defaults/Grid2.lua reapplyAfterTemplate | 소비 | 앞서 읽음 | 확인만 | 조각 값을 그대로 다시 씀 |
| Party.lua moveGrid2 | 소비 | 읽음 | 함께 고침(문구) / 확인만(자리 계산) | 새 자리는 preset 에서 읽음 |
| tests layoutv2·firststart | 시험 | grep 「TOP」·「위 가운데」 | 함께 고침 | |
| 설치안내·feature-map·Codex 확인 메모 | 문서 | grep 「위 가운데」 | 함께 고침 | Hekili 설명(phase8.md·appearance-8.md)의 「위 가운데」는 Hekili 이야기라 영향 없음 |
| 앞 Step 의 work_log·Result·TRIAGE | 기록 | grep | 영향 없음(기록) | |

### 실행한 명령과 판정 줄

- `python3 -I tools/patches.py verify` → patches=7 unmodified=20 failures=0
- `python3 -I tools/genregistry.py --check` → up to date
- `python3 -I tools/luacheck.py AddOns/!DevilForever_Core` → checked=21 failed=0
- suites:
  - castbars 16/16 · catalog 4/4 · chatsetup 32/32 · composition 8/8 · core 109/109
  - firststart 27/27 · fufdefaults 22/22 · layoutv2 rc=0 (Grid2 PASS 4줄, 위 표 값) · patches 4/4
  - pitbull4 6/6 · pitbull4runtime 20/20 · statusstrip 20/20 · thirdparty 8/8
  - detailslayout 같은 FileNotFoundError · performance·installer 판정 밖(앞과 같음)
- `build.py --install` ×2 → sha256=aa3e926b27aac520a7ac8c20c38bf7acd90aa4ed1643f9b2c1bdae8f885edb97 두 번 같음 (files=2214)
- `build.py --install --variant fuf` ×2 → sha256=7e5e792c297879c9d1fb9893e8cd072ec743781e28b33e49a052e658ab3f8f95 두 번 같음 (files=2158)
- `python3 tools/catalog.py <pitbull4 zip> <fuf zip> --write` → 2 packages. 이어서 같은 순서로 `--check` → matches (pitbull4 aa3e926b27aa, fuf 7e5e792c2978), rc=0. 뒤에 ZIP 해시를 다시 재어 그대로임(aa3e926b27aa · 7e5e792c2978)
- catalog suite: 6번 돌려 1번 `modified_zip_no_longer_matches` 실패("rebuilt from the same inputs matches again: expected 0, got 1"), 5번 통과. 원인(코드로 본 판단): 시험의 `make_zip` 이 `zf.writestr(name, data)` 로 지금 시각을 ZIP 날짜로 넣음(tests/catalog/run.py:34-39). 같은 입력을 다시 만들 때 2초 단위 시각이 바뀌면 바이트가 달라짐. 시험 쪽 문제이고 이번 변경과 무관. 범위 밖이라 안 고침

### 결정 대기

1. Grid2 새 자리의 게임 화면 확인은 Codex 몫(확인 메모 1번에 적음).
2. 세로 간격은 오라 덮개(최악 추정) 위 8 px. 실제 오라가 덮개보다 낮으면 대상과 Grid2 사이가 그만큼 더 벌어짐. 붙이는 높이를 실측으로 다시 잡을지.
3. catalog 시험의 시각 의존(위) — 고칠지 결정 필요. `ZipInfo` 에 날짜를 고정하면 됨.

### 이어받을 상태

남은 일 없음.

## Step 50 고침 (audit_log-50-1.md · TRIAGE 「Step 50 review」)

읽은 것: `iter_3/audit_log-50-1.md` 전문 · TRIAGE 69-75 · 검수 B probe `scratchpad/probes/p6.py`·`p7.py`·`p9.py` 전문(지금 작업 트리로 다시 돌려 같은 수치 확인) · PitBull4 Aura/Forever.lua 296-340(native 상자 놓기) · Presets/V2.lua 전문 · Party.lua moveGrid2.

### 오라 최악 계산을 고침 (중간 1 · 경미 1)

`tests/layoutv2/run.py` 의 덮개 추정을 지움. 대신 새 함수 `aura_bands` 가 단위마다 PitBull4 Aura 모듈을 그 profile 로 직접 돌림.
- 경로: native 전투 경로(UpdateNativeBuffs/Debuffs → GetManagedLayoutDB(Layout.lua) → 상자 SetPoint/폭).
- 상한: 그룹마다(내 것·남의 것) maxFrameCount 까지 채움.
- 회피 규칙: 피하는 프레임(`avoid_frame`)이 숨었을 때와 보일 때, 두 번 계산.
- 띠 사각형: 상자의 SetPoint 점·오프셋과 폭으로 계산. 오른쪽 기둥이면 그 x 범위만 잡음.
- 대상 단위: 플레이어·대상·소환수·주시·대상의 소환수(켜진 것). V1 과 V2 둘 다.

측정한 대상 약화 띠의 위 끝(물리 y). 검수 B probe p7·p9 와 같은 값:

| 배치 | 해상도 | 주시 없음 | 주시 보임 |
|---|---|---|---|
| V1 | fhd | 415 | 291 |
| V1 | qhd | 612 | 460 |
| V1 | uhd | 998 | 770 |
| V2 | fhd | 355 | 355 |
| V2 | qhd | 549 | 549 |
| V2 | uhd | 912 | 912 |

V2 의 대상 규칙은 `{above, width}` 뿐이라 회피가 없어 두 값이 같음.

### 새 자리 (BOTTOMRIGHT 유지 · 오른쪽 끝 = 대상 오른쪽 끝 · 위로 자람)

| 배치 | 해상도 | 아래 끝 y | PosX · PosY (물리 px × factor) | 40명 창 (x,y,폭,높이) | 최악 띠와 간격 |
|---|---|---|---|---|---|
| V1 | fhd | 304 | -439 · +776 | (685, 128, 796, 176) | **-13** (아래) |
| V1 | qhd | 452 | -585 · +988 | (987, 216, 988, 236) | 8 |
| V1 | uhd | 762 | -878 · +1398 | (1688, 458, 1274, 304) | 8 |
| V1 | uhd 3862 | 762 | 같은 값 | (1710, 458, 1274, 304) | 8 |
| V2 | fhd | 347 | -536 · +733 | (588, 171, 796, 176) | 8 |
| V2 | qhd | 541 | -731 · +899 | (841, 305, 988, 236) | 8 |
| V2 | uhd | 904 | -1119 · +1256 | (1447, 600, 1274, 304) | 8 |
| V2 | uhd 3862 | 904 | 같은 값 | (1469, 600, 1274, 304) | 8 |

- V2 PosX 는 V2.lua 가 계산함: `(xTarget + w - m.width) * factor`. PosY = `(m.height - m.gridBottom) * factor`. gridBottom 은 위 측정값 − 8 을 modes 표에 넣은 것.
- **fhd V1 부족분:**
  - 최악(주시 보임)에 맞추면 아래 끝 283, 위 끝 107 이 되어 Hekili 아이콘 줄(y 64~120, x 652~1268)과 겹침.
  - 그래서 화면 안에서 가능한 가장 가까운 자리로 둠: Hekili 아래 8 px(위 끝 128, 아래 끝 304).
  - 이때 「주시 보임 + 내 것·남의 것 약화 효과가 거의 다 찬」 경우에만 대상 오른쪽 70 px 기둥(x 1411~1481)이 창 아래로 13 px 들어감.
  - 주시가 없으면 띠 위 끝 415 라 111 px 띄워짐.
  - 시험은 이 한 쌍만 13 px 까지 허용하고 이름으로 적어 둠(SHORTFALL).
- **V2 3862 폭:** V2 대상은 화면 가운데 기준으로 놓이고 Grid2 는 오른쪽 기준. 그래서 늘어난 폭의 절반(11 px)만큼 오른쪽 끝이 어긋남. 시험은 그만큼만 허용함.
- 「대상 위」 단언(V1·V2, 4 화면):
  - 화면 안.
  - 다른 preset 사각형 61개(V1)/66개(V2) 와 겹침 0. fhd V1 부족분 하나만 예외.
  - 가로로 대상과 겹침.
  - 아래 끝 ≤ 대상 위 끝.
  - 아래 끝 ≤ 모든 대상 띠 위 끝 − 8.
  - 오른쪽 끝 맞춤.

### V2 에 Grid2 자리 (중간 2)

- `Presets/V2.lua`: V1·V2 비교 배치 정의에 Grid2Layout 조각(창 자리 anchor·PosX·PosY 만)을 넣음. V1 = 기본 preset 값. V2 = V2 대상 위.
- 비교 배치 예약 문구: 「PitBull4, Quartz, Grid2 창 자리만 적용」.
- 시험 `grid2_spot_follows_the_compare_layout_and_back`(firststart): fhd → fhd-v2 = (-536, 733) → fhd-v1 = (-439, 776).

### `/dfp party on` 옛 자리 이동 (4)

- PitBull4 profile 이 V2 를 쓰는 중(dfLayoutV2)이면 `<preset>-v2` 의 자리로 옮김.
- 알림: 「Grid2 창: 예전 기본 자리 → fhd-v2 preset 의 자리(오른쪽, 대상 프레임 위)」.
- 시험: 같은 case 에서 V2 사용 중 옛 자리 → V2 자리 확인. 새 설치 기대값 (-439, 776).

### 바꾼 파일

| 파일 | 무엇 |
|---|---|
| `Presets/{fhd,qhd,uhd}.lua` | Grid2Layout PosY 776/988/1398 ×factor |
| `Presets/V2.lua` | modes 에 height·gridBottom · `pixelFactor` · 비교 배치의 Grid2Layout 자리 조각 |
| `Presets.lua` | 비교 배치 예약 문구 |
| `Party.lua` | moveGrid2 가 V2 사용 중이면 V2 자리 · 알림의 preset 이름 · 머리 주석 |
| `tests/layoutv2/run.py` | `aura_bands`(native 띠) · `default_screen_map(…, v2)` · V1·V2 배치 단언 · 주석 사실대로 |
| `tests/firststart/run.py` | 기대값 · V2 왕복과 V2 중 옛 자리 이동 case |
| `codex-briefs/phase26-step47-check.md` 1번 | 자리 숫자(V1·V2)와 fhd 부족분 확인 항목 |
| `Installer/ReleaseCatalog.json` | 다시 씀 |

설치안내.md·feature-map.md 는 숫자 없이 「오른쪽 적 대상 프레임 위」라고만 적고 있어 그대로 맞음(확인만).

### 영향 지도

| 곳 | 유형 | 찾은 방법 | 영향도 | 이유 |
|---|---|---|---|---|
| Presets 셋 Grid2Layout | 같은 값 | grep | 함께 고침 | |
| V2.lua 비교 배치 조각 | 같은 값(V2 대상) | 전문 | 함께 고침 | |
| Presets.lua Restore layoutOnly 문구 | 사용자 글 | grep | 함께 고침 | Grid2 도 씀 |
| Party.lua moveGrid2 | 소비 | 읽음 | 함께 고침 | V1/V2 |
| Defaults/Grid2.lua reapplyAfterTemplate | 소비 | 앞서 읽음 | 확인만 | 활성 preset(기본) 조각만 다시 씀 — 비교 배치 중 Grid2 첫 템플릿이면 V1 자리로 돌아감(드묾, 아래 결정 대기) |
| tests layoutv2·firststart | 시험 | 실행 | 함께 고침 | |
| 설치안내·feature-map | 문서 | grep | 확인만 | |
| Codex 확인 메모 | 문서 | 읽음 | 함께 고침 | |

### 실행한 명령과 판정 줄

- B probe p7·p9·p6 을 작업 트리로 돌림 → 위 표 V1/V2 띠 값과 같음
- `python3 -I tools/patches.py verify` → patches=7 unmodified=20 failures=0
- `python3 -I tools/genregistry.py --check` → up to date
- `python3 -I tools/luacheck.py AddOns/!DevilForever_Core` → checked=21 failed=0
- suites:
  - castbars 16/16 · catalog 4/4 · chatsetup 32/32 · composition 8/8 · core 109/109
  - firststart 28/28 · fufdefaults 22/22 · patches 4/4 · pitbull4 6/6 · pitbull4runtime 20/20 · statusstrip 20/20 · thirdparty 8/8
  - layoutv2 rc=0 (배치 PASS 8줄, 위 표 값)
  - detailslayout 같은 FileNotFoundError · performance·installer 판정 밖
- firststart 첫 실행 1건 실패는 내 시험 순서 잘못이었음. V1 요청을 건 세션을 carry 해서 다음 접속이 V1 을 적용함. 요청 전에 carry 하도록 고침 → 28/28
- `build.py --install` ×2 → sha256=0efdb7218a75b4b0c380f9fb4ecd71389efade321dfe5e840b353a82bd1671da 같음(files=2214)
- `build.py --install --variant fuf` ×2 → sha256=d641a4ce40121b63319e6f503a82fbb7e202bf8dee50d154634b0ff8454f3fce 같음(files=2158)
- `python3 tools/catalog.py <두 zip> --write` → 2 packages, 다음 같은 순서 `--check` → matches (pitbull4 0efdb7218a75, fuf d641a4ce4012), rc=0. ZIP 해시 다시 재어 그대로

### 결정 대기

1. **fhd V1 부족분 13 px.** 대안:
   - ⓐ 그대로(주시 보임 + 약화 효과 대량일 때만 대상 오른쪽 오라 기둥 위 끝이 창 아래에 들어감).
   - ⓑ fhd Grid2 칸 높이를 줄임. frameHeight 32→29 면 40명 창 높이 161 → 아래 끝 289 가 291 위에 옴. 외관 값이라 Codex/사용자 판단.
   - ⓒ fhd Hekili 줄 높이를 조금 올림.
   - ⓓ fhd 만 대상 오라 회피 기둥 높이 상한을 줄임.
   - 어느 쪽인지.
2. V2 3862 폭에서 오른쪽 끝 11 px 어긋남. V2 비교 배치 전용이라 그대로 둠.
3. 비교 배치(V2) 중에 새 Grid2 프로필의 첫 템플릿이 적용되면, Defaults/Grid2.lua 가 활성(기본) preset 의 Grid2Layout 을 다시 써 V1 자리로 감(코드로 본 추정, 시험 안 함). 드문 경우라 그대로.
4. 게임 화면 확인은 Codex(확인 메모 1번에 숫자와 fhd 부족분 적음).

### 이어받을 상태

남은 일 없음. 스크래치 `s47/measure.py`(V1·V2 띠·자리 측정).

# unit 프레임 두 판 비교 — Forever Unit Frames(FUF) 판 vs PitBull4 판 (Phase 6 · Phase 6-rev)

이 표는 원천 코드와 우리 설정 파일을 읽어 만든 것이다. 게임에서 돌려 본 결과가 아니다. 게임 안 비교는 Codex 발주문 `Collection/codex-briefs/phase6-rev.md` 로 하고, 어느 쪽을 기본으로 묶을지는 그 결과로 Phase 23 에서 정해 기록한다(R107 ①). 두 판은 함께 켜지 않는다(같은 기능 두 애드온 금지).

경로 줄임: `F/` = `Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/`, `P/` = `Collection/AddOns/PitBull4/`(우리가 고친 판), `PD` = `Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua`, FUF 조사 기록 = `Claude/results/handoffs/phase6/iter_1/work_log-a2.md`.

## 1. 두 판의 정체

| 항목 | FUF 판 (Phase 6) | PitBull4 판 (Phase 6-rev) |
|---|---|---|
| 애드온 | Forever Unit Frames 0.65.2, 원본 그대로 (`F/ForeverUnitFrames.toc:1–5`, 작성자 StephanRosin) | PitBull4 v4.2.50 + Forever 고침 = `v4.2.50-forever.1`, 폴더 이름 `PitBull4` 그대로 |
| Forever 로드 근거 | Forever 전용으로 만든 애드온, TOC `Interface: 16001` (`F/ForeverUnitFrames.toc:1`) | 받은 v4.2.50 에는 16001 TOC 가 없다. 우리가 `P/PitBull4_Camelot.toc`·`P/PitBull4.toc`(16001, `modules_Camelot.xml`)를 더했다. 고침 내용은 V42 의 4.2.49-Forever-v42 판에서 옮겼다(`Collection/patches/PitBull4.patch` 머리말) |
| 게임 확인 | 미검증(이 컨테이너) | 미검증. V42 판 TOC 의 「Confirmed Forever 1.60.1 build 70291」 은 V42 판에 대한 표기라 옮기지 않았다. V42 의 v3 디버프 경로는 V42 설명서도 「실제 게임 엔진과 전투 표시는 검증하지 못했다」고 적었다 |
| 크기 | 파일 239개, Lua 43,795줄 | 파일 309개, Lua 79,774줄 (라이브러리 포함) |
| 원본과의 차이 | 없음 | v4.2.50 대비 72개 파일 (패치 9,291줄, 바뀐 파일 목록 = 작업 기록 Step 42 표) |

## 2. 기능별 비교

| 관점 | FUF 판 | PitBull4 판 |
|---|---|---|
| 프레임 | 내·대상·대상의 대상·대상의 대상의 대상·소환수·소환수 대상·주시·주시 대상, 파티, 우두머리 1–5, 공격대 (등록 표 15개) | Devil profile 그대로: 플레이어·대상·대상의 대상·대상의 대상의 대상·주시 대상·주시 대상의 대상·플레이어의 소환수 켬, 주시 대상의 대상의 대상·소환수의 대상 꺼 둠, 파티·파티원 대상·파티원 소환수 묶음 (`PD` units/groups). **우두머리 프레임 없음**(`made_groups` 로 PitBull4 기본 Boss 묶음을 만들지 않음 — 블리자드 우두머리 프레임은 PitBull4 가 숨기지 않아 그대로 보인다, `P/Modules/HideBlizzard/HideBlizzard.lua:14–26` 의 `boss = false`) |
| 파티·공격대 | 파티 = FUF(계정 공용 설정), 공격대 = Grid2 가 켜지면 `DevilForever_FUFDefaults` 가 캐릭터마다 한 번 `/fuf raid off` | 파티 묶음은 파티일 때만 보인다(PitBull4 기본 `show_when`: party 만, `P/Main.lua` 기본값). 공격대 묶음이 없어 Grid2 와 겹치지 않는다. 따로 끄는 애드온이 필요 없다 |
| 체력 | 모든 프레임 (`F/Elements/Health.lua`) | 모든 프레임. Forever 의 제한 값에서도 `UnitHealthPercent(unit, true)` 로 막대와 숫자를 같은 기준으로 그린다(`P/Modules/HealthBar/HealthBar.lua:156–167, 305–310`) |
| 주 자원 (분노·기력·마나) | `UnitPowerType` 대로 (`F/Elements/Power.lua:69–88`) | `UnitPowerType` 대로, 제한 값이면 `UnitPowerPercent` (`P/Modules/PowerBar/PowerBar.lua:155–157`). 대상의대상 배치는 자원 막대 끔(Devil) |
| 연계 점 (도적·표범 드루이드) | 대상 프레임 점 (`F/Elements/ComboPoints.lua`) | 대상 프레임 (클래식 규칙: 대상에만, `P/Modules/ComboPoints/ComboPoints.lua:177–193`). 대상의대상·파티 배치는 끔(Devil) |
| 드루이드 변신 중 마나 | 자원 막대 아래 띠 (`F/Elements/DruidMana.lua`) | `DruidManaBar` 막대 (드루이드·사제·주술사에서만 로드, 마나가 주 자원이 아닐 때, `P/Modules/AltManaBar/AltManaBar.lua:1–24`) |
| 주술사 토템 | 놓은 칸만 아이콘 (`F/Elements/Totems.lua`) | Totems 모듈 있음, **Devil profile 이 꺼 둠** — 토템은 Dominos 토템 바(classes.md SHAMAN) |
| 사냥꾼 소환수 만족도 | 소환수 프레임 아이콘 (`F/Elements/PetHappiness.lua`) | `HappinessIcon` 모듈 (사냥꾼에서만 로드, `GetPetHappiness` 또는 `C_PetInfo`, `P/Modules/HappinessIcon_Classic/HappinessIcon.lua:1–40`) — PitBull4 기본 켜짐 |
| **흑마법사 영혼의 조각** | 표시 없음 (Phase 6 결정 대기 3 → 최종 보고) | **표시 없음.** PitBull4 의 조각 모듈은 자원 종류(power type) 조각을 센다(`Collection/upstream/pitbull-unit-frames-4-0-v4.2.50/PitBull4/Modules/SoulShards_Classic/SoulShards.lua:10, 53–56`). Forever 의 조각은 아이템 개수(아이템 6265, classes.md WARLOCK)라 맞지 않고, `modules_Camelot.xml:49` 에서 빠져 있다. 설정만으로 채울 길은 LuaTexts 문자 하나(`GetItemCount(6265)` + 가방 사건)뿐이며 만들지 않았다(결정 대기) |
| 시전바 | FUF 자체 시전바, Quartz 모듈이 켜지면 `DevilForever_Castbars` 가 같은 unit 의 FUF 시전바를 숨김 | PitBull4 CastBar 모듈 끔, 블리자드 시전바도 PitBull4 가 숨기지 않음(Devil `HideBlizzard.castbar = false`) → 시전바는 Quartz 하나. `DevilForever_Castbars` 는 FUF 가 없으면 로드되지 않는다(TOC Dependencies) |
| 버프·디버프 | 대상·주시·파티 버프, 대상의 대상 류를 뺀 프레임 디버프 (`F/Core/Settings.lua:585–615`) | 대상 버프 14·디버프 16, 파티 버프 8(「기본 버프, 내 것」 필터 `!C`)·디버프 3, 플레이어·대상의대상 배치는 오라 끔(Devil). Forever 고침: 디버프는 블리자드 `CustomAuraContainer` 로 그린다 — 디버프 필터가 「없음」 인 배치만, 최대 수는 내 것/다른 사람 것 따로, 남은 시간 색은 고정 색, 그 경로에는 Masque·강조 없음(V42 설명서 12–33행, `P/Modules/Aura/Forever.lua:1–4`) |
| 치유 예측 | 켬 (`healPrediction`, `F/Core/Settings.lua:183`) | **끔** (Devil `VisualHeal` 끔) |
| 거리 흐림 | 켬 (`rangeFade`, `F/Core/Settings.lua:982`) | **끔** (Devil `RangeFader` 끔) |
| 위협 표시 | — | 끔 (Aggro·ThreatBar, 위협은 Details!/TinyThreat — R107 ②) |
| 이름·숫자 글자 | FUF 고정 요소 | LuaTexts 스크립트(Devil 의 이름·생명력·마력·직업·백분율 글자 그대로). Forever 고침이 제한 값을 블리자드 글자 출력으로 넘긴다(`P/Modules/LuaTexts/Forever.lua:8–75`) |
| 특성별 설정 묶음 | 원천 없음 | V42 의 `SpecProfiles.lua`(LibDualSpec 대신, 특성/특성 묶음이 바뀌면 고른 설정 묶음으로, 전투 중 바꾸지 않음, 사용자가 켤 때만) |

## 3. 전투 안전 (taint)

| 항목 | FUF 판 | PitBull4 판 |
|---|---|---|
| 근거 | 이번에 읽지 않음 (원천 확인 없음) | V42 고침: 제한 상태 사건 `ADDON_RESTRICTION_STATE_CHANGED` 을 받아 밀린 갱신을 제한이 끝난 뒤 다시 한다(`P/Main.lua:1782–1856`); 블리자드 프레임 숨기기는 전투 밖에서만 `SetParent`, 전투 중엔 투명도만(`P/Modules/HideBlizzard/HideBlizzard.lua:109–223`); 설정 창의 크기 값은 전투 중 잠김(`P/Options/LayoutEditor/General.lua` disabled = InCombatLockdown) |
| 게임 확인 | Codex 발주문 phase6-rev.md 8번 | Codex 발주문 phase6-rev.md 8번 |

## 4. 기본값을 넣는 길·저장·복원

| 항목 | FUF 판 | PitBull4 판 |
|---|---|---|
| 저장 변수 | `ForeverUnitFramesDB` (AceDB 아님). FUF 가 저장할 때마다 프로필 표를 통째로 다시 쓴다 → Core 기본값 파일을 쓸 수 없음 | `PitBull4DB` (AceDB-3.0, 계정). Core 기본값 파일 `PD` 로 넣는다: 공용 프로필 「Default」, 모듈은 AceDB namespace 25개 |
| 기본값 내용 | `DevilForever_FUFDefaults`: Grid2 가 켜지면 공격대만 끔 | Devil profile 「Wide」 의 기능 값(어떤 프레임·묶음·배치·모듈·오라 수·글자 스크립트) |
| 이미 쓰던 설정 | 건드리지 않음 | 건드리지 않음 — Core 는 처음 볼 때 없던 프로필(첫 설치, 프로필이 아직 없는 새 캐릭터)에만 쓴다. AceDB 가 로그아웃 때 기본값과 같은 값을 지우므로, 이미 있는 프로필에 빠진 키는 사용자가 고른 값일 수 있어서다(`Collection/AddOns/!DevilForever_Core/Defaults.lua` 머리말) |
| Phase 20 저장·복원 | AceDB 가 아니라 따로 연결이 필요(`Collection/judgment.md` 4-2 「AceDB 가 아닌 여섯」) | AceDB 라 ProfileManager 의 AceDB 경로로 다룰 수 있다(같은 곳) |

## 5. 유지보수

| 항목 | FUF 판 | PitBull4 판 |
|---|---|---|
| 새 판이 나오면 | 원본 ZIP 을 바꾸면 끝(우리 수정 없음) | v4.2.50 이후 판마다 Forever 고침 72개 파일을 다시 옮겨야 한다. 패치를 다시 대 보는 시험이 있다(`Collection/tests/pitbull4/run.py` patch 항목) |
| 자동 업데이트 | 켜도 된다 | **꺼야 한다** — 켜면 Forever TOC 가 없는 원본으로 덮인다(발주문 phase6-rev.md 0번) |
| 외관 수단 | FUF 테마 12개 + 프로필 외관 키 | PitBull4 배치(layout)별 막대 질감·글꼴·테두리·초상화 + LibSharedMedia. Devil 테두리 질감 「Devil」 은 `!DevilUI` 미디어라 모음집에 없다(appearance-6-rev.md) |
| 다른 모음집 애드온과의 의존 | `DevilForever_Castbars`·`DevilForever_FUFDefaults` 가 FUF 에 의존 | 의존하는 우리 애드온 없음 |

## 6. 요약

- 같은 요구(체력·직업 자원·마나와 토템 강제 없음·Phase 9 와 겹치지 않는 파티/공격대)는 두 판 모두 원천상 맞는다. 다른 점: PitBull4 판은 Devil profile 을 따라 **치유 예측·거리 흐림·토템 아이콘·우두머리 프레임이 없다.**
- 흑마법사 영혼의 조각은 **두 판 모두 표시하지 않는다**(R61 빈 곳 후보).
- PitBull4 판은 AceDB 라 기본값 주입과 Phase 20 복원이 쉽고 특성별 설정 묶음이 있지만, 우리가 고친 판이라 새 판마다 다시 옮겨야 하고 자동 업데이트를 꺼야 한다. FUF 판은 원본 그대로라 유지보수 부담이 없다.
- 게임 안 로드·오류·전투 taint·디버프 표시는 둘 다 미검증이며 Codex 비교 결과로 정한다.

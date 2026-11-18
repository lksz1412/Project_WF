# Forever 직업·특성·자원 표 (Step 10)

기계용 같은 내용: `Collection/data/classes.json`. 이 표는 애드온 제작자가 코드에 넣은 자료로 만든 것이고 게임 공식 목록이 아니다. **실제 Forever 직업 목록과 맞는지는 Codex 가 Phase 1 발주문(`Collection/codex-briefs/phase1.md` 4번)으로 확인한다.** 근거가 없는 칸은 「원천 없음」 으로 둔다. Retail 지식으로 채운 칸은 없다.

경로 줄임: `H/` = `Collection/upstream/Hekili-v0.8.6/`, `F/` = `Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/`, `D/` = `Collection/upstream/Dominos-12.0.4/Dominos/`.

## 직업 수: 9

| 근거 | 위치 | 내용 |
|---|---|---|
| Hekili 직업 모듈 폴더 | `Collection/manifest.md:125–134` | Hekili_Druid·Hunter·Mage·Paladin·Priest·Rogue·Shaman·Warlock·Warrior (Hekili_Shared 는 공용 모듈) |
| FUF 공격대 버프 자료의 직업 목록 | `F/Raid/BuffData.lua:68` | `Data.CLASSES = { "WARRIOR", "PALADIN", "PRIEST", "SHAMAN", "DRUID", "ROGUE", "MAGE", "WARLOCK", "HUNTER" }` |
| FUF 정렬 순서 기본값 | `F/Raid/Settings.lua:30–31` | 같은 9개 |

세 근거가 같은 9개를 가리킨다(확정: 세 파일의 내용이 서로 같다는 것까지). 이것이 Forever 의 전체 직업이라는 것은 추정이다 — 세 곳 모두 애드온 제작자의 자료다. Hekili 핵심 코드에 `DEATHKNIGHT` 분기가 있지만(`H/Hekili/Engine/Sim/Core.lua:1598,1818`) 그 직업 모듈은 묶음에 없다.

## 특성의 뜻

Hekili 는 특성 하나를 특성 나무(talent tree) 하나로 본다(`H/Hekili/Engine/Schema/Spec/Kits.lua:108–116`). 「지원 안 함」 표시가 붙은 특성은 Hekili 가 추천을 내지 않고 표시창도 끈다(같은 파일 141행 `if d.unsupported then s.options.enabled = false end`). FUF 원천에는 특성 목록이 없다(원천 없음).

## 직업별 표

| 직업 (token) | 특성 (Hekili key · 나무 · 역할) | Hekili 추천 | 주 자원 | 보조 자원·형태별 자원 | 특수 바 | 근거 |
|---|---|---|---|---|---|---|
| WARRIOR | arms · 1 · attack / fury · 2 · attack / protection · 3 · tank | 셋 다 있음 | Rage (`H/Hekili_Warrior/Warrior.lua:290–291`) | 없음 | 태세 3개: battle·berserker·defensive (`Warrior.lua:569,579,633`, 태세 바꾸기 849–852) → Dominos 태세 바 (`D/Dominos.toc:46`) | `Warrior.lua:39–52` |
| PALADIN | holy · 1 · healer / protection · 2 · tank / retribution · 3 · attack | holy 없음 | Mana (`H/Hekili_Paladin/Paladin.lua:258`) | 없음 | 오라 6개, 한 번에 하나 (`Paladin.lua:386,429–436`). 태세 바에 오라가 뜨는지는 원천 없음 | `Paladin.lua:37–58` |
| HUNTER | beast_mastery · 1 · attack / marksmanship · 2 · attack / survival · 3 · attack | 셋 다 있음 | Mana — 모듈 머리말에 「Forever 사냥꾼은 마나를 쓰고 focus 는 쓰지 않는다」 (`H/Hekili_Hunter/Hunter.lua:3–4`, 등록 328–329) | 소환수 자원: 원천 없음 (FUF 에 focus 색 설정은 있으나 직업과 묶이지 않음 `F/Elements/Power.lua:16`) | 소환수 (`Hunter.lua:365–371`), 매 소환 2마리 18초 (`Hunter.lua:360–362`), 소환수 만족도 아이콘 (`F/Elements/PetHappiness.lua:3–9,50–54`) → Dominos 소환수 바 (`D/Dominos.toc:43`). 상(aspect)이 태세 바에 뜨는지는 원천 없음 | `Hunter.lua:38–77` |
| ROGUE | assassination · 1 / combat · 2 / subtlety · 3 (모두 attack) | 셋 다 있음 | Energy (`H/Hekili_Rogue/Rogue.lua:156–157`) | ComboPoints (`Rogue.lua:148`) — FUF 는 대상 프레임에 점으로 그린다 (`F/Elements/ComboPoints.lua:3–5,19–23`) | 은신 (`Rogue.lua:309–316`, 읽는 방식 `H/Hekili/Game/State/Sources/Forms.lua:8–10`). 태세 바에 뜨는지는 원천 없음 | `Rogue.lua:34–61` |
| PRIEST | discipline · 1 · attack (추천 묶음 이름 Smite) / holy · 2 · healer / shadow · 3 · attack | holy 없음 | Mana (`H/Hekili_Priest/Priest.lua:234–235`) | 없음 | 어둠의 형상(shadowform)을 형태로 다룸 (`Priest.lua:5`, 비용 감소 286–291) | `Priest.lua:45–67` |
| SHAMAN | elemental · 1 · attack / enhancement · 2 · attack / restoration · 3 · healer | restoration 없음 | Mana (`H/Hekili_Shaman/Shaman.lua:496–497`) | 없음 | 토템 4칸 (`Shaman.lua:534–537`; FUF 토템 아이콘 `F/Elements/Totems.lua:56–64,114`) → Dominos 토템 바, camelot 에서 로드 (`D/Dominos.toc:48–52`, `D/core/addressMap.lua:173`) | `Shaman.lua:48–69` |
| MAGE | arcane · 1 / fire · 2 / frost · 3 (모두 attack) | 셋 다 있음 | Mana (`H/Hekili_Mage/Mage.lua:239–240`) | 없음 | 찾지 못함 | `Mage.lua:40–70` |
| WARLOCK | affliction · 1 / demonology · 2 / destruction · 3 (모두 attack) | 셋 다 있음 | Mana (`H/Hekili_Warlock/Warlock.lua:241–242`) | 영혼의 조각 — 자원 막대가 아니라 아이템 개수(아이템 6265) (`Warlock.lua:142,279–280`) | 악마 5종: imp·voidwalker·succubus·incubus·felhunter (`Warlock.lua:308–314`) → Dominos 소환수 바 (`D/Dominos.toc:43`) | `Warlock.lua:55–87` |
| DRUID | balance · 1 · attack / feral · 2 · attack / guardian · 2 · tank / restoration · 3 · healer | restoration 없음 | Mana (사람 형태) (`H/Hekili_Druid/Druid.lua:322–323`) | 표범: Energy (`Druid.lua:238–243`)·ComboPoints (244) / 곰: Rage (246–247) / 변신 중 마나 띠 (`F/Elements/DruidMana.lua:3–8,56–69`) | 형태 5개: cat·bear·moonkin·travel·aquatic (`Druid.lua:84–87,168–169`) → Dominos 태세 바 (`D/Dominos.toc:46`) | `Druid.lua:34–65`. feral 과 guardian 은 같은 야성 나무를 쓰고, 「두꺼운 가죽 3/3」 이면 guardian 으로 본다 (`Druid.lua:31–33`) |

## 합계

- 특성 28개: 전사·성기사·사냥꾼·도적·사제·주술사·마법사·흑마법사 각 3개, 드루이드 4개(guardian 이 따로 있음).
- Hekili 가 추천을 내지 않는 특성 4개: PALADIN holy, PRIEST holy, SHAMAN restoration, DRUID restoration. 모두 치유 역할이다. Phase 8 은 이 특성들의 상태 알림·CD 표시를 Hekili 밖에서 채워야 할 수 있다(Phase 8 갈래 2·3 판정 대상).

## 원천 없음 목록

| 칸 | 이유 |
|---|---|
| FUF 의 특성 자료 | FUF 는 직업별 요소(콤보 점·토템·드루이드 마나·소환수 만족도)만 갖고 특성 목록은 없다 |
| 사냥꾼 소환수의 자원 | Hekili 사냥꾼 모듈이 소환수를 모델로 다루지 않는다고 적었다(`Hunter.lua:14` 「the pet and its abilities (D6)」 미구현 목록) |
| 성기사 오라·사냥꾼 상·도적 은신이 태세 바에 뜨는지 | 받은 원천 어디에도 Forever 의 태세 바 구성이 적혀 있지 않다. Phase 3(Dominos) 의 Codex 실사용 검증에서 본다 |
| 한국어 직업·특성 이름 | 게임 클라이언트가 주는 이름을 쓴다. 원천에는 영어 키만 있다 |

# Hekili 직업 전투보조 지원표 (Step 18)

기계용 같은 내용: `Collection/data/hekili-support.json`. 행은 `Collection/data/classes.md` 의 특성 28개 전부다. 모든 칸은 원천 줄을 달았고, 원천이 없는 칸은 「원천 없음」 으로 둔다. Retail 지식으로 채운 칸은 없다. 이 표는 애드온 원천을 읽어 만든 것이고 게임 안에서 확인한 것이 아니다(게임 안 확인은 Step 20·Codex 몫).

경로 줄임: `H/` = `Collection/upstream/Hekili-v0.8.6/`. `<직업>.lua` = `H/Hekili_<직업>/<직업>.lua`.

판정 등급: **확정** = 줄을 읽고 그대로 옮김 · **추정** = 읽은 줄에서 이끌어 낸 판단 · **미검증** = 원천은 그렇게 말하나 게임 안에서 확인 안 됨 · **원천 없음** = 받은 원천에서 찾지 못함.

---

## 1. Hekili 가 화면에 보이는 것 (모든 특성 공통 근거)

Hekili 의 오라·CD 자료는 특성이 아니라 **직업 kit 하나**에 등록된다. 특성은 kit 를 `__index` 로 물려받는다(`H/Hekili/Engine/Schema/Spec/Kits.lua:117–151`, 특히 127–140 `setmetatable( {...}, { __index = kit } )`). 그래서 아래 ㉠ 칸의 「이 특성 키」 는 직업 kit 자료 가운데 그 특성 나무의 talent 키와 이름이 같은 것(기계 대조) + 원천 주석이 그 특성 것이라고 적은 것이다.

| 코드 | 내용 | 근거 | 등급 |
|---|---|---|---|
| C1 | 표시창 5개(Primary·AOE·Cooldowns·Defensives·Interrupts)는 모두 **추천 대기열**이다. 화면 위쪽 가운데(`relativeTo = "SCREEN"`, `displayPoint = "TOP"`, y −170~−280)에 아이콘으로 뜬다 | `H/Hekili/Options/Options.lua:414–506` | 확정 |
| C2 | Cooldowns·Defensives·Interrupts 표시창은 그 토글에 묶인 능력의 **추천**만 보인다(CD 타이머 목록이 아니다) | `H/Hekili/Engine/Sim/State.lua:6541–6543, 7226–7229` | 확정 |
| C3 | 알림 글 창(`HekiliNotification`)은 일시정지·모드·토글 켜고 끔·팩 초기화·표시 style 등록 오류만 띄운다. 오라·proc·CD 상태 글은 없다 | `Options.lua:400–404`(기본값), `8861, 8870–8878, 8938, 8971, 9003`, `H/Hekili/Options/ChatCommands.lua:254–255`, `H/Hekili/UI/Styles.lua:47, 51` | 확정 |
| C4 | 표시창 아이콘 빛남: **추천된 능력**의 주문이 activation overlay 상태(`C_SpellActivationOverlay.IsSpellOverlayed`)일 때만 빛난다. 기본값 켜짐·autocast 모양 | `H/Hekili/UI/Resolve.lua:124`, `H/Hekili/UI/Styles/Classic.lua:689–714, 736–760`, `Options.lua:432–437` | 확정 |
| C5 | 단축바 버튼 강조: 표시창의 첫 추천(과 둘째) 능력이 놓인 실제 단축바 버튼을 LibCustomGlow 로 빛낸다(Dominos 포함) | `H/Hekili/UI/BarGlow.lua:1–11` | 확정 |
| C6 | Truth 층(표시창 Modern 토글): **추천 버튼 위**에 게임의 실제 cooldown swipe·proc mark 를 그린다. 검증 전 overlay 4개는 코드에서 꺼 둠 | `H/Hekili/UI/Truth.lua:1–9, 26, 57` | 확정(코드) · 미검증(게임) |
| C7 | 소리 없음: Hekili 핵심·직업 모듈 `.lua`(Libs 제외)에 `PlaySound` 0건. SpellFlash 는 zhCN 번역 문자열만 있고 쓰는 코드가 없다(색 getter 한 줄뿐) | grep 결과(작업 기록), `H/Hekili/Locales/zhCN.lua:1036–1067`, `Options.lua:8173` | 확정 |
| C8 | 「지원 안 함」 특성: 표시창이 꺼지고(`options.enabled = false`), 우선순위 목록이 없으며, 설정 쪽은 그 이유만 보인다 | `Kits.lua:114–115, 141`, `Options.lua:4496`, `H/Hekili/Engine/Schema/Spec/Activation.lua:386` | 확정 |
| C9 | 오라 자료 꼴: `RegisterAura(key, data)` — `id`·`duration`·`max_stack`·`copy`(다른 순위 ID)·`overlay`(proc 를 주문 빛남으로 읽음)·`family` 를 `kit.auras[key]` 에 둔다 | `H/Hekili/Engine/Schema/Spec/Auras.lua:16–30, 90, 150, 160–168` | 확정 |
| C10 | 능력 자료 꼴: `RegisterAbility(key, data)` — `id`·`cooldown`(숫자 또는 함수)·`toggle`(cooldowns·defensives·interrupts)·`form` 을 `kit.abilities[key]` 에 둔다. 함수 값 칸은 읽으면 Hekili state 안에서 실행된다 | `H/Hekili/Engine/Schema/Spec/Abilities.lua:88–90, 104–115, 151–180, 390–403` | 확정 |
| C11 | 이 자료의 목적은 추천 시뮬레이션과 belief(전투 중 상태 모델)이고, 특성별 「무엇을 보여 줄지」 목록은 원천에 없다. 우선순위가 읽지 않는데도 Cooldown Manager 대응·사용자 우선순위용으로 등록한 항목이 있다(「no priority reads them, the Cooldown Manager follows their presence」 · 「no priority casts them; registered for the displays and custom priorities」) | `Paladin.lua:412–413`, `Priest.lua:384`, `Warlock.lua:365` | 확정(주석) · 「목록 없음」 = 원천 없음 |

---

## 2. 지원표 (특성 28개)

열: **지원** = Hekili 가 그 특성에 우선순위를 내는가 · **㉠** = 오라·proc·CD 감시 자료가 있는가(자료 위치 · 이 특성 키 = `키 오라줄/능력줄 cd초`) · **상태 알림** = Hekili 가 오라 상태를 알리는 꼴 · **proc** · **CD** · **추천** = 다음 행동 추천.

공통 칸 약속: 지원 특성의 상태 알림 = 「없음(C1·C3)」, proc = 「추천 아이콘에 한해 빛남(C4·C5·C6)」, CD = 「추천에 한해(C2·C6)」. 지원 안 함 특성은 셋 다 「없음(C8)」.

### WARRIOR — kit `Warrior.lua`: 오라 562–845 · 능력 1008–2124 · talent 503–560 · 우선순위 2227–2241

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| arms (나무 1) | 예 `Warrior.lua:41` | 있음. 나무 1 키: mortal_strike 722/1606 cd6 · sweeping_strikes 810/2011 cd30(cooldowns) · bloodthrill 738(proc, Overpower 창 730 을 엶) · spearing_strike 능력 1966 cd20. 공용: overpower_ready 730, recklessness 753/1743 cd1800, battle_stance 569. talent 510–521 | 없음(C1·C3) | 추천 한정(C4·C5·C6) | 추천 한정(C2·C6) | 있음 `Warrior.lua:2237` | overpower_ready 는 전투 중 보이지 않는다고 적힘(730 주석) — 미검증 |
| fury (나무 2) | 예 `:42` | 있음. 나무 2 키: enrage 650 · flurry 663 · blood_craze 584 · death_wish 622/1292 cd180(cooldowns) · reckless_swings 748/1717 cd15 · gore_drinker 670 · bloodthirst 능력 1150 cd6. 공용: berserker_stance 579, berserker_rage 574/1060 cd30. talent 528–540 | 없음 | 추천 한정 | 추천 한정 | 있음 `:2232` | — |
| protection (나무 3) | 예 `:43–50` | 있음. 나무 3 키: last_stand 710/1560 cd180(defensives) · concussion_blow 616/1267 cd45 · shield_slam 능력 1894 cd6. 공용: shield_block 793/1871, shield_wall 799/1912(defensives), revenge_usable 773, defensive_stance 633. talent 548–559 | 없음 | 추천 한정 | 추천 한정 | 있음 `:2227` | — |

### PALADIN — kit `Paladin.lua`: 오라 344–475 · 능력 679–1277 · talent 277–332 · 우선순위 1319–1333

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| holy (나무 1) | **아니오** `Paladin.lua:39` `unsupported = true` | 있음. 원천이 「Holy 전용 오라(B8, Holy is unsupported)」 라고 적음(431). 나무 1 키: divine_favor 387 · infusion_of_light 443 · lights_vigil 444/1211 cd6 · oath_of_light 446/1232 · holy_shock 능력 831(cd 함수, cooldowns). 치유: holy_light 921, flash_of_light 938, lay_on_hands 956 cd1200. talent 279–295 | 없음(C8) | 없음(C8) | 없음(C8) | 없음(C8) — 만들지 않음(R62) | Hekili 표시가 꺼져 있어 화면에는 아무것도 안 뜬다 |
| protection (나무 2) | 예 `:40–47` | 있음. 나무 2 키: holy_shield 378/865 cd10 · redoubt 416(proc) · reckoning 423(proc) · templars_bulwark 409/892(cooldowns) · iron_creed 426 · swift_judgement 능력 718 cd60. 공용: righteous_fury 385, shieldsworn_block 427, forbearance 410. talent 297–313 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1324` | 원천: 「Own procs (B3; no priority reads them, the Cooldown Manager follows their presence)」(412) |
| retribution (나무 3) | 예 `:48–56` | 있음. 나무 3 키: seal_of_command 350 · vengeance 414(proc) · vindication 406 · repentance 466/1160 cd60. 공용: 봉인 7개 350–376(한 번에 하나, family), Echo 368–373, judgement 689, consecration 437/785 cd8. talent 315–331 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1319`, Holy Shock 빌드는 `:1329`(selector 1308–1314) | — |

### HUNTER — kit `Hunter.lua`: 오라 382–463 · 능력 590–1242 · talent 1249–1303 · 우선순위 1323–1357

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| beast_mastery (나무 1) | 예 `Hunter.lua:40–51` | 있음. 나무 1 키: bestial_wrath 386/665 cd120(cooldowns) · frenzy 435 · intimidation 430/1023 cd60 · summon_hawk 능력 731 cd6. 공용: rapid_fire 387/643(cooldowns), quick_shots 401(proc). talent 1251–1266 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1338`(기본 Turret), `:1323` | 소환수와 그 능력은 모델에 없다(`Hunter.lua:14` D6). quick_shots 는 「nothing applies it … unprobed」(13–14) |
| marksmanship (나무 2) | 예 `:52–63` | 있음. 나무 2 키: rapid_killing 411(proc) · sniper_shot 412/791 cd15 · rapid_recuperation 406 · trueshot_aura 436/1164 · scatter_shot 431/1009 cd30. 공용: aimed_shot 749 cd6, multi_shot 771 cd6. talent 1268–1283 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1343`, `:1328` | — |
| survival (나무 3) | 예 `:64–75` | 있음. 나무 3 키: resourcefulness 405 · expose_prey 413 · lacerating_strikes 415 · strider_kick 414/864 cd8 · deterrence 432/1052 · counterattack 능력 1037 cd5. 공용: defensive_state 442(Mongoose Bite 창), mongoose_bite 841 cd5. talent 1285–1302 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1348`, `:1333`, `:1353` | — |

### ROGUE — kit `Rogue.lua`: 오라 224–362 · 능력 503–1107, 1123–1349, 1352–1355 · talent 164–222 · 우선순위 1364–1378

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| assassination (나무 1) | 예 `Rogue.lua:36–43` | 있음. 나무 1 키: cold_blood 254/608 cd180(cooldowns) · venom 357 · mutilate 능력 833. 원천 주석상 이 나무 것: remorseless 239(talent remorseless_attacks 167). 공용: slice_and_dice 303, rupture 296, 독 227–231. talent 166–182 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1369` | — |
| combat (나무 2) | 예 `:44–51` | 있음. 나무 2 키: adrenaline_rush 232/504 cd300(cooldowns) · blade_flurry 248/584 cd120(cooldowns) · riposte 능력 806 cd6. talent 184–202 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1364` | — |
| subtlety (나무 3) | 예 `:52–59` | 있음. 나무 3 키: ghostly_strike 279/723 cd20 · death_mark 260/1079 cd10 · hemorrhage 291/753 · premeditation 능력 861 cd120 · preparation 능력 878 cd600. 공용: ghostly_strike_next 286, stealth 310, vanish 317/1015. talent 204–221 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1374` | — |

### PRIEST — kit `Priest.lua`: 오라 368–434 · 능력 436–863, 930–992 · talent 1000–1056 · 우선순위 1071–1080

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| discipline (나무 1) | 예 `Priest.lua:47–55` | 있음. 나무 1 키: inner_focus 374/799 cd180(cooldowns) · divine_aegis 413 · penance 432/706 cd12 · power_infusion 능력 820 cd180. 공용: power_word_shield 375/748(defensives), weakened_soul 376. talent 1002–1019 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1076`(Smite) | 우선순위 이름이 Smite 다(54) |
| holy (나무 2) | **아니오** `:56` | 있음. 나무 2 키: prayer_of_mending 392(CDM 연결 주석 390–391)/948 cd10 · inspiration 407 · spirit_of_redemption 408 · blessed_recovery 406 · holy_nova 능력 731. 원천 주석상 이 나무 proc: holy_purpose 414(Searing Light, 머리말 20). 치유 능력 utility 933–947, lightwell 991 cd600. talent 1021–1037 | 없음(C8) | 없음(C8) | 없음(C8) | 없음(C8) — 만들지 않음(R62) | — |
| shadow (나무 3) | 예 `:57–65` | 있음. 나무 3 키: shadowform 371/575 · spirit_tap 382(proc) · dark_inspiration 383(proc) · shadow_weaving 427 · vampiric_embrace 426/557 cd30 · blackout 409 · mind_flay 430/490. 공용: devouring_plague 424/518 cd24, shadow_word_death 542 cd18, mind_blast 456. talent 1039–1055 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1071` | proc 굴림은 보이지 않고 aura walk 가 plain 일 때만 읽는다(머리말 20–21) |

### SHAMAN — kit `Shaman.lua`: 오라 548–694 · 능력 707–1144 · talent 1152–1206 · 우선순위 1279–1288 (R7: 직업 점검을 여기부터)

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| elemental (나무 1) | 예 `Shaman.lua:50–58` | 있음. 머리말이 Elemental kit 를 따로 적음(18–25). 나무 1 키: elemental_devastation 582 · earthbound 689. ID 대조: elemental_mastery 오라 567/능력 813 cd180(cooldowns) = talent_16166(1169). 원천 주석상: clearcasting 667(Elemental Focus, talent 1160), revelation 569, water_shield 559(머리말 21), chain_lightning 769, flame_shock 671. talent 1154–1169 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1279` | — |
| enhancement (나무 2) | 예 `:59–66` | 있음. 나무 2 키: maelstrom_weapon 571(5중첩 proc) · flurry 581 · improved_stormstrike 588 · stormstrike 684/862 cd6 · rage_of_the_farseer 693/1122 cd180(cooldowns). 공용: lightning_shield 550(3충전), 무기 imbue 574–577, windfury_attack 583. talent 1171–1188 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1284` | Flametongue·Windfury 무기 proc 은 모델에 없음(머리말 11–12) |
| restoration (나무 3) | **아니오** `:67` | 있음. 나무 3 키: water_shield 559/849 · natures_swiftness 586/794 cd180(cooldowns) · riptide 687/1000 cd12. 공용: mana_tide 617, healing_stream 623, ancestral_fortitude 690. 치유 능력: healing_wave 921, lesser_healing_wave 949, chain_heal 974. talent 1190–1205 | 없음(C8) | 없음(C8) | 없음(C8) | 없음(C8) — 만들지 않음(R62) | 토템 4칸 자료는 `RegisterTotems` 537 |

### MAGE — kit `Mage.lua`: 오라 284–309, 698–706, 895–919 · 능력 377–690, 753–886, 984–1289 · talent 1305–1362 · 우선순위 1375–1394

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| arcane (나무 1) | 예 `Mage.lua:42–50` | 있음. 나무 1 키: arcane_blast 287/380(4충전) · missile_barrage 290(proc) · arcane_power 295/637 cd180(cooldowns) · presence_of_mind 296/655 cd180(cooldowns) · arcane_wrath 능력 427 cd6. 공용: clearcasting 294(proc), evocation 300/595 cd480. talent 1307–1324 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1375` | proc 굴림은 보이지 않음(머리말 22–23) |
| fire (나무 2) | 예 `:51–59` | 있음. 나무 2 키: heating_up 291(proc) · combustion 299/673 cd180(cooldowns) · blast_wave 897/1026 cd45 · ignite 913 · pyroblast 능력 522. 공용: fire_vulnerability 308. talent 1326–1342 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1380`, Frostfire `:1385` | — |
| frost (나무 3) | 예 `:60–68` | 있음. 나무 3 키: fingers_of_frost 293(proc) · ice_barrier 703/797 cd30 · ice_block 705/869 cd300(defensives) · frostbite 914 · cold_snap 능력 816 cd600(cooldowns) · ice_lance 능력 775 cd8. 공용: winters_chill 700, frigid_power 704. talent 1344–1361 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1390` | — |

### WARLOCK — kit `Warlock.lua`: 오라 320–387, 393–405 · 능력 593–1081, 1126–1407 · talent 1425–1481 · 우선순위 1525–1549

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| affliction (나무 1) | 예 `Warlock.lua:57–65` | 있음. 나무 1 키: amplify_curse 351/1037 cd180(cooldowns) · siphon_life 334/783 · wrack 335/838 · soul_harvest 363 · curse_of_exhaustion 401/1373. 원천 주석상: shadow_trance 349(Nightfall proc, talent 1438, `overlay = 686`). 공용: corruption 322, bane_of_agony 329. talent 1427–1443 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1525` | proc 이 `overlay` 를 가진 몇 안 되는 예(349–350) |
| demonology (나무 2) | 예 `:66–75` | 있음. 나무 2 키: decimation 350(proc, `overlay = 6353`) · demonic_brand 338 · fel_domination 365/1394 cd300(cooldowns) · soul_link 366 · master_demonologist 368 · demonic_sacrifice 381/1062(효과 377–380). talent 1445–1463 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1530`, Shadow Brand `:1545` | 악마 주문은 모델에 없음(머리말 34) |
| destruction (나무 3) | 예 `:76–85` | 있음. 나무 3 키: bane_of_havoc 344/705 · aftermath 399 · conflagrate 능력 911 cd10 · shadowburn 능력 935 cd15 · incinerate 974. 원천 주석상: shadow_and_flame 360–361(talent 1479), shadow_vulnerability 340(Improved Shadow Bolt 1466). 공용: immolate 328, revelation 357. talent 1465–1480 | 없음 | 추천 한정 | 추천 한정 | 있음 `:1535`, SM Ruin `:1540` | — |

### DRUID — kit `Druid.lua`: 오라 434–745 · 능력 851–2273 · talent 361–417 · 우선순위 2330–2344

| 특성 | 지원 | ㉠ 감시 자료 | 상태 알림 | proc | CD | 추천 | 비고 |
|---|---|---|---|---|---|---|---|
| balance (나무 1) | 예 `Druid.lua:36–44` | 있음. 나무 1 키: eclipse 543(4중첩) · natures_grace 660(proc) · insect_swarm 617/1440 · moonkin_form 654/1579. 공용: moonfire 644, clearcasting 516(Omen of Clarity proc), natures_swiftness 667/1607 cd180(나무 3 talent). talent 363–378 | 없음 | 추천 한정 | 추천 한정 | 있음 `:2335` | — |
| feral (나무 2) | 예 `:45–53` | 있음. 나무 2 키: primal_bite 1681 · shifting_power 1858 · feral_charge 1208 cd15. `form = "cat_form"` 능력(C10): claw 1039, rake 1728(오라 702), rip 1827(709), shred 1887, ferocious_bite 1237, prowl 1704(695), dash 1077 cd300, feral_charge_cat 2216 cd30. 공용: berserk 465/959 cd180(cooldowns), clearcasting 516, poised 526. talent 380–399 | 없음 | 추천 한정 | 추천 한정 | 있음 `:2330` | — |
| guardian (나무 2) | 예 `:54–62` | 있음. feral 과 같은 나무라 talent 키로는 못 가른다. `form = "bear_form"` 능력(C10)으로 가른다: enrage 1123 cd60(오라 558) · frenzied_regeneration 1276 cd180(defensives, 오라 590) · lacerate 1467(630) · maul 1521(638) · bash 900(449) · demoralizing_roar 1097(537) · growl 1321 cd8 · challenging_roar 1016 cd600 · swipe_bear 1954. 공용: barkskin 444/881 cd60(defensives), bear_form 458. 선택 기준 thick_hide talent 385 | 없음 | 추천 한정 | 추천 한정 | 있음 `:2340` | feral·guardian 은 「두꺼운 가죽 3/3」 으로 가린다(31–33) |
| restoration (나무 3) | **아니오** `:63` | 있음. 나무 3 키: natures_swiftness 667/1607 cd180 · wild_growth 730/2040 cd6 · swiftmend 능력 2026 cd15. 공용: tranquility 731/2059, innervate 611/1401 cd360(cooldowns), rebirth 2079 cd1800, regrowth 능력 1783, rejuvenation 능력 1810, clearcasting 516. talent 401–416 | 없음(C8) | 없음(C8) | 없음(C8) | 없음(C8) — 만들지 않음(R62) | rejuvenation·regrowth 의 대상 HoT 오라 키는 원천 없음(오라 블록 434–745 에 없음) |

### 합계

- 지원 24 · 지원 안 함 4(PALADIN holy, PRIEST holy, SHAMAN restoration, DRUID restoration). 확정(각 행의 `unsupported` 줄과 C8).
- ㉠ 감시 자료: 28개 모두 **있음**(직업 kit 단위). 확정(각 행 줄). 지원 안 함 4개도 kit 에 그 나무 자료가 있다.
- ㉡ EventAlert 식 상태 알림: 28개 모두 **없음**(3장).

---

## 3. ㉡ Hekili 가 EventAlert 식 알림(화면 중앙 아이콘·소리·강조)을 보이는가

**판정: 없음.** 확정(코드) — 아래 셋이 모두 「추천」 에만 걸려 있고 오라·proc·CD 상태를 따로 알리는 길이 없다.

| R6 의 꼴 | Hekili 에 있는 것 | 상태 알림인가 | 근거 |
|---|---|---|---|
| 화면 중앙 아이콘 | 표시창 5개가 화면 위쪽 가운데에 아이콘으로 뜬다 | 아니다 — 추천 대기열이다. proc 이 떠도 그 능력이 추천되지 않으면 아이콘이 없다 | C1·C2 |
| 소리 | 없음 | — | C7 |
| 강조(빛남) | 표시창 아이콘 빛남, 단축바 버튼 빛남, Truth 층 proc mark | 아니다 — 모두 추천된 능력에만 걸린다(`r.glow = rec.actionID > 0 and IsSpellOverlayed( rec.actionID )`, `Resolve.lua:124`) | C4·C5·C6 |
| 알림 글 | `HekiliNotification` | 아니다 — 토글·모드 글뿐 | C3 |

참고(추정): Forever 클라이언트에는 Blizzard 의 Cooldown Manager 창 넷(`EssentialCooldownViewer`·`UtilityCooldownViewer`·`BuffIconCooldownViewer`·`BuffBarCooldownViewer`)이 있고 Hekili 는 그 창을 읽기만 한다(`H/Hekili/Game/State/Sources/Presence/CooldownViewer.lua:1–21, 29–30`). 이것은 Hekili 의 기능이 아니라 클라이언트 기능이고, 우리 묶음이 쓸지는 결정 대기 1.

---

## 4. 갈래 판정

마스터 플랜 갈래(마스터 플랜 215행): 갈래 1 = ㉠·㉡ 모두 있음 → Hekili 설정만 · 갈래 2 = ㉡ 없음 → 보완 모듈이 전 특성의 알림 꼴(각각 끌 수 있게) · 갈래 3 = ㉠ 없음 → 보완 모듈이 그 특성의 정적 표시 목록을 가짐.

| 특성 | 갈래 | 정적 표시 목록의 원천 | 등급 |
|---|---|---|---|
| 지원 24개(WARRIOR 3, PALADIN protection·retribution, HUNTER 3, ROGUE 3, PRIEST discipline·shadow, SHAMAN elemental·enhancement, MAGE 3, WARLOCK 3, DRUID balance·feral·guardian) | **2** | ① Hekili 직업 모듈 자료(2장 ㉠ 칸) | ㉡ 없음 = 확정 · 원천 ① 로 충분 = 추정 |
| 지원 안 함 4개(PALADIN holy, PRIEST holy, SHAMAN restoration, DRUID restoration) | **2** | ① Hekili 직업 모듈 자료(그 나무 키가 kit 에 있음) | ㉠ 있음 = 확정 · Hekili 가 그 특성에서 런타임 자료를 채우는지 = 미검증(5장 주의 3) |
| 갈래 3 에 드는 특성 | **없음** | ② Codex 자료·③ 원천 없음 으로 갈 특성 없음 | 확정(28행 모두 ㉠ 있음) |

**전체 판정(A1 판단):** 갈래 2. 보완 모듈 `DevilForever_Combat` 은 28개 특성 모두의 알림 꼴(화면 중앙 아이콘·소리·강조, 각각 끔 가능)을 맡는다. 무엇을 보일지(정적 표시 목록)는 특성마다 Hekili 직업 모듈 자료에서 고른다(원천 ①). 갈래 3 이 아니라서 D7 Codex 자료(②)는 「있는지」 를 위해서는 필요 없다. 다만 Hekili 자료 일부는 원천 스스로 「in-game check」 를 달았으므로 ID·지속 시간의 게임 안 확인은 Step 20 몫이다(결정 대기 3).

추천(다음 행동)은 Hekili 의 것만 쓴다. 지원 안 함 4개는 추천이 없고, 보완 모듈이 만들지 않는다(R62 경계: 금지는 추천·판단·회전 로직뿐, 정적 표시 목록은 표시 설정 데이터).

**목록을 고르는 기계 규칙(추정, Step 19 설계 입력):**

1. 그 특성 나무의 talent 키와 같은 이름의 오라·능력 → 그 특성(2장 「나무 n 키」, `RegisterTalents` 의 `{ tree, spell, max rank }` — `Spec.lua:112–125`, 꼴 `Kits.lua:108–109`).
2. 같은 나무를 쓰는 DRUID feral·guardian 은 능력의 `form`(cat_form / bear_form)으로 가른다(`Abilities.lua:88–90`, `Druid.lua` 각 능력).
3. talent 키와 이름이 다른 것(예: SHAMAN `talent_16166` ↔ elemental_mastery, 같은 ID 16166)은 ID 대조나 원천 주석으로 붙인다 — 손 판정이 들어가므로 사용자 추가·삭제 칸을 둔다(사용자가 고친 항목이 늘 우선).
4. 직업 공용(talent 없는 기본 능력·오라)은 모든 특성에 넣을지 사용자가 고르게 둔다(기본값은 결정 대기 2).

---

## 5. 보완 모듈이 Hekili 자료를 런타임에 읽는 길 (추천 엔진은 건드리지 않음)

| 무엇 | 공개 이름 | 근거 | 등급 |
|---|---|---|---|
| Hekili 전역 | `Hekili`(AceAddon, `local` 아님) | `H/Hekili/Hekili.lua:15` | 확정 |
| 직업 kit | `Hekili.Class.kit` — `.auras[key]`, `.abilities[key]`, `.talents[key]` = `{ tree, spell, max rank }`, `.trees[slot]`, `.specs[key]`(각 `.key`·`.tree`·`.role`·`.unsupported`) | `Hekili.lua:89–141`(91), `Kits.lua:122–149`, `Spec.lua:112–125` | 확정 |
| 오라 한 항목 | `id`·`duration`·`max_stack`·`copy`·`overlay` 같은 숫자 칸을 `rawget` 으로 읽는다 | C9 | 확정 |
| 능력 한 항목 | `id`·`toggle`·`form`·숫자 `cooldown` 은 `rawget`. 함수 칸(`cooldown` 함수 등)은 읽지 않는다 — `__index` 가 Hekili state 안에서 실행한다 | C10(`Abilities.lua:104–115, 170–180`) | 확정(코드) · 「읽지 말 것」 = A1 판단 |
| 지금 특성 | `Hekili.State.spec.key`·`.id`·`.kitID` | `Activation.lua:113–118` | 확정(코드) · 지원 안 함 특성에서도 채워지는지 = 미검증 |
| 지금 특성의 오라 표 | `Hekili.Class.auras`(특성 바꿈마다 비우고 다시 채움) | `Activation.lua:95–111`, `Auras.lua:121–124` | 확정 |
| 전투 중 오라 상태 | `Hekili.Client.C_UnitAuras.GetPlayerAuraBySpellID(id)` — 게임 API 가 전투 중 secret 이라 Hekili 가 늘 자기 belief 로 답한다 | `Hekili.lua:151–154`, `H/Hekili/Game/API/Facade.lua:725–739`(「secret in combat; errors when tainted」), `H/Hekili/Game/State/Sources/Auras.lua:1–10` | 확정(코드) · 게임 안 = 미검증 |
| 전투 중 CD | `Hekili.Client.C_Spell.GetSpellCooldown(id)`·`GetSpellCharges(id)` — 시간이 secret 이면 belief 값으로 바꿔 준다 | `Facade.lua:1027–1035, 1051–1062`(「times secret in combat, flags plain」) | 확정(코드) · 미검증(게임) |
| CD 그림(swipe) | 게임 API `C_Spell.GetSpellCooldownDuration` + `Cooldown:SetCooldownFromDurationObject` — 값은 secret 이어도 위젯에 넘길 수 있다 | `Facade.lua:1391–1412`(Hekili 는 Truth.lua 에서만 씀) | 추정(보완 모듈이 직접 불러도 된다는 것) |
| proc | 게임 API `C_SpellActivationOverlay.IsSpellOverlayed(id)` 는 전투 중에도 plain. 오라의 `overlay` 칸이 그 주문 ID 를 준다(예: `Warlock.lua:349–350`) | `Facade.lua:1245`, `Sources/Auras.lua:7–8`, C9 | 확정(코드) · 미검증(게임) |

**건드리지 않는 것(경계, A1 판단):** `Hekili.Engine.Output`·`Engine.Subscribe`(추천 출력 — `H/Hekili/Engine/Output.lua:88, 236`), WeakAuras 이벤트 `HEKILI_RECOMMENDATION_UPDATE`(`H/Hekili/Integrations/WeakAuras.lua:1–4`), `Hekili:Query`·`Hekili:Run`(내부 `ns` 를 엶 — `Hekili.lua:174–196`), `Hekili:RegisterDisplayStyle`(추천 표시창의 그림 방식 — `Styles.lua:41–58`). 보완 모듈은 kit 자료(정적)와 `Hekili.Client`(상태 읽기)만 쓴다. Hekili 원천은 `Hekili.Client` 를 「The game client as an addon may read it」 이라 적고, 직업 모듈이 registration API·State·Class 와 함께 쓰는 공개 이름이라고 밝힌다(`Hekili.lua:151–154`). 다른 애드온이 써도 된다는 보증까지는 아니다(추정).

**주의:**
1. 전투 중 belief 값은 Hekili 의 모델값이다(관찰이 아니라 추정치일 수 있음 — `Facade.lua:1–14`). 표시용으로만 쓴다. 미검증.
2. Hekili 가 없으면 보완 모듈도 쓸 자료가 없다. 「전투보조」 는 Hekili 와 한 묶음(R44)이라 TOC 의존으로 둔다(추정).
3. 지원 안 함 특성에서 Hekili 가 belief 를 만드는지는 원천에서 확정하지 못했다(`Kits.lua:115` 「the engine idles」, `Tracked.lua:1–4` 「built from the active spec's registrations」). 그 특성에서 `Hekili.Client` 답이 비면 게임 API 를 직접 부르되 전투 중엔 secret 이다. 미검증 → 결정 대기 4.
4. 보완 모듈이 쓴 표시 목록이 Hekili 판 올림으로 키가 바뀌면 깨진다 — 목록은 키 대신 주문 ID 를 같이 저장하는 편이 낫다(A1 판단).

---

## 6. 원천 없음·미검증 목록

| 칸 | 등급 | 이유 |
|---|---|---|
| 특성별 「보여 줄 것」 목록(원천이 직접 준 것) | 원천 없음 | Hekili 자료는 kit 단위 시뮬레이션 자료다(C11). 특성 배정은 4장 기계 규칙(추정) |
| DRUID restoration 의 대상 HoT 오라(rejuvenation·regrowth) | 원천 없음 | 능력(`Druid.lua:1783, 1810`)만 있고 오라 키 없음 |
| HUNTER 소환수 오라·능력 | 원천 없음 | 「the pet and its abilities (D6)」 미구현(`Hunter.lua:14`) |
| WARLOCK 악마 주문 | 원천 없음 | 「the demon's spells … pet-bar, D6」(`Warlock.lua:33–34`) |
| proc 굴림 자체(Mage·Priest·Warlock 등) | 미검증 | 「the procs' rolls (… unseen; the player aura walk reads them where plain)」(`Mage.lua:22–23`, `Priest.lua:20–21`, `Warlock.lua:28–29`) |
| 전투 중 오라·CD 가 secret 이라는 것 | 미검증(게임) | Hekili 원천의 probe 기록(`Facade.lua:725–739, 1027–1035`)이 근거, 우리가 게임에서 본 것 아님 |
| Truth 층 overlay 4개 | 미검증 | 코드에서 꺼 둠(`Truth.lua:26`) |
| Hekili 자료 ID 일부 | 미검증 | 원천이 「in-game check」 를 단 것들(예: `Shaman.lua:26–29, 669–670`, `Mage.lua:15–21`) |

---

## 7. 결정 대기 (master 에게)

1. **Forever 클라이언트 Cooldown Manager 를 쓸지** — 클라이언트에 버프·CD 아이콘 창 넷이 있다(`CooldownViewer.lua:29–30`, 추정). 보완 모듈 알림과 겹칠 수 있다. 기본값(A1): 이 단계에서는 건드리지 않고 Step 20 Codex 실사용 발주문에서 「켜져 있는지·겹치는지」 를 본다.
2. **직업 공용 항목을 특성 목록에 넣을지** — 기본값(A1): talent 나무 키 + `form` + 원천 주석 배정만 기본으로 켜고, 공용 항목은 목록에는 두되 꺼 둔 채 사용자가 켠다.
3. **D7 Codex 자료 요청** — 갈래 3 이 없어 「있는지」 를 위한 요청은 불필요. ID·지속 시간 게임 안 확인만 Step 20 발주문에 싣는 것을 기본값으로 한다.
4. **지원 안 함 4개의 런타임 상태 읽기** — Hekili belief 가 그 특성에서 도는지 미검증. 기본값(A1): Step 19 는 `Hekili.Client` 를 먼저 쓰고, 답이 없으면 게임 API·`IsSpellOverlayed` 로 넘어가는 설계로 하고, Step 20 에서 주술사 restoration 으로 확인(R7 순서).
5. **D2 표시 범위와 갈래 2 의 관계** — D2 가(알림+CD+추천, 추천은 따로 끔)는 지원 24개에만 「추천」 이 있다. 지원 안 함 4개는 알림+CD 만 보인다는 것을 최종 보고에 적을지 master 판단.

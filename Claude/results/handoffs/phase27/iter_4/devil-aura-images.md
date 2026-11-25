# Old Devil UI samples — where player and target buffs/debuffs are drawn (image reading)

Phase 27 · Step 70 · image-reading sub. Source images: `D:\Projects\Project_WF\_local_only\devil-inven-r240\images\` (index `images.json`, 72 entries). Context list of posts: `Codex/docs/old-devil-reference-comparison.md` lines 22–57 (read in full for context; post order below follows that table).

## Scope and method

- `images.json` has 72 entries: 70 files on disk + 2 entries for post 8906 with status `fail HTTP Error 404` (no file; not read).
- 70 files = 68 unique SHA256. Byte-identical duplicates (read once):
  - `idx3461_i1785063732.jpg` = `idx3461_i21702517.jpg` (SHA256 `01c6576116e4…`)
  - `idx9789_i12983843248.jpg` = `idx9880_i13980379535.jpg` (SHA256 `908e60ca3c48…`)
- 19 files named `idx…_s_…jpg` are 119×83 thumbnails. They were read as one labeled montage at 3× nearest-neighbour. Each shows a cropped/zoomed part of a game screen of the same post; too small for aura reading (see the thumbnail section).
- Every full image was viewed whole; small regions (unit frames, top-right corner, icon rows) were cropped from the original pixels and enlarged 2–7×. Crops are in the scratch folder `C:\Users\lksz1\AppData\Local\Temp\claude\712c5ac97757b4a3\5a41c91b-71c1-4f88-8d73-93b3933d99f1\scratchpad\aura.P2OD\`.
- Coordinates are in original image pixels, rough (x0–x1, y0–y1).
- Confidence words: **confirmed** = directly visible; **estimated** = position visible but its meaning (buff vs debuff, own vs other, addon) is inferred from border colour, timer text or name; **not readable** = cannot be decided from the image.
- "TR block" = a separate icon/bar block in the top-right screen corner (where the game's default buff frame sits), detached from the unit frame.
- Function of icon grids without labels (2×3 or 4×3 boxes near the screen centre in posts 11218, 11361, 12174, 13140, 9880) is **not readable**: they may be aura trackers or cooldown trackers; nothing in the image tells which.

---

## Post 45 (2015 / nicecurry original; 4 samples, DevilUI 3.0)

### idx45_1103_5258.jpg — 867×694 — full screen ("DevilUI 3.0 Standard Normal (STN)")
- Frames: player frame top-left x10–155 y28–70 (portrait + bar). No target. — confirmed
- Player buffs/debuffs: none visible near the frame; top-right corner next to the round minimap empty (crop). — confirmed (no aura shown at that moment)
- Target: no target.
- Other: two vertical icon columns at the right edge x815–865 y290–610 carry item counts → action/item buttons, not auras. — estimated

### idx45_1103_7511.jpg — 867×542 — full screen ("Standard Wide (STW)")
- Frames: player x15–155 y25–55; target (self) x170–310 y25–55 with two ToT name boxes x313–372. — confirmed
- Player and target auras: none visible anywhere. — confirmed

### idx45_1103_6784.jpg — 900×720 — full screen ("Special Normal (SPN)")
- Frames: player lower-left x155–308 y490–530, pet above x200–308 y453–480. No target. — confirmed
- Auras: none visible. — confirmed

### idx45_1103_7276.jpg — 800×500 — full screen ("Special Wide (SPW)", the 4th sample)
- Frames: pet x205–285 y305–332, player x170–285 y340–372 (same arrangement as SPN). No target. — confirmed
- Auras: none visible (enlarged crop of the frame area). — confirmed

## Post 11218 (2023)

### idx11218_i13715800082.png — 1344×756 — full screen ("DevilUI 8.0.1 Fixed by Arastin")
- Frames: player x308–487 y518–568 (left of centre, low); target (friendly NPC) x858–1035 y518–568. — confirmed
- Player buffs: TR block x1240–1330 y22–52, one row of 3 icons, each with a green duration bar under it. — confirmed position; buff meaning estimated
- Player debuffs: none visible.
- Target: no auras visible (friendly NPC). — confirmed
- Other: two 2×3 icon clusters above the frames' inner ends x455–500 y280–350 and x845–890 y280–350, some with counts ("2", "0"), one grey → not readable (aura vs cooldown). Faint empty slot boxes centre x590–760 y455–525 → not readable. "WeakAuras" appears on the bottom info bar.

### idx11218_i13441659684.png — 551×632 — close-up of an inventory bag. Skipped.

## Post 2958 (2009 / 3.3 Black)

### idx2958_i27419179.jpg — 1920×1024 — full screen
- Frames: player x600–870 y757–808 (long horizontal bar, portrait left; above the bottom panel, left of centre); target (friendly NPC) x1048–1325 y757–808 (portrait right). — confirmed
- Player buffs: TR block x1835–1900 y12–40, 2 icons with cyan border, no timer text. — confirmed position; buff meaning estimated
- Player debuffs: none visible.
- Target buffs: 2 icons to the RIGHT of the target frame x1350–1410 y762–787, one row, icon ≈ half the frame height. — confirmed position; buff (friendly NPC) estimated
- Target debuffs: none visible.
- Other: 3 icons above the action bars x893–982 y838–865 = stance/aspect bar. — estimated

## Post 13140 (2026 / Forever Beta, 2560×1440)

### idx13140_i1501524156851826.jpg — 2560×1440 — full screen (bottom panel variant)
- Frames: player top-left x38–356 y58–141. No target. — confirmed
- Auras: none near the player frame; top-right holds only the objective tracker. — confirmed
- Other: one isolated icon (fire/claw art) x759–813 y730–781 left of the character → not readable (proc/cooldown/aura).

### idx13140_i1053162798196619.jpg — 2560×1440 — full screen (round minimap top-right)
- Frames: player top-left x38–356 y58–141. No target. — confirmed
- Auras: none. Two empty 2×3 slot grids (grey outlines, no icons) ≈x822–930 and x1574–1680, y568–728 → not readable. Same fire icon ≈x684–740 y820–875.

### idx13140_i1882042185546511.jpg — 2560×1440 — full screen (bottom-concentrated variant)
- Frames: player bar-only frame lower-left of centre ≈x666–1000 y913–985. No target. — confirmed
- Auras: none. Two empty 4×3 slot grids ≈x712–925 and x1635–1845, y505–665 → not readable. Fire icon again.

### idx13140_i1472941816407653.jpg — 2560×1440 — full screen, DevilUI options window covers the centre
- Frames behind the window (same as 1882 variant). Auras: not readable.
- Addon list shown in the window: AdvancedInterfaceOptions, Broker Money, Broker: XP Bar, Castbars, ChocolateBar, DevilUI, Leatrix Plus, Mapster, Masque, PitBull Unit Frames 4.0, RangeDisplay, TipTac. — confirmed

## Post 11361 (2019–2023 / Classic, "DevilUI 1.13.2 Fan Ver.")

### idx11361_i13332298828.jpg — 1920×1080 — full screen
- Frames: pet x518–695 y628–685, player x440–695 y715–785 (left of centre, low). No target. — confirmed
- Player buffs: 1 icon in the TR block x1672–1702 y35–65. — position confirmed; buff meaning estimated
- Other: 2×3 bordered grids left x645–715 y395–500 (2 icons filled, bottom row) and right x1205–1275 y395–500 (1 filled) → not readable.

### idx11361_i13373274081.jpg — 371×142 — file-list crop (DevilUI 9.10, disk2.pak). Not a game screen; skipped.

### idx11361_i14702893841.png — 1920×1080 — full screen (combat, hunter)
- Frames: player x440–695 y740–810; pet x518–695 y655–712; target x1225–1480 y740–810 (right of centre, low) with ToT/ToTT name boxes under it. — confirmed
- Player buffs: TR block x1635–1705 y35–65, 2 icons, no timer text. — position confirmed; meaning estimated
- Player debuffs: none visible. Pet: 1 red-bordered icon above the pet frame's left end x520–537 y635–650. — estimated pet debuff
- Target auras: ABOVE the target frame, left-aligned, two rows:
  - upper row x1228–1310 y655–670: 4 small icons, red/dark borders, numbers 18 / 3 / 5 / 15 — debuffs, general (estimated)
  - lower row (next to the frame) x1228–1295 y675–705: 2 LARGER icons (≈2× the small ones, ≈0.45× frame height), green border, timers "1.8" and "1:49" — own debuffs (estimated by green border and timers)
  - the same two icons with timers also sit above the enemy nameplate ("1.9" + demon icon). — confirmed
- Target buffs: none distinguishable. — not readable
- Other: 4 party frames top-left x20–210; 1–3 small icons under each frame's left edge. — confirmed position

### idx11361_i15140573447.png — 1920×1080 — full screen
- Frames: player x440–695 y740–810, pet x518–695 y655–712, target (friendly warrior) x1225–1480 y740–810. — confirmed
- Auras: player none visible (TR empty); target none. — confirmed
- Other: the two 2×3 grids again; left grid's bottom-row icons differ between the three shots of this post → may be an aura or cooldown tracker; not readable.

## Post 12124 (2021 / Shadowlands Black)

### idx12124_i13726980278.jpg — 2418×1363 — full screen (dungeon combat)
- Frames: player ≈x660–980 y1065–1125 (bottom, left of centre, portrait at the right end); target ≈x1434–1755 y1065–1120 (right of centre, portrait at the left end); focus/ToT small frame centre ≈x1130–1290. — confirmed
- Player buffs: (a) one row of 7 small icons directly BELOW the player frame, left-aligned ≈x665–805 y1130–1148 (green/yellow borders, stacks 5 and 3), plus 1 icon under the portrait end ≈x940–968; icon ≈0.3× frame height. (b) TR block left of the minimap ≈x1815–2130 y48–97, one row of 7 icons with timers (5초, 54분, 9초, 0초). — confirmed positions; buff meaning estimated
- Player debuffs: none distinguishable. — not readable
- Target auras: one row of 4 small icons BELOW the target frame, left-aligned ≈x1437–1520 y1123–1143. Buff/debuff and own/other split not readable.
- Other: 3 large icons centre under the frames ≈x1065–1283 y1174–1240 with stacks (2/5, 5, 2), ≈2× the frame aura icons — separate big aura/proc display (estimated, WeakAuras-like). Raid-buff checklist grid ≈x1700–1940 y215–360 (지능/체력/전투력/블러드 with check/X). Party frames right ≈x1840–1960 with 2–4 icons right of each (aura vs cooldown not readable).

### idx12124_i15496852308.jpg — 2418×1361 — full screen (city)
- Player: row of 5 small icons BELOW the player frame, left-aligned; TR block row of 5 icons left of the minimap. — confirmed positions
- Target (friendly NPC): no auras. Checklist grid; 1 party frame with 1 icon right of it.

### idx12124_i15567580445.jpg — 2417×1361 — full screen (city; NPC dialog over the player frame)
- Same as 15496: 5 icons below the player frame, 5 icons in the TR block; target (friendly) no auras.

## Post 12174 (2020 / Normal rebuild)

### idx12174_i15004589504.jpg — 1920×1080 — full screen, PitBull4 placeholder/config mode (`{Lua:…}` texts)
- Frames: player top-left x25–330 y40–115 (portrait left); pet under it x55–250 y140–185; target x360–655 y40–115 (top, right of the player) with ToT/ToTT boxes x665–780; focus x425–640 y260–305; 4 party frames left x25–345. — confirmed
- Player auras: NO aura slots attached to the player frame (enlarged crop). Player buffs shown in the TR block x1520–1700 y55–80, 5 icons. — confirmed
- Target auras (all BELOW the target frame, left-aligned, three rows): — confirmed positions
  1. 14 small buff slots, numbered 1→14 left to right, x362–655 y118–135
  2. 4 LARGER slots (≈2×), borders red/blue/green/red, counts 4/3/2, x362–500 y142–172 — estimated own / priority debuffs
  3. 12 small debuff slots with coloured borders and counts, x362–612 y180–197
  Order: buffs → large debuffs → small debuffs.
- Pet, focus and party frames: one row below each, 8 small buff slots (left) + 3 debuff slots (right). — confirmed
- Other: two 2×3 grids centre x650–720 and x1155–1225, y445–550 (icons filled) → not readable.

## Posts 9880 and 9789 (same bytes)

### idx9880_i13980379535.jpg (= idx9789_i12983843248.jpg) — 576×324 — full screen, low resolution
- Frames: player/target frames not visible at this size. — not readable
- Player buffs: TR block x470–520 y12–22, 4 icons with green duration bars. — position confirmed; meaning estimated
- Other: two 2×3 icon clusters centre (left x198–215 y140–170, 6 filled; right x352–374 y140–165, 4 filled) beside "1 combo" text → not readable.

## Post 3461 (BlackEdition2 6.1 Alpha / 3.3)

### idx3461_i21702517.jpg (= idx3461_i1785063732.jpg) — 800×500 — full screen with the author's yellow labelled boxes
- The author's label "버프 & 디버프" (buffs & debuffs) marks a box in the top-right x528–710 y8–85, directly left of the "미니맵" (minimap) box; 4 icons sit right-aligned in it x655–710 y10–25. — confirmed (label and icons)
- Frames ("유닛프레임" box) bottom x200–600 y388–412: player x200–315 (bars only), small centre frame x370–430, target (self) x485–600. — confirmed
- Tiny icons just under the player frame's left end (x200–225 y405–412) and under the target frame's right end (x575–600 y405–412), partly covered by the yellow box line, ≈5 px. — position estimated; type not readable
- Other: party/focus box on the right side is empty in this shot.

### idx3461_i33352474.jpg — 600×480 — full screen (5:4 variant)
- Frames: player x135–240 y324–346. No target. Auras: none visible (TR and frame area). — confirmed

### idx3461_i74109714.jpg — 1680×1050 — full screen ("DevilUI Black Edition II")
- Frames: player x420–665 y820–862 (left of centre, above the bottom panel); target (NPC) x1015–1260 y820–862. — confirmed
- Player buffs: 1 green-bordered icon directly BELOW the player frame's left end x420–437 y866–882 (≈0.4× frame height); the same icon also in the TR block x1468–1497 y22–52 left of the minimap → the buff is drawn in both places. — confirmed positions; buff meaning estimated
- Target: no auras visible. Debuffs: none.

## Post 8906 — 2 entries, HTTP 404, no file. Not read.

## Post 4238 (2010 / BlackEdition1 light)

### idx4238_i26822971.jpg — 800×600 — Windows AddOns folder list (not a game screen)
- Aura-related folder names visible: PitBull4_Aura, ClassTimer, OmniCC (also Quartz cast bars). — confirmed

### idx4238_i23415265.jpg — 1280×1024 — full screen
- Frames: player x373–590 y757–800 (left of centre, portrait left). No target. — confirmed
- Player buffs: TR block x1138–1270 y15–45, one row of 4 icons, no timer text (minimap is at the bottom in this layout). — position confirmed; meaning estimated
- Debuffs: none.

## Post 2582 (2009 / 3.38)

### idx2582_0806_5971.jpg — 1200×960 — full screen
- Frames: player x230–433 y655–718; pet above x293–433 y605–650. No target. — confirmed
- Player buffs: TR block x1095–1190 y30–55, 3 icons, "16초" under the first. — confirmed position
- Pet: 1 small red-bordered icon left of the pet frame x274–290 y607–623 → not readable.

## Post 1932 (2008 / Black CUSTOM)

### idx1932_1027_6677.jpg — 1280×1024 — full screen
- Frames: player x378–605 y765–797. No target. — confirmed
- Player buffs: TR block as 2 BARS (icon + name), x1070–1205 y8–40: "빠른 폭풍까마귀 변신", "야생의 징표". — confirmed
- Other: 5 icons above the action bars x385–485 y843–862 = shapeshift bar. — estimated

### idx1932_1027_7738.jpg — 1280×1024 — full screen (Alterac Valley, druid bear)
- Frames: player x378–605 y765–797; target (boss) x672–900 y765–797. — confirmed
- Player buffs: (a) TR block x1070–1275 y5–260, 15 bars (icon + name): 6 untimed first (광포한 곰 변신, 달빛야수 오라, 무리의 우두머리, 수호자 ×4, 집중의 오라, 피의 서약), then timed ones in descending order 59:07 … 0:04. (b) 2 blue timer bars directly ABOVE the player frame x380–550 y737–757: "나무 껍질 (플레이어) 8.6초", "생존 본능 (플레이어) 13초". — confirmed
- Player debuffs: none visible.
- Target debuffs: ABOVE the target frame — top: 1 yellow timer bar x672–900 y712–724 "가르기 (5) (대상) 10초" (own debuff as a bar, estimated own); between it and the frame: 2 rows of small icons x672–900 y727–763 (≈13 + ≈11; ≈0.4× frame height; red/purple borders; stack and time numbers). Own icons are not drawn larger. — confirmed positions
- Target buffs: not separable from the icon rows. — not readable
- Other: party frames right x1065–1275 y605–805 with one small aura row under each.

## Post 1877 (2008 / WCK Wide)

### idx1877_1029_9689.jpg — 1680×1050 — full screen, unit-frame placeholder/config mode
- Frames: player x410–680 y385–470; target x1005–1270 y385–470. — confirmed
- Player auras: grid BELOW the player frame, right-anchored (slot 1 at the right, growing left), 4 rows: green 1–12, green 13–24, yellow 25–32 then red 9–12, red 13–16 → 32 buff slots first, then 16 debuff slots after the buffs. Icon ≈0.45× frame height. — confirmed (placeholder numbering and colours)
- 2 icons stacked at the player frame's right side x680–710 y390–450 (crystal, red rune) → weapon enchant style. — estimated
- Target auras: one row of 10 green-bordered placeholder icons directly BELOW the target frame, left-anchored, small (≈0.3× frame height). Buff/debuff type of that row: not readable.
- Other: a "No Target" timer bar and a "Cooldowns" bar block under the target side; pet frame x415–630 y690–760 with 6 red slots (2×3) right and 9 green below; party frames left with rows under each.

### idx1877_1029_9382.jpg — 1680×1050 — full screen, Bartender config open
- Player frame faded behind the config; target (self) x1005–1270 shows no icons. Auras: not readable.

### idx1877_1029_3690.jpg — 1680×1050 — full screen, world map covers the centre
- Unit frames hidden. Auras: not readable.

## Post 1865 (2008 / Wide personal mix)

### idx1865_1029_7212.jpg — 1584×990 — full screen, placeholder/config mode
- Frames: player top-left x30–280 y25–100; pet under it; target x315–560 y25–100. — confirmed
- Player auras: a DETACHED block in the top-right, left of the minimap, x820–1335 y45–310: green buff rows 12→1, 24→13, 32→25 (right-anchored), then red debuff rows 12→1, 16→13 below the buffs, then two weapon-enchant slots (OH, MH) at the right end. Icons ≈40 px (larger than the target's). — confirmed
- Target auras: BELOW the target frame — green buffs 1–10, 11–20, 21–24 (3 rows, left-anchored) first, then red debuffs in 4 rows (40–31, 30–21, 20–11, 10–1). Icon ≈0.4× frame height. — confirmed
- Other: 2 weapon-enchant-like icons above the action bar x440–495 y850–875; "No Target" and "Cooldowns" timer-bar block x1105–1545 y340–460.

## Post 1853 (2008 / D3_Skin mix, orb UI)

### idx1853_1024_5332.jpg — 1280×768 — full screen
- Frames: target top-left x15–220 y35–95 (enemy); player shown as health/resource orbs at the bottom. — confirmed
- Player buffs: TR block x1030–1090 y25–50, 2 icons ("14초" under the first); 1 more icon under the minimap x1125–1150 y185–205 ("52분"). — confirmed positions; meaning estimated
- Target: 1 red-bordered icon below the target frame's right end x200–220 y95–115. — position confirmed; debuff estimated
- Other: timer bars x870–1000 y505–540 (비열한 습격 0.8, [63] 강철이빨…, 번개같은 속도 14) — a timer-bar aura display (estimated). 2 icons centre x805–855 y325–345 → not readable.

### idx1853_1024_4918.jpg — 1280×768 — full screen
- Target (friendly mage) top-left; 2 green-bordered icons below the frame, left x20–60 y95–115. — confirmed position; buffs estimated
- Player buffs: TR block x1035–1085 y28–52, 2 icons; icon under minimap "48분".

## Post 1403 (2008 / DevilSkin)

### idx1403_0421_6044.jpg — 1280×968 — full screen
- Frames: player top-left x5–180 y30–75. No target. — confirmed
- Player buffs: a row of 7 icons x880–1095 y130–155 under the top bar, left of the minimap, numbers 19/19/18/20/20/19 under six of them. — position confirmed; buff (minutes) estimated
- Other: near the character x760–835 y440–470 two larger icons + six smaller with counts → item buttons / weapon enchants. — estimated

## Post 1361 (2008 / Devil-Wind rogue mix)

### idx1361_0414_5787.jpg — 566×465 — folder list. Skipped.

### idx1361_0414_4133.jpg — 1280×1024 — full screen
- Frames: player x330–560 y655–715; target (self) x710–940; small ToT frame centre. — confirmed
- Player buffs: TR block as bars x1100–1270 y10–110: "황갈색 와이번" (no timer) then purple "검투사의 쾌검 25:33", "검투사의 절단검 23:23" (weapon enchants) under it. — confirmed
- Debuffs: none.

### idx1361_0414_3243.jpg — 1280×1024 — full screen (PvP)
- Player buffs: TR block, purple enchant bars only. — confirmed
- 4 timer bars directly ABOVE the player frame x330–560 y590–655: 비열한 습격 0:02, 충격포 0:03, 신경 마비 독 0:11, 과다출혈 ×10 0:14 — rogue-applied debuffs on the target shown as bars over the player frame. — position confirmed; "own debuffs on target" estimated
- Target frame x710–940 y655–715; 1 icon ABOVE its right end x915–940 y630–655 (stack 10). — confirmed position; debuff estimated
- Other: party frames top-left with a small icon row below-right of each; one more timer bar "[70] Russul 맹독 VII 9s" mid-right (another unit).

### idx1361_0414_9820.jpg — 1195×379 — partial bottom crop (player frame x295–525 y175–235 and item buttons). No auras. Not a full screen.

### idx1361_0414_4442.jpg — 1280×1024 — full screen (PvP)
- Player buffs: TR block bars — blue 회피 0:06, 아드레날린 촉진 0:04, 폭풍의 칼날 0:03, then a gap, then purple enchant bars 4:59, 2:49. — confirmed
- Target x710–940 + cast bar; 1 icon ABOVE the target frame's right end. — position confirmed; type not readable

## Post 1121 (2008 / rogue mix)

### idx1121_0324_2793.jpg — 1000×800 — full screen
- Frames: player x280–440 y585–630; target (self) x555–715. — confirmed
- Player buffs: single bar "광물 찾기" (tracking) under the minimap x875–990 y140–160. — confirmed
- Other: icon column at the left edge x0–20 y300–540 (buttons).

### idx1121_0324_7031.jpg — 1280×1024 — full screen
- Same layout; "광물 찾기" bar top-right; 2 icons left x35–60 y650–690 → not readable.

### idx1121_0324_2626.jpg — 1000×800 — full screen (combat)
- Frames: player x280–440 y585–630; target (boss) x555–715 y585–630; party frames top-left. — confirmed
- Player buffs: TR bars under the minimap, right column x875–995 y140–265: 광물 찾기, 냉혈, 상급 왕의 축복 27:39, 신의 권능: 인내 27:27, 아드레날린 촉진 0:03, 해결사의 분노 0:01. — confirmed
- Player debuffs: separate LEFT column of that bar block x765–870 y140–160: "빙결 0:04". — position confirmed; debuff estimated
- 2 small icons above the player frame's left end x280–315 y572–585 (one red, "4") → not readable.
- Target auras: 2 rows of small icons ABOVE the target frame x555–715 y570–598 (≈13 per row, stack "5" at the right). Buff/debuff split not readable.
- Party frames: one row of buff icons under each. — confirmed

### idx1121_0324_5820.jpg — 786×591 — folder list. Skipped.

### idx1121_0324_8270.jpg — 1000×800 — full screen (bags open)
- Player frame bottom; "광물 찾기" bar; no target; no other auras.

## Post 1086 (2008 / rogue mix)

### idx1086_0313_4478.jpg — 1280×1024 — full screen
- Frames: player x360–565 y750–810; target (self) x710–915. — confirmed
- Player buffs: single "광물 찾기" bar under the minimap x1125–1270 y180–205. Nothing else. — confirmed

## Post 1008 (2008 / healer mix)

### idx1008_0226_5246.jpg — 1280×1024 — full screen (raid)
- Frames: player x185–450 y565–625 (round portrait, left of centre); target top-centre x465–790 y95–130 (boss + ToT "Fos"). — confirmed
- Player buffs: TR block x825–1100 y28–70, one row of 8 icons with minutes + 1 icon below the right end x1075–1095 y75–100. — confirmed
- Target auras: 2 rows × 10 icons BELOW the target frame x465–770 y150–210 (stacks "5"). Buff/debuff split not readable; own not larger. — confirmed position
- Other: HoT timer bars x940–1095 y205–335 ("[70] 가르가스 0:07 회복의 기원" …); raid grid centre-bottom; "30m 이내" range icons (not auras).

### idx1008_0226_3943.jpg — 1280×1024 — full screen (raid)
- Player buffs: same TR block (3분, 12분, …) + 1 icon below ("3초"). — confirmed
- Target frame: not visible at the top centre in this shot. — estimated
- Other: boss timer bars top-left x235–445 y100–148 (18 다음 급강하 폭격 / 57 방어구 녹이기: Fos / 7:46 격노 — boss timers, not auras); HoT bars and "Cooldowns" on the right.

## Post 546 (2007 / rogue centre mix)

### idx546_1019_9798.jpg — 1280×1024 — full screen (raid)
- Frames: player x415–590 y735–795; target (boss) x690–915 y735–795. — confirmed
- Player buffs: TR block x760–1100 y15–150, 3 rows (10 icons with 분; a row with 초; 4 icons). — confirmed
- Player debuffs: 1 red-bordered icon "33초" alone below that block x1070–1100 y178–215. — position confirmed; debuff estimated
- Target auras: 3 rows (10, 10, 4) BELOW the target frame x690–905 y785–850, mixed borders, stacks. Own not visibly larger. — confirmed position
- Other: top-left bars x0–200 y10–105 (그림자 망토 25 / 회피 41 / 폭풍의 칼날 1:32 / 전력 질주 1:47 / 소멸 4:20 / 아드레날린 촉진 4:49 + "1:32 피의 욕망 브로치") — cooldown timer bars (estimated); centre: combo-point circles, red "23초" bar and "5.8 파열의 회오리 대기시간" bar.

## Thumbnails (19 files, 119×83 each)

`idx1008_s_0226_3943`, `idx1086_s_0313_4478`, `idx1121_s_0324_2793`, `idx1121_s_0324_7031`, `idx1121_s_0324_8270`, `idx1361_s_0414_3243`, `idx1361_s_0414_4133`, `idx1361_s_0414_4442`, `idx1361_s_0414_5787`, `idx1361_s_0414_9820`, `idx1403_s_0421_6044`, `idx1853_s_1024_4918`, `idx1865_s_1029_7212`, `idx1877_s_1029_3690`, `idx1877_s_1029_9689`, `idx1932_s_1027_6677`, `idx1932_s_1027_7738`, `idx2582_s_0806_5971`, `idx546_s_1019_9798`.
Each is a cropped/zoomed preview of a game screen of its post (several show a "moon only" watermark not present in the full image read). At 119×83 no aura icon can be classified → not readable; positions are taken from the full images above.

---

## Summary table

TR = top-right block detached from the frame. "—" = nothing visible. cfg = placeholder/config mode.

| post | image | full screen? | player buffs place | player debuffs place | target buffs place | target debuffs place | own-aura larger? | other aura display | confidence |
|---|---|---|---|---|---|---|---|---|---|
| 45 | 1103_5258 | yes | — | — | no target | no target | n/a | — | confirmed |
| 45 | 1103_7511 | yes | — | — | — (target=self) | — | n/a | — | confirmed |
| 45 | 1103_6784 | yes | — | — | no target | no target | n/a | — | confirmed |
| 45 | 1103_7276 | yes | — | — | no target | no target | n/a | — | confirmed |
| 11218 | i13715800082 | yes | TR icons (3, duration bars) | — | — (friendly) | — | n/a | 2×3 grids (not readable) | confirmed / meaning est. |
| 11218 | i13441659684 | no (bag) | | | | | | | — |
| 2958 | i27419179 | yes | TR icons (2) | — | right of target frame (2) | — | n/a | stance bar | position confirmed, buff est. |
| 13140 | i1501524156851826 | yes | — | — | no target | no target | n/a | lone fire icon (not readable) | confirmed |
| 13140 | i1053162798196619 | yes | — | — | no target | no target | n/a | empty 2×3 grids | confirmed |
| 13140 | i1882042185546511 | yes | — | — | no target | no target | n/a | empty 4×3 grids | confirmed |
| 13140 | i1472941816407653 | yes (window) | not readable | not readable | no target | no target | n/a | options window | not readable |
| 11361 | i13332298828 | yes | TR icon (1) | — | no target | no target | n/a | 2×3 grids | est. |
| 11361 | i13373274081 | no (file list) | | | | | | | — |
| 11361 | i14702893841 | yes | TR icons (2) | — | not readable | above target frame: small row on top, larger own row next to frame | **yes** (≈2×, green border, timers) | same own debuffs over nameplate; party auras under frames | position confirmed, own est. |
| 11361 | i15140573447 | yes | — | — | — (friendly) | — | n/a | 2×3 grids | confirmed |
| 12124 | i13726980278 | yes | below player frame (row, left) + TR icons (7) | not readable | below target frame (row of 4, type n/r) | (same row) | no | 3 big centre aura icons; buff checklist | confirmed positions |
| 12124 | i15496852308 | yes | below player frame (5) + TR icons (5) | — | — (friendly) | — | n/a | buff checklist | confirmed |
| 12124 | i15567580445 | yes | below player frame (5) + TR icons (5) | — | — (friendly) | — | n/a | checklist | confirmed |
| 12174 | i15004589504 | yes (cfg) | TR icons (5); frame has no aura slots | none on frame | below target frame, row 1 | below buffs: large row, then small row | **yes, est.** (large debuff row) | pet/focus/party rows below; 2×3 grids | confirmed positions |
| 9880 (=9789) | i13980379535 | yes (low-res) | TR icons (4, duration bars) | — | not readable | not readable | n/r | 2×3 clusters | est. |
| 3461 | i21702517 (=i1785063732) | yes (labelled) | TR block labelled "버프 & 디버프" (4 icons); tiny icons under frame | (labelled TR) | tiny icons under target right end | (same) | n/r | — | label confirmed; icons n/r |
| 3461 | i33352474 | yes | — | — | no target | no target | n/a | — | confirmed |
| 3461 | i74109714 | yes | below player frame (1, left) + TR (same icon) | — | — | — | n/a | — | confirmed |
| 8906 | 2 entries | failed 404 | | | | | | | not read |
| 4238 | i26822971 | no (folder list) | | | | | | PitBull4_Aura, ClassTimer folders | confirmed |
| 4238 | i23415265 | yes | TR icons (4) | — | no target | no target | n/a | — | confirmed |
| 2582 | 0806_5971 | yes | TR icons (3) | — | no target | no target | n/a | pet icon | confirmed |
| 1932 | 1027_6677 | yes | TR bars (2) | — | no target | no target | n/a | shapeshift bar | confirmed |
| 1932 | 1027_7738 | yes | TR bars (15) + timer bars above player frame (2) | — | not readable | above target frame: own bar on top, 2 icon rows | no (own as bar) | party aura rows | confirmed |
| 1877 | 1029_9689 | yes (cfg) | below player frame (buffs first) | below player frame, after buffs | below target frame (1 row, type n/r) | (same row) | n/r | No-Target / Cooldowns bars; weapon-enchant icons | confirmed |
| 1877 | 1029_9382 | yes (config open) | not readable | not readable | — (self) | — | n/a | Cooldowns bars | n/r |
| 1877 | 1029_3690 | yes (map open) | not readable | not readable | not readable | not readable | n/r | — | n/r |
| 1865 | 1029_7212 | yes (cfg) | detached block left of minimap, top-right | same block, below buffs | below target frame (3 rows) | below target buffs (4 rows) | player block icons larger than target's | weapon-enchant slots; timer bars | confirmed |
| 1853 | 1024_5332 | yes | TR icons (2) + 1 under minimap | — | — | below target frame, right end (1) | n/a | timer-bar display | position confirmed, debuff est. |
| 1853 | 1024_4918 | yes | TR icons (2) | — | below target frame, left (2) | — | n/a | — | position confirmed, buff est. |
| 1403 | 0421_6044 | yes | row left of minimap (7, under top bar) | — | no target | no target | n/a | item/enchant icons | est. |
| 1361 | 0414_5787 | no (folder) | | | | | | | — |
| 1361 | 0414_4133 | yes | TR bars (+ enchant bars) | — | — (self) | — | n/a | — | confirmed |
| 1361 | 0414_3243 | yes | TR bars (enchants) | — | not readable | above target frame right end (1) + bars above player frame | n/r | timer bars | position confirmed, meaning est. |
| 1361 | 0414_9820 | no (partial crop) | | | | | | | — |
| 1361 | 0414_4442 | yes | TR bars | — | not readable | above target frame right end (1, type n/r) | n/r | — | est. |
| 1121 | 0324_2793 | yes | TR bar (tracking only) | — | — (self) | — | n/a | — | confirmed |
| 1121 | 0324_7031 | yes | TR bar (tracking only) | — | — | — | n/a | — | confirmed |
| 1121 | 0324_2626 | yes | TR bars (right column) | TR bars (left column, 1) | above target frame (2 rows, type n/r) | (same rows) | n/r | party aura rows | position confirmed, debuff est. |
| 1121 | 0324_5820 | no (folder) | | | | | | | — |
| 1121 | 0324_8270 | yes | TR bar (tracking only) | — | no target | no target | n/a | — | confirmed |
| 1086 | 0313_4478 | yes | TR bar (tracking only) | — | — (self) | — | n/a | — | confirmed |
| 1008 | 0226_5246 | yes | TR icons (8 + 1) | — | below target frame (2×10, type n/r) | (same rows) | no | HoT timer bars | confirmed |
| 1008 | 0226_3943 | yes | TR icons | — | no target frame visible | — | n/a | boss timer bars, HoT bars | confirmed / target est. |
| 546 | 1019_9798 | yes | TR icons (3 rows) | separate icon below TR block (1) | below target frame (3 rows, type n/r) | (same rows) | no | cooldown timer bars | confirmed / debuff est. |
| all | 19 `_s_` thumbnails | no (119×83) | | | | | | | not readable |

## Tally over the 43 full-screen images (unique bytes)

Full screens: 45 ×4, 11218 ×1, 2958 ×1, 13140 ×4, 11361 ×3, 12124 ×3, 12174 ×1, 9880 ×1, 3461 ×3, 4238 ×1, 2582 ×1, 1932 ×2, 1877 ×3, 1865 ×1, 1853 ×2, 1403 ×1, 1361 ×3, 1121 ×4, 1086 ×1, 1008 ×2, 546 ×1 = 43. Not full screen: 6 (bag, file list, 3 folder lists, 1 partial crop) + 19 thumbnails. 43 + 6 + 19 = 68 unique.

### Player buffs

| arrangement | count | images |
|---|---|---|
| TR block, icons only | 15 | 11218, 2958, 11361_133, 11361_147, 12174, 9880, 3461_217 (labelled), 4238_234, 2582, 1853 ×2, 1403, 1008 ×2, 546 |
| below the player frame + same/other icons in TR block | 4 | 12124 ×3, 3461_741 |
| TR block as bars (incl. 5 with only the tracking bar "광물 찾기") | 9 | 1932_667, 1361 ×3, 1121 ×4, 1086 |
| TR bars + timer bars above the player frame | 1 | 1932_773 |
| below the player frame only (config) | 1 | 1877_968 |
| detached block left of the minimap (config) | 1 | 1865 |
| nothing visible | 9 | 45 ×4, 13140 ×3, 11361_151, 3461_333 |
| not readable | 3 | 13140_147, 1877_938, 1877_369 |

### Player debuffs

| arrangement | count | images |
|---|---|---|
| below the player frame, after the buffs (config) | 1 | 1877_968 |
| in the detached block, rows below the buffs (config) | 1 | 1865 |
| separate item next to / under the TR buff block | 2 | 1121_2626 (bar column left of buff bars), 546 (icon below buff rows) |
| nothing visible | 36 | all others except below |
| not readable | 3 | 13140_147, 1877_938, 1877_369 |

The 3461 labelled sample says buffs and debuffs share the top-right box ("버프 & 디버프"), but no debuff is on screen there; it is counted under "nothing visible" for debuffs.

### Target auras

| arrangement | count | images |
|---|---|---|
| below the target frame | 8 | 12124_137, 12174 (cfg), 1877_968 (cfg), 1865 (cfg), 1853_533, 1853_491, 1008_524, 546 |
| above the target frame | 5 | 11361_147, 1932_773, 1361_324, 1361_444, 1121_2626 |
| right of the target frame | 1 | 2958 |
| target present but no auras, or no target | 24 | rest |
| not readable | 5 | 9880, 13140_147, 1877_369, 3461_217, 1008_394 (target frame not visible) |

Where buffs and debuffs are separated on the target (all below the frame, buffs first, debuffs under them): 12174 (cfg) and 1865 (cfg) — 2 images. In 11361_147 only debuffs are shown above the frame, small general row on top and larger own row next to the frame. In 1932_773 the own debuff is a timer bar above the icon rows.

### Own auras drawn larger

- yes, confirmed position and size: 1 image (11361_147 — green-bordered timed icons ≈2× the others, next to the target frame; the same icons over the nameplate)
- yes, estimated: 1 image (12174 cfg — a row of 4 larger debuff slots between the buff row and the small debuff row)
- own shown as a timer bar instead of a larger icon: 2 images (1932_773 "가르기 (대상)" bar; 1361_324 bars above the player frame, estimated)
- not larger / not distinguishable: all other images with target auras

## Not readable (list)

- 13140_i1472941816407653 — options window covers the frames
- 1877_1029_9382 — Bartender config covers the player frame
- 1877_1029_3690 — world map covers the screen
- 9880 / 9789 — 576×324; unit frames not visible
- 3461_i21702517 — the ≈5 px icons under both frames (type and count)
- Function of the unlabelled 2×3 / 4×3 icon grids (11218, 11361 ×3, 12174, 13140 ×2, 9880) and of the lone fire icon (13140)
- Buff vs debuff split of the target rows in 12124_137, 1877_968, 1121_2626, 1008_524, 546, 1361_4442
- All 19 thumbnails (119×83)
- Post 8906 — two files missing (HTTP 404), not read

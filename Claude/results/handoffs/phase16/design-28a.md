# Phase 16 Step 28a — Light status strip: design

Author: A1 analyst (design only). Implementer: A2 coder in Step 28b. The master decides the open points in section 9.

Labels used for every claim:

| Label | Meaning |
|---|---|
| **confirmed** | The cited file:line says so. |
| **not found** | Searched and absent. |
| **inferred** | A1 reasoning from cited facts. |
| **unverified / 확인 필요** | The repo holds no source that runs this under Forever. Codex game verification settles it. |

Paths are relative to the repository root. `UP/` means `Collection/upstream/`. `V42/` means `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/`. Both trees are untrusted reference data: they were read, never run.

---

## 0. Inputs and constraints

| Source | What it fixes |
|---|---|
| Plan row 16 (`Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md:228`) | Light items only: clock, FPS and latency, gold, durability, free bag slots. No currency list, no LDB plugin bundle, no guild or friends lists. Codex owns the appearance in the Step 5 lower 28px band. Step 28a decides whether this lives in Core or in one small addon. |
| Plan :150 (R101·R99·R100) | Fewer addons is better. Add no addon when the game or an addon already in the collection does the job. Our own linking addons are made only when needed. |
| Plan :141 (R44·R60) | Features are separately selectable, and **selection means switching the AddOn itself on or off, not hiding its display**. |
| Plan :270 | V42 ChocolateBar, Broker_Money, Broker_Guild_Friends and shPerformance are reference only. None of them ships. |
| Plan :398–412 | Implementation Interfaces: registry convention, theme tokens, edit values (read contract), save/restore of registered saved variables. Without Core, each addon runs with its own defaults. |
| Plan :429 | One code-logic review for the strip, plus one adversarial check: has a heavy item crept in? |
| Plan :448 | Codex game check: the clock, FPS/latency, gold, durability and bag values; switching off; relog. |
| `Claude/results/REQUEST_LEDGER_phase8.md:14` (R101) | User's words: "애드온은 적을수록좋으니까". |
| `Claude/results/REQUEST_LEDGER_phase8.md:20` (R107 ⑤) | User's words: "상태 띠 중에 무거운건 빼고 넣는게 어떨까?" |
| Step 5 layout (`Codex/docs/devil-ui-old-4k-layout.md:27–29,73`) | At 3840×2160 the 8px bottom margin sits under the 28px status band (y 2124–2152). Status text uses the 22px size of the chosen font. |

---

## 1. Items

### 1.1 Choice of clock: local time

The strip shows **local time**: the PC clock, read with `date()`. **A1 judgment.** The reasons:

1. The game already shows a clock. The collection's SexyMap defaults keep the minimap clock (`TimeManagerClockButton`) visible "always" (`Collection/AddOns/!DevilForever_Core/Defaults/SexyMap.lua:70`, **confirmed**). If the strip showed realm time and the minimap clock did too, the item would duplicate a game feature, which R101 argues against.
2. Local time needs no server data. It is right from the first frame after login.
3. `date()` per minute is the cheapest source.

Realm time stays available. `GetGameTime()` is used by a Forever-only build (`UP/kaliels-tracker-8.11.1-forever/!KalielsTracker/Core/Modules/Filters.lua:368`, **confirmed**). Switching to realm time changes one function, so it is listed as an alternative in the Decision Queue (DQ-2).

### 1.2 Per-item design

"Tick" means the shared 1 s ticker (section 2). Text formats are exact, and 28b tests them. Labels come from a two-row table (koKR, default) chosen by `GetLocale()`. FPS and ms are units, not labels, so they stay the same in every locale. A value that is unavailable shows `-` (ASCII), so no glyph is needed that the koKR font might lack (**A1 judgment**).

| Item (key) | API | Update trigger | Format (koKR / other) | Cost per update |
|---|---|---|---|---|
| Gold (`gold`) | `GetMoney()` returns copper | Event `PLAYER_MONEY`. Also at every `PLAYER_ENTERING_WORLD` (PEW), plus one refresh 5 s after PEW | Gold > 0: `1,234g 05s 07c`. Gold = 0 and silver > 0: `5s 07c`. Otherwise `7c`. The letters g, s and c carry the coin colours `|cffffd700`, `|cffc7c7cf` and `|cffeda55f` (V42 Broker_Money `core.lua:228–230`). Gold is grouped with `,` by our own function, so no client helper is needed. | 1 API call, about 4 `string.format` calls. Runs on events only. |
| Durability (`durability`) | `GetInventoryItemDurability(slot)` returns `cur, max`, or nil when the slot has no durability | Events `UPDATE_INVENTORY_DURABILITY` and `PLAYER_EQUIPMENT_CHANGED`. Also at PEW and at PEW + 5 s | `내구 87%` / `Dur 87%`. The value is the **lowest** `floor(cur/max*100)` over slots with `max > 0`. With no such slot: `내구 -` / `Dur -`. | Up to 18 API calls. Runs on events only. |
| Free bag slots (`bags`) | `C_Container.GetContainerNumFreeSlots(bag)` returns `free, family`. Fall back to the global `GetContainerNumFreeSlots`. | Event `BAG_UPDATE_DELAYED`, plus `BAG_CONTAINER_UPDATE` registered under pcall (확인 필요). Also at PEW and at PEW + 5 s | `가방 23` / `Bags 23`: the sum of `free` over bags `BACKPACK_CONTAINER (0) .. NUM_BAG_SLOTS (4)`, counting only `family == 0` (general bags). With neither API: `가방 -`. | 5 API calls. Runs on events only. |
| Clock (`clock`) | `time()` detects the minute change. `tonumber(date("%H"))` and `tonumber(date("%M"))` read the time. | Tick. `date()` runs only when `floor(time()/60)` changes, with a forced refresh every 60 ticks. | 24 h: `09:05`. 12 h, koKR: `오전 12:05` / `오후 9:05`. 12 h, other: `12:05 AM` / `9:05 PM`. Hour 0 shows as 12 AM and hour 12 as 12 PM. | 1 `time()` per tick. `date()` twice a minute. |
| Latency (`latency`) | `GetNetStats()`: the 3rd return is home ms and the 4th is world ms | Every 30th tick, plus once at PEW. The client itself refreshes these values about every 30 s. | `38/41 ms`, meaning home/world, each `floor()` | 1 API call per 30 s |
| FPS (`fps`) | `GetFramerate()` | Every tick | `60 fps`, using `floor()` | 1 API call and 1 `floor` per second |

**After every update:** the item calls `fontString:SetText(text)` only when `text` differs from the last text set. An unchanged value costs no layout work (**A1 judgment**).

**Durability slot range.** Use `INVSLOT_FIRST_EQUIPPED .. INVSLOT_LAST_EQUIPPED` when both globals are numbers. Otherwise use `1 .. 18`.
- Details' Forever build loops over these globals (`UP/Details-…/Details/core/plugins_statusbar.lua:1285`; the Forever TOC `Details_Camelot.toc` lists `core\plugins_statusbar.lua` at line 212).
- Titan scans slots 18 down to 1 when the build number is below 40000, which includes 16001 (`UP/titan-panel-9.3.7/Titan/TitanGlobal.lua:38–42`, `TitanRepair/TitanRepair.lua:61–66`).

Both are **confirmed** as code. That the Forever client defines `INVSLOT_*` is **inferred**: Details runs that loop under its 16001 TOC.

**Why the lowest slot and not the average:**
- Leatrix (`Leatrix_Plus.lua:8764–8785`) shows a total-weighted average.
- Details (`plugins_statusbar.lua:1285–1299`) shows a per-item mean.

Repair need is decided by the worst item, so the order asks for the minimum. **A1 judgment**, matching the Step 28a order.

**Bags.** Bags with a non-zero family, such as quivers, ammo pouches and profession bags, are left out. Bagnon does the same in its broker (`UP/bagnon-12.1.11/BagBrother/core/features/brokerPlugin.lua:37–42`). Forever has ammo and quivers because the client is below 40000 (TitanGlobal.lua:39–40), so this matters here (**inferred**).

**Why PEW + 5 s.** Details reschedules its durability read 5 s later when no item reports durability yet (`plugins_statusbar.lua:1296`). It reads gold 10 s after PEW (`:1390`). One delayed refresh per PEW covers data that arrives late. A flag guards against stacked timers. **A1 judgment**, following that precedent.

### 1.3 API evidence (Forever)

"Forever-only" means a TOC that lists only 16001. "Multi" means a TOC that lists 16001 among other interfaces, so the line may sit on a branch that Forever does not take. Titan's branches were checked where it mattered.

| Item | API / event | Evidence (file:line) | Tier |
|---|---|---|---|
| FPS | `GetFramerate()` | `UP/leatrix-plus-1.60.31-forever/Leatrix_Plus/Leatrix_Plus.lua:21132` (Forever-only TOC, `Leatrix_Plus.toc:1`) · `UP/Details-Details.20261109.15410.172/Details/core/plugins_statusbar.lua:1209`, 1 s timer `:1217` (`Details_Camelot.toc` Interface 16001) · `UP/titan-panel-9.3.7/TitanPerformance/TitanPerformance.lua:321` (multi) · `V42/shPerformance/shPerformance.lua:126` | confirmed |
| Latency | `GetNetStats()` → `in, out, home, world` | `UP/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Elements/Castbar.lua:117` (`_, _, home, world`; Forever-only TOC) · `TitanPerformance.lua:340–341` (names all four returns) · `plugins_statusbar.lua:1245`, 30 s timer `:1254` · `V42/shPerformance/shPerformance.lua:139`, comment on the slow client refresh `:142` | confirmed |
| Gold | `GetMoney()` | `UP/kaliels-tracker-8.11.1-forever/!KalielsTracker/Mainline/Base/QuestObjectiveTracker.lua:360` (Forever build) · `plugins_statusbar.lua:1368` · `UP/titan-panel-9.3.7/TitanGold/TitanGold.lua:146` · `V42/Broker_Money/core.lua:429` | confirmed |
| Gold | event `PLAYER_MONEY` | `plugins_statusbar.lua:1386` · `V42/Broker_Money/core.lua:449` | confirmed |
| Durability | `GetInventoryItemDurability(slot)`, nil when the slot has none | `Leatrix_Plus.lua:8764–8765` (`if duraval ~= nil`; Forever-only) · `UP/titan-panel-9.3.7/TitanRepair/TitanRepair.lua:338–339` (`if minimum and maximum`) · `plugins_statusbar.lua:1286–1287` | confirmed |
| Durability | `INVSLOT_FIRST_EQUIPPED` / `INVSLOT_LAST_EQUIPPED` | `plugins_statusbar.lua:1285` (Details Forever TOC) · fallback 1..18 from `TitanRepair.lua:61–66` with `TitanGlobal.lua:38–42` | confirmed as code · client globals inferred |
| Durability | event `UPDATE_INVENTORY_DURABILITY` | `plugins_statusbar.lua:1315` · `TitanRepair.lua:537` · named in Leatrix's event filter `Leatrix_Plus.lua:20393` (Forever-only) | confirmed |
| Durability | event `PLAYER_EQUIPMENT_CHANGED` | `UP/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Elements/WeaponEnchants.lua:208–210` (Forever-only; registered under `pcall`) | confirmed (the event name). That it fires is 확인 필요, because FUF also guards it with pcall. |
| Bags | `C_Container.GetContainerNumFreeSlots(bag)` → `free, family` | `UP/titan-panel-9.3.7/TitanBag/TitanBag.lua:155` · `UP/baganator-862/Baganator/Sorting/BagUsageChecks.lua:23` (`_, family`) · `UP/xloot-12.23.0/XLoot_Frame/Frame.lua:52` (C_Container with global fallback), `:1431–1433` (loop `0 .. NUM_BAG_SLOTS`, `open, family`) · `brokerPlugin.lua:37–42` (`BACKPACK_CONTAINER .. NUM_BAG_SLOTS`, `family == 0`) | confirmed (all multi TOCs). `C_Container.GetContainerNumSlots` in a Forever-only file: `Leatrix_Plus.lua:7955`, `:20933` |
| Bags | event `BAG_UPDATE_DELAYED` | `UP/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Raid/BuffWatch.lua:420` (Forever-only) · `UP/bagnon-12.1.11/BagBrother/core/api/events.lua:43` | confirmed |
| Bags | event `BAG_CONTAINER_UPDATE` | Only `TitanBag.lua:527` (multi) | **확인 필요**. Register under pcall. |
| Clock | `date("%H")`, `date("%M")` | `UP/titan-panel-9.3.7/TitanClock/TitanClock.lua:87` (multi; the "Local" branch has no flavour switch) · `UP/basic-minimap-v12.1.6/BasicMinimap/BasicMinimap.lua:258` (loaded only for game type mainline, `BasicMinimap.toc:29`) · `UP/Prat-3.0-3.9.117/Prat-3.0/modules/Timestamps.lua:250` (`date(format, GetServerTime())`; Prat TOC 16001) | confirmed as code. Whether Forever counts as "mainline" is 확인 필요 (plan :230 also leaves this open for Mapster). Titan and Prat do not depend on it. |
| Clock | `time()` | `UP/kaliels-tracker-8.11.1-forever/!KalielsTracker/Core/System/Tracker.lua:231` (Forever build) · `UP/Prat-3.0-3.9.117/Prat-3.0/modules/Filtering.lua:131` | confirmed |
| Clock (alternative) | `GetGameTime()` | `Filters.lua:368` (Kaliel Forever build) · `TitanClock.lua:56` | confirmed |
| Clock (alternative) | CVars `timeMgrUseLocalTime`, `timeMgrUseMilitaryTime` | `BasicMinimap.lua:257,263` only (mainline-only file) | 확인 필요 |
| Ticker | `C_Timer.NewTicker`, `ticker:Cancel()` | `Leatrix_Plus.lua:1978–1979`, `:6059–6065` (Forever-only) | confirmed |
| Ticker | `C_Timer.After` | `Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua:215` (our code) · `BasicMinimap.lua:255` | confirmed as code |
| Fallback font | `CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")` | `Leatrix_Plus.lua:1016` (Forever-only) | confirmed |
| Locale | `GetLocale()` | `Leatrix_Plus.lua:17` · `ChatSetup.lua:57` | confirmed |
| Slash command | `SlashCmdList[...]` | `Leatrix_Plus.lua:4542` · `Collection/AddOns/PitBull4/Options/Options.lua:37` | confirmed |
| Coin colours | `|cffffd700` / `|cffc7c7cf` / `|cffeda55f` | `V42/Broker_Money/core.lua:228–230` | confirmed (text colour codes only) |

**Not found:**
- A Forever API dump in the repo. The searches covered `*api*` files outside upstream; Hekili only mentions "the Forever API data" at `Hekili_Warrior/Warrior.lua:158`.
- A clock, durability or bag plugin in V42 ChocolateBar. Its modules are Launchers, GameMusic, TestNoText, MoreChocolate, Placeholder, PlayedTime, MicroMenu and ItemLevel, and none of them contains `durab`, `GetGameTime`, `FreeSlots` or `date(`. `Broker_MicroMenu.lua:90–91` reads FPS and latency only.

---

## 2. Update model

| Group | Driver | Interval / events | Runs in combat |
|---|---|---|---|
| Timed: clock, FPS, latency | **One** `C_Timer.NewTicker(1.0, Tick)` | FPS every tick. Latency every 30th tick. Clock only when the minute changes (`floor(time()/60)` differs), with a forced refresh every 60 ticks to catch time-zone and daylight-saving jumps. | Yes, at constant cost: 2–3 C calls, 1–2 number compares and no table allocation per tick |
| Event: gold, durability, bags | Our own event frame | The events listed in section 1.2. PEW refreshes all of them, and PEW + 5 s refreshes them once more. | Yes. Each event costs 1 to 18 API calls. |

### 2.1 Rules for 28b

1. **The ticker exists only when needed.** It runs while at least one timed item is on and the strip frame is shown.
   - `OnHide` of the strip frame cancels it, for example when `UIParent` is hidden.
   - `OnShow` restarts it.
   - Switching off the last timed item cancels it. Switching one back on starts it.
2. **Each item registers its events only while it is on.** Switching an item off unregisters events no other enabled item needs. A switched-off item calls no API.
3. **Register each item event with `pcall(frame.RegisterEvent, frame, event)`.** FUF does the same on Forever (`WeaponEnchants.lua:208–210`). A failed registration goes into an in-memory status list that `/dfstatus` prints, and the item still works from PEW and the ticker.
4. **No `OnUpdate` script.** An OnUpdate script would run Lua on every frame.
   - shPerformance (V42) used OnUpdate with an elapsed counter (`shPerformance.lua:122–144`). A 1 s ticker calls Lua 1 time a second instead of 60–144 times.
   - **inferred** cost comparison.
5. **Text compare before `SetText`.** See section 1.2.
6. **No extra work at combat start or end.** The strip registers neither `PLAYER_REGEN_DISABLED` nor `PLAYER_REGEN_ENABLED`.

**Interval choice.** 1 s matches Details' FPS timer (`plugins_statusbar.lua:1217`). Latency at 30 s matches Details (`:1254`) and the client's own refresh, noted at `shPerformance.lua:142`. The shPerformance note "ANYTHING UNDER 2 will likely effect performance" (`:13`) is about its memory tooltip, which walks every addon (`:215`). The strip has no such work, so 1 s is safe. **A1 judgment.**

### 2.2 Taint and protected frames

Nothing here is protected.

| Rule | Reason |
|---|---|
| No secure templates, no `SecureHandler*`, no protected functions, no `SetCVar` | The strip only reads values. |
| No `hooksecurefunc` and no `HookScript` on any Blizzard frame, and no replaced Blizzard globals | FUF notes that "No hooksecurefunc on a frame (in Forever it breaks Blizzard's own code)" (`UP/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/BlizzardFonts.lua:13–14`, **confirmed**). |
| Globals limited to the names in section 4.1 | No collision with Blizzard names. Every name carries the `DevilForever_StatusStrip` prefix. |
| Strip frame: `EnableMouse(false)`, strata `LOW`, parent `UIParent` | It never blocks clicks on the bars around the band, and it hides with the UI (Alt+Z). |
| **Brief Codex:** do not anchor protected frames (Dominos bars and the like) to the strip frame, and do not anchor the strip into a protected frame chain | Moving an insecure frame that a protected frame depends on, during combat, is the classic source of "action blocked" errors. Keeping the anchor graph separate avoids it. **inferred** from the general client rule; whether Forever enforces this exactly is 확인 필요. |
| Edit values that Codex applies during combat are held by Core until `PLAYER_REGEN_ENABLED` (`Collection/AddOns/!DevilForever_Core/Edit.lua:20–23`) | The strip itself is not protected and would allow the change. The hold is harmless. |

---

## 3. Placement decision

### (a) Optional module inside `!DevilForever_Core`

- **Gains:**
  - The addon count does not grow (R101, as plan :150 reads it).
  - The strip can reuse `Core:On` and `Core.NewCallbackList` (`Core.lua:70–129`).
- **Costs:**
  1. **It breaks the R44/R60 reading in plan :141.** "Selection means switching the AddOn itself on or off, not hiding its display." Core is the required bundle (`Registry.lua:8` `bundle = "required"`; `genregistry.py:158`), so the strip could only be hidden by a setting. That is exactly the "표시 끄기" that plan :141 rules out.
  2. **It breaks Core's own contract.**
     - `Core.lua:3` says "Core changes no frame itself; it only stores data and calls back".
     - `API.lua:74` says "Core changes no frame".
     - A strip module creates frames and a ticker inside every combination of the collection.
  3. **It needs a new settings area in `DevilForever_CoreDB`.**
     - The DB layout at `Core.lua:212–220` holds only `schema/defaults/theme/edits`.
     - Registry edit fields cannot store on/off flags. The fields are `position, size, font, color, rows, spacing` (`Edit.lua:32`; `genregistry.py:62`).
     - The change touches Core's saved-variable layout, which Phase 20 restore depends on.
  4. **It reopens a reviewed module.**
     - The Core is reviewed under the "새 구조 모듈: Core" row of the Test Plan, with 3 rounds (plan :426).
     - Adding a module would pull Core back into that review.
     - A strip bug would then live inside the one addon every user must load.
- **Estimated size:** about 330 lines of strip code, plus edits to Core.lua, API.lua and the Core TOC, plus Core test updates.

### (b) One small addon `DevilForever_StatusStrip`

- **Gains:**
  1. It is selectable in the AddOn list, as plan :141 requires.
  2. It is independent of Core. With no Core and no Codex code it still shows plain text at the bottom of the screen, as plan :404 requires ("Core 가 없으면 각 애드온은 자기 기본 동작·외관으로 동작한다").
  3. **The registry and build pick it up from its TOC with no tool change.**
     - The registry reads it through `own_addon_entries` (`genregistry.py:140–168`), giving bundle `individual`, use `new` and saved variables from the TOC.
     - The build (`Collection/tools/build.py:6`) takes every folder under `Collection/AddOns/`.
  4. **It follows established precedent.** Three small own addons already ship: `DevilForever_Castbars`, `DevilForever_ChatSetup` and `DevilForever_FUFDefaults`. Each is 170–233 lines.
- **Costs:** +1 addon. The collection's own addons become Core plus four.
- **Why R101 is still met:**
  1. R101 asks for no new addon when the game or an addon already in the collection does the job. Nothing in the collection shows gold, FPS, latency, durability and free bag slots together. Titan Panel was removed by R107 ⑤.
  2. Plan row 16 itself calls the work "새 개발 (작은 정보 부분)", meaning a feature rather than a linking addon.
  3. Against V42, which had ChocolateBar plus Broker_Money, shPerformance and two durability brokers (`!DevilUI/Profile/ChocolateBar.lua:1615,1618,1879,1884,1898`), one addon replaces four or more. The net count goes down.

### Recommendation: **(b)** — A1 judgment

R44/R60 has a hard reading in the plan: selection is by AddOn. Core's no-frame contract is a reviewed interface. Option (a) violates the first and erodes the second just to save one folder. R101's purpose, no needless addons, is still served, because no existing addon covers the job and the one new addon replaces a V42 bundle. **The master decides** (DQ-1).

If the master picks (a) anyway, these changes are needed:
- the module file goes last in the Core TOC;
- the settings go in `DevilForever_CoreDB.statusStrip = {enabled = true, items = {...}, clock24 = true}`, with `Core.lua` `DB_LAYOUT` extended (schema stays 1, because FillMissing adds the new key);
- the Core API doc gains the section 4.2 API under `Core.StatusStrip`;
- plan :141 needs a written exception, which the master raises with the user.

---

## 4. Interface for Codex (option b)

### 4.1 Global names

| Global | Kind | Note |
|---|---|---|
| `DevilForever_StatusStrip` | table | The public API (section 4.2) |
| `DevilForever_StatusStripFrame` | Frame | The strip, parent `UIParent` |
| `DevilForever_StatusStripGold` | FontString | Child of the strip frame |
| `DevilForever_StatusStripBags` | FontString | Child of the strip frame |
| `DevilForever_StatusStripDurability` | FontString | Child of the strip frame |
| `DevilForever_StatusStripClock` | FontString | Child of the strip frame |
| `DevilForever_StatusStripLatency` | FontString | Child of the strip frame |
| `DevilForever_StatusStripFPS` | FontString | Child of the strip frame |
| `DevilForever_StatusStripDB` | saved variable | `## SavedVariables` (account) |
| `SLASH_DEVILFOREVERSTATUS1`, `SlashCmdList.DEVILFOREVERSTATUS` | slash command `/dfstatus` | DQ-4 |

**Rules for the frames:**
- All six FontStrings are created once, at file load, with `strip:CreateFontString(<name>, "OVERLAY", "GameFontHighlightSmall")`. A switched-off item is hidden, not destroyed, so a font Codex applied once stays applied.
- **Item order is fixed in code:** `gold, bags, durability, clock, latency, fps`. Items whose width changes most often go last, so their width changes do not shift the others. **A1 judgment.**

**Built-in look** (no Codex code, or no Core):
- two points, `BOTTOMLEFT` and `BOTTOMRIGHT` of `UIParent`;
- height 20, no background texture;
- items anchored left to right with spacing 12;
- the addon draws nothing else.

**Built-in layout:**
- the first shown item is anchored `LEFT` to the strip's `LEFT` at `x = spacing`;
- each next shown item is anchored `LEFT` to the previous item's `RIGHT` at `x = spacing`;
- the layout runs at load, on every item on/off, and on `SetSpacing`.

### 4.2 API (for Codex appearance code and the slash command)

```
DevilForever_StatusStrip.version            = 1
DevilForever_StatusStrip:GetFrame()         -> the strip Frame
DevilForever_StatusStrip:GetFontString(key) -> FontString | nil      (key: "gold"|"bags"|"durability"|"clock"|"latency"|"fps")
DevilForever_StatusStrip:ListItems()        -> {{key, enabled, shown}, ...} in display order (copy)
DevilForever_StatusStrip:GetValue(key)      -> value|nil, text   (gold copper, durability %, bags free, clock "HH:MM" 24h, latency home, world, fps)
DevilForever_StatusStrip:SetSpacing(px)     -> true | false, reason   (number >= 0; re-runs the layout; session only)
DevilForever_StatusStrip:IsItemEnabled(key) -> bool
DevilForever_StatusStrip:SetItemEnabled(key, on) -> true | false, reason   (writes the saved variable, re-layouts, starts/stops ticker and events)
DevilForever_StatusStrip:SetClock24(on)     -> true | false, reason
DevilForever_StatusStrip:RegisterCallback(owner, fn) / :UnregisterCallback(owner)
    fn("LAYOUT", shownKeys)  -- after every layout run; shownKeys = ordered list copy
```

The latency `GetValue` returns `home, world, text`.

**How appearance code gets the values:**
- It reads tokens and edit values through Core (`Core.Edit:Get("statusstrip.bar")` and `Core.Theme:Get`) and applies them itself, as for any other registered frame (plan :405, :408):
  - `position` and `size` go onto `GetFrame()`;
  - `font` and `color` go onto each of the six `GetFontString(key)`;
  - `spacing` goes to `SetSpacing(px)`;
  - background, border and divider art go on its own textures or kgPanels panels behind the strip.
- **The strip addon never reads Core edit values or tokens.** Appearance stays with Codex (R87), and the addon stays independent of Core.
- **The `LAYOUT` callback** runs after the addon's own anchoring. Codex can put dividers between shown items there. It may re-anchor the FontStrings there, because they are insecure.
- **No value callback exists.** A per-second callback would add cost on every tick. Codex does not need values, because the FontStrings already carry the text. Colouring by value is DQ-5.
- **The callback list is the strip's own copy** of the `Core.NewCallbackList` pattern: one function per owner, `pcall`, errors to `geterrorhandler()` (`Core.lua:62–102`).

### 4.3 Registry entry (`registry_extra.json`, added by 28b)

```json
"DevilForever_StatusStrip": {
  "frames": [
    {"key": "statusstrip.bar", "frame": "DevilForever_StatusStripFrame",
     "tokens": {"font": "font.number", "color": "color.text.normal", "spacing": "spacing.default"}},
    {"key": "statusstrip.gold", "frame": "DevilForever_StatusStripGold"},
    {"key": "statusstrip.bags", "frame": "DevilForever_StatusStripBags"},
    {"key": "statusstrip.durability", "frame": "DevilForever_StatusStripDurability"},
    {"key": "statusstrip.clock", "frame": "DevilForever_StatusStripClock"},
    {"key": "statusstrip.latency", "frame": "DevilForever_StatusStripLatency"},
    {"key": "statusstrip.fps", "frame": "DevilForever_StatusStripFPS"}
  ],
  "editable": [
    {"frame": "statusstrip.bar", "field": "position"},
    {"frame": "statusstrip.bar", "field": "size",    "min": 8, "max": 8192},
    {"frame": "statusstrip.bar", "field": "font",    "min": 6, "max": 64},
    {"frame": "statusstrip.bar", "field": "color"},
    {"frame": "statusstrip.bar", "field": "spacing", "min": 0, "max": 128}
  ],
  "saved_variables": {"DevilForever_StatusStripDB": {"split": "common"}}
}
```

| Point | Reason |
|---|---|
| Edit items sit on the bar only, and one style applies to all six texts | This keeps the AI-editable surface small, in line with R107 ⑥. Per-item fonts or colours can be added later without changing the code contract. **A1 judgment** |
| `size` uses one min/max for both width and height (`Edit.lua:90–93`; `genregistry.py:205–208`) | `min` must stay at or below the smallest height and `max` at or above the widest width. At 4K with pixel-exact scale, UIParent is about 3840 wide (**inferred**). 8192 covers ultrawide. 8 covers a thin strip. |
| `font` min/max bound `font.size` only (`Edit.lua:94–98`) | The Step 5 status text is 22px at 4K (`devil-ui-old-4k-layout.md:73`). 6–64 covers FHD, QHD and UHD. |
| The `tokens` map sets the base token for `font.path` and `color` | The font size base is always `font.size.normal` (`Edit.lua:37,213–215`). Codex's preset or edit value sets the real size. |
| `genregistry.py` accepts this shape: frames with key, frame and tokens; editable frames that exist as frame keys; a saved variable named in the TOC (`genregistry.py:241–277`) | 28b runs `genregistry.py --check`. |

### 4.4 Theme tokens that apply (Theme.lua:23–44)

| Token | Use |
|---|---|
| `font.number`, `font.size.normal` (`font.size.small` if Codex prefers it) | Item text |
| `color.text.normal` | Item text |
| `color.text.highlight` | Optional: units or labels, if Codex splits colours |
| `color.panel.background`, `color.panel.border`, `texture.panel`, `border.size` | Strip background (Codex textures) |
| `color.divider`, `texture.divider` | Dividers between shown items (from the `LAYOUT` callback) |
| `spacing.default` | Item spacing base |

`color.text.disabled` and the ornament and status-bar textures are not used.

### 4.5 Placement in the Step 5 band (Codex)

Codex places `DevilForever_StatusStripFrame` in the Step 5 lower status band: 28px tall, above the 8px bottom margin, y 2124–2152 at 3840×2160 (`Codex/docs/devil-ui-old-4k-layout.md:27–29`). It does so through the `statusstrip.bar` position, size and font values of each preset (FHD, QHD, UHD), per R107 ⑥. The addon's built-in two-point bottom anchor is only the fallback.

---

## 5. Saved settings

```lua
DevilForever_StatusStripDB = {
  schema  = 1,
  items   = {gold = true, bags = true, durability = true, clock = true, latency = true, fps = true},
  clock24 = true,
}
```

Seven flags in all, which is the minimum the order asks for: item on/off, and 12/24 h for the clock.

**Scope.** Account (`## SavedVariables`) with split `common`. The same strip appears on every character. Nothing is per class. **A1 judgment.**

**Defaults.** `clock24 = true` and every item on (**A1 judgment**; see DQ-3).

**Load (`ADDON_LOADED` for the addon itself):**
1. When the saved variable is nil, create it from `DEFAULTS` (a deep copy).
2. When it is not a table, use defaults for this session only, leave the disk value alone, and note it in the status list.
3. When `schema` is a number greater than 1 (an unknown version), leave the table untouched, use defaults for this session only, and note it. This follows Phase 20's rule: data of an unknown version is never reset silently (plan row 20).
4. Otherwise fill keys whose value is `nil` from `DEFAULTS`, recursing into `items`, and keep every stored value and every unknown key.
5. At read time, a flag that is not a boolean counts as its default for the session and is left on disk as it is.

This mirrors `Core.FillMissing` (`Core.lua:29–46`) without depending on Core.

**Core Defaults: none.**
- Core's defaults injection (`Defaults.lua:1–85`) exists to put collection values into third-party addons' saved variables.
- The strip is our own addon, so its built-in `DEFAULTS` are the collection defaults. A `Defaults/DevilForever_StatusStrip.lua` file would be a second source for the same values.
- For a fresh saved variable it would also rewrite the same values at the first PEW (first-load mode, `Defaults.lua:22–26`).
- So registry_extra gets no `defaults` key and the Core TOC is unchanged. **A1 judgment.**

**Phase 20.** The saved variable is listed in the registry through the TOC (`genregistry.py:92–101`), so save and restore cover it. A restore takes effect at the next load.

**Changing settings.** Use `/dfstatus` (DQ-4):

| Command | Effect |
|---|---|
| `/dfstatus` | Prints each item's on/off state, the clock mode and any event-registration failures. |
| `/dfstatus <item> on|off` | Switches one item on or off. |
| `/dfstatus clock 12|24` | Sets the clock mode. |

There is no options panel: R107 ⑥ says the user changes things through AI. Switching the whole strip off is done in the AddOn list, per plan :141.

---

## 6. Excluded (heavy or duplicate)

| Excluded | Reason |
|---|---|
| Currency list | Iterating all currencies, listening to their update events and building a tooltip is heavier than a text read. The game's currency tab already shows them (R101). The Forever currency API was not checked: 확인 필요 if it is ever wanted. |
| LDB plugin host (a ChocolateBar or Titan kind of display) | It needs LibStub, CallbackHandler and LibDataBroker, plus a plugin registry, drag-and-drop and options. V42 ChocolateBar's own Lua outside its libs is about 8,200 lines, with Options.lua alone at 1,845 (line counts in this session). Broker_Money pulls in AceGUI, AceConfig and LibQTip, about 13,800 lines with its libs, to show one gold value. R107 ⑤ removes this whole class. |
| Guild and friends lists | Roster updates arrive often and need roster requests, long tooltips and per-member data. The game's social window covers them (R101). V42 used Ara Guild and Friends (`!DevilUI/Profile/ChocolateBar.lua` Wide_T objSettings, read by machine). |
| Memory per addon | `UpdateAddOnMemoryUsage()` walks every addon (`V42/shPerformance/shPerformance.lua:215,276`). The author warns about update periods under 2 s (`:13`). shPerformance also forces `collectgarbage("collect")` (`:70,275`), which causes frame hitches. |
| Tooltips (realm time, bandwidth, per-slot durability, gold per character) | They need mouse-enabled frames and GameTooltip ownership. Gold per character needs a cross-character database that grows with every character (`V42/Broker_Money/core.lua:196–208,435`). Not in v1 (DQ-6). |
| Repair cost and auto-repair | They need cost and merchant scans across slots: TitanRepair is 1,403 lines. Selling junk is a feature Titan says does not work on Forever (`Claude/results/handoffs/addon-survey/features.md:239`). This is feature creep. |
| Experience and reputation | Phase 19 owns them (Experience Forever). A second display would be a duplicate. |
| Coordinates, zone, location | SexyMap already shows zone text and coordinates (registry frames `sexymap.zonetext` and `sexymap.coordinates`, `registry_extra.json`). Coordinates also need per-frame updates. |
| Played time | It asks the server and prints to chat (V42 `ChocolateBar/modules/CB_PlayedTime.lua`), a visible side effect. |
| Launchers, micro menu, volume, item level | The game and Dominos' menu bar already cover them (R101). |
| Ammo count | It is light, and Forever has ammo (TitanGlobal.lua:39–40). The plan's item list does not include it. Not added (DQ-7). |

The adversarial check at plan :429 can use this table: any API outside section 1.3 in the 28b code is a finding.

---

## 7. Test plan for 28b

The tests go in `Collection/tests/statusstrip/run.py` and follow the layout of `Collection/tests/chatsetup/run.py`: a fresh `lupa.lua51` runtime per case and stubs for every client call. They check the addon's logic only.

**Stubs:**
- `CreateFrame`, returning frames with `RegisterEvent` (it raises for names a case marks unknown, to test pcall), `UnregisterEvent`, `SetScript`, `GetScript`, `CreateFontString`, `SetPoint`, `ClearAllPoints`, `Show`, `Hide`, `IsShown`, `SetHeight`, `SetFrameStrata` and `EnableMouse`;
- FontStrings with `SetText` that counts its calls, plus `GetText`, `Show`, `Hide`, `SetPoint` and `ClearAllPoints`;
- `UIParent`;
- `C_Timer.NewTicker`, returning a handle with `Cancel` and test-driven ticks, and `C_Timer.After`, queued;
- `GetFramerate`, `GetNetStats`, `GetMoney` and `GetInventoryItemDurability`;
- `C_Container.GetContainerNumFreeSlots` (each case can remove it to test the global fallback);
- the globals `INVSLOT_FIRST_EQUIPPED`, `INVSLOT_LAST_EQUIPPED`, `BACKPACK_CONTAINER` and `NUM_BAG_SLOTS` (each case can remove them);
- `GetLocale`, `date`, `time`, `InCombatLockdown`, `SlashCmdList`, `print` and `geterrorhandler`;
- `hooksecurefunc`, stubbed to **raise**, and `SetCVar`, stubbed to raise.

| # | Area | Cases (expected) |
|---|---|---|
| 1 | Money format | 0 → `0c`. 7 → `7c`. 507 → `5s 07c`. 10000 → `1g 00s 00c`. 12345678 → `1,234g 56s 78c`. 1000000000 → `100,000g 00s 00c`. Each case is checked with the colour codes stripped and also verbatim. `GetMoney` nil → `-`. |
| 2 | Grouping | 999 → `999`. 1000 → `1,000`. 1234567 → `1,234,567`. |
| 3 | Durability minimum | {1:(50,100), 5:(10,80), 16:nil} → `12%` (floor of 12.5). All nil → `-`. A slot with max 0 is skipped. All full → `100%`. With `INVSLOT_*` removed, the fallback range 1..18 is used, checked by counting calls. |
| 4 | Bag sum | Bags 0–4, families {0,0,8,0,0}, free {5,3,9,0,2} → `10`, because family 8 is skipped. With `C_Container` removed, the global function is used. With both removed → `-`. |
| 5 | Clock | 24 h: 9:05 → `09:05`. 12 h koKR: 0:05 → `오전 12:05`, 12:00 → `오후 12:00`, 21:05 → `오후 9:05`. 12 h enUS: 21:05 → `9:05 PM`. |
| 6 | Latency and FPS | `GetNetStats` → (0, 0, 38.6, 41.2) gives `38/41 ms`. `GetFramerate` 59.7 gives `59 fps`. |
| 7 | Throttle | Over 61 ticks: `GetFramerate` is called 61 times. `SetText` on the FPS string fires only when the value changes, so a constant value means 1 call. `GetNetStats` is called 3 times: PEW, tick 30 and tick 60. `date` runs only on minute changes driven by the `time()` stub, plus once at tick 60. With combat on through the `InCombatLockdown` stub the call counts are the same. |
| 8 | Ticker life | Timed items all off → no ticker. Switching one on → a ticker. Strip `OnHide` → `Cancel`. `OnShow` → a new ticker. At most one live ticker at any time. |
| 9 | Item toggles | When an item is off: its FontString is hidden, its API is never called, and its events are unregistered (gold off means `PLAYER_MONEY` is not registered). Re-layout anchors skip hidden items. `LAYOUT` fires with the shown keys in order. A callback error goes to `geterrorhandler` and the other callbacks still run. |
| 10 | Settings | nil saved variable → defaults written. Partial table → missing keys filled and stored values kept. `items = "x"` → session defaults and the disk value unchanged. `schema = 2` → nothing written and defaults used. Flag `fps = "yes"` → treated as on and left on disk. Unknown keys survive. |
| 11 | Events | PEW refreshes all enabled items and queues one `C_Timer.After(5)`. A second PEW while that refresh is pending queues no second timer. An unknown event (`BAG_CONTAINER_UPDATE` marked unknown) does not stop loading and appears in the `/dfstatus` output. |
| 12 | Slash | `/dfstatus fps off` writes `items.fps = false` and hides the item. `/dfstatus clock 12` sets `clock24 = false`. A bad argument changes nothing and prints a usage line. |
| 13 | Safety | No `hooksecurefunc` or `SetCVar` call (the stubs would raise). Globals after load are only the section 4.1 set. The script diffs `_G` before and after load. |

The other gates in the phase16 detail plan stay as written: luacheck rc0, `genregistry.py --check`, and the build sha256.

---

## 8. File list for 28b and size estimate (option b)

| File | Kind | Est. lines |
|---|---|---|
| `Collection/AddOns/DevilForever_StatusStrip/DevilForever_StatusStrip.toc` | new | about 8: Interface 16001, Title, Notes, Version 0.1.0, `## SavedVariables: DevilForever_StatusStripDB`, file. No Dependencies or OptionalDeps, because nothing calls Core. |
| `Collection/AddOns/DevilForever_StatusStrip/StatusStrip.lua` | new | 320–400: header comment about 30, locale and formatters about 80, items about 70, layout and API about 70, events and ticker about 60, settings and slash about 60 |
| `Collection/AddOns/!DevilForever_Core/registry_extra.json` | edit | +about 50 |
| `Collection/AddOns/!DevilForever_Core/Registry.lua` | regenerate (`genregistry.py`) | +about 90, generated |
| `Collection/tests/statusstrip/run.py` | new | 450–550 |
| `Collection/codex-briefs/phase16.md` | new (game check, per plan :448 and the detail plan) | 70–100 |
| `Collection/codex-briefs/appearance-16.md` | new (appearance: sections 4.1–4.5, Step 5 band, the anchor rule from section 2.2) | 80–120 |

Hand-written total: about 1,000–1,230 lines, of which about 330–410 are addon code. No change to Core Lua, the Core TOC, `genregistry.py`, `build.py` or `manifest.json`: our own addons are taken from their TOC (`genregistry.py:140–168`, `build.py:6`).

**Items to include in the phase16 Codex game-check brief:**
- gold against the bag money display;
- durability against the character pane;
- free slots against the open bags;
- latency against the game menu or network display;
- FPS against the client's framerate display;
- clock against the PC clock;
- `/dfstatus` toggles and 12/24 h;
- AddOn off in the list;
- `/reload` and relog persistence;
- the `/dfstatus` line that lists failed event registrations, which settles `BAG_CONTAINER_UPDATE` and `PLAYER_EQUIPMENT_CHANGED`;
- BugSack clean through one combat.

---

## 9. Decision Queue

| ID | Point | A1 default (used in this design) | Alternatives |
|---|---|---|---|
| DQ-1 | Placement | (b) `DevilForever_StatusStrip` | (a) Core module, which needs a written exception to plan :141 and a Core re-review |
| DQ-2 | Clock source | Local time (`date`) | Realm time (`GetGameTime`). Or follow the game clock's own CVars `timeMgrUseLocalTime` and `timeMgrUseMilitaryTime` (evidence only in a mainline-only file, so 확인 필요), which also removes `clock24`. |
| DQ-3 | Clock item and default | Keep the clock on. `clock24 = true` | Default the clock off, or drop it, because the minimap clock is already shown "always" (`Defaults/SexyMap.lua:70`). Or default to 12 h. |
| DQ-4 | `/dfstatus` command | Include it (about 40 lines). It is the only way to toggle items or 12/24 h in game without an options UI. | No command: the user's AI edits the saved variable while logged out, per R107 ⑥. |
| DQ-5 | Warning colour (durability ≤ 20%, bags ≤ 2 free) | None in v1 | It needs a new token such as `color.text.warning`, which is not in `Theme.TOKENS` (Theme.lua:23–44). Adding one changes Core. Or the addon embeds a colour code, which puts appearance in the code against R87. |
| DQ-6 | Tooltips | None. The strip ignores the mouse. | A hover tooltip with realm time, home and world, and the worst slot. It needs `EnableMouse(true)` on item frames, so the strip could then catch clicks in the band. |
| DQ-7 | Ammo count (Forever has ammo) | Not included (outside the plan list) | Add an `ammo` item: one count read on `UNIT_INVENTORY_CHANGED`/`BAG_UPDATE_DELAYED`. The API is 확인 필요. |
| DQ-8 | Registry `phases` for own addons is always `[]` (`genregistry.py:157`) | Leave it | Extend the extras schema with `phases` so the strip shows Phase 16. This is a tool change. |
| DQ-9 | Item order | Fixed in code: gold, bags, durability, clock, latency, fps | Make the order a saved setting (more surface), or let Codex re-anchor in `LAYOUT`. |

---

## 10. Read ranges (this session)

| File | Range |
|---|---|
| `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` | 135–155, 225–232, 265–275, 395–415, 425–450 (and line hits for 28px/Step 5 via grep: 55, 123, 213, 289, 306, 338, 347, 352, 385, 487, 517) |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-phase16-세부계획.md` | 1–8 (all) |
| `Claude/results/handoffs/phase16/SESSIONS.md` | all |
| `Claude/results/REQUEST_LEDGER_phase8.md` | lines 14 (R101), 18–20 (R105–R107) |
| `Collection/AddOns/!DevilForever_Core/!DevilForever_Core.toc` | 1–19 (all) |
| `…/Core.lua` | 1–268 (all) |
| `…/API.lua` | 1–171 (all) |
| `…/Theme.lua` | 1–185 (all) |
| `…/Edit.lua` | 1–264 (all) |
| `…/Defaults.lua` | 1–509 (all) |
| `…/Registry.lua` | 1–80 (header and first entries), plus a grep of the top-level entry lines |
| `…/registry_extra.json` | 1–808 (1–140 verbatim, 140–808 compacted; structure checked by Python) |
| `…/Defaults/SexyMap.lua` | grep `clock`, line 70 |
| `Collection/tools/genregistry.py` | 1–390 (all) |
| `Collection/tools/build.py` | grep only (lines 6–10, 22, 52, 91, 99) |
| `Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua` | 1–233 (all) |
| `Collection/AddOns/DevilForever_{Castbars,ChatSetup,FUFDefaults}/*.toc` | all |
| `Collection/tests/chatsetup/run.py` | 1–60 · `Collection/tests/castbars/run.py` 1–30 |
| `V42/shPerformance/shPerformance.lua` | 1–279 (all) · its two TOCs (all) |
| `V42/Broker_Money/core.lua` | 1–455 (all) · its two TOCs (all) |
| `V42/ChocolateBar/ChocolateBar.toc` | all · `ForeverCompat.lua` 24–35 · modules grep for `durab`, `GetGameTime`, `FreeSlots`, `GetFramerate`, `GetNetStats` and `date(` |
| `V42/!DevilUI/Profile/ChocolateBar.lua` (1,918 lines, saved-variable data) | 1–40 and 1546–1567 verbatim. Profile keys outlined by grep. The `objSettings` of the `Wide` (38–387) and `Wide_T` (1568–1918) profiles were extracted by Python; key lines 1599, 1615, 1618, 1696, 1713, 1718, 1840, 1879, 1884, 1889 and 1898 were located by grep. |
| `UP/titan-panel-9.3.7/TitanClock/TitanClock.lua` | 1–200, 318–360, plus a grep of 140–564 |
| `UP/titan-panel-9.3.7/TitanRepair/TitanRepair.lua` | 55–70, 315–360, 525–560, plus a grep |
| `UP/titan-panel-9.3.7/TitanBag/TitanBag.lua` | 60–175, 510–545, plus a grep |
| `UP/titan-panel-9.3.7/Titan/TitanGlobal.lua` | 30–60 |
| `UP/leatrix-plus-1.60.31-forever/Leatrix_Plus/Leatrix_Plus.lua` | 8715–8830, 20375–20400, 20925–20940, 7950–7958, plus grep hits (1016, 1978–1979, 6059–6065, 4542, 17, 21132) · TOC 1–12 |
| `UP/Details-…/Details/core/plugins_statusbar.lua` | 1195–1330, 1355–1395, grep 880–960 · `Details_Camelot.toc` grep line 212 |
| `UP/basic-minimap-v12.1.6/BasicMinimap/BasicMinimap.toc` | all · `BasicMinimap.lua` 245–300 |
| `UP/bagnon-12.1.11/BagBrother/core/features/brokerPlugin.lua` | 1–47 (all) |
| `UP/xloot-12.23.0/XLoot_Frame/Frame.lua` | 1425–1440, plus line 52 |
| `UP/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/BlizzardFonts.lua` | 1–40 · `Elements/WeaponEnchants.lua` 205–212 · `Raid/BuffWatch.lua` 415–422 · `Core/Media.lua` 8–20 · `Elements/AuraButton.lua` 66–74 · TOC 1–5 |
| `Codex/docs/devil-ui-old-4k-layout.md` | 20–60, plus grep hits 18, 24, 29, 64, 73, 79, 105 |
| `Claude/results/handoffs/addon-survey/features.md` | lines 58, 139, 204, 239 |
| Other upstream lines cited in section 1.3 | single grep hit lines as cited |

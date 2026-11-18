# Work log — A2 coder, Phase 16 Step 28b (iter 1)

Role: work sub that writes the status strip addon, its tests, the registry entry, the ZIP rebuild and the two Codex briefs. Nothing committed, nothing deleted. `Collection/upstream/` was not opened. Temp output goes under the scratchpad (`mktemp -d`).

## Read ranges (input for this step)

| File | Range |
|---|---|
| `Claude/results/handoffs/phase16/design-28a.md` | 1–496 (all) |
| `Claude/results/handoffs/phase16/DECISIONS_28a.md` | 1–9 (all) |
| `Claude/results/handoffs/phase16/SESSIONS.md` | 1–8 (all) |
| `Claude/results/handoffs/phase16/iter_1/work_log-a1.md` | 1–29 (all) |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-phase16-세부계획.md` | 1–8 (all) |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` | lines 228, 429, 448 |
| `Collection/AddOns/!DevilForever_Core/API.lua` | 1–77 |
| `Collection/AddOns/!DevilForever_Core/Core.lua` | 25–130 (FillMissing, callback list, event frame — pattern only) |
| `Collection/AddOns/!DevilForever_Core/registry_extra.json` | 1–808 (all) |
| `Collection/tools/genregistry.py` | 1–390 (all) |
| `Collection/tools/build.py` | 1–144 (all) |
| `Collection/tools/luacheck.py` | 1–40 · `Collection/tools/tocdeps.py` 1–40 (usage) |
| `Collection/AddOns/DevilForever_ChatSetup/DevilForever_ChatSetup.toc` | 1–7 (all) · `ChatSetup.lua` 1–233 (all) |
| `Collection/tests/chatsetup/run.py` | 1–443 (all) |
| `Collection/tests/core/run.py` | 425–523 (generated registry case) plus a grep of names |
| `Collection/codex-briefs/phase14.md` | 1–77 (all) · `appearance-14.md` 1–34 (all) |
| `Collection/codex-briefs/*.md` | hash lines (grep of the old sha256: 24 files) |
| `Claude/results/handoffs/phase10/iter_1/work_log-a2.md` | grep of build / hash lines (precedent) |
| `.claude/tools/banned_lexicon.json` | all |

## Steps

| # | Step | Result |
|---|---|---|
| 1 | Baseline: `python3 -I Collection/tools/build.py --out-dir <scratch>/base.*` | `built folders=5 files=329 zip_entries=331`, sha256 `d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820` = the committed ZIP and the briefs |
| 2 | Baseline: `python3 -I Collection/tests/core/run.py` | `cases=61 passed=61 failed=0` |
| 3 | Wrote `Collection/AddOns/DevilForever_StatusStrip/DevilForever_StatusStrip.toc` (7 lines) and `StatusStrip.lua` (678 lines; header comment 1–69 holds the contract and the public API) | design §1, §2, §4.1–4.2, §5 with DECISIONS_28a (separate addon, local time, 24 h on, `/dfstatus`, no warning colour, tooltip or ammo) |
| 4 | Wrote `Collection/tests/statusstrip/run.py` (721 lines, 17 cases covering design §7 areas 1–13) · `python3 -I Collection/tests/statusstrip/run.py` | first run 15/17 (test helper compared Lua tables wrongly: `rel.name` on a converted dict, and `==` on two Lua wrappers); helper fixed (`rel["name"]`, `rawequal`) → `lupa=2.8 cases=17 passed=17 failed=0` |
| 5 | Added the `DevilForever_StatusStrip` entry to `registry_extra.json` (json round-trip of the old file gave identical bytes first; entry appended last, +70 lines) · `python3 -I Collection/tools/genregistry.py` ×2 · `--check` | both `wrote … (53260 bytes, sha256 24206f2c90bbb52c6a729aafd0cd3d95be667ab0dda6f1aa3df126909a21684e)` · `check …: up to date (53260 bytes)` rc0 |
| 6 | `python3 -I Collection/tests/core/run.py` | `generated_registry_lookup` failed: the all-frames list now holds the 7 strip frames (expected change). Updated that expectation and added strip asserts (frame keys, editable items on the bar only, bundle/use/defaults/SV) → `cases=61 passed=61 failed=0` |
| 7 | `python3 -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_StatusStrip 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` | rc0 `runtime=Lua 5.1 luajit=False lupa=2.8 checked=15 failed=0` |
| 8 | `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_StatusStrip` | rc0 `folders=2 unresolved=0 client_provided=0 optional_missing=0 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` |
| 9 | `python3 -I Collection/tools/build.py` and again with `--out-dir <scratch>` | both `built folders=6 files=331 zip_entries=333`, sha256 `120bc9748e264cd517b547675fb744552aa6bbe6d66425c3f003b20fea1c7407`; ZIP holds `Interface/AddOns/DevilForever_StatusStrip/{DevilForever_StatusStrip.toc,StatusStrip.lua}`; folders `!DevilForever_Core, DevilForever_Castbars, DevilForever_ChatSetup, DevilForever_FUFDefaults, DevilForever_StatusStrip, PitBull4` |
| 10 | Brief hash update (Python line replace in `Collection/codex-briefs/*.md`): old → new sha256; contents list `DevilForever_FUFDefaults/`, `PitBull4/` → `…, DevilForever_StatusStrip/, PitBull4/` on the hash line | 24 hash replacements in 24 files, 12 contents lists (phase2–10, 6-rev, 14, 15); appearance briefs name only the folders they use, left as they were |
| 11 | Wrote `Collection/codex-briefs/phase16.md` (97 lines; items 0–11, item 0 and 11 follow phase14: `forever_moved_phase16/AddOns`, full restore by renaming aside and copying the backup back) and `appearance-16.md` (51 lines) | — |
| 12 | Gates on the briefs: `/run` byte lengths (Python over backtick spans); grep of the seven banned words named in the order (rule 5) over the new files, the strip addon, the test and this log; hash counts | `/run` max 248 bytes (7 lines, all ≤255) · banned-word grep 0 hits (rc1) · old hash 0, new hash 26 (24 earlier briefs + phase16 + appearance-16) |
| 13 | Full re-run of all gates (raw output: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/gates.LwMJ/`) | luacheck rc0 checked=15 failed=0 · strip 17/17 · core 61/61 · genregistry ×2 same sha `24206f2c…1684e`, `--check` rc0 · tocdeps unresolved=0 · build ×2 sha `120bc974…c7407` · other own tests unchanged: chatsetup 13/13, castbars 16/16, fufdefaults 16/16, pitbull4 6/6 |
| 14 | Static check of the strip Lua for look and taint calls (grep `|c` codes, SetTexture/SetColorTexture/SetTextColor/SetVertexColor/SetBackdrop, hooksecurefunc, HookScript, SetCVar, OnUpdate, SecureHandler, Template) | only hit: the header comment line 17 that says "no OnUpdate script". Client calls used: CreateFrame, CreateFontString, GetLocale, GetMoney, GetInventoryItemDurability, C_Container.GetContainerNumFreeSlots / GetContainerNumFreeSlots, date, time, GetNetStats, GetFramerate, C_Timer.NewTicker / After, geterrorhandler, print, SlashCmdList — all in design §1.3 |

## Deviations from the design (A2 judgment)

1. **No coin colour codes in the gold text.** Design §1.2 puts `|cffffd700`/`|cffc7c7cf`/`|cffeda55f` on g/s/c. The order (rule 5, R87) forbids hard-coded colours for looks, and DECISIONS_28a DQ-5 cites R87. Gold text is plain `1,234g 05s 07c`; the test checks the verbatim text has no colour codes. Codex can colour it (appearance-16 §2 says the addon sets no colour).
2. **Bag family nil counts as general.** Design §1.2 counts only `family == 0`. A client that returns no family would show 0 forever under that rule; the addon counts `family == nil` as general too. Bags with a non-zero family are still left out (test area 4 unchanged).
3. **Late refresh (PEW + 5 s) covers the event items only** (gold, bags, durability). Design §2 says PEW + 5 s refreshes "them" (the event group). Timed items keep their ticker; test area 7 counts `GetNetStats` = PEW, tick 30, tick 60 only, which needs this.
4. **Durability percent computed as `floor(cur * 100 / max)`** instead of `floor(cur / max * 100)`: same value, no float rounding below a whole number (29/100 stays 29; tested).
5. **Extra public function `:GetStatusLog()`** (copy of the status lines `/dfstatus` prints). Not in design §4.2; read-only, adds no global.
6. **Size:** `StatusStrip.lua` is 678 lines against the 320–400 estimate (header contract 69 lines, one function per item reader/formatter/refresh). `run.py` 721 lines against 450–550.
7. **Unavailable latency / fps text** is `- ms` / `- fps` (design only says "-"); clock unavailable is `-`.

## Decision Queue

| ID | Point | Default used | Alternative |
|---|---|---|---|
| A2-1 | Gold coin colours (deviation 1) | none in the addon | Codex adds them in the Skin addon, or the master grants an exception to R87 for these three codes |
| A2-2 | `SetItemEnabled` while the saved variable is unusable (not a table / schema > 1 / `items` not a table) | switch held for this session only, disk value untouched, returns `true` | refuse with `false, reason` |
| A2-3 | Core test file `Collection/tests/core/run.py` edited (registry expectation, as the order allowed) | strip frames added to the all-frames list + 3 strip asserts | — |

## State for the next call

All gates pass. If review findings change `StatusStrip.lua`, the ZIP must be rebuilt and the new hash put into all 26 brief lines (old hash `120bc974…c7407` → new), as in steps 9–10.

## Fix 1 (review findings, `Claude/results/handoffs/phase16/TRIAGE_phase16.md`)

Read ranges for this fix: `TRIAGE_phase16.md` 1–30 (all); `StatusStrip.lua` 28–32, 236–245, 350–360, 393–428, 459–487, 565–590 (the lines the triage quotes, re-read before editing); `phase16.md` 9, 32, 45–47, 53; `appearance-16.md` 12–40. No compaction in this session; the earlier inputs are still the ones listed at the top.

### Impact map

| Place | Verdict | Done |
|---|---|---|
| `StatusStrip.lua` header (ListItems named fields m5b, SetSpacing nesting m2, event failure wording m3) | fix | header lines for `:ListItems()`, `:SetSpacing()` and the event rule rewritten |
| `StatusStrip.lua` value storage + `refresh.fps` (m1) | fix | `store(key, …)` reuses one table per item; `refresh.fps` returns before formatting when the whole-number fps equals the stored one |
| `StatusStrip.lua` `runLayout` (m2) | fix | split into `anchorShownItems` + `runLayout` with a guard: a nested call is noted, runs once after the current run; requests during that second run are dropped |
| `StatusStrip.lua` `updateEvents` (m3, m4) | fix | `ok and result ~= false` is success; a `false` return is noted as `RegisterEvent returned false`; `failedEvents` removed |
| `StatusStrip.lua` bag family nil (m5a) | keep | declared deviation 2 above stays |
| `tests/statusstrip/run.py` | fix together | stub `TEST_falseEvents`; 3 new cases: `fps_tick_does_no_work_when_unchanged`, `spacing_set_from_layout_callback_is_not_nested`, `register_event_returning_false_is_a_failure` |
| `phase16.md` :9 (m3), :32 (M3), item 4 quiver (M2), item 5 latency (M1) | fix | :9 adds the `false` return and the "확인 필요 — 등록 실패가 오류 없이 지나갈 수도 있다" line with items 3/4 as the real check; :32 "글자 색 없음 — 동전 색은 넣지 않는다"; item 4 compares the strip with the hand count while special bags have free slots, and says moving ammo out of a general bag rightly changes it (result line updated); item 5 passes when each number is within 100 ms of `GetNetStats` home/world |
| `appearance-16.md` §1 gold (M3), §2 spacing row (m2), §3 OnShow/OnHide (m6) | fix | gold text plain, one colour per FontString, no coin colours; SetSpacing from `LAYOUT` is not nested and runs once more after; no `SetScript` OnShow/OnHide on the strip, use `HookScript` |
| ZIP + hash in all 26 brief lines | fix together | rebuilt; `120bc974…c7407` → `2460bd1d…9df4` |
| `registry_extra.json` / `Registry.lua` | check only | no contract change; `--check` up to date, registry_extra diff unchanged (+70 from step 5) |
| Records (earlier work logs, results) | no change | — |
| Deviation 1 (coin colours) / Decision Queue A2-1 | settled by master (M3) | no coin colours; accepted design deviation |

### Commands and verdicts (raw output `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/fix1.yl8u/`)

| Command | Verdict |
|---|---|
| `python3 -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_StatusStrip 'Collection/AddOns/!DevilForever_Core' Collection/tests/core/fixtures` | rc0 `checked=15 failed=0` |
| `python3 -I Collection/tests/statusstrip/run.py` | `lupa=2.8 cases=20 passed=20 failed=0` (17 earlier unchanged + 3 new) |
| `python3 -I Collection/tests/core/run.py` | `cases=61 passed=61 failed=0` |
| `python3 -I Collection/tools/genregistry.py --check` | `up to date (53260 bytes)` rc0 |
| `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_StatusStrip` | rc0 `folders=2 unresolved=0 … duplicates=0` |
| `python3 -I Collection/tools/build.py` ×2 (repo, scratch) | both `built folders=6 files=331 zip_entries=333`, sha256 `2460bd1de6dd86f71dc15f7a990144fe2a45b7da2561eb88dd0a7fcbe5ef9df4` |
| brief hash replace (Python) | 26 replacements; old `120bc974…` 0, new 26 in 26 files |
| `/run` lines in phase16 / appearance-16 | max 248 bytes, 0 over 255 |
| banned-word grep (new files, addon, test, this log) | 0 hits |
| own-addon tests chatsetup / castbars / fufdefaults / pitbull4 | 13/13, 16/16, 16/16, 6/6 |

Sizes now: `StatusStrip.lua` 714 lines, `run.py` 784, `phase16.md` 97, `appearance-16.md` 52.

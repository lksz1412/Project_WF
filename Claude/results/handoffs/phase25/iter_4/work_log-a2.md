# work_log — Phase 25 Step 40d — A2 coder (new session)

Base: HEAD 8b7aa012 (brief names 05fca250; 8b7aa012 = the brief commit on top). Scratch root: /tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad (each run in its own `mktemp -d`).

## Read (basis)
- Claude/results/handoffs/phase25/brief-40d.md 1–32 (full)
- Collection/tools/build.py 1–338 (full), genregistry.py 1–466 (full), extract.py 1–637 (full), toclib.py 1–231 (full)
- Review/0.1.4/tools/package.py 1–135 (full), Review/0.1.4/HANDOVER.md 1–62 (full), Review/0.1.4/tests/README.md (full)
- Collection/install.json 1–50 (full); Collection/manifest.json via python (packages/addons/collection keys)
- Collection/patches/PitBull4.patch 1–40 (header) + `grep '^diff \|^--- \|^+++ '` (file header format: timestamps)
- Collection/tests/pitbull4/run.py 1–278 (full); Collection/tests/core/run.py 1–230 (harness), 440–610 (registry lookup), 770–940, 1890–1945, 2340–2358 (genregistry cases, main)
- Codex/docs/0.1.5-installer-catalog-handoff.md 1–14 (full); Collection/Installer/ReleaseCatalog.json (full), Contract.md 1–80
- Collection/tests/install/verify_archives.py 1–235 (full)
- Claude/results/handoffs/phase25/iter_1/audit_log-step44.md 1–19 (full), audit_log-step45-2.md 1–18 (full); iter_3/work_log-a2.md 1–153 (full; 40c hand edits); iter_2/work_log-a2.md (grep registry lines 8–239)

## Item 1 — structure (originals, patches, manifest)
Inventory (scratch `d40.*/cmp.py`, compare every Collection/AddOns folder with its manifest upstream folder): third-party folders byte-identical to upstream = 24 (Details, Details_TinyThreat, Dominos, Dominos_Config, Masque_Dominos, ForeverUnitFrames, Grid2, Grid2LDB, Grid2Options, Hekili ×11, Masque, Masque_Onyx, ProfileManager, Quartz); differing = ExperienceForever (ExperienceForever.lua), SexyMap (Coordinates.lua); own folders missing in OWN_FOLDERS = Appearance, DetailsLayout, Skin_Dominos, Skin_Nameplates, Skin_NativeChat, Skin_StatusStrip.

Impact map:
| Place | Verdict | Reason |
|---|---|---|
| extract.py OWN_FOLDERS | fix | + the 6 own folders; phases/bundle copied from HEAD Registry.lua (Appearance [2,22] required; DetailsLayout [10]; Skin_Dominos [3]; Skin_Nameplates [14]; Skin_NativeChat [4]; Skin_StatusStrip [16]; individual) so the registry stays the same |
| extract.py new PATCHED + patch_path + third_party_entries + manifest "third_party" + manifest.md section | fix | per shipped third-party folder: package, version, source ZIP/sha, upstream_path, state unmodified/patched, patch |
| new Collection/tools/patches.py (verify / regenerate / reapply) | new | brief item 1 a–c |
| Collection/patches/PitBull4.patch | regenerated | same hunks (checked: diff of non-header lines empty); file headers without timestamps; header "Generated with" line updated |
| Collection/patches/Experience_Forever.patch, SexyMap.patch | new | Codex edits folded in (audit M2) |
| SexyMap/Coordinates.lua | line endings LF → CRLF (upstream) | Codex copy was LF, upstream CRLF → whole-file hunk; content kept, CRLF restored so the patch is 3 hunks (version-up friendly) — my choice |
| PitBull4 LibPlayerSpells LICENSE (item 5) | shipped copy = upstream bytes | text equal ignoring CR (cmp of CR-stripped files); CRLF copy had no meaning; patch no longer needs `-x LICENSE` — my choice |
| genregistry.py | fix (item 2) | below |
| build.py | fix (item 3) | below |
| tests/pitbull4/run.py patch case | check only | applies with `patch -p1 --binary --batch`; label-only headers parse |

Commands / verdicts:
- `python3 -I Collection/tools/extract.py --no-extract` → `... errors=0` (after the patches exist; first run listed the two missing patch files)
- `python3 -I Collection/tools/patches.py regenerate` → wrote Experience_Forever.patch, PitBull4.patch, SexyMap.patch
- `TMPDIR=<scratch> python3 -I Collection/tools/patches.py verify` → `verify patches=3 unmodified=24 failures=0`
- `python3 -I Collection/tests/pitbull4/run.py` → `cases=6 passed=6 failed=0` (patch_reproduces_the_copy passes)

## Item 2 — genregistry / registry
Impact map: genregistry own_addon_entries → skips manifest third_party folders (they are start-package folders); manifest_entries → TOC data of a shipped third-party folder read from Collection/AddOns (a patch may change a TOC), others from the manifest; error text for an unknown folder → names both sections. Registry.lua → regenerated = compare.
- `python3 -I Collection/tools/genregistry.py --check` → `check Collection/AddOns/!DevilForever_Core/Registry.lua: up to date (58497 bytes)` — the 40b/40c hand edits (Skin_Nameplates savedVariables = {}, Party/targetpet implications) equal the generator output; no difference to explain.

## Item 3 — one build path (build.py)
Read for this item: Collection/tests/install/verify_archives.py 1–235, Collection/Installer/Engine/ApprovedPackage.cs 100–200, Collection/install/설치안내.md 1–71, Review/0.1.4/trial-receipt.json (python), `git show <rev>:Collection/install.json` for 181e3685 (0.1.0), 4107aab2 (0.1.1), a69f6a2c (0.1.2), 477eb062 (0.1.4).

Impact map:
| Place | Verdict | Reason |
|---|---|---|
| build.py verification mode (`--select`/`--name`, upstream folders from Collection/upstream) | removed | one build path; every shipped folder is in Collection/AddOns (`--install` still accepted, same meaning) |
| build.py install_selection / install_sources | fix | upstream folders read from Collection/AddOns; each must be a manifest third_party folder of the package install.json names; every AddOns folder must be named (own or upstream, base or variant) |
| build.py check_sources → patches.verify | new | the build refuses when a third-party folder is not upstream (+patch) |
| build.py runtime_files / loaded_code | new | TOC load lists (all own TOCs, `[Allow/ExcludeLoad… x]` conditions ignored, `[Token]` path parts = any name, XML Script/Include followed, case-insensitive) decide which .lua/.xml ship; root Bindings.xml kept; DEV_FILES = Core registry_extra.json; textures and every non-code file kept |
| build.py install_manifest | fix | upstream kind = manifest state (unmodified/patched) + patch path; `review` of a variant copied (one-session) |
| Review/0.1.4/tools/package.py | check only | unchanged; verify-source compares the checkout with the frozen 0.1.4 sources, so it fails on this branch (`ValueError: Collection/install.json differs from the original pitbull4 release`) — it is for the v0.1.4 checkout; receipts untouched |
| tests/install/verify_archives.py | fix | 0.1.5+: dev-only files (Probe.lua, SessionProbe.lua, registry_extra.json) must be absent; one-session optional (shared payload of the two release ZIPs compared instead); 0.1.4 expectations kept for older versions |
| Collection/Installer (ReleaseCatalog.json) | check only | outside my write scope; values in item 6 |

Excluded from the archives (TOC rule; pitbull4 ZIP 70 files, fuf ZIP 62 = same list without PitBull4):
- !DevilForever_Core: /registry_extra.json (development file)
- Details: /Details.xml, /Libs/DF/addon.examples.lua, /Libs/DF/buildmenu.examples.lua, /Libs/DF/button.examples.lua, /Libs/DF/charts.examples.lua, /Libs/DF/containers.examples.lua, /Libs/DF/cooltip.examples.lua, /Libs/DF/definitions.lua, /Libs/DF/dropdown.examples.lua, /Libs/DF/keybind.examples.lua, /Libs/DF/lines.examples.lua, /Libs/DF/packtable.tests.lua, /Libs/DF/rounded_panel.examples.lua, /Libs/DF/scrollbox.examples.lua, /Libs/DF/scrollbox_exemples.lua, /Libs/DF/slider.examples.lua, /Libs/DF/tabcontainer.examples.lua, /Libs/DF/timeline.exemples.lua, /Libs/LibDBIcon-1.0/lib.xml, /Libs/LibOpenRaid/classes.lua, /core/parser_timewalk.lua, /embeds.xml, /frames/window_all_in_one.lua, /frames/window_custom_scripts.lua, /frames/window_pro_file correct.lua, /functions/benchmark.lua, /luaserver.lua
- Details_TinyThreat: /Libs/AceLocale-3.0/AceLocale-3.0.lua, /Libs/AceLocale-3.0/AceLocale-3.0.xml, /Libs/LibStub/LibStub.lua, /Libs/LibStub/tests/test.lua, /Libs/LibStub/tests/test2.lua, /Libs/LibStub/tests/test3.lua, /Libs/LibStub/tests/test4.lua, /embeds.xml
- DevilForever_Skin_Nameplates: /Probe.lua, /SessionProbe.lua
- Dominos: /libs/CallbackHandler-1.0/CallbackHandler-1.0.xml, /libs/LibDBIcon-1.0/lib.xml, /libs/LibDualSpec-1.0/LibStub.lua, /libs/LibSharedMedia-3.0/lib.xml
- Grid2: /Libs/LibCustomGlow-1.0/LibCustomGlow-1.0.xml, /Libs/LibSharedMedia-3.0/lib.xml, /Libs/LibStub/tests/test.lua, /Libs/LibStub/tests/test2.lua, /Libs/LibStub/tests/test3.lua, /Libs/LibStub/tests/test4.lua
- Grid2LDB: /Libs/LibDBIcon-1.0/lib.xml
- Grid2Options: /Libs/LibCompress/lib.xml
- Hekili: /Libs/LibDBIcon-1.0/lib.xml, /Libs/LibDeflate/lib.xml, /Libs/LibSpellRange-1.0/lib.xml
- Hekili_Shared: /Shared/ItemAuras.lua
- Masque: /Libs/AceGUI-3.0_SFX-Widgets/LibStub/LibStub.lua, /Libs/LibDBIcon-1.0/lib.xml, /Libs/LibDualSpec-1.0/LibStub.lua
- PitBull4: /Debug.lua, /Libs/LibDBIcon-1.0/lib.xml, /Libs/LibDeflate/examples/example.lua, /Libs/LibDeflate/lib.xml, /Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua, /Libs/LibDualSpec-1.0/LibStub.lua, /Libs/LibSerialize/lib.xml, /Modules/Aura/Libs/LibPlayerSpells-1.0/LibStub.lua
- ProfileManager: /Libs/CallbackHandler-1.0/Callbackhandler-1.0.xml, /Libs/LibDBIcon-1.0/lib.xml, /Libs/LibDeflate/lib.xml
- Quartz: /libs/LibDualSpec-1.0/LibStub.lua
- SexyMap: /Ping.lua
First dry run also dropped Masque/Locales/*.lua (9) — the TOC lines carry `[AllowLoadTextLocale …]`; condition pattern widened to every `[AllowLoad…/ExcludeLoad… x]`, Masque locales kept (dry-run diff checked).

## Item 4 — third-party runtime patches
Read: Details_TinyThreat.lua 1–160, 162–262, 280–370, 630–790, 900–1018; Details/core/plugins.lua 250–330 (plugin frame created hidden, OnShow → SHOW, OnHide → HIDE); Review/0.1.4/tools/reproduce-astra-runtime.py (full), Review/0.1.4/astra-review.md 9–12; ExperienceForever.lua 1–32, 100–128, 140–202, 280–460, 525–626, 828–948, 1075–1215, 1250–1320, option setters 1383–1968 (grep of `set = function` bodies); ProfileManager Core.lua 1–72, Providers.lua 1–12, 405–475, 595–640, 3060–3136, Presets.lua 100–120, UI.lua 270–340, grep of TryRegisterAllProviders / Providers consumers.

Impact map:
| Place | Verdict | Reason |
|---|---|---|
| TinyThreat OnDetailsEvent HIDE/SHOW | fix | `isShown` flag follows the plugin frame (Details sends SHOW/HIDE from OnShow/OnHide) |
| TinyThreat PLAYER_REGEN_DISABLED, COMBAT_PLAYER_ENTER | fix | start the timer only while shown; SHOW in combat starts it (existing code) |
| TinyThreat Threater "someone joined → Start" | check only | runs only while Actived (shown) |
| EF OnEnable ticker | fix | 1 s ticker → UpdateTimeText |
| EF Update | fix | time fields via shared SetTimeFields; stores lastCtx and per-slot text |
| EF new UpdateTimeText | new | texts only, SetText on change; level/XP/max/rested change (rested has no event) → QueueUpdate |
| EF option setters, events | check only | all call QueueUpdate/Update/Apply*/UpdateBorder themselves (grep) |
| ProfileManager provider event frame | fix | PLAYER_LOGIN/ADDON_LOADED → one rescan next frame |
| ProfileManager UI/Commands rescans (UI.lua 281, 4855, 4892, 4907; Commands.lua 34, 39) | check only | they call TryRegisterAllProviders themselves → UI shows current providers |
| Collection/patches/{Details,Experience_Forever,ProfileManager}.patch | new/regenerated | header text describes the change; EF patch also carries the Codex quest-XP edit; SexyMap.patch = Codex edit only |
| extract.py PATCHED | fix | + Details: Details_TinyThreat, ProfileManager: ProfileManager |

Probes (stubbed, `python3 -I Collection/tests/thirdparty/run.py`, upstream = Collection/upstream copy, shipped = Collection/AddOns):
- `PROBE TinyThreat HIDE then combat, 30 ticks, 40 raid members (timers, threat reads): upstream (1, 1200) -> shipped (0, 0)`
- `PROBE ExperienceForever 30 idle ticks (SetText, bar value/range writes, rep refresh, border refresh): upstream (270, 180, 30, 30) -> shipped (0, 0, 0, 0)`
- `PROBE ProfileManager 40 ADDON_LOADED + PLAYER_LOGIN in one frame (rescans, root-DB exception checks): upstream (41, 820) -> shipped (1, 20)`
Behaviour: TinyThreat shown → combat starts the timer, 40 reads per tick, combat end stops; HIDE in combat cancels, combat events while hidden start nothing, SHOW in combat starts it again. EF: 40 one-second snapshots (texts of 9 slots + 5 bars) equal between upstream and shipped with a silent XP change, a silent rested change, an XP event, a label option toggle and a level up; idle tick → no full update, rested change → one. ProfileManager: same provider ids as upstream after login; a later ADDON_LOADED rescans on the next frame; shown UI refreshed as after one upstream event.

## Item 5 — PitBull4 patch_reproduces_the_copy
Decision (mine): shipped LibPlayerSpells LICENSE = upstream bytes (LF); the CRLF copy had the same text (CR-stripped cmp equal). `-x LICENSE` gone. `python3 -I Collection/tests/pitbull4/run.py` → `cases=6 passed=6 failed=0`.

## Item 6 — version 0.1.5, build, catalog
- install.json version 0.1.5; Core TOC `## Version: 0.1.5`; `extract.py --no-extract` (manifest, errors=0); `genregistry.py` → wrote Registry.lua 58497 bytes, sha256 c0e48c7719dd244bf6e2e16a72116cc9a82fde358074a0c79dc5424640807c01 (diff: Core version 0.1.4 → 0.1.5 only).
- `python3 -I Collection/tools/build.py --variant pitbull4 --out-dir outputs/collection` → `built folders=35 files=2246 zip_entries=2249 sha256=dc7bcf454e6674aac2f3c7f95afd41baea9e9aac731d49576087e34a5312bdf7`
- `python3 -I Collection/tools/build.py --variant fuf --out-dir outputs/collection` → `built folders=37 files=2190 zip_entries=2193 sha256=39b590f0b48822c1977983680603c47ad7b8930b70bbf656c29559a0c8af0e62`
- second build of both into `<scratch>/rel40.*/second` → same sha256 (sha256sum listed both pairs equal).
- one-session: not built (my choice: 0.1.5 ships two variants; the handoff doc keeps comparison ZIPs out of the catalog; `--variant one-session` still works).
- New `Collection/tools/catalog.py` reads the built ZIPs (the handoff doc asks that the values come from the final ZIP by code; it names no file, so no JSON file was written next to the ZIP):
  `python3 -I Collection/tools/catalog.py outputs/collection/DevilForever-0.1.5.zip outputs/collection/DevilForever-0.1.5-fuf.zip`
  schema devil-forever-installer-catalog/1, interface 16001, defaultVariant pitbull4
  - pitbull4 · 0.1.5 · DevilForever-0.1.5.zip · sha256 dc7bcf454e6674aac2f3c7f95afd41baea9e9aac731d49576087e34a5312bdf7 · zipBytes 126902460 · addonBytes 487650592 · addonFiles 2243 · 35 folders
  - fuf · 0.1.5 · DevilForever-0.1.5-fuf.zip · sha256 39b590f0b48822c1977983680603c47ad7b8930b70bbf656c29559a0c8af0e62 · zipBytes 127558890 · addonBytes 490843124 · addonFiles 2187 · 37 folders
  (folders = the install.json lists of each variant; same names as the 0.1.2 catalog rows.)

## Item 7 — install notes
`Collection/install/설치안내.md`: section 「0.1.5 ZIP」 (two ZIPs, folder counts, only game-loaded files, no diagnostics, what changed, no one-session ZIP); new 「0.1.0 ~ 0.1.4 에서 올릴 때」 (move old collection folders aside first; folders that no longer belong: Prat-3.0 (in install.json 0.1.0–0.1.2), DevilForever_Skin_Prat (review builds), the other variant's unit-frame folders); FUF ZIP name 0.1.5; /dfcheck line; local build line (extract → patches verify → build). /dfp party lines unchanged.

## Gates (final)
- `python3 -I Collection/tools/genregistry.py --check` → `check Collection/AddOns/!DevilForever_Core/Registry.lua: up to date (58497 bytes)` rc 0
- `python3 -I Collection/tests/core/run.py` → `cases=108 passed=108 failed=0` (genregistry_extra_applied_and_checked, genregistry_output_matches_file, genregistry_editable_frame_and_default_checked, genregistry_t28_restore_options all PASS)
- pitbull4 `cases=6 passed=6 failed=0` · firststart `24/24` · fufdefaults `22/22` · pitbull4runtime `19/19` · chatsetup `28/28` · castbars `16/16` · statusstrip `20/20`
- new thirdparty `cases=8 passed=8 failed=0` · new patches `cases=4 passed=4 failed=0` (repository verify; regenerate + verify + idempotent + header kept; drift: shipped file, hand-edited body, unmodified folder, stray folder, binary difference; reapply clean, one conflict `CONFLICT Foo/a.lua: 1 hunk(s) failed` + .rej, missing folder)
- `TMPDIR=<scratch> python3 -I Collection/tools/patches.py verify` → `verify patches=5 unmodified=22 failures=0`
- `patches.py reapply --package SexyMap|PitBull4 --upstream <current upstream_dir> --out <scratch>` → clean; `diff -r` with Collection/AddOns identical
- `python3 -I Collection/tools/luacheck.py Collection/AddOns/Details_TinyThreat Collection/AddOns/ExperienceForever Collection/AddOns/ProfileManager Collection/AddOns/SexyMap Collection/AddOns/PitBull4 Collection/AddOns/!DevilForever_Core` → `checked=324 failed=0`
- Codex runner `<scratch>/cx477.d2Y2/venv/bin/python Review/0.1.4/tests/run.py --output <scratch>/g40.*/codex` → rc 0, `PASS suites=8/8 expected_counted_cases=195`
- `python3 -I Collection/tests/install/verify_archives.py <scratch copy of both ZIPs> --version 0.1.5 --reviewed-chat` → rc 0; pitbull4 `checked=1298 failed=0`, tocdeps `unresolved=0`, `folders=35 files=2246 internal_hashes=2245`; fuf `checked=1249 failed=0`, `unresolved=0`, `folders=37 files=2190 internal_hashes=2189`; one-session not built
- build twice identical (sha256 above)
- line endings: TinyThreat CRLF kept, EF/ProfileManager LF kept, Core TOC kept; SexyMap/Coordinates.lua LF → CRLF and PitBull4 LibPlayerSpells LICENSE CRLF → LF on purpose (upstream bytes)

## Files
Changed: Collection/tools/{build,extract,genregistry}.py; Collection/install.json; Collection/manifest.{json,md} (extract.py); Collection/AddOns/!DevilForever_Core/{!DevilForever_Core.toc, Registry.lua (genregistry)}; Collection/AddOns/Details_TinyThreat/Details_TinyThreat.lua; Collection/AddOns/ExperienceForever/ExperienceForever.lua; Collection/AddOns/ProfileManager/Providers.lua; Collection/AddOns/SexyMap/Coordinates.lua (CRLF); Collection/AddOns/PitBull4/Modules/Aura/Libs/LibPlayerSpells-1.0/LICENSE (upstream bytes); Collection/patches/PitBull4.patch; Collection/install/설치안내.md; Collection/tests/install/verify_archives.py.
New: Collection/tools/{patches,catalog}.py; Collection/patches/{Details,Experience_Forever,ProfileManager,SexyMap}.patch; Collection/tests/{patches,thirdparty}/run.py; outputs/collection/DevilForever-0.1.5.zip, DevilForever-0.1.5-fuf.zip (untracked; outputs/collection already tracks 0.1.0 ZIPs). No file moved or deleted. .gitignore unchanged (Collection/upstream/ already ignored).

## Decision Queue
1. Patch file name = package name with spaces → `_` (Experience_Forever.patch) — my choice.
2. Archive exclusion rule also drops 4 unreferenced files in Hekili folders (3 lib.xml, Hekili_Shared/Shared/ItemAuras.lua) although Hekili is otherwise out of scope; alternative: exempt Hekili folders.
3. Non-code upstream docs (README/CHANGELOG/.md/.txt, lib .toc files) stay in the ZIPs (no runtime load; licences/notices among them); textures all kept (no texture-use analysis, M7 not addressed).
4. Collection/Installer/ReleaseCatalog.json not updated (outside scope); catalog values above / `catalog.py` output are ready for it; tampered-ZIP and comparison-ZIP refusal by the installer not tested here (C# engine).
5. Review/0.1.4/tools/package.py verify-source fails on this branch by design (frozen 0.1.4 sources); verify-release unaffected.
6. The 0.1.5 ZIPs (~127 MB each) are in outputs/collection untracked — commit or release upload is master's call.
7. build.py now needs Collection/upstream (extract.py) because it runs patches.verify before writing.
8. EF: rested XP growth has no event in EF; the ticker checks level/XP/max/rested each second and runs the full update on a change (keeps upstream's display). Other values (pet XP, rep, quest XP) follow their events as before.

# Step 41-rev (R126–R127) — base 758d5a2b

## Read (basis)
- Claude/plans/2026-11-18-devil-forever-addon-collection-phase25-세부계획.md last 30 lines (Step 41-rev row)
- References/codex-appearance/25-codex-handoff/README.md (grep grid/font: lines 5, 17, 18, 69–76); positions.json via python (layouts/*/gridFont 12/14/18, gridBorder, grid2Button)
- !DevilForever_Core/Presets/fhd.lua 524–575 (Grid2 proposal + fragments; qhd/uhd same line 552); Presets.lua 140–215 (Register keeps only name/screen/uiScale/edits/fragments → the proposal's "indicators" table is never written); Defaults/Grid2.lua (full)
- Grid2/GridDefaults.lua 27–110; Grid2/modules/IndicatorText.lua 262–275 (textsize = dbx.fontSize or Grid2Frame profile fontSize or 11); Grid2Options/profiles/ProfileClassic.lua, ProfileModern.lua, ProfileBlizzard.lua (grep text indicators: name text = Classic text-down 10, Modern text-center 10, Blizzard text-name 10; Classic text-up 9)
- tests/firststart/run.py 490–640 (Grid2 stub, template session, existing case)
- DevilForever_Appearance/Composition.lua 1–146 (full), Crests.lua 1–25, Appearance.lua (grep Composition: 46, 164); Themes/ listing (13 themes; every non-devil theme has <preset>_deck_reviewed.tga, devil has none)
- Collection/Installer/Contract.md (grep catalog/version lines 7–16, 62, 76; 140 lines), Engine/ApprovedPackage.cs 20–50, 100–200, Engine/Models.cs 40–67, Engine/InstallationStore.cs 143–176 (grep), Publish-Installer.ps1 10–40; Collection/tests/installer/run.py 1–30 (runs the published exe)

## Item 1 — Grid2 name text 12/14/18
Finding: the preset's `["indicators"]["text-center"]` values were never written (Presets:Register keeps fragments only; the fragments are Grid2Frame and Grid2Layout). The template assigns whole indicator entries; the name text indicator differs per template (Classic text-down, Modern text-center, Blizzard text-name), so a fixed "text-center" entry would add a typeless indicator to Classic/Blizzard profiles.
Impact map:
| Place | Verdict | Reason |
|---|---|---|
| Presets/{fhd,qhd,uhd}.lua Grid2Frame fragment | fix | + `fontSize` 12/14/18 (Grid2's frame default text size, used by text indicators without their own size) |
| same files, proposal `indicators["text-center"].fontSize` | fix | 16/18/22 → 12/14/18 (kept consistent; not read by Core — DQ) |
| Defaults/Grid2.lua reapplyAfterTemplate | fix | after a template was applied: every "text" indicator the statusMap maps status `name` to gets the Grid2Frame fragment's fontSize (same once-per-profile-key condition) |
| Defaults/Grid2.lua header comment | fix together | states the name-text rule |
| tests/firststart grid2_preset_values_survive_first_start_template | fix together | per template: name indicator = text-down/text-center/text-name, fontSize 12; other text indicators keep the template value (Classic text-up 9); Grid2Frame fontSize 12; existing profile keeps the template's 10; static check of 12/14/18 in the three presets |
| a later `/dfp preset` on an existing profile | check only | does not change the name text (only first-start template step) — DQ |
- `python3 -I Collection/tests/firststart/run.py` → `cases=24 passed=24 failed=0`

## Item 2 — installer catalog from the ZIPs
- Contract/engine: ApprovedPackage.cs:26–28 requires exactly 2 packages (fuf, pitbull4), defaultVariant pitbull4, interface 16001 → the 0.1.2 rows are replaced, no history kept (the engine would refuse a 4-row catalog).
- catalog.py: `--write [FILE]` (default Collection/Installer/ReleaseCatalog.json) and `--check [FILE]` (byte compare with what the ZIPs give, rc 1 on difference); output byte format = the existing file's (indent 2, trailing newline — checked: re-dumping the old file gives the same bytes). `--out` removed.
- New tests/catalog/run.py: write→check match; member byte changed / one more file → DIFFERS rc 1, rebuilt from same inputs → match; one-session ZIP in place of fuf → rc 1; repository catalog vs outputs/collection ZIPs.
- dotnet is not installed here: the C# installer's refusal of a tampered or comparison ZIP (ApprovedPackage SHA/ZipBytes lookup, member hashes) was not run; the Python check above covers the catalog side only.
- Collection/Installer/Contract.md still names 0.1.2 in its table (lines 12–13) — outside the write scope given (DQ).

## Item 3 — reviewed deck replaces _deck.tga
Impact map:
| Place | Verdict | Reason |
|---|---|---|
| build.py runtime_files | fix | `<name>_deck.tga` excluded when `<name>_deck_reviewed.tga` is in the same directory (reason "replaced by …"); 36 files = 12 themes × 3 presets; devil's 3 `_deck.tga` kept (no reviewed sibling) |
| Composition.lua GetPlan | fix | surfaces of the active theme only: devil → `_deck.tga`, every other theme → `_deck_reviewed.tga`; top or deck unknown to the client → no plan (individual shell); the racial→family fallback and the `_deck.tga` retry are gone (they pointed at files no longer shipped) |
| Composition.lua Apply | fix | a failed SetTexture → frame hidden (shell), no second file tried |
| Composition crest overlay (non-reviewed only) | check only | only devil is non-reviewed now; devil has no crest → overlay not shown (as before for devil) |
| tests/install/verify_archives.py composition check | fix | 0.1.5+: non-devil `_deck.tga` must be absent; size/alpha/centre comparisons read it from Collection/AddOns |
| Codex performance test (Composition path count) | check only | runner 8/8 |
- New tests/composition/run.py (shipped set from build.runtime_files): shipped set has reviewed decks only (devil own deck); 13 themes × 3 presets paint top + reviewed deck (devil: deck), only shipped paths requested; reviewed deck unknown → nothing loaded, shell; failed reviewed texture → no `_deck.tga`, shell; same without IsKnownFile API (orc: one attempt, shell); no API → only shipped names. Against the HEAD Composition.lua copy (`git show HEAD:…` into `<scratch>/old41.*`): `every_theme_paints_reviewed_deck_from_shipped_files` and `failed_texture_without_lookup_api_keeps_shell` FAIL (racial themes fell back to the family `_deck.tga`; API-less retry asked for `_deck.tga`).

## Item 4 — rebuild, catalog, gates
- `build.py --variant pitbull4 --out-dir outputs/collection` → `built folders=35 files=2210 zip_entries=2213 sha256=174149f811375190788f515ee7ff1b1c9ea11cecd83124da04edb0c9be9da40e`
- `build.py --variant fuf --out-dir outputs/collection` → `built folders=37 files=2154 zip_entries=2157 sha256=f563aaba6e80105dd54c76a260560db060ce2911b1c963e47bb1c3a885d515de`
- second builds into `<scratch>/b41.*/second` → same sha256 both
- excluded files: pitbull4 106 (70 + 36 decks), fuf 98 (62 + 36)
- `catalog.py <both ZIPs> --write` → wrote Collection/Installer/ReleaseCatalog.json (2 packages); `--check` → `matches the ZIPs (pitbull4 174149f81137, fuf f563aaba6e80)` rc 0
  - pitbull4 · 0.1.5 · DevilForever-0.1.5.zip · 174149f811375190788f515ee7ff1b1c9ea11cecd83124da04edb0c9be9da40e · zipBytes 81398885 · addonBytes 336654337 · addonFiles 2207 · 35 folders
  - fuf · 0.1.5 · DevilForever-0.1.5-fuf.zip · f563aaba6e80105dd54c76a260560db060ce2911b1c963e47bb1c3a885d515de · zipBytes 82055349 · addonBytes 339846869 · addonFiles 2151 · 37 folders
- genregistry --check up to date (58497 bytes) · patches verify `patches=5 unmodified=22 failures=0`
- core 108/108 · pitbull4 6/6 · firststart 24/24 · fufdefaults 22/22 · pitbull4runtime 19/19 · chatsetup 28/28 · castbars 16/16 · statusstrip 20/20 · thirdparty 8/8 · patches 4/4 · composition 6/6 · catalog 4/4 (skipped=0)
- luacheck Core + Appearance `checked=27 failed=0`
- verify_archives `<scratch>/g41.*/v/zips --version 0.1.5 --reviewed-chat` rc 0: pitbull4 `checked=1298 failed=0`, `unresolved=0`, `files=2210 internal_hashes=2209`; fuf `checked=1249 failed=0`, `unresolved=0`, `files=2154 internal_hashes=2153`
- Codex runner `--output <scratch>/g41.*/codex` rc 0 `PASS suites=8/8 expected_counted_cases=195`
- line endings kept: Presets LF, Defaults/Grid2.lua CRLF, Composition.lua LF

## Decision Queue (41-rev)
1. The proposal `indicators` table in Presets/*.lua (text-center, icon sizes) is not read by Core; name text now comes from the Grid2Frame fragment fontSize + the template step. Icon sizes there stay unused.
2. Name text size follows the preset only at the first-start template; `/dfp preset <other>` later changes Grid2Frame (default size) but not the template's name indicator.
3. Contract.md still describes 0.1.2 (version, file names) — outside the given scope.
4. The C# tamper/comparison refusal test needs dotnet (Windows or a dotnet environment).
5. Composition: a race theme whose files the client does not know now shows the individual shell instead of the family composition with a crest.

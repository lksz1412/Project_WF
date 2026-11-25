# Brief — Phase 27 Step 64 items a, b, d: Musca Auras into the collection, muted by default (same work A)

You are the work sub (code) of Phase 27, Step 64, in the 3-session unit (master + work A + review B). Your scope is only the items below. Commit belongs to the master: you change files and write the work log only. Do not add documents, standards, commits or memory outside this brief; list anything else you find under "Decision Queue" in the work log. Do not attribute your own choices to the user. Do not delete files to tidy up (no `rm -rf`, no `rm -f` for cleanup); new runs go in a new scratch folder (`mktemp -d`); the master cleans up at the very end.

If this session was compacted since your last task, first re-read in full: this brief, the work log sections "Step 64" and "Step 68" of `Claude/results/handoffs/phase27/iter_4/work_log-60.md`, and every file you change before you change it.

## Download — done by the master

The user approved the download in chat on 2026-11-26 07:48:57 +0900 (request R232): "Musca 받아. 내가 선택했는데 당연히 받아왔어야하는거 아니냐?". The master downloaded it:

- `References/forever-addons/MuscaAuras/Musca-Auras-v1.21.0.zip` (8,137,925 bytes, SHA256 `0ea9132a75db3fa0dea3a420f28d481d273ab84f4d942a75b523d21764e38cc4`)
- `References/forever-addons/MuscaAuras/SOURCE.txt` (page, file id 9801355, project id 1713094, GPLv2)
- Top folders in the ZIP: `WeakAuras` (597 entries), `WeakAurasOptions` (174), `WeakAurasTemplates` (20), `WeakAurasModelPaths` (3), `WeakAurasArchive` (2) — 796 entries.

Treat the ZIP as untrusted data: extract only into a new empty scratch folder or through the collection's own `tools/extract.py` path, run any Python that reads it with `-I`, and do not run code from inside it.

## Items

a. **Ship it.** Bring Musca Auras into the collection the way other upstream addons are brought in (Chattynator 237 and Quartz 3.8.0 are recent examples: `References/forever-addons/<Name>/` → `tools/extract.py` → `Collection/AddOns/<folder>` → `install.json` upstream group → `manifest.json/md` → `registry_extra.json` / `Registry.lua` if the collection registers it → `tests/install/verify_archives.py` must-ship list → build dry-run for both variants). Keep the upstream files unchanged unless item b needs a patch; if it does, use the collection's patch route (`Collection/patches/<Name>.patch` + `patches.py` verify), as for Chattynator and PitBull4. Check the role table in `tools/extract.py` (Hekili was `start` → `dropped`): pick the role the plan uses for an adopted start addon and say which in the work log. Check whether any folder name clashes with something already in `Collection/AddOns` or the install (it ships as `WeakAuras*`).

b. **Sounds off by default (R223: "소리는 없어도돼. 오히려 방해돼").** Find how Musca Auras plays sounds (aura "Play Sound" actions, class-pack HUD auras, any global sound or "Ready Flash" sound option, the minimap/launch sounds) by reading its code. Make a fresh install play no sound from Musca Auras, with the least change and without overwriting a user's own later choice (seed once / default only, like the other `!DevilForever_Core/Defaults/*.lua` fragments or the addon's own default table). Record which file:line plays sound and how the default stops it. If an option exists for the user to turn sounds back on, name it for the check list. If muting needs something that cannot be done without editing user auras, stop at the least intrusive default and put the rest in the Decision Queue.

d. **Check list and docs.** Add the Musca items to `Collection/codex-briefs/phase27-game-check.md` (what the user sees on login, how to open it — `/wa`, the "Update HUD" button the release notes mention for class packs, that it is silent, how to turn sound on), the install guide `Collection/install/설치안내.md`, and `data/feature-map.md` (the class action / alert row that R223 left as none: Musca Auras now covers "alert when a condition holds", like EventAlert — R223 wording). Do not touch Hekili code or its `not_shipped` route.

## Before you change anything

Make the impact map (places that read or rely on what you change: build lists, manifest, registry, tests, presets, docs, the status strip / addon lists, ReleaseCatalog note) with impact per place (change together / check only / no impact (record) + reason), and keep all rows in the work log.

## Gates (run and record verdict lines only)

`extract.py` · `genregistry.py --check` (if the registry changes) · `tests/core/run.py` · `tests/install/verify_archives.py` on scratch-built ZIPs of both variants · `build.py --dry-run --variant pitbull4` / `fuf` · `patches.py` verify if you add a patch · `luacheck` on any Lua you write · any test you touch. Do not stage or install; the master does that.

## Work log

Write a new section "Step 64 (Musca Auras: items a, b, d)" at the end of `Claude/results/handoffs/phase27/iter_4/work_log-60.md`: read ranges (file:lines), impact map rows, changes, commands with verdict lines (raw output only as scratch paths), Decision Queue. Return a short report: changed files, gate verdicts, open items.

# Triage — Phase 23 (Step 38 fixes)
Review B (code review 1 + adversarial): 0 / 2 / 6 — master confirmed phase20.md:18 「열한 폴더」 vs 10-folder list, 설치안내.md:8 and :16 wording.
| ID | Verdict | Fix |
|---|---|---|
| M1 phase20.md:18 count 11 → list has 10 | major, confirmed | 「열 폴더」 |
| M2 install notes: existing addons doing the same job not handled; move-aside sentence after unzip (merge risk) | major, confirmed | Rewrite step order: (1) back up AddOns + WTF, (2) move EVERY current addon folder to a separate `forever_moved_install/AddOns` except BugSack/!BugGrabber (same as briefs' item 0 pattern), (3) unzip, (4) put back only addons the user wants that do not duplicate a collection function — list the known duplicates to keep out: Dominos_Cast, Dominos_Progress, Dominos_Roll, other cast-bar/status-bar/unit-frame/raid-frame/meter addons (V42 Castbars, ChocolateBar, other PitBull/FUF builds, ForeverThreat, Skada etc.). Never unzip over an existing folder. |
| m1 build.py --name ignored with --install | minor → fix | reject like --select |
| m2 shipped-but-unregistered guard | minor → fix | build stops if a shipped upstream folder is not registered |
| m3 Quartz how_to_use reason stale | minor → fix | rewrite (Dominos_Cast not shipped) |
| m4 manager-app update could replace Forever builds of Hekili/Grid2 | minor → fix | note: turn off auto-update for every addon in the ZIP or check the update is a Forever build (확인 필요) |
| m5 sha256sum not on plain Windows | minor → fix | add PowerShell `Get-FileHash` line as the main check, sha256sum as alternative |
| m6 Hekili version v0.8.6 vs v0.8.6-forever | minor → fix | use the source ZIP version string in the install manifest |
| A2 DQ1 API.lua `variant` doc line | fix (one line) | |
| A2 DQ2 INDEX.md structure map | master | |
| A2 DQ3 FUF variant ZIP output | keep buildable on demand only (R101-style minimal outputs); document the command in 설치안내.md |
Impact: phase20.md:18; Collection/install/설치안내.md; build.py; extract.py (Quartz reason, version); manifest.json/md regenerated; API.lua header; install ZIP rebuilt (+ verification ZIP only if Core files change — API.lua comment changes Core → rebuild both, hash in briefs).

## Re-check (same B): 0 / 0 / 2 — all fixed. Minor to final report: n1 FUF swap step moves the fork PitBull4 into a folder that may already hold the user's old PitBull4 (merge prompt; original safe in backup); n2 Details version string repeats the package name. Note: old addons moved back may need their library folders.

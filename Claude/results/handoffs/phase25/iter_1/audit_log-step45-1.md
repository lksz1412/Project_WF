# Audit log — Step 45 review (1) whole scheme — Fable (bada-fable-auditor)

Counts: 중대 2 · 중간 9 · 경미 3

- C1 No single product truth: our install.json 0.1.0 (30 folders, Prat) / Codex "0.1.0" in Step 48 (35 folders, no Prat) / Codex install.json 0.1.2 + Installer Contract.md:12 0.1.2 / Core TOC 0.1.4 + public release tag v0.1.4 (→72e520a, fixtureOnly trial, not rebuildable, contains SexyMap M1 defect, not installable by the installer catalog). Codex put 2,558 addon files incl. upstream copies into Collection/AddOns (plan :178–179 says upstream not committed).
- C2 User decisions R111–R149 exist only on the user's PC (Codex trace cites REQUEST_LEDGER_phase25.md L8–L56; branch file has 7 lines). Numbers collide with our R111–R115. Only R150 「마스터 플랜에따라 구체화 진행하자」 and R151 「ㄱㄱ」 have verbatim text on branch (Codex/results/REQUEST_LEDGER_phase26.md:5–6). Step numbers also collide (Codex Step 44–72 vs ours; "Step 40" has three meanings).
- M1 Master plan stale vs reality: Prat (:25,:218), 1–2 themes (:71; Codex has 13), network no-rerequest (:164,:309,:541,:111 vs R111), results to References/ (:100,:184–185,:409,:413), R110 not in plan body.
- M2 Roles/data flow changed: Codex edited Core/ChatSetup/FUFDefaults/3rd-party (Codex ledger phase29.3 cites user 「진행해.」); no shared pass gate (our core tests fail on Codex branch, genregistry --check fails); of 34 brief result locations only 1 file exists on branch.
- M3 Codex records cite 130 missing targets / 180 links (_local_only, D:/Projects/…, Step 40 integration, codex-appearance 8/19/24, codex-verify phase1, live-checklist…) — claims not re-checkable.
- M4 Game checks 0; check scope shrank from 34 briefs to an 8-row table; /dfp save/restore/preset/spec and Cooldown Manager highlight/sound absent.
- M5 No upgrade path between versions (old Prat-3.0 folder would stay; Codex 설치안내:30 allows separate updates but Installer Contract.md:73 blocks on extra/changed files).
- M6 "Restore to before install" split three ways, none complete (our handover :36 pending; Codex ZIP notes manual backup; installer excludes WTF; no command to undo the 3-chat split).
- M7 R107⑥ "user edits UI via AI" has no defined path; presets/uhd.lua 571 lines with 11 comment lines (brief asked comments per value); Composition.lua:55 any position/size/color edit drops the composite theme image.
- M8 Against R101: 30 → 35 folders (FUF 37), ZIP 18.6MB → 127MB, unpacked 488MB, DevilForever_Appearance 383MiB (81%); test probes (Probe.lua, SessionProbe.lua, DevilForever_UIReviewDB) inside Skin_Nameplates default package.
- M9 Open decisions scattered: Aurora (R107④) undecided on branch; unit default provisional; 4th resolution/4K-only (Codex T7); R13; uiScale unmeasured (uhd.lua:2).
- m1 plan header says draft / R1–R87; m2 two similar folders DevilForever-install/ vs DevilForever-installer/; m3 383MiB TGA as plain blobs, old 0.1.0 ZIP still in outputs.
- Merge decisions proposed (§5): bring local ledger verbatim + number map; base content = Codex branch, frame = our structure (upstream not committed, install.json/manifest/registry generation/core tests); one version name; chat = native?; keep/drop 3rd-party patches; installer in scheme?; shared pass gate; add save/restore/CDM to live checks; 13 themes packaging; Aurora/unit/4th res/R13.
Master verified: Composition.lua:55, Skin_Nameplates.toc:6–10, Codex REQUEST_LEDGER_phase26.md:5–6, Contract.md:12, tag v0.1.4 → 72e520a.

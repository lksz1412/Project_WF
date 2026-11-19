# Audit log — Step 44 — B auditor (bada-b-auditor) — Codex branch codex/review-0.1.4 @72e520a vs 16b801b

Counts: 중대 1 · 중간 5 · 경미 5 (+ 추정 2)

- C1 Package not rebuildable from branch: install.json:4 "0.1.2" vs Core TOC 0.1.4 → build.py:298-300 BuildError (measured dry-run); build.py:113-116 every Collection/AddOns folder must be in install.json own (branch has upstream copies + Appearance/Skin_*/DetailsLayout); genregistry.py:186-187 own-folder check fails; Registry.lua (version 0.1.4) generated from inputs not on branch (manifest.json:16348 "0.1.2").
- M1 Defaults/SexyMap.lua:144-151 writes appearance point/scale/x/y via Defaults fill-missing into EXISTING SexyMap profiles (probe: applied fill-missing on an existing profile) — bypasses Presets fragment rule "only into a nil SV" (Presets.lua:44-46). Core tests miss it (GetPhysicalScreenSize stub missing → pcall log).
- M2 ExperienceForever.lua and SexyMap/Coordinates.lua modified and shipped (hash), but package manifest says "kind": "unmodified" (pitbull4/manifest.json:237-238, :628-629); Collection/manifest.json verdict "settings"; no patch file; install.json treats them as upstream so a normal build drops the edits.
- M3 Prat removed (TOC, registry_extra, Registry) without a recorded decision on branch; install.json:17 still lists Prat-3.0; Defaults/Prat-3.0.lua orphan shipped.
- M4 5 of 9 core failures = test fixture clash with real Presets files loaded by TOC (fixture skips only Defaults/); contract (token<default<preset<edit; restore clears preset frames only) holds when Presets/ excluded (probe). Tests need updating; branch has none.
- M5 (partly inferred) Presets/*.lua and Defaults/SexyMap.lua compute UIParent:GetEffectiveScale() at file load → constants; ChatLayout.lua defers the same calc. Needs client check.
- m1 version labels inconsistent (manifest 0.1.2, TOC 0.1.4, ChatSetup/FUFDefaults TOC 0.1.0 despite changes).
- m2 Defaults/SexyMap.lua:70 TimeManagerClockButton "never" (was "always") — no comment/record. [master: matches user R110 ③ "시계는 상태띠만" — accepted]
- m3 NativeLayout.lua cannot detect /fuf set rejection (FUF prints, returns nil) — labelled sent-unverified.
- m4 Defaults.lua new key preserveSharedProfiles not in validSpec/header doc.
- m5 TOC comment line 23 misplaced.
- inferred: ChatLayout receipt match may release all windows after first /reload if client re-anchors; ChatSetup freeWindows stricter.
- B perf claims: all 4 confirmed in code, all upstream behaviour, real cost small; TinyThreat "중간" overstated (window 2 is the threat window, normally shown).
- C third-party edits: both correct; not recorded as modified (M2).
- D reproducibility: no (C1).

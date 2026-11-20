# Phase 25 detail plan — Codex verification results → fixes → freeze

[Phase 25 start — master plan re-read in full 1–550 (Read 1–240, 241–400, 401–550) on 2026-11-18 after compaction recovery.]

Inputs needed: `References/codex-verify/phase<ID>/` and `References/codex-appearance/<ID>/`. Checked on 2026-11-18 21:17 KST against origin/main b8a7c50: both folders absent. User R109: Codex on hold until the user's PC is free; Claude finishes its own part first.

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 44 | Audit Codex review branch `codex/review-0.1.4` (72e520a + adfd3c8) vs merge-base 16b801b: Codex edits to our addons (Core Presets/Edit/Defaults/API/registry/presets, ChatSetup, FUFDefaults) incl. 9 failing core tests + genregistry --check fail; Codex perf claims (TinyThreat, PitBull4, ExperienceForever, ProfileManager); Codex edits to as-is third-party ExperienceForever/SexyMap; package reproducibility (install.json 0.1.2 lists Prat, package 0.1.4 has 35 folders without Prat); 4 candidate ZIPs (receipt, TOC 16001, scope vs R101); Codex records/R-number collision (Codex local R112–R151 vs ours R111–R113) | B auditor (read-only) + master triage | master mechanical checks (tests, hash compare) + B report with file:line quotes | B once (high) | 90–150 | ✅ 1 critical · 5 middle · 5 minor (triage) |
| 45 | R114 three independent reviews, one after another (no parallel): (1) whole scheme — plan vs product (requirements R1–R114 coverage, roles Claude/Codex, install/restore/registry/presets consistency); (2) code inefficiency — all shipped Lua we own or patched + hot paths of bundled third-party (timers, OnUpdate, event storms, table churn); (3) WoW user usage patterns — is the collection complete for daily/levelling/5-man/raid/healer/PvP/professions, with sources | Fable auditor ×3 (`bada-fable-auditor`, user R115; new sub each, read-only; web allowed for (3); code-optimisation review is the priority) | report with file:line or source links; master triage | — | 120–240 | ✅ (1) 2·9·3 (2) 0·8·10 (3) 0·4·6 |
| 40 | Fix code defects found by Codex verification results (per Phase brief result tables); plus R118: party frames move to Grid2 (Grid2 party layout + FrameDisplay, PitBull4/FUF party groups off; R120: add PitBull4 targetpet frame, keep ToT/ToToT/focustarget); plus R110 ③: hide the minimap clock so only the status-strip clock shows (SexyMap/Phase 5 default + Codex check) | A2 coder + B | static gates + logic review of fixes | code ② | 60–120 (+30–60 per result bundle) | ⏸ after Step 44: apply accepted Codex changes to our branch + fix defects |
| 41 | Freeze final bundle (ZIP, manifest, SHA256), restore method, unverified list, handover | master (handover) / A2 (freeze docs after Step 40) | build rc0 + sha256; handover 5 items | — | 30–60 | ⏸ handover written now; freeze waits for Step 40 |

## R122 decisions (2026-11-19)
- Base line = Codex branch content; Claude re-checks every Codex code change before acceptance (R122 ①④).
- Version: next official = 0.1.5; v0.1.4 stays a trial (R122 ③).
- Installer = user's request (R149–R151) → in scheme (R122 ⑧).
- Third-party inefficiency: fix, keep upstream original + patch (diff) in the work tree, ship only the patched result; on upstream version-up re-apply the diff (R122 ⑨). Hekili deferred to a separate discussion (R122 ⑩).
- Live checklist additions to be reviewed (R122 ⑫).
- Open to Codex (request text): local ledger originals with C-prefix, missing linked files, Prat original wording, Aurora opinion, composite vs individual shell, adaptive layout, release marked trial, pause Collection/ code edits during merge.
- Open to user: item 7 (individual shell) and 13 (adaptive UI) answered by master as proposals; 14, 16 unanswered; 9 "public folder" interpretation to confirm.

## Step 40 breakdown (R118–R123)
| Sub | Work | Owner | Gate | Status |
|---|---|---|---|---|
| 40a | Merge `origin/codex/review-0.1.4` (477eb06) into the work branch (Codex content = base, R122 ①); restore point = pushed commit before merge | master (git) | merge clean, Codex test runner 8/8 | ✅ merge f2d2d7ac clean · runner 8/8 (195) · core 107/108 (genregistry only) |
| 40b | Defaults & defects: Grid2 party layout + FrameDisplay party (R118) with healer indicators dispel border / range fade / incoming heal (R123 14); PitBull4 party groups off, targetpet on, ToT kept (R120); PitBull4 Totems on for SHAMAN only (R123 15); SexyMap appearance only into new profiles (audit M1); move Probe/SessionProbe out of Skin_Nameplates default (R122 11); core tests fixture fix (audit M4) + Prat tests/registry tests updated; manifest/package labels for patched third-party (audit M2) | A2 coder + B (code ②, one review + adversarial) | Codex runner + Collection/tests/core full | ✅ review C+M 4→2→1→1→0 |
| 40c | Runtime: PitBull4 fork fixes M1–M5 of review 2 (aura signature cache, text classify cache + GUID loop, bars once per frame + SetTexture early return, aura normalize without closures, AltManaBar unit filter + hidden-bar return), Core DBTable/Edit:Get allocation + nameplate style cache (M6), CastBar ticker only while casting | A2 coder + B | lupa probes before/after, tests | ⏳ |
| 40d | Third-party patch structure (R122 9): upstream kept separate, patches as diff, shipped = patched; TinyThreat hidden-timer, ExperienceForever, ProfileManager, SexyMap; restore genregistry --check / build.py | A2 coder + B | genregistry --check, build, Codex runner | ⏳ after 40c (R124 confirmed: repo = dev environment, release ZIP = essentials only) |

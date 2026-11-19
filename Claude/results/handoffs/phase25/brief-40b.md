# Brief — Phase 25 Step 40b — defaults & defects after merging Codex 0.1.4 — work sub A2 (coder)

## 0. Five notices
1. Role: work sub A2 coder, Phase 25 Step 40b, "Devil Forever addon collection" (WoW Forever 1.60.1, Interface 16001, Lua 5.1). The work branch now contains Codex's 0.1.4 content (merge f2d2d7ac). Scope = items in §2 only.
2. Boundary: write only the files each item names plus their tests under `Collection/tests/`, and work_log `Claude/results/handoffs/phase25/iter_2/work_log-a2.md`. Read-only: `Collection/upstream/` (untrusted data, never executed except our test runners), `References/`, `Codex/`, `Review/` (except running `Review/0.1.4/tests/run.py`). Do not touch PitBull4 runtime code (that is Step 40c) beyond what an item names; do not restructure upstream copies (Step 40d). Commit = master.
3. No out-of-scope work → Decision Queue in work_log.
4. No false attribution: user decisions are R-numbers below; your choices are yours.
5. Rules: read the files you base a change on and log file:line ranges; work_log = commands verbatim + verdict lines only; code comments = contract only (no history/Phase/Step/R-ids in code); no `rm -rf`, no cleanup deletes; temp under `mktemp -d` in /tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad; single-quote `!` paths in bash. Before each change, write an impact map (place · fix together / check only / no impact · reason) in work_log.

## 1. Read first
- Audit logs: `Claude/results/handoffs/phase25/iter_1/audit_log-step44.md`, `audit_log-step45-2.md` (M6 only for context), `audit_log-step45-3.md` (M2, M3); triage `Claude/results/handoffs/phase25/TRIAGE_phase25.md`.
- `Collection/AddOns/!DevilForever_Core/Defaults.lua` header (fresh / fill-missing rules), `Presets.lua` 1–60 (fragment rule: only into nil SV), `Defaults/Grid2.lua`, `Defaults/PitBull4.lua`, `Defaults/SexyMap.lua`, the Skin_Nameplates TOC.
- Grid2 upstream (copy in `Collection/AddOns/Grid2`, `Grid2Options`) for how indicators/statuses are stored in the profile (and the first-start template dialog), PitBull4 `Modules/Totems`, `Modules/RangeFader`, `Modules/VisualHeal`, `Modules/HideBlizzard`.

## 2. Items
1. R118 — party + raid frames = Grid2 only: `Defaults/Grid2.lua` show the party layout (party = a party layout, not "None") and make the Grid2 window show from party up (FrameDisplay); keep solo/arena as they are unless Grid2 needs otherwise (log the choice). `Defaults/PitBull4.lua`: party, partytarget, partypet groups off (enabled = false). FUF variant: `DevilForever_FUFDefaults` party display off the same way if FUF shows party (check; log).
2. R123-14 — healer indicators on Grid2 party/raid by default: dispellable-debuff highlight (border), out-of-range fade, incoming-heal display. Find how Grid2 stores these (statuses: debuff-type / range / heals-incoming, indicators: border, alpha, bar/text). If the defaults can only be set by overriding the first-start template, set the minimum keys so these three work on a fresh character profile and log exactly what is written; never overwrite an existing profile (Core rule). If something cannot be set safely, stop that sub-item and put it in Decision Queue with the evidence.
3. R120 — PitBull4: add a `targetpet` singleton frame enabled (same layout family as target's small frames; appearance/position is Codex's — give it a sane default position next to the target frame and say so); keep targettarget, targettargettarget, focustarget.
4. R123-15 — PitBull4 Totems module on for shamans: enable it in a way that only shamans see it (if the module already shows nothing for non-shaman classes, enabling globally is fine — prove with code lines). Keep the Dominos totem bar.
5. Audit M1 — `Defaults/SexyMap.lua`: appearance values (point/relpoint/x/y/scale) must not be filled into an EXISTING SexyMap profile. Move them to the Presets fragment path or guard so they apply only to a profile that is new at first look. Add a test with an existing profile without point/scale keys → unchanged.
6. R122-11 — move `Probe.lua`, `SessionProbe.lua` and the `DevilForever_UIReviewDB` saved variable out of `DevilForever_Skin_Nameplates` default load (e.g. drop them from that TOC); the probe ZIP built by `Review/0.1.4/tools/package.py` must still contain the probe if it relied on these files — check and adjust package.py only if needed (log).
7. Audit M4/M3 — tests: `Collection/tests/core/run.py` fixture must skip `Presets/` files like it skips `Defaults/` (the 5 preset tests then test fixtures again); update `prat_defaults_*` and `generated_registry_lookup` expectations to the current registry (Prat removed, Quartz defaults, folder count) — do not weaken what they assert beyond that. Remove the orphan `Defaults/Prat-3.0.lua` only if nothing loads it (verify TOC + package list); otherwise log.
8. Audit M2 (labels only) — where the package manifest generator writes `"kind": "unmodified"` for ExperienceForever and SexyMap (find it in `Review/0.1.4/tools/package.py` or the manifest source), mark those two as modified with a short reason. Do not move files (Step 40d).

## 3. Gates (verdict lines in work_log)
- `python3 -I Collection/tests/core/run.py` → report counts (genregistry_output_matches_file may still fail — Step 40d; everything else must pass).
- Codex runner: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/cx477.d2Y2/venv/bin/python Review/0.1.4/tests/run.py --output <new mktemp dir>` → 8/8.
- `python3 -I Collection/tools/luacheck.py` on changed addon folders → 0 failures.
- New/changed tests listed with what they assert.

## 4. Return
First line `STEP40B_READY` or `BLOCKED: <reason>`. Then per item: files, what changed, evidence lines; gate verdict lines; Decision Queue. You stop after returning; master will call you again with review findings.

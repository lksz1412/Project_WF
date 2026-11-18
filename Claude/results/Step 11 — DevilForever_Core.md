# Step 11 — !DevilForever_Core (Phase 2)

Recorded: 2026-11-18 14:29:14 +0900

## Done
- A2 built `Collection/AddOns/!DevilForever_Core/` (TOC 16001, Core/Registry/Theme/Edit/Defaults/API), `Collection/tools/genregistry.py`, `Collection/tests/core/` (39 logic cases, lupa, stubs — not a client emulator).
- Review B, 3 rounds (R87: new structure module): critical 1 · major 3 → recheck 1: major 3 → recheck 2: major 1 → root fix → master check. Trend 4 → 3 → 1 → 0.
- Key design (TRIAGE_phase2.md): folder renamed `!DevilForever_Core` so it loads first; plain-SV defaults overwrite only for targets first seen fresh in the login window, otherwise fill-missing only; late-created status; `Defaults:Suppress` for restore/import code; AceDB key incl. regional-name branch; theme/edit callbacks never in combat; registry is the source of truth for defaults registration.

## Basis
- Master read: Defaults.lua 135–138, 203–208 (check 1), Theme.lua:84, AceDB-3.0.lua 263–278, Defaults.lua grep first-load/Suppress (final), review reports in full.
- Impact maps and read ranges: `Claude/results/handoffs/phase2/iter_1/work_log-a2.md` (Check 1 fix, Recheck 1 fix, Recheck 2 fix).

## Files
- Collection/AddOns/!DevilForever_Core/**, Collection/tools/genregistry.py, Collection/tests/core/**, plan/phase2 detail/judgment folder-name rename (master, word substitution).

## Gates
- luacheck Core checked=6 failed=0; tests 39/39 (master rerun); genregistry --check up to date; tocdeps unresolved 0 (work_log).
- Cost: A2 ~0.33M, B ~0.27M tokens.

## Next
- Step 12: Codex appearance brief + Codex phase2 real-use brief (load order and same-event handler order checks, N3).
- Open (final report): Edit queue in memory only (minor 2), Clear return inconsistency (minor 3), Details per-character SV note (minor a).

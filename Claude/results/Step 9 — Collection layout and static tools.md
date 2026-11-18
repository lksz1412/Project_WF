# Step 9 — Collection layout and static tools (Phase 1)

Recorded: 2026-11-18 13:25:14 +0900

## Done
- A2 (bada-a2-coder) built `Collection/tools/{toclib,extract,luacheck,tocdeps,build}.py`, `.gitignore` line `Collection/upstream/`, `Collection/AddOns/.gitkeep`, lupa 2.8 (Lua 5.1) installed. Also ran the mechanical part of Step 8: 39 packages extracted (SHA256 39/39), `Collection/manifest.{json,md}` (98 addon folders).
- Review B (bada-a3-reviewer, 1 logic pass per R87): critical 0 · major 2 (duplicate TOC keys / [cond] prefix; AllowLoadGameType ignored) · minor 5. Same A2 fixed M1, M2, minor 1. Master spot-check accepted.

## Basis
- Read: brief-a2.md, work_log-a2.md verdict lines, review report, toclib.py:63–79, extract.py:302, Mapster.toc:1,10, tocdeps --role all output.
- Triage and impact map: `Claude/results/handoffs/phase1/TRIAGE_phase1.md`, work_log-a2.md "Check 1 fix" (impact map rows).

## Files
- Collection/tools/*.py, Collection/manifest.json, Collection/manifest.md, Collection/AddOns/.gitkeep, outputs/collection/DevilForever-collection.zip (placeholder), .gitignore (+1 line)

## Gates (work_log-a2.md verdict lines)
- luacheck Hekili+FUF: checked=322 failed=0; bytecode test rejected.
- tocdeps --role start: unresolved=0, forever_load_no=0; --role all: unresolved=0, forever_load_no=1 (Mapster — mainline only).
- extract rerun byte-identical; unsafe ZIP members 5/5 rejected.
- Cost: A2 ~0.21M tokens, B ~0.18M tokens.

## Next
- Step 8 judgment (A1): per-feature "how to use"; Mapster (Phase 18 start) is mainline-only → needs alternative (V42 Mapster Forever-v2?). Step 10 class table. Phase 1 Codex brief.
- Open: lupa not persistent across containers (A2 DQ 8) — reinstall when needed.

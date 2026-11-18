# Step 8 — Extraction, manifest, how-to-use judgment (Phase 1)

Recorded: 2026-11-18 13:51:40 +0900

## Done
- Mechanical: A2 extract.py — 39 packages (SHA256 39/39), 98 addon folders, manifest.json/md (see Step 9 for tools and review).
- Judgment: A1 `Collection/judgment.md` (291 lines) + manifest how_to_use (20 start packages): feature Phases 2–22 → as-is 1 (15), settings 14, modify 1 (18 Mapster), new 5 (2, 8, 20, 21, 22).
- Findings: Mapster TOC `AllowLoadGameType: mainline` (also V42) — keep, port V42 FogClear guard, Codex checks loadability; Devilconfig has no editor/SavedVariables → Phase 21 = new development; ProfileManager covers 11 of our addons via providers/AceDB, not FUF/ForeverThreat/SexyMap/Bagnon/Titan/Aurora/Core, no spec-change switching; Hekili has class aura/CD data (inferred) but no EventAlert-style center alerts (not found) → Phase 8 branch 2 likely; healer specs unsupported.
- Master decisions on A1 DQ 1–6 (TRIAGE_phase1.md): Phase 18 modify, Phase 21 new, Codex loadability item, Phase 19 start → Experience Forever, tool fixes (mainline = "check", role by plan, keep how_to_use). Phase 21 editor → 3-round review.
- A1 applied plan changes (rows 18/19/21, outline, totals → Claude 2,090–3,790 min, Correction History row); A2 applied tool follow-ups.

## Basis
- Master read: Devilconfig.toc 1–15, V42 Mapster.toc:10, Aurora Skin/init.lua:10–16, codex-briefs/phase1.md 1–60, tocdeps --role start output (how_to_use filled count).
- A1/A2 read ranges and impact maps: `Claude/results/handoffs/phase1/iter_1/work_log-a1.md` ("DQ apply"), `work_log-a2.md` ("DQ5-6").
- Review: judgment = master quote check (R87); tool follow-up = master spot check.

## Files
- Collection/judgment.md, Collection/manifest.{json,md}, Collection/codex-briefs/phase1.md, Collection/tools/{extract,toclib,tocdeps}.py, master plan (rows 18/19/21 etc.)

## Gates
- tocdeps --role start: unresolved=0, forever_load_check=1 (Mapster), forever_load_no=0; extract rerun byte-identical; how_to_use 20/20 kept.
- Cost: A1 ~0.48M, A2 ~0.25M tokens.

## Next
- Step 10 history (class table), Phase 1 Result.

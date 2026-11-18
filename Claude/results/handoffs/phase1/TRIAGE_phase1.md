# Review triage — Phase 1

## Already decided
- From Phase 0 TRIAGE "이미 정한 것" + R83/R86/R87 (D4=나, verification split, use-as-is first, appearance=Codex, review strength master-decided ≤10 rounds).
- Phase 1: role field = by ZIP location; feature_phases = from plan table (A2 Decision Queue 1 accepted).

## Check 1 — tools logic review (B, 1 pass: critical 0 · major 2 · minor 5)
Master confirmed toclib.py:63 overwrite and Mapster.toc:10 `## AllowLoadGameType: mainline`.

| ID | Verdict | Fix · why |
|---|---|---|
| M1 | confirmed major | Merge repeated list keys in one TOC (keep all lines, record each line's `[condition]` prefix/suffix separately instead of gluing it to the first item); tocdeps strips both prefix and suffix conditions. Why: Phase 17 / Bartender4 deps shown wrong. |
| M2 | confirmed major | Parse `AllowLoadGameType`/`ExcludeLoadGameType` (header and per-line); manifest per TOC gets `game_types`; add `forever_load` = "yes" (no restriction or allow list contains forever/camelot), "no" (allow list without forever/camelot, or exclude contains them), with note that camelot = Forever is inferred (unverified, Codex check). manifest.md shows the flag; tocdeps/tocs_for_interface prefer TOCs whose forever_load != no. Why: Mapster (Phase 18 start) is mainline-only. |
| minor 1 | include (same file, one line) | luacheck rejects binary chunks (leading `\x1b`). |
| minor 2–5 | not fixed | list → final report. |
Check 1 fix: master spot-check tocdeps --role all (Mapster flagged, unresolved 0) + toclib forever_load body read — accepted

## Step 8 judgment — master check (R87: master decides strength; quote check)
Confirmed against source: Devilconfig.toc 1–15 has no SavedVariables (launcher only); V42 Mapster.toc:10 `mainline`; Aurora Skin/init.lua:10–16 "Forever ... runs the Mainline UI". Codex phase1 brief read 1–60: 0 backup first, no input automation — OK.

Master decisions on A1 Decision Queue (nonblocking, within approved scope; recorded for final report):
| DQ | Decision | Why |
|---|---|---|
| 1 Phase 18 | accept: Mapster `modify` (port V42 FogClear guard), TOC change only if Codex finds it not loadable; sub-steps 30a/30b | V42 fix shows it ran in game; mainline likely accepted on Forever (inferred) |
| 2 Phase 21 | accept: `new` development (editor + save) using Devilconfig launcher pattern and !DevilUI minimap.lua movers; read Edit Mode Expanded/BlizzMove at Step 34 | source has no editor; R44 editing is required |
| 3 Codex item | accept: add loadability check item (TipTac/Kaliel's/Details/Mapster) to phase1 brief | cheap, covers TOC suffix doubt |
| 4 Phase 19 | accept: start addon → Experience Forever (pet XP) ; Dominos_Progress comparison | requirement "소환수 경험치 지원 여부" |
| 5 tools | A2: mainline → "check" not "no"; show load conditions on required deps; show how_to_use in manifest.md | avoids false "no" |
| 6 role | A2: role = "start" when the package is a start addon in the plan table, else "comparison"; keep `source_dir` for location | role field was misleading |
| A1 note 2 | master: Phase 21 editor counts as new structure module → 3-round code review (R87 exception, ≤10) | editor+save is R44 core; plan Test Plan row to be aligned at Phase 21 detail plan |

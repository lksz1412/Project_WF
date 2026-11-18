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

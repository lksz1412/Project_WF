# Triage — Phase 20 (Step 33, Core save/restore + presets)

## Already decided
DECISIONS_32.md (module in Core; PM for keys/game settings; contract wording; design §11 defaults). Codex on hold (R109).

## Review B 3 rounds (0 / 4 / 10) — master triangulated Profiles.lua:729–738, 566–568, 590, 880–884, 901–904; Presets.lua:385–391 (all confirmed)
| ID | Verdict | Fix (what · why) |
|---|---|---|
| ①-1 request dropped when player key unknown at Core ADDON_LOADED | major, confirmed | Do not drop. If the key is unknown, accept the request only when its age ≤ 120 s (a /reload takes seconds), apply it, and at PLAYER_LOGIN (key known) compare with the stored character key; on mismatch print a loud line pointing to `/dfp restore __before-restore`. Why: Defaults already allows late keys (Defaults.lua:61–62); dropping makes the feature dead on such clients. |
| ③-1 fresh-mode fragment overwrites values a restore just wrote | major, confirmed | WasFresh(sv) returns false for any SV written by this session's restore job (record before write). |
| ③-2 undo slot replaced by partial backup | major, confirmed | When the source snapshot is the undo slot itself, the new undo keeps the previous undo's entries for SVs not written this time (carried). For other sources keep the current one-slot rule. Add test. |
| ③-3 class restore overwrites another character's character-named profile | major, confirmed | For each saved profile name that is another character's current profileKeys target (and not this character's), do not overwrite it: write the saved values into a profile named after this character and point this character's profileKey to it; report the rename. Class/shared-named profiles keep the intended class-wide behaviour. Add test. |
| a phase20.md:18 says 12 folders, list has 11 | minor → fix | count |
| ②-a fresh-mode fragment skips only logged | minor → fix | print one chat line per login when any fragment was kept/skipped |
| ③-b suppression before version check | minor → fix | suppress only folders that pass the version check |
| ③-c keys restore uses snapshot key list | minor → fix | intersect with current registry keys |
| ③-d pending applied on any reload within 600 s | minor → fix | pending becomes armed only by `/dfp go`; un-armed requests are kept, not applied |
| ③-e preset switch half done after cancel/timeout | minor → fix | report on next login that preset X fragments were not written; `/dfp preset X` again finishes |
| ③-f `only <Folder>` not validated | minor → fix | refuse unknown folder before reload |
| ③-g arg parsing (extra words, case) | minor → fix | lower-case part words and YES; reject extra words |
| ③-k test gaps | minor → fix | tests for ③-1, ③-2, ③-3, ①-1 fallback, and T26 with go |
| ②-b whole-SV restore also restores other characters' data | accepted risk (design DQ5) → final report | |

## Impact map
| Place | Verdict |
|---|---|
| Profiles.lua (pending/keys, WasFresh, undo, class restore, suppress order, keys list, armed flag, only validation) | fix |
| Presets.lua (skip report line, half-done report) | fix |
| Commands.lua (parsing) | fix |
| tests/core/run.py (new cases) | fix together |
| phase20.md :18 (+ any item that describes changed behaviour: go arming, key fallback) | fix |
| design-32.md | no change (record of the design; deviations go in work_log) |
| ZIP + hashes | fix together |

## Re-check 1 (same B): 0 / 3 / 5 — ①-1, ③-1, ③-2, ③-3 and the fix-marked minors fixed (quotes in B report). Majors went down (4 → 3); new ones are in the new code.
| ID | Verdict | Fix |
|---|---|---|
| ③'-1 key fallback applies Hero's per-character data on Alt after an interrupted reload; undo cannot repair | major (probe) | Root fix: when the player key is unknown, apply only account-wide `common` entries whose SV is not per-character; skip per-character SVs and the class part (report "캐릭터 확인 뒤 다시 /dfp go"); never label a backup with stored keys — label it "unknown" so undo is allowed on whichever character runs it next with keys known. Same for save: refuse save when the key is unknown. |
| ③'-2 rename target can be another character's live profile | major (probe) | One rule for both: a profile is owned by others if any other character's profileKeys **or** LibDualSpec entry points to it. Never write into such a profile; choose a free target name (keys.char, then "keys.char (2)", …) that no other character uses and that is not already a target in this job. Report every rename. |
| ③'-3 other characters' LibDualSpec mappings not protected | major (probe) | covered by the ③'-2 rule |
| ③'-4 unfinished flag can stick | minor → fix | clear `unfinished` when any preset restore or request completes, and when `/dfp cancel` clears a preset request |
| ③'-5 unarmed request reported everywhere and overwrites `last` | minor → fix | report only on the requesting character; do not overwrite `store.last` |
| ③'-6 kept-fragment line every login | minor → fix | print once per (preset, fragment set) change; remember in Core DB |
| ③'-7 contract wording too narrow | minor → fix | "writes registered saved variables only at load time: after a user command, or preset values into saved variables that are new on disk" |
| ③'-8 two names renamed to one target | minor → fix | covered by unique target allocation |
Tests: one case per major (probe scenarios) + ③'-4/③'-5.

## Re-check 2 (same B): 0 / 0 / 7 — ③'-1..③'-8 fixed (probes). Minor to final report: undo cannot re-attach to a shared class profile (rename again), free name can overwrite this character's unused same-name profile (in backup), unknown-key preset request clears the unfinished flag, cancel clears unfinished with no reminder, Details half restore with unknown key, kept-notice signature noise, phase20 item 4 wording after rename.

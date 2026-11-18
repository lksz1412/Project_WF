# Step 27 — Aurora Codex 발주문 (Phase 15)

Recorded: 2026-11-18 18:27:38 +0900

## Done
Codex briefs for the Aurora use decision (R107 ④, weighed against R101): phase15.md (10 items: load, 7 default windows, options with originals, double skin on collection addons, nameplate/Cooldown Manager skins that cannot be turned off, performance/errors incl. GC change, persistence, decision.md 사용/안 씀, full restore incl. questTextContrast back to the user's own value) and appearance-15.md (branch A DevilForever_Skin_Aurora via Core contract, AuroraConfig option originals kept in our SV + restore command; questTextContrast way back is an addon-free /run line; branch B leave defaults). Nothing shipped; ZIP unchanged.

## Basis
Master: plan re-read 1-549 at Phase start; triangulated Aurora Skin/init.lua 342-344 and phase15.md 85-88, appearance-15.md questTextContrast grep. A2 reads in work_log-a2.md (Aurora toc/config/init/aurora/compatibility/integration/gui files with file:line; briefs 14/2). Impact map: TRIAGE_phase15.md + work_log fix 1-3.

## Files
Collection/codex-briefs/phase15.md, Collection/codex-briefs/appearance-15.md

## Gates
/run lines all <=255 bytes; phase15 items 10 with 3 parts; banned words 0; ZIP sha256 d0210532… and Aurora ZIP sha256 match SOURCE.txt. B: review 0/1/4 → recheck 0/2/0 (root-cause redesign) → 0/1/1 → 0/0/2.

## Next
Phase 16 (Steps 28a/28b) light status strip: design info items and place (Core vs small addon, R101).

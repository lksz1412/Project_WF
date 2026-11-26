# Brief — Phase 27 Step 71: revise the four aura proposals (same A1 analyst)

You wrote `Claude/results/handoffs/phase27/proposal-70-auras.md` in Step 70. Same limits as brief-70 (analysis and design only, no addon code, no commit, no cleanup deletes, mark every claim confirmed / not found / estimated / unverified, side findings to the Decision Queue in `iter_4/work_log-70.md`). If you were compacted, re-read in full first: `brief-70.md`, `proposal-70-auras.md`, `iter_4/work_log-70.md`, `iter_4/devil-aura-images.md`, `Collection/AddOns/!DevilForever_Core/Presets/uhd.lua`, and note the ranges.

## The user's new message (2026-11-26 18:30, R245)

"뭔 개소리야 오른쪽 위로 왜 보내." — the user rejects sending auras to the top-right (the game's default buff frame). Proposals A–D all sent the player's buffs (or all player auras) to the top-right; that is rejected.

## Master's reading (default, recorded in the Decision Queue)

- No proposal moves any aura to the top-right game frame. Auras stay attached to the unit frames, one set per frame (the "two sets" of R238/R239 must not come back), and the game's default buff/debuff frame is hidden (PitBull4 HideBlizzard `aura`), so nothing shows twice.
- The Devil tally stays as evidence, but the player-side choices now come from the frame-attached profiles only (player below 9, above 2, per §3 of the proposal) plus target tallies; say plainly that 107/119 Devil profiles used the top-right frame and that this is the arrangement the user rejected.

## Work

1. Rewrite `proposal-70-auras.md` in place (it is not committed history but the live proposal; keep a short line at the top saying it was revised on 2026-11-26 after the user's message, and why). Keep the tallies and sources. Four proposals again: three from the tally of frame-attached arrangements (player and target), one original recommendation with reasoning. For each: arrangement for player / target / pet / focus, icon sizes fhd/qhd/uhd, fit with Quartz bars, Dominos pet/totem bars, Grid2, quest tracker, Details stack (screen map in `Collection/tests/layoutv2/run.py`), code changes (preset keys, PitBull4 aura layout options, HideBlizzard aura on), pros/cons, supporting versions/sources.
2. Rewrite §7 (user choices) to match; drop the question about the top-right debuff frame.
3. Add the reading range and the changes to `iter_4/work_log-70.md` under a new heading "Step 71".

Return a short report: the four proposals in one line each, what changed from Step 70, unread items.

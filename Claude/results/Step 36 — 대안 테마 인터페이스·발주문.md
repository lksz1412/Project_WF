# Step 36 — 대안 테마 인터페이스·발주문 (Phase 22)

Recorded: 2026-11-18 20:30:29 +0900

## Done
Theme token-set interface checked and small gaps fixed in Core Theme.lua (fallback report for missing tokens, name rules, devil replacement notifies listeners with combat deferral, unchanged/queued switch saves the choice) and Commands.lua (/dfp theme list/switch, status line). Profiles snapshots already carry the active theme. Codex briefs appearance-22.md (1–2 complete themes as concepts, not recolours; candidates are Codex's record; all 20 tokens; file shape <appearance folder>/Themes/<name>.lua calling Theme:RegisterSet; three layouts) and phase22.md (test addon DFThemeCheck, switch/follow/persist/combat/unknown/snapshot, full restore). ZIP sha256 718c3f4a378867550e8d40ec27cccb99302470348ac4f2d090aac8f809cfd874.

## Basis
[Phase 22 start — master plan re-read 1-549.] A2 read ranges and impact map: handoffs/phase22/iter_1/work_log-a2.md. B read ranges in review report (TRIAGE_phase22.md). Master re-ran core 108/108.

## Files
Core/Theme.lua, Core/Commands.lua, tests/core/run.py, codex-briefs/appearance-22.md, codex-briefs/phase22.md, 29 brief hashes, install ZIP

## Gates
luacheck 21/0; core 108/108, other suites pass; genregistry --check; tocdeps 0; build ×2 same sha; /run ≤255 bytes; banned words 0; brief steps simulated in harness. B 0/0/6.

## Next
Phase 23 (Steps 37-38) collection integration check.

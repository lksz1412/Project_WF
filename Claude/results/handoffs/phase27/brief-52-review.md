# Review brief — Phase 27 Step 52 (same review sub B)

Read only. Change type: code ② for `Collection/tools/install_local.ps1` (new dev tool, P3 installer/tool) + doc ② for `Collection/codex-briefs/phase27-game-check.md` (new check list). One review pass each: changed lines + impact-map units + one adversarial item + linked-place check + "connections outside the map". The work sub already ran the dry runs (PowerShell 7 and 5.1) and refusal tests — judge from `Claude/results/handoffs/phase27/iter_1/work_log-52.md`; run something only if the record is missing or looks wrong, and never without `-DryRun` (the real install is master's, after this review).

## Spec

`Claude/results/handoffs/phase27/brief-52.md` (read in full).

## Input files (full)

- `Collection/tools/install_local.ps1`
- `Collection/codex-briefs/phase27-game-check.md`
- Linked: `D:/Projects/Project_WF/_local_only/live-015-pitbull-install-20261124.ps1` (Codex's script whose checks were reused), `D:/Projects/Project_WF/_local_only/claude-p27-stage-255f4725/receipt.json` (read with python for the fields; it is a data file), `Collection/codex-briefs/phase26-step47-check.md`, `Collection/codex-briefs/appearance-26-theme-switcher.md` §3, and for each slash command / test mode the check list cites, the cited file:line in `Collection/AddOns/` (and `Collection/upstream/` if cited).
- Work record: `work_log-52.md` (commands, verdicts, impact map).

## What to check

1. Script vs brief-52 item 2, line by line: fixed root, Wow.exe, process check, link checks, backup-before-write with inventory compare that stops before any game write, per-folder mirror only for package folders, left-alone folders, post-copy inventory compare, installation.json, -DryRun writes nothing, exit codes, PS 5.1 and 7 compatibility.
2. Adversarial: any path where the script writes into the game folder before the backup is verified, deletes something outside a package folder, leaves the game half-installed without saying so, or accepts a wrong root / a stage that does not match the receipt. Think about robocopy exit codes (0–7 success, ≥8 failure), long paths, files locked, a package folder that does not exist yet in the game.
3. Check list: every Step 47/50 item 1–8 and theme-switcher §3 item is present or marked excluded with a reason; Hekili lines removed; each cited command exists at the cited file:line and does what the line says; expected coordinates copied correctly from `phase26-step47-check.md`; no step needs gameplay unless marked.
4. Work sub Decision Queue items 2–3: is either a defect in this change's scope?

Report form and grades: same as the Step 51 review (first line counts; 중대/중간 with file:line + original quote; minor max 5; read ranges; no fix proposals).

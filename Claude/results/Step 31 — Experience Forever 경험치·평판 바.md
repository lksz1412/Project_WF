# Step 31 — Experience Forever 경험치·평판 바 (Phase 19)

Recorded: 2026-11-18 19:15:42 +0900

## Done
Experience Forever 2.0.4 used as-is (no Core defaults file: its AceDB global defaults already have pet bar on, rep bar on, game XP bar faded; Core cannot write AceDB global). Registry entry: frames experienceforever.bar / .minimap, editable item = bar position only (EF re-applies its own width/height/font), SV ExperienceForeverDB account. EF not in our ZIP (Codex installs from References ZIP); Dominos_Progress not shipped. Codex briefs phase19.md (9 items incl. watched-faction and pet record/restore, no quest completion, full restore) and appearance-19.md (three layouts in the Step 5 long top line / black band, EF value files per layout). ZIP rebuilt (Registry.lua) sha256 0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49, hash in 28 briefs.

## Basis
[Phase 19 start — master plan re-read 1-549.] Master triangulated ExperienceForever.lua:44,59,82,373, registry_extra.json:880-903, Edit.lua:7. A2 read ranges + impact map: handoffs/phase19/iter_1/work_log-a2.md (initial + fix 1). Triage: TRIAGE_phase19.md.

## Files
registry_extra.json (EF entry), Registry.lua, tests/core/run.py, codex-briefs/phase19.md, codex-briefs/appearance-19.md, 26 earlier briefs (hash), install ZIP

## Gates
core 61/61 (master re-run), other suites pass, luacheck 14/0, genregistry --check up to date, tocdeps unresolved 0, build ×2 same sha256, /run ≤255 bytes, banned words 0. B: 0/2/3 → 0/0/0.

## Next
Phase 20 (Steps 32-33) settings save/restore — ProfileManager scope + preset restore.

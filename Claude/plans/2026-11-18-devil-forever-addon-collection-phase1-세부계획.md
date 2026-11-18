# Phase 1 detail plan — sources, tools, "how to use" judgment, class table

[Phase 1 start — master plan body re-read: lines 1–100 (outline), 100–359 (Ground Truth, constraints, structure map, Phase Range table, Implementation Changes) on 2026-11-18.]

Language: English (internal tier). Review strength per R87 exception (master decides, ≤10 rounds).

| Step | Work | Owner | Gate (command + evidence) | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 8 | Extract start + comparison ZIPs to `Collection/upstream/<name>-<ver>/` (path-traversal check, no symlinks, SHA256 vs SOURCE.txt); machine-extract per addon: TOC fields (Interface, Version, Dependencies, OptionalDeps, SavedVariables[PerCharacter], LoadOnDemand), file count, Libs versions, license file names; write `Collection/manifest.json` draft; then first-pass "how to use" judgment per feature Phase (as-is / settings / modify / new) from manifest + Codex ANALYSIS.md + targeted reads, recorded in manifest with reasons | A2 coder (extraction script) → A1 analyst (judgment) | `python3 Collection/tools/extract.py` rc0; manifest has 13 start + comparison addons; every TOC 16001 present for Forever picks; judgment table covers Phases 3–22 | tool script: 1 logic review (B); judgment: master check vs source lines | 120–240 min | ⏳ |
| 9 | tools + layout (see Step 9 history) | A2 | done | 1 review, M1·M2 fixed | 30–60 | ✅ |
| 10 | Forever class/spec/resource table from Hekili class modules + FUF source (no Retail invention; unknown = "source missing") → `Collection/data/classes.json` + md | A1 (same as Step 8) | every row cites file:line; classes count stated with source | master check | 45–90 min | ⏳ |
| — | Phase 1 Codex real-use verification brief `Collection/codex-briefs/phase1.md` (R9 current addons, client version, resolution/UI scale, class list check, R13 optional retail WTF upload — D5) | master or A1 | file exists, ≤10 items, each with how/expected/result line | — | (in Step 10) | ⏳ |

Unit: same A2 (Steps 8 extraction + 9 tools) ↔ same B; same A1 (Step 8 judgment + Step 10). Serial (one live sub at a time).

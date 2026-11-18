# Phase 2 detail plan — common appearance: code base (Claude) / appearance (Codex)

[Phase 2 start — master plan body re-read: outline 7–86, Implementation Changes 302–355, Implementation Interfaces 391–406, Test Plan 407–448 on 2026-11-18.]

Language: English. Review per R87 exception: Core = new structure module → 3 rounds (linkage, meaning, adversarial).

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 11 | `Collection/AddOns/DevilForever_Core/`: TOC (16001), registry (static Lua data generated from manifest by `Collection/tools/genregistry.py`), defaults injection (once per addon on first load, never overwrite user values; AceDB + plain SV), theme token API (named tokens, token-set switch for Phase 22), per-frame edit-value API (persisted in Core SV, overlays tokens), appearance frame-name list, public API doc block; combat-safe (no protected frame changes in combat) | A2 coder | luacheck rc0; tocdeps with Core; lupa unit harness of pure-Lua parts (registry/defaults/token/edit merge) with stubbed WoW globals — logic only, not a load harness (R86) | 3 rounds by B | 150–240 | ⏳ |
| 12 | Apply review fixes; write Codex appearance brief `Collection/codex-briefs/appearance-2.md` (Step 5 design: 3840×2160, 80px buttons, 304px bottom block, 28px status strip, 3 chats, minimap, center 8×3, long top row, end caps; input pass-through; texture judgment R52; token/edit-value read contract; frame names; V42 reset code to exclude) and Codex real-use brief `Collection/codex-briefs/phase2.md` | A2 (fixes) + master/A2 (briefs) | briefs exist; ≤10 items each with how/expected/result line | master check | 45–90 | ⏳ |

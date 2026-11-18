# Phase 20 detail plan — Settings save/restore (ProfileManager + scoped restore + layout preset restore)

[Phase 20 start — master plan re-read in full 1–549 (Read 1–240, 241–390, 391–549) on 2026-11-18.]

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 32 | Read ProfileManager v4.0 (Providers/Addons/Keybinds/GameSettings) and V42 Reflux mechanism; map which collection addons/SVs PM supports; design the missing scoped restore (registry SVs only, keep missing addons' entries, never silently reset unknown-version data, common vs class/spec split + spec switch, keybinds/game settings only on user choice, no macros) and the layout-preset restore (FHD/QHD/UHD: drop AI-edited edit values, return to preset values — R107 ⑥; restore calls Defaults:Suppress); where it lives (Core module vs PM extension vs small addon — R101/R44); Core layout-preset layer interface for Codex presets | A1 analyst | design doc complete with file:line evidence; every gap cited | master check (feeds 33) | 60–90 | ✅ |
| 33 | Implement per design, lupa logic tests with fake SV data, luacheck, registry, build ZIP + hashes, Codex briefs phase20.md (no appearance brief — plan row 451) | A2 coder | luacheck rc0, tests pass, genregistry --check, build sha256 | B 3 rounds (연계·뜻·적대) — new structure module (plan line 428) | 120–210 | ✅ |

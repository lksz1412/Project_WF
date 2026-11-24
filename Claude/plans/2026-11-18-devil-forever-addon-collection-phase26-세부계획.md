# Phase 26 detail plan — Codex live 0.1.5 tuning branch merge + status-strip theme switcher art

[Phase 26 start — master plan re-read in full 1–558 (Read 1–200, 200–400, 400–558) on 2026-11-24.]

Inputs: Codex branch `origin/codex/live-015-pitbull-20261124` @d8b63f59 (6 commits on main d4ae2f75; user decisions in `Codex/results/REQUEST_LEDGER_phase31.1.md` G77-1…76); user decisions R130, R131.

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 46 | Codex appearance brief `Collection/codex-briefs/appearance-26-theme-switcher.md`: theme names as English script lettering images (gold, cursive) per theme, decorative arrow images (prev/next, normal/hover/pressed/disabled), strip background unchanged, sizes per fhd/qhd/uhd from the strip preset, file naming/paths, how ThemeSwitcher.lua consumes them (texture swap instead of FontString), animation kept, fallback to text when a texture is missing, deliverables + checks. Codex makes the images and applies them (R131) | A2 writer + B | banned words, paths exist, code refs checked | ② one B pass + adversarial | 30–60 | ✅ review C+M 3→1→0 |
| 47 | Review and merge the Codex live branch; apply R130 (PitBull4 party + Grid2 both, PitBull4 base, version rule) and G77 decisions; fix the patch-count test; rebuild 0.1.5 ZIPs + catalog | A2 coder + B | all suites, genregistry, patches verify, build twice identical, catalog --check | code ② | 120–240 | ⏳ after user go |

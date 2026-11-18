# Step 43 — PitBull4 Forever variant and comparison (Phase 6-rev; includes Phase 2-rev Core change)

Recorded: 2026-11-18 17:35:26 +0900

## Done
- Collection/AddOns/PitBull4/ = v4.2.50 + Forever TOCs + 70 V42 files (9 kept from v4.2.50; library picks by higher minor), version v4.2.50-forever.1; Collection/patches/PitBull4.patch reproduces the tree from v4.2.50.
- Defaults/PitBull4.lua: AceDB PitBull4DB profile "Default", 26 targets (main + 25 namespaces) with the Devil "Wide" profile's functional values (units/groups/layouts, module on/off incl. CastBar per layout, auras, LuaTexts, HideBlizzard castbar=false, lock, minimap icon hidden, made_units/made_groups, group_anchors_updated, Normal layout exists); 164 appearance paths → Codex fragment (appearance-6-rev.md).
- Comparison Collection/data/unitframes-compare.md: both cover health + class resources except warlock soul shards (neither); PitBull4 = AceDB (Core defaults + Phase 20 restore direct, spec profiles); cost = modified copy to re-port per upstream version, auto-update off. Default ship decided in Phase 23.
- **Phase 2-rev (Core rule change, review-driven):** AceDB targets are written only into a profile that was new at Core's first look (snapshot taken without the player key); existing profiles kept ("existing-profile-kept"). Fixes overriding user choices that AceDB strips at logout (affects Dominos/Prat/Hekili/PitBull4 defaults). Header comments of Defaults/Dominos.lua and Hekili.lua corrected by master.
- Review B 1 pass: critical 0 · major 1 (Core AceDB rule) · minor 4 → fixed M1 + minors 1, 3 → recheck: major 1 new (late player key) → snapshot fix → master check (code read + tests 59/59).
## Basis
- Master read AceDB-3.0.lua:172–174, Defaults.lua:49 (old), snapshotAce/inspectAce (new, 229–273), review reports; triage Claude/results/handoffs/phase6-rev/TRIAGE_phase6-rev.md; A2 impact maps in work_log-a2.md.
## Gates
- luacheck checked=202 failed=0; core 59/59 (master rerun); castbars 16, chatsetup 13, fufdefaults 16, pitbull4 6; patch reproduces tree; build sha256 81b23bd0…7ef7 (16 briefs updated).
## Next
- Phase 9 (Grid2). Open: shards gap (R61), late-key fresh install applies after /reload (DQ14), applied-before-newness (reset case), LibDualSpec dead refs in other-flavour TOCs, frames stacked until Codex fragment.

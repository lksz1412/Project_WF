# Audit log — Step 45 review (2) code inefficiency — Fable (bada-fable-auditor) — target codex/review-0.1.4 @adfd3c8 (addon code unchanged in 477eb06)

Counts: 중대 0 · 중간 8 · 경미 10

Critical 0 basis: no OnUpdate in our addons; one 1 s ticker (StatusStrip); no CLEU in ours; nameplate handler exits in combat; no unbounded SV; 383MiB textures not loaded at login; no self-rescheduling combat deferral. Unmeasured: native UpdateAllAuras cost (could raise M1).

- M1 PitBull4 fork Aura/Forever.lua:112-142,153-161,177,284-286 — style_signature rebuilt (≈10 tables, ~70 tostring, sort, concat) per aura update ×4 per frame, layout table, native container reconfigured + UpdateAllAuras each time; combat start/end UpdateAll twice (Aura.lua:109-110 + Forever.lua:297-300). probe(stubbed) 88µs·12KB per frame update.
- M2 PitBull4 fork Aura/Update.lua:56-66,103-125,155-187,446 etc — closure+pcall per field per aura (~20); sort comparator calls is_aura_mine twice. probe 5.4µs·1.9KB per aura.
- M3 PitBull4 fork HealthBar.lua:372-379, PowerBar.lua:51-53 — immediate update + queued update; UNIT_POWER_UPDATE and FREQUENT both → 3 redraws per change; LiveStatusBar:SetTexture no same-path early return; upstream batched per frame (guids_to_update).
- M4 PitBull4 fork LuaTexts/Forever.lua:14,28-29,66,70 — 7–11 pattern searches per text update (81µs for the 936-char class text on UNIT_AURA); per-event SafeGUID/UnitGUID("pet") per font string (16× upstream).
- M5 PitBull4 fork AltManaBar.lua:44-50 — RegisterEvent for all units (upstream RegisterUnitEvent "player"), no hidden-bar early return, %.17g string round trip.
- M6 Skin_Nameplates/Appearance.lua:18-51,110-117 + Core.lua:290-292 DBTable, Edit:Get deep copies — ~30µs·4.5KB + 3 widget calls per NAME_PLATE_UNIT_ADDED out of combat.
- M7 DevilForever_Appearance TGA 156 files 382.9MiB uncompressed (82% of package); only ~6–10MiB loaded; 228MiB other-resolution presets never used per machine; 156MiB fallback _deck.tga unused when _deck_reviewed exists.
- M8 Profiles.lua:487-488,73 — snapshots of whole SVs (HekiliDB etc.) up to 11, no byte cap, loaded every login (account-wide).
- m1 Appearance full re-apply ~0.5ms·87KB per change, several times at login; m2 Dominos skin per UPDATE_BINDINGS; m3 NativeChat chrome() tables, full apply after each combat; m4 leftover ADDON_LOADED etc. handlers, Castbars hookAll retry loop forever when an FUF bar is missing, ChatLayout 4 s timer when unmanaged; m5 all three presets computed at load; m6 PitBull4 CastBar 0.15 s ticker if module enabled in existing profiles; m7 small closures in fork; m8 Hekili frameBudget 0.7 default + our bar-glow on; m9 probes shipped in Skin_Nameplates; m10 FUF castbar double handling.
- Heaviest bundled: CPU Hekili; size Details (no CLEU parser on Forever); next PitBull4 fork.
- Top-10 order: M1, M4, M3, M2, M6, M5, M7, M8, m6+m8, m1/m2/m4.
Master verified: Aura/Forever.lua:284-286, PowerBar.lua:51-53, HealthBar.lua:372-377, AltManaBar.lua:44-50 vs upstream RegisterUnitEvent "player" (AltManaBar.lua:35-37); PitBull4 code identical to our 16b801b (fork = ours, from V42 Forever build).

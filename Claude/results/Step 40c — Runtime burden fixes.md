# Step 40c — Runtime burden fixes (Phase 25) — R117

Recorded: 2026-11-20 10:18:03 +0900

## Done
- PitBull4 fork: aura native container/style rebuilt only on settings/profile/font/restriction/unit change (option setters bump the settings version; UNIT_AURA safety net calls UpdateAllAuras once), one combat-transition UpdateAll; LuaTexts classification cached per code string, GUID loop without per-text conversions; health/power bars once per frame, PowerBar only UNIT_POWER_FREQUENT, SetTexture early return; aura normalise without per-field closures, is_aura_mine once; AltManaBar unit events + hidden-bar return; CastBar ticker only while casting.
- R120 targetpet singleton support + default (fresh profiles), Codex positions in three presets (only into existing unit entries on /dfp preset).
- R123-15 Totems module created only for shamans; Codex sizes/positions.
- Grid2 frameBorder 2/3/4; preset values re-applied after Grid2's first-start template (wrapper on MakeDatabaseDefaults, return value).
- Core: DBTable key only on fallback, Edit:Get cache (invalidated on edits/themes/presets/restore; theme login restore via switch()), nameplate style cache, Core:Off; leftover handlers removed, Castbars retries capped, ChatLayout timer only when managed.
- Probes (stubbed) before→after: aura container calls 17→0/update, garbage 10KB→0.4KB; text pattern searches 9.5→0; UNIT_HEALTH SafeGUID 65→17; bar redraws 3→1; aura normalise 2.2KB→0.005KB; AltManaBar frame updates 10→0; CastBar idle updates 66→0 per 10 s; Edit:Get 0.87KB→0.08KB.

## Basis
brief-40c.md; A2 work_log iter_3/work_log-a2.md (parts 1–2, fix 1–2, impact maps, probes); B audit iter_3/audit_log-40c.md; triage TRIAGE_phase25.md; Codex layout References/codex-appearance/25-codex-handoff/README.md + positions.json. Master verified quoted lines per round.

## Files
PitBull4 fork (Aura/Forever.lua, Update.lua, FilterTypes.lua, Highlight.lua, LuaTexts ×2, HealthBar, PowerBar, BetterStatusBar, AltManaBar, CastBar/Forever.lua, Totems, Utils, Main), Collection/patches/PitBull4.patch; Core (Core.lua, Edit.lua, Theme.lua, Presets.lua, Profiles.lua, Defaults/PitBull4.lua, Defaults/Grid2.lua, Presets/fhd|qhd|uhd.lua); Skin_Nameplates/Appearance.lua; Appearance/SharedMedia.lua; Castbars.lua; ChatLayout.lua; tests pitbull4runtime (new, 19), firststart 24.

## Gates
core 107/108 (genregistry → 40d), firststart 24/24, fufdefaults 22/22, pitbull4 5/6 (LICENSE → 40d), pitbull4runtime 19/19, chatsetup 28/28, castbars 16/16, statusstrip 20/20, luacheck 220 files 0 fail, Codex runner 8/8 (195). Game-client behaviour unverified (DQ: native aura container follows UNIT_AURA; nameplate texture read-back).

## Next
Step 40d — third-party patch structure (R122 ⑨, R124): upstream originals + diffs, release ZIP essentials only, genregistry/build.py restored; TinyThreat hidden timer, ExperienceForever, ProfileManager.

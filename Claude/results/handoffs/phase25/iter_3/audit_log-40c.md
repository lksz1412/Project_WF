# Audit log — Step 40c review 1 — B (bada-a3-reviewer) — code ② — diff fd4b6c9d..40f75095

Counts: 중대 1 · 중간 2 · 경미 3
- C1 Aura/Forever.lua:281-291 fast path keyed on settings_version; :354-356 bumps it only on AceConfigRegistry ConfigTableChange, which AceConfigDialog ActivateControl does not fire (it calls set then Open; NotifyChange only in SelectGroup:492). Aura option setters call Options.UpdateFrames()/PitBull4_Aura:UpdateAll() directly → native debuff container keeps old settings until reload/profile/font/restriction change (repro c40.nZJp/aura.py; test fires the callback by hand).
- M1 Theme.lua:209-211 PLAYER_LOGIN saved-theme restore does not bump Theme.version (switch() :151-152 does) → Edit:Get cache serves devil tokens all session if called before login (repro c40.nZJp/theme.py); candidate early caller Skin_StatusStrip/Skin.lua:16.
- M2 DQ6: Grid2 first-start templates (Classic/Modern/Blizzard) overwrite frameWidth/Height/frameBorder/Padding after preset fragments → item 11 values lost on fresh installs (install notes recommend Modern).
- m1 Castbars retry cap 3 per session; m2 `/dfp preset` request writes a position-only "대상의 소환수" entry into existing PitBull4 profiles; m3 nameplate font size compare may miss on rounded GetFont.
Refuted (no defect): aura cache other paths, DQ1 safety net, LuaTexts, bars, normalise helpers, AltManaBar, CastBar ticker, targetpet, Totems, Core:Off, handler cleanup.

## Re-check 1 (same B) — 중대 0 · 중간 1 · 경미 1 (was 1·2·3)
- C1, M1, m2 fixed; DQ10 no frequent caller of wrapped UpdateAll.
- M2-r Defaults/Grid2.lua post-hook on MakeDatabaseDefaults runs after the FIRST call, which only opens the first-boot dialog and returns false (GridDefaults.lua UpdateDefaults/MakeDatabaseDefaults), records done[key]; the later call that applies the chosen template is skipped → template values remain (repro c40f1.KnKW/grid2.py: after Modern 66 46 1 2). Harness stub never simulates the dialog call.
- m DQ11: metadata API present on Forever (PitBull4 Main.lua:1597 uses C_AddOns.GetAddOnMetadata) → fragments not skipped; only the no-API fallback compares "4.1.13-forever".

## Re-check 2 (same B) — 중대 0 · 중간 0 · 경미 0
- M2-r fixed: wrapper uses MakeDatabaseDefaults' return value; dialog-first sequence keeps (96,32,2,4) for Classic/Modern/Blizzard; installed at Core's ADDON_LOADED("Grid2") before OnEnable→LoadConfig; new profile from Grid2 options not touched (no preset record); profile reset after done keeps template values (user action, once only).
Trend (critical+middle): 3 → 1 → 0.

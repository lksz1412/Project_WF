# Audit log — Step 40c review 1 — B (bada-a3-reviewer) — code ② — diff fd4b6c9d..40f75095

Counts: 중대 1 · 중간 2 · 경미 3
- C1 Aura/Forever.lua:281-291 fast path keyed on settings_version; :354-356 bumps it only on AceConfigRegistry ConfigTableChange, which AceConfigDialog ActivateControl does not fire (it calls set then Open; NotifyChange only in SelectGroup:492). Aura option setters call Options.UpdateFrames()/PitBull4_Aura:UpdateAll() directly → native debuff container keeps old settings until reload/profile/font/restriction change (repro c40.nZJp/aura.py; test fires the callback by hand).
- M1 Theme.lua:209-211 PLAYER_LOGIN saved-theme restore does not bump Theme.version (switch() :151-152 does) → Edit:Get cache serves devil tokens all session if called before login (repro c40.nZJp/theme.py); candidate early caller Skin_StatusStrip/Skin.lua:16.
- M2 DQ6: Grid2 first-start templates (Classic/Modern/Blizzard) overwrite frameWidth/Height/frameBorder/Padding after preset fragments → item 11 values lost on fresh installs (install notes recommend Modern).
- m1 Castbars retry cap 3 per session; m2 `/dfp preset` request writes a position-only "대상의 소환수" entry into existing PitBull4 profiles; m3 nameplate font size compare may miss on rounded GetFont.
Refuted (no defect): aura cache other paths, DQ1 safety net, LuaTexts, bars, normalise helpers, AltManaBar, CastBar ticker, targetpet, Totems, Core:Off, handler cleanup.

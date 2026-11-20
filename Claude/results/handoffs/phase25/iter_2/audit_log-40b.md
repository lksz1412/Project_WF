# Audit log — Step 40b review 1 — B (bada-a3-reviewer) — code ②

Counts: 중대 1 · 중간 3 · 경미 5
- C1 FUF variant: FUFDefaults.lua:126-129 existing characters (0.1.4 record) stop at "done-before"; a new character sends `set party hideBlizzardFrame on` + `set party enabled off` (:143-146) into the shared FUF unit profile "Default" (UnitProfiles.lua:51-52) → existing characters lose FUF party while their existing Grid2 profile keeps 0.1.4 party "None"/FrameDisplay "Raid" → no party frame at all.
- M1 PitBull4 variant: Defaults/PitBull4.lua:24 PROFILE "Default" (existing on 0.1.4 installs → party groups stay enabled) vs Defaults/Grid2.lua:30 profile "$char" (new character profile gets party "By Group", FrameDisplay "Grouped") → new character on existing install sees PitBull4 party + Grid2 party (also one-session variant).
- M2 SexyMap: Defaults/SexyMap.lua:166-167 fragment + Presets.lua:408-409 request mode → Core.WriteOver replaces SexyMap2DB["Hero-Realm"]="global" with a partial {core={shape,point,relpoint,x,y,scale},borders}; SexyMap.lua:343 then skips core defaults → :502 autoZoom nil comparison error (repro scratch b40b.boxW/exp_global.py).
- M3 SexyMap: Presets.lua:417 freshness by saved variable (account) while values keyed per character (:167); second character on existing SexyMap2DB → state "already", no appearance and no notice (Presets.lua:505 reports kept/skipped only). Brief asked "profile new at first look".
- m1 Registry.lua Skin_Nameplates: savedVariables key removed instead of `{}` (generator shape); m2 FUF party commands no read-back, "sent" permanent; m3 "kind": "modified" new vocabulary; m4 firststart test premise without CoreDB applied record differs from real install; m5 kept-set signature change prints one extra notice on upgrade (harmless).
Refuted: Grid2 Grouped/arena, template vs layouts, Blizzard party hiding on fresh installs, combat deferral, AddFragment validation/TOC order, Prat deletion refs, probes, test weakening.
Master verified: FUFDefaults.lua:126-129, Defaults/SexyMap.lua:166-167, Presets.lua:417, Grid2.lua:30 "$char", PitBull4.lua:24 "Default".

## Re-check 1 (same B) — 중대 1 · 중간 1 · 경미 4 (was 1·3·5)
- C1/M1/M2/M3/m1/m4/DQ7 fixed.
- R1 (critical) FUF fresh install: Party.lua:175-177 writes Grid2 at ADDON_LOADED, FUF side only session.fufOff (:181-182); FUFDefaults sends after 20 s (FUFDefaults.lua:40,:170). /reload within 20 s → FUF SV now exists (Boot.lua:27) → next session "unchanged" → Grid2 party + FUF party = two sets, permanent (repro exp_fufreload.py).
- R2 (middle) `/dfp party` writes the shared unit-frame profile (Party.lua:267, :276-279) but only this character's Grid2 profile (:248-252) → other characters on the same unit profile get none/two party frames (repro exp_cmd_alt.py); notes don't say to repeat per character.
- m: late keys "not-settled" (consistent), Grid2 global.defaultProfileName case, FUF Set not-ready/invalid prints success + Describe stale, package notes LF→CRLF header lines.

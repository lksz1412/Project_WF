# Audit log — Step 45 review (3) usage completeness — Fable (bada-fable-auditor) — product codex/review-0.1.4 @477eb06

Counts: 중대 0 · 중간 4 · 경미 6

Conclusion: no UI axis missing; add 0 new addons to default (agrees with Codex astra-review:27, R101). Gaps are activity helpers never put to a decision (quest helper, boss warnings) and two defaults.
- M1 No way to show not-yet-accepted quests on the map; Questie never decided (plan 230 lists it only as reference; R100 removed the tracker). Inven users: 「기본 ui는 내가 안받은 퀘는 표시가 안됨」. Forever build on Wago (1.60.1). → optional #1 (rights notice, R101).
- M2 5-man healer: PitBull4 party highlight=false (Defaults/PitBull4.lua:154-156), RangeFader off (:445-448), VisualHeal off (:486-490); Grid2 party None. User R96 「힐러도 생각하고 있어서」. [master: R118 moves party to Grid2 → Grid2 party needs dispel/range/incoming-heal indicators]
- M3 (inferred) Shaman totem remaining time may have no display: PitBull4 Totems disabled (:480-484); Blizzard TotemFrame parented to PlayerFrame, which PitBull4 HideBlizzard hides; Dominos totem bar shows spell cooldown, not totem duration. Cooldown Manager might cover it — unverified. User starts with Shaman (R7).
- M4 Raid boss warnings absent; game default does not load EncounterWarnings on Forever; DBM Forever modules are skeleton only; → not now, DBM optional after raids open 2026-12-09.
- m1 What's Training? description misses its main use (class trainer spells); m2 astra-review inconsistencies (FarmerNodes vs "not in list", DBM or BigWigs); m3 Forever Loot Sparkles = one CVar (outlineModeShowLootEffectWhenDisabled=1) → install note line; m4 설치안내 assumes BugSack/BugGrabber present but not bundled; m5 add game-default tips to install notes (/입장 파티찾기, showInGameNavigation, CDM buff tracking, rank macros); m6 4K UI scale guidance missing for game-default frames.
- Optional list order: Questie+QuestieDB, Loot Sparkles (or CVar), What's Training?, DungeonJournal, Leatrix Plus, Auctionator, BugSack+BugGrabber, DBM (after 12-09), FarmerNodes/GatherMate2. Not needed: bag/tooltip/map/tracker addons (R100), Clique/Better Click Casting (R97), OmniCC, nameplate addons, LFG/mail/BG timers, BigWigs/LittleWigs, WeakAuras (no Forever build).
Master verified: Defaults/PitBull4.lua:154-156 highlight=false, :480-484 Totems disabled.

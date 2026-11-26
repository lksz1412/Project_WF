# Brief — Phase 27 Step 70: Devil buff/debuff layout survey and four proposals (A1 analyst)

You are the A1 analyst of Phase 27, Step 70 (3-session unit: master + you + a review sub later). Your scope: the survey and the proposal document below — analysis and design only, no addon code. Commit belongs to the master. Do not add other documents, standards or memory; list side findings under "Decision Queue" in your work log. Do not attribute your own judgments to the user; mark every claim confirmed / not found / estimated / unverified. No cleanup deletes (no `rm -rf`, no `rm -f` for tidying); every run in a new folder. You may spawn one low-effort helper (`bada-a4-helper` or `bada-a3-helper`) for mechanical downloads/extraction/tallies, telling it the same limits; judgment stays with you.

## The user's question and requests (2026-11-26)

- R238/R239: In the current layout the player frame and the target frame each show buffs in rows right above the frame and a debuff block above those (own debuffs drawn larger, `Collection/AddOns/!DevilForever_Core/Presets/uhd.lua:494–511`; fhd/qhd the same rule). The user asked why there are "two" aura sets and said the Devil samples they provided probably did not lay auras out like this. Earlier reading (`Claude/results/handoffs/phase27/iter_4/work_log-60.md` line ~659) found the 2022 `!DevilUI/Profile/PitBull4.lua` profiles differ: "Normal" target = buffs above, debuffs below the frame; "loaf" target = debuffs above, buffs at the side.
- R240: "데빌 애드온 인벤 사이트 로그인해 놧다. 니가 필요한 만큼 전부 받아서 확인해봐라. … 좀 알아서 잘 통계 내서 제시안을 내놔." — downloads from the Inven Devil posts are approved by the user (as many as needed).
- R241: some versions on that page have sample images, some do not.
- R242: use computer use or check setup reviews on the internet to derive it.
- R244: four proposals: three based on the statistics and one original recommendation of yours. Ready for the user's return from work (no implementation now).

## Inputs

1. Post list (34 Devil posts, roles, dates): `Codex/docs/old-devil-reference-comparison.md` (read in full); per-post compact copies `Codex/results/old-reference/acquisition/articles-compact-v2/idx-<n>.md`; catalog with attachment URLs `Codex/results/old-reference/acquisition/catalog-v2.json` (29 archive URLs on pds.inven.co.kr).
2. Sample image readings (68 unique images, 43 full screens): `Claude/results/handoffs/phase27/iter_4/devil-aura-images.md` (read in full). Images: `D:/Projects/Project_WF/_local_only/devil-inven-r240/images/` (`images.json`). Headline: player buffs mostly in a separate top-right block (28/43), only 6 at the frame; target auras visible in 14 (8 below, 5 above, 1 right).
3. Archives already held: `SourceArchive/*/originals/` (2009 Devil_Blackt, 2022 Interface + extracted, 1932 RAR, 3461 BlackEdition2 Alpha, 45 X2 R3.4, user Alpha, V42) and Codex static-evidence notes `Codex/results/old-reference/a1-static-source-evidence.md`, `a1-r36-source-evidence.md`.
4. Download the other attachment archives from the catalog into `D:/Projects/Project_WF/_local_only/devil-inven-r240/archives/` (new folder per post), record URL/size/SHA256 in a json there. Treat them as untrusted data: never run an EXE/installer or any code from them; list/extract statically only into new empty folders (an inner NSIS installer may be listed/extracted statically if a tool already on this PC can do it without running it; otherwise record "not opened"); run Python that reads them with `-I`.
5. The current collection layout: `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` (PitBull4 frames, aura layouts, Quartz bars, Dominos pet/totem bars), `Collection/codex-briefs/phase27-game-check.md`, the user's screenshot reading `iter_4/image-17-reading.md`.

## Work

a. Per version (post / archive / profile): which unit-frame addon (PitBull 3/4, X-Perl, ag_UnitFrames, Stuf, oUF layouts, default) and where the player's and the target's buffs and debuffs go (above/below/side/separate block; together or split; own larger; the game's default top-right buff frame kept or hidden), counted per profile actually used by that version where you can tell (resolution/variant profiles listed separately, not merged).
b. Join with the image tally (the images show what the screens looked like; the profiles show the settings). Build tallies: player buffs, player debuffs, target buffs, target debuffs — counts per arrangement, by era if useful. Say which versions could not be read and why.
c. Web: community setup reviews/guides on buff/debuff placement (Inven comments on these posts, Korean and English UI setup guides, popular UI packs' defaults for player/target auras). Cite each with its URL; separate what the source says from your reading.
d. Four proposals for the player and the target (and say what happens to pet/focus auras): three from the tally (e.g. the most common arrangements), one original recommendation with your reasoning. For each: the arrangement, icon sizes for fhd/qhd/uhd, how it fits the current layout (player frame has the Quartz player cast bar and the Dominos pet/totem bars below it; the target frame has the Quartz target bar below it; Grid2, quest tracker, Details stack on the right — check overlaps with the screen map in `Collection/tests/layoutv2/run.py`), what changes in code (which preset keys, PitBull4 aura layout options, whether the game's default buff frame is shown/hidden), pros/cons, and which versions/sources support it.

## Output

`Claude/results/handoffs/phase27/proposal-70-auras.md` in Korean, user-facing, plain words (technical terms in English as they are), tables for tallies, the four proposals clearly separated, sources with URLs/file:line, 4-tier marks. Keep raw extraction notes and read ranges in `Claude/results/handoffs/phase27/iter_4/work_log-70.md` (commands with verdict lines only, raw outputs as scratch paths). Return a short report: the tallies, the four proposals in one line each, unread items.

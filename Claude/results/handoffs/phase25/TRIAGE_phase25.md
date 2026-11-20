# Triage — Phase 25

## Already decided (carried)
- R110: unit default by Codex comparison; nameplate castbar kept; clock = status strip only (minimap clock hidden); Aurora limits accepted; restore-scope risk accepted.

## Step 44 audit (B af00496cd38816ba0) — master check
| ID | Master check (source quote) | Verdict | What / why |
|---|---|---|---|
| C1 | install.json:4 "0.1.2"; build.py:298-300 version check — confirmed | defect (Step 40) | branch cannot rebuild its own package; decide source layout (upstream copies in Collection/AddOns vs upstream extract) then fix install.json/manifest/genregistry |
| M1 | Defaults/SexyMap.lua:144-151 — confirmed | defect (Step 40) | appearance via Defaults overwrites layout of existing SexyMap users; move to preset fragment (nil-SV only) |
| M2 | pitbull4/manifest.json:237-238 "unmodified" — confirmed | defect (Step 40) | record patches (patch files + manifest "modified"); else normal build drops them |
| M3 | — | decision needed (user) | Prat dropped for native chat by Codex (Codex trace cites R112/R145 — Codex-local R numbers, not on branch); plan Phase 4 says Prat |
| M4 | — | test update (Step 40) | contract holds; fixture must exclude Presets/ |
| M5 | — | client check (Codex) | load-time scale constants |
| m2 | Defaults/SexyMap.lua:70 "never" — confirmed | accepted | = R110 ③ |
| perf ×4 | TinyThreat 90-92/912-915 — confirmed | low priority | upstream behaviour; small cost; patching as-is addons only if user wants |
| candidates ×4 | receipt + TOC 16001 present (FarmerNodes/WhatsTraining multi-interface) | optional only | not for default set (R101); game untested |

## Addendum — Codex commit 477eb06 (R116) — master measured on a clean worktree
| Item | Measured | Status |
|---|---|---|
| Codex handover `Review/0.1.4/HANDOVER.md` (60 lines) | read in full | received |
| package.py verify-source | PASS 2,558 files + 4 candidate ZIPs | Codex claim confirmed |
| Review/0.1.4/tests/run.py | 8/8 suites, 195 cases; 5 build-generator cases excluded by name (genregistry ×4, pitbull4 patch) | confirmed; exclusions = C1 not fixed, only bypassed |
| package.py build + verify_archives | 3 variants + probe built; one-session 38 folders, unresolved 0, Lua 1,477 files 0 fail | rebuild works via Codex's new tool |
| our genregistry.py --check / build.py --install | still ERROR (Details not in manifest / not in install.json) | C1 remains for the project's own pipeline; Registry.lua is hand-maintained in practice |
| Prat decision record `evidence/chat-decision.md` | cites R112 → requirement-trace (summary only) | user's original wording still not in repo; our ledger phase25 on branch still 7 lines (C2 open) |
| install.json | 0.1.4, Prat removed, own = 9 folders | M3 list mismatch fixed |
| Collection/AddOns changes in 477eb06 | none | M1 SexyMap overwrite still present; M2 ExperienceForever/SexyMap still "unmodified" in package manifest |

## Step 45 review 2 — order for Step 40 (user R117: runtime burden over disk size)
1 PitBull4 aura signature/native reset (M1) · 2 PitBull4 text pattern cache + GUID loop (M4) · 3 PitBull4 bars batch per frame + SetTexture early return (M3) · 4 PitBull4 aura normalize closures (M2) · 5 PitBull4 AltManaBar unit filter (M5) · 6 Core DBTable/Edit:Get allocations + nameplate style cache (M6) · 7 PitBull4 CastBar ticker only while casting, Hekili frameBudget decision (m6, m8) · 8 appearance/Dominos apply batching, leftover handlers, Castbars retry loop (m1, m2, m4) · 9 snapshot size (M8, login read/write) · last: texture disk size (M7) — loaded memory already small.

## Step 40b review 1 (B a525ab0d3116b83c0) — master triage
Root cause of C1/M1: party ownership is written into profiles of different scope (Grid2 per character "$char", PitBull4/FUF shared "Default"), each only when *its own* profile is new → mixed states (none or double party frames) on existing installs. Fix the cause, not each symptom:
- Rule (decided by master): automatic switch to Grid2 party happens only when BOTH the character's Grid2 profile and the unit-frame profile it uses are new (fresh install path). Otherwise neither is changed automatically (existing installs keep their current party owner, consistent). Moving an existing install to Grid2 party = an explicit user command (Core contract "after a user command"), e.g. `/dfp party grid2` (and `/dfp party unitframes` back), which writes both sides for the current character/profile and reports what changed, out of combat only. Install notes get one line for upgraders.
- M2: fragment must never replace a non-table (string "global" choice) profile value, and must never create a partial `core` table — write appearance keys only into an existing profile table by merging, or after SexyMap created the profile; requested mode included.
- M3: freshness/record per character profile key, and state "already"/"kept" for a character without appearance gives one notice line with the `/dfp preset` hint.
- Fix together: m1 (Registry savedVariables = {}), m4 (firststart test premise with CoreDB applied record), install notes lines 9/52 and package notes /dfcheck mentions (A2 DQ 7). Keep: m2 (log only), m3 (vocabulary ok; 40d decides), m5.
- Fix 1 (A2): Core Party.lua decides once per session; both new → Grid2 party; one side new → follows the existing side (A2 DQ10, master accepts: avoids alts without party frames after `/dfp party grid2`); neither → nothing. `/dfp party [grid2|unitframes]`. SexyMap fragment per profileKey, merge-only at PLAYER_ENTERING_WORLD. Next: same B re-check.
- Re-check 1: middle+critical 4 → 2 (not oscillating). Root cause still the scope mismatch, now in time (deferred FUF write) and across characters (command). Master decision for fix 2: record the party owner as intent on the shared unit-frame profile (CoreDB, keyed by unit addon + profile name), set by the fresh-install decision or by `/dfp party`; every login reconciles both sides for the current character from that record (Grid2 party keys for this character's profile; FUF command if FUF side not yet applied) — the record is the user's/first-install consent, so following it is not an unrequested overwrite. Grid2 is written only together with (or after) the unit side, never ahead of it. m: Grid2 defaultProfileName → resolve the profile Grid2 actually uses; FUF Set must not print success when FUF not ready (report "not applied"); CRLF of package notes keep as original bytes.
- Re-check 2: middle+critical 2 → 1. Fix 3 decision: reconcile only the ownership, not exact values — act only when the state contradicts the record (owner grid2 but Grid2 does not show party, or the unit-frame main party group/FUF party shows; owner unitframes the reverse). When Grid2 must show party and its layout is "None", set "By Group"; never replace another non-None layout or a FrameDisplay that already shows party. PitBull4: only the main party group decides ownership; partytarget/partypet stay as the user set them after the first switch. m1 `/dfp party` cancels any pending automatic FUF step; m2 one chat line per session while FUF stays pending; m4 add the global GetAddOnEnableState fallback; m3 accept (log).
- Re-check 3: middle 1 → 1 (count did not drop; new item in the same family) → root-cause switch: every automatic write by Party (any side, any session) prints one chat line naming what changed, why (record), and the command to change it; install notes (4) tell new installs as well as upgraders: Grid2 draws party, to use unit-frame party run `/dfp party unitframes`, changing it inside the addon windows is reverted at next login. m1: command output names every changed Grid2 value (window included). After this, B re-check 4; if a middle remains, stop iterating and carry it to the final report.

## Step 40c review 1 (same B) — master triage
| ID | Master check | Verdict | What / why |
|---|---|---|---|
| C1 | Forever.lua:281-283, 354-356 confirmed | fix | bump the aura settings version in every user-setting path: wrap the refresh entry points the option setters call (PitBull4.Options.UpdateFrames, PitBull4_Aura:UpdateAll when called outside the combat/timer path) or compare a cheap settings stamp; test through a real option set function, not a hand-fired callback |
| M1 | Theme.lua:209-211 confirmed | fix (root) | every change of the active theme goes through one function that bumps Theme.version and fires listeners (login restore included) |
| M2 | — | fix, option (a) | after Grid2's first-start template is applied to a fresh profile, re-apply our Grid2 preset fragment keys to that profile once (and record it); existing profiles untouched |
| m2 | — | fix together | preset position entries for PitBull4 units write only into unit entries that already exist |
| m1, m3 | — | keep (log) | |
- 40c re-check 1: C+M 3 → 1. Fix 2: re-apply only after the call that actually applied a template (wrap and use the return value / template-applied marker in the Grid2 profile), test with a stub that reproduces the dialog-first sequence. DQ11 keep (log).

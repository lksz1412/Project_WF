# Review triage — Phase 6-rev
## Check 1 — PitBull4 port + defaults (B 1 pass: critical 0 · major 1 · minor 4)
Master confirmed AceDB-3.0.lua:172–174 (logout strips default-equal values) and Core Defaults.lua:49 (wrong assumption "raw keys are the user's").

| ID | Verdict | Fix · why |
|---|---|---|
| M1 | confirmed major · Core root fix (Phase 2-rev) | AceDB targets: a raw nil in an EXISTING profile may be a user choice equal to the addon default (AceDB strips it at logout). So for AceDB targets Core writes only into a profile that did not exist before Core first looked (fresh SV, or a profile key/name not present yet = new character/new profile); an existing profile is left untouched (state "existing-profile-kept", nothing recorded as applied for it... record so it is not retried). Update Defaults.lua header (line 49 claim), API docs, every AceDB test that seeded default-equal raw values (run.py:959–976 and Dominos/Prat/Hekili existing-profile cases) to model AceDB's real stripping. Affects Dominos, Prat (scrollback), Hekili (barGlow), PitBull4. Why: never override user choices. |
| minor 1 | include | CastBar per-layout enabled=false for the four Devil layouts. |
| minor 3 | include | mark the "Normal"/default layout exists=true in defaults (OnNewProfile does not run when Core created the profile). |
| minor 2, 4 | not fixed | LibDualSpec dead refs in other-flavour TOCs; Core-only install stacks frames until Codex fragment → final report. |
Re-verification: same B rechecks Core change + PitBull4 defaults.

## Recheck 1 (same B · major 1 new · minor 1) — M1, minor 1, minor 3 resolved
| ID | Verdict | Fix · why |
|---|---|---|
| N1 | confirmed major | First look must not depend on the player key: at the first look record (a) whether the SV was nil and (b) a snapshot of the SV's profileKeys keys and profile names (namespaces included) — no key needed. When the key becomes available later, "existing" = SV was not nil AND (snapshot profileKeys contains the char key OR snapshot profiles contain the resolved profile). Tests: key unavailable at ADDON_LOADED, addon's AceDB:New runs, key available at PLAYER_LOGIN → fresh install still gets defaults; existing install with key late → kept. Update Defaults.lua header assumptions. Why: silent total loss on such clients. |
| outside-map minor | not fixed | applied record checked before newness (user resets by deleting only the addon SV keeps stock) → final report. |

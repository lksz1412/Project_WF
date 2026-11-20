# Step 41-rev — Grid2 name text, installer catalog, spare decks (Phase 25-rev) — R126·R127

Recorded: 2026-11-20 20:48:16 +0900

## Done
- Grid2 name text 12/14/18 via Grid2Frame fontSize and the template's name indicator after first-start (Classic text-down / Modern text-center / Blizzard text-name), once per fresh profile.
- Collection/Installer/ReleaseCatalog.json generated from the 0.1.5 ZIPs by catalog.py (--write/--check); exactly the two rows the engine accepts; Contract.md lines 12-13 → 0.1.5 (master).
- Release ZIPs exclude 36 spare _deck.tga where _deck_reviewed.tga exists; Composition.lua never requests an unshipped file (failure → individual shell).
- New ZIPs: DevilForever-0.1.5.zip sha256 174149f811375190788f515ee7ff1b1c9ea11cecd83124da04edb0c9be9da40e (81,398,885 B); DevilForever-0.1.5-fuf.zip f563aaba6e80105dd54c76a260560db060ce2911b1c963e47bb1c3a885d515de (82,055,349 B).

## Basis
A2-2 work_log iter_4 "Step 41-rev"; B audit iter_4/audit_log-40d.md (41-rev section).

## Gates
genregistry rc0, patches verify, core 108/108 and all suites (firststart 24, composition 6, catalog 4, …), verify_archives 0.1.5 rc0, build twice identical, catalog --check rc0. C# tamper refusal unverified (no dotnet).

## Next
R128: two separate releases (v0.1.5 PitBull4, v0.1.5-fuf) — via Codex.

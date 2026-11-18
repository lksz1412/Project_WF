# Step 38 — Integration fixes (Phase 23)

Recorded: 2026-11-18 21:02:25 +0900

## Done
F1 install ZIP mode (build.py --install [--variant pitbull4|fuf], Collection/install.json, DevilForever-install/{manifest.json, SHA256SUMS.txt, 설치안내.md}); F2 dropped Phases out of the registry (73 → 34 entries; Aurora kept pending; Details_Streamer removed; how_to_use reasons rewritten); F3 own folders + PitBull4 fork in manifest (PitBull4 package/modify/phases 6/variant 6-rev; Core phases 2,20,22); F4 Dominos_Cast out of phase3/15/20 briefs; F5 install notes (backup → move every addon aside → unzip → put back only non-duplicates; never unzip over existing folders; auto-update off; PowerShell hash check); F6 appearance-16 one-colour wording. Review fixes: phase20 folder count, build guards (--name, shipped-but-unregistered), Quartz reason, version strings, API.lua variant doc line. ZIPs: verification f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef, install 997379ea49a69a296a154d219ed7e3b726282565df62e2dec0dc0a929502139a (FUF variant buildable on demand, 4f54abc0…). Plan structure map updated (install.json, install/, install ZIP).

## Basis
integration-37.md §9 + DECISIONS_37.md; A2 work_log (Step 38 + fix 1) for read ranges and impact maps; master triangulated B quotes (phase20.md:18, 설치안내.md:8,:16) and re-ran all suites.

## Impact map (summary — full rows in work_log and TRIAGE_phase23.md)
| Place | Verdict |
|---|---|
| tools build/extract/genregistry, install.json, manifest, registry, tests | fixed |
| briefs phase3/15/20/appearance-16 + 31 hashes | fixed |
| API.lua header | fixed |
| records | no change |

## Gates
All suites pass (core 108); luacheck 206/0; genregistry --check; tocdeps both variants 0 unresolved; ZIPs reproducible; sha256sum -c OK both variants; manifest = ZIP folders; old hashes 0; /run ≤255; banned words 0. B 0/2/6 → 0/0/2.

## Next
Phase 24 Codex mockup brief.

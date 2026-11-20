# Audit log — Step 40d review 1 — B (bada-a3-reviewer) — diff 8b7aa012..3006d7aa

Counts: 중대 0 · 중간 0 · 경미 3
- m1 install notes upgrade list (설치안내.md:19-22) misses DevilForever_PerfProbe from the 0.1.4 FrameTimeProbe ZIP (Review/0.1.4/perf-probe-zip.json); otherwise only Prat-3.0 disappeared across 0.1.0–0.1.4 install.json.
- m2 patches.py reapply copies the new upstream with symlinks=True (:300-302) and does not reject links before `patch` (verify rejects via tree_files :110-116).
- m3 build needs GNU diff/patch (:140, :183) and an extracted Collection/upstream; notes do not state these prerequisites.
Verified OK: patch verify (5 patches, 22 unmodified), patch tests 4/4 incl. conflict, genregistry --check, exclusion rule (no cross-folder loads), determinism, TinyThreat/ExperienceForever/ProfileManager patches and probes (thirdparty 8/8), PitBull4 LICENSE, versions; DQ1/DQ2 acceptable.

# Step 40d — Third-party patch structure, single build path, 0.1.5 (Phase 25) — R117·R122⑨·R124

Recorded: 2026-11-20 10:51:09 +0900

## Done
- manifest third_party section (22 unmodified, 5 patched: PitBull4, Details/TinyThreat, Experience_Forever, ProfileManager, SexyMap); tool Collection/tools/patches.py (verify / regenerate / reapply for version-ups).
- genregistry --check and build.py restored; build.py = only release build, excludes code files no TOC loads (70 files PitBull4 ZIP, 62 FUF), keeps textures and licence docs; deterministic.
- Third-party runtime patches (probe stubbed, upstream→shipped): TinyThreat hidden-window threat reads 1200→0; ExperienceForever idle 30 s SetText 270→0, bar writes 180→0; ProfileManager rescans 41→1 per login burst.
- Version 0.1.5; ZIPs built (untracked, gitignored, >100 MB): DevilForever-0.1.5.zip sha256 dc7bcf454e6674aac2f3c7f95afd41baea9e9aac731d49576087e34a5312bdf7, -fuf.zip 39b590f0b48822c1977983680603c47ad7b8930b70bbf656c29559a0c8af0e62; catalog values via Collection/tools/catalog.py (work_log).
- Install notes: 0.1.5 section + upgrade section.

## Basis
brief-40d.md; A2-2 work_log iter_4/work_log-a2.md; B audit iter_4/audit_log-40d.md (0·0·3).

## Gates
genregistry --check rc0; core 108/108; pitbull4 6/6; firststart 24/24; fufdefaults 22/22; pitbull4runtime 19/19; chatsetup 28/28; castbars 16/16; statusstrip 20/20; thirdparty 8/8; patches 4/4; Codex runner 8/8; luacheck 324 files 0 fail; build twice identical; verify_archives 0.1.5 pass.

## Next
Step 41 freeze: Phase 25 Result, handover update, push main; release upload of the two ZIPs needs user approval.

# Brief — Phase 27 Step 56 pre-run (same work sub A)

Base commit `3facebd5` (Collection unchanged since `c34716a3`). The in-game check (Step 53) is blocked until the user wakes up, so releases wait. Do the parts that need no game and no publishing.

## Deliverables

1. **Candidate ZIPs** in a NEW folder `D:/Projects/Project_WF/_local_only/claude-p27-release-<8 hex>/`:
   - `python Collection/tools/build.py --variant pitbull4 --out-dir <folder>/run1` and again into `<folder>/run2`; same for `--variant fuf`. (Keep your os.devnull scratch wrapper; tools unchanged.) The two runs of each variant must give the same SHA-256 and byte count; record names, bytes, SHA-256.
2. **Catalog**: update `Collection/Installer/ReleaseCatalog.json` with `python Collection/tools/catalog.py <pitbull4 zip> <fuf zip>` (read catalog.py for the exact usage), then `python Collection/tools/catalog.py <pitbull4 zip> <fuf zip> --check` must say it matches. This file change is the only repo file you change in this step. Run `Collection/tests/catalog/` if it exists.
3. **Installer**: .NET SDK 10.0.404 is installed per user at `C:\Users\lksz1\.dotnet` (the machine-wide `C:\Program Files\dotnet` has no SDK). Run `Collection/Installer/Publish-Installer.ps1 -PackageDirectory <folder with the two run1 ZIPs> -OutputDirectory <folder>/installer -IncludeFuf` with `$env:DOTNET_ROOT` and `PATH` pointing to the user SDK first (in that process only). Read the script fully first. NuGet restore needs network — allowed (nuget.org only). Record the EXE path, size, sha256 and the version it reports.
4. **Installer test**: read `Collection/tests/installer/run.py` fully, then run it as it expects (built EXE, the two approved ZIPs, a comparison ZIP and a tampered copy — make the comparison/tampered files in `<folder>/test-inputs/` the way run.py or its docs describe; never modify the run1 ZIPs), a NEW test folder under `<folder>/`, `--version 0.1.5`. Gate: approved ZIPs accepted, comparison and tampered ZIPs rejected, no writes outside the test folder (as the test checks). It must never point at the real game folder.
5. Work log `Claude/results/handoffs/phase27/iter_1/work_log-56.md` (same form as before; impact map for the catalog change — who reads ReleaseCatalog.json: installer build, catalog tests, release checks).

## Rules

Same as earlier briefs: no commit, no deletes, no popups, no writes into the game folder, no GitHub release or tag, nothing outside the new `_local_only/claude-p27-release-<hex>/` folder except `ReleaseCatalog.json` and your work log.

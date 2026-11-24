# Audit log — Step 52 re-check after fix round 1 (same review B), returned 2026-11-24 20:57 +0900

Saved by master from the reviewer's return text (verdict part verbatim, evidence condensed to its line references).

중대·중간 없음 (중대 0 · 중간 0 · 경미 2)

- M1 fixed: `phase27-game-check.md:33` `print(select(2,GetPhysicalScreenSize())-f:GetBottom()*f:GetEffectiveScale()/PixelUtil.GetPixelToUIUnitFactor())`; computed 304.0 · 452.0 · 762.0 and V2 347.0 · 541.0 · 904.0 (Grid2/GridLayout.lua:882, Presets/{fhd,qhd,uhd}.lua:730, V2.lua:15–17, :154); `/run` line 141 bytes. Grid2 PosY is `Presets/fhd.lua:730`; the earlier `:272` was the reviewer's own line-number slip.
- M2 fixed: flag `install_local.ps1:10`, `:174` false, `:186` true just before the first real mirror; catch `:208–216` prints "partly changed", backup path, `Get-RestoreText $backup`, exit 1; every failure after the first write reaches it (:178–179 later folders, :187, :196, :205); failures before the write do not print it; `-Help` (`:38–39`) uses the same text; same as check list :13.
- M3 fixed: `:4` rule + `:38`, `:51`, `:70` point to the WTF backup restore; old "/dfp preset <원래 이름> → /dfp go 로 되돌린다" wording gone.

경미
1. `phase27-game-check.md:4` lists `/dfp preset`·`/dfp go`·`/pb4`·`/q3`·Grid2 settings, but not `/dfp party on` (:57), `/dfp theme` (:88), `/grid2 minimapicon show` (:77), `Edit:Set` (:93); the restore sentence covers them anyway.
2. `install_local.ps1:205` — if only the installation.json write fails, :211 still says "partly changed"; errs on the safe side.

Read: install_local.ps1 1–217 · phase27-game-check.md 1–96 · TRIAGE_phase27.md 21–41 · work_log-52.md 99–134 · V2.lua 8–20, 140–156 · Presets/{fhd,qhd,uhd}.lua :730 · Grid2/GridLayout.lua 903–913, :1005. Nothing run except python arithmetic.

# Review findings triage — Phase 27

## Already decided (carried into every later brief)

- Theme switcher art is made by Claude with code (Allura glyphs + gold gradient, outline, shadow), not by Codex (R152–R154).
- Arrow fallback blanks the four attached texture objects with `SetTexture(nil)` instead of `ClearNormalTexture` — the client's accepted call is not confirmed offline (work A decision, Step 51).
- Two animation groups (image, text) keep the existing test contract `text.animation` (work A decision, Step 51).
- `patches.py` / `build.py` are run on this PC through a scratch wrapper that sets `os.devnull = "/dev/null"`; the tools are not changed in Phase 27 (pre-existing Windows issue at `Collection/tools/patches.py:140`, outside scope).

## Step 51 review (2026-11-24 20:39, audit_log-51.md)

Result: 중대 0 · 중간 0 · 경미 4. Master checked the quoted lines `ThemeSwitcher.lua:159–161` (BLEND highlight) and `:228–231` (login in combat) against the file: quotes match. No fix round; the unit ends.

| # | Grade (confirmed) | Finding | Decision |
|---|---|---|---|
| 1 | minor | Pushed image is mostly covered by the hover image while pressing (brief §1 + §2-1 combination) | List for final report; Step 53 screen check looks at it |
| 2 | minor | Login-in-combat dim is not visible because the panel shows only after combat | List; spec line kept |
| 3 | minor | Outline touches the top/bottom edge of the name draw area; prev/next shadow not mirrored | List |
| 4 | minor | work_log says Skin.lua full read; reviewer checked grep lines only | Record only |

## Step 52 review (2026-11-24 20:52, audit_log-52.md)

Result: 중대 0 · 중간 3 · 경미 5. Master checked each quote against the files:
- M1 confirmed: `phase27-game-check.md:33` formula uses `f:GetBottom()` (distance from the screen bottom); `Presets/fhd.lua:272` `["anchor"]="BOTTOMRIGHT"…["PosY"]=776`; `Grid2/GridLayout.lua:882` `local y = (a:find("BOTTOM") and f:GetBottom()*s)`; the expected 304/452/762 and 347/541/904 are measured from the screen top (1080−776 = 304).
- M2 confirmed: `install_local.ps1:178` mirror per folder, `:187` post-copy compare, `:199–201` catch prints one ERROR line only — a failure after the first mirror leaves a half-installed game without saying so or printing the restore commands.
- M3 confirmed: `Presets.lua:304–306` clears edit values on preset restore and `:323–327` rewrites addon values after `/dfp go`, so the check list's "go back to the original preset" (`phase27-game-check.md:4`, `:38`, `:70`) overwrites user settings.

Impact map (master):

| Place | Effect | Reason |
|---|---|---|
| `phase27-game-check.md:33` measure formula | fix | M1 — measure from the screen top (screen height − bottom) so it matches 304/452/762 · 347/541/904 |
| `phase27-game-check.md:38` and any other line that compares a "물리 px" y value | fix (check all) | same basis as :33 |
| `install_local.ps1:165–201` (mirror loop, post-copy compare, catch) | fix | M2 — once a game write has started, a failure must print that the game folder is partly changed, the backup path and the exact restore commands, and exit 1 |
| `install_local.ps1:29–32` help restore text, `phase27-game-check.md:13` restore lines | check only | must stay equal to the new failure message |
| `phase27-game-check.md:4`, `:38`, `:70` (and any other "되돌린다" after `/dfp preset`/`/dfp go`/`/pb4`/`/q3`/Grid2 option changes) | fix | M3 — say these steps rewrite settings in WTF; the way back is: close the game and copy the §0 WTF backup back (the install does not touch WTF, so this returns every setting to the state before the check) |
| `phase26-step47-check.md` | no effect (record) | older brief, numbers are right; it has no formula |

Minor 1–5: list for the final report, not fixed.

Already decided: the release folder set (incl. Hekili) is installed unchanged — R153 excludes Hekili work, not the Hekili folders (work A DQ2, reviewer agrees).

### Step 52 re-check (2026-11-24 20:57, audit_log-52-recheck.md)

중대 0 · 중간 0 · 경미 2 (list). M1–M3 closed. Record note: the Grid2 PosY line is `Presets/fhd.lua:730`; the ":272" above came from the reviewer's numbering slip (this triage section is a record and stays as written).
Fix round decisions (work A): measure from the screen top `h − GetBottom()·scale / PixelUtil.GetPixelToUIUnitFactor()`; restore text built by one function `Get-RestoreText` for help and failure output.

## Step 58 — user check R158 (diagnosis iter_2/diag-58.md)

Master checked: ThemeSwitcher.lua:81–82 SetText before SetFont (:197) + BugGrabber "Font not set" → confirmed. SexyMap.lua:211 stack in BugGrabber → confirmed. V2.lua:100–112 focus x = xPlayer+w+timerGap → confirmed not centred.
Already decided (with reason): Grid2 above the quest tracker (R158 latest user words supersede R148) · square cells 44/58/88 · V2 folded into base presets, names kept (Composition/switcher/Party depend on names) · focus centred, symmetric gaps · one aura table for player/target/focus, focus own layout (pets unchanged — user) · target-pet chain added · HUD art fixed in code first, bar surrounds above Onyx · switcher SetText moved into apply() · SexyMap error fixed in our file.

## Step 58 review 1 (B, a2531127) — 중대 0 · 중간 1 · 경미 5
- M1 check list x formula mixes UIParent units and Grid2 frame units (`phase27-game-check.md:33`, `GridLayout.lua:880` rule) → master: confirmed by the quoted lines; fix together with round 2.
- Minor 1–5 → list for the final report (comments in fhd/V2.lua, "/dfp go" hint before auto reload, count==0 placement, FUF Quartz V2 copy unverified).

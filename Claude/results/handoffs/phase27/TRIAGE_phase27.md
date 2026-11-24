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

# Triage — Phase 26

## Already decided
- R131 images by Codex, Claude plans; R130 ⑥ background unchanged, gold script; R117 no runtime burden; R132 font candidates (OFL 1.1, master-verified).

## Step 46 review 1 — master triage
| ID | Verdict | What / why |
|---|---|---|
| M1 | fix | edited strip font/height differing from the preset slot → text fallback (same rule as Composition's edit fallback) |
| M2 | fix | name the method: SetHighlightTexture(path, "BLEND") with a complete image, or swap the normal texture on enter/leave — pick one, state it |
| M3 | fix | list the R132 candidates (default Great Vibes unless the user picks), ship OFL.txt beside the images in Media/ThemeSwitcher/, do not ship the TTF, Claude updates manifest license_files in its later check |
| m1–m6 | fix together | Disable()/Enable() rule (default: disabled only when ≤1 theme; combat keeps refusal+tooltip — user question open), arrow fallback per preset, hide the FontString while an image shows, SetTexture()==false → text fallback, give the texcoord numbers, animate image and text together |
- Re-check 1: middle 3 → 1. Fix 2: ship the licence as `Media/ThemeSwitcher/LICENSE-OFL.txt` (matches extract.py LICENSE_RE, so the regenerated manifest lists it; no hand edit); create texture objects first, judge SetTexture, then attach to buttons; on fallback clear button textures and re-show the arrow FontStrings; disabled check = test harness or temporarily registering one theme (state which).

## Step 48 review (1) — own + modified addons · master triage (review only, R133: no fixes)
Source: `iter_2/audit_log-48-1.md` (audit B1). Quotes checked against the worktree @d8b63f59: V2.lua:121-122, fhd.lua:588, Party.lua:193-195, Party.lua:397-398, fhd.lua:469 — all match.
| ID | Verdict | What / why |
|---|---|---|
| M1 | confirmed · report | V2 writes only dfAuraGeometry {above,width}; V1 avoid keys (size_ratio .7) stay → V2 player/target auras shrink when pet/focus shown |
| M2 | confirmed · report | Party.lua:193-198 re-applies "hidden" party sub-groups every login → user's own change silently reverted |
| M3 | confirmed · report → Step 47 | R130 needs PitBull4 party + Grid2 together; code has a single owner and new install records grid2; PitBull4 party show_when raid=false |
| m1–m6 | list → final report | Quartz Pet bar not moved in V2 · no resolution check for layout-only preset · alignPixel group signature · dfOffset/dfHeight nil arithmetic · Party:Set notice counts all groups · Skin_Dominos tail re-apply after combat |

## Step 48 review (2) — unmodified bundled originals · master triage (review only)
Source: `iter_2/audit_log-48-2.md` (audit B2). Quotes checked @d8b63f59: Hekili Events.lua:2178-2186, Dominos.lua:295-298, Hekili BarGlow.lua:118-121, Events.lua:2376-2379, Player.lua:216-219 — all match.
| ID | Verdict | What / why |
|---|---|---|
| C1 | confirmed · report | Hekili ReadKeybindings loops DominosFrame1..14 without nil check; Dominos makes 8 → Lua error on every bind/spell event; keybind text and pet target detection lost |
| M1 | confirmed path, size unmeasured · report → Hekili discussion | Hekili takes UNIT_COMBAT/UNIT_AURA for every unit; per-event front cost in raid even when idle (healer spec) |
| m1–m13 | list → final report | see audit log (debounce nil handle, double glow, ALT-SHIFT override binds, Grid2 secret GUID redraw, Grid2 template popup per new char, Grid2LDB minimap button, etc.) |

## Step 48 review (3) — Quartz swing (hunter / melee) · master triage (review only)
Source: `iter_2/audit_log-48-3.md` (audit B3). Quotes checked @d8b63f59: SwingForever.lua:53-60, 81-82, 115-119, 128; Hekili Sources/Swing.lua:1-8 — all match.
| ID | Verdict | What / why |
|---|---|---|
| M1 | confirmed · report | off-hand swing ignored (single bar) → dual-wield sees main hand only |
| M2 | confirmed code, game effect unverified · report | only PLAYER_SWING; no haste/parry/Slam recalculation inside a cycle |
| M3 | confirmed · report | no hunter stand-still window; bar hides at 0 if shot is delayed by moving |
| m1–m7 | list → final report | load premise (only SwingForever loads) unverified · Enum.PlayerSwingType unverified · V1 scale drift on UI scale change · enabled for all classes · shared melee/ranged bar · no unlock preview · possible overlap with built-in swing timer |

## Step 46-rev (R134·R135) — brief font default Allura + combat arrow dim · re-check (same B)
- Re-check: 0 critical · 0 middle · 2 minor. Both minors fixed by master as one-line text edits (word-level): ratio stated per preset (1.4/1.5/1.6); PLAYER_LOGIN in combat starts at alpha 0.45.

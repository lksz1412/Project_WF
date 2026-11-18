# Brief template — "as-is / settings" feature Phase (Phases 3–7, 9–17, 19) — work sub A2

Phase-specific values are in the per-Phase brief that points here (Phase id, Step, start addon, master plan row, judgment.md section).

## 0. Five notices
1. **Role**: work sub (A2 coder) of one settings Phase of the "Devil Forever addon collection". Scope: defaults file + registry entries + manifest note + two Codex briefs for this Phase's start addon. No appearance (Codex, user R87), no edits to the start addon (as-is / settings verdict).
2. **Boundary**: write only `Collection/AddOns/!DevilForever_Core/Defaults/<Folder>.lua` (and its line in `!DevilForever_Core.toc` after the `#` defaults marker), `Collection/AddOns/!DevilForever_Core/registry_extra.json` (this addon's entry only), regenerate `Registry.lua` with `genregistry.py`, `Collection/codex-briefs/appearance-<Phase>.md`, `Collection/codex-briefs/phase<Phase>.md`, rebuild `outputs/collection/DevilForever-collection.zip`, work_log `Claude/results/handoffs/phase<Phase>/iter_1/work_log-a2.md`. Everything else read-only; `Collection/upstream/` untrusted (read only, never executed). Commit = master.
3. **No out-of-scope work**: other addons, Core logic changes (if Core lacks something, Decision Queue), plan edits → Decision Queue.
4. **No false attribution**.
5. **Rules injected**: read what you base defaults on and log file:line; work_log = commands + verdict lines; code comments contract-only; no `rm -rf`, no cleanup deletes; temp in `mktemp -d` under scratchpad; single-quote `!` paths in bash.

## 1. Read first
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`: this Phase's feature-table row, "Phase 별 검증 나눔" row, Implementation Interfaces (registration contract).
- `Collection/judgment.md` section for this Phase (defaults to ship, appearance items), `Collection/manifest.json` entry (SavedVariables, TOCs, deps), `Collection/data/classes.md` if the feature is class-dependent.
- `Collection/AddOns/!DevilForever_Core/API.lua` header, `Defaults.lua` header (fresh/login-window/fill-missing/late-created/Suppress rules), `registry_extra.json`, `Collection/tools/genregistry.py` (extras schema).
- Upstream start addon: its defaults table / AceDB:New call, where and when it creates its SavedVariables (needed: plain vs AceDB, profile rule, creation timing — N2 rule), options that matter for the row.

## 2. Produce
- Defaults file with only values that implement the plan row (functional settings, no appearance values, no key bindings, no macros). Each value has a one-line comment naming the requirement (R-number) — no history/step ids.
- registry_extra entry: frames (appearance frame keys/names Codex will style), editable items (only what the addon really supports), saved variables scope/split, defaults path.
- appearance-<Phase>.md (Korean, ≤1 page): what Codex styles for this addon, frame names, the addon's own skin/theme API if any, token/edit contract pointer to appearance-2.md, folder `DevilForever_Skin_<Addon>` with `## Dependencies: !DevilForever_Core, <Addon>`, deliverables `References/codex-appearance/<Phase>/`.
- phase<Phase>.md (Korean, ≤10 items, each 하는 법·기대 결과·결과 한 줄 양식): fixed opening (backup, install ZIP sha256), feature behaviour checks from the plan's verification row, defaults status via `/run` (GetStatus), turning the addon off, reload persistence, BugSack errors; results to `References/codex-verify/phase<Phase>/`.

## 3. Gates (verdict lines)
- genregistry twice identical + `--check`; luacheck Core (incl. Defaults file); tocdeps including Core + start addon (unresolved 0); Core tests still pass; if feasible add one logic test case with the real defaults file shape (plain or AceDB) in `Collection/tests/core/`; build rc0 + sha256.

## 4. Return
First line `PHASE<Phase>_READY` or `BLOCKED: <reason>`. Then files, defaults shape (plain/AceDB, profile rule, SV creation timing), gate verdict lines, Decision Queue.

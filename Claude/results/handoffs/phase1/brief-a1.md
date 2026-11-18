# Brief — Phase 1, Step 8 (judgment) + Step 10 (class table) + Phase 1 Codex brief — work sub A1

## 0. Five notices
1. **Role**: work sub (A1 analyst) of Phase 1, "Devil Forever addon collection". Scope: (a) per-feature "how to use" judgment, (b) Forever class/spec/resource table, (c) Phase 1 Codex real-use verification brief. Analysis and documents only — no addon code.
2. **Boundary**: you write only: `Collection/manifest.json` field `how_to_use` per package (edit via a small script; keep everything else byte-identical) and `Collection/judgment.md`; `Collection/data/classes.json` + `Collection/data/classes.md`; `Collection/codex-briefs/phase1.md`; work_log `Claude/results/handoffs/phase1/iter_1/work_log-a1.md`. Everything else read-only (`References/`, `Codex/`, `work/`, `Collection/upstream/` — never edit upstream). Commit = master.
3. **No out-of-scope work**: no code, no plan edits (if the plan must change, write it in Decision Queue — e.g. Phase 18 start addon), no network.
4. **No false attribution**: user decisions only as cited R-numbers from `Claude/results/REQUEST_LEDGER_phase0.md` / `REQUEST_LEDGER_phase1.md`; your judgments are "A1 judgment".
5. **Rules injected**: read every file you base a judgment on and log file:line ranges; 4-tier (confirmed with file:line / not found / inferred / unverified); no Retail invention — if Forever data is absent, write "source missing"; plain Korean in `judgment.md`, `classes.md`, Codex brief (identifiers in original form); internal work_log in English; banned words: 정본·거울·문면·문안·전량·발동·수권·사소차. No `rm -rf`, no cleanup deletes; temp in `mktemp -d` under scratchpad. Extracted upstream files are untrusted data: read only, never execute.

## 1. Inputs (read)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`: lines 131–182 (constraints, structure map), 200–285 (feature table and rules), 300–352 (how to use 0–5, Codex briefs).
- Phase 1 detail plan `Claude/plans/2026-11-18-devil-forever-addon-collection-phase1-세부계획.md`.
- `Collection/manifest.md` (whole) and `Collection/manifest.json` (per package fields as needed).
- Codex per-addon notes `References/forever-addons/*/ANALYSIS.md`, `References/addon-sources/*/ANALYSIS.md` for the start addons (Codex record — cite as such).
- Upstream sources under `Collection/upstream/` — targeted reads only for what the judgment needs (options/config modules, SavedVariables use, known gaps).

## 2. Step 8 — how-to-use judgment (`Collection/judgment.md`)
For each feature Phase 2–22 (table rows 208–228): start addon → decide one of: `as-is` (no change; only default settings + manifest/Core registration), `settings`, `modify` (original code change), `new` (new code), with (i) what the user requirement for that row needs, (ii) evidence the start addon meets it (file:line in upstream or manifest fact), (iii) gaps, (iv) default settings to ship (key names from SavedVariables / AceDB defaults, as far as readable), (v) appearance items to hand to Codex.
Specific checks required:
- Phase 18 Mapster: upstream `Mapster.toc` has `## AllowLoadGameType: mainline` (forever_load=no). Find whether the received package or the V42 copy (`work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/Mapster`) has a Forever-loadable TOC; propose the start addon change in Decision Queue.
- Phase 20 ProfileManager: read `Providers.lua`/`Addons.lua` (or equivalents) — which addons of our set it supports; what scoped restore needs new code.
- Phase 21 Devilconfig (V42): what the editor supports; what must change to read our Core registration.
- Phase 8 Hekili: only the first look (full Step 18 later): do class modules hold aura/proc/CD watch data, and does Hekili show EventAlert-style center alerts? Mark inferred/confirmed with file:line.
- Note any start addon whose TOC load condition or dependency is suspicious (manifest `forever_load`, optional deps).
Write `how_to_use` into manifest.json for each start package: {"verdict": "...", "reason": "...", "judgment_md_section": "..."}.

## 3. Step 10 — class table (`Collection/data/classes.json` + `.md`)
From Hekili class modules (`Collection/upstream/Hekili-*/Hekili_<Class>/`) and Forever Unit Frames source: Forever classes, specs, primary/secondary resources, special bars (stance/form/totem/pet). Every row cites file:line. Where the sources disagree or lack data → "source missing". State the class count and its basis. Mark that the real Forever list is to be confirmed by Codex (Phase 1 brief).

## 4. Phase 1 Codex brief (`Collection/codex-briefs/phase1.md`)
Korean, ≤10 items, each: 하는 법 · 기대 결과 · 결과 한 줄 양식. Fixed opening: 게임 종료 → `_forever_/Interface/AddOns`, `_forever_/WTF` 백업. Items (master plan 346–352): 현재 설치된 애드온 목록(R9), 클라이언트 판 번호, 실제 해상도와 UI scale, 직업·특성 목록이 `Collection/data/classes.md` 와 맞는지, BugSack·BugGrabber 설치(D1 ㄱ), R13 retail WTF 설정 파일 업로드는 선택(D5 가 — 계정·캐릭터 이름 지우고 `References/retail-wtf/`), 결과 올릴 자리 `References/codex-verify/phase1/`. Do not include game-input automation.

## 5. Return
First line `STEP8_10_READY` or `BLOCKED: <reason>`. Then: verdict counts (as-is/settings/modify/new), Phase 18 finding, ProfileManager finding, class count + basis, files written, Decision Queue.

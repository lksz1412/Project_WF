# A1 work log — Forever UI plan, iteration 1

## Ownership and boundaries

- Owned outputs: `Codex/plans/2026-11-17-devil-ui-forever-plan.md`, `Codex/docs/shaman-source-evidence.md`, this work log. New files only at initial authoring; no code, game/app input, installs, settings, account data, commits, deletion or extra agents.
- Current stage: planning only; implementation needs user feedback, plan update and explicit GO. Master owns request ledger, observations, commits and independent reviewer dispatch.
- Read-only inventory is historical. Master's later messages say user may remove old AddOns; completion not confirmed. User says Forever is a fresh environment without old macros; no old keybind/profile/macro migration is assumed.

## Read coverage

All line numbers below are inclusive. Initial combined tool output was truncated; covered files were re-read in smaller calls before use. A failed `references/core_principles.md` / `references/accessibility.md` lookup was corrected to the skill root; no missing file content was inferred.

| File (absolute skill root = `C:/Users/USER/.agents/skills/`) | Read range |
|---|---|
| `Codex/results/handoffs/forever-ui/brief.md` | 1–32, full |
| `Codex/docs/observed-environment.md` | 1–29, full |
| `Codex/docs/addon-reference-inventory.md` | 1–31, full |
| `Codex/results/REQUEST_LEDGER.md` | initial 1–22; latest R1–R10 revision 1–25, full |
| `Codex/docs/INDEX.md` | 1–10, full |
| `skill_LKS_original_plan-execution/SKILL.md` | 1–98, 99–291, full |
| `skill_LKS_original_source-research/SKILL.md` | 1–155, full; mode B |
| `skill_LKS_original_file-reading/references/policies/feedback_full_file_read_required.md` | 1–57, full |
| `skill_LKS_original_communication-decisions/references/policies/feedback_confirmed_items_policy.md` | 1–62, full |
| `skill_LKS_original_communication-decisions/references/policies/feedback_communication_style.md` | 1–39, 40–87, full |
| `skill_LKS_original_visual-design/SKILL.md` | 1–97, full |
| `skill_LKS_original_visual-design/core_principles.md` | 1–143, full |
| `skill_LKS_original_visual-design/accessibility.md` | 1–115, full; only principles for future UI layout, no mockup |
| `skill_LKS_original_review-chunking/SKILL.md` | 1–67, 68–138, full |
| `skill_LKS_original_review-chunking/references/policies/feedback_chunked_review.md` | 1–66, 67–80, 81–139, full |
| `skill_LKS_original_plan-execution/references/policies/feedback_planning_vs_execution.md` | 1–40, full |
| `skill_LKS_original_plan-execution/references/record-formats.md` | only designated format subsection 59–70, ‘늘 지킬 제약’; other master record formats not used |

The active AGENTS instruction text was supplied in the task context and read in full. No local instruction file or unrelated master logs were opened. Master supplied the confirmed banned-word/replacement list in a message; no independent lexicon changes were made.

## Unit A — Candidate declarations and firsthand reports

### Method and decisions

2026-11-17 research window: support/reviews 2026-09-01 through 2026-11-17; original appearance source 2022 only. Discovery in Korean/English followed by focused publisher and firsthand threads. No guide/roundup was classified as a review. Official declarations, public user experiences, local observations and own design judgments remain distinct.

- Dominos 12.0.4, SexyMap v12.1.7 and original Quartz 3.8.0 declare Forever; that does not test them in game. PitBull has no visible Forever flavor; no abandonment inference.
- Forever Unit Frames 0.65.0 is a candidate with explicit conditional selection, not an approved installation. It supplies a supported target for health/mana and totem evaluation before custom unit-frame code is proposed.
- Hekili Forever v0.8.5 declares Enhancement/Elemental and focus/proc+recommendation capabilities. Independent firsthand Shaman usage evidence is insufficient; Restoration recommendation support not established.
- Korean user's actual two-spec experience and English Shaman totem/healing reports were found. Contradictory Riptide visibility and Enhancement experiences remain visible. No class balance advice derived from them.
- Original reference exact geometry and archive contents were not analyzed. Future extraction gate owns them. The confirmed first screenshot is not an open question.

### Queries executed

Common explicit suffix: `after:2026-09-01 before:2026-11-18`.

1. `"포에버" "주술사" "헤키리"`; `"Forever" "shaman" "Hekili"`; `"WoW Forever" "shaman" UI totem restoration`.
2. `site:inven.co.kr "포에버" "주술사" "애드온"`; `site:inven.co.kr "포에버" "헤키리"`; `site:reddit.com "hekili" "forever" "shaman"`.
3. `"Hekili Forever" shaman review comment enhancement elemental`; `"포에버" "정술" "애드온"`; `"포에버" "복술" "토템"`.
4. `site:inven.co.kr/board/wow/6567/23257`; `site:inven.co.kr "포에버" "주술사" "토템" "저는"`; `site:reddit.com "Hekili Forever" "shaman"`; `site:reddit.com "Forever" "Elemental" "Hekili"`.
5. `"주술사 40넘으니까 재미 확없어짐"`; `"포에버" "토템" "애드온" "술사"`; `"포에버" "고술" "헤키리"`; `"Forever" "resto shaman" "UI" "I" site:reddit.com`.

Master subsequently instructed that existing evidence was sufficient and further searches should stop. Followed: remaining web opens only completed coverage of already chosen sources.

### Source reading coverage and access results

Web line ranges refer to the tool's extracted text, not original HTML line numbers. Source IDs S/U are defined with real URLs in the evidence file.

| Source | Coverage/result |
|---|---|
| S1 original Inven | extracted 0–222, 201–284, 172–512, full 0–512 combined; article 103–114 used; image pixels not inspected; comments not returned |
| S2 Dominos | 0–363 + 254–444, full 0–444 |
| S3 SexyMap | full 0–426 |
| S4 Quartz | full 0–428 |
| S5 PitBull | full 0–419 |
| S6 Forever Unit Frames | 0–499 + 415–531, full 0–531 |
| S7 Hekili original | 0–257 + 224–369, full 0–369 |
| S8 Hekili Forever | full 0–324 |
| S9 Hekili v0.8.5 | full 0–303 via followup open; Shaman release notes 228–232 |
| S10 EventAlert | full 0–407 |
| U1 Inven 23257 | direct desktop 502; mobile cache miss; query variants still inaccessible. Search cache exposes author/date/title and all six short body lines. No claim of full original/comment read |
| U2 Totem setup | 0–422 + 308–439, full 0–439 |
| U3 Healer thread | full 0–673 on single followup open; used GreatValueUser 330–337, response basis distinguished from other-class anecdotes |
| U4–U6 Riptide thread | 0–398 + 366–537 + 426–1126 + 780–1502, full 0–1502 combined. Native UI contradiction 95/102 and opposing Enhancement experiences 620/805 retained |
| Hekili Forever `/comments` | tool reported URL inaccessible; not treated as zero comments or zero users |
| Inven 23263 | desktop 502; mobile cache miss; not used as evidence |

Long search discovery results also included guides, publisher release history and controller beta material. These were not fully adopted as sources; no claims based only on their titles/snippets. Older Hekili v0.2/0.3/0.5/0.6 release snippets were not used to describe the current v0.8.5 runtime.

### Unit gate

Self-check: each selected evidence row has URL, period/date, source type, short exact quote, observation and limitation; U1 cache limitation visible; same-source Riptide quotations <=25 words total; no local account identifiers. Output: `Codex/docs/shaman-source-evidence.md`. Independent final-plan review is still pending.

## Unit B — 11-section plan

Initial authoring follows the confirmed layout and new-environment assumption. Detailed phase files are future paths, not existing artifacts. Master plan may recommend installations or later code but grants neither itself. Concrete gates distinguish installation selection from actual runtime acceptance.

### Mechanical execution output

Read-only preflight command: `git status --short; git rev-parse --show-toplevel; Test-Path` for the three owned paths; `Get-Date`.

Decisive output, 2026-11-17 19:22:43 +09:00:

```text
C:/Users/USER/Documents/Codex/2026-11-17/new-chat-2
Codex/plans/2026-11-17-devil-ui-forever-plan.md: False
Codex/docs/shaman-source-evidence.md: False
Codex/results/handoffs/forever-ui/iter_1/work_log.md: False
```

Master's ledger modification and session register were present; no edits made to either. No implementation tests exist or were run.

## Decision Queue

- PQ-FOREVER-1: user's intended Shaman spec and main content; no assumed answer.
- PQ-FOREVER-2: desired amount of effects/procs and recommendations; evaluate together, no lineage argument.
- Master review: candidate unit-frame selection conditions and custom fallback cost; exact fidelity cannot be guaranteed before original archive and runtime gates.
- Actual model/effort usage statistics are not exposed to this subagent; unobserved, not zero. Role configuration is A1 as assigned.

## Root transitions and final draft checkpoint — 2026-11-17

Master serialized two root transitions by interrupt/resume of this same A session. No compaction or context loss occurred. Existing reads/research remained available. Final canonical root is `D:/Projects/Project_WF`; no subsequent writes were made to either C: checkpoint. Current project rules prohibit planning-only commits, and push/merge need separate explicit user permission. No commit was made by A.

Recovery reads after the C: transition: PROJECT_LOCATION 1–22, INDEX 1–15, REQUEST_LEDGER 1–25, brief 1–32, observed-environment 1–29, addon inventory 1–31, own work_log 1–112 and evidence 1–42. Combined output truncation was corrected by separately reading addon inventory and own work_log fully. After the D: transition: `D:/Projects/AGENTS.md` full 1–80; PROJECT_LOCATION full 1–30; INDEX full 1–16; REQUEST_LEDGER full 1–28, then latest R1–R14 revision full 1–33. User AGENTS text remains in context. No project-local AGENTS was reported by master.

Additional specified policy reads: `feedback_change_impact_analysis.md` 1–65; `feedback_workspace_git_safety.md` 1–81 (tail recovered separately); `feedback_flow_interruption.md` 1–66 (front recovered separately); `skill_LKS_original_multi-session-orchestration/SKILL.md` 1–140 and 141–292; `references/policies/feedback_session_division.md` 1–56 and 57–102; `references/model_effort_sample.md` 1–157. All are full reads under the installed skill root recorded above.

### Change list and impact map before this append

Change: append recovery coverage, natural-unit decisions, actual output and pending macro update to this existing log. Preserve the old C: output as historical evidence, not a current path. New plan uses D: root. Do not edit master-owned records.

| Place | Type | Method | Impact | Reason |
|---|---|---|---|---|
| This work_log | historical record plus new checkpoint | full 1–112 read | append only | preserve prior facts, add new path/gates |
| New master plan | consumer of evidence and current instructions | full 1–150 + 151–303 read | confirm only | draft complete, no edit needed for log append |
| INDEX / PROJECT_LOCATION / REQUEST_LEDGER | same path/scope facts, source records | full reads plus mechanical search | confirm only | master owned, outside A writing scope |
| Earlier C: copies | checkpoint twin | master clone records, own prior reads | no edit | historical recovery copies, not live twins to update |
| Evidence | plan input | full 1–42 read | confirm only | web facts unchanged; no raw macro material |
| Input-producing code / callers / callees | code interfaces | no code implementation | none | this is a log append, not code |
| Locked tests / parser | machine consumers | specified files and mechanical script | none found | no existing persisted tests/automated log parser given |

Mechanical supplementary search: rg for old/new roots, work_log, macro/매크로 and R12–R14 across the five known related records and plan; matches reviewed in the already-read contexts. Historical records retain their original paths. No generated plan snapshot exists in A's scope.

### Natural-unit decisions and self-checks

- B1 scope/ground truth: user-confirmed first screenshot fixed; current addon inventory historical, native resolution/scale unconfirmed; new environment does not imply old macro/profile/keybind migration. Evidence distinctions retained. Explicit D: project and planning-only commit restriction included.
- B2 architecture/old projects: Dominos/Quartz original roles and SexyMap restored as conditional candidates; FUF selection gate makes health/mana provider concrete without pretending it works. Native safe state and bounded custom alternative remain explicit. Fifteen rows use observed versions, not assumed installed files; optional features excluded from core.
- B3 sequence/interfaces: original source/profile recovery precedes prototype, then actual game gates and rollback; one owner per scope, no automatic binds. Three chapters each have two phases, cumulative steps 1–12, future phase paths labelled uncreated.
- B4 Shaman: Elemental/Enhancement/Restoration kept separate, totems/mana/procs/casts/healing checks derive from identified reports with limitations. Hekili integrated alerts+recommendations evaluated together, independent Shaman runtime reviews insufficient. Riptide and Enhancement contradictory reports preserved.
- B5 validation/decisions: non-code structural P5 fixed five plus five brief-defined risks, ten independent rounds still pending. Future Lua runtime first then code-structural three rounds. All ten preflight categories and actual game backup/scale/reload/relogin/lockdown/resource/target/page/map/profile/error/rollback gates included. Final open preferences are spec/content and alert amount; candidate/custom cost remains conditional.
- B6 macro followup: latest user explicitly authorized byte-preserved originals, not compatibility rewriting. Draft records master-provided 9+8 counts as a prior report, not A's raw observation. Source/target/profiles not opened by A. No macro, keybind or game setting changed by A.

### Actual write and mechanical gate output

First D: write, despite approved escalation, failed because the cloned repo had no empty `Codex/plans` directory. Error: `Could not find a part of the path ... Codex/plans/...plan.md`. No existing file was overwritten. Corrected by creating the missing directory and new file, with ErrorActionPreference Stop and an explicit existing-plan guard. Second require_escalated command returned rc0:

```text
D:\Projects\Project_WF\Codex\plans\2026-11-17-devil-ui-forever-plan.md  29790
303
```

Full generated plan was then read 1–150 and 151–303. Mechanical validation (PowerShell regex/arrays against the actual file; not a runtime addon test):

```powershell
$heads=@($c | Where-Object {$_ -match '^## '})
$expected=@('## Summary','## Current Ground Truth','## Phase Range','## Non-goals','## Implementation Changes','## Phase N — 복원·구성·검증','## Implementation Interfaces','## Test Plan','## Assumptions','## Correction History','## Decisions Required')
if(($heads -join "`n") -ne ($expected -join "`n")){throw 'section order mismatch'}
$rows=[regex]::Matches($planText,'(?m)^\| [0-9]{1,2} \|').Count
if($rows -ne 15){throw 'addon row count mismatch'}
$stepMatches=[regex]::Matches($planText,'(?m)^     Step ([0-9]+) .+?([0-9]+)~([0-9]+)분')
if($stepMatches.Count -ne 12){throw 'step count mismatch'}
$minMinutes=0; $maxMinutes=0
foreach($m in $stepMatches){$minMinutes += [int]$m.Groups[2].Value; $maxMinutes += [int]$m.Groups[3].Value}
$q=0
foreach($m in [regex]::Matches($e,'(?m)^\| U[456] \|.+$')){foreach($s in [regex]::Matches($m.Value,'“([^”]+)”')){$q += [regex]::Matches($s.Groups[1].Value,'\S+').Count}}
if($q -gt 25){throw 'same-source quote limit exceeded'}
rg -n '정본|수권|사소차|문면|문안|전량|발동' $p 'Codex/docs/shaman-source-evidence.md'
```

Actual decisive result, 2026-11-17 19:41:27 +09:00, rc0:

```text
PASS sections=11 ordered; addon_rows=15; steps=12; estimate_minutes=630..1110; same_source_quote_words=23
PASS banned_confirmed_terms=0
```

No addon runtime/install or independent ten-round review was performed. No output snapshot or extra phase plan was generated by A. Global model/effort usage remains unobserved.

### Latest macro steering — helper held before spawn

Master first authorized one nested bada-a3-helper for mechanically exact macro backup/copy/hash checking. Before any spawn, new user input stated that three characters were logged in to collect information. Master explicitly withdrew the stale source-two-files/one-character assumption and instructed A to hold the macro dispatch until new input. Followed: no helper was spawned and no macro active write occurred. New three-character mapping/inventory is pending master confirmation. The draft's earlier 9+8/0-byte row is a timestamped master report, not a current uniqueness guarantee; update it with new authoritative evidence in the next increment. Master instructed that this should not block returning the saved UI draft for independent review.

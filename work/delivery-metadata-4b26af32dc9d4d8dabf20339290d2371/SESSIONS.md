# Sessions — planning

| Role | Definition | Runtime task identifier | Responsibility | State | Configuration | Runtime model/effort/usage/context/compaction |
|---|---|---|---|---|---|---|
| A | bada-a1-analyst | /root/ui_plan | Source-grounded Shaman UI plan draft; source evidence | returned, waiting for B | gpt-6.1-sol high, role TOML and supported role selection verified | unobserved |
| B | bada-b-auditor | /root/ui_review | Ten-perspective read-only plan audit | running | gpt-6.1-sol high, supported role selected | unobserved |
| mechanical helper | bada-a3-helper | /root/ui_plan/macro_archive | Byte-identical private macro library and lookup index | archive completed; top-level index created, final return pending | gpt-6.1-sol low, nested role reported by A | unobserved |

Only B is an active non-carve-out sub. The helper is a closed, disjoint mechanical carve-out. Master controls communications, source confirmation, privacy and triage; Computer Use ended. No new commits after the user-selected D: root entry, per project instructions. Future implementation needs its own phase entry and appropriate worker role.

2026-11-17 19:58:27 +09:00: B returned audit major0/moderate2/minor0; A resumed for accepted corrections, same identifier; B idle. Helper returned completed. No non-carve-out concurrency.

2026-11-17 20:05:10 +09:00: A returned accepted corrections and scoped gate output; B resumed for recheck; A idle. Same identifiers/roles; runtime telemetry unobserved.

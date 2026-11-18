#!/bin/bash
# usage: open_settings_phase.sh <phase> <step> <title> <work-desc> <est>
set -e
cd /home/user/Project_WF
P=$1; S=$2; T=$3; W=$4; E=$5
mkdir -p Claude/results/handoffs/phase$P
cat > Claude/plans/2026-11-18-devil-forever-addon-collection-phase$P-세부계획.md <<EOT
# Phase $P detail plan — $T

[Phase $P start — master plan re-read: feature-table row for Phase $P, verification split rows, Interfaces on $(TZ=Asia/Seoul date +%F).]

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| $S | $W — per \`Claude/results/handoffs/settings-phase-brief-template.md\` | A2 | template §3 gates | master check, or 1 logic review if code beyond a defaults table | $E | ⏳ |
EOT
printf '# User request ledger — Phase %s\n\nCarried-over open rows (numbers unchanged): R1, R9, R13, R20–R23, R31, R44–R66.\n\n| No. | Time | Received | Request | Where reflected | Master plan | Detail plan | Status | Basis |\n|---|---|---|---|---|---|---|---|---|\n' "$P" > Claude/results/REQUEST_LEDGER_phase$P.md
printf '# Session register — phase%s\n\n## Phase %s\n\n| Role | Definition | agentId | Target | Read area | Compactions | Last context | State |\n|---|---|---|---|---|---|---|---|\n' "$P" "$P" > Claude/results/handoffs/phase$P/SESSIONS.md
echo opened $P

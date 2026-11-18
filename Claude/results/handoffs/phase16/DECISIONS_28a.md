# Master decisions on design-28a Decision Queue
| ID | Decision | Why |
|---|---|---|
| DQ-1 | (b) separate addon `DevilForever_StatusStrip` | plan line 141 (selection = AddOn on/off, R44·R60); Core contract "changes no frame" (Core.lua:3, confirmed); no Core re-review; R101 met — nothing else shows these values |
| DQ-2 | local time | no server data needed |
| DQ-3 | clock item on, 24 h (plan row 16 lists the clock) | minimap clock duplication (SexyMap default TimeManagerClockButton="always", Defaults/SexyMap.lua:70 confirmed) → final-report item; Codex may suggest turning one off |
| DQ-4 | include `/dfstatus` (item on/off, 12/24h) | cheap; user can toggle without editing files |
| DQ-5, DQ-6, DQ-7 | none (no warning colour, no tooltip, no ammo) | R87 no hard-coded colours; mouse-through band; not requested |
| DQ-8, DQ-9 | leave as designed | |

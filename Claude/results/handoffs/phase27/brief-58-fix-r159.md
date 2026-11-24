# Brief addendum — Step 58 fix, user corrections R159 (supersede the matching rows of brief-58-fix.md)

User's words: "그리드 위치는 상단을 퀘스트 상단에, 우변을 퀘스트 좌변에 맞춰. 파티도, 공격대도 / 크기랑 모양은 일단 적용되면 확인해보고 피드백 줄게 / V2 기본 혹시 모를 수요를 위해 V1을 버리지는 않는다. V2 를 New로 V1 을 Old 로 하여 테마 변경 상태띠 모듈 좌측변에 버전 변경 모듈도 같이 둔다. 방식은 완전 동일하게 금색 필기체, 화살표로 전환하는것으로. / 주시 대상 상하 위치는 지금도 좋아. 그런데 선택한 대상 쪽에 가깝게 붙어있는게 문제야. 내 캐릭터와 대상 캐릭터 사이 중앙에 오게 하라고."

| Row | Replaces | New decision |
|---|---|---|
| 1 | Grid2 spot | Grid2 window TOP edge = the objective (quest) tracker's TOP edge; Grid2 RIGHT edge = the tracker's LEFT edge (Grid2 sits directly left of the tracker, tops aligned, grows down/left). Same anchor for party and raid layouts. Cell size/shape: keep the square default for now (user checks after). |
| 3 | V2 default | Do NOT fold V1 away. Two layout versions per screen size: **New** = V2 (default for new installs / first preset pick) and **Old** = V1 (today's fhd/qhd/uhd). Keep the active preset names working for code that depends on them (Composition, switcher image table, Party) — record how you map New/Old onto names. |
| 3b | new | **Version switcher** on the status strip, placed at the LEFT side of the theme switcher, exactly the same construction as the theme switcher: gold Allura script name images "New" and "Old" per fhd/qhd/uhd made by `theme_switcher_art.py` (same sizes/style rules, deterministic), the same prev/next arrow images, slide animation, text fallback, combat refusal + dim. Switching applies that layout the same way `/dfp preset <name>` + `/dfp go` does (say what the user sees: reload prompt or automatic reload). Add `LICENSE-OFL` coverage, manifest/extract update, tests like the theme switcher's. |
| 4 | Focus | Vertical position unchanged. Horizontal: focus frame centre = midpoint between the player frame's right edge and the target frame's left edge (equal gap on both sides). Pet frames unchanged. |
| new | install | The user stays in game and will `/reload`. Add a switch to `Collection/tools/install_local.ps1` (e.g. `-AllowRunningGame`) that skips only the "Wow.exe is running" refusal; it still backs up AddOns + WTF, writes only the package AddOns folders, never WTF. Help text explains it. Dry-run + refusal tests as before. |

Everything else in brief-58-fix.md stands.

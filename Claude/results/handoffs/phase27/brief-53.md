# Brief — Phase 27 Step 53 (screen check sub, Haiku — model chosen by the user, R154)

The user is asleep (R155). Work alone; never wait for the user. If something needs the user, stop that part and report it.

## Goal

The new 0.1.5 addons (commit c34716a3) were installed into `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns` at 21:01 (backup `D:\Projects\Project_WF\_local_only\claude-p27-backup-5b85dff4`). Check in the real game client, by screen only, that the addons load and show the layout that the check list expects. No gameplay.

Check list (read in full first): `D:/Projects/Project_WF/_local_only/claude-phase27/Collection/codex-briefs/phase27-game-check.md`.

## Allowed

- Computer use on the desktop and the game window: start `C:\Program Files (x86)\World of Warcraft\_forever_\Wow.exe` (or the launcher `C:\Program Files (x86)\World of Warcraft\World of Warcraft Launcher.exe` if Wow.exe needs it), click through to the character list, pick an existing character, Enter World.
- In game: open the chat box and type the slash commands / `/run` lines from the check list exactly, press Enter; open addon settings windows; click the status strip theme arrows; hover; `/reload`; the in-game screenshot key (Print Screen) — screenshots land in `C:\Program Files (x86)\World of Warcraft\_forever_\Screenshots\`.
- At the end: `/dfp preset` / `/dfp go` steps change saved settings — that is fine, master restores WTF from the backup afterwards. Log out to the character list and exit the game normally (menu → Exit Game) when done.

## Not allowed

- Typing any password, account name, authenticator code or any credential. If the client or launcher asks for a login, stop, take one screenshot of that screen (do not type anything), and report "login needed".
- Combat, attacking, casting at mobs, moving the character, inviting players, joining groups, chatting to other players (only slash commands that start with `/dfp`, `/run`, `/pb4`, `/q3`, `/grid2`, `/dom`, `/reload`), buying, mail, trading, creating or deleting characters, changing game system options.
- Writing or deleting any file except: copying the screenshots you took into `D:/Projects/Project_WF/_local_only/claude-phase27/References/codex-verify/phase27/screens/` and writing `D:/Projects/Project_WF/_local_only/claude-phase27/References/codex-verify/phase27/result.md`.
- If a computer-use access request is not approved, stop and report it.

## What to check (in this order; skip items marked 「플레이 필요」 and item 7)

1. Section 0: addon list on the character screen shows the DevilForever / Grid2 / PitBull4 / Quartz / Dominos folders enabled (open AddOns button if present). Any red "out of date / load failed" lines? Any Lua error popup after entering the world (BugSack icon / error frame)?
2. Item 9 (theme switcher): name images in gold script for all 13 themes (press ▶ 13 times, screenshot each), hover, ◀ ▶ slide, `/reload` keeps the theme, text fallback with the Edit:Set / Edit:Clear lines (do the `print(...)` guard first).
3. Item 1: run the measure line; PitBull4 config mode party + Grid2 test mode 5 and 40; note the printed y value and whether windows overlap; screenshots.
4. Item 6 (V2) and item 1's V2 measure: `/dfp preset` (list) → the `-v2` preset for this screen → `/dfp go` → after reload, measure and screenshot; config mode solo.
5. Item 2 (config-mode pet slot placement), item 3 (`/pb4` toggle + `/reload` twice; skip the relog part if it needs the login), item 5 (only if the logged-in character is a hunter; otherwise note the class), item 8 (`/dom config` on/off).
6. Turn off test modes (`SetConfigMode("disabled")`, `SetTestMode(false)`), exit the game.

## Report

`result.md`: for every check-list line: `결과: 맞음 / 다름(무엇이 · 화면 파일) / 못 봄(이유)`, the exact printed values (y measures, guard print), screen resolution and preset shown by `/dfp status`, character class, list of screenshot files with one line each saying what it shows. Your return text: the same table in short form plus anything that blocked you. Say clearly which results are your reading of a screenshot (they will be checked by master against the image).

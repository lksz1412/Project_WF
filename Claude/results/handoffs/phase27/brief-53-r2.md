# Brief addendum — Phase 27 Step 53 round 2 (same screen check sub, Haiku)

Everything in `brief-53.md` still holds, with these changes:

1. The user is awake and already logged in: `Wow.exe` (PID 32644) is running and a character is in the world. Do NOT start the launcher or Wow.exe, do NOT go to the character list, do NOT log in.
2. Call `request_access` for the running game app (World of Warcraft / Wow.exe). The user will approve the prompt. If it is denied again, stop and report.
3. Section 0 (addon list on the character screen): skip the character-screen part. Instead, in the world: `/run print(C_AddOns and C_AddOns.GetNumAddOns and C_AddOns.GetNumAddOns() or GetNumAddOns())` and check for a Lua error popup / BugSack red icon; screenshot.
4. Screenshots: you may use the computer-use screenshot directly, and also press Print Screen in game for files you copy to `References/codex-verify/phase27/screens/` (only copy files created during this run).
5. At the end: turn test modes off, then if you switched to a `-v2` preset, switch back with `/dfp preset <the preset /dfp status showed at the start>` and `/dfp go`. Do NOT log out and do NOT exit the game — leave the character in the world for the user.
6. Still no gameplay, no credentials, no moving, no chat to others.

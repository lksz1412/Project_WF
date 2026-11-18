# Observed environment — 2026-11-17

## Authorization

User confirmed the first screenshot in https://www.inven.co.kr/board/wow/1636/31588 as the desired appearance. The existing CurseForge combination was an unsatisfactory workaround and is reference only. Current task: inspect CurseForge and WoW with Computer Use, verify candidate support, write a plan. No installation or configuration changes are authorized by this planning request.

## Computer Use observations

Windows apps were enumerated with `@oai/sky` `list_apps()`. CurseForge has one window. WoW is running from `C:\Program Files (x86)\World of Warcraft\_forever_\Wow.exe`. CurseForge's accessibility document lists 15 projects in the selected Forever instance. Nine show Update; six show Recently Updated without a game-version value. Those labels are app observations, not proof of game compatibility or abandonment.

WoW was activated and its window captured. Screenshot metadata is 2560 × 1440. Game settings panel and the existing gameplay interface were visible. The game only exposes its top-level window through accessibility; no text or character details were transcribed from the image. No game input was sent. The initial settings panel remained open. Screenshot capture alone is not a proof of the configured render resolution, UI scale, enabled addon set, Lua error status, or functional compatibility.

The first WoW capture, before activation, showed the occluding desktop and was rejected as evidence of the game screen. The refreshed capture after activation showed the game.

## Read-only filesystem confirmation

Executable file/product version: 1.60.1.70938. Installed directories include the same 15 main projects, their submodules and Masque_Dominos. No PitBull, SexyMap, ElvUI, or Bagnon directory was observed. This is a directory inventory only, not a source audit or loaded-state test.

Selected Config.wtf values: textLocale koKR; GxMaximize 1. No configured resolution or UI scale was confirmed by this selected-value check. Account-specific SavedVariables and keybindings were not read.

## External reference already grounded

- Original reference post: https://www.inven.co.kr/board/wow/1636/31588 — 2022 Black FanFix 10.0.2 하단집중형. Author lists Dominos, PitBull, Quartz, SexyMap, ChocolateBar_FanFix. It is a composition of addons and profiles, not one standalone addon.
- Linked public Drive folder: https://drive.google.com/drive/folders/1QMZiceFpizZ5dHxTkG2UemZAYKaQFdg7 — listed Fonts.zip (35,611,779 bytes) and Interface.zip (31,392,260 bytes), modified 2022-11-19. Connector raw fetch succeeded for Interface.zip, but it has NOT been materialized or inspected locally. Do not claim source analysis, recovered profiles, licensing, or exact reproduction is complete.
- Modern client distinction: https://github.com/Questie/Questie/pull/7848 (maintainer implementation) explicitly distinguishes Forever content from modern UI APIs and Retail project ID. This does not validate any particular UI addon.

## Boundaries

No Update, Update all, Install, Sync, deletion, addon toggle, keybinding change, CVar change, reload, logout, or game chat action was performed. Game state may continue to change naturally. No player/account identifiers are included in the report. No performance or combat tests have been run.

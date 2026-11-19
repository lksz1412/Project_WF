# Experience Forever - Changelog

## v2.0.4
- Fixed the bar's border sometimes not showing all the way around, depending on where the bar was placed.
  Border lines no longer snap away, and the bar now snaps to whole screen pixels when moved.

## v2.0.3
- Fixed the hidden default XP bar still catching mouse input, which stopped Experience Forever's
  bar being moved or clicked when placed over it.

## v2.0.2
- Fixed the "blocked from an action only available to the Blizzard UI" popup at login.
  The addon no longer listens to the combat log, which this client blocks for addons.
- Reputation per kill is still auto-detected; reputation from quest turn-ins is ignored.

## v2.0.1
- Fixed the "ExperienceForever has been blocked from an action only available to the Blizzard UI" popup.
  The default XP bar is now faded out instead of hidden, which no longer taints Blizzard's UI.

## v2.0.0
Master release. Includes everything from the 1.x versions below.

- Kills to level: new text item showing roughly how many more kills like your last
  one you need to reach the next level. Learns XP per kill from the actual change in
  your XP bar after a kill (rested bonus included, quest turn-ins ignored).
- Reputation kills-to-standing: hover the reputation bar to see the kills needed to
  reach every standing above your current one, and optionally show the kills to the
  next standing in the bar text.
- Auto-detected reputation per kill, learned per faction from the game's reputation
  messages (most common of your last 7 kills), with a manual per-faction fallback and
  a "Forget Learned Value" option.
- New options: "Show Kills To Next Standing", "Reputation Per Kill",
  "Auto-Detect Reputation Per Kill", "Forget Learned Value".

## Earlier versions (1.3.0 - 1.5.1)
- 1.5.1: Kills to level now measures real XP change instead of the chat message.
- 1.5.0: Added "Kills to level" text item.
- 1.4.0: Added auto-detection of reputation per kill.
- 1.3.0: Added kills-to-standing estimates to the reputation bar.

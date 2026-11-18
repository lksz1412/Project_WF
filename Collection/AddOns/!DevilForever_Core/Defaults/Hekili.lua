-- Functional defaults for Hekili (HekiliDB, AceDB-3.0, account scope).
--
-- Profile rule: Hekili calls AceDB:New("HekiliDB", defaults, true), so every
-- character without a profileKeys entry uses the shared profile "Default";
-- Core writes only into a profile that is new when it first looks; an existing
-- profile is left untouched.
-- The next-action recommendation itself needs no value here: Hekili's own
-- defaults show it (profile.enabled, displays.Primary.enabled; the Cooldowns,
-- Defensives and Interrupts displays only when their toggle is "separate",
-- AOE only in dual/reactive mode), hide every display for specs Hekili does
-- not support, and let the player turn it off on its own (/hekili disable,
-- a display's Enabled option, the pause binding, or the addon list).
-- Status alerts and cooldowns are the client's Cooldown Manager, not Hekili.
-- Display position, size, skin and key bindings are not set here.

DevilForever_Core.Defaults:Register("Hekili", {
  version = 1,
  targets = {
    {
      savedVariable = "HekiliDB",
      shape = "acedb",
      profile = "Default",
      values = {
        barGlow = {
          enabled = true,   -- plan row 8 (action bar highlight) / D2: the recommended ability's action button glows
        },
      },
    },
  },
})

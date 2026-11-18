-- Functional defaults for Dominos (DominosDB, AceDB-3.0, account scope).
--
-- Profile rule: Dominos calls AceDB:New("DominosDB", defaults, UnitClass("player")),
-- so a character without a profileKeys entry uses the profile named after the
-- localized class name ("$className"); Core fills the profile that profileKeys
-- names when there is one (a LibDualSpec or user-chosen profile included).
-- Values equal to Dominos' own defaults are removed from the saved file by
-- AceDB at logout; they stay in effect through Dominos' defaults.
-- The action bar count (8), action bar paging (bar 1 per stance/form/stealth/
-- shadowform) and the stance, pet, possess and totem bars come from Dominos'
-- own defaults and are not set here. Key bindings are not set.

DevilForever_Core.Defaults:Register("Dominos", {
  version = 1,
  targets = {
    {
      savedVariable = "DominosDB",
      shape = "acedb",
      profile = "$className",
      values = {
        showBindingText = true,   -- R1: key binding text shown on buttons
      },
    },
  },
})

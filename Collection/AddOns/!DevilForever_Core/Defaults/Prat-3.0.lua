-- Functional defaults for Prat-3.0 (Prat3DB, AceDB-3.0, account scope).
--
-- Profile rule: Prat calls AceDB:New("Prat3DB", defaults, "Default"), so a
-- character without a profileKeys entry uses the profile "Default". Each Prat
-- module keeps its settings, its "on" switch included, in the AceDB namespace
-- "Prat_<module>" (module.name of AceAddon NewModule), under the same profile
-- name as the parent database.
-- Every other module keeps Prat's own on/off default. The chat windows, their
-- message groups and channels are client chat settings, not Prat settings;
-- the three-window split is made by DevilForever_ChatSetup. ChatLog (off) and
-- the History command-history save (savehistory = false) are Prat's defaults
-- and are not set here.

DevilForever_Core.Defaults:Register("Prat-3.0", {
  version = 1,
  targets = {
    {
      savedVariable = "Prat3DB",
      shape = "acedb",
      namespace = "Prat_History",
      profile = "Default",
      values = {
        scrollback = false,   -- R24 / plan row 4: chat lines are not stored in Prat3HighCPUPerCharDB between sessions
      },
    },
    {
      savedVariable = "Prat3DB",
      shape = "acedb",
      namespace = "Prat_Memory",
      profile = "Default",
      values = {
        on = false,           -- plan row 4 / R44: chat window, channel and CVar save/restore stays with Phase 20
      },
    },
  },
})

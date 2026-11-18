-- Functional defaults for Grid2 (Grid2DB, AceDB-3.0, account scope).
--
-- Profile rule: Grid2 calls AceDB:New("Grid2DB", defaults, Grid2:GetDefaultProfileName()), and
-- that name is nil unless Grid2DB.global.defaultProfileName is set, so a character without a
-- profileKeys entry gets its own profile named by the AceDB character key ("$char"). Core writes
-- only into a profile that is new at its first look (see Defaults.lua); an existing profile is
-- left as it is. With Grid2DB.global.defaultProfileName set, a new character uses that shared
-- profile and the values below go to an unused character-named profile.
-- Grid2Layout keeps its settings in the AceDB namespace "Grid2Layout" of the same saved variable,
-- under the same profile name (one target per table).
-- Grid2 reads hideBlizzard once, at its OnInitialize; layouts and FrameDisplay on every group
-- change.
-- Not set here: indicators and statuses (role icons, dispellable-debuff border, buff/HoT icons)
-- come from the profile template the player picks in Grid2's own first-start dialog, which runs
-- because versions.Grid2 is left unset; the raid layout (Grid2's "By Group"); unit button clicks
-- (Grid2's left = target, right = menu; no click casting — R97, mouseover macros use the
-- buttons' unit attribute); key bindings; appearance.

DevilForever_Core.Defaults:Register("Grid2", {
  version = 1,
  targets = {
    {
      savedVariable = "Grid2DB",
      shape = "acedb",
      profile = "$char",
      values = {
        hideBlizzard = {
          raid = true,   -- plan row 9 / one owner: Blizzard raid frames hidden while Grid2 draws the raid
        },
      },
    },
    {
      savedVariable = "Grid2DB",
      shape = "acedb",
      namespace = "Grid2Layout",
      profile = "$char",
      values = {
        -- plan row 9 / R45: Grid2 shows raid groups only; party and solo belong to the unit frames (Phase 6)
        layouts = {
          solo = "None",
          party = "None",
          arena = "None",
        },
        FrameDisplay = "Raid",   -- plan row 9: Grid2's window hidden outside a raid (no empty frame box)
      },
    },
  },
})

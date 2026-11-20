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
-- change. Grid2's group types (GridRoster.lua GroupChanged): solo, party, arena, raid; display
-- "Grouped" shows the window in every type but solo (GridLayout.lua UpdateVisibility).
-- Not set here: indicators and statuses (role icons, dispellable-debuff border, buff/HoT icons)
-- come from the profile template the player picks in Grid2's own first-start dialog, which runs
-- because versions.Grid2 is left unset. The templates Classic (preselected), Modern and Blizzard
-- (Grid2Options/profiles) all map border <- debuffs-DispellableByMe, alpha <- range and the
-- health bar <- heals-incoming; the minimal "Empty" template has the range fade only. Values
-- written here would not survive: the template assigns whole indicator and statusMap entries.
-- Also not set: the raid layout (Grid2's "By Group"); unit button clicks (Grid2's left =
-- target, right = menu; no click casting — R97, mouseover macros use the buttons' unit
-- attribute); key bindings; appearance.

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
        -- the unit frames own solo and party here; Party.lua moves the party to Grid2 (layout
        -- "By Group" for party and arena, window "Grouped") when this profile and the unit-frame
        -- profile are both new, or on /dfp party grid2
        layouts = {
          solo = "None",
          party = "None",
          arena = "None",
        },
        FrameDisplay = "Raid",   -- window hidden outside a raid (no empty frame box)
      },
    },
  },
})

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

-- Grid2's first-start template (the profile chosen in Grid2's dialog, written by
-- Grid2:MakeDatabaseDefaults after the preset fragments) assigns Grid2Frame and
-- Grid2Layout keys such as frameWidth/frameHeight/frameBorder/Padding. Right after
-- it ran, the active preset's Grid2Frame/Grid2Layout fragment values are written
-- again into that profile, once per profile key, and only when the preset wrote
-- them into that profile before (DevilForever_CoreDB.preset.fragments); other
-- profiles are left alone. Values inside the template's indicators (text sizes)
-- stay as the template sets them. Recorded in
-- DevilForever_CoreDB.preset.grid2Template[<targetKey>] = fragment version.
local Core = DevilForever_Core

local function reapplyAfterTemplate()
  local grid2 = _G.Grid2
  local db = grid2 and grid2.db
  if type(db) ~= "table" or type(db.GetCurrentProfile) ~= "function" then return end
  local profile = db:GetCurrentProfile()
  local presets = Core.Presets
  local active = presets and presets:GetActive()
  local def = active and presets:Get(active)
  local sv = _G.Grid2DB
  if not def or type(sv) ~= "table" or type(sv.namespaces) ~= "table" then return end
  local written = Core:DBTable("preset", "fragments", active)
  local done = Core:DBTable("preset", "grid2Template")
  for _, f in ipairs(def.fragments) do
    if f.folder == "Grid2" and (f.namespace == "Grid2Frame" or f.namespace == "Grid2Layout") then
      local key = "Grid2DB/" .. f.namespace .. "@profile:" .. profile
      local space = sv.namespaces[f.namespace]
      local target = type(space) == "table" and type(space.profiles) == "table" and space.profiles[profile]
      if type(written[key]) == "number" and done[key] == nil and type(target) == "table" then
        Core.WriteOver(target, f.values)
        done[key] = f.version
        Core:Log("info", "Defaults:Grid2", key .. ": preset values written again after Grid2's first-start template")
      end
    end
  end
end

Core:On("ADDON_LOADED", function(_, folder)
  if folder ~= "Grid2" then return end
  local grid2 = _G.Grid2
  if type(grid2) == "table" and type(grid2.MakeDatabaseDefaults) == "function" and type(hooksecurefunc) == "function" then
    hooksecurefunc(grid2, "MakeDatabaseDefaults", reapplyAfterTemplate)
  end
end)

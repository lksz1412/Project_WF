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
-- come from Grid2's profile template, applied because versions.Grid2 is left unset. Grid2 would
-- ask for it in a first-start dialog (reopened every second, Grid2's window hidden until a
-- pick); the hook below picks Modern (else Classic) for it, so no dialog opens. The templates
-- Classic, Modern and Blizzard (Grid2Options/profiles) all map border <- debuffs-DispellableByMe,
-- alpha <- range and the health bar <- heals-incoming; the minimal "Empty" template has the range
-- fade only. Values written here would not survive: the template assigns whole indicator and
-- statusMap entries.
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
        -- party and raid on Grid2 (healer mouseover), next to the unit frames' own party;
        -- nothing solo
        layouts = {
          solo = "None",
          party = "By Group",
          arena = "By Group",
        },
        FrameDisplay = "Grouped",   -- window in party, arena and raid, hidden solo (no empty frame box)
        minimapIcon = {
          hide = true,   -- Grid2LDB's minimap button (Grid2Layout's shared value) off; /grid2 minimapicon show shows it
        },
      },
    },
  },
})

-- Grid2:MakeDatabaseDefaults() without a chosen template (Grid2.defaultProfileIndex nil)
-- loads Grid2Options and opens the first-start dialog. The hook sets the index of the
-- registered template "Modern" (else "Classic") first, after loading Grid2Options when
-- needed (Grid2 does the same load), so the template is applied at once; when neither is
-- registered Grid2's dialog opens as before.
-- Grid2's first-start template (written by
-- Grid2:MakeDatabaseDefaults after the preset fragments) assigns Grid2Frame and
-- Grid2Layout keys such as frameWidth/frameHeight/frameBorder/Padding. The method
-- returns true when it applied a template (false when it only opened the
-- dialog, GridDefaults.lua MakeDatabaseDefaults). Right after a call that
-- applied one, the active preset's Grid2Frame/Grid2Layout fragment values are written
-- again into that profile, once per profile key, and only when the preset wrote
-- them into that profile before (DevilForever_CoreDB.preset.fragments); other
-- profiles are left alone. The template's name text (each "text" indicator that
-- its statusMap maps the "name" status to: Classic text-down, Modern text-center,
-- Blizzard text-name) gets the Grid2Frame fragment's fontSize in the same step;
-- other indicator values stay as the template sets them. Recorded in
-- DevilForever_CoreDB.preset.grid2Template[<targetKey>] = fragment version.
-- The other text indicators of a cell (statuses such as dead, offline or the health deficit) get
-- OTHER_TEXT of the preset, three quarters of the name text. A profile this collection set up before
-- these sizes has its text indicators sized once at Grid2's ADDON_LOADED, before Grid2 reads its
-- database: only indicators still at a size the template (8, 9) or an earlier preset name text (12,
-- 14, 18) gave, so a size the player picked stays. Recorded in
-- DevilForever_CoreDB.preset.grid2Text[<profile>] = TEXT_VERSION.
local Core = DevilForever_Core

local OTHER_TEXT = {fhd = 11, qhd = 15, uhd = 23}
local EARLIER_TEXT = {[8] = true, [9] = true, [12] = true, [14] = true, [18] = true}
local TEXT_VERSION = 1

local function setTextSizes(profileTable, nameSize, otherSize, onlyEarlier)
  local indicators = type(profileTable) == "table" and profileTable.indicators
  local map = type(profileTable) == "table" and profileTable.statusMap
  if type(nameSize) ~= "number" or type(indicators) ~= "table" or type(map) ~= "table" then return 0 end
  local written = 0
  for name, ind in pairs(indicators) do
    if type(ind) == "table" and ind.type == "text" then
      local isName = type(map[name]) == "table" and map[name].name
      local size = isName and nameSize or otherSize
      if type(size) == "number" and (not onlyEarlier or ind.fontSize == nil or EARLIER_TEXT[ind.fontSize]) then
        ind.fontSize = size
        written = written + 1
      end
    end
  end
  return written
end

-- Name and other text sizes of the active preset (the Grid2Frame fragment's fontSize), or nil.
local function presetTextSizes()
  local presets = Core.Presets
  local active = presets and presets:GetActive()
  local family = type(active) == "string" and active:match("^(%a+)")
  for _, name in ipairs({active, family}) do
    local def = name and presets:Get(name)
    for _, f in ipairs(def and def.fragments or {}) do
      if f.folder == "Grid2" and f.namespace == "Grid2Frame" and type(f.values.fontSize) == "number" then
        return f.values.fontSize, OTHER_TEXT[family]
      end
    end
  end
end

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
        if f.namespace == "Grid2Frame" and type(sv.profiles) == "table" then
          local family = type(active) == "string" and active:match("^(%a+)")
          setTextSizes(sv.profiles[profile], f.values.fontSize, OTHER_TEXT[family], false)
          Core:DBTable("preset", "grid2Text")[profile] = TEXT_VERSION
        end
        done[key] = f.version
        Core:Log("info", "Defaults:Grid2", key .. ": preset values written again after Grid2's first-start template")
      end
    end
  end
end

local TEMPLATES = {"Modern", "Classic"}

local function pickTemplate(grid2)
  if type(grid2.DbGetRegisteredProfileByName) ~= "function" then return end
  local load = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn
  if _G.Grid2Options == nil and type(load) == "function" then pcall(load, "Grid2Options") end
  for _, name in ipairs(TEMPLATES) do
    local info, index = grid2:DbGetRegisteredProfileByName(name)
    if info and type(index) == "number" then
      grid2.defaultProfileIndex = index
      Core:Log("info", "Defaults:Grid2", "first-start template " .. name .. " picked (no dialog)")
      return
    end
  end
end

-- A profile the collection's preset wrote before: text indicators sized once (see OTHER_TEXT).
local function resizeEarlierText()
  local sv = _G.Grid2DB
  local keys = Core.PlayerKeys()
  if type(sv) ~= "table" or not keys or type(sv.profileKeys) ~= "table" or type(sv.profiles) ~= "table" then return end
  local profile = sv.profileKeys[keys.char]
  local profileTable = type(profile) == "string" and sv.profiles[profile]
  local done = Core:DBTable("preset", "grid2Text")
  if type(profileTable) ~= "table" or (tonumber(done[profile]) or 0) >= TEXT_VERSION then return end
  local active = Core.Presets and Core.Presets:GetActive()
  local family = type(active) == "string" and active:match("^(%a+)")
  local key = "Grid2DB/Grid2Frame@profile:" .. profile
  local byPreset = Core:DBTable("preset", "fragments")
  local ours = false
  for _, name in ipairs({active, family}) do
    local written = name and rawget(byPreset, name)
    if type(written) == "table" and type(written[key]) == "number" then ours = true end
  end
  if not ours then return end
  local nameSize, otherSize = presetTextSizes()
  if not nameSize then return end
  local written = setTextSizes(profileTable, nameSize, otherSize, true)
  done[profile] = TEXT_VERSION
  Core:Log("info", "Defaults:Grid2", profile .. ": " .. written .. " text indicator sizes set for the preset")
end

Core:On("ADDON_LOADED", function(_, folder)
  if folder ~= "Grid2" then return end
  resizeEarlierText()
  local grid2 = _G.Grid2
  local make = type(grid2) == "table" and grid2.MakeDatabaseDefaults
  if type(make) == "function" then
    grid2.MakeDatabaseDefaults = function(self, ...)
      if self.defaultProfileIndex == nil then pickTemplate(self) end
      local applied = make(self, ...)
      if applied then reapplyAfterTemplate() end
      return applied
    end
  end
end)

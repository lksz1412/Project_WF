local _, addon = ...
local stages = {"baseline", "quest", "chat", "petabsent", "pet", "combat", "party", "raid", "theme", "comparison"}
local valid = {}
for _, stage in ipairs(stages) do valid[stage] = true end

local frames = {
  action = "DominosFrame1", menu = "DominosFramemenu", bags = "DominosFramebags",
  queue = "DominosFramequeue", minimap = "Minimap", minimapClock = "TimeManagerClockButton",
  status = "DevilForever_StatusStripFrame", playerCast = "Quartz3CastBarPlayer",
  targetCast = "Quartz3CastBarTarget", damage = "DetailsBaseFrame1", threat = "DetailsBaseFrame2",
  essential = "EssentialCooldownViewer", utility = "UtilityCooldownViewer",
  cooldownIcons = "BuffIconCooldownViewer", cooldownBars = "BuffBarCooldownViewer",
  questWatch = "QuestWatchFrame", watch = "WatchFrame", objectives = "ObjectiveTrackerFrame",
  experience = "ExperienceForeverFrame", raid = "Grid2LayoutFrame",
  pbPlayer = "PitBull4_Frames_플레이어", pbTarget = "PitBull4_Frames_대상",
  pbPet = "PitBull4_Frames_플레이어의 소환수", pbPetTarget = "PitBull4_Frames_플레이어의 소환수의 대상",
  petActions = "DominosFramepet", petCast = "Quartz3CastBarPet",
  fufPlayer = "ForeverUnitFrames_player", fufTarget = "ForeverUnitFrames_target",
}

local function read(fn, ...)
  if type(fn) ~= "function" then return end
  local ok, a, b, c, d = pcall(fn, ...)
  if not ok then return end
  if type(issecretvalue) == "function" and
      (issecretvalue(a) or issecretvalue(b) or issecretvalue(c) or issecretvalue(d)) then return end
  return a, b, c, d
end

local function petPresence()
  if type(UnitExists) ~= "function" then return end
  local ok, exists = pcall(UnitExists, "pet")
  if not ok or (type(issecretvalue) == "function" and issecretvalue(exists)) then return end
  return exists and true or false
end

local function describe(frame, factor, screenHeight)
  if not frame then return {found = false} end
  local found = {found = true, visible = read(frame.IsVisible or frame.IsShown, frame)}
  local x, y, width, height = read(frame.GetRect, frame)
  local scale = read(frame.GetEffectiveScale, frame)
  if type(factor) == "number" and factor > 0 and type(scale) == "number" and scale > 0 and
      type(screenHeight) == "number" and type(x) == "number" and type(y) == "number" and
      type(width) == "number" and type(height) == "number" then
    local multiplier = scale / factor
    found.rect = {x * multiplier, screenHeight - (y + height) * multiplier,
      width * multiplier, height * multiplier}
  end
  return found
end

local function capture()
  local version, build, date, interface = read(GetBuildInfo)
  local width, height = read(GetPhysicalScreenSize)
  local factor = read(PixelUtil and PixelUtil.GetPixelToUIUnitFactor)
  if type(factor) ~= "number" and DevilForever_Appearance then
    factor = read(DevilForever_Appearance.GetPixelFactor, DevilForever_Appearance)
  end
  local core = DevilForever_Core
  local setup = DevilForever_ChatSetupDB
  local windows = type(setup) == "table" and setup.result == "created" and setup.windows
  if type(windows) ~= "table" then windows = nil end
  local plates = C_NamePlate and read(C_NamePlate.GetNamePlates)
  local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
  local value = {
    version = version, build = build, date = date, interface = interface, width = width, height = height,
    scale = UIParent and read(UIParent.GetEffectiveScale, UIParent), factor = factor,
    preset = core and core.Presets and read(core.Presets.GetActive, core.Presets),
    theme = core and core.Theme and read(core.Theme.GetSet, core.Theme),
    combat = read(InCombatLockdown) and true or false, partySize = read(GetNumGroupMembers),
    petPresent = petPresence(),
    inRaid = read(IsInRaid), nameplates = type(plates) == "table" and #plates or nil, frames = {},
    pitbull4 = read(isLoaded, "PitBull4"), fuf = read(isLoaded, "ForeverUnitFrames"),
    nameplateSizes = addon and read(addon.NameplateSizes),
  }
  for key, name in pairs(frames) do value.frames[key] = describe(_G[name], factor, height) end
  for _, key in ipairs({"public", "group", "system"}) do
    local id = windows and windows[key] or (key == "public" and 1)
    local frame = type(id) == "number" and _G["ChatFrame" .. id]
    value.frames[key] = describe(frame, factor, height)
  end
  return value
end

local function output(text)
  local line = "DevilForever check: " .. text
  if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
    DEFAULT_CHAT_FRAME:AddMessage(line)
  else
    print(line)
  end
end

local function status()
  local captures = DevilForever_UIReviewDB and DevilForever_UIReviewDB.captures or {}
  for _, stage in ipairs(stages) do
    local data = captures[stage]
    if data then
      output(stage .. " | " .. tostring(data.width or "?") .. "x" .. tostring(data.height or "?") ..
        " | " .. tostring(data.preset or "?") .. "/" .. tostring(data.theme or "?") ..
        " | combat=" .. tostring(data.combat) .. " group=" .. tostring(data.partySize or "?") ..
        " | PB4=" .. tostring(data.pitbull4) .. " FUF=" .. tostring(data.fuf))
    else
      output(stage .. " | pending")
    end
  end
end

local function show(stage)
  local data = DevilForever_UIReviewDB and DevilForever_UIReviewDB.captures and DevilForever_UIReviewDB.captures[stage]
  if not data then output(stage .. " | pending"); return end
  output(stage .. " | build=" .. tostring(data.build or "?") .. " scale=" .. tostring(data.scale or "?") ..
    " plates=" .. tostring(data.nameplates or "?") .. " pet=" .. tostring(data.petPresent))
  local sizes = data.nameplateSizes
  if sizes then
    output("nameplate bars | matched=" .. sizes.matched .. " measured=" .. sizes.measured .. " seen=" .. sizes.inspected)
    local first = sizes.first
    if first then
      output(string.format("nameplate bar | %.1fx%.1f target=%dx%d", first.width, first.height, first.targetWidth, first.targetHeight))
    end
  end
  local keys = {}
  for key in pairs(data.frames) do keys[#keys + 1] = key end
  table.sort(keys)
  for _, key in ipairs(keys) do
    local frame = data.frames[key]
    if frame.rect then
      output(key .. " | " .. string.format("%.1f,%.1f %.1fx%.1f", unpack(frame.rect)) ..
        " | visible=" .. tostring(frame.visible))
    else
      output(key .. " | " .. (frame.found and "no bounds" or "absent"))
    end
  end
end

local function run(message)
  local requested = message:match("^%s*show%s+([%a]+)%s*$")
  if requested and valid[requested] then show(requested); return end
  local stage = message:match("^%s*([%a]+)%s*$") or ""
  if stage == "" or stage == "report" then status(); return end
  if stage == "start" then
    local value = capture()
    if value.pitbull4 and value.fuf then output("both unit-frame addons loaded"); return end
    local previous = DevilForever_UIReviewDB and DevilForever_UIReviewDB.captures
    DevilForever_UIReviewDB = {captures = {baseline = value}, previous = previous}
    output("baseline | recorded, new review started")
    return
  end
  if not valid[stage] then output("start | " .. table.concat(stages, " | ") .. " | report"); return end
  local value = capture()
  if value.pitbull4 and value.fuf then output("both unit-frame addons loaded"); return end
  if (stage == "combat" and not value.combat) or (stage == "pet" and value.petPresent ~= true) or
      (stage == "petabsent" and value.petPresent ~= false) or
      (stage == "party" and (value.inRaid or (value.partySize or 0) < 2)) or
      (stage == "raid" and not value.inRaid) or
      (stage == "comparison" and (not value.fuf or value.pitbull4 ~= false)) then
    output(stage .. " | required game state is absent"); return
  end
  if type(DevilForever_UIReviewDB) ~= "table" or type(DevilForever_UIReviewDB.captures) ~= "table" then
    DevilForever_UIReviewDB = {captures = {}}
  end
  DevilForever_UIReviewDB.captures[stage] = value
  output(stage .. " | recorded")
end

SLASH_DEVILFOREVERUICHECK1 = "/dfcheck"
SlashCmdList.DEVILFOREVERUICHECK = run

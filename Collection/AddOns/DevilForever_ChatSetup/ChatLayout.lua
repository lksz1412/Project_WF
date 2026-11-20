local _, addon = ...
local layouts = {
  fhd = function()
-- Evaluate at first placement after the client has established UIParent scale.
local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
if not pixel then DevilForever_Core:Log("skip", "Chat layout", "physical pixel factor unavailable"); return {} end
return {
  public = {point = "TOPLEFT", x = 6 * pixel, y = -866 * pixel, width = 426 * pixel, height = 148 * pixel},
  group = {point = "TOPLEFT", x = 446 * pixel, y = -866 * pixel, width = 426 * pixel, height = 148 * pixel},
  system = {point = "TOPLEFT", x = 1492 * pixel, y = -866 * pixel, width = 422 * pixel, height = 148 * pixel},
}
  end,
  qhd = function()
-- Evaluate at first placement after the client has established UIParent scale.
local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
if not pixel then DevilForever_Core:Log("skip", "Chat layout", "physical pixel factor unavailable"); return {} end
return {
  public = {point = "TOPLEFT", x = 6 * pixel, y = -1192 * pixel, width = 608 * pixel, height = 174 * pixel},
  group = {point = "TOPLEFT", x = 628 * pixel, y = -1192 * pixel, width = 608 * pixel, height = 174 * pixel},
  system = {point = "TOPLEFT", x = 1952 * pixel, y = -1192 * pixel, width = 602 * pixel, height = 174 * pixel},
}
  end,
  uhd = function()
-- Evaluate at first placement after the client has established UIParent scale.
local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
if not pixel then DevilForever_Core:Log("skip", "Chat layout", "physical pixel factor unavailable"); return {} end
return {
  public = {point = "TOPLEFT", x = 8 * pixel, y = -1828 * pixel, width = 944 * pixel, height = 244 * pixel},
  group = {point = "TOPLEFT", x = 970 * pixel, y = -1828 * pixel, width = 944 * pixel, height = 244 * pixel},
  system = {point = "TOPLEFT", x = 2910 * pixel, y = -1828 * pixel, width = 922 * pixel, height = 244 * pixel},
}
  end,
}

function addon.GetPreparedChatWindow(role)
  if not DevilForever_Appearance or not DevilForever_Core or not DevilForever_Core.Presets then return nil end
  local active = DevilForever_Core.Presets:GetActive()
  local layout = layouts[active]
  return layout and layout()[role]
end

local windowsCreated = {}
function addon:RegisterWindowsCreated(owner, callback)
  windowsCreated[owner] = callback
end

function addon.NotifyWindowsCreated()
  for _, callback in pairs(windowsCreated) do
    local ok, reason = pcall(callback)
    if not ok and type(geterrorhandler) == "function" then geterrorhandler()(reason) end
  end
end

DevilForever_ChatSetup = addon

local roleOrder = {"public", "group", "system"}
local ready, pending, scheduled = false, false, false
local layoutState = "waiting"
local layoutRoles = {}
local severity = {current = 0, applied = 1, ["failed-restored"] = 2, ["restore-failed"] = 3}

local function roleResult(role, result)
  layoutRoles[role] = result
  if (severity[result] or 0) > (severity[layoutState] or 0) then layoutState = result end
end

local function finite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function snapshot(frame)
  if not frame or type(frame.GetPoint) ~= "function" or frame.isTemporary then return nil end
  local point, relative, relativePoint, x, y = frame:GetPoint(1)
  if relative ~= UIParent or type(point) ~= "string" or not finite(x) or not finite(y)
      or not finite(frame:GetWidth()) or not finite(frame:GetHeight()) then return nil end
  return {id = frame:GetID(), point = point, relativePoint = relativePoint,
    x = x, y = y, width = frame:GetWidth(), height = frame:GetHeight(),
    scale = frame.GetScale and frame:GetScale() or 1, docked = not not frame.isDocked}
end

local function near(a, b)
  return finite(a) and finite(b) and math.abs(a - b) < 0.01
end

local function matches(a, b)
  return type(a) == "table" and type(b) == "table" and a.id == b.id and a.point == b.point and a.relativePoint == b.relativePoint
    and a.docked == b.docked and near(a.x, b.x) and near(a.y, b.y)
    and near(a.width, b.width) and near(a.height, b.height) and near(a.scale, b.scale)
end

function addon.CaptureManagedLayout()
  local db = DevilForever_ChatSetupDB
  if type(db) ~= "table" or db.result ~= "created" or type(db.windows) ~= "table" then return end
  local roles = {}
  for _, role in ipairs(roleOrder) do
    local id = db.windows[role]
    local frame = type(id) == "number" and id ~= 2 and _G["ChatFrame" .. id]
    if frame and addon.GetPreparedChatWindow(role) then roles[role] = snapshot(frame) end
  end
  if next(roles) then db.managedLayout = {version = 1, roles = roles} end
end

local function apply()
  if not ready then return end
  if InCombatLockdown() then pending = true; layoutState = "combat"; return end
  pending = false
  local db = DevilForever_ChatSetupDB
  local managed = type(db) == "table" and db.result == "created" and db.managedLayout
  if type(managed) ~= "table" or managed.version ~= 1 or type(managed.roles) ~= "table" then
    layoutState = "unmanaged"
    return
  end
  layoutState = "current"
  layoutRoles = {}
  for _, role in ipairs(roleOrder) do
    local receipt = managed.roles[role]
    local id = type(db.windows) == "table" and db.windows[role]
    local frame = type(id) == "number" and id ~= 2 and _G["ChatFrame" .. id]
    if receipt then
      local current = snapshot(frame)
      if not frame or (not frame:IsShown() and not frame.isDocked) or not matches(receipt, current) then
        managed.roles[role] = nil
        roleResult(role, "released")
      else
        local bounds = addon.GetPreparedChatWindow(role)
        if bounds and not (current.point == bounds.point and current.relativePoint == bounds.point
            and near(current.x, bounds.x) and near(current.y, bounds.y)
            and near(current.width, bounds.width) and near(current.height, bounds.height)) then
          local ok = pcall(function()
            frame:SetSize(bounds.width, bounds.height)
            frame:ClearAllPoints()
            frame:SetPoint(bounds.point, UIParent, bounds.point, bounds.x, bounds.y)
            local actual = snapshot(frame)
            if not actual or not near(actual.x, bounds.x) or not near(actual.y, bounds.y)
                or not near(actual.width, bounds.width) or not near(actual.height, bounds.height) then
              error("chat layout verification failed")
            end
            if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(frame) end
          end)
          if ok then
            managed.roles[role] = snapshot(frame)
            roleResult(role, "applied")
          else
            local restored = pcall(function()
              frame:SetSize(current.width, current.height)
              frame:ClearAllPoints()
              frame:SetPoint(current.point, UIParent, current.relativePoint, current.x, current.y)
              if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(frame) end
            end)
            local result = restored and matches(current, snapshot(frame)) and "failed-restored" or "restore-failed"
            roleResult(role, result)
            if result == "restore-failed" then managed.roles[role] = nil end
          end
        end
      end
    end
  end
end

-- The windows carry a placement receipt (layout managed by this addon).
local function managedLayout()
  local db = DevilForever_ChatSetupDB
  local managed = type(db) == "table" and db.result == "created" and db.managedLayout
  return type(managed) == "table" and managed.version == 1 and type(managed.roles) == "table"
end

-- The 4 s settle wait before the first apply runs only when there is a
-- managed layout to check (also when one appears later in the session).
local waiting = false
local function settleThenApply()
  if waiting then return end
  waiting = true
  C_Timer.After(4, function() waiting = false; ready = true; apply() end)
end

local function schedule()
  if not ready then
    if managedLayout() then settleThenApply() end
    return
  end
  if scheduled then return end
  scheduled = true
  C_Timer.After(0, function() scheduled = false; apply() end)
end

-- Legacy windows without a placement receipt stay outside automatic management.
function addon.GetLayoutStatus()
  local db = DevilForever_ChatSetupDB
  local roles = type(db) == "table" and type(db.managedLayout) == "table" and db.managedLayout.roles
  local count = 0
  for _ in pairs(type(roles) == "table" and roles or {}) do count = count + 1 end
  local roles = {}
  for role, result in pairs(layoutRoles) do roles[role] = result end
  return {state = layoutState, managedRoles = count, pending = pending, roles = roles}
end

local events = CreateFrame("Frame")
for _, name in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED"}) do
  events:RegisterEvent(name)
end
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    if managedLayout() then settleThenApply() else layoutState = "unmanaged" end
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then
    schedule()
  end
end)
local Core = DevilForever_Core
if Core and Core.Edit and type(Core.Edit.RegisterCallback) == "function" then
  Core.Edit:RegisterCallback(addon, function(key)
    if key == "appearance.chat1" or key == "appearance.chat2" or key == "appearance.chat3" then schedule() end
  end)
end

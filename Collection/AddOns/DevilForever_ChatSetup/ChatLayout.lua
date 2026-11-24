local _, addon = ...
local function publicWindow(left, right, top, height, pixel)
  if type(GetPhysicalScreenSize) == "function" then
    local width = GetPhysicalScreenSize()
    if type(width) == "number" and width > 0 then left = math.max(left, math.ceil(width * 0.015)) end
  end
  return {point = "TOPLEFT", x = left * pixel, y = -top * pixel,
    width = (right - left) * pixel, height = height * pixel}
end
local layouts = {
  fhd = function()
-- Evaluate at first placement after the client has established UIParent scale.
local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
if not pixel then DevilForever_Core:Log("skip", "Chat layout", "physical pixel factor unavailable"); return {} end
return {
  public = publicWindow(30, 417, 866, 148, pixel),
  group = {point = "TOPLEFT", x = 446 * pixel, y = -866 * pixel, width = 426 * pixel, height = 148 * pixel},
  system = {point = "TOPLEFT", x = 1492 * pixel, y = -866 * pixel, width = 422 * pixel, height = 148 * pixel},
}
  end,
  qhd = function()
-- Evaluate at first placement after the client has established UIParent scale.
local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
if not pixel then DevilForever_Core:Log("skip", "Chat layout", "physical pixel factor unavailable"); return {} end
return {
  public = publicWindow(40, 595, 1192, 174, pixel),
  group = {point = "TOPLEFT", x = 628 * pixel, y = -1192 * pixel, width = 608 * pixel, height = 174 * pixel},
  system = {point = "TOPLEFT", x = 1952 * pixel, y = -1192 * pixel, width = 602 * pixel, height = 174 * pixel},
}
  end,
  uhd = function()
-- Evaluate at first placement after the client has established UIParent scale.
local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
if not pixel then DevilForever_Core:Log("skip", "Chat layout", "physical pixel factor unavailable"); return {} end
return {
  public = publicWindow(60, 928, 1828, 244, pixel),
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

local anchors = {TOPLEFT = {0, 1}, TOP = {.5, 1}, TOPRIGHT = {1, 1}, LEFT = {0, .5},
  CENTER = {.5, .5}, RIGHT = {1, .5}, BOTTOMLEFT = {0, 0}, BOTTOM = {.5, 0}, BOTTOMRIGHT = {1, 0}}
local function rectangle(value)
  if type(value) ~= "table" or not UIParent.GetHeight then return end
  local point, relative = anchors[value.point], anchors[value.relativePoint]
  local width, height = UIParent:GetWidth(), UIParent:GetHeight()
  if not point or not relative or not finite(width) or not finite(height) then return end
  local scale = value.scale or 1
  return relative[1] * width + (value.x - point[1] * value.width) * scale,
    relative[2] * height + (value.y - point[2] * value.height) * scale
end

local function sameRectangle(a, b)
  if matches(a, b) then return true end
  if type(a) ~= "table" or type(b) ~= "table" or a.id ~= b.id or a.docked ~= b.docked
      or not near(a.width, b.width) or not near(a.height, b.height) or not near(a.scale, b.scale) then return false end
  local ax, ay = rectangle(a)
  local bx, by = rectangle(b)
  return near(ax, bx) and near(ay, by)
end

local function builtinLayout()
  if not C_EditMode or type(C_EditMode.GetLayouts) ~= "function" then return end
  local ok, data = pcall(C_EditMode.GetLayouts)
  local presets = EditModePresetLayoutManager and EditModePresetLayoutManager.presetLayoutInfo
  if not ok or type(data) ~= "table" or type(data.activeLayout) ~= "number"
      or type(presets) ~= "table" or #presets == 0 then return end
  if data.activeLayout >= 1 and data.activeLayout <= #presets then return data.activeLayout end
  return false
end

local publicFallback
function addon.CapturePublicFallback(frame)
  local preset = builtinLayout()
  publicFallback = preset and {preset = preset, frame = snapshot(frame)} or nil
  return preset ~= false
end

local function explicitPreset()
  local presets = DevilForever_Core and DevilForever_Core.Presets
  local name = presets and presets.GetAppliedRequest and presets:GetAppliedRequest()
  return type(name) == "string" and name == presets:GetActive()
end

function addon.CaptureManagedLayout()
  local db = DevilForever_ChatSetupDB
  if type(db) ~= "table" or db.result ~= "created" or type(db.windows) ~= "table" then return end
  local roles = {}
  for _, role in ipairs(roleOrder) do
    local id = db.windows[role]
    local frame = type(id) == "number" and id ~= 2 and _G["ChatFrame" .. id]
    if frame and addon.GetPreparedChatWindow(role) and (role ~= "public" or builtinLayout() ~= false) then
      roles[role] = snapshot(frame)
    end
  end
  if next(roles) then
    db.managedLayout = {version = 1, roles = roles}
    if publicFallback and publicFallback.frame then db.managedLayout.publicFallback = publicFallback end
  end
end

local requestHandled = false
local function apply()
  if not ready then return end
  if InCombatLockdown() then pending = true; layoutState = "combat"; return end
  pending = false
  local db = DevilForever_ChatSetupDB
  local managed = type(db) == "table" and db.result == "created" and db.managedLayout
  local preset = builtinLayout()
  local recover = not requestHandled and explicitPreset()
  if recover then requestHandled = true end
  if recover and preset
      and type(db) == "table" and db.result == "created" and type(db.windows) == "table"
      and db.windows.public == 1 and not ChatFrame1.isTemporary then
    local current = snapshot(ChatFrame1)
    if current then
      if type(managed) ~= "table" or managed.version ~= 1 or type(managed.roles) ~= "table" then
        managed = {version = 1, roles = {}}
        db.managedLayout = managed
      end
      if not managed.publicFallback or managed.publicFallback.preset ~= preset then
        managed.publicFallback = {preset = preset, frame = current}
      end
      managed.roles.public = current
    end
  end
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
      local public = role == "public" and id == 1
      local fallback = public and managed.publicFallback
      local accepted = public and (sameRectangle(receipt, current)
        or type(fallback) == "table" and preset == fallback.preset and sameRectangle(fallback.frame, current))
        or not public and matches(receipt, current)
      if public and preset == false then accepted = false end
      if not frame or (not frame:IsShown() and not frame.isDocked) or not accepted then
        managed.roles[role] = nil
        if public then managed.publicFallback = nil end
        roleResult(role, "released")
      else
        local bounds = addon.GetPreparedChatWindow(role)
        local desired = bounds and {id = id, point = bounds.point, relativePoint = bounds.point,
          x = bounds.x, y = bounds.y, width = bounds.width, height = bounds.height,
          scale = current.scale, docked = current.docked}
        if bounds and not (public and sameRectangle(current, desired)
            or current.point == bounds.point and current.relativePoint == bounds.point
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
            local result = restored and (public and sameRectangle(current, snapshot(frame))
              or not public and matches(current, snapshot(frame))) and "failed-restored" or "restore-failed"
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
    or not requestHandled and explicitPreset() and type(db) == "table" and db.result == "created"
      and type(db.windows) == "table" and db.windows.public == 1
end

-- Native layout initialization settles before managed placement is checked.
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

-- Legacy windows need an explicit preset request to regain a placement receipt.
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
  if event == "PLAYER_ENTERING_WORLD" or event == "EDIT_MODE_LAYOUTS_UPDATED" then
    if managedLayout() then settleThenApply() else layoutState = "unmanaged" end
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then
    schedule()
  end
end)
if C_EditMode and type(C_EditMode.GetLayouts) == "function" then events:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED") end
local Core = DevilForever_Core
if Core and Core.Edit and type(Core.Edit.RegisterCallback) == "function" then
  Core.Edit:RegisterCallback(addon, function(key)
    if key == "appearance.chat1" or key == "appearance.chat2" or key == "appearance.chat3" then schedule() end
  end)
end

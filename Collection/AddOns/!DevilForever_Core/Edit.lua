-- Per-frame edit values that overlay theme tokens.
--
-- Stored in DevilForever_CoreDB.edits[frameKey][field]. frameKey is any
-- non-empty string chosen by the code that owns the frame (registry frame keys
-- are the shared ones). Fields and value shapes:
--   position = {point = str, relativeTo = str|nil, relativePoint = str|nil, x = num, y = num}
--   size     = {width = num > 0, height = num > 0}
--   font     = {path = str|nil, size = num > 0|nil, flags = str|nil}  (at least one key)
--   color    = {r, g, b[, a]}  numbers 0..1
--   rows     = integer >= 1
--   spacing  = number >= 0
-- A registry editable item {frame = frameKey, field, min, max} bounds rows,
-- spacing, size.width/height and font.size.
--
-- Get(frameKey) layers, lowest first: field token (font: font.normal +
-- font.size.normal, color: color.text.normal, spacing: spacing.default; a
-- registry frame entry may name other tokens per field), registry item
-- default, stored edit value. font merges per key; other fields replace.
--
-- Set/Clear while InCombatLockdown() is true are held and written on
-- PLAYER_REGEN_ENABLED (last value per frame and field wins). Listeners get
-- (frameKey, field, storedValue) after a value is written; storedValue is nil
-- after a clear.

local _, Core = ...

local type, pairs, ipairs, floor, tinsert = type, pairs, ipairs, math.floor, table.insert

local Edit = {}
Core.Edit = Edit

Edit.FIELDS = {"position", "size", "font", "color", "rows", "spacing"}
local FIELD_SET = {}
for _, f in ipairs(Edit.FIELDS) do FIELD_SET[f] = true end

local FIELD_TOKENS = {color = "color.text.normal", spacing = "spacing.default", font = "font.normal"}
local FONT_SIZE_TOKEN = "font.size.normal"

local listeners = Core.NewCallbackList()
local pending, pendingOrder = {}, {}
local CLEAR = {}

-- Registry lookups -----------------------------------------------------------

local frameIndex, itemIndex

local function buildIndex()
  frameIndex, itemIndex = {}, {}
  local registry = Core.Registry
  local addons = type(registry) == "table" and registry.addons or {}
  for _, entry in pairs(addons) do
    for _, frame in ipairs(entry.frames or {}) do
      if frame.key then frameIndex[frame.key] = frame end
    end
    for _, item in ipairs(entry.editable or {}) do
      if item.frame and item.field then
        itemIndex[item.frame] = itemIndex[item.frame] or {}
        itemIndex[item.frame][item.field] = item
      end
    end
  end
end

local function registryItem(frameKey, field)
  if not itemIndex then buildIndex() end
  return itemIndex[frameKey] and itemIndex[frameKey][field]
end

local function registryFrame(frameKey)
  if not frameIndex then buildIndex() end
  return frameIndex[frameKey]
end

-- Validation -----------------------------------------------------------------

local function inRange(n, item)
  if item and type(item.min) == "number" and n < item.min then return false end
  if item and type(item.max) == "number" and n > item.max then return false end
  return true
end

local function optString(v) return v == nil or (type(v) == "string" and v ~= "") end

local validators = {
  position = function(v)
    return type(v) == "table" and type(v.point) == "string" and v.point ~= ""
      and optString(v.relativeTo) and optString(v.relativePoint)
      and type(v.x) == "number" and type(v.y) == "number"
  end,
  size = function(v, item)
    return type(v) == "table" and type(v.width) == "number" and type(v.height) == "number"
      and v.width > 0 and v.height > 0 and inRange(v.width, item) and inRange(v.height, item)
  end,
  font = function(v, item)
    if type(v) ~= "table" or (v.path == nil and v.size == nil and v.flags == nil) then return false end
    if v.size ~= nil and (type(v.size) ~= "number" or v.size <= 0 or not inRange(v.size, item)) then return false end
    return optString(v.path) and (v.flags == nil or type(v.flags) == "string")
  end,
  color = function(v)
    if type(v) ~= "table" then return false end
    for i = 1, 3 do
      if type(v[i]) ~= "number" or v[i] < 0 or v[i] > 1 then return false end
    end
    return v[4] == nil or (type(v[4]) == "number" and v[4] >= 0 and v[4] <= 1)
  end,
  rows = function(v, item)
    return type(v) == "number" and v >= 1 and floor(v) == v and inRange(v, item)
  end,
  spacing = function(v, item)
    return type(v) == "number" and v >= 0 and inRange(v, item)
  end,
}

-- True when `value` is a valid `field` value for `frameKey`.
function Edit:Validate(frameKey, field, value)
  if type(frameKey) ~= "string" or frameKey == "" then return false, "frameKey must be a non-empty string" end
  if not FIELD_SET[field] then return false, "unknown field" end
  if not validators[field](value, registryItem(frameKey, field)) then return false, "invalid " .. field .. " value" end
  return true
end

-- Store ----------------------------------------------------------------------

local function write(frameKey, field, value)
  local edits = Core:DBTable("edits")
  local stored = edits[frameKey]
  if value == nil then
    if type(stored) == "table" then
      stored[field] = nil
      if next(stored) == nil then edits[frameKey] = nil end
    end
  else
    if type(stored) ~= "table" then
      stored = {}
      edits[frameKey] = stored
    end
    stored[field] = Core.CopyTable(value)
  end
  listeners:Fire(frameKey, field, Core.CopyTable(value))
end

local function queue(frameKey, field, value)
  local byField = pending[frameKey]
  if not byField then
    byField = {}
    pending[frameKey] = byField
  end
  if byField[field] == nil then tinsert(pendingOrder, {frameKey, field}) end
  byField[field] = value == nil and CLEAR or Core.CopyTable(value)
end

local function change(frameKey, field, value)
  if not Core.ready then return false, "Core saved variables not loaded yet" end
  if Core.InCombat() then
    queue(frameKey, field, value)
    return true, "queued"
  end
  write(frameKey, field, value)
  return true, "applied"
end

-- Stores an edit value. Returns true, "applied" | "queued" or false, reason.
function Edit:Set(frameKey, field, value)
  local ok, reason = self:Validate(frameKey, field, value)
  if not ok then return false, reason end
  return change(frameKey, field, value)
end

-- Removes the edit value of `field`, or of every stored or waiting field when
-- `field` is nil ("unchanged" when there was none).
function Edit:Clear(frameKey, field)
  if type(frameKey) ~= "string" or frameKey == "" then return false, "frameKey must be a non-empty string" end
  if field ~= nil then
    if not FIELD_SET[field] then return false, "unknown field" end
    return change(frameKey, field, nil)
  end
  local stored = self:GetEdits(frameKey)
  local waiting = pending[frameKey] or {}
  local result = "unchanged"
  for _, f in ipairs(Edit.FIELDS) do
    if stored[f] ~= nil or waiting[f] ~= nil then
      local ok, how = change(frameKey, f, nil)
      if not ok then return false, how end
      result = how
    end
  end
  return true, result
end

-- Stored edit values of `frameKey` (copy), without tokens.
function Edit:GetEdits(frameKey)
  if not Core.ready then return {} end
  local stored = Core:DBTable("edits")[frameKey]
  return type(stored) == "table" and Core.CopyTable(stored) or {}
end

-- Edits waiting for the end of combat: list of {frameKey, field, value}.
function Edit:GetPending()
  local out = {}
  for _, pair in ipairs(pendingOrder) do
    local v = pending[pair[1]][pair[2]]
    out[#out + 1] = {frameKey = pair[1], field = pair[2], value = v ~= CLEAR and Core.CopyTable(v) or nil}
  end
  return out
end

-- Resolved values ------------------------------------------------------------

local function baseValue(frameKey, field)
  local frame = registryFrame(frameKey)
  local tokenName = frame and frame.tokens and frame.tokens[field] or FIELD_TOKENS[field]
  local value = tokenName and Core.Theme:Get(tokenName)
  if field == "font" then
    local font = {path = value, size = Core.Theme:Get(FONT_SIZE_TOKEN)}
    if font.path == nil and font.size == nil then return nil end
    return font
  end
  return value
end

local function overlay(field, low, high)
  if high == nil then return Core.CopyTable(low) end
  if field == "font" and type(low) == "table" and type(high) == "table" then
    local out = Core.CopyTable(low)
    for k, v in pairs(high) do out[k] = v end
    return out
  end
  return Core.CopyTable(high)
end

-- Resolved values of every field for `frameKey`: {[field] = value}; a field
-- with no token, default or edit is absent.
function Edit:Get(frameKey)
  local edits = self:GetEdits(frameKey)
  local out = {}
  for _, field in ipairs(Edit.FIELDS) do
    local value = baseValue(frameKey, field)
    local item = registryItem(frameKey, field)
    if item and item.default ~= nil then value = overlay(field, value, item.default) end
    value = overlay(field, value, edits[field])
    out[field] = value
  end
  return out
end

-- Registry editable items of `frameKey`: {[field] = item copy}.
function Edit:GetEditableItems(frameKey)
  if not itemIndex then buildIndex() end
  return Core.CopyTable(itemIndex[frameKey] or {})
end

-- fn(frameKey, field, storedValue); one function per owner.
function Edit:RegisterCallback(owner, fn) return listeners:Register(owner, fn) end
function Edit:UnregisterCallback(owner) return listeners:Unregister(owner) end

Core:On("PLAYER_REGEN_ENABLED", function()
  if #pendingOrder == 0 then return end
  local order, byFrame = pendingOrder, pending
  pending, pendingOrder = {}, {}
  for _, pair in ipairs(order) do
    local v = byFrame[pair[1]][pair[2]]
    write(pair[1], pair[2], v ~= CLEAR and v or nil)
  end
end)

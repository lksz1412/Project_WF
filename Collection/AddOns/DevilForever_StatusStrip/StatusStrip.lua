--[[ DevilForever_StatusStrip: one text strip with six light values.

Items, in fixed display order (key: text, how it is kept up to date):
  gold        "1,234g 05s 07c" / "5s 07c" / "7c"  PLAYER_MONEY
  bags        "Bags 23" (koKR "가방 23")          BAG_UPDATE_DELAYED, BAG_CONTAINER_UPDATE
              free slots of bags 0..NUM_BAG_SLOTS whose family is 0 (general bags)
  durability  "Dur 87%" (koKR "내구 87%")          UPDATE_INVENTORY_DURABILITY, PLAYER_EQUIPMENT_CHANGED
              lowest cur/max of the equipped slots that have durability
  clock       "09:05", or 12 h "9:05 PM" (koKR "오후 9:05")  1 s ticker, when the minute changes
              local PC time; also every 60th tick
  latency     "38/41 ms" (home/world)              1 s ticker, every 30th tick
  fps         "60 fps"                             1 s ticker, every tick
A value the client does not give shows "-". PLAYER_ENTERING_WORLD refreshes every
enabled item and queues one more refresh of the event items 5 s later.

Cost rules: one C_Timer ticker, alive only while a timed item (clock, latency,
fps) is on and the strip is shown; no OnUpdate script; an item that is off has
its events unregistered and calls no API; SetText only when the text changes.
Item events are registered under pcall; an error or a false return is a failure
and is kept in the status list that /dfstatus prints. Nothing is secure or protected: no Blizzard frame is
hooked, no CVar is written, the strip ignores the mouse.

Look: the addon sets no colour, texture or font of its own. Text uses the
client font object GameFontHighlightSmall until appearance code sets a font.
Built-in place: BOTTOMLEFT and BOTTOMRIGHT of UIParent, height 20, items
anchored left to right with spacing 12.

Public API (global table DevilForever_StatusStrip):
  .version = 1
  :GetFrame()                  -> the strip Frame (DevilForever_StatusStripFrame)
  :GetFontString(key)          -> FontString | nil
  :ListItems()                 -> {{key = string, enabled = boolean, shown = boolean}, ...}
                                  in display order (copy)
  :GetValue(key)               -> value | nil, text | nil
                                  gold copper, bags free slots, durability percent,
                                  clock "HH:MM" (24 h), fps frames per second;
                                  latency returns home, world, text
  :SetSpacing(px)              -> true | false, reason   (number >= 0; this session only)
                                  called from a LAYOUT callback: the new spacing is kept and
                                  the layout runs once more after the current run, not nested
  :IsItemEnabled(key)          -> boolean
  :SetItemEnabled(key, on)     -> true | false, reason   (stored in DevilForever_StatusStripDB)
  :SetClock24(on)              -> true | false, reason   (stored in DevilForever_StatusStripDB)
  :GetStatusLog()              -> copy of the status lines
  :RegisterCallback(owner, fn) -> true | false   fn("LAYOUT", shownKeys) after every layout
  :UnregisterCallback(owner)   -> true | false
  An error in one callback goes to the client error handler; the others still run.

Saved variable DevilForever_StatusStripDB (account):
  {schema = 1, items = {gold, bags, durability, clock, latency, fps = boolean}, clock24 = boolean}
  nil: defaults are written. Not a table, or schema above 1: defaults are used
  for this session and the stored value is left as it is. Otherwise missing keys
  are filled and every stored value and unknown key is kept. A flag that is not
  a boolean counts as its default and stays on disk as it is.

Slash command:
  /dfstatus                    item states, clock mode and status lines
  /dfstatus <item> on|off      switch one item
  /dfstatus clock 12|24        clock mode
]]

local ADDON_NAME = ...
local DB_NAME = "DevilForever_StatusStripDB"
local SCHEMA = 1
local TICK_SECONDS = 1
local LATENCY_EVERY_TICKS = 30
local CLOCK_FORCED_EVERY_TICKS = 60
local LATE_REFRESH_SECONDS = 5
local DEFAULT_SPACING = 12
local STRIP_HEIGHT = 20
local FALLBACK_SLOT_FIRST, FALLBACK_SLOT_LAST = 1, 18
local FALLBACK_BAG_FIRST, FALLBACK_BAG_LAST = 0, 4
local UNAVAILABLE = "-"

local floor = math.floor

local ITEM_ORDER = {"gold", "bags", "durability", "clock", "latency", "fps"}

local FONTSTRING_NAMES = {
  gold = "DevilForever_StatusStripGold",
  bags = "DevilForever_StatusStripBags",
  durability = "DevilForever_StatusStripDurability",
  clock = "DevilForever_StatusStripClock",
  latency = "DevilForever_StatusStripLatency",
  fps = "DevilForever_StatusStripFPS",
}

local TIMED_ITEMS = {clock = true, latency = true, fps = true}

local ITEM_EVENTS = {
  gold = {"PLAYER_MONEY"},
  bags = {"BAG_UPDATE_DELAYED", "BAG_CONTAINER_UPDATE"},
  durability = {"UPDATE_INVENTORY_DURABILITY", "PLAYER_EQUIPMENT_CHANGED"},
}

local DEFAULTS = {
  schema = SCHEMA,
  items = {gold = true, bags = true, durability = true, clock = true, latency = true, fps = true},
  clock24 = true,
}

local TEXTS = {
  koKR = {
    bags = "가방", durability = "내구", am = "오전", pm = "오후", amPmFirst = true,
    on = "켬", off = "끔", clock24 = "24시간", clock12 = "12시간", title = "DevilForever 상태 띠",
    usage = "사용법: /dfstatus · /dfstatus <항목> on|off · /dfstatus clock 12|24 (항목: gold bags durability clock latency fps)",
  },
  default = {
    bags = "Bags", durability = "Dur", am = "AM", pm = "PM", amPmFirst = false,
    on = "on", off = "off", clock24 = "24 h", clock12 = "12 h", title = "DevilForever status strip",
    usage = "Usage: /dfstatus · /dfstatus <item> on|off · /dfstatus clock 12|24 (items: gold bags durability clock latency fps)",
  },
}

local locale = type(GetLocale) == "function" and GetLocale() or nil
local L = TEXTS[locale] or TEXTS.default

-- Formatting -----------------------------------------------------------------

-- "1234567" -> "1,234,567" for a whole number >= 0.
local function groupDigits(number)
  local text = string.format("%d", number)
  local changed
  repeat
    text, changed = text:gsub("^(%d+)(%d%d%d)", "%1,%2")
  until changed == 0
  return text
end

local function formatMoney(copper)
  if type(copper) ~= "number" then return UNAVAILABLE end
  copper = floor(copper)
  local gold = floor(copper / 10000)
  local silver = floor((copper % 10000) / 100)
  local rest = copper % 100
  if gold > 0 then
    return string.format("%sg %02ds %02dc", groupDigits(gold), silver, rest)
  elseif silver > 0 then
    return string.format("%ds %02dc", silver, rest)
  end
  return string.format("%dc", rest)
end

local function formatCount(label, value)
  if value == nil then return label .. " " .. UNAVAILABLE end
  return string.format("%s %d", label, value)
end

local function formatDurability(percent)
  if percent == nil then return L.durability .. " " .. UNAVAILABLE end
  return string.format("%s %d%%", L.durability, percent)
end

local function formatClock(hour, minute, clock24)
  if clock24 then return string.format("%02d:%02d", hour, minute) end
  local half = hour < 12 and L.am or L.pm
  local shownHour = hour % 12
  if shownHour == 0 then shownHour = 12 end
  if L.amPmFirst then return string.format("%s %d:%02d", half, shownHour, minute) end
  return string.format("%d:%02d %s", shownHour, minute, half)
end

local function formatLatency(home, world)
  if home == nil or world == nil then return UNAVAILABLE .. " ms" end
  return string.format("%d/%d ms", home, world)
end

local function formatFPS(fps)
  if fps == nil then return UNAVAILABLE .. " fps" end
  return string.format("%d fps", fps)
end

-- Readers (one per item; each returns the value(s) or nil) -------------------

local function readMoney()
  local copper = type(GetMoney) == "function" and GetMoney() or nil
  return type(copper) == "number" and copper or nil
end

-- Lowest whole percent over the equipped slots that report max > 0.
local function readDurability()
  if type(GetInventoryItemDurability) ~= "function" then return nil end
  local first, last = FALLBACK_SLOT_FIRST, FALLBACK_SLOT_LAST
  if type(INVSLOT_FIRST_EQUIPPED) == "number" and type(INVSLOT_LAST_EQUIPPED) == "number" then
    first, last = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED
  end
  local lowest
  for slot = first, last do
    local current, maximum = GetInventoryItemDurability(slot)
    if type(current) == "number" and type(maximum) == "number" and maximum > 0 then
      local percent = floor(current * 100 / maximum)
      if lowest == nil or percent < lowest then lowest = percent end
    end
  end
  return lowest
end

-- Free slots in general bags (family 0; a client that gives no family counts
-- the bag as general).
local function readFreeBagSlots()
  local freeSlots = type(C_Container) == "table" and C_Container.GetContainerNumFreeSlots
  if type(freeSlots) ~= "function" then freeSlots = GetContainerNumFreeSlots end
  if type(freeSlots) ~= "function" then return nil end
  local first = type(BACKPACK_CONTAINER) == "number" and BACKPACK_CONTAINER or FALLBACK_BAG_FIRST
  local last = type(NUM_BAG_SLOTS) == "number" and NUM_BAG_SLOTS or FALLBACK_BAG_LAST
  local total = 0
  for bag = first, last do
    local free, family = freeSlots(bag)
    if type(free) == "number" and (family == nil or family == 0) then total = total + free end
  end
  return total
end

local function readClock()
  local hour, minute = tonumber(date("%H")), tonumber(date("%M"))
  if hour == nil or minute == nil then return nil end
  return hour, minute
end

local function readLatency()
  if type(GetNetStats) ~= "function" then return nil end
  local _, _, home, world = GetNetStats()
  if type(home) ~= "number" or type(world) ~= "number" then return nil end
  return floor(home), floor(world)
end

local function readFPS()
  local fps = type(GetFramerate) == "function" and GetFramerate() or nil
  return type(fps) == "number" and floor(fps) or nil
end

-- State ----------------------------------------------------------------------

local db              -- table the settings are read from and written to
local sessionItems    -- item flags of this session when db.items is not a table
local statusLog = {}
local statusSeen = {}
local values = {}     -- key -> {value..., text}; one table per item, reused
local lastText = {}   -- key -> text last given to SetText
local registeredEvents = {}
local ticker
local tickCount = 0
local lastClockMinute
local lateRefreshPending = false
local stripVisible = true
local spacing = DEFAULT_SPACING

local function note(line)
  if statusSeen[line] then return end
  statusSeen[line] = true
  statusLog[#statusLog + 1] = line
end

local function copyTable(source)
  local out = {}
  for k, v in pairs(source) do
    out[k] = type(v) == "table" and copyTable(v) or v
  end
  return out
end

-- Fills keys that are nil in `target` from `source`, recursing where both hold
-- tables; never replaces a stored value.
local function fillMissing(target, source)
  for k, v in pairs(source) do
    local current = rawget(target, k)
    if current == nil then
      rawset(target, k, type(v) == "table" and copyTable(v) or v)
    elseif type(v) == "table" and type(current) == "table" then
      fillMissing(current, v)
    end
  end
end

local function itemFlags()
  local settings = db or DEFAULTS
  if type(settings.items) == "table" then return settings.items end
  sessionItems = sessionItems or copyTable(DEFAULTS.items)
  return sessionItems
end

local function isEnabled(key)
  local flag = itemFlags()[key]
  if type(flag) == "boolean" then return flag end
  return DEFAULTS.items[key]
end

local function isClock24()
  local flag = (db or DEFAULTS).clock24
  if type(flag) == "boolean" then return flag end
  return DEFAULTS.clock24
end

-- Frames -----------------------------------------------------------------------

local strip = CreateFrame("Frame", "DevilForever_StatusStripFrame", UIParent)
strip:SetFrameStrata("LOW")
strip:EnableMouse(false)
strip:SetHeight(STRIP_HEIGHT)
strip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
strip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)

local fontStrings = {}
for _, key in ipairs(ITEM_ORDER) do
  fontStrings[key] = strip:CreateFontString(FONTSTRING_NAMES[key], "OVERLAY", "GameFontHighlightSmall")
end

-- Writes up to three values into the item's own table (created once per item).
local function store(key, first, second, third)
  local slot = values[key]
  if not slot then
    slot = {}
    values[key] = slot
  end
  slot[1], slot[2], slot[3] = first, second, third
end

local function show(key, text)
  if lastText[key] ~= text then
    lastText[key] = text
    fontStrings[key]:SetText(text)
  end
end

-- Refresh (one per item) ---------------------------------------------------------

local refresh = {}

function refresh.gold()
  local copper = readMoney()
  local text = formatMoney(copper)
  store("gold", copper, text)
  show("gold", text)
end

function refresh.bags()
  local free = readFreeBagSlots()
  local text = formatCount(L.bags, free)
  store("bags", free, text)
  show("bags", text)
end

function refresh.durability()
  local percent = readDurability()
  local text = formatDurability(percent)
  store("durability", percent, text)
  show("durability", text)
end

function refresh.clock(minute)
  lastClockMinute = minute or floor(time() / 60)
  local hour, min = readClock()
  local text = hour and formatClock(hour, min, isClock24()) or UNAVAILABLE
  store("clock", hour and string.format("%02d:%02d", hour, min) or nil, text)
  show("clock", text)
end

function refresh.latency()
  local home, world = readLatency()
  local text = formatLatency(home, world)
  store("latency", home, world, text)
  show("latency", text)
end

-- Formats only when the whole-number fps differs from the stored one.
function refresh.fps()
  local fps = readFPS()
  local slot = values.fps
  if slot and slot[1] == fps then return end
  local text = formatFPS(fps)
  store("fps", fps, text)
  show("fps", text)
end

local function refreshAll()
  for _, key in ipairs(ITEM_ORDER) do
    if isEnabled(key) then refresh[key]() end
  end
end

local function refreshEventItems()
  for _, key in ipairs(ITEM_ORDER) do
    if ITEM_EVENTS[key] and isEnabled(key) then refresh[key]() end
  end
end

-- Callbacks --------------------------------------------------------------------

local callbackOrder, callbackFns = {}, {}

local function reportError(err)
  local handler = type(geterrorhandler) == "function" and geterrorhandler()
  if handler then handler(err) end
end

local function fireCallbacks(...)
  local owners = {}
  for i, owner in ipairs(callbackOrder) do owners[i] = owner end
  for _, owner in ipairs(owners) do
    local fn = callbackFns[owner]
    if fn then
      local ok, err = pcall(fn, ...)
      if not ok then reportError(err) end
    end
  end
end

-- Layout -------------------------------------------------------------------------

local function anchorShownItems()
  local previous
  local shownKeys = {}
  for _, key in ipairs(ITEM_ORDER) do
    local fontString = fontStrings[key]
    if isEnabled(key) then
      fontString:ClearAllPoints()
      if previous then
        fontString:SetPoint("LEFT", previous, "RIGHT", spacing, 0)
      else
        fontString:SetPoint("LEFT", strip, "LEFT", spacing, 0)
      end
      fontString:Show()
      previous = fontString
      shownKeys[#shownKeys + 1] = key
    else
      fontString:Hide()
    end
  end
  return shownKeys
end

-- A layout asked for from inside a LAYOUT callback is not nested: it is noted
-- and runs once after the current run. Requests during that second run are
-- dropped, so a callback that always asks cannot loop.
local layoutRunning = false
local layoutRequested = false

local function runLayout()
  if layoutRunning then
    layoutRequested = true
    return
  end
  layoutRunning = true
  layoutRequested = false
  fireCallbacks("LAYOUT", anchorShownItems())
  if layoutRequested then
    layoutRequested = false
    fireCallbacks("LAYOUT", anchorShownItems())
  end
  layoutRequested = false
  layoutRunning = false
end

-- Ticker -------------------------------------------------------------------------

local function onTick()
  tickCount = tickCount + 1
  if isEnabled("fps") then refresh.fps() end
  if isEnabled("latency") and tickCount % LATENCY_EVERY_TICKS == 0 then refresh.latency() end
  if isEnabled("clock") then
    local minute = floor(time() / 60)
    if minute ~= lastClockMinute or tickCount % CLOCK_FORCED_EVERY_TICKS == 0 then refresh.clock(minute) end
  end
end

local function anyTimedItemEnabled()
  for key in pairs(TIMED_ITEMS) do
    if isEnabled(key) then return true end
  end
  return false
end

local function updateTicker()
  local wanted = db ~= nil and stripVisible and anyTimedItemEnabled()
  if wanted and not ticker then
    if type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function" then
      ticker = C_Timer.NewTicker(TICK_SECONDS, onTick)
    else
      note("C_Timer.NewTicker missing: clock, latency and fps refresh at login only")
    end
  elseif not wanted and ticker then
    ticker:Cancel()
    ticker = nil
  end
end

strip:SetScript("OnHide", function()
  stripVisible = false
  updateTicker()
end)
strip:SetScript("OnShow", function()
  stripVisible = true
  updateTicker()
end)

-- Events -------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")

local function updateEvents()
  local needed = {}
  for key, events in pairs(ITEM_EVENTS) do
    if isEnabled(key) then
      for _, event in ipairs(events) do needed[event] = true end
    end
  end
  for _, events in pairs(ITEM_EVENTS) do
    for _, event in ipairs(events) do
      if needed[event] and not registeredEvents[event] then
        local ok, result = pcall(eventFrame.RegisterEvent, eventFrame, event)
        if ok and result ~= false then
          registeredEvents[event] = true
        else
          note("event " .. event .. " not registered: " .. (ok and "RegisterEvent returned false" or tostring(result)))
        end
      elseif not needed[event] and registeredEvents[event] then
        eventFrame:UnregisterEvent(event)
        registeredEvents[event] = nil
      end
    end
  end
end

local function forget(key)
  values[key] = nil
  lastText[key] = nil
end

local function loadSettings()
  local stored = _G[DB_NAME]
  if stored == nil then
    db = copyTable(DEFAULTS)
    _G[DB_NAME] = db
  elseif type(stored) ~= "table" then
    db = copyTable(DEFAULTS)
    note(DB_NAME .. " is not a table: defaults used this session, stored value kept")
  elseif type(stored.schema) == "number" and stored.schema > SCHEMA then
    db = copyTable(DEFAULTS)
    note(DB_NAME .. " schema " .. stored.schema .. " is unknown: defaults used this session, stored value kept")
  else
    fillMissing(stored, DEFAULTS)
    db = stored
    if type(db.items) ~= "table" then
      note(DB_NAME .. ".items is not a table: item defaults used this session, stored value kept")
    end
  end
end

local function applySettings()
  runLayout()
  updateEvents()
  updateTicker()
end

local EVENT_ITEMS = {}
for key, events in pairs(ITEM_EVENTS) do
  for _, event in ipairs(events) do EVENT_ITEMS[event] = key end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 == ADDON_NAME then
      self:UnregisterEvent("ADDON_LOADED")
      loadSettings()
      applySettings()
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    if not db then return end
    refreshAll()
    if not lateRefreshPending and type(C_Timer) == "table" and type(C_Timer.After) == "function" then
      lateRefreshPending = true
      C_Timer.After(LATE_REFRESH_SECONDS, function()
        lateRefreshPending = false
        refreshEventItems()
      end)
    end
  else
    local key = EVENT_ITEMS[event]
    if key and db and isEnabled(key) then refresh[key]() end
  end
end)

-- Public API -----------------------------------------------------------------------

local StatusStrip = {version = 1}
DevilForever_StatusStrip = StatusStrip

local function validKey(key)
  return type(key) == "string" and FONTSTRING_NAMES[key] ~= nil
end

function StatusStrip:GetFrame()
  return strip
end

function StatusStrip:GetFontString(key)
  if not validKey(key) then return nil end
  return fontStrings[key]
end

function StatusStrip:ListItems()
  local list = {}
  for i, key in ipairs(ITEM_ORDER) do
    list[i] = {key = key, enabled = isEnabled(key), shown = fontStrings[key]:IsShown() and true or false}
  end
  return list
end

function StatusStrip:GetValue(key)
  if not validKey(key) or not values[key] then return nil end
  local stored = values[key]
  if key == "latency" then return stored[1], stored[2], stored[3] end
  return stored[1], stored[2]
end

function StatusStrip:SetSpacing(px)
  if type(px) ~= "number" or px ~= px or px < 0 or px == math.huge then
    return false, "spacing must be a number >= 0"
  end
  spacing = px
  runLayout()
  return true
end

function StatusStrip:IsItemEnabled(key)
  if not validKey(key) then return false end
  return isEnabled(key)
end

function StatusStrip:SetItemEnabled(key, on)
  if not validKey(key) then return false, "unknown item" end
  if type(on) ~= "boolean" then return false, "on must be a boolean" end
  if not db then return false, "settings not loaded yet" end
  itemFlags()[key] = on
  if on then
    runLayout()
    updateEvents()
    updateTicker()
    refresh[key]()
  else
    forget(key)
    applySettings()
  end
  return true
end

function StatusStrip:SetClock24(on)
  if type(on) ~= "boolean" then return false, "on must be a boolean" end
  if not db then return false, "settings not loaded yet" end
  db.clock24 = on
  if isEnabled("clock") then refresh.clock() end
  return true
end

function StatusStrip:GetStatusLog()
  local copy = {}
  for i, line in ipairs(statusLog) do copy[i] = line end
  return copy
end

function StatusStrip:RegisterCallback(owner, fn)
  if owner == nil or type(fn) ~= "function" then return false end
  if callbackFns[owner] == nil then callbackOrder[#callbackOrder + 1] = owner end
  callbackFns[owner] = fn
  return true
end

function StatusStrip:UnregisterCallback(owner)
  if owner == nil or callbackFns[owner] == nil then return false end
  callbackFns[owner] = nil
  for i, o in ipairs(callbackOrder) do
    if o == owner then
      table.remove(callbackOrder, i)
      break
    end
  end
  return true
end

-- Slash command ----------------------------------------------------------------------

local function printStatus()
  local parts = {}
  for _, key in ipairs(ITEM_ORDER) do
    parts[#parts + 1] = key .. "=" .. (isEnabled(key) and L.on or L.off)
  end
  print(L.title .. ": " .. table.concat(parts, " ") .. " clock=" .. (isClock24() and L.clock24 or L.clock12))
  for _, line in ipairs(statusLog) do print(L.title .. ": " .. line) end
end

SLASH_DEVILFOREVERSTATUS1 = "/dfstatus"
SlashCmdList.DEVILFOREVERSTATUS = function(message)
  local text = string.lower(type(message) == "string" and message or ""):match("^%s*(.-)%s*$")
  if text == "" then
    printStatus()
    return
  end
  local first, second = text:match("^(%S+)%s+(%S+)$")
  if first == "clock" and (second == "12" or second == "24") then
    local ok = StatusStrip:SetClock24(second == "24")
    if ok then printStatus() else print(L.usage) end
    return
  end
  if validKey(first) and (second == "on" or second == "off") then
    local ok = StatusStrip:SetItemEnabled(first, second == "on")
    if ok then printStatus() else print(L.usage) end
    return
  end
  print(L.usage)
end

runLayout()

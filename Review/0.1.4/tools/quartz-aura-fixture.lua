local modules, subscriptions, oneShots, repeaters, reads = {}, {}, {}, {}, {}
local setup, locale, media, ace = {}, {}, {}, {}
local db = {}
local M = {}
function M:SetEnabledState(v) self.enabledState = v end
function M:IsEnabled() return self.live end
function M:RegisterEvent(event, method) subscriptions[event] = method end
function M:RegisterUnitEvent(event, method) self:RegisterEvent(event, method or event) end
function M:UnregisterAllEvents() subscriptions = {} end
function M:ScheduleTimer(method, delay)
  oneShots[#oneShots + 1] = {method, delay}
end
function M:ScheduleRepeatingTimer(method, delay)
  repeaters[#repeaters + 1] = {method, delay}
  return #repeaters
end
function M:CancelAllTimers() oneShots, repeaters = {}, {} end

function setup:NewModule(name)
  local m = setmetatable({live = false}, {__index = M})
  modules[name] = m
  return m
end
function setup:GetModule(name) return assert(modules[name], name) end
function setup:IterateModules() return pairs(modules) end
function setup:EnableModule(name)
  local m = modules[name]
  m.live = true
  if m.OnEnable then m:OnEnable() end
end
function setup:DisableModule(name)
  local m = modules[name]
  m.live = false
  if m.OnDisable then m:OnDisable() end
end
function setup:SetupOptions() end
function setup:RegisterModuleOptions() end
function locale:GetLocale() return setmetatable({}, {__index = function(_, key) return key end}) end
function media:Register() end
function media.RegisterCallback() end
function media.UnregisterCallback() end
function ace:NewAddon() return setup end
function ace:GetAddon() return setup end
function db:New(_, defaults)
  return {
    profile = defaults.profile,
    RegisterNamespace = function(_, _, baseline) return {profile = baseline.profile} end
  }
end
function LibStub(name)
  local libs = {["AceLocale-3.0"]=locale, ["AceAddon-3.0"]=ace, ["AceDB-3.0"]=db, ["LibSharedMedia-3.0"]=media}
  return assert(libs[name], name)
end
for _, name in ipairs({"Player", "Target", "Focus", "Pet"}) do setup:NewModule(name) end
function init(on)
  setup:OnInitialize()
  local values = setup.db.profile.modules
  setmetatable(values, {__index = function(t) return rawget(t, "*") end})
  assert(setup:GetModuleEnabled("Buff") == true)
  if not on then values.Buff = false end
  local buff = setup:GetModule("Buff")
  buff:OnInitialize()
  for i=1,60 do
    local name, bucket = debug.getupvalue(buff.OnEnable, i)
    if name == "containers" then
      for _, unit in ipairs({"target", "focus"}) do
        bucket[unit] = {
          UpdateAllAuras = function() reads[unit] = (reads[unit] or 0) + 1 end,
          SetEnabled = function() end, Hide = function() end
        }
      end
      break
    end
  end
  buff.ApplySettings = function() end
  setup:ApplySettings()
  local listenerCount = 0
  for _ in pairs(subscriptions) do listenerCount = listenerCount + 1 end
  reads = {}
  for _, r in ipairs(repeaters) do
    for _=1,math.floor(30/r[2]) do buff[r[1]](buff) end
  end
  local idleTarget, idleFocus = reads.target or 0, reads.focus or 0
  if subscriptions.UNIT_AURA then
    for _=1,12 do buff:UNIT_AURA("UNIT_AURA","target") end
    for _=1,5 do buff:UNIT_AURA("UNIT_AURA","focus") end
  end
  if subscriptions.UNIT_SPELLCAST_STOP then
    buff:CastStopped()
    for _, r in ipairs(oneShots) do buff[r[1]](buff) end
  end
  local castModules = 0
  for _, name in ipairs({"Player", "Target", "Focus", "Pet"}) do
    if setup:GetModule(name):IsEnabled() then castModules = castModules + 1 end
  end
  local info = {events=listenerCount, periodicTimers=#repeaters, castModulesEnabled=castModules,
      idleTarget=idleTarget, idleFocus=idleFocus, targetTotal=reads.target or 0, focusTotal=reads.focus or 0}
  if on then
    setup:SetModuleEnabled("Buff", false)
    assert(next(subscriptions) == nil and #oneShots == 0 and #repeaters == 0)
    info.timersAfterDisable = #repeaters
  end
  return info
end

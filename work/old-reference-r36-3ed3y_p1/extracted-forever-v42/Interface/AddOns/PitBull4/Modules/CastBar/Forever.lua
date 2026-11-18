local PitBull4 = _G.PitBull4
if not PitBull4.Compat.IsForever or not UnitCastingDuration or not UnitChannelDuration then return end

local module = PitBull4:GetModule("CastBar")
local readable = PitBull4.Compat.IsValueAccessible
local updateFrame = module.UpdateFrame
local unpack = unpack or table.unpack
local function unitForFrame(frame)
    return frame.unit or frame.best_unit
end

-- No GUID/spell-name keys and no arithmetic on live cast timing.
local function getCast(unit)
    if not unit then return end
    local name, _, icon, _, _, _, _, shielded = UnitCastingInfo(unit)
    local channeling, empowered = false, false
    if type(name) == "nil" then
        name, _, icon, _, _, _, shielded, _, empowered = UnitChannelInfo(unit)
        channeling = true
    end
    if type(name) == "nil" then return end
    empowered = readable(empowered) and empowered == true
    local duration
    if channeling and empowered and UnitEmpoweredChannelDuration then
        duration = UnitEmpoweredChannelDuration(unit, true)
    elseif channeling then
        duration = UnitChannelDuration(unit)
    else
        duration = UnitCastingDuration(unit)
    end
    if type(duration) == "nil" then return end
    return { name = name, icon = icon, shielded = shielded,
        channeling = channeling and not empowered, duration = duration }
end

function module:OnEnable()
    for _, event in ipairs({"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_DELAYED",
        "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTIBLE",
        "UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_UPDATE",
        "UNIT_SPELLCAST_EMPOWER_STOP"}) do
        PitBull4.Compat.RegisterOptionalEvent(self, event, "ForeverCastEvent")
    end
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAll")
    self.foreverTicker = C_Timer.NewTicker(0.15, function() self:UpdateAll() end)
    self:UpdateAll()
end
function module:OnDisable()
    if self.foreverTicker then self.foreverTicker:Cancel(); self.foreverTicker = nil end
end
function module:ForeverCastEvent(_, unit)
    if readable(unit) and type(unit) == "string" then self:UpdateForUnitID(unit) end
end
function module:GetRawValue(frame)
    local data = getCast(unitForFrame(frame))
    frame.forever_cast = data
    local db = self:GetLayoutDB(frame)
    if not data and db.auto_hide then return end
    local icon = data and db.show_icon and readable(data.icon) and data.icon or nil
    return 0, 1, icon
end
function module:GetValue(frame)
    if not frame.forever_cast and self:GetLayoutDB(frame).auto_hide then return end
    return 0
end
function module:GetColor(frame)
    if frame.force_show or PitBull4:IsInConfigMode() then return self:GetExampleColor(frame) end
    local data = frame.forever_cast
    if not data then return 0, 0, 0, 0 end
    local key = data.channeling and "channel_" or "casting_"
    key = key .. ((readable(data.shielded) and data.shielded) and "uninterruptible_color" or "interruptible_color")
    local r, g, b = unpack(self.db.profile.global[key])
    return r, g, b, 1
end
function module:GetBackgroundColor(frame)
    if not frame.forever_cast and not self:GetLayoutDB(frame).idle_background then
        return nil, nil, nil, 0
    end
end
function module:UpdateFrame(frame)
    local changed = updateFrame(self, frame)
    local bar = frame.CastBar
    if bar and frame.forever_cast and not frame.force_show and not PitBull4:IsInConfigMode() then
        bar:SetDurationValue(frame.forever_cast.duration, frame.forever_cast.channeling)
    end
    return changed
end

-- Used by the text provider to send cast names/times directly to FontString.
module.GetForeverCast = getCast

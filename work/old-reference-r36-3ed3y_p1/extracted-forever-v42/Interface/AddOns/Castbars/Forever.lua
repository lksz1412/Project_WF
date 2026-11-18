-- Castbars Forever backend. Keep Castbars.lua as the original source/reference.
-- Restricted cast values go directly to Blizzard widgets/duration objects.
local Castbars = LibStub("AceAddon-3.0"):NewAddon("Castbars", "AceConsole-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
Castbars.SharedMedia = LSM
local unpack = unpack or table.unpack
local configs = { "CastingBarFrame", "PetCastingBarFrame", "TargetCastingBarFrame", "FocusCastingBarFrame" }
local units = { "player", "pet", "target", "focus" }
local titles = { "Player/Vehicle", "Pet", "Target", "Focus" }
local tickSeconds = { [689]=1, [755]=1, [740]=2, [47540]=1, [15407]=1, [48045]=1, [64843]=2, [5143]=0.4, [12051]=2 }

local function readable(value)
    return not issecretvalue or not issecretvalue(value)
end

local function present(value)
    return not readable(value) or value ~= nil
end

local function getFont(config)
    local font = LSM:Fetch("font", config.Font, true)
    if type(font) ~= "string" or not font:find("%S") then
        font = GameFontNormal:GetFont()
    end
    return font
end

local function clearMirror(frame)
    frame.mirrorType, frame.mirrorMaximum, frame.mirrorScale, frame.mirrorPaused = nil, nil, nil, nil
    frame.tmr:SetText("")
    frame:Hide()
end

local function updateTimer(frame)
    local cfg = Castbars.db.profile[frame.configName]
    if frame.preview then
        frame.tmr:SetText("1.5 / 3.0")
    elseif frame.useDuration then
        local decimals = math.max(0, math.min(2, cfg.TotalCastTimeDecimals or 1))
        local fmt = "%." .. decimals .. "f"
        if cfg.ShowPushback and frame.pushback and frame.pushback > 0 and cfg.ShowTotalCastTime then
            frame.tmr:SetFormattedText("+%.1f " .. fmt .. " / " .. fmt,
                frame.pushback, frame.duration:GetRemainingDuration(), frame.duration:GetTotalDuration())
        elseif cfg.ShowPushback and frame.pushback and frame.pushback > 0 then
            frame.tmr:SetFormattedText("+%.1f " .. fmt, frame.pushback, frame.duration:GetRemainingDuration())
        elseif cfg.ShowTotalCastTime then
            frame.tmr:SetFormattedText(fmt .. " / " .. fmt, frame.duration:GetRemainingDuration(), frame.duration:GetTotalDuration())
        else
            frame.tmr:SetFormattedText(fmt, frame.duration:GetRemainingDuration())
        end
    elseif frame.mirrorType then
        local progress = GetMirrorTimerProgress(frame.mirrorType)
        if not readable(progress) then return end
        -- Inactive timers may return nil or a negative value. A replenishing
        -- timer is also finished once full, even if no STOP event arrives.
        if type(progress) ~= "number" or progress < 0
            or (not frame.mirrorPaused and frame.mirrorScale > 0 and progress >= frame.mirrorMaximum) then
            clearMirror(frame)
            return
        end
        frame:SetValue(progress)
        frame.tmr:SetFormattedText("%.1f", progress / 1000)
    end
end

local function updateGCD(frame)
    if not frame.gcd then return end
    local cfg = Castbars.db.profile.CastingBarFrame
    if not cfg.Show or not cfg.ShowCooldownSpark or not C_Spell or not C_Spell.GetSpellCooldownDuration then
        frame.gcd:Hide()
        return
    end
    local duration = C_Spell.GetSpellCooldownDuration(61304)
    if readable(duration) and duration == nil then frame.gcd:Hide(); return end
    frame.gcd:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, Enum.StatusBarTimerDirection.ElapsedTime)
    frame.gcd:SetAlphaFromBoolean(duration:IsZero(), 0, cfg.Alpha)
    frame.gcd:Show()
end

local function clearTicks(frame)
    for _, tick in ipairs(frame.ticks) do tick:Hide() end
end

local function updateTicks(frame, spellID)
    clearTicks(frame)
    if frame.unit ~= "player" or not frame.channel or not readable(spellID) then return end
    local interval = tickSeconds[spellID]
    local total = frame.duration:GetTotalDuration()
    if not interval or not readable(total) or total <= 0 then return end
    -- Haste can be secret even while the spell ID and duration are public.
    -- Only optional tick marks need it; the duration-driven bar must still run.
    local haste = GetHaste()
    if not readable(haste) or type(haste) ~= "number" then return end
    interval = interval / (1 + haste / 100)
    if interval <= 0 or interval == math.huge then return end
    local count = math.min(30, math.floor(total / interval) - 1)
    for i = 1, count do
        local tick = frame.ticks[i]
        if not tick then
            tick = frame:CreateTexture(nil, "OVERLAY")
            tick:SetColorTexture(1, 1, 1, 0.55)
            frame.ticks[i] = tick
        end
        tick:ClearAllPoints()
        tick:SetPoint("CENTER", frame, "LEFT", frame:GetWidth() * i * interval / total, 0)
        tick:SetSize(1, frame:GetHeight())
        tick:Show()
    end
end

local function updateLatency(frame)
    frame.latency:Hide()
    if frame.unit ~= "player" or frame.channel or not frame.useDuration then return end
    local cfg = Castbars.db.profile[frame.configName]
    if not cfg.ShowLatency then return end
    local total = frame.duration:GetTotalDuration()
    if not readable(total) or total <= 0 then return end
    local _, _, _, latency = GetNetStats()
    local queue = tonumber(C_CVar.GetCVar("SpellQueueWindow")) or 0
    local width = frame:GetWidth() * math.min(1, ((latency or 0) + queue) / 1000 / total)
    frame.latency:SetWidth(math.max(0.1, width))
    frame.latency:Show()
end

local function refreshCast(frame)
    if frame.preview then return end
    local cfg = Castbars.db.profile[frame.configName]
    if not cfg.Show then frame:Hide(); return end
    local name, _, icon, startTime, endTime, _, _, shielded, spellID, _, delayTimeMs = UnitCastingInfo(frame.unit)
    frame.pushback = readable(delayTimeMs) and delayTimeMs and delayTimeMs / 1000 or 0
    local channel, empowered = false, false
    if not present(name) then
        name, _, icon, startTime, endTime, _, shielded, spellID, empowered = UnitChannelInfo(frame.unit)
        channel = true
        frame.pushback = 0
    end
    if not present(name) then
        frame.useDuration = false
        frame:Hide()
        return
    end
    -- Blacklists are meaningful only when the API exposes the spell identity.
    if frame.unit == "player" and readable(name) and readable(spellID) then
        local blacklist = cfg.Blacklist
        if blacklist and (blacklist[name] or blacklist[spellID]) then
            frame.useDuration = false
            frame:Hide()
            return
        end
    end
    local duration
    if channel and empowered and UnitEmpoweredChannelDuration then
        duration = UnitEmpoweredChannelDuration(frame.unit, true)
    elseif channel and UnitChannelDuration then
        duration = UnitChannelDuration(frame.unit)
    elseif not channel and UnitCastingDuration then
        duration = UnitCastingDuration(frame.unit)
    elseif readable(startTime) and readable(endTime) and startTime and endTime and C_DurationUtil then
        duration = C_DurationUtil.CreateDuration()
        duration:SetTimeSpan(startTime / 1000, endTime / 1000)
    end
    if readable(duration) and duration == nil then
        frame.useDuration = false
        frame:Hide()
        return
    end
    frame.duration, frame.useDuration, frame.channel = duration, true, channel
    frame:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate,
        channel and not empowered and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime)
    frame.text:SetText(name)
    frame.icon:SetTexture(icon)
    frame.targetText:SetText("")
    if frame.unit == "player" and cfg.ShowSpellTarget and present(frame.sentTarget) then
        frame.targetText:SetText(frame.sentTarget)
    end
    local color = channel and cfg.BarColorChanneling or cfg.BarColor
    if readable(shielded) and shielded then color = cfg.BarColorShielded end
    frame:SetStatusBarColor(unpack(color))
    frame.shield:SetShown(cfg.ShowShield and true or false)
    if frame.shield.SetAlphaFromBoolean and present(shielded) then
        frame.shield:SetAlphaFromBoolean(shielded, 1, 0)
    else
        frame.shield:SetAlpha(readable(shielded) and shielded and 1 or 0)
    end
    updateTicks(frame, spellID)
    updateLatency(frame)
    frame:SetAlpha(cfg.Alpha)
    updateTimer(frame)
    frame:Show()
end

local function createBar(name, configName, friendlyName)
    local frame = CreateFrame("StatusBar", name, UIParent)
    frame.configName, frame.friendlyName, frame.ticks = configName, friendlyName, {}
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:EnableMouse(false)
    frame.backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.backdrop:SetAllPoints()
    frame.shade = frame:CreateTexture(nil, "BACKGROUND")
    frame.shade:SetAllPoints()
    frame.shade:SetColorTexture(0, 0, 0, 0.5)
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame.shield = frame:CreateTexture(nil, "OVERLAY")
    frame.shield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield")
    frame.shield:SetPoint("CENTER", frame.icon)
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.tmr = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.targetText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.latency = frame:CreateTexture(nil, "OVERLAY")
    frame.latency:SetColorTexture(1, 0.15, 0.15, 0.35)
    frame.latency:SetPoint("TOPRIGHT")
    frame.latency:SetPoint("BOTTOMRIGHT")
    frame.latency:Hide()
    if configName == "CastingBarFrame" then
        frame.gcd = CreateFrame("StatusBar", "CastbarsForeverGCD", UIParent)
        frame.gcd:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        frame.gcd:SetStatusBarColor(0.2, 1, 0.2, 0.8)
        frame.gcd:Hide()
    end
    frame:SetScript("OnDragStart", function(self)
        if Castbars.ConfigMode then self:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relpoint, x, y = self:GetPoint()
        local cfg = Castbars.db.profile[self.configName]
        Castbars.db.profile[self.configName].Position = {
            point=point, relpoint=relpoint, x=x, y=y + (self.mirrorIndex or 0) * (cfg.Height + 10)
        }
        Castbars:FrameLayoutRestoreAll()
    end)
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed < 0.05 then return end
        self.elapsed = 0
        updateTimer(self)
    end)
    frame:Hide()
    return frame
end

function Castbars:FrameMediaRestore(frame)
    local cfg = self.db.profile[frame.configName]
    frame:SetStatusBarTexture(LSM:Fetch("statusbar", cfg.Texture) or "Interface\\TargetingFrame\\UI-StatusBar")
    local border = cfg.Border ~= "None" and LSM:Fetch("border", cfg.Border, true)
    if border and border ~= "" then
        local edge = math.max(0.1, math.min(16, (cfg.Height - 2) / 1.5) + cfg.BorderWidthAdjustment)
        frame.backdrop:SetBackdrop({edgeFile=border, edgeSize=edge})
        frame.backdrop:SetBackdropBorderColor(unpack(cfg.BorderColor))
    else
        frame.backdrop:SetBackdrop(nil)
    end
    for _, text in ipairs({frame.text, frame.tmr, frame.targetText}) do
        text:SetFont(getFont(cfg), cfg.FontSize, cfg.FontOutline and "OUTLINE" or "")
    end
end

function Castbars:FrameLayoutRestore(frame)
    local cfg = self.db.profile[frame.configName]
    self:FrameMediaRestore(frame)
    frame:SetSize(cfg.Width, cfg.Height)
    local offset = cfg.BorderOffsetAdjustment or 0
    frame.backdrop:ClearAllPoints()
    frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -offset, offset)
    frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offset, -offset)
    frame:SetAlpha(cfg.Alpha)
    local pos = cfg.Position
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relpoint, pos.x or 0, (pos.y or 0) - (frame.mirrorIndex or 0) * (cfg.Height + 10))
    frame.icon:ClearAllPoints()
    frame.icon:SetSize(cfg.Height, cfg.Height)
    frame.icon:SetPoint(cfg.IconAlignment == "RIGHT" and "LEFT" or "RIGHT", frame,
        cfg.IconAlignment == "RIGHT" and "RIGHT" or "LEFT", cfg.IconAlignment == "RIGHT" and 4 or -4, 0)
    frame.icon:SetShown(cfg.ShowIcon and true or false)
    frame.shield:SetSize(cfg.Height * 1.8, cfg.Height * 2.2)
    frame.text:ClearAllPoints()
    frame.text:SetPoint("LEFT", 3, 0)
    frame.text:SetPoint("RIGHT", -48, 0)
    frame.text:SetJustifyH(cfg.TextAlignment)
    frame.text:SetShown(cfg.ShowSpellName)
    frame.tmr:ClearAllPoints()
    frame.tmr:SetPoint("RIGHT", -3, 0)
    frame.targetText:ClearAllPoints()
    frame.targetText:SetPoint("BOTTOM", frame, "TOP", 0, 2)
    frame.targetText:SetShown(cfg.ShowSpellTarget and true or false)
    if frame.gcd then
        frame.gcd:SetSize(cfg.Width, 2)
        frame.gcd:ClearAllPoints()
        frame.gcd:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
        updateGCD(frame)
    end
    if frame.unit then refreshCast(frame) end
end

function Castbars:FrameLayoutRestoreAll()
    if not self.frames then return end
    if InCombatLockdown() then self.pendingLayout = true; return end
    for _, frame in ipairs(self.frames) do self:FrameLayoutRestore(frame) end
    self:UpdateNativeBars()
end

function Castbars:FrameMediaRestoreAll()
    self:FrameLayoutRestoreAll()
end

function Castbars:UpdateNativeBars()
    -- Keep Blizzard's native event handlers registered; only suppress duplicate art.
    local natives = {
        {PlayerCastingBarFrame or CastingBarFrame, "CastingBarFrame"},
        {PetCastingBarFrame, "PetCastingBarFrame"},
        {TargetFrameSpellBar, "TargetCastingBarFrame"},
        {FocusFrameSpellBar, "FocusCastingBarFrame"},
    }
    for _, entry in ipairs(natives) do
        local frame, key = entry[1], entry[2]
        if frame then
            local hidden = self.db.profile[key].Show
            if frame.CastbarsOriginalAlpha == nil then frame.CastbarsOriginalAlpha = frame:GetAlpha() end
            frame:SetAlpha(hidden and 0 or frame.CastbarsOriginalAlpha)
            if not frame.CastbarsAlphaHook then
                frame.CastbarsAlphaHook = true
                hooksecurefunc(frame, "SetAlpha", function(native, alpha)
                    if self.db.profile[key].Show and readable(alpha) and alpha ~= 0 then native:SetAlpha(0) end
                end)
            end
        end
    end
end

function Castbars:StartMirror(timer, value, maximum, scale, paused, label)
    if self.ConfigMode then return end
    if not timer or timer == "UNKNOWN" then return end
    local available
    for _, frame in ipairs(self.mirrorFrames) do
        if frame.mirrorType == timer then
            available = frame
            break
        end
        if not available and not frame.mirrorType then available = frame end
    end
    if not available then return end
    available.mirrorType, available.mirrorMaximum, available.mirrorScale = timer, maximum, scale
    available.mirrorPaused = paused == true or (type(paused) == "number" and paused > 0)
    available.friendlyName = label or timer
    available:SetMinMaxValues(0, maximum)
    available:SetValue(value)
    available.text:SetText(label)
    local color = MirrorTimerColors and MirrorTimerColors[timer]
    if color then available:SetStatusBarColor(color.r, color.g, color.b) end
    available:Show()
end

function Castbars:StopMirror(timer)
    if self.ConfigMode then return end
    for _, frame in ipairs(self.mirrorFrames) do
        if frame.mirrorType == timer then clearMirror(frame) end
    end
end

function Castbars:PauseMirror(timer, paused)
    if self.ConfigMode then return end
    for _, frame in ipairs(self.mirrorFrames) do
        if frame.mirrorType == timer then
            frame.mirrorPaused = paused == true or (type(paused) == "number" and paused > 0)
        end
    end
end

function Castbars:RefreshMirrors()
    if self.ConfigMode then return end
    for _, frame in ipairs(self.mirrorFrames) do clearMirror(frame) end
    for i = 1, MIRRORTIMER_NUMTIMERS or 3 do
        self:StartMirror(GetMirrorTimerInfo(i))
    end
    if MirrorTimerContainer then MirrorTimerContainer:SetAlpha(0) end
    for i = 1, MIRRORTIMER_NUMTIMERS or 3 do
        local frame = _G["MirrorTimer" .. i]
        if frame then frame:SetAlpha(0) end
    end
end

function Castbars:Show()
    if InCombatLockdown() then self:Print("전투가 끝난 뒤 설정 모드를 사용할 수 있습니다."); return end
    self.ConfigMode = true
    for _, frame in ipairs(self.frames) do
        frame.preview = true
        frame:EnableMouse(true)
        frame:SetMinMaxValues(0, 3)
        frame:SetValue(1.5)
        frame.text:SetText(frame.friendlyName)
        frame.icon:SetTexture(136116)
        frame:SetStatusBarColor(unpack(self.db.profile[frame.configName].BarColor))
        frame.latency:Hide()
        clearTicks(frame)
        frame:Show()
        updateTimer(frame)
    end
end

function Castbars:Hide()
    self.ConfigMode = false
    for _, frame in ipairs(self.frames) do
        frame.preview = false
        frame:EnableMouse(false)
        frame:Hide()
        if frame.unit then refreshCast(frame) end
    end
    self:RefreshMirrors()
end

function Castbars:Toggle()
    if self.ConfigMode then self:Hide() else self:Show() end
end

function Castbars:ChatCommand(cmd)
    if cmd == "unlock" then self:Show(); return end
    if cmd == "lock" then self:Hide(); return end
    local spell = cmd:match("^blacklist%s+(.+)$")
    if spell then
        spell = tonumber(spell) or spell
        local list = self.db.profile.CastingBarFrame.Blacklist
        list[spell] = not list[spell] or nil
        return
    end
    LibStub("AceConfigDialog-3.0"):Open("Castbars")
end

-- The existing profile schema and appearance controls are appended below.

function Castbars:GetOptionsTableForBar(frameConfigName, friendlyName, order)
    local options =
    {
        type = "group",
        name = friendlyName,
        order = order,
        args =
        {
            width =
            {
                name = "Width",
                type = "range",
                order = 100,
                desc = "Set the width of the " .. friendlyName .. " bar",
                min = 50,
                max = 600,
                step = 1,
                get = function() return self.db.profile[frameConfigName]["Width"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Width"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            height =
            {
                name = "Height",
                type = "range",
                order = 101,
                desc = "Set the height of the " .. friendlyName .. " bar",
                min = 10,
                max = 100,
                step = 1,
                get = function() return self.db.profile[frameConfigName]["Height"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Height"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            texture =
            {
                name = "Texture",
                type = "select",
                order = 102,
                desc = "Select texture to use for the " .. friendlyName .. " bar",
                dialogControl = "LSM30_Statusbar",
                values = AceGUIWidgetLSMlists.statusbar,
                get = function() return self.db.profile[frameConfigName]["Texture"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Texture"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            color =
            {
                name = "Bar Color",
                type = "color",
                order = 103,
                desc = "Set color of the " .. friendlyName .. " bar",
                get = function(info)
                    return unpack(self.db.profile[frameConfigName]["BarColor"]);
                end,
                set = function(info, r, g, b)
                    self.db.profile[frameConfigName]["BarColor"] = {r, g, b};
                    self:FrameLayoutRestoreAll();
                end,
            },
            border =
            {
                name = "Border",
                type = "select",
                order = 105,
                desc = "Select border to use for the " .. friendlyName .. " bar",
                dialogControl = "LSM30_Border",
                values = AceGUIWidgetLSMlists.border,
                get = function() return self.db.profile[frameConfigName]["Border"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Border"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            bordercolor =
            {
                name = "Border Color",
                type = "color",
                hasAlpha = true,
                order = 106,
                desc = "Set color of the border of the " .. friendlyName .. " bar",
                get = function(info)
                    return unpack(self.db.profile[frameConfigName]["BorderColor"]);
                end,
                set = function(info, r, g, b, a)
                    self.db.profile[frameConfigName]["BorderColor"] = {r, g, b, a};
                    self:FrameLayoutRestoreAll();
                end,
            },
            borderwidthadjustment =
            {
                name = "Border Width Adjustment",
                type = "range",
                order = 107,
                desc = "Adjust the width of the border of the " .. friendlyName .. " bar",
                min = -16,
                max = 16,
                step = 0.1,
                get = function() return self.db.profile[frameConfigName]["BorderWidthAdjustment"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["BorderWidthAdjustment"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            borderoffsetadjustment =
            {
                name = "Border Offset Adjustment",
                type = "range",
                order = 108,
                desc = "Adjust the offset of the border of the " .. friendlyName .. " bar",
                min = -16,
                max = 16,
                step = 0.1,
                get = function() return self.db.profile[frameConfigName]["BorderOffsetAdjustment"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["BorderOffsetAdjustment"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            alpha =
            {
                name = "Opacity",
                type = "range",
                order = 109,
                desc = "Set the opacity of the " .. friendlyName .. " bar",
                min = 0,
                max = 1,
                step = 0.01,
                get = function() return self.db.profile[frameConfigName]["Alpha"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Alpha"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            font =
            {
                name = "Font",
                type = "select",
                order = 200,
                desc = "Select font to use for the " .. friendlyName .. " bar",
                dialogControl = "LSM30_Font",
                values = AceGUIWidgetLSMlists.font,
                get = function() return self.db.profile[frameConfigName]["Font"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Font"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            fontsize =
            {
                name = "Font Size",
                type = "range",
                order = 201,
                desc = "Set the font size of the " .. friendlyName .. " bar",
                min = 6,
                max = 30,
                step = 1,
                get = function() return self.db.profile[frameConfigName]["FontSize"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["FontSize"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            fontoutline =
            {
                name = "Font Outline",
                type = "toggle",
                order = 202,
                desc = "Toggles outline on the font of the " .. friendlyName .. " bar",
                get = function() return self.db.profile[frameConfigName]["FontOutline"] end,
                set = function()
                    self.db.profile[frameConfigName]["FontOutline"] = not self.db.profile[frameConfigName]["FontOutline"];
                    self:FrameLayoutRestoreAll();
                end,
            },
        },
    };
    if (frameConfigName ~= "MirrorTimer") then
        options.args.enable =
        {
            name = "Enable",
            type = "toggle",
            order = 1,
            desc = "Toggles display of the " .. friendlyName .. " bar",
            get = function() return self.db.profile[frameConfigName]["Show"] end,
            set = function()
                self.db.profile[frameConfigName]["Show"] = not self.db.profile[frameConfigName]["Show"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.showicon =
        {
            name = "Show Icon",
            type = "toggle",
            order = 2,
            desc = "Toggles display of the icon at the left side of the bar",
            get = function() return self.db.profile[frameConfigName]["ShowIcon"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowIcon"] = not self.db.profile[frameConfigName]["ShowIcon"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.iconalign =
        {
            name = "Icon Alignment",
            type = "select",
            order = 3,
            desc = "Set the alignment of the icon",
            values = {LEFT = "Left", RIGHT = "Right"},
            get = function() return self.db.profile[frameConfigName]["IconAlignment"] end,
            set = function(info, value)
                self.db.profile[frameConfigName]["IconAlignment"] = value;
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "TargetCastingBarFrame" or frameConfigName == "FocusCastingBarFrame") then
        options.args.showshield =
        {
            name = "Show Shield",
            type = "toggle",
            order = 4,
            desc = "Toggles display of the shield around the bar when the spell cannot be interrupted.",
            get = function() return self.db.profile[frameConfigName]["ShowShield"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowShield"] = not self.db.profile[frameConfigName]["ShowShield"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showlatency =
        {
            name = "Show Latency",
            type = "toggle",
            order = 5,
            desc = "Toggles display of the combined queue zone and latency indicator, which shows the queue zone and latency as a bar at the end of the Castbar, making it easier to time chain casting of spells.",
            get = function() return self.db.profile[frameConfigName]["ShowLatency"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowLatency"] = not self.db.profile[frameConfigName]["ShowLatency"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.showspellname =
        {
            name = "Show Spell Name",
            type = "toggle",
            order = 6,
            desc = "Toggles display of the name of the spell being cast.",
            get = function() return self.db.profile[frameConfigName]["ShowSpellName"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowSpellName"] = not self.db.profile[frameConfigName]["ShowSpellName"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showspelltarget =
        {
            name = "Show Spell Target",
            type = "toggle",
            order = 7,
            desc = "Toggles display of the target of the spell being cast.",
            get = function() return self.db.profile[frameConfigName]["ShowSpellTarget"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowSpellTarget"] = not self.db.profile[frameConfigName]["ShowSpellTarget"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.showtotalcasttime =
        {
            name = "Show Total Cast Time",
            type = "toggle",
            order = 8,
            desc = "Toggles display of the total cast time.",
            get = function() return self.db.profile[frameConfigName]["ShowTotalCastTime"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowTotalCastTime"] = not self.db.profile[frameConfigName]["ShowTotalCastTime"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.totalcasttimedecimals =
        {
            name = "Total Cast Time Decimals",
            type = "range",
            order = 9,
            desc = "Set the number of decimal places for the total cast time.",
            min = 0,
            max = 3,
            step = 1,
            get = function() return self.db.profile[frameConfigName]["TotalCastTimeDecimals"] end,
            set = function(info, value)
                self.db.profile[frameConfigName]["TotalCastTimeDecimals"] = value;
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showpushback =
        {
            name = "Show Pushback",
            type = "toggle",
            order = 10,
            desc = "Toggles display of the pushback time when spell casting is delayed.",
            get = function() return self.db.profile[frameConfigName]["ShowPushback"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowPushback"] = not self.db.profile[frameConfigName]["ShowPushback"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showspark =
        {
            name = "Show Global Cooldown Spark",
            type = "toggle",
            order = 11,
            desc = "Toggles display of the global cooldown spark.",
            get = function() return self.db.profile[frameConfigName]["ShowCooldownSpark"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowCooldownSpark"] = not self.db.profile[frameConfigName]["ShowCooldownSpark"];
                updateGCD(self.unitBars[1]);
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showswingtimer =
        {
            name = "Show Swing Timer",
            type = "toggle",
            order = 12,
            desc = "Toggles display of the swing timer.",
            get = function() return self.db.profile[frameConfigName]["ShowSwingTimer"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowSwingTimer"] = not self.db.profile[frameConfigName]["ShowSwingTimer"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.colorchanneling =
        {
            name = "Channeling Bar Color",
            type = "color",
            order = 104,
            desc = "Set color of the " .. friendlyName .. " bar when channeling",
            get = function(info)
                return unpack(self.db.profile[frameConfigName]["BarColorChanneling"]);
            end,
            set = function(info, r, g, b)
                self.db.profile[frameConfigName]["BarColorChanneling"] = {r, g, b};
            end,
        }
    end
    if (frameConfigName == "TargetCastingBarFrame" or frameConfigName == "FocusCastingBarFrame") then
        options.args.colorshielded =
        {
            name = "Shielded Bar Color",
            type = "color",
            order = 105,
            desc = "Set color of the " .. friendlyName .. " bar when cast cannot be interrupted",
            get = function(info)
                return unpack(self.db.profile[frameConfigName]["BarColorShielded"]);
            end,
            set = function(info, r, g, b)
                self.db.profile[frameConfigName]["BarColorShielded"] = {r, g, b};
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.coloroutofrange =
        {
            name = "Out-of-range Bar Color",
            type = "color",
            order = 106,
            desc = "Set color of the " .. friendlyName .. " bar when target is out of range",
            get = function(info)
                return unpack(self.db.profile[frameConfigName]["BarColorOutOfRange"]);
            end,
            set = function(info, r, g, b)
                self.db.profile[frameConfigName]["BarColorOutOfRange"] = {r, g, b};
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.textalign =
        {
            name = "Text Alignment",
            type = "select",
            order = 203,
            desc = "Set the alignment of the Castbar text",
            values = {LEFT = "Left", CENTER = "Center"},
            get = function() return self.db.profile[frameConfigName]["TextAlignment"] end,
            set = function(info, value)
                self.db.profile[frameConfigName]["TextAlignment"] = value;
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    for _, key in ipairs({"showswingtimer", "coloroutofrange"}) do
        if options.args[key] then
            options.args[key].disabled = true
            options.args[key].desc = "포에버에서 제한되는 전투 정보에 의존하는 구형 기능입니다. 기존 설정값은 보존됩니다."
        end
    end
    return options;
end

function Castbars:GetOptionsTable()
    local options =
    {
        type = "group",
        args =
        {
            general =
            {
                type = "group",
                name = "General Settings",
                childGroups = "tab",
                args =
                {
                    toggleconfigmode =
                    {
                        name = "Configuration Mode",
                        type = "toggle",
                        order = 1,
                        desc = "Toggle configuration mode to allow moving bars and setting appearance options",
                        get = function() return self.ConfigMode end,
                        set = function() self:Toggle() end,
                    },
                    player = self:GetOptionsTableForBar("CastingBarFrame", "Player/Vehicle", 2),
                    pet = self:GetOptionsTableForBar("PetCastingBarFrame", "Pet", 3),
                    target = self:GetOptionsTableForBar("TargetCastingBarFrame", "Target", 4),
                    focus = self:GetOptionsTableForBar("FocusCastingBarFrame", "Focus", 5),
                    mirror = self:GetOptionsTableForBar("MirrorTimer", "Mirror Timers", 6),
                },
            },
            profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
        },
    };
    return options;
end


function Castbars:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CastbarsDB",
    {
        profile =
        {
            ["**"] =
            {
                Width = 205,
                Height = 13,
                Alpha = 1.0,
                Texture = "Castbars",
                BarColor = {0.3, 0.3, 0.8},
                BarColorChanneling = {0.4, 0.2, 0.8},
                BarColorShielded = {0.6, 0.6, 0.6},
                BarColorOutOfRange = {0.6, 0.6, 0.6},
                Border = "Blizzard Tooltip",
                BorderColor = {0.0, 0.0, 0.0, 0.8},
                BorderWidthAdjustment = 0,
                BorderOffsetAdjustment = 0,
                Font = "Friz Quadrata TT",
                FontSize = 10,
                FontOutline = true,
                TextAlignment = "CENTER",
                Position = nil,
                ShowSpellName = true,
            },
            CastingBarFrame =
            {
                Show = true,
                ShowLatency = true,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowSpellTarget = true,
                ShowTotalCastTime = true,
                TotalCastTimeDecimals = 1,
                ShowPushback = true,
                ShowCooldownSpark = true,
                Width = 250,
                Height = 24,
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = -245},
                Blacklist = {},
            },
            PetCastingBarFrame =
            {
                Show = true,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowTotalCastTime = false,
                TotalCastTimeDecimals = 1,
                Width = 150,
                Height = 12,
                FontSize = 9,
                Border = "None",
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = -275},
            },
            TargetCastingBarFrame =
            {
                Show = true,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowTotalCastTime = false,
                TotalCastTimeDecimals = 1,
                ShowShield = true,
                Height = 12,
                Border = "None",
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = 180},
            },
            FocusCastingBarFrame =
            {
                Show = false,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowTotalCastTime = false,
                TotalCastTimeDecimals = 1,
                ShowShield = true,
                Height = 12,
                Border = "None",
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = 220},
            },
            MirrorTimer =
            {
                Position = {point = "TOP", relpoint = "TOP", x = 0, y = -130},
            },
        }
    });
    self.db.RegisterCallback(self, "OnProfileChanged", "FrameLayoutRestoreAll");
    self.db.RegisterCallback(self, "OnProfileCopied", "FrameLayoutRestoreAll");
    self.db.RegisterCallback(self, "OnProfileReset", "FrameLayoutRestoreAll");

    self.frames, self.unitBars, self.mirrorFrames = {}, {}, {}
    LSM:Register("statusbar", "Castbars", [[Interface\AddOns\Castbars\Castbars.tga]])
    self.options = self:GetOptionsTable();
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Castbars", self.options);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Castbars", nil, nil, "general");
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Castbars", "Profiles", "Castbars", "profile");
    self:RegisterChatCommand("cb", "ChatCommand");
    self:RegisterChatCommand("castbars", "ChatCommand");

    self.playerClass = select(2, UnitClass("player"));

    for i, key in ipairs(configs) do
        local frame = createBar("CastbarsForever" .. i, key, titles[i])
        frame.unit = units[i]
        self.frames[#self.frames + 1] = frame
        self.unitBars[#self.unitBars + 1] = frame
    end
    for i = 1, MIRRORTIMER_NUMTIMERS or 3 do
        local frame = createBar("CastbarsForeverMirror" .. i, "MirrorTimer", "Mirror Timer " .. i)
        frame.mirrorIndex = i - 1
        self.frames[#self.frames + 1] = frame
        self.mirrorFrames[i] = frame
    end
    self:FrameLayoutRestoreAll()
    self:RefreshMirrors()

    local events = CreateFrame("Frame")
    self.eventFrame = events
    for _, event in ipairs({
        "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "UNIT_PET",
        "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED",
        "MIRROR_TIMER_START", "MIRROR_TIMER_PAUSE", "MIRROR_TIMER_STOP", "ADDON_LOADED", "ACTIONBAR_UPDATE_COOLDOWN",
    }) do events:RegisterEvent(event) end
    for _, event in ipairs({
        "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP",
        "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
        "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_STOP", "UNIT_SPELLCAST_EMPOWER_UPDATE",
        "UNIT_SPELLCAST_SENT",
    }) do events:RegisterUnitEvent(event, "player", "vehicle", "pet", "target", "focus") end
    events:SetScript("OnEvent", function(_, event, unit, target, ...)
        if event == "PLAYER_REGEN_DISABLED" and self.ConfigMode then self:Hide() end
        if event == "PLAYER_REGEN_ENABLED" and self.pendingLayout then
            self.pendingLayout = nil
            self:FrameLayoutRestoreAll()
        end
        if event == "UNIT_SPELLCAST_SENT" then
            if unit == "player" then self.unitBars[1].sentTarget = target end
            return
        end
        if event == "ACTIONBAR_UPDATE_COOLDOWN" then updateGCD(self.unitBars[1]); return end
        -- These events are synchronous: the timer list can still contain the
        -- old entry. Apply the event payload directly, especially on STOP.
        if event == "MIRROR_TIMER_START" then self:StartMirror(unit, target, ...); return end
        if event == "MIRROR_TIMER_STOP" then self:StopMirror(unit); return end
        if event == "MIRROR_TIMER_PAUSE" then self:PauseMirror(unit, target); return end
        if event == "ADDON_LOADED" then self:UpdateNativeBars(); return end
        self.unitBars[1].unit = UnitHasVehicleUI and UnitHasVehicleUI("player") and "vehicle" or "player"
        for _, frame in ipairs(self.unitBars) do
            if not unit or unit == frame.unit or not event:find("^UNIT_SPELLCAST") then
                refreshCast(frame)
            end
        end
        if event == "PLAYER_ENTERING_WORLD" then
            self:UpdateNativeBars()
            self:RefreshMirrors()
        end
    end)
    LSM.RegisterCallback(self, "LibSharedMedia_Registered", "FrameMediaRestoreAll")
    LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "FrameMediaRestoreAll")
    CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {}
    CONFIGMODE_CALLBACKS.Castbars = function(action)
        if action == "ON" then self:Show() elseif action == "OFF" then self:Hide() end
    end
end


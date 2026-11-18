local PitBull4 = _G.PitBull4
if not PitBull4.Compat.IsForever then return end
local module = PitBull4:GetModule("LuaTexts")
local readable = PitBull4.Compat.IsValueAccessible

-- Readable values keep the user's Lua code and formatting. Restricted values
-- go straight to native FontString sinks instead of becoming fabricated zeroes.
function module:TryForeverText(text, unit, code)
    local attach_to = text.db and text.db.attach_to
    if unit ~= "player" and (attach_to == "AltManaBar" or attach_to == "DruidManaBar") then
        text:SetText("")
        return true
    end
    if code:find("CastData%s*%(") and PitBull4.CastBar and PitBull4.CastBar.GetForeverCast then
        local data = PitBull4.CastBar.GetForeverCast(unit)
        if data then
            if code:find("end_time", 1, true) then
                text:SetFormattedText("%.1f", data.duration:GetRemainingDuration())
            else
                text:SetText(data.name)
            end
        else
            text:SetText("")
        end
        self.to_update[text] = 0.1
        return true
    end
    local health = code:find("%f[%a]HP%s*%(") or code:find("MaxHP%s*%(") or code:find("UnitHealth%s*%(")
    local power = code:find("%f[%a]Power%s*%(") or code:find("MaxPower%s*%(") or code:find("UnitPower%s*%(")
    if health or power then
        local current, maximum
        if health then
            current, maximum = UnitHealth(unit), UnitHealthMax(unit)
        else
            local mana = code:find("Power%s*%(%s*unit%s*,%s*0%s*%)") and 0 or nil
            current, maximum = UnitPower(unit, mana), UnitPowerMax(unit, mana)
        end
        if not readable(current) or not readable(maximum) then
            -- Forever fix: 퍼센트 텍스트는 제한 상태에서도 퍼센트로 표시
            local pct
            if code:find("Percent%s*%(") and CurveConstants and CurveConstants.ScaleTo100 then
                local ok, value
                if health and UnitHealthPercent then
                    ok, value = pcall(UnitHealthPercent, unit, true, CurveConstants.ScaleTo100)
                elseif not health and UnitPowerPercent then
                    local mana = code:find("Power%s*%(%s*unit%s*,%s*0%s*%)") and 0 or nil
                    ok, value = pcall(UnitPowerPercent, unit, mana, false, CurveConstants.ScaleTo100)
                end
                if ok then pct = value end
            end
            if pct ~= nil then
                if code:find('"%s/%s || %s%%"', 1, true) then
                    text:SetFormattedText("%s/%s || %.0f%%", current, maximum, pct)
                elseif code:find('"%s || %s%%"', 1, true) then
                    text:SetFormattedText("%s || %.0f%%", current, pct)
                else
                    text:SetFormattedText("%.0f%%", pct)
                end
            else
                text:SetFormattedText("%s / %s", current, maximum)
            end
            self.to_update[text] = 0.1
            return true
        end
    end
    if code:find("%f[%a]Name%s*%(") or code:find("UnitName%s*%(") then
        local name = UnitName(unit)
        if not readable(name) then text:SetText(name); return true end
    end
    if code:find("%f[%a]Level%s*%(") or code:find("UnitLevel%s*%(") then
        local level = UnitLevel(unit)
        if not readable(level) then text:SetFormattedText("%s", level); return true end
    end
    return false
end

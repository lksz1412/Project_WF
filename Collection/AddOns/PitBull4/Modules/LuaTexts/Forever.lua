local PitBull4 = _G.PitBull4
if not PitBull4.Compat.IsForever then return end
local module = PitBull4:GetModule("LuaTexts")
local readable = PitBull4.Compat.IsValueAccessible

-- What a text's code reads, found once per code string (codes are a handful
-- of user strings that change only when the user edits them).
local kinds = {}
local function kind_of(code)
    local k = kinds[code]
    if k then return k end
    k = {
        cast = code:find("CastData%s*%(") and true or false,
        end_time = code:find("end_time", 1, true) and true or false,
        health = (code:find("%f[%a]HP%s*%(") or code:find("MaxHP%s*%(") or code:find("UnitHealth%s*%(")) and true or false,
        power = (code:find("%f[%a]Power%s*%(") or code:find("MaxPower%s*%(") or code:find("UnitPower%s*%(")) and true or false,
        mana = code:find("Power%s*%(%s*unit%s*,%s*0%s*%)") and true or false,
        percent = code:find("Percent%s*%(") and true or false,
        current_max_percent = code:find('"%s/%s || %s%%"', 1, true) and true or false,
        current_percent = code:find('"%s || %s%%"', 1, true) and true or false,
        name = (code:find("%f[%a]Name%s*%(") or code:find("UnitName%s*%(")) and true or false,
        level = (code:find("%f[%a]Level%s*%(") or code:find("UnitLevel%s*%(")) and true or false,
    }
    kinds[code] = k
    return k
end

-- Readable values keep the user's Lua code and formatting. Restricted values
-- go straight to native FontString sinks instead of becoming fabricated zeroes.
function module:TryForeverText(text, unit, code)
    local attach_to = text.db and text.db.attach_to
    if unit ~= "player" and (attach_to == "AltManaBar" or attach_to == "DruidManaBar") then
        text:SetText("")
        return true
    end
    local k = kind_of(code)
    if k.cast and PitBull4.CastBar and PitBull4.CastBar.GetForeverCast then
        local data = PitBull4.CastBar.GetForeverCast(unit)
        if data then
            if k.end_time then
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
    local health, power = k.health, k.power
    if health or power then
        local current, maximum
        if health then
            current, maximum = UnitHealth(unit), UnitHealthMax(unit)
        else
            local mana = k.mana and 0 or nil
            current, maximum = UnitPower(unit, mana), UnitPowerMax(unit, mana)
        end
        if not readable(current) or not readable(maximum) then
            -- Forever fix: 퍼센트 텍스트는 제한 상태에서도 퍼센트로 표시
            local pct
            if k.percent and CurveConstants and CurveConstants.ScaleTo100 then
                local ok, value
                if health and UnitHealthPercent then
                    ok, value = pcall(UnitHealthPercent, unit, true, CurveConstants.ScaleTo100)
                elseif not health and UnitPowerPercent then
                    local mana = k.mana and 0 or nil
                    ok, value = pcall(UnitPowerPercent, unit, mana, false, CurveConstants.ScaleTo100)
                end
                if ok then pct = value end
            end
            if pct ~= nil then
                if k.current_max_percent then
                    text:SetFormattedText("%s/%s || %.0f%%", current, maximum, pct)
                elseif k.current_percent then
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
    if k.name then
        local name = UnitName(unit)
        if not readable(name) then text:SetText(name); return true end
    end
    if k.level then
        local level = UnitLevel(unit)
        if not readable(level) then text:SetFormattedText("%s", level); return true end
    end
    return false
end

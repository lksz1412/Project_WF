--[[
Author: Fairlady
Fcp  - Combo Points and Buff/Debuff display addon
contact: cikandin@gmail.com
]]

local core = LibStub("AceAddon-3.0"):GetAddon("FairComboPoints2")
local Others = LibStub("AceAddon-3.0"):NewAddon("FCP2_OTHERS", "AceConsole-3.0")
local shown = {}
local shownself = {}
local classcolor = {}
local temp = {}

function Others:OnInitialize()
	core.db = LibStub("AceDB-3.0"):New("FCP2DB2", defaults, "Default")
	local tCount = 0
	for k, v in pairs(core.db.profile.others.aura) do
		tCount = tCount+1
	end
	for k, v in pairs(core.db.profile.self.aura) do
		tCount = tCount+1
	end
	if tCount then
		for k, v in pairs(RAID_CLASS_COLORS) do
			classcolor[k] = { v.r, v.g, v.b }
		end
		Others.self = core:MakeIconFrame("FCP2SelfBuff", core.db.profile.self)
		Others.icon = core:MakeIconFrame("FCP2TargetBuff", core.db.profile.others)
		Others.icon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		Others.icon:RegisterEvent("PLAYER_TARGET_CHANGED")
		Others.icon:RegisterEvent("UNIT_AURA")
		Others.icon:RegisterEvent("UNIT_PET")
		Others.icon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	    Others.icon:SetScript("OnEvent", function(s, event, ...) self:OnEvent(event, ...)   end)
	end
end
--arg desc:
--arg2 :event
--arghide(wiki3) : hide caster
--arg3 (wiki4): sourceGUID
--arg4 (wiki5): sourceName
--arg5 (wiki6): sourceFlags
--argFlag2 (wiki7): sourceFlag2
--arg6 (wiki8) : destGUID
--arg7 (wiki9) :destName
--arg8 (wiki10): destFlags
--argdestFlag2 (wiki11): destFlags2
--arg9 (wiki12): Spell ID
--arg10 (wiki13): Spell Name
function Others:OnEvent(event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, arg2, arghide, arg3, arg4, arg5, argFlag2, arg6, arg7, arg8, argdestFlag2, arg9, arg10 = ...
		if arg3 ~= UnitGUID("player") and arg3 ~= UnitGUID("pet") then return end
		if UnitIsDead("player") then return end
		if arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_APPLIED_DOSE" or arg2 == "SPELL_AURA_REFRESH" then
			if arg7 == UnitName("player") or arg6 == UnitGUID("pet") or arg7 == nil then
				for tmp1, k in pairs(core.db.profile.self.aura) do
					if arg10 == k then
						local count, duration, _, endTime = self:check_aura("player", arg9)
						if not duration then count, duration = self:check_aura("pet", arg9) end
						if duration then
							local f = self:createSelfIcon(arg3, arg6, arg9)
							self:ShowCount(count, f)
							self:ani_timer(endTime, endTime-GetTime(), f)
							self:calc_pos(shownself, core.db.profile.self)
						end
					end
				end
			else
				for tmp2, k in pairs(core.db.profile.others.aura) do
					if arg10 == k and (arg6 == UnitGUID("target") or arg6 == UnitGUID("mouseover"))then
						local f = self:createIcon(arg3, arg6, arg9)
						local _, count, duration, endTime
						if arg6 == UnitGUID("target") then
							count, duration, _, endTime = self:check_aura("target", arg10)
						elseif arg6 == UnitGUID("mouseover") then
							count, duration, _, endTime = self:check_aura("mouseover", arg10)
						end
						self:ShowCount(count, f)
						if duration then
							self:ani_timer(endTime, endTime-GetTime(), f)
							local _, class
							if arg6 == UnitGUID("target") then
								--UIFrameFadeIn(f.glow, 0.2, 0, 1)
								if UnitIsFriend("player", "target") then
									_, class = UnitClass("target")
								elseif arg6 == UnitGUID("mouseover") and UnitIsFriend("player", "mouseover") then
									_, class = UnitClass("mouseover")
								end
								if class then
									f.bg:SetVertexColor(unpack(classcolor[class]))
								end
								self:calc_pos(shown, core.db.profile.others)
							end
						end
					end
				end
			end
		end
		if arg2 == "SPELL_AURA_REMOVED" or arg2 == "SPELL_AURA_REMOVED_DOSE" or arg2 == "SPELL_AURA_BROKEN" then
			local targetTable
			if arg7 == UnitName("player") or arg6 == UnitGUID("pet") then
				targetTable = shownself
			else
				targetTable = shown
			end
			for i=1, #(targetTable) do
				if targetTable[i] and targetTable[i].source == arg3 and targetTable[i].target == arg6 and targetTable[i].buffName == arg9 then
					self:remove_icon(targetTable[i])
				end
			end
		end
	end
	if event == "PLAYER_TARGET_CHANGED" then
		for i=1, #(shown) do
			if shown[i].target == UnitGUID("target") then
				shown[i].glow:Show()
				--UIFrameFadeIn(shown[i].glow, 0.2, 0, 1)
			else
				shown[i].glow:Hide()
			end
		end
		for tmp1, k in pairs(core.db.profile.others.aura) do
			local count, duration, spellId, expirationTime = self:check_aura("target", k)
			if duration then
				local f = self:createIcon(UnitGUID("player"), UnitGUID("target"), spellId)
				self:ShowCount(count, f)
				self:ani_timer(expirationTime, expirationTime-GetTime(), f)
				if UnitIsFriend("player", "target") then
					local _, class = UnitClass("target")
					f.bg:SetVertexColor(unpack(classcolor[class]))
				end
				self:calc_pos(shown, core.db.profile.others)
				--UIFrameFadeIn(f.glow, 0.2, 0, 1)
			end
		end
	end
	if event == "UNIT_PET" then
		for i=1, #(shownself) do
			if shownself[i].source == UnitGUID("pet") then
				--UIFrameFlash(shownself[i], 0.0, 0.2, 0.2, false, 0, 0)
				shownself[i]:Hide()
				tremove(shownself, i)
			end
		end
	end
	if event == "UNIT_AURA" then
		local unit, _ = select(1, ...)
		--for 4.2 refresh bug by Blizzard
		local targetTable
		if unit == "player" or unit == "playerpet" then
			targetTable = shownself
		else
			targetTable = shown
		end
		for i=1, #(targetTable) do
			local buffname = GetSpellInfo(targetTable[i].buffName)
			local _, duration, _, endTime = self:check_aura(unit, buffname)
			if targetTable[i].target == UnitGUID(unit) and targetTable[i].endtime and endTime and endTime > targetTable[i].endtime then
				self:ani_timer(endTime, endTime-GetTime(), targetTable[i])
			end
		end
		if unit ~= "player" then return end
		local j
		for tmp, v in pairs(core.db.profile.self.aura) do
			local exist = false
			local count, duration, spellid, endTime = self:check_aura(unit, v)
			for i=1, #(shownself) do
				if shownself[i].buffName == spellid then exist = true end
				if GetSpellInfo(shownself[i].buffName) == v and not spellid then j = i end
			end
			if spellid and not exist then
				local ID = UnitGUID("player")
				self:MakePlayerIconFrame(ID, ID, spellid, count, duration, endTime)
			end
		end
		if j then
			self:remove_icon(shownself[j])
		end
		for i=1, #(shownself) do
			local spellname = GetSpellInfo(shownself[i].buffName)
			local count = self:check_aura(unit, spellname)
			self:ShowCount(count, shownself[i])
		end
	end
end

function Others:MakePlayerIconFrame(fromID, toID, spellID, count, duration, endTime)
	local f
	if duration then
		f = self:createSelfIcon(fromID, toID, spellID)
		self:ShowCount(count, f)
		if duration ~= 0 then
			self:ani_timer(endTime, endTime-GetTime(), f)
		end
		self:calc_pos(shownself, core.db.profile.self)
	end
	return f
end

function Others:ShowCount(count, f)
	if count and count>1 then
		f.text:SetText(count)
		f.text:Show()
	elseif count == 1 then
		f.text:Hide()
	end
end

function Others:createIcon(from, to, value)
	local f
	local count = 1
	local exist = false
	for i=1, #(shown) do
		if shown[i] and shown[i].source == from and shown[i].target == to then
			count = i
			if shown[i].buffName == value then
				exist = true
				f = shown[i]
			end
		end
	end
	if not exist then
		f = core:CreateBuffIcon(value, Others.icon, core.db.profile.others)
		f.source = from
		f.target = to
		f.buffName = value
		tinsert(shown, count, f)
	end
	return f
end

function Others:createSelfIcon(from, to, value)
	local f
	local count = 1
	local exist = false
	for i=1, #(shownself) do
		if shownself[i] and shownself[i].source == from and shownself[i].target == to then
			count = i
			if shownself[i].buffName == value then
				exist = true
				f = shownself[i]
			end
		end
	end
	if not exist then
		f = core:CreateBuffIcon(value, Others.self, core.db.profile.self)
		f.source = from
		f.target = to
		f.buffName = value
		tinsert(shownself, count, f)
	end
	return f
end

function Others:remove_icon(f)
	local targetTable, db
	for i=1, #(shown) do
		if f == shown[i] then
		tremove(shown, i)
		targetTable = shown
		db = core.db.profile.others
		end
	end
	for i=1, #(shownself) do
		if f == shownself[i] then
		tremove(shownself, i)
		targetTable = shownself
		db = core.db.profile.self
		end
	end
	f:Hide()
	f:SetParent(nil)
	--UIFrameFlash(f, 0.0, 0.2, 0.2, false, 0, 0)
	if targetTable then
		self:calc_pos(targetTable, db)
	end
end

function Others:calc_pos(targetTable, db)
	for i =1, #(targetTable) do
		local _, _, _, x, y = targetTable[i]:GetPoint()
		local pos = (i-1)*db.scale*45
		if db.orientation == "c" then
			local pos = ((i-1)-(#(targetTable)-1)/2)*db.scale*45
			targetTable[i]:Show()
			core:MoveAnimation(targetTable[i], pos-x, 0, pos, 0)
		elseif db.orientation == "cv" then
			local pos = ((i-1)-(#(targetTable)-1)/2)*db.scale*45
			targetTable[i]:Show()
			core:MoveAnimation(targetTable[i], 0, pos-y, 0, pos)
		elseif db.orientation == "r" then
			targetTable[i]:Show()
			core:MoveAnimation(targetTable[i], pos-x, 0, pos, 0)
		elseif db.orientation == "l" then
			targetTable[i]:Show()
			core:MoveAnimation(targetTable[i], -(pos+x), 0, -pos, 0)
		elseif db.orientation == "t" then
			targetTable[i]:Show()
			core:MoveAnimation(targetTable[i], 0, pos-y, 0, pos)
		elseif db.orientation == "b" then
			targetTable[i]:Show()
			core:MoveAnimation(targetTable[i], 0, -(pos+y), 0, -pos)
		end
	end
end

function Others:ani_timer(endTime, duration, frame)
	local size = frame:GetWidth()
	local db
	frame.endtime = endTime
	if frame.target == "player" or frame.target == nil then
		db = core.db.profile.self
	else
		db = core.db.profile.others
	end
	frame:SetScript("OnUpdate", function()
		local elapsed = endTime - GetTime()
		if elapsed > 0 then
			if elapsed > duration-0.3 then
				frame:SetScale(2-(-elapsed+duration)/0.3)
			end
			local percent = strsub(elapsed/duration, 0, 4)
			Others:calc_ring(frame, percent*100)
			Others:calc_spark(frame.spark, percent)
			if db.timer then
				local time
				if elapsed >3600 then
					time = elapsed/3600
					time = floor(time).."h"
				elseif elapsed > 60 then
					time = elapsed/60
					time = floor(time).."m"
				else
					time = floor(elapsed).."s"
				end
				frame.time:Show()
				frame.time:SetText(time)
			else
				frame.time:Hide()
			end
			if (elapsed<3) then
				frame.time:Show()
				frame.time:SetText(strsub(elapsed, 0, 4))
			end
		else
			Others:remove_icon(frame)
			frame:SetScript("OnUpdate", nil)
		end
	end)
end

function Others:check_aura(unit, aura)
	local _, name, count, duration, expirationTime, spellId, caster
	for i = 1, 40 do
		name, _, _, count, _, duration, expirationTime, caster, _, _, spellId = UnitDebuff(unit, i, "PLAYER|PET")
 		if aura == name or aura == spellId and (caster == "player" or caster == "pet") then
			return count, duration, spellId, expirationTime
		end
	end
	if not duration then
		for i=1, 40 do
			name, _, _, count, _, duration, expirationTime, caster, _, _, spellId = UnitBuff(unit, i, "PLAYER|PET")
			if aura == name or aura == spellId and (caster == "player" or caster == "pet")then
				return count, duration, spellId, expirationTime
			end
		end
	end
end

function Others:calc_ring(frame, value)
	for i =1, frame.segments_used do
		if (value >= i*25) then
			frame.ring[i].square1:Hide()
			frame.ring[i].square2:Hide()
			frame.ring[i].slicer:Hide()
			frame.ring[i].fullsegment:Show()
		elseif value > (i-1)*25 and value < i*25 then
			core:calc_ring_segment(frame.ring[i], (value-(i-1)*25)*4 )
			frame.ring[i].square1:Show()
			frame.ring[i].square2:Show()
			frame.ring[i].slicer:Show()
			frame.ring[i].fullsegment:Hide()
		else
			frame.ring[i].square1:Hide()
			frame.ring[i].square2:Hide()
			frame.ring[i].slicer:Hide()
			frame.ring[i].fullsegment:Hide()
		end
	end
end

function Others:calc_spark(self, value)
    local spark = self.texture
    local adjust = 0.009
    value = 1-value+adjust
    local mult = -1
    local radian = math.rad(90) + math.rad(value * (mult*360))
    spark:SetPoint("CENTER", spark.radius * math.cos(radian), spark.radius * math.sin(radian))
    spark:SetRotation(radian - spark.shiftradian)
end
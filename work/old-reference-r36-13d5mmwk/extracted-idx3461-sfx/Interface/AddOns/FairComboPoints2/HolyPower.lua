--[[
Author: Fairlady
Fcp  - Combo Points and Buff/Debuff display addon
$Date: 2010-10-15 21:58:13 +0000 (Fri, 15 Sep 2010) $
$Revision: 001 $
Project Version: 1.0.0
contact: cikandin@gmail.com
]]

local _, class = UnitClass("player")
if class ~= "PALADIN" then return end

local FCP2 = LibStub("AceAddon-3.0"):GetAddon("FairComboPoints2")
local modName = "Holy Power"
local HolyPowerModule = FCP2:NewModule(modName, "AceConsole-3.0", "AceEvent-3.0")
local points = 0
HolyPowerModule.MAX_POINTS = 5
HolyPowerModule.displayName = HOLY_POWER
HolyPowerModule.abbrev = "HP"

function HolyPowerModule:OnInitialize()
	self.graphics = FCP2:MakeGraphicsFrame(modName, self.MAX_POINTS)
	self.number = FCP2:MakeNumberFrame(modName, self.MAX_POINTS)
end

function HolyPowerModule:OnEnable()
	if not FCP2.db.profile.modules[modName].disableGraphics then
		self.graphics:Show()
	end
	if not FCP2.db.profile.modules[modName].disableNumber then
		self.number:Show()
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


	self:RegisterEvent("UNIT_POWER", "Update")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "Update")
end

function HolyPowerModule:OnDisable()
	self.graphics:Hide()
	self.number:Hide()
	self:UnregisterAllEvents()
end

function HolyPowerModule:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local _, arg2, arghide, arg3, arg4, arg5, argFlag2, arg6, arg7, arg8, argdestFlag2, arg9, arg10 = ...
	if arg3 ~= UnitGUID("player") then return end
	if UnitIsDead("player") then
		return self:Update("force")
	end
	if arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_APPLIED_DOSE" or arg2 == "SPELL_AURA_REFRESH" then
		if arg9 == 90174 then
			HolyPowerModule:WingAnimation(self.number.effect[13], 30, "BOTTOMLEFT")
			HolyPowerModule:WingAnimation(self.number.effect[16], -30, "BOTTOMRIGHT")
			self:Update("force")
		end
	elseif arg2 == "SPELL_AURA_REMOVED" or arg2 == "SPELL_AURA_REMOVED_DOSE" or arg2 == "SPELL_AURA_BROKEN" then
		if arg9 == 90174 then
			--UIFrameFlash(self.number.effect[13], 0, 0.3, 0.3, false, 0, 0)
			--UIFrameFlash(self.number.effect[16], 0, 0.3, 0.3, false, 0, 0)
			self.number.effect[13]:Hide()
			self.number.effect[16]:Hide()
			self:Update("force")
	 	end
	end
end

function HolyPowerModule:WingAnimation(frame, degree, point)
	frame:SetAlpha(0)
	frame:Show()
	local rotate_ani = frame:CreateAnimationGroup()

	local a0 = rotate_ani:CreateAnimation("Alpha")
   	a0:SetChange(1)
    a0:SetDuration(0.6)

 	local a1 = rotate_ani:CreateAnimation("Rotation")
	a1:SetDegrees(0-degree*2)
    a1:SetDuration(0.1)
    a1:SetSmoothing("OUT")
    a1:SetOrigin(point, 0, 0)

	local a2 = rotate_ani:CreateAnimation("Rotation")
	a2:SetDegrees(degree*3)
    a2:SetDuration(0.4)
    a2:SetSmoothing("IN")
    a2:SetOrigin(point, 0, 0)
    a2:SetStartDelay(0.1)

 	local a3 = rotate_ani:CreateAnimation("Rotation")
	a3:SetDegrees(0-degree)
    a3:SetDuration(0.8)
    a3:SetSmoothing("OUT")
    a3:SetOrigin(point, 0, 0)
    a3:SetStartDelay(0.4)

    rotate_ani:Play()
    rotate_ani:SetScript("OnFinished", function()
		frame:SetAlpha(1)
	end)
end

function HolyPowerModule:Update(event, ...)
	local arg1, arg2 = ...
	if event == "force" or event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" or (arg1 == "player" and arg2 == "HOLY_POWER") then
		local count = UnitPower("player", SPELL_POWER_HOLY_POWER)
		local startTime = GetTime()
		if count and count > 0 then
			local r, g, b = FCP2:GetColorByPoints(modName, count)
			for i = count, 1, -1 do
				self.graphics.points[i].icon:SetVertexColor(r, g, b)
				self.graphics.points[i]:Show()
			end
			if count ~= points then
				for j = self.MAX_POINTS, count+1, -1 do
					self.graphics.points[j]:Hide()
				end
				for k = self.MAX_POINTS, 1, -1 do
					self.number.points[k]:Hide()
				end
				FCP2:FireAnimation(count,modName)
				FCP2:RotateAnimation(self.graphics.points[count].blink)
				if count == self.MAX_POINTS then
					self.number.effect[14]:Show()
					FCP2:RepeatAnimation(self.number.effect[14])
					self.number.combo:Hide()
				else
					self.number.effect[10]:Hide()
					self.number.effect[12]:Hide()
					self.number.combo:Show()
					self.number.points[count]:Show()
					--FCP2:ScaleAnimation(self.number.points[count])
					self.number.points[count]:SetScript("OnUpdate",  function(self, elapsed) FCP2:ScaleAnimation(self,startTime,128*FCP2.db.profile.modules[modName].numberscale) end)
					FCP2:NumberSlideAnimation(self.number.combo_ani,self.number.combo,modName)
					self.number.effect[14]:Hide()
				end
			end
		elseif count and count == 0 then
			for i = 1, self.MAX_POINTS do
				if self.graphics.points[i]:IsShown() then
					--FCP2:Fair_Animation_Hide2(self.graphics.points[i],0.3,modName)
					self.graphics.points[i]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self,startTime,0.3,modName,25*FCP2.db.profile.modules[modName].scale) end)
				end
				--FCP2:Fair_Animation_Hide2(self.number.points[i],0.3,modName)
				self.number.points[i]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self,startTime,0.3,modName,128*FCP2.db.profile.modules[modName].numberscale) end)
			end
			if self.number.combo:IsShown() then
				--for i = 1, self.MAX_POINTS do
					--if self.number.points[i]:IsShown() then
						--UIFrameFlash(self.number.points[i],0, 0.5, 0.5, false,0, 0)
					--end
				--end
				FCP2:NumberSlideOutAnimation(self.number.combo,modName)
				self.number.effect[15]:Show()
				FCP2:Fair_Animation_Hide2(self.number.effect[15],0.3,modName)
			end
			self.number.effect[14]:Hide()
			self.number.combo_ani:Hide()
			self.number.effect[10]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self,startTime,0.3,modName,256*FCP2.db.profile.modules[modName].numberscale) end)
			self.number.effect[12]:Hide()
		end
		points = count or 0
	end
end
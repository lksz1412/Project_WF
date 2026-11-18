--[[
Author: Fairlady, Sayclub
Fcp  - Combo Points and Buff/Debuff display addon
$Date: 2010-10-15 21:58:13 +0000 (Fri, 15 Sep 2010) $
$Revision: 001 $
Project Version: 1.0.0
contact: cikandin@gmail.com
]]

local _, class = UnitClass("player")
if class ~= "DEATHKNIGHT" then return end

local FCP2 = LibStub("AceAddon-3.0"):GetAddon("FairComboPoints2")
local modName = "ShadowInfusion"
local ShadowInfusion = FCP2:NewModule(modName, "AceConsole-3.0", "AceEvent-3.0")
local point = 0
ShadowInfusion.abbrev = "SI"
ShadowInfusion.MAX_POINTS = 5
ShadowInfusion.displayName = GetSpellInfo(91342)

function ShadowInfusion:OnInitialize()
	self.graphics = FCP2:MakeGraphicsFrame(modName, self.MAX_POINTS)
	self.number = FCP2:MakeNumberFrame(modName, self.MAX_POINTS)
end

function ShadowInfusion:OnEnable()
	if not FCP2.db.profile.modules[modName].disableGraphics then
		self.graphics:Show()
	end
	if not FCP2.db.profile.modules[modName].disableNumber then
		self.number:Show()
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_PET")
	local count = self:checkAura("player", ShadowInfusion.displayName)
	if count then
		if count ~= point then
			ShadowInfusion:UpdateAura(count)
		end
	else
		ShadowInfusion:UpdateAura(0)
	end
end

function ShadowInfusion:OnDisable()
	self.graphics:Hide()
	self.number:Hide()
	self:UnregisterAllEvents()
end

function ShadowInfusion:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local _, arg2, arghide, arg3, arg4, arg5, argFlag2, arg6, arg7, arg8, argdestFlag2, arg9, arg10 = ...
	if arg6 ~= UnitGUID("pet") then return end
	if UnitIsDead("player") or UnitIsDead("pet") then
		return ShadowInfusion:UpdateAura(0)
	end
	local count
	if (arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_APPLIED_DOSE" or arg2 == "SPELL_AURA_REFRESH" or arg2=="SPELL_AURA_REMOVED" or arg2=="SPELL_AURA_REMOVED_DOSE" or arg2 == "SPELL_AURA_BROKEN") then
		if arg9 == 91342 then
			local count = self:checkAura("player", ShadowInfusion.displayName)
			if count then
				if count ~= point then
					ShadowInfusion:UpdateAura(count)
				end
			else
				ShadowInfusion:UpdateAura(0)
			end
		end
	end
end
--from faircombo1 , check aura
function ShadowInfusion:checkAura(Unit, AuraName)
	local i = 1
	while UnitAura(Unit, i, "PLAYER|HELPFUL") ~= nil do
		local name, _, icon, count = UnitAura(Unit, i, "PLAYER|HELPFUL")
 		if AuraName == name then
			return count
		end
		i = i + 1
	end
end

function ShadowInfusion:UNIT_PET()
	if UnitExists("pet") then
		local count = self:checkAura("player", ShadowInfusion.displayName)
		if count then
			self:UpdateAura(count, true)
		end
	else
		self:UpdateAura(0)
	end
end

function ShadowInfusion:UpdateAura(count, fire)
	local i, j
	local startTime=GetTime()
	if point and count and point > count then
		for i = self.MAX_POINTS, count + 1, -1 do
			if self.graphics.points[i]:IsShown() then
				--FCP2:Fair_Animation_Hide2(self.graphics.points[i], 0.3, modName)
				self.graphics.points[i]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self, startTime, 0.3, modName, 25*FCP2.db.profile.modules[modName].scale) end)
			end
			if self.number.points[i]:IsShown() then
				--FCP2:Fair_Animation_Hide2(self.number.points[i], 0.3, modName)
				self.number.points[i]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self, startTime, 0.3, modName, 128*FCP2.db.profile.modules[modName].numberscale) end)
			end
		end
	end
	for i = 1, count do
		self.graphics.points[i].icon:SetVertexColor(FCP2:GetColorByPoints(modName, count))
		self.graphics.points[i]:Show()
		self.number.points[i]:Hide()
		self.number.effect[10]:Hide()
		self.number.effect[12]:Hide()
	end
	if count > 0 then
		FCP2:RotateAnimation(self.graphics.points[count].blink)
		if count < self.MAX_POINTS then
			self.number.combo:Show()
			self.number.points[count]:Show()
			--FCP2:ScaleAnimation(self.number.points[count])
			self.number.points[count]:SetScript("OnUpdate",  function(self, elapsed) FCP2:ScaleAnimation(self, startTime, 128*FCP2.db.profile.modules[modName].numberscale) end)
			FCP2:NumberSlideAnimation(self.number.combo_ani, self.number.combo, modName)
		else
			self.number.combo_ani:Hide()
			self.number.combo:Hide()
		end
		if not fire or count == self.MAX_POINTS then
			FCP2:FireAnimation(count, modName)
		end
	else
		if self.number.combo:IsShown() then
			FCP2:NumberSlideOutAnimation(self.number.combo, modName)
		end
		self.number.combo_ani:Hide()
		self.number.effect[10]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self, startTime, 0.3, modName, 256*FCP2.db.profile.modules[modName].numberscale) end)
		self.number.effect[12]:Hide()
	end
	point = count
	--self.text:SetNumPoints(stacks)
end
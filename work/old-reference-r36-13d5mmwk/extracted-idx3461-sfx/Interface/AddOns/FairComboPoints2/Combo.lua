--[[
Author: Fairlady
Fcp  - Combo Points and Buff/Debuff display addon
$Date: 2010-10-15 21:58:13 +0000 (Fri, 15 Sep 2010) $
$Revision: 001 $
Project Version: 1.0.0
contact: cikandin@gmail.com
]]

local FCP2 = LibStub("AceAddon-3.0"):GetAddon("FairComboPoints2")
local modName = "Combo Points"
local ComboModule = FCP2:NewModule(modName, "AceConsole-3.0", "AceEvent-3.0")
ComboModule.abbrev = "CP"
ComboModule.MAX_POINTS = 5
ComboModule.displayName = COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT

function ComboModule:OnInitialize()
	self.graphics = FCP2:MakeGraphicsFrame(modName, self.MAX_POINTS)
	self.number = FCP2:MakeNumberFrame(modName,self.MAX_POINTS)
end

function ComboModule:OnEnable()
	if not FCP2.db.profile.modules[modName].disableGraphics then
		self.graphics:Show()
	end
	if not FCP2.db.profile.modules[modName].disableNumber then
		self.number:Show()
	end
	if not FCP2.db.profile.modules[modName].disableText then
	end

	self:RegisterEvent("UNIT_COMBO_POINTS")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UNIT_COMBO_POINTS")
	self:UNIT_COMBO_POINTS()
end

function ComboModule:OnDisable()
	self.graphics:Hide()
	self.number:Hide()
	self:UnregisterAllEvents()
end

function ComboModule:UNIT_COMBO_POINTS(arg1)
	local points = GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player") or 0
	if arg1 == "PLAYER_TARGET_CHANGED" and points == 0 then return end
	local r, g, b = FCP2:GetColorByPoints(modName, points)
	if points and points == 0 then
		local startTime=GetTime()
		for i = 1, self.MAX_POINTS do
			self.graphics.points[i]:Hide()
	--		FCP2:Fair_Animation_Hide2(self.number.points[i],0.3,modName)
			self.number.points[i]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self,startTime,0.3,modName,128*FCP2.db.profile.modules[modName].numberscale) end)
		end
		if self.number.combo:IsShown() then
			FCP2:NumberSlideOutAnimation(self.number.combo,modName)
		end
		self.number.combo_ani:Hide()
		self.number.effect[10]:SetScript("OnUpdate",  function(self, elapsed) FCP2:Fair_Animation_Hide(self,startTime,0.3,modName,256*FCP2.db.profile.modules[modName].numberscale) end)
		self.number.effect[12]:Hide()
	elseif points and points > 0 then
		local startTime=GetTime()
		for i = self.MAX_POINTS, 1, -1 do
			if i > points then
				self.graphics.points[i]:Hide()
			else
				self.graphics.points[i].icon:SetVertexColor(r, g, b)
				self.graphics.points[i]:Show()
			end
			self.number.points[i]:Hide()
		end
		self.number.effect[10]:Hide()
		self.number.effect[12]:Hide()
		FCP2:RotateAnimation(self.graphics.points[points].blink)
		if points < self.MAX_POINTS then
			self.number.combo:Show()
			self.number.points[points]:Show()
			self.number.points[points]:SetScript("OnUpdate",  function(self, elapsed) FCP2:ScaleAnimation(self,startTime,128*FCP2.db.profile.modules[modName].numberscale) end)
			--FCP2:ScaleAnimation(self.number.points[points],startTime)
			FCP2:NumberSlideAnimation(self.number.combo_ani,self.number.combo,modName)
		else
			self.number.combo_ani:Hide()
			self.number.combo:Hide()
		end
		FCP2:FireAnimation(points,modName)
	end
end
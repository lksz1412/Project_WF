--[[
Author: Fairlady
Fcp  - Combo Points and Buff/Debuff display addon
$Date: 2010-10-15 21:58:13 +0000 (Fri, 15 Sep 2010) $
$Revision: 001 $
Project Version: 1.0.0
contact: cikandin@gmail.com
]]

local _, class = UnitClass("player")
if class ~= "PRIEST" then return end

local FCP2 = LibStub("AceAddon-3.0"):GetAddon("FairComboPoints2")
local modName = "Shadow Orb"
local ShadowOrb = FCP2:NewModule(modName, "AceConsole-3.0", "AceEvent-3.0")
local points = 0
ShadowOrb.MAX_POINTS = 5
ShadowOrb.displayName = SHADOW_ORBS
ShadowOrb.abbrev = "SO"

function ShadowOrb:OnInitialize()
	self.graphics = FCP2:MakeGraphicsFrame(modName, self.MAX_POINTS)
	self.number = FCP2:MakeNumberFrame(modName,self.MAX_POINTS)
end

function ShadowOrb:OnEnable()
	if not FCP2.db.profile.modules[modName].disableGraphics then
		self.graphics:Show()
	end
	if not FCP2.db.profile.modules[modName].disableNumber then
		self.number:Show()
	end
	self:Change()
	self:RegisterEvent("UNIT_POWER", "Update")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
	self:RegisterEvent("SPELLS_CHANGED", "Change")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "Update")
end

function ShadowOrb:Change()
	if IsPlayerSpell(157217) then
		self.MAX_POINTS = 5
	else
		self.MAX_POINTS = 3
	end
end

function ShadowOrb:OnDisable()
	self.graphics:Hide()
	self.number:Hide()
	self:UnregisterAllEvents()
end

function ShadowOrb:Update(event, ...)
	local arg1, arg2 = ...
	if event == "force" or event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" or (arg1 == "player" and arg2 == "SHADOW_ORBS") then
		local count = (GetSpecialization() == 3) and UnitPower("player", SPELL_POWER_SHADOW_ORBS) or 0
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
						--JerryFrameFlash(self.number.points[i],0, 0.5, 0.5, false,0, 0)
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
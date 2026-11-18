--[[
Author: Fairlady
Fcp  - Combo Points and Buff/Debuff display addon
contact: cikandin@gmail.com
]]

local FCP2 = LibStub("AceAddon-3.0"):GetAddon("FairComboPoints2")
local Custom = LibStub("AceAddon-3.0"):NewAddon("FCP2_CUSTOM", "AceConsole-3.0")

function Custom:OnInitialize()
	FCP2.db = LibStub("AceDB-3.0"):New("FCP2DB2", defaults, "Default")
	for modName, customModule in FCP2:IterateModules() do
		local point, petbuff
		if customModule.custom == true then
			if FCP2.db.profile.modules[modName].MAX_POINTS then
				customModule.MAX_POINTS = FCP2.db.profile.modules[modName].MAX_POINTS
			end
			if not getglobal(modName.."graphics") then
				customModule.graphics = FCP2:MakeGraphicsFrame(modName, customModule.MAX_POINTS)
				customModule.number = FCP2:MakeNumberFrame(modName, customModule.MAX_POINTS)
			end

			function customModule:OnEnable()
				if not FCP2.db.profile.modules[modName].disableGraphics then
					self.graphics:Show()
				end
				if not FCP2.db.profile.modules[modName].disableNumber then
					self.number:Show()
				end
				self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self:RegisterEvent("UNIT_AURA")
				self:RegisterEvent("UNIT_PET")
				self:PLAYER_TARGET_CHANGED()
			end

			function customModule:OnDisable()
				self.graphics:Hide()
				self.number:Hide()
				self:UnregisterAllEvents()
			end

			function customModule:UNIT_AURA(self, unit)
				if unit ~= "player" then return end
				local count = customModule:checkAura(modName)
				if count and point then
					if count ~= point then
						customModule:UpdateAura(count)
					end
				end
			end

			function customModule:UNIT_PET()
				if petbuff then
					if UnitExists("pet") then
						local count = self:checkAura(modName)
						if count then
							self:UpdateAura(count, true)
						end
					else
						customModule:UpdateAura(0)
					end
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
			function customModule:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
				local _, arg2, arghide, arg3, arg4, arg5, argFlag2, arg6, arg7, arg8, argdestFlag2, arg9, arg10 = ...
				if arg3 ~= UnitGUID("player") and arg3 ~= UnitGUID("pet") then return end
				if UnitIsDead("player") then
					return customModule:UpdateAura(0)
				end
				local count
				if arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_APPLIED_DOSE" or arg2 == "SPELL_AURA_REFRESH" or arg2=="SPELL_AURA_REMOVED" or arg2=="SPELL_AURA_REMOVED_DOSE" or arg2 == "SPELL_AURA_BROKEN" then
					if (arg10 == modName ) then
						local count = self:checkAura(arg10)
						if count then
							if count == 0 then
								customModule:UpdateAura(self.MAX_POINTS)
							else
								customModule:UpdateAura(count)
							end
						else
							customModule:UpdateAura(0)
						end
					end
				end
			end

			--from faircombo1 , check aura

			function customModule:checkAura(AuraName)
				local i = 1
				while UnitAura("player", i) ~= nil do
					local name, _, icon, count = UnitAura("player", i, "PLAYER")
						if AuraName == name then
							if count then return count end
						end
					i = i + 1
				end
				i = 1
				while UnitDebuff("target", i) ~= nil do
					local name, _, icon, count = UnitDebuff("target", i, "PLAYER")
						if AuraName == name then
							if count then return count end
						end
					i = i + 1
				end
				i = 1
				while UnitBuff("target", i) ~= nil do
					local name, _, icon, count = UnitBuff("target", i, "PLAYER")
						if AuraName == name then
							if count then return count end
						end
						i = i+1
					end
				i = 1
				while UnitBuff("pet", i) ~= nil do
					local name, _, icon, count = UnitBuff("pet", i)
					if AuraName == name then
							petbuff = true
						if count then return count end
					end
					i = i+1
				end
			end

			function customModule:PLAYER_TARGET_CHANGED()
				count = self:checkAura(modName)
				if count then
					self:UpdateAura(count, true)
				else
					self:UpdateAura(0)
				end
			end

			function customModule:UpdateAura(count, fire)
				local i, j
				local startTime=GetTime()
				if point and count and point > count then
					for i = self.MAX_POINTS, count+1, -1 do
						if self.graphics.points[i] and self.number.points[i] then
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
				end
				for i = 1, count do
					self.graphics.points[i].icon:SetVertexColor(FCP2:GetColorByPoints(modName, count))
					self.graphics.points[i]:Show()
					self.number.points[i]:Hide()
					self.number.effect[10]:Hide()
					self.number.effect[12]:Hide()
				end
				if count>0 then
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
			end
		end
	end
end
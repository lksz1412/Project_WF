local addonName, ns = ...
local _G = _G
local SSItemLevel = SSItemLevel or ns.SSItemLevel
local fontstrings = {}

local SSInspectItemLevel = CreateFrame("Frame", "SSInspectItemLevel", UIParent)
SSInspectItemLevel:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function SSInspectItemLevel:UpdateItemLevel()
	if(not InspectFrame or not InspectFrame:IsShown()) then return end

	local unit = InspectFrame.unit
	local count, tot, txt = #SSItemLevel.itemslots, 0, nil
	local level = UnitLevel(unit)
	for slot,n in pairs(SSItemLevel.itemslots) do
		local id = GetInventorySlotInfo(n)
		local link = GetInventoryItemLink(unit, id)
		txt = nil
		if link and link ~= "" then
			local ilevel = SSItemLevel:GetItemLevel(unit, link, level, id)
			if (ilevel and ilevel > 0) then
				txt = ilevel
				tot = tot + ilevel
			end
		elseif (n == "SecondaryHandSlot") then
			link = GetInventoryItemLink(unit, 16) -- 주장비
			if (link and link ~= "" and ("INVTYPE_2HWEAPON" == itemEquipLoc or "INVTYPE_RANGED" == itemEquipLoc or "INVTYPE_RANGEDRIGHT")) then
				count = count - 1
			end
		end
		fontstrings[slot]:SetText(txt)
	end
	fontstrings['TOT']:SetText(string.format("평균: %.2f", tot/count))
end

local time = 1
SSInspectItemLevel:SetScript('OnUpdate', function(self, elapsed)
	time = time - elapsed
	if time <= 0 then
		self:UpdateItemLevel()
		time = 1
	end
end)


function SSInspectItemLevel:UNIT_INVENTORY_CHANGED(unit)
	if(InspectFrame.unit == unit) then
		self:UpdateItemLevel()
	end
end

SSInspectItemLevel.PLAYER_TARGET_CHANGED = SSInspectItemLevel.UpdateItemLevel
SSInspectItemLevel.INSPECT_READY = SSInspectItemLevel.UpdateItemLevel


function SSInspectItemLevel:ADDON_LOADED(addon)
	if(addon == "Blizzard_InspectUI") then
		local font, _, flags = NumberFontNormal:GetFont()

		for slot,n in pairs(SSItemLevel.itemslots) do
			local gslot = _G["Inspect"..n]
			fontstrings[slot] = gslot:CreateFontString(nil, "OVERLAY")
			fontstrings[slot]:SetFont(font, 12, flags)
			fontstrings[slot]:SetPoint("TOP", gslot, "TOP", 0, -5)
			fontstrings[slot]:SetTextColor(1,1,1)
		end
		fontstrings['TOT'] = _G["InspectFrame"]:CreateFontString(nil, "OVERLAY")
		fontstrings['TOT']:SetFont(font, 12, flags)
		fontstrings['TOT']:SetPoint("BOTTOMLEFT", _G["InspectFrame"], "BOTTOMLEFT", 8, 14)
		fontstrings['TOT']:SetTextColor(1,1,1)

		self:RegisterEvent('PLAYER_TARGET_CHANGED')
		self:RegisterEvent('UNIT_INVENTORY_CHANGED')

		-- We should check the first argument of this event later on.
		-- Blizzard's code isn't actually updated yet, so it doesn't
		-- check if the GUID is correct, nor if the inspect is ready.
		self:RegisterEvent('INSPECT_READY')

		self:UnregisterEvent("ADDON_LOADED")
		self.ADDON_LOADED = nil
	end
end


SSInspectItemLevel:RegisterEvent('ADDON_LOADED')
local addonName, ns = ...
local _G = _G
local LBI = LibStub("LibBlueItem-1.0")

local itemslots = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"WristSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
}

local fontstrings = {}
-- AVERAGE
local frame = CreateFrame("Frame", "SSItemLevel", UIParent)
frame.scanTooltip = CreateFrame("GameTooltip", "SSItemLevel_ScanTip", nil, "GameTooltipTemplate");
frame.scanTooltip:SetOwner(UIParent, "ANCHOR_NONE");
frame.itemslots = itemslots
local msg = string.gsub(ITEM_LEVEL, "%%d", "(.+)")

ns.SSItemLevel = frame

frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

--[[
function frame:GetScanItemLevel(unit, slot)
	self.scanTooltip:ClearLines()
	self.scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	local hasItem = self.scanTooltip:SetInventoryItem(unit, slot)
	self.scanTooltip:Show()

	if hasItem then
		local numLines = self.scanTooltip:NumLines();
		local iLevel = 0
		for i = 2, min(numLines, 5) do
			local text = _G["SSItemLevel_ScanTipTextLeft" .. i]:GetText() or ""
			local iLevel = string.match(text, msg)
			if iLevel ~= nil then
				self.scanTooltip:Hide()
				return tonumber(iLevel)
			end
		end
	end
	self.scanTooltip:Hide()

	return 0
end
--]]
-- Thanks to Ro of Hyjal-US http://us.battle.net/wow/en/forum/topic/7199032730#9
function frame:GetScanItemLevel(itemLink)
  local levelAdjust={ -- 11th item:id field and level adjustment
["0"]=0,["1"]=8,["373"]=4,["374"]=8,["375"]=4,["376"]=4,
["377"]=4,["379"]=4,["380"]=4,["445"]=0,["446"]=4,["447"]=8,
["451"]=0,["452"]=8,["453"]=0,["454"]=4,["455"]=8,["456"]=0,
["457"]=8,["458"]=0,["459"]=4,["460"]=8,["461"]=12,["462"]=16,
["466"]=4,["467"]=8,["469"]=4,["470"]=8,["471"]=12,["472"]=16,
["477"]=4,["478"]=8,["480"]=8,["492"]=4,["493"]=8,["495"]=4,["496"]=8,["497"]=12,["498"]=16,
["504"]=12,["505"]=16,["506"]=20,["507"]=24}

  local baseLevel = select(4,GetItemInfo(itemLink))
  local upgrade = itemLink:match("item:"..("[^:]+:"):rep(9).."(%d+)")
  if baseLevel and upgrade and levelAdjust[upgrade] then
    return baseLevel + levelAdjust[upgrade]
  else
    return baseLevel
  end
end

function frame:GetItemLevel(unit, itemLink, unitLevel, slot)
--	local _,_,quality,iLevel = GetItemInfo(itemLink)
--	print(GetItemInfo(itemLink))
	local _,_,quality = GetItemInfo(itemLink)
	local iLevel = self:GetScanItemLevel(itemLink)
--	print(itemLink, quality, iLevel, unitLevel)
	if not quality or not iLevel then
		return 0;
	elseif quality == 3 and unitLevel >= 60 then
		return iLevel;
	elseif quality == 2 and unitLevel >= 60 then
		return iLevel;
	elseif quality < 2 then
		return 0;
	elseif quality == 7 then
        if iLevel > 1 then -- 가로쉬 계귀무기들  
            local temp = iLevel + ((620 - iLevel) / 10) * (unitLevel - 90);
            return math.floor(temp+0.5);            
		else -- 여기서부터 일반 계귀들
			local bid = LBI:GetItemLevelBonusID(itemLink)
			if bid then
				if bid == 582 then unitLevel = min(unitLevel, 90)
				elseif bid == 583 then unitLevel = min(unitLevel, 100) end
			else
				unitLevel = min(unitLevel, 60)
			end
			if unitLevel >= 91 and unitLevel <= 100 then
				local temp = 520 + ((600-520)/(100-91)) * (unitLevel-91)
				return math.floor(temp+0.5);       
			elseif unitLevel >= 86 and unitLevel <= 90 then
				local temp = 384 + ((463-384)/(90-86)) * (unitLevel-86)
				return math.floor(temp+0.5);         
			elseif unitLevel >= 81 and unitLevel <= 85 then
				local temp = 279 + ((333-279)/(85-81)) * (unitLevel-81)
				return math.floor(temp+0.5);         
			elseif unitLevel >= 68 and unitLevel <= 80 then
				local temp = 139 + ((187-139)/(80-68)) * (unitLevel-68)
				return math.floor(temp+0.5);      
			elseif unitLevel >= 58 and unitLevel <= 67 then
				local temp = 79 + ((105-79)/(67-58)) * (unitLevel-58)
				return math.floor(temp+0.5);            
			elseif unitLevel <= 57  then 
				return max(unitLevel + 5, 10)
			end
		end
	end
	return iLevel;
end

function frame:UpdateItemLevel()
	local count, tot, txt = #self.itemslots, 0, nil
	for slot,n in pairs(self.itemslots) do
		local id = GetInventorySlotInfo(n)
		local link = GetInventoryItemLink("player", id)
		txt = nil
		if link and link ~= "" then
			local ilevel = self:GetItemLevel("player", link, UnitLevel("player"), id)
			if (ilevel and ilevel > 0) then
				txt = ilevel
				tot = tot + ilevel
			end
		elseif (n == "SecondaryHandSlot") then
			link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot")) -- 주장비
			if link ~= nil and link ~= "" then
				local itemEquipLoc = select(9,GetItemInfo(link))
				if (link and link ~= "" and ("INVTYPE_2HWEAPON" == itemEquipLoc or "INVTYPE_RANGED" == itemEquipLoc or "INVTYPE_RANGEDRIGHT")) then
					count = count - 1
				end
			end
		end
		fontstrings[slot]:SetText(txt)
	end
--	print(count, tot, tot/count)
--	ItemAverage = tot/count
	fontstrings['TOT']:SetText(format("%s: %.2f", ITEMS, tot/count))
end

function frame:ADDON_LOADED(addon)
	if (addonName == addon) then
		local font, _, flags = NumberFontNormal:GetFont()

		for slot,n in pairs(self.itemslots) do
			local gslot = _G["Character"..n]
			fontstrings[slot] = gslot:CreateFontString(nil, "OVERLAY")
			fontstrings[slot]:SetFont(font, 12, flags)
			fontstrings[slot]:SetPoint("TOP", gslot, "TOP", 0, -3)
			fontstrings[slot]:SetTextColor(1,1,1)
		end
		fontstrings['TOT'] = _G["PaperDollFrame"]:CreateFontString(nil, "OVERLAY")
		fontstrings['TOT']:SetFont(CharacterLevelText:GetFont())
		fontstrings['TOT']:SetPoint("TOP", CharacterLevelText, "BOTTOM", 0, -3)
		fontstrings['TOT']:SetTextColor(1,1,0)


--		hooksecurefunc(CharacterLevelText, "SetFormattedText", function (self,...)
--			self:SetText(format("%s\n%s: %.2f", self:GetText(), ITEMS, ItemAverage))
--		end)
		hooksecurefunc("PaperDollFrame_SetLevel", function ()
			local a1, f, a2, x, y = CharacterLevelText:GetPoint()
			CharacterLevelText:SetPoint( a1, f, a2, x, y + 10)
		end)

		_G["PaperDollFrame"]:HookScript("OnShow", function(self, ...)
			frame:UpdateItemLevel()
			frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
		end)

		_G["PaperDollFrame"]:HookScript("OnHide", function(self, ...)
			frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
		end)

		self:UpdateItemLevel()
		self:UnregisterEvent("ADDON_LOADED")
		self.ADDON_LOADED = nil
	end
end

function frame:UNIT_INVENTORY_CHANGED(unit)
	if (unit == "player") then
		self:UpdateItemLevel()
	end
end
frame.UPDATE_INVENTORY_DURABILITY = frame.UpdateItemLevel

frame:RegisterEvent("ADDON_LOADED")

--ns.SSItemLevel = SSItemLevel
local addonName, ns = ...
local _G = _G

local itemslots = {
	"HeadSlot",
	"ShoulderSlot",
	"ChestSlot",
	"WristSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"TabardSlot",
}
local slotID
local fontstrings = {}

local frame = CreateFrame("Frame", "SSItemLevelDurabilityFrame", _G["PaperDollFrame"])
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

SSGetDurability = function (slotID)
	local link = GetInventoryItemLink("player", slotID)
	if not link then return -1 end

	local durability, maximum = GetInventoryItemDurability(slotID)
	if not durability or (maximum == 0) then return -1 end

	return (durability/maximum)
end


function frame:GetDurabilityPercent(slotID)
	local c = SSGetDurability(slotID)
	local p = floor(c * 100 + 0.5)

	if (not SSItemLevelDurability or p < 0) then return "" end

	if (p > 0) then
		return format("|cff%.2x%.2x%.2x%d%%|r", 1*255, c*255, c*255,p)
	end

	return "|cffFF00000|r"
end

function frame:UPDATE_INVENTORY_DURABILITY()
	local id
	for slot,n in pairs(itemslots) do
		id = GetInventorySlotInfo(n)
		if (fontstrings[id] == nil) then
			local font, _, flags = NumberFontNormal:GetFont()
			local gslo
			gslot = _G["Character"..n]
			fontstrings[id] = gslot:CreateFontString(nil, "OVERLAY")
			fontstrings[id]:SetFont(font, 10, flags)
			fontstrings[id]:SetPoint("BOTTOM", gslot, "BOTTOM", 0, 3)
			fontstrings[id]:SetTextColor(1,1,1)
		end
		fontstrings[id]:SetText(self:GetDurabilityPercent(id))
	end
end

function frame:PLAYER_LOGIN()
	--
	if (SSItemLevelDurability == nil) then SSItemLevelDurability = true end

	local font, _, flags = NumberFontNormal:GetFont()
	local check = CreateFrame("CheckButton", addonName.."CheckButton", _G["PaperDollFrame"], "UICheckButtonTemplate")
	check:SetSize(16,16)
	_G[check:GetName() .. "Text"]:SetFont(font, 10, flags)
	_G[check:GetName() .. "Text"]:SetTextColor(1,1,1)
	_G[check:GetName() .. "Text"]:SetText("내구도")
	_G[check:GetName() .. "Text"]:ClearAllPoints()
	_G[check:GetName() .. "Text"]:SetPoint("LEFT", check, "RIGHT", 0, 1)
	check:SetChecked(SSItemLevelDurability)
	check:SetPoint("BOTTOMLEFT", _G["PaperDollFrame"], "BOTTOMLEFT", 6, 4)
	check:SetScript("OnClick", function (self)
		SSItemLevelDurability = self:GetChecked() and true or false
		frame:UPDATE_INVENTORY_DURABILITY()
	end)

	_G["PaperDollFrame"]:HookScript("OnShow", function(self, ...)
		frame:UPDATE_INVENTORY_DURABILITY()
		frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
		frame:RegisterEvent("PLAYER_DEAD")
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		frame:RegisterEvent("PLAYER_UNGHOST")
		frame:RegisterEvent("MERCHANT_UPDATE")
		frame:RegisterEvent("MERCHANT_CLOSED")
	end)

	_G["PaperDollFrame"]:HookScript("OnHide", function(self, ...)
		frame:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		frame:UnregisterEvent("PLAYER_DEAD")
		frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		frame:UnregisterEvent("PLAYER_UNGHOST")
		frame:UnregisterEvent("MERCHANT_UPDATE")
		frame:UnregisterEvent("MERCHANT_CLOSED")
	end)
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end
frame:RegisterEvent("PLAYER_LOGIN")

frame.PLAYER_DEAD				= frame.UPDATE_INVENTORY_DURABILITY
frame.PLAYER_REGEN_ENABLED		= frame.UPDATE_INVENTORY_DURABILITY
frame.PLAYER_UNGHOST			= frame.UPDATE_INVENTORY_DURABILITY
frame.MERCHANT_UPDATE			= frame.UPDATE_INVENTORY_DURABILITY
frame.MERCHANT_CLOSED			= frame.UPDATE_INVENTORY_DURABILITY

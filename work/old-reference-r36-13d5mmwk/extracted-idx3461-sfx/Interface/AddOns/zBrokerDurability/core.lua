local pName = "zBrokerDurability"
local f = CreateFrame("frame")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject(pName, {
  type = "data source",
  text = "0%",
  icon = "Interface\\AddOns\\zBrokerDurability\\icon.tga"
})

function f:Print(text) if text then DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00zBD:|r " .. tostring(text)); end end

f.Defaults = {
	percent = true,
	price = true,
	totals = true,
	reputation = true,
	items = true,
	lowest = true,
}

local wornRepairCost, bagRepairCost, totalRepairCost = 0, 0, 0
local currentDura, totalDura = 0, 0

local itemslots = {
	"HeadSlot",
	"ShoulderSlot",
	"ChestSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"MainHandSlot",
	"SecondaryHandSlot"
}

DurabilityFrame:UnregisterAllEvents()
DurabilityFrame:Hide()

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("MERCHANT_CLOSED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

local function FormatCurrency(amount)
	return format("|cffffd700%ig|r |cffc7c7cf%02is|r |cffeda55f%02ic|r", floor(amount / 10000), floor(mod(amount, 10000) / 100), mod(amount, 100))
end

local function FormatText(text, color)
	return format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, text)
end

local myTip = nil
function dataobj.OnTooltipShow(tip)
	if not tip or not tip.AddLine or not tip.AddDoubleLine then return end
	if not myTip then myTip = CreateFrame("GameTooltip", "zBrokerDurabilityTip") end

	if f.Options.totals then
		tip:AddLine(_G["REPAIR_COST"])
		tip:AddDoubleLine(_G["CURRENTLY_EQUIPPED"], FormatCurrency(wornRepairCost))
		tip:AddDoubleLine(_G["TUTORIAL_TITLE10"], FormatCurrency(bagRepairCost)) --Bags
	end
	
	if f.Options.reputation then
		if f.Options.totals then tip:AddLine(" ") end
		tip:AddLine(_G["REPAIR_ALL_ITEMS"] .. ":")
		tip:AddDoubleLine(FormatText(_G["FACTION_STANDING_LABEL" .. 4], ITEM_QUALITY_COLORS[1]), FormatCurrency(totalRepairCost * 1.00))
		tip:AddDoubleLine(FormatText(_G["FACTION_STANDING_LABEL" .. 5], FACTION_BAR_COLORS[4]),  FormatCurrency(totalRepairCost * 0.95))
		tip:AddDoubleLine(FormatText(_G["FACTION_STANDING_LABEL" .. 6], ITEM_QUALITY_COLORS[2]), FormatCurrency(totalRepairCost * 0.90))
		tip:AddDoubleLine(FormatText(_G["FACTION_STANDING_LABEL" .. 7], ITEM_QUALITY_COLORS[3]), FormatCurrency(totalRepairCost * 0.85))
		tip:AddDoubleLine(FormatText(_G["FACTION_STANDING_LABEL" .. 8], ITEM_QUALITY_COLORS[4]), FormatCurrency(totalRepairCost * 0.80))
	end

	if f.Options.items and totalRepairCost > 0 then
		if f.Options.totals or f.Options.reputation then tip:AddLine(" ") end
		tip:AddLine(_G["REPAIR_AN_ITEM"] .. ":")
		for _, slotName in ipairs(itemslots) do
			local item = _G["Character" .. slotName]
			local hasItem, _, repairCost = myTip:SetInventoryItem("player", item:GetID())
			local slotId = GetInventorySlotInfo(slotName)
			local itemLink = GetInventoryItemLink("player", slotId)
			if itemLink then
				if repairCost > 0 then
					local durability, maximum = GetInventoryItemDurability(slotId)
					tip:AddDoubleLine(format("(%02i%%) ", floor(durability / maximum * 100)) .. FormatText(select(1, GetItemInfo(itemLink)), ITEM_QUALITY_COLORS[select(3, GetItemInfo(itemLink))]), FormatCurrency(repairCost))
				end
			end
		end
	end
end

function f:SlashCommandHandler(msg)
	if msg == "" then -- No arguments, print current options status
		self:Print("Options")
		for key, val in pairs(self.Options) do
			self:Print(key .. " - " .. tostring(val))
		end
	end
	
	for key, val in pairs(self.Options) do
		if msg:lower() == key then
			self.Options[key] = not val
			self:Print("Changed " .. key .. " - now " .. tostring(self.Options[key]))
		end
	end
	
	self:Update()
end

function f:Update(event, addon)
	if event == "ADDON_LOADED" and addon == "zBrokerDurability" then
		if not zBD then zBD = {} end
		-- Recursively create / update options table with default options if not yet set
		local function updateTable(source, dest)
			if not dest then dest = {} end
			for key, val in pairs(source) do
				if type(val) == "table" then
					updateTable(val, dest[key])
				else
					if dest[key] == nil then dest[key] = val end
				end
			end
		end
		updateTable(self.Defaults, zBD)
		self.Options = zBD;

		SLASH_ZBROKERDURABILITY1 = "/zbd"
		SlashCmdList["ZBROKERDURABILITY"] = function(msg) self:SlashCommandHandler(msg) end
	elseif event ~= "ADDON_LOADED" then
		currentDura, totalDura, minDura = 0, 0, 100
		for _, slotName in ipairs(itemslots) do
			local durability = 0
			local slotId = GetInventorySlotInfo(slotName)
			local itemLink = GetInventoryItemLink("player", slotId)
			if itemLink then
				local durability, maximum = GetInventoryItemDurability(slotId)
				if maximum then
					currentDura = currentDura + durability
					totalDura = totalDura + maximum
					if floor(durability / maximum * 100) < minDura then minDura = floor(durability / maximum * 100) end
				end
			end
		end
		
		local tDura = floor(currentDura / totalDura * 100)
		if self.Options.lowest then tDura = minDura end
		
		if not myTip then myTip = CreateFrame("GameTooltip", "zBrokerDurabilityTip") end
		
		wornRepairCost = 0
		for _, slotName in ipairs(itemslots) do
			local item = _G["Character" .. slotName]
			local hasItem, _, repairCost = myTip:SetInventoryItem("player", item:GetID())

			if hasItem and repairCost and repairCost > 0 then
				wornRepairCost = wornRepairCost + repairCost
			end
		end

		bagRepairCost = 0
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local hasCooldown, repairCost = myTip:SetBagItem(bag, slot)

				if repairCost and repairCost > 0 then
					bagRepairCost = bagRepairCost + repairCost
				end
			end
		end

		totalRepairCost = wornRepairCost + bagRepairCost

		local dColor = ""
		if tDura >= 80 then
			dColor = "|cff00FF00"
		elseif tDura >= 60 then
			dColor = "|cff99FF00"
		elseif tDura >= 40 then
			dColor = "|cffFFFF00"
		elseif tDura >= 20 then
			dColor = "|cffFF9900"
		elseif tDura >= 0 then
			dColor = "|cffFF2000"
		end

		dataobj.text = (self.Options.percent and dColor .. tDura .. "%|r" or "") .. (self.Options.price and (tDura == 100 and "" or " (" .. FormatCurrency(totalRepairCost) .. ")") or "")
	end
end
f:SetScript("OnEvent", function(self, event, ...) return self.Update(self, event, ...) end)
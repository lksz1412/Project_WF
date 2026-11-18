local AceAddon = LibStub("AceAddon-3.0")
BlueItemLink = AceAddon:NewAddon("BlueItemLink", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0")
BlueItemLink.title = "Blue Item Link"
BlueItemLink.version = "1.3"
BlueItemLink.frameIndex = 0

local ItemPriceTooltip = AceAddon:GetAddon("ItemPriceTooltip", true)
local StatStain = AceAddon:GetAddon("StatStain", true)

if not BluePrint then function BluePrint() end end

local consoleOptions = {
	name = "Blue Item Link",
	desc = "다수의 아이템 링크를 표시합니다.",
	type = "group",
	args = {
		descript = {
			type = "description",
			name = "화면에 다수의 링크를 표시해주는 애드온입니다.\n",
			order = 5,
		},
		chatlink = {
			type = "toggle",
			name = "채팅창 링크 보기",
			desc = "체크하면 채팅창에 링크되는 아이템을 마우스 오버로 볼 수 있습니다.",
			get = function() return BlueItemLink.db.profile.chat end,
			set = function()
				BlueItemLink.db.profile.chat = not BlueItemLink.db.profile.chat
				BlueItemLink:ChatFrameOnHyperlink()
			end,
			order = 10,
		},
		scale = {
			type = "range",
			name = "크기 조절",
			desc = "프레임의 크기를 조절합니다.",
			get = function()
				return BlueItemLink.db.profile.scale
			end,
			set = function(key, value)
				BlueItemLink.db.profile.scale = value
				BlueItemLink:Scale()

			end,
			min = 0.5,
			max = 2.0,
			step = 0.01,
			order = 20,
		},
	}
}

local default = {
	profile = {
		pos = {},
		scale = 1.0,
		chat = true
	},
}

local function GetItemValue(link)
	if link then
		local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(link)
		if not(itemLink) then
			itemLink = link
		end
		local _, _, itemID = strfind(itemLink, "item:(%d+)")
		local _, _, enchantID = strfind(itemLink, "enchant:(%d+)")
		if itemID then
			return itemLink, tonumber(itemID), itemTexture, itemName, itemRarity
		elseif enchantID then
			return itemLink, -tonumber(enchantID)
		else
			return nil
		end
	end
end

function BlueItemLink:SupportedAddons(frame, itemLink, itemID, itemName, itemTexture)
	-- 툴팁 후킹이 필요한 타 애드온 지원
	if itemID > 0 then

		if ItemPriceTooltip then
			ItemPriceTooltip:AddPrice(frame, 1, itemID)
		end
		if (RatingBuster) then
			RatingBuster.ProcessTooltip(frame, nil, itemLink)
		end
		if (BlueCatPoint) then
			BlueCatPoint.ProcessTooltip(frame, nil, itemLink)
		end
		if (TankPoints and TankPointsTooltips) then
			TankPointsTooltips.ProcessTooltip(frame, nil, itemLink)
		end
		if (Mendeleev and Mendeleev.ParseTooltip) then -- supported Mendleev (by fenlis)
			Mendeleev:ParseTooltip(frame, itemLink)
		end
		if (TradeskillInfo) then
			TradeskillInfo:AddToTooltip(frame, itemID)
		end
		if (ReagentHeaven_ModifyTooltip) then
			ReagentHeaven_ModifyTooltip(frame)
		end
		if (WhoDrop) then
			WhoDrop:AddInfoToTooltip(frame, itemLink)
		end
		if (NuguDrop_OnShow) then
			NuguDrop_OnShow(frame:GetName())
		end
		if (Whats) then
			Whats.ProcessTooltip(frame, nil, itemLink)
		end
	end
	if (BlueItemInfo) then
		BlueItemInfo.ProcessTooltip(frame, nil, itemLink)
	end
	if (BlueItemInfo2) then
		BlueItemInfo2.ProcessTooltip(frame, nil, itemLink)
	end
	if (BlueCraftInfo) then
		BlueCraftInfo.ProcessTooltip(frame, nil, itemLink)
	end
end

function BlueItemLink:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("BlueItemLinkDB", default, "Default")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BlueItemLink", consoleOptions, "bil", "blueitemlink")

	local ACR = LibStub("AceConfigRegistry-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	ACR:RegisterOptionsTable("Blue Item Link", consoleOptions)
	ACR:RegisterOptionsTable("Blue Item Link Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
	ACD:AddToBlizOptions("Blue Item Link", "Blue Item Link")
	ACD:AddToBlizOptions("Blue Item Link Profiles", "프로필", "Blue Item Link")
end

function BlueItemLink:OnEnable()
	self.prevSetItemRef = SetItemRef
	SetItemRef = function(link, text, button) self:SetItemRef(link, text, button) end
	self:ChatFrameOnHyperlink()
end

function BlueItemLink:SetItemRef(link, text, button)
	local itemLink = GetItemValue(link)
	if IsModifierKeyDown() or self:CheckLink(link) == false then
		self.prevSetItemRef(link, text, button)
	else
		local frame = self:FindFrame(itemLink or link)
		if frame then
			frame:Hide()
		else
			self:OpenLink(itemLink or link)
		end
	end
end

function BlueItemLink:CheckLink(link)
	if link then
		if strfind(link, "item:") then
			return true
		elseif strfind(link, "enchant:") then
			return true
		elseif strfind(link, "spell:") then
			return true
		elseif strfind(link, "quest:") then
			return true
		--elseif strfind(link, "action:") then
		--	return true
		else
			return false
		end
	else
		return false
	end
end

function BlueItemLink:OpenLink(link, frame)
	if self:CheckLink(link) then
		frame = frame or self:GetEmptyFrame()
		local textureFrame = getglobal(frame:GetName().."ItemTexture")
		local itemLink, itemID, texture, itemName = GetItemValue(link)
		frame:SetOwner(UIParent, "ANCHOR_PRESERVE")
		frame:ClearLines()
		if itemLink then
			frame:SetHyperlink(itemLink)
			frame.itemLink = itemLink
			self:SupportedAddons(frame, itemLink, itemID, itemName, itemTexture)
		else
			frame:SetHyperlink(link)
			frame.link = link
		end
		if texture then
			textureFrame:SetTexture(texture)
			textureFrame:Show()
		else
			textureFrame:Hide()
		end
		frame:Show()
		if itemID then
			self:SendMessage("BlueItemLink_OpenLink", frame, itemLink, itemID, itemName, itemTexture)
		end
	end
end

function BlueItemLink:OnLoad()
	tinsert(UISpecialFrames, this:GetName())
	this:SetClampedToScreen(true)
	this:SetPadding(16)
	this:SetBackdropColor(0.09, 0.12, 0.09)
	this:RegisterForDrag("LeftButton")
	this.link = nil
	this.itemLink = nil
	this.itemID = nil
end

function BlueItemLink:OnClick(button, itemLink, isMoving)
	itemLink = itemLink or this.itemLink or this.link
	if not(itemLink) or isMoving then
		return
	end
	local _, _, itemID = strfind(itemLink, "item:(%d+)")
	local _, _, enchantID = strfind(itemLink, "enchant:(%d+)")
	local name = getglobal(this:GetName().."TextLeft1"):GetText()
	if itemID or enchantID then
		local id = tonumber(itemID) or -tonumber(enchantID)
		if IsControlKeyDown() and IsShiftKeyDown() and BlueItemInfo2 then
			BlueItemInfo2:AddMemo(id)
		elseif IsShiftKeyDown() then
			if enchantID then
				ChatFrameEditBox:Show()
				ChatFrameEditBox:Insert("|cffffd000|Henchant:"..enchantID.."|h["..gsub(name, "마법부여: ", "").."]|h|r")
			elseif AuctionFrame and AuctionFrame:IsVisible() and BrowseName:IsVisible() then
				BrowseName:SetText(name)
			else
				ChatFrameEditBox:Show()
				ChatFrameEditBox:Insert(itemLink)
			end
		elseif IsAltKeyDown() then
			if BlueItemInfo2 then
				BlueItemInfo2:AddFavoriteItem(id)
			elseif BlueItemInfoFavorite then
				BlueItemInfoFavorite:Process(id)
			end
		elseif IsControlKeyDown() then
			DressUpItemLink(itemLink)
		end
	end
end

function BlueItemLink:FindFrame(link)
	local itemLink = GetItemValue(link)
	for i = 1, self.frameIndex do
		local frame = getglobal("BlueItemLink"..i)
		if (itemLink and frame.itemLink == itemLink) or (link and frame.link == link) then
			return frame, i
		elseif link == nil and frame.itemLink == nil and frame.link == nil then
			return frame, i
		end
	end
	return nil
end

function BlueItemLink:GetEmptyFrame()
	local frame = self:FindFrame(nil)
	return frame or self:CreateFrame()
end

function BlueItemLink:CreateFrame()
	self.frameIndex = self.frameIndex + 1
	local frame = CreateFrame("GameTooltip", "BlueItemLink"..self.frameIndex, UIParent, "BlueItemLinkTemplate")
	frame:SetID(self.frameIndex)
	frame.isNew = true
	if not(self.db.profile.pos) then
		self.db.profile.pos = {}
	end
	if not(self.db.profile.scale) then
		self.db.profile.scale = 1.0
	end
	self:Reset(frame)
	if (ItemsInEnglish) then
		frame:SetScript("OnShow", function() ItemsInEnglish:SetNewTooltip(frame) end)
	end
	if (Mendeleev and Mendeleev.OnTooltipSetItem) then -- supported Mendleev (by fenlis)
		Mendeleev:HookScript(frame, "OnTooltipSetItem")
	end
	if StatStain then
		StatStain:AddTooltip(frame)
	end
	if (Skinner) then -- supported Skinner (by fenlis)
		if Skinner.db.profile.Tooltips.style == 3 then frame:SetBackdrop(backdrop) end
		Skinner:skinTooltip(frame)
		if not Skinner:IsHooked(frame, "SetBackdropColor") then
			Skinner:Hook(frame, "SetBackdropColor", function(r, g, b, a) end, true)
		end
		if not Skinner:IsHooked(frame, "OnHide") then
			Skinner:HookScript(frame, "OnHide", function(object)
				Skinner.hooks[frame].OnHide(object)
				if Skinner:IsHooked(frame, "SetBackdropColor") then Skinner:Unhook(frame, "SetBackdropColor") end
			end)
		end
	end
	return frame
end

function BlueItemLink:ChatFrameOnHyperlink()
	if self.db.profile.chat then
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = getglobal("ChatFrame"..i)
			frame:SetScript("OnHyperlinkEnter", function(arg1, arg2)
				local link = (type(arg1) == "string") and arg1 or arg2
				if self:CheckLink(link) then
					GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
					GameTooltip:SetHyperlink(link)
					GameTooltip:Show()
				end
			end)
			frame:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
		end
	else
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = getglobal("ChatFrame"..i)
			frame:SetScript("OnHyperlinkEnter", nil)
			frame:SetScript("OnHyperlinkLeave", nil)
		end
	end
end

function BlueItemLink:SavePosition(frame, id)
	local s = frame:GetEffectiveScale()
	local ws = UIParent:GetEffectiveScale()
	local x = frame:GetLeft() * s
	local y = frame:GetTop() * s - UIParent:GetTop() * ws
	self.db.profile.pos[id] = { x, y }
end

function BlueItemLink:Scale()
	for i = 1, self.frameIndex do
		self:Reset(getglobal("BlueItemLink"..i))
	end
end

function BlueItemLink:Reset(frame)
	local id = tonumber(frame:GetID())
	frame:SetScale(self.db.profile.scale)
	if self.db.profile.pos[id] then
		local s = frame:GetEffectiveScale()
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self.db.profile.pos[id][1] / s, self.db.profile.pos[id][2] / s)
	end
end

function BlueItemLink:SetCompareItem()
	if (not this.itemLink) then
		return
	end
	local item1, item2, side
	if ( ShoppingTooltip1:SetHyperlinkCompareItem(this.itemLink, 1) ) then
		item1 = true
	end
	if ( ShoppingTooltip2:SetHyperlinkCompareItem(this.itemLink, 2) ) then
		item2 = true
	end
	local rightDist = GetScreenWidth() - this:GetRight()
	if (rightDist < this:GetLeft()) then
		side = 1
	else
		side = 2
	end
	if item1 then
		ShoppingTooltip1:SetOwner(this, "ANCHOR_NONE")
		ShoppingTooltip1:ClearAllPoints()
		if side == 1 then
			ShoppingTooltip1:SetPoint("TOPRIGHT", this, "TOPLEFT", 0, -45)
		else
			ShoppingTooltip1:SetPoint("TOPLEFT", this, "TOPRIGHT", 0, -10)
		end
		ShoppingTooltip1:SetHyperlinkCompareItem(this.itemLink, 1)
		ShoppingTooltip1:Show()
		if item2 then
			ShoppingTooltip2:SetOwner(ShoppingTooltip1, "ANCHOR_NONE")
			ShoppingTooltip2:ClearAllPoints()
			if side == 1 then
				ShoppingTooltip2:SetPoint("TOPRIGHT", "ShoppingTooltip1", "TOPLEFT", 0, 0)
			else
				ShoppingTooltip2:SetPoint("TOPLEFT", "ShoppingTooltip1", "TOPRIGHT", 0, 0)
			end
			ShoppingTooltip2:SetHyperlinkCompareItem(this.itemLink, 2)
			ShoppingTooltip2:Show()
		end
	end
end
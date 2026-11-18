local addOnName = ...
local BIL = CreateFrame("Frame", addOnName)
BIL:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
BIL:RegisterEvent("ADDON_LOADED")

local _G = _G
local min = _G.min
local type = _G.type
local unpack = _G.unpack
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local tonumber = _G.tonumber
local strchar = _G.strchar
local tinsert = _G.table.insert
local tremove = _G.table.remove
local GetItemIcon = _G.GetItemIcon
local GetItemInfo = _G.GetItemInfo
local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local GetAchievementInfo = _G.GetAchievementInfo
local IsModifiedClick = _G.IsModifiedClick

BIL.tooltips = {}

local linkTypes = { item = true, spell = true, enchant = true, achievement = true, unit = true, quest = true }
local linkType, linkId, _

function BIL:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
	if BlueItemLinkDB then
		if BlueItemLinkDB.profiles or not BlueItemLinkDB.scale then
			BlueItemLinkDB = nil
		elseif BlueItemLinkDB[1] then
			for p in pairs(BlueItemLinkDB) do
				if type(p) == "number" then
					BlueItemLinkDB[p] = nil
				end
			end
			BlueItemLinkDB.talentID = nil
			BlueItemLinkDB.questID = nil
			BlueItemLinkDB.enchantID = nil
			BlueItemLinkDB.achievementID = nil
			BlueItemLinkDB.itemID = nil
			BlueItemLinkDB.spellID = nil
		end
	end
	if not BlueItemLinkDB then
		BlueItemLinkDB = { scale = 1, escHide = true, showIcon = true }
	end
	self.db = BlueItemLinkDB
	local optf = CreateFrame("Frame", "BlueItemLinkOptionFrame", InterfaceOptionsFramePanelContainer)
	optf:Hide()
	optf.name = "블루 아이템 링크"
	optf:SetScript("OnShow", function()
		BlueItemLink:CreateOptionFrame()
	end)
	InterfaceOptions_AddCategory(optf)
	-- 슬래쉬 커맨드 등록
	SLASH_BLUEITEMLINK1 = "/blueitemlink"
	SLASH_BLUEITEMLINK2 = "/bil"
	SlashCmdList["BLUEITEMLINK"] = function()
		if InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == BlueItemLinkOptionFrame then
			InterfaceOptionsFrame_Show()
		else
			InterfaceOptionsFrame_Show()
			InterfaceOptionsFrame_OpenToCategory(BlueItemLinkOptionFrame)
		end
	end
	self:SetScript("OnUpdate", function(self, timer)
		self.timer = (self.timer or 0) + timer
		if self.timer > 2 then
			self.timer = nil
			self:SetScript("OnUpdate", nil)
			ItemRefTooltip:Hide()
			ItemRefTooltip.SetOwner = function(self)
				getmetatable(ItemRefTooltip).__index.SetOwner(self, UIParent, "ANCHOR_NONE")
			end
			hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(self, link)
				if type(link) == "string" then
					for _, t in ipairs(BIL.tooltips) do
						if t.link == link then
							t:Hide()
							self:Hide()
							self._bil.linked, self._bil.lines = nil
							self._bil:Hide()
							return
						end
					end
					if self:IsShown() then
						linkType, linkId = link:match("^([^:]+):(%d+)")
						if linkTypes[linkType] then
							BIL:SetRefTooltip(linkType, tonumber(linkId), link)
							linkType, linkId = nil
							return
						elseif linkType ~= "trade" then
							BIL:SetRefTooltip(nil, nil, link)
							linkType, linkId = nil
							return
						end
					end
				end
				self._bil.linked, self._bil.lines = nil
				self._bil:Hide()
			end)
			ItemRefTooltip._bil = CreateFrame("Frame", nil, ItemRefTooltip)
			ItemRefTooltip._bil:SetScript("OnUpdate", function(self)
				if self.linked and self.lines ~= ItemRefTooltip:NumLines() then
					self.lines = ItemRefTooltip:NumLines()
					BIL:CopyTooltip(self.linked)
				end
			end)
		end
	end)
end

function BIL:SetRefTooltip(tp, id, link)
	local tip
	for _, t in ipairs(self.tooltips) do
		if t:IsShown() then
			if t.link == link then
				t:Hide()
				ItemRefTooltip:Hide()
				ItemRefTooltip._bil:Hide()
				ItemRefTooltip._bil.linked, ItemRefTooltip._bil.lines = nil
				return
			end
		else
			tip = t
		end
	end
	tip = tip or self:CreateTooltip()
	tip.linkType, tip.id, tip.link = tp, id, link
	ItemRefTooltip._bil.lines = ItemRefTooltip:NumLines()
	ItemRefTooltip._bil.linked = tip
	ItemRefTooltip._bil:Show()
	self:CopyTooltip(tip)
end

local left, right, lr, lg, lb, rr, rg, rb, text, texture, textureIndex, moneyIndex

function BIL:CopyTooltip(tip)
	tip.noHide = true
	tip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	tip:ClearLines()
	tip.noHide = nil
	tip:SetMinimumWidth(ItemRefTooltip:GetWidth(), true)
	money, moneyIndex = ItemRefTooltipMoneyFrame1, 1
	texture, textureIndex = ItemRefTooltipTexture1, 1
	for i = 1, ItemRefTooltip:NumLines() do
		left = _G["ItemRefTooltipTextLeft"..i]
		if money and money:IsShown() and select(2, money:GetPoint()) == left then
			SetTooltipMoney(tip, money.staticMoney or 0, "STATIC", _G["ItemRefTooltipMoneyFrame"..moneyIndex.."PrefixText"]:GetText(), nil)
			moneyIndex = moneyIndex + 1
			moeny = _G["ItemRefTooltipMoneyFrame"..moneyIndex]
		elseif left:IsShown() then
			lr, lg, lb = left:GetTextColor()
			right = _G["ItemRefTooltipTextRight"..i]
			if right:IsShown() and right:GetText() and right:GetText() ~= "" then
				rr, rg, rb = right:GetTextColor()
				tip:AddDoubleLine(left:GetText(), right:GetText(), lr, lg, lb, rr, rg, rb)
			else
				tip:AddLine(left:GetText(), lr, lg, lb, 1)
			end
			if texture and texture:IsShown() and select(2, texture:GetPoint()) == left then
				if type(texture:GetTexture()) == "string" then
					tip:AddTexture(texture:GetTexture())
				end
				textureIndex = textureIndex + 1
				texture = _G["ItemRefTooltipTexture"..textureIndex]
			end
		end
	end
	left, right, lr, lg, lb, rr, rg, rb, text, texture, textureIndex, moneyIndex = nil
	tip:Show()
	if ItemRefTooltip:GetSpell() then
		if tip.linkType == "enchant" then
			tip.realLink = ("|cffffd000|H%s|h[%s]|h|r"):format(tip.link, _G[tip:GetName().."TextLeft1"]:GetText())
		else
			tip.realLink = GetSpellLink(select(3, ItemRefTooltip:GetSpell()))
		end
		tip.icon:SetTexture(self.db.showIcon and select(3, GetSpellInfo(select(3, ItemRefTooltip:GetSpell()))) or nil)
	elseif select(2, ItemRefTooltip:GetItem()) then
		tip.realLink = select(2, ItemRefTooltip:GetItem())
		tip.icon:SetTexture(self.db.showIcon and GetItemIcon(tip.realLink) or nil)
	elseif tip.linkType == "achievement" then
		tip.realLink = ("|cffffff00|H%s|h[%s]|h|r"):format(tip.link, _G[tip:GetName().."TextLeft1"]:GetText())
		tip.icon:SetTexture(self.db.showIcon and select(10, GetAchievementInfo(tip.id)) or nil)
	elseif tip.linkType == "quest" then
		tip.realLink = ("|cffffff00|H%s|h[%s]|h|r"):format(tip.link, _G[tip:GetName().."TextLeft1"]:GetText())
		tip.icon:SetTexture(self.db.showIcon and "Interface\\Icons\\INV_Scroll_11" or nil)
	else
		tip.realLink = nil
		tip.icon:SetTexture(nil)
	end
end

local function tipOnClick(self, button)
	if button == "LeftButton" and IsModifiedClick() and self.realLink and not(BlueItemInfo3 and BlueItemInfo3:ModifiedItemClick(self.realLink)) then
		HandleModifiedItemClick(GetFixedLink(self.realLink))
	end
end

local function tipOnEnter(self)
	BIL.enter = self
	if self.linkType == "item" and self.link then
		BIL:RegisterEvent("MODIFIER_STATE_CHANGED")
		BIL:MODIFIER_STATE_CHANGED()
	end
end

local function tipOnLeave(self)
	BIL.enter = nil
	if self.linkType == "item" and self.link then
		BIL:UnregisterEvent("MODIFIER_STATE_CHANGED")
		BIL:SetScript("OnUpdate", nil)
		ResetCursor()
		for _, tip in pairs(self.shoppingTooltips) do
			tip:Hide()
		end
	end
end

local function tipOnHide(self)
	if not self.noHide then
		if ItemRefTooltip._bil.linked == self then
			ItemRefTooltip:Hide()
		end
		self.linkType, self.id, self.link, self.realLink = nil
	end
end

local function tipGetItem(self)
	if self.linkType == "item" and self.link and self.realLink then
		return self.realLink:match("|h%[(.-)%]|h") or "", self.realLink
	else
		return nil
	end
end

local enableSkinner = nil

if Skinner then
	enableSkinner = function(self)
		if Skinner.db and Skinner.db.profile.Tooltips.skin then
			if Skinner.db.profile.Tooltips.style == 3 then
				self:SetBackdrop(Skinner.backdrop)
			end
			Skinner:skinTooltip(self)
			self:SetBackdropBorderColor(Skinner:setTTBBC())
		end
	end
end

function BIL:CreateTooltip()
	local tip = CreateFrame("GameTooltip", addOnName..(#self.tooltips + 1), UIParent, "GameTooltipTemplate")
	GameTooltip_OnLoad(tip)
	tip:Hide()
	tip:SetFrameStrata("HIGH")
	tip:SetToplevel(true)
	tip:SetMovable(true)
	tip:SetScale(self.db.scale)
	tip:SetUserPlaced(true)
	tip:SetPoint("CENTER", 0, 0)
	tip:SetClampedToScreen(true)
	tip:EnableMouse(true)
	tip:RegisterForDrag("LeftButton")
	tip:SetScript("OnDragStart", tip.StartMoving)
	tip:SetScript("OnDragStop", tip.StopMovingOrSizing)
	tip:SetScript("OnEnter", tipOnEnter)
	tip:SetScript("OnLeave", tipOnLeave)
	tip:SetScript("OnHide", tipOnHide)
	tip:SetScript("OnMouseUp", tipOnClick)
	tip:SetScript("OnShow", enableSkinner)
	tip.closeButton = CreateFrame("Button", nil, tip, "UIPanelCloseButton")
	tip.closeButton:SetPoint("TOPRIGHT", 1, 0)
	tip.icon = tip:CreateTexture(nil, "OVERLAY")
	tip.icon:SetSize(40, 40)
	tip.icon:SetPoint("TOPRIGHT", tip, "TOPLEFT", 1, -3)
	tip.shoppingTooltips = ItemRefTooltip.shoppingTooltips
	tip.GetItem = tipGetItem
	if self.db.escHide then
		tinsert(UISpecialFrames, tip:GetName())
	end
	tinsert(self.tooltips, tip)
	return tip
end

function BIL:MODIFIER_STATE_CHANGED()
	if self.enter and self.enter.linkType == "item" and self.enter.link then
		BIL:SetScript("OnUpdate", nil)
		ResetCursor()
		if false and IsModifiedClick("CHATLINK") then

		elseif IsModifiedClick("COMPAREITEMS") then
			return GameTooltip_ShowCompareItem(self.enter, 1)
		elseif IsModifiedClick("DRESSUP") and IsDressableItem(self.enter.link) then
			self:SetScript("OnUpdate", ShowInspectCursor)
		end
		for _, tip in pairs(self.enter.shoppingTooltips) do
			tip:Hide()
		end
	end
end

function BIL:SetScale()
	for _, frame in ipairs(self.tooltips) do
		frame:SetScale(BlueItemLinkDB.scale)
		frame:Show()
	end
end
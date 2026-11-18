BlueItemLink = CreateFrame("Frame")
BlueItemLink:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
BlueItemLink:RegisterEvent("ADDON_LOADED")

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
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsModifiedClick = _G.IsModifiedClick

local spliter = strchar(124)
local simpleLink = spliter.."H(.+)"..spliter.."h%["
local nameLink = spliter.."h%[(.+)%]"..spliter.."h"
local linkTypes = { unit = true, item = "아이템ID: ", enchant = "조제법ID: ", quest = "퀘스트ID: ", spell = "주문ID: ", achievement = "업적ID: ", talent = "특성ID :" }
local linkText = {
	enchant = "|cffffd000|H%s|h[%s]|h|r", quest = "|cffffff00|H%s|h[%s]|h|r", talent = "|cff4e96f7|H%s|h[%s]|h|r", achievement = "|cffffff00|H%s|h[%s]|h|r"
}

local leftText, leftR, leftG, leftB, rightText, rightR, rightG, rightB, texture, texturePos, linkType, moneyValue, moneyAnchor, moneyText, addInfo
local textures = {}
local tooltipID, ItemRefTooltipOwnerParent, ItemRefTooltipOwnerAnchor
local tempTooltip = CreateFrame("GameTooltip", nil, UIParent)
local build = tonumber(select(2, GetBuildInfo()) or 0)

function BlueItemLink:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	-- 옵션 창 생성
	local optf = CreateFrame("Frame", "BlueItemLinkOptionFrame", InterfaceOptionsFramePanelContainer)
	optf:Hide()
	optf.name = "BlueItemLink"
	optf:SetScript("OnShow", function()
		BlueItemLink:CreateOptionFrame()
	end)
	InterfaceOptions_AddCategory(optf)
	-- 슬래쉬 커맨드 등록
	SLASH_BLUEITEMLINK1 = "/blueitemlink"
	SLASH_BLUEITEMLINK2 = "/bil"
	SlashCmdList["BLUEITEMLINK"] = function()
		InterfaceOptionsFrame_OpenToCategory(BlueItemLinkOptionFrame)
	end
	-- 설정값 정의
	if BlueItemLinkDB and (BlueItemLinkDB.profiles or BlueItemLinkDB.scale == nil) then
		BlueItemLinkDB = nil
	end
	BlueItemLinkDB = BlueItemLinkDB or {
		scale = 1.0, escHide = true, showIcon = true,
		itemID = false, enchantID = false, questID = false,
		spellID = false, achievementID = false, talentID = false,
	}
	-- 채팅창 링크 사전 확인
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i]:HookScript("OnHyperlinkEnter", self.OnHyperlinkEnter)
	end
	-- 변수 초기화
	self.tooltips = {}
	self.savedLink = {}
	self.left = {}
	self.right = {}
	self:Hide()
	self.startTimer = 0
	self:SetScript("OnUpdate", function(self, timer)
		self.startTimer = self.startTimer + timer
		if self.startTimer > 2 then
			self.startTimer = nil
			self:SetScript("OnUpdate", nil)
			hooksecurefunc(ItemRefTooltip, "SetOwner", self.ItemRefTooltipSetOwner)
			hooksecurefunc(ItemRefTooltip, "SetHyperlink", self.ItemRefTooltipSetHyperlink)
			self:RegisterEvent("MODIFIER_STATE_CHANGED")
		end
	end)
	self:Show()
end

function BlueItemLink:OnHyperlinkEnter(link, link2)
	link = type(link) == "string" and link or link2
	if link and link:find("item:") and not GetItemInfo(link) then
		tempTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		tempTooltip:SetHyperlink(link)
		tempTooltip:Show()
	end
end

function BlueItemLink:ItemRefTooltipSetOwner(...)
	ItemRefTooltipOwnerParent, ItemRefTooltipOwnerAnchor = ...
end

function BlueItemLink:ItemRefTooltipSetHyperlink(link)
	if ItemRefTooltipOwnerParent == UIParent and ItemRefTooltipOwnerAnchor == "ANCHOR_PRESERVE" and link then
		link = link:match(simpleLink) or link
		linkType = (":"):split(link, 2)
		if linkType and linkTypes[linkType] then
			BlueItemLink:Process(link, linkType)
			self:Hide()
		end
	end
end

function BlueItemLink:Process(link, linkType)
	if self.savedLink[link] then
		if self.tooltips[self.savedLink[link]] then
			if self.tooltips[self.savedLink[link]]:IsShown() then
				self.tooltips[self.savedLink[link]]:Hide()
			else
				self:SetTooltip(link, linkType, self.tooltips[self.savedLink[link]])
			end
		end
	else
		self:SetTooltip(link, linkType, nil)
	end
end

function BlueItemLink:GetLinkFrame()
	for _, frame in ipairs(self.tooltips) do
		if frame.link == nil then
			return frame
		end
	end
	return self:CreateTooltip()
end

function BlueItemLink:CreateTooltip()
	-- 툴팁 생성
	tooltipID = #self.tooltips + 1
	BlueItemLinkDB[tooltipID] = BlueItemLinkDB[tooltipID] or { "CENTER", 0, 0 }
	if #BlueItemLinkDB[tooltipID] == 2 then
		BlueItemLinkDB[tooltipID][1], BlueItemLinkDB[tooltipID][2], BlueItemLinkDB[tooltipID][3] = "CENTER", 0, 0
	end
	local f = CreateFrame("GameTooltip", "BlueItemLink"..tooltipID, UIParent, "GameTooltipTemplate")
	GameTooltip_OnLoad(f)
	f:SetID(tooltipID)
	f.frameName = f:GetName()
	f.db = BlueItemLinkDB[tooltipID]
	f:SetFrameStrata("HIGH")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetPadding(16)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnMouseDown", self.OnClick)
	f:SetScript("OnDragStart", self.OnDragStart)
	f:SetScript("OnDragStop", self.OnDragStop)
	f:SetScript("OnEnter", self.OnEnter)
	f:SetScript("OnLeave", self.OnLeave)
	f:SetScript("OnHide", self.OnHide)
	f:SetScale(BlueItemLinkDB.scale)
	if BlueItemLinkDB.escHide then
		tinsert(UISpecialFrames, f.frameName)
	end
	f.closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	f.closeButton:SetPoint("TOPRIGHT", 1, 0)
	f.icon = f:CreateTexture(nil, "OVERLAY")
	f.icon:SetWidth(40)
	f.icon:SetHeight(40)
	f.icon:SetPoint("TOPRIGHT", f, "TOPLEFT", 1, -3)
	if BlueItemLinkDB.showIcon then
		f.icon:Show()
	else
		f.icon:Hide()
	end
	f:SetPoint(unpack(f.db))
	f.firstLine = _G[f.frameName.."TextLeft1"]
	f.firstLine:SetFontObject("GameTooltipText")
	_G[f.frameName.."TextRight1"]:SetFontObject("GameTooltipText")
	f.SetTooltipInfo = self.SetTooltipInfo
	tinsert(self.tooltips, f)
	return f
end

function BlueItemLink:SetTooltip(link, linkType, f)
	-- 툴팁 복사
	f = f or self:GetLinkFrame()
	self.savedLink[link] = f:GetID()
	f.link = link
	f.linkType = linkType
	if type(linkTypes[f.linkType]) == "string" then
		f.id = tonumber(f.link:match(f.linkType..":(%d+)") or "")
	end
	f:SetOwner(UIParent, "ANCHOR_PRESERVE")
	f:ClearLines()
	f:SetBackdropColor(ItemRefTooltip:GetBackdropColor())
	f:SetBackdropBorderColor(ItemRefTooltip:GetBackdropBorderColor())
	f:SetMinimumWidth(ItemRefTooltip:GetWidth(), true)
	GameTooltip_ClearMoney(f)
	for i = 1, 10 do
		texture = _G["ItemRefTooltipTexture"..i]
		if texture and texture:IsShown() and type(texture:GetTexture()) == "string" then
			texturePos = tonumber((select(2, texture:GetPoint()):GetName()):match("(%d+)") or "")
			if texturePos then
				textures[texturePos] = texture:GetTexture()
			end
		end
		texture = _G[f.frameName.."Texture"..i]
		texture:SetTexture()
	end
	if build > 9947 and f.linkType == "item" and ItemRefTooltip.hasMoney and ItemRefTooltipMoneyFrame1 and ItemRefTooltipMoneyFrame1:IsShown() then
		moneyAnchor = (select(2, ItemRefTooltipMoneyFrame1:GetPoint()):GetName() or ""):match("ItemRefTooltipTextLeft(%d+)")
		if moneyAnchor then
			moneyAnchor = tonumber(moneyAnchor)
			moneyText = ItemRefTooltipMoneyFrame1PrefixText:GetText()
			moneyValue = ItemRefTooltipMoneyFrame1.staticMoney or 0
		end
	else
		moneyAnchor = nil
	end
	addInfo = true
	for i = 1, ItemRefTooltip:NumLines() do
		if moneyAnchor == i then
			SetTooltipMoney(f, moneyValue, "STATIC", moneyText, nil)
		else
			if not self.left[i] then
				self.left[i], self.right[i] = _G["ItemRefTooltipTextLeft"..i], _G["ItemRefTooltipTextRight"..i]
			end
			leftText, rightText = self.left[i]:GetText(), self.right[i]:GetText()
			if addInfo and f.id and (leftText and leftText:find(f.id)) or (rightText and rightText:find(f.id)) then
				addInfo = nil
			end
			leftR, leftG, leftB = self.left[i]:GetTextColor()
			rightR, rightG, rightB = self.right[i]:GetTextColor()
			f:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB, true)
			if textures[i] then
				f:AddTexture(textures[i])
				textures[i] = nil
			end
		end
	end
	f:SetTooltipInfo(addInfo)
	f:Show()
	f.timer = 0
	f:SetScript("OnUpdate", self.OnUpdate)
end

function BlueItemLink:OnHide()
	BlueItemLink.savedLink[self.link] = nil
	self.link = nil
	self.linkType = nil
	self.id = nil
	self.id2 = nil
	self.realLink = nil
	self.nameLink = nil
	self.isMoving = nil
end

function BlueItemLink:OnDragStart()
	self.isMoving = true
	self:StartMoving()
end

function BlueItemLink:OnDragStop()
	if self.isMoving then
		self.isMoving = nil
		self:StopMovingOrSizing()
		self.db[1], _, _, self.db[2], self.db[3] = self:GetPoint()
	end
end

function BlueItemLink:SetTooltipInfo(addID)
	if type(self.id) == "number" and self.link then
		self.id2 = nil
		if self.linkType == "item" then
			self.icon:SetTexture(GetItemIcon(self.id) or "")
			self.realLink = select(2, GetItemInfo(self.link))
		elseif self.linkType == "spell" then
			self.icon:SetTexture(select(3, GetSpellInfo(self.id)) or "")
			self.realLink = GetSpellLink(self.id)
		elseif self.firstLine:GetText() then
			if self.linkType == "talent" then
				if self.link:match("talent:(%d+):(%d+)") then
					self.id, self.id2 = self.link:match("talent:(%d+):(%d+)")
					self.id, self.id2 = tonumber(self.id), tonumber(self.id2)
				end
				self.icon:SetTexture("")
				self.realLink = linkText[self.linkType]:format(self.link, self.firstLine:GetText())
			elseif self.linkType == "enchant" then
				self.icon:SetTexture(select(3, GetSpellInfo(self.id)) or "")
				self.realLink = linkText[self.linkType]:format(self.link, self.firstLine:GetText())
			elseif self.linkType == "achievement" then
				self.icon:SetTexture(select(10, GetAchievementInfo(self.id)) or "")
				self.realLink = linkText[self.linkType]:format(self.link, self.firstLine:GetText())
			elseif self.linkType == "quest" then
				self.icon:SetTexture("Interface\\Icons\\INV_Scroll_11")
				self.realLink = linkText[self.linkType]:format(self.link, self.firstLine:GetText())
			else
				self.icon:SetTexture("")
				self.realLink = nil
			end
		else
			self.icon:SetTexture("")
			self.realLink = nil
		end
		if addID and BlueItemLinkDB[self.linkType.."ID"] then
			self:AddLine(linkTypes[self.linkType]..self.id..(self.id2 and (", "..self.id2) or ""))
		end
		self.nameLink = self.realLink and self.realLink:match(nameLink) or nil
	else
		self.icon:SetTexture("")
		self.id, self,id2, self.realLink = nil
	end
end

function BlueItemLink:OnClick()
	if self.link and self.id and self.realLink then
		if BlueItemInfo2 then
			if IsAltKeyDown() then
				if self.linkType == "item" then
					return BlueItemInfo2:AddFavoriteItem(self.id)
				elseif self.linkType == "enchant" then
					return BlueItemInfo2:AddFavoriteItem(-self.id)
				end
			elseif IsControlKeyDown() and IsShiftKeyDown() and self.linkType == "item" then
				BlueItemInfo2:AddMemo(self.id)
			end
		end
		if IsModifiedClick("CHATLINK") and self.realLink then
			if self.linkType == "item" and AuctionFrame and AuctionFrame:IsVisible() and BrowseName:IsVisible() and self.nameLink then
				BrowseName:SetText(self.nameLink)
			else
				ChatFrameEditBox:Show()
				ChatFrameEditBox:Insert(self.realLink)
			end
		elseif IsModifiedClick("DRESSUP") and self.linkType == "item" then
			DressUpItemLink(self.realLink)
		end
	end
end

function BlueItemLink:OnUpdate(timer)
	self.timer = (self.timer or 0) + timer
	self:Show()
	if self.timer > 0.1 then
		self.timer = nil
		self:SetScript("OnUpdate", nil)
	end
end

function BlueItemLink:OnEnter()
	BlueItemLink.enterFrame = self
	if IsModifiedClick("COMPAREITEMS") then
		BlueItemLink:MODIFIER_STATE_CHANGED("LSHIFT", 1)
	else
		BlueItemLink:MODIFIER_STATE_CHANGED()
	end
end

function BlueItemLink:OnLeave()
	BlueItemLink.enterFrame = nil
	if ShoppingTooltip1:IsShown() then
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()
	end
end

function BlueItemLink:MODIFIER_STATE_CHANGED(key, press)
	if self.enterFrame and self.enterFrame.linkType == "item" and key == "LSHIFT" and press == 1 then
		ShoppingTooltip1:SetOwner(self.enterFrame, "ANCHOR_NONE")
		ShoppingTooltip1:ClearAllPoints()
		ShoppingTooltip2:SetOwner(ShoppingTooltip1, "ANCHOR_NONE")
		ShoppingTooltip2:ClearAllPoints()
		if (GetScreenWidth() - self.enterFrame:GetRight()) < self.enterFrame:GetLeft() then
			ShoppingTooltip1:SetPoint("TOPRIGHT", self.enterFrame, "TOPLEFT", 0, -45)
			ShoppingTooltip2:SetPoint("TOPRIGHT", ShoppingTooltip1, "TOPLEFT", 0, 0)
		else
			ShoppingTooltip1:SetPoint("TOPLEFT", self.enterFrame, "TOPRIGHT", 0, -10)
			ShoppingTooltip2:SetPoint("TOPLEFT", "ShoppingTooltip1", "TOPRIGHT", 0, 0)
		end
		ShoppingTooltip1:SetHyperlinkCompareItem(self.enterFrame.link, 1)
		ShoppingTooltip1:Show()
		ShoppingTooltip2:SetHyperlinkCompareItem(self.enterFrame.link, 2)
		ShoppingTooltip2:Show()
	elseif ShoppingTooltip1:IsShown() then
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()
	end
end

function BlueItemLink:SetScale()
	for _, frame in ipairs(self.tooltips) do
		frame:SetScale(BlueItemLinkDB.scale)
		frame:Show()
	end
end

function BlueItemLink:SetIcon()
	if BlueItemLinkDB.showIcon then
		for _, frame in ipairs(self.tooltips) do
			frame.icon:Show()
		end
	else
		for _, frame in ipairs(self.tooltips) do
			frame.icon:Hide()
		end
	end
end

function BlueItemLink:SetEscHide()
	if BlueItemLinkDB.escHide then
		for _, frame in ipairs(UISpecialFrames) do
			if frame:find("BlueItemLink") then
				return
			end
		end
		for _, frame in ipairs(self.tooltips) do
			tinsert(UISpecialFrames, self.tooltips:GetName())
		end
	else
		for index, frame in ipairs(UISpecialFrames) do
			if frame:find("BlueItemLink") then
				tremove(UISpecialFrames, index)
				return self:SetEscHide()
			end
		end
	end
end
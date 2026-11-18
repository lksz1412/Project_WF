local addOnName = GetAddOnDependencies(...)
local texturePath = "Interface\\AddOns\\"..(...).."\\Texture\\"
local BII3 = _G[addOnName]

local _G = _G
local ceil = _G.math.ceil
local tinsert = _G.table.insert
local wipe = _G.table.wipe
local GetItemCount = _G.GetItemCount
local IsAltKeyDown = _G.IsAltKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsModifiedClick = _G.IsModifiedClick
local items, buttons, heroicOffset, flexibleOffset, mythicOffset, findRaidOffset, offset, realOffset, displayNum = {}, {}, 0, 0
local normal, heroic, flexible, mythic, findRaid, category1, category2, category3, code1, code2, code3, currentCode, c1, c2, c3, _

local function setStatus(button, step, status)
	if step < 0 then
		button.prevCode = status
		if status then
			button.up:Enable()
		else
			button.up:Disable()
		end
	else
		button.nextCode = status
		if status then
			button.down:Enable()
		else
			button.down:Disable()
		end
	end
end

local function find1(first, last, step)
	for i = first, last, step do
		c1 = BII3.codeList:sub(i, i)
		if BII3.itemList[c1.."**"] then
			for j = BII3.codeListZero, BII3.codeListLen do
				c2 = c1..BII3.codeList:sub(j, j)
				if BII3.itemList[c2.."*"] then
					for k = BII3.codeListZero, BII3.codeListLen do
						c3 = c2..BII3.codeList:sub(k, k)
						if BII3.itemList[c3] then
							return setStatus(BII3.dropdownButtons[1], step, c3)
						end
					end
				end
			end
		end
	end
	setStatus(BII3.dropdownButtons[1], step, nil)
end

local function find2(first, last, step)
	for i = first, last, step do
		c1 = code1..BII3.codeList:sub(i, i)
		if BII3.itemList[c1.."*"] then
			for j = BII3.codeListZero, BII3.codeListLen do
				c2 = c1..BII3.codeList:sub(j, j)
				if BII3.itemList[c2] then
					return setStatus(BII3.dropdownButtons[2], step, c2)
				end
			end
		end
	end
	setStatus(BII3.dropdownButtons[2], step, nil)
end

local function find3(first, last, step)
	for i = first, last, step do
		c1 = code1..code2..BII3.codeList:sub(i, i)
		if BII3.itemList[c1] then
			return setStatus(BII3.dropdownButtons[3], step, c1)
		end
	end
	setStatus(BII3.dropdownButtons[3], step, nil)
end

local function addItemTable(item, ...)
	item = tonumber(item)
	tinsert(items, item)
	if ... then
		addItemTable(...)
	end
end

local function updateList()
	BII3:SortItem(currentCode)
	normal, heroic, flexible, mythic, findRaid = BII3:SplitList(currentCode)
	wipe(items)
	BII3:UnpackItemList(items, normal)
	heroicOffset = #items + 1
	BII3:UnpackItemList(items, heroic)
	flexibleOffset = #items + 1
	BII3:UnpackItemList(items, flexible)
	mythicOffset = #items + 1
	BII3:UnpackItemList(items, mythic)
	findRaidOffset = #items + 1
	BII3:UnpackItemList(items, findRaid)
	normal, heroic, flexible, mythic, findRaid = nil
	if heroicOffset == #items + 1 then
		heroicOffset = -1
	end
	if flexibleOffset == #items + 1 then
		flexibleOffset = -1
	end
	if mythicOffset == #items + 1 then
		mythicOffset = -1
	end
	if findRaidOffset == #items + 1 then
		findRaidOffset = -1
	end
	BII3:UpdateItemList()
end

function BII3:Update(force)
	if self.db.code ~= currentCode then
		currentCode = self.db.code
		code1, code2, code3 = currentCode:match("(.)(.)(.)")
		category1, category2, category3 = BII3:GetCategoryName(currentCode)
		if self.dropdownButtons[1].code ~= code1 then
			self.dropdownButtons[1].code = code1
			self.dropdownButtons[1]:SetText(self:ClearColor(category1))
			find1(self.codeList:find(code1) - 1, 1, -1)
			find1(self.codeList:find(code1) + 1, self.codeListLen, 1)
		end
		if self.dropdownButtons[2].code ~= (code1..code2) then
			self.dropdownButtons[2].code = code1..code2
			self.dropdownButtons[2]:SetText(self:ClearColor(category2):gsub("^오리지널 ", "") or nil)
			self.dropdownButtons[2].key = code1
			find2(self.codeList:find(code2) - 1, self.codeListZero, -1)
			find2(self.codeList:find(code2) + 1, self.codeListLen, 1)
		end
		if category3 then
			self.dropdownButtons[3]:SetText(self:ClearColor(category3))
			self.dropdownButtons[3].key = code1..code2
			self.dropdownButtons[3]:Enable()
			find3(self.codeList:find(code3) - 1, self.codeListZero, -1)
			find3(self.codeList:find(code3) + 1, self.codeListLen, 1)
		else
			self.dropdownButtons[3]:SetText(nil)
			self.dropdownButtons[3].key = nil
			self.dropdownButtons[3]:Disable()
			self.dropdownButtons[3].prevCode, self.dropdownButtons[3].nextCode = nil
			self.dropdownButtons[3].up:Disable()
			self.dropdownButtons[3].down:Disable()
		end
		c1, c2, c3, code1, code2, code3, category1, category2, category3 = nil
		updateList(force)
		self.container.scrollBar:SetValue(0)
	elseif force then
		updateList(force)
	end
end

function BII3:MODIFIER_STATE_CHANGED()
	if self:IsEventRegistered("MODIFIER_STATE_CHANGED") then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor()
		else
			ResetCursor()
		end
		if IsModifiedClick("COMPAREITEMS") then
			GameTooltip_ShowCompareItem(GameTooltip, 1)
		elseif GameTooltip.shoppingTooltips[1]:IsShown() then
			for _, t in pairs(GameTooltip.shoppingTooltips) do
				t:Hide()
			end
		end
	else
		ResetCursor()
		if GameTooltip.shoppingTooltips[1]:IsShown() then
			for _, t in pairs(GameTooltip.shoppingTooltips) do
				t:Hide()
			end
		end
	end
end

local function buttonOnClick(self, button)
	if BII3:IsItem(self.id) then
		if self.id > 0 and self.suffix then
			if button == "LeftButton" then
				BII3:ItemOnClick(BII3:GetItemSimpleLink(self.id, -self.suffix, self.unique), button)
			else
				ToggleDropDownMenu(1, BII3:GetItemSimpleLink(self.id, -self.suffix, self.unique), self.dropdown, "cursor")
			end
		elseif button == "LeftButton" then
			CloseDropDownMenus(1)
			BII3:ItemOnClick(self.id, button)
		else
			ToggleDropDownMenu(1, self.id, self.dropdown, "cursor")
		end
	else
		CloseDropDownMenus(1)
	end
end

local itemName, itemRarity, itemLevel

local function buttonOnEnter(self)
	BII3.enter = self
	BII3:UnregisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -150, 0)
	if self.id > 0 then
		if self.suffix then
			GameTooltip:SetHyperlink(BII3:GetItemSimpleLink(self.id, -self.suffix, self.unique))
		else
			GameTooltip:SetHyperlink(BII3:GetItemSimpleLink(self.id))
		end
		BII3:RegisterEvent("MODIFIER_STATE_CHANGED")
	elseif self.id < 0 then
		GameTooltip:SetHyperlink("spell:"..-self.id)
		if BII3.GetMountModelID and (BII3:GetMountModelID(self.id) or 0) > 0 then
			BII3:RegisterEvent("MODIFIER_STATE_CHANGED")
		end
	end
	GameTooltip:Show()
	BII3:MODIFIER_STATE_CHANGED()
end

local function buttonOnLeave(self)
	BII3.enter = nil
	BII3:UnregisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:Hide()
	BII3:MODIFIER_STATE_CHANGED()
end

local function randomSuffixOnMouseDown(self)
	self:GetNormalTexture():SetPoint("TOPLEFT", 1, -1)
	self:GetNormalTexture():SetPoint("BOTTOMRIGHT", 1, -1)
end

local function randomSuffixOnMouseUp(self)
	self:GetNormalTexture():SetPoint("TOPLEFT", 0, 0)
	self:GetNormalTexture():SetPoint("BOTTOMRIGHT", 0, 0)
end

local function randomSuffixOnClick(self)
	ToggleDropDownMenu(1, self:GetParent().id, self.dropdown, self:GetName(), 0, 0)
end

local function randomSuffixOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("무작위 마법부여 상세 보기")
	GameTooltip:Show()
end

local function createItemButton(id)
	if not buttons[id] then
		buttons[id] = CreateFrame("Button", addOnName.."ItemButton"..id, BII3.container.scrollChild, "LargeItemButtonTemplate")
		buttons[id]:SetID(id)
		buttons[id]:SetFrameLevel(BII3.container.scrollChild:GetFrameLevel() + 1)
		buttons[id]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		buttons[id].name = _G[addOnName.."ItemButton"..id.."Name"]
		buttons[id].name:SetText(UNKNOWN)
		buttons[id].name:ClearAllPoints()
		buttons[id].name:SetPoint("TOPLEFT", addOnName.."ItemButton"..id.."NameFrame", 14, -10)
		buttons[id].name:SetPoint("BOTTOMRIGHT", addOnName.."ItemButton"..id.."NameFrame", -17, 12)
		buttons[id].icon = _G[addOnName.."ItemButton"..id.."IconTexture"]
		buttons[id].icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		buttons[id].border = buttons[id]:CreateTexture(nil, "ARTWORK")
		buttons[id].border:SetTexture(texturePath.."IconBorder")
		buttons[id].border:SetAllPoints(buttons[id].icon)
		buttons[id].border:SetAlpha(0.5)
		buttons[id].border:Hide()
		buttons[id].highlight = buttons[id]:CreateTexture(nil, "BACKGROUND")
		buttons[id].highlight:SetPoint("CENTER", _G[addOnName.."ItemButton"..id.."NameFrame"], 0, 0)
		buttons[id].highlight:SetSize(102, 37)
		buttons[id].itemChecked = buttons[id]:CreateTexture(nil, "OVERLAY")
		buttons[id].itemChecked:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
		buttons[id].itemChecked:SetSize(32, 24)
		buttons[id].itemChecked:SetPoint("CENTER", buttons[id].icon, 0, 0)
		buttons[id].dropdown = CreateFrame("Frame", addOnName.."ItemButton"..id.."ItemDropDown", buttons[id], "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(buttons[id].dropdown, BII3.itemDropdownMenu)
		buttons[id].randomSuffix = CreateFrame("Button", addOnName.."ItemButton"..id.."RandomButton", buttons[id])
		buttons[id].randomSuffix:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		buttons[id].randomSuffix:SetFrameLevel(buttons[id]:GetFrameLevel() + 1)
		buttons[id].randomSuffix:SetAlpha(0.75)
		buttons[id].randomSuffix:SetSize(12, 12)
		buttons[id].randomSuffix:SetPoint("TOPRIGHT", -3, -1)
		buttons[id].randomSuffix:SetNormalTexture("Interface\\FriendsFrame\\InformationIcon")
		buttons[id].randomSuffix:GetNormalTexture():ClearAllPoints()
		buttons[id].randomSuffix:GetNormalTexture():SetPoint("TOPLEFT", 0, 0)
		buttons[id].randomSuffix:GetNormalTexture():SetPoint("BOTTOMRIGHT", 0, 0)
		buttons[id].randomSuffix:SetHighlightTexture("Interface\\FriendsFrame\\InformationIcon-Highlight", "ADD")
		buttons[id].randomSuffix:GetHighlightTexture():SetAlpha(0.5)
		buttons[id].randomSuffix:GetHighlightTexture():SetAllPoints(buttons[id].randomSuffix:GetNormalTexture())
		buttons[id].randomSuffix:SetScript("OnMouseDown", randomSuffixOnMouseDown)
		buttons[id].randomSuffix:SetScript("OnMouseUp", randomSuffixOnMouseUp)
		buttons[id].randomSuffix:SetScript("OnClick", randomSuffixOnClick)
		buttons[id].randomSuffix:SetScript("OnEnter", randomSuffixOnEnter)
		buttons[id].randomSuffix:SetScript("OnLeave", GameTooltip_Hide)
		buttons[id].randomSuffix.dropdown = CreateFrame("Frame", addOnName.."ItemButton"..id.."RandomButtonDropDown", buttons[id].randomSuffix, "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(buttons[id].randomSuffix.dropdown, BII3.randomItemDropdownMenu)
		buttons[id]:SetScript("OnClick", buttonOnClick)
		buttons[id]:SetScript("OnEnter", buttonOnEnter)
		buttons[id]:SetScript("OnLeave", buttonOnLeave)
		if id == 1 then
			buttons[id]:SetPoint("TOPLEFT", 0, 0)
			BII3.container.buttons[1] = buttons[id]
		elseif id % 4 == 1 then
			buttons[id]:SetPoint("TOPLEFT", buttons[id - 4], "BOTTOMLEFT", 0, -2)
			BII3.container.buttons[ceil(id / 4)] = buttons[id]
		else
			buttons[id]:SetPoint("LEFT", buttons[id - 1], "RIGHT", 1, 0)
		end
	end
end

local function clearItemButton(id)
	buttons[id].id = nil
	buttons[id].unique = nil
	buttons[id].suffix = nil
	buttons[id].noitem = nil
	buttons[id].name:SetText()
	buttons[id]:Hide()
end

local function setButtonColor(i, color)
	if color == "findRaid" then
		buttons[i].highlight:SetGradientAlpha("VERTICAL", 0.3, 0.3, 0.3, 1, 0.58, 0.58, 0.58, 1)
		buttons[i].highlight:SetTexture(0.58, 0.58, 0.58, 0.75)
		buttons[i].highlight:Show()
	elseif color == "flexible" then
		buttons[i].highlight:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0.3, 0.3, 0.3, 1)
		buttons[i].highlight:SetTexture(0.3, 0.3, 0.3, 0.75)
		buttons[i].highlight:Show()
	elseif color == "mythic" then
		buttons[i].highlight:SetGradientAlpha("VERTICAL", 0, 0, 0.6, 1, 0, 0, 1, 1)
		buttons[i].highlight:SetTexture(0, 0, 1, 0.4)
		buttons[i].highlight:Show()
	elseif color == "heroic" then
		buttons[i].highlight:SetGradientAlpha("VERTICAL", 0.6, 0, 0, 1, 1, 0, 0, 1)
		buttons[i].highlight:SetTexture(1, 0, 0, 0.4)
		buttons[i].highlight:Show()
	else
		buttons[i].highlight:Hide()
	end
end

function BII3:GetNumDisplayList()
	return ceil(self.container:GetHeight() / self.container.buttonHeight + 1) * 4
end

function BII3:UpdateItemList()
	if BII3:IsShown() then
		CloseDropDownMenus(1)
		BII3.container.displayNum = BII3:GetNumDisplayList()
		offset = HybridScrollFrame_GetOffset(BII3.container) * 4
		for i = 1, BII3.container.displayNum do
			offset = offset + 1
			if offset > #items then
				if buttons[i] then
					clearItemButton(i)
				end
			else
				createItemButton(i)
				if type(items[offset]) == "string" then
					buttons[i].id, buttons[i].unique, buttons[i].suffix = items[offset]:match("(%d+)%-(%d+)%-(%d+)")
					buttons[i].id = tonumber(buttons[i].id)
					buttons[i].unique = tonumber(buttons[i].unique)
					buttons[i].suffix = tonumber(buttons[i].suffix)
				else
					buttons[i].id, buttons[i].unique, buttons[i].suffix = items[offset]
				end
				buttons[i].icon:SetTexture(BII3:GetItemIcon(buttons[i].id))
				buttons[i].name:SetText(BII3:GetItemColorName(buttons[i].id, buttons[i].suffix))
				if buttons[i].id > 0 then
					if BII3:HasItem(buttons[i].id) or (BII3.HasMount and BII3:HasMount(buttons[i].id)) then
						buttons[i].itemChecked:SetDesaturated(nil)
						buttons[i].itemChecked:Show()
					elseif BII3:IsFavorite(buttons[i].id) then
						buttons[i].itemChecked:SetDesaturated(true)
						buttons[i].itemChecked:Show()
					else
						buttons[i].itemChecked:Hide()
					end
					if not BII3:IsItem(buttons[i].id) then
						buttons[i].noitem = true
					else
						buttons[i].noitem = nil
					end
					if BII3:IsRandomSuffixItem(buttons[i].id) and not buttons[i].suffix then
						buttons[i].randomSuffix:Show()
					else
						buttons[i].randomSuffix:Hide()
					end
				else
					if BII3.HasMount and BII3:HasMount(buttons[i].id) then
						buttons[i].itemChecked:SetDesaturated(nil)
						buttons[i].itemChecked:Show()
					elseif BII3:IsFavorite(buttons[i].id) then
						buttons[i].itemChecked:SetDesaturated(true)
						buttons[i].itemChecked:Show()
					else
						buttons[i].itemChecked:Hide()
					end
					buttons[i].noitem = nil
					buttons[i].randomSuffix:Hide()
				end
				if findRaidOffset == -1 and BII3:IsFindRaidItem(buttons[i].id) then
					setButtonColor(i, "findRaid")
				elseif mythicOffset == -1 and BII3:IsMythicItem(buttons[i].id) then
					setButtonColor(i, "mythic")
				elseif flexibleOffset == -1 and BII3:IsFlexibleItem(buttons[i].id) then
					setButtonColor(i, "flexible")
				elseif heroicOffset == -1 and BII3:IsHeroicItem(buttons[i].id) then
					setButtonColor(i, "heroic")
				elseif findRaidOffset > 0 and findRaidOffset <= offset then
					setButtonColor(i, "findRaid")
				elseif mythicOffset > 0 and mythicOffset <= offset then
					setButtonColor(i, "mythic")
				elseif flexibleOffset > 0 and flexibleOffset <= offset then
					setButtonColor(i, "flexible")
				elseif heroicOffset > 0 and heroicOffset <= offset then
					setButtonColor(i, "heroic")
				else
					buttons[i].highlight:Hide()
				end
				buttons[i]:Show()
				if buttons[i] == BII3.enter then
					buttons[i]:GetScript("OnEnter")(buttons[i])
				end
			end
		end
		for i = BII3.container.displayNum + 1, #buttons do
			clearItemButton(i)
		end
		HybridScrollFrame_Update(BII3.container, ceil(#items / 4) * BII3.container.buttonHeight, BII3.container:GetHeight())
	end
end

BII3.container.update = BII3.UpdateItemList
BII3.container.buttons = {}
BII3.container.buttonHeight = (QuestProgressItem1:GetHeight() + 2)
BII3.container.stepSize = BII3.container.buttonHeight * 2.5

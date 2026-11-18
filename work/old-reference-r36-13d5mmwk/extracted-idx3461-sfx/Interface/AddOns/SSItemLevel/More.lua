local addonName, ns = ...
local _G = _G
local SSItemLevel = SSItemLevel or ns.SSItemLevel
local tooltip = CreateFrame("GameTooltip", addonName.."ScanTooltip", SSItemLevel, "GameTooltipTemplate")
local tooltipName = tooltip:GetName()
local tooltip1 = CreateFrame("GameTooltip", addonName.."ScanTooltip1", SSItemLevel, "GameTooltipTemplate")
local tooltipName1 = tooltip1:GetName()
local tooltip2 = CreateFrame("GameTooltip", addonName.."ScanTooltip2", SSItemLevel, "GameTooltipTemplate")
local tooltipName2 = tooltip2:GetName()
local runSpells={}
local iconpath = "Interface\\ItemSocketingFrame\\%s"
local msg = string.gsub(iconpath, "%%s", "(.+)")
local msg1 = string.gsub(EMPTY_SOCKET, "%%d", "(%%d+)")
local EmptyGems = {}
local EnchantIcon
local RuneforgIcon
local tradeSpells = {}
local L = {}
local EmptySocket = {
	["UI-EmptySocket-Hydraulic"]=EMPTY_SOCKET_HYDRAULIC, -- 수력 홈
	["UI-EmptySocket-CogWheel"]=EMPTY_SOCKET_COGWHEEL, -- 맞물림톱니 홈
	["UI-EmptySocket-Meta"]=EMPTY_SOCKET_META,	--얼개
	["UI-EmptySocket-Prismatic"]=EMPTY_SOCKET_PRISMATIC, -- 다색
	["UI-EmptySocket-Blue"]=EMPTY_SOCKET_BLUE, -- 푸른색
	["UI-EmptySocket-Red"]=EMPTY_SOCKET_RED, -- 붉은색
	["UI-EmptySocket-Yellow"]=EMPTY_SOCKET_YELLOW, -- 노란색
	["UI-EmptySocket"]=UNKNOWN, --
}

local itemslots = {
	["HeadSlot"]={},
	["NeckSlot"]={},
	["ShoulderSlot"]={},
	["BackSlot"]={},
	["ChestSlot"]={},
	["WristSlot"]={},
	["MainHandSlot"]={},
	["SecondaryHandSlot"]={},
	["HandsSlot"]={},
	["WaistSlot"]={},
	["LegsSlot"]={},
	["FeetSlot"]={},
	["Finger0Slot"]={},
	["Finger1Slot"]={},
	["Trinket0Slot"]={},
	["Trinket1Slot"]={},
--	["TabardSlot"]={},
}

local tradeitemslots = {
	[1] = {		-- 마법 부여
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"WristSlot",
		"HandsSlot",
		"LegsSlot",
		"FeetSlot",
		"MainHandSlot",
		"SecondaryHandSlot",
	},
	[2] = {		-- 죔쇠
		"WaistSlot",
	},
	[3] = {		-- 드군(600+) 마법 부여
		"NeckSlot",
        "BackSlot",
		"Finger0Slot",
		"Finger1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
	},	
}

local Anchor = {
	[1] = "RIGHT",
	[2] = "RIGHT",
	[3] = "RIGHT",
	[15] = "RIGHT",
	[5] = "RIGHT",
	[9] = "RIGHT",

	[10] = "LEFT",
	[6] = "LEFT",
	[7] = "LEFT",
	[8] = "LEFT",
	[11] = "LEFT",
	[12] = "LEFT",
	[13] = "LEFT",
	[14] = "LEFT",

	[16] = "TOP",
	[17] = "TOP",
--	[18] = "TOP",
}

L.Enchant, _, EnchantIcon = GetSpellInfo(28029)
L.Runeforg, _, RuneforgIcon = GetSpellInfo(53428)
L.Blacksmith = GetSpellInfo(29844)
L.Gem = select(8,GetAuctionItemClasses())

L.Check = "검사"
L.AfterCheck = "표기"
L.EnchantCheck = "마"
L.BlacksmithCheck = "대"
L.RuneforgCheck = "룬"
L.JewelCraft = "보"
L.Buckle = "죔"
L.CheckTooltip = format("%s, %s, %s\n%s", L.Enchant, L.Gem, TRADE_SKILLS, "상태에 따라 필요한 부분을 표기합니다.")
L.AfterCheckTooltip = format("%s, %s, %s %s", L.Enchant, L.Gem, TRADE_SKILLS, "보기\n|cFFFFFFFF'자세히' 첵크 되어야 합니다.|r")
L.CheckSuccess = "표기 할 아이탬이 없습니다."


function SSItemLevel:Clear()
	EmptyGems[1] = nil
	EmptyGems[2] = nil
	EmptyGems[3] = nil
	for i = 1, 5 do
		local texture = _G[tooltipName .. 'Texture' .. i]
		if texture then texture:SetTexture(nil) end
	end
	tooltip:ClearLines()
	tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

function SSItemLevel:GetEmptySocketString(id)
	tooltip1:ClearLines()
	tooltip1:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltip1:SetInventoryItem("player", id)

	local txt
	for i = 5, min(12,tooltip1:NumLines()) do
		txt = _G[tooltipName1.."TextLeft"..i]:GetText()
		if (txt and tonumber(txt:match(msg1)) > 0) then
			tooltip1:Hide()
			return txt
		end
	end

	tooltip1:Hide()

	return UNKNOWN
end

function SSItemLevel:GetEmptyGemCount(id)
	local gems = { GetInventoryItemGems(id) }
	local offset
	local textureName
	self:Clear()
	tooltip:SetInventoryItem("player", id)
	tooltip:Show()

	local gemcount = 0
	for i = 1, 5 do
		local texture = _G[tooltipName .. 'Texture' .. i]
		if texture then
			textureName = string.match(texture:GetTexture() or "", msg)
			if (textureName and EmptySocket[textureName]) then
				gemcount = gemcount + 1
				offset = gemcount
				if (gems[gemcount]) then
					offset = gemcount + 1
					if (gems[offset]) then
						offset = offset + 1
					end
				end
				EmptyGems[offset] = textureName
			end
		end
	end
	wipe(gems)
	tooltip:Hide()
	return gemcount
end

function SSItemLevel:GetEmptyGemCountLink(itemLink)
	local itemId = tonumber(itemLink:match("Hitem:(%d+):"))
	local iLink = select(2, GetItemInfo(itemId))
	self:Clear()
	tooltip:SetHyperlink(iLink)
	tooltip:Show()

	local gemcount = 0
	for i = 1, 5 do
		local texture = _G[tooltipName .. 'Texture' .. i]
		if texture then
			textureName = string.match(texture:GetTexture() or "", msg)
			if (textureName and EmptySocket[textureName]) then
				gemcount = gemcount + 1
			end
		end
	end

	tooltip:Hide()
	return gemcount
end

function SSItemLevel:GetEffectID(itemLink)
	local a1, itemId, enchantId,a2,a3,a4,a5,a6,a7,a8,a9,a10 = strsplit(":", itemLink)
	enchantId = tonumber(enchantId)
	if (enchantId > 0) then
		local link1 = select(2, GetItemInfo(format("%s:%s:0:0:0:%s:%s:%s:%s:%s%s", a1,itemId,a5,a6,a7,a8,a9,a10)))
		local link2 = select(2, GetItemInfo(format("%s:%s:%d:0:0:0:%s:%s:%s:%s%s", a1,itemId,enchantId,a5,a6,a7,a8,a9,a10)))

		tooltip1:ClearLines()
		tooltip1:SetOwner(WorldFrame, "ANCHOR_NONE")
		tooltip1:SetHyperlink(link1)
		tooltip1:Show()

		tooltip2:ClearLines()
		tooltip2:SetOwner(WorldFrame, "ANCHOR_NONE")
		tooltip2:SetHyperlink(link2)
		tooltip2:Show()

		local t1, t2
		
		for i = 2, min(tooltip1:NumLines(),tooltip2:NumLines()) do
			t1 = _G[tooltipName1.."TextLeft"..i]:GetText()
			t2 = _G[tooltipName2.."TextLeft"..i]:GetText()
			if (t1 ~= t2) then
				if t2 == " " then 
					local line = i + 1
					t2 = _G[tooltipName2.."TextLeft"..line]:GetText()
				end
				tooltip1:Hide()
				tooltip2:Hide()
				return enchantId, t2
			end
		end
		tooltip1:Hide()
		tooltip2:Hide()
		return enchantId, ""
	end
end

function SSItemLevel_OnClick(self,...)
	if (not IsAddOnLoaded("Blizzard_ItemSocketingUI")) then
		LoadAddOn("Blizzard_ItemSocketingUI")
	end
	if (self.index and CursorHasItem()) then
		local type, data, subType = GetCursorInfo()
		if (type == "item") then
			local class = select(6, GetItemInfo(subType))
			if (L.Gem == class) then
				SocketInventoryItem(self:GetParent():GetID())
				ClickSocketButton(self:GetID())
			end
		end
		ClearCursor()
	else
		if (self.index) then
			SocketInventoryItem(self:GetParent():GetID())
		end
	end
end

function SSItemLevel_OnEnter(self)
	if (self.link) then
		_G["GameTooltip"]:SetOwner(self, "ANCHOR_RIGHT")
		_G["GameTooltip"]:SetHyperlink(self.link)
		_G["GameTooltip"]:Show()
	elseif (self.tooltip) then
		_G["GameTooltip"]:SetOwner(self, "ANCHOR_RIGHT")
		_G["GameTooltip"]:AddLine(self.tooltip)
		_G["GameTooltip"]:Show()
	end
end

function SSItemLevel_OnLeave(self)
	_G["GameTooltip"]:Hide()
end

function SSItemLevel:CreateButton(slot, index)
	local button = CreateFrame("Button", addonName..slot.."Socket"..index, _G["Character"..slot])
	button:EnableMouse(true)
	button:RegisterForClicks("AnyUp")
	button:RegisterForDrag("LeftButton", "RightButton")
	button:SetScript("OnEnter", SSItemLevel_OnEnter)
	button:SetScript("OnLeave", SSItemLevel_OnLeave)
	button:SetScript("OnClick", SSItemLevel_OnClick)

	button:SetWidth(12)
	button:SetHeight(12)
	local icon = button:CreateTexture(nil, "BORDER")
	icon:SetAllPoints(button)
	icon:Show()
	button.icon = icon

	return button
end

function SSItemLevel:HideAllButtons()
	for slot,t in pairs(itemslots) do
		for i = 1, 7 do
			if (t[i]) then
				t[i].link = nil
				t[i].tooltip = nil
				t[i].index = nil
				if (i == 7) then t[i]:SetText(nil) end
				t[i]:Hide()
			end
		end
	end
end

function SSItemLevel:GetRunEnchant(id)
	local txt
	self:Clear()
	tooltip:SetInventoryItem("player", id)
	tooltip:Show()
	for i = 5, min(12,tooltip:NumLines()) do
		txt = _G[tooltipName.."TextLeft"..i]:GetText()
		if (txt and runSpells[txt]) then
			tooltip:Hide()
			return txt
		end
	end
	tooltip:Hide()
end

function SSItemLevel:ScanInventory()
	self:HideAllButtons()
	if (not SSItemLevelMore) then return end
	local gem1, gem2, gem3, empty, id, itemLink, name, link, count, anchor
	for slot,t in pairs(itemslots) do
		id = GetInventorySlotInfo(slot)
		itemLink = GetInventoryItemLink("player", id)
		if (itemLink and itemLink ~= "") then
			-- 보석 확인
			empty = self:GetEmptyGemCount(id)
			gem1, gem2, gem3 = GetInventoryItemGems(id)
			anchor = Anchor[id]
			count = 0
			if (gem1 or gem2 or gem3 or empty > 0) then
				if (gem3 or EmptyGems[3]) then count = 3
				elseif (gem2 or EmptyGems[2]) then count = 2
				else count = 1 end
--				print(slot, self:GetSocketCount(itemLink), gem1, gem2, gem3, EmptyGems[1], EmptyGems[2])
				for i = 1, count do
					name, link = GetItemGem(itemLink, i)
					if (not t[i]) then t[i] = self:CreateButton(slot, i) end
					if (EmptyGems[i]) then
						t[i].icon:SetTexture(format(iconpath,EmptyGems[i]))
						if (EmptyGems[i] == "UI-EmptySocket") then
							t[i].tooltip = self:GetEmptySocketString(id)
						else
							t[i].tooltip = EmptySocket[EmptyGems[i]]
						end
						t[i].link = nil
					else
						t[i].icon:SetTexture(GetItemIcon(link))
						t[i].tooltip = nil
						t[i].link = link
					end
					t[i]:ClearAllPoints()
					if (anchor == "RIGHT") then
						if (i == 1) then
							t[i]:SetPoint("TOPLEFT", _G["Character"..slot], "TOPRIGHT", 8, -6)
						else
							t[i]:SetPoint("LEFT", t[i-1], "RIGHT", 0, 0)
						end
					elseif (anchor == "LEFT") then
						if (i == 1) then
							t[i]:SetPoint("TOPRIGHT", _G["Character"..slot], "TOPLEFT", -8, -6)
						else
							t[i]:SetPoint("RIGHT", t[i-1], "LEFT", 0, 0)
						end
					else
						if (i == 1) then
							t[i]:SetPoint("BOTTOM", _G["Character"..slot], "TOP", -(((count - 1) * 12) / 2), 3)
						else
							t[i]:SetPoint("RIGHT", t[i-1], "LEFT", 0, 0)
						end
					end
					t[i].index = i
					t[i]:SetID(i)
					t[i]:Show()
				end
			end

			-- 마부 확인
			local eid, state = self:GetEffectID(itemLink)
			if (eid) then
				if (not t[4]) then t[4] = self:CreateButton(slot, 4) end
				t[4].icon:SetTexture(EnchantIcon)
				t[4].tooltip = format("%s", state)
				if (anchor == "RIGHT") then
					t[4]:SetPoint("TOPLEFT", _G["Character"..slot], "TOPRIGHT", 8, -22)
				elseif (anchor == "LEFT") then
					t[4]:SetPoint("TOPRIGHT", _G["Character"..slot], "TOPLEFT", -8, -22)
				else
					if ((t[1] and t[1]:IsShown()) or (t[2] and t[2]:IsShown()) or (t[3] and t[3]:IsShown())) then
						t[4]:SetPoint("BOTTOM", _G["Character"..slot], "TOP", 0, 17)
					else
						t[4]:SetPoint("BOTTOM", _G["Character"..slot], "TOP", 0, 3)
					end
				end
				t[4]:Show()
			end

			-- 룬벼리기
			if (IsSpellKnown(53428)) then
				if (slot == "MainHandSlot" or slot == "SecondaryHandSlot") then
					local run = self:GetRunEnchant(id)
					if (run) then
						if (not t[4]) then t[4] = self:CreateButton(slot, 6) end
						t[4].icon:SetTexture(RuneforgIcon)
					end
				end
			end
		end
	end
end

function SSItemLevel:CreateString(slot, id)
	local anchor = Anchor[id]
	local t =  _G["Character"..slot]:CreateFontString(nil, "OVERLAY")
	t:SetFont(_G["CharacterLevelText"]:GetFont())
	t:SetTextColor(1,1,0)
	if (anchor == "RIGHT") then
		t:SetPoint("LEFT", _G["Character"..slot], "RIGHT", 8, 0)
	elseif (anchor == "LEFT") then
		t:SetPoint("RIGHT", _G["Character"..slot], "LEFT", -10, 0)
	else
		t:SetPoint("BOTTOM", _G["Character"..slot], "TOP", 0, 4)
	end
	return t
end

function SSItemLevel:CheckGems(slot, id, itemLink, text, IsPlus)
	local txt, count = nil, 0
	local empty, gem1, gem2, gem3
	local plus = IsPlus and 1 or 0
	if (itemLink) then
		itemslots[slot][7] =  itemslots[slot][7] or self:CreateString(slot, id)
		empty = self:GetEmptyGemCount(id)
		gem1, gem2, gem3 = GetInventoryItemGems(id)
		if (gem1 or gem2 or gem3 or empty > 0) then
			if (gem3 or EmptyGems[3]) then count = 3
			elseif (gem2 or EmptyGems[2]) then count = 2
			else count = 1 end

			if (empty > 0 and not IsBlacksmith) then
				itemslots[slot][7] = itemslots[slot][7] or self:CreateString(slot, id)
				txt = itemslots[slot][7]:GetText()
				if (txt and txt ~= "") then
					if (not txt:find(text)) then
						itemslots[slot][7]:SetText(format("%s,%s", txt, text))
					end
				else
					itemslots[slot][7]:SetText(L.JewelCraft)
				end
				itemslots[slot][7]:Show()
			end
		end
		if (plus > 0 and (self:GetEmptyGemCountLink(itemLink) + plus) > count) then
			itemslots[slot][7] = itemslots[slot][7] or self:CreateString(slot, id)
			txt = itemslots[slot][7]:GetText()
			if (txt and txt ~= "") then
				if (not txt:find(text)) then
					itemslots[slot][7]:SetText(format("%s,%s", txt, text))
				end
			else
				itemslots[slot][7]:SetText(text)
			end
			itemslots[slot][7]:Show()
		end
	end
end

function SSItemLevel:CheckEnchant(slot, id, itemLink, text)
	if (not self:GetEffectID(itemLink)) then
		local txt
		itemslots[slot][7] =  itemslots[slot][7] or self:CreateString(slot, id)
		txt = itemslots[slot][7]:GetText()
		if (txt and txt ~= "") then
			if (not txt:find(text)) then
				itemslots[slot][7]:SetText(format("%s,%s", txt, text))
			end
		else
			itemslots[slot][7]:SetText(text)
		end
		itemslots[slot][7]:Show()
	end
end

function SSItemLevel:CheckAllItems()
	-- 버튼 숨기기
	self:HideAllButtons()
    
	-- 검사
	local id, itemLink, anchor, txt, empty, gem1, gem2, gem3, count

	-- 일반 마부 검색
	for _, slot in pairs(tradeitemslots[1]) do
		id = GetInventorySlotInfo(slot)
		itemLink = GetInventoryItemLink("player", id)
        if (itemLink and itemLink ~= "") then
            local baseLevel = select(4,GetItemInfo(itemLink))
            if (baseLevel < 600) then  SSItemLevel:CheckEnchant(slot, id, itemLink, L.EnchantCheck) end
		end
	end
	
	-- 드군(600+ 마부 검색)
		for _, slot in pairs(tradeitemslots[3]) do
		id = GetInventorySlotInfo(slot)
		itemLink = GetInventoryItemLink("player", id)
        if (itemLink and itemLink ~= "") then
            local baseLevel = select(4,GetItemInfo(itemLink))
			local itype = select(6,GetItemInfo(itemLink))
			if(slot == "SecondaryHandSlot" and itype ~= "무기") then break end
            if (baseLevel >= 600) then SSItemLevel:CheckEnchant(slot, id, itemLink, L.EnchantCheck) end
		end
	end

	-- 빈 보석 홈 검색
	for slot,t in pairs(itemslots) do
		id = GetInventorySlotInfo(slot)
		itemLink = GetInventoryItemLink("player", id)
		if (itemLink and itemLink ~= "") then self:CheckGems(slot, id, itemLink, L.JewelCraft) end
	end

	-- 죔쇠 검색
	for _, slot in pairs(tradeitemslots[2]) do
		id = GetInventorySlotInfo(slot)
		itemLink = GetInventoryItemLink("player", id)
		local baseLevel = select(4,GetItemInfo(itemLink))
		if (baseLevel < 600) then
			if (itemLink and itemLink ~= "") then self:CheckGems(slot, id, itemLink, L.Buckle, true)	end
		end
	end
    
	-- 검사 경과
	for _,t in pairs(itemslots) do
		if (t and t[7] and t[7]:IsShown()) then
			return nil
		end
	end
	return true
end


function SSItemLevel:PLAYER_LOGIN()
	if (SSItemLevelMore == nil) then SSItemLevelMore = true end

	local font, _, flags = NumberFontNormal:GetFont()
	local check = CreateFrame("CheckButton", addonName.."StateCheckButton", _G["PaperDollFrame"], "UICheckButtonTemplate")
	check:SetSize(16,16)
	_G[check:GetName() .. "Text"]:SetFont(font, 10, flags)
	_G[check:GetName() .. "Text"]:SetTextColor(1,1,1)
	_G[check:GetName() .. "Text"]:SetText("자세히")
	_G[check:GetName() .. "Text"]:ClearAllPoints()
	_G[check:GetName() .. "Text"]:SetPoint("LEFT", check, "RIGHT", 0, 0)
	check:SetChecked(SSItemLevelMore)
	check:SetPoint("BOTTOMLEFT", _G["PaperDollFrame"], "BOTTOMLEFT", 6, 18)
	check:SetScript("OnClick", function (self)
		SSItemLevelMore = self:GetChecked() and true or false
		if (SSItemLevelMore) then
			SSItemLevel:ScanInventory()
		else
			SSItemLevel:HideAllButtons()
		end
	end)
	local b = CreateFrame("BUTTON", nil, _G["PaperDollFrame"], "UIPanelButtonTemplate");
	b:SetWidth(66)
	b:SetHeight(_G["CharacterFrameExpandButton"]:GetHeight() / 1.5)
	b:SetPoint("RIGHT", _G["CharacterFrameExpandButton"], "LEFT", 0, 2)
	b:SetText(L.Check)
	b:SetScript("OnEnter", function(self)
		_G["GameTooltip"]:SetOwner(self, "ANCHOR_TOP")
		_G["GameTooltip"]:AddLine(self.Check and L.AfterCheckTooltip or L.CheckTooltip)
		_G["GameTooltip"]:Show()
	end)
	b:SetScript("OnLeave", function()
		_G["GameTooltip"]:Hide()
	end)
	b:SetScript("OnClick", function (self)
		if (self.Check) then
			SSItemLevel:ScanInventory()
			self:SetText(L.Check)
			self.Check = nil
		else
			if(SSItemLevel:CheckAllItems())then
				if (_G["GameTooltip"]:IsShown()) then
					_G["GameTooltip"]:ClearLines()
					_G["GameTooltip"]:AddLine(L.CheckSuccess)
					_G["GameTooltip"]:Show()
				end
				SSItemLevel:ScanInventory()
				return
			else
				self:SetText(L.AfterCheck)
				self.Check = true
			end
		end
		if (_G["GameTooltip"]:IsShown()) then
			_G["GameTooltip"]:ClearLines()
			_G["GameTooltip"]:AddLine(self.Check and L.AfterCheckTooltip or L.CheckTooltip)
			_G["GameTooltip"]:Show()
		end
	end)

	self:HookScript("OnEvent", function(self, event, ...)
		if (event == "UNIT_INVENTORY_CHANGED") then
			if ("player" == ...) then
				b.Check = nil
				b:SetText(L.Check)
				self:ScanInventory()
			end
		end
	end)
	_G["PaperDollFrame"]:HookScript("OnShow", function(self, ...)
		-- 룬 마부 검색
		for _, id in pairs({53323,54446,70164,62158,53331,53341,53342,54447,53343,53344,}) do
			local n = GetSpellInfo(id)
			if (n) then
				runSpells[n] = true
			end
		end
		-- 기타 검색
		if (not L.Enchant or not EnchantIcon) then
			L.Enchant, _, EnchantIcon = GetSpellInfo(28029)
		end
		if (not L.Runeforg or not RuneforgIcon) then
			L.Runeforg, _, RuneforgIcon = GetSpellInfo(53428)
		end
		if (not L.Blacksmith ) then
			L.Blacksmith = GetSpellInfo(29844)
		end

		SSItemLevel:ScanInventory()
		SSItemLevel:RegisterEvent("SOCKET_INFO_UPDATE")
		SSItemLevel:RegisterEvent("FORGE_MASTER_ITEM_CHANGED")
		SSItemLevel:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
		SSItemLevel:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	end)
	_G["PaperDollFrame"]:HookScript("OnHide", function(self, ...)
		SSItemLevel:UnregisterEvent("SOCKET_INFO_UPDATE")
		SSItemLevel:UnregisterEvent("FORGE_MASTER_ITEM_CHANGED")
		SSItemLevel:UnregisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
		SSItemLevel:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
		b.Check = nil
		b:SetText(L.Check)
	end)
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end
SSItemLevel.SOCKET_INFO_UPDATE = SSItemLevel.ScanInventory
SSItemLevel.FORGE_MASTER_ITEM_CHANGED = SSItemLevel.ScanInventory
SSItemLevel.ITEM_UPGRADE_MASTER_UPDATE = SSItemLevel.ScanInventory
SSItemLevel.PLAYER_EQUIPMENT_CHANGED = SSItemLevel.ScanInventory
SSItemLevel.UNIT_INVENTORY_CHANGED = function(self, unit)
	if (unit == "player") then
		self:UpdateItemLevel()
		self:ScanInventory()
	end
end

SSItemLevel:RegisterEvent("PLAYER_LOGIN")

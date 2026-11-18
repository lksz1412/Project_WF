local addOnName = GetAddOnDependencies(...)
local texturePath = "Interface\\AddOns\\"..addOnName.."_UI\\Texture\\"
local BII3 = _G[addOnName]
local Search = CreateFrame("Frame", addOnName.."Search", UIParent)
local LBI = LibStub("LibBlueItem-1.0")
Search.db = BII3.chardb.search

local backdrop = {
	edgeFile = texturePath.."Border",
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 2, right = 2, top = 2, bottom = 2 },
}
local _

BII3.search = Search
tinsert(UISpecialFrames, addOnName.."Search")
Search:SetBackdrop(backdrop)
backdrop.bgFile = nil
Search:SetBackdropColor(0, 0, 0, 0.75)
Search:SetSize(256, 472)
Search:SetPoint(BII3.chardb.search.anchor, BII3.chardb.search.px, BII3.chardb.search.py)
Search:SetToplevel(true)
Search:EnableMouse(true)
Search:SetMovable(true)
Search:SetClampedToScreen(true)
Search:RegisterForDrag("LeftButton", "RightButton")
Search:SetScript("OnDragStart", Search.StartMoving)
Search:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	BII3.chardb.search.anchor, _, _, BII3.chardb.search.px, BII3.chardb.search.py = self:GetPoint()
end)
Search:SetScript("OnShow", function()
	PlaySound("igCharacterInfoOpen")
end)
Search:SetScript("OnHide", function()
	PlaySound("igCharacterInfoClose")
	collectgarbage()
end)
local region = Search:CreateTexture(nil, "OVERLAY")
region:SetPoint("TOPLEFT", 5, -5)
region:SetSize(18, 18)
region:SetTexture("Interface\\Minimap\\Tracking\\None")
region:SetTexCoord(0.07, 0.93, 0.07, 0.93)
region = Search:CreateFontString(nil, "OVERLAY", "GameFontNormal")
region:SetPoint("TOP", 0, -7)
region:SetText(GetAddOnMetadata(addOnName.."_Search", "Title") or "")
region = CreateFrame("Button", nil, Search, "UIPanelCloseButton")
region:SetFrameLevel(Search:GetFrameLevel() + 1)
region:SetPoint("TOPRIGHT", 2, 2)

local function editBoxOnFocusGained(self)
	self:HighlightText()
	Search.focused = self
	CloseDropDownMenus(1)
end

local function editBoxOnFocusLost(self)
	self:HighlightText(0, 0)
	Search.focused = nil
end

local function editBoxOnEnter(self)
	self.inner:SetTexture(1, 0, 0, 0.35)
end

local function editBoxOnLeave(self)
	self.inner:SetTexture(0, 0, 0, 0.35)
end

local function clearAllFocus()
	if Search.focused then
		Search.focused:ClearFocus()
	end
end

local function textChanged(self)
	if self.key then
		local value = (self:GetText() or ""):trim()
		if value == "" then
			Search.db[self.key] = nil
		elseif self:IsNumeric() then
			Search.db[self.key] = tonumber(value)
		else
			Search.db[self.key] = value
		end
	end
end

local function createFrame(frameType, name, title, width)
	local frame = CreateFrame(frameType, addOnName.."Search"..name, Search)
	frame:SetFrameLevel(Search:GetFrameLevel() + 1)
	frame:SetSize(width or 204, 24)
	if width == 0 then
		frame:SetPoint("RIGHT", -7, 0)
	end
	frame:SetBackdrop(backdrop)
	if frameType == "Button" then
		frame:SetNormalFontObject("GameFontHighlightLeft")
		frame:SetText(UNKNOWN)
		frame:GetFontString():ClearAllPoints()
		frame:GetFontString():SetPoint("LEFT", 8, 1)
		frame:GetFontString():SetPoint("RIGHT", -8, 1)
		frame:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		frame:GetNormalTexture():SetTexture(0, 0, 0, 0.35)
		frame:GetNormalTexture():ClearAllPoints()
		frame:GetNormalTexture():SetPoint("TOPLEFT", 4, -4)
		frame:GetNormalTexture():SetPoint("BOTTOMRIGHT", -4, 4)
		frame:SetHighlightTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		frame:GetHighlightTexture():SetTexture(1, 0, 0, 0.35)
		frame:GetHighlightTexture():SetAllPoints(frame:GetNormalTexture())
		frame:SetPushedTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		frame:GetPushedTexture():SetTexture(1, 0, 0, 0.1)
		frame:GetPushedTexture():SetAllPoints(frame:GetNormalTexture())
		frame:SetScript("PreClick", clearAllFocus)
	elseif frameType == "EditBox" then
		frame:SetAutoFocus(nil)
		frame:EnableMouse(true)
		frame:SetFontObject("GameFontHighlight")
		frame:SetJustifyH("LEFT")
		frame:SetTextInsets(8, 8, 0, 0)
		frame:SetText(UNKNOWN)
		frame:SetScript("OnTextChanged", textChanged)
		frame:SetScript("OnEditFocusGained", editBoxOnFocusGained)
		frame:SetScript("OnEditFocusLost", editBoxOnFocusLost)
		frame:SetScript("OnEnterPressed", EditBox_ClearFocus)
		frame:SetScript("OnEscapePressed", EditBox_ClearFocus)
		frame:SetScript("OnHide", EditBox_ClearFocus)
		frame:SetScript("OnEnter", editBoxOnEnter)
		frame:SetScript("OnLeave", editBoxOnLeave)
		frame.inner = frame:CreateTexture(nil, "BACKGROUND")
		frame.inner:SetPoint("TOPLEFT", 4, -4)
		frame.inner:SetPoint("BOTTOMRIGHT", -4, 4)
		frame.inner:SetTexture(0, 0, 0, 0.35)
	end
	if title then
		frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
		frame.title:SetHeight(24)
		frame.title:SetPoint("TOPRIGHT", frame, "TOPLEFT", -2, 0)
		frame.title:SetPoint("LEFT", Search, "LEFT", 8, 0)
		frame.title:SetText(title)
	end
	return frame
end

Search.name = createFrame("EditBox", "Name", "이름", 0)
Search.name:SetPoint("TOPLEFT", 70, -26)
Search.name.key = "name"
Search.equipLoc = createFrame("Button", "EquipLoc", "착용 부위", 0)
Search.equipLoc:SetPoint("TOPLEFT", Search.name, "BOTTOMLEFT", 0, -2)
Search.equipLoc:SetScript("OnClick", function(self)
	ToggleDropDownMenu(1, nil, Search.equipLocDropDown, self, 0, 0)
end)
Search.equipLocDropDown = CreateFrame("Frame", addOnName.."SearchEquipLocDropDown", Search.equipLoc, "UIDropDownMenuTemplate")
Search.rarity = createFrame("Button", "Rarity", "등급", 0)
Search.rarity:SetPoint("TOPLEFT", Search.equipLoc, "BOTTOMLEFT", 0, -2)
Search.rarity:SetScript("OnClick", function(self)
	ToggleDropDownMenu(1, nil, Search.rarityDropDown, self, 0, 0)
end)
Search.rarityDropDown = CreateFrame("Frame", addOnName.."SearchRarityDropDown", Search.rarity, "UIDropDownMenuTemplate")
Search.minLevel = createFrame("EditBox", "MinLevel", "아이템레벨", 50)
Search.minLevel:SetPoint("TOPLEFT", Search.rarity, "BOTTOMLEFT", 0, -2)
Search.minLevel:SetNumeric(true)
Search.minLevel:SetMaxBytes(4)
Search.minLevel:SetJustifyH("CENTER")
Search.minLevel:SetTextInsets(0, 0, 0, 0)
Search.minLevel.key = "minLevel"
Search.maxLevel = createFrame("EditBox", "MaxLevel", "─", 50)
Search.maxLevel:SetPoint("LEFT", Search.minLevel, "RIGHT", 30, 0)
Search.maxLevel:SetNumeric(true)
Search.maxLevel:SetMaxBytes(4)
Search.maxLevel:SetJustifyH("CENTER")
Search.maxLevel.title:SetPoint("LEFT", Search.minLevel, "RIGHT", 10, 0)
Search.maxLevel:SetTextInsets(0, 0, 0, 0)
Search.maxLevel.key = "maxLevel"
Search.condition1 = createFrame("Button", "Condition1", "검색 조건1", 0)
Search.condition1:SetPoint("TOPLEFT", Search.minLevel, "BOTTOMLEFT", 0, -2)
Search.condition1:SetScript("OnClick", function(self)
	ToggleDropDownMenu(1, nil, Search.condition1DropDown, self, 0, 0)
end)
Search.condition1DropDown = CreateFrame("Frame", addOnName.."SearchCondition1DropDown", Search.condition1, "UIDropDownMenuTemplate")
Search.condition1DropDown:SetID(1)
Search.condition2 = createFrame("Button", "Condition2", "검색 조건2", 0)
Search.condition2:SetPoint("TOPLEFT", Search.condition1, "BOTTOMLEFT", 0, -2)
Search.condition2:SetScript("OnClick", function(self)
	ToggleDropDownMenu(1, nil, Search.condition2DropDown, self, 0, 0)
end)
Search.condition2DropDown = CreateFrame("Frame", addOnName.."SearchCondition2DropDown", Search.condition2, "UIDropDownMenuTemplate")
Search.condition2DropDown:SetID(2)
Search.condition3 = createFrame("Button", "Condition3", "검색 조건3", 0)
Search.condition3:SetPoint("TOPLEFT", Search.condition2, "BOTTOMLEFT", 0, -2)
Search.condition3:SetScript("OnClick", function(self)
	ToggleDropDownMenu(1, nil, Search.condition3DropDown, self, 0, 0)
end)
Search.condition3DropDown = CreateFrame("Frame", addOnName.."SearchCondition3DropDown", Search.condition3, "UIDropDownMenuTemplate")
Search.condition3DropDown:SetID(3)
Search.condition4 = createFrame("Button", "Condition4", "검색 조건4", 0)
Search.condition4:SetPoint("TOPLEFT", Search.condition3, "BOTTOMLEFT", 0, -2)
Search.condition4:SetScript("OnClick", function(self)
	ToggleDropDownMenu(1, nil, Search.condition4DropDown, self, 0, 0)
end)
Search.condition4DropDown = CreateFrame("Frame", addOnName.."SearchCondition4DropDown", Search.condition4, "UIDropDownMenuTemplate")
Search.condition4DropDown:SetID(4)
Search.reset = CreateFrame("Button", addOnName.."SearchResetButton", Search, "UIPanelButtonTemplate")
Search.reset:RegisterForClicks("LeftButtonUp")
Search.reset:SetSize(110, 24)
Search.reset:SetPoint("TOP", Search.condition4, "BOTTOM", 0, -2)
Search.reset:SetPoint("RIGHT", Search, "CENTER", 0, 0)
Search.reset:SetText("초기화")
Search.reset:SetScript("OnClick", function()
	Search:Reset()
	Search:Search()
end)
Search.search = CreateFrame("Button", addOnName.."SearchButton", Search, "UIPanelButtonTemplate")
Search.search:RegisterForClicks("LeftButtonUp")
Search.search:SetSize(110, 24)
Search.search:SetPoint("TOP", Search.condition4, "BOTTOM", 0, -2)
Search.search:SetPoint("LEFT", Search, "CENTER", 0, 0)
Search.search:SetText("검색")
Search.search:SetScript("OnClick", function()
	Search:Refresh()
	Search:Search()
end)
region = Search:CreateTexture()
region:SetDrawLayer("ARTWORK", 2)
region:SetTexture(texturePath.."Border")
region:SetTexCoord(0.546875, 0.703125, 0, 0.375)
region:SetHeight(7)
region:SetPoint("TOP", Search.reset, "BOTTOM", 0, -2)
region:SetPoint("LEFT", 3, 0)
region:SetPoint("RIGHT", -3, 0)
Search.noMatch = Search:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Search.noMatch:SetText("검색된 아이템이 없습니다")
Search.noMatch:SetPoint("TOPLEFT", region, "BOTTOMLEFT", 1, 0)
Search.noMatch:SetPoint("BOTTOMRIGHT", -6, 4)

Search.scroll = CreateFrame("ScrollFrame", addOnName.."SearchScroll", Search, "ListScrollFrameTemplate")
Search.scroll:SetFrameLevel(Search:GetFrameLevel() + 1)
Search.scroll:SetPoint("TOPLEFT", Search.noMatch, 0, 0)
Search.scroll:SetPoint("BOTTOMRIGHT", Search.noMatch, -20, 0)
Search.scroll:DisableDrawLayer("BACKGROUND")
Search.scroll.scrollBar = _G[addOnName.."SearchScrollScrollBar"]
Search.scroll.scrollBar.doNotHide = true

local function itemButtonOnEnter(self)
	Search.scroll.target = self
	if self.id then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(BII3:GetItemSimpleLink(self.id, self.suffix and -self.suffix or 0, self.unique))
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end
end

local function itemButtonOnLeave(self)
	Search.scroll.target = nil
	GameTooltip:Hide()
end

local link

local function itemButtonOnClick(self, button)
	BII3:ItemOnClick(self.id, button)
end

local itemButtons = {}
for i = 1, 10 do
	itemButtons[i] = CreateFrame("Button", addOnName.."SearchItemButton"..i, Search)
	itemButtons[i]:SetWidth(0)
	itemButtons[i]:SetHeight(20)
	itemButtons[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	itemButtons[i]:SetNormalTexture("Interface\\Icons\\Temp")
	itemButtons[i]:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
	itemButtons[i]:GetNormalTexture():ClearAllPoints()
	itemButtons[i]:GetNormalTexture():SetPoint("LEFT", itemButtons[i], "LEFT")
	itemButtons[i]:GetNormalTexture():SetSize(20, 20)
	itemButtons[i]:SetNormalFontObject("GameFontNormalLeft")
	itemButtons[i]:SetText(UNKNOWN)
	itemButtons[i]:GetFontString():ClearAllPoints()
	itemButtons[i]:GetFontString():SetPoint("TOPLEFT", 24, 0)
	itemButtons[i]:GetFontString():SetPoint("BOTTOMRIGHT", 0, 0)
	itemButtons[i]:SetScript("OnEnter", itemButtonOnEnter)
	itemButtons[i]:SetScript("OnLeave", itemButtonOnLeave)
	itemButtons[i]:SetScript("OnClick", itemButtonOnClick)
	itemButtons[i]:SetPoint("TOPLEFT", region, "BOTTOMLEFT", 2, (i - 1) * (-20))
	itemButtons[i]:SetPoint("TOPRIGHT", region, "BOTTOMRIGHT", -22, (i - 1) * (-20))
end

region = CreateFrame("Frame", nil, Search.scroll)
region:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = texturePath.."ScrollBar",
	tile = true, tileSize = 16,  edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
region:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
region:SetBackdropColor(0.1, 0.1, 0.1, 1)
region:SetPoint("TOPLEFT", Search.scroll.scrollBar, 2, 0)
region:SetPoint("BOTTOMRIGHT", Search.scroll.scrollBar, -2, 1)

region = nil

local statsList = {
	ITEM_MOD_STRENGTH_SHORT,
	ITEM_MOD_AGILITY_SHORT,
	ITEM_MOD_STAMINA_SHORT,
	ITEM_MOD_INTELLECT_SHORT,
	ITEM_MOD_SPIRIT_SHORT,
	ITEM_MOD_ATTACK_POWER_SHORT,
	ITEM_MOD_SPELL_POWER_SHORT,
	ITEM_MOD_CRIT_RATING_SHORT,
	ITEM_MOD_HIT_RATING_SHORT,
	ITEM_MOD_HASTE_RATING_SHORT,
	ITEM_MOD_MASTERY_RATING_SHORT,
	ITEM_MOD_EXPERTISE_RATING_SHORT,
	ITEM_MOD_DODGE_RATING_SHORT,
	ITEM_MOD_PARRY_RATING_SHORT,
	ITEM_MOD_RESILIENCE_RATING_SHORT,
	ITEM_MOD_PVP_POWER_SHORT,
	RESISTANCE0_NAME,
}
local rarityList = { "희귀 아이템", "영웅 아이템", "전설 아이템", "희귀 이상 아이템", "영웅 이상 아이템" }
local category = {
	[0000] = "전체",
	[0100] = "양손 장비",
	[0102] = "양손 장비, 도검",
	[0103] = "양손 장비, 둔기",
	[0104] = "양손 장비, 도끼",
	[0107] = "양손 장비, 장창",
	[0108] = "양손 장비, 지팡이",
	[0200] = "주장비",
	[0202] = "주장비, 도검",
	[0203] = "주장비, 둔기",
	[0204] = "주장비, 도끼",
	[0205] = "주장비, 단검",
	[0206] = "주장비, 장착 무기",
	[0300] = "한손 장비",
	[0302] = "한손 장비, 도검",
	[0303] = "한손 장비, 둔기",
	[0304] = "한손 장비, 도끼",
	[0305] = "한손 장비, 단검",
	[0306] = "한손 장비, 장착 무기",
	[0400] = "보조 무기",
	[0402] = "보조 무기, 도검",
	[0403] = "보조 무기, 둔기",
	[0404] = "보조 무기, 도끼",
	[0405] = "보조 무기, 단검",
	[0406] = "보조 무기, 장착 무기",
	[0500] = "원거리 장비",
	[0511] = "원거리 장비, 총",
	[0512] = "원거리 장비, 활",
	[0513] = "원거리 장비, 석궁",
	[0515] = "원거리 장비, 마법봉",
	[0610] = "방패",
	[0799] = "보조장비",
	[0900] = "머리",
	[0917] = "머리, 천",
	[0918] = "머리, 가죽",
	[0919] = "머리, 사슬",
	[0920] = "머리, 판금",
	[1000] = "어깨",
	[1017] = "어깨, 천",
	[1018] = "어깨, 가죽",
	[1019] = "어깨, 사슬",
	[1020] = "어깨, 판금",
	[1100] = "가슴",
	[1117] = "가슴, 천",
	[1118] = "가슴, 가죽",
	[1119] = "가슴, 사슬",
	[1120] = "가슴, 판금",
	[1200] = "다리",
	[1217] = "다리, 천",
	[1218] = "다리, 가죽",
	[1219] = "다리, 사슬",
	[1220] = "다리, 판금",
	[1300] = "손",
	[1317] = "손, 천",
	[1318] = "손, 가죽",
	[1319] = "손, 사슬",
	[1320] = "손, 판금",
	[1400] = "손목",
	[1417] = "손목, 천",
	[1418] = "손목, 가죽",
	[1419] = "손목, 사슬",
	[1420] = "손목, 판금",
	[1500] = "허리",
	[1517] = "허리, 천",
	[1518] = "허리, 가죽",
	[1519] = "허리, 사슬",
	[1520] = "허리, 판금",
	[1600] = "발",
	[1617] = "발, 천",
	[1618] = "발, 가죽",
	[1619] = "발, 사슬",
	[1620] = "발, 판금",
	[1717] = "등",
	[1899] = "목",
	[1999] = "손가락",
	[2099] = "장신구",
}

function Search:Reset()
	for p in pairs(self.db) do
		self.db[p] = nil
	end
	self:Refresh()
end

function Search:Refresh()
	self.name:SetText(self.db.name or "")
	self.equipLoc:SetText(category[self.db.equipLoc] or "전체")
	self.db.rarity = self.db.rarity or 4
	self.rarity:SetText(rarityList[self.db.rarity] or "")
	if self.db.minLevel and self.db.maxLevel then
		if self.db.minLevel > self.db.maxLevel then
			self.db.minLevel = self.db.maxLevel
		end
	end
	self.minLevel:SetText(self.db.minLevel or "")
	self.maxLevel:SetText(self.db.maxLevel or "")
	self.condition1:SetText(statsList[self.db.con1] or "")
	self.condition2:SetText(statsList[self.db.con2] or "")
	self.condition3:SetText(statsList[self.db.con3] or "")
	self.condition4:SetText(statsList[self.db.con4] or "")
	CloseDropDownMenus(1)
	clearAllFocus()
end

local function equipLocFunc(self, arg1, arg2)
	arg1 = arg1 + arg2
	if category[arg1] then
		Search.db.equipLoc = arg1
	else
		Search.db.equipLoc = nil
	end
	Search:Refresh()
end

UIDropDownMenu_Initialize(Search.equipLocDropDown, function(self, level)
	local info = UIDropDownMenu_CreateInfo()
	info.isNotRadio = true
	info.notCheckable = true
	info.func = equipLocFunc
	if level == 1 then
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "전체", nil, 0, 0, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "양손 장비", true, 1, 100, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "주장비", true, 2, 200, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "한손 장비", true, 3, 300, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "보조 무기", true, 4, 400, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "원거리 장비", true, 5, 500, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "방패", nil, 6, 600, 10
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "보조장비", nil, 7, 700, 99
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "머리", true, 9, 900, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "어깨", true, 10, 1000, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "가슴", true, 11, 1100, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "다리", true, 12, 1200, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "손", true, 13, 1300, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "손목", true, 14, 1400, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "허리", true, 15, 1500, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "발", true, 16, 1600, 0
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "등", nil, 17, 1700, 17
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "목", nil, 18, 1800, 99
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "손가락", nil, 19, 1900, 99
		UIDropDownMenu_AddButton(info, level)
		info.text, info.hasArrow, info.value, info.arg1, info.arg2 = "장신구", nil, 20, 2000, 99
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 and type(UIDROPDOWNMENU_MENU_VALUE) == "number" then
		info.hasArrow, info.value = nil
		info.arg1 = UIDROPDOWNMENU_MENU_VALUE * 100
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.text, info.arg2 = "전체", 0
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "도검", 2
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "둔기", 3
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "도끼", 4
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "장창", 7
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "지팡이", 8
			UIDropDownMenu_AddButton(info, level)
		elseif UIDROPDOWNMENU_MENU_VALUE >= 2 and UIDROPDOWNMENU_MENU_VALUE <= 4 then
			info.text, info.arg2 = "전체", 0
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "도검", 2
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "둔기", 3
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "도끼", 4
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "단검", 5
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "장착 무기", 6
			UIDropDownMenu_AddButton(info, level)
		elseif UIDROPDOWNMENU_MENU_VALUE == 5 then
			info.text, info.arg2 = "전체", 0
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "총", 11
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "활", 12
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "석궁", 13
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "마법봉", 15
			UIDropDownMenu_AddButton(info, level)
		elseif UIDROPDOWNMENU_MENU_VALUE >= 9 and UIDROPDOWNMENU_MENU_VALUE <= 20 then
			info.text, info.arg2 = "전체", 0
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "천", 17
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "가죽", 18
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "사슬", 19
			UIDropDownMenu_AddButton(info, level)
			info.text, info.arg2 = "판금", 20
			UIDropDownMenu_AddButton(info, level)
		end
	end
end)

local function rarityFunc(self, arg1)
	if arg1 then
		Search.db.rarity = arg1
		Search:Refresh()
	end
end

UIDropDownMenu_Initialize(Search.rarityDropDown, function(self)
	local info = UIDropDownMenu_CreateInfo()
	info.isNotRadio = true
	info.notCheckable = true
	info.func = rarityFunc
	Search.db.rarity = Search.db.rarity or 4
	for i = 1, #rarityList do
		info.text, info.arg1 = rarityList[i], i
		UIDropDownMenu_AddButton(info)
	end
	info.text, info.arg1 = "닫기", nil
	UIDropDownMenu_AddButton(info)
end)

local function conditionFunc(self, arg1, arg2)
	if arg1 then
		if arg1 == 0 then
			Search.db["con"..arg2] = nil
		else
			Search.db["con"..arg2] = arg1
		end
		Search:Refresh()
	end
end

local function conditionDropDown(self)
	local info = UIDropDownMenu_CreateInfo()
	info.isNotRadio = true
	info.notCheckable = true
	info.func = conditionFunc
	info.arg2 = self:GetID()
	for i = 1, #statsList do
		if self:GetID() == 1 and (Search.db.con2 == i or Search.db.con3 == i or Search.db.con4 == i) then
		elseif self:GetID() == 2 and (Search.db.con1 == i or Search.db.con3 == i or Search.db.con4 == i) then
		elseif self:GetID() == 3 and (Search.db.con2 == i or Search.db.con1 == i or Search.db.con4 == i) then
		elseif self:GetID() == 4 and (Search.db.con2 == i or Search.db.con3 == i or Search.db.con1 == i) then
		else
			info.text, info.arg1 = statsList[i], i
			UIDropDownMenu_AddButton(info)
		end
	end
	info.text, info.arg1 = "조건 없음", 0
	UIDropDownMenu_AddButton(info)
	info.text, info.arg1 = "닫기", nil
	UIDropDownMenu_AddButton(info)
end

UIDropDownMenu_Initialize(Search.condition1DropDown, conditionDropDown)
UIDropDownMenu_Initialize(Search.condition2DropDown, conditionDropDown)
UIDropDownMenu_Initialize(Search.condition3DropDown, conditionDropDown)
UIDropDownMenu_Initialize(Search.condition4DropDown, conditionDropDown)

local _G = _G
local pairs = _G.pairs
local wipe = _G.table.wipe
local tinsert = _G.table.insert
local floor = _G.math.floor
local GetAddOnMetadata = _G.GetAddOnMetadata

local itemList, idx, stats, safeName, rarity, name, level, category, loc1, loc2, sloc1, sloc2 = {}
local unique, suffix

local function checkName(name, safeName)
	if safeName then
		if name:find(safeName) then
			return true
		else
			return nil
		end
	else
		return true
	end
end

local function checkEquipLoc(category)
	if Search.db.equipLoc then
		if Search.db.equipLoc == 0 or Search.db.equipLoc == category then
			return true
		else
			sloc1 = floor(Search.db.equipLoc / 100)
			loc1 = floor(category / 100)
			if sloc1 == loc1 then
				sloc2 = Search.db.equipLoc - sloc1 * 100
				if sloc2 == 0 or sloc2 == (category - loc1 * 100) then
					return true
				end
			end
			return nil
		end
	else
		return true
	end
end

local function checkRarity(rarity)
	if Search.db.rarity == 1 then
		return rarity == 3
	elseif Search.db.rarity == 2 then
		return rarity == 4
	elseif Search.db.rarity == 3 then
		return rarity == 5
	elseif Search.db.rarity == 4 then
		return rarity >= 3
	elseif Search.db.rarity == 5 then
		return rarity >= 4
	end
	return nil
end

local function checkLevel(level)
	if Search.db.minLevel or Search.db.maxLevel then
		return level >= (Search.db.minLevel or level) and level <= (Search.db.maxLevel or level)
	else
		return true
	end
end

local function checkStats(stats)
	local con
	for i = 1, 4 do
		con = Search.db["con"..i]
		if con and con > 0 then
			if bit.band(stats, 2 ^ (con - 1)) == 0 then
				return false
			end
		end
	end
	return true
end

local function getSafeText(text)
	if text == "^" or text == "$" then
		text = nil
	elseif text then
		local func, err = loadstring(("return ('____'):find('%s')"):format(text) or "")
		if func and not err then
			func, err = pcall(func)
		end
		if err then
			text = "____"
		end
	end
	return text
end

local function updateScroll()
	FauxScrollFrame_Update(Search.scroll, #itemList, 10, 20)
	for i, btn in ipairs(itemButtons) do
		idx = i + Search.scroll.offset
		if itemList[idx] then
			if type(itemList[idx]) == "string" then
				btn.id, btn.unique, btn.suffix = itemList[idx]:match("(%d+)%-(%d+)%-(%d+)")
				btn.id = tonumber(btn.id)
				btn.unique = tonumber(btn.unique)
				btn.suffix = tonumber(btn.suffix)
			else
				btn.id, btn.unique, btn.suffix = itemList[idx]
			end
			btn:SetNormalTexture(BII3:GetItemIcon(btn.id))
			btn:SetText(BII3:GetItemColorName(btn.id, btn.suffix))
			btn:Show()
		else
			btn.id, btn.unique, btn.suffix = nil
			btn:Hide()
		end
	end
	if Search.scroll.target and Search.scroll.target:IsVisible() then
		itemButtonOnEnter(Search.scroll.target)
	else
		GameTooltip:Hide()
	end
end

Search.scroll:SetScript("OnVerticalScroll", function(self, scroll)
	FauxScrollFrame_OnVerticalScroll(self, scroll, 20, updateScroll)
end)

function Search:Search()
	wipe(itemList)
	safeName = self.db.name and getSafeText(self.db.name) or nil
	for id in pairs(BII3.itemDB) do
		if id > 0 then
			suffix = GetAddOnMetadata(addOnName.."_UI", "X-DB-ItemSuffix-"..id)
			if suffix then
				unique, suffix = suffix:match("(%d+)_(.+)")
				if suffix then
					for s in suffix:gmatch("(%d+)") do
						stats = GetAddOnMetadata(addOnName.."_Search", "X-DB-Stats-"..id.."-"..unique.."-"..s)
						if stats then
							rarity, name, level, category = BII3:GetItem(id)
							if rarity then
								name = (LBI:GetRandomSuffixFormat(tonumber(s)) or "%s"):format(name)
								if checkName(name, safeName) and checkRarity(rarity) and checkEquipLoc(category) and checkLevel(level) and checkStats(stats) then
									tinsert(itemList, id.."-"..unique.."-"..s)
								end
							end
						end
					end
				end
			else
				stats = tonumber(GetAddOnMetadata(addOnName.."_Search", "X-DB-Stats-"..id) or "")
				if stats then
					rarity, name, level, category = BII3:GetItem(id)
					if rarity then
						if checkName(name, safeName) and checkRarity(rarity) and checkEquipLoc(category) and checkLevel(level) and checkStats(stats) then
							tinsert(itemList, id)
						end
					end
				end
			end
		end
	end
	stats, safeName, rarity, name, level, category, loc1, loc2, sloc1, sloc2, unique, suffix = nil
	collectgarbage()
	Search.scroll.scrollBar:SetMinMaxValues(0, 0)
	Search.scroll.scrollBar:SetValue(0)
	Search.scroll.offset = 0
	if #itemList == 0 then
		self.noMatch:Show()
	else
		BII3:Sort(itemList)
		self.noMatch:Hide()
	end
	updateScroll()
end

Search:Refresh()
Search:Search()
Search:Raise()
PlaySound("igCharacterInfoOpen")
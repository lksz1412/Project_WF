local addOnName = GetAddOnDependencies(...)
local texturePath = "Interface\\AddOns\\"..(...).."\\Texture\\"
local _
local BII3 = _G[addOnName]

function BII3:ClearColor(text)
	return text:gsub("|r", ""):gsub("|c[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]", "")
end

local function startMoving(self)
	CloseDropDownMenus(1)
	self.isMoving = true
	BII3:StartMoving()
end

local function stopMoving(self)
	if self.isMoving then
		self.isMoving = nil
		BII3:StopMovingOrSizing()
		BII3.db.anchor, _, _, BII3.db.px, BII3.db.py = BII3:GetPoint()
		BII3.db.height = BII3:GetHeight() or 312
	end
end

tinsert(UISpecialFrames, addOnName)
BII3:SetMovable(true)
BII3:SetResizable(true)
BII3:EnableMouse(true)
BII3:SetClampedToScreen(true)
BII3:SetScale(BII3.db.scale)
BII3:SetSize(622, BII3.db.height)
BII3:SetMinResize(622, 183)
BII3:SetMaxResize(622, 612)
BII3:SetPoint(BII3.db.anchor, BII3.db.px, BII3.db.py)
BII3:RegisterForDrag("LeftButton", "RightButton")
BII3:SetBackdrop({
	edgeFile = texturePath.."Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
BII3:SetScript("OnMouseDown", BII3.CloseDropDownMenu)
BII3:SetScript("OnDragStart", startMoving)
BII3:SetScript("OnDragStop", stopMoving)
BII3:SetScript("OnShow", function(self)
	PlaySound("igCharacterInfoOpen")
	if self.forceRefresh then
		self.forceRefresh = nil
		self:Update(true)
	end
end)
BII3:SetScript("OnHide", function(self)
	PlaySound("igCharacterInfoClose")
	collectgarbage()
end)

local region = BII3:CreateTexture(nil, "BORDER")
region:SetPoint("TOPLEFT", 4, -4)
region:SetPoint("BOTTOMRIGHT", -4, 4)
region:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
region:SetGradientAlpha("VERTICAL", 0, 0, 0.25, 0.7, 0.1, 0.1, 0.35, 0.7)
region = CreateFrame("Button", nil, BII3)
region:SetFrameLevel(BII3:GetFrameLevel() + 1)
region:SetPoint("TOPLEFT", 6, -6)
region:SetSize(18, 18)
region:SetNormalTexture("Interface\\AddOns\\"..addOnName.."\\Icon")
region:SetPushedTexture("Interface\\AddOns\\"..addOnName.."\\Icon")
region:GetPushedTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
region:SetScript("OnClick", function() BII3:ToggleOption() end)
region:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine("옵션창 열기/닫기")
	GameTooltip:Show()
end)
region:SetScript("OnLeave", GameTooltip_Hide)
if BII3:HasModule("Search") then
	region = CreateFrame("Button", nil, BII3)
	region:SetFrameLevel(BII3:GetFrameLevel() + 1)
	region:SetPoint("TOPLEFT", 26, -6)
	region:SetSize(18, 18)
	region:SetNormalTexture("Interface\\Minimap\\Tracking\\None")
	region:SetPushedTexture("Interface\\Minimap\\Tracking\\None")
	region:GetPushedTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
	region:SetScript("OnClick", function() BII3:ToggleSearch() end)
	region:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("아이템 검색창 열기/닫기")
		GameTooltip:Show()
	end)
	region:SetScript("OnLeave", GameTooltip_Hide)
end
region = BII3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
region:SetPoint("TOP", 0, -7)
region:SetFormattedText("%s |cffffffffv%s.%s|r", GetAddOnMetadata(addOnName, "Title"), GetAddOnMetadata(addOnName, "Version"), GetAddOnMetadata(addOnName.."_UI", "X-DB-NumItems"))
region = CreateFrame("Button", nil, BII3, "UIPanelCloseButton")
region:SetFrameLevel(BII3:GetFrameLevel() + 1)
region:SetPoint("TOPRIGHT", 2, 2)
region = CreateFrame("Frame", nil, BII3)
region:SetFrameLevel(BII3:GetFrameLevel() + 1)
region:SetPoint("TOPLEFT", BII3, "BOTTOMLEFT", 0, 8)
region:SetPoint("BOTTOMRIGHT", 0, -2)
region:EnableMouse(true)
region:RegisterForDrag("LeftButton")
region:SetScript("OnMouseDown", function(self)
	self.isMoving = true
	BII3:StartSizing("BOTTOM")
end)
region:SetScript("OnMouseUp", stopMoving)
region:SetScript("OnHide", stopMoving)
BII3.dropdownButtons = {}
local function dropDownOnClick(self)
	ToggleDropDownMenu(1, self.key, BII3["listDropdown"..self:GetID()], self:GetName(), 0, 0)
end
local function dropDownOnMouseWheel(self, delta)
	if delta > 0 then
		if self.prevCode then
			BII3.db.code = self.prevCode
			BII3:Update()
		end
	elseif self.nextCode then
		BII3.db.code = self.nextCode
		BII3:Update()
	end
end
local function dropDownUpDownOnClick(self)
	dropDownOnMouseWheel(self:GetParent(), self.delta)
end
for i = 1, 3 do
	region = CreateFrame("Button", addOnName.."DropDownButton"..i, BII3)
	region.key = ""
	region:SetID(i)
	region:SetSize(204, 24)
	region:SetFrameLevel(BII3:GetFrameLevel() + 1)
	region:SetBackdrop(BII3:GetBackdrop())
	region:EnableMouseWheel(true)
	region:SetNormalFontObject("GameFontHighlight")
	region:SetText(UNKNOWN)
	region:GetFontString():ClearAllPoints()
	region:GetFontString():SetPoint("LEFT", 4, 1)
	region:GetFontString():SetPoint("RIGHT", -35, 1)
	region:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	region:GetNormalTexture():SetTexture(0, 0, 0, 0.35)
	region:GetNormalTexture():ClearAllPoints()
	region:GetNormalTexture():SetPoint("TOPLEFT", 4, -4)
	region:GetNormalTexture():SetPoint("BOTTOMRIGHT", -4, 4)
	region:SetHighlightTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	region:GetHighlightTexture():SetTexture(1, 0, 0, 0.35)
	region:GetHighlightTexture():SetAllPoints(region:GetNormalTexture())
	region:SetPushedTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	region:GetPushedTexture():SetTexture(1, 0, 0, 0.1)
	region:GetPushedTexture():SetAllPoints(region:GetNormalTexture())
	region:SetPoint("LEFT", BII3.dropdownButtons[i - 1], "RIGHT", 0, 0)
	region:SetScript("OnClick", dropDownOnClick)
	region:SetScript("OnMouseWheel", dropDownOnMouseWheel)
	region.up = CreateFrame("Button", nil, region)
	region.up.delta = 1
	region.up:SetSize(20, 20)
	region.up:SetFrameLevel(BII3:GetFrameLevel() + 2)
	region.up:SetPoint("RIGHT", -19, 0)
	region.up:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
	region.up:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
	region.up:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled")
	region.up:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	region.up:SetScript("OnClick", dropDownUpDownOnClick)
	region.down = CreateFrame("Button", nil, region)
	region.down.delta = -1
	region.down:SetSize(20, 20)
	region.down:SetFrameLevel(BII3:GetFrameLevel() + 2)
	region.down:SetPoint("RIGHT", -2, 0)
	region.down:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	region.down:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	region.down:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	region.down:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	region.down:SetScript("OnClick", dropDownUpDownOnClick)
	BII3.dropdownButtons[i] = region
end
BII3.dropdownButtons[1]:SetPoint("TOPLEFT", 5, -24)
BII3.container = CreateFrame("ScrollFrame", addOnName.."Container", BII3, "HybridScrollFrameTemplate")
BII3.container:SetPoint("TOPLEFT", 7, -50)
BII3.container:SetPoint("BOTTOMRIGHT", -23, 7)
BII3.container:SetFrameLevel(BII3:GetFrameLevel() + 1)
BII3.container.scrollBar = CreateFrame("Slider", addOnName.."ContainerScrollBar", BII3.container, "HybridScrollBarTemplate")
BII3.container.scrollBar:SetFrameLevel(BII3:GetFrameLevel() + 3)
BII3.container.scrollBar:SetPoint("TOPLEFT", BII3.container, "TOPRIGHT", 0, -12)
BII3.container.scrollBar:SetPoint("BOTTOMLEFT", BII3.container, "BOTTOMRIGHT", 0, 11)
BII3.container.scrollBar:DisableDrawLayer("ARTWORK")
BII3.container.scrollBar:EnableMouseWheel(true)
BII3.container.scrollBar:SetValueStep(.005)
BII3.container.scrollBar:SetScript("OnMouseWheel", function(self, ...)
	self:GetParent():GetScript("OnMouseWheel")(self:GetParent(), ...)
end)
BII3.container.scrollBar.doNotHide = true
BII3.container.scrollChild:SetWidth(BII3.container:GetWidth())
BII3.container.scrollChild:SetFrameLevel(BII3:GetFrameLevel() + 2)
BII3.container:UpdateScrollChildRect()
BII3.container:SetScript("OnSizeChanged", function(self)
	if self.displayNum ~= BII3:GetNumDisplayList() then
		self.update()
	end
end)
BII3.container:RegisterForDrag("LeftButton", "RightButton")
BII3.container:SetScript("OnDragStart", startMoving)
BII3.container:SetScript("OnDragStop", stopMoving)
BII3.container:SetScript("OnHide", stopMoving)
region = CreateFrame("Frame", nil, BII3.container)
region:SetFrameLevel(BII3.container:GetFrameLevel() + 1)
region:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = texturePath.."ScrollBar",
	tile = true, tileSize = 16,  edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
region:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
region:SetBackdropColor(0.1, 0.1, 0.1, 1)
region:SetPoint("TOPLEFT", BII3.container.scrollBar, 2, 0)
region:SetPoint("BOTTOMRIGHT", BII3.container.scrollBar, -3, 1)

BII3.randomSuffixItemsList = CreateFrame("Frame", nil, BII3.container)
BII3.randomSuffixItemsList:EnableMouse(true)
BII3.randomSuffixItemsList:SetFrameLevel(BII3.container:GetFrameLevel() + 5)
BII3.randomSuffixItemsList:SetBackdrop({
	bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
})
BII3.randomSuffixItemsList:SetBackdropColor(0, 0, 0, 0.75)
BII3.randomSuffixItemsList:Hide()
BII3.randomSuffixItemsList.buttons = {}
BII3.container.scrollBar:HookScript("OnValueChanged", function() CloseDropDownMenus(1) end)

if BII3:IsVisible() then
	BII3:GetScript("OnShow")(BII3)
end
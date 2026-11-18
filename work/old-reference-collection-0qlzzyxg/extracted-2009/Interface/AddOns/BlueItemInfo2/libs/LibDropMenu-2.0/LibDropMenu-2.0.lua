local lib = LibStub:NewLibrary("LibDropMenu-2.0", 2)
if not lib then return end

local _G = _G
local type = _G.type
local sort = _G.sort
local unpack = _G.unpack
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local tinsert = _G.table.insert
local GetCursorPosition = _G.GetCursorPosition
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetMouseFocus = _G.GetMouseFocus
local IsMouseButtonDown = _G.IsMouseButtonDown

lib.menus = lib.menus or {}
lib.frames = lib.frames or {}

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = 1, tileSize = 16, edgeSize = 16,
	insets = { top = 5, right = 5, left = 5, bottom = 5 },
}

------- User Function -----------

function lib:RegisterMenu(name, menu)
	if type(name) == "string" and type(menu) == "table" and menu.type == "group" and type(menu.args) == "table" then
		lib.menus[name] = menu
	end
end

function lib:UnregisterMenu(name)
	if type(name) == "string" then
		lib.menus[name] = nil
	end
end

function lib:IsOpen(name)
	return name and lib.openedMenu == name
end

function lib:OpenMenu(name, point, relative, relativePoint, xoffset, yoffset, minWidth, skipTitle)
	if type(name) == "string" and lib.menus[name] then
		lib:CloseMenu(1)
		lib.skipTitle = skipTitle
		lib.openedMenu = name
		if point == "CURSOR" or point == "cursor" then
			local uiScale = UIParent:GetScale()
			xoffset, yoffset = GetCursorPosition()
			xoffset, yoffset = xoffset / uiScale, -(GetScreenHeight() * uiScale - yoffset) / uiScale
			point, relative, relativePoint = "TOPLEFT", UIParent, "TOPLEFT"
		end
		lib:MakeMenu(1, lib.menus[name])
		lib.frames[1].owner = relative
		lib.frames[1]:ClearAllPoints()
		lib.frames[1]:SetPoint(point, relative, relativePoint, xoffset, yoffset)
	end
end

function lib:CloseMenu(level)
	level = level or 1
	local isClose = nil
	for _, frame in pairs(lib.frames) do
		if frame:IsShown() and frame:GetID() >= level then
			if frame.parentButton then
				frame.parentButton:UnlockHighlight()
				frame.parentButton = nil
			end
			frame:Hide()
		end
	end
	if level == 1 then
		lib.openedMenu = nil
	end
	if not((lib.frames.input and lib.frames.input:IsShown()) or (lib.frames.range and lib.frames.range:IsShown())) then
		lib.inEditBox = nil
	end
	return isClose
end

function lib:Reflash()
	for id, frame in pairs(lib.frames) do
		if frame:IsShown() then
			if type(id) == "number" then
				for i = 1, #frame.list do
					if frame.list[i]:IsShown() then
						if frame.list[i].menu.type == "toggle" then
							frame.list[i].icon:SetTexture(lib:GetMenuValue(frame.list[i].menu, "get") and "Interface\\Buttons\\UI-CheckBox-Check" or "")
						else
							frame.list[i].icon:SetTexture(lib:GetMenuValue(frame.list[i].menu, "icon") or "")
							if frame.list[i].menu.type == "color" then
								local r, g, b = lib:GetMenuValue(frame.list[i].menu, "get")
								frame.list[i].expand:SetVertexColor(r, g, b)
							end
						end
						lib:MenuButtonSetEnable(frame.list[i], not lib:GetMenuValue(frame.list[i].menu, "disabled"))
					else
						break
					end
				end
			end
		end
	end
end

-------- Library Function : Don't Run it! -----------

function lib:CreateFrame(level)
	if lib.frames[level] then
		if level == 1 then
			lib.frames[1]:SetScript("OnUpdate", lib.MainMenuOnUpdate)
		end
		return
	end
	lib.frames[level] = CreateFrame("Frame", "LibDropMenu20_"..level, UIParent)
	lib.frames[level]:Hide()
	lib.frames[level]:EnableMouse("true")
	lib.frames[level]:SetFrameStrata("DIALOG")
	lib.frames[level]:SetClampedToScreen(true)
	lib.frames[level]:SetBackdrop(backdrop)
	lib.frames[level]:SetBackdropColor(0.1, 0.1, 0.2, 1)
	if level == "input" then
		lib.frames[level]:SetWidth(200)
		lib.frames[level]:SetHeight(40)
		lib.frames[level].editBox = CreateFrame("EditBox", lib.frames[level]:GetName().."_EditBox", lib.frames[level])
		lib.frames[level].editBox:SetFontObject("GameFontHighlightSmall")
		lib.frames[level].editBox:SetWidth(160)
		lib.frames[level].editBox:SetHeight(13)
		lib.frames[level].editBox:SetPoint("CENTER", lib.frames[level], "CENTER", 0, 0)
		lib.frames[level].editBox:SetScript("OnEnterPressed", function(self)
			if type(self.menu.set) == "function" then
				self.menu.set((self:GetText() or ""):trim(), self.menu.arg1, self.menu.arg2, self.menu.arg3, self.menu.arg4)
			end
			self:ClearFocus()
			lib:CloseMenu(self:GetParent():GetID())
		end)
		lib.frames[level].editBox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
			lib:CloseMenu(self:GetParent():GetID())
		end)
		lib.frames[level].editBox:SetScript("OnEditFocusLost", function()
			lib.inEditBox = nil
		end)
		local left = lib.frames[level].editBox:CreateTexture(nil, "BACKGROUND")
		left:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left")
		left:SetTexCoord(0, 0.390625, 0, 1)
		left:SetWidth(100)
		left:SetHeight(32)
		left:SetPoint("LEFT", lib.frames[level].editBox, "LEFT", -10, 0)
		local right = lib.frames[level].editBox:CreateTexture(nil, "BACKGROUND")
		right:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		right:SetTexCoord(0.609375, 1, 0, 1)
		right:SetWidth(100)
		right:SetHeight(32)
		right:SetPoint("RIGHT", lib.frames[level].editBox, "RIGHT", 10, 0)
		lib.frames[level]:SetScript("OnHide", function()
			lib.frames[level].editBox:ClearFocus()
		end)
	elseif level == "range" then
		lib.frames[level]:SetWidth(105)
		lib.frames[level]:SetHeight(170)
		lib.frames[level]:EnableMouseWheel(true)
		lib.frames[level].slider = CreateFrame("Slider", lib.frames[level]:GetName().."_Slider", lib.frames[level])
		lib.frames[level].slider:SetOrientation("VERTICAL")
		lib.frames[level].slider:SetWidth(16)
		lib.frames[level].slider:SetHeight(128)
		lib.frames[level].slider:SetPoint("LEFT", lib.frames[level], "LEFT", 15, 0)
		lib.frames[level].slider:SetBackdrop(OpacitySliderFrame:GetBackdrop())
		lib.frames[level].slider:SetThumbTexture((OpacitySliderFrame:GetThumbTexture()):GetTexture())
		lib.frames[level].slider:SetScript("OnValueChanged", lib.RangeOnValueChangedBySlider)
		lib.frames[level].minValue = lib.frames[level].slider:CreateFontString(nil, "ARTWORK", "GameFontGreenSmall")
		lib.frames[level].minValue:SetPoint("BOTTOM", lib.frames[level].slider, "TOP")
		lib.frames[level].maxValue = lib.frames[level].slider:CreateFontString(nil, "ARTWORK", "GameFontGreenSmall")
		lib.frames[level].maxValue:SetPoint("TOP", lib.frames[level].slider, "BOTTOM")
		lib.frames[level].editBox = CreateFrame("EditBox", lib.frames[level]:GetName().."_EditBox", lib.frames[level])
		lib.frames[level].editBox:ClearFocus()
		lib.frames[level].editBox:SetAutoFocus(false)
		lib.frames[level].editBox:SetFontObject("GameFontHighlightSmall")
		lib.frames[level].editBox:SetWidth(44)
		lib.frames[level].editBox:SetHeight(13)
		lib.frames[level].editBox:SetPoint("LEFT", lib.frames[level].slider, "RIGHT", 12, 0)
		lib.frames[level].editBox:SetJustifyH("CENTER")
		lib.frames[level].editBox:SetScript("OnEnterPressed", lib.RangeOnValueChangedByEditBox)
		lib.frames[level].editBox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
			lib:CloseMenu(self:GetParent():GetID())
		end)
		local left = lib.frames[level].editBox:CreateTexture(nil, "BACKGROUND")
		left:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left")
		left:SetTexCoord(0, 0.125, 0, 1)
		left:SetWidth(32)
		left:SetHeight(32)
		left:SetPoint("LEFT", lib.frames[level].editBox, "LEFT", -10, 0)
		local right = lib.frames[level].editBox:CreateTexture(nil, "BACKGROUND")
		right:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		right:SetTexCoord(0.875, 1, 0, 1)
		right:SetHeight(32)
		right:SetWidth(32)
		right:SetPoint("RIGHT", lib.frames[level].editBox, "RIGHT", 10, 0)
		lib.frames[level].unit = lib.frames[level].slider:CreateFontString(nil, "ARTWORK", "GameFontGreenSmall")
		lib.frames[level].unit:SetPoint("TOP", lib.frames[level].editBox, "BOTTOM", 0, -5)
		lib.frames[level]:SetScript("OnMouseWheel", function(self, wheel)
			self.editBox:ClearFocus()
			if wheel > 0 then
				self.slider:SetValue(self.slider:GetValue() + self.step)
			else
				self.slider:SetValue(self.slider:GetValue() - self.step)
			end
		end)
	else
		lib.frames[level].list = {}
	end
	if type(level) == "number" then
		lib.frames[level]:SetID(level)
		lib.frames[level]:SetFrameLevel(level)
		lib.frames[level].menu2 = {}
	end
	if level == 1 then
		lib.frames[1].tempText = lib.frames[1]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmallLeft")
		lib.frames[1].tempText:Hide()
		lib.frames[1]:SetScript("OnUpdate", lib.MainMenuOnUpdate)
	end
end

local menuTypes = { ["header"] = 0, ["group"] = 2, ["text"] = 2, ["range"] = 2, ["toggle"] = 1, ["execute"] = 1, ["color"] = 1 }

function lib:MainMenuOnUpdate(timer)
	if self.owner and self.owner:IsVisible() then
		self.focus = GetMouseFocus()
		if self.focus and self.focus:GetName() and self.focus:GetName():find("^LibDropMenu20") then
			self.closeTimer = 0
		elseif self.focus == self.owner then
			self.closeTimer = 0
		elseif ColorPickerFrame:IsShown() and self.colorPickButton then
			self.closeTimer = 0
		elseif lib.inEditBox then
			self.closeTimer = 0
		else
			self.closeTimer = self.closeTimer + timer
			if self.closeTimer > 8 or IsMouseButtonDown() then
				self.colorPickButton = nil
				lib:CloseMenu(1)
			end
		end
	else
		lib:CloseMenu(1)
	end
end

function lib:MakeMenu(level, menu)
	if not lib.frames[level] then
		lib:CreateFrame(level)
	end
	lib.frames[level].menu = menu
	-- 유효한 테이블인지 검사
	for p, v in pairs(menu.args) do
		if type(v) == "table" and v.type and menuTypes[v.type] and v.name then
			if not lib:GetMenuValue(v, "hidden") then
				tinsert(lib.frames[level].menu2, p)
			end
		end
	end
	-- 메뉴 정렬. order 기준으로. order 값이 없으면 이름순으로.
	sort(lib.frames[level].menu2, function(a, b)
		if menu.args[a].order and menu.args[b].order then
			return menu.args[a].order < menu.args[b].order
		elseif menu.args[a].order then
			return true
		elseif menu.args[b].order then
			return false
		else
			return menu.args[a].name < menu.args[b].name
		end
	end)
	lib.frames[level].minWidth = 10
	lib.frames[level]:SetHeight(20)
	for id, key in ipairs(lib.frames[level].menu2) do
		lib:MakeMenuButton(level, id)
		lib.frames[level].list[id].menu = menu.args[key]
		lib.frames[level].list[id].menuType = menuTypes[menu.args[key].type]
		if menuTypes[menu.args[key].type] == 2 then
			lib.frames[level].list[id].expand:Show()
			if lib.frames[level].list[id].swatchBg:IsShown() then
				lib.frames[level].list[id].expand:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
				lib.frames[level].list[id].expand:SetVertexColor(1, 1, 1)
				lib.frames[level].list[id].swatchBg:Hide()
			end
		elseif menu.args[key].type == "color" then
			if not lib.frames[level].list[id].swatchBg:IsShown() then
				lib.frames[level].list[id].expand:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
				lib.frames[level].list[id].expand:Show()
				lib.frames[level].list[id].swatchBg:Show()
			end
		else
			lib.frames[level].list[id].expand:Hide()
			lib.frames[level].list[id].swatchBg:Hide()
		end
		lib.frames[level].list[id].text:SetText(menu.args[key].name)
		lib.frames[level].minWidth = max(lib.frames[level].minWidth, lib:GetTextWidth(menu.args[key].name))
		lib.frames[level]:SetHeight(lib.frames[level]:GetHeight() + 18)
		lib.frames[level].list[id]:Show()
	end
	if level == 1 then
		lib.frames[1].closeTimer = 0
		-- 닫기 버튼 생성
		if not lib.frames[1].list[0] then
			lib:MakeMenuButton(1, 0)
			lib.frames[1].list[0].menuType = 1
			lib.frames[1].list[0].text:SetText("닫기")
			lib.frames[1].list[0].width = lib.frames[1].list[0].text:GetWidth() + 2
			lib.frames[1].list[0]:SetScript("OnClick", function() lib:CloseMenu(1) end)
		end
		lib.frames[1].minWidth = max(lib.frames[1].list[0].width, lib.frames[1].minWidth)
		lib.frames[1].list[0].text:SetWidth(lib.frames[1].minWidth + 10)
		lib.frames[1].list[0]:SetWidth(lib.frames[1].minWidth + 46)
		lib.frames[1]:SetHeight(lib.frames[level]:GetHeight() + 18)
		-- 타이틀 생성
		if lib.skipTitle or not menu.name then
			if lib.frames[1].list[-1] then
				lib.frames[1].list[-1]:Hide()
				if lib.frames[1].list[1] then
					lib.frames[1].list[1]:ClearAllPoints()
					lib.frames[1].list[1]:SetPoint("TOPLEFT", lib.frames[level], "TOPLEFT", 10, -10)
				end
			end
		else
			lib:MakeMenuButton(1, -1)
			lib.frames[1].list[-1].menuType = 0
			lib.frames[1].list[-1].text:SetText(menu.name)
			lib.frames[1].list[-1].icon:SetTexture(type(menu.icon) == "string" and menu.icon or "")
			lib.frames[1].minWidth = max(lib:GetTextWidth(menu.name), lib.frames[1].minWidth)
			lib.frames[1].list[-1].text:SetWidth(lib.frames[1].minWidth + 10)
			lib.frames[1].list[-1]:SetWidth(lib.frames[1].minWidth + 46)
			lib:MenuButtonSetEnable(lib.frames[1].list[-1])
			if lib.frames[1].list[1] then
				lib.frames[1].list[1]:ClearAllPoints()
				lib.frames[1].list[1]:SetPoint("TOPLEFT", lib.frames[1].list[-1], "BOTTOMLEFT", 0, 0)
			end
			lib.frames[1]:SetHeight(lib.frames[level]:GetHeight() + 18)
		end
	end
	for i = #lib.frames[level].menu2 + 1, #lib.frames[level].list do
		lib.frames[level].list[i].menu = nil
		lib.frames[level].list[i]:Hide()
	end
	for id in pairs(lib.frames[level].menu2) do
		lib.frames[level].menu2[id] = nil
		lib.frames[level].list[id].text:SetWidth(lib.frames[level].minWidth + 10)
		lib.frames[level].list[id]:SetWidth(lib.frames[level].minWidth + 46)
	end
	lib.frames[level]:SetWidth(lib.frames[level].minWidth + 66)
	lib.frames[level]:Show()
	lib:Reflash()
end

function lib:MakeMenuButton(level, id)
	if not lib.frames[level].list[id] then
		lib.frames[level].list[id] = CreateFrame("Button", lib.frames[level]:GetName().."_"..(id == -1 and "Title" or id == 0 and "Close" or id), lib.frames[level])
		lib.frames[level].list[id]:SetHeight(18)
		lib.frames[level].list[id].text = lib.frames[level].list[id]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmallLeft")
		lib.frames[level].list[id].icon = lib.frames[level].list[id]:CreateTexture(nil, "ARTWORK")
		lib.frames[level].list[id].icon:SetWidth(16)
		lib.frames[level].list[id].icon:SetHeight(16)
		if level == "select" then
			lib.frames[level].list[id].icon = lib.frames[level].list[id]:CreateTexture(nil, "ARTWORK")
			lib.frames[level].list[id].icon:SetWidth(16)
			lib.frames[level].list[id].icon:SetHeight(16)
			lib.frames[level].list[id].icon:SetTexture("Interface\\Buttons\\UI-RadioButton")
			lib.frames[level].list[id].icon:SetTexCoord(0, 0.25, 0, 1)
			lib.frames[level].list[id].icon:SetPoint("LEFT", lib.frames[level].list[id], "LEFT", 0, 0)
			lib.frames[level].list[id].checked = lib.frames[level].list[id]:CreateTexture(nil, "ARTWORK")
			lib.frames[level].list[id].checked:SetWidth(16)
			lib.frames[level].list[id].checked:SetHeight(16)
			lib.frames[level].list[id].checked:SetTexture("Interface\\Buttons\\UI-RadioButton")
			lib.frames[level].list[id].checked:SetTexCoord(0.25, 0.5, 0, 1)
			lib.frames[level].list[id].checked:SetAllPoints(lib.frames[level].list[id].icon)
		else
			lib.frames[level].list[id].icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			lib.frames[level].list[id].icon:SetPoint("LEFT", lib.frames[level].list[id], "LEFT", 0, 0)
			lib.frames[level].list[id].expand = lib.frames[level].list[id]:CreateTexture(nil, "OVERLAY")
			lib.frames[level].list[id].expand:SetWidth(16)
			lib.frames[level].list[id].expand:SetHeight(16)
			lib.frames[level].list[id].expand:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
			lib.frames[level].list[id].expand:SetPoint("LEFT", lib.frames[level].list[id].text, "RIGHT", 2, 0)
			lib.frames[level].list[id].expand:Hide()
			lib.frames[level].list[id].swatchBg = lib.frames[level].list[id]:CreateTexture(nil, "BACKGROUND")
			lib.frames[level].list[id].swatchBg:SetWidth(14)
			lib.frames[level].list[id].swatchBg:SetHeight(14)
			lib.frames[level].list[id].swatchBg:SetTexture(1, 1, 1)
			lib.frames[level].list[id].swatchBg:SetPoint("CENTER", lib.frames[level].list[id].expand, "CENTER", 0, 0)
			lib.frames[level].list[id].swatchBg:Hide()
		end
		lib.frames[level].list[id]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		lib.frames[level].list[id]:GetHighlightTexture():SetAlpha(0.7)
		lib.frames[level].list[id]:SetID(id)
		if id == 1 or id == -1 then
			lib.frames[level].list[id]:SetPoint("TOPLEFT", lib.frames[level], "TOPLEFT", 10, -10)
		elseif id == 0 then
			lib.frames[level].list[id]:SetPoint("BOTTOMLEFT", lib.frames[level], "BOTTOMLEFT", 10, 10)
		else
			lib.frames[level].list[id]:SetPoint("TOPLEFT", lib.frames[level].list[id - 1], "BOTTOMLEFT", 0, 0)
		end
	end
	lib.frames[level].list[id].text:ClearAllPoints()
	lib.frames[level].list[id].text:SetPoint("LEFT", lib.frames[level].list[id], "LEFT", 18, 0)
	lib.frames[level].list[id]:SetScript("OnMouseUp", lib.MenuButtonOnMouseUp)
	lib.frames[level].list[id]:SetScript("OnMouseDown", lib.MenuButtonOnMouseDown)
	if level == "select" then
		lib.frames.select.list[id]:SetScript("OnClick", lib.SelectButtonOnClick)
		lib.frames.select.list[id].menuType = 1
	else
		lib.frames[level].list[id]:SetScript("OnEnter", lib.MenuButtonOnEnter)
		lib.frames[level].list[id]:SetScript("OnLeave", GameTooltip_Hide)
		lib.frames[level].list[id]:SetScript("OnClick", lib.MenuButtonOnClick)
	end
	lib.frames[level].list[id]:Show()
end

function lib:GetMenuValue(table, key)
	if type(table[key]) == "function" then
		return table[key](table.arg1, table.arg2, table.arg3, table.arg4)
	else
		return table[key] or nil
	end
end

function lib:MenuButtonSetEnable(button, value)
	if button.menuType == 0 then
		button:Disable()
		button.icon:SetDesaturated(nil)
		button.text:SetTextColor(1, 0.82, 0)
	elseif value then
		button:Enable()
		button.icon:SetDesaturated(nil)
		button.expand:SetDesaturated(nil)
		button.swatchBg:SetDesaturated(nil)
		button.text:SetTextColor(1, 1, 1)
	else
		button:Disable()
		button.icon:SetDesaturated(true)
		button.expand:SetDesaturated(true)
		button.swatchBg:SetDesaturated(true)
		button.text:SetTextColor(0.58, 0.58, 0.58)
	end
end

function lib:MenuButtonOnClick()
	if self.menu.type == "toggle" then
		if type(self.menu.set) == "function" then
			if lib:GetMenuValue(self.menu, "get") then
				self.menu.set(false, self.menu.arg1, self.menu.arg2, self.menu.arg3, self.menu.arg4)
				lib:Reflash()
			else
				self.menu.set(true, self.menu.arg1, self.menu.arg2, self.menu.arg3, self.menu.arg4)
				lib:Reflash()
			end
		end
	elseif self.menu.type == "execute" then
		if type(self.menu.func) == "function" then
			self.menu.func(self.menu.arg1, self.menu.arg2, self.menu.arg3, self.menu.arg4)
			lib:Reflash()
		end
	elseif self.menu.type == "color" then
		if ColorPickerFrame:IsShown() then
			HideUIPanel(ColorPickerFrame)
		end
		lib.frames[1].colorPickButton = self
		ColorPickerFrame.previousValues = {}
		ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b, ColorPickerFrame.previousValues.a = lib:GetMenuValue(self.menu, "get")
		ColorPickerFrame.previousValues.a = self.menu.hasAlpha and ColorPickerFrame.previousValues.a or nil
		ColorPickerFrame.hasOpacity = self.menu.hasAlpha
		ColorPickerFrame.opacity = self.menu.hasAlpha and (1 - (ColorPickerFrame.previousValues.a or 1)) or nil
		ColorPickerFrame.opacityFunc = ColorPickerFrame.hasOpacity and lib.SetColorPickerFrameFunc or nil
		ColorPickerFrame.func = lib.SetColorPickerFrameFunc
		ColorPickerFrame.cancelFunc = lib.CancelColorPickerFrameFunc
		ColorPickerFrame:SetColorRGB(ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b)
		ShowUIPanel(ColorPickerFrame)
	end
end

function lib:MenuButtonOnMouseDown()
	if self.menuType == 1 and self:IsEnabled() then
		self.text:ClearAllPoints()
		self.text:SetPoint("LEFT", self, "LEFT", 18, -2)
	end
end

function lib:MenuButtonOnMouseUp()
	if self.menuType == 1 and self:IsEnabled() then
		self.text:ClearAllPoints()
		self.text:SetPoint("LEFT", self, "LEFT", 18, 0)
	end
end

function lib:MenuButtonOnEnter()
	if self:IsEnabled() and self.menuType ~= 0 then
		if self:GetName() == "LibDropMenu20_1_Close" then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:AddLine("메뉴를 닫습니다.", nil, nil, nil, 1)
			GameTooltip:Show()
		elseif self.menu then
			if type(self.menu.link) == "string" then
				GameTooltip:SetOwner(self, "ANCHOR_LEFT")
				GameTooltip:SetHyperlink(self.menu.link)
				GameTooltip:Show()
			elseif self.menu.desc then
				GameTooltip:SetOwner(self, "ANCHOR_LEFT")
				GameTooltip:AddLine(self.menu.desc, nil, nil, nil, 1)
				if self.menu.desc1 then
					GameTooltip:AddLine(self.menu.desc1, 1, 1, 1, 1)
				end
				GameTooltip:Show()
			end
			if self.menu.type == "group" then
				if type(self.menu.args) == "table" then
					lib:CloseMenu(self:GetParent():GetID() + 1)
					lib:MakeMenu(self:GetParent():GetID() + 1, self.menu)
					return lib:SetChildMenuPoint(self, self:GetParent():GetID() + 1)
				end
			elseif self.menu.type == "text" then
				if self.menu.validate then
					local list = lib:GetMenuValue(self.menu, "validate")
					if type(list) == "table" then
						for _ in pairs(list) do
							lib:CloseMenu(self:GetParent():GetID() + 1)
							lib:CreateSelectFrame(list, lib:GetMenuValue(self.menu, "get"), self.menu, self:GetParent():GetID() + 1)
							return lib:SetChildMenuPoint(self, "select")
						end
					end
				else
					lib:CloseMenu(self:GetParent():GetID() + 1)
					lib:CreateInputFrame(lib:GetMenuValue(self.menu, "get"), self.menu, self:GetParent():GetID() + 1)
					return lib:SetChildMenuPoint(self, "input")
				end
			elseif self.menu.type == "range" then
				lib:CloseMenu(self:GetParent():GetID() + 1)
				lib:CreateRangeFrame(lib:GetMenuValue(self.menu, "get"), self.menu, self:GetParent():GetID() + 1)
				return lib:SetChildMenuPoint(self, "range")
			end
		end
	end
	lib:CloseMenu(self:GetParent():GetID() + 1)
end

function lib:SetChildMenuPoint(button, level)
	if lib.frames[level] then
		button:LockHighlight()
		lib.frames[level].parentButton = button
		lib.frames[level]:SetParent(button:GetParent())
		lib.frames[level]:ClearAllPoints()
		lib.frames[level]:SetPoint("TOPLEFT", button, "TOPRIGHT", 8, 10)
		if GetScreenWidth() == lib.frames[level]:GetRight() then
			lib.frames[level]:ClearAllPoints()
			lib.frames[level]:SetPoint("TOPRIGHT", button, "TOPLEFT", -8, 10)
		end
		lib.frames[level]:Show()
	end
end

function lib:GetTextWidth(text)
	if lib.frames[1] then
		if text and text ~= "" then
			lib.frames[1].tempText:SetText(text)
			return lib.frames[1].tempText:GetWidth(text) + 2
		end
	end
	return 0
end

function lib:SetColorPickerFrameFunc()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	lib.frames[1].colorPickButton.expand:SetVertexColor(r, g, b)
	if type(lib.frames[1].colorPickButton.menu.set) == "function" then
		if lib.frames[1].colorPickButton.menu.hasAlpha then
			lib.frames[1].colorPickButton.menu.set(r, g, b, 1 - OpacitySliderFrame:GetValue(), lib.frames[1].colorPickButton.menu.arg1, lib.frames[1].colorPickButton.menu.arg2, lib.frames[1].colorPickButton.menu.arg3, lib.frames[1].colorPickButton.menu.arg4)
		else
			lib.frames[1].colorPickButton.menu.set(r, g, b, lib.frames[1].colorPickButton.menu.arg1, lib.frames[1].colorPickButton.menu.arg2, lib.frames[1].colorPickButton.menu.arg3, lib.frames[1].colorPickButton.menu.arg4)
		end
	end
end

function lib:CancelColorPickerFrameFunc()
	lib.frames[1].colorPickButton.expand:SetVertexColor(ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b)
	if type(lib.frames[1].colorPickButton.menu.set) == "function" then
		if lib.frames[1].colorPickButton.menu.hasAlpha then
			lib.frames[1].colorPickButton.menu.set(ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b, ColorPickerFrame.previousValues.a, lib.frames[1].colorPickButton.menu.arg1, lib.frames[1].colorPickButton.menu.arg2, lib.frames[1].colorPickButton.menu.arg3, lib.frames[1].colorPickButton.menu.arg4)
		else
			lib.frames[1].colorPickButton.menu.set(ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b, lib.frames[1].colorPickButton.menu.arg1, lib.frames[1].colorPickButton.menu.arg2, lib.frames[1].colorPickButton.menu.arg3, lib.frames[1].colorPickButton.menu.arg4)
		end
	end
end

function lib:CreateSelectFrame(list, value, menu, level)
	lib:CreateFrame("select")
	lib.frames.select:Hide()
	lib.frames.select:SetID(level)
	lib.frames.select:SetFrameLevel(level)
	lib.frames.select.minWidth = 10
	lib.frames.select:SetHeight(20)
	lib.frames.select.menu = menu
	if #list > 0 then
		for id, name in ipairs(list) do
			lib:MakeMenuButton("select", id)
			lib.frames.select.list[id].value = name
			if name == value then
				lib.frames.select.list[id].checked:Show()
			else
				lib.frames.select.list[id].checked:Hide()
			end
			lib.frames.select.list[id].text:SetText(name)
			lib.frames.select.list[id]:Show()
			lib.frames.select.minWidth = max(lib.frames.select.minWidth, lib:GetTextWidth(name))
			lib.frames.select:SetHeight(lib.frames.select:GetHeight() + 18)
		end
		for i = #list + 1, #lib.frames.select.list do
			lib.frames.select.list[i].value = nil
			lib.frames.select.list[i]:Hide()
		end
	else
		local id = 0
		for v, name in pairs(list) do
			id = id + 1
			lib:MakeMenuButton("select", id)
			lib.frames.select.list[id].value = v
			if v == value then
				lib.frames.select.list[id].checked:Show()
			else
				lib.frames.select.list[id].checked:Hide()
			end
			lib.frames.select.list[id].text:SetText(name)
			lib.frames.select.list[id]:Show()
			lib.frames.select.minWidth = max(lib.frames.select.minWidth, lib:GetTextWidth(name))
			lib.frames.select:SetHeight(lib.frames.select:GetHeight() + 18)
		end
		for i = id + 1, #lib.frames.select.list do
			lib.frames.select.list[i].value = nil
			lib.frames.select.list[i]:Hide()
		end
	end
	for i = 1, #lib.frames.select.list do
		if lib.frames.select.list[i]:IsShown() then
			lib.frames.select.list[i].text:SetWidth(lib.frames.select.minWidth + 10)
			lib.frames.select.list[i]:SetWidth(lib.frames.select.minWidth + 46)
		else
			break
		end
	end
	lib.frames.select:SetWidth(lib.frames.select.minWidth + 66)
	lib.frames.select:Show()
end

function lib:SelectButtonOnClick()
	local parent = self:GetParent()
	if type(parent.menu.set) == "function" then
		parent.menu.set(self.value, parent.menu.arg1, parent.menu.arg2, parent.menu.arg3, parent.menu.arg4)
		for i = 1, #parent.list do
			if parent.list[i]:IsShown() then
				if parent.list[i] == self then
					parent.list[i].checked:Show()
				else
					parent.list[i].checked:Hide()
				end
			else
				break
			end
		end
	end
end

function lib:CreateInputFrame(value, menu, level)
	lib:CreateFrame("input")
	lib.frames.input:Hide()
	lib.frames.input.editBox:SetText((type(value) == "string" or type(value) == "number") and value or "")
	lib.frames.input.editBox.menu = menu
	lib.frames.input:SetID(level)
	lib.frames.input:SetFrameLevel(level)
	lib.frames.input:Show()
end

function lib:CreateRangeFrame(value, menu, level)
	lib:CreateFrame("range")
	lib.frames.range:Hide()
	lib.frames.range.editBox:ClearFocus()
	lib.frames.range.menu = menu
	lib.frames.range:SetID(level)
	lib.frames.range:SetFrameLevel(level)
	lib.frames.range:Show()
	local minv, maxv, step = lib:GetMenuValue(menu, "min"), lib:GetMenuValue(menu, "max"), lib:GetMenuValue(menu, "step")
	lib.frames.range.pointing = ((step..""):match(".(%d+)") or ""):len() or 0
	if lib.frames.range.pointing == 0 then
		lib.frames.range.pointing = "%d"
	else
		lib.frames.range.pointing = "%."..lib.frames.range.pointing.."f"
	end
	lib.frames.range.step = step
	lib.frames.range.minValue:SetText(minv)
	lib.frames.range.maxValue:SetText(maxv)
	lib.frames.range.unit:SetText(lib:GetMenuValue(menu, "unit") or "")
	lib.frames.range.slider:SetMinMaxValues(minv, maxv)
	lib.frames.range.slider:SetValueStep(step)
	lib.frames.range.slider:SetValue(value)
end

function lib:RangeOnValueChangedBySlider()
	self = self:GetParent()
	self.editBox:ClearFocus()
	self.editBox:SetText(lib.frames.range.pointing:format(lib.frames.range.slider:GetValue()))
	if type(self.menu.set) == "function" then
		self.menu.set(self.editBox:GetNumber(), self.menu.arg1, self.menu.arg2, self.menu.arg3, self.menu.arg4)
	end
end

function lib:RangeOnValueChangedByEditBox()
	self = self:GetParent()
	self.editBox:ClearFocus()
	self.slider:SetValue(self.editBox:GetNumber())
	lib.RangeOnValueChangedBySlider(self.slider)
end
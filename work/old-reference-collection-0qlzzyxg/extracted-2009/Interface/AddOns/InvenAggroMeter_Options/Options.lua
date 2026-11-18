local _G = _G
local type = _G.type
local tonumber = _G.tonumber
local ceil = _G.math.ceil
local tinsert = _G.table.insert
local tremove = _G.table.remove

local SM = LibStub("LibSharedMedia-3.0")

local function cbOnClick(self)
	if self:GetChecked() then
		PlaySound("igMainMenuOptionCheckBoxOn")
		InvenAggroMeterDB[self.key] = true
	else
		PlaySound("igMainMenuOptionCheckBoxOff")
		InvenAggroMeterDB[self.key] = false
	end
	if type(self.setFunc) == "function" then
		self.setFunc()
	elseif type(self.setFunc) == "string" and type(InvenAggroMeter[self.setFunc]) == "function" then
		InvenAggroMeter[self.setFunc](InvenAggroMeter)
	end
	InvenAggroMeter:ReflashOption()
end

local function cbOnEnter(self)
	if self.tooltipText then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:AddLine(self.tooltipText, nil, nil, nil, true)
		GameTooltip:Show()
	end
end

local function cbOnLeave(self)
	GameTooltip:Hide()
end

local function btOnClick(self)
	if type(self.runFunc) == "function" then
		self.runFunc()
	elseif type(self.runFunc) == "string" and type(InvenAggroMeter[self.runFunc]) == "function" then
		InvenAggroMeter[self.runFunc](InvenAggroMeter)
	end
	InvenAggroMeter:ReflashOption()
end

local function sdOnValueChanged(self, v)
	InvenAggroMeterDB[self.key] = tonumber(self.renew:format(v))
	if self.unit == "%" then
		self.value:SetFormattedText("%d%%", v * 100)
	else
		self.value:SetFormattedText(self.renew..self.unit, v)
	end
	if type(self.setFunc) == "function" then
		self.setFunc()
	elseif type(self.setFunc) == "string" and type(InvenAggroMeter[self.setFunc]) == "function" then
		InvenAggroMeter[self.setFunc](InvenAggroMeter)
	end
	--InvenAggroMeter:ReflashOption()
end

local function mdOnClick(self)
	local f = InvenAggroMeterMediaSelectFrame
	if not f then
		f = CreateFrame("Frame", "InvenAggroMeterMediaSelectFrame")
		f:SetBackdrop(GameTooltip:GetBackdrop())
		f:SetBackdropColor(GameTooltip:GetBackdropColor())
		f:SetClampedToScreen(true)
		f:EnableMouse(true)
		f.buttons = {}
	elseif f:IsVisible() then
		f:Hide()
		return
	end
	f:SetParent(self)
	f:Show()
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 18, 6)
	f:SetWidth(200)
	f:SetHeight(200)
	local media
	local mlist = SM:List(self.media)
	if self.media == "statusbar" then
		for i = 1, #mlist do
			if mlist[i] == "Blizzard" then
				tremove(mlist, i)
				tinsert(mlist, 1, "Blizzard")
				break
			end
		end
	elseif self.media == "sound" then
		for i = 1, #mlist do
			if mlist[i] == "None" then
				tremove(mlist, i)
				tinsert(mlist, 1, "None")
				break
			end
		end
	end
	for i = 1, #mlist do
		if not f.buttons[i] then
			f.buttons[i] = CreateFrame("Button", nil, f)
			f.buttons[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
			f.buttons[i]:SetNormalFontObject("GameFontHighlightSmall")
			f.buttons[i].text = f.buttons[i]:GetNormalFontObject()
			f.buttons[i]:SetWidth(100)
			f.buttons[i]:SetHeight(16)
			f.buttons[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			if i == 1 then
				f.buttons[i]:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -10)
				f.buttons[1]:SetScript("OnClick", function(button, click)
					local self = button:GetParent():GetParent()
					if click == "RightButton" then
						if self.media == "sound" then
							PlaySoundFile(button.media)
						end
						return
					end
					if self.media == "sound" then
						PlaySoundFile(button.media)
					end
					InvenAggroMeterDB[self.key] = button.value
					self.value:SetText(button.value:gsub("Blizzard: ", ""))
					if type(self.setFunc) == "function" then
						self.setFunc()
					elseif type(self.setFunc) == "string" and type(InvenAggroMeter[self.setFunc]) == "function" then
						InvenAggroMeter[self.setFunc](InvenAggroMeter)
					end
					button:GetParent():Hide()
				end)
			elseif i < 5 then
				f.buttons[i]:SetPoint("LEFT", f.buttons[i - 1], "RIGHT", 10, 0)
				f.buttons[i]:SetScript("OnClick", f.buttons[1]:GetScript("OnClick"))
			else
				f.buttons[i]:SetPoint("TOP", f.buttons[i - 4], "BOTTOM", 0, -2)
				f.buttons[i]:SetScript("OnClick", f.buttons[1]:GetScript("OnClick"))
			end
		end
		f.buttons[i].media = SM:Fetch(self.media, mlist[i])
		local removeBlizText = mlist[i]:gsub("Blizzard: ", "")
		if mlist[i] == InvenAggroMeterDB[self.key] then
			f.buttons[i]:SetText("|cff5555ff"..removeBlizText.."|r")
		else
			f.buttons[i]:SetText(removeBlizText)
		end
		if self.media == "statusbar" then
			f.buttons[i]:SetNormalTexture(f.buttons[i].media)
			f.buttons[i]:GetNormalTexture():SetVertexColor(1, 1, 1)
		else
			f.buttons[i]:SetNormalTexture("")
		end
		f.buttons[i].value = mlist[i]
		f.buttons[i]:Show()
	end
	for i = #mlist + 1, #f.buttons do
		f.buttons[i]:Hide()
	end
	if #mlist < 4 then
		f:SetWidth(120 + 110 * (#mlist - 1))
	else
		f:SetWidth(450)
	end
	f:SetHeight(ceil(#mlist / 4) * 18 + 20)
end

local function colorOnClick(self)
	ColorPickerFrame.func = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = ColorPickerFrame.hasOpacity and (1 - OpacitySliderFrame:GetValue())
		ColorPickerFrame.IAMparent.color:SetTexture(r, g, b, a)
		InvenAggroMeterDB[ColorPickerFrame.IAMparent.key] = { r, g, b, a }
		if type(self.setFunc) == "function" then
			self.setFunc(r, g, b, a)
		elseif type(self.setFunc) == "string" and type(InvenAggroMeter[self.setFunc]) == "function" then
			InvenAggroMeter[self.setFunc](InvenAggroMeter, r, g, b, a)
		end
	end
	ColorPickerFrame.IAMparent = self
	ColorPickerFrame.prevValue = CopyTable(InvenAggroMeterDB[self.key])
	ColorPickerFrame.hasOpacity = self.hasAlpha
	ColorPickerFrame.opacityFunc = self.hasAlpha and ColorPickerFrame.func
	ColorPickerFrame.opacity = self.hasAlpha and (InvenAggroMeterDB[self.key][4] and (1 - InvenAggroMeterDB[self.key][4]) or 0)
	ColorPickerFrame.cancelFunc = function()
		if type(self.setFunc) == "function" then
			self.setFunc(unpack(ColorPickerFrame.prevValue))
		elseif type(self.setFunc) == "string" and type(InvenAggroMeter[self.setFunc]) == "function" then
			InvenAggroMeter[self.setFunc](InvenAggroMeter, unpack(ColorPickerFrame.prevValue))
		end
		ColorPickerFrame.IAMparent.color:SetTexture(unpack(ColorPickerFrame.prevValue))
		ColorPickerFrame.prevValue = nil
	end
	ColorPickerFrame:SetColorRGB(InvenAggroMeterDB[self.key][1], InvenAggroMeterDB[self.key][2], InvenAggroMeterDB[self.key][3])
	ShowUIPanel(ColorPickerFrame)
end

local function CreateUICheckButton(parentFrame, name, text, tooltipText, key, setFunc, ...)
	name = "InvenAggroMeterOption"..name
	local frame = CreateFrame("CheckButton", name, parentFrame, "InterfaceOptionsCheckButtonTemplate")
	frame:SetPoint(...)
	frame.text = _G[name.."Text"]
	frame.text:SetText(text)
	frame.key = key
	frame.tooltipText = tooltipText
	frame.setFunc = setFunc
	frame:SetChecked(InvenAggroMeterDB[key])
	frame:SetScript("OnClick", cbOnClick)
	frame:SetScript("OnEnter", cbOnEnter)
	frame:SetScript("OnLeave", cbOnLeave)
	return frame
end

local function CreateUIButton(parentFrame, name, text, tooltipText, runFunc, w, h, ...)
	name = "InvenAggroMeterOption"..name
	local frame = CreateFrame("Button", name, parentFrame, "UIPanelButtonTemplate")
	frame:SetPoint(...)
	frame:SetWidth(w or 146)
	frame:SetHeight(h or 22)
	frame:SetText(text)
	frame.tooltipText = tooltipText
	frame.runFunc = runFunc
	frame:SetScript("OnClick", btOnClick)
	frame:SetScript("OnEnter", cbOnEnter)
	frame:SetScript("OnLeave", cbOnLeave)
	return frame
end

local function CreateUISlider(parentFrame, name, text, tooltipText, minv, maxv, step, unit, key, setFunc, ...)
	name = "InvenAggroMeterOption"..name
	local frame = CreateFrame("Slider", name, parentFrame, "OptionsSliderTemplate")
	frame.text = _G[name.."Text"]
	frame.low = _G[name.."Low"]
	frame.high = _G[name.."High"]
	frame:SetPoint(...)
	frame:SetMinMaxValues(minv, maxv)
	frame:SetValueStep(step)
	frame:SetValue(InvenAggroMeterDB[key])
	frame.text:SetText(text)
	frame.low:SetText(minv)
	frame.high:SetText(maxv)
	frame.key = key
	frame.unit = unit or ""
	frame.step = step
	frame.value = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.value:SetPoint("TOP", frame, "BOTTOM")
	frame.value:SetText(InvenAggroMeterDB[key]..frame.unit)
	frame.tooltipText = tooltipText
	frame.setFunc = setFunc
	if unit == "%" then
		if step < 1 then
			frame.renew = "%.2f"
			frame.low:SetFormattedText("%d", minv * 100)
			frame.high:SetFormattedText("%d", maxv * 100)
			frame.value:SetFormattedText("%d%%", InvenAggroMeterDB[key] * 100)
		else
			frame.renew = "%d"
			frame.unit = "%%"
		end
	elseif floor(step) == step then
		frame.renew = "%d"
	elseif step >= 0.1 then
		frame.renew = "%.1f"
	else
		frame.renew = "%.2f"
	end
	frame:SetScript("OnValueChanged", sdOnValueChanged)
	return frame
end

local function CreateMediaUIDropdownMenu(parentFrame, name, text, tooltipText, media, key, setFunc, width, ...)
	name = "InvenAggroMeterOption"..name
	local frame = CreateFrame("Frame", name, parentFrame, "UIDropDownMenuTemplate")
	frame:SetPoint(...)
	frame.button = _G[name.."Button"]
	frame.value = _G[name.."Text"]
	UIDropDownMenu_SetWidth(frame, width or 126)
	frame.tooltipText = tooltipText
	frame.key = key
	frame.media = media
	frame.setFunc = setFunc
	frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.text:SetPoint("BOTTOM", frame, "TOP", 0, 2)
	frame.text:SetText(text)
	frame.value:SetJustifyH("LEFT")
	frame.value:SetText(InvenAggroMeterDB[key])
	frame.button:SetScript("OnEnter", function(self) cbOnEnter(self:GetParent()) end)
	frame.button:SetScript("OnLeave", function(self) cbOnLeave(self:GetParent()) end)
	frame.button:SetScript("OnClick", function(self) mdOnClick(self:GetParent()) end)
	frame:SetScript("OnShow", function(self)
		self.value:SetText(InvenAggroMeterDB[self.key])
	end)
	return frame
end

local function CreateUIDropdownMenu(parentFrame, name, text, tooltipText, key, setFunc, width, list, ...)
	name = "InvenAggroMeterOption"..name
	local frame = CreateFrame("Frame", name, parentFrame, "UIDropDownMenuTemplate")
	frame:SetPoint(...)
	frame.button = _G[name.."Button"]
	frame.value = _G[name.."Text"]
	UIDropDownMenu_SetWidth(frame, width or 126)
	frame.tooltipText = tooltipText
	frame.key = key
	frame.media = media
	frame.setFunc = setFunc
	frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.text:SetPoint("BOTTOM", frame, "TOP", 0, 2)
	frame.text:SetText(text)
	frame.value:SetJustifyH("LEFT")
	frame.value:SetText(InvenAggroMeterDB[key])
	frame.button:SetScript("OnEnter", function(self) cbOnEnter(self:GetParent()) end)
	frame.button:SetScript("OnLeave", function(self) cbOnLeave(self:GetParent()) end)
	frame.list = list
	UIDropDownMenu_Initialize(frame, function(self)
		local info = UIDropDownMenu_CreateInfo()
		for i = 1, #self.list do
			info.text = self.list[i]
			info.func = function(b)
				UIDropDownMenu_SetSelectedID(self, b:GetID())
				InvenAggroMeterDB[self.key] = UIDropDownMenu_GetText(self)
				if type(self.setFunc) == "function" then
					self.setFunc()
				elseif type(self.setFunc) == "string" and type(InvenAggroMeter[self.setFunc]) == "function" then
					InvenAggroMeter[self.setFunc](InvenAggroMeter)
				end
			end
			info.checked = self.list[i] == InvenAggroMeterDB[self.key]
			UIDropDownMenu_AddButton(info)
		end
	end)
	frame:SetScript("OnShow", function(self)
		self.value:SetText(InvenAggroMeterDB[self.key])
	end)
	return frame
end

local function CreateUIColorButton(parentFrame, name, text, tooltipText, hasAlpha, key, setFunc, ...)
	name = "InvenAggroMeterOption"..name
	local frame = CreateFrame("Button", name, parentFrame)
	frame:SetPoint(...)
	frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.text:SetPoint("LEFT", frame, "LEFT", 27, 0)
	frame.text:SetText(text)
	frame.icon = frame:CreateTexture(nil, "ARTWORK")
	frame.icon:SetWidth(16)
	frame.icon:SetHeight(16)
	frame.icon:SetTexture("Interface\\AddOns\\InvenAggroMeter\\Texture\\ColorSelecter.tga")
	frame.icon:SetPoint("LEFT", frame, "LEFT", 5, 0)
	frame.color = frame:CreateTexture(nil, "OVERLAY")
	frame.color:SetWidth(14)
	frame.color:SetHeight(14)
	frame.color:SetPoint("CENTER", frame.icon, "CENTER", 0, 0)
	frame.color:SetTexture(unpack(InvenAggroMeterDB[key]))
	frame:SetHeight(26)
	frame:SetWidth(27 + frame.text:GetWidth())
	frame.tooltipText = tooltipText
	frame.hasAlpha = hasAlpha
	frame.key = key
	frame.setFunc = setFunc
	frame:SetScript("Onclick", colorOnClick)
	frame:SetScript("OnEnter", cbOnEnter)
	frame:SetScript("OnLeave", cbOnLeave)
	return frame
end

local function SetTextColor(object, r, g, b)
	if object and object.SetTextColor then
		object:SetTextColor(r, g, b)
	end
end

local function SetUseable(f, v)
	if f then
		f = _G["InvenAggroMeterOption"..f]
		if not f then return false end
		if v then
			if f.Enable then
				f:Enable()
			end
			SetTextColor(f.text, 1, 1, 1)
			SetTextColor(f.low, 1, 1, 1)
			SetTextColor(f.high, 1, 1, 1)
			if f:GetObjectType() == "Slider" then
				SetTextColor(f.value, 1, 0.78, 0)
			else
				SetTextColor(f.value, 1, 1, 1)
			end
			if f.button and f.button.Enable then
				f.button:Enable()
			end
			if f.icon then
				f.icon:SetVertexColor(1, 1, 1)
			end
			if f.color then
				f.color:SetVertexColor(1, 1, 1)
			end
		else
			if f.Enable then
				f:Disable()
			end
			SetTextColor(f.text, 0.58, 0.58, 0.58)
			SetTextColor(f.low, 0.58, 0.58, 0.58)
			SetTextColor(f.high, 0.58, 0.58, 0.58)
			SetTextColor(f.value, 0.58, 0.58, 0.58)
			if f.button and f.button.Enable then
				f.button:Disable()
			end
			if f.icon then
				f.icon:SetVertexColor(0.58, 0.58, 0.58)
			end
			if f.color then
				f.color:SetVertexColor(0.58, 0.58, 0.58)
			end
		end
		return true
	end
end

function InvenAggroMeter:ReflashOption()
	local i
	if InvenAggroMeterDB.shown then
		i = 2
		while true do
			if not SetUseable(i, true) then
				break
			end
			i = i + 1
		end
		i = 1
		while true do
			if not SetUseable("9_"..i, InvenAggroMeterDB.autoSizing) then
				break
			end
			i = i + 1
		end
		SetUseable("Warn1", true)
		i = 2
		while true do
			if not SetUseable("Warn"..i, InvenAggroMeterDB.warn) then
				break
			end
			i = i + 1
		end
		i = 1
		while true do
			if not SetUseable("Filter"..i, true) then
				break
			end
			i = i + 1
		end
	else
		i = 2
		while true do
			if not SetUseable(i, false) then
				break
			end
			i = i + 1
		end
		i = 1
		while true do
			if not SetUseable("9_"..i, false) then
				break
			end
			i = i + 1
		end
		i = 1
		while true do
			if not SetUseable("Warn"..i, false) then
				break
			end
			i = i + 1
		end
		i = 1
		while true do
			if not SetUseable("Filter"..i, false) then
				break
			end
			i = i + 1
		end
	end
end

function InvenAggroMeter:CreateOptionFrame()
	local f = InvenAggroMeterOptionFrame
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	f.title:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -16)
	f.title:SetText(f.name)
	f.subText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.subText:SetPoint("TOPLEFT", f.title, "TOPLEFT", 15, -40)
	f.subText:SetHeight(32)
	f.subText:SetJustifyH("LEFT")
	f.subText:SetJustifyV("TOP")
	f.subText:SetNonSpaceWrap(true)
	f.subText:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -8)
	f.subText:SetPoint("RIGHT", -32, 0)
	f.subText:SetText("대상 몬스터에 대한 소환수 및 파티원, 공격대원의 위협 수준을 표시해줍니다.")
	f.option1 = CreateUICheckButton(f, 1, "사용하기", "인벤 어그로 미터기를 사용합니다.", "shown", "SetOnUpdate", "TOPLEFT", f.subText, "BOTTOMLEFT", -2, -8)
	f.option2 = CreateUICheckButton(f, 2, "솔로잉 시 표시하기", "솔로잉 시 어그로 미터기 사용 여부를 설정합니다. 체크 하지 않으면 소환수가 있거나, 파티 및 공격대에 속해 있을 경우에만 표시됩니다.", "useSolo", "PLAYER_TARGET_CHANGED", "TOPLEFT", f.subText, "BOTTOMLEFT", 200, -8)
	f.option3 = CreateUICheckButton(f, 3, "창 고정하기", "어그로 미터기 창을 고정합니다.", "lock", "SetLock", "TOPLEFT", f.option1, "BOTTOMLEFT", 0, -8)
	f.option4 = CreateUIButton(f, 4, "테스트 바 토글", "편한 설정을 위한 테스트 바를 표시합니다.", "ToggleTestBar", nil, nil, "TOPLEFT", f.option2, "BOTTOMLEFT", 0, -8)
	f.option5 = CreateUISlider(f, 5, "업데이트 빈도", "위협 수치 업데이트 빈도를 설정합니다. 낮게 설정할수록 빠르게 변하지만, 성능이 저하됩니다. (권장 0.25초)", 0.1, 0.5, 0.01, "초", "updateDelay", nil, "TOPLEFT", f.option3, "BOTTOMLEFT", 0, -16)
	f.option6 = CreateUISlider(f, 6, "크기 조절", "인벤 어그로 미터기 프레임의 크기를 조절합니다.", 0.5, 1.5, 0.01, "%", "scale", function() InvenAggroMeterFrame:SetScale(InvenAggroMeterDB.scale) end, "TOPLEFT", f.option4, "BOTTOMLEFT", 0, -18)
	f.option7 = CreateMediaUIDropdownMenu(f, 7, "바 텍스쳐", "바 텍스쳐를 설정합니다.", "statusbar", "texture", "SetBarTexture", nil, "TOPLEFT", f.option5, "BOTTOMLEFT", -16, -30)
	f.option8 = CreateUISlider(f, 8, "바 높이 조절", "위협 수준 바의 높이를 설정합니다.", 12, 24, 1, nil, "barHeight", function()
		InvenAggroMeter:SetBarHeight()
		if InvenAggroMeterDB.autoSizing then
			if InvenAggroMeter.testBar then
				InvenAggroMeter.testBar = nil
				InvenAggroMeter:ToggleTestBar()
			else
				InvenAggroMeterFrame:SetHeight(InvenAggroMeterDB.barHeight)
			end
		end
	end, "TOPLEFT", f.option6, "BOTTOMLEFT", 0, -32)
	f.option9 = CreateUICheckButton(f, 9, "자동 접음", "자동으로 화면에 보여진 바 만큼 인벤 어그로 미터기의 창 크기를 조절해 줍니다. 이 경우 화면에 보여질 최대 바의 갯수를 설정할 수 있습니다. 항상 고정된 크기의 창을 보고 싶다면 이 옵션을 끄십시오.", "autoSizing", function()
		if InvenAggroMeterDB.list < 2 then
			InvenAggroMeterDB.list = 2
		elseif InvenAggroMeterDB.list > 40 then
			InvenAggroMeterDB.list = 40
		end
		if InvenAggroMeterDB.autoSizing then
			if InvenAggroMeter.testBar then
				InvenAggroMeter.testBar = nil
				InvenAggroMeter:ToggleTestBar()
			else
				InvenAggroMeterFrame:SetHeight(InvenAggroMeterDB.barHeight)
			end
		else
			InvenAggroMeterFrame:SetHeight(InvenAggroMeterDB.barHeight * (InvenAggroMeterDB.list + 1) + 1)
			InvenAggroMeter:SetNumList()
		end
		InvenAggroMeterOption9_1:SetValue(InvenAggroMeterDB.list)
		InvenAggroMeter:SetAutoHide()
	end, "TOPLEFT", f.option7, "BOTTOMLEFT", 16, -8)
	f.option9_1 = CreateUISlider(f, "9_1", "표시 인원 수", "화면에 위협 수준을 표시할 인원을 설정합니다. 표시되는 인원이 많을수록 성능이 저하됩니다.", 2, 40, 1, "명", "list", function()
		if InvenAggroMeterDB.autoSizing then
			if InvenAggroMeter.testBar then
				InvenAggroMeter.testBar = nil
				InvenAggroMeter:ToggleTestBar()
			end
		end
	end, "TOPLEFT", f.option8, "BOTTOMLEFT", 0, -30)
	f.option10 = CreateUICheckButton(f, 10, "아래로 확장하기", "인벤 어그로 미터기의 바를 아래로 늘립니다.", "grow", "OnDragStop", "TOPLEFT", f.option9, "BOTTOMLEFT", 0, -8)
	f.option11 = CreateUICheckButton(f, 11, "자동 숨김", "표시할 바가 없으면 인벤 어그로 미터기를 숨깁니다.", "autoHide", "SetAutoHide", "TOPLEFT", f.option9_1, "BOTTOMLEFT", 0, -10)
	f.option12 = CreateUIColorButton(f, 12, "배경 색상", "인벤 어그로 미터기의 배경 색상을 설정합니다.", true, "backdropColor", function(r, g, b, a)
		InvenAggroMeterFrame:SetBackdropColor(r, g, b, a)
	end, "TOPLEFT", f.option10, "BOTTOMLEFT", 0, -8)
	f.option13 = CreateUIColorButton(f, 13, "제목 바 색상", "인벤 어그로 미터기의 제목 바 색상을 설정합니다.", true, "titleColor", function(r, g, b, a)
		InvenAggroMeterFrame.bars[0]:SetBackdropColor(r, g, b, a)
	end, "TOPLEFT", f.option11, "BOTTOMLEFT", 0, -8)
	f:SetScript("OnShow", function() InvenAggroMeter:ReflashOption() end)
	f:SetScript("OnHide", function() if InvenAggroMeterMediaSelectFrame then InvenAggroMeterMediaSelectFrame:Hide() end end)

	local sf0 = CreateFrame("Frame", "InvenAggroMeterBarOptionFrame", InterfaceOptionsFramePanelContainer)
	sf0:Hide()
	sf0:SetScript("OnShow", function() InvenAggroMeter:ReflashOption() end)
	sf0:SetScript("OnHide", function() if InvenAggroMeterMediaSelectFrame then InvenAggroMeterMediaSelectFrame:Hide() end end)
	sf0.parent = f.name
	sf0.name = "바 표시"
	sf0.title = sf0:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	sf0.title:SetPoint("TOPLEFT", sf0, "TOPLEFT", 16, -16)
	sf0.title:SetText(sf0.name)
	sf0.option1 = CreateUICheckButton(sf0, "Bar1", "TPS 숨기기", "위협 수준 바에서 TPS(초당 위협 수준 생성량)를 숨깁니다.", "hideTPS", function()
		if InvenAggroMeter.testBar then
			InvenAggroMeter.testBar = nil
			InvenAggroMeter:ToggleTestBar()
		end
		InvenAggroMeter:UpdateTPS()
		InvenAggroMeter:SetBarTextWidth()
		InvenAggroMeter:AutoSizingThreatText()
	end, "TOPLEFT", sf0.title, "TOPLEFT", 15, -40)
	sf0.option2 = CreateUICheckButton(sf0, "Bar2", "위협 수준량 숨기기", "위협 수준 바에서 위협 수준량을 숨깁니다.", "hideThreat", function()
		if InvenAggroMeter.testBar then
			InvenAggroMeter.testBar = nil
			InvenAggroMeter:ToggleTestBar()
		end
		InvenAggroMeter:SetBarTextWidth()
		InvenAggroMeter:AutoSizingThreatText()
	end, "TOPLEFT", sf0.title, "TOPLEFT", 200, -40)
	sf0.option3 = CreateUIDropdownMenu(sf0, "Bar3", "자기 강조", "위협 수준 바 위에서 자기 자신을 강조하는 방법을 설정합니다.", "itsyou", "ChangeItsYouType", nil, { "강조 안함", "하이라이트", "화살표", "하이라이트 + 화살표" }, "TOPLEFT", sf0.option1, "BOTTOMLEFT", -16, -8)
	sf0.option4 = CreateUICheckButton(sf0, "Bar4", "위협 비율 숨기기", "위협 수준 바에서 위협 수준 비율을 숨깁니다.", "hidePercent", function()
		if InvenAggroMeter.testBar then
			InvenAggroMeter.testBar = nil
			InvenAggroMeter:ToggleTestBar()
		end
		InvenAggroMeter:SetBarTextWidth()
		InvenAggroMeter:AutoSizingThreatText()
	end, "TOPLEFT", sf0.option2, "BOTTOMLEFT", 0, -8)
	InterfaceOptions_AddCategory(sf0)

	local sf1 = CreateFrame("Frame", "InvenAggroMeterWarnOptionFrame", InterfaceOptionsFramePanelContainer)
	sf1:Hide()
	sf1:SetScript("OnShow", function() InvenAggroMeter:ReflashOption() end)
	sf1:SetScript("OnHide", function() if InvenAggroMeterMediaSelectFrame then InvenAggroMeterMediaSelectFrame:Hide() end end)
	sf1.parent = f.name
	sf1.name = "경보"
	sf1.title = sf1:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	sf1.title:SetPoint("TOPLEFT", sf1, "TOPLEFT", 16, -16)
	sf1.title:SetText(sf1.name)
	sf1.option1 = CreateUICheckButton(sf1, "Warn1", "경보 사용하기", "일정 수준 이상의 위협 수준 획득시 다양한 방식으로 경보를 해줍니다.", "warn", nil, "TOPLEFT", sf1.title, "TOPLEFT", 15, -40)
	sf1.option2 = CreateUIButton(sf1, "Warn2", "경보 테스트", "설정된 경보 방식으로 테스트 해봅니다.", function() InvenAggroMeter:Warn(true) end, nil, nil, "TOPLEFT", f.title, "BOTTOMLEFT", 200, -28)
	sf1.option3 = CreateUISlider(sf1, "Warn3", "경고할 위협 수준량", "설정한 퍼센트 이상으로 위협 수준이 올라가면 경보합니다.", 40, 100, 1, "%", "warnPercent", nil, "TOPLEFT", sf1.option1, "BOTTOMLEFT", 0, -16)
	sf1.option4 = CreateUICheckButton(sf1, "Warn4", "화면 흔들림", "화면을 흔들어 경보합니다. 전투중 이름표 표시를 사용하면 해당 전투중에는 화면 흔들림 기능이 작동하지 않습니다.", "shake", nil, "TOPLEFT", sf1.option3, "TOPLEFT", 0, -36)
	sf1.option5 = CreateUICheckButton(sf1, "Warn5", "화면 깜빡임", "화면 가장자리를 번쩍여 경보합니다.", "flash", nil, "TOPLEFT", sf1.option2, "TOPLEFT", 0, -76)
	sf1.option6 = CreateUICheckButton(sf1, "Warn6", "글자 경보", "화면 상단에 '위협 수준 경고'라는 글자를 표시합니다.", "text", nil, "TOPLEFT", sf1.option4, "BOTTOMLEFT", 0, -8)
	sf1.option7 = CreateMediaUIDropdownMenu(sf1, "Warn7", "소리", "소리로 경보합니다. None을 선택하면 소리 경보기능이 꺼집니다.", "sound", "sound", nil, nil, "TOPLEFT", sf1.option5, "BOTTOMLEFT", -16, -8)
	sf1.option8 = CreateUICheckButton(sf1, "Warn8", "인스턴스 던전에서만 경보 사용", "인스턴스 던전에서만 경보 기능을 사용합니다.", "warnInstance", nil, "TOPLEFT", sf1.option2, "BOTTOMLEFT", 0, -16)
	InterfaceOptions_AddCategory(sf1)

	local sf2 = CreateFrame("Frame", "InvenAggroMeterFilterOptionFrame", InterfaceOptionsFramePanelContainer)
	sf2:Hide()
	sf2:SetScript("OnShow", function() InvenAggroMeter:ReflashOption() end)
	sf2:SetScript("OnHide", function() if InvenAggroMeterMediaSelectFrame then InvenAggroMeterMediaSelectFrame:Hide() end end)
	sf2.parent = f.name
	sf2.name = "필터링"
	sf2.title = sf2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	sf2.title:SetPoint("TOPLEFT", sf2, "TOPLEFT", 16, -16)
	sf2.title:SetText(sf2.name)
	sf2.option1 = CreateUICheckButton(sf2, "Filter1", "전사", "전사 직업의 플레이어의 위협 수준을 보입니다.", "WARRIOR", "CheckMemberList", "TOPLEFT", sf2.title, "TOPLEFT", 15, -40)
	sf2.option2 = CreateUICheckButton(sf2, "Filter2", "도적", "도적 직업의 플레이어의 위협 수준을 보입니다.", "ROGUE", "CheckMemberList", "TOPLEFT", sf2.title, "TOPLEFT", 200, -40)
	sf2.option3 = CreateUICheckButton(sf2, "Filter3", "사제", "사제 직업의 플레이어의 위협 수준을 보입니다.", "PRIEST", "CheckMemberList", "TOPLEFT", sf2.option1, "BOTTOMLEFT", 0, -8)
	sf2.option4 = CreateUICheckButton(sf2, "Filter4", "마법사", "마법사 직업의 플레이어의 위협 수준을 보입니다.", "MAGE", "CheckMemberList", "TOPLEFT", sf2.option2, "BOTTOMLEFT", 0, -8)
	sf2.option5 = CreateUICheckButton(sf2, "Filter5", "흑마법사", "흑마법사 직업의 플레이어의 위협 수준을 보입니다.", "WARLOCK", "CheckMemberList", "TOPLEFT", sf2.option3, "BOTTOMLEFT", 0, -8)
	sf2.option6 = CreateUICheckButton(sf2, "Filter6", "사냥꾼", "사냥꾼 직업의 플레이어의 위협 수준을 보입니다.", "HUNTER", "CheckMemberList", "TOPLEFT", sf2.option4, "BOTTOMLEFT", 0, -8)
	sf2.option7 = CreateUICheckButton(sf2, "Filter7", "드루이드", "드루이드 직업의 플레이어의 위협 수준을 보입니다.", "DRUID", "CheckMemberList", "TOPLEFT", sf2.option5, "BOTTOMLEFT", 0, -8)
	sf2.option8 = CreateUICheckButton(sf2, "Filter8", "주술사", "주술사 직업의 플레이어의 위협 수준을 보입니다.", "SHAMAN", "CheckMemberList", "TOPLEFT", sf2.option6, "BOTTOMLEFT", 0, -8)
	sf2.option9 = CreateUICheckButton(sf2, "Filter9", "성기사", "성기사 직업의 플레이어의 위협 수준을 보입니다.", "PALADIN", "CheckMemberList", "TOPLEFT", sf2.option7, "BOTTOMLEFT", 0, -8)
	sf2.option10 = CreateUICheckButton(sf2, "Filter10", "죽음의 기사", "죽음의 기사 직업의 플레이어의 위협 수준을 보입니다.", "DEATHKNIGHT", "CheckMemberList", "TOPLEFT", sf2.option8, "BOTTOMLEFT", 0, -8)
	sf2.option11 = CreateUICheckButton(sf2, "Filter11", "소환수, NPC", "소환수 및 NPC의 위협 수준을 보입니다.", "PET", "CheckMemberList", "TOPLEFT", sf2.option9, "BOTTOMLEFT", 0, -8)
	InterfaceOptions_AddCategory(sf2)

	local sf3 = CreateFrame("Frame", "InvenAggroMeterMiniMapButtonOptionFrame", InterfaceOptionsFramePanelContainer)
	sf3:Hide()
	sf3:SetScript("OnShow", function() InvenAggroMeter:ReflashOption() end)
	sf3:SetScript("OnHide", function() if InvenAggroMeterMediaSelectFrame then InvenAggroMeterMediaSelectFrame:Hide() end end)
	sf3.parent = f.name
	sf3.name = "미니맵 버튼"
	sf3.title = sf3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	sf3.title:SetPoint("TOPLEFT", sf3, "TOPLEFT", 16, -16)
	sf3.title:SetText(sf3.name)
	sf3.option1 = CreateUICheckButton(sf3, "MapButtonShow", "미니맵 버튼 보이기", "미니맵 버튼을 보이거나 숨깁니다.", nil, nil, "TOPLEFT", sf3.title, "TOPLEFT", 15, -40)
	sf3.option1:SetChecked(InvenAggroMeterDB.minimapButton.show)
	sf3.option1:SetScript("OnClick", function(self)
		if self:GetChecked() then
			PlaySound("igMainMenuOptionCheckBoxOn")
			InvenAggroMeterDB.minimapButton.show = true
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
			InvenAggroMeterDB.minimapButton.show = false
		end
		LibStub("LibMapButton-1.1"):GetButton(InvenAggroMeter):Toggle()
	end)
	sf3.option2 = CreateUICheckButton(sf3, "MapButtonLock", "미니맵 버튼 고정", "미니맵 버튼을 잠가 실수로 다른 위치로 옮겨지는것을 방지합니다.", nil, nil, "TOPLEFT", sf3.title, "TOPLEFT", 200, -40)
	sf3.option2:SetChecked(not InvenAggroMeterDB.minimapButton.dragable)
	sf3.option2:SetScript("OnClick", function(self)
		if self:GetChecked() then
			PlaySound("igMainMenuOptionCheckBoxOn")
			InvenAggroMeterDB.minimapButton.dragable = false
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
			InvenAggroMeterDB.minimapButton.dragable = true
		end
	end)
	InterfaceOptions_AddCategory(sf3)

	self.optionPanel = { f, sf0, sf1, sf2, sf3 }
end
local _G = _G
local type = _G.type
local tonumber = _G.tonumber
local ceil = _G.math.ceil
local tinsert = _G.table.insert
local tremove = _G.table.remove

local function cbOnClick(self)
	if self:GetChecked() then
		PlaySound("igMainMenuOptionCheckBoxOn")
		BlueItemLinkDB[self.key] = true
	else
		PlaySound("igMainMenuOptionCheckBoxOff")
		BlueItemLinkDB[self.key] = false
	end
	if type(self.setFunc) == "function" then
		self.setFunc()
	elseif type(self.setFunc) == "string" and type(BlueItemLink[self.setFunc]) == "function" then
		BlueItemLink[self.setFunc](BlueItemLink)
	end
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

local function sdOnValueChanged(self, v)
	BlueItemLinkDB[self.key] = tonumber(self.renew:format(v))
	if self.unit == "%" then
		self.value:SetFormattedText("%d%%", v * 100)
	else
		self.value:SetFormattedText(self.renew..self.unit, v)
	end
	if type(self.setFunc) == "function" then
		self.setFunc()
	elseif type(self.setFunc) == "string" and type(BlueItemLink[self.setFunc]) == "function" then
		BlueItemLink[self.setFunc](BlueItemLink)
	end
end

local function CreateUICheckButton(parentFrame, name, text, tooltipText, key, setFunc, ...)
	name = "BlueItemLinkOption"..name
	local frame = CreateFrame("CheckButton", name, parentFrame, "InterfaceOptionsCheckButtonTemplate")
	frame:SetPoint(...)
	frame.text = _G[name.."Text"]
	frame.text:SetText(text)
	frame.key = key
	frame.tooltipText = tooltipText
	frame.setFunc = setFunc
	frame:SetChecked(BlueItemLinkDB[key])
	frame:SetScript("OnClick", cbOnClick)
	frame:SetScript("OnEnter", cbOnEnter)
	frame:SetScript("OnLeave", cbOnLeave)
	return frame
end

local function CreateUISlider(parentFrame, name, text, tooltipText, minv, maxv, step, unit, key, setFunc, ...)
	name = "BlueItemLinkOption"..name
	local frame = CreateFrame("Slider", name, parentFrame, "OptionsSliderTemplate")
	frame.text = _G[name.."Text"]
	frame.low = _G[name.."Low"]
	frame.high = _G[name.."High"]
	frame:SetPoint(...)
	frame:SetMinMaxValues(minv, maxv)
	frame:SetValueStep(step)
	frame:SetValue(BlueItemLinkDB[key])
	frame.text:SetText(text)
	frame.low:SetText(minv)
	frame.high:SetText(maxv)
	frame.key = key
	frame.unit = unit or ""
	frame.step = step
	frame.value = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.value:SetPoint("TOP", frame, "BOTTOM")
	frame.value:SetText(BlueItemLinkDB[key]..frame.unit)
	frame.tooltipText = tooltipText
	frame.setFunc = setFunc
	if unit == "%" then
		if step < 1 then
			frame.renew = "%.2f"
			frame.low:SetFormattedText("%d", minv * 100)
			frame.high:SetFormattedText("%d", maxv * 100)
			frame.value:SetFormattedText("%d%%", BlueItemLinkDB[key] * 100)
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

function BlueItemLink:CreateOptionFrame()
	local f = BlueItemLinkOptionFrame
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
	f.subText:SetText("화면에 다중 링크를 표시해줍니다.")
	f.option1 = CreateUISlider(f, 1, "크기", "링크창의 크기를 설정합니다.", 0.5, 1.5, 0.01, "%", "scale", "SetScale", "TOPLEFT", f.subText, "BOTTOMLEFT", -2, -8)
	f.option2 = CreateUICheckButton(f, 2, "ESC 닫기", "ESC키를 누르면 모든 링크창이 닫힙니다.", "escHide", "SetEscHide", "TOPLEFT", f.subText, "BOTTOMLEFT", 200, -42)
	f.option3 = CreateUICheckButton(f, 3, "아이콘 보기", "링크된 아이템 및 주문의 아이콘을 표시합니다.", "showIcon", "SetIcon", "TOPLEFT", f.option1, "BOTTOMLEFT", 0, -16)
	f.option4 = CreateUICheckButton(f, 4, "아이템ID 표시", "링크된 아이템의 ID를 표시합니다.", "itemID", nil, "TOPLEFT", f.option3, "BOTTOMLEFT", 0, -8)
	f.option5 = CreateUICheckButton(f, 5, "조제법ID 표시", "링크된 조제법의 ID를 표시합니다.", "enchantID", nil, "TOPLEFT", f.option2, "BOTTOMLEFT", 0, -8)
	f.option6 = CreateUICheckButton(f, 6, "주문ID 표시", "링크된 주문의 ID를 표시합니다.", "spellID", nil, "TOPLEFT", f.option4, "BOTTOMLEFT", 0, -8)
	f.option7 = CreateUICheckButton(f, 7, "퀘스트ID 표시", "링크된 퀘스트의 ID를 표시합니다.", "questID", nil, "TOPLEFT", f.option5, "BOTTOMLEFT", 0, -8)
	f.option8 = CreateUICheckButton(f, 8, "업적ID 표시", "링크된 업적의 ID를 표시합니다.", "achievementID", nil, "TOPLEFT", f.option6, "BOTTOMLEFT", 0, -8)
	f.option9 = CreateUICheckButton(f, 9, "특성ID 표시", "링크된 특성의 ID를 표시합니다.", "talentID", nil, "TOPLEFT", f.option7, "BOTTOMLEFT", 0, -8)
	f:SetScript("OnShow", nil)
end
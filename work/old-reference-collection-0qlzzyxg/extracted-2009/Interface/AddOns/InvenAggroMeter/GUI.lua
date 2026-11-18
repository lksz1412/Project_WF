local _G = _G
local select = _G.select
local unpack = _G.unpack
local strtrim = _G.string.trim
local mod = _G.mod
local floor = _G.math.floor
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer
local UnitExists = _G.UnitExists
local bar, percent, tw0, tw1, tw2, point, offsetx, offsety, test, texture, mob, textvalue, tpsvalue

local SM = LibStub("LibSharedMedia-3.0")

function InvenAggroMeter:CreateFrame()
	if InvenAggroMeterFrame then return end
	local backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true, tileSize = 16,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
	local f = CreateFrame("Frame", "InvenAggroMeterFrame", UIParent)
	f.bars = {}
	f:SetFrameStrata("LOW")
	f:SetFrameLevel(1)
	f:SetBackdrop(backdrop)
	f:SetBackdropColor(unpack(InvenAggroMeterDB.backdropColor))
	f:SetWidth(InvenAggroMeterDB.width)
	if InvenAggroMeterDB.autoSizing then
		f:SetHeight(InvenAggroMeterDB.barHeight)
	else
		f:SetHeight(InvenAggroMeterDB.height)
	end
	f:SetScale(InvenAggroMeterDB.scale)
	f:SetResizable(true)
	f:SetClampedToScreen(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetMaxResize(640, InvenAggroMeterDB.barHeight * 41 + 1)
	f:SetMinResize(110, InvenAggroMeterDB.barHeight * 3 + 1)
	f.bars[0] = CreateFrame("Frame", nil, f)
	f.bars[0]:SetPoint("TOPLEFT", f, "TOPLEFT")
	f.bars[0]:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -InvenAggroMeterDB.barHeight-6)
	f.bars[0]:SetBackdrop(backdrop)
	f.bars[0]:SetBackdropColor(unpack(InvenAggroMeterDB.titleColor))
	f.title = f.bars[0]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.title:SetAllPoints(f.bars[0])
	f.title:SetJustifyH("LEFT")
	f.title:SetText(self.title)
	f.dummyText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.dummyText:Hide()
	f.gripRight = CreateFrame("Button", nil, f)
	f.gripRight:SetToplevel(true)
	f.gripRight:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	f.gripRight:SetNormalTexture("Interface\\AddOns\\InvenAggroMeter\\Texture\\ResizeGrip")
	f.gripRight:SetHighlightTexture("Interface\\AddOns\\InvenAggroMeter\\Texture\\ResizeGrip")
	f.gripRight:SetWidth(20)
	f.gripRight:SetHeight(20)
	f.gripRight:SetScript("OnMouseDown", function(self)
		if not InvenAggroMeterDB.lock then
			self:GetParent():StartSizing(InvenAggroMeterDB.autoSizing and "RIGHT" or "BOTTOMRIGHT")
			self:GetParent():SetScript("OnUpdate", function(self)
				if self:GetWidth() ~= self.prevWidth then
					InvenAggroMeter:AutoSizingThreatText()
					self.prevWidth = self:GetWidth()
				end
				if self:GetHeight() ~= self.prevHeight then
					self.prevHeight = self:GetHeight()
					InvenAggroMeter:SetNumList()
				end
			end)
		end
	end)
	f.gripRight:SetScript("OnMouseUp", function(self)
		self:GetParent():SetScript("OnUpdate", nil)
		InvenAggroMeter.OnDragStop(self:GetParent())
		InvenAggroMeterDB.width = self:GetParent():GetWidth()
		InvenAggroMeterDB.height = self:GetParent():GetHeight()
		InvenAggroMeter:AutoSizingThreatText()
		InvenAggroMeter:SetNumList()
	end)
	f.gripLeft = CreateFrame("Button", nil, f)
	f.gripLeft:SetToplevel(true)
	f.gripLeft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
	f.gripLeft:SetNormalTexture("Interface\\AddOns\\InvenAggroMeter\\Texture\\ResizeGripLeft")
	f.gripLeft:SetHighlightTexture("Interface\\AddOns\\InvenAggroMeter\\Texture\\ResizeGripLeft")
	f.gripLeft:SetHighlightTexture("Interface\\AddOns\\InvenAggroMeter\\Texture\\ResizeGripLeft")
	f.gripLeft:SetWidth(20)
	f.gripLeft:SetHeight(20)
	f.gripLeft:SetScript("OnMouseDown", function(self)
		if not InvenAggroMeterDB.lock then
			self:GetParent():StartSizing(InvenAggroMeterDB.autoSizing and "LEFT" or "BOTTOMLEFT")
			self:GetParent():SetScript("OnUpdate", function(self)
				if self:GetWidth() ~= self.prevWidth then
					self.prevWidth = self:GetWidth()
					InvenAggroMeter:AutoSizingThreatText()
				end
				if self:GetHeight() ~= self.prevHeight then
					self.prevHeight = self:GetHeight()
					InvenAggroMeter:SetNumList()
				end
			end)
		end
	end)
	f.gripLeft:SetScript("OnMouseUp", function(self)
		self:GetParent():SetScript("OnUpdate", nil)
		InvenAggroMeter.OnDragStop(self:GetParent())
		InvenAggroMeterDB.width = self:GetParent():GetWidth()
		InvenAggroMeterDB.height = self:GetParent():GetHeight()
		InvenAggroMeter:AutoSizingThreatText()
		InvenAggroMeter:SetNumList()
	end)
	if InvenAggroMeterDB.pos[1] and InvenAggroMeterDB.pos[2] then
		local fs = f:GetEffectiveScale()
		if InvenAggroMeterDB.grow then
			f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", InvenAggroMeterDB.pos[1] / fs, InvenAggroMeterDB.pos[2] / fs)
		else
			f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", InvenAggroMeterDB.pos[1] / fs, InvenAggroMeterDB.pos[2] / fs)
		end
	else
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
	f:SetScript("OnDragStart", self.OnDragStart)
	f:SetScript("OnDragStop", self.OnDragStop)
	f:SetScript("OnHide", function(self)
		self.threat1Max = 1
	end)
	f.itsyou = CreateFrame("Frame", nil, f)
	f.itsyou.texture = f.itsyou:CreateTexture(nil, "OVERLAY")
	f.itsyou.texture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	f.itsyou.texture:SetBlendMode("ADD")
	f.itsyou.texture:SetPoint("TOPLEFT", f.itsyou, "TOPLEFT", -25, 0)
	f.itsyou.texture:SetPoint("BOTTOMRIGHT", f.itsyou, "BOTTOMRIGHT", 25, 0)
	f.itsyou.texture:SetAlpha(0.75)
	f.itsyou.arrow = f.itsyou:CreateFontString(nil, "OVERLAY", "GameFontRed")
	f.itsyou.arrow:SetText("▶")
	f.itsyou.arrow:SetPoint("RIGHT", f.itsyou, "LEFT", 0, 1)
	f.itsyou.arrow2 = f.itsyou:CreateFontString(nil, "OVERLAY", "GameFontRed")
	f.itsyou.arrow2:SetText("◀")
	f.itsyou.arrow2:SetPoint("LEFT", f.itsyou, "RIGHT", 0, 1)
	f.itsyou:Hide()
	self:ChangeItsYouType()
	self:SetLock()
	if self:GetIsVisible() then
		f:Show()
	else
		f:Hide()
	end
end

function InvenAggroMeter:SetTitle()
	mob = nil
	for i = 1, 3 do
		mob = (mob or "").."target"
		if UnitExists(mob) then
			if InvenAggroMeter:UnitIsMob(mob) then
				InvenAggroMeterFrame.title:SetText(UnitName(mob))
				break
			end
		else
			break
		end
	end
	if not mob then
		InvenAggroMeterFrame.title:SetText(self.title)
		InvenAggroMeterFrame.title:SetTextColor(1, 1, 1)
	end
	return mob
end

function InvenAggroMeter:SetLock()
	if InvenAggroMeterDB.lock then
		InvenAggroMeterFrame.gripLeft:Hide()
		InvenAggroMeterFrame.gripRight:Hide()
	else
		InvenAggroMeterFrame.gripLeft:Show()
		InvenAggroMeterFrame.gripRight:Show()

	end
end

function InvenAggroMeter:CreateBar(index)
	if index > 0 and index <= 40 then
		if not InvenAggroMeterFrame.bars[index] then
			InvenAggroMeterFrame.bars[index] = CreateFrame("StatusBar", nil, InvenAggroMeterFrame)
			InvenAggroMeterFrame.bars[index]:SetStatusBarTexture(SM:Fetch("statusbar", InvenAggroMeterDB.texture))
			InvenAggroMeterFrame.bars[index]:SetPoint("TOPLEFT", InvenAggroMeterFrame.bars[index - 1], "BOTTOMLEFT")
			InvenAggroMeterFrame.bars[index]:SetPoint("BOTTOMRIGHT", InvenAggroMeterFrame.bars[index - 1], "BOTTOMRIGHT", 0, -InvenAggroMeterDB.barHeight)
			InvenAggroMeterFrame.bars[index].name = InvenAggroMeterFrame.bars[index]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			InvenAggroMeterFrame.bars[index].name:SetPoint("LEFT", InvenAggroMeterFrame.bars[index], "LEFT", 2, 0)
			InvenAggroMeterFrame.bars[index].name:SetJustifyH("LEFT")
			InvenAggroMeterFrame.bars[index].name:SetHeight(12)
			InvenAggroMeterFrame.bars[index].threat = InvenAggroMeterFrame.bars[index]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			InvenAggroMeterFrame.bars[index].threat:SetJustifyH("RIGHT")
			InvenAggroMeterFrame.bars[index].threat:SetHeight(self:GetTextHeight())
			InvenAggroMeterFrame.bars[index].threat:SetWidth(self:GetTextWidth("100%") + 2)
			InvenAggroMeterFrame.bars[index].threat:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index], "RIGHT", -2, 0)

			InvenAggroMeterFrame.bars[index].threat1 = InvenAggroMeterFrame.bars[index]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			InvenAggroMeterFrame.bars[index].threat1:SetJustifyH("RIGHT")
			InvenAggroMeterFrame.bars[index].threat1:SetHeight(InvenAggroMeterFrame.bars[index].threat:GetHeight())
			InvenAggroMeterFrame.bars[index].threat1:SetWidth((InvenAggroMeterFrame.threat1Max or 0) + 4)

			InvenAggroMeterFrame.bars[index].threat2 = InvenAggroMeterFrame.bars[index]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			InvenAggroMeterFrame.bars[index].threat2:SetJustifyH("RIGHT")
			InvenAggroMeterFrame.bars[index].threat2:SetHeight(InvenAggroMeterFrame.bars[index].threat:GetHeight())

			InvenAggroMeterFrame.bars[index]:SetMinMaxValues(0, 100)
			InvenAggroMeterFrame.bars[index]:SetValue(0)
			self:SetBarTextWidth(index)
		end
		return false
	end
	return true
end

function InvenAggroMeter:SetBarTextWidth(index)
	if not index then
		for i = 1, #InvenAggroMeterFrame.bars do
			self:SetBarTextWidth(i)
		end
	elseif InvenAggroMeterFrame.bars[index] then
		if InvenAggroMeterDB.hidePercent and InvenAggroMeterDB.hideThreat and InvenAggroMeterDB.hideTPS then
			InvenAggroMeterFrame.bars[index].threat:Hide()
			InvenAggroMeterFrame.bars[index].threat1:Hide()
			InvenAggroMeterFrame.bars[index].threat2:Hide()
		elseif InvenAggroMeterDB.hidePercent and InvenAggroMeterDB.hideThreat then
			InvenAggroMeterFrame.bars[index].threat:Hide()
			InvenAggroMeterFrame.bars[index].threat1:Hide()
			InvenAggroMeterFrame.bars[index].threat2:Show()
			InvenAggroMeterFrame.bars[index].threat2:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat2:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index], "RIGHT", -2, 0)
		elseif InvenAggroMeterDB.hidePercent and InvenAggroMeterDB.hideTPS then
			InvenAggroMeterFrame.bars[index].threat:Hide()
			InvenAggroMeterFrame.bars[index].threat1:Show()
			InvenAggroMeterFrame.bars[index].threat2:Hide()
			InvenAggroMeterFrame.bars[index].threat1:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat1:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index], "RIGHT", -2, 0)
		elseif InvenAggroMeterDB.hideThreat and InvenAggroMeterDB.hideTPS then
			InvenAggroMeterFrame.bars[index].threat:Show()
			InvenAggroMeterFrame.bars[index].threat1:Hide()
			InvenAggroMeterFrame.bars[index].threat2:Hide()
		elseif InvenAggroMeterDB.hidePercent then
			InvenAggroMeterFrame.bars[index].threat:Hide()
			InvenAggroMeterFrame.bars[index].threat1:Show()
			InvenAggroMeterFrame.bars[index].threat2:Show()
			InvenAggroMeterFrame.bars[index].threat1:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat1:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index], "RIGHT", -2, 0)
			InvenAggroMeterFrame.bars[index].threat2:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat2:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index].threat1, "LEFT", 0, 0)
		elseif InvenAggroMeterDB.hideThreat then
			InvenAggroMeterFrame.bars[index].threat:Show()
			InvenAggroMeterFrame.bars[index].threat1:Hide()
			InvenAggroMeterFrame.bars[index].threat2:Show()
			InvenAggroMeterFrame.bars[index].threat2:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat2:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index].threat, "LEFT", 0, 0)
		elseif InvenAggroMeterDB.hideTPS then
			InvenAggroMeterFrame.bars[index].threat:Show()
			InvenAggroMeterFrame.bars[index].threat1:Show()
			InvenAggroMeterFrame.bars[index].threat2:Hide()
			InvenAggroMeterFrame.bars[index].threat1:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat1:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index].threat, "LEFT", 0, 0)
		else
			InvenAggroMeterFrame.bars[index].threat:Show()
			InvenAggroMeterFrame.bars[index].threat1:Show()
			InvenAggroMeterFrame.bars[index].threat2:Show()
			InvenAggroMeterFrame.bars[index].threat1:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat1:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index].threat, "LEFT", 0, 0)
			InvenAggroMeterFrame.bars[index].threat2:ClearAllPoints()
			InvenAggroMeterFrame.bars[index].threat2:SetPoint("RIGHT", InvenAggroMeterFrame.bars[index].threat1, "LEFT", 0, 0)
		end
	end
end

function InvenAggroMeter:GetTextWidth(text)
	InvenAggroMeterFrame.dummyText:SetText(text)
	return InvenAggroMeterFrame.dummyText:GetWidth()
end

function InvenAggroMeter:GetTextHeight()
	InvenAggroMeterFrame.dummyText:SetText("0")
	return InvenAggroMeterFrame.dummyText:GetHeight()
end

function InvenAggroMeter:SetBarHeight(h)
	InvenAggroMeterDB.barHeight = h or InvenAggroMeterDB.barHeight
	if (InvenAggroMeterDB.barHeight * 3 + 1) > InvenAggroMeterFrame:GetHeight() then
		InvenAggroMeterDB.height = InvenAggroMeterDB.barHeight * 3 + 1
		InvenAggroMeterFrame:SetHeight(InvenAggroMeterDB.height)
	elseif (InvenAggroMeterDB.barHeight * 41 + 1) < InvenAggroMeterFrame:GetHeight() then
		InvenAggroMeterDB.height = InvenAggroMeterDB.barHeight * 41 + 1
	end
	InvenAggroMeterFrame:SetHeight(InvenAggroMeterDB.height)
	InvenAggroMeterFrame:SetMaxResize(640, InvenAggroMeterDB.barHeight * 41 + 1)
	InvenAggroMeterFrame:SetMinResize(110, InvenAggroMeterDB.barHeight * 3 + 1)
	InvenAggroMeterFrame.bars[0]:ClearAllPoints()
	InvenAggroMeterFrame.bars[0]:SetPoint("TOPLEFT", InvenAggroMeterFrame, "TOPLEFT")
	InvenAggroMeterFrame.bars[0]:SetPoint("BOTTOMRIGHT", InvenAggroMeterFrame, "TOPRIGHT", 0, -InvenAggroMeterDB.barHeight)
	for i = 1, #InvenAggroMeterFrame.bars do
		InvenAggroMeterFrame.bars[i]:ClearAllPoints()
		InvenAggroMeterFrame.bars[i]:SetPoint("TOPLEFT", InvenAggroMeterFrame.bars[i - 1], "BOTTOMLEFT")
		InvenAggroMeterFrame.bars[i]:SetPoint("BOTTOMRIGHT", InvenAggroMeterFrame.bars[i - 1], "BOTTOMRIGHT", 0, -InvenAggroMeterDB.barHeight)
	end
	self:SetNumList()
	InvenAggroMeter:OnDragStop()
end

function InvenAggroMeter:SetBarTexture()
	texture = SM:Fetch("statusbar", InvenAggroMeterDB.texture)
	for i = 1, #InvenAggroMeterFrame.bars do
		InvenAggroMeterFrame.bars[i]:SetStatusBarTexture(texture)
		InvenAggroMeterFrame.bars[i]:SetStatusBarColor(unpack(self.classColor[InvenAggroMeterFrame.bars[i].class] or { 0, 1, 0}))
	end
end



function InvenAggroMeter:SetNumList()
	if not InvenAggroMeterDB.autoSizing then
		InvenAggroMeterDB.list = floor(InvenAggroMeterFrame:GetHeight() / InvenAggroMeterDB.barHeight) - 1
		if self.testBar then
			self.testBar = nil
			self:ToggleTestBar()
		else
			self:HideBars(InvenAggroMeterDB.list + 1)
		end
		if InvenAggroMeterOption9_1 and InvenAggroMeterOption9_1:IsVisible() then
			InvenAggroMeterOption9_1:SetValue(InvenAggroMeterDB.list)
		end
	end
end

function InvenAggroMeter:SetAutoSizing(n)
	if InvenAggroMeterDB.autoSizing then
		if n and n >= 0 then
			InvenAggroMeterFrame:SetHeight(InvenAggroMeterDB.barHeight * (n + 1) + 1)
		end
	else

	end
end

local function setBarText(p, tv, tps)
	textvalue = ""
	if not InvenAggroMeterDB.hidePercent then
		textvalue = ("%d%%"):format(p)
	end
	if not InvenAggroMeterDB.hideThreat then
		textvalue = (("%.1fk "):format(tv))..textvalue
	end
	if not InvenAggroMeterDB.hideTPS then
		if tps then
			textvalue = (("%d "):format(tps))..textvalue
		else
			textvalue = "- "..textvalue
		end
	end
	return strtrim(textvalue)
end

function InvenAggroMeter:SetBar(index, unit, percent, threatValue, tps, guid)
	if self:CreateBar(index) then return end
	percent = percent or 0
	threatValue = threatValue or 0
	InvenAggroMeterFrame.bars[index]:SetValue(percent)
	InvenAggroMeterFrame.bars[index].unit = unit
	InvenAggroMeterFrame.bars[index].guid = guid
	InvenAggroMeterFrame.bars[index].class = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or "PET"
	InvenAggroMeterFrame.bars[index].name:SetText(UnitName(unit))
	InvenAggroMeterFrame.bars[index].threat:SetFormattedText("%d%%", percent)
	InvenAggroMeterFrame.bars[index].threat1:SetFormattedText("%.1fk", threatValue / 100000)
	if tps then
		InvenAggroMeterFrame.bars[index].threat2:SetFormattedText("%d", tps)
	else
		InvenAggroMeterFrame.bars[index].threat2:SetText("??")
	end
	InvenAggroMeterFrame.bars[index]:SetStatusBarColor(unpack(self.classColor[InvenAggroMeterFrame.bars[index].class] or { 0, 1, 0}))
	InvenAggroMeterFrame.bars[index]:Show()
	InvenAggroMeterFrame.threat1Max = max(InvenAggroMeterFrame.threat1Max or 0, self:GetTextWidth(InvenAggroMeterFrame.bars[index].threat1:GetText()))
	self:AutoSizingThreatText(index)
end

function InvenAggroMeter:UpdateTPS()
	if not self.testBar and not InvenAggroMeterDB.hideTPS then
		for i = 1, self.ShowNumBar do
			tpsvalue = self:GetTPS(InvenAggroMeterFrame.bars[i].guid)
			if tpsvalue then
				InvenAggroMeterFrame.bars[i].threat2:SetFormattedText("%d", tpsvalue)
			else
				InvenAggroMeterFrame.bars[i].threat2:SetText("??")
			end
		end
	end
end

function InvenAggroMeter:ToggleTestBar()
	self.testBar = not self.testBar
	if InCombatLockdown() then
		self.testBar = nil
		return
	end
	self.setYouAlready = nil
	if self.testBar then
		InvenAggroMeterFrame:Show()
		InvenAggroMeterFrame.threat1Prev = InvenAggroMeterFrame.threat1Max
		InvenAggroMeterFrame.threat1Max = 0
		for i = 1, InvenAggroMeterDB.list do
			if InvenAggroMeter:CreateBar(i) then break end
			test = self.classList[mod(i, #self.classList + 1)] or "PET"
			InvenAggroMeterFrame.bars[i].class = test
			InvenAggroMeterFrame.bars[i].name:SetText(test:sub(1, 1)..(test:sub(2)):lower())
			InvenAggroMeterFrame.bars[i]:SetValue((1 - (i - 1) / InvenAggroMeterDB.list) * 100)
			InvenAggroMeterFrame.bars[i].threat:SetFormattedText("%d%%", InvenAggroMeterFrame.bars[i]:GetValue())
			InvenAggroMeterFrame.bars[i].threat1:SetFormattedText("%.1fk", InvenAggroMeterFrame.bars[i]:GetValue() * self.randomThreat * 10)
			InvenAggroMeterFrame.bars[i].threat2:SetFormattedText("%d", InvenAggroMeterFrame.bars[i]:GetValue() * 11.2)
			InvenAggroMeterFrame.bars[i]:SetStatusBarColor(unpack(self.classColor[test] or { 0, 1, 0 }))
			InvenAggroMeterFrame.bars[i]:Show()
			InvenAggroMeterFrame.threat1Max = max(InvenAggroMeterFrame.threat1Max, self:GetTextWidth(InvenAggroMeterFrame.bars[i].threat1:GetText()))
			if test == self.playerClass and not self.setYouAlready then
				self.setYouAlready = true
				self:SetItsYou(i)
			end
			self:AutoSizingThreatText(i)
		end
		--[[
		if InvenAggroMeterFrame.threat1Prev ~= InvenAggroMeterFrame.threat1Max then
			self:AutoSizingThreatText()
		end
		]]
		self:HideBars(InvenAggroMeterDB.list + 1)
		InvenAggroMeterFrame.title:SetText("테스트 바 표시 중")
		InvenAggroMeterFrame.title:SetTextColor(1, 1, 1)
	else
		self:HideBars(1)
		InvenAggroMeterFrame.title:SetText(self.title)
		InvenAggroMeterFrame.title:SetTextColor(1, 1, 1)
	end
end

function InvenAggroMeter:AutoSizingThreatText(index)
	tw0 = InvenAggroMeterFrame:GetWidth()
	if index then
		InvenAggroMeterFrame.bars[index].threat1:SetWidth(InvenAggroMeterFrame.threat1Max + 4)
		tw1 = self:GetTextWidth(InvenAggroMeterFrame.bars[index].name:GetText())
		tw2 = (InvenAggroMeterDB.hidePercent and 0 or InvenAggroMeterFrame.bars[index].threat:GetWidth()) + (InvenAggroMeterDB.hideThreat and 0 or InvenAggroMeterFrame.bars[index].threat1:GetWidth()) + (InvenAggroMeterDB.hideTPS and 0 or InvenAggroMeterFrame.bars[index].threat2:GetWidth())
		if (tw1 + tw2 + 5) > tw0 then
			tw3 = tw0 - tw2 - 5
			InvenAggroMeterFrame.bars[index].name:SetWidth(tw3 > 0 and tw3 or 1)
		else
			InvenAggroMeterFrame.bars[index].name:SetWidth(tw0)
		end
	else
		for i = 1, #InvenAggroMeterFrame.bars do
			self:AutoSizingThreatText(i)
		end
	end
end

function InvenAggroMeter:SetItsYou(index)
	if index and index > 0 and InvenAggroMeterDB.list >= index then
		InvenAggroMeterFrame.itsyou.index = index
		InvenAggroMeterFrame.itsyou:ClearAllPoints()
		InvenAggroMeterFrame.itsyou:SetAllPoints(InvenAggroMeterFrame.bars[index])
		InvenAggroMeterFrame.itsyou:Show()
	else
		InvenAggroMeterFrame.itsyou.index = nil
		InvenAggroMeterFrame.itsyou:Hide()
	end
end

function InvenAggroMeter:ChangeItsYouType()
	if InvenAggroMeterDB.itsyou == "하이라이트" then
		InvenAggroMeterFrame.itsyou.texture:Show()
		InvenAggroMeterFrame.itsyou.arrow:Hide()
		InvenAggroMeterFrame.itsyou.arrow2:Hide()
	elseif InvenAggroMeterDB.itsyou == "화살표" then
		InvenAggroMeterFrame.itsyou.texture:Hide()
		InvenAggroMeterFrame.itsyou.arrow:Show()
		InvenAggroMeterFrame.itsyou.arrow2:Show()
	elseif InvenAggroMeterDB.itsyou == "하이라이트 + 화살표" then
		InvenAggroMeterFrame.itsyou.texture:Show()
		InvenAggroMeterFrame.itsyou.arrow:Show()
		InvenAggroMeterFrame.itsyou.arrow2:Show()
	else
		InvenAggroMeterFrame.itsyou.texture:Hide()
		InvenAggroMeterFrame.itsyou.arrow:Hide()
		InvenAggroMeterFrame.itsyou.arrow2:Hide()
	end
end

function InvenAggroMeter:HideBars(n)
	if not(n and n > 0) then
		n = 1
	end
	for i = n, #InvenAggroMeterFrame.bars do
		InvenAggroMeterFrame.bars[i]:SetValue(0)
		InvenAggroMeterFrame.bars[i].unit = nil
		InvenAggroMeterFrame.bars[i].class = nil
		InvenAggroMeterFrame.bars[i]:Hide()
		if InvenAggroMeterFrame.itsyou.index == i then
			self:SetItsYou()
		end
	end
	self:SetAutoSizing(n - 1)
	self.ShowNumBar = n - 1
	self:SetAutoHide()
end

function InvenAggroMeter:SetAutoHide()
	if InvenAggroMeterDB.autoHide then
		if self.ShowNumBar == 0 then
			InvenAggroMeterFrame:Hide()
		else
			InvenAggroMeterFrame:Show()
		end
	elseif self:GetIsVisible() then
		InvenAggroMeterFrame:Show()
	else
		InvenAggroMeterFrame:Hide()
	end
end

function InvenAggroMeter:OnDragStart()
	if not InvenAggroMeterDB.lock then
		InvenAggroMeterFrame:StartMoving()
	end
end

function InvenAggroMeter:OnDragStop()
	InvenAggroMeterFrame:StopMovingOrSizing()
	local fs, ws = self:GetEffectiveScale(), UIParent:GetEffectiveScale()
	if InvenAggroMeterDB.grow then
		InvenAggroMeterDB.pos = { InvenAggroMeterFrame:GetLeft() * fs, InvenAggroMeterFrame:GetTop() * fs - UIParent:GetTop() * ws }
		InvenAggroMeterFrame:ClearAllPoints()
		InvenAggroMeterFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", InvenAggroMeterDB.pos[1] / fs, InvenAggroMeterDB.pos[2] / fs)
	else
		InvenAggroMeterDB.pos = { InvenAggroMeterFrame:GetLeft() * fs, InvenAggroMeterFrame:GetBottom() * fs - UIParent:GetBottom() * ws }
		InvenAggroMeterFrame:ClearAllPoints()
		InvenAggroMeterFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", InvenAggroMeterDB.pos[1] / fs, InvenAggroMeterDB.pos[2] / fs)
	end
end
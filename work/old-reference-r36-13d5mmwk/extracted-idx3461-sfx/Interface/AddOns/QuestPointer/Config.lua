local myname, ns = ...
local myfullname = GetAddOnMetadata(myname, "Title")

----------------------
--      Locals      --
----------------------

local tekcheck = LibStub("tekKonfig-Checkbox")
local tekslider = LibStub("tekKonfig-Slider")
local GAP = 8

---------------------
--      Panel      --
---------------------

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = myfullname
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, myfullname, ("%s 일반 설정"):format(myfullname))
	
	local tracked = tekcheck.new(frame, nil, "추적중인 퀘스트만 표시", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	tracked.tiptext = "당신이 추적중인 퀘스트만 미니맵에 표시합니다."
	local checksound = tracked:GetScript("OnClick")
	tracked:SetScript("OnClick", function(self)
		checksound(self)
		ns.db.watchedOnly = not ns.db.watchedOnly
		ns:UpdatePOIs()
	end)
	tracked:SetChecked(ns.db.watchedOnly)

	local useArrows = tekcheck.new(frame, nil, "가장자리 화살표 표시", "TOPLEFT", tracked, "BOTTOMLEFT", -2, -GAP)
	useArrows.tiptext = "미니맵에 표시되지 못하는 아이콘의 경우 해당 방향을 가리키는 화살표 아이콘으로 대체합니다."
	useArrows:SetScript("OnClick", function(self)
		checksound(self)
		ns.db.useArrows = not ns.db.useArrows
		ns:UpdatePOIs()
	end)
	useArrows:SetChecked(ns.db.useArrows)

	local scaleslider, scaleslidertext, scalecontainer = tekslider.new(frame, string.format("아이콘 크기: %.2f", ns.db.iconScale or 1), 0.3, 2, "TOPLEFT", useArrows, "BOTTOMLEFT", 2, -GAP)
	scaleslider.tiptext = "POI 아이콘의 크기를 설정합니다.."
	scaleslider:SetValue(ns.db.iconScale or 1)
	scaleslider:SetValueStep(.05)
	scaleslider:SetScript("OnValueChanged", function(self)
		ns.db.iconScale = self:GetValue()
		scaleslidertext:SetText(string.format("아이콘 크기: %.2f", ns.db.iconScale or 1))
		ns:UpdatePOIs()
	end)

	local ascaleslider, ascaleslidertext, ascalecontainer = tekslider.new(frame, string.format("화살표 크기: %.2f", ns.db.arrowScale or 1), 0.3, 2, "TOPLEFT", scalecontainer, "BOTTOMLEFT", 2, -GAP)
	ascaleslider.tiptext = "화살표의 크기를 설정합니다."
	ascaleslider:SetValue(ns.db.arrowScale or 1)
	ascaleslider:SetValueStep(.05)
	ascaleslider:SetScript("OnValueChanged", function(self)
		ns.db.arrowScale = self:GetValue()
		ascaleslidertext:SetText(string.format("화살표 크기: %.2f", ns.db.arrowScale or 1))
		ns:UpdatePOIs()
	end)
	
	local ialphaslider, ialphaslidertext, ialphacontainer = tekslider.new(frame, string.format("아이콘 투명도: %.2f", ns.db.iconAlpha or 1), 0.1, 1, "TOPLEFT", ascalecontainer, "BOTTOMLEFT", 2, -GAP)
	ialphaslider.tiptext = "POI 아이콘의 투명도 값을 설정합니다."
	ialphaslider:SetValue(ns.db.iconAlpha or 1)
	ialphaslider:SetValueStep(.05)
	ialphaslider:SetScript("OnValueChanged", function(self)
		ns.db.iconAlpha = self:GetValue()
		ialphaslidertext:SetText(string.format("아이콘 투명도: %.2f", ns.db.iconAlpha or 1))
		ns:UpdatePOIs()
	end)
	
	local aalphaslider, aalphaslidertext, aalphacontainer = tekslider.new(frame, string.format("화살표 투명도: %.2f", ns.db.arrowAlpha or 1), 0.1, 1, "TOPLEFT", ialphacontainer, "BOTTOMLEFT", 2, -GAP)
	aalphaslider.tiptext = "POI 화살표의 투명도를 설정합니다."
	aalphaslider:SetValue(ns.db.arrowAlpha or 1)
	aalphaslider:SetValueStep(.05)
	aalphaslider:SetScript("OnValueChanged", function(self)
		ns.db.arrowAlpha = self:GetValue()
		aalphaslidertext:SetText(string.format("화살표 투명도: %.2f", ns.db.arrowAlpha or 1))
		ns:UpdatePOIs()
	end)
	
	local fadeEdge = tekcheck.new(frame, nil, "Fade non-arrow icons on the edge", "TOPLEFT", aalphacontainer, "BOTTOMLEFT", -2, -GAP)
	fadeEdge.tiptext = "Automatically set TomTom's CrazyArrow to point to the nearest quest POI. This will mess up anything else you're trying to do with TomTom, so be careful with it."
	fadeEdge:SetScript("OnClick", function(self)
		checksound(self)
		ns.db.fadeEdge = not ns.db.fadeEdge
		ns:UpdatePOIs()
	end)
	fadeEdge:SetChecked(ns.db.fadeEdge)

	local autoTomTom = tekcheck.new(frame, nil, "TomTom에 자동 추가", "TOPLEFT", fadeEdge, "BOTTOMLEFT", -2, -GAP)
	autoTomTom.tiptext = "Automatically set TomTom's CrazyArrow to point to the nearest quest POI. This will mess up anything else you're trying to do with TomTom, so be careful with it."
	autoTomTom:SetScript("OnClick", function(self)
		checksound(self)
		ns.db.autoTomTom = not ns.db.autoTomTom
		ns:AutoTomTom()
	end)
	autoTomTom:SetChecked(ns.db.autoTomTom)

	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)

-----------------------------
--      Slash command      --
-----------------------------

_G["SLASH_".. myname:upper().."1"] = GetAddOnMetadata(myname, "X-LoadOn-Slash")
_G["SLASH_".. myname:upper().."2"] = "/qp"
SlashCmdList[myname:upper()] = function(msg)
	if msg:match("closest") and ns.TomTomClosestPOI then
		ns:TomTomClosestPOI()
	else
		InterfaceOptionsFrame_OpenToCategory(myname)
	end
end

----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(myname, {
	type = "launcher",
	icon = [[Interface\WorldMap\UI-WorldMap-QuestIcon.tga]],
	iconCoords = {0, 0.5, 0, 0.5},
	OnClick = function(self, button)
		if button == "RightButton" then
			InterfaceOptionsFrame_OpenToCategory(myname)
		elseif ns.TomTomClosestPOI then
			ns:TomTomClosestPOI()
		end
	end,
})

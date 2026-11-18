local name = "Can_Chat";
local currentVersion = GetAddOnMetadata("CAN_Chat", "Version");
local note = GetAddOnMetadata("Can_Chat", "Notes");
local localizedClass, englishClass = UnitClassBase("player");
local classColor = string.format("|cFF%02x%02x%02x", RAID_CLASS_COLORS[englishClass].r * 255, RAID_CLASS_COLORS[englishClass].g * 255, RAID_CLASS_COLORS[englishClass].b * 255);
local playerName = UnitName("player");
local myClass = UnitClass("player");
local ownerType = {["FRIEND"] = true, ["CHAT_ROSTER"] = false};
local editboxwidth, editboxheight, editboxnums = 100, 15, 5

local function prt(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end


local function defaults()


		-- 케릭별 저장
	if CANChatDB==nil then CANChatDB = {}; end
	if CANChatDB["Head"] == nil then  CANChatDB["Head"] = ""; end
	if CANChatDB["Whi"] == nil then  CANChatDB["Whi"] = localizedClass.." 손여~~";  end
	if CANChatDB["Ctrl"] == nil then  CANChatDB["Ctrl"] = 1; end
	if CANChatDB["Highlight"] == nil then  CANChatDB["Highlight"] = 0; end
	if CANChatDB["HighlightData"] == nil then  CANChatDB["HighlightData"] = {}; end
	if CANChatDB["HighlightSound"] == nil then  CANChatDB["HighlightSound"] = 0; end
	if CANChatDB["Except"] == nil then  CANChatDB["Except"] = 0; end
	if CANChatDB["ExceptData"] == nil then  CANChatDB["ExceptData"] = {}; end
	if CANChatDB["ChatFrame"] == nil then  CANChatDB["ChatFrame"] = 0; end
	if CANChatDB["TempExcept"] == nil then  CANChatDB["TempExcept"] = 0; end

		-- 계정별 저장
	if CANChat==nil then  CANChat = {};  end
	if CANChat["Combat"] == nil then  CANChat["Combat"] = 0; end
	if CANChat["Edit"] == nil then  CANChat["Edit"] = 1; end
	if CANChat["Fade"] == nil then  CANChat["Fade"] = 0; end
	if CANChat["Hide"] == nil then  CANChat["Hide"] = 0; end
	if CANChat["CallMe"] == nil then  CANChat["CallMe"] = {}; end
	if CANChat["OutLine"]==nil then CANChat["OutLine"] = 0; end
	if CANChat["ChatNo"]==nil then CANChat["ChatNo"] = "4"; end
	if CANChat["Channel"]==nil then CANChat["Channel"] = ""; end



--	prt("|cFFFFCC00/can|r   :  옵션창열기      |cFFFFCC00/can 도움말|r  :  도움말보기");
end



local Can = CreateFrame("Frame","Can",UIParent);
local CanOption = CreateFrame("Frame","CanOption",UIParent);

Can:RegisterEvent("VARIABLES_LOADED");
Can:RegisterEvent("PLAYER_ENTERING_WORLD")

function Can.OnLoad(self)
	self:SetScript("OnEvent", function(frame, event, ...) if Can[event] then return Can[event](Can, event, ...) end end)
end

function Can:VARIABLES_LOADED()

		defaults();
		Can_CreateOption();
		Highlight();            -- 구문강조
		CAN_InitSlash();	-- 명령어 입력
		CAN_Fade()		-- 숨김 기능
		CAN_EditBox()		-- 입력박스 위|아래
		CAN_Combatlog()		-- 전투로그창 왼쪽|오른쪽 정렬
		CAN_Out()		-- 채팅 글자에 아웃라인 입히기
		CAN_Core()
end


function CanOption.OnLoad(self)
	self.name = "Can_Chat";
	InterfaceOptions_AddCategory(self);
end

function Can_CreateOption()

	local title = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	title:SetPoint("TOPLEFT", 16, -16);
	title:SetText(name.." "..currentVersion);
	subText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
	subText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8);
	subText:SetText(note.."/캔 : 옵션창열기         /캔 도움말 : 유용한 명령어");
	AuthorText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
	AuthorText:SetPoint("BoTTOMRIGHT", CanOption, "BOTTOMRIGHT", -20, 5);
	AuthorText:SetText("레인서버  Noone");

	local whiVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	whiVText:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 10, -20);
	whiVText:SetText("보낼 귓속말");
	local whiV = CreateFrame("EditBox", "CanChatOptionsVolunteerEditBox", CanOption, "InputBoxTemplate");
	whiV:SetWidth(250);
	whiV:SetHeight(16);
	whiV:SetPoint("LEFT", whiVText, "RIGHT", 10, 0);
	whiV:SetAutoFocus(false);
	whiV:SetMaxLetters(255);
	whiV:SetScript("OnShow", function(self)
		self:SetText(CANChatDB.Whi);
		self:SetCursorPosition(0);
	end);
	whiV:SetScript("OnHide", function(self)
		local text = self:GetText();
		if (text == "" or text==nil) then
			CANChatDB.Whi=CANChatDB.Whi;
		else
			CANChatDB.Whi = text;
		end
	end);

	local whiD = CreateFrame("BUTTON", "CanChatOptionsVolunteerEditBoxDefaultButton", CanOption, "UIPanelButtonTemplate");
	whiD:SetWidth(44);
	whiD:SetHeight(22);
	whiD:SetPoint("LEFT", whiV, "RIGHT", 10, 0);
	whiD:SetText("초기화");
	whiD:SetScript("OnClick", function(self)
		CANChatDB.Whi=localizedClass.." 손여~~";
		whiV:SetText(CANChatDB.Whi);
	end);
	whiD:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText("Ctrl 귓속말을 \n"..classColor..localizedClass.." 손여~~|r 로 초기화합니다.");
	end);
	whiD:SetScript("OnLeave", function() GameTooltip:Hide() end);


	local hVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	hVText:SetPoint("TOPLEFT", whiVText, "BOTTOMLEFT", 0, -20);
	hVText:SetText("말머리");
	local hV = CreateFrame("EditBox", "CanChatOptionsHeadEditBox", CanOption, "InputBoxTemplate");
	hV:SetWidth(250);
	hV:SetHeight(16);
	hV:SetPoint("LEFT", hVText, "RIGHT", 37, 0);
	hV:SetAutoFocus(false);
	hV:SetMaxLetters(255);
	hV:SetScript("OnShow", function(self)
		self:SetText(CANChatDB.Head);
		self:SetCursorPosition(0);

	end);
	hV:SetScript("OnHide", function(self)
		local text = self:GetText();
		if (text == "" or text==nil) then
			CANChatDB.Head=CANChatDB.Head;
		else
			CANChatDB.Head = text;

		end
	end);

	local hD = CreateFrame("BUTTON", "CanChatOptionsHeadEditBoxDefaultButton", CanOption, "UIPanelButtonTemplate");
	hD:SetWidth(44);
	hD:SetHeight(22);
	hD:SetPoint("LEFT", hV, "RIGHT", 10, 0);
	hD:SetText("초기화");
	hD:SetScript("OnClick", function(self)
		CANChatDB.Head="";
		hV:SetText(CANChatDB.Head);
	end);
	hD:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText("|CFFFFCC00머리말을 초기화합니다.");
	end);
	hD:SetScript("OnLeave", function() GameTooltip:Hide() end);




	local chaVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	chaVText:SetPoint("TOPLEFT", hVText, "BOTTOMLEFT", 0, -20);
	chaVText:SetText("파티 채팅 프레임");
	local chaV = CreateFrame("EditBox", "CanChatOptionsNoEditBox", CanOption, "InputBoxTemplate");
	chaV:SetWidth(25);
	chaV:SetHeight(16);
	chaV:SetPoint("LEFT", chaVText, "RIGHT", 20, 0);
	chaV:SetAutoFocus(false);
	chaV:SetMaxLetters(255);
	chaV:SetScript("OnShow", function(self)
		self:SetText(CANChat.ChatNo);
		self:SetCursorPosition(0);
	end);
	chaV:SetScript("OnHide", function(self)	end);
	chaV:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText("|c00FFFFFF ※ 변경시 리로드 or 재접속 해주세요.   해당 채팅프레임이 없다면 수동으로 생성해주세요.");
	end);
	chaV:SetScript("OnLeave", function() GameTooltip:Hide() end);

	local chaD = CreateFrame("BUTTON", "CanChatOptionsHeadEditBoxDefaultButton", CanOption, "UIPanelButtonTemplate");
	chaD:SetWidth(44);
	chaD:SetHeight(22);
	chaD:SetPoint("LEFT", chaV, "RIGHT", 30, 0);
	chaD:SetText("확인");
	chaD:SetScript("OnClick", function(self)

			local text = chaV:GetText();
			if (text == "" or text==nil) then
				CANChat.ChatNo=CANChat.ChatNo;

			else
				if (CANChat.ChatNo == text) then
					if ( PartyChat:IsShown() ) then
						DEFAULT_CHAT_FRAME:AddMessage("|CFFFFCC00Can : 파티 채팅창 프레임 =  |c00FFFFFF"..CANChat.ChatNo.."|r")
						PartyChat:AddMessage("|CFFFFCC00현재 파티 채팅창 프레임|r")
					else
						DEFAULT_CHAT_FRAME:AddMessage("|CFFFFCC00해당 프레임은 생성되어 있지 않습니다. 해당 대화프레임을 생성하신 후에 리로드 or 재접속 하시면 적용됩니다.");
					end
				else

					 StaticPopupDialogs["CONFIRM"] = {
						text = TEXT(text.."번 프레임으로 적용 하시겠습니?"),
						button1 = TEXT("수락"),
						button2 = TEXT("취소"),
						timeout = 0,
						exclusive = 1,
						whileDead = 1,
						interruptCinematic = 1,
						OnAccept =  function(self)
							DEFAULT_CHAT_FRAME:AddMessage("|CFFFFCC00"..CANChat.ChatNo.."번 프레임에 적용되었습니다. 리로드 or 재접속 하시면 적용됩니다.");
						CANChat.ChatNo = text;
						PartyChat=getglobal("ChatFrame"..CANChat.ChatNo)
						PartyChatTab = getglobal("ChatFrame"..CANChat.ChatNo.."Tab")
						PartyChat:Show();  PartyChatTab:Show();
							if ( PartyChat:IsShown() ) then
								DEFAULT_CHAT_FRAME:AddMessage("|CFFFFCC00Can : 파티 채팅창 프레임 =  |c00FFFFFF"..CANChat.ChatNo.."|r")
								PartyChat:AddMessage("|CFFFFCC00현재 파티 채팅창 프레임|r")
							end
						end,

						OnCancel =  function(self)self:Hide()end,
					};

					local dialog = StaticPopup_Show("CONFIRM");

				end
			end
	end);

	chaD:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText("|CFFFFCC00파티 채팅 프레임 확인 및 적용");
	end);
	hD:SetScript("OnLeave", function() GameTooltip:Hide() end);


	local parVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	parVText:SetPoint("TOPLEFT", chaVText, "TOPLEFT", 0,-20);
	parVText:SetText("인전 진입시 파티창 숨김");
	local parcVText = CreateFrame("CheckButton", " htVText", CanOption, "InterfaceOptionsCheckButtonTemplate");
	parcVText:SetPoint("RIGHT", parVText, "RIGHT", 30, 0);
	parcVText:SetScript("OnClick", function(self) CANChatDB.ChatFrame = self:GetChecked()  prt("|cFFFFCC00Can : 파티창 인던 진입시 사라짐 기능 →  |CFF"..(CANChatDB["ChatFrame"]==1 and "00FF00사용" or "FF0000중지")) end);
	parcVText:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("|c00FFFFFF인던 진입시 파티창을 숨겨 줍니다.");
	end);
	parcVText:SetScript("OnHide", function(self) if CANChatDB.ChatFrame == 1 then parcVText:SetChecked(); end end)
	parcVText:SetScript("OnLeave", function() GameTooltip:Hide() end);


	local htVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	htVText:SetPoint("TOPLEFT", hVText, "BOTTOMLEFT", 0, -100);
	htVText:SetText("강조글 목록");
	local htcVText = CreateFrame("CheckButton", " htVText", CanOption, "InterfaceOptionsCheckButtonTemplate");
	htcVText:SetPoint("RIGHT",  htVText, "RIGHT", 30, 0);
	htcVText:SetScript("OnClick", function(self) CANChatDB.Highlight = self:GetChecked()  prt("|cFFFFCC00Can : 강조 기능 →  |CFF"..(CANChatDB["Highlight"]==1 and "00FF00사용" or "FF0000중지")) end);
	htcVText:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("|c00FFFFFF파티 채널에 아래에 입력한 문구들을 강조합니다.");
	end);
	htcVText:SetScript("OnHide", function(self) if CANChatDB.Highlight == 1 then htcVText:SetChecked(); end end);
	htcVText:SetScript("OnLeave", function() GameTooltip:Hide() end);


	local edVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	edVText:SetPoint("TOPLEFT", htVText, "TOPLEFT", 150,0);
	edVText:SetText("제외글 목록");
	local edcVText = CreateFrame("CheckButton", " htVText", CanOption, "InterfaceOptionsCheckButtonTemplate");
	edcVText:SetPoint("RIGHT", edVText, "RIGHT", 30, 0);
	edcVText:SetScript("OnClick", function(self) CANChatDB.Except = self:GetChecked()  prt("|cFFFFCC00Can : 제외 기능 →  |CFF"..(CANChatDB["Except"]==1 and "00FF00사용" or "FF0000중지")) end);
	edcVText:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("|c00FFFFFF파티 채널에 아래에 입력한 문구가 포함된 글들을 제외합니다.");
	end);
	edcVText:SetScript("OnHide", function(self) if CANChatDB.Except == 1 then edcVText:SetChecked(); end end);
	edcVText:SetScript("OnLeave", function() GameTooltip:Hide() end);


	local hteVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	hteVText:SetPoint("TOPLEFT", htVText, "TOPLEFT", 0,-140);
	hteVText:SetText("강조글만 보기");
	local htecVText = CreateFrame("CheckButton", " htVText", CanOption, "InterfaceOptionsCheckButtonTemplate");
	htecVText:SetPoint("RIGHT", hteVText, "RIGHT", 30, 0);
	htecVText:SetScript("OnClick", function(self) CANChatDB.TempExcept = self:GetChecked()  prt("|cFFFFCC00Can : 예외 기능 →  |CFF"..(CANChatDB["TempExcept"]==1 and "00FF00사용" or "FF0000중지")) end);
	htecVText:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("|c00FFFFFF강조글이 포함된 글만 채팅창에 보여줍니다.");
	end);
	htecVText:SetScript("OnHide", function(self) if CANChatDB.TempExcept == 1 then htecVText:SetChecked(); end end);
	htecVText:SetScript("OnLeave", function() GameTooltip:Hide() end);


	local caVText = CanOption:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	caVText:SetPoint("TOPLEFT",edVText, "TOPLEFT", 150,0);
	caVText:SetText("나를불러주세요");


	local editboxname = "TestEditBox"
	local frame = CreateFrame("frame", "TestScrollFrame", CanOption)
	local scroll = CreateFrame("scrollframe", "TestEditBoxScroll", frame, "FauxScrollFrameTemplate")

	local editboxname2 = "TestEditBox2"
	local frame2 = CreateFrame("frame", "TestScrollFrame2", CanOption)
	local scroll2 = CreateFrame("scrollframe", "TestEditBoxScroll2", frame2, "FauxScrollFrameTemplate")

	local editboxname3 = "TestEditBox3"
	local frame3 = CreateFrame("frame", "TestScrollFrame3", CanOption)
	local scroll3 = CreateFrame("scrollframe", "TestEditBoxScroll3", frame3, "FauxScrollFrameTemplate")

	local function updatescroll(self)
	    local nums = #CANChatDB.HighlightData + 1 -- 한개 더 많게하여 빈 입력칸이 보여지도록 함
	    local index, eb
	    for i = 1, editboxnums do
		index = i + self.offset
		eb = _G[editboxname..i]
		if CANChatDB.HighlightData[index] or index == nums then
	            eb:ClearFocus()
		    if CANChatDB.HighlightData[index] then
			eb:SetText(CANChatDB.HighlightData[index] or "")
		    else
			eb:SetText("")
		    end

		    eb:SetID(index)
		    eb:Show()
		    eb:SetCursorPosition(0);

		else
		    eb:Hide()
		end
	    end

	    local showscrollbar = FauxScrollFrame_Update(self, nums, editboxnums, editboxheight)

	end

	local function OnEnterPressed(self)
	    local text = self:GetText()
	    local id = self:GetID()

	    if not text or text == "" then
	     if CANChatDB.HighlightData[id] then
		    table.remove(CANChatDB.HighlightData, id)
	     end
	    else
		CANChatDB.HighlightData[id] = text
	    end

	    self:ClearFocus()
	    updatescroll(scroll)
	end

	local function OnEscapePressed(self)
	    self:SetText(CANChatDB.HighlightData[self:GetID()] or "")
	    self:ClearFocus()
	end

	for i = 1, editboxnums do
	    local x = i*editboxheight
	    local eb = CreateFrame("editbox", editboxname..i, frame)
	    eb:SetAutoFocus(false)
	    eb:EnableMouse(true)
	    eb:SetFontObject("GameFontHighlightSmall")
	    eb:SetScript("OnEnterPressed", OnEnterPressed)
	    eb:SetScript("OnEscapePressed", OnEscapePressed)
	    eb:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
	    eb:SetScript("OnEditFocusGained", EditBox_HighlightText)
	    eb:SetWidth(editboxwidth)
	    eb:SetHeight(editboxheight)
	    eb:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -(x-editboxheight))
	    eb:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -x)
	    local t = eb:CreateTexture(nil, "border")
	    t:SetTexture(0, 0, 0, 0.5)
	    t:SetAllPoints(eb)
	end

	scroll.scrollBarHideable = true
	scroll:SetScript("OnVerticalScroll", function(self, arg)
	    FauxScrollFrame_OnVerticalScroll(self, arg, editboxheight, updatescroll) end)
	scroll:SetAllPoints(frame)
	scroll:RegisterEvent("VARIABLES_LOADED")
	scroll:SetScript("OnShow", updatescroll)
	scroll:SetScript("OnEvent", updatescroll)

	frame:SetWidth(editboxwidth)
	frame:SetHeight(editboxheight*editboxnums)
	frame:SetPoint("LEFT", htVText, "LEFT", 0, -50)

	t = frame:CreateTexture(nil, "artwork")
	t:SetAllPoints(frame)
	t:SetWidth(editboxwidth)
	t:SetHeight(editboxheight*editboxnums)
	t:SetTexture(0, 0, 0, 0.5)



	local function updatescroll2(self)
	    local nums = #CANChatDB.ExceptData+1 -- 한개 더 많게하여 빈 입력칸이 보여지도록 함
	    local index, eb2
	    for i = 1, editboxnums do
		index = i + self.offset
		eb2 = _G[editboxname2..i]
		if CANChatDB.ExceptData[index] or index == nums then
		    eb2:ClearFocus()
		    eb2:SetText(CANChatDB.ExceptData[index] or "")
		    eb2:SetID(index)
		    eb2:Show()
		    eb2:SetCursorPosition(0);
		else
		    eb2:Hide()
		end
	    end

	    local showscrollbar = FauxScrollFrame_Update(self, nums, editboxnums, editboxheight)

	end

	local function OnEnterPressed2(self)
	    local text = self:GetText()
	    local id = self:GetID()
	    if not text or text == "" then
	     if CANChatDB.ExceptData[id] then
		    table.remove(CANChatDB.ExceptData, id)
	     end
	    else
		CANChatDB.ExceptData[id] = text
	    end
	    self:ClearFocus()
	    updatescroll2(scroll2)
	end
	local function OnEscapePressed2(self)
	    self:SetText(CANChatDB.ExceptData[self:GetID()] or "")
	    self:ClearFocus()
	end

	for i = 1, editboxnums do
	    local x = i*editboxheight
	    local eb2 = CreateFrame("editbox", editboxname2..i, frame2)
	    eb2:SetAutoFocus(false)
	    eb2:EnableMouse(true)
	    eb2:SetFontObject("GameFontHighlightSmall")
	    eb2:SetScript("OnEnterPressed", OnEnterPressed2)
	    eb2:SetScript("OnEscapePressed", OnEscapePressed2)
	    eb2:SetScript("OnEditFocusLost", EditBox_ClearHighlight2)
	    eb2:SetScript("OnEditFocusGained", EditBox_HighlightText2)
	    eb2:SetWidth(editboxwidth)
	    eb2:SetHeight(editboxheight)
	    eb2:SetPoint("TOPLEFT", frame2, "TOPLEFT", 0, -(x-editboxheight))
	    eb2:SetPoint("TOPRIGHT", frame2, "TOPRIGHT", 0, -x)
	    local t2 = eb2:CreateTexture(nil, "border")
	    t2:SetTexture(0, 0, 0, 0.5)
	    t2:SetAllPoints(eb2)
	end

	scroll2.scrollBarHideable = true

	scroll2:SetScript("OnVerticalScroll", function(self, arg)
	  FauxScrollFrame_OnVerticalScroll(self, arg, editboxheight, updatescroll2) end)
	scroll2:RegisterEvent("VARIABLES_LOADED")
	scroll2:SetAllPoints(frame2)
	scroll2:SetScript("OnShow", updatescroll2)
	scroll2:SetScript("OnEvent", updatescroll2)

	frame2:SetWidth(editboxwidth)
	frame2:SetHeight(editboxheight*editboxnums)
	frame2:SetPoint("LEFT", edVText, "LEFT", 0, -50)

	t2 = frame2:CreateTexture(nil, "artwork")
	t2:SetAllPoints(frame2)
	t2:SetWidth(editboxwidth)
	t2:SetHeight(editboxheight*editboxnums)
	t2:SetTexture(0, 0, 0, 0.5)



	local function updatescroll3(self)
	    local nums = #CANChat.CallMe+1 -- 한개 더 많게하여 빈 입력칸이 보여지도록 함
	    local index, eb3
	    for i = 1, editboxnums do
		index = i + self.offset
		eb3 = _G[editboxname3..i]
		if CANChat.CallMe[index] or index == nums then
		    eb3:ClearFocus()
		    eb3:SetText(CANChat.CallMe[index] or "")
		    eb3:SetID(index)
		    eb3:Show()
		    eb3:SetCursorPosition(0);
		else
		    eb3:Hide()
		end
	    end

	    local showscrollbar = FauxScrollFrame_Update(self, nums, editboxnums, editboxheight)

	end

	local function OnEnterPressed3(self)
	    local text = self:GetText()
	    local id = self:GetID()
	    if not text or text == "" then
	     if CANChat.CallMe[id] then
		    table.remove(CANChat.CallMe, id)
	     end
	    else
		CANChat.CallMe[id] = text
	    end
	    self:ClearFocus()
	    updatescroll3(scroll3)
	end
	local function OnEscapePressed3(self)
	    self:SetText(CANChat.CallMe[self:GetID()] or "")
	    self:ClearFocus()
	end

	for i = 1, editboxnums do
	    local x = i*editboxheight
	    local eb3 = CreateFrame("editbox", editboxname3..i, frame3)
	    eb3:SetAutoFocus(false)
	    eb3:EnableMouse(true)
	    eb3:SetFontObject("GameFontHighlightSmall")
	    eb3:SetScript("OnEnterPressed", OnEnterPressed3)
	    eb3:SetScript("OnEscapePressed", OnEscapePressed3)
	    eb3:SetScript("OnEditFocusLost", EditBox_ClearHighlight3)
	    eb3:SetScript("OnEditFocusGained", EditBox_HighlightText3)
	    eb3:SetWidth(editboxwidth)
	    eb3:SetHeight(editboxheight)
	    eb3:SetPoint("TOPLEFT", frame3, "TOPLEFT", 0, -(x-editboxheight))
	    eb3:SetPoint("TOPRIGHT", frame3, "TOPRIGHT", 0, -x)
	    local t3 = eb3:CreateTexture(nil, "border")
	    t3:SetTexture(0, 0, 0, 0.5)
	    t3:SetAllPoints(eb3)
	end

	scroll3.scrollBarHideable = true
	scroll3:SetScript("OnVerticalScroll", function(self, arg)
	  FauxScrollFrame_OnVerticalScroll(self, arg, editboxheight, updatescroll3) end)
	scroll3:RegisterEvent("VARIABLES_LOADED")
	scroll3:SetAllPoints(frame3)
	scroll3:SetScript("OnShow", updatescroll3)
	scroll3:SetScript("OnEvent", updatescroll3)

	frame3:SetWidth(editboxwidth)
	frame3:SetHeight(editboxheight*editboxnums)
	frame3:SetPoint("LEFT",caVText, "LEFT", 0, -50)

	t3 = frame3:CreateTexture(nil, "artwork")
	t3:SetAllPoints(frame3)
	t3:SetWidth(editboxwidth)
	t3:SetHeight(editboxheight*editboxnums)
	t3:SetTexture(0, 0, 0, 0.5)


	local htD = CreateFrame("BUTTON", "CanChatOptionshtEditBoxDefaultButton", CanOption, "UIPanelButtonTemplate");
	htD:SetWidth(100);
	htD:SetHeight(10);
	htD:SetPoint("LEFT", htVText, "LEFT", 0, -100);
	htD:SetText("초기화");
	htD:SetScript("OnClick", function(self)
		CANChatDB.HighlightData = {};
		updatescroll(scroll)
	end);
	htD:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText("강조글 목록 초기화");
	end);
	htD:SetScript("OnLeave", function() GameTooltip:Hide() end)


	local edD = CreateFrame("BUTTON", "CanChatOptionsedEditBoxDefaultButton", CanOption, "UIPanelButtonTemplate");
	edD:SetWidth(100);
	edD:SetHeight(10);
	edD:SetPoint("LEFT", edVText, "LEFT", 0, -100);
	edD:SetText("초기화");
	edD:SetScript("OnClick", function(self)
		CANChatDB.ExceptData = {};
		updatescroll2(scroll2)
	end);
	edD:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText("제외글 목록 초기화");
	end);
	edD:SetScript("OnLeave", function() GameTooltip:Hide() end)


	local caD = CreateFrame("BUTTON", "CanChatOptionscaEditBoxDefaultButton", CanOption, "UIPanelButtonTemplate");
	caD:SetWidth(100);
	caD:SetHeight(10);
	caD:SetPoint("LEFT", caVText, "LEFT", 0, -100);
	caD:SetText("초기화");
	caD:SetScript("OnClick", function(self)
		CANChat.CallMe = {};
		updatescroll3(scroll3)
	end);
	caD:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText("콜미 목록 초기화");
	end);
	caD:SetScript("OnLeave", function() GameTooltip:Hide() end)


end






Can:OnLoad()
CanOption:OnLoad()

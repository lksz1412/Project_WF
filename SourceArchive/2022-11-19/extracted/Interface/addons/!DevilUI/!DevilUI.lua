local L = GetLocale()
local index = GetCurrentResolution();
local resolution = select(index, GetScreenResolutions());
local NORMAL = (resolution == "720x576"
		or resolution == "800x600"
		or resolution == "1024x768"
		or resolution == "1152x864"
		or resolution == "1280x960"
		or resolution == "1280x1024"
		or resolution == "1400x1050"
		or resolution == "1600x1200"
		or resolution == "1680x1200"
		or resolution == "1920x1440"
		or resolution == "2048x1536"
		or resolution == "3200x2400");

local LOW =	(resolution == "1280x720"
		or resolution == "1280x800"
		or resolution == "1920x1080"
		or resolution == "2048x1152"
		or resolution == "2560x1440"
		or resolution == "2880x1620"
		or resolution == "3200x1800"
		or resolution == "3840x2160"
		or resolution == "4096x2160");

local MEDIUM = (resolution == "1152x864"
		or resolution == "1360x768"
		or resolution == "1366x768"
		or resolution == "1440x900"
		or resolution == "1680x1050"
		or resolution == "1920x1200"
		or resolution == "2560x1600"
		or resilution == "2880x1800"
		or resolution == "3840x2400");
		
local HIGH = (resolution == "1920x817"
		or resolution == "2560x1080"
		or resolution == "3440x1440"
		or resolution == "6880x2880");
		
local function installNormal()
	ChatFrame1EditBox:SetText("/reflux switch ShapaNormal");
	ChatEdit_SendText( ChatFrame1EditBox );
	Devilinstall = true
end

local function installWide()
	ChatFrame1EditBox:SetText("/reflux switch ShapaWide");
	ChatEdit_SendText( ChatFrame1EditBox );
	Devilinstall = true
end

local function installWideHigh()
	ChatFrame1EditBox:SetText("/reflux switch ShapaWH");
	ChatEdit_SendText( ChatFrame1EditBox );
	Devilinstall = true
end

local function chatset()
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	ChatFrame1:Show()
	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		local chatFrameId = frame:GetID()
		local chatName = FCF_GetChatWindowInfo(chatFrameId)				
		if i == 1 then
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 8, 166)
			frame:SetHeight(200)
			frame:SetWidth(400)
			frame:Show()
		end
	end
	
	FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_StopDragging(ChatFrame1)
	ChatFrame1:SetUserPlaced(true)
	FCF_SetChatWindowFontSize(self, ChatFrame1, 14)
	FCF_SetChatWindowFontSize(self, ChatFrame3, 14)
	FCF_SetWindowAlpha(ChatFrame1, 0)
	FCF_SetWindowAlpha(ChatFrame2, 0)
	FCF_SetWindowAlpha(ChatFrame3, 0)			
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")	
	ChangeChatColor("CHANNEL5", 195/255, 230/255, 232/255)
	ChangeChatColor("CHANNEL6", 55/255, 172/255, 92/255)

	StaticPopup_Show("DEVILSETTING")
	if (NORMAL) then 
		StaticPopup_Show("NORMAL")
	elseif (HIGH) then
		StaticPopup_Show("WIDE2")
	else
		StaticPopup_Show("WIDE")
	end
end

local function installdevil()
	if (NORMAL) then 
		StaticPopup_Show("NORMAL")
	elseif (HIGH) then
		StaticPopup_Show("WIDE2")
	else
		StaticPopup_Show("WIDE")
	end
end
	
StaticPopupDialogs["NORMAL"] = {
	text = "환영합니다. DevilUI를 시작 합니다.",
	button1 = "OK",
	OnAccept = installNormal,
	timeout = 0,
	whileDead = 1,
}
StaticPopupDialogs["WIDEHIGH"] = {
	text = "환영합니다. DevilUI를 시작 합니다.",
	button1 = "OK",
	OnAccept = installWideHigh,
	timeout = 0,
	whileDead = 1,
}
StaticPopupDialogs["WIDE"] = {
	text = "환영합니다. DevilUI를 시작 합니다.",
	button1 = "OK",
	OnAccept = installWide,
	timeout = 0,
	whileDead = 1,
}
StaticPopupDialogs["CHATSETTING"] = {
	text = "채팅설정을 초기화 하시겠습니까?\n\n(DeviUI가 처음이신 분만 초기화 하세요.)",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = chatset,
	OnCancel = installdevil,
	timeout = 0,
	whileDead = 1,
}
StaticPopupDialogs["DEVILSETTING"] = {
	text = "※채팅창 개인설정은 재접속후에 가능합니다.\n(재접속 이전에 변경하시면 설정이 초기화 됩니다.).",
	timeout = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

local DevilUIcheckinstall = CreateFrame("Frame")
	DevilUIcheckinstall:RegisterEvent("PLAYER_ENTERING_WORLD")
	DevilUIcheckinstall:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	print("Welcome on DevilUI for patch 9.2.0 !")
	print("현재 해상도:", resolution);
	print(" ")

	SetCVar("screenshotQuality", 8)	
	SetCVar("useUiScale", 1)
	SetCVar("checkAddonVersion", 0)
	SetCVar("scriptErrors", 0)
	SetCVar("countdownForCooldowns", 1)

	if not (Devilinstall) then

		SetCVar("cameraDistanceMaxZoomFactor", 2.6)
		SetCVar("chatStyle", "classic")

		if (LOW) then
			SetCVar("uiScale", 0.75)
		elseif (MEDIUM) then
			SetCVar("uiScale", 0.825)
		elseif (HIGH) then
			SetCVar("uiScale", 0.75)
		else
			SetCVar("uiScale", 0.7)
		end

		StaticPopup_Show("CHATSETTING")
		StaticPopup_Hide("GTFO_POPUP_MESSAGE")
	end
end)

BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 10, 50)
end)

TimeAlertFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 10, 50)
end)
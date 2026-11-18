
BLANK_TEXTURE			= "Interface\\AddOns\\!DevilUI\\media\\WHITE64X64"
DevilUI_BORDER_COLOR		= { .2,.2,.2,1 }
DevilUI_BACKDROP_COLOR	= { .1,.1,.1,1 }

function CreatePanel(height, width, x, y, anchorPoint, anchorPointRel, anchor, level, parent, strata)
	local Panel = CreateFrame("Frame", _, parent)
	Panel:SetFrameLevel(level)
	Panel:SetFrameStrata(strata)
	Panel:SetHeight(height)
	Panel:SetWidth(width)
	Panel:SetPoint(anchorPoint, anchor, anchorPointRel, x, y)
	Panel:SetBackdrop( { 
		bgFile = BLANK_TEXTURE, 
		edgeFile = BLANK_TEXTURE, 
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	Panel:SetBackdropColor(unpack(DevilUI_BACKDROP_COLOR))
	Panel:SetBackdropBorderColor(unpack(DevilUI_BORDER_COLOR))
	return Panel
end 

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
		or resolution == "1920x1440");

local WIDE = (resolution == "1440x900"
		or resolution == "1280x800" 
		or resolution == "1680x1050" 
		or resolution == "1920x1200" 
		or resolution == "2560x1600");

local WIDEX = (resolution == "1680x945" 
		or resolution == "2560x1440" 
		or resolution == "1920x1080" 
		or resolution == "1600x900" 
		or resolution == "2048x1152" 
		or resolution == "1776x1000"
		or resolution == "1360x768" 
		or resolution == "1366x768");

local function installNormal()
	ChatFrame1EditBox:SetText("/reflux switch Normal");
	ChatEdit_SendText( ChatFrame1EditBox );
	Devilinstall = true
end
local function installWide()
	ChatFrame1EditBox:SetText("/reflux switch Wide");
	ChatEdit_SendText( ChatFrame1EditBox );
	Devilinstall = true
end
local function installWideX()
	ChatFrame1EditBox:SetText("/reflux switch WideX");
	ChatEdit_SendText( ChatFrame1EditBox );
	Devilinstall = true
end
local function chatset()
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
			
	if (NORMAL) then
		FCF_OpenNewWindow("길드&귓말")
		FCF_UnDockFrame(ChatFrame3)
		FCF_SetLocked(ChatFrame3, 1)
		ChatFrame3:Show()
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = _G[format("ChatFrame%s", i)]
			local chatFrameId = frame:GetID()
			local chatName = FCF_GetChatWindowInfo(chatFrameId)				
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 26)
				frame:SetHeight(146)
				frame:SetWidth((GetScreenWidth()-490)/2)
			elseif i == 3 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 400)
				frame:SetHeight(146)
				frame:SetWidth((GetScreenWidth()-490)/2)
			end
		end
		FCF_SavePositionAndDimensions(ChatFrame3)
		FCF_StopDragging(ChatFrame3)
		StaticPopup_Show("NORMAL")
	else
		FCF_OpenNewWindow("길드&귓말")
		FCF_UnDockFrame(ChatFrame3)
		FCF_SetLocked(ChatFrame3, 1)
		ChatFrame3:Show()
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = _G[format("ChatFrame%s", i)]
			local chatFrameId = frame:GetID()
			local chatName = FCF_GetChatWindowInfo(chatFrameId)				
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 26)
				frame:SetHeight(146)
				frame:SetWidth((GetScreenWidth()-854)/2)
			elseif i == 3 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 240)
				frame:SetHeight(160)
				frame:SetWidth((GetScreenWidth()-854)/2)
			end
		end
		FCF_SavePositionAndDimensions(ChatFrame3)
		FCF_StopDragging(ChatFrame3)
		GarrisonLandingPageMinimapButton:Hide()
		GarrisonLandingPageMinimapButton:SetParent(Minimap)
		GarrisonLandingPageMinimapButton:ClearAllPoints()
		GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", 12, -46)
	end

	ChatFrame1:SetUserPlaced(true)
	FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_StopDragging(ChatFrame1)
	FCF_SetWindowAlpha(ChatFrame1, 0)
	FCF_SetWindowAlpha(ChatFrame2, 0)
	FCF_SetWindowAlpha(ChatFrame3, 0)
	FCF_SetChatWindowFontSize(self, ChatFrame1, 14)
	FCF_SetChatWindowFontSize(self, ChatFrame3, 14)
	
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM_NOMENU")
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame1, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame1, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame1, "CHANNEL")
	ChatFrame_AddMessageGroup(ChatFrame1, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_BATTLE_INFO")

	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame3, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame3, "CHANNEL")
	ChatFrame_AddMessageGroup(ChatFrame3, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame3, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_CONVERSATION")

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
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")

	ChangeChatColor("CHANNEL5", 195/255, 230/255, 232/255)
	ChangeChatColor("CHANNEL6", 55/255, 172/255, 92/255)

	StaticPopup_Show("DEVILSETTING")
	if (WIDE) then
		StaticPopup_Show("WIDE")
	elseif (WIDEX) then
		StaticPopup_Show("WIDEX")
	end
end
local function installdevil()
	if (NORMAL) then 
		StaticPopup_Show("NORMAL")
	elseif (WIDE) then
		StaticPopup_Show("WIDE")
	else
		StaticPopup_Show("WIDEX")
	end
end

StaticPopupDialogs["NORMAL"] = {
	text = "환영합니다. DevilUI를 시작 합니다.",
	button1 = "OK",
	OnAccept = installNormal,
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
StaticPopupDialogs["WIDEX"] = {
	text = "환영합니다. DevilUI를 시작 합니다.",
	button1 = "OK",
	OnAccept = installWideX,
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

	print("Welcome on DevilUI for patch 6.0 !")
	print("현재 해상도:", resolution);
	print("만든이:헬스크림 호드-챈트마스터")
	print(" ")

	SetCVar("screenshotQuality", 8)	
	SetCVar("useUiScale", 1)
	SetCVar("checkAddonVersion", 0)
	SetCVar("scriptErrors", 0)
	SetCVar("countdownForCooldowns", 1)

	if not (Devilinstall) then
		SetCVar("uiScale", 0.75)
		SetCVar("chatStyle", "classic")
		SetCVar("cameraDistanceMaxFactor", 2)
		SetCVar("cameraDistanceMax", 50)

--		if (LOW) then
--			SetCVar("uiScale", 0.9)
--		else
--			SetCVar("uiScale", 0.75)
--		end

		StaticPopup_Show("CHATSETTING")
		StaticPopup_Hide("GTFO_POPUP_MESSAGE")
	end
end)

BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame3, "TOPLEFT", 10, 50)
end)

TimeAlertFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame3, "TOPLEFT", 10, 50)
end)
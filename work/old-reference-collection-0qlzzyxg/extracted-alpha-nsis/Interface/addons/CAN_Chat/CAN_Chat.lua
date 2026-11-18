DEFAULT_CHATFRAME_ALPHA = 0			-- 채팅창 프레임 알파값(마우스를 채창에 올렸을때 프레임 알파값변화 0)
local currentVersion = GetAddOnMetadata("CAN_Chat", "Version");
--------------------------------------------------------------------------------
--  Core
--------------------------------------------------------------------------------
function CAN_Core()


	local PartyChat
	local PartyChatTab
	local FrameName, ChatNumber
	local f = CreateFrame("Frame")
	f:RegisterEvent("VARIABLES_LOADED")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function(self, event)

		PartyChat=getglobal("ChatFrame"..CANChat.ChatNo)
		PartyChatTab = getglobal("ChatFrame"..CANChat.ChatNo.."Tab")

		if (event == "PLAYER_ENTERING_WORLD") and CANChatDB["ChatFrame"]==1 then  -- 인던 진입시 파티창 프레임 숨김
			local ins, instype = IsInInstance()

			if ins and (instype=="party" or instype=="raid" or instype=="arena") then
				PartyChat:Hide();
				PartyChatTab:Hide();
				PartyHide=true
			else
				PartyChat:Show();
				PartyChatTab:Show();
				PartyHide=false
			end
		end

	end)

end
--------------------------------------------------------------------------------
-- Channel sticky		채널 고정 (고정을 풀고 싶을땐 해당 채널 뒤에 숫자 1 를 0 으로 바꾸시면 됩니다. 지우셔도 되구요)
--------------------------------------------------------------------------------
	ChatTypeInfo['SAY'].sticky =			1
	ChatTypeInfo['YELL'].sticky =			1
	ChatTypeInfo['PARTY'].sticky =			1
	ChatTypeInfo['GUILD'].sticky =			1
	ChatTypeInfo['OFFICER'].sticky =		1
	ChatTypeInfo['RAID'].sticky =			1
	ChatTypeInfo['RAID_WARNING'].sticky =	        1
	ChatTypeInfo['INSTANCE_CHAT'].sticky =	        1
	ChatTypeInfo['WHISPER'].sticky =		1      --   귓말   ★★★  <=====================================================
	ChatTypeInfo['CHANNEL'].sticky =		1

--------------------------------------------------------------------------------
--  채널줄임
--------------------------------------------------------------------------------
	local _G = getfenv(0)
	_G.CHAT_GUILD_GET =				"G %s:\32"
	_G.CHAT_RAID_GET =				"공 %s:\32"
	_G.CHAT_PARTY_GET =				"P %s:\32"
	_G.CHAT_RAID_WARNING_GET =		"|cffff0000[|r경보|cffff0000]|r %s:\32"
	_G.CHAT_RAID_LEADER_GET =			"|cffff3399[|r공L|cffff3399]|r %s:\32"
	_G.CHAT_OFFICER_GET =				"o %s:\32"
	_G.CHAT_INSTANCE_CHAT_GET =		"인스 %s:\32"
	_G.CHAT_INSTANCE_CHAT_LEADER_GET =	"|cffff0000[|r전L|cffff0000]|r %s:\32"
	_G.CHAT_SAY_GET =				"%s:\32"
	_G.CHAT_YELL_GET =				"%s:\32"
	_G.CHAT_WHISPER_GET =				"From %s:\32"
	_G.CHAT_WHISPER_INFORM_GET =		"To %s:\32"
	_G.CHAT_FLAG_AFK =				"[AFK] "
	_G.CHAT_FLAG_DND =				"[DND] "
	_G.CHAT_FLAG_GM =				"[GM] "
	_G.CHAT_PARTY_LEADER_GET =			"PL %s:\32"
	_G.CHAT_PARTY_GUIDE_GET =			"DG %s:\32"

--------------------------------------------------------------------------------
-- More Font Size		폰트사이즈 추가
--------------------------------------------------------------------------------
	CHAT_FONT_HEIGHTS = {
		[1] = 7,	[2] = 8,	[3] = 9,	[4] = 10,	[5] = 11,	[6] = 12,
		[7] = 13,	[8] = 14,	[9] = 15,	[10] = 16,	[11] = 17,	[12] = 18,
		[13] = 19,	[14] = 20,	[15] = 21,	[16] = 22,	[17] = 24,	[18] = 32
	}

--------------------------------------------------------------------------------
-- 명령어
--------------------------------------------------------------------------------
	function CAN_SetHead(msg) CANChatDB["Head"] = msg; end
	function CAN_SetWhi(msg) if msg == "" then CANChatDB["Whi"]=myClass.." 손여~~"; else CANChatDB["Whi"] = msg;   end end

	function CAN_Set(msg)	-- 명령어2
		local c,x,y = string.split(" ",msg)
		PartyChat=getglobal("ChatFrame"..CANChat.ChatNo)
		PartyChatTab = getglobal("ChatFrame"..CANChat.ChatNo.."Tab")
		if c=="" then
			InterfaceOptionsFrame_OpenToCategory("Can_Chat");
		elseif c=="도움말" then
			Help()
		elseif c=="폰트강조" then
			CANChat["OutLine"]= 1 - CANChat["OutLine"]
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Can : Ctrl폰트강조 기능 →  |CFF"..(CANChat["OutLine"]==1 and "00FF00사용" or "FF0000중지"))
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFCC00 이 옵션 변경은 재접속이나 UI 리로드 후에 적용됩니다. ")
		elseif c=="귓말" then
			CANChatDB["Ctrl"] = 1 - CANChatDB["Ctrl"]
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Can : Ctrl귓말 기능 →  |CFF"..(CANChatDB["Ctrl"]==1 and "00FF00사용" or "FF0000중지"))
		elseif c=="전투로그" then
			CANChat["Combat"] = 1 - CANChat["Combat"];
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Can : 전투로그 →  |CFF"..(CANChat["Combat"]==1 and "00FF00오른쪽 정렬" or "FF0000왼쪽 정렬"))
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFCC00 이 옵션 변경은 재접속이나 UI 리로드 후에 적용됩니다. ")
		elseif c=="입력창" then
			CANChat["Edit"] = 1 - CANChat["Edit"];
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Can : 입력창 →  |CFF"..(CANChat["Edit"]==1 and "00FF00위로" or "FF0000아래로"))
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFCC00 이 옵션 변경은 재접속이나 UI 리로드 후에 적용됩니다. ")
		elseif c=="사라짐" then
			CANChat["Fade"] = 1 - CANChat["Fade"];
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Can : 사라짐 기능 →  |CFF"..(CANChat["Fade"]==1 and "00FF00사용" or "FF0000중지"))
		elseif c=="파티창" then
			if x=="켬" then	PartyChat:Show();  PartyChatTab:Show();
			elseif x=="끔" then	PartyChat:Hide();  PartyChatTab:Hide();
			elseif x == "검색" then
				local x = GetMouseFocus();
				if x then
					FrameName = x:GetName();
					ChatNumber = string.sub(FrameName, 10, 10)
					if tonumber(ChatNumber) then
						DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00검색된 채팅창 번호 = |c00FFFFFF"..ChatNumber)
					else
						DEFAULT_CHAT_FRAME:AddMessage("|cff88ffaa채팅창 좌측상단 설정탭 위에 마우스를 올리고 다시 해보세요")
					end
				end
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Can : 잘못 입력 하셨습니다. /캔 도움말");
		end
	end


	CAN_SendChatMessage = SendChatMessage;
	function HEAD_SendChatMessage(msg, chatType, language, channel)
		if instype~="arena"	then CAN_SendChatMessage(CANChatDB["Head"]..msg, chatType, language, channel); end
	end
	SendChatMessage = HEAD_SendChatMessage;

--------------------------------------------------------------------------------
-- AltInvite( Thanks to Tools!(clamp) )   and   CtrlWhisper(class)
--  알트 클릭 초대 와 컨트롤 클릭 귓말 기능
--------------------------------------------------------------------------------
	hooksecurefunc("SetItemRef", function(link)
	 local name = link and link:match("^player:([^:]+).*$")
	    if not name then return end
	    if IsAltKeyDown() then
		InviteUnit(name) ChatFrame1EditBox:Hide()
	    elseif CANChatDB["Ctrl"] == 1 and IsControlKeyDown() then
		SendChatMessage(CANChatDB["Whi"], "WHISPER", nil, name) ChatFrame1EditBox:Hide()
	    end
	 end)
--------------------------------------------------------------------------------
-- Clear ChatFrame		채팅창 지우기
--------------------------------------------------------------------------------
	local function ClearChatFrame(cmd)
		local cf;
		for i = 1, NUM_CHAT_WINDOWS do
			if i~=2 and i~=3 then
				cf = _G["ChatFrame"..i];  -- 컴뱃로그 제외
				if( (cf ~= nil)) then cf:Clear(); end
			end
		end
	end

	SlashCmdList["CANChat"] = function(cmd) ClearChatFrame(cmd); end
	SLASH_CANChat1 = "/cls";
	SLASH_CANChat2 = "/친";
--------------------------------------------------------------------------------
-- HelpFrame		GM문의
--------------------------------------------------------------------------------
	local function HelpFrame(cmd) ToggleHelpFrame() end
	SlashCmdList["CANGM"] = function(cmd) HelpFrame(cmd); end
	SLASH_CANGM1 = "/gm";
	SLASH_CANGM2 = "/지엠";
--------------------------------------------------------------------------------
-- LeaveParty		파티 탈퇴
--------------------------------------------------------------------------------
	SlashCmdList["CANParty"] = function(cmd) LeaveParty() end
	SLASH_CANParty1 = "/파탈";
--------------------------------------------------------------------------------
-- Calculator			계산기
--------------------------------------------------------------------------------
	function Calculator(msg)
		local origHandler = geterrorhandler()
		seterrorhandler(function (msg)
			print("잘못된 계산식입니다.")
		end)
		msg = "local answer="..msg..";if answer then SendChatMessage(\"계산: "..msg.."\",\"SAY\");SendChatMessage(\"결과: \"..answer,\"SAY\") end"
		RunScript(msg)
		seterrorhandler(origHandler)
	end
--------------------------------------------------------------------------------
-- Call Me			나를 불러주세요
--------------------------------------------------------------------------------
	local hook = {}
	local k = nil
	local Chat = ChatFrame1
	local Call_AddMessage = Chat.AddMessage
	local ChatAddMessage = function(self, text, ...)
		local text2 = text
		local found2 = false
		local name2, cont2, cha2
		local s2,e2 = string.find(text2, "(|Hplayer:.-|h%[)([^%s]+)(%])");
		if not s2 then return Call_AddMessage(self, text, ...)	end

		cha2 = string.sub(text2, 1, s2-1)
		name2 = string.sub(text2, s2, e2)
		cont2= string.sub(text2, e2+1)

		if (type(text2) == "string") and not string.find(name2, UnitName("player")) then
			if CANChat["CallMe"] ~= {} then
				for k2, v2 in pairs(CANChat.CallMe) do
					cont2, nMatch = gsub(cont2, v2, "|cFFFFCC00"..v2.."|r")
					if string.find(cont2,v2) then
						PlaySoundFile("Interface\\AddOns\\CAN_Chat\\Sound\\CallMe.mp3");
						local info = ChatTypeInfo["CHANNEL"];
						RaidNotice_AddMessage(RaidBossEmoteFrame,text,info);
					end
				end
			end
		end
		return Call_AddMessage(self, cha2..name2..cont2, ...)
	end

	for i=1,NUM_CHAT_WINDOWS do
		if i~=2 then			--전투 로그창
			k = _G['ChatFrame'..i];
			hook[k] = k.AddMessage;
			k.AddMessage = ChatAddMessage;
		end
	end

--------------------------------------------------------------------------------
-- Highlight && Except && Call Me		구문강조 && 구문제외
--------------------------------------------------------------------------------
function Highlight()

	PartyChat=getglobal("ChatFrame"..CANChat.ChatNo)
	local Orig_AddMessage = PartyChat.AddMessage
	local PartyChatAddMessage = function(self, text, ...)
		local text = text
		local found = false
		local name, cont, cha
		local s,e = string.find(text, "(|Hplayer:.-|h%[)([^%s]+)(%])");
		if not s then return Orig_AddMessage(self, text, ...) end

		cha = string.sub(text, 1, s-1)		-- 채널
		name = string.sub(text, s, e)		-- 이름
		cont = string.sub(text, e+1)		-- 구문

		if (type(text) == "string") then
			if CANChatDB["Except"] == 1 then
				for k, v in pairs(CANChatDB.ExceptData) do
					if string.find(cont,v) then return Orig_AddMessage(self,"") end
				end
			end
			if CANChatDB["Highlight"] == 1 then
				for k, v in pairs(CANChatDB.HighlightData) do
					cont, nMatch = gsub(cont, v, "|cFFFFCC00"..v.."|r")
					if string.find(cont,v) then
						found = true
					end
				end
			end
		end

		if IsControlKeyDown() then		 -- Ctrl키 누르면 채팅창에 글씨 안올라옴
			return Orig_AddMessage(self,"")
		else
			if found then
				return Orig_AddMessage(self, "|cFFFFCC00▶|r"..cha..name..cont, ...)
			else
				if CANChatDB["TempExcept"]==1 then
					return Orig_AddMessage(self,"")
				else
					return Orig_AddMessage(self, cha..name..cont, ...)
				end
			end
		end
	end

	PartyChat.AddMessage = PartyChatAddMessage

end

--------------------------------------------------------------------------------
-- Help			도움말
--------------------------------------------------------------------------------
	function Help()
		DEFAULT_CHAT_FRAME:AddMessage("    |cFFFFCC00 CAN_Chat 사용법입니다. |r"..currentVersion)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00ALT키 누르고 채팅창에서 아이디 클릭하시면 초대가 됩니다.|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Ctrl키 누르고 채팅창에서 아이디 클릭하시면 자동으로 귓말이 보내집니다.|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Ctrl키를 누르면 파티창에 글이 더이상 올라가지 않습니다.");
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/말머리 말머리내용 |c00FFFFFF : 말머리 기능|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/손글 귓말내용 |c00FFFFFF : Ctrl귓말 시 귓말내용 입력(기본: 클래스 손~), 변경 후 기본으로 초기화 |cFFFFCC00/손글|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/cls 또는 /친 |c00FFFFFF: 현재 모든 채팅창 내용 지우기(전투로그창 제외)|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/파탈 |c00FFFFFF : 파티탈퇴|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/지엠 or /gm |c00FFFFFF : GM문의창 열기  |r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/계산 |c00FFFFFF : 계산기       예) /계산 1+2 |r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 귓말 |c00FFFFFF : Ctrl귓말 기능 사용|중지|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 전투로그 |c00FFFFFF : 전투로그 왼쪽 정렬|오른쪽 정렬|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 입력창 |c00FFFFFF : 입력창 위|아래|r ")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 사라짐 |c00FFFFFF : 채팅글 1분후 사라짐 사용|중지|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 폰트강조 |c00FFFFFF : 폰트강조(OUTLINE) 기능 사용|중지|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 파티창 켬|끔 |c00FFFFFF : 파티프레임 수동으로 켜기|숨김|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 파티창 검색 |c00FFFFFF : 현재 마우스가 위치한 프레임의 번호를 알려줍니다.|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00/캔 |c00FFFFFF : 옵션창 열기|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00이 외에 기능은 명령어 대신 소스 수정 및 파일 이름을 바꿔 주시면 됩니다.|r")
	end
--------------------------------------------------------------------------------
-- Combatlo Justify		전투 로그 오른쪽 정렬
--------------------------------------------------------------------------------
	function CAN_Combatlog()
		if CANChat["Combat"] ==1 then
			ChatFrame2:SetJustifyH("RIGHT")
		end
	end
--------------------------------------------------------------------------------
-- EditBox			입력창 위로
--------------------------------------------------------------------------------
	function CAN_EditBox()
		for i = 1, NUM_CHAT_WINDOWS do
			local prefix = "ChatFrame" .. i
			local editBox = _G[prefix .. "EditBox"]

			editBox:SetAltArrowKeyMode(false)	-- 채팅창에 방향키

			if CANChat["Edit"] ==1 then
				editBox:ClearAllPoints()
				local frame = _G[prefix]
				editBox:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -5, i == 2 and 50 or 25);
				editBox:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -20, i == 2 and 50 or 25);
			end
		end
	end
--------------------------------------------------------------------------------
-- Fading			채팅창 메시지 사라짐(1분)
--------------------------------------------------------------------------------
	function CAN_Fade()
		for i = 1, NUM_CHAT_WINDOWS do
			local chatframe = _G["ChatFrame"..i];
			chatframe:SetFading(CANChat["Fade"]);
		end
	end
--------------------------------------------------------------------------------
-- OutLine			채팅창 메시지 폰트에 아웃라인 입히기
--------------------------------------------------------------------------------
	function CAN_Out()
		if CANChat["OutLine"]==1 then
			for i = 1, NUM_CHAT_WINDOWS do   -- 채팅 폰트에 아웃라인 입히기
				cf = _G["ChatFrame" .. i]
				cf:SetFont(GameFontNormalSmall:GetFont(), 13, "THINOUTLINE")
			end
		end
	end

--------------------------------------------------------------------------------
-- Commands
--------------------------------------------------------------------------------

	function CAN_InitSlash()	-- 명령어1
		if (CAN_SetHead == nil) then CAN_SetHead = "" end
		SlashCmdList["CANH"] = CAN_SetHead;
		SLASH_CANH1 = "/말머리";

		if (CAN_SetWhi == nil) then CAN_SetWhi = "" end
		SlashCmdList["CANWHI"] = CAN_SetWhi;
		SLASH_CANWHI1 = "/손글";

		if (CAN_Set == nil) then CAN_Set = "" end
		SlashCmdList["CAN"] = CAN_Set;
		SLASH_CAN1 = "/can";
		SLASH_CAN2 = "/캔";
		SLASH_CAN3 = "/zos";

		SlashCmdList["CALCULATOR"] = function(msg) Calculator(msg) end
		SLASH_CALCULATOR1="/계산";

		local PartyChat="ChatFrame"..CANChat.ChatNo
	end

--------------------------------------------------------------------------------
-- Neon Chat		입력창 테두리 해당 채널색에 맞게 변형
--------------------------------------------------------------------------------

	local CAN_Chat_Background = 0.7

	local chateditbox = CreateFrame("Button", nil, ChatFrame1EditBox)
	chateditbox:SetBackdrop(GameTooltip:GetBackdrop())
	chateditbox:SetBackdropColor(0,0,0,0)
	chateditbox:SetBackdropBorderColor(0,0,0,0)

	hooksecurefunc("ChatEdit_UpdateHeader", function(editbox)
		if ACTIVE_CHAT_EDIT_BOX then
			local type = editbox:GetAttribute("chatType")
			local frame = string.match(ACTIVE_CHAT_EDIT_BOX:GetName(), "^(.-)EditBox$")

			if ( type == "CHANNEL" ) then
				local id = GetChannelName(editbox:GetAttribute("channelTarget"))
				if id == 0 then
					chateditbox:SetBackdropColor(ChatTypeInfo[type].r/10,ChatTypeInfo[type].g/10,ChatTypeInfo[type].b/10, CAN_Chat_Background)
				else
					chateditbox:SetBackdropColor(ChatTypeInfo[type].r/10,ChatTypeInfo[type].g/10,ChatTypeInfo[type].b/10, CAN_Chat_Background)
				end
			else
				chateditbox:SetBackdropColor(ChatTypeInfo[type].r/10,ChatTypeInfo[type].g/10,ChatTypeInfo[type].b/10, CAN_Chat_Background)
			end

			chateditbox:SetParent(ACTIVE_CHAT_EDIT_BOX)
			chateditbox:ClearAllPoints()
			chateditbox:SetPoint("TOPLEFT",ACTIVE_CHAT_EDIT_BOX:GetName().."FocusLeft","TOPLEFT",4,-3)
			chateditbox:SetPoint("BOTTOMRIGHT",ACTIVE_CHAT_EDIT_BOX:GetName().."FocusRight","BOTTOMRIGHT",-4,3)
			chateditbox:SetFrameLevel(_G[frame.."EditBox"]:GetFrameLevel()-1)
		else
			chateditbox:SetBackdropColor(0,0,0,0)
		end

		for chatframe=1,CURRENT_CHAT_FRAME_ID do
			for i=6,8 do select(i, _G["ChatFrame"..chatframe.."EditBox"]:GetRegions()):Hide() end
		end
	end)
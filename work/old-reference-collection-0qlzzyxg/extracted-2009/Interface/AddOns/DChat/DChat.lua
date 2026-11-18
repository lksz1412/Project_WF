	---------------------
	-- LinK Tooltip --
	---------------------
--[[
	local orig1, orig2 = {}, {}
	local GameTooltip = GameTooltip
	local linktypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}
	local function OnHyperlinkEnter(frame, link, ...)
		local linktype = link:match("^([^:]+)")
		if linktype and linktypes[linktype] then
			GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
			GameTooltip:SetHyperlink(link)
			GameTooltip:Show()
		end
		if orig1[frame] then return orig1[frame](frame, link, ...) end
	end
	local function OnHyperlinkLeave(frame, ...)
		GameTooltip:Hide()
		if orig2[frame] then return orig2[frame](frame, ...) end
	end
	local _G = getfenv(0)
	for i=1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		orig1[frame] = frame:GetScript("OnHyperlinkEnter")
		frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
		orig2[frame] = frame:GetScript("OnHyperlinkLeave")
		frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
	end
]]
	---------------------
	-- channelsformats --
	---------------------
--[[
	_G.CHAT_GUILD_GET =                 "길 * %s:\32"
	_G.CHAT_RAID_GET =                  "공 * %s:\32"
	_G.CHAT_PARTY_GET =                 "파 * %s:\32"
	_G.CHAT_RAID_WARNING_GET =          "공경 * %s:\32"
	_G.CHAT_RAID_LEADER_GET =           "공장 * %s:\32"
	_G.CHAT_OFFICER_GET =               "관 * %s:\32"
	_G.CHAT_BATTLEGROUND_GET =          "전 * %s:\32"
	_G.CHAT_BATTLEGROUND_LEADER_GET =   "전지 * %s:\32"
	_G.CHAT_SAY_GET =                   "%s:\32"
	_G.CHAT_YELL_GET =                  "%s:\32"
	_G.CHAT_WHISPER_GET =               "%s:\32에게서 귓 *"
	_G.CHAT_WHISPER_INFORM_GET =        "%s:\32에게로 귓 *"
	_G.CHAT_FLAG_AFK =                  "[자비] "
	_G.CHAT_FLAG_DND =                  "[다용] "
	_G.CHAT_FLAG_GM =                   "[GM] "

	------------------------
	-- short channelnames --
	------------------------

	local str = "(%d. %2$.3s) %s"
	--local str = "(%d) %3$s"
	local channel = function(...)
	return str:format(...)
	end

	--local type = type
	local _AddMessage = ChatFrame1.AddMessage
	local AddMessage = function(self, text,...)
	if(type(text) == "string") then
	    text = text:gsub("|Hplayer:([^:]+):(%d+)|h%[(.-)%]|h", "|Hplayer:%1:%2|h%3|h")
	    text = text:gsub("%[(%d+)%. (.+)%].+(|Hplayer.+)", channel)
	end
	return _AddMessage(self, text, ...)
	end
]]--
	--------------------- 
	-- channel stickys --
	---------------------

	ChatTypeInfo['SAY'].sticky          = 1
	ChatTypeInfo['YELL'].sticky         = 0
	ChatTypeInfo['PARTY'].sticky        = 1
	ChatTypeInfo['GUILD'].sticky        = 1
	ChatTypeInfo['OFFICER'].sticky      = 1
	ChatTypeInfo['RAID'].sticky         = 1
	ChatTypeInfo['RAID_WARNING'].sticky = 1
	ChatTypeInfo['BATTLEGROUND'].sticky = 1
	ChatTypeInfo['CHANNEL'].sticky = 1


	---------------------
	-- alt Click --
	---------------------

	hooksecurefunc("SetItemRef", function(link)
	    if IsAltKeyDown() and link then
		local name = link:match("^player:([^:]+).*$")
		if name then InviteUnit(name) ChatFrameEditBox:Hide() end
	    end
	end)

	--------------------- 
	-- Font Size --
	---------------------

	CHAT_FONT_HEIGHTS = {
	[1] = 7,
	[2] = 8,
	[3] = 9,
	[4] = 10,
	[5] = 11,
	[6] = 12,
	[7] = 13,
	[8] = 14,
	[9] = 15,
	[10] = 16,
	[11] = 17,
	[12] = 18,
	[13] = 19,
	[14] = 20,
	[15] = 21,
	[16] = 22,
	[17] = 24,
	[18] = 32
	}

	-----------------
	-- mousescroll --
	-----------------

	local function hide (h)
		h:SetScript('OnShow', h.Hide);
		h:Hide();
	end

	local function show(h)
		h:SetScript('OnShow', h.Show);
		h:Show();
	end

	function bottom()
		this:GetParent():ScrollToBottom();
		hide(getglobal(this:GetParent():GetName()..'BottomButton'));
	end

	function scroll(chatframe, y)
		if ( y > 0 ) then
			if IsShiftKeyDown() then
				 chatframe:ScrollToTop();
			else
				 chatframe:ScrollUp();
			end
			if chatframe:AtBottom() then
				hide(getglobal(chatframe:GetName()..'BottomButton'));
			else
			show(getglobal(chatframe:GetName()..'BottomButton'));
			end
			elseif (y < 0 ) then
			if IsShiftKeyDown() then
				 chatframe:ScrollToBottom();
			else
				 chatframe:ScrollDown();
			end
			if chatframe:AtBottom() then
				hide(getglobal(chatframe:GetName()..'BottomButton'));
			end
		end
	end

	----------------------
	-- hide the buttons --
	----------------------

	hide(ChatFrameMenuButton);

	for i=1,NUM_CHAT_WINDOWS do

	local x = getfenv(0);
	local iBtmButton = x['ChatFrame'..i..'BottomButton'];
	local iFrame = x['ChatFrame'..i];
	hide(x['ChatFrame'..i..'UpButton']);
	hide(x['ChatFrame'..i..'DownButton']);
	iBtmButton:ClearAllPoints();
	iBtmButton:SetPoint("RIGHT", iFrame, "RIGHT", 0, 0);
	iBtmButton:SetPoint("LEFT", iFrame, "RIGHT", -32, 0);
	iBtmButton:SetPoint("TOP", iFrame, "BOTTOM", 0, 28);
	iBtmButton:SetPoint("BOTTOM", iFrame, "BOTTOM", 0, -4);
	hide(iBtmButton);

	-- enable mouse wheel in chatframes
	local c = x['ChatFrame'..i];
	c:EnableMouseWheel(true);
	c:SetScript('OnMouseWheel', scroll);

	-- display chatframe buttombutton when not in bottomline
	local cb = x['ChatFrame'..i..'BottomButton'];
	cb:SetScript("OnClick",bottom);

	end  

	-----------------
	-- EditBox Top Position --
	-----------------

	ChatFrameEditBox:ClearAllPoints()
	ChatFrameEditBox:SetPoint("BOTTOMLEFT",  ChatFrame1, "TOPLEFT", -5, 0)
	ChatFrameEditBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", -15, 0)

	------------------
	-- Allow Arrow Key --
	------------------
	ChatFrameEditBox:SetAltArrowKeyMode(false)

	--------------------
	-- Hide EditBox Border --
	--------------------
	select(6, ChatFrameEditBox:GetRegions()):Hide()
	select(7, ChatFrameEditBox:GetRegions()):Hide()
	select(8, ChatFrameEditBox:GetRegions()):Hide()

	  
	-----------------
	-- tell target --
	-----------------

	local function tellTarget(s)
	if not UnitExists('target') and UnitName('target') and UnitIsPlayer('target') and GetDefaultLanguage('player') == GetDefaultLanguage('target') or not (s and s:len()>0) then
	    return
	end
	local name, realm = UnitName('target')
	if realm and realm ~= GetRealmName() then
	    name = ('%s-%s'):format(name, realm)
	end
	SendChatMessage(s, 'WHISPER', nil, name)
	end

	SlashCmdList['TELLTARGET'] = tellTarget
	SLASH_TELLTARGET1 = '/tt'

	---------------------
	-- Neon Chat --
	---------------------

	local ebf = CreateFrame("Button", nil, ChatFrameEditBox)
	ebf:SetBackdrop({
	  bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
	  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
	  tile = true, tileSize = 16, 
	  edgeSize = 15, 
	  insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	ebf:SetAllPoints()
	ebf:SetPoint("TOPLEFT", "ChatFrameEditBoxLeft", 2, -2)
	ebf:SetPoint("BOTTOMRIGHT", "ChatFrameEditBoxRight", -2, 2)
	ebf:SetFrameLevel(1)
	ebf:Show()

	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = DEFAULT_CHAT_FRAME.editBox:GetAttribute("chatType")
		if ( type == "CHANNEL" ) then
			local id = GetChannelName(DEFAULT_CHAT_FRAME.editBox:GetAttribute("channelTarget"))
			if id == 0 then
				ebf:SetBackdropBorderColor(0,0,0, CAN_Chat_Border)
			else
				ebf:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b, CAN_Chat_Border)
			end
		else
			ebf:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b, CAN_Chat_Border)
		end
		ebf:SetBackdropColor(ChatTypeInfo[type].r/10,ChatTypeInfo[type].g/10,ChatTypeInfo[type].b/10, CAN_Chat_Background)
	  end
	)

	---------------
	-- URL copy --
	---------------

	UrlCopy = {}
	URL_STYLE = " |cffE599FF|Hurl:%s|h%s|h|r "  

	local patterns = {
	{ " www%.([_A-Za-z0-9-]+)%.([_A-Za-z0-9-%.&/]+)%s?", "www.%1.%2"},
	{ " (%a+)://(%S+)%s?", "%1://%2"},
	{ " ([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", "%1@%2%3%4"},
	{ " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?", "%1.%2.%3.%4:%5"},
	{ " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", "%1.%2.%3.%4" },
	{ " ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%s?", "%1.%2.%3"},
	{ " ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%:([_0-9-]+)%s?", "%1.%2.%3:%4"},
	{ " ([_A-Za-z0-9-]+)%.(%a%a%a)%s?", "%1.%2"},
	}

	local currentLink
	local orig = {}
	local origItemRef = nil

	local function addMessage(frame, text, ...)
	if type(text) == "string" and text:len() > 7 then
	    for i, v in ipairs(patterns) do
		text = text:gsub(v[1], URL_STYLE:format(v[2], v[2]))
	    end
	end
	return orig[frame](frame, text, ...)
	end

	local function setItemRef(link, text, button)
	if link:sub(1, 3) == "url" then
	    currentLink = link:sub(5)
	    StaticPopup_Show("UrlCopyDialog")
	    return
	end
	return origItemRef(link, text, button)
	end

	function UrlCopy:Enable()
	for i = 1, NUM_CHAT_WINDOWS do
	    local c = _G["ChatFrame"..i]
	    orig[c] = c.AddMessage
	    c.AddMessage = addMessage
	end
	origItemRef = _G.SetItemRef
	_G.SetItemRef = setItemRef

	StaticPopupDialogs["UrlCopyDialog"] = {
	    text = "URL 복사 (Ctrl+C)",
	    button2 = TEXT(CLOSE),
	    hasEditBox = 1,
	    hasWideEditBox = 1,
	    showAlert = 1,
	    OnShow = function()
		local editBox = _G[this:GetName().."WideEditBox"]
		if editBox then
		    editBox:SetText(currentLink)
		    editBox:SetFocus()
		    editBox:HighlightText(0)
		end
		local button = _G[this:GetName().."Button2"]
		if button then
		    button:ClearAllPoints()
		    button:SetWidth(200)
		    button:SetWidth(200)
		    button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
		end
		local icon = _G[this:GetName().."AlertIcon"]
		if icon then
		    icon:Hide()
		end
	    end,
	    EditBoxOnEscapePressed = function() this:GetParent():Hide() end,
	    timeout = 0,
	    whileDead = 1,
	    hideOnEscape = 1,
	}
	end

	UrlCopy:Enable()
scmChannelnames = AceLibrary("AceAddon-2.0"):new("AceHook-2.1")

local _G = getfenv(0)

SCM_CHANNELNAMES_REGEXPS = {
	["%<자리비움%>"] = "|CFFCCCCCC<비움>|R",
	["%<다른용무중%>"] = "|CFFCCCCCC<용무중>|R",
	["%[길드%]"] = "[G]",
	["%[파티%]"] = "[P]",
	["%[공격대%]"] = "[R]",
	["%[공격대장%]"] = "[|cffff3399RL|r]",
	["%[공격대 경보%]"] = "|cffff0000[|rRW|cffff0000]|r",
	["%[전장%]"] = "|cffff3399[|rBG|cffff3399]|r",
	["%[전장 지휘관%]"] = "|cffff0000[|rBGL|cffff0000]|r",
}

-- for URL copy -
SCM_UrlPatterns = {
	-- www.X.Y url
	"((%a+)://(%S+))",
	"(www%.[_A-Za-z0-9-]+%.%S+)",
	-- X@X.Y url (---> email)
	"([_A-Za-z0-9-%.]+@[_A-Za-z0-9-]+%.[_A-Za-z0-9-%.]+)",
	-- XXX.YYY.ZZZ.WWW:VVVV url (IP of ts server for example)
	"(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)",
	-- XXX.YYY.ZZZ.WWW url (---> IP)
	"(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)",
	-- X.Y.Z url
	"([_A-Za-z0-9-]+%.[_A-Za-z0-9-]+%.%S+)",
	-- X.Y.Z:WWWW url  (ts server for example)
	"([_A-Za-z0-9-]+%.[_A-Za-z0-9-]+%.%S+%:[_0-9-]+)",
}

function scmChannelnames:OnEnable()

	for i = 1, 7 do
		self:Hook(_G["ChatFrame"..i], "AddMessage", true)
	end
end

function scmChannelnames:AddMessage(frame, text, r, g, b, id)

	if type(text) == "string" then
		for k,v in pairs(SCM_UrlPatterns) do
			if string.find(text, v) then
				text = string.gsub(text, v, "|cffffff00[|Hurl:".."%1".."|h".."%1".."|h]|r");
				break
			end
		end
		for k, v in pairs(SCM_CHANNELNAMES_REGEXPS) do
			text = text:gsub(k, v)
		end
	end

	return self.hooks[frame].AddMessage(frame, text, r, g, b, id)
end


--- Alt 초대 추가 부분 -----
function SCM_SetItemRef(link, text, button)
	if ( strsub(link, 1, 6) == "player" ) then
		local namelink = strsub(link, 8);
		local name, lineid = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then
			name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3");
			name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2");

			if ( button == "RightButton" ) then
				FriendsFrame_ShowDropdown(name, 1, lineid);
				return;
			elseif ( IsAltKeyDown() ) then 
				InviteUnit(name); 				
				return;
			elseif ( IsShiftKeyDown() ) then
				SendWho("n-"..name); 
				return;
			end
		ChatFrame_SendTell(name);
		end
		return;
	end

	if (strsub(link, 1, 3) == "url") then
		link = strsub(link, 5);

		getglobal( "scmHyperlinkerEditBox" ):SetText( link );
		scmHyperlinkerForm:Show();

--		if (not ChatFrameEditBox:IsShown()) then
--			ChatFrame_OpenChat(link, DEFAULT_CHAT_FRAME);
--		else
--			ChatFrameEditBox:Insert(link);
--		end
--		return;
	else 
		ItemRefTooltip:SetHyperlink(link);
	end

	if ( IsControlKeyDown() ) then
		DressUpItemLink(text);
	elseif ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(text);
		end
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
	end
end

local lOriginal_SetItemRef = SetItemRef;
SetItemRef = SCM_SetItemRef;

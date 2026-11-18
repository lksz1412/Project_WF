local gsub = _G.string.gsub
local find = _G.string.find

local urlStyle = "|cffffffff|Hurl:%1|h[%1]|h|r"
local urlPatterns = {
	"(http://%S+)", -- http://Y
	"(www%.%S+)", -- www.X~
	"(%d+%.%d+%.%d+%.%d+:?%d*)", -- 111.222.333.444, 111.222.333.444:56789
	"(%S+://%S+)", -- X://Y
	"(magnet%:%?xt%=urn%:btih%:%S+)",-- magnet:?xt=urn:btih:  for torrent
	"(%S+@%S+%.%S+)", -- X@Y.Z email
}

local messageTypes = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_RAID",
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BATTLEGROUND_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_CONVERSATION",
}

local urlFilter = function(self, event, text, ...)
	for _, pattern in ipairs(urlPatterns) do
		local result, matches = gsub(text, pattern, urlStyle)

		if matches > 0 then
			return false, result, ...
		end
	end
end

for _, event in ipairs(messageTypes) do
	ChatFrame_AddMessageEventFilter(event, urlFilter)
end

local origSetItemRef = _G.SetItemRef
local currentLink
local SetItemRefHook = function(link, text, button)
	if link:sub(0, 3) == "url" then
		currentLink = link:sub(5)
		StaticPopup_Show("UrlCopyDialog")
		return
	end

	return origSetItemRef(link, text, button)
end

SetItemRef = SetItemRefHook

StaticPopupDialogs["UrlCopyDialog"] = {
	text = "URL 복사",
	button2 = TEXT(CLOSE),
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		local name = self:GetName()
		local editBox = _G[name .. "EditBox"]
		if editBox then
			editBox:SetText(currentLink)
			editBox:SetFocus()
			editBox:HighlightText(0)
		end

		local button = _G[name .. "Button2"]
		if button then
			button:ClearAllPoints()
			button:SetWidth(200)
			button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
		end
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
}
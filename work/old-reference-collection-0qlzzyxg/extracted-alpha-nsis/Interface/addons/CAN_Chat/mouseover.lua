local function hook(k,v,f) k[k:GetScript(v) and "HookScript" or "SetScript"](k,v,f) end
local function enter(self, link)
	local linktype = link:match("^([^:]+)")
	if linktype and linktype ~= "enchant" and linktype ~= "trade" then
	    GameTooltip:SetOwner(self, "anchor_cursor")
	    pcall(GameTooltip.SetHyperlink, GameTooltip, link)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
    hook(_G["ChatFrame"..i], "OnHyperlinkEnter", enter)
    hook(_G["ChatFrame"..i], "OnHyperlinkLeave", function() GameTooltip:Hide() end)
end
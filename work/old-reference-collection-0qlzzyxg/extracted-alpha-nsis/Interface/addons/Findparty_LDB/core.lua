local findparty_msg_kr = "파티 찾기 도우미"
local tooltip_msg_kr = {
	"파티 찾기 도우미 v"..GetAddOnMetadata("FindParty", "version"),
	"\n",
	"\n|cff00ff00왼쪽 클릭: |r파티 찾기 도우미 열기",
	"\n|cff00ff00오른쪽 클릭: |r설정",
	"\n|cff00ff00Ctrl + 클릭: |r광고 시작/정지",
	"\n|cff00ff00Shift + 클릭: |r애드온 작동/작동정지",
	"\n",
	"\n현재 상태:"
}
local activated_msg_kr = " 작동중"
local deactivated_msg_kr = " 작동정지"
local announcing_msg_kr = " 광고중"

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("FindParty", 
{
	type = "launcher",
	text = findparty_msg_kr,
	icon = "Interface\\Addons\\Findparty_LDB\\SIM-Icon",
	OnClick = function(self, button)
		FP_IconClicked(self, button)
	end,
	OnTooltipShow = function(self)
		local msg = ""
		for k,v in ipairs(tooltip_msg_kr) do
			msg = msg..v
		end
		if FP_Options.activated then
			msg = msg..activated_msg_kr
		else
			msg = msg..deactivated_msg_kr
		end
		if FP_IsAnnoucing() then
			msg = msg..announcing_msg_kr
		end
		GameTooltip:ClearLines()
		GameTooltip:AddLine(msg)
		GameTooltip:Show()
	end,

})

if FP_Minimap_Button then FP_Minimap_Button:Hide() end

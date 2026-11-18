function GetMinimapShape() return "SQUARE" end

local addon = CreateFrame"Frame"

local frames = {
	MinimapZoomIn,
	MinimapZoomOut,
	MinimapBorderTop,
	MinimapToggleButton,
	MiniMapWorldMapButton,
	MiniMapVoiceChatFrame,
	MinimapNorthTag,
	MinimapBorder,
	GameTimeFrame,
}

addon:SetScript("OnEvent", function()

	if(event=="PLAYER_LOGIN") then

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(self, z)
		local c = Minimap:GetZoom()
		if(z > 0 and c < 5) then
			Minimap:SetZoom(c + 1)
		elseif(z < 0 and c > 0) then
			Minimap:SetZoom(c - 1)
		end
	end)

	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			_G.GameTimeFrame:Click()
		elseif btn == "LeftButton" then
			_G.Minimap_OnClick(self)
		end
	end)

	Minimap:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -510, 30)

  	MiniMapMailBorder:Hide()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("BOTTOMRIGHT", 2, -5)
	MiniMapMailIcon:SetTexture"Interface\\AddOns\\dMiniMap\\mail"

	MinimapZoneText:SetParent(Minimap)
	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetPoint("TOP", Minimap, 0, 17)
	MinimapZoneTextButton:Hide()

	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButtonBorder:Hide()
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("TOPLEFT", -5, 4)

	MiniMapBattlefieldBorder:Hide()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("LEFT", -3, 0)

	Minimap:SetMaskTexture"Interface\\AddOns\\dMiniMap\\mask"
	Minimap:SetScale(1.05)

	for _, frame in pairs(frames) do
		frame:Hide()
		frame.Show = function() end
	end
	end
end)

addon:RegisterEvent"PLAYER_LOGIN"
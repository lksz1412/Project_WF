-- Addon = CreateFrame("Frame")

--------------------------------------------------------------------
-- MINIMAP ROUND TO SQUARE AND MINIMAP SETTING
--------------------------------------------------------------------

function GetMinimapShape() return "SQUARE" end

local index = GetCurrentResolution();
local resolution = select(index, GetScreenResolutions());
local DevilUIMinimap = CreateFrame("Frame")
	DevilUIMinimap:RegisterEvent("PLAYER_LOGIN")
	DevilUIMinimap:RegisterEvent("PLAYER_ENTERING_WORLD")
	DevilUIMinimap:RegisterEvent("ADDON_LOADED")

	if resolution == "720x576"
		or resolution == "800x600"
		or resolution == "1024x768"
		or resolution == "1152x864"
		or resolution == "1280x960"
		or resolution == "1280x1024"
		or resolution == "1400x1050"
		or resolution == "1600x1200"
		or resolution == "1680x1200" then
		MinimapCluster:SetPoint("BOTTOM", "UIParent", "BOTTOM", 201, 20)
		Minimap:ClearAllPoints()
		Minimap:SetPoint("BOTTOM", "UIParent", "BOTTOM", 201, 20)
		Minimap:SetScale(0.95)
		PetBattleFrame:SetPoint("BOTTOM", 0, 215)
		PetBattleFrame:SetScale(0.8)
	else
		MinimapCluster:SetPoint("BOTTOM", "UIParent", "BOTTOM", 355, 20)
		Minimap:ClearAllPoints()
		Minimap:SetPoint("BOTTOM", "UIParent", "BOTTOM", 355, 20)
		Minimap:SetScale(1)
		PetBattleFrame:SetPoint("BOTTOM", 0, 225)
		PetBattleFrame:SetScale(0.8)
	end

Minimap:SetFrameStrata("MEDIUM")
MinimapCluster:SetFrameStrata("LOW")
--------------------------------------------------------------------
-- Hide Border
--------------------------------------------------------------------

MinimapBorder:Hide()
MinimapBorderTop:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MiniMapVoiceChatFrame:Hide()
GameTimeFrame:Hide()
MiniMapWorldMapButton:Hide()
MinimapNorthTag:Hide()

MiniMapMailBorder:Hide()
MiniMapMailFrame:SetParent(Minimap)
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT", 5, -9)
MiniMapMailIcon:SetTexture"Interface\\AddOns\\!DevilUI\\media\\mail.tga"

MinimapZoneText:SetParent(Minimap)
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint("TOP", Minimap, 0, 17)
MinimapZoneTextButton:Hide()

GarrisonLandingPageMinimapButton:Hide()
GarrisonLandingPageMinimapButton:SetParent(Minimap)
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", 26, -26)

MiniMapTrackingBackground:Hide()
MiniMapTrackingButtonBorder:Hide()
MiniMapTracking:SetParent(Minimap)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPLEFT", -5, 4)

QueueStatusMinimapButton:Hide()
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("TOP", Minimap, "TOP", 0, 4)

GuildInstanceDifficulty:Hide()
GuildInstanceDifficulty:SetParent(Minimap)
GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetScale(.9)
GuildInstanceDifficulty:SetPoint("TOPRIGHT", 16, 10)

MiniMapInstanceDifficulty:Hide()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", 16, 10)

WorldStateAlwaysUpFrame:ClearAllPoints()
WorldStateAlwaysUpFrame:SetPoint("TOP", 0, -80)

Boss1TargetFrame:ClearAllPoints()
Boss1TargetFrame:SetPoint("TOPRIGHT", 66, -260)
Boss1TargetFrame:SetScale(0.8)
Boss2TargetFrame:SetScale(0.8)
Boss3TargetFrame:SetScale(0.8)
Boss1TargetFrame.SetPoint = function() end 
Boss1TargetFrame.SetAllPoints = function() end

PlayerPowerBarAlt:ClearAllPoints()
PlayerPowerBarAlt:SetPoint("BOTTOM", 0, 250)
PlayerPowerBarAlt.SetPoint = function() end 
--[[
MiniMapLFGFrameBorder:Hide()
MiniMapLFGFrame:ClearAllPoints()
MiniMapLFGFrame:SetPoint("TOP", Minimap, "TOP", 0, 4)
]]
----------------------------------------------------------------------------------------
-- capture bar update position
----------------------------------------------------------------------------------------

local function captureupdate()
	local nexty = 0
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		local cb = _G["WorldStateCaptureBar"..i]
		if cb and cb:IsShown() then
			cb:ClearAllPoints()
			cb:SetPoint("TOP", UIParent, "TOP", 0, -120)
			nexty = nexty + cb:GetHeight()
		end
	end
end
--hooksecurefunc("WorldStateAlwaysUpFrame_Update", captureupdate)

----------------------------------------------------------------------------------------
-- Enable mouse scrolling & GameTimeFrame
----------------------------------------------------------------------------------------

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)

Minimap:SetScript("OnMouseUp", function(self, btn)
	if btn == "RightButton" then
		_G.GameTimeFrame:Click()
	elseif btn == "LeftButton" then
		_G.Minimap_OnClick(self)
	end
end)

----------------------------------------------------------------------------------------
-- Set Square Map Mask
----------------------------------------------------------------------------------------

Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')










	

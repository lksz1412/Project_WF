Addon = CreateFrame("Frame")

--------------------------------------------------------------------
-- MINIMAP ROUND TO SQUARE AND MINIMAP SETTING
--------------------------------------------------------------------

function GetMinimapShape() return "SQUARE" end

Minimap:SetScale(1.1)
Minimap:SetFrameStrata("LOW")
MinimapCluster:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -10, -20)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -10, -20)

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

MiniMapTrackingBackground:Hide()
MiniMapTrackingButtonBorder:Hide()
MiniMapTracking:SetParent(Minimap)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPLEFT", -5, 4)

GarrisonLandingPageMinimapButton:Hide()
GarrisonLandingPageMinimapButton:SetParent(Minimap)
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", 12, -46)

QueueStatusMinimapButton:Hide()
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("LEFT", -3, 0)

MiniMapInstanceDifficulty:Hide()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", 16, 10)

WorldStateAlwaysUpFrame:ClearAllPoints()
WorldStateAlwaysUpFrame:SetPoint("TOP", 0, -80)

Boss1TargetFrame:ClearAllPoints()
Boss1TargetFrame:SetPoint("TOPLEFT", 386, -220)
Boss1TargetFrame:SetScale(0.9)
Boss2TargetFrame:SetPoint("TOPLEFT", 386, -310)
Boss2TargetFrame:SetScale(0.9)
Boss3TargetFrame:SetPoint("TOPLEFT", 386, -400)
Boss3TargetFrame:SetScale(0.9)
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
			cb:SetPoint("TOP", Minimap, "BOTTOM", -4, -12)
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










	

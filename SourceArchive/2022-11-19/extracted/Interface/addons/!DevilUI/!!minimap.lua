--Addon = CreateFrame("Frame")

--------------------------------------------------------------------
-- MINIMAP ROUND TO SQUARE AND MINIMAP SETTING
--------------------------------------------------------------------

function GetMinimapShape() return "ROUND" end

Minimap:SetScale(1.05)
Minimap:SetFrameStrata("HIGH")
MinimapCluster:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -6, -36)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -6, -36)

----------------------------------------------------------------------------------------
-- Minimap Move and Click Setting
----------------------------------------------------------------------------------------

Minimap:SetMovable(true)
Minimap:SetUserPlaced(true)
Minimap:SetScript("OnMouseDown", function()
    if (IsShiftKeyDown()) then
        Minimap:ClearAllPoints()
        Minimap:StartMoving()
    end
end)

Minimap:SetScript('OnMouseUp', function(self, button)
Minimap:StopMovingOrSizing()
    if (button == 'RightButton') then
        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * 0.7), -3)
    elseif (button == 'MiddleButton') then
        ToggleCalendar()
    else
        Minimap_OnClick(self)
    end
end)

--------------------------------------------------------------------
-- Hide Border
--------------------------------------------------------------------

PetBattleFrame:SetPoint("BOTTOM", 0, 28)
PetBattleFrame:SetScale(0.8)

MinimapBorder:Hide()
MinimapBorderTop:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MiniMapVoiceChatFrame:Hide()
GameTimeFrame:Hide()
MiniMapWorldMapButton:Hide()
MinimapNorthTag:Hide()

--MiniMapMailBorder:Hide()
MiniMapMailFrame:SetParent(Minimap)
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPRIGHT", 5, 4)
--MiniMapMailIcon:SetTexture"Interface\\AddOns\\DevilUI\\mail"

MinimapZoneText:SetParent(Minimap)
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint("TOP", Minimap, 0, 17)
MinimapZoneTextButton:Hide()

MiniMapTrackingBackground:Hide()
--MiniMapTrackingButtonBorder:Hide()
MiniMapTracking:SetParent(Minimap)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPLEFT", -5, 4)

--QueueStatusMinimapButton:Hide()
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("LEFT", -28, 0)

MiniMapInstanceDifficulty:Hide()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", 16, 10)

WorldStateAlwaysUpFrame:ClearAllPoints()
WorldStateAlwaysUpFrame:SetPoint("TOP", 0, -80)

Boss1TargetFrame:ClearAllPoints()
Boss1TargetFrame:SetPoint("TOPRIGHT", 66, -256)
Boss1TargetFrame:SetScale(0.8)
Boss2TargetFrame:SetScale(0.8)
Boss3TargetFrame:SetScale(0.8)
Boss1TargetFrame.SetPoint = function() end 
Boss1TargetFrame.SetAllPoints = function() end

PlayerPowerBarAlt:ClearAllPoints()
PlayerPowerBarAlt:SetPoint("BOTTOM", 0, 250)
PlayerPowerBarAlt.SetPoint = function() end 
--[[
MiniMapLFGFrame:SetParent(Minimap)
MiniMapLFGFrame:ClearAllPoints()
MiniMapLFGFrame:SetPoint("LEFT", -28, 0)
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
			cb:SetPoint("TOP", Minimap, "BOTTOM", -10, -18)
			nexty = nexty + cb:GetHeight()
		end
	end
end
--hooksecurefunc("WorldStateAlwaysUpFrame_Update", captureupdate)

----------------------------------------------------------------------------------------
-- Enable mouse scrolling 
----------------------------------------------------------------------------------------

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)

----------------------------------------------------------------------------------------
-- Set Square Map Mask
----------------------------------------------------------------------------------------

--Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')










	

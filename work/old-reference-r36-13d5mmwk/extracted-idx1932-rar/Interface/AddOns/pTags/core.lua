local addon = CreateFrame("Frame", nil, UIParent)
local tex = "Interface\\AddOns\\pTags\\texture"
local time = 0

local function IsNamePlateFrame(frame)
	if frame:GetName() then
		return false
	end

	local overlayRegion = frame:GetRegions()
	if not overlayRegion or overlayRegion:GetObjectType() ~= "Texture" or overlayRegion:GetTexture() ~= "Interface\\Tooltips\\Nameplate-Border" then
		return false
	end
	return true
end

local frame
function addon:onUpdate(elapsed)
	time = time + elapsed

	if time > 1 then
		time = 0
		for i = 1, select("#", WorldFrame:GetChildren()) do
			frame = select(i, WorldFrame:GetChildren())

			if not frame.background and IsNamePlateFrame(frame) then 
				addon:setupNamePlate(frame)
			end
		end  
	end
end

local healthBar, castBar
local overlayRegion, highlightRegion, nameTextRegion, bossIconRegion, levelTextRegion, raidIconRegion
function addon:setupNamePlate(frame)
	healthBar, castBar = frame:GetChildren()
	overlayRegion, _, _, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion = frame:GetRegions()

	overlayRegion:Hide()
	bossIconRegion:Hide()
    highlightRegion:Hide()
	highlightRegion.Show = function() end

	nameTextRegion:ClearAllPoints()
	nameTextRegion:SetPoint("LEFT", healthBar, "LEFT", 2, 11)
	nameTextRegion:SetFont(NAMEPLATE_FONT, 9)

	levelTextRegion:ClearAllPoints()
	levelTextRegion:SetPoint("RIGHT", healthBar, "RIGHT", 11, 0)
	levelTextRegion:SetFont(NAMEPLATE_FONT, 9)

	healthBar:SetStatusBarTexture(tex)
	healthBar:SetHeight(12)

	background = healthBar:CreateTexture(nil, "BORDER")
	background:SetPoint("TOP", healthBar, 0, 1)
	background:SetPoint("BOTTOM", healthBar, 0, -1)
	background:SetPoint("LEFT", healthBar, -1, 0)
	background:SetPoint("RIGHT", healthBar, 1, 0)
	background:SetTexture(tex)
	background:SetVertexColor(.1, .1, .1, .6)
  
	frame.background = background
end

addon:SetScript("OnUpdate", addon.onUpdate)
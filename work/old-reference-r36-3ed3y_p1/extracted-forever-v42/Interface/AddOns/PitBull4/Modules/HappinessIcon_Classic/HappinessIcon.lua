if UnitClassBase("player") ~= "HUNTER" then
	return
end

local PitBull4 = _G.PitBull4
local L = PitBull4.L
local SafeNumber = PitBull4.Utils.SafeNumber

local function get_happiness()
	local getter = _G.GetPetHappiness
	if type(getter) ~= "function" then
		getter = _G.C_PetInfo and _G.C_PetInfo.GetPetHappiness
	end
	if type(getter) ~= "function" then return end
	local happiness, damage_percentage = getter()
	happiness = SafeNumber(happiness)
	if happiness ~= 1 and happiness ~= 2 and happiness ~= 3 then return end
	return happiness, SafeNumber(damage_percentage)
end

local PitBull4_HappinessIcon = PitBull4:NewModule("HappinessIcon")

PitBull4_HappinessIcon:SetModuleType("indicator")
PitBull4_HappinessIcon:SetName(L["Happiness icon"])
PitBull4_HappinessIcon:SetDescription(L["Show an icon on the pet frame to indicate its happiness."])
PitBull4_HappinessIcon:SetDefaults({
	attach_to = "root",
	location = "edge_bottom_right",
	position = 1,
	size = 1.2,
	tooltip = true,
})

function PitBull4_HappinessIcon:OnEnable()
	for _, event in ipairs({"UNIT_HAPPINESS", "UNIT_PET"}) do
		if not C_EventUtils or not C_EventUtils.IsEventValid or C_EventUtils.IsEventValid(event) then
			self:RegisterEvent(event)
		end
	end
end

function PitBull4_HappinessIcon:GetTexture(frame)
	if frame.unit ~= "pet" or not get_happiness() then
		return nil
	end

	return [[Interface\PetPaperDollFrame\UI-PetHappiness]]
end

function PitBull4_HappinessIcon:GetExampleTexture(frame)
	if frame.unit ~= "pet" then
		return nil
	end

	return [[Interface\PetPaperDollFrame\UI-PetHappiness]]
end

local tex_coords = {
	{0.375, 0.5625, 0, 0.359375},
	{0.1875, 0.375, 0, 0.359375},
	{0, 0.1875, 0, 0.359375},
}

function PitBull4_HappinessIcon:GetTexCoord(frame, texture)
	local happiness = get_happiness()
	local tex_coord = tex_coords[happiness] or tex_coords[3]

	return tex_coord[1], tex_coord[2], tex_coord[3], tex_coord[4]
end
function PitBull4_HappinessIcon:GetExampleTexCoord()
	local tex_coord = tex_coords[3]
	return tex_coord[1], tex_coord[2], tex_coord[3], tex_coord[4]
end

function PitBull4_HappinessIcon:UNIT_HAPPINESS()
	self:UpdateForUnitID("pet")
end

function PitBull4_HappinessIcon:UNIT_PET(event, unit)
	if unit == "player" then self:UpdateForUnitID("pet") end
end

function PitBull4_HappinessIcon:GetEnableMouse(frame)
	return self:GetLayoutDB(frame).tooltip
end

function PitBull4_HappinessIcon.OnEnter(icon, motion)
	local happiness, damage_percentage = get_happiness()
	if happiness then
		GameTooltip:SetOwner(icon, "ANCHOR_RIGHT")
		GameTooltip:SetText(_G["PET_HAPPINESS"..happiness] or (L["Pet happiness"] .. ": " .. happiness))
		if damage_percentage then
			local template = _G.PET_DAMAGE_PERCENTAGE or "%s%%"
			GameTooltip:AddLine(string.format(template, damage_percentage), 1, 1, 1)
		end
		GameTooltip:Show()
	end
end

function PitBull4_HappinessIcon.OnLeave(icon, motion)
	if GameTooltip:GetOwner() == icon then
		GameTooltip:Hide()
	end
end

PitBull4_HappinessIcon:SetLayoutOptionsFunction(function(self)
	return 'tooltip', {
		type = 'toggle',
		name = L["Tooltip"],
		desc = L["Show a tooltip on mouseover with the happiness and damage percent for the pet."],
		get = function(info)
			return PitBull4.Options.GetLayoutDB(self).tooltip
		end,
		set = function(info, value)
			PitBull4.Options.GetLayoutDB(self).tooltip = value

			for frame in PitBull4:IterateFramesForUnitID("pet") do
				self:Clear(frame)
				self:Update(frame)
			end
		end
	}
end)

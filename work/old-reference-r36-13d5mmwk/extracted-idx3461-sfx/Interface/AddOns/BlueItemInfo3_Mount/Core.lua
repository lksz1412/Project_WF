local modName = ...
local addOnName = GetAddOnDependencies(modName)
local BII3 = _G[addOnName]

local _G = _G
local abs = _G.math.abs
local floor = _G.math.floor
local bitand = _G.bit.band
local GetAddOnMetadata = _G.GetAddOnMetadata

local mounts = {}
local spell2item = {}
local companionType, companionID, displayID, creatureID, descriptionText, sourceText

for i = 1, C_MountJournal.GetNumMounts() do
	mounts[(select(2, C_MountJournal.GetMountInfo(i)))] = i
end

local function get(id)
	companionID = tonumber(GetAddOnMetadata(modName, "X-DB-Pet-"..id))
	if companionID then
		return (C_PetJournal.GetNumCollectedInfo(companionID) or 0) > 0 and 2 or nil, 2, companionID
	end
	if id < 0 and mounts[-id] then
		companionID = abs(id)
		return select(11, C_MountJournal.GetMountInfo(mounts[companionID])) and 1 or nil, 1, companionID
	elseif id > 0 then
		companionID = tonumber(GetAddOnMetadata(modName, "X-DB-Spell-"..id))
		if companionID then
			return get(-companionID)
		end
	end
	return nil
end

local function getInfo(id)
	companionType, companionID = select(2, get(id))
	if companionType == 1 then
		return C_MountJournal.GetMountInfoExtra(mounts[companionID])
	elseif companionType == 2 then
		creatureID, sourceText, descriptionText = select(4, C_PetJournal.GetPetInfoBySpeciesID(companionID))
		displayID = tonumber(GetAddOnMetadata(modName, "X-DB-Model-"..companionID))
		if displayID then
			return displayID, descriptionText, sourceText
		else
			return -creatureID, descriptionText, sourceText
		end
	end
	return nil
end

function BII3:IsMount(id)
	return (getInfo(id))
end

function BII3:HasMount(id)
	return (get(id))
end

function BII3:GetMountObtain(id)
	local obtain = GetAddOnMetadata(modName, "X-DB-Obtain-"..id) or (id < 0 and spell2item[id] and GetAddOnMetadata(modName, "X-DB-Obtain-"..spell2item[id]) or nil)
	if obtain then
		return (obtain:gsub(";", ":"):gsub("|n", "\n"):gsub("[ \n]+$", ""))
	else
		obtain = select(3, getInfo(id))
		if obtain then
			return (obtain:gsub("|n", "\n"):gsub("[ \n]+$", ""))
		end
	end
	return nil
end

function BII3:ViewMount(id)
	id = self:GetLinkID(id) or id
	if type(id) == "number" and floor(id) == id then
		id = getInfo(id)
		if id then
			local frame, model
			if SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() then
				frame, model = SideDressUpFrame, SideDressUpModel
			else
				frame, model = DressUpFrame, DressUpModel
			end
			if not frame:IsShown() or frame.mode ~= "mount" then
				frame.mode = "mount"
				frame.ResetButton:Show()
				if not frame.ResetButton._BII3 then
					frame.ResetButton._BII3 = true
					frame.ResetButton:SetScript("PreClick", function()
						if frame.mode ~= "player" then
							frame.mode = "player"
							SetDressUpBackground(frame, (select(2, UnitRace("player"))))
							model:ClearModel()
							model:SetUnit("player")
						end
					end)
				end
				SetDressUpBackground(frame, "Pet")
				ShowUIPanel(frame)
			end
			model:ClearModel()
			if id > 0 then
				model:SetDisplayInfo(id)
			else
				model:SetCreature(abs(id))
			end
			return true
		end
	end
	return false
end

local dressUpItemLink = _G.DressUpItemLink

function DressUpItemLink(link)
	if link then
		if IsDressableItem(link) then
			return dressUpItemLink(link)
		else
			return BII3:ViewMount(link)
		end
	end
	return false
end

function BII3:AddMountItemList()
	local function readList(code, prefix, index)
		prefix = prefix..(index and "H" or "A")
		index = 1
		local list = GetAddOnMetadata(modName, "X-DB-"..prefix.."-"..index)
		local spell
		while list do
			BII3.itemList[code] = (BII3.itemList[code] and (BII3.itemList[code].."/") or "")..list
			list = "/"..list
			for id in list:gmatch("/(%d+)") do
				id = tonumber(id)
				spell = tonumber(GetAddOnMetadata(modName, "X-DB-Spell-"..id))
				if spell then
					spell = -spell
					spell2item[spell] = id
				end
			end
			index = index + 1
			list = GetAddOnMetadata(modName, "X-DB-"..prefix.."-"..index)
		end
		if BII3.itemList[code] then
			BII3.itemList[code:sub(1, 1).."**"] = true
			BII3.itemList[code:sub(1, 2).."*"] = true
		end
	end
	readList("x00", "Ground", BII3.isHorde)
	readList("x10", "Flying", BII3.isHorde)
	readList("x20", "Water", BII3.isHorde)
	readList("x30", "Pet", BII3.isHorde)
	self.AddMountItemList = nil
end
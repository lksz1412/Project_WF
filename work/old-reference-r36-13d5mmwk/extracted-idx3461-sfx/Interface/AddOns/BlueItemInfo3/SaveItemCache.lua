local _G = _G
local BII3 = _G[...]
local GetItemInfo = _G.GetItemInfo
local itemName, itemRarity, itemLevel, itemSubClass, itemEquipLoc, _

local LBI = LibStub("LibBlueItem-1.0")

function BII3:SaveItemCache(id, name)
	if id and id > 0 and name and name:trim() ~= "" then
		local originalID = select(2, LBI:GetItemIDAndBonusID(id))
		itemRarity, itemName, itemLevel, itemEquipLoc = self:GetItem(id)
		if itemName then
			name = GetItemInfo(originalID)
			if itemName ~= name then
				self.itemNameDB[id] = itemRarity.."|"..name.."|"..itemLevel.."|"..itemEquipLoc
				itemRarity, itemName, itemLevel, itemEquipLoc = nil
				return true
			end
		else
			itemName, _, itemRarity, itemLevel, _, _, itemSubClass, _, itemEquipLoc = GetItemInfo(originalID)
			if itemName then
				itemEquipLoc = LBI:GetItemEquipCode(itemSubClass, itemEquipLoc)
				if itemEquipLoc then
					self.itemNameDB[id] = itemRarity.."|"..itemName.."|"..itemLevel.."|"..itemEquipLoc
					itemName, itemRarity, itemLevel, itemSubClass, itemEquipLoc = nil
					return true
				end
				itemName, itemRarity, itemLevel, itemSubClass, itemEquipLoc = nil
			end
		end
	end
	return nil
end
BagFu = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceDB-2.0", "AceEvent-2.0")
local BagFu, self = BagFu, BagFu

BagFu.hasIcon = true
BagFu.cannotDetachTooltip = true
BagFu.defaultPosition = "RIGHT"

local L = AceLibrary("AceLocale-2.2"):new("FuBar_BagFu")
local _G = _G
local select = select
local string_format = string.format
--
local Tablet = AceLibrary("Tablet-2.0")
local Crayon = LibStub("LibCrayon-3.0")
--
local KEYRING_CONTAINER = KEYRING_CONTAINER
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local options = {
	type = "group",
	pass = true,
	get = function(key)
		return BagFu.db.profile[key]
	end,
	set = function(key, val)
		BagFu.db.profile[key] = val
		BagFu:Update()
	end,
	args = {
		includeAmmo = {
			type = "toggle",
			name = L["Ammo/Soul Bags"],
			desc = L["Include ammo/soul bags"],
		},
		includeProfession = {
			type = "toggle",
			name = L["Profession Bags"],
			desc = L["Include profession bags"],
		},
		showDepletion = {
			type = "toggle",
			name = L["Bag Depletion"],
			desc = L["Show depletion of bags"],
		},
		showTotal = {
			type = "toggle",
			name = L["Bag Total"],
			desc = L["Show total amount of space in bags"],
		},
		openBagsAtBank = {
			type = "toggle",
			name = L["Open Bags at Bank"],
			desc = L["Open all of your bags when you're at the bank"],
			set = function(v)
				BagFu.db.profile.openBagsAtBank = v
				if v then
					BagFu:RegisterEvent("BANKFRAME_OPENED", function() OpenAllBags(true) end)
				else
					BagFu:UnregisterEvent("BANKFRAME_OPENED")
				end
			end,
			get = function() return BagFu.db.profile.openBagsAtBank end,
		},
		openBagsAtVendor = {
			type = "toggle",
			name = L["Open Bags at Vendor"],
			desc = L["Open all of your bags when you're at a vendor"],
			set = function(v)
				BagFu.db.profile.openBagsAtVendor = v
				if v then
					BagFu:RegisterEvent("MERCHANT_SHOW", function() OpenAllBags(true) end)
					BagFu:RegisterEvent("MERCHANT_CLOSED", function() CloseAllBags() end)
				else
					BagFu:UnregisterEvent("MERCHANT_SHOW")
					BagFu:UnregisterEvent("MERCHANT_CLOSED")
				end
			end,
			get = function() return BagFu.db.profile.openBagsAtVendor end,
		},
	}
}

function BagFu:OnInitialize()
	self:RegisterDB("BagFuDB")
	self:RegisterDefaults('profile', {
		showDepletion = false,
		includeProfession = true,
		includeAmmo = false,
		showTotal = true,
		openBagsAtBank = false,
		openBagsAtVendor = false,
	})
	self.OnMenuRequest = options
end

function BagFu:OnEnable()
	self:RegisterBucketEvent("BAG_UPDATE", 5, "Update")
	if self.db.profile.openBagsAtBank then
		self:RegisterEvent("BANKFRAME_OPENED", function() OpenAllBags(true) end)
	end
	if self.db.profile.openBagsAtVendor then
		self:RegisterEvent("MERCHANT_SHOW", function() OpenAllBags(true) end)
		self:RegisterEvent("MERCHANT_CLOSED", function() CloseAllBags() end)
	end
end

-- Unused (here) BagTypes
-- 4096: Vanity Pets
-- 2048: Unknown
-- 256: Keyring

local function IsAmmoBag(bagType)
	-- 4: Soul Bag
	-- 2: Ammo Pouch
	-- 1: Quiver
	if bagType == 4 or bagType == 2 or bagType == 1 then
		return true
	end
	return false
end

local function IsProfessionBag(bagType)
	-- 1024: Mining Bag
	-- 512: Gem Bag
	-- 128: Engineering Bag
	-- 64: Enchanting Bag
	-- 32: Herb Bag
	-- 16: Inscription Bag
	-- 8: Leatherworking Bag
	if bagType == 1024 or bagType == 512 or bagType == 128 or bagType == 64 or bagType == 32 or bagType == 16 or bagType == 8 then
		return true
	end
	return false
end

function BagFu:OnTextUpdate()
	local totalSlots = 0
	local takenSlots = 0
	for i = 0, NUM_BAG_SLOTS do
		local usable = true
		local freeSlots, bagType = GetContainerNumFreeSlots(i)

		if i >= 1 then
			if not self.db.profile.includeAmmo and IsAmmoBag(bagType) then
				usable = false
			elseif not self.db.profile.includeProfession and IsProfessionBag(bagType) then
				usable = false
			end
		end
		if usable then
			local bagSize = GetContainerNumSlots(i)
			if bagSize ~= nil and bagSize > 0 then
				totalSlots = totalSlots + bagSize
				takenSlots = takenSlots + (bagSize - freeSlots)
			end
		end
	end
	
	local color = Crayon:GetThresholdHexColor((totalSlots - takenSlots) / totalSlots)
	
	if self.db.profile.showDepletion then
		takenSlots = totalSlots - takenSlots
	end
	
	if self.db.profile.showTotal then
		self:SetText(string_format("|cff%s%d/%d|r", color, takenSlots, totalSlots))
	else
		self:SetText(string_format("|cff%s%d|r", color, takenSlots))
	end
end

function BagFu:OnTooltipUpdate()
	Tablet:SetHint(L["Click to open your bags"])
end

function BagFu:OnClick()
	-- Holding shift will open all bags, even if you asked to not show professions/ammo.
	local shifted = IsShiftKeyDown()
	-- Just toggle the keyring if control is held
	if IsControlKeyDown() then
		ToggleBag(KEYRING_CONTAINER)
		return
	end
	--
	if not ContainerFrame1:IsShown() then
		for i = 1, NUM_BAG_SLOTS do
			if _G["ContainerFrame" .. (i + 1)]:IsShown() then
				_G["ContainerFrame" .. (i + 1)]:Hide()
			end
		end
		ToggleBackpack()
		if ContainerFrame1:IsShown() then
			for i = 1, NUM_BAG_SLOTS do
				local usable = true
				local _, bagType = GetContainerNumFreeSlots(i)
				if not self.db.profile.includeAmmo and IsAmmoBag(bagType) then
					usable = false
				elseif not self.db.profile.includeProfession and IsProfessionBag(bagType) then
					usable = false
				end
				if usable or shifted then
					ToggleBag(i)
				end
			end
		end
	else
		for i = 0, NUM_BAG_SLOTS do
			if _G["ContainerFrame" .. (i + 1)]:IsShown() then
				_G["ContainerFrame" .. (i + 1)]:Hide()
			end
		end
	end
end

------------------------------------------------------
-- DisenchantPredictor.lua
------------------------------------------------------

-- constants
local FDP_DUST = 1;
local FDP_ESSENCE = 2;
local FDP_SHARD = 3;
local FDP_CRYSTAL = 4;

-- Saved vars
FDP_Exceptions = {};

-- WotLK disenchants
--[[
lesser cosmic	- green 150
greater cosmic	- green 154 162
small dream		- blue 150 154 158 159 162 163 166
(large) dream	- blue 167

but what shards do you (rarely) get from greens?
]]

-- TEMP
-- guesses at the cutoffs between small/large shard and lesser/greater essence
FDP_WOTLK_BLUE_TRANSITION = 167
FDP_WOTLK_GREEN_TRANSITION = 152

FDP_ItemIDs = {
	["DUST_STRANGE"]			= 10940;
	["DUST_SOUL"]				= 11083;
	["DUST_VISION"]				= 11137;
	["DUST_DREAM"]				= 11176;
	["DUST_ILLUSION"]			= 16204;
	["DUST_ARCANE"]				= 22445;	-- TBC
	["DUST_INFINITE"]			= 34054;	-- WotLK
	                                          
	["ESSENCE_MAGIC_LESSER"]	= 10938;      
	["ESSENCE_MAGIC_GREATER"]	= 10939;      
	["ESSENCE_ASTRAL_LESSER"]	= 10998;      
	["ESSENCE_ASTRAL_GREATER"]	= 11082;      
	["ESSENCE_MYSTIC_LESSER"]	= 11134;      
	["ESSENCE_MYSTIC_GREATER"]	= 11135;      
	["ESSENCE_NETHER_LESSER"]	= 11174;      
	["ESSENCE_NETHER_GREATER"]	= 11175;      
	["ESSENCE_ETERNAL_LESSER"]	= 16202;      
	["ESSENCE_ETERNAL_GREATER"]	= 16203;      
	["ESSENCE_PLANAR_LESSER"]	= 22447;	-- TBC
	["ESSENCE_PLANAR_GREATER"]	= 22446;	-- TBC
	["ESSENCE_COSMIC_LESSER"]	= 34056;	-- WotLK
	["ESSENCE_COSMIC_GREATER"]	= 34055;	-- WotLK
                                              
	["SHARD_GLIMMER_SMALL"]		= 10978;      
	["SHARD_GLIMMER_LARGE"]		= 11084;      
	["SHARD_GLOWING_SMALL"]		= 11138;      
	["SHARD_GLOWING_LARGE"]		= 11139;      
	["SHARD_RADIANT_SMALL"]		= 11177;      
	["SHARD_RADIANT_LARGE"]		= 11178;      
	["SHARD_BRILLIANT_SMALL"]	= 14343;      
	["SHARD_BRILLIANT_LARGE"]	= 14344;      
	["SHARD_PRISMATIC_SMALL"]	= 22448;	-- TBC
	["SHARD_PRISMATIC_LARGE"]	= 22449;	-- TBC
	["SHARD_DREAM_SMALL"]		= 34053;	-- WotLK
	["SHARD_DREAM_LARGE"]		= 34052;	-- WotLK

	["CRYSTAL_NEXUS"]			= 20725;      
	["CRYSTAL_VOID"]			= 22450;	-- TBC
	["CRYSTAL_ABYSS"]			= 34057;	-- WotLK
}

-- formula for dust by level: max(1, ceil((item level - 15) / 10))
FDP_DustNames = {
	"DUST_STRANGE",		-- item level 1-25      req level 1-20
	"DUST_SOUL",		-- item level 26-35     req level 21-30
	"DUST_VISION",		-- item level 36-45     req level 31-40
	"DUST_DREAM",		-- item level 46-65     req level 41-50
	"DUST_ILLUSION",	-- item level 56-65     req level 51-60
	"DUST_ARCANE",		-- item level 66-120	req level 57-70
	"DUST_INFINITE",	-- item level 130+		req level 67-80
}

-- formula for essence by level: max(1, ceil((item level - 10) / 5))
FDP_EssenceNames = {
	"ESSENCE_MAGIC_LESSER",		-- item level 6-15 
	"ESSENCE_MAGIC_GREATER",	-- item level 16-20
	"ESSENCE_ASTRAL_LESSER",	-- item level 21-25
	"ESSENCE_ASTRAL_GREATER",	-- item level 26-30
	"ESSENCE_MYSTIC_LESSER",	-- item level 31-35
	"ESSENCE_MYSTIC_GREATER",	-- item level 36-40
	"ESSENCE_NETHER_LESSER",	-- item level 41-45
	"ESSENCE_NETHER_GREATER",	-- item level 46-50
	"ESSENCE_ETERNAL_LESSER",	-- item level 51-55
	"ESSENCE_ETERNAL_GREATER",	-- item level 56-60
	"ESSENCE_ETERNAL_GREATER",	-- item level 61-65
	"ESSENCE_PLANAR_LESSER",	-- item level 66-99
	"ESSENCE_PLANAR_GREATER",	-- item level 100-120? (end of BC greens)
	"ESSENCE_COSMIC_LESSER",	-- item level 130 - FDP_WOTLK_TRANSITION (start of WotLK greens)
	"ESSENCE_COSMIC_GREATER",	-- item level FDP_WOTLK_TRANSITION+
}
	
-- formula for shard by level: max(1, ceil((item level - 20) / 5))
FDP_ShardNames = {
	"SHARD_GLIMMER_SMALL",		-- item level 1-25
	"SHARD_GLIMMER_LARGE",		-- item level 26-30
	"SHARD_GLOWING_SMALL",		-- item level 31-35
	"SHARD_GLOWING_LARGE",		-- item level 36-40
	"SHARD_RADIANT_SMALL",		-- item level 41-45
	"SHARD_RADIANT_LARGE",		-- item level 46-50
	"SHARD_BRILLIANT_SMALL",	-- item level 51-55
	"SHARD_BRILLIANT_LARGE",	-- item level 56-70 pre-BC items
	"SHARD_PRISMATIC_SMALL",	-- item level 66-99 BC items 
	"SHARD_PRISMATIC_LARGE",	-- item level 100+
	"SHARD_DREAM_SMALL",		-- item level 130 - FDP_WOTLK_TRANSITION (start of WotLK items)
	"SHARD_DREAM_LARGE",		-- item level FDP_WOTLK_TRANSITION+
}

FDP_CrystalNames = {
	"CRYSTAL_NEXUS",	-- item level 56-94 epics
	"CRYSTAL_VOID",		-- item level 95-150ish (BC) epics
	"CRYSTAL_ABYSS",		-- item level 160+ (Wrath) epics
}

local BCicon ="|TInterface\\AddOns\\GFW_DisenchantPredictor\\bc.tga:16:32:0:|t";
local BC1 = "57-63 "..BCicon;
local BC2 = "64-70 "..BCicon;
local BCall = "57-70 "..BCicon;

local Wicon ="|TInterface\\AddOns\\GFW_DisenchantPredictor\\wrath.tga:16:32:0:|t";
local W1 = FDP_LOWER.." "..Wicon;
local W2 = FDP_HIGHER.." "..Wicon;
local Wall = Wicon;

FDP_DustLevels = {
	"1-20", "21-30", "31-40", "41-50", "51-60", BCall, Wall
}

FDP_EssenceLevels = {
	"1-10", "11-15", "16-20", "21-25", "26-30", "31-35", "36-40", "41-45", "46-50", "51-60", "51-60", BC1, BC2, W1, W2
}
	
FDP_ShardLevels = {
	"1-20", "21-25", "26-30", "31-35", "36-40", "41-45", "46-50", "51-60", BC1, BC2, W1, W2
}

FDP_CrystalLevels = {
	"51-60", BCall, Wall
}

FDP_WeaponTypes = { "INVTYPE_2HWEAPON", "INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPONOFFHAND", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT", "INVTYPE_THROWN" };
FDP_ArmorTypes = { "INVTYPE_BODY", "INVTYPE_CHEST", "INVTYPE_CLOAK", "INVTYPE_FEET", "INVTYPE_FINGER", "INVTYPE_HAND", "INVTYPE_HEAD", "INVTYPE_HOLDABLE", "INVTYPE_LEGS", "INVTYPE_NECK", "INVTYPE_RANGED", "INVTYPE_ROBE", "INVTYPE_SHIELD", "INVTYPE_SHOULDER", "INVTYPE_TRINKET", "INVTYPE_WAIST", "INVTYPE_WRIST", "INVTYPE_RELIC", };

function FDP_HookTooltip(frame)
	if (frame:GetScript("OnTooltipSetItem")) then
		frame:HookScript("OnTooltipSetItem", FDP_OnTooltipSetItem);
	else
		frame:SetScript("OnTooltipSetItem", FDP_OnTooltipSetItem);
	end
end

function FDP_OnTooltipSetItem(self)
	local name, link = self:GetItem();
	if ( (FDP_Config.Reagents or FDP_Config.Items) and link) then
				
		local _, _, itemID = string.find(link, "item:(%d+)");
		if (itemID == nil or tonumber(itemID) == nil) then return false; end
		itemID = tonumber(itemID);
		if (FDP_StaticExceptions[itemID] or FDP_Exceptions[itemID]) then
			return false;
		end

		if (FDP_Config.Reagents) then
			if (FDP_TooltipForReagent(this, itemID)) then
				return true;
			end
		end
		
		if (FDP_Config.Debug) then
			local name, link, quality, itemLevel = GetItemInfo(itemID);	
			self:AddDoubleLine("Item Level", itemLevel);
		end
			
		if (FDP_Config.Items) then
			local C = GFW_FONT_COLOR;
			local quality, level, kind = FDP_ItemInfoForLink(link);
			if (level and level > 0 and kind) then
				for lineNum = 1, self:NumLines() do
					local leftText = getglobal(self:GetName().."TextLeft"..lineNum):GetText();
					if (leftText == ITEM_DISENCHANT_NOT_DISENCHANTABLE) then
						FDP_Exceptions[itemID] = 1;
						return false;
					end
				end
				
				local dustIndex, essenceIndex, shardIndex, crystalIndex = FDP_DisenchantIndex(level, quality, itemID);
				local dustName, essenceName, shardName, crystalName;
				if (quality == 4 and crystalIndex ) then
					crystalName = FDP_DisplayName(FDP_CrystalNames[crystalIndex]);
					self:AddLine(FDP_CAN_DIS_TO.." "..crystalName, C.r, C.g, C.b);
					return true;
				elseif (quality == 3) then
					shardName = FDP_DisplayName(FDP_ShardNames[shardIndex]);
					if (not shardName) then return nil; end
					if (crystalIndex) then
						crystalName = FDP_DisplayName(FDP_CrystalNames[crystalIndex]);
						if (FDP_Config.Verbose) then
							self:AddLine(FDP_CAN_DIS_TO, C.r, C.g, C.b);
							self:AddLine("  "..shardName.." "..FDP_MOST_LIKELY, C.r, C.g, C.b);
							self:AddLine("  "..crystalName.." "..FDP_RARELY, C.r, C.g, C.b);
						else
							self:AddLine(FDP_CAN_DIS_TO, C.r, C.g, C.b);
							self:AddDoubleLine(" ", shardName..crystalName);
						end
					else
						self:AddLine(FDP_CAN_DIS_TO.." "..shardName, C.r, C.g, C.b);
					end
					return true;
				elseif (quality == 2) then
					dustName = FDP_DisplayName(FDP_DustNames[dustIndex]);
					essenceName = FDP_DisplayName(FDP_EssenceNames[essenceIndex]);
					shardName = FDP_DisplayName(FDP_ShardNames[shardIndex]);
					if (not dustName or not essenceName or not shardName) then return nil; end
					if (FDP_Config.Verbose) then
						self:AddLine(FDP_CAN_DIS_TO, C.r, C.g, C.b);
						self:AddLine("  "..dustName.." "..FDP_MOST_LIKELY, C.r, C.g, C.b);
						if (kind == "WEAPON") then
							self:AddLine("  "..essenceName.." "..FDP_JUST_LIKELY, C.r, C.g, C.b);
						else
							self:AddLine("  "..essenceName.." "..FDP_OCCASIONALLY, C.r, C.g, C.b);		
						end
						self:AddLine("  "..shardName.." "..FDP_RARELY, C.r, C.g, C.b);
					else
						self:AddDoubleLine(FDP_CAN_DIS_TO, shardName, C.r, C.g, C.b);
						self:AddDoubleLine(" ", essenceName..dustName);
					end
					return true;
				end
			end
		end
	end
	return false;
end

function FDP_ContainerFrameItemButton_OnClick(self, button)
	if ( button == "LeftButton" and not FDP_IsDisenchanting ) then
		local bagID = self:GetParent():GetID();
		local slotID = self:GetID();
	
		FDP_ClickedItem = GetContainerItemLink(bagID, slotID);
	end
end

function FDP_PaperDollItemSlotButton_OnClick(self, button)
	if ( button == "LeftButton" and not FDP_IsDisenchanting ) then
		FDP_ClickedItem = GetInventoryItemLink("player", self:GetID());
	end
end

function FDP_TooltipForReagent(frame, itemID)
	
	local identifier = GFWTable.KeyOf(FDP_ItemIDs, itemID);
	if (identifier == nil) then 
		return false; -- not an itemID we care about
	end
	
	local kind, levelRange;
	local namesTables = {FDP_DustNames, FDP_EssenceNames, FDP_ShardNames, FDP_CrystalNames};
	local levelTables = {FDP_DustLevels, FDP_EssenceLevels, FDP_ShardLevels, FDP_CrystalLevels};
	for tableID, aTable in pairs(namesTables) do
		local index = GFWTable.KeyOf(aTable, identifier);
		if (index) then
			levelRange = levelTables[tableID][index];
			kind = tableID;
			break;
		end
	end

	if (kind) then
		if (tonumber(string.sub(levelRange,1,1))) then
			levelRange = string.format(FDP_LEVEL_FORMAT, levelRange);
		end
		frame:AddLine(string.format(FDP_CAN_DIS_FROM_FORMAT, levelRange), 0.7,0.7,0.7);
		if (FDP_Config.Verbose) then
			if (kind == FDP_CRYSTAL) then
				frame:AddLine(FDP_CRYSTAL_VERBOSE, 0.7,0.7,0.7);
			elseif (kind == FDP_SHARD) then
				frame:AddLine(FDP_SHARD_VERBOSE, 0.7,0.7,0.7);
			elseif (kind == FDP_ESSENCE) then
				frame:AddLine(FDP_ESSENCE_VERBOSE, 0.7,0.7,0.7);
			elseif (kind == FDP_DUST) then
				frame:AddLine(FDP_DUST_VERBOSE, 0.7,0.7,0.7);
			end
		end
		return true;
	end
end

function FDP_OnLoad()

	-- Register Slash Commands
	SLASH_FDP1 = "/enchant";
	SLASH_FDP2 = "/disenchant";
	SLASH_FDP3 = "/ench";
	SLASH_FDP4 = "/dis";
	SLASH_FDP5 = "/de";
	SLASH_FDP6 = "/dp";
	SlashCmdList["FDP"] = function(msg)
		FDP_ChatCommandHandler(msg);
	end
			
	DisenchantPredictorFrame:RegisterEvent("LOOT_OPENED");	
	DisenchantPredictorFrame:RegisterEvent("UNIT_SPELLCAST_START");	
	DisenchantPredictorFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");	
	
	FDP_HookTooltip(GameTooltip);
	FDP_HookTooltip(ItemRefTooltip);

	hooksecurefunc("ContainerFrameItemButton_OnClick", FDP_ContainerFrameItemButton_OnClick);
	hooksecurefunc("PaperDollItemSlotButton_OnClick", FDP_PaperDollItemSlotButton_OnClick);

end

local LootOpenedTime = 0;
local MIN_TRY_AGAIN_TIME = 1;

function FDP_OnEvent(event, arg1)
	if (event == "LOOT_OPENED") then
		if (GetTime() - LootOpenedTime < MIN_TRY_AGAIN_TIME) then
			return; -- UIParent likes to get lost in infinite recursion...
		end
		LootOpenedTime = GetTime();

		if (FDP_IsDisenchanting and LootFrame:IsVisible()) then
			for slot = 1, GetNumLootItems() do
				if (LootSlotIsCoin(slot)) then
					return; -- coins don't come from disenchanting.
				else
					local link = GetLootSlotLink(slot);
					if (link == nil) then 
						return; 
					end
					local _, _, itemID = string.find(link, "item:(%d+)");
					itemID = tonumber(itemID);
					if (itemID == nil) then return; end
					local identifier = GFWTable.KeyOf(FDP_ItemIDs, itemID);
					if (identifier == nil) then 
						-- if it's not one of our known disenchanted reagents, we probably didn't get here by disenchanting.
						return; 
					end
					if (FDP_IsDisenchanting and FDP_ClickedItem) then
						local quality, level, kind = FDP_ItemInfoForLink(FDP_ClickedItem);
						local dustIndex, essenceIndex, shardIndex, crystalIndex = FDP_DisenchantIndex(level, quality, itemID);
						local indices = {dustIndex, essenceIndex, shardIndex, crystalIndex};
						
						for i, table in pairs({FDP_DustNames, FDP_EssenceNames, FDP_ShardNames, FDP_CrystalNames}) do
							if (GFWTable.KeyOf(table, identifier)) then
								local expectedName = table[indices[i]];
								if (expectedName ~= identifier) then
									local version = GetAddOnMetadata("GFW_DisenchantPredictor", "Version");
									local _, _, _, colorCode = GetItemQualityColor(quality);
									local qualityName = colorCode..getglobal("ITEM_QUALITY"..quality.."_DESC")..FONT_COLOR_CODE_CLOSE;
									GFWUtils.Print(string.format(GFWUtils.Red("Disenchant Predictor %s:").." Expected %s from a level %s %s item, but got %s instead. Please check www.fizzwidget.com for updates.", version, FDP_DisplayName(expectedName), GFWUtils.Hilite(level), qualityName, FDP_DisplayName(identifier)));
								end
							end
						end
					end
				end
			end
		end
		FDP_ClickedItem = nil;	
		FDP_IsDisenchanting = nil;
	elseif (event == "UNIT_SPELLCAST_START" and arg1 == "player") then
		local spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo("player");
		if (FDP_ClickedItem and icon == "Interface\\Icons\\INV_Enchant_Disenchant") then
			if ( GetCVar("autoLootDefault") == "1" ) then
				if (FDP_Config.Debug) then
					local name, link, quality, itemLevel = GetItemInfo(FDP_ClickedItem);	
					GFWUtils.Print(string.format(FDP_DISENCHANTING_DEBUG, FDP_ClickedItem, itemLevel));
				else
					GFWUtils.Print(string.format(FDP_DISENCHANTING_STATUS, FDP_ClickedItem));
				end
			end
			FDP_IsDisenchanting = true;
		end
	elseif (event == "UNIT_SPELLCAST_INTERRUPTED" and arg1 == "player") then
		FDP_ClickedItem = nil;	
		FDP_IsDisenchanting = nil;
	end
end

function FDP_ChatCommandHandler(msg)
	
	if ( msg == "" ) then
		GFW_DisenchantPredictor:ShowConfig();
		return;
	end

	-- Print Help
	if ( msg == "help" ) then
		local version = GetAddOnMetadata("GFW_DisenchantPredictor", "Version");
		GFWUtils.Print("Fizzwidget Disenchant Predictor "..version..":");
		GFWUtils.Print("/enchant (or /ench or /disenchant or /dis or /de or /dp)");
		GFWUtils.Print("- "..GFWUtils.Hilite("help").." - "..FDP_HELP_HELP);
		GFWUtils.Print("- "..GFWUtils.Hilite(FDP_CMD_LINK).." - "..FDP_HELP_LINK);
		return;
	end
	
	if (msg == "version") then
		local version = GetAddOnMetadata("GFW_DisenchantPredictor", "Version");
		GFWUtils.Print("Fizzwidget Disenchant Predictor "..version);
		return;
	end
		
	local _, _, link  = string.find(msg, "(|c%x+|Hitem:[-%d:]+|h%[.-%]|h|r)");
	if (link and link ~= "") then

		local _, _, itemID = string.find(link, "item:([-%d]+)");
		itemID = tonumber(itemID);
		if (itemID == nil) then 
			GFWUtils.Print(string.format(FDP_ERROR_ITEMID_FORMAT, link));
			return; 
		end
		
		local identifier = GFWTable.KeyOf(FDP_ItemIDs, itemID);
		if (identifier) then 
			local kind, levelRange;
			local namesTables = {FDP_DustNames, FDP_EssenceNames, FDP_ShardNames, FDP_CrystalNames};
			local levelTables = {FDP_DustLevels, FDP_EssenceLevels, FDP_ShardLevels, FDP_CrystalLevels};
			for tableID, aTable in pairs(namesTables) do
				local index = GFWTable.KeyOf(aTable, identifier);
				if (index) then
					levelRange = levelTables[tableID][index];
					kind = tableID;
					break;
				end
			end
			if (kind) then
				GFWUtils.Print(link..": "..string.format(FDP_CAN_DIS_FROM_FORMAT, levelRange));
				if (FDP_Config.Verbose) then
					if (kind == FDP_CRYSTAL) then
						GFWUtils.Print(FDP_CRYSTAL_VERBOSE);
					elseif (kind == FDP_SHARD) then
						GFWUtils.Print(FDP_SHARD_VERBOSE);
					elseif (kind == FDP_ESSENCE) then
						GFWUtils.Print(FDP_ESSENCE_VERBOSE);
					elseif (kind == FDP_DUST) then
						GFWUtils.Print(FDP_DUST_VERBOSE);
					end
				end
				return;
			end
		else
			GFWUtils.Print(string.format(FDP_ERROR_ITEMID_FORMAT, link));
			return; 
		end
		
		if (FDP_StaticExceptions[itemID] or FDP_Exceptions[itemID]) then
			GFWUtils.Print(string.format(FDP_CANT_DIS_EXCEPTION_FORMAT, link));
			return;
		end
		local quality, level, kind = FDP_ItemInfoForLink(link);
		if (quality < 2 or quality > 0) then
			GFWUtils.Print(string.format(FDP_CANT_DIS_QUALITY_FORMAT, link));
			return;
		end
		
		if (level and kind and level > 0) then
			local dustIndex, essenceIndex, shardIndex, crystalIndex = FDP_DisenchantIndex(level, quality, itemID);
			local dustName, essenceName, shardName, crystalName;
			if (quality == 4 and kind and crystalIndex) then
				crystalName = FDP_DisplayName(FDP_CrystalNames[crystalIndex]);
				GFWUtils.Print(link ..": "..FDP_CAN_DIS_TO.." ".. crystalName);
				return;
			elseif (quality == 3 and kind) then
				shardName = FDP_DisplayName(FDP_ShardNames[shardIndex]);
				if (crystalIndex) then
					crystalName = FDP_DisplayName(FDP_CrystalNames[crystalIndex]);
					GFWUtils.Print(link ..": "..FDP_CAN_DIS_TO);
					GFWUtils.Print(" - "..shardName.." "..FDP_MOST_LIKELY);
					GFWUtils.Print(" - "..crystalName.." "..FDP_RARELY);
				else
					GFWUtils.Print(link ..": "..FDP_CAN_DIS_TO.." "..shardName);
				end
				return;
			elseif (quality == 2 and kind) then
				dustName = FDP_DisplayName(FDP_DustNames[dustIndex]);
				essenceName = FDP_DisplayName(FDP_EssenceNames[essenceIndex]);
				shardName = FDP_DisplayName(FDP_ShardNames[shardIndex]);
				GFWUtils.Print(link ..": "..FDP_CAN_DIS_TO);
				GFWUtils.Print(" - "..dustName.." "..FDP_MOST_LIKELY);
				if (kind == "WEAPON") then
					GFWUtils.Print(" - "..essenceName.." "..FDP_JUST_LIKELY);
				else
					GFWUtils.Print(" - "..essenceName.." "..FDP_OCCASIONALLY);		
				end
				GFWUtils.Print(" - "..shardName.." "..FDP_RARELY);
				return;
			end
		else
			GFWUtils.Print(string.format(FDP_CANT_DIS_TYPE_FORMAT, link));
			return;
		end
		GFWUtils.Print(string.format(FDP_BAIL_FORMAT, link));
		return;
	end
	
	-- If we're this far, we probably have bad input.
	FDP_ChatCommandHandler("help");
end

local BCBlueExceptions = {
	[23835]	= 1,	-- Gnomish Poultryizer
	[23836]	= 1,	-- Goblin Rocket Launcher
	[25653]	= 1,	-- Riding Crop
	[32863]	= 1,	-- Skybreaker Whip
};
function FDP_DisenchantIndex(level, quality, itemID)
    local shardIndex = math.min(10, math.max(1, math.ceil((level - 20) / 5)));
	local crystalIndex;
	if (BCBlueExceptions[itemID]) then
		shardIndex = 9;		-- Small Prismatic
		crystalIndex = 1;	-- Nexus
		return nil, nil, shardIndex, crystalIndex;
	end
	
    local dustIndex = math.min(6, math.max(1, math.ceil((level - 15) / 10)));
    local essenceIndex = math.min(19, math.max(1, math.ceil((level - 10) / 5)));

	-- The pattern gets disrupted as we get into BC and Wrath content
	if (quality == 2) then
		if (level >= 56 and level < 65) then
			shardIndex = 8;		-- Large Brilliant
		elseif (level >= 66 and level < 100) then
			dustIndex = 6;		-- Arcane
			essenceIndex = 12;	-- Lesser Planar
			shardIndex = 9;		-- Small Prismatic
		elseif (level >= 100 and level < 130) then
			dustIndex = 6;		-- Arcane
			essenceIndex = 13;	-- Greater Planar
			shardIndex = 10;	-- Large Prismatic
		elseif (level >= 130 and level < FDP_WOTLK_GREEN_TRANSITION) then
			dustIndex = 7;		-- Infinite
			essenceIndex = 14;	-- Lesser Cosmic
			shardIndex = 11;	-- Small Dream
		elseif (level >= FDP_WOTLK_GREEN_TRANSITION) then
			dustIndex = 7;		-- Infinite
			essenceIndex = 15;	-- Greater Cosmic
			shardIndex = 12;	-- (Large) Dream
		end
	elseif (quality == 3) then
	 	if (level >= 56 and level < 65) then
			shardIndex = 8;		-- Large Brilliant
			crystalIndex = 1;	-- Nexus
		elseif (level >= 66 and level < 100) then
			shardIndex = 9;		-- Small Prismatic
			crystalIndex = 1;	-- Nexus
		elseif (level >= 100 and level < 130) then
			shardIndex = 10;	-- Large Prismatic
			crystalIndex = 2;	-- Void
		elseif (level >= 130 and level < FDP_WOTLK_BLUE_TRANSITION) then
			shardIndex = 11;	-- Small Dream
			crystalIndex = 2;	-- Void
		elseif (level >= FDP_WOTLK_BLUE_TRANSITION) then
			shardIndex = 12;	-- (Large) Dream
			crystalIndex = 3;	-- Abyss
		end
	elseif (quality == 4) then
		if (level >= 56 and level < 95) then
			crystalIndex = 1;	-- Nexus
		elseif (level >= 95 and level < 160) then
			crystalIndex = 2;	-- Void
		elseif (level >= 160) then
			crystalIndex = 3;	-- Abyss
		end
	end
    return dustIndex, essenceIndex, shardIndex, crystalIndex;
end

function FDP_PrefetchItemInfo()
	for _, itemID in pairs(FDP_ItemIDs) do
		FDPHiddenTooltip:SetHyperlink("item:"..itemID);
	end
end

-- returns a link almost always (thanks to prefetching), colored localized name otherwise.
function FDP_DisplayName(identifier)
	local itemID = FDP_ItemIDs[identifier];
	if (itemID == nil) then
		return getglobal(identifier); -- shouldn't happen anyways, right?
	end
	
	local localizedName, link = GetItemInfo(itemID);
	if (localizedName) then
		return link;
	else
		FDPHiddenTooltip:SetHyperlink("item:"..itemID);		-- prefetch for later
	
		if (strsub(identifier, 1, 4) == "DUST") then
			kind = 1;
		elseif (strsub(identifier, 1, 7) == "ESSENCE") then
			kind = 2;
		elseif (strsub(identifier, 1, 5) == "SHARD") then
			kind = 3;
		elseif (strsub(identifier, 1, 7) == "CRYSTAL") then
			kind = 4;
		end
		local _, _, _, colorCode = GetItemQualityColor(kind);
		
		localizedName = getglobal(identifier) or identifier;
		return colorCode..localizedName..FONT_COLOR_CODE_CLOSE;
	end
end

function FDP_ItemInfoForLink(itemLink)
	
	_, _, itemID = string.find(itemLink, "item:(%d+)");
	itemID = tonumber(itemID);
	if (itemID == nil) then return nil; end
	
	local name, link, quality, itemLevel, minLevel, type, subType, stackCount, equipLoc, texture = GetItemInfo(itemID);	

	-- we use equipLoc instead of type because it's unlocalized
	local kind;		
	if (GFWTable.KeyOf(FDP_WeaponTypes, equipLoc)) then
		kind = "WEAPON";
	end
	if (GFWTable.KeyOf(FDP_ArmorTypes, equipLoc)) then
		kind = "ARMOR";
	end
	
	if (kind) then
		return quality, itemLevel, kind;
	end
end

------------------------------------------------------
-- Ace3 options panel stuff
------------------------------------------------------

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")

-- AceAddon Initialization
GFW_DisenchantPredictor = LibStub("AceAddon-3.0"):NewAddon("GFW_DisenchantPredictor")
GFW_DisenchantPredictor.date = gsub("$Date: 2009-04-16 20:45:06 -0700 (Thu, 16 Apr 2009) $", "^.-(%d%d%d%d%-%d%d%-%d%d).-$", "%1")

function GFW_DisenchantPredictor:OnProfileChanged(event, database, newProfileKey)
	-- this is called every time our profile changes (after the change)
	FDP_Config = database.profile
end

local function getProfileOption(info)
	return FDP_Config[info.arg]
end

local function setProfileOption(info, value)
	FDP_Config[info.arg] = value
end

local options = {
	type = 'group',
	args = {
		general = {
			type = 'group',
			cmdInline = true,
			order = -1,
			get = getProfileOption,
			set = setProfileOption,
			name = FDP_OPTIONS_GENERAL,
			args = {
				reagents = {
					type = 'toggle',
					order = 1,
					width = "double",
					name = FDP_OPTION_REAGENTS,
					arg = "Reagents",
				},
				items = {
					type = 'toggle',
					order = 2,
					width = "double",
					name = FDP_OPTION_ITEMS,
					arg = "Items",
				},
				itemid = {
					type = 'toggle',
					order = 3,
					width = "double",
					name = FDP_OPTION_VERBOSE,
					arg = "Verbose",
				},
			},
		},
	},
}
local profileDefault = {
	Reagents = true,
	Items = true,
	Verbose = true,
}
local defaults = {}
defaults.profile = profileDefault

function GFW_DisenchantPredictor:SetupOptions()
	-- Inject profile options
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profile.order = -2
	
	-- Register options table
	AceConfig:RegisterOptionsTable("GFW_DisenchantPredictor", options)
	
	local title = GetAddOnMetadata("GFW_DisenchantPredictor", "Title");
	title = string.gsub(title, "Fizzwidget", "GFW");		-- shorter so it fits in the list width
	local version = GetAddOnMetadata("GFW_DisenchantPredictor", "Version");
	local titleText = title .. " " .. version;

	-- Setup Blizzard option frames
	self.optionsFrames = {}
	-- The ordering here matters, it determines the order in the Blizzard Interface Options
	self.optionsFrames.general = AceConfigDialog:AddToBlizOptions("GFW_DisenchantPredictor", titleText, nil, "general")
	self.optionsFrames.profile = AceConfigDialog:AddToBlizOptions("GFW_DisenchantPredictor", FDP_OPTIONS_PROFILE, titleText, "profile")
end

function GFW_DisenchantPredictor:OnInitialize()

	local version = GetAddOnMetadata("GFW_DisenchantPredictor", "Version");
	self.version = version.." (r"..gsub("$Revision: 688 $", "(%d+)", "%1")..")"

	-- Create DB
	self.db = AceDB:New("GFW_DisenchantPredictor_DB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	FDP_Config = self.db.profile

	self:SetupOptions()
end

function GFW_DisenchantPredictor:ShowConfig()
	-- Open the profiles tab before, so the menu expands
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.profile)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.general)
end

------------------------------------------------------
-- Runtime loading
------------------------------------------------------

FDP_OnLoad();

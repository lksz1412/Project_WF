local AceHook = LibStub("AceHook-3.0");
local format = string.format;
local unpack = unpack;
local gtt = GameTooltip;
local bptt = BattlePetTooltip;
local fbptt = FloatingBattlePetTooltip;
local pjpatt = PetJournalPrimaryAbilityTooltip;
local pjsatt = PetJournalSecondaryAbilityTooltip;
local fpbatt = FloatingPetBattleAbilityTooltip;
local ejtt = EncounterJournalTooltip;

-- classic support
local isWoWClassic, isWoWBcc, isWoWWotlkc, isWoWSl, isWoWRetail = false, false, false, false, false;
if (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_CLASSIC"]) then
	isWoWClassic = true;
elseif (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_BURNING_CRUSADE_CLASSIC"]) then
	isWoWBcc = true;
elseif (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_WRATH_CLASSIC"]) then
	isWoWWotlkc = true;
else -- retail
	if (_G["LE_EXPANSION_LEVEL_CURRENT"] == _G["LE_EXPANSION_SHADOWLANDS"]) then
		isWoWSl = true;
	else
		isWoWRetail = true;
	end
end

local CreateColorFromHexString = CreateColorFromHexString;

if (not CreateColorFromHexString) then
	CreateColorFromHexString = function(hexColor)
		return CreateColor(tonumber(hexColor:sub(3, 4), 16) / 255, tonumber(hexColor:sub(5, 6), 16) / 255, tonumber(hexColor:sub(7, 8), 16) / 255, tonumber(hexColor:sub(1, 2), 16) / 255);
	end
end

local GetSpellLink = GetSpellLink;

if (isWoWClassic) then
	GetSpellLink = function(spellID)
		local name, _, icon, castTime, minRange, maxRange, _spellID = GetSpellInfo(spellID);	-- [18.07.19] 8.0/BfA: 2nd param "rank/nameSubtext" now returns nil
		return format("|c%s|Hspell:%d:0|h[%s]|h|r", "FF71D5FF", spellID, name);
	end
end

local C_CurrencyInfo_GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink;

if (not C_CurrencyInfo_GetCurrencyLink) then
	C_CurrencyInfo_GetCurrencyLink = GetCurrencyLink;
end

local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest;

if (not C_QuestLog_GetSelectedQuest) then
	C_QuestLog_GetSelectedQuest = function()
		local index = GetQuestLogSelection();
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(index);
		return questID;
	end
end

-- Addon
local modName = ...;
local ttif = CreateFrame("Frame", modName);

-- Register with TipTac core addon if available
if (TipTac) then
	TipTac:RegisterElement(ttif,"ItemRef");
end

-- Default Config
local cfg;
local TTIF_DefaultConfig = {
	if_enable = true,
	if_infoColor = { 0.2, 0.6, 1 },

	if_itemQualityBorder = true,
	if_showItemLevel = false,					-- Used to be true, but changed due to the itemLevel issues
	if_showItemId = false,
--	if_showKeystoneRewardLevel = true,
--	if_showKeystoneTimeLimit = true,
--	if_showKeystoneAffixInfo = true,
	if_modifyKeystoneTips = true,
	if_spellColoredBorder = true,
	if_showSpellIdAndRank = false,
--	if_auraSpellColoredBorder = true,
	if_showAuraSpellIdAndRank = false,
--	if_showMawPowerId = false,
	if_showAuraCaster = true,
--	if_questDifficultyBorder = true,
	if_showQuestLevel = false,
	if_showQuestId = false,
--	if_currencyQualityBorder = true,
	if_showCurrencyId = false,
	if_achievmentColoredBorder = true,
	if_showAchievementIdAndCategoryId = false,
	if_modifyAchievementTips = true,
--	if_battlePetQualityBorder = true,
	if_showBattlePetLevel = false,
	if_showBattlePetId = false,
--	if_battlePetAbilityColoredBorder = true,
	if_showBattlePetAbilityId = false,
--	if_transmogAppearanceItemQualityBorder = true,	
--	if_showTransmogAppearanceItemId = false,
--	if_transmogIllusionColoredBorder = true,
--	if_showTransmogIllusionId = false,
--	if_transmogSetQualityBorder = true,
--	if_showTransmogSetId = false,	
--	if_conduitQualityBorder = true,
--	if_showConduitItemLevel = false,
--	if_showConduitId = false,
--	if_azeriteEssenceQualityBorder = true,
--	if_showAzeriteEssenceId = false,
	if_runeforgePowerColoredBorder = false,
	if_showRuneforgePowerId = false,
--	if_flyoutColoredBorder = true,
	if_showFlyoutId = false,
--	if_petActionColoredBorder = true,
	if_showPetActionId = false,

	if_wccc = false, -- 색약 보정
	if_etcinfo = false, -- 아이템 추가 정보
	if_showIcon = true,
	if_smartIcons = true,
	if_inIcon = false, -- 속성 아이콘 툴팁 내부표시 기본값
	if_qIcon = false, -- 퀘스트 아이콘
	if_bIcon = false, -- 아이템 속성 아이콘
	if_borderlessIcons = false,
	if_iconSize = 35, -- 기본값 변경 (기본값 42)
	if_itemStackCount = false,  -- 아이템 겹침 수량 표시 기본값 추가	
	if_IconPosition = "LEFT",  -- 툴팁 아이콘 위치 기본값 추가
};

-- Tooltips to Hook into -- MUST be a GameTooltip widget -- If the main TipTac is installed, the TT_TipsToModify is used instead
local tipsToModify = {
	"GameTooltip",
	"ItemRefTooltip",
	"NamePlateTooltip",
	"BattlePetTooltip",
	"FloatingBattlePetTooltip",
	"PetJournalPrimaryAbilityTooltip",
	"PetJournalSecondaryAbilityTooltip",
	"FloatingPetBattleAbilityTooltip",
	--"EncounterJournalTooltip", -- commented out for embedded tooltips, see description in tt:SetPadding()
	-- 3rd party addon tooltips
	"PlaterNamePlateAuraTooltip",
};

local addOnsLoaded = {
	["TipTacItemRef"] = false,
	["Blizzard_AchievementUI"] = false,
	["Blizzard_Collections"] = false,
	["Blizzard_Communities"] = false,
	["Blizzard_EncounterJournal"] = false,
	["Blizzard_GuildUI"] = false,
	["Blizzard_PlayerChoice"] = false,
	["Blizzard_PVPUI"] = false,
	["WorldQuestTracker"] = false
};

-- Tips which will have an icon
local tipsToAddIcon = {
	["GameTooltip"] = true,
	["ShoppingTooltip1"] = true,
	["ShoppingTooltip2"] = true,
	["ItemRefTooltip"] = true,
	["ItemRefShoppingTooltip1"] = true,
	["ItemRefShoppingTooltip2"] = true,
	["BattlePetTooltip"] = true,
	["FloatingBattlePetTooltip"] = true,
	["PetJournalPrimaryAbilityTooltip"] = true,
	["PetJournalSecondaryAbilityTooltip"] = true,
	["FloatingPetBattleAbilityTooltip"] = true,
	--["EncounterJournalTooltip"] = true, -- commented out for embedded tooltips, see description in tt:SetPadding()
};

-- Tables
local LinkTypeFuncs = {};
local CustomTypeFuncs = {};
local criteriaList = {};	-- Used for Achievement criterias
local tipDataAdded = {};	-- Sometimes, OnTooltipSetItem/Spell is called before the tip has been filled using SetHyperlink, we use the array to test if the tooltip has had data added

-- Colors for achivements
local COLOR_COMPLETE = { 0.25, 0.75, 0.25 };
local COLOR_INCOMPLETE = { 0.5, 0.5, 0.5 };

-- Colored text string (red/green)
local BoolCol = { [false] = "|cffff8080", [true] = "|cff80ff80" };

--------------------------------------------------------------------------------------------------------
--                                          Helper Functions                                          --
--------------------------------------------------------------------------------------------------------

-- Get displayed item
function ttif:GetDisplayedItem(tooltip)
	if (tooltip.GetItem) then
		return tooltip:GetItem();
	else
		return TooltipUtil.GetDisplayedItem(tooltip);
	end
end

-- Get displayed spell
function ttif:GetDisplayedSpell(tooltip)
	if (tooltip.GetSpell) then
		return tooltip:GetSpell();
	else
		return TooltipUtil.GetDisplayedSpell(tooltip);
	end
end

--------------------------------------------------------------------------------------------------------
--                                         Create Tooltip Icon                                        --
--------------------------------------------------------------------------------------------------------

-- Set Texture and Text
local function ttSetIconTextureAndText(self, texture, count)
	if (texture) then
		self.ttIcon:SetTexture(texture ~= "" and texture or "Interface\\Icons\\INV_Misc_QuestionMark");
		if (count) and (count ~= "") and (tonumber(count) > 0) then
			self.ttCount:SetText(count);
		else
			self.ttCount:SetText("");
		end
		self.ttIcon:Show();
	else
		self.ttIcon:Hide();
		self.ttCount:SetText("");
	end
end

-- Create Icon with Counter Text for Tooltip
function ttif:CreateTooltipIcon(tip)
	tip.ttIcon = tip:CreateTexture(nil,"BACKGROUND");
	-- 아이콘 위치 지정 추가 시작
	if (cfg.if_IconPosition == "LEFT") then
		tip.ttIcon:SetPoint("TOPRIGHT",tip,"TOPLEFT",1,-2.5);
		tip.ttIcon:Hide();
	else
		tip.ttIcon:SetPoint("BOTTOMLEFT",tip,"TOPLEFT",2,-1);	
		tip.ttIcon:Hide();
	end
	-- 아이콘 위치 지정 추가 끝
	tip.ttCount = tip:CreateFontString(nil,"ARTWORK");
	tip.ttCount:SetTextColor(1,1,0.1); -- 숫자 색상 조절 (최대 겹침수량이라는 것을 구분짓기 위함)
	tip.ttCount:SetPoint("BOTTOMRIGHT",tip.ttIcon,"BOTTOMRIGHT",-1, 1); -- 숫자 위치 조절
end

--------------------------------------------------------------------------------------------------------
--                                         TipTacItemRef Frame                                        --
--------------------------------------------------------------------------------------------------------

ttif:SetScript("OnEvent",function(self,event,...) self[event](self,event,...); end);

ttif:RegisterEvent("VARIABLES_LOADED");
ttif:RegisterEvent("ADDON_LOADED");

-- Resolves the given table array of string names into their global objects
local function ResolveGlobalNamedObjects(tipTable)
	local resolved = {};
	for index, tipName in ipairs(tipTable) do
		-- lookup the global object from this name, assign false if nonexistent, to preserve the table entry
		if (type(tipName) == "string") then
			local tip = (_G[tipName] or false);

			-- Check if this object has already been resolved. This can happen for thing like AtlasLoot, which sets AtlasLootTooltip = GameTooltip
			if (resolved[tip]) then
				tip = false;
			elseif (tip) then
				if (type(tip) == "table" and BackdropTemplateMixin and "BackdropTemplate") then
					Mixin(tip, BackdropTemplateMixin);
					if (tip.NineSlice) then
						Mixin(tip.NineSlice, BackdropTemplateMixin);
					end
				end
				resolved[tip] = index;
			end

			-- Assign the resolved object or false back into the table array
			tipTable[index] = tip;
		end
	end
end

-- Chain config tables
local function ChainConfigTables(config, defaults)
	local config_metatable_org = getmetatable(config);
	
	return setmetatable(config, {
		__index = function(tab, index)
			local value = defaults[index];
			
			if (value) then
				return value;
			end
			
			if (not config_metatable_org) then
				return nil;
			end
			
			local config_metatable_org__index = config_metatable_org.__index;
			
			if (not config_metatable_org__index) then
				return nil;
			end
			
			if (type(config_metatable_org__index) == "table") then
				return config_metatable_org__index[index];
			end
			
			return config_metatable_org__index(tab, index);
		end
	});
end

-- Variables Loaded [One-Time-Event]
function ttif:VARIABLES_LOADED(event)
	-- What tipsToModify to use, TipTac's main addon, or our own?
	if (TipTac and TipTac.tipsToModify) then
		tipsToModify = TipTac.tipsToModify;
	end

	-- Use TipTac settings if installed
	if (TipTac_Config) then
		cfg = ChainConfigTables(TipTac_Config, TTIF_DefaultConfig);
	else
		cfg = TTIF_DefaultConfig;
	end

	-- Hook Tips & Apply Settings
	self:HookTips();
	self:OnApplyConfig();
	
	-- Re-Trigger event ADDON_LOADED for TipTacItemRef if config wasn't ready
	self:ADDON_LOADED("ADDON_LOADED", "TipTacItemRef");

	-- Cleanup
	self:UnregisterEvent(event);
	self[event] = nil;
end

--------------------------------------------------------------------------------------------------------
--                                           Element Events                                           --
--------------------------------------------------------------------------------------------------------

-- Apply Settings -- It seems this may be called from TipTac:OnApplyConfig() before we have received our VARIABLES_LOADED, so ensure we have created the tip objects
function ttif:OnApplyConfig()
	local gameFont = GameFontNormal:GetFont();
	for index, tip in ipairs(tipsToModify) do
		if (type(tip) == "table") and (tipsToAddIcon[tip:GetName()]) and (tip.ttIcon) then
			if (cfg.if_showIcon) then
				tip.ttIcon:SetSize(cfg.if_iconSize, cfg.if_iconSize);
				tip.ttCount:SetFont(gameFont, (cfg.if_iconSize / 3), "OUTLINE");
				tip.ttSetIconTextureAndText = ttSetIconTextureAndText;
				if (cfg.if_borderlessIcons) then
					tip.ttIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93);
				else
					tip.ttIcon:SetTexCoord(0, 1, 0, 1);
				end
				tip.ttIcon:ClearAllPoints();
			-- 애드온 재시작 없이 아이콘 위치 변경 가능하도록 추가 시작
				if (cfg.if_IconPosition == "LEFT") then
					tip.ttIcon:SetPoint("TOPRIGHT",tip,"TOPLEFT",1,-2.5);
				else
					tip.ttIcon:SetPoint("BOTTOMLEFT",tip,"TOPLEFT",2,-1);	
				end
			-- 애드온 재시작 없이 아이콘 위치 변경 가능하도록 추가 끝		
			elseif (tip.ttSetIconTextureAndText) then
				tip.ttIcon:Hide();
				tip.ttSetIconTextureAndText = nil;
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------
--                                       HOOK: Tooltip Functions                                      --
--------------------------------------------------------------------------------------------------------

-- apply workaround for the following "bug": on first mouseover over toy or unit aura after starting the game the gtt will be cleared (OnTooltipCleared) and internally set again. There ist no immediately following SetToyByItemID(), SetAction(), SetUnitAura() or SetAzeriteEssence() (only approx. 0.2-1 second later), but on the next OnUpdate the GetItem() aka TooltipUtil.GetDisplayedItem() is set again.
-- ttWorkaroundForFirstMouseoverStatus:
-- nil = no hooks applied (uninitialized)
-- 0   = hooks applied (initialized)
-- 1   = waiting for GameTooltip:OnTooltipCleared (armed, 1st stage)
-- 2   = waiting for GameTooltip:OnUpdate (armed, 2nd stage)
-- 3   = tooltip modification reapplied (triggered)
function ttif:ApplyWorkaroundForFirstMouseover(self, isAura, source, link, linkType, id, rank)
	local tooltip = self;
	
	-- functions
	local resetVarsFn = function(tooltip)
		tooltip.ttWorkaroundForFirstMouseoverStatus = 0; -- initialized
		tooltip.ttWorkaroundForFirstMouseoverID = nil;
		tooltip.ttWorkaroundForFirstMouseoverRank = nil;
		tooltip.ttWorkaroundForFirstMouseoverOwner = nil;
	end
	
	local initVarsFn = function(tooltip, id, rank, owner)
		tooltip.ttWorkaroundForFirstMouseoverStatus = 1; -- armed, 1st stage
		tooltip.ttWorkaroundForFirstMouseoverID = id;
		tooltip.ttWorkaroundForFirstMouseoverRank = rank;
		tooltip.ttWorkaroundForFirstMouseoverOwner = owner;
	end
	
	local reapplyTooltipModificationFn = function(tooltip)
		tipDataAdded[tooltip] = linkType;
		if (linkType == "spell") then
			LinkTypeFuncs.spell(tooltip, isAura, source, link, linkType, tooltip.ttWorkaroundForFirstMouseoverID);
		elseif (linkType == "azessence") then
			LinkTypeFuncs.azessence(tooltip, link, linkType, tooltip.ttWorkaroundForFirstMouseoverID, tooltip.ttWorkaroundForFirstMouseoverRank);
		else
			LinkTypeFuncs.item(tooltip, link, linkType, tooltip.ttWorkaroundForFirstMouseoverID);
		end
	end
	
	-- apply hooks
	if (not tooltip.ttWorkaroundForFirstMouseoverStatus) then -- nil = uninitialized
		AceHook:SecureHookScript(tooltip, "OnTooltipCleared", function(tooltip)
			if (tooltip.ttWorkaroundForFirstMouseoverStatus == 1) then -- armed, 1st stage
				if (tooltip:GetOwner() ~= tooltip.ttWorkaroundForFirstMouseoverOwner) then
					resetVarsFn(tooltip); -- 0 = initialized
					return;
				end
				tooltip.ttWorkaroundForFirstMouseoverStatus = 2; -- armed, 2nd stage
			end
		end);
		
		AceHook:SecureHookScript(tooltip, "OnUpdate", function(tooltip)
			if (tooltip.ttWorkaroundForFirstMouseoverStatus == 2) then -- armed, 2nd stage
				reapplyTooltipModificationFn(tooltip);
				tooltip.ttWorkaroundForFirstMouseoverStatus = 3; -- triggered
			end
		end);
		
		AceHook:SecureHookScript(tooltip, "OnHide", function(tooltip)
			resetVarsFn(tooltip); -- 0 = initialized
		end);
		
		resetVarsFn(tooltip); -- 0 = initialized
	end
	
	if (tooltip.ttWorkaroundForFirstMouseoverStatus == 0) or (tooltip.ttWorkaroundForFirstMouseoverID ~= id) or (owner ~= tooltip.ttWorkaroundForFirstMouseoverOwner) then
		initVarsFn(tooltip, id, rank, tooltip:GetOwner()); -- 1 = armed, 1st stage
	else
		tooltip.ttWorkaroundForFirstMouseoverStatus = 3; -- triggered
	end
end

-- add text line to PetJournalPrimaryAbilityTooltip, PetJournalSecondaryAbilityTooltip, FloatingPetBattleAbilityTooltip and EncounterJournalTooltip (see BattlePetTooltipTemplate_AddTextLine() in "FloatingPetBattleTooltip.lua")
local function PJATT_EJTT_AddTextLine(self, text, r, g, b, wrap)
	local linePadding = 2;
	local anchorXOfs = 0;
	local anchorYOfs = 0;
	local anchorXOfsWrap = 0;
	
	if not r then
		r, g, b = NORMAL_FONT_COLOR:GetRGB();
	end
	
	local anchor = self.textLineAnchor;
	if not anchor then
		if (self == pjpatt or self == pjsatt or self == fpbatt) then
			anchor = self.bottomFrame;
			linePadding = 5;
			anchorXOfsWrap = -10;
		elseif (self == ejtt) then
			if (self.Item2:IsShown()) then
				anchor = self.Item2;
			else
				anchor = self.Item1.tooltip;
			end
			anchorXOfs = 10; -- see AdventureJournal_Reward_OnEnter() in "Blizzard_EncounterJournal/Blizzard_EncounterJournal.lua"
			anchorYOfs = 6;
		end
	end
	
	local line = self.linePool:Acquire();
	line:SetText(text);
	line:SetTextColor(r, g, b);
	line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchorXOfs, -linePadding + anchorYOfs);
	
	if wrap then
		line:SetPoint("RIGHT", self, "RIGHT", anchorXOfsWrap, -linePadding + anchorYOfs);
	end
	
	line:Show();
	
	self.textLineAnchor = line;
	
	self:SetHeight(self:GetHeight() + line:GetHeight() + linePadding);
	
	if (self == pjpatt or self == pjsatt or self == fpbatt) then
		self.bottomFrame = line;
	end
end

-- HOOK: PetJournalPrimaryAbilityTooltip:OnLoad + PetJournalSecondaryAbilityTooltip:OnLoad + FloatingPetBattleAbilityTooltip:OnLoad + EncounterJournalTooltip:OnLoad (see BattlePetTooltip_OnLoad() in "FloatingPetBattleTooltip.lua")
local function PJATT_EJTT_OnLoad_Hook(self)
	local subLayer = 0;
	self.linePool = CreateFontStringPool(self, "ARTWORK", subLayer, "GameTooltipText");
	self.AddLine = PJATT_EJTT_AddTextLine;
end

-- HOOK: PetJournalPrimaryAbilityTooltip:OnShow + PetJournalSecondaryAbilityTooltip:OnShow + FloatingPetBattleAbilityTooltip:OnShow + EncounterJournalTooltip:OnShow (see BattlePetTooltipTemplate_SetBattlePet() in "FloatingPetBattleTooltip.lua")
local function PJATT_EJTT_OnShow_Hook(self)
	self.linePool:ReleaseAll();
	self.textLineAnchor = nil;
end

--
-- main hooking functions
-- 

-- HOOK: ItemRefTooltip + GameTooltip:SetHyperlink
function ttif:SetHyperlink_Hook(self, hyperlink)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local refString = hyperlink:match("|H([^|]+)|h") or hyperlink;
		local linkType = refString:match("^[^:]+");
		-- Call Tip Type Func
		if (LinkTypeFuncs[linkType]) and (self:NumLines() > 0) then
			tipDataAdded[self] = "hyperlink";
			if (linkType == "spell") then
				LinkTypeFuncs.spell(self, false, nil, refString, (":"):split(refString));
			elseif (linkType == "azessence") then
				local _linkType, essenceID, essenceRank = (":"):split(refString);
				local link = C_AzeriteEssence.GetEssenceHyperlink(essenceID, essenceRank);
				if (link) then
					local linkType, _essenceID, _essenceRank = link:match("H?(%a+):(%d+):(%d+)");
					if (_essenceID) then
						tipDataAdded[self] = linkType;
						LinkTypeFuncs.azessence(self, link, linkType, _essenceID, _essenceRank);

						-- apply workaround for first mouseover
						ttif:ApplyWorkaroundForFirstMouseover(self, false, nil, link, linkType, _essenceID, _essenceRank);
					end
				end
			else
				LinkTypeFuncs[linkType](self, refString, (":"):split(refString));
			end
		end
	end
end

-- HOOK: SetUnitAura
local function SetUnitAura_Hook(self, unit, index, filter)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod =  UnitAura(unit, index, filter); -- [18.07.19] 8.0/BfA: "dropped second parameter"
		if (spellID) then
			local link = GetSpellLink(spellID);
			if (link) then
				local linkType, _spellID = link:match("H?(%a+):(%d+)");
				if (_spellID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.spell(self, true, source, link, linkType, _spellID);

					-- apply workaround for first mouseover
					ttif:ApplyWorkaroundForFirstMouseover(self, true, source, link, linkType, _spellID);
				end
			end
		end
	end
end

-- HOOK: GameTooltip:SetCompanionPet
local function SetCompanionPet_Hook(self, petID)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByPetID(petID);
		if (speciesID) then
			local health, maxHealth, power, speed, breedQuality = C_PetJournal.GetPetStats(petID);
			tipDataAdded[self] = "battlepet";
			LinkTypeFuncs.battlepet(self, nil, "battlepet", speciesID, level, breedQuality and breedQuality - 1 or 0, maxHealth, power, speed, nil, displayID);
		end
	end
end

-- HOOK: ItemRefTooltip + GameTooltip:SetAction
local function SetAction_Hook(self, slot)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local actionType, id, subType = GetActionInfo(slot);
		if (actionType == "spell" and subType == "pet") then
			local line = _G[self:GetName().."TextLeft1"]; -- id is always 0. as a workaround find pet action in pet spell book by name.
			local name = line and (line:GetText() or "");
			if (name ~= "" and PetHasSpellbook()) then
				local numPetSpells, petToken = HasPetSpells(); -- returns numPetSpells = nil for feral spirit (shaman wolves) in wotlkc
				
				if (numPetSpells) then
					for i = 1, numPetSpells do
						local spellType, _id = GetSpellBookItemInfo(i, BOOKTYPE_PET); -- see SpellButton_OnEnter() in "SpellBookFrame.lua"
						if (spellType == "PETACTION") then
							local spellName, spellSubName, spellID = GetSpellBookItemName(i, BOOKTYPE_PET);
							if (spellName == name) then
								local icon = GetSpellBookItemTexture(i, BOOKTYPE_PET);
								tipDataAdded[self] = "petAction";
								CustomTypeFuncs.petAction(self, nil, "petAction", _id, icon);
								break;
							end
						end
					end
				end
			end
			
			if (not tipDataAdded[self]) then -- fallback if pet action was not found in pet spell book by name.
				local icon = GetActionTexture(slot);
				tipDataAdded[self] = "petAction";
				CustomTypeFuncs.petAction(self, nil, "petAction", nil, icon);
			end
		elseif (actionType == "item") then
			local name, link = ttif:GetDisplayedItem(self);
			if (link) then
				local linkType, itemID = link:match("H?(%a+):(%d+)");
				if (itemID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.item(self, link, linkType, itemID);
					
					-- apply workaround for first mouseover if item is a toy
					if (C_ToyBox) then
						_itemID, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(itemID);
						
						if (_itemID) then
							ttif:ApplyWorkaroundForFirstMouseover(self, false, nil, link, linkType, itemID);
						end
					end
				end
			end
		elseif (actionType == "summonpet") then
			local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByPetID(id);
			if (speciesID) then
				local health, maxHealth, power, speed, breedQuality = C_PetJournal.GetPetStats(id);
				tipDataAdded[self] = "battlepet";
				LinkTypeFuncs.battlepet(self, nil, "battlepet", speciesID, level, breedQuality and breedQuality - 1 or 0, maxHealth, power, speed, nil, displayID);
			end
		elseif (actionType == "flyout") then
			local icon = GetActionTexture(slot);
			tipDataAdded[self] = "flyout";
			CustomTypeFuncs.flyout(self, nil, "flyout", id, icon);
		elseif (actionType == "macro") then
			local spellID = GetMacroSpell(id);
			if (spellID) then
				local link = GetSpellLink(spellID);
				if (link) then
					local linkType, _spellID = link:match("H?(%a+):(%d+)");
					if (_spellID) then
						tipDataAdded[self] = linkType;
						LinkTypeFuncs.spell(self, false, nil, link, linkType, _spellID);
					end
				end
			end
		end
	end
end

-- HOOK: GameTooltip:SetSpellBookItem
local function SetSpellBookItem_Hook(self, slot, bookType)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local spellType, id = GetSpellBookItemInfo(slot, bookType); -- see SpellButton_OnEnter() in "SpellBookFrame.lua"
		if (spellType == "FLYOUT") then
			local icon = GetSpellBookItemTexture(slot, bookType);
			tipDataAdded[self] = "flyout";
			CustomTypeFuncs.flyout(self, nil, "flyout", id, icon);
		elseif (spellType == "PETACTION") then
			local icon = GetSpellBookItemTexture(slot, bookType);
			tipDataAdded[self] = "petAction";
			CustomTypeFuncs.petAction(self, nil, "petAction", id, icon);
		end
	end
end

-- HOOK: GameTooltip:SetPetAction
local function SetPetAction_Hook(self, slot)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(slot); -- see PetActionBar_Update() in "PetActionBarFrame.lua"
		if (spellID) then
			local link = GetSpellLink(spellID);
			if (link) then
				local linkType, _spellID = link:match("H?(%a+):(%d+)");
				if (spellID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.spell(self, false, nil, link, linkType, _spellID);
				end
			end
		else
			local _name, icon;
			if (isToken) then
				_name = _G[name];
				icon = _G[texture];
			else
				_name = name;
				icon = texture;
			end
			
			if (_name ~= "" and PetHasSpellbook()) then -- id is missing. as a workaround find pet action in pet spell book by name.
				local numPetSpells, petToken = HasPetSpells(); -- returns numPetSpells = nil for feral spirit (shaman wolves) in wotlkc
				
				if (numPetSpells) then
					for i = 1, numPetSpells do
						local spellType, id = GetSpellBookItemInfo(i, BOOKTYPE_PET); -- see SpellButton_OnEnter() in "SpellBookFrame.lua"
						if (spellType == "PETACTION") then
							local spellName, spellSubName, spellID = GetSpellBookItemName(i, BOOKTYPE_PET);
							if (spellName == _name) then
								tipDataAdded[self] = "petAction";
								CustomTypeFuncs.petAction(self, nil, "petAction", id, icon);
								break;
							end
						end
					end
				end
			end
			
			if (not tipDataAdded[self]) then -- fallback if pet action was not found in pet spell book by name.
				tipDataAdded[self] = "petAction";
				CustomTypeFuncs.petAction(self, nil, "petAction", nil, icon);
			end
		end
	end
end

-- HOOK: GameTooltip:SetQuestItem
local function SetQuestItem_Hook(self, _type, index)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, texture, numItems, quality, isUsable, itemID = GetQuestItemInfo(_type, index); -- see QuestInfoRewardItemCodeTemplate_OnEnter() in "QuestInfo.lua"
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID);
		if (itemLink) then
			local linkType, _itemID = itemLink:match("H?(%a+):(%d+)");
			if (_itemID) then
				tipDataAdded[gtt] = linkType;
				LinkTypeFuncs.item(gtt, itemLink, linkType, _itemID);
			end
		end
	end
end

-- HOOK: GameTooltip:SetQuestLogItem
local function SetQuestLogItem_Hook(self, _type, index)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local isChoice = (_type == "choice"); -- see QuestInfoRewardItemCodeTemplate_OnEnter() in "QuestInfo.lua"
		local itemID, numItems;
		if (isChoice) then
			local name, texture, _numItems, quality, isUsable, _itemID = GetQuestLogChoiceInfo(index);
			itemID = _itemID;
			numItems = _numItems;
		else
			local name, texture, _numItems, quality, isUsable, _itemID, itemLevel = GetQuestLogRewardInfo(index);
			itemID = _itemID;
			numItems = _numItems;
		end
		local itemName, itemLink, itemRarity, _itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID);
		if (itemLink) then
			local linkType, __itemID = itemLink:match("H?(%a+):(%d+)");
			if (__itemID) then
				tipDataAdded[gtt] = linkType;
				LinkTypeFuncs.item(gtt, itemLink, linkType, __itemID);
			end
		end
	end
end

-- HOOK: GameTooltip:SetQuestCurrency
local function SetQuestCurrency_Hook(self, _type, index)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local currencyID = GetQuestCurrencyID(_type, index); -- see QuestInfoRewardItemCodeTemplate_OnEnter() in "QuestInfo.lua"
		local name, texture, quantity, quality = GetQuestCurrencyInfo(_type, index);
		local link = C_CurrencyInfo_GetCurrencyLink(currencyID, quantity);
		if (link) then
			local linkType, _currencyID, _quantity = link:match("H?(%a+):(%d+):(%d+)");
			if (_currencyID) then
				tipDataAdded[gtt] = linkType;
				LinkTypeFuncs.currency(gtt, link, linkType, _currencyID, _quantity);
			end
		end
	end
end

-- HOOK: GameTooltip:SetQuestLogCurrency
local function SetQuestLogCurrency_Hook(self, _type, index)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local questID = C_QuestLog_GetSelectedQuest(); -- see QuestInfoRewardItemCodeTemplate_OnEnter() in "QuestInfo.lua"
		local isChoice = (_type == "choice");
		local name, texture, quantity, currencyID, quality = GetQuestLogRewardCurrencyInfo(index, questID, isChoice);
		local link = C_CurrencyInfo_GetCurrencyLink(currencyID, quantity);
		if (link) then
			local linkType, _currencyID, _quantity = link:match("H?(%a+):(%d+):(%d+)");
			if (_currencyID) then
				tipDataAdded[gtt] = linkType;
				LinkTypeFuncs.currency(gtt, link, linkType, _currencyID, _quantity);
			end
		end
	end
end

-- HOOK: GameTooltip:SetQuestPartyProgress
local function SetQuestPartyProgress_Hook(self, questID, omitTitle, ignoreActivePlayer)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = GetQuestLink(questID);
		if (link) then
			local level = link:match("H?%a+:%d+:(%d+)");
			LinkTypeFuncs.quest(self, nil, "quest", questID, level);
		else
			LinkTypeFuncs.quest(self, nil, "quest", questID, nil);
		end
		tipDataAdded[self] = "quest";
	end
end

-- HOOK: GameTooltip:SetRecipeReagentItem
local function SetRecipeReagentItem_Hook(self, recipeID, dataSlotIndex)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, dataSlotIndex);
		if (link) then
			local linkType, itemID = link:match("H?(%a+):(%d+)");
			if (itemID) then
				tipDataAdded[self] = linkType;
				LinkTypeFuncs.item(self, link, linkType, itemID);
			end
		end
	end
end

-- HOOK: GameTooltip:SetToyByItemID
local function SetToyByItemID_Hook(self, itemID)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, link = ttif:GetDisplayedItem(self);
		if (link) then
			local linkType, _itemID = link:match("H?(%a+):(%d+)");
			if (_itemID) then
				tipDataAdded[self] = linkType;
				LinkTypeFuncs.item(self, link, linkType, _itemID);
				
				-- apply workaround for first mouseover
				ttif:ApplyWorkaroundForFirstMouseover(self, false, nil, link, linkType, _itemID);
			end
		end
	end
end

-- HOOK: GameTooltip:SetLFGDungeonReward
local function SetLFGDungeonReward_Hook(self, dungeonID, rewardIndex)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, texture, numItems, isBonusReward, rewardType, rewardID, quality = GetLFGDungeonRewardInfo(dungeonID, rewardIndex); -- see LFGDungeonReadyDialogReward_OnEnter in "LFGFrame.lua"
		if (rewardType == "item") then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(rewardID);
			if (itemLink) then
				local linkType, itemID = itemLink:match("H?(%a+):(%d+)");
				if (itemID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.item(self, itemLink, linkType, itemID);
				end
			end
		elseif (rewardType == "currency") then
			local link = C_CurrencyInfo_GetCurrencyLink(rewardID, numItems);
			if (link) then
				local linkType, currencyID, quantity = link:match("H?(%a+):(%d+):(%d+)");
				if (currencyID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.currency(self, link, linkType, currencyID, quantity);
				end
			end
		end
	end
end

-- HOOK: GameTooltip:SetLFGDungeonShortageReward
local function SetLFGDungeonShortageReward_Hook(self, dungeonID, rewardArg, rewardIndex)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, texture, numItems, isBonusReward, rewardType, rewardID, quality = GetLFGDungeonShortageRewardInfo(dungeonID, rewardArg, rewardIndex); -- see LFGDungeonReadyDialogReward_OnEnter in "LFGFrame.lua"
		if (rewardType == "item") then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(rewardID);
			if (itemLink) then
				local linkType, itemID = itemLink:match("H?(%a+):(%d+)");
				if (itemID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.item(self, itemLink, linkType, itemID);
				end
			end
		elseif (rewardType == "currency") then
			local link = C_CurrencyInfo_GetCurrencyLink(rewardID, numItems);
			if (link) then
				local linkType, currencyID, quantity = link:match("H?(%a+):(%d+):(%d+)");
				if (currencyID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.currency(self, link, linkType, currencyID, quantity);
				end
			end
		end
	end
end

-- HOOK: GameTooltip:SetCurrencyByID
local function SetCurrencyByID_Hook(self, currencyID, quantity)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = C_CurrencyInfo_GetCurrencyLink(currencyID, quantity);
		if (link) then
			local linkType, _currencyID, _quantity = link:match("H?(%a+):(%d+):(%d+)");
			if (_currencyID) then
				tipDataAdded[self] = linkType;
				LinkTypeFuncs.currency(self, link, linkType, _currencyID, _quantity);
			end
		end
	end
end

-- HOOK: GameTooltip:SetCurrencyToken
local function SetCurrencyToken_Hook(self, currencyIndex)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = C_CurrencyInfo.GetCurrencyListLink(currencyIndex);
		if (link) then
			local linkType, currencyID, quantity = link:match("H?(%a+):(%d+):(%d+)");
			if (currencyID) then
				tipDataAdded[self] = linkType;
				LinkTypeFuncs.currency(self, link, linkType, currencyID, quantity);
			end
		end
	end
end

-- HOOK: GameTooltip:SetCurrencyTokenByID
local function SetCurrencyTokenByID_Hook(self, currencyID)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = C_CurrencyInfo_GetCurrencyLink(currencyID);
		if (link) then
			local linkType, _currencyID, quantity = link:match("H?(%a+):(%d+):(%d+)");
			if (_currencyID) then
				tipDataAdded[self] = linkType;
				LinkTypeFuncs.currency(self, link, linkType, _currencyID, quantity);
			end
		end
	end
end

-- HOOK: GameTooltip:SetConduit + GameTooltip:SetEnhancedConduit
local function SetConduit_Hook(self, conduitID, conduitRank)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = C_Soulbinds.GetConduitHyperlink(conduitID, conduitRank);
		if (link) then
			local linkType, _conduitID, _conduitRank = link:match("H?(%a+):(%d+):(%d+)");
			if (_conduitID) then
				tipDataAdded[self] = linkType;
				LinkTypeFuncs.conduit(self, link, linkType, _conduitID, _conduitRank);
			end
		end
	end
end

-- HOOK: GameTooltip:SetAzeriteEssence
local function SetAzeriteEssence_Hook(self, essenceID, essenceRank)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = C_AzeriteEssence.GetEssenceHyperlink(essenceID, essenceRank);
		if (link) then
			local linkType, _essenceID, _essenceRank = link:match("H?(%a+):(%d+):(%d+)");
			if (_essenceID) then
				tipDataAdded[self] = linkType;
				LinkTypeFuncs.azessence(self, link, linkType, _essenceID, _essenceRank);

				-- apply workaround for first mouseover
				ttif:ApplyWorkaroundForFirstMouseover(self, false, nil, link, linkType, _essenceID, _essenceRank);
			end
		end
	end
end

-- HOOK: GameTooltip:SetAzeriteEssenceSlot
local function SetAzeriteEssenceSlot_Hook(self, slot)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local milestones = C_AzeriteEssence.GetMilestones();
		
		for i, milestoneInfo in ipairs(milestones) do
			if (milestoneInfo.slot == slot) then
				if (not milestoneInfo.unlocked) then
					break;
				end
				
				local milestoneID = milestoneInfo.ID;
				local essenceID = C_AzeriteEssence.GetMilestoneEssence(milestoneID);
				local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
				local essenceRank = essenceInfo.rank;
				
				local link = C_AzeriteEssence.GetEssenceHyperlink(essenceID, essenceRank);
				if (link) then
					local linkType, _essenceID, _essenceRank = link:match("H?(%a+):(%d+):(%d+)");
					if (_essenceID) then
						tipDataAdded[self] = linkType;
						LinkTypeFuncs.azessence(self, link, linkType, _essenceID, _essenceRank);

						-- apply workaround for first mouseover
						ttif:ApplyWorkaroundForFirstMouseover(self, false, nil, link, linkType, _essenceID, _essenceRank);
					end
				end
				
				break;
			end
		end
	end
end

-- HOOK: BattlePetToolTip_Show
local function BPTT_Show_Hook(speciesID, level, breedQuality, maxHealth, power, speed, customName)
	if (cfg.if_enable) and (not tipDataAdded[bptt]) and (bptt:IsShown()) then
		tipDataAdded[bptt] = "battlepet";
		local speciesName, speciesIcon, petType, creatureID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, displayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
		LinkTypeFuncs.battlepet(bptt, nil, "battlepet", speciesID, level, breedQuality, maxHealth, power, speed, nil, displayID);
	end
end

-- HOOK: FloatingBattlePet_Show
local function FBP_Show_Hook(speciesID, level, breedQuality, maxHealth, power, speed, customName, petID)
	if (cfg.if_enable) and (not tipDataAdded[fbptt]) and (fbptt:IsShown()) then
		local speciesName, speciesIcon, petType, creatureID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, displayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
		LinkTypeFuncs.battlepet(fbptt, nil, "battlepet", speciesID, level, breedQuality, maxHealth, power, speed, nil, displayID);
	end
end

-- HOOK: PetJournal_ShowAbilityTooltip
local function PJ_ShowAbilityTooltip_Hook(self, abilityID, speciesID, petID, additionalText)
	if (cfg.if_enable) and (not tipDataAdded[pjpatt]) and (pjpatt:IsShown()) then
		tipDataAdded[pjpatt] = "battlePetAbil";
		LinkTypeFuncs.battlePetAbil(pjpatt, nil, "battlePetAbil", abilityID, speciesID, petID, additionalText);
	end
end

-- HOOK: PetJournal_ShowAbilityCompareTooltip
local function PJ_ShowAbilityCompareTooltip_Hook(abilityID1, abilityID2, speciesID, petID)
	if (cfg.if_enable) then
		if (not tipDataAdded[pjpatt]) and (pjpatt:IsShown()) then
			tipDataAdded[pjpatt] = "battlePetAbil";
			LinkTypeFuncs.battlePetAbil(pjpatt, nil, "battlePetAbil", abilityID1, speciesID, petID, nil);
		end
		if (not tipDataAdded[pjsatt]) and (pjsatt:IsShown()) then
			tipDataAdded[pjsatt] = "battlePetAbil";
			LinkTypeFuncs.battlePetAbil(pjsatt, nil, "battlePetAbil", abilityID2, speciesID, petID, nil);
		end
	end
end

-- HOOK: FloatingPetBattleAbility_Show
local function FPBA_Show_Hook(abilityID, maxHealth, power, speed)
	if (cfg.if_enable) and (fpbatt:IsShown()) then
		if (tipDataAdded[fpbatt]) then -- fire OnShow handler if hyperlink clicked repeatedly. The FloatingPetBattleAbilityTooltip doesn't toggle the tooltip like a FloatingBattlePetTooltip.
			PJATT_EJTT_OnShow_Hook(fpbatt);
		end
		tipDataAdded[fpbatt] = "battlePetAbil";
		LinkTypeFuncs.battlePetAbil(fpbatt, nil, "battlePetAbil", abilityID, nil, nil, nil);
	end
end

-- OnTooltipSetItem
local function OnTooltipSetItem(self,...)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, link = ttif:GetDisplayedItem(self);
		if (link) then
			local linkType, itemID = link:match("H?(%a+):(%d+)");
			if (itemID) then
				tipDataAdded[self] = linkType;
				if (linkType == "keystone") then
					local refString = link:match("|H([^|]+)|h") or link;
					LinkTypeFuncs.keystone(self, link, (":"):split(refString));
				else
					LinkTypeFuncs.item(self, link, linkType, itemID);
				end
			end
		end
	end
end

-- OnTooltipSetSpell
local function OnTooltipSetSpell(self,...)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local name, id = ttif:GetDisplayedSpell(self);	-- [18.07.19] 8.0/BfA: "dropped second parameter (nameSubtext)"
		if (id) then
			local link = GetSpellLink(id);
			if (link) then
				local linkType, spellID = link:match("H?(%a+):(%d+)");
				if (spellID) then
					tipDataAdded[self] = linkType;
					LinkTypeFuncs.spell(self, false, nil, link, linkType, spellID);
				end
			end
		end
	end
end

-- HOOK: QuestMapLogTitleButton_OnEnter
local function QMLTB_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local info = C_QuestLog.GetInfo(self.questLogIndex);
		local questID = info.questID;
		local link = GetQuestLink(questID);
		if (link) then
			local level = link:match("H?%a+:%d+:(%d+)");
			LinkTypeFuncs.quest(gtt, nil, "quest", questID, level);
		else
			LinkTypeFuncs.quest(gtt, nil, "quest", questID, nil);
		end
		tipDataAdded[gtt] = "quest";
	end
end

-- HOOK: TaskPOI_OnEnter
local function TPOI_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local questID = self.questID;
		local link = GetQuestLink(questID);
		if (link) then
			local level = link:match("H?%a+:%d+:(%d+)");
			LinkTypeFuncs.quest(gtt, nil, "quest", questID, level);
		else
			LinkTypeFuncs.quest(gtt, nil, "quest", questID, nil);
		end
		tipDataAdded[gtt] = "quest";
	end
end

-- HOOK: QuestPinMixin:OnMouseEnter + StorylineQuestPinMixin:OnMouseEnter
local function QPM_OnMouseEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local questID = self.questID;
		local link = GetQuestLink(questID);
		if (link) then
			local level = link:match("H?%a+:%d+:(%d+)");
			LinkTypeFuncs.quest(gtt, nil, "quest", questID, level);
		else
			LinkTypeFuncs.quest(gtt, nil, "quest", questID, nil);
		end
		tipDataAdded[gtt] = "quest";
	end
end

-- HOOK: QuestBlobPinMixin:UpdateTooltip
local function QBPM_UpdateTooltip_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) then
		local mouseX, mouseY = self:GetMap():GetNormalizedCursorPosition();
		local questID, numPOITooltips = self:UpdateMouseOverTooltip(mouseX, mouseY);
		if (questID) then
			local link = GetQuestLink(questID);
			if (link) then
				local level = link:match("H?%a+:%d+:(%d+)");
				LinkTypeFuncs.quest(gtt, nil, "quest", questID, level);
			else
				LinkTypeFuncs.quest(gtt, nil, "quest", questID, nil);
			end
			tipDataAdded[gtt] = "quest";
		end
	end
end

-- HOOK: RuneforgePowerBaseMixin:OnEnter
local function RPBM_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local runeforgePowerID = self:GetPowerID();
		if (runeforgePowerID) then
			tipDataAdded[gtt] = "runeforgePower";
			CustomTypeFuncs.runeforgePower(gtt, nil, "runeforgePower", runeforgePowerID);
		end
	end
end

-- HOOK: GameTooltip_AddQuestRewardsToTooltip
local function GTT_AddQuestRewardsToTooltip_Hook(self, questID, style)
	if (cfg.if_enable) and (not tipDataAdded[self]) then
		local link = GetQuestLink(questID);
		if (link) then
			local level = link:match("H?%a+:%d+:(%d+)");
			LinkTypeFuncs.quest(self, nil, "quest", questID, level);
		else
			LinkTypeFuncs.quest(self, nil, "quest", questID, nil);
		end
		tipDataAdded[self] = "quest";
	end
end

-- HOOK: EmbeddedItemTooltip_SetItemByID
local function EITT_SetItemByID_Hook(self, id, count)
	local targetTooltip = self.Tooltip;
	if (cfg.if_enable) and (not tipDataAdded[targetTooltip]) and (targetTooltip:IsShown()) then
		local itemID = id;
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID);
		if (itemLink) then
			local linkType, _itemID = itemLink:match("H?(%a+):(%d+)");
			if (_itemID) then
				tipDataAdded[targetTooltip] = linkType;
				LinkTypeFuncs.item(targetTooltip, itemLink, linkType, _itemID);
			end
		end
	end
end

-- HOOK: EmbeddedItemTooltip_SetItemByQuestReward
local function EITT_SetItemByQuestReward_Hook(self, questLogIndex, questID, rewardType, showCollectionText)
	local targetTooltip = self.Tooltip;
	if (cfg.if_enable) and (not tipDataAdded[targetTooltip]) and (targetTooltip:IsShown()) then
		if (not questLogIndex) then
			return
		end
		
		rewardType = (rewardType or "reward");
		local getterFunc;
		if (rewardType == "choice") then
			getterFunc = GetQuestLogChoiceInfo;
		else
			getterFunc = GetQuestLogRewardInfo;
		end
		
		local name, texture, numItems, quality, isUsable, itemID = getterFunc(questLogIndex, questID);
		
		if (name) and (texture) then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID);
			if (itemLink) then
				local linkType, itemID = itemLink:match("H?(%a+):(%d+)");
				if (itemID) then
					tipDataAdded[targetTooltip] = linkType;
					LinkTypeFuncs.item(targetTooltip, itemLink, linkType, itemID);
				end
			end
		end
	end
end

-- HOOK: EmbeddedItemTooltip_SetSpellByQuestReward
local function EITT_SetSpellByQuestReward_Hook(self, rewardIndex, questID)
	local targetTooltip = self.Tooltip;
	if (cfg.if_enable) and (not tipDataAdded[targetTooltip]) and (targetTooltip:IsShown()) then
		local texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID, genericUnlock, spellID = GetQuestLogRewardSpell(rewardIndex, questID);
		
		if (name) and (texture) then
			local link = GetSpellLink(spellID);
			if (link) then
				local linkType, _spellID = link:match("H?(%a+):(%d+)");
				if (spellID) then
					tipDataAdded[targetTooltip] = linkType;
					LinkTypeFuncs.spell(targetTooltip, false, nil, link, linkType, _spellID);
				end
			end
		end
	end
end

-- HOOK: EmbeddedItemTooltip_SetSpellWithTextureByID
local function EITT_SetSpellWithTextureByID_Hook(self, spellID, texture)
	local targetTooltip = self.Tooltip;
	if (cfg.if_enable) and (not tipDataAdded[targetTooltip]) and (targetTooltip:IsShown()) then
		if (texture) then
			local link = GetSpellLink(spellID);
			if (link) then
				local linkType, _spellID = link:match("H?(%a+):(%d+)");
				if (spellID) then
					tipDataAdded[targetTooltip] = linkType;
					LinkTypeFuncs.spell(targetTooltip, false, nil, link, linkType, _spellID);
				end
			end
		end
	end
end

-- HOOK: EmbeddedItemTooltip_SetCurrencyByID
local function EITT_SetCurrencyByID_Hook(self, currencyID, quantity)
	local targetTooltip = self.Tooltip;
	if (cfg.if_enable) and (not tipDataAdded[targetTooltip]) and (targetTooltip:IsShown()) then
		local link = C_CurrencyInfo_GetCurrencyLink(currencyID, quantity);
		if (link) then
			local linkType, _currencyID, _quantity = link:match("H?(%a+):(%d+):(%d+)");
			if (_currencyID) then
				tipDataAdded[targetTooltip] = linkType;
				LinkTypeFuncs.currency(targetTooltip, link, linkType, _currencyID, _quantity);
			end
		end
	end
end

-- HOOK: DressUpOutfitDetailsSlotMixin:OnEnter
local function DUODSM_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		if (not self.transmogID) then
			return;
		end
		if (self.item) then -- item
			local itemID = self.item.itemID;
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID);
			if (itemLink) then
				local linkType, _itemID = itemLink:match("H?(%a+):(%d+)");
				if (_itemID) then
					tipDataAdded[gtt] = linkType;
					LinkTypeFuncs.item(gtt, itemLink, linkType, _itemID);
				end
			end
		else -- illusion
			local illusionID = self.transmogID;
			local name, hyperlink, sourceText = C_TransmogCollection.GetIllusionStrings(illusionID);
			if (hyperlink) then
				local linkType, illusionID = hyperlink:match("H?(%a+):(%d+)");
				if (illusionID) then
					tipDataAdded[gtt] = linkType;
					LinkTypeFuncs.transmogillusion(gtt, hyperlink, linkType, illusionID);
				end
			end
		end
	end
end

-- HOOK: TalentDisplayMixin:OnEnter
local function TDM_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) then
		local spellID = self:GetSpellID();
		if (spellID) then
			local link = GetSpellLink(spellID);
			if (link) then
				local linkType, _spellID = link:match("H?(%a+):(%d+)");
				if (_spellID) then
					tipDataAdded[gtt] = linkType;
					LinkTypeFuncs.spell(gtt, false, nil, link, linkType, _spellID);
				end
			end
		end
	end
end

-- HOOK: PlayerChoicePowerChoiceTemplateMixin:OnEnter
local function PCPCTM_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local spellID = (self.optionInfo and self.optionInfo.spellID);
		if (spellID) then
			local link = GetSpellLink(spellID);
			if (link) then
				local linkType, _spellID = link:match("H?(%a+):(%d+)");
				if (_spellID) then
					tipDataAdded[gtt] = linkType;
					LinkTypeFuncs.spell(gtt, false, nil, link, linkType, _spellID);
				end
			end
		end
	end
end

-- HOOK: HonorFrame.BonusFrame.Buttons:OnEnter
local function HFBFB_OnEnter(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) then
		tipDataAdded[gtt] = "pvpEnlistmentBonus";
		CustomTypeFuncs.pvpEnlistmentBonus(gtt, nil, "pvpEnlistmentBonus");
	end
end

-- HOOK: AdventureJournal_Reward_OnEnter
local function AJR_OnEnter_Hook(self)
	if (cfg.if_enable) and (ejtt:IsShown()) then
		local rewardData = self.data;
		if (rewardData) then
			-- item and currency can both exist. In this case currency is the second item.
			if (rewardData.currencyType) or (rewardData.itemLink) then
				if (tipDataAdded[ejtt]) then -- fire OnShow handler to reset line pool. AdventureJournal_Reward_OnEnter will be called multiple times without OnHide.
					PJATT_EJTT_OnShow_Hook(ejtt);
				end
			end
			if (rewardData.currencyType) then -- currency
				local currencyLink = C_CurrencyInfo_GetCurrencyLink(rewardData.currencyType, rewardData.currencyQuantity)
				if (currencyLink) then
					local linkType, currencyID, quantity = currencyLink:match("H?(%a+):(%d+):(%d+)");
					if (currencyID) then
						tipDataAdded[ejtt] = linkType;
						LinkTypeFuncs.currency(ejtt, currencyLink, linkType, currencyID, quantity);
					end
				end
			end
			if (rewardData.itemLink) then -- item
				local linkType, itemID = rewardData.itemLink:match("H?(%a+):(%d+)");
				if (itemID) then
					tipDataAdded[ejtt] = linkType;
					LinkTypeFuncs.item(ejtt, rewardData.itemLink, linkType, itemID);
				end
			end
		end
	end
end

-- HOOK: CommunitiesGuildNewsButton_OnEnter / GuildNewsButton_OnEnter
local function GNB_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local newsType = self.newsType;
		if (newsType == NEWS_PLAYER_ACHIEVEMENT or newsType == NEWS_GUILD_ACHIEVEMENT) then
			local achievementID = self.id;
			local link = GetAchievementLink(achievementID);
			local refString = link:match("|H([^|]+)|h") or link;
			tipDataAdded[gtt] = "achievement";
			LinkTypeFuncs.achievement(gtt, refString, (":"):split(refString));
		end
	end
end

-- HOOK: CommunitiesGuildInfoFrame.Challenges:OnEnter / GuildInfoFrameInfoChallenge:OnEnter
local function GIFC_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		tipDataAdded[gtt] = "guildChallenge";
		CustomTypeFuncs.guildChallenge(gtt, nil, "guildChallenge");
	end
end

-- HOOK: WardrobeCollectionFrame.ItemsCollectionFrame:RefreshAppearanceTooltip() respectively WardrobeCollectionFrame.ItemsCollectionFrame.Models:OnEnter, see WardrobeItemsCollectionMixin:RefreshAppearanceTooltip() and WardrobeItemsModelMixin:OnEnter() in "Blizzard_Collections/Blizzard_Wardrobe.lua"
local function WCFICF_RefreshAppearanceTooltip_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local itemsCollectionFrame = self; -- item, see WardrobeCollectionFrameMixin:GetAppearanceItemHyperlink() + WardrobeItemsModelMixin:OnMouseDown() in "Blizzard_Collections/Blizzard_Wardrobe.lua"
		local wardrobeCollectionFrame = itemsCollectionFrame:GetParent();
		if (wardrobeCollectionFrame.tooltipSourceIndex) then
			local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(self.tooltipVisualID, itemsCollectionFrame:GetActiveCategory(), itemsCollectionFrame.transmogLocation);
			local index = CollectionWardrobeUtil.GetValidIndexForNumSources(wardrobeCollectionFrame.tooltipSourceIndex, #sources);
			local sourceID = sources[index].sourceID;
			
			tipDataAdded[gtt] = "transmogappearance";
			LinkTypeFuncs.transmogappearance(gtt, nil, "transmogappearance", sourceID);
		end
	end
end

-- HOOK: WardrobeCollectionFrame.ItemsCollectionFrame.Models:OnEnter, see WardrobeItemsModelMixin:OnEnter() in "Blizzard_Collections/Blizzard_Wardrobe.lua"
local function WCFICFM_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local itemsCollectionFrame = self:GetParent();
		if (itemsCollectionFrame.transmogLocation:IsIllusion()) then -- illusion
			local illusionID = self.visualInfo.sourceID;
			local name, hyperlink, sourceText = C_TransmogCollection.GetIllusionStrings(illusionID);
			if (hyperlink) then
				local linkType, illusionID = hyperlink:match("H?(%a+):(%d+)");
				if (illusionID) then
					tipDataAdded[gtt] = linkType;
					LinkTypeFuncs.transmogillusion(gtt, hyperlink, linkType, illusionID);
				end
			end
		end
	end
end

-- HOOK: WardrobeCollectionFrame.SetsCollectionFrame:RefreshAppearanceTooltip respectively WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.itemFramesPool:OnEnter, see WardrobeSetsCollectionMixin:RefreshAppearanceTooltip() and WardrobeSetsDetailsItemMixin:OnMouseDown() in "Blizzard_Collections/Blizzard_Wardrobe.lua"
local function WCFSCF_RefreshAppearanceTooltip_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local setID = self:GetSelectedSetID();
		local sourceID = self.tooltipPrimarySourceID;
		
		local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
		local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType);
		local sources = C_TransmogSets.GetSourcesForSlot(setID, slot);
		if (#sources == 0) then
			-- can happen if a slot only has HiddenUntilCollected sources
			tinsert(sources, sourceInfo);
		end
		CollectionWardrobeUtil.SortSources(sources, sourceInfo.visualID, sourceID);
		local wardrobeCollectionFrame = self:GetParent();
		local selectedIndex = wardrobeCollectionFrame.tooltipSourceIndex;
		if (selectedIndex) then
			local index = CollectionWardrobeUtil.GetValidIndexForNumSources(selectedIndex, #sources);
			local _sourceID = sources[index].sourceID;
			
			tipDataAdded[gtt] = "transmogappearance";
			LinkTypeFuncs.transmogappearance(gtt, nil, "transmogappearance", _sourceID);
		end
	end
end

-- HOOK: WardrobeCollectionFrame.SetsTransmogFrame.Models:RefreshTooltip, see WardrobeSetsTransmogModelMixin:RefreshTooltip() in "Blizzard_Collections/Blizzard_Wardrobe.lua"
local function WCFSTFM_RefreshTooltip_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local setID = self.setID;
		if (setID) then
			tipDataAdded[gtt] = "transmogset";
			LinkTypeFuncs.transmogset(gtt, nil, "transmogset", setID);
		end
	end
end

-- HOOK: AchievementFrameAchievementsObjectives MiniAchievement:OnEnter, see MiniAchievementTemplate:OnEnter() in "Blizzard_AchievementUI/Blizzard_AchievementUI.xml"
local function AFAOMA_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) then
		local parent = self:GetParent(); -- see AchievementObjectives_DisplayProgressiveAchievement() in "Blizzard_AchievementUI/Blizzard_AchievementUI.lua"
		if (parent) then
			local achievementID = parent.id;
			repeat
				local _achievementID, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID);
				if (name == self.name) and (description == self.desc) then
					local link = GetAchievementLink(achievementID);
					local refString = link:match("|H([^|]+)|h") or link;
					tipDataAdded[gtt] = "achievement";
					LinkTypeFuncs.achievement(gtt, refString, (":"):split(refString));
					break;
				end
				achievementID = GetPreviousAchievement(achievementID);
			until (not achievementID);
		end
	end
end

-- HOOK: WorldQuestTracker_Tracker:OnEnter, see TrackerFrameOnEnter() in "WorldQuestTracker/WorldQuestTracker_Tracker.lua"
local function WQTT_OnEnter_Hook(self)
	if (cfg.if_enable) and (not tipDataAdded[gtt]) and (gtt:IsShown()) then
		local questID = self.questID;
		if (questID) then
			local link = GetQuestLink(questID);
			if (link) then
				local level = link:match("H?%a+:%d+:(%d+)");
				LinkTypeFuncs.quest(gtt, nil, "quest", questID, level);
			else
				LinkTypeFuncs.quest(gtt, nil, "quest", questID, nil);
			end
			tipDataAdded[gtt] = "quest";
		end
	end
end

-- OnTooltipCleared
local function OnTooltipCleared(self)
	tipDataAdded[self] = nil;
	if (self.ttSetIconTextureAndText) then
		self:ttSetIconTextureAndText();
	end
end

-- HOOK: EmbeddedItemTooltip_Clear
local function EITT_Clear_Hook(self)
	local targetTooltip = self.Tooltip;
	tipDataAdded[targetTooltip] = nil;
end

-- HOOK: BattlePetTooltip:OnHide
local function BPTT_OnHide_Hook(self)
	tipDataAdded[self] = nil;
	if (self.ttSetIconTextureAndText) then
		self:ttSetIconTextureAndText();
	end
end

-- HOOK: FloatingBattlePetTooltip:OnHide
local function FBPTT_OnHide_Hook(self)
	tipDataAdded[self] = nil;
	if (self.ttSetIconTextureAndText) then
		self:ttSetIconTextureAndText();
	end
end

-- HOOK: PetJournalPrimaryAbilityTooltip:OnHide + PetJournalSecondaryAbilityTooltip:OnHide
local function PJATT_OnHide_Hook(self)
	tipDataAdded[self] = nil;
	if (self.ttSetIconTextureAndText) then
		self:ttSetIconTextureAndText();
	end
end

-- HOOK: FloatingPetBattleAbilityTooltip:OnHide
local function FPBATT_OnHide_Hook(self)
	tipDataAdded[self] = nil;
	if (self.ttSetIconTextureAndText) then
		self:ttSetIconTextureAndText();
	end
end

-- HOOK: EncounterJournalTooltip:OnHide
local function EJTT_OnHide_Hook(self)
	tipDataAdded[self] = nil;
	if (self.ttSetIconTextureAndText) then
		self:ttSetIconTextureAndText();
	end
end

-- Function to apply necessary hooks to tips
function ttif:ApplyHooksToTips(tips, resolveGlobalNamedObjects, addToTipsToModify)
	-- Resolve the TipsToModify strings into actual objects
	if (resolveGlobalNamedObjects) then
		ResolveGlobalNamedObjects(tips);
	end
	
	-- apply necessary hooks to tips
	for index, tip in ipairs(tips) do
		if (type(tip) == "table") and (type(tip.GetObjectType) == "function") then
			local tipName = tip:GetName();
			local tipHooked = false;
			
			if (addToTipsToModify) then
				tipsToModify[#tipsToModify + 1] = tip;
			end
			
			if (tip:GetObjectType() == "GameTooltip") then
				hooksecurefunc(tip, "SetHyperlink", function(self, ...)
					ttif:SetHyperlink_Hook(self, ...)
				end);
				hooksecurefunc(tip, "SetUnitAura", SetUnitAura_Hook);
				hooksecurefunc(tip, "SetUnitBuff", SetUnitAura_Hook);
				hooksecurefunc(tip, "SetUnitDebuff", SetUnitAura_Hook);
				hooksecurefunc(tip, "SetAction", SetAction_Hook);
				hooksecurefunc(tip, "SetSpellBookItem", SetSpellBookItem_Hook);
				hooksecurefunc(tip, "SetPetAction", SetPetAction_Hook);
				hooksecurefunc(tip, "SetQuestItem", SetQuestItem_Hook);
				hooksecurefunc(tip, "SetQuestLogItem", SetQuestLogItem_Hook);
				if (isWoWWotlkc) or (isWoWSl) or (isWoWRetail) then
					hooksecurefunc(tip, "SetQuestCurrency", SetQuestCurrency_Hook);
					hooksecurefunc(tip, "SetQuestLogCurrency", SetQuestLogCurrency_Hook);
				end
				if (isWoWSl) or (isWoWRetail) then
					hooksecurefunc(tip, "SetConduit", SetConduit_Hook);
					hooksecurefunc(tip, "SetEnhancedConduit", SetConduit_Hook);
					hooksecurefunc(tip, "SetAzeriteEssence", SetAzeriteEssence_Hook);
					hooksecurefunc(tip, "SetAzeriteEssenceSlot", SetAzeriteEssenceSlot_Hook);
					hooksecurefunc(tip, "SetCurrencyByID", SetCurrencyByID_Hook);
					hooksecurefunc(tip, "SetCurrencyToken", SetCurrencyToken_Hook);
					if (tip.SetCurrencyTokenByID) then -- removed since df 10.0.2
						hooksecurefunc(tip, "SetCurrencyTokenByID", SetCurrencyTokenByID_Hook);
					end
					hooksecurefunc(tip, "SetQuestPartyProgress", SetQuestPartyProgress_Hook);
					hooksecurefunc(tip, "SetCompanionPet", SetCompanionPet_Hook);
					hooksecurefunc(tip, "SetRecipeReagentItem", SetRecipeReagentItem_Hook);
					hooksecurefunc(tip, "SetToyByItemID", SetToyByItemID_Hook);
					hooksecurefunc(tip, "SetLFGDungeonReward", SetLFGDungeonReward_Hook);
					hooksecurefunc(tip, "SetLFGDungeonShortageReward", SetLFGDungeonShortageReward_Hook);
				end
				if (TooltipDataProcessor) then -- since df 10.0.2
					TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self, ...)
						if (self == tip) then
							OnTooltipSetItem(self, ...);
						end
					end);
					TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, ...)
						if (self == tip) then
							OnTooltipSetSpell(self, ...);
						end
					end);
				else -- before df 10.0.2
					tip:HookScript("OnTooltipSetItem", OnTooltipSetItem);
					tip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell);
				end
				tip:HookScript("OnTooltipCleared", OnTooltipCleared);
				if (tipName == "GameTooltip") then
					hooksecurefunc(QuestPinMixin, "OnMouseEnter", QPM_OnMouseEnter_Hook);
					hooksecurefunc(StorylineQuestPinMixin, "OnMouseEnter", QPM_OnMouseEnter_Hook);
					hooksecurefunc("GameTooltip_AddQuestRewardsToTooltip", GTT_AddQuestRewardsToTooltip_Hook);
					hooksecurefunc("EmbeddedItemTooltip_SetItemByID", EITT_SetItemByID_Hook);
					hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", EITT_SetItemByQuestReward_Hook);
					hooksecurefunc("EmbeddedItemTooltip_SetSpellByQuestReward", EITT_SetSpellByQuestReward_Hook);
					hooksecurefunc("EmbeddedItemTooltip_SetCurrencyByID", EITT_SetCurrencyByID_Hook);
					hooksecurefunc("EmbeddedItemTooltip_Clear", EITT_Clear_Hook);
					-- classic support
					if (isWoWSl) or (isWoWRetail) then
						hooksecurefunc("QuestMapLogTitleButton_OnEnter", QMLTB_OnEnter_Hook);
						hooksecurefunc("TaskPOI_OnEnter", TPOI_OnEnter_Hook);
						for pin in WorldMapFrame:EnumeratePinsByTemplate("QuestBlobPinTemplate") do
							hooksecurefunc(pin, "UpdateTooltip", QBPM_UpdateTooltip_Hook);
						end
						hooksecurefunc("EmbeddedItemTooltip_SetSpellWithTextureByID", EITT_SetSpellWithTextureByID_Hook);
						hooksecurefunc(RuneforgePowerBaseMixin, "OnEnter", RPBM_OnEnter_Hook);
						hooksecurefunc(DressUpOutfitDetailsSlotMixin, "OnEnter", DUODSM_OnEnter_Hook);
						if (isWoWRetail) then
							hooksecurefunc(TalentDisplayMixin, "OnEnter", TDM_OnEnter_Hook);
						end
					end
				end
				tipHooked = true;
			else
				if (tip:GetObjectType() == "Frame") then
					if (tipName == "BattlePetTooltip") then
						hooksecurefunc("BattlePetToolTip_Show", BPTT_Show_Hook);
						tip:HookScript("OnHide", BPTT_OnHide_Hook);
						tipHooked = true;
					elseif (tipName == "FloatingBattlePetTooltip") then
						hooksecurefunc("FloatingBattlePet_Show", FBP_Show_Hook);
						tip:HookScript("OnHide", FBPTT_OnHide_Hook);
						tipHooked = true;
					elseif (IsAddOnLoaded("Blizzard_Collections")) and ((tipName == "PetJournalPrimaryAbilityTooltip") or (tipName == "PetJournalSecondaryAbilityTooltip")) then
						if (tipName == "PetJournalPrimaryAbilityTooltip") then
							hooksecurefunc("PetJournal_ShowAbilityTooltip", PJ_ShowAbilityTooltip_Hook);
							hooksecurefunc("PetJournal_ShowAbilityCompareTooltip", PJ_ShowAbilityCompareTooltip_Hook);
						end
						tip:HookScript("OnHide", PJATT_OnHide_Hook);
						-- add function Addline() (see BattlePetTooltipTemplate_AddTextLine() in "FloatingPetBattleTooltip.lua")
						tip:HookScript("OnLoad", PJATT_EJTT_OnLoad_Hook);
						tip:HookScript("OnShow", PJATT_EJTT_OnShow_Hook);
						if (tip.strongAgainstTextures) then -- fire OnLoad handler if already loaded
							PJATT_EJTT_OnLoad_Hook(tip);
						end
						tipHooked = true;
					elseif (tipName == "FloatingPetBattleAbilityTooltip") then
						hooksecurefunc("FloatingPetBattleAbility_Show", FPBA_Show_Hook);
						tip:HookScript("OnHide", FPBATT_OnHide_Hook);
						-- add function Addline() (see BattlePetTooltipTemplate_AddTextLine() in "FloatingPetBattleTooltip.lua")
						tip:HookScript("OnLoad", PJATT_EJTT_OnLoad_Hook);
						tip:HookScript("OnShow", PJATT_EJTT_OnShow_Hook);
						if (tip.strongAgainstTextures) then -- fire OnLoad handler if already loaded
							PJATT_EJTT_OnLoad_Hook(tip);
						end
						tipHooked = true;
					elseif (IsAddOnLoaded("Blizzard_EncounterJournal")) and (tipName == "EncounterJournalTooltip") then
						hooksecurefunc("AdventureJournal_Reward_OnEnter", AJR_OnEnter_Hook);
						tip:HookScript("OnHide", EJTT_OnHide_Hook);
						-- add function Addline() (see BattlePetTooltipTemplate_AddTextLine() in "FloatingPetBattleTooltip.lua")
						tip:HookScript("OnLoad", PJATT_EJTT_OnLoad_Hook);
						tip:HookScript("OnShow", PJATT_EJTT_OnShow_Hook);
						if (tip.headerText) then -- fire OnLoad handler if already loaded
							PJATT_EJTT_OnLoad_Hook(tip);
						end
						-- tipHooked = true;
					end
				end
			end
			
			if (tipHooked) then
				if (tipsToAddIcon[tipName]) then
					self:CreateTooltipIcon(tip);
				end
			end
		end
	end
end

-- Function to apply necessary hooks to CommunitiesFrameGuildDetailsFrameInfo
local CFGDFIChooked = {};

function ttif:ApplyHooksToCFGDFI()
	local numChallenges = GetNumGuildChallenges(); -- see CommunitiesGuildInfoFrame_UpdateChallenges() in "Blizzard_Communities/GuildInfo.lua"
	for i = 1, numChallenges do
		local frame = CommunitiesFrameGuildDetailsFrameInfo.Challenges[i];
		if (frame) and (not CFGDFIChooked[frame]) then
			frame:HookScript("OnEnter", GIFC_OnEnter_Hook);
			CFGDFIChooked[frame] = true;
		end
	end
end

-- Function to apply necessary hooks to GuildInfoFrameInfoChallenge
local GIFIChooked = {};

function ttif:ApplyHooksToGIFIC()
	local numChallenges = GetNumGuildChallenges(); -- see GuildInfoFrame_UpdateChallenges() in "Blizzard_GuildUI/Blizzard_GuildInfo.lua"
	for i = 1, numChallenges do
		local index, current, max = GetGuildChallengeInfo(i);
		local frame = _G["GuildInfoFrameInfoChallenge"..index];
		if (frame) and (not GIFIChooked[frame]) then
			frame:HookScript("OnEnter", GIFC_OnEnter_Hook);
			GIFIChooked[frame] = true;
		end
	end
end

-- Apply hooks for all the tooltips to modify during VARIABLES_LOADED -- Only hook GameTooltip objects
function ttif:HookTips()
	self:ApplyHooksToTips(tipsToModify, true);
end

-- AddOn Loaded
function ttif:ADDON_LOADED(event, addOnName)
	if (not cfg) then return end;
	
	-- check if addon is already loaded
	if (addOnsLoaded[addOnName] == nil) or (addOnsLoaded[addOnName]) then
		return;
	end
	
	-- now AchievementFrameAchievementsObjectives exists
	if (addOnName == "Blizzard_AchievementUI") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("Blizzard_AchievementUI")) and (not addOnsLoaded['Blizzard_AchievementUI'])) then
		if (AchievementFrameAchievementsObjectives.GetMiniAchievement) then -- function GetMiniAchievement() doesn't exist in wotlkc
			local AFAOMAhooked = {}; -- see AchievementsObjectivesMixin:GetMiniAchievement() in "Blizzard_AchievementUI/Blizzard_AchievementUI.lua"
			
			hooksecurefunc(AchievementFrameAchievementsObjectives, "GetMiniAchievement", function(self, index)
				local miniAchievement = self:GetElementAtIndex("MiniAchievementTemplate", self.miniAchivements, index, AchievementButton_LocalizeMiniAchievement);
				if (not AFAOMAhooked[miniAchievement]) then
					miniAchievement:HookScript("OnEnter", AFAOMA_OnEnter_Hook);
					AFAOMAhooked[miniAchievement] = true;
				end
			end);
		end
		
		if (addOnName == "TipTac") then
			addOnsLoaded["Blizzard_AchievementUI"] = true;
		end
	end
	-- now PetJournalPrimaryAbilityTooltip and PetJournalSecondaryAbilityTooltip exist
	if (addOnName == "Blizzard_Collections") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("Blizzard_Collections")) and (not addOnsLoaded['Blizzard_Collections'])) then
		pjpatt = PetJournalPrimaryAbilityTooltip;
		pjsatt = PetJournalSecondaryAbilityTooltip;
		
		-- Hook Tips & Apply Settings
		self:ApplyHooksToTips({
			"PetJournalPrimaryAbilityTooltip",
			"PetJournalSecondaryAbilityTooltip"
		}, true, true);

		self:OnApplyConfig();
		
		-- Function to apply necessary hooks to WardrobeCollectionFrame.ItemsCollectionFrame, see WardrobeItemsCollectionMixin:UpdateItems() in "Blizzard_Collections/Blizzard_Wardrobe.lua"
		hooksecurefunc(WardrobeCollectionFrame.ItemsCollectionFrame, "RefreshAppearanceTooltip", WCFICF_RefreshAppearanceTooltip_Hook); -- for items (incl. reapply for tabbing through items with same visualID)

		local itemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame; -- for illusions
		for i = 1, itemsCollectionFrame.PAGE_SIZE do
			local model = itemsCollectionFrame.Models[i];
			model:HookScript("OnEnter", WCFICFM_OnEnter_Hook);
		end

		hooksecurefunc(WardrobeCollectionFrame.ItemsCollectionFrame, "UpdateItems", function(self) -- reapply if selecting or scrolling
			if (gtt:IsShown()) then
				local itemsCollectionFrame = self;
				for i = 1, itemsCollectionFrame.PAGE_SIZE do
					local model = itemsCollectionFrame.Models[i];
					local gttOwner = gtt:GetOwner();
					
					if (gttOwner == model) then
						WCFICFM_OnEnter_Hook(gttOwner);
						break;
					end
				end
			end
		end);
		
		-- Function to apply necessary hooks to WardrobeCollectionFrame.SetsCollectionFrame
		hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, "RefreshAppearanceTooltip", WCFSCF_RefreshAppearanceTooltip_Hook); -- for sets (incl. reapply for tabbing through items with same visualID)

		-- Function to apply necessary hooks to WardrobeCollectionFrame.SetsTransmogFrame, see WardrobeSetsTransmogMixin:UpdateSets() in "Blizzard_Collections/Blizzard_Wardrobe.lua"
		local setsTransmogFrame = WardrobeCollectionFrame.SetsTransmogFrame; -- for sets at transmogrifier
		for i = 1, setsTransmogFrame.PAGE_SIZE do
			local model = setsTransmogFrame.Models[i];
			hooksecurefunc(model, "RefreshTooltip", WCFSTFM_RefreshTooltip_Hook);
		end
		
		if (addOnName == "TipTac") then
			addOnsLoaded["Blizzard_Collections"] = true;
		end
	end
	-- now CommunitiesGuildNewsFrame exists
	if (addOnName == "Blizzard_Communities") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("Blizzard_Communities")) and (not addOnsLoaded['Blizzard_Communities'])) then
		hooksecurefunc("CommunitiesGuildNewsButton_OnEnter", GNB_OnEnter_Hook);

		-- Function to apply necessary hooks to CommunitiesFrameGuildDetailsFrameInfo
		ttif:ApplyHooksToCFGDFI();
		
		hooksecurefunc("CommunitiesGuildInfoFrame_UpdateChallenges", function()
			ttif:ApplyHooksToCFGDFI();
		end);
		
		if (addOnName == "TipTac") then
			addOnsLoaded["Blizzard_Communities"] = true;
		end
	end
	-- now EncounterJournalTooltip exists
	if (addOnName == "Blizzard_EncounterJournal") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("Blizzard_EncounterJournal")) and (not addOnsLoaded['Blizzard_EncounterJournal'])) then
		ejtt = EncounterJournalTooltip;
		
		-- Hook Tips & Apply Settings
		-- commented out for embedded tooltips, see description in tt:SetPadding()
		-- self:ApplyHooksToTips({
			-- "EncounterJournalTooltip"
		-- }, true, true);

		-- self:OnApplyConfig();
		
		if (addOnName == "TipTac") then
			addOnsLoaded["Blizzard_EncounterJournal"] = true;
		end
	end
	-- now GuildNewsButton exists
	if (addOnName == "Blizzard_GuildUI") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("Blizzard_GuildUI")) and (not addOnsLoaded['Blizzard_GuildUI'])) then
		hooksecurefunc("GuildNewsButton_OnEnter", GNB_OnEnter_Hook);
		
		-- Function to apply necessary hooks to GuildInfoFrameInfoChallenge
		ttif:ApplyHooksToGIFIC();
		
		hooksecurefunc("GuildInfoFrame_UpdateChallenges", function()
			ttif:ApplyHooksToGIFIC();
		end);
		
		if (addOnName == "TipTac") then
			addOnsLoaded["Blizzard_GuildUI"] = true;
		end
	end
	-- now PlayerChoiceTorghastOption exists
	if (addOnName == "Blizzard_PlayerChoice") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("Blizzard_PlayerChoice")) and (not addOnsLoaded['Blizzard_PlayerChoice'])) then
		hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, "OnEnter", PCPCTM_OnEnter_Hook);
		
		if (addOnName == "TipTac") then
			addOnsLoaded["Blizzard_PlayerChoice"] = true;
		end
	end
	-- now PVPRewardTemplate exists
	if (addOnName == "Blizzard_PVPUI") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("Blizzard_PVPUI")) and (not addOnsLoaded['Blizzard_PVPUI'])) then
		-- Function to apply necessary hooks to PVPRewardTemplate, see HonorFrameBonusFrame_Update() in "Blizzard_PVPUI/Blizzard_PVPUI.lua"
		local buttons = {
			HonorFrame.BonusFrame.RandomBGButton,
			HonorFrame.BonusFrame.Arena1Button,
			HonorFrame.BonusFrame.RandomEpicBGButton,
			HonorFrame.BonusFrame.BrawlButton,
			HonorFrame.BonusFrame.BrawlButton2
		};
		
		for i, button in pairs(buttons) do
			button.Reward.EnlistmentBonus:HookScript("OnEnter", HFBFB_OnEnter);
		end
		
		if (addOnName == "TipTac") then
			addOnsLoaded["Blizzard_PVPUI"] = true;
		end
	end
	-- now WorldQuestTrackerAddon exists
	if (addOnName == "WorldQuestTracker") or ((addOnName == "TipTacItemRef") and (IsAddOnLoaded("WorldQuestTracker")) and (not addOnsLoaded['WorldQuestTracker'])) then
		local WQTThooked = {}; -- see WorldQuestTracker.GetOrCreateTrackerWidget() in "WorldQuestTracker/WorldQuestTracker_Tracker.lua"
		
		hooksecurefunc(WorldQuestTrackerAddon, "GetOrCreateTrackerWidget", function(index)
			local frame = _G["WorldQuestTracker_Tracker" .. index];
			if (frame) and (not WQTThooked[frame]) then
				frame:HookScript("OnEnter", WQTT_OnEnter_Hook);
				WQTThooked[frame] = true;
			end
		end);
		
		if (addOnName == "TipTac") then
			addOnsLoaded["WorldQuestTracker"] = true;
		end
	end

	addOnsLoaded[addOnName] = true;
	
	-- Cleanup if all addons are loaded
	local allAddOnsLoaded = true;
	
	for addOn, isLoaded in pairs(addOnsLoaded) do
		if (not isLoaded) then
			allAddOnsLoaded = false;
			break;
		end
	end
	
	if (allAddOnsLoaded) then
		self:UnregisterEvent(event);
		self[event] = nil;

		-- we no longer need to receive any events
		self:UnregisterAllEvents();
		self:SetScript("OnEvent", nil);
	end
end

--------------------------------------------------------------------------------------------------------
--                                        Smart Icon Evaluation                                       --
--------------------------------------------------------------------------------------------------------

-- returns true if an icon should be displayed
local function SmartIconEvaluation(tip,linkType)
	if (tip == bptt or tip == fbptt) then -- BattlePetTooltip and FloatingBattlePetTooltip
		return true;
	end

	if (linkType == "battlePetAbil") then
		if (tip.anchoredTo and tip.anchoredTo.icon) then
			return false;
		end
		return true;
	end
	
	if (tip == ejtt) then -- EncounterJournalTooltip
		return false;
	end
	
	local owner = tip:GetOwner();

	-- No Owner?
	if (not owner) then
		return false;
	-- Item
	elseif (linkType == "item") then
		if (owner.hasItem or owner.action or owner.icon or owner.Icon or owner.texture or owner.lootFrame or owner.ItemIcon or owner.iconTexture) then
			return false;
		end
	-- Spell
	elseif (linkType == "spell") then
		if (owner.action or owner.texture or owner.icon or owner.Icon or -- mount tooltip in action bar
				(owner.unit and owner.count and owner.filter)) then -- classic: aura
			return false;
		end
		local ownerParent = owner:GetParent();
		if (ownerParent) then
			if (owner.unit and ownerParent.buffs) then -- classic: aura under frame
				return false;
			end
			if (owner.ActiveTexture and ownerParent.icon) then -- mount tooltip in mount journal list
				return false;
			end
			if (ownerParent.Artwork) then -- player choice torghast option
				return false;
			end
		end
	-- Achievement
--	elseif (linkType == "achievement") then
--		if (owner.icon) then
--			return false;
--		end
	-- Battle pet
	elseif (linkType == "battlepet") then
		if (owner.action or owner.icon) then -- pet tooltip in action bar
			return false;
		end
		local ownerParent = owner:GetParent(); -- pet tooltip in pet journal list
		if (ownerParent and ownerParent.petTypeIcon and ownerParent.icon) then
			return false;
		end
	-- Runeforge power
	elseif (linkType == "runeforgePower") then
		if (owner.Icon) then
			return false;
		end
	-- Transmog illusion
	elseif (linkType == "transmogillusion") then
		if (owner.Icon) then
			return false;
		end
	-- Conduit
	elseif (linkType == "conduit") then
		if (owner.Icon) then
			return false;
		end
		local ownerParent = owner:GetParent();
		if (ownerParent and ownerParent.Icon) then
			return false;
		end
	-- Flyout
	elseif (linkType == "flyout") then
		if (owner.icon) then
			return false;
		end
	-- Pet action
	elseif (linkType == "petAction") then
		if (owner.icon) then
			return false;
		end
	-- Azerite essence
	elseif (linkType == "azessence") then
		if (owner.Icon) then
			return false;
		end
	end

	-- IconTexture sub texture
	local ownerName = owner:GetName();
	if (ownerName) then
		if (_G[ownerName.."IconTexture"]) or (ownerName:match("SendMailAttachment(%d+)")) then
			return false;
		end
	end

	-- If we passed all checks, return true to show an icon
	return true;
end

--------------------------------------------------------------------------------------------------------
--                                       Tip LinkType Functions                                       --
--------------------------------------------------------------------------------------------------------

-- Sets backdrop border color
function ttif:SetBackdropBorderColorLocked(tip, lockColor, r, g, b, a)
	if (not lockColor) and (tip.ttBackdropBorderColorApplied) then
		return;
	end
	
	tip.ttSetBackdropBorderColorLocked = false;
	tip:SetBackdropBorderColor(r, g, b, (a or 1) * ((cfg.tipBorderColor and cfg.tipBorderColor[4]) or 1));
	tip.ttSetBackdropBorderColorLocked = true;
	
	if (lockColor) then
		tip.ttBackdropBorderColorApplied = true;
	end
end

-- instancelock
function LinkTypeFuncs:instancelock(link,linkType,guid,mapId,difficulty,encounterBits)
	--AzDump(guid,mapId,difficulty,encounterBits)
  	-- TipType Border Color -- Disable these 3 lines to color border. Az: Work into options?
--	if (cfg.if_itemQualityBorder) then
--      ttif:SetBackdropBorderColorLocked(self, true, 1, .5, 0, 1);
--	end
end

-- item
function LinkTypeFuncs:item(link, linkType, id)
	local itemTexture = GetItemInfo(link);
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(link);
	if (classID == 5) and (subClassID == 1) then -- keystone
		local splits = StringSplitIntoTable(":", link);
		local mapID = splits[17];
		local keystoneLevel = splits[19];
		LinkTypeFuncs.keystone(self, link, linkType, id, mapID, keystoneLevel, select(21, unpack(splits))); -- modifierID1, modifierID2, modifierID3, modifierID4
		return;
	end
	local trueItemLevel = LibItemString:GetTrueItemLevel(link);
	if (trueItemLevel) then
		itemLevel = trueItemLevel;
	end

	--  아이템 등급과 유형 보기위한 구문 추가 : Start
  local ir;
  if (itemTexture) then
   if (cfg.if_etcinfo) then
    ir = itemRarity;
    if ir == 0 then
     ir = "|cff9d9d9d저급 아이템|r(|cff9d9d9d회색|r)";
    elseif ir == 1 then
     ir = "|cffffffff일반 아이템|r(|cffffffff흰색|r)";
    elseif ir == 2 then
     ir = "|cff1eff00고급 아이템|r(|cff1eff00녹색|r)";
    elseif ir == 3 then
     ir = "|cff0070dd희귀 아이템|r(|cff0070dd파랑|r)";
    elseif ir == 4 then
     if (cfg.if_wccc) then
      ir = "|cffff0000영웅 아이템|r(|cffff0000보라|r)";
     else
      ir = "|cffa335ee영웅 아이템|r(|cffa335ee보라|r)";
     end
    elseif ir == 5 then
     ir = "|cffff8000전설 아이템|r(|cffff8000주황|r)";
    elseif ir == 6 then
     ir = "|cffe6cc80유물 아이템|r(|cffe6cc80금색)|r";
    elseif ir == 7 then
     ir = "|cffe6cc80계승 아이템|r(|cffe6cc80금색|r)";
    else
    return;
    end
    self:AddLine("> 분류 : |CFF64DB99"..itemType.."|r [|CFFFFFFFF"..itemSubType.."|r]");
    self:AddLine("> 등급 : "..ir);
	self:Show();  -- 형상 툴팁 사이즈 맞추기 위해 추가 
   end

   if (cfg.if_itemStackCount) and not (linkType == "keystone") then  -- 최대 겹침 수량 표시 조건 만듬   
    self:AddLine("[ |cffee82ee최대 겹침 수량:|r |cffffffff"..itemStackCount.."개|r ]");
    self:Show();  -- 형상 툴팁 사이즈 맞추기 위해 추가 2
   end
  end
--  아이템 등급과 유형 보기위한 구문 추가 : End 

  -- Icon
  -- 퀘스트 아이템 및 아이템 귀속, 색약 보정, 아이템 레벨 강조 추가 : Start  
  if (not cfg.if_inIcon) then -- 아이콘 내부가 아닐 때
   if (not self.IsEmbedded) and (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self,linkType)) then
	local count = (itemStackCount and itemStackCount > 1 and (itemStackCount == 0x7FFFFFFF and "#" or itemStackCount) or "");
	self:ttSetIconTextureAndText(itemTexture, count);
   end
  else
   -- if (cfg.if_showIcon) then
   if (itemTexture) and (not self.IsEmbedded) then
    local newitt = "|T"..itemTexture..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
    _G[self:GetName().."TextLeft1"]:SetText(newitt);
   end
  end

  local tex = "Interface\\TargetingFrame\\PortraitQuestBadge.blp"; 

  if (itemTexture) then
   if (cfg.if_enable) then  -- 아이템 테두리 색상 적용 조건이 없어도 실행되도록 (cfg.if_itemQualityBorder) 에서 변경
    local qtext;
	local qvalue = 0;
	local btext;
	local bvalue = 0;
    local tex_bind = "Interface\\GossipFrame\\DailyQuestIcon.blp";
    local tex_bind2 = "Interface\\GossipFrame\\HealerGossipIcon.blp";
    local tex_bind3 = "Interface\\Buttons\\UI-GroupLoot-Pass-Up.blp";
    local tex_bind4 = "Interface\\Buttons\\UI-MicroStream-Yellow.blp"; 

  -- 퀘스트 관련 검사
  if (cfg.if_qIcon) then
	 for i = 2, 4 do
   
   qtext = _G[self:GetName().."TextLeft"..i]:GetText();
		
		if (qtext == "퀘스트") or (qtext == "퀘스트 아이템") or (qtext == "퀘스트 시작 아이템") then
			qvalue = 1;
      result1 = i;
      _G[self:GetName().."TextLeft"..result1]:SetText("|CFFe6cc80"..qtext.."|r");
			break;
		end
	 end
	end

	-- Quality Border
	-- if (not self.IsEmbedded) and (cfg.if_itemQualityBorder) then
		-- local itemQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(itemRarity or 0)));
		-- ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());
	-- end

	-- level + id -- Only alter the tip if we got either a valid "itemLevel" or "id"
	local showLevel = (itemLevel and cfg.if_showItemLevel);
	local showId = (id and cfg.if_showItemId);
	local linePadding = 2;

	if (showLevel or showId) then
		local targetTooltip = self;
		if (showLevel) then
			for h = 2, min(self:NumLines(),LibItemString.TOOLTIP_MAXLINE_LEVEL) do --for h = 2, self:NumLines() do
			
				line = _G[self:GetName().."TextLeft"..h];
				result3 = (line:GetText() or ""):match(ITEM_LEVEL.."+");
				result4 = (line:GetText() or ""):match("필요한 아이템 레벨: .+");
			
				if (line and result3) then
					result = result3;
					result2 = result4;
					line:SetText(nil);
					break;
				end
			end
		
			local line2 = _G[self:GetName().."TextLeft1"]:GetText(); 
		
			if (itemType == "제조법") and result3 then 
			 if (not line2:match("주문식".."+") or not line2:match("디자인".."+")) then 
			  self:AddLine(format("◎ 제작 %s",result or 0),unpack(cfg.if_infoColor)); 
			 end
			elseif (itemType == "보석") and result4 then
			 self:AddLine(format("◈ %s",result2 or 0),unpack(cfg.if_infoColor));
			end
		
			if (self == ejtt) then
				targetTooltip = self.Item1.tooltip;
				if (targetTooltip:IsShown()) then
					-- remove level from embedded tip
					for i = 2, min(targetTooltip:NumLines(), LibItemString.TOOLTIP_MAXLINE_LEVEL) do
						local line = _G[targetTooltip:GetName().."TextLeft"..i];
						if (line and (line:GetText() or ""):match(ITEM_LEVEL_PLUS)) then
							line:SetText(nil);
							break;
						end
					end
				else 
					-- remove level from tip's line pool
					for line in self.linePool:EnumerateActive() do
						if (line and (line:GetText() or ""):match(ITEM_LEVEL_PLUS)) then
							local linePredecessorPoint, linePredecessorRelativeTo, linePredecessorRelativePoint, linePredecessorXOfs, linePredecessorYOfs = line:GetPoint(1);
							
							if (line == self.textLineAnchor) then
								-- last line in line pool
								self.textLineAnchor = linePredecessorRelativeTo;
							else
								-- re-anchor successor line
								for successorLine in self.linePool:EnumerateActive() do
									local successorLinePredecessorPoint, successorLinePredecessorRelativeTo, successorLinePredecessorRelativePoint, successorLinePredecessorXOfs, successorLinePredecessorYOfs = successorLine:GetPoint(1);
									
									if (successorLinePredecessorRelativeTo == line) then
										local successorLineNumPoints = successorLine:GetNumPoints();
										local successorLineLeftPoint, successorLineLeftRelativeTo, successorLineLeftRelativePoint, successorLineLeftXOfs, successorLineLeftYOfs = successorLine:GetPoint(2);
										local successorLineRightPoint, successorLineRightRelativeTo, successorLineRightRelativePoint, successorLineRightXOfs, successorLineRightYOfs;
										if (successorLineNumPoints > 2) then
											successorLineRightPoint, successorLineRightRelativeTo, successorLineRightRelativePoint, successorLineRightXOfs, successorLineRightYOfs = successorLine:GetPoint(3);
										end
										successorLinePredecessorRelativeTo = linePredecessorRelativeTo;
										
										successorLine:ClearAllPoints();
										successorLine:SetPoint(successorLinePredecessorPoint, successorLinePredecessorRelativeTo, successorLinePredecessorRelativePoint, successorLinePredecessorXOfs, successorLinePredecessorYOfs);
										successorLine:SetPoint(successorLineLeftPoint, successorLineLeftRelativeTo, successorLineLeftRelativePoint, successorLineLeftXOfs, successorLineLeftYOfs);
										if (successorLineNumPoints > 2) then
											successorLine:SetPoint(successorLineRightPoint, successorLineRightRelativeTo, successorLineRightRelativePoint, successorLineRightXOfs, successorLineRightYOfs);
										end
										break;
									end
								end
							end
							
							-- remove level from tip's line pool
							self:SetHeight(self:GetHeight() - line:GetHeight() - linePadding);
							line:ClearAllPoints();
							self.linePool:Release(line);
							
							break;
						end
					end
				end
			else
				for i = 2, min(self:NumLines(),LibItemString.TOOLTIP_MAXLINE_LEVEL) do
					local line = _G[self:GetName().."TextLeft"..i];
					if (line and (line:GetText() or ""):match(ITEM_LEVEL_PLUS)) then
						line:SetText(nil);
						break;
					end
				end
			end
		end

		if (not showLevel) then
			targetTooltip:AddLine(format("아이템ID: %d",id),unpack(cfg.if_infoColor));
		elseif (showId) then
			targetTooltip:AddLine(format("아이템 레벨: %d, 아이템ID: %d",itemLevel,id),unpack(cfg.if_infoColor));
		else
			targetTooltip:AddLine(format("아이템 레벨: %d",itemLevel),unpack(cfg.if_infoColor));
		end
		targetTooltip:Show();	-- call Show() to resize tip after adding lines. only necessary for items in toy box.
	end

	-- 색약 보정
	if (itemRarity == 4) then
	local wtext;
	 if (cfg.if_wccc) then
	  wtext = _G[self:GetName().."TextLeft1"]; --:GetText() or "";
	   wtext:SetTextColor(1, 0, 0);
--	    self:SetBackdropBorderColor(1,0,0)  -- 아이템 테두리 색상 적용 조건일때 실행되도록 주석 처리
	 end
	end

   -- 귀속 여부 검사
  if (not self.IsEmbedded) then
   for j = 2, 6 do
	  btext = _G[self:GetName().."TextLeft"..j]:GetText();
		if btext == "착용 시 귀속" then				
		 bvalue = 1;
		 result = j;
		 break;
		elseif btext == "획득 시 귀속" then
		 bvalue = 2;
		 result = j;
		 break;
		elseif btext == "귀속 아이템" then
		 bvalue = 3;
		 result = j;
		 break;
		elseif btext == "계정 귀속" or btext == "블리자드 계정 귀속" then
		 bvalue = 4;
		 result = j;
		 break;
		end
	 end
	end
 
	  -- 귀속 아이템 표시
	  if (not self.IsEmbedded) and (cfg.if_bIcon) then 
	   if bvalue == 1 then 
      _G[self:GetName().."TextLeft"..result]:SetText("|CFF46FFFF"..btext.."|r |T"..tex_bind..":"..(cfg.if_iconSize - 22).."|t");
     elseif bvalue == 2 then
     _G[self:GetName().."TextLeft"..result]:SetText("|CFF98FB98"..btext.."|r |T"..tex_bind2..":"..(cfg.if_iconSize - 22).."|t");
     elseif bvalue == 3 then
     _G[self:GetName().."TextLeft"..result]:SetText("|CFFFF7878"..btext.."|r |T"..tex_bind3..":"..(cfg.if_iconSize - 22).."|t");
     elseif bvalue == 4 then
     _G[self:GetName().."TextLeft"..result]:SetText("|CFFe6cc80"..btext.."|r |T"..tex_bind4..":"..(cfg.if_iconSize - 18).."|t");
		 end
		end
   
	 -- 퀘스트 관련 검사 2
	 if (itemType == "퀘스트") or (itemSubType == "퀘스트") then
    qvalue = 2; -- 역시 퀘템이라면 1
   end

   -- 퀘스트 아이콘 표시 및 퀄리티 색상, 색약보정 색상 표현
   if cfg.if_qIcon then
	  if (qvalue == 1) or (qvalue == 2) then   
		 if (not cfg.if_inIcon) then
			local itemQualityColor = CreateColorFromHexString("FF71D5FF");
			ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());
			_G[self:GetName().."TextLeft1"]:SetText("|T"..tex..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText());
		 elseif (cfg.if_inIcon) and (cfg.if_showIcon) then
			local itemQualityColor = CreateColorFromHexString("FF71D5FF");
			ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());
			_G[self:GetName().."TextLeft1"]:SetText(_G[self:GetName().."TextLeft1"]:GetText().." |T"..tex..":"..(cfg.if_iconSize - 16).."|t");
      else
		local itemQualityColor = CreateColorFromHexString("FF71D5FF");
		ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());
		_G[self:GetName().."TextLeft1"]:SetText("|T"..tex..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText());
		 end
	  elseif (cfg.if_wccc) and itemRarity == 4 and (not self.IsEmbedded) and (cfg.if_itemQualityBorder) then  -- (cfg.if_itemQualityBorder) 조건 추가
		ttif:SetBackdropBorderColorLocked(self,true,1,0,0)
	  elseif (not self.IsEmbedded) and (cfg.if_itemQualityBorder) then  -- else 에서 (cfg.if_itemQualityBorder) 조건 만듬
		local itemQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(itemRarity or 0)));	  	  
		return ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());
      end
	  elseif (cfg.if_wccc) and itemRarity == 4 and (not self.IsEmbedded) and (cfg.if_itemQualityBorder) then  -- (cfg.if_itemQualityBorder) 조건 추가
		ttif:SetBackdropBorderColorLocked(self,true,1,0,0)
  	  elseif (not self.IsEmbedded) and (cfg.if_itemQualityBorder) then  -- (cfg.if_itemQualityBorder) 조건 만듬
		local itemQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(itemRarity or 0)));	   	  
		return ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());  -- else return 에서 else 삭제
	  end
    end
  end
end
-- 퀘스트 아이템 및 아이템 귀속, 색약 보정, 아이템 레벨 강조 추가 : End

-- keystone
local getRewardLevelInitialized = false;

function LinkTypeFuncs:keystone(link, linkType, itemID, mapID, keystoneLevel, ...) -- modifierID1, modifierID2, modifierID3, modifierID4
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID);
	local trueItemLevel = LibItemString:GetTrueItemLevel(link);
	if (trueItemLevel) then
		itemLevel = trueItemLevel;
	end

	-- Icon
	-- 쐐기돌 툴팁 안쪽에 아이콘 추가 시작
	if (not cfg.if_inIcon) then		
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self,linkType)) then
		local count = (itemStackCount and itemStackCount > 1 and (itemStackCount == 0x7FFFFFFF and "#" or itemStackCount) or "");
			self:ttSetIconTextureAndText(itemTexture, count);
		end
	else
		local newatt = "|T"..itemTexture..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		_G[self:GetName().."TextLeft1"]:SetText(newatt);
	end	
	-- 쐐기돌 툴팁 안쪽에 아이콘 추가 끝
	-- Quality Border
	if (cfg.if_wccc) then
		local ktext = _G[self:GetName().."TextLeft1"];
			ktext:SetTextColor(1, 0, 0);  	
		if (cfg.if_itemQualityBorder and cfg.if_wccc) then
			ttif:SetBackdropBorderColorLocked(self, true, 1,0,0);
		end
	end
	if (cfg.if_itemQualityBorder and not cfg.if_wccc) then	
		local itemQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(itemRarity or 0)));
		ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());
	end

	-- RewardLevel + WeeklyRewardLevel + ItemID + TimeLimit + AffixInfos
	if (not getRewardLevelInitialized) then -- makes shure that C_MythicPlus.GetRewardLevelForDifficultyLevel() returns values
		C_MythicPlus.RequestMapInfo();
		getRewardLevelInitialized = true;
	end
	local weeklyRewardLevel, endOfRunRewardLevel = nil, nil;
	if (keystoneLevel) then
		weeklyRewardLevel, endOfRunRewardLevel = C_MythicPlus.GetRewardLevelForDifficultyLevel(keystoneLevel);
	end

	local showId = (itemID and cfg.if_showItemId);
	local showRewardLevel = (endOfRunRewardLevel and cfg.if_modifyKeystoneTips);
	local showWeeklyRewardLevel = (weeklyRewardLevel and cfg.if_modifyKeystoneTips);
	local showTimeLimit = (mapID and cfg.if_modifyKeystoneTips);
	local showAffixInfo = cfg.if_modifyKeystoneTips;
	
	if (showId or showRewardLevel or showWeeklyRewardLevel or showTimeLimit or showAffixInfo) then
		local tipName = self:GetName();
		local infoColorMixin = CreateColor(cfg.if_infoColor[1], cfg.if_infoColor[2], cfg.if_infoColor[3], (cfg.if_infoColor[4] or 1));

		if (showId) then
			self:AddLine(format("아이템ID: %d", itemID), unpack(cfg.if_infoColor));  -- 한글화
		end
		
		if (not showRewardLevel and showWeeklyRewardLevel) then
			self:AddLine(format("주간 보상 레벨: %d", weeklyRewardLevel), unpack(cfg.if_infoColor));  -- 한글화
		elseif (showRewardLevel and showWeeklyRewardLevel) then
			self:AddLine(format("보상 레벨: %d, 주간 보상 레벨: %d", endOfRunRewardLevel, weeklyRewardLevel), unpack(cfg.if_infoColor));  -- 한글화
		elseif (showRewardLevel and not showWeeklyRewardLevel) then
			self:AddLine(format("보상 레벨: %d", endOfRunRewardLevel), unpack(cfg.if_infoColor));  -- 한글화
		end

		if (showTimeLimit) then
			local name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(mapID);
			if (timeLimit) then
				self:AddLine(format("시간 제한: %s", SecondsToTime(timeLimit, false, true)), unpack(cfg.if_infoColor));  -- 한글화
			end
		end
		
		if (showAffixInfo) then
			for i = 1, select('#', ...) do
				local modifierID = select(i, ...);
				modifierID = tonumber(modifierID);
				if (modifierID) then
					local modifierName, modifierDescription, fileDataID = C_ChallengeMode.GetAffixInfo(modifierID);
					if (modifierName and modifierDescription) then
						self:AddLine(format("%s %s\n%s", CreateTextureMarkup(fileDataID, 64, 64, 0, 0, 0.07, 0.93, 0.07, 0.93), GREEN_FONT_COLOR:WrapTextInColorCode(modifierName), modifierDescription), cfg.if_infoColor[1], cfg.if_infoColor[2], cfg.if_infoColor[3], true);
					end
				end
			end
		end
		
		self:Show();	-- call Show() to resize tip after adding lines
	end
end

-- spell
function LinkTypeFuncs:spell(isAura, source, link, linkType, spellID)
	local name, _, icon, castTime, minRange, maxRange, _spellID = GetSpellInfo(spellID);	-- [18.07.19] 8.0/BfA: 2nd param "rank/nameSubtext" now returns nil
	local rank = GetSpellSubtext(spellID);	-- will return nil at first unless its locally cached
	rank = (rank and rank ~= "" and ", "..rank or "");

	local mawPowerID = nil;
	if (isWoWSl) or (isWoWRetail) then
		local linkMawPower = GetMawPowerLinkBySpellID(spellID);
		if (linkMawPower) then
			local _linkType, _mawPowerID = linkMawPower:match("H?(%a+):(%d+)");
			mawPowerID = _mawPowerID;
			if (not table_MawPower_by_MawPowerID[mawPowerID]) then -- possible internal blizzard bug: GetMawPowerLinkBySpellID() e.g. returns mawPowerID 1453 for battle shout with spellID 6673, which doesn't exist in table MawPower (from https://wow.tools/dbc/?dbc=mawpower)
				mawPowerID = nil;
			end
		end
	end

	local isSpell = (not isAura);

	-- Icon
	-- 주문 아이콘 툴팁 안쪽에 아이콘 표시 추가 : Start
	if (not cfg.if_inIcon) then
		if (not self.IsEmbedded) and (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self,linkType)) then
			self:ttSetIconTextureAndText(icon);
		end
	else
   		local newstt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
	 	_G[self:GetName().."TextLeft1"]:SetText(newstt);
 	end
	-- 주문 아이콘 툴팁 안쪽에 아이콘 표시 추가 : End
	-- Caster
	local showAuraCaster = (cfg.if_showAuraCaster and UnitExists(source));
	if (showAuraCaster) then
		self:AddLine(format("시전자: %s", UnitName(source) or UNKNOWNOBJECT), unpack(cfg.if_infoColor));  -- 한글화
	end

	-- MawPowerID and SpellID + Rank -- pre-16.08.25 only caster was formatted as this: "<Applied by %s>"
	local showMawPowerID = (cfg.if_showAuraSpellIdAndRank and mawPowerID);
	local showSpellIdAndRank = (((isSpell and cfg.if_showSpellIdAndRank) or (isAura and cfg.if_showAuraSpellIdAndRank)) and spellID and (spellID ~= 0));
	if (showMawPowerID or showSpellIdAndRank) then
		if (not showMawPowerID) then
			self:AddLine(format("주문ID: %d", spellID)..rank, unpack(cfg.if_infoColor));
		elseif (showSpellIdAndRank) then
			self:AddLine(format("령 능력ID: %d, 주문ID: %d", mawPowerID, spellID)..rank, unpack(cfg.if_infoColor));
		else
			self:AddLine(format("령 능력ID: %d", mawPowerID), unpack(cfg.if_infoColor));
		end
	end

	if (showAuraCaster or showMawPowerID or showSpellIdAndRank) then
		self:Show();	-- call Show() to resize tip after adding lines
	end

  	-- Colored Border
	if (not self.IsEmbedded) and (cfg.if_spellColoredBorder) then
		local spellColor = nil;
		
		if (mawPowerID and spellID) then
			local rarityAtlas = C_Spell.GetMawPowerBorderAtlasBySpellID(spellID);
			if (rarityAtlas) then
				local rarityAtlasColors = { -- see table UiTextureAtlasElement name "jailerstower-animapowerlist-powerborder*"
					["jailerstower-animapowerlist-powerborder-white"] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Common],
					["jailerstower-animapowerlist-powerborder-green"] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Uncommon],
					["jailerstower-animapowerlist-powerborder-blue"] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Rare],
					["jailerstower-animapowerlist-powerborder-purple"] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic]
				};
				if (rarityAtlasColors[rarityAtlas]) then
					spellColor = rarityAtlasColors[rarityAtlas].color;
				end
			end
		end
		
		if (not spellColor) then
			spellColor = CreateColorFromHexString("FF71D5FF"); -- see GetSpellLink(). extraction of color code from this function not used, because in classic it only returns the spell name instead of a link.
		end
		-- 색약 보정을 적용하기 위한 변수 추가 및 보정 시작
		local Wc = mawPowerID
		local mawPowerWccc = Wc == "19" or Wc == "35" or Wc == "59" or Wc == "60" or Wc == "61" or Wc == "62" or Wc == "64" or Wc == "65" or Wc == "66" or Wc == "94"or Wc == "95" or Wc == "96" or 
			Wc == "97" or Wc == "98" or Wc == "103" or Wc == "110" or Wc == "112" or Wc == "154" or Wc == "155" or Wc == "156" or Wc == "157" or Wc == "162" or Wc == "165" or Wc == "178" or Wc == "186" or 
			Wc == "199" or Wc == "213" or Wc == "220" or Wc == "227" or Wc == "234" or Wc == "241" or Wc == "248" or Wc == "255" or Wc == "262" or Wc == "269" or Wc == "276" or Wc == "283" or Wc == "288" or 
			Wc == "289" or Wc == "294" or Wc == "295" or Wc == "300" or Wc == "301" or Wc == "306" or Wc == "307" or Wc == "312" or Wc == "313" or Wc == "318" or Wc == "319" or Wc == "324" or Wc == "325" or 
			Wc == "330" or Wc == "336" or Wc == "337" or Wc == "342" or Wc == "343" or Wc == "348" or Wc == "349" or Wc == "354" or Wc == "355" or Wc == "360" or Wc == "739" or Wc == "746" or Wc == "755" or 
			Wc == "757" or Wc == "764" or Wc == "765" or Wc == "777" or Wc == "778" or Wc == "787" or Wc == "788" or Wc == "794" or Wc == "806" or Wc == "807" or Wc == "815" or Wc == "816" or Wc == "820" or 
			Wc == "825" or Wc == "826" or Wc == "830" or Wc == "831" or Wc == "832" or Wc == "833" or Wc == "834" or Wc == "841" or Wc == "933" or Wc == "939" or Wc == "940" or Wc == "941" or Wc == "942" or 
			Wc == "945" or Wc == "948" or Wc == "949" or Wc == "950" or Wc == "951" or Wc == "952" or Wc == "953" or Wc == "978" or Wc == "979" or Wc == "980" or Wc == "981" or Wc == "982" or Wc == "983" or 
			Wc == "990" or Wc == "1038" or Wc == "1039" or Wc == "1040" or Wc == "1041" or Wc == "1042" or Wc == "1043" or Wc == "1045" or Wc == "1068" or Wc == "1069" or Wc == "1070" or Wc == "1071" or 
			Wc == "1072" or Wc == "1107" or Wc == "1108" or Wc == "1119" or Wc == "1121" or Wc == "1136" or Wc == "1137" or Wc == "1138" or Wc == "1144" or Wc == "1146" or Wc == "1152" or Wc == "1153" or 
			Wc == "1160" or Wc == "1165" or Wc == "1176" or Wc == "1179" or Wc == "1182" or Wc == "1195" or Wc == "1196" or Wc == "1203" or Wc == "1206" or Wc == "1209" or Wc == "1210" or Wc == "1212" or 
			Wc == "1216" or Wc == "1219" or Wc == "1222" or Wc == "1225" or Wc == "1228" or Wc == "1229" or Wc == "1235" or Wc == "1236" or Wc == "1240" or Wc == "1242" or Wc == "1245" or Wc == "1246" or 
			Wc == "1256" or Wc == "1259" or Wc == "1262" or Wc == "1266" or Wc == "1269" or Wc == "1271" or Wc == "1273" or Wc == "1277" or Wc == "1280" or Wc == "1284" or Wc == "1285" or Wc == "1288" or 
			Wc == "1325" or Wc == "1338" or Wc == "1341" or Wc == "1347" or Wc == "1354" or Wc == "1363" or Wc == "1366" or Wc == "1369" or Wc == "1372" or Wc == "1375" or Wc == "1378" or Wc == "1381" or 
			Wc == "1384" or Wc == "1387" or Wc == "1390" or Wc == "1393" or Wc == "1396" or Wc == "1438" or Wc == "1448" or Wc == "1450" or Wc == "1459" or Wc == "1476" or Wc == "1477" or Wc == "1478" or 
			Wc == "1479" or Wc == "1480" or Wc == "1484" or Wc == "1512" or Wc == "1513" or Wc == "1514" or Wc == "1515" or Wc == "1516" or Wc == "1517" or Wc == "1518" or Wc == "1523" or Wc == "1524" or 
			Wc == "1525" or Wc == "1526" or Wc == "1527" or Wc == "1528" or Wc == "1529" or Wc == "1538" or Wc == "1542"						   											
		if (mawPowerWccc and cfg.if_wccc and cfg.if_itemQualityBorder) then
			spellColor = CreateColorFromHexString("FFFF0000");  -- 빨간색 Hex 코드 추가
		end
		if (mawPowerWccc and cfg.if_wccc) then
		local mtext = _G[self:GetName().."TextLeft1"];
			mtext:SetTextColor(1, 0, 0);  		
		end
		-- 색약 보정을 적용하기 위한 변수 추가 및 보정 끝
		ttif:SetBackdropBorderColorLocked(self, true, spellColor:GetRGBA());
	end
end

-- maw power
function LinkTypeFuncs:mawpower(link, linkType, mawPowerID)
	local spellID = nil;
	if (mawPowerID and table_MawPower_by_MawPowerID[mawPowerID]) then
		spellID = table_MawPower_by_MawPowerID[mawPowerID].spellID;
	end
	
	local name, _, icon, castTime, minRange, maxRange, _spellID = GetSpellInfo(spellID);	-- [18.07.19] 8.0/BfA: 2nd param "rank/nameSubtext" now returns nil
	local rank = GetSpellSubtext(spellID);	-- will return nil at first unless its locally cached
	rank = (rank and rank ~= "" and ", "..rank or "");

	-- Icon
	if (not cfg.if_inIcon) then
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self,linkType)) then
			self:ttSetIconTextureAndText(icon);
		end
	else
   		local newstt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
	 	_G[self:GetName().."TextLeft1"]:SetText(newstt);
 	end

	-- MawPowerID and SpellID + Rank -- pre-16.08.25 only caster was formatted as this: "<Applied by %s>"
	local showMawPowerID = (cfg.if_showAuraSpellIdAndRank and mawPowerID and (mawPowerID ~= 0));
	local showSpellIdAndRank = (cfg.if_showSpellIdAndRank and spellID and (spellID ~= 0));
	if (showMawPowerID or showSpellIdAndRank) then
		if (not showMawPowerID) then
			self:AddLine(format("주문ID: %d", spellID)..rank, unpack(cfg.if_infoColor));
		elseif (showSpellIdAndRank) then
			self:AddLine(format("령 능력ID: %d, 주문ID: %d", mawPowerID, spellID)..rank, unpack(cfg.if_infoColor));
		else
			self:AddLine(format("령 능력ID: %d", mawPowerID), unpack(cfg.if_infoColor));
		end
		self:Show();	-- call Show() to resize tip after adding lines
	end

  	-- Colored Border
	if (cfg.if_spellColoredBorder) then
		local spellColor = nil;
		
		if (mawPowerID and spellID) then
			local rarityAtlas = C_Spell.GetMawPowerBorderAtlasBySpellID(spellID);
			if (rarityAtlas) then
				if (rarityAtlas == "jailerstower-animapowerlist-powerborder-white") then -- see table UiTextureAtlasElement name "jailerstower-animapowerlist-powerborder*"
					spellColor = CreateColorFromHexString(select(4, GetItemQualityColor(1)));
				elseif (rarityAtlas == "jailerstower-animapowerlist-powerborder-green") then
					spellColor = CreateColorFromHexString(select(4, GetItemQualityColor(2)));
				elseif (rarityAtlas == "jailerstower-animapowerlist-powerborder-blue") then
					spellColor = CreateColorFromHexString(select(4, GetItemQualityColor(3)));
				elseif (rarityAtlas == "jailerstower-animapowerlist-powerborder-purple") then
					spellColor = CreateColorFromHexString(select(4, GetItemQualityColor(4)));
				end
			end
		end
		
		if (not spellColor) then
			spellColor = CreateColorFromHexString("FF71D5FF"); -- see GetSpellLink(). extraction of color code from this function not used, because in classic it only returns the spell name instead of a link.
		end
		-- 색약 보정을 적용하기 위한 변수 추가 및 보정 시작
		local Wc = mawPowerID
		local mawPowerWccc = Wc == "19" or Wc == "35" or Wc == "59" or Wc == "60" or Wc == "61" or Wc == "62" or Wc == "64" or Wc == "65" or Wc == "66" or Wc == "94"or Wc == "95" or Wc == "96" or 
			Wc == "97" or Wc == "98" or Wc == "103" or Wc == "110" or Wc == "112" or Wc == "154" or Wc == "155" or Wc == "156" or Wc == "157" or Wc == "162" or Wc == "165" or Wc == "178" or Wc == "186" or 
			Wc == "199" or Wc == "213" or Wc == "220" or Wc == "227" or Wc == "234" or Wc == "241" or Wc == "248" or Wc == "255" or Wc == "262" or Wc == "269" or Wc == "276" or Wc == "283" or Wc == "288" or 
			Wc == "289" or Wc == "294" or Wc == "295" or Wc == "300" or Wc == "301" or Wc == "306" or Wc == "307" or Wc == "312" or Wc == "313" or Wc == "318" or Wc == "319" or Wc == "324" or Wc == "325" or 
			Wc == "330" or Wc == "336" or Wc == "337" or Wc == "342" or Wc == "343" or Wc == "348" or Wc == "349" or Wc == "354" or Wc == "355" or Wc == "360" or Wc == "739" or Wc == "746" or Wc == "755" or 
			Wc == "757" or Wc == "764" or Wc == "765" or Wc == "777" or Wc == "778" or Wc == "787" or Wc == "788" or Wc == "794" or Wc == "806" or Wc == "807" or Wc == "815" or Wc == "816" or Wc == "820" or 
			Wc == "825" or Wc == "826" or Wc == "830" or Wc == "831" or Wc == "832" or Wc == "833" or Wc == "834" or Wc == "841" or Wc == "933" or Wc == "939" or Wc == "940" or Wc == "941" or Wc == "942" or 
			Wc == "945" or Wc == "948" or Wc == "949" or Wc == "950" or Wc == "951" or Wc == "952" or Wc == "953" or Wc == "978" or Wc == "979" or Wc == "980" or Wc == "981" or Wc == "982" or Wc == "983" or 
			Wc == "990" or Wc == "1038" or Wc == "1039" or Wc == "1040" or Wc == "1041" or Wc == "1042" or Wc == "1043" or Wc == "1045" or Wc == "1068" or Wc == "1069" or Wc == "1070" or Wc == "1071" or 
			Wc == "1072" or Wc == "1107" or Wc == "1108" or Wc == "1119" or Wc == "1121" or Wc == "1136" or Wc == "1137" or Wc == "1138" or Wc == "1144" or Wc == "1146" or Wc == "1152" or Wc == "1153" or 
			Wc == "1160" or Wc == "1165" or Wc == "1176" or Wc == "1179" or Wc == "1182" or Wc == "1195" or Wc == "1196" or Wc == "1203" or Wc == "1206" or Wc == "1209" or Wc == "1210" or Wc == "1212" or 
			Wc == "1216" or Wc == "1219" or Wc == "1222" or Wc == "1225" or Wc == "1228" or Wc == "1229" or Wc == "1235" or Wc == "1236" or Wc == "1240" or Wc == "1242" or Wc == "1245" or Wc == "1246" or 
			Wc == "1256" or Wc == "1259" or Wc == "1262" or Wc == "1266" or Wc == "1269" or Wc == "1271" or Wc == "1273" or Wc == "1277" or Wc == "1280" or Wc == "1284" or Wc == "1285" or Wc == "1288" or 
			Wc == "1325" or Wc == "1338" or Wc == "1341" or Wc == "1347" or Wc == "1354" or Wc == "1363" or Wc == "1366" or Wc == "1369" or Wc == "1372" or Wc == "1375" or Wc == "1378" or Wc == "1381" or 
			Wc == "1384" or Wc == "1387" or Wc == "1390" or Wc == "1393" or Wc == "1396" or Wc == "1438" or Wc == "1448" or Wc == "1450" or Wc == "1459" or Wc == "1476" or Wc == "1477" or Wc == "1478" or 
			Wc == "1479" or Wc == "1480" or Wc == "1484" or Wc == "1512" or Wc == "1513" or Wc == "1514" or Wc == "1515" or Wc == "1516" or Wc == "1517" or Wc == "1518" or Wc == "1523" or Wc == "1524" or 
			Wc == "1525" or Wc == "1526" or Wc == "1527" or Wc == "1528" or Wc == "1529" or Wc == "1538" or Wc == "1542"						   											
		if (mawPowerWccc and cfg.if_wccc and cfg.if_itemQualityBorder) then
			spellColor = CreateColorFromHexString("FFFF0000");  -- 빨간색 Hex 코드 추가
		end
		if (mawPowerWccc and cfg.if_wccc) then
		local mtext = _G[self:GetName().."TextLeft1"];
			mtext:SetTextColor(1, 0, 0);  		
		end
		-- 색약 보정을 적용하기 위한 변수 추가 및 보정 끝		
		ttif:SetBackdropBorderColorLocked(self, true, spellColor:GetRGBA());
	end
end

-- quest
function LinkTypeFuncs:quest(link, linkType, questID, level)
	local tagInfo = C_QuestLog.GetQuestTagInfo(questID);
	local quality = tagInfo and tagInfo.quality or Enum.WorldQuestQuality.Common;
	local qualityWccc = quality == Enum.WorldQuestQuality.Epic;  -- 색약 보정 위한 에픽(보라색) 등급 변수 추가

	-- QuestLevel + QuestID
	local showLevel = (level and cfg.if_showQuestLevel);
	local showId = (questID and cfg.if_showQuestId);

	if (showLevel or showId) then
		if (not showLevel) then
			self:AddLine(format("퀘스트ID: %d", questID or 0), unpack(cfg.if_infoColor));
		elseif (showId) then
			self:AddLine(format("퀘스트 레벨: %d, 퀘스트ID: %d", level or 0, questID or 0), unpack(cfg.if_infoColor));
		else
			self:AddLine(format("퀘스트 레벨: %d", level or 0), unpack(cfg.if_infoColor));
		end
		self:Show();	-- call Show() to resize tip after adding lines
	end

  	-- Difficulty Border
  	-- 색약 보정 위한 함수 추가(문자) 시작
		local tagInfo = C_QuestLog.GetQuestTagInfo(questID);  	
	if (cfg.if_wccc) and qualityWccc then
		local qtext = _G[self:GetName().."TextLeft1"];
			qtext:SetTextColor(1, 0, 0);
	end
	-- 색약 보정 위한 함수 추가(문자) 끝
	local difficultyColorMixin;
  	
	if (C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID)) then -- see GameTooltip_AddQuest
		difficultyColorMixin = WORLD_QUEST_QUALITY_COLORS[quality].color;
	else
		local difficultyColor = GetDifficultyColor and GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID)) or GetQuestDifficultyColor(level);
		difficultyColorMixin = CreateColor(difficultyColor.r, difficultyColor.g, difficultyColor.b, 1);
	end
	if (cfg.if_itemQualityBorder) then  -- 색약 보정 정상작동 위해 조건 이동		
		ttif:SetBackdropBorderColorLocked(self, true, difficultyColorMixin:GetRGBA());
	end
	-- 색약 보정 위한 함수 추가(테두리) 시작
	if (not self.IsEmbedded) and (cfg.if_itemQualityBorder and cfg.if_wccc) and qualityWccc then
		ttif:SetBackdropBorderColorLocked(self,true,1,0,0);
	end
	-- 색약 보정 위한 함수 추가(테두리) 끝
end
	
-- currency -- Thanks to Vladinator for adding this!
function LinkTypeFuncs:currency(link, linkType, currencyID, quantity)
	local _quantity = (quantity or 0); -- mouseover over sightless eye currency link of missing recipes of broken isles (legion) returns nil
	local currencyInfo = nil;
	local icon, quality;
	local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer and C_CurrencyInfo.IsCurrencyContainer(currencyID, _quantity);

	if (isCurrencyContainer) then
		currencyInfo = C_CurrencyInfo.GetCurrencyContainerInfo(currencyID, _quantity);

		icon = currencyInfo.icon;
		quality = currencyInfo.quality;
	else
		currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
		icon = currencyInfo.iconFileID;
		quality = currencyInfo.quality;
	end

	-- Icon
	-- 화폐 아이콘 툴팁 안쪽에 아이콘 표시 추가 시작
	if (not cfg.if_inIcon) then
		if (not self.IsEmbedded) and (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self,linkType)) then
			if (currencyInfo) then
				local displayQuantity = nil;
				self:ttSetIconTextureAndText(icon, _quantity);	-- As of 5.2 GetCurrencyInfo() now returns full texture path. Previously you had to prefix it with "Interface\\Icons\\"
			end
		end
	else
		if (not self.IsEmbedded) then
			local newatt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
			_G[self:GetName().."TextLeft1"]:SetText(newatt);
		end
	end	
	-- 화폐 아이콘 툴팁 안쪽에 아이콘 표시 추가 끝
	-- CurrencyID
	if (cfg.if_showCurrencyId) then
		self:AddLine(format("화폐ID: %d", currencyID), unpack(cfg.if_infoColor));
		self:Show();	-- call Show() to resize tip after adding lines
	end

  	-- Quality Border
	if (not self.IsEmbedded) and (cfg.if_itemQualityBorder) then
		if (currencyInfo) then
			local currencyQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(quality)));
			ttif:SetBackdropBorderColorLocked(self, true, currencyQualityColor:GetRGBA());
		end
	-- 색약 보정 위한 함수 추가 시작				
  		if (cfg.if_wccc) and (quality == 4) then
			local ktext = _G[self:GetName().."TextLeft1"];
				ktext:SetTextColor(1, 0, 0);  	
			if (cfg.if_itemQualityBorder and cfg.if_wccc) and (quality == 4) then
				ttif:SetBackdropBorderColorLocked(self,true,1,0,0);
			end
		end
	-- 색약 보정 위한 함수 추가 끝
	end
end

-- achievement
function LinkTypeFuncs:achievement(link, linkType, achievementID, guid, completed, month, day, year, criteria1, criteria2, criteria3, criteria4)
	local _achievementID, name, points, _completed, _month, _day, _year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID);
	if (cfg.if_modifyAchievementTips) then
		completed = (tonumber(completed) == 1);
		local tipName = self:GetName();
		local isPlayer = (UnitGUID("player"):sub(3) == guid);
		-- Get category
		local catId = GetAchievementCategory(achievementID);
		local category, catParent = GetCategoryInfo(catId);
		local catName;
		while (catParent > 0) do
			catName, catParent = GetCategoryInfo(catParent);
			category = catName.." - "..category;
		end
		-- Get Criteria
		wipe(criteriaList);
		local criteriaComplete = 0;
		for i = 6, self:NumLines() do
			local left = _G[tipName.."TextLeft"..i];
			local right = _G[tipName.."TextRight"..i];
			local leftText = left:GetText();
			local rightText = right:GetText();
			if (leftText and leftText ~= " ") then
				criteriaList[#criteriaList + 1] = { label = leftText, done = left:GetTextColor() < 0.5 };
				if (criteriaList[#criteriaList].done) then
					criteriaComplete = (criteriaComplete + 1);
				end
			end
			if (rightText and rightText ~= " ") then
				criteriaList[#criteriaList + 1] = { label = rightText, done = right:GetTextColor() < 0.5 };
				if (criteriaList[#criteriaList].done) then
					criteriaComplete = (criteriaComplete + 1);
				end
			end
		end
		-- Cache Info
		local progressText = _G[tipName.."TextLeft3"]:GetText() or "";
		-- Rebuild Tip
		self:ClearLines();
		local stat = isPlayer and GetStatistic(achievementID);
		self:AddDoubleLine(name,(stat ~= "0" and stat ~= "--" and stat),nil,nil,nil,1,1,1);
		self:AddLine("<"..category..">");
		if (rewardText) then
			self:AddLine(rewardText,unpack(cfg.if_infoColor));
		end
		self:AddLine(description,1,1,1,1);
		if (progressText ~= "") then
			self:AddLine(BoolCol[completed]..progressText);
		end
		if (#criteriaList > 0) then
			self:AddLine(" ");
			self:AddLine("업적 목표: 총|cffffffff"..#criteriaList.."|r개 중에 |cffffffff"..criteriaComplete.."|r개 완료"); -- 한글화
			local r1, g1, b1, r2, g2, b2;
			local myDone1, myDone2;
			for i = 1, #criteriaList, 2 do
				r1, g1, b1 = unpack(criteriaList[i].done and COLOR_COMPLETE or COLOR_INCOMPLETE);
				if (criteriaList[i + 1]) then
					r2, g2, b2 = unpack(criteriaList[i + 1].done and COLOR_COMPLETE or COLOR_INCOMPLETE);
				end
				if (not isPlayer) then
					local success, _, _, completed = pcall(GetAchievementCriteriaInfo,achievementID,i);
					myDone1 = (success and completed);
					--myDone1 = select(3,GetAchievementCriteriaInfo(achievementID,i));
					if (i + 1 <= #criteriaList) then
						local success, _, _, completed = pcall(GetAchievementCriteriaInfo,achievementID,i + 1);
						myDone2 = (success and completed);
						--myDone2 = select(3,GetAchievementCriteriaInfo(achievementID,i + 1));
					end
				end
				myDone1 = (isPlayer and "" or BoolCol[myDone1].."*|r")..criteriaList[i].label;
				myDone2 = criteriaList[i + 1] and criteriaList[i + 1].label..(isPlayer and "" or BoolCol[myDone2].."*");
				self:AddDoubleLine(myDone1,myDone2,r1,g1,b1,r2,g2,b2);
			end
		end
		-- AchievementID + Category
		if (cfg.if_showAchievementIdAndCategoryId) then
			self:AddLine(format("업적ID: %d, 분류ID: %d",achievementID or 0,catId or 0),unpack(cfg.if_infoColor));
		end
		-- Show
		self:Show();	-- call Show() to resize tip after adding lines
	else
		-- AchievementID + Category
		if (cfg.if_showAchievementIdAndCategoryId) then
			local catId = GetAchievementCategory(achievementID);
			self:AddLine(format("업적ID: %d, 분류ID: %d",achievementID or 0,catId or 0),unpack(cfg.if_infoColor));
			self:Show();	-- call Show() to resize tip after adding lines
		end
	end
	-- Icon
	if (not cfg.if_inIcon) then
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self,linkType)) then
			self:ttSetIconTextureAndText(icon,points);
		end
	else
		local newatt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		  _G[self:GetName().."TextLeft1"]:SetText(newatt);
	end		
  	--  Colored Border
	if (cfg.if_achievmentColoredBorder) then
		local achievementColor = ACHIEVEMENT_COLOR_CODE:match("|c(%x+)");
		local achievementColorMixin = CreateColorFromHexString(achievementColor);
		ttif:SetBackdropBorderColorLocked(self, true, achievementColorMixin:GetRGBA());
	end
end

-- battle pet
function LinkTypeFuncs:battlepet(link, linkType, speciesID, level, breedQuality, maxHealth, power, speed, petID, displayID)
	local speciesName, speciesIcon, petType, creatureID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, _displayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID);

	-- Icon
	if (not cfg.if_inIcon) then	
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(speciesIcon);
		end
	else
		local newatt = "|T"..speciesIcon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		  _G[self:GetName().."TextLeft1"]:SetText(newatt);
	end
	
	-- Quality Border
	if (cfg.if_itemQualityBorder) then
		local battlePetQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(breedQuality or 0)));
		ttif:SetBackdropBorderColorLocked(self, true, battlePetQualityColor:GetRGBA());
	-- 색약 보정 위한 함수 추가 시작
		if (cfg.if_wccc) then
			ttif:SetBackdropBorderColorLocked(self, true, battlePetQualityColor:GetRGBA(1,0,0));
		end
	end
	if (cfg.if_wccc) and breedQuality == 4 then
		local ptext = _G[self:GetName().."TextLeft1"];
		ptext:SetTextColor(1, 0, 0);
	-- 색약 보정 위한 함수 추가 끝
	end

	-- level + creatureID -- Only alter the tip if we got either a valid "level" or "creatureID"
	local showLevel = (level and cfg.if_showBattlePetLevel);
	local showId = (creatureID and cfg.if_showBattlePetId);
	local linePadding = 2;

	if (showLevel or showId) then
		if (showLevel) then
			if (self == bptt or self == fbptt) then
				-- remove level from tip
				self:SetHeight(self:GetHeight() - self.Level:GetHeight() - linePadding);
				self.Level:SetText(nil);
				
				-- re-anchor successor node
				local levelPoint, levelRelativeTo, levelRelativePoint, levelXOfs, levelYOfs = self.Level:GetPoint();
				local healthTexturePoint, healthTextureRelativeTo, healthTextureRelativePoint, healthTextureXOfs, healthTextureYOfs = self.HealthTexture:GetPoint();
				healthTextureRelativeTo = levelRelativeTo;
				
				self.HealthTexture:ClearAllPoints();
				self.HealthTexture:SetPoint(healthTexturePoint, healthTextureRelativeTo, healthTextureRelativePoint, healthTextureXOfs, healthTextureYOfs);
				
				-- remove level from tip's line pool
				for line in self.linePool:EnumerateActive() do
					if (line and (line:GetText() or ""):match(BATTLE_PET_CAGE_TOOLTIP_LEVEL)) then
						local linePredecessorPoint, linePredecessorRelativeTo, linePredecessorRelativePoint, linePredecessorXOfs, linePredecessorYOfs = line:GetPoint(1);
						
						if (line == self.textLineAnchor) then
							-- last line in line pool
							self.textLineAnchor = linePredecessorRelativeTo;
						else
							-- re-anchor successor line
							for successorLine in self.linePool:EnumerateActive() do
								local successorLinePredecessorPoint, successorLinePredecessorRelativeTo, successorLinePredecessorRelativePoint, successorLinePredecessorXOfs, successorLinePredecessorYOfs = successorLine:GetPoint(1);
								
								if (successorLinePredecessorRelativeTo == line) then
									local successorLineNumPoints = successorLine:GetNumPoints();
									local successorLineLeftPoint, successorLineLeftRelativeTo, successorLineLeftRelativePoint, successorLineLeftXOfs, successorLineLeftYOfs = successorLine:GetPoint(2);
									local successorLineRightPoint, successorLineRightRelativeTo, successorLineRightRelativePoint, successorLineRightXOfs, successorLineRightYOfs;
									if (successorLineNumPoints > 2) then
										successorLineRightPoint, successorLineRightRelativeTo, successorLineRightRelativePoint, successorLineRightXOfs, successorLineRightYOfs = successorLine:GetPoint(3);
									end
									successorLinePredecessorRelativeTo = linePredecessorRelativeTo;
									
									successorLine:ClearAllPoints();
									successorLine:SetPoint(successorLinePredecessorPoint, successorLinePredecessorRelativeTo, successorLinePredecessorRelativePoint, successorLinePredecessorXOfs, successorLinePredecessorYOfs);
									successorLine:SetPoint(successorLineLeftPoint, successorLineLeftRelativeTo, successorLineLeftRelativePoint, successorLineLeftXOfs, successorLineLeftYOfs);
									if (successorLineNumPoints > 2) then
										successorLine:SetPoint(successorLineRightPoint, successorLineRightRelativeTo, successorLineRightRelativePoint, successorLineRightXOfs, successorLineRightYOfs);
									end
									break;
								end
							end
						end
						
						-- remove level from tip's line pool
						self:SetHeight(self:GetHeight() - line:GetHeight() - linePadding);
						line:ClearAllPoints();
						self.linePool:Release(line);
						
						break;
					end
				end
			else
				for i = 2, min(self:NumLines(),LibItemString.TOOLTIP_MAXLINE_LEVEL) do
					local line = _G[self:GetName().."TextLeft"..i];
					if (line and (line:GetText() or ""):match(BATTLE_PET_CAGE_TOOLTIP_LEVEL)) then
						line:SetText(nil);
						break;
					end
				end
			end
		end
		
		if (not showLevel) then
			self:AddLine(format("NPC ID: %d", tonumber(creatureID)), unpack(cfg.if_infoColor));
		elseif (showId) then
			self:AddLine(format("레벨: %d, NpcID: %d", level, tonumber(creatureID)), unpack(cfg.if_infoColor));
		else
			self:AddLine(format("레벨: %d", level), unpack(cfg.if_infoColor));
		end

		if (self ~= bptt and self ~= fbptt) then
			self:Show();	-- call Show() to resize tip after adding lines. only necessary for pet tooltip in action bar.
		end
	end
	
	if (not showLevel) then
		if (self == bptt or self == fbptt) then
			-- re-anchor successor node if necessary
			local healthTexturePoint, healthTextureRelativeTo, healthTextureRelativePoint, healthTextureXOfs, healthTextureYOfs = self.HealthTexture:GetPoint();
			
			if (healthTextureRelativeTo ~= self.Level) then
				healthTextureRelativeTo = self.Level;
				
				self.HealthTexture:ClearAllPoints();
				self.HealthTexture:SetPoint(healthTexturePoint, healthTextureRelativeTo, healthTextureRelativePoint, healthTextureXOfs, healthTextureYOfs);
			end
		end
	end
end

-- battle pet ability
function LinkTypeFuncs:battlePetAbil(link, linkType, abilityID, speciesID, petID, additionalText)
	local abilityName, abilityIcon, abilityType = C_PetJournal.GetPetAbilityInfo(abilityID)

	-- Icon
	if (not cfg.if_inIcon) then	
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(abilityIcon);
		end
	else
		self:ttSetIconTextureAndText(nil);
	end
		
	-- AbilityID
	if (cfg.if_showBattlePetAbilityId) then
		self:AddLine("능력ID: "..abilityID, unpack(cfg.if_infoColor));
		-- self:Show();	-- call Show() to resize tip after adding lines
	end

	-- Colored Border
	if (cfg.if_spellColoredBorder) then
		local abilityColor = CreateColorFromHexString("FF4E96F7"); -- see GetBattlePetAbilityHyperlink() in "ItemRef.lua"
		ttif:SetBackdropBorderColorLocked(self, true, abilityColor:GetRGBA());
	end
end

-- conduit -- Thanks to hobulian for code example
function LinkTypeFuncs:conduit(link, linkType, conduitID, conduitRank)
		local spellID = C_Soulbinds.GetConduitSpellID(conduitID, conduitRank);
		local name, _, icon, castTime, minRange, maxRange, _spellID = GetSpellInfo(spellID);
	-- 도관 아이콘 툴팁 안쪽에 아이콘 표시 추가 시작
	-- Icon
	if (not cfg.if_inIcon) then	
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(icon);
		end
	else
		local newatt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		_G[self:GetName().."TextLeft1"]:SetText(newatt);
	end
	-- 도관 아이콘 툴팁 안쪽에 아이콘 표시 추가 끝

	-- ItemLevel + ConduitID
	local conduitCollectionData = C_Soulbinds.GetConduitCollectionData(conduitID);
	local conduitItemLevel = (conduitCollectionData and conduitCollectionData.conduitItemLevel); -- conduitCollectionData is only available for own conduits
	
	local showLevel = (conduitItemLevel and cfg.if_showItemLevel);
	local showId = (conduitID and cfg.if_showItemId);

	if (showLevel or showId) then
		if (showLevel) then
			for i = 2, min(self:NumLines(),LibItemString.TOOLTIP_MAXLINE_LEVEL) do
				local line = _G[self:GetName().."TextLeft"..i];
				if (line and (line:GetText() or ""):match(ITEM_LEVEL_PLUS)) then
					line:SetText(nil);
					break;
				end
			end
		end
		
		if (not showLevel) then
			self:AddLine(format("도관ID: %d", conduitID), unpack(cfg.if_infoColor));  -- 한글화
		elseif (showId) then
			self:AddLine(format("아이템 레벨: %d, 도관ID: %d", conduitItemLevel, conduitID), unpack(cfg.if_infoColor));  -- 한글화
		else
			self:AddLine(format("아이템 레벨: %d", conduitItemLevel), unpack(cfg.if_infoColor));  -- 한글화
		end
		self:Show();	-- call Show() to resize tip after adding lines. only necessary for items in toy box.
	end

  	-- Quality Border	
	-- 색약 보정 위한 함수 추가 시작	  	
	if (cfg.if_wccc) then
	local ctext = _G[self:GetName().."TextLeft1"];
		ctext:SetTextColor(1, 0, 0);  	
		if (cfg.if_itemQualityBorder and cfg.if_wccc) then
			ttif:SetBackdropBorderColorLocked(self, true, 1,0,0);		
		end
	end	      
		if (cfg.if_itemQualityBorder and not cfg.if_wccc) then
	-- 색약 보정 위한 함수 추가 끝
		local conduitQuality = C_Soulbinds.GetConduitQuality(conduitID, conduitRank);
		local conduitQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(conduitQuality or 0)));
		ttif:SetBackdropBorderColorLocked(self, true, conduitQualityColor:GetRGBA());
	end
end

-- transmog appearance (see WardrobeCollectionFrameMixin:GetAppearanceItemHyperlink() + WardrobeItemsModelMixin:OnMouseDown() in "Blizzard_Collections/Blizzard_Wardrobe.lua")
function LinkTypeFuncs:transmogappearance(link, linkType, sourceID)
	local _linkType, itemID = nil, nil;
	local _link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
	if (_link) then
		_linkType, itemID = _link:match("H?(%a+):(%d+)");
	end
	if (not itemID) then
		return;
	end

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subClassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(_link);
	local trueItemLevel = LibItemString:GetTrueItemLevel(_link);
	if (trueItemLevel) then
		itemLevel = trueItemLevel;
	end

	-- Icon
	if (not cfg.if_inIcon) then
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self,linkType)) then
			local count = (itemStackCount and itemStackCount > 1 and (itemStackCount == 0x7FFFFFFF and "#" or itemStackCount) or "");
			self:ttSetIconTextureAndText(itemTexture, count);
		end
	else
 		if (itemTexture) then
    		local newitt = "|T"..itemTexture..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
    		_G[self:GetName().."TextLeft1"]:SetText(newitt);
   		end
	end		

	-- ItemID
	if (cfg.if_showItemId) then
		self:AddLine(format("아이템ID: %d", itemID), unpack(cfg.if_infoColor));  -- 한글화
		self:Show();	-- call Show() to resize tip after adding lines
	end

	-- Quality Border
	-- 색약 보정 위한 함수 추가 시작
	if (cfg.if_wccc) and (cfg.if_itemQualityBorder) and itemRarity == 4 then
		ttif:SetBackdropBorderColorLocked(self, true,1,0,0);
	end	
	if (cfg.if_wccc) and itemRarity == 4 then
		local itext = _G[self:GetName().."TextLeft1"];
		itext:SetTextColor(1, 0, 0);
	-- 색약 보정 위한 함수 추가 끝									
	elseif (cfg.if_itemQualityBorder) then
		local itemQualityColor = CreateColorFromHexString(select(4, GetItemQualityColor(itemRarity or 0)));
		ttif:SetBackdropBorderColorLocked(self, true, itemQualityColor:GetRGBA());
	end
end

-- transmog illusion
function LinkTypeFuncs:transmogillusion(link, linkType, illusionID)
	local illusionInfo = C_TransmogCollection.GetIllusionInfo(illusionID);
	
	-- Icon
	if (not cfg.if_inIcon) then	
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(illusionInfo.icon);
		end
	else
		local newatt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		  _G[self:GetName().."TextLeft1"]:SetText(newatt);
	end

	-- IllusionID
	if (cfg.if_showItemId) then
		self:AddLine(format("형상ID: %d", illusionID), unpack(cfg.if_infoColor));
		self:Show();	-- call Show() to resize tip after adding lines. only necessary for dress up frame.
	end

  	-- Colored Border
	if (cfg.if_itemQualityBorder) then
		local name, hyperlink, sourceText = C_TransmogCollection.GetIllusionStrings(illusionID);
		local illusionColor = hyperlink:match("|c(%x+)");
		local illusionColorMixin = CreateColorFromHexString(illusionColor);
		ttif:SetBackdropBorderColorLocked(self, true, illusionColorMixin:GetRGBA());
	end
end

-- transmog set (see WardrobeSetsTransmogModelMixin:OnEnter() in "Blizzard_Collections/Blizzard_Wardrobe.lua")
function LinkTypeFuncs:transmogset(link, linkType, setID)
	local totalQuality = 0;
	local numTotalSlots = 0;
	local waitingOnQuality = false;
	local sourceQualityTable = {};
	local primaryAppearances = C_TransmogSets.GetSetPrimaryAppearances(setID);
	
	for i, primaryAppearance in pairs(primaryAppearances) do
		numTotalSlots = numTotalSlots + 1;
		local sourceID = primaryAppearance.appearanceID;
		if (sourceQualityTable[sourceID]) then
			totalQuality = totalQuality + sourceQualityTable[sourceID];
		else
			local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
			if (sourceInfo and sourceInfo.quality) then
				sourceQualityTable[sourceID] = sourceInfo.quality;
				totalQuality = totalQuality + sourceInfo.quality;
			else
				waitingOnQuality = true;
			end
		end
	end
	
	if (waitingOnQuality) then
		tipDataAdded[self] = nil;
		return;
	end
	
	-- Icon
	if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
		local SetsDataProvider = CreateFromMixins(WardrobeSetsDataProviderMixin);
		local icon = SetsDataProvider:GetIconForSet(setID);
		self:ttSetIconTextureAndText(icon);
	end

	-- SetID
	if (cfg.if_showItemId) then
		self:AddLine(format("세트ID: %d", setID), unpack(cfg.if_infoColor));  -- 한글화
		self:Show();	-- call Show() to resize tip after adding lines
	end

  	-- Quality Border
	-- 색약 보정 위한 함수 추가 시작
	if (cfg.if_wccc) and (cfg.if_itemQualityBorder) then
		ttif:SetBackdropBorderColorLocked(self, true,1,0,0);
	end	
	if (cfg.if_wccc) then
		local itext = _G[self:GetName().."TextLeft1"];
		itext:SetTextColor(1, 0, 0);
	-- 색약 보정 위한 함수 추가 끝									
	elseif (cfg.if_itemQualityBorder) then
		local setQuality = (numTotalSlots > 0 and totalQuality > 0) and Round(totalQuality / numTotalSlots) or Enum.ItemQuality.Common;
		local setColor = CreateColorFromHexString(select(4, GetItemQualityColor(setQuality)));
		ttif:SetBackdropBorderColorLocked(self, true, setColor:GetRGBA());
	end
end

-- azerite essence
function LinkTypeFuncs:azessence(link, linkType, essenceID, essenceRank)
	local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
	
	-- Icon
	if (not cfg.if_inIcon) then	
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(essenceInfo.icon);
		end
	else
		local newatt = "|T"..essenceInfo.icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		  _G[self:GetName().."TextLeft1"]:SetText(newatt);
	end

	-- EssenceID
	if (cfg.if_showSpellIdAndRank) then
		self:AddLine(format("정수ID: %d", essenceID), unpack(cfg.if_infoColor));
		self:Show();	-- call Show() to resize tip after adding lines.
	end

  	-- Quality Border
	if (cfg.if_itemQualityBorder) then
		local essenceColor = CreateColorFromHexString(select(4, GetItemQualityColor(essenceRank + 1)));
		ttif:SetBackdropBorderColorLocked(self, true, essenceColor:GetRGBA());
	end
	-- 색약 보정 위한 함수 추가 시작
	if (cfg.if_wccc) and essenceInfo.rank == 3 then
		local atext = _G[self:GetName().."TextLeft1"];
			atext:SetTextColor(1, 0, 0);		
		if (cfg.if_wccc) and (cfg.if_itemQualityBorder) and essenceInfo.rank == 3 then
			ttif:SetBackdropBorderColorLocked(self, true,1,0,0);
		end
	end	
	-- 색약 보정 위한 함수 추가 끝
end

--------------------------------------------------------------------------------------------------------
--                                      Tip CustomType Functions                                      --
--------------------------------------------------------------------------------------------------------

-- runeforge power
function CustomTypeFuncs:runeforgePower(link, linkType, runeforgePowerID)
	local powerInfo = C_LegendaryCrafting.GetRuneforgePowerInfo(runeforgePowerID);
	
	-- Icon
	if (not cfg.if_inIcon) then	
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(powerInfo.iconFileID);
		end
	else
		local newatt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		  _G[self:GetName().."TextLeft1"]:SetText(newatt);
	end	

	-- RuneforgePowerID
	if (cfg.if_showRuneforgePowerId) then
		self:AddLine(format("룬포지 파워ID: %d", runeforgePowerID), unpack(cfg.if_infoColor));
		self:Show();	-- call Show() to resize tip after adding lines
	end

  	-- Colored Border
	if (cfg.if_runeforgePowerColoredBorder) then
		local runeforgePowerColor = CreateColor(LEGENDARY_ORANGE_COLOR.r, LEGENDARY_ORANGE_COLOR.g, LEGENDARY_ORANGE_COLOR.b, 1); -- see RuneforgePowerBaseMixin:OnEnter() in "RuneforgeUtil.lua"
		ttif:SetBackdropBorderColorLocked(self, true, runeforgePowerColor:GetRGBA());
	end
end

-- guild challenge
function CustomTypeFuncs:guildChallenge(link, linkType)
  	-- Colored Border
	if (cfg.if_itemQualityBorder) then
		local guildChallengeColor = CreateColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1); -- see CommunitiesGuildChallengeTemplate:OnEnter() / GuildChallengeTemplate:OnEnter() in "Blizzard_Communities/GuildInfo.xml" / "Blizzard_GuildUI/Blizzard_GuildInfo.xml"
		ttif:SetBackdropBorderColorLocked(self, true, guildChallengeColor:GetRGBA());
	end
end

-- pvp enlistment bonus
function CustomTypeFuncs:pvpEnlistmentBonus(link, linkType)
  	-- Colored Border
	if (cfg.if_itemQualityBorder) then
		local pvpEnlistmentBonusColor = CreateColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1); -- see PVPRewardEnlistmentBonus_OnEnter() in "Blizzard_PVPUI/Blizzard_PVPUI.lua"
		ttif:SetBackdropBorderColorLocked(self, true, pvpEnlistmentBonusColor:GetRGBA());
	end
end

-- flyout
function CustomTypeFuncs:flyout(link, linkType, flyoutID, icon)
	-- Icon
	if (not cfg.if_inIcon) then
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(icon);
		end
	else
		local newatt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		  _G[self:GetName().."TextLeft1"]:SetText(newatt);
	end	

	-- FlyoutID
	if (cfg.if_showFlyoutId) then
		self:AddLine(format("FlyoutID: %d", flyoutID), unpack(cfg.if_infoColor));
		self:Show();	-- call Show() to resize tip after adding lines
	end

  	-- Colored Border
	if (cfg.if_flyoutColoredBorder) then
		local spellColor = CreateColorFromHexString("FF71D5FF"); -- see GetSpellLink(). extraction of color code from this function not used, because in classic it only returns the spell name instead of a link.
		ttif:SetBackdropBorderColorLocked(self, true, spellColor:GetRGBA());
	end
end

-- pet action
function CustomTypeFuncs:petAction(link, linkType, petActionID, icon)
	-- Icon
	if (not cfg.if_inIcon) then
		if (self.ttSetIconTextureAndText) and (not cfg.if_smartIcons or SmartIconEvaluation(self, linkType)) then
			self:ttSetIconTextureAndText(icon);
		end
	else
		local newatt = "|T"..icon..":"..(cfg.if_iconSize - 16).."|t ".._G[self:GetName().."TextLeft1"]:GetText();
		  _G[self:GetName().."TextLeft1"]:SetText(newatt);
		self:AddLine();
		self:Show();		  
	end		

	-- PetActionID
	if (cfg.if_showPetActionId and petActionID) then
		self:AddLine(format("행동ID: %d", petActionID), unpack(cfg.if_infoColor));
		self:Show();	-- call Show() to resize tip after adding lines. only necessary for pet tooltip in action bar.
	end

  	-- Colored Border
	if (cfg.if_spellColoredBorder) then
		local spellColor = CreateColorFromHexString("FF71D5FF"); -- see GetSpellLink(). extraction of color code from this function not used, because in classic it only returns the spell name instead of a link.
		ttif:SetBackdropBorderColorLocked(self, true, spellColor:GetRGBA());
	end
end

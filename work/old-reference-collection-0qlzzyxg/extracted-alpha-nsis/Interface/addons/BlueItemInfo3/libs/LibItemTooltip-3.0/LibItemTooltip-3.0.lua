local MAJOR_VERSION, MINOR_VERSION = "LibItemTooltip-3.0", 7
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local hookableTooltips = {
	"GameTooltip",
	"ItemRefTooltip",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
	"ItemRefShoppingTooltip3",
}
local itemTitle = HELPFRAME_ITEM_TITLE or "아이템"
local spellTitle = STAT_CATEGORY_SPELL or "주문"
local achievementTitle = ACHIEVEMENTS or "업적"
local questTitle = QUESTS_LABEL or "퀘스트"

lib.handlers = lib.handlers or {}

local pairs = _G.pairs
local select = _G.select
local tonumber = _G.tonumber
local GetItemInfo = _G.GetItemInfo
local GetSpellLink = _G.GetSpellLink
local UnitAura = _G.UnitAura
local UnitBuff = _G.UnitBuff
local UnitDebuff = _G.UnitDebuff
local GetActionInfo = _G.GetActionInfo
local tipName, tipLink, tipID, tipLevel, tipUpgradeID, lastquestID, timer, _
local itemTipHooked, spellTipHooked, achievementTipHooked = {}, {}, {}

local upgradeItemLevel = {
	[1] = 8,
	[373] = 4,
	[374] = 8,
	[375] = 4,
	[376] = 4,
	[377] = 4,
	[378] = 7,
	[379] = 4,
	[380] = 4,
	[446] = 4,
	[447] = 8,
	[452] = 8,
	[454] = 4,
	[455] = 8,
	[457] = 8,
	[459] = 4,
	[460] = 8,
	[461] = 12,
	[462] = 16,
	[466] = 4,
	[467] = 8,
	[469] = 4,
	[470] = 8,
	[471] = 12,
	[472] = 16,
	[477] = 4,
	[478] = 8,
	[480] = 8,
	[492] = 4,
	[493] = 8,
	[495] = 4,
	[496] = 8,
	[497] = 12,
	[498] = 16,
	[504] = 12,
	[505] = 16,
	[506] = 20,
	[507] = 24,
}

function lib:Register(method, handler)
	if type(method) == "string" then
		method = _G[method]
	end
	if type(method) == "function" then
		lib.handlers[method] = true
	elseif type(method) == "table" and type(method[handler]) == "function" then
		lib.handlers[method] = handler
	end
end

function lib:Unregister(method)
	if type(method) == "string" then
		method = _G[method]
	end
	if lib.handlers[method] then
		lib.handlers[method] = nil
	end
end

function lib:OnTooltip(name, link, id, tooltipMethod)
	--self:Show()
	for method, handler in pairs(lib.handlers) do
		if handler == true then
			method(self, name, link, id)
		elseif method ~= BlueItemInfo3 then
			method[handler](method, self, name, link, id, tooltipMethod)
		end
	end
	if lib.handlers[BlueItemInfo3] then
		BlueItemInfo3[lib.handlers[BlueItemInfo3]](BlueItemInfo3, self, name, link, id, tooltipMethod)
	end
end

function lib:AddLinkID(idTitle, id, addblank)
	if not idTitle or not id then return end
	if not(Blizzard_CombatLog_Filters and Blizzard_CombatLog_Filters.noTooltipID) then
		if self:GetName() then
			local tooltipNamePrefix, i, text = self:GetName()
			local writeId = idTitle.."ID: "..id
			for i = GameTooltip:NumLines(), 1, -1 do
				text = _G[tooltipNamePrefix.."TextLeft"..i]
				if text and text:GetText() == writeId then
					self:Show()
					return true
				end
			end
		end
		if addblank and tostring(addblank) and tostring(addblank) == "true" then
			self:AddLine(" ")
		end
		self:AddLine(idTitle.."ID: "..id)
	end
	self:Show()
end

function lib:OnTooltipSpellUpdate()
	local tipN = self:GetName()
	if not spellTipHooked[tipN] then
		spellTipHooked[tipN] = true
		if self:GetSpell() then
			tipName, _, tipID = self:GetSpell()
			lib.OnTooltip(self, tipName, GetSpellLink(tipID), -tipID)
			lib.AddLinkID(self, spellTitle, tipID)
			tipName, tipID = nil
		end
	end
end

function lib:OnTooltipItemUpdate()
	local tipN = self:GetName()
	if not itemTipHooked[tipN] then
		itemTipHooked[tipN] = true
		if select(2, self:GetItem()) then
			tipName, tipLink = self:GetItem()
			tipID, tipUpgradeID = tipLink:match("item:(%d+):[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:(%d+)")
			if tipID then
				tipID, tipUpgradeID = tonumber(tipID), tonumber(tipUpgradeID)
			else
				tipID = tonumber(tipLink:match("item:(%d+)"))
			end
			tipLevel = select(4, GetItemInfo(tipID))
			if tipLevel and upgradeItemLevel[tipUpgradeID] then
				tipLevel = (tipLevel + upgradeItemLevel[tipUpgradeID]).."|cff00ff00(+"..upgradeItemLevel[tipUpgradeID]..")|r"
			end
			lib.OnTooltip(self, self:GetItem(), select(2, self:GetItem()), tipID)
			lib.AddLinkID(self, itemTitle, tipID)
			tipName, tipLink, tipID, tipUpgradeID, tipLevel = nil
		end
	end
end

local function questUpdate()
	if lastquestID ~= nil then	
		timer = nil
		lib.OnTooltip(ItemRefTooltip, "QUEST", GetQuestLink(lastquestID), -lastquestID)
		lib.AddLinkID(ItemRefTooltip, questTitle, lastquestID, true)
	end	
end

function lib:OnTooltipQuestUpdate()
	if not timer then
		timer = C_Timer.NewTimer(0.1, questUpdate)
	end
end

local function onTooltipItemUpdate(self)
	lib.OnTooltipItemUpdate(self)
end

local function onTooltipSpellUpdate(self)
	lib.OnTooltipSpellUpdate(self)
end

local function onTooltipQuestUpdate(self)
	lib.OnTooltipQuestUpdate(self)
end

function lib:OnTooltipCleared()
	local tipN = self:GetName()
	spellTipHooked[tipN] = nil
	itemTipHooked[tipN] = nil
	achievementTipHooked[tipN] = nil
	--self._lit30:Hide()
end

local function onTooltipCleared(self)
	lib.OnTooltipCleared(self)
end

local function setItemRef(self, link)
	lastquestID = link:match("quest:(%d+)")
	local achievementID = link:match("achievement:(%d+)")
	if not achievementID then return end
	if achievementID and (not achievementTipHooked["ItemRefTooltip"] or (achievementTipHooked["ItemRefTooltip"] ~= achievementID)) then
		lastquestID = nil
		achievementTipHooked["ItemRefTooltip"] = achievementID
		lib.OnTooltip(ItemRefTooltip, "ACHIEVEMENT", GetAchievementLink(achievementID), -achievementID)
		lib.AddLinkID(ItemRefTooltip, achievementTitle, achievementID, true)
	end
end

function lib:RegisterTooltip(tip)
	if type(tip) == "table" and type(tip.SetHyperlink) == "function" and tip:HasScript("OnTooltipCleared") then
		if not tip._lit30 then
			tip._lit30 = CreateFrame("Frame", nil, tip)
			--tip._lit30:Hide()
			tip:HookScript("OnTooltipCleared", onTooltipCleared)
			tip:HookScript("OnTooltipSetItem", onTooltipItemUpdate)
			tip:HookScript("OnTooltipSetSpell", onTooltipSpellUpdate)
			tip:HookScript("OnTooltipSetQuest", onTooltipQuestUpdate)

			local function setByItemID(self, id, tooltipMethod)
				if id and type(id) == "number" and id > 0 and id == floor(id) then
					lib.OnTooltip(self, self:GetName(), select(2, GetItemInfo(id)), id, tooltipMethod)
					lib.AddLinkID(self, itemTitle, id)
				end
			end

			hooksecurefunc(tip, "SetToyByItemID", function(self, id)
				setByItemID(self, id, "SetToyByItemID")
			end)

			local function setAura(self, id)
				if id then
					lib.OnTooltip(self, tipName, GetSpellLink(id), -id)
					lib.AddLinkID(self, spellTitle, id)
				end
			end
			hooksecurefunc(tip, "SetUnitAura", function(self, unit, id, filter) setAura(self, (select(11, UnitAura(unit, id, filter)))) end)
			hooksecurefunc(tip, "SetUnitBuff", function(self, unit, id, filter) setAura(self, (select(11, UnitBuff(unit, id, filter)))) end)
			hooksecurefunc(tip, "SetUnitDebuff", function(self, unit, id, filter) setAura(self, (select(11, UnitDebuff(unit, id, filter)))) end)
			hooksecurefunc("SetItemRef", setItemRef)
		end
		return true
	end
	return nil
end

function hookQuestTooltip(self)
	GameTooltip:AddLine(questTitle.."ID: "..self.questID)
	GameTooltip:Show()
end

hooksecurefunc("QuestMapLogTitleButton_OnEnter", hookQuestTooltip)

for _, tip in pairs(hookableTooltips) do
	lib:RegisterTooltip(_G[tip])
end
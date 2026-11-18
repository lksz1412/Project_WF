-- Player HUD aura support for Forever. Skin visual regions only; Blizzard
-- retains aura data, cancellation, tooltips, fading, timers and Edit Mode.
local _, Core = ...
local build = Core.WOW_VERSION or 0
if not ((WOW_PROJECT_CAMELOT and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)
	or (build >= 16000 and build < 17000)) then return end

local API = Core.API
-- Forever uses modern aura regions despite its Classic interface number.
-- An explicit type also avoids inspecting a button's auraType or aura data.
local auraType = "ForeverPlayerAura"
API:AddType(auraType, {"Icon", "Normal", "DebuffBorder", "EnchantBorder"}, "Aura")

local events = CreateFrame("Frame")
local records, owners = {}, {}
local groups
local queued, pendingCombat

local function forbidden(frame)
	return frame.IsForbidden and frame:IsForbidden()
end

local function combatBlocked(button)
	return InCombatLockdown() and button.IsProtected and button:IsProtected()
end

local function apply(record)
	local button, proxy = record.button, record.proxy
	if forbidden(button) then return end
	if combatBlocked(button) then pendingCombat = true; return end
	-- The native button includes a duration-text area (30x40 or 60x30).
	-- Skin the 30x30 icon, leaving the native button size and anchors intact.
	local container = record.owner.AuraContainer
	local point = "TOP"
	if container then
		if container.isHorizontal == false then
			point = container.addIconsToRight and "LEFT" or "RIGHT"
		else
			point = container.addIconsToTop and "BOTTOM" or "TOP"
		end
	end
	proxy:ClearAllPoints()
	proxy:SetPoint(point, button, point, 0, 0)
	record.group:ReSkin(proxy)
end

local function addButton(owner, button, group)
	if not button or forbidden(button) then return end
	local record = records[button]
	if record then return record end
	local icon = button.Icon
	-- Private-aura anchors have Frame icons owned by Blizzard. Leave them alone.
	if not icon or not icon.GetObjectType or icon:GetObjectType() ~= "Texture" then return end
	if combatBlocked(button) then pendingCombat = true; return end
	local proxy = CreateFrame("Frame", nil, button)
	proxy:SetSize(30, 30)
	proxy:SetFrameLevel(button:GetFrameLevel())
	proxy:EnableMouse(false)
	record = {button = button, proxy = proxy, owner = owner, group = group}
	records[button] = record
	-- Set the anchor before AddButton applies the initial skin.
	local container = owner.AuraContainer
	local point = container and container.isHorizontal == false
		and (container.addIconsToRight and "LEFT" or "RIGHT")
		or (container and container.addIconsToTop and "BOTTOM" or "TOP")
	proxy:SetPoint(point, button, point, 0, 0)
	group:AddButton(proxy, {
		Icon = icon,
		DebuffBorder = button.DebuffBorder,
		EnchantBorder = button.TempEnchantBorder,
	}, auraType, true)
	if type(button.Update) == "function" then
		hooksecurefunc(button, "Update", function() apply(record) end)
	end
	return record
end

local function scan(owner, group, reskin)
	if not owner or forbidden(owner) then return end
	for _, button in ipairs(owner.auraFrames or {}) do
		local record = addButton(owner, button, group)
		if record and reskin then apply(record) end
	end
end

local function bind(owner, group)
	if not owner or forbidden(owner) then return end
	if not owners[owner] then
		owners[owner] = group
		if type(owner.UpdateAuraButtons) == "function" then
			hooksecurefunc(owner, "UpdateAuraButtons", function() scan(owner, group, false) end)
		end
		if type(owner.UpdateGridLayout) == "function" then
			hooksecurefunc(owner, "UpdateGridLayout", function() scan(owner, group, true) end)
		end
	end
	scan(owner, group, true)
end

local function refresh()
	if not Core.db then return end
	if not groups then
		local korean = GetLocale() == "koKR"
		groups = {
			buffs = API:Group("Blizzard Buffs", korean and "버프" or "Buffs", "Buffs"),
			debuffs = API:Group("Blizzard Buffs", korean and "디버프" or "Debuffs", "Debuffs"),
		}
	end
	bind(BuffFrame, groups.buffs)
	bind(DebuffFrame, groups.debuffs)
	local consolidated = BuffFrame and BuffFrame.ConsolidatedBuffs
	local tooltip = consolidated and consolidated.Tooltip
	if tooltip and tooltip.Auras then bind(tooltip.Auras, groups.buffs) end
end

local function queue()
	if queued then return end
	queued = true
	C_Timer.After(0, function() queued = nil; refresh() end)
end

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, name)
	if event == "ADDON_LOADED" then
		if name == "Blizzard_BuffFrame" then queue() end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if pendingCombat then pendingCombat = nil; queue() end
	else
		queue()
	end
end)

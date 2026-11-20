-- Forever's 12.1 engine denies addon aura queries when combat data is secret.
-- CustomAuraContainer delegates assignment, textures, stacks, durations and
-- tooltips to Blizzard's secure implementation. Never read its live aura data,
-- visible button count, positions or duration back into addon Lua.
local PitBull4 = _G.PitBull4
if not PitBull4.Compat.IsForever then return end

local Aura = PitBull4:GetModule("Aura")
local states = setmetatable({}, {__mode = "k"})
local unavailable = false

-- Raised whenever aura settings, the profile, fonts or the restriction state
-- may have changed; containers and button styles are rebuilt only then (or
-- when their unit, size or frame geometry changes).
local settings_version = 1
local function settings_changed() settings_version = settings_version + 1 end

local control_points = {
	TOPLEFT_TOP = "BOTTOMLEFT", TOPRIGHT_TOP = "BOTTOMRIGHT",
	TOPLEFT_LEFT = "TOPRIGHT", TOPRIGHT_RIGHT = "TOPLEFT",
	BOTTOMLEFT_BOTTOM = "TOPLEFT", BOTTOMRIGHT_BOTTOM = "TOPRIGHT",
	BOTTOMLEFT_LEFT = "BOTTOMRIGHT", BOTTOMRIGHT_RIGHT = "BOTTOMLEFT",
}

local function mirror(value, a, b)
	return value:gsub(a, "@SWAP@"):gsub(b, a):gsub("@SWAP@", b)
end

local function set_font(frame, text, db, parent)
	local font, size = frame:GetFont(db.font, db.size)
	text:SetFont(font, size, "OUTLINE")
	text:SetTextColor(unpack(db.color))
	text:ClearAllPoints()
	text:SetPoint(db.anchor, parent, db.anchor, db.offset_x, db.offset_y)
end

local function style_button(button_state, group)
	local button = button_state.button
	local db, frame, rule = group.db, group.frame, group.rule
	button:SetSize(group.size, group.size)
	button:EnableMouse(not db.click_through and not (frame.classification_db or {}).click_through)
	button:SetHideTooltipInCombat(false)
	button:SetTooltipAnchorPoint("ANCHOR_BOTTOMRIGHT")
	local icon = button_state.icon
	if db.zoom_aura then
		icon:SetTexCoord(.07, .93, .07, .93)
	else
		icon:SetTexCoord(0, 1, 0, 1)
	end
	local texts = db.texts[rule]
	set_font(frame, button_state.count, texts.count, button_state.overlay)
	set_font(frame, button_state.time, texts.cooldown_text, button_state.overlay)
	button:SetIcon(icon)
	button:SetApplicationCount(button_state.count)
	if db.cooldown[rule] then
		button_state.cooldown:Show()
		button:SetDurationCooldown(button_state.cooldown)
	else
		button:ClearDurationCooldown()
		button_state.cooldown:Hide()
	end
	if db.cooldown_text[rule] then
		-- Native duration binding works even when expiration times are secret.
		-- Keep the configured static text color; no Lua time-based comparisons.
		button_state.time:Show()
		button:SetDurationText(button_state.time, {})
	else
		button:ClearDurationText()
		button_state.time:Hide()
	end
	local border = button_state.border
	button:ClearDispelTypeTextures()
	local border_db = db.borders[rule][group.friendly and "friend" or "enemy"]
	if border_db.enabled then
		border:Show()
		local colors = Aura.db.profile.global.colors
		if border_db.color_type == "type" then
			local color_map = {}
			for kind, color in pairs(colors.type) do
				color_map[kind == "nil" and "None" or kind] = {r = color[1], g = color[2], b = color[3]}
			end
			button:AddDispelTypeTexture(border, {style = "PreserveAsset", showAlways = true,
				customDispelColorMap = color_map})
		else
			local color = border_db.color_type == "caster" and colors.caster[group.mine and "my" or "other"]
				or border_db.custom_color or {1, 0, 0}
			border:SetVertexColor(unpack(color))
		end
	else
		border:Hide()
	end
end

local function initialize_button(button, group)
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(button)
	local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	cooldown:SetAllPoints(button)
	cooldown:SetReverse(true)
	cooldown:SetHideCountdownNumbers(true)
	local overlay = CreateFrame("Frame", nil, button)
	overlay:SetAllPoints(button)
	overlay:SetFrameLevel(cooldown:GetFrameLevel() + 1)
	local count = overlay:CreateFontString(nil, "OVERLAY")
	local time = overlay:CreateFontString(nil, "OVERLAY")
	local border = overlay:CreateTexture(nil, "BORDER")
	border:SetAllPoints(button)
	border:SetTexture([[Interface\AddOns\PitBull4\Modules\Aura\border]])
	local state = {button = button, icon = icon, cooldown = cooldown,
		overlay = overlay, count = count, time = time, border = border}
	group.buttons[#group.buttons + 1] = state
	style_button(state, group)
end

-- This signature contains settings only, never live aura fields. Existing
-- protected children may reject styling during combat; retry on the next
-- layout/restriction update while their native aura updates keep running.
local function style_signature(group)
	if group.signature_version == settings_version and group.signature_size == group.size
		and group.signature_friendly == group.friendly and group.signature_rule == group.rule then
		return group.last_signature
	end
	local db, rule = group.db, group.rule
	local parts = {tostring(group.size), tostring(db.zoom_aura),
		tostring(db.click_through), tostring((group.frame.classification_db or {}).click_through),
		tostring(db.cooldown[rule]), tostring(db.cooldown_text[rule]), tostring(group.friendly)}
	local border = db.borders[rule][group.friendly and "friend" or "enemy"]
	parts[#parts + 1], parts[#parts + 2] = tostring(border.enabled), tostring(border.color_type)
	for _, category in ipairs({"caster", "type"}) do
		local colors = Aura.db.profile.global.colors[category]
		-- Sort keys so a signature never depends on table iteration order.
		local keys = {}
		for key in pairs(colors) do keys[#keys + 1] = key end
		table.sort(keys)
		for _, key in ipairs(keys) do
			parts[#parts + 1] = key
			for _, number in ipairs(colors[key]) do parts[#parts + 1] = tostring(number) end
		end
	end
	for _, value in ipairs(border.custom_color or {}) do parts[#parts + 1] = tostring(value) end
	for _, name in ipairs({"count", "cooldown_text"}) do
		local text_db = db.texts[rule][name]
		local font, size = group.frame:GetFont(text_db.font, text_db.size)
		for _, value in ipairs({font, size, text_db.anchor, text_db.offset_x, text_db.offset_y,
			unpack(text_db.color)}) do
			parts[#parts + 1] = tostring(value)
		end
	end
	group.signature_version, group.signature_size = settings_version, group.size
	group.signature_friendly, group.signature_rule = group.friendly, group.rule
	group.last_signature = table.concat(parts, "\031")
	return group.last_signature
end

-- 사용자 수정: kind = "buff" | "debuff" (원래는 디버프 전용)
local function update_group(container, group, mine, db, frame, cfg, vertical, kind)
	local is_buff = kind == "buff"
	local max_count = is_buff and db.max_buffs or db.max_debuffs
	group.db, group.frame, group.cfg = db, frame, cfg
	group.mine = mine
	group.friendly = PitBull4.Utils.SafeBoolean(UnitIsFriend("player", frame.best_unit or frame.unit), false)
	group.rule = (mine and "my_" or "other_") .. (is_buff and "buffs" or "debuffs")
	local my_size, other_size = Aura:GetAuraIconSizes(cfg, group.available_width, vertical and cfg.row_spacing or cfg.col_spacing)
	group.size = mine and my_size or other_size
	local key = mine and "mine" or "others"
	local layout = {
		elementWidth = group.size, elementHeight = group.size,
		elementSpacing = vertical and cfg.row_spacing or cfg.col_spacing,
		lineSpacing = vertical and cfg.col_spacing or cfg.row_spacing,
		forceNewLine = not mine and cfg.new_row_size and cfg.my_size ~= cfg.size or false,
		layoutIndex = (mine ~= (cfg.reverse == true)) and 1 or 2,
	}
	-- Each group is independently limited by the native API. Keeping two groups
	-- preserves the user's different own/other sizes and cooldown settings.
	if not group.added then
		container:AddAuraGroup(key, (is_buff and "HELPFUL" or "HARMFUL") .. (mine and "|PLAYER" or "|!PLAYER"), {
			maxFrameCount = max_count,
			-- Public native enums: Default=0, AuraInstanceIDOnly=8;
			-- Normal=0, Reverse=1 (Blizzard_AuraContainerShared.lua).
			sortMethod = cfg.sort and 0 or 8, sortDirection = cfg.reverse and 1 or 0,
			layout = layout,
			initializeFrame = function(button) initialize_button(button, group) end,
		})
		group.added = true
	else
		container:SetAuraGroupMaxFrameCount(key, max_count)
		container:SetAuraGroupLayout(key, layout)
		container:SetAuraGroupSortMethod(key, cfg.sort and 0 or 8, cfg.reverse and 1 or 0)
	end
	local signature = style_signature(group)
	if group.signature ~= signature then
		local styled = true
		for _, button_state in ipairs(group.buttons) do
			if not pcall(style_button, button_state, group) then styled = false end
		end
		if styled then group.signature = signature end
	end
	group.styled_version = group.signature == signature and settings_version or nil
end

-- 사용자 수정: 버프용 컨테이너를 따로 둠 (전투 중 버프가 사라지던 문제)
local buff_states = setmetatable({}, {__mode = "k"})

local function clear_native(store, frame)
	local state = store[frame]
	if state then
		state.container:SetEnabled(false)
		state.container:Hide()
		state.applied_version = nil
	end
end

function Aura:ClearNativeDebuffs(frame)
	clear_native(states, frame)
end

function Aura:ClearNativeBuffs(frame)
	clear_native(buff_states, frame)
end

local update_native

function Aura:UpdateNativeDebuffs(frame, db)
	return update_native(self, frame, db, "debuff", states)
end

-- 버프는 전투 중(숨김 데이터 상태)에만 네이티브로 그림. 평상시에는 기존 방식
-- 그대로라 무기 강화 아이콘, 필터, 설정 미리보기가 예전처럼 동작함.
function Aura:UpdateNativeBuffs(frame, db)
	local restricted = (PitBull4.HasRestrictedUnitData and PitBull4:HasRestrictedUnitData())
		or InCombatLockdown() or PitBull4.Utils.SafeBoolean(UnitAffectingCombat("player"), false)
	if not restricted then
		self:ClearNativeBuffs(frame)
		return false
	end
	return update_native(self, frame, db, "buff", buff_states)
end

update_native = function(self, frame, db, kind, store)
	local is_buff = kind == "buff"
	local cfg = is_buff and db.layout.buff or db.layout.debuff
	local enabled_kind = is_buff and db.enabled_buffs or (not is_buff and db.enabled_debuffs)
	local max_count = is_buff and db.max_buffs or db.max_debuffs
	-- Debuff filters keep their existing path. Restricted buffs use native
	-- groups; arbitrary Lua buff filters resume when combat restrictions end.
	if unavailable or frame.force_show or (not is_buff and cfg.filter and cfg.filter ~= "") then
		clear_native(store, frame)
		return false
	end
	local unit = frame.best_unit or frame.unit
	if not db.enabled or not enabled_kind or not unit or max_count <= 0 then
		clear_native(store, frame)
		return true
	end
	local state = store[frame]
	if not state then
		local ok, container = pcall(CreateFrame, "AuraContainer", nil, frame, "CustomAuraContainerTemplate")
		if not ok or not container.AddAuraGroup or not container.SetFlowLayoutAxis then
			if ok then container:Hide() end
			unavailable = true
			return false
		end
		state = {container = container, mine = {buttons = {}}, others = {buttons = {}}}
		store[frame] = state
		container:SetEnabled(false)
	end
	local container = state.container
	-- Everything below depends only on settings, the unit token, the frame's
	-- geometry and friendliness; the native container follows the unit's auras
	-- itself. A new unit behind the same token needs one UpdateAllAuras.
	local friendly = PitBull4.Utils.SafeBoolean(UnitIsFriend("player", unit), false)
	local guid = PitBull4.Utils.SafeGUID(frame.guid)
	local frame_width, frame_height, frame_level = frame:GetWidth(), frame:GetHeight(), frame:GetFrameLevel()
	if state.applied_version == settings_version and state.unit == unit and state.db == db
		and state.friendly == friendly and state.width == frame_width and state.height == frame_height
		and state.level == frame_level and state.mine.styled_version == settings_version
		and state.others.styled_version == settings_version then
		if guid == nil or guid ~= state.guid then
			state.guid = guid
			container:UpdateAllAuras()
		end
		return true
	end
	local growth, anchor, side = cfg.growth, cfg.anchor, cfg.side
	local x, y = cfg.offset_x, cfg.offset_y
	local class = frame.classification_db or {}
	if class.horizontal_mirror then
		growth, anchor, side = mirror(growth, "left", "right"), mirror(anchor, "LEFT", "RIGHT"), mirror(side, "LEFT", "RIGHT")
		x = -x
	end
	if class.vertical_mirror then
		growth, anchor, side = mirror(growth, "up", "down"), mirror(anchor, "TOP", "BOTTOM"), mirror(side, "TOP", "BOTTOM")
		y = -y
	end
	local vertical = growth:match("^up") or growth:match("^down")
	local left, up = growth:find("left", 1, true), growth:find("up", 1, true)
	local width = cfg.width
	if cfg.width_type == "percent" then
		width = (vertical and frame:GetHeight() or frame:GetWidth()) * cfg.width_percent
	end
	width = math.max(1, width)
	container:ClearAllPoints()
	container:SetPoint(control_points[anchor .. "_" .. side] or "TOPLEFT", frame, anchor, x, y)
	container:SetFrameLevel(frame:GetFrameLevel() + cfg.frame_level)
	container:SetFlowLayoutAxis(vertical and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
	container:SetFlowLayoutAnchorPoint((up and "BOTTOM" or "TOP") .. (left and "RIGHT" or "LEFT"))
	container:SetFlowLayoutGrowthDirection(left and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right,
		up and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down)
	container:SetFlowLayoutMaximumLineSize(width)
	state.mine.available_width, state.others.available_width = width, width
	update_group(container, state.mine, true, db, frame, cfg, vertical, kind)
	update_group(container, state.others, false, db, frame, cfg, vertical, kind)
	container:SetUnit(unit)
	container:Show()
	container:SetEnabled(true)
	-- The unit token can stay 'target' while the underlying target changes.
	container:UpdateAllAuras()
	state.applied_version, state.unit, state.db, state.friendly = settings_version, unit, db, friendly
	state.width, state.height, state.level, state.guid = frame_width, frame_height, frame_level, guid
	return true
end

local on_enable = Aura.OnEnable
function Aura:OnEnable()
	on_enable(self)
	PitBull4.Compat.RegisterOptionalEvent(self, "ADDON_RESTRICTION_STATE_CHANGED", "ForeverRestrictionChanged")
	-- One update per combat transition: the deferred one below, after the
	-- combat state has settled (it switches buffs between native and Lua).
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	if not self.forever_config_watch then
		local registry = LibStub and LibStub("AceConfigRegistry-3.0", true)
		if registry then registry.RegisterCallback(self, "ConfigTableChange", settings_changed) end
		self.forever_config_watch = true
	end
	-- 사용자 수정: 전투 시작/종료 때 버프를 네이티브 ↔ 기존 방식으로 바꿔 그림
	if not self.forever_combat_watch then
		local watch = CreateFrame("Frame")
		watch:RegisterEvent("PLAYER_REGEN_DISABLED")
		watch:RegisterEvent("PLAYER_REGEN_ENABLED")
		watch:SetScript("OnEvent", function()
			C_Timer.After(0, function() if Aura:IsEnabled() then Aura:UpdateAll() end end)
		end)
		self.forever_combat_watch = watch
	end
end

function Aura:ForeverRestrictionChanged()
	settings_changed()
	self:UpdateAll()
end

local on_profile_changed = Aura.OnProfileChanged
function Aura:OnProfileChanged(...)
	settings_changed()
	if on_profile_changed then return on_profile_changed(self, ...) end
end

local on_media = Aura.LibSharedMedia_Registered
function Aura:LibSharedMedia_Registered(event, mediatype, ...)
	if mediatype == "font" then settings_changed() end
	if on_media then return on_media(self, event, mediatype, ...) end
end

local on_disable = Aura.OnDisable
function Aura:OnDisable()
	for frame in pairs(states) do self:ClearNativeDebuffs(frame) end
	for frame in pairs(buff_states) do self:ClearNativeBuffs(frame) end
	on_disable(self)
end

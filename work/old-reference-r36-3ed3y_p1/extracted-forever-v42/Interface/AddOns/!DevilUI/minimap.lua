local addonName, FC = ...

FC.FinishProfileLoad(...)
FC.FinishProfileLoad = nil

do

local _, FC = ...
local revision = 1
local copy = FC.Copy

function FC.GetMinimapStyle(settings)
    settings = settings or FC.GetCharacterState()
    if not settings then return "square" end
    local saved = DevilUIAccount.minimapStyles and DevilUIAccount.minimapStyles[settings.profile]
    if saved == "square" or saved == "default" then return saved end
    return FC.GetNativeDefaults(settings.profile).minimap.native and "default" or "square"
end

function FC.UpdateMinimapStyle(settings)
    if not settings or not settings.minimap then return end
    local cfg = settings.minimap
    cfg.native = FC.GetMinimapStyle(settings) == "default" or nil
    if not cfg.native and not cfg.h and MinimapCluster then
        local w, h = UIParent:GetWidth(), UIParent:GetHeight()
        cfg.followPanel = false
        cfg.x, cfg.y = MinimapCluster:GetLeft() / w, MinimapCluster:GetBottom() / h
        cfg.w, cfg.h = MinimapCluster:GetWidth() / w, MinimapCluster:GetHeight() / h
        local container = MinimapCluster.MinimapContainer
        cfg.baseSize = container and container:GetWidth() or MinimapCluster:GetWidth() - 2
    end
end

function FC.PrepareNativeMinimap(settings, rect, reset_size)
    if FC.IsNativeStyleCurrent and not FC.IsNativeStyleCurrent(settings.profile) then return false, "현재 입력 방식과 편집 모드 구성이 다릅니다." end
    if settings.minimap.native then settings.nativeMinimapRevision = nil; return true end
    if InCombatLockdown() or FC.IsEditModeActive() then return false, "전투와 편집 모드 종료를 기다립니다." end
    local api = C_EditMode
    if not api or not api.GetLayouts or not api.SaveLayouts or not EditModePresetLayoutManager then return false, "미니맵 편집 모드 초기화를 기다립니다." end
    local presets = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
    if not presets or #presets == 0 then return false, "미니맵 편집 모드 초기화를 기다립니다." end
    local layouts = copy(api.GetLayouts())
    if not layouts or type(layouts.layouts) ~= "table" then return false, "미니맵 편집 모드 구성을 기다립니다." end
    local index = layouts.activeLayout - #presets
    local activate

    if settings.profile == "Wide_WH" and (not layouts.layouts[index] or layouts.layouts[index].layoutName ~= settings.nativeLayoutName) then
        index = 0
    end
    if index < 1 or not layouts.layouts[index] then
        for i, layout in ipairs(layouts.layouts) do
            if layout.layoutName == settings.nativeLayoutName then index = i; activate = true; break end
        end
    end
    local layout = layouts.layouts[index]
    if not layout or not layout.systems then return false, "DevilUI 사용자 편집 구성을 선택한 뒤 다시 접속하세요." end
    local info
    for _, entry in ipairs(layout.systems) do if entry.system == Enum.EditModeSystem.Minimap then info = entry; break end end
    if not info then
        info = {system = Enum.EditModeSystem.Minimap, settings = {}}
        layout.systems[#layout.systems + 1] = info
    end
    local anchor = info.anchorInfo
    local changed = info.isInDefaultPosition ~= false or info.anchorInfo2 ~= nil or not anchor or
        anchor.point ~= "BOTTOMLEFT" or anchor.relativePoint ~= "BOTTOMLEFT" or anchor.relativeTo ~= "UIParent" or
        math.abs((anchor.offsetX or 0) - rect.x) > .01 or math.abs((anchor.offsetY or 0) - rect.y) > .01
    info.isInDefaultPosition = false
    info.anchorInfo2 = nil
    info.anchorInfo = {point = "BOTTOMLEFT", relativePoint = "BOTTOMLEFT", relativeTo = "UIParent", offsetX = rect.x, offsetY = rect.y}
    if reset_size or not settings.nativeMinimapRevision then

        local size_value = settings.minimap.nativeSize or 5
        local size_id = Enum.EditModeMinimapSetting.Size
        local found
        for _, value in ipairs(info.settings) do
            if value.setting == size_id then changed = changed or value.value ~= size_value; value.value = size_value; found = true; break end
        end
        if not found then info.settings[#info.settings + 1] = {setting = size_id, value = size_value}; changed = true end
        settings.minimap.baseSize = math.max(58, (rect.size - 2) / ((50 + size_value * 10) / 100))
    end
    if changed then FC.NativeSessionDirty = true; api.SaveLayouts(layouts) end
    if activate then FC.NativeSessionDirty = true; api.SetActiveLayout(index + #presets) end
    settings.nativeMinimapRevision = revision
    settings.minimap.nativeDirty = nil
    return true
end

function FC.CommitLayoutPlacement()
    local settings = FC.GetCharacterState()
    if not settings then return end
    if settings.chat.nativeDirty then
        local ok, ready, reason = pcall(FC.CommitNativeChat, settings)
        if not ok or not ready then print("DevilUI: " .. tostring(ok and reason or ready)); return end
    end
    if settings.minimap.nativeDirty then
        local ok, ready, reason = pcall(FC.PrepareNativeMinimap, settings, FC.GetMinimapPlacement())
        if not ok or not ready then print("DevilUI: " .. tostring(ok and reason or ready)); return end
    end
    if FC.NativeSessionDirty and not FC.NativeReloadRequested then
        FC.NativeReloadRequested = true
        print("DevilUI: 채팅창·미니맵의 편집 모드 배치를 저장하고 UI를 재시작합니다.")
        ReloadUI()
    end
end

function FC.UpgradePlacementDefaults()
    local settings = FC.GetCharacterState()
    if not settings or settings.stage ~= "complete" then return true end
    if InCombatLockdown() or FC.IsEditModeActive() or FC.NativeSessionDirty then return false end
    FC.UpdateMinimapStyle(settings)
    settings.chat.followNative = true
    settings.nativeMinimapRevision = not settings.minimap.native and 1 or nil
    settings.geometryRevision, settings.geometryNotice = 12, nil
    return true
end
end

FC.LoadChatSetup(...)
FC.LoadChatSetup = nil

do

local _, FC = ...
local applying, queued, moving, layout_applied
local active_stop
local minimap_holder
local minimap_bounds, minimap_pulse
local minimap_selection_overlay
local hooks = setmetatable({}, {__mode = "k"})
local movers = {}
local unlocked = false
local editor_open = false
local stock_minimap

function FC.ResetInstallLayout()

    if moving and moving.StopMovingOrSizing then moving:StopMovingOrSizing() end
    moving, active_stop, unlocked = nil, nil, false
    layout_applied = nil
    for _, mover in ipairs(movers) do mover:Hide() end
    if minimap_holder then minimap_holder:Hide(); minimap_holder:ClearAllPoints() end
end

function FC.IsEditModeActive()
 local editor = EditModeManagerFrame
 return editor_open or (editor and editor.IsShown and editor:IsShown()) or false
end

local function enabled()
    local settings = FC.GetCharacterState()
    return settings and settings.enabled and settings.stage ~= nil and not settings.nativeAwaitingSelection and
        (not FC.IsNativeStyleCurrent or FC.IsNativeStyleCurrent(settings.profile))
end
local function panel(name)
    local ace = LibStub and LibStub("AceAddon-3.0", true)
    local kg = ace and ace:GetAddon("kgPanels", true)
    if not kg or not kg.FetchFrame or (kg.active and kg.active ~= (DevilUILayout and DevilUILayout.panelLayout or "Wide")) then return end
    local frame = kg:FetchFrame(name)
    local parent = frame

    while parent do
        if parent == Minimap or parent == ChatFrame1 or parent == MinimapCluster then return end
        parent = parent.GetParent and parent:GetParent()
    end
    return frame
end
local function place(frame, point, relative, relative_point, x, y)
    local clear = frame.ClearAllPointsBase or frame.ClearAllPoints
    local set = frame.SetPointBase or frame.SetPoint
    clear(frame)
    set(frame, point, relative, relative_point, x or 0, y or 0)
end
local function root_size()
    return UIParent:GetWidth(), UIParent:GetHeight()
end

local function scale(frame, value)
 local set = frame.SetScaleBase or frame.SetScale
 set(frame, value)
end
local function root_scale(frame)
 local parent = frame.GetParent and frame:GetParent()
 local ratio = parent and parent.GetEffectiveScale and UIParent:GetEffectiveScale() / parent:GetEffectiveScale() or 1
 scale(frame, ratio)
end

local function hook_layout(frame, method)
    if not frame or type(frame[method]) ~= "function" then return end
    hooks[frame] = hooks[frame] or {}
    if hooks[frame][method] then return end
    hooks[frame][method] = true
    hooksecurefunc(frame, method, function()
        if not applying then FC.QueueLayout() end
    end)
end

local function apply_chat()
    local chat = ChatFrame1
    if not chat then return false end
    local cfg = DevilUILayout.chat
    if cfg.followNative then FC.PlaceExtraChatWindows(); return true end
    scale(chat, 1)
    if chat.SetResizeBounds then chat:SetResizeBounds(100, 70) end
    if cfg.followPanel then
        local target = panel("chat1")
        if target then
            local ratio = target:GetEffectiveScale() / UIParent:GetEffectiveScale()
            place(chat, "BOTTOMLEFT", target, "BOTTOMLEFT", 6, 10)
            chat:SetSize(math.max(100, target:GetWidth() * ratio - 14), math.max(70, target:GetHeight() * ratio - 28))
        else
            place(chat, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 6, 27)
            chat:SetSize(343, 217)
        end
    else
        local w, h = root_size()
        place(chat, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", cfg.x * w, cfg.y * h + (cfg.offsetY or 0))
        chat:SetSize(cfg.w * w, cfg.h * h)
    end
    if chat.SetUserPlaced then chat:SetUserPlaced(false) end
    if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(chat) end
    FC.PlaceExtraChatWindows()
    return true
end

function FC.PlaceExtraChatWindows()
    FC.ApplyExtraChatLayout(panel)
end

local function ensure_minimap_holder()
    if minimap_holder then return minimap_holder end
    minimap_holder = CreateFrame("Frame", "DevilUIForeverMinimap", UIParent, "BackdropTemplate")
    minimap_holder:SetClampedToScreen(true)
    minimap_holder:SetFrameStrata("LOW")
    minimap_holder:SetFrameLevel(5)
    minimap_holder:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]], edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
    minimap_holder:SetBackdropColor(0, 0, 0, 1)
    minimap_holder:SetBackdropBorderColor(.16, .16, .16, 1)

    minimap_holder.Layout = function() end
    return minimap_holder
end

function FC.GetMinimapPlacement()
    FC.UpdateMinimapStyle(DevilUILayout)
    local cfg = DevilUILayout.minimap
    if cfg.native then return end
    local w, h = root_size()
    local target = cfg.followPanel and panel("미니맵이미지")
    if target then
        local ratio = target:GetEffectiveScale() / UIParent:GetEffectiveScale()
        local size = math.max(60, math.min(target:GetWidth(), target:GetHeight()) * ratio - 8)
        return {x = target:GetLeft() * ratio + (target:GetWidth() * ratio - size) / 2,
            y = target:GetBottom() * ratio + (target:GetHeight() * ratio - size) / 2, size = size}
    elseif cfg.followPanel then return {x = w / 2 + 299, y = 21, size = 237}
    end
    return {x = cfg.x * w, y = cfg.y * h, size = math.max(60, cfg.h * h)}
end

local function native_minimap_ready()
    return DevilUILayout and not DevilUILayout.minimap.native and DevilUILayout.nativeMinimapRevision and not FC.NativeSessionDirty and MinimapCluster and MinimapCluster.MinimapContainer
end

local header_entries = setmetatable({}, {__mode = "k"})
local muted_clocks = setmetatable({}, {__mode = "k"})
local function full_header_enabled()
    local settings = DevilUILayout
    return settings and (settings.profile == "Wide" or settings.profile == "Wide_WH") and
        not settings.minimap.native
end

local function remember_header_region(region)
    if not region then return end
    local original = {width = region:GetWidth(), height = region:GetHeight(), points = {}}
    if region.GetNumPoints then
        for index = 1, region:GetNumPoints() do original.points[index] = {region:GetPoint(index)} end
    end
    if region.GetJustifyH then original.justify = region:GetJustifyH() end
    if region.CanWordWrap then original.wordWrap = region:CanWordWrap() end
    if region.CanNonSpaceWrap then original.nonSpaceWrap = region:CanNonSpaceWrap() end
    return original
end

local function restore_header_region(region, original)
    if not region or not original then return end
    region:ClearAllPoints()
    region:SetSize(original.width, original.height)
    for _, point in ipairs(original.points) do region:SetPoint(unpack(point)) end
    if original.justify then region:SetJustifyH(original.justify) end
    if original.wordWrap ~= nil then region:SetWordWrap(original.wordWrap) end
    if original.nonSpaceWrap ~= nil then region:SetNonSpaceWrap(original.nonSpaceWrap) end
end

local function restore_minimap_header()
    for zone, entry in pairs(header_entries) do
        entry.frame:Hide()
        restore_header_region(zone, entry.zone)
        restore_header_region(entry.label, entry.labelStyle)
        for texture, original in pairs(entry.textures) do restore_header_region(texture, original) end
        header_entries[zone] = nil
    end
    for clock, alpha in pairs(muted_clocks) do clock:SetAlpha(alpha); muted_clocks[clock] = nil end
end

local function update_header_clock(entry)

    local value = date("%H:%M")
    if value ~= entry.time then entry.clock:SetText(value); entry.time = value end
    local width = entry.clock.GetStringWidth and entry.clock:GetStringWidth() or 36
    width = math.min(math.max(40, width + 4), entry.side * .45)
    entry.clock:SetWidth(width)
    if entry.label then entry.label:SetWidth(math.max(1, entry.side - 16 - width - 8)) end
end

local function current_zone_name()
    if not GetMinimapZoneText then return end
    local function nonempty(value)
        if issecretvalue and issecretvalue(value) then return end
        if type(value) == "string" and value:find("%S") then return value end
    end
    local name = nonempty(GetMinimapZoneText())
    if name then return name end
    if IsInInstance and IsInInstance() and GetInstanceInfo then
        name = nonempty(GetInstanceInfo())
        if name then return name end
    end
    return (GetRealZoneText and nonempty(GetRealZoneText())) or
        (GetZoneText and nonempty(GetZoneText())) or ""
end

local function update_region_text(label)
    if not label then return end
    local name = current_zone_name()
    if name == nil then return end
    local current = label.GetText and label:GetText()
    if issecretvalue and issecretvalue(current) then return end
    if current ~= name then label:SetText(name) end
end

local function refresh_header_regions()
    if not enabled() then return end
    if DevilUILayout.profile == "Wide_B" or DevilUILayout.minimap.native then
        update_region_text(MinimapZoneText)
    elseif full_header_enabled() then
        for _, entry in pairs(header_entries) do update_region_text(entry.label) end
    end
end

local function apply_full_minimap_header(zone, side, y)
    local entry = header_entries[zone]
    if not entry then
        local frame = CreateFrame("Frame", nil, zone)
        frame:SetAllPoints(zone); frame:EnableMouse(false)
        local clock = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        clock:SetJustifyH("RIGHT")
        clock:SetPoint("RIGHT", zone, "RIGHT", -8, 0)
        entry = {frame = frame, clock = clock, zone = remember_header_region(zone),
            label = MinimapZoneText, labelStyle = remember_header_region(MinimapZoneText), textures = {}}
        header_entries[zone] = entry

        frame.DevilUIHeader = true
        local elapsed = 0
        frame:SetScript("OnUpdate", function(self, delta)
            if not enabled() or not full_header_enabled() then self:Hide(); return end
            elapsed = elapsed + delta
            if elapsed < 1 then return end
            elapsed = 0
            update_header_clock(entry)
            update_region_text(entry.label)
        end)
    end
    entry.side = side
    zone:SetWidth(side)
    place(zone, "TOPLEFT", minimap_holder, "TOPLEFT", 0, y)
    for _, texture in pairs({zone.StateTexture, zone.AddTexture}) do
        if not entry.textures[texture] then entry.textures[texture] = remember_header_region(texture) end
        texture:ClearAllPoints(); texture:SetAllPoints(zone)
    end
    local label = entry.label
    if label then
        place(label, "LEFT", zone, "LEFT", 8, 0)
        label:SetJustifyH("LEFT")
        if label.SetWordWrap then label:SetWordWrap(false) end
        if label.SetNonSpaceWrap then label:SetNonSpaceWrap(false) end
        if label.GetFont then
            local font, size, flags = label:GetFont()
            if font and size then entry.clock:SetFont(font, size, flags) end
        end
    end

    if TimeManagerClockButton then
        if muted_clocks[TimeManagerClockButton] == nil then muted_clocks[TimeManagerClockButton] = TimeManagerClockButton:GetAlpha() end
        TimeManagerClockButton:SetAlpha(0)
    end
    update_header_clock(entry)
    update_region_text(entry.label)
    entry.frame:Show()
end

local function apply_minimap_header(holder, side)
    local settings = DevilUILayout
    if not settings or (settings.profile ~= "Wide" and settings.profile ~= "Wide_WH") then return end
    local cluster = MinimapCluster
    local zone = cluster and cluster.ZoneTextButton
    if zone then

        local cfg = FC.GetNativeDefaults(settings.profile).minimap
        local y = cfg and cfg.labelY or 24
        place(zone, "TOPLEFT", holder, "TOPLEFT", 6, y)
        apply_full_minimap_header(zone, side, y)
    end
    local label_width = math.max(50, side - (GameTimeFrame and 64 or 40))
    local zone_width = math.max(50, side - 40)
    local inset = 6 + (zone_width - label_width) / 2
    local tracking = cluster and cluster.Tracking or MiniMapTracking
    local tracking_button = tracking and (tracking.Button or tracking)
    if tracking then
        root_scale(tracking)

        place(tracking, "CENTER", holder, "TOPLEFT", inset + tracking_button:GetWidth() / 2, -5 - tracking_button:GetHeight() / 2)
    end
    local calendar = GameTimeFrame
    if calendar then
        if tracking_button then place(calendar, "LEFT", tracking_button, "RIGHT", 3, 0)
        else place(calendar, "TOPLEFT", holder, "TOPLEFT", inset, -5) end
    end

    local diel = cluster and cluster.DielFrame
    if diel then
        if diel:GetParent() ~= holder then diel:SetParent(holder) end
        root_scale(diel)
        diel:SetFrameLevel(holder:GetFrameLevel() + 4)
        place(diel, "TOPRIGHT", holder, "TOPRIGHT", -4, -4)
    end
    if TimeManagerClockButton and calendar then

        place(TimeManagerClockButton, "TOPRIGHT", holder, "TOPRIGHT", -7 - calendar:GetWidth(), -4)
    end
end

local function sync_minimap_selection()
    if not editor_open or not native_minimap_ready() or InCombatLockdown() or not minimap_holder then return end
    local selection = MinimapCluster.Selection
    if not selection then return end

    selection:ClearAllPoints()
    selection:SetAllPoints(minimap_holder)
    selection:SetFrameStrata("HIGH")
    selection:SetFrameLevel(math.max(selection:GetFrameLevel(), 1000))
    selection:SetAlpha(1)
    selection:EnableMouse(true)
    selection:Show()
    if not minimap_selection_overlay then
        minimap_selection_overlay = CreateFrame("Frame", nil, selection, "BackdropTemplate")
        minimap_selection_overlay:SetAllPoints(selection)
        minimap_selection_overlay:EnableMouse(false)
        minimap_selection_overlay:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]], edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 2})
        minimap_selection_overlay:SetBackdropColor(.12, .55, .8, .18)
        minimap_selection_overlay:SetBackdropBorderColor(.3, .8, 1, .95)
        local label = minimap_selection_overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("CENTER")
        label:SetText("미니맵")
    end
end

local function sync_minimap_visuals()
    if not native_minimap_ready() or InCombatLockdown() or not minimap_holder then return end
    local cluster, holder = MinimapCluster, minimap_holder
    local container = cluster.MinimapContainer

    place(container, "CENTER", holder, "CENTER")
    local side = container:GetWidth() * container:GetScale() + 2
    if math.abs(cluster:GetWidth() - side) > .01 or math.abs(cluster:GetHeight() - side) > .01 then cluster:SetSize(side, side) end
    apply_minimap_header(holder, side)
    sync_minimap_selection()
end

function FC.CaptureNativeMinimap()
    if not native_minimap_ready() or InCombatLockdown() then return end
    local cfg = DevilUILayout.minimap
    local cluster = MinimapCluster
    local w, h = root_size()
    cfg.followPanel = false
    cfg.x, cfg.y, cfg.w, cfg.h = cluster:GetLeft() / w, cluster:GetBottom() / h, cluster:GetWidth() / w, cluster:GetHeight() / h
    cfg.baseSize = cluster.MinimapContainer:GetWidth()
end

function FC.CaptureSharedPlacement(capture_map)
    local settings = FC.GetCharacterState()
    if not settings or not settings.enabled or settings.stage ~= "complete" or
        not layout_applied or applying or moving or InCombatLockdown() or FC.IsEditModeActive() or FC.NativeSessionDirty or
        not FC.IsNativeLayoutActive(settings) then return end
    if capture_map ~= false then FC.CaptureNativeMinimap() end
    local w, h = root_size()
    for _, definition in ipairs(FC.GetExtraChatDefinitions()) do
        local frame = FC.GetExtraChatFrame(definition)
        local cfg = settings[definition.key]
        if cfg and frame and not frame.isDocked then
            local x, y = frame:GetLeft(), frame:GetBottom()
            if x and y then
                cfg.followPanel, cfg.offsetY = false, nil
                cfg.x, cfg.y = x / w, y / h
                cfg.w, cfg.h = frame:GetWidth() / w, frame:GetHeight() / h
            end
        end
    end
    FC.SaveSharedPlacement(settings)
end

if FCF_SavePositionAndDimensions then
    hooksecurefunc("FCF_SavePositionAndDimensions", function()
        FC.CaptureSharedPlacement(false)
    end)
end

local coordinate_fonts = setmetatable({}, {__mode = "k"})
local function apply_coordinate_font()
    local coords = MinimapCluster and MinimapCluster.MinimapContainer and MinimapCluster.MinimapContainer.PlayerCoords
    local text = coords and coords.CoordText
    if not text or not text.GetFont or not text.SetFont then return end
    local bigger = DevilUILayout.profile == "Wide_WH"
    local original = coordinate_fonts[text]
    if not bigger and not original then return end
    local font, size, flags = text:GetFont()
    if not font or type(size) ~= "number" then return end
    if not original then
        original = {font = font, size = size, flags = flags, height = coords:GetHeight()}
        coordinate_fonts[text] = original
    end
    local desired = original.size + (bigger and 2 or 0)
    if font ~= original.font or size ~= desired or flags ~= original.flags then text:SetFont(original.font, desired, original.flags) end

    local height = bigger and math.max(original.height, desired + 2) or original.height
    if coords:GetHeight() ~= height then coords:SetHeight(height) end
    if not bigger then coordinate_fonts[text] = nil end
end

local function remember_stock_minimap()
    if stock_minimap then return end
    local cluster = MinimapCluster
    local container = cluster and cluster.MinimapContainer
    stock_minimap = {regions = {}, width = cluster and cluster:GetWidth(), height = cluster and cluster:GetHeight(),
        containerWidth = container and container:GetWidth(), containerHeight = container and container:GetHeight(),
        containerScale = container and container:GetScale() or 1,
        mouse = cluster and cluster.IsMouseEnabled and cluster:IsMouseEnabled(),
        mask = Minimap.GetMaskTexture and Minimap:GetMaskTexture(),
        insets = Minimap.GetHitRectInsets and {Minimap:GetHitRectInsets()}}
    local function remember(region)
        if not region or stock_minimap.regions[region] then return end
        local saved = remember_header_region(region)
        saved.parent = region.GetParent and region:GetParent()
        saved.scale = region.GetScale and region:GetScale()
        saved.level = region.GetFrameLevel and region:GetFrameLevel()
        saved.strata = region.GetFrameStrata and region:GetFrameStrata()
        saved.alpha = region.GetAlpha and region:GetAlpha()
        saved.shown = region.IsShown and region:IsShown()
        stock_minimap.regions[region] = saved
    end
    if cluster then
        for _, key in ipairs({"MinimapContainer", "ZoneTextButton", "Tracking", "IndicatorFrame", "InstanceDifficulty", "DielFrame", "BorderTop", "Selection"}) do remember(cluster[key]) end
    end
    remember(container and container.PlayerCoords)
    for _, name in ipairs({"Minimap", "MinimapZoneText", "GameTimeFrame", "TimeManagerClockButton", "MiniMapTracking", "MinimapZoomIn", "MinimapZoomOut", "MinimapBorder", "MinimapBorderTop", "MinimapCompassTexture"}) do remember(_G[name]) end
    remember(Minimap.ZoomIn); remember(Minimap.ZoomOut)
end

local function restore_stock_minimap()
    if not stock_minimap then return end
    restore_minimap_header()
    local saved, cluster = stock_minimap, MinimapCluster
    local container = cluster and cluster.MinimapContainer
    local width = container and container:GetWidth()
    local height = container and container:GetHeight()
    local container_scale = container and container:GetScale()
    for region, original in pairs(saved.regions) do
        if original.parent and region.SetParent then region:SetParent(original.parent) end
        restore_header_region(region, original)
        if original.scale then scale(region, original.scale) end
        if original.level then region:SetFrameLevel(original.level) end
        if original.strata then region:SetFrameStrata(original.strata) end
        if original.alpha then region:SetAlpha(original.alpha) end
        if original.shown ~= nil then region:SetShown(original.shown) end
    end
    if container then
        container:SetSize(width, height)
        scale(container, container_scale)
        local ratio = container:GetScale()
        cluster:SetSize(width * ratio + saved.width - saved.containerWidth * saved.containerScale,
            height * ratio + saved.height - saved.containerHeight * saved.containerScale)
        local original = saved.regions[Minimap]
        if original and saved.containerWidth and saved.containerHeight then
            Minimap:SetSize(original.width * width / saved.containerWidth, original.height * height / saved.containerHeight)
        end
    end
    if cluster and saved.mouse ~= nil then cluster:EnableMouse(saved.mouse) end
    Minimap:SetMaskTexture(saved.mask or [[Textures\MinimapMask]])
    if Minimap.SetHitRectInsets and saved.insets then Minimap:SetHitRectInsets(unpack(saved.insets)) end
    if Minimap.SetQuestBlobRingScalar then Minimap:SetQuestBlobRingScalar(1) end
    if Minimap.SetArchBlobRingScalar then Minimap:SetArchBlobRingScalar(1) end
    if minimap_bounds then minimap_bounds:Hide(); minimap_bounds = nil end
    if minimap_selection_overlay then minimap_selection_overlay:Hide() end
    if minimap_holder then minimap_holder:Hide() end
    stock_minimap = nil
end

function FC.SetMinimapStyle(style)
    if style ~= "square" and style ~= "default" then return false end
    if not enabled() then return false, "먼저 DevilUI 초기 설정을 완료해 주세요." end
    if InCombatLockdown() or FC.IsEditModeActive() or FC.NativeSessionDirty or unlocked then
        return false, "전투·편집 모드·배치 조절을 마친 뒤 변경해 주세요."
    end
    if style == "square" and DevilUILayout.minimap.native and MinimapCluster then
        local cfg, cluster = DevilUILayout.minimap, MinimapCluster
        local w, h = root_size()
        cfg.followPanel = false
        cfg.x, cfg.y = cluster:GetLeft() / w, cluster:GetBottom() / h
        cfg.w, cfg.h = cluster:GetWidth() / w, cluster:GetHeight() / h
        cfg.baseSize = cluster.MinimapContainer and cluster.MinimapContainer:GetWidth() or cluster:GetWidth() - 2
    end
    DevilUIAccount.minimapStyles = DevilUIAccount.minimapStyles or {}
    DevilUIAccount.minimapStyles[DevilUILayout.profile] = style
    FC.UpdateMinimapStyle(DevilUILayout)
    if style == "square" then DevilUILayout.nativeMinimapRevision = 1 end
    for _, mover in ipairs(movers) do mover:Hide() end
    movers = {}
    local ready = FC.ApplyLayout()
    if not ready then return false, "미니맵 배치 적용을 기다립니다." end
    return true
end

local function apply_minimap()
    FC.UpdateMinimapStyle(DevilUILayout)
    if not full_header_enabled() then restore_minimap_header() end
    apply_coordinate_font()
    local map = Minimap
    if not map then return false end
    local cfg = DevilUILayout.minimap
    if cfg.native then
        restore_stock_minimap()
        return true
    end
    remember_stock_minimap()
    local holder = ensure_minimap_holder()
    local root_w, root_h = root_size()
    local target = cfg.followPanel and panel("미니맵이미지")
    local side
    if target then
        local ratio = target:GetEffectiveScale() / UIParent:GetEffectiveScale()
        side = math.max(60, math.min(target:GetWidth(), target:GetHeight()) * ratio - 8)
        place(holder, "CENTER", target, "CENTER")
    elseif cfg.followPanel then
        side = 237
        place(holder, "BOTTOMLEFT", UIParent, "BOTTOM", 299, 21)
    else
        side = math.max(60, cfg.h * root_h)
        place(holder, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", cfg.x * root_w, cfg.y * root_h)
    end
    holder:SetSize(side, side)
    holder:Show()
    local cluster = MinimapCluster
    local coupled = native_minimap_ready()
    local inner = coupled and (cfg.baseSize or side - 2) or side - 2
    if coupled then

        side = inner * cluster.MinimapContainer:GetScale() + 2
        cluster:SetSize(side, side)
        holder:ClearAllPoints()
        holder:SetAllPoints(cluster)
    end
    if cluster then

        cluster:EnableMouse(coupled and true or false)
        for _, child in pairs({cluster.MinimapContainer, cluster.ZoneTextButton, cluster.Tracking, cluster.IndicatorFrame, cluster.InstanceDifficulty}) do
            if child:GetParent() ~= holder then child:SetParent(holder) end
        end
        local container = cluster.MinimapContainer
        if container then
            if not coupled then root_scale(container) end
            container:SetFrameLevel(holder:GetFrameLevel() + 1)
            place(container, "CENTER", holder, "CENTER")
            container:SetSize(inner, inner)
            if coupled and not minimap_bounds then

                minimap_bounds = CreateFrame("Frame", "DevilUIForeverMinimapBounds", cluster)
                local padding = cluster.GetWidthPadding and cluster:GetWidthPadding() or 20
                minimap_bounds:SetPoint("TOPLEFT", container, "TOPLEFT", (padding - 2) / 2, 1)
                minimap_bounds:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -(padding - 2) / 2, -1)
            end
        end
        if cluster.BorderTop then cluster.BorderTop:Hide() end
        if cluster.ZoneTextButton then
            root_scale(cluster.ZoneTextButton)
            cluster.ZoneTextButton:SetFrameLevel(holder:GetFrameLevel() + 3)
            place(cluster.ZoneTextButton, "TOPLEFT", holder, "TOPLEFT", 6, -5)
            cluster.ZoneTextButton:SetWidth(math.max(50, side - 40))
        end
        if cluster.Tracking then root_scale(cluster.Tracking); cluster.Tracking:SetFrameLevel(holder:GetFrameLevel() + 3); place(cluster.Tracking, "BOTTOMLEFT", holder, "BOTTOMLEFT", 5, 5) end
        if cluster.IndicatorFrame then root_scale(cluster.IndicatorFrame); cluster.IndicatorFrame:SetFrameLevel(holder:GetFrameLevel() + 3); place(cluster.IndicatorFrame, "BOTTOMRIGHT", holder, "BOTTOMRIGHT", -5, 5) end
        if cluster.InstanceDifficulty then root_scale(cluster.InstanceDifficulty); cluster.InstanceDifficulty:SetFrameLevel(holder:GetFrameLevel() + 3); place(cluster.InstanceDifficulty, "TOPRIGHT", holder, "TOPRIGHT", -4, -4) end
        if container and container.PlayerCoords then
            place(container.PlayerCoords, "BOTTOM", holder, "BOTTOM", 0, 3)
        end
    end
    scale(map, 1)
    map:SetFrameLevel(holder:GetFrameLevel() + 2)
    place(map, "CENTER", coupled and cluster.MinimapContainer or holder, "CENTER")
    map:SetSize(inner, inner)
    map:SetMaskTexture([[Interface\Buttons\WHITE8X8]])
    if map.SetHitRectInsets then map:SetHitRectInsets(0, 0, 0, 0) end
    for _, texture in ipairs({"MinimapBorder", "MinimapBorderTop", "MinimapCompassTexture"}) do
        if _G[texture] then _G[texture]:SetAlpha(0) end
    end
    if map.SetQuestBlobRingScalar then map:SetQuestBlobRingScalar(0) end
    if map.SetArchBlobRingScalar then map:SetArchBlobRingScalar(0) end
    if MinimapZoneText then
        MinimapZoneText:SetWidth(math.max(50, side - (GameTimeFrame and 64 or 40)))
        if cluster and cluster.ZoneTextButton then place(MinimapZoneText, "CENTER", cluster.ZoneTextButton, "CENTER") end
    end
    local calendar = GameTimeFrame
    if calendar then

        if calendar:GetParent() ~= holder then calendar:SetParent(holder) end
        root_scale(calendar)
        calendar:SetFrameLevel(holder:GetFrameLevel() + 5)
        place(calendar, "TOPRIGHT", holder, "TOPRIGHT", -4, -4)
        calendar:SetAlpha(1)
        calendar:EnableMouse(true)
        calendar:Show()
        if cluster and cluster.InstanceDifficulty then place(cluster.InstanceDifficulty, "TOPRIGHT", holder, "TOPRIGHT", -4, -26) end
    end
    if TimeManagerClockButton then
        if calendar then place(TimeManagerClockButton, "TOPRIGHT", calendar, "TOPLEFT", -3, 0)
        else place(TimeManagerClockButton, "TOPRIGHT", holder, "TOPRIGHT", -3, -3) end
    end
    if MiniMapTracking then place(MiniMapTracking, "BOTTOMLEFT", holder, "BOTTOMLEFT", 3, 3) end
    apply_minimap_header(holder, side)
    local zoom_in, zoom_out = map.ZoomIn or MinimapZoomIn, map.ZoomOut or MinimapZoomOut
    if zoom_in then place(zoom_in, "BOTTOMRIGHT", holder, "BOTTOMRIGHT", -4, 20) end
    if zoom_out then place(zoom_out, "BOTTOMRIGHT", holder, "BOTTOMRIGHT", -4, 4) end

    if not FC.shape_callback then
        local original = GetMinimapShape
        GetMinimapShape = function()
            if enabled() and not DevilUILayout.minimap.native then return "SQUARE" end
            return original and original() or "ROUND"
        end
        FC.shape_callback = true
    end
    if not FC.wheel_hooked then
        map:EnableMouseWheel(true)
        if not map:GetScript("OnMouseWheel") then
            map:SetScript("OnMouseWheel", function(self, delta)
                self:SetZoom(math.max(0, math.min(self:GetZoomLevels() - 1, self:GetZoom() + (delta > 0 and 1 or -1))))
            end)
        end
        FC.wheel_hooked = true
    end
    if coupled and not minimap_pulse then
        minimap_pulse = CreateFrame("Frame")
        local elapsed = 0
        minimap_pulse:SetScript("OnUpdate", function(_, delta)
            if not editor_open then return end
            elapsed = elapsed + delta
            if elapsed < .05 then return end
            elapsed = 0
            sync_minimap_visuals()
        end)
    end
    return true
end

function FC.ApplyLayout()
    if not enabled() or applying or moving or InCombatLockdown() or FC.IsEditModeActive() or FC.NativeSessionDirty then return false end
    applying = true
    local ok, chat, map = pcall(function() return apply_chat(), apply_minimap() end)
    applying = nil
    if not ok then
        print("DevilUI: 배치를 적용하지 못했습니다: " .. tostring(chat))
        return false
    end
    layout_applied = chat and map
    return layout_applied
end

function FC.QueueLayout()
    if not enabled() or applying or queued then return end
    queued = true
    C_Timer.After(.1, function() queued = nil; FC.ApplyLayout() end)
end

local groups = {"SYSTEM", "SAY", "YELL", "EMOTE", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "WHISPER", "WHISPER_INFORM", "BN_WHISPER", "BN_WHISPER_INFORM", "LOOT", "MONEY", "CURRENCY", "COMBAT_XP_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_MISC_INFO", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE"}
function FC.AttachChannels()
    local chat = ChatFrame1
    local get = GetChannelList or (C_ChatInfo and C_ChatInfo.GetChannelList)
    local add = chat and (chat.AddChannel or ChatFrame_AddChannel)
    if not get or not add then return end
    local channels = {get()}
    local count = 0
    for index = 1, #channels, 3 do
        local name = channels[index + 1]
        if type(name) == "string" and name ~= "" then
            if not chat.ContainsChannel or not chat:ContainsChannel(name) then add(chat, name) end
            count = count + 1
        end
    end
    if count > 0 then DevilUILayout.channelsReady = true end
end
function FC.ConfigureChat()
    if FC.EnsureTabletCombatLog then FC.EnsureTabletCombatLog() end
    if InCombatLockdown() or FC.IsEditModeActive() or FC.NativeSessionDirty then return false end
    if not ChatFrame1 or not ChatFrame2 then return false end
    if COMBATLOG == ChatFrame2 and not Blizzard_CombatLog_Update_QuickButtons then return false end
    local defaults = FC.GetNativeDefaults(DevilUILayout.profile)
    for id = 1, 2 do
        local chat = _G["ChatFrame" .. id]
        local remove = chat.RemoveAllMessageGroups or ChatFrame_RemoveAllMessageGroups
        local add = chat.AddMessageGroup or ChatFrame_AddMessageGroup
        if not remove or not add then return false end
        remove(chat)
        local window = defaults.windows[id]
        for _, group in ipairs(window.groups or groups) do
            if (id ~= 1 or group ~= "TRADESKILLS") and ChatTypeGroup and ChatTypeGroup[group] then add(chat, group) end
        end
        if FCF_SetWindowName then FCF_SetWindowName(chat, window.name) end
        if window.fontSize and FCF_SetChatWindowFontSize then FCF_SetChatWindowFontSize(nil, chat, window.fontSize) end
        if FCF_SetWindowColor then FCF_SetWindowColor(chat, 0, 0, 0) end
        if FCF_SetWindowAlpha then FCF_SetWindowAlpha(chat, window.alpha) end
        if FCF_SetUninteractable then FCF_SetUninteractable(chat, false) end
        if FCF_SetLocked then FCF_SetLocked(chat, true) end
    end
    if defaults.mergeCombatLog then
        if FC.ConfigureTabletCombatChat then FC.ConfigureTabletCombatChat() end
    elseif defaults.restoreCombatTab and FC.ConfigureTabletCombatChat then FC.ConfigureTabletCombatChat()
    elseif FCF_DockFrame then FCF_DockFrame(ChatFrame2, 2, false) end
    local ready, reason = FC.ConfigureExtraChat()
    if not ready then return false, reason end
    if FCF_SelectDockFrame then FCF_SelectDockFrame(ChatFrame1) end
    if ChatFrame1.ReceiveAllPrivateMessages then ChatFrame1:ReceiveAllPrivateMessages() end
    FC.AttachChannels()
    return true
end

local function save_placement(target, key)
    local w, h = root_size()
    local cfg = DevilUILayout[key]
    cfg.followPanel = false
    cfg.x, cfg.y = target:GetLeft() / w, target:GetBottom() / h
    cfg.offsetY = nil
    cfg.w, cfg.h = target:GetWidth() / w, target:GetHeight() / h
    if key == "chat" then cfg.followNative = nil; cfg.nativeDirty = true end
    if key == "minimap" and native_minimap_ready() then
        cfg.baseSize = math.max(58, (target:GetWidth() - 2) / MinimapCluster.MinimapContainer:GetScale())
        cfg.nativeDirty = true
    end
    if key ~= "minimap" and FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(target) end
    FC.SaveSharedPlacement(DevilUILayout)
end
local function make_mover(target, key, title)
    local mover = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    mover.layoutTarget = target
    mover:SetAllPoints(target)
    mover:SetFrameStrata("DIALOG")
    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")
    mover:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]], edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
    mover:SetBackdropColor(0, .5, .3, .4)
    mover:SetBackdropBorderColor(.2, 1, .5, 1)
    local label = mover:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(title .. "\n드래그: 이동 / 오른쪽 아래: 크기")
    target:SetMovable(true)
    target:SetResizable(true)
    if target.SetResizeBounds then target:SetResizeBounds(100, 70) end
    mover:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        moving = target; target:StartMoving()
    end)
    local function stop()
        if not moving or InCombatLockdown() then return end
        target:StopMovingOrSizing()
        if key == "minimap" then target:SetSize(target:GetWidth(), target:GetWidth()) end
        save_placement(target, key)
        moving = nil; FC.ApplyLayout()
    end
    active_stop = nil
    mover:HookScript("OnDragStart", function() if moving == target then active_stop = stop end end)
    mover:SetScript("OnDragStop", stop)
    local grip = CreateFrame("Button", nil, mover)
    grip:SetSize(24, 24); grip:SetPoint("BOTTOMRIGHT")
    local grip_text = grip:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    grip_text:SetAllPoints(); grip_text:SetText("+")
    grip:SetScript("OnMouseDown", function()
        if InCombatLockdown() then return end
        moving = target; active_stop = stop; target:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp", stop)
    return mover
end
function FC.SetUnlocked(value)
    if InCombatLockdown() or FC.IsEditModeActive() then print("DevilUI: 전투와 편집 모드를 종료한 후 배치를 조절하세요."); return end
    if not enabled() then print("DevilUI: 먼저 /devilui install로 초기 설정을 적용하세요."); return end
    if not value and moving and active_stop then active_stop() end
    FC.ApplyLayout()
    if value and #movers == 0 then
        movers[1] = make_mover(ChatFrame1, "chat", "채팅창")
        if not DevilUILayout.minimap.native then movers[2] = make_mover(native_minimap_ready() and MinimapCluster or ensure_minimap_holder(), "minimap", "미니맵") end
    end
    if value then
        for _, definition in ipairs(FC.ExtraChatWindows) do
            local chat = FC.GetExtraChatFrame(definition)
            local previous = movers[definition.key]
            if previous and previous.layoutTarget ~= chat then
                previous:Hide()
                for index, mover in ipairs(movers) do
                    if mover == previous then table.remove(movers, index); break end
                end
                movers[definition.key] = nil
            end
            if chat and not chat.isDocked and not movers[definition.key] then
                local mover = make_mover(chat, definition.key, definition.name)
                movers[#movers + 1] = mover
                movers[definition.key] = mover
            end
        end
    end
    unlocked = value
    for _, mover in ipairs(movers) do mover:SetShown(value) end
    print(value and "DevilUI: 조절 후 /devilui lock으로 잠그세요." or "DevilUI: 배치를 잠갔습니다.")
    if not value then FC.CommitLayoutPlacement() end
end
function FC.FitPanels()
    if not enabled() or InCombatLockdown() or FC.IsEditModeActive() then return end
    if DevilUILayout.minimap.native then
        DevilUILayout.chat = FC.Copy(FC.GetNativeDefaults(DevilUILayout.profile).chat)
        FC.ApplyLayout()
        return
    end
    DevilUILayout.chat = {followPanel = true}
    DevilUILayout.minimap = {followPanel = true}
    for _, definition in ipairs(FC.ExtraChatWindows) do
        local cfg = DevilUILayout[definition.key]
        if cfg then cfg.followPanel = true end
    end
    if native_minimap_ready() then
        local ready, reason = FC.PrepareNativeMinimap(DevilUILayout, FC.GetMinimapPlacement(), true)
        if not ready then print("DevilUI: " .. tostring(reason)); return end
        FC.CommitLayoutPlacement()
    end
    FC.ApplyLayout()
end

function FC.RefreshLayoutOptions()
    local frame = FC.layout_options
    if not frame or not frame:IsShown() then return end
    local style = FC.GetMinimapStyle()
    local editable = enabled() and not InCombatLockdown() and not FC.IsEditModeActive() and not FC.NativeSessionDirty and not unlocked
    frame.squareButton:SetEnabled(editable and style ~= "square")
    frame.defaultButton:SetEnabled(editable and style ~= "default")
    frame.shapeStatus:SetText("현재: " .. (style == "square" and "네모 미니맵" or "기본 미니맵") .. " (프로필별 저장)")
    if not frame.showIconScale then return end
    local percent, name, editable, reason = FC.GetMinimapIconPercent()
    frame.refreshing = true
    frame.iconLayoutName, frame.savedIconPercent = name, percent
    frame.iconPercent, frame.iconEditable = percent, editable and true or false
    frame.iconSlider:SetValue(percent or 100)
    frame.iconValue:SetText(percent and (tostring(percent) .. "%") or "-")
    frame.iconSlider:EnableMouse(frame.iconEditable)
    frame.iconSlider:SetAlpha(frame.iconEditable and 1 or .5)
    frame.iconApply:SetEnabled(false)
    frame.iconStatus:SetText(reason or ("편집 모드: " .. (name or "-") .. "\n저장하면 UI를 재시작합니다."))
    frame.refreshing = nil
end

function FC.OpenLayoutOptions(show_icon_scale)
    if not FC.layout_options then
        local frame = CreateFrame("Frame", "DevilUIForeverLayoutOptions", UIParent, "BasicFrameTemplateWithInset")
        frame:Hide()
        frame:SetSize(390, 465); frame:SetPoint("CENTER"); frame:SetFrameStrata("DIALOG")
        frame.TitleText:SetText("DevilUI 배치 설정")
        local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("TOPLEFT", 18, -38); text:SetWidth(350); text:SetJustifyH("LEFT")
        frame.description = text
        local definitions = {{"이동·크기 조절", function() FC.SetUnlocked(true); frame:Hide() end},
            {"조절 완료·잠금", function() FC.SetUnlocked(false) end},
            {"초기 설치 안내 다시 열기", function() frame:Hide(); FC.ShowInstall() end}}
        frame.buttons = {}
        for index, definition in ipairs(definitions) do
            local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            button:SetSize(344, 26); button:SetPoint("TOPLEFT", 23, -83 - (index - 1) * 34)
            button:SetText(definition[1]); button:SetScript("OnClick", definition[2])
            frame.buttons[index] = button
        end
        for index, definition in ipairs({{"네모 미니맵", "square", "squareButton"}, {"기본 미니맵", "default", "defaultButton"}}) do
            local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
            button:SetSize(168, 28); button:SetPoint("TOPLEFT", 23 + (index - 1) * 176, -195)
            button:SetText(definition[1]); frame[definition[3]] = button
            button:SetScript("OnClick", function()
                local ok, reason = FC.SetMinimapStyle(definition[2])
                FC.RefreshLayoutOptions()
                if not ok and reason then frame.shapeStatus:SetText(reason) end
            end)
        end
        frame.shapeStatus = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.shapeStatus:SetPoint("TOPLEFT", 24, -234); frame.shapeStatus:SetWidth(342); frame.shapeStatus:SetJustifyH("LEFT")
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 24, -285); label:SetText("미니맵 내부 아이콘 크기 (%)")
        frame.iconValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.iconValue:SetPoint("TOPRIGHT", -25, -285)
        local slider = CreateFrame("Slider", nil, frame, "BackdropTemplate")
        slider:SetPoint("TOPLEFT", 30, -311); slider:SetSize(330, 18)
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(50, 200); slider:SetValueStep(10)
        if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
        slider:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]], edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
        slider:SetBackdropColor(.08, .08, .08, 1); slider:SetBackdropBorderColor(.4, .4, .4, 1)
        slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])
        frame.iconSlider = slider
        local low = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        low:SetPoint("TOPLEFT", 30, -334); low:SetText("50%")
        local high = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        high:SetPoint("TOPRIGHT", -30, -334); high:SetText("200%")
        frame.iconStatus = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.iconStatus:SetPoint("TOPLEFT", 24, -357); frame.iconStatus:SetWidth(342); frame.iconStatus:SetJustifyH("LEFT")
        local apply = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        apply:SetSize(344, 28); apply:SetPoint("BOTTOM", 0, 18); apply:SetText("아이콘 크기 저장·적용 (UI 재시작)")
        frame.iconApply = apply
        slider:SetScript("OnValueChanged", function(_, value)
            if frame.refreshing then return end
            frame.iconPercent = math.max(50, math.min(200, 50 + math.floor((value - 50) / 10 + .5) * 10))
            frame.iconValue:SetText(tostring(frame.iconPercent) .. "%")
            apply:SetEnabled(frame.iconEditable and frame.iconPercent ~= frame.savedIconPercent)
        end)
        apply:SetScript("OnClick", function()
            local ok, changed = FC.SaveMinimapIconPercent(frame.iconPercent, frame.iconLayoutName)
            if not ok then
                FC.RefreshLayoutOptions()
                frame.iconStatus:SetText(tostring(changed))
                return
            end
            if changed then
                FC.NativeReloadRequested = true
                print("DevilUI: 미니맵 내부 아이콘 크기를 저장했습니다. UI를 재시작합니다.")
                ReloadUI()
            else FC.RefreshLayoutOptions() end
        end)
        frame.iconControls = {label, frame.iconValue, slider, low, high, frame.iconStatus, apply}
        frame:SetScript("OnShow", FC.RefreshLayoutOptions)
        FC.layout_options = frame
    end

    local frame = FC.layout_options
    frame.showIconScale = show_icon_scale == true
    frame:SetSize(390, frame.showIconScale and 465 or 285)
    frame.description:SetText(frame.showIconScale and "채팅창·미니맵 배치를 조절합니다.\n내부 아이콘 크기는 편집 모드 설정과 연동됩니다." or
        "채팅창·미니맵 배치를 조절합니다.\n미니맵 내부 아이콘은 Devilconfig의 배치 설정에서 조절하세요.")
    for _, control in ipairs(frame.iconControls) do control:SetShown(frame.showIconScale) end
    frame:Show()
    FC.RefreshLayoutOptions()
end

local zone_events = {PLAYER_ENTERING_WORLD = true, ZONE_CHANGED = true, ZONE_CHANGED_INDOORS = true, ZONE_CHANGED_NEW_AREA = true, MINIMAP_ZONE_CHANGED = true}
local events = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "MINIMAP_ZONE_CHANGED", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED", "EDIT_MODE_LAYOUTS_UPDATED", "ADDON_LOADED"}) do
    if not C_EventUtils or C_EventUtils.IsEventValid(event) then events:RegisterEvent(event) end
end
events:SetScript("OnEvent", function(_, event)
    if zone_events[event] then
        C_Timer.After(0, refresh_header_regions)
        if event ~= "PLAYER_ENTERING_WORLD" then return end
    end
    if FC.RefreshLayoutOptions and (event == "EDIT_MODE_LAYOUTS_UPDATED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED") then
        C_Timer.After(0, FC.RefreshLayoutOptions)
    end
    if event == "PLAYER_REGEN_DISABLED" then
        for _, mover in ipairs(movers) do mover:Hide() end
        if moving then pcall(moving.StopMovingOrSizing, moving) end
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        if moving and active_stop then active_stop() end
        for _, mover in ipairs(movers) do mover:SetShown(unlocked) end
    end
    if event == "ADDON_LOADED" then
        local ace = LibStub and LibStub("AceAddon-3.0", true)
        local kg = ace and ace:GetAddon("kgPanels", true)
        hook_layout(kg, "ActivateLayout")
    end
    FC.QueueLayout()
end)
local region_elapsed = 0
events:SetScript("OnUpdate", function(_, delta)
    if not DevilUILayout or (DevilUILayout.profile ~= "Wide_B" and not DevilUILayout.minimap.native) then region_elapsed = 0; return end
    region_elapsed = region_elapsed + delta
    if region_elapsed < 1 then return end
    region_elapsed = 0
    refresh_header_regions()
end)
if EventRegistry and EventRegistry.RegisterCallback then
 EventRegistry:RegisterCallback("EditMode.Enter", function()
  editor_open = true
  if FC.RefreshLayoutOptions then C_Timer.After(0, FC.RefreshLayoutOptions) end
 end, FC)
 EventRegistry:RegisterCallback("EditMode.Exit", function()
  editor_open = false

  C_Timer.After(.05, function()
   FC.CaptureSharedPlacement()
   FC.QueueLayout()
   if FC.RefreshLayoutOptions then FC.RefreshLayoutOptions() end
   if FC.QueueFinishInstall then FC.QueueFinishInstall() end
  end)
 end, FC)
 EventRegistry:RegisterCallback("EditMode.SavedLayouts", function() FC.QueueLayout() end, FC)
end
end

do
local _, FC = ...
local function tablet_active(completed)
 local settings = FC.GetCharacterState()
 return settings and settings.enabled and settings.profile == "Wide_T" and
  (not completed or settings.stage == "complete")
end

function FC.EnsureTabletCombatLog()
 local settings = FC.GetCharacterState()
 if not settings or settings.profile ~= "Wide_T" or InCombatLockdown() then return end
 local api = C_AddOns
 if api and api.IsAddOnLoaded and api.LoadAddOn and not api.IsAddOnLoaded("Blizzard_CombatLog") then
  api.LoadAddOn("Blizzard_CombatLog")
 end
end

function FC.ConfigureTabletCombatChat()
 if not tablet_active() or InCombatLockdown() or FC.IsEditModeActive() then return end

 if not ChatFrame2 then return end
 if FCF_DockFrame then FCF_DockFrame(ChatFrame2, 2, false) end
 if SetChatWindowShown then SetChatWindowShown(2, true) end
 if ChatFrame2Tab then ChatFrame2Tab:Show() end
end

local icons_hooked = setmetatable({}, {__mode = "k"})
local libraries_hooked = setmetatable({}, {__mode = "k"})
local function hide_button(button)
 if not tablet_active(true) or not button then return end
 if button.db then button.db.hide = true end
 button:Hide()
 if not icons_hooked[button] and button.HookScript then
  icons_hooked[button] = true
  button:HookScript("OnShow", function(self)
   if tablet_active(true) then
    if self.db then self.db.hide = true end
    self:Hide()
   end
  end)
 end
end
function FC.HideTabletMinimapButtons()
 if not tablet_active(true) then return end
 local lib = LibStub and LibStub("LibDBIcon-1.0", true)
 if not lib or not lib.GetButtonList or not lib.GetMinimapButton then return end
 if not libraries_hooked[lib] then
  libraries_hooked[lib] = true
  if lib.RegisterCallback then
   lib.RegisterCallback(FC, "LibDBIcon_IconCreated", function(_, button) hide_button(button) end)
  end

  for _, method in ipairs({"Show", "Refresh"}) do
   if type(lib[method]) == "function" then
    hooksecurefunc(lib, method, function(self, name)
     if tablet_active(true) then hide_button(self:GetMinimapButton(name)) end
    end)
   end
  end
 end
 for _, name in ipairs(lib:GetButtonList()) do hide_button(lib:GetMinimapButton(name)) end
end

local runtime = CreateFrame("Frame")
local function event_valid(event)
 return not C_EventUtils or C_EventUtils.IsEventValid(event)
end
function FC.ApplyTabletRuntime()
 if not tablet_active(true) or InCombatLockdown() or FC.IsEditModeActive() then return end
 FC.EnsureTabletCombatLog()
 FC.HideTabletMinimapButtons()
end
local queued
local function queue()
 if queued then return end
 queued = true
 C_Timer.After(.2, function() queued = nil; FC.ApplyTabletRuntime() end)
end
for _, event in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "ADDON_LOADED"}) do
 if event_valid(event) then runtime:RegisterEvent(event) end
end
if EventRegistry and EventRegistry.RegisterCallback then
 EventRegistry:RegisterCallback("EditMode.Exit", queue, runtime)
end
runtime:SetScript("OnEvent", queue)
end

FC.LoadInstaller(...)
FC.LoadInstaller = nil

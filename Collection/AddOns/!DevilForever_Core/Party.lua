-- Party frames: Grid2 draws party and raid; the unit-frame addon's party
-- (PitBull4's party groups, or Forever Unit Frames' (FUF) party) is a switch
-- on top of it, on by default.
--
-- Where each side is stored: Grid2 per character (the profile Grid2DB.profileKeys
-- names for the character, else Grid2DB.global.defaultProfileName, else the
-- AceDB character key), PitBull4 in its shared profile (PitBull4DB.profileKeys
-- entry, else "Default") and FUF in its shared unit profile
-- (ForeverUnitFramesDB.active[<Name-Realm>], else "Default").
--
-- Who writes the switch: at first install the Defaults and preset values make
-- the PitBull4 party groups (party, party target, party target's target,
-- party pet) on, FUF keeps its own default (party on) and Grid2's new profile
-- shows party and raid. After that only /dfp party on|off writes it; logins
-- never compare or re-apply anything, so a group switched in PitBull4's own
-- options stays as the user set it.
--   /dfp party on|off, out of combat, with exactly one unit-frame addon loaded:
--     PitBull4  every party group (unit_group party, partytarget,
--               partytargettarget, partypet) gets enabled = on and the
--               package's show_when (party and raid, not solo). The pet group
--               of an earlier package version (dfPartyRole = "hidden") becomes
--               the package's pet group (unit_group and dfPartyRole "partypet");
--               the values it lacks (layout, position, size, spacing) come from
--               the active preset's pet group, scaled to the profile's dfPixel
--               and added to its dfGeometry signatures; values it holds are kept.
--     FUF       FUF's own commands (SlashCmdList.FOREVERUNITFRAMES)
--               "set party enabled on" | "set party hideBlizzardFrame on" +
--               "set party enabled off"; READBACK seconds later FUF's saved
--               unit profile is read back and one line says whether it took.
--     Grid2     (when loaded) brought to show party if it does not: a party or
--               arena layout "None" becomes "By Group" and a window
--               "Raid"/"Never" becomes "Grouped"; other values are kept. With `on`,
--               a window still at the package's earlier default spot (anchor
--               TOPLEFT, PosX/PosY of OLD_GRID2_SPOT for the active preset, within
--               a physical pixel) moves to the active preset's spot (its V2 compare
--               layout's while the PitBull4 profile uses it, dfLayoutV2); a window the
--               user moved stays where it is (one line says so).
-- The saved-variable tables are written; the frames follow at the next /reload.

local _, Core = ...

local type, pairs, ipairs, tostring, rawget = type, pairs, ipairs, tostring, rawget

local Party = {}
Core.Party = Party

local READBACK = 1   -- seconds before FUF's saved unit profile is read back (FUF saves half a second after a change)

local PB4_PARTY = {party = true, partytarget = true, partytargettarget = true, partypet = true}
local UNIT_ADDONS = {"PitBull4", "ForeverUnitFrames"}

-- {state = "idle"|"applied"|"fuf-pending", on, key, unit} of the last command this session.
local session = {state = "idle"}

local function loaded(folder) return Core.IsLoadedInClient(folder) end

local function sub(parent, key)
  local t = rawget(parent, key)
  if t == nil then
    t = {}
    parent[key] = t
  elseif type(t) ~= "table" then
    return nil
  end
  return t
end

-- Name of the Grid2 profile this character uses, and its Grid2Layout table
-- (created on the way when `create`).
local function grid2Profile(keys, create)
  local sv = _G.Grid2DB
  if type(sv) ~= "table" then return nil end
  local profileKeys = rawget(sv, "profileKeys")
  local entry = type(profileKeys) == "table" and rawget(profileKeys, keys.char)
  local global = rawget(sv, "global")
  local shared = type(global) == "table" and rawget(global, "defaultProfileName")
  local name = (type(entry) == "string" and entry ~= "" and entry)
    or (type(shared) == "string" and shared ~= "" and shared) or keys.char
  if not create then
    local spaces = rawget(sv, "namespaces")
    local space = type(spaces) == "table" and rawget(spaces, "Grid2Layout")
    local profiles = type(space) == "table" and rawget(space, "profiles")
    local p = type(profiles) == "table" and rawget(profiles, name)
    return type(p) == "table" and p or nil, name
  end
  local spaces = sub(sv, "namespaces")
  local space = spaces and sub(spaces, "Grid2Layout")
  local profiles = space and sub(space, "profiles")
  return profiles and sub(profiles, name), name
end

-- Grid2 shows party frames (its own defaults: layout "By Group", window "Always").
local function grid2Shows(p)
  local layouts = type(p) == "table" and rawget(p, "layouts")
  local party = type(layouts) == "table" and rawget(layouts, "party") or "By Group"
  local display = type(p) == "table" and rawget(p, "FrameDisplay") or "Always"
  return party ~= "None" and display ~= "Never" and display ~= "Raid"
end

local LABEL = {party = "파티 칸", arena = "투기장 칸", FrameDisplay = "창"}

-- The package's earlier Grid2 window spot per preset (anchor TOPLEFT, physical pixels), where it
-- overlaps the PitBull4 party column.
local OLD_GRID2_SPOT = {fhd = {24, -164}, qhd = {40, -164}, uhd = {80, -240}}

local function pixelFactor()
  local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
  if type(factor) == "number" and factor > 0 then return factor end
  if type(GetPhysicalScreenSize) ~= "function" then return nil end
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  local ui = UIParent and UIParent:GetEffectiveScale()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then return logical * ui / height end
end

-- Moves this character's Grid2 window from the earlier default spot to the active preset's spot.
-- Returns "moved", preset | "user" | nil (no active package preset, or already elsewhere by the package).
local function moveGrid2(keys)
  local p = grid2Profile(keys, false)
  local active = Core.Presets and Core.Presets:GetActive()
  local old = active and OLD_GRID2_SPOT[active]
  -- the V2 compare layout in use (PitBull4 profile dfLayoutV2) has its own spot above its target
  local sv = _G.PitBull4DB
  local pkeys = type(sv) == "table" and rawget(sv, "profileKeys")
  local pname = type(pkeys) == "table" and rawget(pkeys, keys.char)
  local profiles = type(sv) == "table" and rawget(sv, "profiles")
  local pb4 = type(profiles) == "table" and rawget(profiles, type(pname) == "string" and pname or "Default")
  local v2 = type(pb4) == "table" and rawget(pb4, "dfLayoutV2") == true
  local want
  for _, name in ipairs(old and (v2 and {active, active .. "-v2"} or {active}) or {}) do
    local def = Core.Presets:Get(name)
    for _, f in ipairs(def and def.fragments or {}) do
      if f.folder == "Grid2" and f.namespace == "Grid2Layout" then
        want = want or {}
        for k, v in pairs(f.values) do want[k] = v end
      end
    end
  end
  local factor = pixelFactor()
  if type(p) ~= "table" or not want or not factor then return nil end
  local anchor, x, y = rawget(p, "anchor") or "TOPLEFT", rawget(p, "PosX"), rawget(p, "PosY")
  local function at(a, px, py)   -- within a physical pixel of (a, px, py)
    return anchor == a and type(x) == "number" and type(y) == "number"
      and math.abs(x / factor - px) <= 1 and math.abs(y / factor - py) <= 1
  end
  if at(want.anchor, want.PosX / factor, want.PosY / factor) then return nil end
  if at("TOPLEFT", old[1], old[2]) then
    p.anchor, p.PosX, p.PosY = want.anchor, want.PosX, want.PosY
    return "moved", v2 and (active .. "-v2") or active
  end
  return "user"
end

-- Brings this character's Grid2 to show party where it does not (see the header);
-- returns values changed, profile name, {"<label> <old>→<new>", ...} | nil, reason.
local function showGrid2(keys)
  local p, name = grid2Profile(keys, true)
  if not p then return nil, "Grid2 저장 변수에 쓸 수 없음" end
  if grid2Shows(p) then return 0, name, {} end
  local layouts = sub(p, "layouts")
  if not layouts then return nil, "Grid2 " .. tostring(name) .. ".layouts 가 표가 아님" end
  local changes = {}
  local function set(t, k, old, v)
    t[k] = v
    changes[#changes + 1] = LABEL[k] .. " " .. tostring(old) .. "→" .. v
  end
  local party = rawget(layouts, "party") or "By Group"
  local arena = rawget(layouts, "arena") or "By Group"
  local display = rawget(p, "FrameDisplay") or "Always"
  if party == "None" then set(layouts, "party", party, "By Group") end
  if arena == "None" then set(layouts, "arena", arena, "By Group") end
  if display == "Raid" or display == "Never" then set(p, "FrameDisplay", display, "Grouped") end
  return #changes, name, changes
end

local function pb4Profile(keys)
  local sv = _G.PitBull4DB
  local profileKeys = type(sv) == "table" and rawget(sv, "profileKeys")
  local entry = type(profileKeys) == "table" and rawget(profileKeys, keys.char)
  local name = type(entry) == "string" and entry ~= "" and entry or "Default"
  local profiles = type(sv) == "table" and rawget(sv, "profiles")
  local p = type(profiles) == "table" and rawget(profiles, name)
  return type(p) == "table" and p or nil, name
end

-- PitBull4 party groups (PitBull4's own default unit_group is "party"), sorted by name.
local function pb4Groups(p)
  local out = {}
  local groups = type(p) == "table" and rawget(p, "groups")
  for name, g in pairs(type(groups) == "table" and groups or {}) do
    if type(g) == "table" and PB4_PARTY[rawget(g, "unit_group") or "party"] then out[#out + 1] = {name, g} end
  end
  table.sort(out, function(a, b) return tostring(a[1]) < tostring(b[1]) end)
  return out
end

-- Party groups on / party groups.
local function pb4Count(p)
  local on, all = 0, 0
  for _, item in ipairs(pb4Groups(p)) do
    all = all + 1
    if rawget(item[2], "enabled") == true then on = on + 1 end
  end
  return on, all
end

local SHOW_WHEN = {solo = false, party = true, raid = true, raid10 = true, raid15 = true, raid20 = true, raid25 = true,
  raid30 = true, raid40 = true}
local GROUP_FIELDS = {"anchor", "relative_point", "relative_to", "position_x", "position_y", "scale", "size_x", "size_y",
  "direction", "vertical_spacing", "horizontal_spacing"}
local PET = "파티원 소환수"

-- The active preset's PitBull4 pet group and the dfPixel it was made at, or nil.
local function presetPet()
  local active = Core.Presets and Core.Presets:GetActive()
  local def = active and Core.Presets:Get(active)
  for _, f in ipairs(def and def.fragments or {}) do
    local groups = f.folder == "PitBull4" and not f.namespace and type(f.values.groups) == "table" and f.values.groups
    local pet = groups and groups[PET]
    if type(pet) == "table" and pet.unit_group == "partypet" and type(pet.position_x) == "number" then
      return pet, f.values.dfPixel, active
    end
  end
end

-- An earlier package's hidden pet group made the package's pet group; returns the preset name used or true.
local function convertPet(p, g)
  g.unit_group, g.dfPartyRole, g.exists = "partypet", "partypet", true
  local pet, made, active = presetPet()
  if not pet then
    if rawget(g, "layout") == nil then g.layout = "대상의대상" end
    return true
  end
  local ratio = type(made) == "number" and made > 0 and type(rawget(p, "dfPixel")) == "number" and p.dfPixel / made or 1
  local filled = {}
  for k, v in pairs(pet) do
    if rawget(g, k) == nil and k ~= "enabled" and k ~= "show_when" then
      if k == "position_x" or k == "position_y" then v = v * ratio end
      g[k] = Core.CopyTable(v)
      filled[k] = true
    end
  end
  local geometry = type(rawget(p, "dfGeometry")) == "table" and rawget(p.dfGeometry, "groups")
  if type(geometry) == "table" and filled.position_x and geometry[PET] == nil then
    local parts = {}
    for _, k in ipairs(GROUP_FIELDS) do parts[#parts + 1] = tostring(g[k]) end
    geometry[PET] = table.concat(parts, "|")
  end
  return active
end

-- Brings every party group to `on` and the package design (see the header).
-- Returns groups changed, groups whose show_when changed, preset name | true when the old pet group was converted.
local function setPB4(p, on)
  local changed, shown, converted = 0, 0, nil
  for _, item in ipairs(pb4Groups(p)) do
    local name, g = item[1], item[2]
    local touched = false
    if name == PET and rawget(g, "dfPartyRole") == "hidden" then
      converted = convertPet(p, g)
      touched = true
    end
    local show = rawget(g, "show_when")
    local same = type(show) == "table"
    for k, v in pairs(SHOW_WHEN) do
      if same and rawget(show, k) ~= v then same = false end
    end
    if not same then
      if type(show) ~= "table" then show = {}; g.show_when = show end
      for k, v in pairs(SHOW_WHEN) do show[k] = v end
      shown, touched = shown + 1, true
    end
    if rawget(g, "enabled") ~= on then
      g.enabled = on
      touched = true
    end
    if touched then changed = changed + 1 end
  end
  return changed, shown, converted
end

-- FUF's profile name for this character and the party table of that profile.
local function fufProfile()
  local fdb = _G.ForeverUnitFramesDB
  if type(fdb) ~= "table" or type(UnitFullName) ~= "function" then return nil, "Default" end
  local name, realm = UnitFullName("player")
  if (not realm or realm == "") and type(GetNormalizedRealmName) == "function" then realm = GetNormalizedRealmName() end
  local key = type(name) == "string" and type(realm) == "string" and realm ~= "" and (name .. "-" .. realm) or nil
  local profiles = type(fdb.profiles) == "table" and fdb.profiles or {}
  local chosen = key and type(fdb.active) == "table" and fdb.active[key]
  local pname = type(chosen) == "string" and type(profiles[chosen]) == "table" and chosen or "Default"
  local profile = profiles[pname]
  return type(profile) == "table" and profile.party or nil, pname
end

local function fufShows()
  local party = fufProfile()
  return not (type(party) == "table" and party.enabled == false)
end

-- The one unit-frame addon loaded, its profile and whether its party is on now.
local function unitSide(keys)
  local found
  for _, folder in ipairs(UNIT_ADDONS) do
    if loaded(folder) then
      if found then return nil, "PitBull4 와 Forever Unit Frames 가 함께 켜져 있음" end
      found = folder
    end
  end
  if not found then return nil, "PitBull4·Forever Unit Frames 가 켜져 있지 않음" end
  if found == "PitBull4" then
    local p, name = pb4Profile(keys)
    local on, all = pb4Count(p)
    return {folder = found, key = found .. "/" .. name, profile = name, shows = on > 0, on = on, all = all, table = p}
  end
  local _, name = fufProfile()
  return {folder = found, key = found .. "/" .. name, profile = name, shows = fufShows()}
end

-- FUF: send the commands for `on`; nil, reason when FUF's handler is missing or raised.
local function sendFUF(on)
  local handler = type(SlashCmdList) == "table" and SlashCmdList.FOREVERUNITFRAMES
  if type(handler) ~= "function" then return nil, "FUF 명령이 없음" end
  local commands = on and {"set party enabled on"} or {"set party hideBlizzardFrame on", "set party enabled off"}
  for _, command in ipairs(commands) do
    local ok, err = pcall(handler, command)
    if not ok then return nil, tostring(err) end
  end
  return true
end

local function later(seconds, fn)
  if type(C_Timer) == "table" and type(C_Timer.After) == "function" then C_Timer.After(seconds, fn) end
end

local epoch = 0   -- raised by every command; a read-back of an older command stays silent

local function onOff(on) return on and "켬" or "끔" end

-- {state, on, key, unit} of the last command this session.
function Party:GetState()
  return {state = session.state, on = session.on, key = session.key, unit = session.unit}
end

-- Lines: what each side stores now for this character.
function Party:Describe()
  local keys = Core.PlayerKeys()
  if not keys then return {"캐릭터를 아직 모름"} end
  local lines = {}
  local unit, why = unitSide(keys)
  if not unit then
    lines[#lines + 1] = why
  elseif unit.folder == "PitBull4" then
    lines[#lines + 1] = "PitBull4 " .. unit.profile .. ": 파티 그룹 " .. unit.all .. "개 중 " .. unit.on .. "개 켜짐"
  else
    lines[#lines + 1] = "Forever Unit Frames " .. unit.profile .. ": 파티 " .. (unit.shows and "켜짐" or "꺼짐")
  end
  if loaded("Grid2") then
    local p, name = grid2Profile(keys, false)
    lines[#lines + 1] = "Grid2 " .. tostring(name) .. ": 파티 " .. (grid2Shows(p) and "보임" or "안 보임")
  end
  lines[#lines + 1] = "/dfp party on|off — 유닛 프레임 파티 켜기/끄기(Grid2 는 늘 파티·공격대를 그림)"
  return lines
end

-- on true | false: the unit-frame party switch for the unit-frame profile this
-- character uses (all characters on that profile) and Grid2 shown for this
-- character. Returns true, lines | false, reason; `say` prints the later FUF
-- read-back.
function Party:Set(on, say)
  if on ~= true and on ~= false then return false, "on 또는 off" end
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  if not Core.ready then return false, "Core 저장 변수를 아직 읽지 않음" end
  local keys, why = Core.PlayerKeys()
  if not keys then return false, "캐릭터를 아직 모름: " .. tostring(why) end
  local unit
  unit, why = unitSide(keys)
  if not unit then return false, why end
  local lines, state = {}, "applied"
  if unit.folder == "PitBull4" then
    if unit.all == 0 then return false, "PitBull4 " .. unit.profile .. ": 파티 그룹 없음 — 바꾼 것 없음" end
    local changed, shown, converted = setPB4(unit.table, on)
    if changed > 0 then
      lines[#lines + 1] = "PitBull4 " .. unit.profile .. ": 파티 그룹 " .. changed .. "개 " .. onOff(on)
      if shown > 0 then lines[#lines + 1] = "  그중 " .. shown .. "개는 공격대에서도 보이게 바꿈" end
      if converted then
        lines[#lines + 1] = "  파티원 소환수: 소환수 그룹으로 바꿈" .. (type(converted) == "string"
          and (" (없던 배치 값은 " .. converted .. " preset 값)") or " (preset 배치 값 없음 — 기본 위치)")
      end
    else
      lines[#lines + 1] = "PitBull4 " .. unit.profile .. ": 파티 그룹 이미 모두 " .. (on and "켜짐" or "꺼짐")
    end
  elseif unit.shows == on then
    lines[#lines + 1] = "Forever Unit Frames " .. unit.profile .. ": 파티 이미 " .. (on and "켜짐" or "꺼짐")
  else
    local ok, err = sendFUF(on)
    if not ok then return false, "Forever Unit Frames: " .. tostring(err) .. " — 바꾼 것 없음" end
    state = "fuf-pending"
    lines[#lines + 1] = "Forever Unit Frames " .. unit.profile .. ": 파티 " .. (on and "켜기" or "끄기")
      .. " 명령 보냄 — 저장되면 한 줄 더"
  end
  epoch = epoch + 1
  if state == "fuf-pending" then
    local mine = epoch
    later(READBACK, function()
      if mine ~= epoch then return end
      local done = fufShows() == on
      session.state = done and "applied" or "fuf-pending"
      local line = done and ("Forever Unit Frames 파티 " .. onOff(on) .. " 확인")
        or "Forever Unit Frames 가 파티 설정을 아직 저장하지 않음 — 전투 밖에서 /dfp party " .. (on and "on" or "off") .. " 를 다시"
      Core:Log("info", "Party", line)
      if type(say) == "function" then say(line) end
    end)
  end
  if loaded("Grid2") then
    local n, name, changes = showGrid2(keys)
    if not n then
      lines[#lines + 1] = "Grid2: " .. tostring(name)
    else
      lines[#lines + 1] = "Grid2 " .. name .. ": 파티 보임"
        .. (n > 0 and (" — 바꾼 값: " .. table.concat(changes, " · ")) or " (이미 그럼)")
      local moved, preset = nil, nil
      if on then moved, preset = moveGrid2(keys) end
      if moved == "moved" then
        lines[#lines + 1] = "Grid2 창: 예전 기본 자리 → " .. preset .. " preset 의 자리(오른쪽, 대상 프레임 위)"
      elseif moved == "user" then
        lines[#lines + 1] = "Grid2 창은 예전 기본 자리가 아니라서 그대로 — PitBull4 파티와 겹치면 Grid2 에서 옮기세요"
      end
    end
  end
  lines[#lines + 1] = unit.key .. " 를 쓰는 캐릭터 모두에 적용되는 설정"
  lines[#lines + 1] = "다시 불러오면(/reload) 화면에 적용됨"
  session.state, session.on, session.key, session.unit = state, on, unit.key, unit.folder
  Core:Log("info", "Party", unit.key .. ": unit-frame party " .. (on and "on" or "off"))
  return true, lines
end

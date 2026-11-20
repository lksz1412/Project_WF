-- Owner of the party frames: Grid2 or the unit-frame addon (PitBull4 or Forever
-- Unit Frames, FUF).
--
-- The two sides are kept in profiles of different scope: Grid2's per character
-- (the profile Grid2DB.profileKeys names for the character, else
-- Grid2DB.global.defaultProfileName, else the AceDB character key), PitBull4's
-- shared one (PitBull4DB.profileKeys entry, else "Default") and FUF's shared
-- unit profile (ForeverUnitFramesDB.active[<Name-Realm>], else "Default").
-- Defaults writes new profiles with the unit frames drawing the party.
--
-- The owner is a record on the unit-frame profile:
--   DevilForever_CoreDB.party.owner["<PitBull4|ForeverUnitFrames>/<profile>"]
--     = "grid2" | "unitframes"
-- It is made when this character's Grid2 profile and the unit-frame profile
-- are both new in the same session (first install: "grid2"), or by
-- /dfp party grid2|unitframes. Without a record nothing is written.
-- Once per session, when Grid2 and exactly one unit-frame addon are loaded
-- and the other one is not enabled to load later (their ADDON_LOADED, or
-- PLAYER_LOGIN), the current character is checked against its record. Only
-- ownership is compared, never exact values: a side is written only when it
-- contradicts the record, and then only what makes it draw / not draw the party.
--   PitBull4  ownership = the main party group (unit_group "party") is on.
--             On a contradiction it and the partytarget/partypet groups are
--             switched together; afterwards those two stay as the user sets them.
--   FUF       ownership = FUF's party is not stored off. On a contradiction
--             FUF's own commands are sent (SlashCmdList.FOREVERUNITFRAMES
--             "set party hideBlizzardFrame on" + "set party enabled off" |
--             "set party enabled on") DELAY seconds after the first
--             PLAYER_ENTERING_WORLD, out of combat; Grid2 follows only after
--             FUF's saved unit profile reads the new value (READBACK seconds
--             later); otherwise one chat line says so and the next login tries again.
--   Grid2     ownership = this character's Grid2 shows party (party layout not
--             "None", window not "Raid"/"Never"). To show party: a party or
--             arena layout "None" becomes "By Group" and a window "Raid"/"Never"
--             becomes "Grouped"; another layout or window is kept. Not to show
--             party: party and arena layout "None", a window shown outside a raid
--             ("Grouped"/"Always") becomes "Raid" (no empty window).
-- Grid2 is never set to draw the party before the unit side is off. Every
-- automatic write of a session (unit side, FUF commands, Grid2) is named in
-- one chat line per session, with the record it follows and the /dfp party
-- command that changes it (printed at the first PLAYER_ENTERING_WORLD when it
-- happens earlier); a FUF step that stays pending gives its own line instead.
-- The addons' saved-variable tables are written (before the addon's own
-- ADDON_LOADED for the addon being loaded); the frames follow at the next /reload.

local _, Core = ...

local type, pairs, ipairs, tostring, rawget = type, pairs, ipairs, tostring, rawget

local Party = {}
Core.Party = Party

local DELAY = 20     -- seconds after the first PLAYER_ENTERING_WORLD (FUF holds saves 15 s on a fresh install)
local READBACK = 1   -- seconds before FUF's saved unit profile is read back (FUF saves half a second after a change)

local PB4_PARTY = {party = true, partytarget = true, partypet = true}
local UNIT_ADDONS = {"PitBull4", "ForeverUnitFrames"}

-- {state = "waiting"|"no-record"|"applied"|"fuf-pending"|"not-settled", owner, key, unit, lines}
local session = {state = "waiting"}

local function loaded(folder) return Core.IsLoadedInClient(folder) end

-- Enabled for this character but not loaded yet (it loads later in this login); false when unknown.
-- C_AddOns.GetAddOnEnableState(name, character), else the older GetAddOnEnableState(character, name).
local function comingLater(folder)
  if loaded(folder) then return false end
  if type(UnitName) ~= "function" then return false end
  local character = UnitName("player")
  local ok, state
  local native = C_AddOns and C_AddOns.GetAddOnEnableState
  if type(native) == "function" then
    ok, state = pcall(native, folder, character)
  elseif type(GetAddOnEnableState) == "function" then
    ok, state = pcall(GetAddOnEnableState, character, folder)
  else
    return false
  end
  return ok and type(state) == "number" and state > 0
end

local function records() return Core:DBTable("party", "owner") end

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
local function grid2Owns(p)
  local layouts = type(p) == "table" and rawget(p, "layouts")
  local party = type(layouts) == "table" and rawget(layouts, "party") or "By Group"
  local display = type(p) == "table" and rawget(p, "FrameDisplay") or "Always"
  return party ~= "None" and display ~= "Never" and display ~= "Raid"
end

local LABEL = {party = "파티 칸", arena = "투기장 칸", FrameDisplay = "창"}

-- Brings this character's Grid2 to `owner` only where it contradicts it (see the header);
-- returns values changed, profile name, {"<label> <old>→<new>", ...} | nil, reason.
local function alignGrid2(keys, owner)
  local p, name = grid2Profile(keys, true)
  if not p then return nil, "Grid2 저장 변수에 쓸 수 없음" end
  if grid2Owns(p) == (owner == "grid2") then return 0, name, {} end
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
  if owner == "grid2" then
    if party == "None" then set(layouts, "party", party, "By Group") end
    if arena == "None" then set(layouts, "arena", arena, "By Group") end
    if display == "Raid" or display == "Never" then set(p, "FrameDisplay", display, "Grouped") end
  else
    set(layouts, "party", party, "None")
    if arena ~= "None" then set(layouts, "arena", arena, "None") end
    if display == "Grouped" or display == "Always" then set(p, "FrameDisplay", display, "Raid") end
  end
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

-- PitBull4 party groups (unit_group party, partytarget, partypet; PitBull4's default "party").
local function pb4Groups(p)
  local out = {}
  local groups = type(p) == "table" and rawget(p, "groups")
  for name, g in pairs(type(groups) == "table" and groups or {}) do
    if type(g) == "table" and PB4_PARTY[rawget(g, "unit_group") or "party"] then out[#out + 1] = {name, g} end
  end
  table.sort(out, function(a, b) return tostring(a[1]) < tostring(b[1]) end)
  return out
end

-- Ownership on the PitBull4 side: a main party group (unit_group "party") is on.
local function pb4Shows(p)
  for _, item in ipairs(pb4Groups(p)) do
    if (rawget(item[2], "unit_group") or "party") == "party" and rawget(item[2], "enabled") == true then return true end
  end
  return false
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

-- The one unit-frame addon loaded with Grid2, its record key and whether it draws the party now.
local function unitSide(keys)
  if not loaded("Grid2") then return nil, "Grid2 가 켜져 있지 않음" end
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
    return {folder = found, key = found .. "/" .. name, profile = name, shows = pb4Shows(p), table = p}
  end
  local _, name = fufProfile()
  return {folder = found, key = found .. "/" .. name, profile = name, shows = fufShows()}
end

local function targetState(folder, label)
  local st = Core.Defaults:GetStatus(folder)
  local t = st and st.targets and st.targets[label]
  return t and t.state
end

-- The unit side is new this session: nil while not known yet.
local function unitIsNew(unit)
  if unit.folder == "PitBull4" then
    local s = targetState("PitBull4", "PitBull4DB")
    if s == "waiting" or s == nil then return nil end
    return s == "applied"
  end
  local fresh = Core.Profiles:WasFresh("ForeverUnitFramesDB")
  if fresh == nil then return nil end
  return fresh == true
end

local function grid2IsNew()
  local s = targetState("Grid2", "Grid2DB/Grid2Layout")
  if s == "waiting" or s == nil then return nil end
  return s == "applied"
end

local function logLine(line)
  Core:Log("info", "Party", line)
end

-- FUF: send the commands for `owner`; nil, reason when FUF's handler is missing or raised.
local function sendFUF(owner)
  local handler = type(SlashCmdList) == "table" and SlashCmdList.FOREVERUNITFRAMES
  if type(handler) ~= "function" then return nil, "FUF 명령이 없음" end
  local commands = owner == "grid2" and {"set party hideBlizzardFrame on", "set party enabled off"}
    or {"set party enabled on"}
  for _, command in ipairs(commands) do
    local ok, err = pcall(handler, command)
    if not ok then return nil, tostring(err) end
  end
  return true
end

local epoch = 0         -- raised by Party:Set; an automatic FUF step of an older epoch stops
local noticed = false   -- the pending line or the automatic-change line was printed this session
local worldSeen = false
local heldNotice        -- automatic-change line waiting for the first PLAYER_ENTERING_WORLD

-- The one chat line of a session that names Party's automatic writes `parts`.
local function autoNotice(parts)
  if noticed or #parts == 0 then return end
  noticed = true
  local owner = session.owner
  local line = "파티 프레임: " .. table.concat(parts, ", ") .. " — 저장된 파티 설정(" .. tostring(session.key) .. ": "
    .. (owner == "grid2" and "Grid2 가" or "유닛 프레임이") .. " 파티를 그림)을 따름. 바꾸려면 전투 밖에서 /dfp party "
    .. (owner == "grid2" and "unitframes" or "grid2")
  if worldSeen then Core.Profiles:Print(line) else heldNotice = line end
end

local function grid2Part(name, changes)
  return "Grid2 " .. tostring(name) .. " " .. table.concat(changes, " · ")
end

-- One chat line per session while the FUF side stays pending.
local function notePending()
  if noticed then return end
  noticed = true
  Core.Profiles:Print("Forever Unit Frames 의 파티 설정이 " .. tostring(session.key)
    .. " 기록과 아직 다름 — 다음 접속 때 다시 맞춤(바로 하려면 전투 밖에서 /dfp party grid2 또는 /dfp party unitframes)")
end

-- After FUF had time to save: Grid2 follows when FUF's saved profile reads the owner's value.
-- `say` prints the outcome (command); without it (login) a failure gives the pending line.
local function confirmFUF(keys, owner, say, mine)
  if mine and mine ~= epoch then return false end
  local done = fufShows() == (owner == "unitframes")
  if not done then
    local line = "Forever Unit Frames 가 파티 설정을 아직 저장하지 않음 — Grid2 는 그대로, 다음 접속 때 다시"
    session.state = "fuf-pending"
    logLine(line)
    if say then say(line) else notePending() end
    return false
  end
  local n, name, changes = alignGrid2(keys, owner)
  local fufPart = "Forever Unit Frames 파티 " .. (owner == "unitframes" and "켬" or "끔")
  local line = n and (fufPart .. " 확인 — " .. (n > 0 and grid2Part(name, changes) or ("Grid2 " .. name .. " 그대로")))
    or ("Grid2: " .. tostring(name))
  session.state = n and "applied" or "fuf-pending"
  logLine(line)
  if say then
    say(line)
  else
    local parts = {fufPart}
    if n and n > 0 then parts[2] = grid2Part(name, changes) end
    autoNotice(parts)
  end
  return n ~= nil
end

local function later(seconds, fn)
  if type(C_Timer) == "table" and type(C_Timer.After) == "function" then C_Timer.After(seconds, fn) end
end

local fufDue = nil      -- owner to apply on the FUF side after the delay
local waitingCombat = false

local function runFUF()
  if not fufDue then return end
  if Core.InCombat() then
    waitingCombat = true
    return
  end
  local owner = fufDue
  fufDue = nil
  local keys = Core.PlayerKeys()
  if not keys then return end
  local ok, why = sendFUF(owner)
  if not ok then
    session.state = "fuf-pending"
    logLine("Forever Unit Frames 명령 안 됨: " .. tostring(why) .. " — 다음 접속 때 다시")
    notePending()
    return
  end
  local mine = epoch
  later(READBACK, function() confirmFUF(keys, owner, nil, mine) end)
end

local function settle(final)
  if session.state ~= "waiting" or not Core.ready then return end
  local keys = Core.PlayerKeys()
  if not keys then
    if final then session.state = "not-settled" end
    return
  end
  if not final then
    for _, folder in ipairs(UNIT_ADDONS) do
      if comingLater(folder) then return end
    end
  end
  local unit = unitSide(keys)
  if not unit then
    if final then session.state = "not-settled" end
    return
  end
  local owners = records()
  local owner = owners[unit.key]
  if owner ~= "grid2" and owner ~= "unitframes" then
    local g, u = grid2IsNew(), unitIsNew(unit)
    if g == nil or u == nil then
      if final then session.state = "not-settled" end
      return
    end
    if not (g and u) then
      session.state, session.key = "no-record", unit.key
      return
    end
    owner = "grid2"
    owners[unit.key] = owner
    logLine(unit.key .. ": new install — party frames recorded for Grid2")
  end
  session.owner, session.key, session.unit = owner, unit.key, unit.folder
  local unitWants = owner == "unitframes"
  local parts = {}
  if unit.folder == "PitBull4" and unit.shows ~= unitWants then
    for _, item in ipairs(pb4Groups(unit.table)) do item[2].enabled = unitWants end
    logLine("PitBull4 " .. unit.profile .. ": party groups " .. (unitWants and "on" or "off") .. " (" .. unit.key .. ")")
    parts[1] = "PitBull4 " .. unit.profile .. " 파티 그룹 " .. (unitWants and "켬" or "끔")
  elseif unit.folder ~= "PitBull4" and unit.shows ~= unitWants then
    session.state = "fuf-pending"
    fufDue = owner
    if worldSeen then later(DELAY, runFUF) end
    return
  end
  local n, name, changes = alignGrid2(keys, owner)
  session.state = n and "applied" or "not-settled"
  if n and n > 0 then
    logLine("Grid2 " .. name .. ": party values follow " .. unit.key .. " (" .. owner .. ")")
    parts[#parts + 1] = grid2Part(name, changes)
  end
  autoNotice(parts)
end

Core:On("ADDON_LOADED", function(_, folder)
  if folder == "Grid2" or folder == "PitBull4" or folder == "ForeverUnitFrames" then settle(false) end
end)
Core:On("PLAYER_LOGIN", function() settle(true) end)
Core:On("PLAYER_ENTERING_WORLD", function()
  if worldSeen then return end
  worldSeen = true
  if heldNotice then
    Core.Profiles:Print(heldNotice)
    heldNotice = nil
  end
  if fufDue then later(DELAY, runFUF) end
end)
Core:On("PLAYER_REGEN_ENABLED", function()
  if waitingCombat then
    waitingCombat = false
    later(DELAY, runFUF)
  end
end)

-- {state, owner, key, unit} of this session.
function Party:GetState()
  return {state = session.state, owner = session.owner, key = session.key, unit = session.unit}
end

-- Lines: the record and what each side stores now for this character.
function Party:Describe()
  local keys = Core.PlayerKeys()
  if not keys then return {"캐릭터를 아직 모름"} end
  local lines = {}
  local unit, why = unitSide(keys)
  if unit then
    local owner = Core.ready and records()[unit.key]
    lines[#lines + 1] = "기록(" .. unit.key .. "): " .. (owner == "grid2" and "Grid2 가 파티를 그림"
      or owner == "unitframes" and "유닛 프레임이 파티를 그림" or "없음 — 지금 상태 그대로")
    lines[#lines + 1] = unit.folder .. " " .. unit.profile .. ": 파티 " .. (unit.shows and "켜짐" or "꺼짐")
  else
    lines[#lines + 1] = why
  end
  if loaded("Grid2") then
    local p, name = grid2Profile(keys, false)
    lines[#lines + 1] = "Grid2 " .. tostring(name) .. ": 파티 " .. (grid2Owns(p) and "보임" or "안 보임")
  end
  return lines
end

-- owner "grid2" | "unitframes": records the owner on the unit-frame profile this
-- character uses and brings this character to it (FUF: Grid2 after FUF's
-- read-back). Returns true, lines | false, reason; `say` prints the later
-- FUF outcome.
function Party:Set(owner, say)
  if owner ~= "grid2" and owner ~= "unitframes" then return false, "grid2 또는 unitframes" end
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  if not Core.ready then return false, "Core 저장 변수를 아직 읽지 않음" end
  local keys, why = Core.PlayerKeys()
  if not keys then return false, "캐릭터를 아직 모름: " .. tostring(why) end
  local unit
  unit, why = unitSide(keys)
  if not unit then return false, why end
  local lines, state = {}, "applied"
  local unitWants = owner == "unitframes"
  local function grid2Line(n, name, changes)
    if not n then return "Grid2: " .. tostring(name) end
    local p = grid2Profile(keys, false)
    return "Grid2 " .. name .. ": 파티 " .. (grid2Owns(p) and "보임" or "안 보임")
      .. (n > 0 and (" — 바꾼 값: " .. table.concat(changes, " · ")) or " (이미 그럼)")
  end
  if unit.folder == "PitBull4" then
    local groups = pb4Groups(unit.table)
    if #groups == 0 and unitWants then return false, "PitBull4 " .. unit.profile .. ": 파티 그룹 없음 — 바꾼 것 없음" end
    fufDue, epoch = nil, epoch + 1
    records()[unit.key] = owner
    if unit.shows ~= unitWants then
      for _, item in ipairs(groups) do item[2].enabled = unitWants end
      lines[#lines + 1] = "PitBull4 " .. unit.profile .. ": 파티 그룹 " .. #groups .. "개 " .. (unitWants and "켬" or "끔")
    else
      lines[#lines + 1] = "PitBull4 " .. unit.profile .. ": 파티 이미 " .. (unitWants and "켜짐" or "꺼짐")
    end
    lines[#lines + 1] = grid2Line(alignGrid2(keys, owner))
  else
    if unit.shows == unitWants then
      fufDue, epoch = nil, epoch + 1
      records()[unit.key] = owner
      lines[#lines + 1] = "Forever Unit Frames " .. unit.profile .. ": 파티 이미 " .. (unitWants and "켜짐" or "꺼짐")
      lines[#lines + 1] = grid2Line(alignGrid2(keys, owner))
    else
      local ok, err = sendFUF(owner)
      if not ok then return false, "Forever Unit Frames: " .. tostring(err) .. " — 바꾼 것 없음" end
      fufDue, epoch = nil, epoch + 1
      records()[unit.key] = owner
      state = "fuf-pending"
      lines[#lines + 1] = "Forever Unit Frames " .. unit.profile .. ": 파티 " .. (unitWants and "켜기" or "끄기")
        .. " 명령 보냄 — 저장되면 Grid2 를 맞춤(곧 한 줄 더)"
      local mine = epoch
      later(READBACK, function() confirmFUF(keys, owner, say, mine) end)
    end
  end
  lines[#lines + 1] = unit.key .. " 를 쓰는 캐릭터 모두에 적용되는 설정 — 다른 캐릭터는 다음 접속 때 맞춰짐"
  lines[#lines + 1] = "다시 불러오면(/reload) 화면에 적용됨"
  session.state, session.owner, session.key, session.unit = state, owner, unit.key, unit.folder
  return true, lines
end

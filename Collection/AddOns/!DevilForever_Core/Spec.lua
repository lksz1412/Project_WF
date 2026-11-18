-- Talent-group (dual spec) profiles for the class part: links the AceDB
-- database of each registry saved variable with split = "class" to
-- LibDualSpec-1.0, which then switches the profile itself when the talent
-- group changes. Core calls no talent API; the current group is
-- LibDualSpec's currentSpec (0 = dual spec not active). Every change refuses
-- in combat. A database without the LibDualSpec methods is reported.

local _, Core = ...

local type, ipairs, tostring, pcall = type, ipairs, tostring, pcall

local Spec = {}
Core.Spec = Spec

local function lds()
  if LibStub == nil then return nil end
  local ok, lib = pcall(LibStub, "LibDualSpec-1.0", true)
  return ok and type(lib) == "table" and lib or nil
end

function Spec:CurrentGroup()
  local lib = lds()
  local group = lib and tonumber(lib.currentSpec) or 0
  return group or 0
end

-- {{folder, savedVariable, db}} for every class-split saved variable.
local function targets()
  local out = {}
  for _, sv in ipairs(Core:GetSavedVariables()) do
    if sv.split == "class" then
      out[#out + 1] = {folder = sv.folder, savedVariable = sv.name, db = Core.FindAceDB(_G[sv.name])}
    end
  end
  return out
end

local function supports(db)
  return type(db) == "table" and type(db.SetDualSpecEnabled) == "function"
    and type(db.SetDualSpecProfile) == "function" and type(db.GetDualSpecProfile) == "function"
    and type(db.GetCurrentProfile) == "function"
end

-- One line per class-split saved variable.
function Spec:GetState()
  local lines = {}
  local group = self:CurrentGroup()
  for _, t in ipairs(targets()) do
    local label = t.folder .. " " .. t.savedVariable
    if not t.db then
      lines[#lines + 1] = label .. ": AceDB 없음(애드온이 켜져 있지 않음)"
    elseif not supports(t.db) then
      lines[#lines + 1] = label .. ": 특성 profile 지원 없음"
    else
      local p1 = t.db:GetDualSpecProfile(1)
      local p2 = t.db:GetDualSpecProfile(2)
      lines[#lines + 1] = label .. ": 지금 " .. tostring(t.db:GetCurrentProfile()) .. ", 1번 " .. tostring(p1)
        .. ", 2번 " .. tostring(p2) .. ", 지금 특성 " .. group
    end
  end
  if #lines == 0 then lines[1] = "직업별 저장 변수 없음" end
  return lines
end

local function each(action)
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  local lines = {}
  for _, t in ipairs(targets()) do
    local label = t.folder .. " " .. t.savedVariable
    if not t.db then
      lines[#lines + 1] = label .. ": AceDB 없음(애드온이 켜져 있지 않음)"
    elseif not supports(t.db) then
      lines[#lines + 1] = label .. ": 특성 profile 지원 없음"
    else
      lines[#lines + 1] = label .. ": " .. action(t.db)
    end
  end
  if #lines == 0 then lines[1] = "직업별 저장 변수 없음" end
  return true, lines
end

-- Turns spec profiles on and maps the current group to the current profile.
function Spec:Link()
  local group = self:CurrentGroup()
  return each(function(db)
    db:SetDualSpecEnabled(true)
    if group < 1 then return "켬 — 지금 특성 번호를 모름(이중 특성 없음)" end
    local current = db:GetCurrentProfile()
    db:SetDualSpecProfile(current, group)
    return "켬 — " .. group .. "번 특성 = " .. tostring(current)
  end)
end

-- Copies the current profile to "<current> (2)" and maps it to the other group.
function Spec:New()
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  local group = self:CurrentGroup()
  if group < 1 then return false, "지금 특성 번호를 모름(이중 특성 없음) — 바꾼 것 없음" end
  local other = group == 1 and 2 or 1
  return each(function(db)
    if type(db.SetProfile) ~= "function" or type(db.CopyProfile) ~= "function" then return "profile 복사 지원 없음" end
    local current = db:GetCurrentProfile()
    local newName = tostring(current) .. " (2)"
    local profiles = type(db.sv) == "table" and type(db.sv.profiles) == "table" and db.sv.profiles or {}
    if profiles[newName] ~= nil then return newName .. " 이 이미 있음 — 바꾼 것 없음" end
    db:SetProfile(newName)
    db:CopyProfile(current)
    db:SetProfile(current)
    db:SetDualSpecEnabled(true)
    db:SetDualSpecProfile(current, group)
    db:SetDualSpecProfile(newName, other)
    return group .. "번 특성 = " .. tostring(current) .. ", " .. other .. "번 특성 = " .. newName
  end)
end

-- Turns spec profiles off.
function Spec:Off()
  return each(function(db)
    db:SetDualSpecEnabled(false)
    return "끔"
  end)
end

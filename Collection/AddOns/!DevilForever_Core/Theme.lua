-- Named theme tokens for appearance code.
--
-- A token set maps token names to values. The base set "devil" defines the
-- token names; a token missing from the active set falls back to "devil".
-- Values (colors {r, g, b, a}, texture paths, font paths, sizes) are supplied
-- by appearance code through RegisterSet; Core ships the names only, so every
-- token reads nil until a set with values is registered.
-- Listeners are called with (newName, oldName) and never while
-- InCombatLockdown() is true: a switch, a replacement of the active set and
-- the restore of the saved set at login are held until PLAYER_REGEN_ENABLED.

local _, Core = ...

local type, pairs, ipairs, sort = type, pairs, ipairs, table.sort

local Theme = {}
Core.Theme = Theme

Theme.BASE_SET = "devil"

-- Token names of the base set. Kinds: color = {r, g, b, a} (0..1),
-- texture = file path, font = file path, size/number = number.
Theme.TOKENS = {
  ["color.panel.background"] = "color",
  ["color.panel.border"] = "color",
  ["color.divider"] = "color",
  ["color.accent"] = "color",
  ["color.text.normal"] = "color",
  ["color.text.highlight"] = "color",
  ["color.text.disabled"] = "color",
  ["texture.panel"] = "texture",
  ["texture.divider"] = "texture",
  ["texture.ornament.left"] = "texture",
  ["texture.ornament.right"] = "texture",
  ["texture.statusbar"] = "texture",
  ["font.normal"] = "font",
  ["font.header"] = "font",
  ["font.number"] = "font",
  ["font.size.small"] = "size",
  ["font.size.normal"] = "size",
  ["font.size.header"] = "size",
  ["border.size"] = "size",
  ["spacing.default"] = "number",
}

local sets = {[Theme.BASE_SET] = {}}
local activeName = Theme.BASE_SET
local pendingName
local pendingNotify = false
local listeners = Core.NewCallbackList()

local function validValue(kind, value)
  if kind == "color" then
    if type(value) ~= "table" then return false end
    for i = 1, 3 do
      local c = value[i]
      if type(c) ~= "number" or c < 0 or c > 1 then return false end
    end
    local a = value[4]
    return a == nil or (type(a) == "number" and a >= 0 and a <= 1)
  elseif kind == "texture" or kind == "font" then
    return type(value) == "string" and value ~= ""
  end
  return type(value) == "number"
end

-- Registers or replaces token set `name` with `values` ({[token] = value}).
-- Unknown token names and values of the wrong kind are dropped and logged.
-- Returns the number of tokens kept. Replacing the active set notifies
-- listeners with (name, name), after combat when in combat.
function Theme:RegisterSet(name, values)
  if type(name) ~= "string" or name == "" or type(values) ~= "table" then return 0 end
  local set, kept = {}, 0
  for token, value in pairs(values) do
    local kind = Theme.TOKENS[token]
    if not kind then
      Core:Log("skip", "Theme:" .. name, "unknown token " .. tostring(token))
    elseif not validValue(kind, value) then
      Core:Log("skip", "Theme:" .. name, "value of " .. token .. " is not a " .. kind)
    else
      set[token] = Core.CopyTable(value)
      kept = kept + 1
    end
  end
  sets[name] = set
  if name == activeName then
    if Core.InCombat() then
      pendingNotify = true
    else
      listeners:Fire(name, name)
    end
  end
  return kept
end

-- Value of `token` in the active set, else in the base set; nil when unset.
-- Table values are returned as copies.
function Theme:Get(token)
  local value = sets[activeName] and sets[activeName][token]
  if value == nil then value = sets[Theme.BASE_SET][token] end
  return Core.CopyTable(value)
end

-- Value of `token` in set `name` only (no fallback).
function Theme:GetFromSet(name, token)
  local set = sets[name]
  return set and Core.CopyTable(set[token]) or nil
end

function Theme:GetSet()
  return activeName, pendingName
end

function Theme:ListSets()
  local names = {}
  for name in pairs(sets) do names[#names + 1] = name end
  sort(names)
  return names
end

function Theme:ListTokens()
  local names = {}
  for name in pairs(Theme.TOKENS) do names[#names + 1] = name end
  sort(names)
  return names
end

local function switch(name)
  local old = activeName
  activeName = name
  pendingName = nil
  pendingNotify = false
  if Core.ready then Core:DBTable("theme").active = name end
  if old ~= name then listeners:Fire(name, old) end
end

-- Makes `name` the active set. Returns true, "applied" | "queued" | "unchanged",
-- or false, reason. In combat the switch waits for PLAYER_REGEN_ENABLED; a later
-- call replaces a waiting one.
function Theme:SetActiveSet(name)
  if not sets[name] then return false, "unknown set" end
  if Core.InCombat() then
    pendingName = name
    return true, "queued"
  end
  if name == activeName then
    pendingName = nil
    return true, "unchanged"
  end
  switch(name)
  return true, "applied"
end

-- fn(newName, oldName); one function per owner.
function Theme:RegisterCallback(owner, fn) return listeners:Register(owner, fn) end
function Theme:UnregisterCallback(owner) return listeners:Unregister(owner) end

Core:On("PLAYER_REGEN_ENABLED", function()
  if pendingName and sets[pendingName] and pendingName ~= activeName then
    switch(pendingName)
  elseif pendingNotify then
    pendingNotify = false
    listeners:Fire(activeName, activeName)
  end
  pendingName = nil
end)

-- The saved active set is restored at PLAYER_LOGIN, after every addon file
-- (and so every RegisterSet call made at load time) has run. A saved name that
-- no addon registered leaves the base set active.
Core:On("PLAYER_LOGIN", function()
  local saved = Core.ready and Core:DBTable("theme").active
  if type(saved) ~= "string" or saved == activeName then return end
  if not sets[saved] then
    Core:Log("skip", "Theme", "saved set " .. saved .. " is not registered; base set kept")
    return
  end
  if Core.InCombat() then
    pendingName = pendingName or saved
    return
  end
  local old = activeName
  activeName = saved
  listeners:Fire(saved, old)
end)

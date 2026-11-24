-- Slash commands /dfprofile and /dfp: text only, no window. Every command that
-- changes something refuses in combat and prints what it does; save, restore
-- and preset values take effect after /dfp go (a /reload), a theme switch
-- (/dfp theme <number>) at once.
-- /dfp keys|game pass through to ProfileManager (Keybinds, GameSettings) only
-- on that explicit command. /dfp party grid2|unitframes moves this character's
-- party frames between Grid2 and the unit-frame addon (Party.lua), at once in
-- the saved variables, on screen after a /reload.

local _, Core = ...

local type, ipairs, tostring = type, ipairs, tostring

local Commands = {}
Core.Commands = Commands

local function say(line) Core.Profiles:Print(line) end

local function sayAll(lines)
  if type(lines) == "table" then
    for _, line in ipairs(lines) do say(line) end
  else
    say(lines)
  end
end

local function result(ok, linesOrReason)
  if ok then sayAll(linesOrReason) else say("안 함: " .. tostring(linesOrReason)) end
end

local HELP = {
  "/dfp status — 지금 preset·기다리는 요청·지난 결과·특성 연결",
  "/dfp list — 저장본 목록",
  "/dfp show <이름> [all|common|class] [only <폴더>] — 되돌리면 무엇을 쓰는지(미리 보기)",
  "/dfp save <이름> — 저장 예약(같은 이름이면 합침) → /dfp go",
  "/dfp restore <이름> [all|common|class] [only <폴더>] — 되돌리기 예약 → /dfp go",
  "/dfp go — 기다리는 요청이 있으면 다시 불러오기",
  "/dfp cancel — 기다리는 요청 지우기",
  "/dfp delete <이름> [yes] — 저장본 하나 지우기",
  "/dfp preset [<이름>] — preset 목록 / preset 으로 되돌리기",
  "/dfp theme [<번호>] — 테마 목록 / 테마 바꾸기(기본 0)",
  "/dfp spec [link|new|off] — 특성(이중 특성) profile 연결",
  "/dfp party [grid2|unitframes] — 파티 프레임을 Grid2 / 유닛 프레임(PitBull4·FUF) 중 어디서 그릴지 (보기 / 바꾸기 → /reload)",
  "/dfp keys save|load|list [<이름>] · /dfp game save|load|list [<이름>] — ProfileManager 의 키 설정·게임 설정",
}

local function words(msg)
  local out = {}
  for w in tostring(msg or ""):gmatch("%S+") do out[#out + 1] = w end
  return out
end

-- [all|common|class] [only <Folder>] after the name; part words and "only"
-- in any letter case, nothing after the folder.
local function partArgs(w, from)
  local part, only = nil, nil
  local i = from
  local word = w[i] and w[i]:lower()
  if word == "all" or word == "common" or word == "class" then
    part = word
    i = i + 1
    word = w[i] and w[i]:lower()
  end
  if word == "only" then
    only = w[i + 1]
    if not only then return nil, nil, "only 뒤에 폴더 이름" end
    i = i + 2
  end
  if w[i] ~= nil then return nil, nil, "알 수 없는 말: " .. w[i] end
  return part, only
end

-- Most words a command takes (command word included).
local MAX_WORDS = {help = 1, status = 1, list = 1, go = 1, cancel = 1, save = 2, delete = 3, preset = 2, theme = 2,
  spec = 2, party = 2}

local function status()
  local P = Core.Profiles
  local st = P:GetStatus()
  local active, registered = Core.Presets:GetActive()
  say("preset: " .. tostring(active or "없음") .. (active and not registered and " (등록 안 됨)" or ""))
  local theme, waiting = Core.Theme:GetSet()
  say("테마: " .. theme .. (waiting and (" (전투 뒤 " .. waiting .. ")") or ""))
  if st.readOnly then say(st.readOnly) end
  if type(st.pending) == "table" then
    say("기다리는 요청: " .. tostring(st.pending.action) .. " " .. tostring(st.pending.name) .. " — /dfp go 또는 /dfp cancel")
  else
    say("기다리는 요청: 없음")
  end
  say("저장본: " .. st.snapshots .. "/" .. st.maxSnapshots)
  if type(st.last) == "table" then
    say("지난 결과: " .. tostring(st.last.action) .. " " .. tostring(st.last.name or ""))
    sayAll(st.last.lines or {})
  end
  sayAll(Core.Spec:GetState())
end

local function list()
  local rows = Core.Profiles:List()
  if #rows == 0 then return say("저장본 없음") end
  for _, r in ipairs(rows) do
    if r.problem then
      say(tostring(r.name) .. " — " .. r.problem .. " (읽기만 함)")
    else
      local when = type(date) == "function" and type(r.savedAt) == "number" and date("%Y-%m-%d %H:%M", r.savedAt)
        or tostring(r.savedAt)
      say(tostring(r.name) .. " — " .. when .. " · " .. tostring(r.char) .. " (" .. tostring(r.class) .. ") · 항목 "
        .. tostring(r.entries) .. " (남긴 항목 " .. tostring(r.carried) .. ") · 약 "
        .. tostring(math.floor(r.bytes / 1024 + 0.5)) .. " KB")
    end
  end
end

-- Base tokens a set lacks (they read the base value).
local function missingTokens(name)
  local T, n = Core.Theme, 0
  if name == T.BASE_SET then return 0 end
  for _, token in ipairs(T:ListTokens()) do
    if T:GetFromSet(name, token) == nil then n = n + 1 end
  end
  return n
end

local function theme(selection)
  local T = Core.Theme
  if not selection then
    local active, waiting = T:GetSet()
    local function show(set, label)
      local missing = missingTokens(set)
      say(label .. (set == active and " (지금)" or "") .. (set == waiting and " (전투 뒤 바뀜)" or "")
        .. (missing > 0 and (" — 빠진 토큰 " .. missing .. "개는 " .. T.BASE_SET .. " 값") or ""))
    end
    local registered = T:ListSets()
    local available = {}
    for _, set in ipairs(registered) do available[set] = true end
    for _, choice in ipairs(T:ListChoices()) do
      show(choice.name, choice.number .. " " .. choice.name)
      available[choice.name] = nil
    end
    for _, set in ipairs(registered) do
      if available[set] then show(set, set) end
    end
    local saved = Core.ready and rawget(Core:DBTable("theme"), "active")
    if type(saved) == "string" and saved ~= active and saved ~= waiting then
      say("저장된 테마 " .. saved .. " 은 등록돼 있지 않음 — " .. active .. " 사용")
    end
    return
  end
  if Core.InCombat() then return say("안 함: 전투 중 — 바꾼 것 없음") end
  local name = selection
  if selection:match("^%d+$") then name = T:GetChoiceName(tonumber(selection)) end
  local ok, how = T:SetActiveSet(name)
  if not ok then return say("안 함: " .. selection .. ": 등록된 테마가 아님 — /dfp theme 로 목록") end
  say(how == "unchanged" and ("이미 " .. name .. " 테마") or ("테마 " .. name .. " 으로 바꿈"))
end

local function passThrough(kindWord, w)
  if (w[2] == "save" or w[2] == "load") and Core.InCombat() then return say("안 함: 전투 중 — 바꾼 것 없음") end
  local PM = ProfileManager
  local part = kindWord == "keys" and "Keybinds" or "GameSettings"
  local api = type(PM) == "table" and PM[part]
  if type(api) ~= "table" then return say("ProfileManager 가 켜져 있지 않음") end
  if type(api.IsAvailable) == "function" and not api:IsAvailable() then
    return say("이 클라이언트에서 ProfileManager " .. part .. " 를 쓸 수 없음")
  end
  local action, name = w[2], w[3]
  if action == "list" then
    local names = api:GetProfileNames()
    return say(part .. ": " .. (#names > 0 and table.concat(names, ", ") or "없음"))
  end
  if action ~= "save" and action ~= "load" then return say("/dfp " .. kindWord .. " save|load|list <이름>") end
  if type(name) ~= "string" or name == "" then return say("이름이 비어 있음") end
  name = table.concat(w, " ", 3)
  local ok, detail
  if action == "save" then
    if api:GetProfile(name) then ok, detail = api:UpdateProfile(name) else ok, detail = api:SaveProfile(name) end
  else
    ok, detail = api:LoadProfile(name)
  end
  if ok then say(part .. " " .. action .. " " .. name .. ": 됨") else say(part .. " " .. action .. " 안 됨: " .. tostring(detail)) end
end

function Commands:Run(msg)
  local w = words(msg)
  local cmd = (w[1] or "help"):lower()
  local P = Core.Profiles
  local most = MAX_WORDS[cmd]
  if most and #w > most then return say("알 수 없는 말: " .. w[most + 1] .. " — /dfp help") end
  if cmd == "help" then
    sayAll(HELP)
  elseif cmd == "status" then
    status()
  elseif cmd == "list" then
    list()
  elseif cmd == "show" then
    if not w[2] then return say("/dfp show <이름>") end
    local part, only, err = partArgs(w, 3)
    if err then return say(err) end
    sayAll(P:Describe(w[2], part, only))
  elseif cmd == "save" then
    if not w[2] then return say("/dfp save <이름> (이름에 빈칸 없이)") end
    result(P:RequestSave(w[2]))
  elseif cmd == "restore" then
    if not w[2] then return say("/dfp restore <이름>") end
    local part, only, err = partArgs(w, 3)
    if err then return say(err) end
    result(P:RequestRestore(w[2], part, only))
  elseif cmd == "go" then
    local ok, why = P:Go()
    if not ok then say("안 함: " .. tostring(why)) end
  elseif cmd == "cancel" then
    local ok, why = P:Cancel()
    say(ok and "기다리는 요청을 지움" or ("안 함: " .. tostring(why)))
  elseif cmd == "delete" then
    if not w[2] then return say("/dfp delete <이름> yes") end
    local ok, why = P:Delete(w[2], w[3] and w[3]:lower())
    say(ok and (w[2] .. " 지움") or ("안 함: " .. tostring(why)))
  elseif cmd == "preset" then
    if not w[2] then
      local active = Core.Presets:GetActive()
      local names = Core.Presets:List()
      if #names == 0 then return say("등록된 preset 없음") end
      for _, name in ipairs(names) do say(name .. (name == active and " (지금)" or "")) end
      return
    end
    result(Core.Presets:Restore(w[2]))
  elseif cmd == "theme" then
    theme(w[2])
  elseif cmd == "spec" then
    local sub = (w[2] or ""):lower()
    if sub == "" then
      sayAll(Core.Spec:GetState())
    elseif sub == "link" then
      result(Core.Spec:Link())
    elseif sub == "new" then
      result(Core.Spec:New())
    elseif sub == "off" then
      result(Core.Spec:Off())
    else
      say("/dfp spec [link|new|off]")
    end
  elseif cmd == "party" then
    local sub = (w[2] or ""):lower()
    if sub == "" then
      sayAll(Core.Party:Describe())
    elseif sub == "grid2" or sub == "unitframes" then
      result(Core.Party:Set(sub, say))
    else
      say("/dfp party [grid2|unitframes]")
    end
  elseif cmd == "keys" or cmd == "game" then
    passThrough(cmd, w)
  else
    say("알 수 없는 명령 — /dfp help")
  end
end

if type(SlashCmdList) == "table" then
  SLASH_DFPROFILE1 = "/dfprofile"
  SLASH_DFPROFILE2 = "/dfp"
  SlashCmdList.DFPROFILE = function(msg) Commands:Run(msg) end
end

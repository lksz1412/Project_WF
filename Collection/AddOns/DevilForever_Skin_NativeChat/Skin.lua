-- Native chat keeps message handling, input, history, filters, locking and geometry.

local Core = DevilForever_Core
local owner = {}
local ready = false
local pending = false
local watched = setmetatable({}, {__mode = "k"})
local focusWatched = setmetatable({}, {__mode = "k"})
local scrollWatched = setmetatable({}, {__mode = "k"})
local roles = {}
local publicControls = {
  "ChatFrameMenuButton", "QuickJoinToastButton", "ChatFrameChannelButton",
  "ChatFrameToggleVoiceDeafenButton", "ChatFrameToggleVoiceMuteButton",
}

local function mouseOver(frame)
  return frame and frame.IsMouseOver and frame:IsMouseOver()
end

local function setAlpha(region, alpha)
  if region and region.SetAlpha then region:SetAlpha(alpha) end
end

local function chrome(frame)
  if InCombatLockdown() then pending = true; return end
  local role = roles[frame]
  if not role then return end
  local name = frame:GetName()
  local tab = _G[name .. "Tab"]
  local edit = _G[name .. "EditBox"]
  local buttons = frame.buttonFrame or _G[name .. "ButtonFrame"]
  local hover = mouseOver(frame) or mouseOver(tab) or mouseOver(buttons) or mouseOver(edit)
  if role == "public" then
    for _, controlName in ipairs(publicControls) do hover = hover or mouseOver(_G[controlName]) end
  end
  local focused = edit and edit.HasFocus and edit:HasFocus()
  local alert = tab and tab.alerting
  local moving = frame.isMoving or frame.isResizing
  local show = hover or focused or alert or moving
  local alpha = show and 1 or 0
  local offset = frame.GetScrollOffset and frame:GetScrollOffset()
  local scrolled = type(offset) == "number" and offset > 0
  setAlpha(tab, alpha)
  setAlpha(buttons, (show or scrolled) and 1 or 0)
  setAlpha(frame.ScrollBar, (show or scrolled) and 1 or 0)
  if role == "public" then
    for _, controlName in ipairs(publicControls) do setAlpha(_G[controlName], alpha) end
  end
  for _, suffix in ipairs({"Left", "Mid", "Right"}) do
    setAlpha(_G[name .. "EditBox" .. suffix], focused and 1 or 0)
  end
  if edit then
    setAlpha(edit.focusLeft, focused and 1 or 0)
    setAlpha(edit.focusMid, focused and 1 or 0)
    setAlpha(edit.focusRight, focused and 1 or 0)
  end
end

local function watch(widget, frame)
  if not widget or not widget.HookScript or watched[widget] then return end
  widget:HookScript("OnEnter", function() chrome(frame) end)
  widget:HookScript("OnLeave", function() chrome(frame) end)
  watched[widget] = true
end

local function styleRole(role, key)
  local db = DevilForever_ChatSetupDB
  local windows = type(db) == "table" and db.result == "created" and type(db.windows) == "table" and db.windows
  local id = windows and windows[role]
  if role == "public" and not id then id = 1 end
  if type(id) ~= "number" or id == 2 then return end
  local frame = _G["ChatFrame" .. id]
  if not frame or frame.isTemporary then return end
  roles[frame] = role
  local name = frame:GetName()
  local values = Core.Edit:Get(key)
  local font = values.font
  if font and font.path and font.size then
    frame:SetFont(font.path, font.size * DevilForever_Appearance:GetPixelUnit(frame), font.flags or "")
  end
  for _, suffix in ipairs(CHAT_FRAME_TEXTURES or {}) do setAlpha(_G[name .. suffix], 0) end
  local tab = _G[name .. "Tab"]
  local edit = _G[name .. "EditBox"]
  local buttons = frame.buttonFrame or _G[name .. "ButtonFrame"]
  watch(frame, frame)
  watch(tab, frame)
  watch(edit, frame)
  watch(buttons, frame)
  watch(frame.ScrollBar, frame)
  if edit and font and font.path and font.size then
    edit:SetFont(font.path, font.size * DevilForever_Appearance:GetPixelUnit(edit), font.flags or "")
    if not focusWatched[edit] then
      edit:HookScript("OnEditFocusGained", function() chrome(frame) end)
      edit:HookScript("OnEditFocusLost", function() chrome(frame) end)
      focusWatched[edit] = true
    end
  end
  if not scrollWatched[frame] then
    for _, method in ipairs({"ScrollUp", "ScrollDown", "ScrollToTop", "ScrollToBottom", "PageUp", "PageDown"}) do
      if type(frame[method]) == "function" then hooksecurefunc(frame, method, function() chrome(frame) end) end
    end
    scrollWatched[frame] = true
  end
  if role == "public" then
    for _, controlName in ipairs(publicControls) do watch(_G[controlName], frame) end
  end
  chrome(frame)
end

local function apply()
  if not ready then return end
  if InCombatLockdown() then pending = true; return end
  pending = false
  if not DevilForever_Appearance:GetPixelUnit(UIParent) then
    Core:Log("skip", "Feature appearance", "physical pixel factor unavailable")
    return
  end
  styleRole("public", "appearance.chat1")
  styleRole("group", "appearance.chat2")
  styleRole("system", "appearance.chat3")
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("UI_SCALE_CHANGED")
events:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_LOGIN" then
    ready = true
    apply()
  elseif event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(4, apply)
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then
    apply()
  end
end)

for _, name in ipairs({"FCFTab_UpdateAlpha", "FCF_StartAlertFlash", "FCF_StopAlertFlash"}) do
  if type(_G[name]) == "function" then hooksecurefunc(name, function(frame) if frame then chrome(frame) end end) end
end
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key == "appearance.chat1" or key == "appearance.chat2" or key == "appearance.chat3" then apply() end
end)

local setup = DevilForever_ChatSetup
if setup and type(setup.RegisterWindowsCreated) == "function" then
  setup:RegisterWindowsCreated(owner, apply)
end

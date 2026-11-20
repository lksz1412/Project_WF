-- Register each theme under its own media names; existing names are not replaced.
local Core = DevilForever_Core
local registered = false
local function register()
  if registered or not LibStub then return end
  local media = LibStub("LibSharedMedia-3.0", true)
  if not media then return end
  for _, name in ipairs({"devil", "horde", "alliance"}) do
    local title = "Devil Forever " .. name
    media:Register("statusbar", title, Core.Theme:GetFromSet(name, "texture.statusbar"))
    media:Register("background", title, Core.Theme:GetFromSet(name, "texture.panel"))
    media:Register("font", title, Core.Theme:GetFromSet(name, "font.normal"), 143)
  end
  registered = true
end
local events = CreateFrame("Frame")
local onEvent = register
register = function()
  onEvent()
  if registered then events:UnregisterAllEvents() end
end
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", register)
register()

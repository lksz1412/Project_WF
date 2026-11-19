-- Read-only client binding probe. This addon does not style or move native frames.
local Probe = {}
DevilForever_NativeAppearanceProbe = Probe
local viewers = {
  "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer",
}
local function describe(frame)
  if not frame then return {exists=false} end
  local result = {exists=true}
  if frame.GetName then result.name=frame:GetName() end
  if frame.GetObjectType then result.kind=frame:GetObjectType() end
  if frame.GetEffectiveScale then result.effectiveScale=frame:GetEffectiveScale() end
  if frame.GetSize then result.width,result.height=frame:GetSize() end
  if frame.GetNumPoints and frame.GetPoint then
    result.points={}
    for index=1,frame:GetNumPoints() do
      local point,relative,relativePoint,x,y=frame:GetPoint(index)
      result.points[index]={point=point,relative=relative and relative.GetName and relative:GetName(),relativePoint=relativePoint,x=x,y=y}
    end
  end
  return result
end
function Probe:CooldownViewers()
  local result={}
  for _,name in ipairs(viewers) do result[name]=describe(_G[name]) end
  return result
end
function Probe:Nameplates()
  local api=C_NamePlate and C_NamePlate.GetNamePlates
  if type(api)~="function" then return {available=false,reason="C_NamePlate.GetNamePlates unavailable"} end
  local result={available=true,plates={}}
  for _,frame in ipairs(api()) do result.plates[#result.plates+1]=describe(frame) end
  return result
end

local function output(message)
  local line="DevilForever: " .. message
  if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage)=="function" then DEFAULT_CHAT_FRAME:AddMessage(line)
  else print(line) end
end
local function shown(value)
  if value==nil then return "unavailable" end
  return tostring(value)
end
local function readCVar(name)
  local getter=C_CVar and C_CVar.GetCVar or GetCVar
  if type(getter)=="function" then return getter(name) end
end
function Probe:PrintSummary()
  local version,build,date,toc
  if type(GetBuildInfo)=="function" then version,build,date,toc=GetBuildInfo() end
  output("client "..shown(version).." build="..shown(build).." date="..shown(date).." interface="..shown(toc))
  local width,height
  if type(GetPhysicalScreenSize)=="function" then width,height=GetPhysicalScreenSize() end
  local uiWidth=UIParent and UIParent.GetWidth and UIParent:GetWidth()
  local uiHeight=UIParent and UIParent.GetHeight and UIParent:GetHeight()
  local scale=UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()
  local factor=PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
  output("screen "..shown(width).." x "..shown(height).."; UIParent "..shown(uiWidth).." x "..shown(uiHeight))
  output("useUiScale="..shown(readCVar("useUiScale")).." uiScale="..shown(readCVar("uiScale")).." effective="..shown(scale).." pixelFactor="..shown(factor))
  local viewers=self:CooldownViewers()
  for _,name in ipairs({"EssentialCooldownViewer","UtilityCooldownViewer","BuffIconCooldownViewer","BuffBarCooldownViewer"}) do
    local data=viewers[name]
    output(name..": "..(data.exists and (shown(data.width).." x "..shown(data.height).." effective="..shown(data.effectiveScale)) or "absent"))
  end
  local plates=self:Nameplates()
  output("nameplates="..(plates.available and tostring(#plates.plates) or "API unavailable"))
end
SLASH_DEVILFOREVERAPPEARANCE1="/dfappearance"
SlashCmdList.DEVILFOREVERAPPEARANCE=function() Probe:PrintSummary() end

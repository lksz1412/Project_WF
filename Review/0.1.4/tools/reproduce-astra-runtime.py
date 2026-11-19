from pathlib import Path
from lupa.lua51 import LuaRuntime

ADDONS = Path(__file__).resolve().parents[3] / "Collection/AddOns"


def execute(vm, member):
    vm.execute((ADDONS / member).read_bytes())


def tiny_threat():
    v=LuaRuntime()
    v.execute("""
local nop=function()end
SlashCmdList={}
DetailsFramework={UnitGroupRolesAssigned=function()return "DAMAGER"end,IsTimewalkWoW=function()return false end,IsClassicWow=function()return false end}
plugin={Frame={RegisterEvent=function(s,k)s[k]=true end,UnregisterEvent=function(s,k)s[k]=nil end,SetWidth=nop,SetHeight=nop},SetPluginDescription=nop,ScheduleRepeatingTimer=function(self,method,dt)created=(created or 0)+1;interval=dt;return method end,CancelTimer=nop}
Details={gump={},NewPluginObject=function()return plugin end,RegisterEvent=nop,InstallPlugin=function()return nil,{}end}
LibStub=setmetatable({GetLibrary=nop},{__call=function()return {GetLocale=function()return {}end}end})
IsInRaid=function()return true end
IsInGroup=function()return true end
GetNumGroupMembers=function()return 40 end
GetUnitName=function(name)return name end
UnitClass=function()return "Warrior","WARRIOR" end
UnitExists=function()return true end
UnitName=function(u)return u end
UnitIsFriend=function()return false end
UnitDetailedThreatSituation=function()reads=(reads or 0)+1;return false,0,0,0,0 end
""")
    execute(v,'Details_TinyThreat/Details_TinyThreat.lua')
    v.execute("""
plugin:OnEvent(nil,'ADDON_LOADED','Details_TinyThreat')
plugin:OnDetailsEvent('HIDE')
assert(not plugin.Actived and plugin.Frame.PLAYER_REGEN_DISABLED)
plugin:OnEvent(nil,'PLAYER_REGEN_DISABLED')
assert(plugin.Actived and plugin.job_thread=='Tick')
for i=1,30 do plugin:Tick() end
assert(reads==1200 and interval==1)
plugin:OnEvent(nil,'PLAYER_REGEN_ENABLED')
assert(not plugin.job_thread and not plugin.Actived)
""")
    print('TinyThreat HIDE -> registered combat event -> 30 hidden ticks, 40 raid members:',v.globals().reads,'threat reads')
def appearance():
    v=LuaRuntime()
    v.execute("""
local noop=function()end
local hits={}
local obj={}
function obj:GetEffectiveScale()return 1 end
function obj:GetHeight()return 1080 end
function obj:Hide()self.hidden=true;if self.tex and self.shown then hits[self]=true end end
function obj:Show()self.shown=true;self.hidden=false end
function obj:SetTexture(x)self.written=true;return true end
function obj:CreateTexture()local t=CreateFrame();t.tex=true;return t end
function obj:SetScript(k,f)self[k]=f end
function obj:RegisterEvent(k)if k=="PLAYER_LOGIN"then eventframe=self end end
setmetatable(obj,{__index=function(_,k)if k:match("^Set")or k:match("^Clear")or k:match("^Enable") then return noop end end})
function CreateFrame(_,name)local o=setmetatable({},{__index=obj});if name then _G[name]=o end;return o end
UIParent=CreateFrame();function GetPhysicalScreenSize()return 1920,1080 end
function InCombatLockdown()return false end
local ys={aux=-400,chat1=-600,status=-850}
DevilForever_Core={Theme={RegisterCallback=noop,GetSet=function()return "devil" end,Get=function(_,k)if k=="border.size"then return 1 elseif k:match("^color") then return {1,1,1,1} else return "texture" end end},Presets={GetActive=function()return "fhd" end},Edit={RegisterCallback=noop,GetEdits=function()return {}end,Get=function(_,key)return {position={relativeTo="DevilForever_AppearanceRoot",point="TOPLEFT",relativePoint="TOPLEFT",x=0,y=ys[key:match("%.(.*)")] or -650},size={width=500,height=50},color={1,1,1,1}}end},Log=noop}
function evidence()local n=0;for t in pairs(hits)do if t.written and t.hidden then n=n+1 end end;return n end
""")
    execute(v,'DevilForever_Appearance/Composition.lua')
    execute(v,'DevilForever_Appearance/Appearance.lua')
    v.execute("eventframe.OnEvent(eventframe,'PLAYER_LOGIN');assert(DevilForever_Composition.active)")
    print('Appearance written, shown, then hidden textures in one composed apply:',v.globals().evidence())
if __name__=='__main__':
    tiny_threat()
    appearance()

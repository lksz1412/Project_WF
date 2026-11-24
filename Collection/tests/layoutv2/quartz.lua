
min,max,abs=math.min,math.max,math.abs
local _,eventFrames=debug.getupvalue(TEST_fire,1)
for _,frame in ipairs(eventFrames) do frame.UnregisterAllEvents=function(self) self.events={} end end
format=string.format
WOW_PROJECT_ID=15;WOW_PROJECT_CAMELOT=15;WOW_PROJECT_MAINLINE=1;WOW_PROJECT_CLASSIC=2
Enum={StatusBarTimerDirection={ElapsedTime=0,RemainingTime=1},StatusBarInterpolation={Immediate=0}}
C_CurveUtil={EvaluateColorValueFromBoolean=function(v,a,b) if v then return a else return b end end}
AceGUIWidgetLSMlists={font={},statusbar={},border={}}
function issecretvalue() return false end
function UnitName() return 'Hero','Surname' end
function UnitCastingInfo() if TEST_casting then return 'Test cast','Test cast',136243,100000,103000,false,'guid',false,1234 end end
function UnitChannelInfo() end
C_Spell={GetSpellName=function(id) return 'Spell'..id end}
function GetTime() return 100 end
function GetScreenWidth() return 3840 end
function GetScreenHeight() return 2160 end
function IsAltKeyDown() return false end
local function merge(target,source)
 for k,v in pairs(source) do
  if type(v)=='table' then target[k]=target[k] or {};merge(target[k],v)
  elseif target[k]==nil then target[k]=v end
 end
 if source['*']~=nil then setmetatable(target,{__index=function() return source['*'] end}) end
 return target
end
TEST_merge=merge
function uiwidget(name,parent)
 local f={name=name,parentFrame=parent,scale=1,w=0,h=0,positionWrites=0,scaleWrites=0,events={}}
 function f:GetName() return self.name end
 function f:GetParent() return self.parentFrame end
 function f:GetWidth() return self.w end
 function f:GetHeight() return self.h end
 function f:GetFrameLevel() return 2 end
 function f:GetScale() return self.scale end
 function f:GetEffectiveScale() return self.scale*TEST_ui end
 function f:GetStringWidth() return 48 end
 function f:SetScale(v) self.scale=v;self.scaleWrites=self.scaleWrites+1 end
 function f:SetWidth(v) self.w=v end
 function f:SetHeight(v) self.h=v end
 function f:SetPoint(...) self.pos={...};self.positionWrites=self.positionWrites+1 end
 function f:ClearAllPoints() self.pos=nil end
 function f:CreateFontString() return uiwidget(nil,self) end
 function f:CreateTexture() return uiwidget(nil,self) end
 function f:GetStatusBarTexture() return self end
 function f:SetScript(key,fn) self[key]=fn end
 function f:Show() local changed=not self.shown;self.shown=true;if changed and self.OnShow then self.OnShow(self) end end
 function f:Hide() local changed=self.shown;self.shown=false;if changed and self.OnHide then self.OnHide(self) end end
 function f:RegisterEvent(e) self.events[e]=true end
 function f:RegisterUnitEvent(e,...) self.events[e]={...} end
 function f:UnregisterAllEvents() self.events={} end
 for _,k in ipairs({'SetBackdrop','SetAlpha','SetFrameStrata','SetFrameLevel','EnableMouse','SetMovable','RegisterForDrag',
  'SetClampedToScreen','SetAllPoints','SetTexture','SetTexCoord','SetStatusBarTexture','SetMinMaxValues',
  'SetStatusBarColor','SetValue','SetTimerDuration','SetFont','SetShadowColor','SetShadowOffset',
  'SetTextColor','SetNonSpaceWrap','SetText','SetFormattedText','SetJustifyH','SetBlendMode',
  'SetVertexColor','SetBackdropBorderColor','SetBackdropColor','SetAlphaFromBoolean','ApplyBackdrop'}) do f[k]=function() end end
 return setmetatable(f,{__index={Hide=function(self) self.shown=false end}})
end
CastingBarFrame=uiwidget('BlizzardPlayerCast',UIParent)
CreateFrame=function(_,name,parent) local f=uiwidget(name,parent);if name then _G[name]=f end;return f end
local addon
local ace={}
function ace:NewAddon()
 addon={modules={}}
 function addon:NewModule(name)
  local m={enabled=true,name=name}
  function m:IsEnabled() return self.enabled end
  m.SetEnabledState=function(self,v) self.enabled=v end
  m.Hook=function() end;m.RegisterUnitEvent=function() end
  m.RegisterEvent=function(self,e) self.registered=self.registered or {};self.registered[e]=true end
  m.UnregisterAllEvents=function(self) self.registered=nil end
  self.modules[name]=m;return m
 end
 function addon:GetModule(name) return self.modules[name] end
 function addon:IterateModules() return pairs(self.modules) end
 function addon:CreateStatusBar(_,parent) return uiwidget(nil,parent) end
 addon.SetupOptions=function() end;addon.RegisterModuleOptions=function() end
 addon.EnableModule=function(self,n) self.modules[n].enabled=true end
 addon.DisableModule=function(self,n) self.modules[n].enabled=false end
 TEST_quartz=addon;return addon
end
function ace:GetAddon(name) if name=='Quartz3' then return addon end end
TEST_libs['AceAddon-3.0']=ace
TEST_libs['AceLocale-3.0']={GetLocale=function() return setmetatable({}, {__index=function(_,k) return k end}) end}
TEST_libs['LibSharedMedia-3.0']={Register=function() end,RegisterCallback=function() end,UnregisterCallback=function() end,Fetch=function(_,_,name) return name end}
TEST_libs['AceDB-3.0']={New=function(_,_,defaults)
 local db={profile=merge(Quartz3DB.profiles.Default,defaults.profile)}
 function db:RegisterNamespace(name,defaults)
  local row=Quartz3DB.namespaces[name].profiles.Default
  local ns={profile=merge(row,defaults.profile)};return ns
 end
 local callback=LibStub('CallbackHandler-1.0'):New(db)
 TEST_quartzCallbacks=callback
 return db
end}

FocusFrameSpellBar=uiwidget('BlizzardFocusCast',UIParent)
C_StringUtil={CreateNumericRuleFormatter=function() return {SetBreakpoints=function() end} end}
local original=uiwidget
function uiwidget(...)
 local f=original(...)
 function f:SetText(v) self.text=v end
 function f:SetFormattedText(fmt,...) self.text=string.format(fmt,...) end
 function f:SetAlphaFromBoolean(v,a,b) self.nativeAlpha=TEST_shielded and a or b end
 function f:SetTimerDuration(duration) self.timerDuration=duration end
 return f
end
function UnitCastingInfo(unit)
 if TEST_casting then return 'Test '..unit,'Test '..unit,136243,100000,103000,false,'guid',TEST_shielded,1234 end
end
DURATION={HasSecretValues=function() return false end,IsZero=function() return false end,
 HasExpired=function() return false end,FormatRemainingDuration=function() return '2.0' end,
 FormatElapsedDuration=function() return '1.0' end,FormatTotalDuration=function() return '3.0' end}
function UnitCastingDuration() return DURATION end
function CreateFromMixins() return {Init=function() end,SetTimeFormat=function() end,SetSecondsFormatter=function() end,
 SetMinimumTime=function() end,SetRoundingMode=function() end,SetMinuteThreshold=function() end} end
SecondsFormatterMixin={};SecondsFormatter={Abbreviation={None=0},Interval={Seconds=1}};Enum.SecondsFormatterFormat={Seconds=1};Enum.SecondsFormatterAbbreviation={None=0};Enum.SecondsFormatterRoundingMethod={Truncate=0,RoundUp=1};Enum.SecondsFormatterInterval={Seconds=1}

local originalWidget=uiwidget
function uiwidget(...)
 local f=originalWidget(...)
 function f:SetValue(v) self.value=v end
 function f:SetMinMaxValues(a,b) self.minimum,self.maximum=a,b end
 return f
end
Enum.PlayerSwingType={MainHand=1,OffHand=2,Ranged=3}
TEST_clock=100
function GetTime() return TEST_clock end
function issecretvalue(v) return type(v)=='table' and v.secret==true end

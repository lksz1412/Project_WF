local createFrame=CreateFrame
function CreateFrame(...)
 local frame=createFrame(...)
 frame.Show=function(self) self.shown=true end;frame.Hide=function(self) self.shown=false end
 return frame
end
C_Timer=C_Timer or {}
PitBull4.Controls={}

PitBull4.Compat={IsForever=true,IsValueAccessible=function() return true end,RegisterOptionalEvent=function(m,e,f) m.events[e]=f end}
PitBull4.Utils.FrameHasUnit=function(f) return f.unit~=nil end
PitBull4.Utils.SafeValue=function(v) return v end;PitBull4.Utils.SafeGUID=function(v) return v end
PitBull4.Utils.SafeString=function(v) return type(v)=='string' and v or nil end
PitBull4.Utils.SafeEqual=function(a,b) return a==b end
PitBull4.Utils.SafeNumber=function(v,default) return type(v)=='number' and v or default end
PitBull4.Utils.SafeBoolean=function(v,default) if v==nil then return default end;return v and true or false end
function PitBull4:IsInConfigMode() return false end
local registry={}
function PitBull4:NewModuleType(name,defaults) local p={defaults=defaults};registry[name]=p;return p end
local oldNew=PitBull4.NewModule
function PitBull4:NewModule(name)
 if name~='CastBar' then return oldNew(self,name) end
 local m={id=name,name=name,events={},db={profile={global={}}}}
 m.SetName=noop;m.SetDescription=noop;m.SetLayoutOptionsFunction=noop;m.SetColorOptionsFunction=noop
 function m:SetModuleType(kind) self.module_type=kind;setmetatable(self,{__index=registry[kind]}) end
 function m:SetDefaults(values,global) self.defaults=values;self.db.profile.global=global end
 function m:GetLayoutDB(f)
  local name=type(f)=='table' and f.layout or f
  local d=DevilForever_Core.CopyTable(registry.bar.defaults);DevilForever_Core.WriteOver(d,self.defaults)
  DevilForever_Core.WriteOver(d,PitBull4DB.namespaces.CastBar.profiles.Default.layouts[name] or {})
  return d
 end
 function m:RegisterEvent(e,f) self.events[e]=f end
 function m:UpdateAll() self:UpdateFrame(TEST_frames[1]) end
 function m:UpdateForUnitID(u) if u=='player' then self:UpdateFrame(TEST_frames[1]) end end
 self.modules[name]=m;self.CastBar=m;return m
end
PitBull4.GetModule=function(self,n) return self.modules[n] end
PitBull4.IterateFramesForGUID=function() return function() end end
PitBull4.IterateFramesForUnitID=function() local done=false;return function() if done then return end;done=true;return TEST_frames[1] end end
local function bar()
 local f=makeRegion();f.kind='LiveStatusBar'
 function f:Delete() self.deleted=true;return nil end
 function f:SetRawValue(current,max) self.raw={current,max} end
 function f:SetValue(v) self.value=v end;function f:GetValue() return self.value or 0 end
 function f:SetDurationValue(d,reverse) self.duration=d;self.deplete=reverse end
 function f:SetTexture(v) self.texture=v end
 function f:Show() self.shown=true end;function f:Hide() self.shown=false end
 for _,k in ipairs({'SetColor','SetNormalAlpha','SetBackgroundColor','SetBackgroundAlpha','SetAtlas','SetIcon','SetIconPosition','SetExtraValue','SetExtra2Value'}) do f[k]=noop end
 return f
end
PitBull4.Controls.MakeLiveStatusBar=bar;PitBull4.Controls.MakeBetterStatusBar=bar
TEST_casting=false;TEST_channel=false;TEST_clock=100;TEST_tickers={}
function GetTime() return TEST_clock end
function UnitCastingInfo(u) if u=='player' and TEST_casting and not TEST_channel then return 'Heal',nil,136243,100000,103000,false,'guid',false end end
function UnitChannelInfo(u) if u=='player' and TEST_casting and TEST_channel then return 'Channel',nil,136243,100000,103000,false,false end end
TEST_duration={GetRemainingDuration=function() return 2 end}
function UnitCastingDuration() return TEST_duration end;function UnitChannelDuration() return TEST_duration end
function UnitGUID(u) return 'guid:'..u end
C_Timer.NewTicker=function(delay,fn) local t={delay=delay,fn=fn,cancelled=false};function t:Cancel() self.cancelled=true end;TEST_tickers[#TEST_tickers+1]=t;return t end
function wipe(t) for k in pairs(t) do t[k]=nil end;return t end

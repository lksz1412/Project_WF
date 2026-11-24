function hooksecurefunc(object,key,callback)
  local old=object[key]
  object[key]=function(...) local result=old(...);callback(...);return result end
end
function noop() end

TEST_ui=1
UIParent.GetEffectiveScale=function() return TEST_ui end
PixelUtil.GetPixelToUIUnitFactor=function() return TEST_factor end
UIParent.GetHeight=function() return 768/TEST_ui end
PitBull4={L={},frames_to_anchor={},modules={},new=function() return {} end,del=function() end,
 Utils={GetRelativeFrame=function() return UIParent,'0' end,FrameHasUnit=function() return false end},
 OutOfCombatWrapper=function(_,fn) return fn end,CallMethodOnModules=noop}
function LibStub:NewLibrary(name) local lib={};TEST_libs[name]=lib;return lib end
local nativeXpcall=xpcall
function xpcall(fn,handler,...)
 local args={...};return nativeXpcall(function() return fn(unpack(args)) end,handler)
end
TEST_profileHooks=0
local secureHook=hooksecurefunc
function hooksecurefunc(object,key,fn)
 if object==PitBull4 and key=='OnProfileChanged' then TEST_profileHooks=TEST_profileHooks+1 end
 return secureHook(object,key,fn)
end
function wipe(t) for k in pairs(t) do t[k]=nil end end
TEST_frames={};TEST_headers={}
function PitBull4:IterateFrames() local i=0;return function() i=i+1;return TEST_frames[i] end end
function PitBull4:IterateHeaders(also_unused)
 local i=0
 return function()
  repeat i=i+1 until not TEST_headers[i] or also_unused or TEST_headers[i].group_db
  return TEST_headers[i]
 end
end
function PitBull4:IterateModulesOfType(kind)
 local entries={}
 for name,m in pairs(self.modules) do if m.module_type==kind then entries[name]=m end end
 return pairs(entries)
end
function makeRegion()
 local f={points={},writes=0}
 function f:SetPoint(...) assert(not TEST_combat);self.points[#self.points+1]={...};self.writes=self.writes+1 end
 function f:ClearAllPoints() assert(not TEST_combat);self.points={} end
 function f:SetScale(v) assert(not TEST_combat);self.scale=v;self.writes=self.writes+1 end
 function f:GetEffectiveScale() return (self.scale or 1)*TEST_ui end
 function f:SetWidth(v) assert(not TEST_combat);self.width=v end
 function f:SetHeight(v) assert(not TEST_combat);self.height=v end
 function f:GetWidth() return self.width end
 function f:GetHeight() return self.height end
 f.SetFrameStrata=noop;f.SetFrameLevel=noop;f.SetOrientation=noop;f.SetReverse=noop;f.SetDeficit=noop
 return f
end
function buildFrames()
 PitBull4.db={profile=PitBull4DB.profiles.Default}
 local profile=PitBull4.db.profile
 for i,name in ipairs({'플레이어','대상'}) do
  local f=makeRegion();f.classification=name;f.classification_db=profile.units[name]
  for k,v in pairs(PitBull4.UnitFrame) do f[k]=v end
  f.RefixSizeAndPosition=PitBull4.SingletonUnitFrame.RefixSizeAndPosition
  f.SetClickThroughState=noop
  f.Update=function(self) self:UpdateLayout(false) end
  f.HealthBar=makeRegion();f.PowerBar=makeRegion()
  TEST_frames[i]=f
 end
 for index,name in ipairs({'HealthBar','PowerBar'}) do
  local m={module_type='bar'}
  function m:GetLayoutDB(layout)
   return {size=PitBull4DB.namespaces[name].profiles.Default.layouts[layout].size,
    position=index,side='center',reverse=false,deficit=false}
  end
  PitBull4.modules[name]=m
 end
 local h={writes=0,group_db=profile.groups['파티']}
 function h:RefreshGroup() assert(not TEST_combat);self.writes=self.writes+1 end
 TEST_headers[1]=h
 TEST_headers[2]={RefreshGroup=function() error('unused profile header refreshed') end}
 TEST_registeredProfile=DevilForever_Core.CopyTable(profile)
 function PitBull4:OnProfileChanged()
  for _,f in ipairs(TEST_frames) do f.classification_db=self.db.profile.units[f.classification] end
  TEST_headers[1].group_db=self.db.profile.groups['파티']
  if not TEST_combat then for _,f in ipairs(TEST_frames) do f:RefreshLayout() end end
 end
 function PitBull4:OnProfileReset() self:OnProfileChanged() end
 TEST_profileCallbacks=LibStub('CallbackHandler-1.0'):New(PitBull4.db)
 PitBull4.db.RegisterCallback(PitBull4,'OnProfileChanged')
 PitBull4.db.RegisterCallback(PitBull4,'OnProfileCopied','OnProfileChanged')
 PitBull4.db.RegisterCallback(PitBull4,'OnProfileReset')
end

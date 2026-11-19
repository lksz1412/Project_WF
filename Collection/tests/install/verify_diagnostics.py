"""Call the read-only diagnostic slash handler in Lua 5.1."""
from pathlib import Path
from lupa import lua51
p=Path(__file__).resolve().parents[2]/'AddOns/DevilForever_Skin_Nameplates/Probe.lua'
r=lua51.LuaRuntime(unpack_returned_tuples=True)
r.execute(r'''
lines={};reads={};writes=0
DEFAULT_CHAT_FRAME={AddMessage=function(_,text) lines[#lines+1]=text end}
SlashCmdList={}
function GetBuildInfo() return "1.16.0","test-build","test-date",16001 end
function GetPhysicalScreenSize() return 3840,2160 end
UIParent={GetWidth=function() return 2133.333 end,GetHeight=function() return 1200 end,GetEffectiveScale=function() return 0.64 end}
PixelUtil={GetPixelToUIUnitFactor=function() return 0.355556 end}
C_CVar={GetCVar=function(name) reads[#reads+1]=name;return name=="useUiScale" and "1" or "0.64" end}
local f={GetSize=function() return 400,80 end,GetEffectiveScale=function() return 0.64 end}
EssentialCooldownViewer=f;UtilityCooldownViewer=f
C_NamePlate={GetNamePlates=function() return {f,f} end}
function SetCVar() writes=writes+1;error("forbidden write") end
function CreateFrame() writes=writes+1;error("forbidden frame creation") end
''')
r.execute(p.read_text(encoding='utf-8'))
r.globals().SlashCmdList.DEVILFOREVERAPPEARANCE('')
lines=list(r.globals().lines.values())
assert len(lines)==8 and 'nameplates=2' in lines[-1]
assert any('EssentialCooldownViewer: 400 x 80' in line for line in lines)
assert any('BuffBarCooldownViewer: absent' in line for line in lines)
assert list(r.globals().reads.values())==['useUiScale','uiScale']
assert r.globals().writes==0
r.execute('C_NamePlate=nil;EssentialCooldownViewer=nil;PixelUtil=nil')
r.globals().SlashCmdList.DEVILFOREVERAPPEARANCE('')
assert 'API unavailable' in r.globals().lines[16]
print('PASS Lua5.1 /dfappearance: 8 local chat rows, build/screen/scales/viewer presence/count, missing API path, 0 setting/frame writes')

r.execute(r'''
function InCombatLockdown() return combat end
function GetNumGroupMembers() return groupSize end
function IsInRaid() return inRaid end
function UnitExists(unit) return unit == "pet" and petPresent end
DevilForever_Core={Presets={GetActive=function() return "uhd",true end},Theme={GetSet=function() return "stage" end}}
DevilForever_Appearance={GetPixelFactor=function() return .32 end}
local frame={GetRect=function() return 16,4,100,30 end,GetEffectiveScale=function() return .64 end,IsVisible=function() return true end}
ChatFrame1=frame; ChatFrame3=frame; DominosFrame1=frame
DominosFramepet=frame; Quartz3CastBarPet=frame
DevilForever_ChatSetupDB={result="created",windows={public=1,group=3}}
C_NamePlate={GetNamePlates=function() return {frame,frame} end}
C_AddOns={IsAddOnLoaded=function(name) if name=="PitBull4" then return pb4Loaded end return fufLoaded end}
pb4Loaded=true; fufLoaded=false
ObjectiveTrackerFrame={GetRect=function() error("restricted") end}
''')
r.execute(p.with_name('SessionProbe.lua').read_text(encoding='utf-8'))
check = r.globals().SlashCmdList.DEVILFOREVERUICHECK
check('report')
assert r.globals().DevilForever_UIReviewDB is None
check('start')
check('combat')
check('party')
check('raid')
check('comparison')
check('pet')
data = r.globals().DevilForever_UIReviewDB.captures
assert set(data) == {'baseline'}
baseline = data.baseline
assert (baseline.preset, baseline.theme, baseline.nameplates) == ('uhd', 'stage', 2)
assert list(baseline.frames.action.rect.values()) == [32, 2092, 200, 60]
assert baseline.frames.group.found and not baseline.frames.system.found
for result in ('failed', 'no-free-window', 'in-progress', 'interrupted'):
    r.globals().DevilForever_ChatSetupDB.result = result
    check('chat')
    snapshot = data.chat.frames
    assert snapshot.public.found and not snapshot.group.found and not snapshot.system.found
r.globals().DevilForever_ChatSetupDB.result = 'created'
assert baseline.frames.objectives.found and baseline.frames.objectives.rect is None
for stage in ('quest', 'chat', 'theme'):
    check(stage)
r.execute('combat=true;groupSize=5;inRaid=false')
check('combat')
check('party')
r.execute('combat=false;groupSize=20;inRaid=true')
check('raid')
assert set(data) == {'baseline', 'quest', 'chat', 'combat', 'party', 'raid', 'theme'}
check('petabsent')
assert data.petabsent.petPresent is False
r.execute('local original=UnitExists;UnitExists=function() error("restricted") end; originalUnitExists=original')
check('petabsent')
assert data.petabsent.petPresent is False
r.execute('UnitExists=originalUnitExists')
r.execute('petPresent=true')
check('petabsent')
assert data.petabsent.petPresent is False
check('pet')
assert data.pet.frames.petActions.found and data.pet.frames.petCast.found
r.execute('fufLoaded=true')
check('comparison')
assert data.comparison is None
r.execute('pb4Loaded=false')
check('comparison')
assert data.comparison.fuf and not data.comparison.pitbull4
check('show combat')
assert any('action | 32.0,2092.0 200.0x60.0' in line for line in r.globals().lines.values())
check('start')
assert set(r.globals().DevilForever_UIReviewDB.captures) == {'baseline'}
assert set(r.globals().DevilForever_UIReviewDB.previous) == set(data)
assert r.globals().writes == 0
print('PASS Lua5.1 /dfcheck: ten stages, pet present/absent/restricted, mixed-variant guard, coordinates and reports, no frame or setting writes')

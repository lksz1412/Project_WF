"""Run the explicit slash entry through the installed Details position methods."""

from pathlib import Path
from lupa.lua51 import LuaRuntime


COLLECTION = Path(__file__).resolve().parents[2]
ADDON = COLLECTION / "AddOns/DevilForever_DetailsLayout"
NATIVE = COLLECTION / "AddOns/Details"


def source(path, first, last, signature):
    text = "\n".join(path.read_text(encoding="utf-8-sig").splitlines()[first - 1:last])
    assert signature in text
    return text


STUB = r'''
messages={};writes=0;combat=false;activePreset="uhd";pixelFactor=.35;uiScale=.64
screen={fhd={1920,1080},qhd={2560,1440},uhd={3840,2160}}
function InCombatLockdown() return combat end
function GetPhysicalScreenSize() return unpack(physicalScreen or screen[activePreset]) end
PixelUtil={GetPixelToUIUnitFactor=function() return pixelFactor end}
UIParent={GetScale=function() return uiScale end,GetEffectiveScale=function() return uiScale end}
DevilForever_Core={Profiles={Print=function(self,message) messages[#messages+1]=message end},
 Presets={GetActive=function() return activePreset,true end}}
DevilForever_Appearance={GetPixelUnit=function() return pixelFactor/uiScale end}
SlashCmdList={}
_detalhes_global={__profiles={mine={user="retained"}},sentinel="global saved data"}
_detalhes_database={active_profile="mine",sentinel="character saved data"}
Details={tabela_instancias={},__initialized=true,chat_tab_embed={enabled=false}}
Details222={WindowSnap={RefreshGeometry=function(instance) assert(not next(instance.snap)) end}}
local function frame()
 local f={parent=UIParent,scale=1,width=333,height=144,shown=true}
 function f:GetParent() return self.parent end
 function f:IsProtected() return self.protected end
 function f:SetScale(s) assert(type(s)=="number" and s>0 and s<math.huge);writes=writes+1;self.scale=s end
 function f:GetScale() return self.scale end
 function f:GetEffectiveScale() return self.scale*uiScale end
 function f:SetWidth(w) assert(type(w)=="number" and w>0 and w<math.huge);writes=writes+1;self.width=w end
 function f:SetHeight(h)
  assert(type(h)=="number" and h>0 and h<math.huge)
  writes=writes+1
  if self.throwOnce then self.throwOnce=nil;error("native resize failure") end
  self.height=h
 end
 function f:GetWidth() return self.width end
 function f:GetHeight() return self.height end
 function f:ClearAllPoints() writes=writes+1;self.point=nil end
 function f:SetPoint(...) writes=writes+1;self.point={...} end
 return f
end
function makeInstance(id)
 local i=setmetatable({meu_id=id,iniciada=true,mostrando="normal",window_scale=.9,
 libwindow={x=33+id,y=-77,point="TOPLEFT",scale=.9,user="keep"},
 posicao={normal={x=5,y=-8,w=333,h=144,user="keep"}},snap={},modo=id==2 and 4 or 2,
 current_raid_plugin=id==2 and "DETAILS_PLUGIN_TINY_THREAT" or nil,
 atributo=1,sub_atributo=1,row_info={height=29,font_size=19,user="keep"},skin="UserSkin",
 baseframe=frame(),rowframe=frame(),windowSwitchButton=frame(),windowBackgroundDisplay=frame()}, {__index=Details})
 Details.tabela_instancias[id]=i
 return i
end
function equal(a,b)
 if type(a)~=type(b) then return false end
 if type(a)=="number" and a~=a and b~=b then return true end
 if type(a)~="table" then return a==b end
 for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
 for k in pairs(b) do if a[k]==nil then return false end end
 return true
end
'''


def session(factor=.35):
    runtime = LuaRuntime(unpack_returned_tuples=True)
    runtime.execute(STUB)
    scope = runtime.globals()
    scope.pixelFactor = factor
    runtime.execute("local Core=DevilForever_Core\n" + source(COLLECTION / "AddOns/!DevilForever_Core/Core.lua", 20, 25, "function Core.CopyTable"))
    for first, last, signature in ((1163, 1165, "function Details:GetInstance"),
                                    (1447, 1449, "function Details:IsStarted")):
        runtime.execute(source(NATIVE / "classes/class_instance.lua", first, last, signature))
    runtime.execute(source(NATIVE / "functions/profiles.lua", 10, 16, "GetCurrentProfileName"))
    runtime.execute(source(NATIVE / "functions/profiles.lua", 82, 97, "function Details:GetProfile"))
    for first, last, signature in ((247, 287, "RestoreLibWindow"), (413, 452, "RestoreMainWindowPosition"),
                                    (476, 495, "CreatePositionTable"), (497, 516, "RestorePositionFromPositionTable")):
        runtime.execute("local end_window_spacement=0\n" + source(NATIVE / "core/windows.lua", first, last, signature))
    runtime.execute(source(NATIVE / "frames/window_main.lua", 8089, 8112, "SetWindowScale"))
    runtime.execute("makeInstance(1);makeInstance(2);makeInstance(3)")
    runtime.execute((ADDON / "Layout.lua").read_text(encoding="utf-8-sig"))
    return runtime


def snapshot(runtime):
    runtime.execute('''
before={}
for id=1,3 do
 local i=Details:GetInstance(id)
 before[id]={libwindow=DevilForever_Core.CopyTable(i.libwindow),normal=DevilForever_Core.CopyTable(i.posicao.normal),
 scale=i.window_scale,skin=i.skin,row_info=DevilForever_Core.CopyTable(i.row_info),modo=i.modo,
 plugin=i.current_raid_plugin,atributo=i.atributo,sub=i.sub_atributo}
end
savedGlobal=DevilForever_Core.CopyTable(_detalhes_global)
savedCharacter=DevilForever_Core.CopyTable(_detalhes_database)
''')


def assert_preserved(runtime, geometry=False):
    runtime.execute('''
for id=1,3 do
 local i=Details:GetInstance(id);local b=before[id]
 assert(i.skin==b.skin and equal(i.row_info,b.row_info) and i.modo==b.modo and i.current_raid_plugin==b.plugin)
 assert(i.atributo==b.atributo and i.sub_atributo==b.sub)
 if CHECK_GEOMETRY or id==3 then
  assert(equal(i.libwindow,b.libwindow) and equal(i.posicao.normal,b.normal) and equal(i.window_scale,b.scale))
 end
end
assert(equal(_detalhes_global,savedGlobal) and equal(_detalhes_database,savedCharacter))
'''.replace("CHECK_GEOMETRY", "true" if geometry else "false"))


def run():
    calls = 0
    for factor in (.35, .64):
        for preset in ("fhd", "qhd", "uhd"):
            runtime = session(factor)
            scope = runtime.globals()
            scope.activePreset = preset
            assert scope.writes == 0
            snapshot(runtime)
            scope.SlashCmdList.DFDETAILSLAYOUT("status")
            assert scope.writes == 0
            result = scope.SlashCmdList.DFDETAILSLAYOUT("apply")
            assert result[0] is True, result
            proposal = runtime.execute((COLLECTION.parent / f"References/codex-appearance/10/details-instances.fragment.{preset}.lua").read_text(encoding="utf-8"))
            for id in (1, 2):
                instance = scope.Details.tabela_instancias[id]
                value = proposal[id]
                assert abs(instance.window_scale - value.window_scale) < 1e-9
                assert abs(instance.libwindow.x - value.libwindow.x) < 1e-9
                assert abs(instance.libwindow.y - value.libwindow.y) < 1e-9
                assert instance.posicao.normal.w == value.posicao.normal.w
                assert instance.posicao.normal.h == value.posicao.normal.h
                assert instance.baseframe.point[1] == "TOPLEFT"
                assert abs(instance.baseframe.point[4] - value.libwindow.x / value.window_scale) < 1e-9
                assert abs(instance.baseframe.point[5] - value.libwindow.y / value.window_scale) < 1e-9
            assert_preserved(runtime)
            assert scope.SlashCmdList.DFDETAILSLAYOUT("apply " + preset)[0] is True
            assert scope.SlashCmdList.DFDETAILSLAYOUT("restore")[0] is True
            assert_preserved(runtime, geometry=True)
            calls += 1
    # Every rejected entry must leave both windows and saved variables intact.
    cases = ("combat=true", "Details.initializing=true", "Details.__initialized=false", "Details.AnnounceStartup=function() end",
             "Details.tabela_instancias[2]=nil", "Details:GetInstance(2).iniciada=false",
             'Details:GetInstance(2).mostrando="solo"', "Details:GetInstance(1).snap[1]=3",
             "Details.chat_tab_embed.enabled=true", "Details:GetInstance(2).baseframe.parent={}",
             "Details:GetInstance(1).baseframe.protected=true", "pixelFactor=0",
             '_detalhes_database.active_profile=""', '_detalhes_database.active_profile="missing"')
    for change in cases:
        runtime = session()
        runtime.execute(change)
        scope = runtime.globals()
        before = scope.writes
        result = scope.SlashCmdList.DFDETAILSLAYOUT("apply")
        assert result[0] is False, (change, result)
        assert scope.writes == before, change
    bounds_cases = (('activePreset="fhd"', "apply uhd"),
                    ('physicalScreen={3840,1080}', "apply uhd"),
                    ('physicalScreen={0,2160}', "apply"),
                    ('physicalScreen={math.huge,2160}', "apply"))
    geometry_cases = ("Details:GetInstance(1).posicao.normal.w=nil",
                      "Details:GetInstance(2).posicao.normal.h=0",
                      "Details:GetInstance(1).window_scale=0",
                      "Details:GetInstance(2).window_scale=0/0",
                      "Details:GetInstance(1).libwindow.scale=math.huge",
                      "Details:GetInstance(2).libwindow.scale=0",
                      "Details:GetInstance(1).libwindow.x=0/0",
                      "Details:GetInstance(2).libwindow.y=math.huge",
                      'Details:GetInstance(1).libwindow.point="INVALID"',
                      "Details:GetInstance(1).libwindow.x=nil;Details:GetInstance(1).posicao.normal.x=nil")
    for change, command in (*bounds_cases, *((change, "apply") for change in geometry_cases)):
        runtime = session()
        runtime.execute(change)
        snapshot(runtime)
        scope = runtime.globals()
        before = scope.writes
        assert scope.SlashCmdList.DFDETAILSLAYOUT(command)[0] is False, (change, command)
        assert scope.writes == before
        assert scope.SlashCmdList.DFDETAILSLAYOUT("restore")[0] is False
        assert scope.writes == before
        assert_preserved(runtime, geometry=True)
    runtime = session()
    runtime.execute("Details:GetInstance(1).posicao.normal.x=nil;Details:GetInstance(1).posicao.normal.y=nil;Details:GetInstance(1).libwindow.scale=nil")
    snapshot(runtime)
    scope = runtime.globals()
    assert scope.SlashCmdList.DFDETAILSLAYOUT("apply")[0] is True
    assert scope.SlashCmdList.DFDETAILSLAYOUT("restore")[0] is True
    assert_preserved(runtime, geometry=True)
    runtime = session()
    scope = runtime.globals()
    snapshot(runtime)
    runtime.execute("Details:GetInstance(1).libwindow.x=nil")
    snapshot(runtime)
    assert scope.SlashCmdList.DFDETAILSLAYOUT("apply fhd")[0] is True
    assert scope.SlashCmdList.DFDETAILSLAYOUT("restore")[0] is True
    assert_preserved(runtime, geometry=True)
    runtime = session()
    scope = runtime.globals()
    snapshot(runtime)
    runtime.execute("Details:GetInstance(2).baseframe.throwOnce=true")
    result = scope.SlashCmdList.DFDETAILSLAYOUT("apply")
    assert result[0] is False and "직전 위치 복원함" in result[1]
    assert_preserved(runtime, geometry=True)
    assert scope.SlashCmdList.DFDETAILSLAYOUT("apply")[0] is True
    runtime.execute('_detalhes_database.active_profile="changed";_detalhes_global.__profiles.changed={}')
    before = scope.writes
    assert scope.SlashCmdList.DFDETAILSLAYOUT("restore")[0] is False
    assert scope.writes == before
    print(f"PASS actual slash->native Details scale/position restore: {calls} preset/factor pairs; existing1/2 only; status/startup no writes; explicit apply; valid nil legacy/LibWindow fallback undo; profile/mode/style/SavedVariables/third window preserved; {len(cases)+len(bounds_cases)+len(geometry_cases)} refusal cases incl FHD/apply-UHD and missing original width; native error rollback")


if __name__ == "__main__":
    run()

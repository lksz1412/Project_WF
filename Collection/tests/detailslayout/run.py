"""Run the explicit slash entry through the installed Details position methods."""

from pathlib import Path
import lupa.lua51 as lupa
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
 Presets={GetActive=function() return activePreset,true end},db=coreDB or {}}
handlers={};timers={};created=0;raidCalls=0;skinCalls=0
function DevilForever_Core:On(event,fn) handlers[event]=handlers[event] or {};table.insert(handlers[event],fn) end
function DevilForever_Core:Off(event,fn)
 local list=handlers[event] or {}
 for i=#list,1,-1 do if list[i]==fn then table.remove(list,i) end end
end
function DevilForever_Core:DBTable(...)
 local t=self.db
 for i=1,select("#",...) do local k=select(i,...);t[k]=t[k] or {};t=t[k] end
 return t
end
C_Timer={After=function(seconds,fn) assert(seconds>0);timers[#timers+1]=fn end}
function fire(event) for _,fn in ipairs(handlers[event] or {}) do fn(event) end end
function runTimers(limit)
 local n=0
 while #timers>0 and n<(limit or 100) do local fn=table.remove(timers,1);fn();n=n+1 end
 return n
end
DevilForever_Appearance={GetPixelUnit=function() return pixelFactor/uiScale end}
SlashCmdList={}
_detalhes_global={__profiles={mine={user="retained"}},sentinel="global saved data"}
_detalhes_database={active_profile="mine",sentinel="character saved data"}
Details={tabela_instancias={},__initialized=true,chat_tab_embed={enabled=false}}
Details.RaidTables={NameTable={DETAILS_PLUGIN_TINY_THREAT={__enabled=true}},PluginsInUse={}}
function Details.RaidTables:EnableRaidMode(instance,name)
 assert(self.NameTable[name] and instance==Details.tabela_instancias[instance.meu_id])
 instance.modo=4;instance.current_raid_plugin=name;self.PluginsInUse[name]=instance.meu_id;raidCalls=raidCalls+1
end
function Details:CreateInstance(id)
 assert(id==true)
 local i=makeInstance(#Details.tabela_instancias+1)
 i.libwindow={};i.posicao={normal={x=0,y=0,w=320,h=130}};i.window_scale=1;i.modo=2;i.current_raid_plugin=nil
 i.skin=Details.standard_skin and Details.standard_skin.skin or Details.tabela_instancias[1].skin
 created=created+1
 return i
end
function Details:ChangeSkin(name) self.skin=name;skinCalls=skinCalls+1 end
textCalls=0
function Details:SetBarSettings(height) self.row_info.height=height;textCalls=textCalls+1 end
function Details:SetBarTextSettings(size) self.row_info.font_size=size;textCalls=textCalls+1 end
function Details:AttributeMenu(enabled,x,y,font,size) self.attribute_text=self.attribute_text or {};self.attribute_text.text_size=size;textCalls=textCalls+1 end
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


def to_py(value):
    """Plain Python copy of a Lua table (saved data carried to the next login)."""
    if lupa.lua_type(value) == "table":
        return {key: to_py(item) for key, item in value.items()}
    return value


def to_lua(runtime, value):
    if isinstance(value, dict):
        return runtime.table_from({key: to_lua(runtime, item) for key, item in value.items()})
    return value


def session(factor=.35, windows=3, core_db=None, preset=None):
    runtime = LuaRuntime(unpack_returned_tuples=True)
    if core_db is not None:
        runtime.globals().coreDB = to_lua(runtime, core_db)
    runtime.execute(STUB)
    if preset:
        runtime.globals().activePreset = preset
    scope = runtime.globals()
    scope.pixelFactor = factor
    runtime.execute("local Core=DevilForever_Core\n" + source(COLLECTION / "AddOns/!DevilForever_Core/Core.lua", 20, 25, "function Core.CopyTable"))
    for first, last, signature in ((1163, 1165, "function Details:GetInstance"),
                                    (1447, 1449, "function Details:IsStarted")):
        runtime.execute(source(NATIVE / "classes/class_instance.lua", first, last, signature))
    runtime.execute(source(NATIVE / "classes/class_instance.lua", 1192, 1194, "function Details:GetNumInstances"))
    runtime.execute(source(NATIVE / "functions/profiles.lua", 10, 16, "GetCurrentProfileName"))
    runtime.execute(source(NATIVE / "functions/profiles.lua", 82, 97, "function Details:GetProfile"))
    for first, last, signature in ((247, 287, "RestoreLibWindow"), (413, 452, "RestoreMainWindowPosition"),
                                    (476, 495, "CreatePositionTable"), (497, 516, "RestorePositionFromPositionTable")):
        runtime.execute("local end_window_spacement=0\n" + source(NATIVE / "core/windows.lua", first, last, signature))
    runtime.execute(source(NATIVE / "frames/window_main.lua", 8089, 8112, "SetWindowScale"))
    runtime.execute("for id=1,%d do makeInstance(id) end" % windows)
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


SCREEN = {"fhd": (1920, 1080), "qhd": (2560, 1440), "uhd": (3840, 2160)}


def check_placed(runtime, preset, ids=(1, 2)):
    """Each window body sits on its rect from Layout.lua in physical pixels at the native scale."""
    scope = runtime.globals()
    pixel = scope.pixelFactor / scope.uiScale
    rects = scope.DevilForever_DetailsLayout.layouts[preset]
    for id in ids:
        instance = scope.Details.tabela_instancias[id]
        rect = rects[id]
        assert abs(instance.window_scale - pixel) < 1e-9
        assert abs(instance.libwindow.x - rect[1] * pixel) < 1e-9
        assert abs(instance.libwindow.y + rect[2] * pixel) < 1e-9
        assert instance.posicao.normal.w == rect[3] and instance.posicao.normal.h == rect[4]
        assert instance.baseframe.point[1] == "TOPLEFT"
        assert abs(instance.baseframe.point[4] - rect[1]) < 1e-9
        assert abs(instance.baseframe.point[5] + rect[2]) < 1e-9


def check_stack():
    """Window 2 (threat) above window 1 (damage), same x and width, titles included, inside the screen."""
    layout = session().globals().DevilForever_DetailsLayout
    for preset, (width, height) in SCREEN.items():
        damage, threat = layout.layouts[preset][1], layout.layouts[preset][2]
        title = layout.titleSpace[preset]
        assert damage[1] == threat[1] and damage[3] == threat[3], preset
        assert threat[2] + threat[4] < damage[2] - title, (preset, "threat window ends above the damage title")
        assert threat[2] - title >= 0 and damage[2] + damage[4] <= height, preset
        assert damage[1] + damage[3] == width, (preset, "the stack reaches the screen's right edge")
        assert abs(damage[4] - threat[4]) <= 1, (preset, "free height split in two")
        sizes = layout.textSizes[preset]
        assert sizes.row > sizes.text and sizes.title == sizes.text, preset


def check_text(runtime, preset, ids=(1, 2)):
    scope = runtime.globals()
    sizes = scope.DevilForever_DetailsLayout.textSizes[preset]
    for id in ids:
        instance = scope.Details.tabela_instancias[id]
        assert (instance.row_info.height, instance.row_info.font_size, instance.attribute_text.text_size) == \
            (sizes.row, sizes.text, sizes.title), (preset, id)


def check_stack_move():
    """Windows made by an earlier first setup (mark without stack) move once, even after a drag; then stay."""
    for preset in ("fhd", "qhd", "uhd"):
        db = {"detailsLayout": {"profiles": {"mine": {"created": 2, "preset": preset}}}}
        runtime = first_login(preset, core_db=db, windows=2,
                              before='Details:GetInstance(1).libwindow.point="BOTTOMRIGHT"')
        scope = runtime.globals()
        scope.runTimers()
        assert scope.created == 0 and scope.raidCalls == 0, preset
        check_placed(runtime, preset)
        check_text(runtime, preset)
        mark = scope.DevilForever_Core.db.detailsLayout.profiles.mine
        assert mark.stack == 1 and mark.preset == preset, preset
        assert len(scope.messages) == 1 and "옮김" in scope.messages[1], list(scope.messages.values())
        later = first_login(preset, core_db=to_py(scope.DevilForever_Core.db), windows=2,
                            before="Details:GetInstance(1).libwindow.x=999")
        later.globals().runTimers()
        assert later.globals().writes == 0 and later.globals().textCalls == 0, preset
        assert later.globals().Details.tabela_instancias[1].libwindow.x == 999
    # a profile with the player's own windows (skipped) is never moved
    runtime = first_login("uhd", core_db={"detailsLayout": {"profiles": {"mine": {"skipped": True}}}}, windows=2)
    runtime.globals().runTimers()
    assert runtime.globals().writes == 0 and runtime.globals().textCalls == 0
    # window 2 deleted since: nothing to stack, marked done
    runtime = first_login("qhd", core_db={"detailsLayout": {"profiles": {"mine": {"created": 2, "preset": "qhd"}}}}, windows=1)
    runtime.globals().runTimers()
    assert runtime.globals().writes == 0 and setup_mark(runtime.globals()).stack == 1
    return 5


def setup_mark(scope):
    marks = scope.DevilForever_Core.db.detailsLayout
    return marks and marks.profiles and marks.profiles.mine


def first_login(preset, core_db=None, windows=1, before=None):
    runtime = session(windows=windows, core_db=core_db, preset=preset)
    if before:
        runtime.execute(before)
    runtime.globals().fire("PLAYER_ENTERING_WORLD")
    runtime.globals().fire("PLAYER_ENTERING_WORLD")
    return runtime


def check_first_setup():
    cases = 0
    for preset in ("fhd", "qhd", "uhd"):
        runtime = first_login(preset, before='Details.standard_skin={skin="StandardSkin"}')
        scope = runtime.globals()
        assert len(scope.timers) == 1, "one start for two PLAYER_ENTERING_WORLD"
        assert scope.writes == 0, "nothing before the timer"
        scope.runTimers()
        details = scope.Details
        assert scope.created == 1 and details.GetNumInstances(details) == 2
        one, two = details.tabela_instancias[1], details.tabela_instancias[2]
        assert two.current_raid_plugin == "DETAILS_PLUGIN_TINY_THREAT" and two.modo == 4 and scope.raidCalls == 1
        assert two.skin == one.skin == "UserSkin" and scope.skinCalls == 1, "window 2 takes window 1's skin"
        assert one.modo == 2 and one.current_raid_plugin is None and one.atributo == 1 and one.sub_atributo == 1, \
            "window 1 stays on damage done"
        check_placed(runtime, preset)
        check_text(runtime, preset)
        mark = scope.DevilForever_Core.db.detailsLayout.profiles.mine
        assert mark.created == 2 and mark.preset == preset and mark.stack == 1 and mark.skipped is None
        assert len(scope.messages) == 1 and "Tiny Threat" in scope.messages[1], list(scope.messages.values())
        # Same session: nothing more.
        writes = scope.writes
        assert scope.DevilForever_DetailsLayout.FirstSetup(scope.DevilForever_DetailsLayout) is True  # done, no message
        assert scope.writes == writes and scope.created == 1
        # Next login with the same saved data, after the player changed both windows.
        again = first_login(preset, core_db=to_py(scope.DevilForever_Core.db), windows=2,
                            before='Details:GetInstance(2).current_raid_plugin=nil;Details:GetInstance(1).libwindow.x=999')
        later = again.globals()
        later.runTimers()
        assert later.writes == 0 and later.created == 0 and later.raidCalls == 0
        assert later.Details.tabela_instancias[1].libwindow.x == 999 and len(later.messages) == 0
        cases += 2
    # A profile whose windows the player made: marked, never touched.
    for count in (2, 3):
        runtime = first_login("qhd", windows=count)
        scope = runtime.globals()
        runtime.execute("before1=DevilForever_Core.CopyTable(Details:GetInstance(1).libwindow)")
        scope.runTimers()
        assert scope.writes == 0 and scope.created == 0 and scope.raidCalls == 0
        assert scope.DevilForever_Core.db.detailsLayout.profiles.mine.skipped is True
        assert runtime.execute("return equal(before1, Details:GetInstance(1).libwindow)")
        cases += 1
    # Not ready yet: retried without writes, set up once ready.
    runtime = first_login("fhd", before="Details.__initialized=false")
    scope = runtime.globals()
    scope.runTimers(3)
    assert scope.created == 0 and scope.writes == 0 and len(scope.timers) == 1
    runtime.execute("Details.__initialized=true")
    scope.runTimers()
    assert scope.created == 1
    # Combat: waits for the end of combat, then sets up.
    runtime = first_login("uhd", before="combat=true")
    scope = runtime.globals()
    scope.runTimers()
    assert scope.created == 0 and len(scope.timers) == 0 and len(scope.handlers.PLAYER_REGEN_ENABLED) == 1
    runtime.execute("combat=false")
    scope.fire("PLAYER_REGEN_ENABLED")
    assert scope.created == 1 and len(scope.handlers.PLAYER_REGEN_ENABLED) == 0
    # Tiny Threat missing, disabled or in use, window 1 not free-standing: no window, no mark, stops at the limit.
    for change in ("Details.RaidTables.NameTable.DETAILS_PLUGIN_TINY_THREAT=nil",
                   "Details.RaidTables.NameTable.DETAILS_PLUGIN_TINY_THREAT.__enabled=false",
                   "Details.RaidTables.PluginsInUse.DETAILS_PLUGIN_TINY_THREAT=1",
                   'Details:GetInstance(1).mostrando="solo"', "Details.chat_tab_embed.enabled=true"):
        runtime = first_login("fhd", before=change)
        scope = runtime.globals()
        ran = scope.runTimers(200)
        assert ran == 30 and len(scope.timers) == 0, (change, ran)
        assert scope.created == 0 and scope.writes == 0, change
        assert setup_mark(scope) is None, change
        cases += 1
    # No active preset: no window, tried again at the next login.
    runtime = first_login(None, before="activePreset=nil")
    scope = runtime.globals()
    scope.runTimers()
    assert scope.created == 0 and setup_mark(scope) is None
    return cases + 3


def run():
    check_stack()
    setup_cases = check_first_setup() + check_stack_move()
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
            check_placed(runtime, preset)
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
    print(f"PASS first setup: window 2 + Tiny Threat on a window-1-only profile per preset, skin of window 1, window 1 kept on damage done, threat-over-damage stack per preset with text sizes; earlier setups moved once; second login no writes; player-made windows marked and untouched; retries/combat/Tiny Threat missing ({setup_cases} cases)")
    print(f"PASS actual slash->native Details scale/position restore: {calls} preset/factor pairs; existing1/2 only; status/startup no writes; explicit apply; valid nil legacy/LibWindow fallback undo; profile/mode/style/SavedVariables/third window preserved; {len(cases)+len(bounds_cases)+len(geometry_cases)} refusal cases incl FHD/apply-UHD and missing original width; native error rollback")


if __name__ == "__main__":
    run()

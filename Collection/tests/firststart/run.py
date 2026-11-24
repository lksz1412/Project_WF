"""First-start defaults of the collection that sit across Core and other addons.

Usage:  python3 -I Collection/tests/firststart/run.py

Reuses the Core test harness (Collection/tests/core/run.py: lupa Lua 5.1
runtime, client stubs, Core files in TOC order) for the SexyMap appearance
fragments, and reads shipped addon files as text for the Grid2 first-start
templates and the nameplate addon's TOC. The native SexyMap login code also
runs against frame stubs; this does not emulate the game client.
"""

import os
import re
import runpy
import sys
import traceback

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ADDONS = os.path.join(REPO, "Collection", "AddOns")
FIXTURE_PRESETS = os.path.join(HERE, "fixtures", "Presets_Screens.lua")

core = runpy.run_path(os.path.join(REPO, "Collection", "tests", "core", "run.py"), run_name="core_harness")
CoreSession, eq, ADDON, SEXYMAP_INIT = core["Session"], core["eq"], core["ADDON"], core["SEXYMAP_INIT"]
lupa = core["lupa"]


class Session(CoreSession):
    def run_file(self, path):
        if path.replace("\\", "/").endswith("/Defaults/SexyMap.lua"):
            self.lua.execute("""
              local create=CreateFrame
              local function scale(self,value) self.scale=value;self.scaleCalls=(rawget(self,'scaleCalls') or 0)+1 end
              function CreateFrame(...)
                local frame=create(...)
                frame.SetScale=scale
                frame.GetScale=function(self) return rawget(self,'scale') or 1 end
                return frame
              end
            """)
        return super().run_file(path)

# A 1920x1080 screen at UI scale 0.64 (UIParent 768 high): Presets picks "fhd".
UI_SCALE = 0.64
PIXEL_FACTOR = 768 / 1080
SCREEN = {
    "UIParent": {"GetEffectiveScale": lambda self: UI_SCALE, "GetHeight": lambda self: 768},
    "PixelUtil": {"GetPixelToUIUnitFactor": lambda: PIXEL_FACTOR},
}
APPEARANCE_CORE = {"shape", "point", "relpoint", "x", "y", "scale"}


# SexyMap's Borders module setup at its ADDON_LOADED (Borders.lua:827-848): the
# borders table is made only when missing. A test stand-in run after SEXYMAP_INIT.
BORDERS_INIT = r"""
local key = UnitNameUnmodified("player") .. "-" .. GetRealmName()
local p = SexyMap2DB[key]
if type(p) == "string" then p = SexyMap2DB.global end
if type(p.borders) ~= "table" then
  p.borders = {hideBlizzard = true, borders = {}, applyPreset = "Blue Rune Circles",
    backdrop = {scale = 1, show = false, textureColor = {}, borderColor = {}, settings = {
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      insets = {left = 4, top = 4, right = 4, bottom = 4}, edgeSize = 16, tile = false}}}
end
"""
SV_CARRIED = ("SexyMap2DB", "DevilForever_CoreDB", "DevilForever_ProfilesDB", "Grid2DB", "PitBull4DB",
              "ForeverUnitFramesDB")


def carry(s, **changes):
    out = {n: s.sv(n) for n in SV_CARRIED if s.sv(n) is not None}
    out.update(changes)
    return out


def sexymap_session(saved=None, player=None, presets=True, login=True):
    """Core with the test presets, SexyMap's own first-load setup after Core's handler, then login."""
    s = Session(registry="generated", extra_files=(), saved=saved, player=player, globals_=SCREEN,
                preset_files=(FIXTURE_PRESETS,) if presets else ())
    s.lua.execute("function GetPhysicalScreenSize() return 1920, 1080 end")  # read by Presets at Core's ready step
    s.load_addon(ADDON)
    s.g.TEST_loaded["SexyMap"] = True
    s.fire("ADDON_LOADED", "SexyMap")
    s.lua.execute(SEXYMAP_INIT)
    s.lua.execute(BORDERS_INIT)
    if login:
        s.fire("PLAYER_LOGIN")
        s.fire("PLAYER_ENTERING_WORLD", True, False)
    return s


def fragment_states(s):
    states = core["to_py"](s.core.Presets.GetFragmentStatus(s.core.Presets))
    return {k: v["state"] for k, v in states.items() if str(v.get("key", "")).startswith("SexyMap2DB")}


def prints(s):
    return list(core["to_py"](s.g.TEST_prints).values())


def installed():
    """SV state of an install made before the appearance fragment: Hero's profile, Core's applied record."""
    return carry(sexymap_session(presets=False))


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


@case
def sexymap_appearance_fresh_install_from_active_preset():
    s = sexymap_session()
    eq(s.sv("DevilForever_CoreDB")["preset"]["active"], "fhd", "1080 high screen: fhd preset")
    p = s.sv("SexyMap2DB")["Hero-Realm"]
    effective = 192 / 140
    pixel = PIXEL_FACTOR / UI_SCALE
    eq({k: p["core"][k] for k in ("shape", "point", "relpoint")}, {"shape": 130871, "point": "TOPLEFT",
                                                                 "relpoint": "TOPLEFT"}, "shape and anchor")
    eq([round(p["core"][k], 6) for k in ("x", "y", "scale")],
       [round(1292 / effective, 6), round(-860 / effective, 6), round(effective * pixel, 6)], "fhd position and scale")
    eq((p["borders"]["hideBlizzard"], p["borders"]["applyPreset"]), (True, False), "borders merged into SexyMap's table")
    eq((p["core"]["rightClickToConfig"], p["buttons"]["visibilitySettings"]["TimeManagerClockButton"]),
       (False, "never"), "functional defaults still written")
    eq(fragment_states(s), {"fhd|1": "written"}, "the active preset's SexyMap fragment written")
    eq(s.sv("DevilForever_CoreDB")["preset"]["fragments"]["fhd"], {"SexyMap2DB@root:Hero-Realm": 1},
       "recorded per character profile key")
    presets = s.core.Presets
    eq({n: [f["profileKey"] for f in core["to_py"](presets.Get(presets, n))["fragments"].values()]
        for n in ("fhd", "qhd", "uhd")},
       {n: ["Hero-Realm"] for n in ("fhd", "qhd", "uhd")}, "every registered preset carries its own SexyMap fragment")
    eq(s.errors(), [], "no errors")


@case
def sexymap_existing_profile_without_appearance_unchanged_and_noticed():
    saved = installed()
    before = saved["SexyMap2DB"]
    eq(sorted(APPEARANCE_CORE & set(before["Hero-Realm"]["core"])), ["shape"], "premise: no position or scale")
    s = sexymap_session(saved=saved)
    eq(s.sv("SexyMap2DB"), before, "existing profile without point/scale keys left as it is")
    eq(s.status("SexyMap")["targets"]["SexyMap2DB"]["state"], "already", "Core's applied record, as a real install")
    eq(fragment_states(s), {"fhd|1": "kept"}, "appearance fragment kept back for an existing profile")
    notice = [l for l in prints(s) if "/dfp preset fhd" in l]
    eq(len(notice), 1, "one notice line with the /dfp preset hint")


@case
def sexymap_second_character_gets_its_own_appearance():
    first = sexymap_session()
    hero = first.sv("SexyMap2DB")["Hero-Realm"]
    s = sexymap_session(saved=carry(first), player={"name": "Alt"})
    db = s.sv("SexyMap2DB")
    eq(db["Hero-Realm"], hero, "the first character's profile untouched")
    alt = db["Alt-Realm"]
    eq((alt["core"]["shape"], alt["core"]["point"], alt["core"]["autoZoom"]), (130871, "TOPLEFT", 5),
       "appearance merged into the profile SexyMap made (its own keys kept)")
    eq(fragment_states(s), {"fhd|1": "written"}, "fresh per profile key")
    eq(sorted(s.sv("DevilForever_CoreDB")["preset"]["fragments"]["fhd"]),
       ["SexyMap2DB@root:Alt-Realm", "SexyMap2DB@root:Hero-Realm"], "one record per character")
    eq(s.errors(), [], "no errors")


def request_preset(saved, name="fhd", player=None):
    """A session that asks /dfp preset <name>, /dfp go; returns the saved variables for the next load."""
    s = sexymap_session(saved=saved, player=player)
    dfp = core["dfp"]
    dfp(s, "preset " + name)
    dfp(s, "go")
    return carry(s)


@case
def sexymap_request_keeps_global_choice():
    saved = installed()
    glob = {"core": dict(saved["SexyMap2DB"]["Hero-Realm"]["core"])}
    saved["SexyMap2DB"] = {"Hero-Realm": "global", "global": glob}
    nxt = request_preset(saved)
    nxt["SexyMap2DB"] = {"Hero-Realm": "global", "global": glob}
    s = sexymap_session(saved=nxt)
    db = s.sv("SexyMap2DB")
    eq(db["Hero-Realm"], "global", "the global choice is not replaced")
    eq(sorted(APPEARANCE_CORE - {"shape"} & set(db["global"]["core"])), [], "nothing written into the global profile")
    eq(fragment_states(s), {"fhd|1": "skipped"}, "requested fragment skipped")
    eq(s.errors(), [], "no errors (SexyMap's own core defaults intact)")


@case
def sexymap_request_into_profile_made_by_sexymap():
    first = sexymap_session(presets=False)
    saved = carry(first)
    nxt = request_preset(saved, player={"name": "Alt"})
    eq("Alt-Realm" in nxt["SexyMap2DB"], True, "premise: the asking session made Alt's profile")
    nxt["SexyMap2DB"].pop("Alt-Realm")
    s = sexymap_session(saved=nxt, player={"name": "Alt"})
    alt = s.sv("SexyMap2DB")["Alt-Realm"]
    eq((alt["core"]["autoZoom"], alt["core"]["shape"], alt["core"]["point"]), (5, 130871, "TOPLEFT"),
       "nil profile at the request load: SexyMap's own core made, then appearance merged")
    eq(fragment_states(s), {"fhd|1": "written"}, "requested fragment written")


@case
def sexymap_without_presets_registers_no_fragment():
    s = sexymap_session(presets=False)
    p = s.sv("SexyMap2DB")["Hero-Realm"]
    eq(sorted(APPEARANCE_CORE - {"shape"} & set(p["core"])), [], "no appearance without a registered preset")
    eq(fragment_states(s), {}, "no SexyMap fragment")
    eq(s.errors(), [], "no errors")


MINIMAP_NATIVE = r"""
tinsert=table.insert
TEST_ui=1
UIParent={GetEffectiveScale=function() return TEST_ui end,GetHeight=function() return 768/TEST_ui end}
local function noop() end
local methods={}
function methods:SetScale(v) self.scale=v end
function methods:SetPoint(p,rel,rp,x,y)
 assert(type(p)=='string','Invalid region point '..tostring(p))
 self.point={p,rel,rp,x,y};self.pointCalls=(rawget(self,'pointCalls') or 0)+1
end
function methods:GetWidth() return rawget(self,'width') or 180 end
function methods:SetSize(w,h) self.width=w;self.height=h end
function methods:GetFrameStrata() return "LOW" end
function methods:GetFrameLevel() return 2 end
function methods:GetZoom() return 0 end
function methods:CreateTexture() return setmetatable({}, {__index=methods}) end
methods.CreateFontString=methods.CreateTexture
setmetatable(methods,{__index=function() return noop end})
local original=CreateFrame
function CreateFrame(...) return setmetatable(original(...),{__index=methods}) end
for _,name in ipairs({"Minimap","MinimapZoomIn","MinimapZoomOut","MinimapCluster","MinimapBackdrop",
 "MinimapNorthTag","MinimapCompassTexture","MinimapBorderTop"}) do _G[name]=CreateFrame("Frame") end
Minimap.ZoomIn=CreateFrame('Frame');Minimap.ZoomOut=CreateFrame('Frame')
local oldLib=LibStub
LibStub=function(name,...)
 if name=="AceConfigRegistry-3.0" then return {RegisterOptionsTable=noop} end
 if name=="AceConfigDialog-3.0" then return {AddToBlizOptions=function() return nil,1 end} end
 return oldLib(name,...)
end
function hooksecurefunc(object,key,callback)
 local original=object[key]
 object[key]=function(...) local result=original(...);callback(...);return result end
end
TEST_mapTimers={}
C_Timer={After=function(delay,fn) if delay==0 then TEST_mapTimers[#TEST_mapTimers+1]=fn end end}
function drainMap() local t=TEST_mapTimers;TEST_mapTimers={};for _,fn in ipairs(t) do fn() end end
SM={L=setmetatable({}, {__index=function(_,key) if key~="OnInitialize" then return key end end}),API={isVanilla=true}}
SM.Borders={OnInitialize=function(_,profile)
 if not profile.borders then profile.borders={borders={},applyPreset="Blue Rune Circles"} end
 NATIVE_core=profile.core;NATIVE_borders=profile.borders;NATIVE_list=profile.borders.borders
 end,OnEnable=function()
 NATIVE_borderCount=#NATIVE_list;NATIVE_applyPreset=NATIVE_borders.applyPreset
 end}
"""


def native_minimap_session(height, saved=None, native="SexyMap_Classic.lua", experience=False):
    screen={"UIParent":{"GetEffectiveScale":lambda self:1,"GetHeight":lambda self:768},
            "PixelUtil":{"GetPixelToUIUnitFactor":lambda:768/height}}
    s = Session(registry="generated", extra_files=(), saved=saved, globals_=screen, preset_files=(FIXTURE_PRESETS,))
    s.lua.execute(MINIMAP_NATIVE)
    s.lua.execute("PixelUtil={GetPixelToUIUnitFactor=function() return 768/"+str(height)+" end}; "
                  "function GetPhysicalScreenSize() return 3840,"+str(height)+" end")
    s.load_addon(ADDON)
    if experience:
        s.lua.execute("""
          XP={db={global={minimap={angle=225,hide=true}}}}
          local old=LibStub
          LibStub=function(name,...)
            if name=='AceAddon-3.0' then return {NewAddon=function() return XP end,GetAddon=function(_,name) if name=='ExperienceForever' then return XP end end} end
            if name=='LibSharedMedia-3.0' then return {Register=function() end} end
            return old(name,...)
          end
        """)
        with open(os.path.join(ADDONS,"ExperienceForever","ExperienceForever.lua"),"rb") as fh:
            s.lua.eval("loadstring")(fh.read(),b"@ExperienceForever.lua")()
        s.lua.execute("XP.MinimapButton=CreateFrame('Button');XP.MinimapButton.hidden=true;XP:UpdateMinimapButtonPosition()")
    with open(os.path.join(ADDONS,"SexyMap",native),"rb") as fh:
        fn=s.lua.eval("loadstring")(fh.read(),("@"+native).encode())
    (fn[0] if isinstance(fn,tuple) else fn)("SexyMap",s.g.SM)
    s.g.TEST_loaded["SexyMap"]=True
    s.fire("ADDON_LOADED","SexyMap")
    if saved is None:
        s.lua.execute('NATIVE_list[1]={name="Rune 1"};NATIVE_list[2]={name="Rune 2"};NATIVE_list[3]={name="Fade"}')
    s.lua.execute("TEST_ui=.64")
    s.fire("PLAYER_LOGIN")
    s.lua.execute("Minimap:SetSize(140,140)")
    if experience:
        s.lua.execute("assert(XP.MinimapButton.pointCalls==1,'XP position must wait for world entry')")
    s.fire("PLAYER_ENTERING_WORLD",True,False)
    s.lua.execute("drainMap()")
    return s


@case
def sexymap_mainline_scale_hook_bypassed_and_xp_button_refreshed_once():
    with open(os.path.join(ADDONS,"SexyMap","SexyMap.toc"),encoding="utf-8") as fh:
        eq("SexyMap.lua [AllowLoadGameType mainline]" in fh.read(),True,"mainline TOC path")
    for native in ("SexyMap.lua","SexyMap_Classic.lua"):
        s=native_minimap_session(2160,native=native,experience=True)
        p=s.g.XP.MinimapButton.point
        eq(round((p[4]**2+p[5]**2)**.5,6),75,"native XP radius follows stable140 width")
        eq((s.g.XP.MinimapButton.pointCalls,s.g.XP.db["global"].minimap.angle,s.g.XP.MinimapButton.hidden),
           (2,225,True),"initial XP placement + one correction; angle/hidden unchanged")
        if native=="SexyMap.lua":
            s.lua.execute("local ok,why=pcall(function() Minimap:SetScale(Minimap:GetScale()) end);assert(not ok and why:find('Invalid region point'))")
        before=s.g.Minimap.scaleCalls
        for ui in (1,.8,.64):
            s.g.TEST_ui=ui
            s.fire("UI_SCALE_CHANGED");s.lua.execute("drainMap()")
            eq(s.g.Minimap.scaleCalls,before+1,"one base scale write per changed scale")
            before=s.g.Minimap.scaleCalls
        s.fire("DISPLAY_SIZE_CHANGED");s.lua.execute("drainMap()")
        eq(s.g.Minimap.scaleCalls,before,"same scale: no repeat scale write")
        eq(s.g.XP.MinimapButton.pointCalls,2,"same width: no repeat XP position write")
        s.lua.execute("NATIVE_core.x=NATIVE_core.x+1;TEST_ui=1")
        s.fire("UI_SCALE_CHANGED");s.lua.execute("drainMap()")
        eq(s.g.Minimap.scaleCalls,before,"manual unmanaged map: no scale write")
        eq(s.g.XP.MinimapButton.pointCalls,2,"manual map: no XP write")
        eq(s.errors(),[],"native mainline/Classic apply continues after scale")


@case
def sexymap_native_login_scale_border_clear_and_reload():
    for height,x,y,side in ((1080,1292,860,192),(1440,1720,1186,224),(2160,2596,1820,304)):
        s=native_minimap_session(height)
        for attempt in range(2):
            p=s.sv("SexyMap2DB")["Hero-Realm"]["core"]
            factor=768/height
            scale=s.g.Minimap.scale
            for got,want in ((p["x"]*scale*.64/factor,x),(-p["y"]*scale*.64/factor,y),(140*scale*.64/factor,side)):
                eq(round(got,6),round(want,6),"native physical pixels")
            eq((s.g.NATIVE_borderCount,s.g.NATIVE_applyPreset),(0,False),"Rune list cleared before native OnEnable")
            eq(s.lua.eval("NATIVE_core==SexyMap2DB['Hero-Realm'].core and NATIVE_list==SexyMap2DB['Hero-Realm'].borders.borders"),True,"native references retained")
            eq(s.errors(),[],"native login errors")
            if attempt==0:
                s=native_minimap_session(height,saved=carry(s))
        for ui in (1,.8,.64):
            s.g.TEST_ui=ui
            s.fire("UI_SCALE_CHANGED")
            s.lua.execute("drainMap()")
            p=s.sv("SexyMap2DB")["Hero-Realm"]["core"]
            scale=s.g.Minimap.scale
            for got,want in ((p["x"]*scale*ui/factor,x),(-p["y"]*scale*ui/factor,y),(140*scale*ui/factor,side)):
                eq(round(got,6),round(want,6),"live UI scale event physical pixels")
        s.lua.execute("NATIVE_core.x=NATIVE_core.x+10;TEST_ui=1")
        old=s.g.Minimap.scale
        s.fire("UI_SCALE_CHANGED")
        s.lua.execute("drainMap()")
        eq(s.g.Minimap.scale,old,"manual geometry releases scale management")


@case
def sexymap_requested_preset_clears_numeric_borders_in_place():
    saved=installed()
    saved["SexyMap2DB"]["Hero-Realm"]["borders"]={"borders":{1:{"name":"Rune 1"},2:{"name":"Rune 2"},3:{"name":"Fade"}},
                                                       "applyPreset":False}
    s=sexymap_session(saved=request_preset(saved),login=False)
    s.lua.execute("held=SexyMap2DB['Hero-Realm'].borders.borders;heldCore=SexyMap2DB['Hero-Realm'].core")
    s.fire("PLAYER_LOGIN")
    eq(s.lua.eval("#held==0 and held==SexyMap2DB['Hero-Realm'].borders.borders and heldCore==SexyMap2DB['Hero-Realm'].core"),
       True,"requested existing profile: numeric list empty and native references kept before setup")
    eq(s.errors(),[],"no errors")


# Party frames (Party.lua): Grid2 draws party and raid, the unit-frame party is a switch ---------

GRID2_PARTY = {"party": "By Group", "arena": "By Group", "FrameDisplay": "Grouped"}
GRID2_HIDDEN = {"party": "None", "arena": "None", "FrameDisplay": "Raid"}   # an earlier package's unit-frame owner
PB4_GROUP_NAMES = ("파티", "파티원 대상", "파티원 소환수")
# C_Timer.After collected and run by the test; a FUF stand-in whose "/fuf set party ..." commands
# store the value in the saved unit profile at once (FUF's own save follows a change by 0.5 s) while
# TEST_fufReady is true (FUF's Commands.IsReady), and nothing otherwise.
PARTY_STUBS = r"""
TEST_timers = {}
C_Timer = {After = function(delay, fn) TEST_timers[#TEST_timers + 1] = {delay, fn} end}
function TEST_runTimers()
  local due = TEST_timers
  TEST_timers = {}
  for _, t in ipairs(due) do t[2]() end
  return #due
end
TEST_fuf, TEST_fufReady = {}, true
SlashCmdList.FOREVERUNITFRAMES = function(msg)
  TEST_fuf[#TEST_fuf + 1] = msg
  if not TEST_fufReady then return end
  local db = ForeverUnitFramesDB
  db.profiles = db.profiles or {}
  db.profiles.Default = db.profiles.Default or {}
  local party = db.profiles.Default.party or {}
  db.profiles.Default.party = party
  if msg == "set party enabled off" then party.enabled = false
  elseif msg == "set party enabled on" then party.enabled = true
  elseif msg == "set party hideBlizzardFrame on" then party.hideBlizzardFrame = true end
end
function UnitFullName() return TEST_player.name, TEST_player.realm end
UnitName = UnitNameUnmodified
"""
FUF_AT_LOAD = r"""
if type(ForeverUnitFramesDB) ~= "table" then ForeverUnitFramesDB = {profiles = {Default = {}}, active = {}} end
"""


def party_session(after, saved=None, player=None, ready=True):
    s = Session(registry="generated", extra_files=(), saved=saved, player=player)
    s.lua.execute(PARTY_STUBS)
    s.g.TEST_fufReady = ready
    s.load_addon(ADDON)
    for name in after:
        s.load_addon(name)
        if name == "ForeverUnitFrames":
            s.lua.execute(FUF_AT_LOAD)  # FUF makes its saved variable at its own ADDON_LOADED
    s.fire("PLAYER_LOGIN")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    return s


def run_timers(s):
    return s.g.TEST_runTimers()


def grid2_party(s, profile="Hero - Realm"):
    p = s.sv("Grid2DB")["namespaces"]["Grid2Layout"]["profiles"][profile]
    return {"party": p["layouts"]["party"], "arena": p["layouts"]["arena"], "FrameDisplay": p["FrameDisplay"]}


def set_grid2(saved, values, profile="Hero - Realm"):
    p = saved["Grid2DB"]["namespaces"]["Grid2Layout"]["profiles"][profile]
    p["layouts"]["party"], p["layouts"]["arena"], p["FrameDisplay"] = values["party"], values["arena"], values["FrameDisplay"]


def pb4_groups(saved_or_session, profile="Default"):
    db = saved_or_session["PitBull4DB"] if isinstance(saved_or_session, dict) else saved_or_session.sv("PitBull4DB")
    return db["profiles"][profile]["groups"]


def pb4_enabled(s, profile="Default"):
    groups = pb4_groups(s, profile)
    return {n: groups[n].get("enabled") for n in PB4_GROUP_NAMES}


def fuf_calls(s):
    return list(core["to_py"](s.g.TEST_fuf).values())


def party_state(s):
    return core["to_py"](s.core.Party.GetState(s.core.Party))


def auto_lines(s):
    return [l for l in prints(s) if "파티" in l]


PB4_OFF = {n: False for n in PB4_GROUP_NAMES}
PB4_ON = {n: True for n in PB4_GROUP_NAMES}


@case
def party_fresh_install_unit_frames_and_grid2_both_draw_party():
    for order in (["Grid2", "PitBull4"], ["PitBull4", "Grid2"]):
        s = party_session(order)
        eq((grid2_party(s), pb4_enabled(s)), (GRID2_PARTY, PB4_ON), "%s first: Grid2 party and PitBull4 party groups" % order[0])
        groups = pb4_groups(s)
        eq([groups[n]["show_when"]["raid"] for n in PB4_GROUP_NAMES], [True] * 3, "PitBull4 party groups shown in a raid too")
        eq("use_pet_header" in groups["파티원 소환수"], False, "pet group in PitBull4's gap mode (each pet beside its owner)")
        eq(s.sv("Grid2DB")["namespaces"]["Grid2Layout"]["profiles"]["Hero - Realm"]["minimapIcon"], {"hide": True},
           "Grid2LDB minimap button off on a new profile")
        eq((s.sv("DevilForever_CoreDB") or {}).get("party"), None, "nothing recorded at login")
        eq(s.errors(), [], "no errors")
    fuf = party_session(["ForeverUnitFrames", "Grid2"])
    eq(run_timers(fuf), 0, "FUF first install: no delayed step")
    eq((grid2_party(fuf), fuf_calls(fuf)), (GRID2_PARTY, []), "FUF keeps its party, Grid2 draws party and raid")


@case
def party_login_never_reapplies_party_groups():
    first = party_session(["Grid2", "PitBull4"])
    saved = carry(first)
    groups = pb4_groups(saved)
    groups["파티원 대상"]["enabled"] = False      # the user switched one group off in PitBull4
    groups["파티원 소환수"]["enabled"] = False
    set_grid2(saved, GRID2_HIDDEN)                 # and Grid2's party off in Grid2
    saved["DevilForever_CoreDB"].setdefault("party", {})["owner"] = {"PitBull4/Default": "grid2"}   # an earlier record
    s = party_session(["Grid2", "PitBull4"], saved=saved)
    eq((s.sv("Grid2DB"), s.sv("PitBull4DB")), (saved["Grid2DB"], saved["PitBull4DB"]), "login writes nothing")
    eq(auto_lines(s), [], "no chat line at login")
    fuf = party_session(["ForeverUnitFrames", "Grid2"])
    fsaved = carry(fuf)
    fsaved["ForeverUnitFramesDB"]["profiles"]["Default"]["party"] = {"enabled": False}
    again = party_session(["ForeverUnitFrames", "Grid2"], saved=fsaved)
    run_timers(again)
    eq((fuf_calls(again), again.sv("ForeverUnitFramesDB")["profiles"]["Default"]["party"]), ([], {"enabled": False}),
       "FUF: no command at login")


@case
def party_command_switches_unit_frame_party_and_counts_changes():
    first = party_session(["Grid2", "PitBull4"])
    saved = carry(first)
    set_grid2(saved, GRID2_HIDDEN)
    s = party_session(["Grid2", "PitBull4"], saved=saved)
    lines = core["dfp"](s, "party off")
    eq(pb4_enabled(s), PB4_OFF, "off: every party group off")
    eq(core["has_line"](lines, "PitBull4 Default: 파티 그룹 3개 끔"), True, "names the three groups it changed: %r" % lines)
    eq(core["has_line"](lines, "Grid2 Hero - Realm: 파티 보임", "파티 칸 None→By Group", "창 Raid→Grouped"), True,
       "Grid2 brought to show the party, every value named: %r" % lines)
    eq(grid2_party(s), GRID2_PARTY, "Grid2 shows party")
    s.lua.execute("PitBull4DB.profiles.Default.groups['파티'].enabled = true")   # switched back on in PitBull4
    lines = core["dfp"](s, "party off")
    eq(core["has_line"](lines, "파티 그룹 1개 끔"), True, "counts only the group it changed: %r" % lines)
    eq(core["has_line"](lines, "Grid2 Hero - Realm: 파티 보임 (이미 그럼)"), True, "Grid2 already shows party")
    lines = core["dfp"](s, "party off")
    eq(core["has_line"](lines, "파티 그룹 이미 모두 꺼짐"), True, "nothing changed: says so")
    core["dfp"](s, "party on")
    eq(pb4_enabled(s), PB4_ON, "on: every party group on")
    core["dfp"](s, "party grid2")
    eq(pb4_enabled(s), PB4_OFF, "earlier word grid2 = off")
    core["dfp"](s, "party unitframes")
    eq(pb4_enabled(s), PB4_ON, "earlier word unitframes = on")
    shown = core["dfp"](s, "party")
    eq((core["has_line"](shown, "PitBull4 Default: 파티 그룹 3개 중 3개 켜짐"), core["has_line"](shown, "Grid2 Hero - Realm: 파티 보임")),
       (True, True), "/dfp party shows both sides: %r" % shown)
    nxt = party_session(["Grid2", "PitBull4"], saved=carry(s))
    eq((nxt.sv("PitBull4DB"), nxt.sv("Grid2DB")), (s.sv("PitBull4DB"), s.sv("Grid2DB")), "next login keeps the command's values")
    eq(s.errors() + nxt.errors(), [], "no errors")


@case
def party_command_without_preset_converts_legacy_pet_group():
    first = party_session(["Grid2", "PitBull4"])
    saved = carry(first)
    pb4_groups(saved)["파티원 소환수"] = {"enabled": False, "dfPartyRole": "hidden"}
    s = party_session(["Grid2", "PitBull4"], saved=saved)
    lines = core["dfp"](s, "party on")
    pet = pb4_groups(s)["파티원 소환수"]
    eq((pet["enabled"], pet["unit_group"], pet["dfPartyRole"], pet["layout"], pet["show_when"]["raid"]),
       (True, "partypet", "partypet", "대상의대상", True), "earlier hidden pet group becomes the package's pet group")
    eq(core["has_line"](lines, "파티원 소환수: 소환수 그룹으로 바꿈", "preset 배치 값 없음"), True, "says so: %r" % lines)


@case
def party_command_fuf_reads_back():
    first = party_session(["ForeverUnitFrames"])
    s = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first))
    eq(core["has_line"](core["dfp"](s, "party on"), "Forever Unit Frames Default: 파티 이미 켜짐"), True, "already on")
    lines = core["dfp"](s, "party off")
    eq(core["has_line"](lines, "명령 보냄"), True, "command sent")
    eq(fuf_calls(s), ["set party hideBlizzardFrame on", "set party enabled off"], "FUF party off, Blizzard's hidden")
    eq(party_state(s)["state"], "fuf-pending", "waits for the read-back")
    run_timers(s)
    eq(core["has_line"](prints(s), "Forever Unit Frames 파티 끔 확인"), True, "outcome printed")
    eq(party_state(s)["state"], "applied", "read back")
    core["dfp"](s, "party on")
    eq(fuf_calls(s)[-1], "set party enabled on", "FUF party on")
    nr = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first), ready=False)
    core["dfp"](nr, "party off")
    run_timers(nr)
    eq(core["has_line"](prints(nr), "아직 저장하지 않음", "/dfp party off"), True, "says it was not applied and what to do")
    gone = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first))
    gone.lua.execute("SlashCmdList.FOREVERUNITFRAMES = nil")
    eq(core["dfp"](gone, "party off"), ["[DF 설정] 안 함: Forever Unit Frames: FUF 명령이 없음 — 바꾼 것 없음"],
       "no FUF handler: refused")


@case
def party_combat_and_two_unit_addons():
    base = party_session(["Grid2", "PitBull4"])
    s = party_session(["Grid2", "PitBull4"], saved=carry(base))
    before = (s.sv("Grid2DB"), s.sv("PitBull4DB"))
    s.combat(True)
    eq(core["dfp"](s, "party off"), ["[DF 설정] 안 함: 전투 중 — 바꾼 것 없음"], "refused in combat")
    eq((s.sv("Grid2DB"), s.sv("PitBull4DB")), before, "nothing written")
    both = party_session(["Grid2", "PitBull4", "ForeverUnitFrames"])
    eq(core["has_line"](core["dfp"](both, "party off"), "함께 켜져"), True, "command refused")
    eq(core["has_line"](core["dfp"](s, "help"), "/dfp party [on|off]"), True, "help names the command")
    eq(core["dfp"](s, "party raid"), ["[DF 설정] /dfp party [on|off]"], "unknown word")


@case
def party_grid2_shared_default_profile_used():
    base = party_session(["Grid2", "PitBull4"])
    saved = carry(base)
    saved["Grid2DB"].setdefault("global", {})["defaultProfileName"] = "Shared"
    saved["Grid2DB"]["profileKeys"] = {}
    saved["Grid2DB"]["namespaces"]["Grid2Layout"]["profiles"]["Shared"] = {"layouts": {"party": "None"}, "FrameDisplay": "Raid"}
    s = party_session(["Grid2", "PitBull4"], saved=saved, player={"name": "Alt"})
    eq(core["has_line"](core["dfp"](s, "party"), "Grid2 Shared: 파티 안 보임"), True, "/dfp party reads the shared profile")
    core["dfp"](s, "party on")
    p = s.sv("Grid2DB")["namespaces"]["Grid2Layout"]["profiles"]["Shared"]
    eq((p["layouts"]["party"], p["FrameDisplay"]), ("By Group", "Grouped"),
       "written into the profile Grid2 uses (global.defaultProfileName)")


# Grid2 first-start template after the preset (Defaults/Grid2.lua hook) -------------------

GRID2_STUB = r"""
function hooksecurefunc(t, k, fn)
  local orig = t[k]
  t[k] = function(...) local r = {orig(...)}; fn(...); return unpack(r) end
end
local PROFILE = "Hero - Realm"
Grid2 = {defaultProfiles = {}}
function Grid2:DbRegisterProfile(info, index) self.defaultProfiles[index or (#self.defaultProfiles + 1)] = info end
function Grid2:DbUpdateStatusesDefaults() end
local function sub(t, k) t[k] = t[k] or {}; return t[k] end
Grid2.db = {GetCurrentProfile = function() return PROFILE end,
  GetNamespace = function(self, ns)
    return {profile = sub(sub(sub(sub(Grid2DB, "namespaces"), ns), "profiles"), PROFILE)} end}
setmetatable(Grid2.db, {__index = function(t, k)
  if k == "profile" then
    local p = sub(sub(Grid2DB, "profiles"), PROFILE)
    sub(p, "statuses"); sub(p, "indicators"); sub(p, "statusMap")
    return p
  end end})
-- As GridDefaults.lua MakeDatabaseDefaults: without a chosen index it opens the
-- first-boot dialog and returns false; the player's choice calls it again.
DIALOG_OPENED = 0
function Grid2:MakeDatabaseDefaults()
  local index = self.defaultProfileIndex
  self.defaultProfileIndex = nil
  if not index then DIALOG_OPENED = DIALOG_OPENED + 1; return false end
  local info = self.defaultProfiles[index]
  info.func(self, info)
  return true
end
"""


GRID2_LOOKUP = r"""
function Grid2:DbGetRegisteredProfileByName(name)
  for index, info in pairs(self.defaultProfiles) do if info.name == name then return info, index end end
end
"""


def grid2_template_session(template, saved=None, lookup=False):
    globals_ = dict(SCREEN)
    globals_["ChatFontNormal"] = {"GetFont": lambda self: ("Fonts\\x.ttf", 14)}
    s = Session(registry="generated", extra_files=(), saved=saved, globals_=globals_, collection_presets=True)
    s.lua.execute("function GetPhysicalScreenSize() return 1920, 1080 end")
    s.load_addon(ADDON)
    s.lua.execute(GRID2_STUB)
    if lookup:
        s.lua.execute(GRID2_LOOKUP)  # GridDefaults.lua DbGetRegisteredProfileByName
    s.lua.execute('TEST_meta.Grid2 = {Version = "4.1.13"}')  # Grid2.toc ## Version, read by Presets
    for rel in ("ProfileClassic.lua", "ProfileModern.lua", "ProfileBlizzard.lua"):
        src = open(os.path.join(GRID2_OPTIONS, "profiles", rel), "rb").read()
        fn = s.lua.eval("loadstring")(src, ("@" + rel).encode())
        (fn[0] if isinstance(fn, tuple) else fn)()
    s.load_addon("Grid2")   # Core's handlers: defaults, preset fragments, the template hook
    s.lua.execute("Grid2:MakeDatabaseDefaults()")   # OnEnable -> LoadConfig: dialog opens unless Core picks
    if template is not None:
        s.lua.execute("Grid2.defaultProfileIndex = %d; Grid2:MakeDatabaseDefaults()" % template)  # the player's pick
    s.fire("PLAYER_LOGIN")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    return s


@case
def grid2_preset_values_survive_first_start_template():
    for index, name in ((1, "Classic"), (2, "Modern"), (3, "Blizzard")):
        s = grid2_template_session(index)
        db = s.sv("Grid2DB")
        frame = db["namespaces"]["Grid2Frame"]["profiles"]["Hero - Realm"]
        layout = db["namespaces"]["Grid2Layout"]["profiles"]["Hero - Realm"]
        eq((frame["frameWidth"], frame["frameHeight"], frame["frameBorder"], layout["Padding"]), (44, 44, 2, 4),
           name + " template: preset cell size, border width and gap written again")
        eq(db["profiles"]["Hero - Realm"]["__template"], name, name + " template's own indicators kept")
        prof = db["profiles"]["Hero - Realm"]
        named = sorted(k for k, ind in prof["indicators"].items() if ind.get("type") == "text"
                       and (prof["statusMap"].get(k) or {}).get("name"))
        eq(named, [GRID2_NAME_TEXT[name]], name + ": the template's name text indicator")
        eq(prof["indicators"][named[0]]["fontSize"], 12, name + ": name text 12 px (fhd preset)")
        others = {k: ind.get("fontSize") for k, ind in prof["indicators"].items()
                  if ind.get("type") == "text" and k not in named}
        eq(others, GRID2_OTHER_TEXT[name], name + ": other text indicators keep the template's size")
        eq(frame["fontSize"], 12, name + ": Grid2Frame default text size 12")
        eq(s.g.DIALOG_OPENED, 1, "premise: the first call only opened the dialog")
        rec = s.sv("DevilForever_CoreDB")["preset"]["grid2Template"]
        eq(sorted(rec), ["Grid2DB/Grid2Frame@profile:Hero - Realm", "Grid2DB/Grid2Layout@profile:Hero - Realm"],
           "recorded once per profile key")
        eq(s.errors(), [], "no errors")
    saved = {"Grid2DB": {"profileKeys": {"Hero - Realm": "Hero - Realm"}, "profiles": {"Hero - Realm": {}},
                         "namespaces": {"Grid2Frame": {"profiles": {"Hero - Realm": {"frameWidth": 70}}}}}}
    old = grid2_template_session(2, saved=saved)
    frame = old.sv("Grid2DB")["namespaces"]["Grid2Frame"]["profiles"]["Hero - Realm"]
    eq(frame["frameWidth"], 66, "an existing profile: the template's value, no preset values written into it")
    eq(old.sv("Grid2DB")["profiles"]["Hero - Realm"]["indicators"]["text-center"]["fontSize"], 10,
       "an existing profile: the template's name text size")
    for preset, size in (("fhd", 12), ("qhd", 14), ("uhd", 18)):
        with open(os.path.join(ADDONS, "!DevilForever_Core", "Presets", preset + ".lua"), encoding="utf-8") as fh:
            src = fh.read()
        eq(src.count('["font"]="Devil Forever devil",["fontSize"]=%d,["iconSize"]=' % size), 1,
           preset + ": Grid2Frame fontSize %d (Codex gridFont)" % size)
        eq(src.count('["text-center"]={["font"]="Devil Forever devil",["fontSize"]=%d}' % size), 1,
           preset + ": proposal text-center %d" % size)


@case
def grid2_first_start_template_picked_without_dialog():
    s = grid2_template_session(None, lookup=True)
    db = s.sv("Grid2DB")
    eq(s.g.DIALOG_OPENED, 0, "no first-start dialog")
    eq(db["profiles"]["Hero - Realm"]["__template"], "Modern", "Modern template applied at the first call")
    frame = db["namespaces"]["Grid2Frame"]["profiles"]["Hero - Realm"]
    eq((frame["frameWidth"], frame["frameHeight"]), (44, 44), "preset cell size written again after the template")
    eq(s.errors(), [], "no errors")


GRID2_NAME_TEXT = {"Classic": "text-down", "Modern": "text-center", "Blizzard": "text-name"}
GRID2_OTHER_TEXT = {"Classic": {"text-up": 9}, "Modern": {}, "Blizzard": {}}


def pb4_preset_session(saved=None, request=False):
    globals_ = dict(SCREEN)
    globals_["ChatFontNormal"] = {"GetFont": lambda self: ("Fonts\\x.ttf", 14)}
    s = Session(registry="generated", extra_files=(), saved=saved, globals_=globals_, collection_presets=True)
    s.lua.execute("function GetPhysicalScreenSize() return 1920, 1080 end")
    s.lua.execute('TEST_meta.PitBull4 = {Version = "v4.2.50-forever.1"}')
    s.boot(after=["PitBull4"])
    return s


@case
def pitbull4_preset_positions_only_into_existing_units():
    fresh = pb4_preset_session()
    units = fresh.sv("PitBull4DB")["profiles"]["Default"]["units"]
    # the base preset is the V2 layout: the target-pet frame and its chain are on
    eq((units["대상의 소환수"]["enabled"], units["대상의 소환수"]["layout"]), (True, "소환수와 주시"),
       "fresh install: V2 target-pet frame")
    eq([units[n]["enabled"] for n in ("대상의 소환수의 대상", "대상의 소환수의 대상의 대상")], [True, True],
       "fresh install: target-pet chain")
    eq(fresh.sv("PitBull4DB")["profiles"]["Default"]["dfLayoutV2"], True, "fresh install: V2 layout")
    saved = {"PitBull4DB": {"profileKeys": {"Hero - Realm": "Default"},
                            "profiles": {"Default": {"units": {"대상": {"unit": "target", "enabled": True}}}}}}
    saved["PitBull4DB"]["namespaces"] = {"LuaTexts": {"profiles": {"Default": {"layouts": {
        "대상의대상": {"enabled": False, "elements": {
            "Lua:이름": {"enabled": False, "code": ""}, "Lua:생명력": {"enabled": False, "exists": False}}}}}}}}
    first = pb4_preset_session(saved=saved)
    eq(first.sv("PitBull4DB"), saved["PitBull4DB"], "existing unrequested profile gains no new rows or modules")
    core["dfp"](first, "preset fhd")
    core["dfp"](first, "go")
    nxt = {n: first.sv(n) for n in ("PitBull4DB", "DevilForever_CoreDB", "DevilForever_ProfilesDB")}
    s = pb4_preset_session(saved=nxt)
    units = s.sv("PitBull4DB")["profiles"]["Default"]["units"]
    preset_units = core["to_py"](s.core.Presets.Get(s.core.Presets, "fhd-v2"))["fragments"][1]["values"]["units"]
    eq(sorted(units), sorted(preset_units), "explicit preset writes the V2 layout's complete rows")
    for name, unit in (("플레이어 아래 대상", "target"), ("플레이어 아래 대상의 대상", "targettarget")):
        eq((units[name]["unit"], units[name]["enabled"], units[name]["layout"]),
           (unit, True, "대상의대상"), "new singleton has native identity and layout")
    fresh_units = fresh.sv("PitBull4DB")["profiles"]["Default"]["units"]
    eq(all(name in fresh_units for name in ("플레이어 아래 대상", "플레이어 아래 대상의 대상")), True,
       "fresh receipt v1 then v2 creates both rows")
    receipt = fresh.sv("DevilForever_CoreDB")["preset"]["fragments"]["fhd"]
    eq(receipt["PitBull4DB@profile:Default"], 11, "the V2 layout fragment, written last, owns the version 11 receipt")
    unchanged = pb4_preset_session(saved=carry(s))
    eq(unchanged.sv("PitBull4DB"), s.sv("PitBull4DB"), "plain reload keeps completed profile")
    eq("position_x" in units["대상"], True, "the existing unit gets its position")
    small = s.sv("PitBull4DB")["namespaces"]["LuaTexts"]["profiles"]["Default"]["layouts"]["대상의대상"]
    eq(small["enabled"], True, "explicit preset restores stored disabled small LuaTexts layout")
    for key, side in (("Lua:이름", "left"), ("Lua:생명력", "right")):
        text = small["elements"][key]
        eq((text["enabled"], text["exists"], text["attach_to"], text["location"]),
           (True, True, "HealthBar", side), "small text enabled and attached to the existing health bar")
        eq(bool(text["code"]), True, "small text has display code")


@case
def pitbull4_party_pet_group_beside_party_in_every_preset():
    s = pb4_preset_session()
    groups = s.sv("PitBull4DB")["profiles"]["Default"]["groups"]
    pet = groups["파티원 소환수"]
    eq((pet["enabled"], pet["unit_group"], pet["dfPartyRole"], "use_pet_header" in pet, pet["layout"]),
       (True, "partypet", "partypet", False, "대상의대상"), "fresh install: party pet group on with its own layout")
    eq(pet["position_y"], groups["파티"]["position_y"], "pet column starts at the party's first row")
    eq(pet["position_x"] > groups["파티원 대상"]["position_x"], True, "pet column right of the party targets")
    names = ("파티", "파티원 대상", "파티원 대상의 대상", "파티원 소환수")
    for preset in ("fhd", "qhd", "uhd"):
        d = core["to_py"](s.core.Presets.Get(s.core.Presets, preset))
        rows = [f["values"]["groups"] for f in d["fragments"].values()
                if f["folder"] == "PitBull4" and not f.get("namespace") and "groups" in f["values"]
                and "파티원 소환수" in f["values"]["groups"]]
        eq(len(rows) >= 2, True, preset + ": pet group in the full and the added-groups fragment")
        for g in rows:
            p, party, target = g["파티원 소환수"], g["파티"], g["파티원 대상"]
            eq((p["enabled"], p["unit_group"], "use_pet_header" in p, p["layout"]), (True, "partypet", False, "대상의대상"),
               preset + ": pet group values")
            eq((p["position_y"] == party["position_y"], p["position_x"] > target["position_x"] + target["size_x"]),
               (True, True), preset + ": pet column beside the party target column")
            eq(all(g[n]["show_when"]["raid"] and g[n]["show_when"]["raid40"] and not g[n]["show_when"]["solo"]
                   for n in names), True, preset + ": party groups in party and raid")
    old = carry(s)
    old["PitBull4DB"]["profiles"]["Default"]["groups"]["파티원 소환수"] = {"enabled": False, "dfPartyRole": "hidden"}
    plain = pb4_preset_session(saved=old)
    eq(plain.sv("PitBull4DB")["profiles"]["Default"]["groups"]["파티원 소환수"], {"enabled": False, "dfPartyRole": "hidden"},
       "existing profile: login keeps the earlier hidden pet group")
    core["dfp"](plain, "preset fhd"); core["dfp"](plain, "go")
    applied = pb4_preset_session(saved=carry(plain))
    pet = applied.sv("PitBull4DB")["profiles"]["Default"]["groups"]["파티원 소환수"]
    eq((pet["enabled"], pet["dfPartyRole"], pet["unit_group"]), (True, "partypet", "partypet"),
       "explicit preset makes it the package's pet group")
    eq(s.errors() + plain.errors() + applied.errors(), [], "no errors")


RAID_OFF = {"solo": False, "party": True, "raid": False, "raid10": False, "raid15": False, "raid20": False,
            "raid25": False, "raid30": False, "raid40": False}


@case
def party_command_brings_015_profile_to_the_new_design():
    fresh = pb4_preset_session()
    want = fresh.sv("PitBull4DB")["profiles"]["Default"]["groups"]["파티원 소환수"]
    saved = carry(fresh)
    profile = saved["PitBull4DB"]["profiles"]["Default"]
    for name in ("파티", "파티원 대상", "파티원 대상의 대상"):   # 0.1.5: party only, switched off for Grid2
        profile["groups"][name]["enabled"] = False
        profile["groups"][name]["show_when"] = dict(RAID_OFF)
    profile["groups"]["파티"]["position_x"] = 999          # the user's own placement
    profile["groups"]["파티원 소환수"] = {"enabled": False, "dfPartyRole": "hidden"}
    profile["dfGeometry"]["groups"].pop("파티원 소환수", None)
    s = pb4_preset_session(saved=saved)
    eq(s.sv("PitBull4DB")["profiles"]["Default"]["groups"], profile["groups"], "login writes nothing (no automatic upgrade)")
    lines = core["dfp"](s, "party on")
    groups = s.sv("PitBull4DB")["profiles"]["Default"]["groups"]
    eq([groups[n]["enabled"] for n in sorted(groups)], [True] * 4, "every party group on")
    eq(all(groups[n]["show_when"]["raid"] and groups[n]["show_when"]["raid40"] and not groups[n]["show_when"]["solo"]
           for n in groups), True, "party and raid, not solo")
    pet = groups["파티원 소환수"]
    eq((pet["unit_group"], pet["dfPartyRole"], pet["layout"]), ("partypet", "partypet", "대상의대상"), "package pet group")
    eq(all(abs(pet[k] - want[k]) < 1e-9 for k in ("position_x", "position_y", "size_x", "size_y", "vertical_spacing")), True,
       "missing placement from the fhd preset")
    eq(groups["파티"]["position_x"], 999, "the user's placement kept")
    geometry = s.sv("PitBull4DB")["profiles"]["Default"]["dfGeometry"]["groups"]
    eq("파티원 소환수" in geometry, True, "pet group joins the run-time rescale")
    eq((core["has_line"](lines, "PitBull4 Default: 파티 그룹 4개 켬"), core["has_line"](lines, "그중 4개는 공격대에서도"),
        core["has_line"](lines, "파티원 소환수: 소환수 그룹으로 바꿈", "fhd preset 값")), (True, True, True), "%r" % lines)
    eq(core["has_line"](core["dfp"](s, "party on"), "파티 그룹 이미 모두 켜짐"), True, "second time: nothing changed")
    off = core["dfp"](s, "party off")
    eq((core["has_line"](off, "파티 그룹 4개 끔"), core["has_line"](off, "공격대에서도")), (True, False), "off counts only enabled: %r" % off)
    eq(s.sv("PitBull4DB")["profiles"]["Default"]["groups"]["파티"]["show_when"]["raid"], True, "show_when stays the design")
    after = pb4_preset_session(saved=carry(s))
    eq(after.sv("PitBull4DB")["profiles"]["Default"]["groups"], s.sv("PitBull4DB")["profiles"]["Default"]["groups"],
       "next login keeps it")
    eq(core["has_line"](core["dfp"](after, "preset fhd"), "PitBull4 파티 그룹도 켬"), True, "explicit preset says it turns them on")
    eq(fresh.errors() + s.errors() + after.errors(), [], "no errors")


def pb4_grid2_session(saved=None):
    globals_ = dict(SCREEN)
    globals_["ChatFontNormal"] = {"GetFont": lambda self: ("Fonts\\x.ttf", 14)}
    s = Session(registry="generated", extra_files=(), saved=saved, globals_=globals_, collection_presets=True)
    s.lua.execute("function GetPhysicalScreenSize() return 1920, 1080 end")
    s.lua.execute('TEST_meta.PitBull4 = {Version = "v4.2.50-forever.1"}; TEST_meta.Grid2 = {Version = "4.1.13"}')
    s.boot(after=["PitBull4", "Grid2"])
    return s


def grid2_spot(s):
    p = s.sv("Grid2DB")["namespaces"]["Grid2Layout"]["profiles"]["Hero - Realm"]
    return (p.get("anchor"), round(p["PosX"] / PIXEL_FACTOR, 6), round(p["PosY"] / PIXEL_FACTOR, 6))


@case
def party_command_moves_grid2_only_from_the_earlier_default_spot():
    fresh = pb4_grid2_session()
    eq(grid2_spot(fresh), ("TOPRIGHT", -247, -259), "new install: fhd preset spot, left of the quest tracker")
    eq(any("Grid2 창" in l for l in core["dfp"](fresh, "party on")), False, "already at the preset spot: no position line")
    for spot, moved in (((None, 24, -164), True), (("TOPLEFT", 24.4, -163.6), True), (("TOPLEFT", 300, -164), False)):
        saved = carry(fresh)
        lay = saved["Grid2DB"]["namespaces"]["Grid2Layout"]["profiles"]["Hero - Realm"]
        if spot[0] is None:
            lay.pop("anchor", None)       # AceDB drops a value equal to Grid2's default (TOPLEFT)
        else:
            lay["anchor"] = spot[0]
        lay["PosX"], lay["PosY"] = spot[1] * PIXEL_FACTOR, spot[2] * PIXEL_FACTOR
        s = pb4_grid2_session(saved=saved)
        before = grid2_spot(s)
        eq(core["dfp"](s, "party off") and grid2_spot(s), before, "off never moves the window")
        lines = core["dfp"](s, "party on")
        if moved:
            eq(grid2_spot(s), ("TOPRIGHT", -247, -259), "earlier default %r: moved to the preset spot" % (spot,))
            eq(core["has_line"](lines, "Grid2 창: 예전 기본 자리 → fhd preset"), True, "%r" % lines)
        else:
            eq(grid2_spot(s), before, "a window the user moved stays")
            eq(core["has_line"](lines, "Grid2 창은 예전 기본 자리가 아니라서 그대로"), True, "%r" % lines)
        nxt = pb4_grid2_session(saved=carry(s))
        eq(grid2_spot(nxt), grid2_spot(s), "login moves nothing")
        eq(s.errors() + nxt.errors(), [], "no errors")


@case
def grid2_spot_follows_the_compare_layout_and_back():
    s = pb4_grid2_session()
    eq(grid2_spot(s), ("TOPRIGHT", -247, -259), "fhd: left of the quest tracker")
    core["dfp"](s, "preset fhd-v2"); core["dfp"](s, "go")
    v2 = pb4_grid2_session(saved=carry(s))
    eq(grid2_spot(v2), ("TOPRIGHT", -247, -259), "fhd-v2: the same spot")
    saved = carry(v2)   # before the V1 request below
    core["dfp"](v2, "preset fhd-v1"); core["dfp"](v2, "go")
    back = pb4_grid2_session(saved=carry(v2))
    eq(grid2_spot(back), ("TOPRIGHT", -247, -259), "fhd-v1: the same spot")
    lay = saved["Grid2DB"]["namespaces"]["Grid2Layout"]["profiles"]["Hero - Realm"]
    lay.pop("anchor", None); lay["PosX"], lay["PosY"] = 24 * PIXEL_FACTOR, -164 * PIXEL_FACTOR
    old = pb4_grid2_session(saved=saved)
    lines = core["dfp"](old, "party on")
    eq(grid2_spot(old), ("TOPRIGHT", -247, -259), "V2 in use: the earlier default spot moves to the preset spot")
    eq(core["has_line"](lines, "fhd preset 의 자리(퀘스트 목록 왼쪽, 위 끝 맞춤)"), True, "%r" % lines)
    eq(s.errors() + v2.errors() + back.errors() + old.errors(), [], "no errors")


def grid2_cells(s):
    p = s.sv("Grid2DB")["namespaces"]["Grid2Frame"]["profiles"]["Hero - Realm"]
    return (p["frameWidth"], p["frameHeight"])


@case
def grid2_cells_follow_the_layout_version():
    s = pb4_grid2_session()
    eq(grid2_cells(s), (44, 44), "new install: New layout, square cells")
    state = s
    for request, cells in (("fhd-v1", (96, 32)), ("fhd-v2", (44, 44)), ("fhd-v1", (96, 32)), ("fhd", (44, 44))):
        core["dfp"](state, "preset " + request); core["dfp"](state, "go")
        state = pb4_grid2_session(saved=carry(state))
        eq(grid2_cells(state), cells, request + ": Grid2 cells")
        eq(grid2_spot(state), ("TOPRIGHT", -247, -259), request + ": the window spot stays")
    again = pb4_grid2_session(saved=carry(state))
    eq(grid2_cells(again), (44, 44), "plain login writes nothing")
    eq(s.errors() + state.errors() + again.errors(), [], "no errors")


@case
def party_groups_kept_notice_points_to_party_command():
    fresh = pb4_preset_session()
    saved = carry(fresh)
    saved["DevilForever_CoreDB"]["preset"]["fragments"]["fhd"]["PitBull4DB@profile:Default"] = 4   # a 0.1.5 receipt
    saved["DevilForever_CoreDB"]["preset"].pop("keptNotice", None)
    s = pb4_preset_session(saved=saved)
    lines = [l for l in prints(s) if "preset" in l or "파티 그룹" in l]
    eq(core["has_line"](lines, "PitBull4 파티 그룹", "/dfp party on"), True, "party groups: the light command: %r" % lines)
    eq(any("/dfp preset fhd" in l for l in lines), True, "the V2 layout rows still point to /dfp preset fhd: %r" % lines)
    again = pb4_preset_session(saved=carry(s))
    eq([l for l in prints(again) if "/dfp party on" in l], [], "printed once")


@case
def companion_chains_explicit_upgrade_keeps_existing_profile():
    previous = pb4_preset_session()
    saved = carry(previous)
    profile = saved["PitBull4DB"]["profiles"]["Default"]
    units = profile["units"]
    # The earlier managed profile has only the two first descendants and no pettargettarget row.
    units.pop("플레이어의 소환수의 대상의 대상")
    units["주시 대상의 대상의 대상"] = {"unit": "focustargettarget", "layout": "대상의대상"}
    pixel = PIXEL_FACTOR / UI_SCALE
    for label, point in (("플레이어의 소환수의 대상", "TOPLEFT"), ("주시 대상의 대상", "TOPRIGHT")):
        units[label] = {"unit": "pettarget" if point == "TOPLEFT" else "focustarget", "layout": "대상의대상",
                        "enabled": point == "TOPRIGHT", "anchor": point, "relative_point": point, "relative_to": "0",
                        "position_x": (703 if point == "TOPLEFT" else -703)*pixel, "position_y": -546*pixel,
                        "scale": 1, "size_x": 123/160, "size_y": 29/28, "font_multiplier": 1}
    for label in ("플레이어의 소환수", "주시 대상"):
        units[label]["position_y"] = -546*pixel
    units["대상의 소환수"]["enabled"] = True
    profile["layouts"].pop("소환수와 주시 아래")
    profile["dfGeometry"]["layouts"].pop("소환수와 주시 아래")
    for label in ("플레이어의 소환수의 대상", "플레이어의 소환수의 대상의 대상", "주시 대상의 대상", "주시 대상의 대상의 대상"):
        profile["dfGeometry"]["units"].pop(label, None)
    for namespace in saved["PitBull4DB"]["namespaces"].values():
        namespace["profiles"]["Default"].get("layouts", {}).pop("소환수와 주시 아래", None)
    saved["DevilForever_CoreDB"]["preset"]["fragments"]["fhd"]["PitBull4DB@profile:Default"] = 3
    units["Custom unit"] = {"unit": "target", "layout": "Custom layout", "enabled": False}
    plain = pb4_preset_session(saved=saved)
    eq(plain.sv("PitBull4DB"), saved["PitBull4DB"], "unrequested existing profile is preserved")
    core["dfp"](plain, "preset fhd"); core["dfp"](plain, "go")
    upgraded = pb4_preset_session(saved=carry(plain))
    units = upgraded.sv("PitBull4DB")["profiles"]["Default"]["units"]
    names = ("플레이어의 소환수의 대상", "플레이어의 소환수의 대상의 대상", "주시 대상의 대상", "주시 대상의 대상의 대상")
    for name, unit in zip(names, ("pettarget", "pettargettarget", "focustarget", "focustargettarget")):
        eq((units[name]["enabled"], units[name]["unit"], units[name]["layout"]), (True, unit, "소환수와 주시 아래"), "explicit four complete native rows")
    eq(units["대상의 소환수"]["enabled"], True, "explicit preset: V2 target-pet frame on")
    for name, unit in (("대상의 소환수의 대상", "targetpettarget"), ("대상의 소환수의 대상의 대상", "targetpettargettarget")):
        eq((units[name]["enabled"], units[name]["unit"], units[name]["layout"]), (True, unit, "소환수와 주시 아래"),
           "explicit target-pet chain rows")
    eq(units["Custom unit"], saved["PitBull4DB"]["profiles"]["Default"]["units"]["Custom unit"], "custom unit preserved")
    eq(any(u.get("unit", "").startswith("focuspet") for u in units.values()), False, "no focus pet rows added")
    restored = pb4_preset_session(saved=carry(upgraded))
    eq(restored.sv("PitBull4DB"), upgraded.sv("PitBull4DB"), "plain reload keeps completed chain profile")
    eq(previous.errors()+plain.errors()+upgraded.errors()+restored.errors(), [], "no errors")


GRID2_OPTIONS = os.path.join(ADDONS, "Grid2Options")


def statusmap_line(text, indicator):
    found = re.findall(r'^m\["%s"\]\s*=\s*\{(.*)\}\s*$' % re.escape(indicator), text, re.M)
    eq(len(found), 1, "one statusMap line for %s" % indicator)
    return found[0]


@case
def grid2_first_start_templates_carry_healer_indicators():
    with open(os.path.join(GRID2_OPTIONS, "Grid2Options.toc"), encoding="utf-8") as fh:
        toc = [line.strip().replace("\\", "/") for line in fh if line.strip().startswith("profiles")]
    eq(toc, ["profiles/ProfileClassic.lua", "profiles/ProfileModern.lua", "profiles/ProfileBlizzard.lua"],
       "the three selectable templates, Classic first (index 1)")
    with open(os.path.join(GRID2_OPTIONS, "GridProfiles.lua"), encoding="utf-8") as fh:
        dialog = fh.read()
    eq(dialog.count("self:SelectDialogGroup( 'Grid2ProfilesDialog', \"1\" )"), 2, "dialog preselects template 1")
    for rel in toc:
        with open(os.path.join(GRID2_OPTIONS, rel), encoding="utf-8") as fh:
            text = fh.read()
        eq('["debuffs-DispellableByMe"]=' in statusmap_line(text, "border"), True, rel + ": dispellable-debuff border")
        eq("range=" in statusmap_line(text, "alpha"), True, rel + ": out-of-range fade")
        eq('["heals-incoming"]=' in statusmap_line(text, "health-bar"), True, rel + ": incoming heals on the health bar")
    with open(os.path.join(ADDONS, "Grid2", "GridDefaultsRetail.lua"), encoding="utf-8") as fh:
        empty = fh.read()
    eq(("debuffs-DispellableByMe" in empty, "range=" in statusmap_line(empty, "alpha")), (False, True),
       "the Empty template: range fade only")


@case
def nameplate_addon_loads_no_probe():
    folder = os.path.join(ADDONS, "DevilForever_Skin_Nameplates")
    with open(os.path.join(folder, "DevilForever_Skin_Nameplates.toc"), encoding="utf-8") as fh:
        lines = [line.strip() for line in fh if line.strip()]
    eq([l for l in lines if not l.startswith("#")], ["NameplateProfiles.lua", "Appearance.lua"], "loaded files")
    eq([l for l in lines if l.startswith("## SavedVariables")], [], "no saved variable")
    s = Session(registry="generated", extra_files=()).boot()
    info = core["to_py"](s.core.GetAddonInfo(s.core, "DevilForever_Skin_Nameplates"))
    eq(info.get("savedVariables") or {}, {}, "registry names no saved variable for the folder")
    eq([os.path.isfile(os.path.join(folder, n)) for n in ("Probe.lua", "SessionProbe.lua")], [True, True],
       "probe files kept in the folder, not loaded")


@case
def orphan_prat_defaults_absent():
    core_dir = os.path.join(ADDONS, "!DevilForever_Core")
    eq(os.path.exists(os.path.join(core_dir, "Defaults", "Prat-3.0.lua")), False, "no Prat defaults file")
    with open(os.path.join(core_dir, "!DevilForever_Core.toc"), encoding="utf-8") as fh:
        eq("Prat" in fh.read(), False, "Core TOC loads no Prat file")


def main():
    passed, failed = 0, []
    for fn in CASES:
        try:
            fn()
            passed += 1
            print("PASS %s" % fn.__name__)
        except Exception:  # noqa: BLE001 - report every failing case
            failed.append(fn.__name__)
            print("FAIL %s" % fn.__name__)
            traceback.print_exc(limit=3)
    print("lupa=%s cases=%d passed=%d failed=%d" % (lupa.__version__, len(CASES), passed, len(failed)))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

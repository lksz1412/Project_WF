"""Lua 5.1 regression checks for appearance batching and Dominos pet rebuilds.

Run: python Collection/tests/performance/run.py --dominos-zip PATH
Counts measure stub API calls, not game frame time or FPS.
"""

import argparse
import ast
from pathlib import Path
from zipfile import ZipFile

from lupa import lua51

ROOT = Path(__file__).resolve().parents[3]
ADDONS = ROOT / "Collection/AddOns"
core_tests = ast.parse((ROOT / "Collection/tests/core/run.py").read_text(encoding="utf-8"))
STUBS = next(ast.literal_eval(n.value) for n in core_tests.body
             if isinstance(n, ast.Assign) and isinstance(n.targets[0], ast.Name)
             and n.targets[0].id == "STUBS")

UI = r'''
counts = {}
function bump(k) counts[k] = (counts[k] or 0) + 1 end
function noop() end
function GetPhysicalScreenSize() return 3840,2160 end
STANDARD_TEXT_FONT="Fonts\\FRIZQT__.TTF"
UNIT_NAME_FONT=STANDARD_TEXT_FONT
NUM_PET_ACTION_SLOTS=10
PixelUtil={GetPixelToUIUnitFactor=function() return 0.5 end}
actions={}
C_Timer={After=function(_,fn) actions[#actions+1]=fn; bump("scheduled") end}
function drain()
  local due=actions; actions={}
  for _,fn in ipairs(due) do fn() end
end
function hooksecurefunc(obj,key,cb)
  local old=obj[key]
  obj[key]=function(...) local r=old(...); cb(...); return r end
end
function widget(name)
  local w={name=name, visible=true}
  function w:GetEffectiveScale() return 1 end
  function w:GetHeight() return 1080 end
  function w:GetName() return self.name end
  function w:GetFont() return "font",12,"" end
  function w:GetSize() return 36,36 end
  function w:GetHitRectInsets() return 0,0,0,0 end
  function w:SetTexture(path)
    self.texture=path
    if path and path:find("Composition",1,true) then bump("composite") end
  end
  function w:Show() self.visible=true end
  function w:Hide() self.visible=false end
  function w:SetFont(...) self.font={...}; if name then bump(name) end end
  function w:SetSize(...) self.size={...}; if name=="nameplates" then bump(name) end end
  function w:SetScale(v) self.scale=v; if name=="appearance" or name=="statusstrip" then bump(name) end end
  function w:CreateTexture() local texture=widget(); self.edge=texture; return texture end
  for _,k in ipairs({"SetFrameStrata","SetFrameLevel","EnableMouse","EnableKeyboard","ClearAllPoints",
    "SetPoint","SetHeight","SetVertexColor","SetAlpha","SetAllPoints","SetTexCoord","SetTextColor",
    "HookScript","SetStatusBarTexture","SetParent"}) do w[k]=noop end
  return w
end
UIParent=widget()
ActionButton1=widget()
PetActionButton1=widget()
ChatFontNormal=widget()
local create=CreateFrame
function CreateFrame(kind,name)
  local f=create(kind)
  local label=name=="DevilForever_AppearanceRoot" and "appearance" or name
  setmetatable(f,{__index=widget(label)})
  if name then _G[name]=f end
  return f
end
function button(scope)
  local b=widget()
  b.HotKey=widget(scope)
  return b
end
for i=1,7 do _G["DominosFrame"..i]={buttons={button(i==1 and "dominos" or nil)}} end
DominosFramepet={buttons={}}
for i=1,10 do DominosFramepet.buttons[i]=button("pet") end
ChatFrame1=widget("nativechat")
CHAT_FRAME_TEXTURES={}
local bar=widget("nameplates")
C_NamePlate={GetNamePlates=function() return {{UnitFrame={healthBar=bar,name=widget()}}} end}
local strip=widget("statusstrip")
DevilForever_StatusStrip={GetFrame=function() return strip end,ListItems=function() return {} end,
  SetSpacing=noop,RegisterCallback=noop}
'''


def run_file(lua, data, name, namespace):
    fn = lua.globals().loadstring(data, "@" + name)
    assert not isinstance(fn, tuple), fn
    fn(name.split("/")[0], namespace)


def session(zip_file, shipped=False, initial="uhd"):
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    lua.execute(STUBS)
    lua.execute(UI)
    lua.execute('DevilForever_CoreDB={preset={active="' + initial + '"}}')
    for folder in ("!DevilForever_Core", "DevilForever_Appearance"):
        ns = lua.table()
        toc_entry = folder + "/" + folder + ".toc"
        if shipped:
            toc = zip_file.read("Interface/AddOns/" + toc_entry).decode("utf-8-sig")
        else:
            toc = (ADDONS / toc_entry).read_text(encoding="utf-8-sig")
        for raw in toc.splitlines():
            rel = raw.strip().replace("\\", "/")
            if not rel or rel.startswith("#"):
                continue
            entry = folder + "/" + rel
            data = zip_file.read("Interface/AddOns/" + entry) if shipped else (ADDONS / entry).read_bytes()
            run_file(lua, data, entry, ns)
        lua.globals().TEST_loaded[folder] = True
        lua.globals().TEST_fire("ADDON_LOADED", folder)
    extra = (
        ("DevilForever_Skin_Dominos/Skin.lua",),
        ("DevilForever_Skin_Nameplates/NameplateProfiles.lua", "DevilForever_Skin_Nameplates/Appearance.lua"),
        ("DevilForever_Skin_NativeChat/Skin.lua",),
        ("DevilForever_Skin_StatusStrip/Skin.lua",),
    )
    for files in extra:
        ns = lua.table()
        for entry in files:
            data = zip_file.read("Interface/AddOns/" + entry) if shipped else (ADDONS / entry).read_bytes()
            run_file(lua, data, entry, ns)
    lua.execute('''
      TEST_fire("PLAYER_LOGIN")
      TEST_fire("PLAYER_ENTERING_WORLD",true,false)
      drain()
      SlashCmdList.DFPROFILE("theme horde")
      notifications={}
      DevilForever_Core.Edit:RegisterCallback("count",function(key,field,value)
        bump("notify_"..key:match("^[^.]+"))
        notifications[#notifications+1]={key=key,field=field,value=DevilForever_Core.CopyTable(value),
          active=DevilForever_Core.Presets:GetActive()}
      end)
      counts={}
    ''')
    assert not list(lua.globals().TEST_errors.values()), list(lua.globals().TEST_errors.values())
    return lua


def counts(lua):
    return dict(lua.globals().counts.items())


def plain(value):
    if lua51.lua_type(value) == "table":
        return {k: plain(v) for k, v in value.items()}
    return value


def resolved(lua):
    return lua.eval('''function()
      local function dump(t)
        if type(t)~="table" then return tostring(t) end
        local keys,out={},{}
        for k in pairs(t) do keys[#keys+1]=k end
        table.sort(keys,function(a,b) return tostring(a)<tostring(b) end)
        for _,k in ipairs(keys) do out[#out+1]=tostring(k).."="..dump(t[k]) end
        return "{"..table.concat(out,",").."}"
      end
      local values={}
      for _,key in ipairs(DevilForever_Core:GetFrameKeys()) do values[key]=DevilForever_Core.Edit:Get(key) end
      return dump(values)
    end''')()


def presets(zip_file):
    for old, new, edited in (("uhd", "qhd", False), ("qhd", "fhd", False),
                             ("fhd", "uhd", False), ("uhd", "qhd", True)):
        results = []
        for shipped in (True, False):
            lua = session(zip_file, shipped, old)
            if edited:
                lua.execute('''local E=DevilForever_Core.Edit
                  assert(E:Set("appearance.chat1","size",E:Get("appearance.chat1").size)); counts={}; notifications={}''')
            lua.globals().SlashCmdList.DFPROFILE("preset " + new)
            results.append((counts(lua), resolved(lua), plain(lua.globals().notifications)))
            assert not list(lua.globals().TEST_errors.values()), list(lua.globals().TEST_errors.values())
        before, after = results[0][0], results[1][0]
        for key in ("appearance", "dominos", "nameplates", "nativechat", "statusstrip"):
            assert after[key] == 1, (old, new, key, after)
        assert before["appearance"] == (40 if edited else 39), before
        assert after["composite"] == 10, after
        assert before["notify_appearance"] == after["notify_appearance"] == (40 if edited else 39)
        assert {k: v for k, v in before.items() if k.startswith("notify_")} == {
            k: v for k, v in after.items() if k.startswith("notify_")}
        assert results[0][1] == results[1][1], (old, new, "resolved fields differ")
        assert results[0][2] == results[1][2], (old, new, "notification values/order differ")
        print("PASS preset", old, new, "edited=" + str(edited), before, "->", after)
    lua = session(zip_file)
    lua.globals().SlashCmdList.DFPROFILE("theme alliance")
    assert counts(lua)["appearance"] == 1 and counts(lua).get("scheduled", 0) == 0
    lua.execute('counts={}; assert(DevilForever_Core.Edit:Set("appearance.chat1","color",{0.1,0.2,0.3,1}))')
    assert counts(lua)["appearance"] == 1 and counts(lua).get("scheduled", 0) == 0
    lua.execute('''
      local E=DevilForever_Core.Edit
      local order={}
      local function mark(n) return function() order[#order+1]=n end end
      assert(E:Batch(function()
        E:AfterBatch("a",mark(1))
        E:Batch(function() E:AfterBatch("a",mark(2)); E:AfterBatch("b",mark(3)) end)
        assert(#order==0)
        return 7
      end)==7)
      assert(table.concat(order,",")=="2,3")
      local ok=pcall(function() E:Batch(function() E:AfterBatch("a",mark(4)); error("body") end) end)
      assert(not ok and order[3]==4)
      E:AfterBatch("a",mark(5)); assert(order[4]==5)
      E:Batch(function()
        E:AfterBatch("bad",function() error("deferred") end)
        E:AfterBatch("a",function() E:Batch(function() E:AfterBatch("a",mark(6)) end) end)
        E:AfterBatch("b",mark(7))
      end)
      assert(order[5]==6 and order[6]==7 and #TEST_errors==1)
    ''')
    print("PASS immediate theme/edit, nested batch, error recovery and reentrant flush")


def pet(zip_file):
    for shipped in (True, False):
        lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        lua.execute(STUBS + UI)
        lua.execute('''
          DevilForever_Core={Edit={Get=function() return {font={path="font",size=12},color={1,1,1,1}} end,
            RegisterCallback=noop,AfterBatch=function(_,_,fn) fn() end},
            Theme={GetSet=function() return "devil" end,RegisterCallback=function(_,_,fn) theme=fn end},Log=noop}
          TEST_uiPixel=1
          DevilForever_Appearance={GetPixelUnit=function(_,region)
            if region==UIParent then return TEST_uiPixel end
            return 1
          end}
          native={CreateClass=function() return {Extend=noop} end,Frame={contextMenu={Extend=noop}}}
        ''')
        run_file(lua, zip_file.read("Interface/AddOns/Dominos/core/buttonBar.lua"), "Dominos/core/buttonBar.lua", lua.globals().native)
        lua.execute('''
          DominosFramepet=setmetatable({buttons={},sets={numButtons=10},OnAttachButton=noop,OnDetachButton=noop,
            Layout=noop,AcquireButton=function() return button("pet") end,GetClickThrough=function() return false end},
            {__index=native.ButtonBar})
          for i=1,10 do DominosFramepet:AttachButton(i) end
        ''')
        entry = "DevilForever_Skin_Dominos/Skin.lua"
        data = zip_file.read("Interface/AddOns/" + entry) if shipped else (ADDONS / entry).read_bytes()
        run_file(lua, data, entry, lua.table())
        lua.execute('TEST_fire("PLAYER_LOGIN"); counts={}; old=DominosFramepet.buttons[1]; DominosFramepet:ReloadButtons(); drain()')
        c = counts(lua)
        assert c.get("dominos", 0) == (20 if shipped else 0), c
        assert c["pet"] == (100 if shipped else 10), c
        assert c.get("scheduled", 0) == (0 if shipped else 1), c
        assert lua.eval("not old.edge.visible and DominosFramepet.buttons[1].edge.visible")
        print("PASS native Dominos ReloadButtons", "shipped" if shipped else "workspace", c)
        if not shipped:
            lua.execute('''
              counts={}; DominosFramepet:ReloadButtons(); TEST_combat=true; drain()
              assert(not counts.pet and not counts.dominos)
              TEST_combat=false; TEST_fire("PLAYER_REGEN_ENABLED")
              assert(counts.pet==10 and not counts.dominos)
              counts={}; DominosFramepet:ReloadButtons(); theme()
              assert(counts.pet==10 and counts.dominos==1)
              drain(); assert(counts.pet==10 and counts.dominos==1)
              counts={}; TEST_combat=true; DominosFramepet:ReloadButtons()
              assert(not counts.scheduled)
              TEST_combat=false; TEST_fire("PLAYER_REGEN_ENABLED")
              assert(counts.pet==10 and not counts.dominos)
            ''')
            print("PASS pet combat deferral, detached edges and full-refresh absorption")
            lua.execute('''
              function checkPetRow(previous)
                assert(not previous.edge.visible)
                for _,b in ipairs(DominosFramepet.buttons) do
                  assert(b.HotKey.font[1]=="font" and b.HotKey.font[2]==12)
                  assert(b.edge.visible and b.edge.texture:find("PetEdge.tga",1,true))
                end
              end
              counts={}; old=DominosFramepet.buttons[1]; DominosFramepet:ReloadButtons()
              TEST_uiPixel=nil; TEST_fire("UPDATE_BINDINGS")
              assert(not counts.pet and not counts.dominos and #actions==1)
              assert(not DominosFramepet.buttons[1].HotKey.font and not DominosFramepet.buttons[1].edge)
              TEST_uiPixel=1; drain()
              assert(counts.pet==10 and not counts.dominos and counts.scheduled==1)
              checkPetRow(old)
            ''')
            print("PASS failed UPDATE_BINDINGS preserves existing pet timer until scale recovers")
            lua.execute('''
              counts={}; old=DominosFramepet.buttons[1]; DominosFramepet:ReloadButtons()
              TEST_uiPixel=nil; drain()
              assert(not counts.pet and not counts.dominos and #actions==0 and counts.scheduled==1)
              TEST_uiPixel=1; TEST_fire("PLAYER_REGEN_ENABLED")
              assert(counts.pet==10 and not counts.dominos and #actions==0)
              checkPetRow(old)
            ''')
            print("PASS failed pet timer retains request for next valid event without polling")
            lua.execute('''
              counts={}; old=DominosFramepet.buttons[1]; TEST_combat=true; DominosFramepet:ReloadButtons()
              TEST_combat=false; TEST_uiPixel=nil; TEST_fire("PLAYER_REGEN_ENABLED")
              assert(not counts.pet and not counts.dominos and #actions==0)
              TEST_uiPixel=1; TEST_fire("PLAYER_REGEN_ENABLED")
              assert(counts.pet==10 and not counts.dominos)
              checkPetRow(old)
              TEST_fire("PLAYER_REGEN_ENABLED"); assert(counts.pet==10 and not counts.dominos)
            ''')
            print("PASS failed combat-end pet update survives until next valid event")
            lua.execute('''
              counts={}; old=DominosFramepet.buttons[1]; TEST_combat=true; DominosFramepet:ReloadButtons()
              TEST_fire("UPDATE_BINDINGS")
              TEST_combat=false; TEST_uiPixel=nil; TEST_fire("PLAYER_REGEN_ENABLED")
              assert(not counts.pet and not counts.dominos and #actions==0)
              TEST_uiPixel=1; TEST_fire("PLAYER_REGEN_ENABLED")
              assert(counts.pet==10 and counts.dominos==1)
              checkPetRow(old)
              TEST_fire("PLAYER_REGEN_ENABLED"); drain()
              assert(counts.pet==10 and counts.dominos==1 and #actions==0)
            ''')
            print("PASS failed combat-end full update preserves both requests and clears them on success")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dominos-zip", required=True, type=Path)
    args = parser.parse_args()
    with ZipFile(args.dominos_zip) as package:
        presets(package)
        pet(package)
    print("PASS performance regression gates (Lua stub calls only)")

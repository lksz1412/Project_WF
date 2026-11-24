"""Exercise the actual Core, standalone Strip, skin and theme selector in Lua 5.1.

Run: python Collection/tests/statusstrip/theme_switcher.py
Animation scheduling and font/frame APIs are client-boundary stubs.
"""
from pathlib import Path
import runpy
ROOT=Path(__file__).resolve().parents[3]
A=ROOT/'Collection/AddOns'
C=runpy.run_path(str(ROOT/'Collection/tests/core/run.py'),run_name='core_harness')
S=runpy.run_path(str(ROOT/'Collection/tests/statusstrip/run.py'),run_name='strip_harness')
ORDER=['devil','alliance','horde','human','dwarf','gnome','nightelf','orc','tauren','troll','undead','skyborne','skyborne-horde']
UI=r"""
local R=getmetatable(UIParent)
function R:SetSize(w,h) self.width,self.height=w,h end
function R:GetWidth() return self.width or 0 end
function R:GetHeight() return self.height or 0 end
function R:SetFont(path,size,flags) self.font={path,size,flags} end
function R:SetTextColor(...) self.color={...} end
function R:SetAllPoints(relative) self.allPoints=relative end
function R:EnableKeyboard(v) self.keyboard=v end
function R:RegisterForClicks(v) self.clicks=v end
function R:SetFrameLevel(v) self.level=v end
function R:GetFrameLevel() return self.level or 1 end
function R:SetScale(v) self.scale=v end
function R:SetClipsChildren(v) self.clip=v end
function R:SetJustifyH(v) self.justify=v end
function R:SetWordWrap(v) self.wrap=v end
function R:SetTexture(v) self.texture=v end
function R:SetVertexColor(...) self.color={...} end
function R:GetStringWidth()
 local width=0
 for ch in (self.text or ''):gmatch('[%z\1-\127\194-\244][\128-\191]*') do width=width+(#ch>1 and self.font[2] or self.font[2]*.5) end
 return width
end
function R:CreateTexture() return self:CreateFontString() end
function R:CreateAnimationGroup()
 local group={scripts={},owner=self,plays=0,stops=0}
 function group:SetScript(k,fn) self.scripts[k]=fn end
 function group:CreateAnimation(kind)
  self.translation={kind=kind}
  local t=self.translation
  function t:SetDuration(v) self.duration=v end
  function t:SetSmoothing(v) self.smoothing=v end
  function t:SetOffset(x,y) self.x,self.y=x,y end
  return t
 end
 function group:Play() self.playing=true;self.plays=self.plays+1 end
 function group:Stop() self.playing=false;self.stops=self.stops+1;if self.scripts.OnStop then self.scripts.OnStop(self) end end
 function group:Finish() self.playing=false;if self.scripts.OnFinished then self.scripts.OnFinished(self) end end
 self.animation=group;return group
end
local create=CreateFrame
function CreateFrame(kind,name,parent)
 local frame=create(kind,name,parent)
 frame.children={};frame.fontStrings={}
 if parent then parent.children=parent.children or {};parent.children[#parent.children+1]=frame end
 return frame
end
local font=R.CreateFontString
function R:CreateFontString(...)
 local f=font(self,...);self.fontStrings=self.fontStrings or {};self.fontStrings[#self.fontStrings+1]=f;return f
end
GameTooltip={SetOwner=function(self,v) self.owner=v end,SetText=function(self,v) self.text=v;self.line=nil end,
 AddLine=function(self,v) self.line=v end,Show=function(self) self.shown=true end,Hide=function(self) self.shown=false end}
DevilForever_Appearance={GetPixelUnit=function() return TEST_pixel end}
"""
def load(s,relative,addon=None):
    fn=s.lua.eval('loadstring')((A/relative).read_bytes(),('@'+relative).encode())
    assert not isinstance(fn,tuple),fn
    fn(addon or relative.split('/')[0],s.lua.table())

def session(width,height,font,locale='koKR',saved=None,registered=ORDER):
    s=C['Session'](registry='generated',extra_files=(),saved=saved,globals_={'GetLocale':lambda:locale})
    s.boot()
    s.lua.execute('CORE_FIRE=TEST_fire;CORE_SLASH=SlashCmdList.DFPROFILE')
    s.lua.execute(S['STUBS']);s.lua.execute(UI);s.g.SlashCmdList.DFPROFILE=s.g.CORE_SLASH
    s.g.TEST_locale=locale;s.g.TEST_pixel=768/height
    s.lua.execute('local strip=TEST_fire;function TEST_fire(event,...) CORE_FIRE(event,...);strip(event,...) end')
    for theme in registered:
        s.core.Theme.RegisterSet(s.core.Theme,theme,s.table({'font.normal':'font','color.text.normal':[1,1,1,1],'color.divider':[1,1,1,1],'border.size':1,'texture.divider':'texture'}))
    edit=s.core.Edit
    for key,value in {'size':{'width':width,'height':22 if height==1080 else 24 if height==1440 else 28},
                      'font':{'path':'font','size':font},'position':{'point':'BOTTOMLEFT','relativePoint':'BOTTOMLEFT','x':0,'y':8},
                      'color':[1,1,1,1],'spacing':24 if height>=2000 else 18}.items():
        ok,_=edit.Set(edit,'statusstrip.bar',key,s.table(value));assert ok
    load(s,'DevilForever_StatusStrip/StatusStrip.lua')
    s.g.TEST_fire('ADDON_LOADED','DevilForever_StatusStrip')
    load(s,'DevilForever_Skin_StatusStrip/Skin.lua')
    load(s,'DevilForever_Skin_StatusStrip/ThemeSwitcher.lua')
    s.g.TEST_fire('PLAYER_LOGIN');s.g.TEST_fire('PLAYER_ENTERING_WORLD')
    assert not s.errors(),s.errors()
    return s

def items(panel):
    slot,left,right=(panel.children[i] for i in (1,2,3))
    return slot,slot.fontStrings[1],left,right

def click(button):button.scripts.OnClick(button)

for w,h,font in [(1920,1080,16),(2560,1440,18),(3840,2160,22),(3862,2160,22)]:
    s=session(w,h,font);p=s.g.DevilForever_StatusStripThemes;slot,text,left,right=items(p)
    base=(p.width,slot.width,left.width,right.width)
    assert p.height==left.height==right.height==s.g.DevilForever_StatusStripFrame.height
    assert p.points[1][1]=='RIGHT' and p.points[1][5]==0 and p.points[1][4]==(-24 if h>=2000 else -18)
    assert slot.clip and slot.width==font*12 and text.text=='데빌'
    assert left.mouse and right.mouse and left.clicks==right.clicks=="LeftButtonUp"
    assert p.width+18<w/2
    assert all(s.g[k].points[1][1]=='LEFT' for k in S['FONTSTRING_NAMES'].values())
    stats={key:s.g[value].text for key,value in S['FONTSTRING_NAMES'].items()}
    old_tickers=s.g.TEST_count.NewTicker
    for index,name in enumerate(ORDER[1:]+ORDER[:1]):
        click(right)
        assert s.core.Theme.GetSet(s.core.Theme)[0]==name
        assert text.text==s.core.Theme.GetDisplayName(s.core.Theme,name)
        assert text.GetStringWidth(text)<=slot.width
        assert (p.width,slot.width,left.width,right.width)==base
        assert text.animation.playing and text.animation.translation.x==-8
    click(left);assert s.core.Theme.GetSet(s.core.Theme)[0]==ORDER[-1]
    assert text.animation.translation.x==8
    for _ in range(21):click(right)
    expected=s.core.Theme.GetSet(s.core.Theme)[0]
    text.animation.Finish(text.animation)
    assert text.text==s.core.Theme.GetDisplayName(s.core.Theme,expected)
    assert text.points[1][4]==0 and not text.animation.playing
    s.g.SlashCmdList.DFPROFILE('theme 2');assert text.text=='호드' and not text.animation.playing
    s.g.SlashCmdList.DFPROFILE('theme alliance');assert text.text=='얼라'
    s.g.TEST_combat=True
    click(right);assert s.core.Theme.GetSet(s.core.Theme)[0]=='alliance'
    assert s.g.GameTooltip.shown and s.g.GameTooltip.line=='전투 중에는 바꿀 수 없습니다.'
    assert s.g.GameTooltip.text=='다음 테마'
    left.scripts.OnEnter(left);assert s.g.GameTooltip.text=='이전 테마'
    s.g.SlashCmdList.DFPROFILE('theme 0');assert text.text=='얼라'
    s.g.TEST_combat=False;s.g.TEST_fire('PLAYER_REGEN_ENABLED')
    assert s.sv('DevilForever_CoreDB')['theme']['active']=='alliance'
    assert stats=={key:s.g[value].text for key,value in S['FONTSTRING_NAMES'].items()}
    assert s.g.TEST_count.NewTicker==old_tickers
    assert all(frame.scripts.OnUpdate is None for frame in s.g.TEST_frames.values())
    assert not s.errors(),s.errors()
    saved={'DevilForever_CoreDB':s.sv('DevilForever_CoreDB')}
    again=session(w,h,font,saved=saved);assert items(again.g.DevilForever_StatusStripThemes)[1].text=='얼라'
    print('PASS',w,h,'13 choices bidirectional wrap/fixed bounds/AnimationGroup rapid last name/slash/combat/saved restore/stats and ticker unchanged')

s=session(1920,1080,16,locale='enUS',registered=['devil','horde'])
_,text,left,right=items(s.g.DevilForever_StatusStripThemes)
click(right);assert text.text=='Horde';click(right);assert text.text=='Devil';click(left);assert text.text=='Horde'
assert [x['name'] for _,x in s.core.Theme.ListChoices(s.core.Theme).items()]==['devil','horde']
assert [v for _,v in s.core.Theme.ListSets(s.core.Theme).items()]==['devil','horde']
s.core.Theme.RegisterSet(s.core.Theme,'custom',s.table({}))
assert [v for _,v in s.core.Theme.ListSets(s.core.Theme).items()]==['custom','devil','horde']
assert len(list(s.core.Theme.ListChoices(s.core.Theme).values()))==2
standalone=S['Session']().load().login()
assert standalone.g.DevilForever_StatusStripThemes is None and standalone.errors()==[]
print('PASS missing sets skipped; ListSets sorted/custom contract and standalone Strip unchanged')

for invalid in (None,'1',.5,{},float('inf')):
    assert s.core.Theme.GetChoiceName(s.core.Theme,s.table(invalid)) is None
for invalid in (None,0,2,'1',{}):
    assert s.core.Theme.Cycle(s.core.Theme,s.table(invalid))[0] is False
print('PASS public selection input guards')

en=session(1920,1080,16,locale='enUS')
slot,text,left,right=items(en.g.DevilForever_StatusStripThemes)
for _ in ORDER:
    click(right)
    assert text.GetStringWidth(text)<=slot.width
assert text.text=='Devil'
print('PASS all English names fit fixed FHD slot')

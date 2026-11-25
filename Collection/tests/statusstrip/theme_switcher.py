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
TEST_badTextures={}
function R:SetTexture(v) self.texture=v;if v and TEST_badTextures[v] then return false end;return true end
function R:SetTexCoord(...) self.texCoord={...} end
function R:SetAlpha(v) self.alpha=v end
function R:Enable() self.enabled=true end
function R:Disable() self.enabled=false end
function R:SetNormalTexture(t) self.normalTexture=t end
function R:SetPushedTexture(t) self.pushedTexture=t end
function R:SetDisabledTexture(t) self.disabledTexture=t end
function R:SetHighlightTexture(t,mode) self.highlightTexture=t;self.highlightMode=mode end
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
function R:CreateFontString(name,layer,template)
 local f=font(self,name,layer,template);self.fontStrings=self.fontStrings or {};self.fontStrings[#self.fontStrings+1]=f
 if template then f.font={template} end
 return f
end
local setText=R.SetText
function R:SetText(text)
 if not self.font then error("FontString:SetText(): Font not set",2) end
 return setText(self,text)
end
GameTooltip={SetOwner=function(self,v) self.owner=v end,SetText=function(self,v) self.text=v;self.line=nil end,
 AddLine=function(self,v) self.line=v end,Show=function(self) self.shown=true end,Hide=function(self) self.shown=false end}
DevilForever_Appearance={GetPixelUnit=function() return TEST_pixel end}
"""
def load(s,relative,addon=None,source=None):
    fn=s.lua.eval('loadstring')(source if source is not None else (A/relative).read_bytes(),('@'+relative).encode())
    assert not isinstance(fn,tuple),fn
    fn(addon or relative.split('/')[0],s.lua.table())

def session(width,height,font,locale='koKR',saved=None,registered=ORDER,screen=None,switcher=None,combat_login=False,layout_v2=None):
    # the PitBull4 preset fragments (V1/V2 layouts) are computed at load from the UI scale and the chat font
    extra={'ChatFontNormal':{'GetFont':lambda self:('font',14)},'UIParent':{'GetEffectiveScale':lambda self:1,'GetHeight':lambda self:768},
           'PixelUtil':{'GetPixelToUIUnitFactor':lambda:768/screen[1]}} if layout_v2 is not None else {}
    s=C['Session'](registry='generated',extra_files=(),saved=saved,globals_=dict({'GetLocale':lambda:locale},**extra),
                   collection_presets=screen is not None)
    if screen:s.g.GetPhysicalScreenSize=s.lua.eval('function() return %d, %d end'%screen)
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
    if layout_v2 is not None:  # PitBull4 loaded, its profile on the New (V2) or Old (V1) layout
        profile={'dfLayoutV2':bool(layout_v2)}
        if layout_v2=='current':profile['dfLayoutRevision']=4  # this package's New (V2) revision
        s.g.TEST_loaded.PitBull4=True;s.g.PitBull4=s.table({'db':{'profile':profile}})
    load(s,'DevilForever_Skin_StatusStrip/ThemeSwitcher.lua',source=switcher)
    s.g.TEST_combat=combat_login
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

# Theme switcher images: shipped files, Lua file table, image/text choice ------------
import re,struct
SKIN=A/'DevilForever_Skin_StatusStrip'
MEDIA=SKIN/'Media/ThemeSwitcher'
SOURCE=(SKIN/'ThemeSwitcher.lua').read_bytes()
LUA_TEXT=SOURCE.decode('utf-8')
ART={'fhd':((256,32),(192,22),(32,32),22,16,(1920,1080)),'qhd':((256,32),(216,24),(32,32),24,18,(2560,1440)),
     'uhd':((512,32),(264,28),(32,32),28,22,(3840,2160))}
FILES=['layout_new','layout_old']+['name_'+t for t in ORDER]+['arrow_%s_%s'%(side,state) for side in ('prev','next')
                                   for state in ('normal','hover','pushed','disabled')]

def tga(path):
    data=path.read_bytes()
    head=struct.unpack('<BBBHHBHHHHBB',data[:18])
    w,h=head[8],head[9]
    return head,w,h,data[18:18+w*h*4],data[18+w*h*4:]

for preset,(name_canvas,name_area,arrow_canvas,bar,_font,_screen) in ART.items():
    on_disk=sorted(p.stem for p in (MEDIA/preset).iterdir())
    assert on_disk==sorted(FILES),(preset,on_disk)
    for stem in FILES:
        head,w,h,pixels,footer=tga(MEDIA/preset/(stem+'.tga'))
        canvas,area=(name_canvas,name_area) if stem.startswith(('name_','layout_')) else (arrow_canvas,(bar,bar))
        assert head==(0,0,2,0,0,0,0,0,w,h,32,8) and (w,h)==canvas,(preset,stem,head)
        assert footer==b'\0'*8+b'TRUEVISION-XFILE.\0',(preset,stem)
        inside=0
        for row in range(h):
            y=h-1-row
            for x in range(w):
                a=pixels[(row*w+x)*4+3]
                if x>=area[0] or y>=area[1]: assert a==0,(preset,stem,x,y)
                elif a: inside+=1
        assert inside>0,(preset,stem)
assert (MEDIA/'LICENSE-OFL.txt').read_bytes()==(ROOT/'Collection/codex-briefs/assets/26-theme-switcher/OFL.txt').read_bytes()
assert not [p for p in SKIN.rglob('*') if p.suffix.lower() in ('.ttf','.otf')]
assert sorted(p.name for p in MEDIA.iterdir())==['LICENSE-OFL.txt','fhd','qhd','uhd']
print('PASS 69 TGA (canvas, type 2, 32 bpp, 8 alpha bits, footer, transparent outside the draw area) + OFL, no font file')

block=re.search(r'local SHIPPED = \{(.*?)\n\}',LUA_TEXT,re.S).group(1)
table={m.group(1):re.findall(r'"([^"]+)"',m.group(2)) for m in re.finditer(r'(\w+) = \{(.*?)\}',block,re.S)}
assert set(table)==set(ART),table.keys()
for preset,names in table.items():
    assert len(names)==len(set(names)) and sorted(names)==sorted(p.stem for p in (MEDIA/preset).iterdir()),preset
assert not re.search(r'OnUpdate|C_Timer|NewTicker|NewTimer',LUA_TEXT)
print('PASS Lua shipped-file table equals the files on disk; no OnUpdate/C_Timer/ticker in ThemeSwitcher.lua')

def art(s):
    p=s.g.DevilForever_StatusStripThemes;slot,text,left,right=items(p)
    return p,slot,text,slot.fontStrings[2],left,right
def path(preset,stem):return 'Interface\\AddOns\\DevilForever_Skin_StatusStrip\\Media\\ThemeSwitcher\\%s\\%s.tga'%(preset,stem)
def arrows_are_images(button,preset,side):
    states={'normal':button.normalTexture,'pushed':button.pushedTexture,'disabled':button.disabledTexture,
            'hover':button.highlightTexture}
    return (all(t is not None and t.texture==path(preset,'arrow_%s_%s'%(side,state)) for state,t in states.items())
            and button.highlightMode=='BLEND' and not button.fontStrings[1].shown)
def arrows_are_text(button):
    textures=[button.normalTexture,button.pushedTexture,button.disabledTexture,button.highlightTexture]
    return all(t is None or t.texture is None for t in textures) and button.fontStrings[1].shown
def coords(t):return [t.texCoord[i] for i in range(1,5)]
def texture_objects(button):return [button.fontStrings[i] for i in range(2,6)]

for preset,(name_canvas,name_area,arrow_canvas,bar,font,screen) in ART.items():
    s=session(screen[0],screen[1],font,locale='enUS',screen=screen)
    assert s.core.Presets.GetActive(s.core.Presets)[0]==preset
    p,slot,text,image,left,right=art(s)
    made=texture_objects(left)+texture_objects(right)
    tickers=s.g.TEST_count.NewTicker
    assert image.shown and not text.shown and image.texture==path(preset,'name_devil')
    assert coords(image)==[0,name_area[0]/name_canvas[0],0,name_area[1]/name_canvas[1]]
    assert (image.width,image.height)==name_area and text.text=='Devil'
    assert arrows_are_images(left,preset,'prev') and arrows_are_images(right,preset,'next')
    assert coords(left.normalTexture)==[0,bar/arrow_canvas[0],0,bar/arrow_canvas[1]] and left.enabled and right.enabled
    assert left.alpha==right.alpha==1
    for theme in ORDER[1:]+ORDER[:1]:
        click(right)
        assert image.texture==path(preset,'name_'+theme) and image.shown and not text.shown
        assert text.animation.playing and image.animation.playing
        assert text.animation.translation.x==image.animation.translation.x==-8
        assert text.points[1][4]==image.points[1][4]==8
    click(left);assert image.animation.translation.x==8 and image.points[1][4]==-8
    image.animation.Finish(image.animation);assert image.points[1][4]==0
    assert all(s.g.rawequal(a,b) for a,b in zip(made,texture_objects(left)+texture_objects(right))),'arrow textures made once'
    assert len(left.fontStrings)==len(right.fontStrings)==5 and len(slot.fontStrings)==2
    s.g.TEST_combat=True;s.g.TEST_fire('PLAYER_REGEN_DISABLED')
    assert left.alpha==right.alpha==.45 and p.alpha is None and slot.alpha is None and image.alpha is None
    click(right);assert s.g.GameTooltip.line=='Unavailable in combat.' and left.enabled and right.enabled
    s.g.TEST_combat=False;s.g.TEST_fire('PLAYER_REGEN_ENABLED');assert left.alpha==right.alpha==1
    assert s.g.TEST_count.NewTicker==tickers and all(f.scripts.OnUpdate is None for f in s.g.TEST_frames.values())
    edit=s.core.Edit
    ok,_=edit.Set(edit,'statusstrip.bar','font',s.table({'path':'font','size':font+1}));assert ok
    assert text.shown and not image.shown and arrows_are_text(left) and arrows_are_text(right)
    ok,_=edit.Set(edit,'statusstrip.bar','font',s.table({'path':'font','size':font}));assert ok
    assert image.shown and arrows_are_images(left,preset,'prev')
    ok,_=edit.Set(edit,'statusstrip.bar','size',s.table({'width':screen[0],'height':bar+2}));assert ok
    assert text.shown and not image.shown and arrows_are_text(right)
    assert not s.errors(),s.errors()
    print('PASS',preset,'name and arrow images, tex coords, slide together, textures made once, combat alpha, edited size/font -> text')

s=session(1920,1080,16,locale='koKR',screen=(1920,1080))
p,slot,text,image,left,right=art(s)
s.g.TEST_badTextures[path('fhd','name_horde')]=True
s.g.SlashCmdList.DFPROFILE('theme horde');assert text.shown and not image.shown and text.text=='호드'
s.g.SlashCmdList.DFPROFILE('theme alliance');assert image.shown and image.texture==path('fhd','name_alliance')
s.g.TEST_badTextures[path('fhd','arrow_next_pushed')]=True
s.g.SlashCmdList.DFPROFILE('theme devil')
assert arrows_are_text(left) and arrows_are_text(right) and image.shown
print('PASS SetTexture false -> that name as text; one arrow file -> both arrows as text (koKR name text)')

for drop,kind in (('"name_horde", ','name'),('"arrow_prev_hover", ','arrows')):
    start=SOURCE.index(b'fhd = {')
    source=SOURCE[:start]+SOURCE[start:].replace(drop.encode(),b'',1)
    assert source!=SOURCE
    s=session(1920,1080,16,locale='enUS',screen=(1920,1080),switcher=source)
    p,slot,text,image,left,right=art(s)
    if kind=='name':
        assert image.shown and arrows_are_images(left,'fhd','prev')
        s.g.SlashCmdList.DFPROFILE('theme horde');assert text.shown and not image.shown
    else:
        assert arrows_are_text(left) and arrows_are_text(right) and image.shown
    q=session(2560,1440,18,locale='enUS',screen=(2560,1440),switcher=source)
    _,_,qtext,qimage,qleft,qright=art(q)
    q.g.SlashCmdList.DFPROFILE('theme horde')
    assert qimage.shown and arrows_are_images(qleft,'qhd','prev') and arrows_are_images(qright,'qhd','next')
print('PASS file left out of the fhd table -> text in fhd only (name per theme, arrows per preset)')

one=session(1920,1080,16,locale='enUS',screen=(1920,1080),registered=['devil'])
_,_,_,_,left,right=art(one);assert left.enabled is False and right.enabled is False
two=session(1920,1080,16,locale='enUS',screen=(1920,1080),registered=['devil','horde'])
_,_,_,_,left,right=art(two);assert left.enabled and right.enabled
fight=session(1920,1080,16,locale='enUS',screen=(1920,1080),combat_login=True)
_,_,_,_,left,right=art(fight);assert left.alpha==right.alpha==.45
fight.g.TEST_combat=False;fight.g.TEST_fire('PLAYER_REGEN_ENABLED');assert left.alpha==right.alpha==1
none=session(1920,1080,16,locale='enUS')
_,_,text,image,left,right=art(none);assert text.shown and not image.shown and arrows_are_text(left)
print('PASS one choice -> Disable, two -> Enable; login in combat -> 0.45; no preset -> text')

# Load order: a FontString without a font must not get text at file load (the client raises).
for w,h,font,screen in [(1920,1080,16,(1920,1080)),(3840,2160,22,(3840,2160))]:
    s=session(w,h,font,locale='enUS',screen=screen)
    _,_,_,_,left,right=art(s)
    assert left.fontStrings[1].text=='\u25c0' and right.fontStrings[1].text=='\u25b6'
    assert not s.errors(),s.errors()
early=SOURCE.replace(b'local arrows = {',b'previousText:SetText("x")\r\nlocal arrows = {',1)
assert early!=SOURCE
try:
    session(1920,1080,16,locale='enUS',switcher=early)
except Exception as exc:
    assert 'Font not set' in str(exc),exc
else:
    raise AssertionError('SetText before SetFont at load was not caught')
print('PASS switcher loads without a font error; arrow text set after SetFont; early SetText at load is caught')

# Version switcher (New = V2, Old = V1) left of the theme switcher: same construction.
def layouts(s):
    p=s.g.DevilForever_StatusStripLayouts;slot,text,left,right=items(p)
    return p,slot,text,slot.fontStrings[2],left,right
for preset,(name_canvas,name_area,arrow_canvas,bar,font,screen) in ART.items():
    for v2,key,label in (('current','new','New'),(False,'old','Old'),(True,'old','Old')):
        s=session(screen[0],screen[1],font,locale='koKR',screen=screen,layout_v2=v2)
        p,slot,text,image,left,right=layouts(s)
        themes=s.g.DevilForever_StatusStripThemes
        assert p.shown and p.points[1][1]=='RIGHT' and s.g.rawequal(p.points[1][2],themes) and p.points[1][3]=='LEFT'
        assert image.shown and not text.shown and image.texture==path(preset,'layout_'+key) and text.text==label
        assert coords(image)==[0,name_area[0]/name_canvas[0],0,name_area[1]/name_canvas[1]]
        assert arrows_are_images(left,preset,'prev') and arrows_are_images(right,preset,'next') and left.enabled
        s.g.TEST_combat=True;s.g.TEST_fire('PLAYER_REGEN_DISABLED')
        assert left.alpha==right.alpha==.45
        reloads=s.g.TEST_reloads
        click(right);assert s.g.TEST_reloads==reloads and s.g.GameTooltip.line=='전투 중에는 바꿀 수 없습니다.'
        assert s.g.GameTooltip.text=='다음 배치'
        s.g.TEST_combat=False;s.g.TEST_fire('PLAYER_REGEN_ENABLED');assert left.alpha==1
        # the first-login re-apply (run here once PitBull4's profile is visible): an older revision gets the
        # version in use requested without a reload; the current revision gets nothing
        s.core.Presets.ReapplyOutdatedLayout(s.core.Presets)
        before=s.sv('DevilForever_ProfilesDB').get('pending')
        if v2!='current':
            assert before and before['name']==preset+('-v2' if v2 else '-v1') and not before['armed'],before
            assert s.g.TEST_reloads==reloads and any('다시 적용하도록 예약' in l for l in s.g.TEST_printed.values())
        else:
            assert before is None
        click(right)  # the switch replaces a waiting layout request
        want=preset+('-v1' if v2=='current' else '-v2')  # an earlier V2 (no current revision) shows Old and steps to New
        pending=s.sv('DevilForever_ProfilesDB')['pending']
        assert s.g.TEST_reloads==reloads+1 and pending['action']=='preset' and pending['name']==want,(pending,want)
        assert not s.errors(),s.errors()
    print('PASS',preset,'version switcher New/Old images left of the theme switcher; earlier V2 profile shows Old; combat refusal and dim; a switch requests the other layout and reloads, replacing the first-login re-apply request')
none=session(3840,2160,22,locale='enUS',screen=(3840,2160))
assert not none.g.DevilForever_StatusStripLayouts.shown and none.g.DevilForever_StatusStripThemes.shown
edited=session(3840,2160,22,locale='enUS',screen=(3840,2160),layout_v2='current')
edit=edited.core.Edit
ok,_=edit.Set(edit,'statusstrip.bar','font',edited.table({'path':'font','size':23}));assert ok
p,slot,text,image,left,right=layouts(edited)
assert text.shown and not image.shown and text.text=='New' and arrows_are_text(left)
print('PASS version switcher hidden without PitBull4; edited font -> text New with arrow text')

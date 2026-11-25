"""Execute V2 preset requests, native frame layout and Forever Swing events in Lua 5.1.

Run: python Collection/tests/layoutv2/run.py
Client frame/event APIs are stubs; no game rendering or protected-engine simulation.
"""
from pathlib import Path
import runpy,copy
ROOT=Path(__file__).resolve().parents[3]
A=ROOT/'Collection/AddOns'
C=runpy.run_path(str(ROOT/'Collection/tests/core/run.py'),run_name='core_harness')
Session=C['Session'];plain=C['to_py'];dfp=C['dfp']

def load(s,rel):
    fn=s.lua.eval('loadstring')((A/rel).read_bytes().removeprefix(b"\xef\xbb\xbf"),('@'+rel).encode())
    assert not isinstance(fn,tuple),fn
    fn('test',s.lua.table())

# installed versions of the other layout targets (the fragments' addonVersion)
ADDON_VERSIONS={}
def session(mode,height,width,saved=None,ui=1,before_boot=None,after=('PitBull4','Quartz')):
    factor=768/height
    g={'UIParent':{'GetEffectiveScale':lambda self:ui,'GetHeight':lambda self:768/ui},
       'PixelUtil':{'GetPixelToUIUnitFactor':lambda:factor},
       'ChatFontNormal':{'GetFont':lambda self:('font',14)},
       # a native action button, so the presets register their Dominos frames (totem bar included)
       'ActionButton1':{'GetSize':lambda self:(45,45),'GetHitRectInsets':lambda self:(0,0,0,0)},
       'NUM_PET_ACTION_SLOTS':10}
    # a native pet slot (Lua functions: fitPet checks their type), so the presets register their pet bar
    pet='PetActionButton1={GetSize=function() return 30,30 end,GetHitRectInsets=function() return 0,0,0,0 end}'
    s=Session(registry='generated',extra_files=(),saved=saved,globals_=g,collection_presets=True,prelude=pet)
    s.lua.execute('function GetPhysicalScreenSize() return %d,%d end'% (width,height))
    s.lua.execute('TEST_meta.PitBull4={Version="v4.2.50-forever.1"};TEST_meta.Quartz={Version="3.8.0"}')
    for folder,version in ADDON_VERSIONS.items():
        s.lua.execute('TEST_meta[%r]={Version=%r}'%(folder,version))
    if saved is None:
        s.g.DevilForever_CoreDB=s.lua.table_from({'preset':{'active':mode}},recursive=True)
    if before_boot:before_boot(s)
    s.boot(after=list(after))
    assert not s.errors(),s.errors()
    return s

def carry(s):
    return {n:s.sv(n) for n in ('DevilForever_CoreDB','DevilForever_ProfilesDB','PitBull4DB','Quartz3DB','Grid2DB','DominosDB')
            if s.sv(n) is not None}

def request(s,name):
    dfp(s,'preset '+name);dfp(s,'go')
    return carry(s)

def rects(s,width,height,ui):
    s.lua.execute((Path(__file__).with_name('native.lua')).read_text(encoding='utf-8'))
    s.g.TEST_factor=768/height
    s.g.TEST_ui=ui
    load(s,'PitBull4/Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua')
    load(s,'PitBull4/UnitFrame.lua');load(s,'PitBull4/UnitFrameLayout.lua')
    s.lua.execute('buildFrames();TEST_fire("PLAYER_LOGIN");TEST_fire("PLAYER_ENTERING_WORLD");for _,f in ipairs(TEST_frames) do f:RefreshLayout() end')
    s.lua.execute("""
      TEST_rects={}
      for name,row in pairs(PitBull4.db.profile.units) do if row.enabled then
        local f=makeRegion();f.layout_db=PitBull4.db.profile.layouts[row.layout]
        f.classification_db=row
        PitBull4.SingletonUnitFrame.RefixSizeAndPosition(f)
        TEST_rects[name]={f.width,f.height,f.scale,f.points[1]}
      end end
    """)
    p=s.g.PitBull4.db.profile
    result={}
    for name,raw in s.g.TEST_rects.items():
        if not p.units[name].enabled:continue
        w,h,scale=raw[1],raw[2],raw[3];point=raw[4];eff=scale*ui/(768/height)
        rel=point[3];x=point[4]*eff;y=-point[5]*eff
        if 'RIGHT' in rel:x+=width
        elif rel=='TOP':x+=width/2
        if 'RIGHT' in point[1]:x-=w*eff
        result[name]=(x,y,w*eff,h*eff)
    return result

def overlaps(a,b):
    return min(a[0]+a[2],b[0]+b[2])-max(a[0],b[0])>1e-6 and min(a[1]+a[3],b[1]+b[3])-max(a[1],b[1])>1e-6

for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160),('uhd',3862,2160)]:
    old=session(mode,height,width)
    initial=carry(old)
    initial['Quartz3DB']['profiles']['Default'].setdefault('modules',{})['Swing']=False
    initial['PitBull4DB']['profiles']['Default']['units']['custom']={'unit':'player','layout':'private','enabled':False}
    initial['PitBull4DB']['profiles']['Default']['layouts']['private']={'size_x':99,'size_y':20,'scale':1}
    old=session(mode,height,width,initial,ui=.64)
    old.core.Edit.Set(old.core.Edit,'appearance.chat1','font',old.lua.table_from({'size':21}))
    before=carry(old)
    v2=session(mode,height,width,request(old,mode+'-v2'),ui=.64)
    db=carry(v2);p=db['PitBull4DB']['profiles']['Default'];bp=before['PitBull4DB']['profiles']['Default']
    assert db['DevilForever_CoreDB']['preset']['active']==mode
    assert db['DevilForever_CoreDB'].get('edits')==before['DevilForever_CoreDB'].get('edits')
    assert p['groups']==bp['groups']
    assert p['units']['custom']==bp['units']['custom'] and p['layouts']['private']==bp['layouts']['private']
    assert p['dfLayoutV2'] and p['units']['대상의 소환수']['enabled']
    assert all('focuspet'!=row.get('unit') for row in p['units'].values())
    for label in ('플레이어','대상'):  # V2 rules replace V1's companion avoidance (no shrink when a pet or focus shows)
        assert set(p['dfAuraGeometry'][label])-{'top_margin'}=={'above','width'},(label,p['dfAuraGeometry'][label])  # player: top_margin clears the totem timer
    q=db['Quartz3DB']['namespaces']
    assert q['Pet']['profiles']['Default']['point']=='TOP' and 'dfGeometry' not in q['Pet']['profiles']['Default']  # pet cast bar moves with the pet frame
    assert q['Swing']['profiles']['Default']['swingposition']=='bottom'
    assert db['Quartz3DB']['profiles']['Default'].get('modules',{})==before['Quartz3DB']['profiles']['Default'].get('modules',{})
    for scale in (1,.64,.8):
        live=session(mode,height,width,db,ui=scale)
        r=rects(live,width,height,scale)
        assert live.g.PitBull4.db.profile.dfGeometry is not None
        assert abs(live.g.PitBull4.db.profile.dfPixel-(768/height)/scale)<1e-8,(mode,scale,live.g.PitBull4.db.profile.dfPixel,live.errors())
        names=['플레이어의 소환수','플레이어','주시 대상','대상','대상의 소환수']
        assert [r[n][0] for n in names]==sorted(r[n][0] for n in names)
        assert max(r[n][1]+r[n][3] for n in names)-min(r[n][1]+r[n][3] for n in names)<1e-6
        for name,a in r.items():
            assert a[0]>=0 and a[1]>=0 and a[0]+a[2]<=width and a[1]+a[3]<=height,(name,a)
            for other,b in r.items():
                if name!=other:assert not overlaps(a,b),(mode,name,other,a,b)
        live.lua.execute(Path(__file__).with_name('cast.lua').read_text(encoding='utf-8'))
        for rel in ['PitBull4/ModuleHandling/BarModules.lua','PitBull4/Modules/CastBar/CastBar.lua','PitBull4/Modules/CastBar/Forever.lua']:
            load(live,rel)
        live.lua.execute("""
          local f=TEST_frames[1];f.layout='보통';f.layout_db=PitBull4.db.profile.layouts['보통']
          f.unit='player';f.GetFrameLevel=function() return 2 end
          local cfg=PitBull4DB.namespaces.CastBar.profiles.Default.layouts['보통']
          -- the player's cast bar is the Quartz Player bar; PitBull4 clears a module whose layout entry is
          -- disabled (ModuleHandling/Module.lua UpdateFrame), and both cast texts are off
          assert(cfg.enabled==false)
          local texts=PitBull4DB.namespaces.LuaTexts.profiles.Default.layouts['보통'].elements
          assert(texts['Lua:시전'].enabled==false and texts['Lua:시전시간'].enabled==false)
        """)
    # the base preset is the layout (the only one); requesting it again keeps every unit where it is
    assert bp['dfLayoutV2'] and bp['units']['대상의 소환수']['enabled']
    again=session(mode,height,width,request(v2,mode),ui=.64)
    pagain=again.sv('PitBull4DB')['profiles']['Default']
    assert pagain['dfLayoutV2'] and pagain['units']['대상의 소환수']['enabled']
    for name in bp['units']:
        if name!='custom':
            for key in ('anchor','relative_point','position_x','position_y','size_x','size_y','layout','enabled'):
                a,b=pagain['units'][name].get(key),bp['units'][name].get(key)
                if key in ('position_x','position_y'):a,b=a/pagain['dfPixel'],b/bp['dfPixel']  # same physical spot at either UI scale
                assert (abs(a-b)<1e-8) if isinstance(b,(int,float)) and not isinstance(b,bool) else a==b,(mode,name,key,a,b)
    assert again.sv('Quartz3DB')['namespaces']['Swing']['profiles']['Default']['swingposition']=='bottom'
    assert not again.errors(),again.errors()
    print('PASS',mode,width,'actual preset request/reload -> V2 -> base preset again; 3 scales native Refix/layout; party/custom/module toggles preserved')
print('PASS V2 lifecycle and native geometry')

for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160),('uhd',3862,2160)]:
    first=session(mode,height,width)
    s=session(mode,height,width,request(first,mode+'-v2'))
    r=rects(s,width,height,1)
    s.lua.execute(Path(__file__).with_name('quartz.lua').read_text(encoding='utf-8'))
    for rel in ['Quartz/Quartz.lua','Quartz/libs/LibWindow-1.1/LibWindow-1.1.lua','Quartz/CastBarTemplate.lua','Quartz/modules/Player.lua','Quartz/modules/Target.lua','Quartz/modules/Focus.lua','Quartz/modules/SwingForever.lua']:
        load(s,rel)
    s.lua.execute("""
      TEST_quartz:OnInitialize()
      for _,m in pairs(TEST_quartz.modules) do m:OnInitialize() end
      TEST_quartz:OnEnable();TEST_quartz.modules.Swing:OnEnable()
    """)
    for ui in (.64,1,.8):
        s.g.TEST_ui=ui;s.fire('UI_SCALE_CHANGED')
        bars={}
        for role in ('Player','Target','Focus'):
            b=s.g.TEST_quartz.modules[role].Bar
            eff=b.GetEffectiveScale(b)/(768/height)
            assert b.pos[1]==b.pos[3]=='TOP'
            bars[role]=(width/2+b.pos[4]*eff-b.GetWidth(b)*eff/2,-b.pos[5]*eff,b.GetWidth(b)*eff,b.GetHeight(b)*eff)
        assert abs(bars['Target'][1]-bars['Focus'][1])<1e-6
        for role in ('Target','Focus'):
            label='대상' if role=='Target' else '주시 대상'
            assert abs(bars[role][0]-r[label][0])<1e-6
            assert all(not overlaps(bars[role],a) for a in r.values())
        assert bars['Player'][1]>height/2
        for a in r.values():assert not overlaps(bars['Player'],a)
        swing=s.g.Quartz3SwingBar
        eff=swing.GetEffectiveScale(swing)/(768/height)
        assert abs(swing.GetWidth(swing)*eff-(bars['Player'][2]-8))<1e-6
        assert abs(swing.GetHeight(swing)*eff-4)<1e-6
        assert swing.pos[1]=='TOP' and swing.pos[3]=='BOTTOM' and swing.pos[5]==-4
        s.g.TEST_shielded=True;s.g.TEST_casting=True
        s.lua.execute("""
          local bar=TEST_quartz.modules.Target.Bar
          bar:UNIT_SPELLCAST_START('UNIT_SPELLCAST_START','target','guid',1234)
          assert(bar.Bar.timerDuration and bar.Shield.nativeAlpha==1)
          bar:UNIT_SPELLCAST_STOP('UNIT_SPELLCAST_STOP','target');TEST_casting=false;bar:UpdateUnit()
          assert(not bar.shown)
        """)
    s.g.TEST_combat=True
    barscale=s.g.TEST_quartz.modules.Player.Bar.scaleWrites
    s.g.TEST_ui=.64;s.fire('UI_SCALE_CHANGED')
    assert s.g.TEST_quartz.modules.Player.Bar.scaleWrites==barscale
    s.g.TEST_combat=False;s.fire('PLAYER_REGEN_ENABLED')
    assert s.g.TEST_quartz.modules.Player.Bar.scaleWrites==barscale+1
    s.lua.execute("""
      local swing=TEST_quartz.modules.Swing
      local bar=Quartz3SwingBar
      local status,window
      -- The status widget is the parent of the module's duration/remaining font strings.
      for i=1,30 do local key,value=debug.getupvalue(swing.PLAYER_SWING,i);if key=='swingstatusbar' then status=value end end
      for i=1,30 do local key,value=debug.getupvalue(swing.ApplySettings,i);if key=='standstill' then window=value end end
      assert(status and window)
      assert(swing.db.profile.dfStandStill==.5)  -- Core's default for the Swing namespace
      -- Not a hunter: no PLAYER_SWING, no bar (melee keep the game's own swing timer).
      swing:OnDisable();TEST_player.class='WARRIOR';swing.registered=nil;swing:OnEnable()
      assert(not swing.registered)
      swing:Unlock();assert(not bar.shown);swing:Lock()
      swing:OnDisable();TEST_player.class='HUNTER';swing:OnEnable()
      assert(swing.registered and swing.registered.PLAYER_SWING)
      -- Hunter: only the ranged cycle.
      TEST_clock=100;swing:PLAYER_SWING('PLAYER_SWING',4,Enum.PlayerSwingType.MainHand);assert(not bar.shown)
      swing:PLAYER_SWING('PLAYER_SWING',4,Enum.PlayerSwingType.OffHand);assert(not bar.shown)
      local width=bar:GetWidth()
      swing:PLAYER_SWING('PLAYER_SWING',2,Enum.PlayerSwingType.Ranged)
      assert(status.value==0 and bar.shown and bar.OnUpdate)
      assert(window.shown and math.abs(window.w-width*.25)<1e-9)  -- last 0.5 s of a 2 s cycle
      TEST_clock=101;bar.OnUpdate();assert(status.value==.5)
      swing:PLAYER_SWING('PLAYER_SWING',9,Enum.PlayerSwingType.MainHand);assert(status.value==.5)
      swing:PLAYER_SWING('PLAYER_SWING',{secret=true},Enum.PlayerSwingType.Ranged);assert(status.value==.5)
      -- The shot comes late (the player moved): the bar stays full until the next shot.
      TEST_clock=102.5;bar.OnUpdate();assert(status.value==1 and bar.shown and bar.OnUpdate)
      TEST_clock=103.9;bar.OnUpdate();assert(status.value==1 and bar.shown)
      swing:PLAYER_SWING('PLAYER_SWING',2,Enum.PlayerSwingType.Ranged);assert(status.value==0 and bar.shown)
      -- Overdue by more than a whole cycle: auto shot stopped, the bar hides.
      TEST_clock=108.1;bar.OnUpdate();assert(not bar.shown and not bar.OnUpdate)
      swing.db.profile.dfStandStill=3;swing:PLAYER_SWING('PLAYER_SWING',2,Enum.PlayerSwingType.Ranged)
      assert(window.shown and math.abs(window.w-width)<1e-9)  -- window longer than the cycle: whole bar
      swing.db.profile.dfStandStill=0;swing:ApplySettings();assert(not window.shown)
      swing.db.profile.dfStandStill=.5;swing:ApplySettings();assert(window.shown)
      swing:PLAYER_SWING('PLAYER_SWING',0,Enum.PlayerSwingType.Ranged);assert(not bar.shown and not bar.OnUpdate and status.value==0)
      -- Unlocked: a full sample cycle with its window; locked again: hidden.
      swing:Unlock();assert(bar.shown and status.value==1 and window.shown)
      TEST_clock=120;bar.OnUpdate();assert(bar.shown)
      swing:Lock();assert(not bar.shown)
      swing:PLAYER_SWING('PLAYER_SWING',3,Enum.PlayerSwingType.Ranged)
      swing:OnDisable();assert(not bar.shown and status.value==0 and not bar.OnUpdate)
      swing:OnEnable();swing:PLAYER_SWING('PLAYER_SWING',3,Enum.PlayerSwingType.Ranged)
      assert(bar.shown and status.value==0)
      local db=swing.db.profile;db.swingposition='top';db.swinggap=-4;swing:ApplySettings()
      assert(bar.pos[1]=='BOTTOM' and bar.pos[3]=='TOP')
      TEST_clock=TEST_clock+1.5;bar.OnUpdate();assert(status.value==.5)
      -- swing above the bar (a module setting): a UI scale change rescales the Player bar and the swing bar with it.
      local player=TEST_quartz.modules.Player
      player.db.profile.scale=player.db.profile.scale*2;player.Bar:ApplySettings()
      assert(bar.scale==player.db.profile.scale)
      swing:OnDisable()
      Enum.PlayerSwingType=nil  -- a client without the enum: the module falls back to 2 = ranged
    """)
    load(s,'Quartz/modules/SwingForever.lua')
    s.lua.execute("""
      local swing=TEST_quartz.modules.Swing
      swing:OnInitialize();swing:OnEnable()
      local bar=Quartz3SwingBar
      swing:PLAYER_SWING('PLAYER_SWING',2,0);assert(not bar.shown)
      swing:PLAYER_SWING('PLAYER_SWING',2,1);assert(not bar.shown)
      swing:PLAYER_SWING('PLAYER_SWING',2,2);assert(bar.shown)
      swing:OnDisable()
      Enum.PlayerSwingType={MainHand=1,OffHand=2,Ranged=3}
    """)
    print('PASS',mode,width,'native Quartz/LibWindow three cast rectangles, shield/start/stop; Player scale follows Swing; hunter-only ranged cycle, stand-still window, late shot kept full, unlock preview, enum fallback, invalid/disable and V1 top')
print('PASS native Quartz Swing and cast consumers')

R=runpy.run_path(str(ROOT/'Collection/tests/pitbull4runtime/run.py'),run_name='aura_harness')
def merge(lua,target,src):
    for key,value in src.items():
        if isinstance(value,dict):
            if target[key] is None:target[key]=lua.table()
            merge(lua,target[key],value)
        else:target[key]=value

for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160),('uhd',3862,2160)]:
    old=session(mode,height,width)
    src=session(mode,height,width,request(old,mode+'-v2'))
    profile=src.sv('PitBull4DB')['profiles']['Default']
    rect=rects(src,width,height,1)
    q=src.sv('Quartz3DB')['namespaces']['Player']['profiles']['Default']
    # the Quartz Player bar with its icon on the left, in the cast row under the player frame
    pix=768/height
    foot=(width/2+q['x']/pix-q['w']/2-q['h']-q['icongap'],-q['y']/pix,q['w']+q['h']+q['icongap'],q['h'])
    all_aura=[]
    for label in ['플레이어','대상','플레이어의 소환수','주시 대상','대상의 소환수']:
        row=profile['units'][label];layout=row['layout'];left,top,w,h=rect[label]
        lua=R['aura_runtime']();g=lua.globals()
        g.PitBull4.GetModule=lambda *_:g.Aura
        g.PitBull4.db=lua.table_from({'profile':profile},recursive=True)
        cfg=src.sv('PitBull4DB')['namespaces']['Aura']['profiles']['Default']['layouts'][layout]
        merge(lua,g.DB,cfg)
        g.FRAME.classification=label;g.FRAME.classification_db=lua.table_from(row,recursive=True)
        g.TEST_width=w;g.TEST_height=h
        lua.execute("""
          FRAME.on_GetWidth=function() return TEST_width end
          FRAME.on_GetHeight=function() return TEST_height end
          function Aura:GetLayoutDB() return DB end
          FRAME.aura_buffs={};FRAME.aura_debuffs={};FRAME.masque_group=false
          for _,kind in ipairs({'buff','debuff'}) do
            local max=kind=='buff' and DB.max_buffs or DB.max_debuffs
            for i=1,max*2 do
              local f=make_obj('AuraIcon');f.is_mine=i<=max
              FRAME['aura_'..(kind=='buff' and 'buffs' or 'debuffs')][i]=f
              f.on_SetPoint=function(self,p,relative,anchor,x,y) self.placement={p,anchor,x,y} end
              f.on_SetWidth=function(self,v) self.width=v end
              f.on_SetHeight=function(self,v) self.height=v end
            end
          end
        """)
        R['load'](lua,'Modules/Aura/Layout.lua')
        lua.execute('Aura:LayoutAuras(FRAME)')
        for kind in ('buffs','debuffs'):
            for icon in g.FRAME['aura_'+kind].values():
                a=(left+icon.placement[3],top-icon.placement[4]-icon.height,icon.width,icon.height)
                assert a[0]>=left-1e-6 and a[0]+a[2]<=left+w+1e-6 and a[1]>=0
                assert not overlaps(a,foot),(mode,label,'foot',a,foot)
                assert all(not overlaps(a,b) for b in rect.values()),(mode,label,a)
                for owner,b in all_aura:
                    if owner!=label:assert not overlaps(a,b),(mode,label,owner,a,b)
                all_aura.append((label,a))
        lua.execute("""
          CONTAINERS={};local create=CreateFrame
          function CreateFrame(kind,...)
            local c=create(kind,...)
            if kind=='AuraContainer' then
              CONTAINERS[#CONTAINERS+1]=c;c.groups={}
              local add=c.on_AddAuraGroup
              c.on_AddAuraGroup=function(self,key,filter,spec) self.groups[key]={spec=spec};return add(self,key,filter,spec) end
              c.on_SetAuraGroupLayout=function(self,key,layout) self.groups[key].spec.layout=layout end
              c.on_SetAuraGroupMaxFrameCount=function(self,key,n) self.groups[key].spec.maxFrameCount=n end
              c.on_SetPoint=function(self,...) self.placement={...} end
              c.on_SetFlowLayoutMaximumLineSize=function(self,v) self.width=v end
            end
            return c
          end
          TEST_combat=true;Aura:UpdateNativeBuffs(FRAME,DB);Aura:UpdateNativeDebuffs(FRAME,DB)
          assert(#CONTAINERS==2)
        """)
        bands=[]
        for container in g.CONTAINERS.values():
            x=y=rowheight=maximum=0
            for group in sorted(container.groups.values(),key=lambda v:v.spec.layout.layoutIndex):
                spec=group.spec;ly=spec.layout
                if ly.forceNewLine and x>0:y+=rowheight+ly.lineSpacing;x=0;rowheight=0
                for i in range(int(spec.maxFrameCount)):
                    if x>0 and x+ly.elementWidth>container.width+1e-6:y+=rowheight+ly.lineSpacing;x=0;rowheight=0
                    maximum=max(maximum,y+ly.elementHeight);rowheight=max(rowheight,ly.elementHeight);x+=ly.elementWidth+ly.elementSpacing
            band=(left,top-container.placement[5]-maximum,w,maximum)
            assert band[1]>=0 and not overlaps(band,foot),(mode,label,band,foot)
            bands.append(band)
        assert bands[1][1]+bands[1][3]<=bands[0][1]+1e-6
    print('PASS',mode,width,'five Aura owners: normal max own+others native Lua rectangles; restricted public container bounds; no row/body/under-foot cast or swing overlap')
print('PASS V2 aura consumers; restricted live renderer geometry remains client boundary')

# Preset screen map (the base preset and the layout-only <preset>-v2, the same layout): Grid2 at its 40-player maximum and its party
# window next to every other preset frame, physical pixels, top-left origin. Aura blocks are the native
# (combat) container bands of PitBull4's Aura module run on the profile: both groups (own and others') at
# their own maximum, and the companion avoidance rules once with the avoided frames hidden and once shown.
import re as _re
def _point(W,H,rel,anchor,x,y,w,h):
    rx=0 if 'LEFT' in rel else W if 'RIGHT' in rel else W/2
    ry=0 if 'TOP' in rel else H if 'BOTTOM' in rel else H/2
    px,py=rx+x,ry-y
    left=px-w if 'RIGHT' in anchor else px if 'LEFT' in anchor else px-w/2
    top=py-h if 'BOTTOM' in anchor else py if 'TOP' in anchor else py-h/2
    return (left,top,w,h)

def _grid2_rects(values,frame,W,H,factor,units):
    cols,rows=(8,5) if units==40 else (1,5)
    pad=values['Padding']
    w=cols*frame['frameWidth']+(cols-1)*pad; h=rows*frame['frameHeight']+(rows-1)*pad
    return _point(W,H,values['anchor'],values['anchor'],values['PosX']/factor,values['PosY']/factor,w,h)

def aura_bands(profile,cfg,label,row,frame,shown):
    """Native buff and debuff container bands of unit `label` (Aura/Forever.lua through Aura/Layout.lua)."""
    left,top,w,h=frame
    lua=R['aura_runtime']();g=lua.globals()
    g.PitBull4.GetModule=lambda *_:g.Aura
    g.PitBull4.db=lua.table_from({'profile':profile},recursive=True)
    merge(lua,g.DB,cfg)
    g.FRAME.classification=label;g.FRAME.classification_db=lua.table_from(row,recursive=True)
    g.TEST_width=w;g.TEST_height=h;g.TEST_shown=shown
    rule=(profile.get('dfAuraGeometry') or {}).get(label) or {}
    if rule.get('avoid_frame'):
        lua.execute("_G[%r]={IsShown=function() return TEST_shown end,HookScript=function() end}"%rule['avoid_frame'])
    lua.execute("""
      FRAME.on_GetWidth=function() return TEST_width end
      FRAME.on_GetHeight=function() return TEST_height end
      function Aura:GetLayoutDB() return DB end
      FRAME.aura_buffs={};FRAME.aura_debuffs={};FRAME.masque_group=false
      CONTAINERS={};local create=CreateFrame
      function CreateFrame(kind,...)
        local c=create(kind,...)
        if kind=='AuraContainer' then
          CONTAINERS[#CONTAINERS+1]=c;c.groups={}
          local add=c.on_AddAuraGroup
          c.on_AddAuraGroup=function(self,key,filter,spec) self.groups[key]={spec=spec};return add(self,key,filter,spec) end
          c.on_SetAuraGroupLayout=function(self,key,layout) self.groups[key].spec.layout=layout end
          c.on_SetAuraGroupMaxFrameCount=function(self,key,n) self.groups[key].spec.maxFrameCount=n end
          c.on_SetPoint=function(self,...) self.placement={...} end
          c.on_SetFlowLayoutMaximumLineSize=function(self,v) self.width=v end
        end
        return c
      end
    """)
    R['load'](lua,'Modules/Aura/Layout.lua')
    lua.execute("TEST_combat=true;Aura:UpdateNativeBuffs(FRAME,DB);Aura:UpdateNativeDebuffs(FRAME,DB);assert(#CONTAINERS==2)")
    bands=[]
    for container in g.CONTAINERS.values():
        x=y=rowheight=maximum=0
        for group in sorted(container.groups.values(),key=lambda v:v.spec.layout.layoutIndex):
            spec=group.spec;ly=spec.layout
            if ly.forceNewLine and x>0:y+=rowheight+ly.lineSpacing;x=0;rowheight=0
            for i in range(int(spec.maxFrameCount)):
                if x>0 and x+ly.elementWidth>container.width+1e-6:y+=rowheight+ly.lineSpacing;x=0;rowheight=0
                maximum=max(maximum,y+ly.elementHeight);rowheight=max(rowheight,ly.elementHeight);x+=ly.elementWidth+ly.elementSpacing
        point,_,anchor,ox,oy=[container.placement[i] for i in range(1,6)]
        bx=left+ox+(w if 'RIGHT' in anchor else 0)-(container.width if 'RIGHT' in point else 0)
        by=(top+h-oy if 'BOTTOM' in anchor else top-oy)-(maximum if 'BOTTOM' in point else 0)
        bands.append((bx,by,container.width,maximum))
    return bands

TOTEM_BUTTON={'fhd':44,'qhd':52,'uhd':72}  # Presets/<mode>.lua Dominos frames.totem scale pixel*button/30
ACTION_BAR_TOP={'fhd':802,'qhd':1118,'uhd':1724}  # Presets/<mode>.lua Dominos frames[1] y
PET_BAR={'fhd':(218,490,22,238),'qhd':(256,806,26,278),'uhd':(212,1564,34,358)}  # Presets/<mode>.lua fitPet x, y, side, span
def default_screen_map(mode,width,height,v2=False):
    s=session(mode,height,width)
    if v2:s=session(mode,height,width,request(s,mode+'-v2'))
    factor=768/height;pixel=factor
    p=s.sv('PitBull4DB')['profiles']['Default'];ns=s.sv('PitBull4DB')['namespaces']
    rects={}
    for name,u in p['units'].items():
        if not u.get('enabled'):continue
        lay=p['layouts'][u['layout']]
        w,h=lay['size_x']*u.get('size_x',1),lay['size_y']*u.get('size_y',1)
        r=_point(width,height,u['relative_point'],u['anchor'],u['position_x']/pixel,u['position_y']/pixel,w,h)
        rects['unit '+name]=r
        cfg=ns['Aura']['profiles']['Default']['layouts'].get(u['layout']) or {}
        if cfg.get('enabled'):
            for shown in (False,True):
                for i,band in enumerate(aura_bands(p,cfg,name,u,r,shown)):
                    rects['auras %s %s %s'%(name,('buffs','debuffs')[i],'avoided shown' if shown else 'alone')]=band
    for name,g in p['groups'].items():
        if not g.get('enabled'):continue
        lay=p['layouts'][g['layout']]
        w,h=lay['size_x']*g['size_x'],lay['size_y']*g['size_y']
        top=_point(width,height,g['relative_point'],g['anchor'],g['position_x']/pixel,g['position_y']/pixel,w,h)
        rects['group '+name]=(top[0],top[1],w,4*h+3*g['vertical_spacing'])
    for name,q in s.sv('Quartz3DB')['namespaces'].items():
        q=q['profiles']['Default']
        if 'point' not in q or 'w' not in q:continue
        icon=q['h']+q.get('icongap',0)
        r=_point(width,height,q['point'],q['point'],q['x']/pixel,q['y']/pixel,q['w'],q['h'])
        rects['quartz '+name]=(r[0]-icon,r[1],r[2]+icon,r[3])
    src=(A/'!DevilForever_Core/Presets'/(mode+'.lua')).read_text(encoding='utf-8')
    d=plain(s.core.Presets.Get(s.core.Presets,mode))
    for key,e in d['edits'].items():
        if 'position' in e and 'size' in e and key.startswith(('appearance.','statusstrip.')):
            pos=e['position']
            rects['edit '+key]=_point(width,height,pos['relativePoint'],pos['point'],pos['x'],pos['y'],e['size']['width'],e['size']['height'])
    det=(A/'DevilForever_DetailsLayout/Layout.lua').read_text(encoding='utf-8')
    for i,(x,y,w,h) in enumerate(_re.findall(r'\{(\d+), (\d+), (\d+), (\d+)\}',_re.search(mode+r' = \{(.*)\},',det).group(1))):
        rects['details %d'%(i+1)]=(int(x),int(y),int(w),int(h))
    layout=plain(s.core.Presets.Get(s.core.Presets,mode+'-v2')) if v2 else d
    grid={}
    for f in d['fragments'].values():
        if f['folder']=='Grid2':grid.setdefault(f['namespace'],{}).update(f['values'])  # base values, then the V2 layout's spot
    for f in layout['fragments'].values():
        if f['folder']=='Grid2' and f['namespace']=='Grid2Layout':grid['Grid2Layout'].update(f['values'])  # V2: the window spot only
    raid=_grid2_rects(grid['Grid2Layout'],grid['Grid2Frame'],width,height,factor,40)
    party=_grid2_rects(grid['Grid2Layout'],grid['Grid2Frame'],width,height,factor,5)
    # Dominos totem bar (the highest fragment version of the layout wins) and the PitBull4 totem timer
    totem=None
    for f in sorted(layout['fragments'].values(),key=lambda f:f['version']):
        if f['folder']=='Dominos' and 'totem' in (f['values'].get('frames') or {}):totem=f['values']['frames']['totem']
    button=TOTEM_BUTTON[mode]
    rects['dominos totem']=_point(width,height,totem['relPoint'],totem['point'],totem['x']*totem['scale']/pixel,
                                  totem['y']*totem['scale']/pixel,6*button+5*2*button/30,button)
    # Dominos pet bar: its spot from the base preset's own entry (the fitPet spot PET_BAR) moved by the entry change
    pet=None
    for f in sorted(layout['fragments'].values(),key=lambda f:f['version']):
        if f['folder']=='Dominos' and 'pet' in (f['values'].get('frames') or {}):pet=f['values']['frames']['pet']
    old=[f for f in d['fragments'].values() if f['folder']=='Dominos' and f['version']==1
         and 'pet' in (f['values'].get('frames') or {})][0]['values']['frames']['pet']
    eff=pet['scale']/pixel;bx,by,bside,bspan=PET_BAR[mode];count=pet['columns']
    side=min(bside,(bspan-2*(count-1))/count)
    px=bx+(pet['x']-old['x'])*eff+(width/2 if pet.get('relPoint')=='TOP' else 0)
    rects['dominos pet']=(px,by-(pet['y']-old['y'])*eff,count*side+2*(count-1),side)
    timer=ns['Totems']['profiles']['Default']['layouts']['보통']
    icon=15*timer['size'];span=4*icon+3*timer['totem_spacing']*icon/50
    outside=p['layouts']['보통'].get('indicator_root_outside_margin',0);pl=rects['unit 플레이어']
    if timer['location']=='out_bottom_left':
        tx,ty=pl[0]-outside,pl[1]+pl[3]+outside
    else:
        assert timer['location']=='out_right_bottom',timer['location']
        tx,ty=pl[0]+pl[2]+outside,pl[1]+pl[3]+outside-icon
    rects['totem timer']=(tx+timer.get('dfOffsetX',0),ty+timer.get('dfOffsetY',0),span,icon)
    return rects,raid,party

# Grid2 left of the quest tracker (Blizzard's objective tracker, right side; top at about 24 % and its
# left edge about 23 % of the screen height from the right): window top on the tracker's top, right edge
# on the tracker's left edge, square cells; the window grows down and left, clear of every preset rectangle.
TRACKER={'fhd':(259,247,88),'qhd':(346,330,116),'uhd':(518,495,176)}
KNOWN_OVERLAP={  # 88/116/176 px cells at the tracker spot, measured; waiting for the user's in-game feedback
    'fhd 1920 party':[],
    'fhd 1920 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'quartz Focus', 'quartz Target', 'unit 대상', 'unit 대상의 대상', 'unit 대상의 대상의 대상', 'unit 대상의 소환수', 'unit 대상의 소환수의 대상', 'unit 대상의 소환수의 대상의 대상', 'unit 주시 대상', 'unit 주시 대상의 대상', 'unit 주시 대상의 대상의 대상'],
    'qhd 2560 party':[],
    'qhd 2560 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'unit 대상', 'unit 대상의 소환수', 'unit 주시 대상'],
    'uhd 3840 party':[],
    'uhd 3840 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'unit 대상', 'unit 대상의 소환수', 'unit 주시 대상'],
    'uhd 3862 party':[],
    'uhd 3862 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'unit 대상', 'unit 대상의 소환수', 'unit 주시 대상'],
}
for v2 in (False,True):
    for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160),('uhd',3862,2160)]:
        rects,raid,party=default_screen_map(mode,width,height,v2)
        assert len([k for k in rects if k.startswith('group ')])==4,sorted(rects)
        top,margin,cell=TRACKER[mode]
        for kind,box in (('raid',raid),('party',party)):
            assert box[0]>=0 and box[1]>=0 and box[0]+box[2]<=width and box[1]+box[3]<=height,(mode,v2,box)
            hits={k for k,r in rects.items() if overlaps(box,r)}
            # Known overlaps at this spot with the user's doubled square cells; size and shape wait for
            # the user's in-game feedback, so the test pins exactly what the window covers today.
            known=set(KNOWN_OVERLAP['%s %d %s'%(mode,width,kind)])
            assert hits==known,(mode,width,v2,kind,box,sorted(hits))
            assert abs(box[1]-top)<1e-6 and abs(box[0]+box[2]-(width-margin))<1e-6,(mode,v2,box)
        print('PASS',mode,width,'-v2' if v2 else 'base','Grid2 40-player window %s and party window %s left of the quest tracker, tops aligned (cells %d px), pinned overlaps raid %d / party %d'%(tuple(round(v) for v in raid),tuple(round(v) for v in party),cell,len(KNOWN_OVERLAP['%s %d raid'%(mode,width)]),len(KNOWN_OVERLAP['%s %d party'%(mode,width)])))
print('PASS preset Grid2 placement left of the quest tracker (base preset and -v2)')

# Details windows 1 (damage) and 2 (Tiny Threat) side by side: the row (title strips included) is as wide and
# as tall as chat panel 1 and starts on its left edge, clear of every preset rectangle, both Grid2 windows
# and the quest tracker column (from the tracker's top down to the section's upper strip).
det_src=(A/'DevilForever_DetailsLayout/Layout.lua').read_text(encoding='utf-8')
TITLE={k:int(v) for k,v in _re.findall(r'(fhd|qhd|uhd) = (\d+)',_re.search(r'titleSpace = \{(.*?)\}',det_src).group(1))}
for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160),('uhd',3862,2160)]:
    rects,raid,party=default_screen_map(mode,width,height)
    one,two=rects['details 1'],rects['details 2'];chat=rects['edit appearance.chat1'];title=TITLE[mode]
    row=(one[0],one[1]-title,two[0]+two[2]-one[0],one[3]+title)
    assert two[1]==one[1] and two[3]==one[3] and two[0]-(one[0]+one[2])==2,(mode,one,two)
    assert (row[0],row[2],row[3])==(chat[0],chat[2],chat[3]),(mode,width,row,chat)
    top,margin,cell=TRACKER[mode]
    upper=rects['edit appearance.upper']
    others=dict((k,r) for k,r in rects.items() if not k.startswith('details '))
    others.update({'grid2 raid':raid,'grid2 party':party,'quest tracker':(width-margin,top,margin,upper[1]-top)})
    for i,box in enumerate((one,two),1):
        boxed=(box[0],box[1]-title,box[2],box[3]+title)
        assert 0<=boxed[0] and boxed[0]+boxed[2]<=width and 0<=boxed[1] and boxed[1]+boxed[3]<=height,(mode,i,boxed)
        hits=sorted(k for k,r in others.items() if overlaps(boxed,r))
        assert hits==[],(mode,width,i,boxed,hits)
    print('PASS',mode,width,'Details row %s (title %d px) = chat panel 1 width/height, left edges aligned, overlaps none of %d rects'%(row,title,len(others)))

core_default=_re.search(r'dfStandStill = ([0-9.]+)',(A/'!DevilForever_Core/Defaults/Quartz.lua').read_text(encoding='utf-8')).group(1)
module_default=_re.search(r'dfStandStill = ([0-9.]+),',(A/'Quartz/modules/SwingForever.lua').read_text(encoding='utf-8')).group(1)
assert core_default==module_default=='0.5',(core_default,module_default)
print('PASS stand-still default: Core Quartz defaults and the Swing module defaults both',core_default)

# Base preset = V2: focus frame centred, one aura table for player/target/focus, target-pet chain shown,
# square Grid2 cells.
for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160),('uhd',3862,2160)]:
    rects,raid,party=default_screen_map(mode,width,height)
    s=session(mode,height,width)
    p=s.sv('PitBull4DB')['profiles']['Default'];aura=s.sv('PitBull4DB')['namespaces']['Aura']['profiles']['Default']['layouts']
    assert p['dfLayoutV2'] is True
    focus=rects['unit 주시 대상']
    assert abs(focus[0]+focus[2]/2-width/2)<1e-6,(mode,width,focus)
    player,target=rects['unit 플레이어'],rects['unit 대상']
    assert abs((focus[0]-(player[0]+player[2]))-(target[0]-(focus[0]+focus[2])))<1e-6,(mode,player,focus,target)
    assert p['units']['주시 대상']['layout']=='주시' and p['units']['플레이어의 소환수']['layout']=='소환수와 주시'
    assert aura['보통']==aura['대상'],(mode,aura['보통'],aura['대상'])
    assert aura['주시']==aura['소환수와 주시'],(mode,aura['주시'],aura['소환수와 주시'])  # focus = pet aura icons and rows
    assert (aura['대상']['max_buffs'],aura['대상']['max_debuffs'])==(14,16)
    assert aura['소환수와 주시']==aura['데빌 파티']  # pets keep the party aura table
    size={'fhd':(20,32),'qhd':(27,43),'uhd':(40,64)}[mode]
    assert (aura['보통']['layout']['buff']['size'],aura['보통']['layout']['debuff']['my_size'])==size
    assert p['dfAuraGeometry']['주시 대상']==p['dfAuraGeometry']['플레이어의 소환수']=={'above':True,'width':p['layouts']['소환수와 주시']['size_x']},(mode,p['dfAuraGeometry']['주시 대상'])
    pet=rects['unit 대상의 소환수']
    for label,unit in (('대상의 소환수의 대상','targetpettarget'),('대상의 소환수의 대상의 대상','targetpettargettarget')):
        row=p['units'][label]
        assert row['enabled'] is True and row['unit']==unit and row['layout']=='소환수와 주시 아래',(label,row)
        r=rects['unit '+label]
        assert pet[0]-1e-6<=r[0] and r[0]+r[2]<=pet[0]+pet[2]+1e-6 and r[1]>=pet[1]+pet[3],(label,r,pet)
    assert p['units']['대상의 대상']['enabled'] is True and p['units']['대상의 대상의 대상']['enabled'] is True
    assert p['dfLayoutRevision']==s.core.Presets.layoutV2Revision==7
    # player and target aura rows at the same height above their frames (no raise)
    assert p['dfAuraGeometry']['플레이어']=={'above':True,'width':player[2]}==p['dfAuraGeometry']['대상'],(mode,p['dfAuraGeometry']['플레이어'])
    for kind in ('buffs','debuffs'):
        a,b=rects['auras 플레이어 %s alone'%kind],rects['auras 대상 %s alone'%kind]
        assert abs(a[1]-b[1])<1e-6 and abs(a[3]-b[3])<1e-6,(mode,kind,a,b)
    # Dominos totem bar and pet bar in the row under the player frame (between the cast row with its swing
    # line and the action bars), each ending at the player frame's right edge (a class shows one of them);
    # the PitBull4 totem timer 8 px left of the totem bar, vertically centred on it; clear of everything
    bar,timer,petbar=rects['dominos totem'],rects['totem timer'],rects['dominos pet']
    q=rects['quartz Player'];swing=q[1]+q[3]+4+4
    right=player[0]+player[2]
    assert abs(bar[0]+bar[2]-right)<1e-6 and abs(petbar[0]+petbar[2]-right)<1e-6,(mode,bar,petbar,player)
    for b in (bar,petbar):assert b[1]>=swing and b[1]+b[3]<=ACTION_BAR_TOP[mode],(mode,b,swing)
    assert abs(petbar[1]+petbar[3]/2-(bar[1]+bar[3]/2))<1e-6,(mode,petbar,bar)
    assert abs(timer[0]+timer[2]+8-bar[0])<1e-6 and abs(timer[1]+timer[3]/2-(bar[1]+bar[3]/2))<1e-6,(mode,timer,bar)
    assert timer[1]+timer[3]<=ACTION_BAR_TOP[mode] and timer[0]>=0,(mode,timer)
    # the aux panel is the art band behind the class and totem bar row;
    # the totem bar and the pet bar share the row (never shown together)
    for name in ('dominos totem','totem timer','dominos pet'):
        shared={'dominos totem','dominos pet'} if name!='totem timer' else set()
        hits=[k for k,r in rects.items() if k not in ({name,'edit appearance.aux'}|shared) and overlaps(rects[name],r)]
        assert not hits,(mode,name,rects[name],hits)
    gap={'fhd':34,'qhd':38,'uhd':44}[mode]  # one frame gap (cast height + 4) between player, focus and target
    assert abs(focus[0]-(player[0]+player[2])-gap)<1e-6 and abs(target[0]-(focus[0]+focus[2])-gap)<1e-6,(mode,player,focus,target)
    print('PASS',mode,width,'V2 default: focus centred %.0f with equal side gaps, player/target aura rows level, Dominos totem bar %s and pet bar ending at the player frame right edge, the totem timer %s left of the totem bar (clear of every rectangle), one aura table %s, target-pet chain under the target-pet'%(focus[0]+focus[2]/2,tuple(round(v) for v in bar),tuple(round(v) for v in timer),size))
src={m:(A/'!DevilForever_Core/Presets'/(m+'.lua')).read_text(encoding='utf-8') for m in ('fhd','qhd','uhd')}
for m,cell in (('fhd',88),('qhd',116),('uhd',176)):
    assert '["frameWidth"]=%d,["frameHeight"]=%d'%(cell,cell) in src[m] and '["anchor"]="TOPRIGHT"' in src[m],m
print('PASS Grid2 cells square (fhd 88, qhd 116, uhd 176) with a TOPRIGHT anchor')

# Name text of the player and target frames grows with the frame (main frame height / companion
# frame height); pet, focus, small and party frames keep the preset size; bar texts unchanged.
NAME_FONT={'fhd':16,'qhd':18,'uhd':22}
FRAME_HEIGHTS={'fhd':(72,56),'qhd':(96,74),'uhd':(144,112)}
for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160)]:
    main,companion=FRAME_HEIGHTS[mode]
    fresh=session(mode,height,width)
    for label,s in (('layout',fresh),):
        p=s.sv('PitBull4DB')['profiles']['Default']
        texts=s.sv('PitBull4DB')['namespaces']['LuaTexts']['profiles']['Default']['layouts']
        assert p['dfLayoutV2'] is True,(mode,label)
        def px(layout,element):
            return 14*p['layouts'][layout]['font_size']*texts[layout]['elements'][element]['size']
        for layout in ('보통','대상'):
            assert (p['layouts'][layout]['size_y'],p['layouts']['소환수와 주시']['size_y'])==(main,companion)
            assert abs(px(layout,'Lua:이름')-NAME_FONT[mode]*main/companion)<1e-6,(mode,label,layout,px(layout,'Lua:이름'))
            for element,size in (('Lua:생명력',.9),('Lua:마력',.75),('Lua:직업',.85),('Lua:백분율',.8),('Lua:레벨',.8)):
                assert abs(px(layout,element)-NAME_FONT[mode]*size)<1e-6,(mode,label,layout,element)
        for layout in ('소환수와 주시','주시'):
            assert abs(px(layout,'Lua:이름')-NAME_FONT[mode])<1e-6,(mode,label,layout,px(layout,'Lua:이름'))
        assert abs(px('대상의대상','Lua:이름')-NAME_FONT[mode]*.75)<1e-6,(mode,label)
        for layout in ('보통','대상','소환수와 주시','주시'):  # level and name: one centred text
            el=texts[layout]['elements']
            assert el['Lua:레벨']['enabled'] is False and el['Lua:이름']['location']=='center',(mode,label,layout)
            assert el['Lua:이름']['code']=='Outline() return "%s %s",Level(unit),Name(unit)' and el['Lua:이름']['events']['UNIT_LEVEL'],(mode,label,layout)
        print('PASS',mode,label,'name text: player/target %.2f px (x %d/%d), pet/focus %d px, bar texts unchanged'%(NAME_FONT[mode]*main/companion,main,companion,NAME_FONT[mode]))
    # A profile written before this change (name size 1 on the player/target frames) gets the new size
    # through the layout request (<preset>-v2: the layout catch-up, also /dfp preset + /dfp go).
    old_profile=carry(session(mode,height,width))
    for layout in ('보통','대상'):
        old_profile['PitBull4DB']['namespaces']['LuaTexts']['profiles']['Default']['layouts'][layout]['elements']['Lua:이름']['size']=1
    before=session(mode,height,width,old_profile)
    assert before.sv('PitBull4DB')['namespaces']['LuaTexts']['profiles']['Default']['layouts']['보통']['elements']['Lua:이름']['size']==1,mode
    after=session(mode,height,width,request(before,mode+'-v2'))
    got=after.sv('PitBull4DB')['namespaces']['LuaTexts']['profiles']['Default']['layouts']['보통']['elements']['Lua:이름']['size']
    assert abs(got-main/companion)<1e-6,(mode,got)
    print('PASS',mode,'existing profile: name size 1 -> %.3f after the %s-v2 request'%(got,mode))

# One player cast bar (Quartz): PitBull4's cast bar module and the player's cast texts are off in a fresh
# profile, and a profile that still has them on (an earlier build) gets them off through the layout request
# (<preset>-v2: the layout catch-up, also /dfp preset + /dfp go).
for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160)]:
    def cast_state(s):
        ns=s.sv('PitBull4DB')['namespaces']
        cb=ns['CastBar']['profiles']['Default'];tx=ns['LuaTexts']['profiles']['Default']['layouts']['보통']['elements']
        return (cb['global']['enabled'],cb['layouts']['보통']['enabled'],tx['Lua:시전']['enabled'],tx['Lua:시전시간']['enabled'])
    fresh=session(mode,height,width)
    assert cast_state(fresh)==(False,False,False,False),(mode,cast_state(fresh))
    old_profile=carry(session(mode,height,width))
    ns=old_profile['PitBull4DB']['namespaces']
    ns['CastBar']['profiles']['Default']['global']['enabled']=True
    ns['CastBar']['profiles']['Default']['layouts']['보통']['enabled']=True
    for element in ('Lua:시전','Lua:시전시간'):
        ns['LuaTexts']['profiles']['Default']['layouts']['보통']['elements'][element]['enabled']=True
    before=session(mode,height,width,old_profile)
    assert cast_state(before)==(True,True,True,True),(mode,cast_state(before))
    for target in ('-v2',):
        after=session(mode,height,width,request(session(mode,height,width,old_profile),mode+target))
        assert cast_state(after)==(False,False,False,False),(mode,target,cast_state(after))
        q=after.sv('Quartz3DB')['namespaces']['Player']['profiles']['Default']
        if target=='-v2':
            tq=after.sv('Quartz3DB')['namespaces']['Target']['profiles']['Default']
            assert (q['point'],q['y'],q['w'],q['h'])==(tq['point'],tq['y'],tq['w'],tq['h']),(mode,q,tq)  # same row and width as the target bar
            assert (q['iconposition'],q['texture'])==(tq['iconposition'],tq['texture'])
    print('PASS',mode,'one player cast bar (Quartz): PitBull4 cast bar and cast texts off, also after the -v2 request of an older profile')

# Layout catch-up after an update (Presets.lua): a collection PitBull4 profile below this build's revision of
# its version gets that version written in the same load, with no command, no reload and nothing pending.
# PitBull4's own saved variable shows the state only at its ADDON_LOADED, so targets that loaded before it
# (here Dominos and Grid2) get theirs at the next load by themselves; a state recorded by the last load
# starts the catch-up at Core's ready step, so every target gets it in that load. Fresh install: the fresh
# fragment path, nothing else. A profile without the layout flag: nothing.
ALL_TARGETS=('Dominos','Grid2','PitBull4','Quartz')  # alphabetical load order
def catch_lines(s):return [l for l in list(plain(s.g.TEST_prints).values()) if '배치' in l and '이 판에 맞춰' in l or '다음 접속 때 자동으로' in l]
def layout_state(s):
    p=s.sv('PitBull4DB')['profiles']['Default'];return p.get('dfLayoutV2'),p.get('dfLayoutRevision')
def revision_db(s):return s.sv('DevilForever_CoreDB').get('layoutRevision') or {}
base_def=None
for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160)]:
    probe=session(mode,height,width)
    for f in plain(probe.core.Presets.Get(probe.core.Presets,mode+'-v2'))['fragments'].values():
        ADDON_VERSIONS[f['folder']]=f['addonVersion']
    v2rev=probe.core.Presets.layoutV2Revision
    assert probe.core.Presets.layoutV1Revision is None and not probe.core.Presets.IsRegistered(probe.core.Presets,mode+'-v1')
    v2def=plain(probe.core.Presets.Get(probe.core.Presets,mode+'-v2'))
    totem_x=[f for f in v2def['fragments'].values() if f['folder']=='Dominos'][0]['values']['frames']['totem']['x']
    # fresh install: the fresh path writes New at the current revision; no catch-up, no line, nothing pending
    fresh=session(mode,height,width,after=ALL_TARGETS)
    assert layout_state(fresh)==(True,v2rev) and not catch_lines(fresh),(mode,layout_state(fresh),catch_lines(fresh))
    assert 'tried' not in revision_db(fresh) and 'due' not in revision_db(fresh) and 'pending' not in fresh.sv('DevilForever_ProfilesDB')
    assert revision_db(fresh)['seen']=={'v2':True,'revision':v2rev}
    current=carry(fresh)
    # same revision: nothing
    same=session(mode,height,width,current,after=ALL_TARGETS)
    assert not catch_lines(same) and 'tried' not in revision_db(same) and same.g.TEST_reloads==0
    # an older New profile, no state recorded by an earlier build: PitBull4 and Quartz in this load, Dominos
    # and Grid2 (loaded before PitBull4) at the next load, by themselves
    stale=copy.deepcopy(current);stale['PitBull4DB']['profiles']['Default']['dfLayoutRevision']=v2rev-1
    stale['DevilForever_CoreDB']['layoutRevision'].pop('seen')
    stale['DominosDB']=stale.get('DominosDB') or {};stale['Grid2DB']=stale.get('Grid2DB') or {}
    first=session(mode,height,width,stale,after=ALL_TARGETS)
    assert layout_state(first)==(True,v2rev),(mode,layout_state(first))  # PitBull4 written before it read its profile
    assert catch_lines(first)==['[DF 설정] 배치를 이 판에 맞춰 적용했습니다(PitBull4·Quartz) — Dominos 막대·Grid2 는 다음 접속 때 자동으로 적용됩니다.'],(mode,catch_lines(first))
    db=revision_db(first)
    assert db['tried']=={'Default|-v2':v2rev} and db['due']['name']==mode+'-v2' and sorted(db['due']['folders'])==['dominos','grid2'],db
    assert first.g.TEST_reloads==0 and 'pending' not in first.sv('DevilForever_ProfilesDB'),mode  # no reload, nothing blocks the switch
    second=session(mode,height,width,carry(first),after=ALL_TARGETS)
    assert catch_lines(second)==['[DF 설정] 배치를 이 판에 맞춰 적용했습니다(Dominos 막대·Grid2).'],(mode,catch_lines(second))
    assert 'due' not in revision_db(second) and second.g.TEST_reloads==0
    dominos=second.sv('DominosDB')['profiles']
    assert any(abs(prof.get('frames',{}).get('totem',{}).get('x',1e9)-totem_x)<1e-6 for prof in dominos.values()),(mode,list(dominos))
    third=session(mode,height,width,carry(second),after=ALL_TARGETS)
    assert not catch_lines(third) and 'due' not in revision_db(third)
    # the player's own request before the deferred part (/dfp preset <preset> + /dfp go): it supersedes the
    # catch-up, so the next load writes the requested preset to all four targets and drops the deferred part
    def dominos_totems(s):return [prof['frames']['totem'] for prof in s.sv('DominosDB')['profiles'].values() if 'totem' in prof.get('frames',{})]
    chose=session(mode,height,width,stale,after=ALL_TARGETS)
    assert 'due' in revision_db(chose)
    picked=request(chose,mode)
    own_load=session(mode,height,width,picked,after=ALL_TARGETS)
    assert 'due' not in revision_db(own_load) and layout_state(own_load)==(True,v2rev),(mode,revision_db(own_load),layout_state(own_load))
    assert dominos_totems(own_load) and all(abs(t['x']-totem_x)<1e-6 for t in dominos_totems(own_load)),(mode,dominos_totems(own_load))
    after_own=session(mode,height,width,carry(own_load),after=ALL_TARGETS)
    assert not catch_lines(after_own) and 'due' not in revision_db(after_own)
    # a later update (state recorded by the last load): every target in the same load, Dominos and Grid2 too
    later=carry(third);later['PitBull4DB']['profiles']['Default']['dfLayoutRevision']=v2rev-1
    later['DevilForever_CoreDB']['layoutRevision']['seen']['revision']=v2rev-1
    later['DevilForever_CoreDB']['layoutRevision'].pop('tried',None)
    one=session(mode,height,width,later,after=ALL_TARGETS)
    assert catch_lines(one)==['[DF 설정] 배치를 이 판에 맞춰 적용했습니다(Dominos 막대·Grid2·PitBull4·Quartz).'],(mode,catch_lines(one))
    assert layout_state(one)==(True,v2rev) and 'due' not in revision_db(one)
    # a profile still on the earlier second layout (dfLayoutV2 false, its own revision): the layout is written,
    # same load for PitBull4 and Quartz
    old=copy.deepcopy(current);old['PitBull4DB']['profiles']['Default']['dfLayoutV2']=False
    old['PitBull4DB']['profiles']['Default']['dfLayoutRevision']=4;old['DevilForever_CoreDB'].pop('layoutRevision',None)
    o=session(mode,height,width,old)
    assert layout_state(o)==(True,v2rev) and catch_lines(o)==['[DF 설정] 배치를 이 판에 맞춰 적용했습니다(PitBull4·Quartz).'],(mode,layout_state(o),catch_lines(o))
    # once per profile and revision: a profile still below after its attempt is left
    again=carry(first);again['PitBull4DB']['profiles']['Default']['dfLayoutRevision']=v2rev-1;again['DevilForever_CoreDB']['layoutRevision'].pop('due',None)
    again['DevilForever_CoreDB']['layoutRevision'].pop('seen',None)
    a=session(mode,height,width,again,after=ALL_TARGETS)
    assert layout_state(a)==(True,v2rev-1) and not catch_lines(a),(mode,catch_lines(a))
    # a PitBull4 profile the collection never laid out (no dfLayoutV2 flag): nothing
    foreign=copy.deepcopy(current);fp=foreign['PitBull4DB']['profiles']['Default']
    del fp['dfLayoutV2'];del fp['dfLayoutRevision'];foreign['DevilForever_CoreDB']['layoutRevision'].pop('seen',None)
    fs=session(mode,height,width,foreign,after=ALL_TARGETS)
    assert 'dfLayoutV2' not in fs.sv('PitBull4DB')['profiles']['Default'] and not catch_lines(fs)
    assert 'tried' not in revision_db(fs) and 'seen' not in revision_db(fs)
    assert not any(x.errors() for x in (fresh,same,first,second,third,one,o,a,fs))
    print('PASS',mode,'layout catch-up: older revision -> PitBull4/Quartz written in the same load and Dominos/Grid2 at the next load by themselves (no command, no reload, nothing pending); recorded state -> every target in one load; a profile on the earlier second layout -> the layout; once per revision; fresh install and foreign profile -> nothing')

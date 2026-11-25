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

def session(mode,height,width,saved=None,ui=1,before_boot=None):
    factor=768/height
    g={'UIParent':{'GetEffectiveScale':lambda self:ui,'GetHeight':lambda self:768/ui},
       'PixelUtil':{'GetPixelToUIUnitFactor':lambda:factor},
       'ChatFontNormal':{'GetFont':lambda self:('font',14)}}
    s=Session(registry='generated',extra_files=(),saved=saved,globals_=g,collection_presets=True)
    s.lua.execute('function GetPhysicalScreenSize() return %d,%d end'% (width,height))
    s.lua.execute('TEST_meta.PitBull4={Version="v4.2.50-forever.1"};TEST_meta.Quartz={Version="3.8.0"}')
    if saved is None:
        s.g.DevilForever_CoreDB=s.lua.table_from({'preset':{'active':mode}},recursive=True)
    if before_boot:before_boot(s)
    s.boot(after=['PitBull4','Quartz'])
    assert not s.errors(),s.errors()
    return s

def carry(s):
    return {n:s.sv(n) for n in ('DevilForever_CoreDB','DevilForever_ProfilesDB','PitBull4DB','Quartz3DB') if s.sv(n) is not None}

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
    # the base preset is the V2 layout; -v1 is the V1 compare layout and the base preset brings V2 back
    assert bp['dfLayoutV2'] and bp['units']['대상의 소환수']['enabled']
    back=session(mode,height,width,request(v2,mode+'-v1'),ui=.64)
    pback=back.sv('PitBull4DB')['profiles']['Default']
    assert not pback['dfLayoutV2'] and not pback['units']['대상의 소환수']['enabled']
    assert pback['units']['대상의 소환수']['layout']=='대상의대상'
    assert not any(pback['units'][n]['enabled'] for n in ('대상의 소환수의 대상','대상의 소환수의 대상의 대상'))
    assert not back.sv('PitBull4DB')['namespaces']['CastBar']['profiles']['Default']['layouts']['보통']['dfOutside']
    assert back.sv('PitBull4DB')['namespaces']['CastBar']['profiles']['Default']['layouts']['보통']['enabled'] is False  # V1: Quartz only too
    assert back.sv('Quartz3DB')['namespaces']['Swing']['profiles']['Default']['swingposition']=='top'
    assert back.sv('Quartz3DB')['namespaces']['Pet']['profiles']['Default']['point']=='TOPLEFT'
    assert pback['dfAuraGeometry']['플레이어']['size_ratio']==.7 and pback['dfAuraGeometry']['플레이어']['avoid_frame']
    assert not back.errors(),back.errors()
    again=session(mode,height,width,request(back,mode),ui=.64)
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
    print('PASS',mode,width,'actual preset request/reload -> V2 -> narrow and regular V1; 3 scales native Refix/layout; party/custom/module toggles preserved')
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
      -- V1 (swing above the bar): a UI scale change rescales the Player bar and the swing bar with it.
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

# Preset screen map (default V1 and the V2 compare layout): Grid2 at its 40-player maximum and its party
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
    size=int(_re.search(r'Primary=\{[^}]*primaryWidth=(\d+)',src).group(1))
    for name,x,y in _re.findall(r'(Primary|AOE|Cooldowns|Defensives|Interrupts)=\{x=\(([-0-9.]+)\)\*pixel,y=\(([-0-9.]+)\)',src):
        rects['hekili '+name]=_point(width,height,'CENTER','CENTER',float(x),float(y),size,size)
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
    return rects,raid,party

# Grid2 left of the quest tracker (Blizzard's objective tracker, right side; top at about 24 % and its
# left edge about 23 % of the screen height from the right): window top on the tracker's top, right edge
# on the tracker's left edge, square cells; the window grows down and left, clear of every preset rectangle.
TRACKER={'fhd':(259,247,88),'qhd':(346,330,116),'uhd':(518,495,176)}
KNOWN_OVERLAP={  # 88/116/176 px cells at the tracker spot, measured; waiting for the user's in-game feedback
    'fhd 1920 party':['details 1', 'details 2'],
    'fhd 1920 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'details 1', 'details 2', 'quartz Focus', 'quartz Target', 'unit 대상', 'unit 대상의 대상', 'unit 대상의 대상의 대상', 'unit 대상의 소환수', 'unit 대상의 소환수의 대상', 'unit 대상의 소환수의 대상의 대상', 'unit 주시 대상', 'unit 주시 대상의 대상', 'unit 주시 대상의 대상의 대상'],
    'qhd 2560 party':['details 1'],
    'qhd 2560 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'details 1', 'unit 대상', 'unit 대상의 소환수', 'unit 주시 대상'],
    'uhd 3840 party':['details 1'],
    'uhd 3840 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'details 1', 'unit 대상', 'unit 대상의 소환수', 'unit 주시 대상'],
    'uhd 3862 party':['details 1'],
    'uhd 3862 raid':['auras 대상 buffs alone', 'auras 대상 buffs avoided shown', 'auras 대상 debuffs alone', 'auras 대상 debuffs avoided shown', 'auras 대상의 소환수 buffs alone', 'auras 대상의 소환수 buffs avoided shown', 'auras 대상의 소환수 debuffs alone', 'auras 대상의 소환수 debuffs avoided shown', 'auras 주시 대상 buffs alone', 'auras 주시 대상 buffs avoided shown', 'auras 주시 대상 debuffs alone', 'auras 주시 대상 debuffs avoided shown', 'details 1', 'unit 대상', 'unit 대상의 소환수', 'unit 주시 대상'],
}
for v2 in (False,True):
    for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160),('uhd',3862,2160)]:
        rects,raid,party=default_screen_map(mode,width,height,v2)
        assert len([k for k in rects if k.startswith('group ')])==4 and len([k for k in rects if k.startswith('hekili ')])==5,sorted(rects)
        top,margin,cell=TRACKER[mode]
        for kind,box in (('raid',raid),('party',party)):
            assert box[0]>=0 and box[1]>=0 and box[0]+box[2]<=width and box[1]+box[3]<=height,(mode,v2,box)
            hits={k for k,r in rects.items() if overlaps(box,r)}
            # Known overlaps at this spot with the user's doubled square cells; size and shape wait for
            # the user's in-game feedback, so the test pins exactly what the window covers today.
            known=set(KNOWN_OVERLAP['%s %d %s'%(mode,width,kind)])
            assert hits==known,(mode,width,v2,kind,box,sorted(hits))
            assert abs(box[1]-top)<1e-6 and abs(box[0]+box[2]-(width-margin))<1e-6,(mode,v2,box)
        print('PASS',mode,width,'V2' if v2 else 'V1','Grid2 40-player window %s and party window %s left of the quest tracker, tops aligned (cells %d px), pinned overlaps raid %d / party %d'%(tuple(round(v) for v in raid),tuple(round(v) for v in party),cell,len(KNOWN_OVERLAP['%s %d raid'%(mode,width)]),len(KNOWN_OVERLAP['%s %d party'%(mode,width)])))
print('PASS preset Grid2 placement left of the quest tracker (V1 and V2)')

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
    assert p['dfLayoutRevision']==s.core.Presets.layoutV2Revision==3
    # the totem timer sits above the player frame (right-aligned), under the player's aura rows; the
    # player-focus and focus-target gaps are one frame gap each
    timer=s.sv('PitBull4DB')['namespaces']['Totems']['profiles']['Default']['layouts']['보통']
    icon=15*timer['size'];outside=p['layouts']['보통'].get('indicator_root_outside_margin',0)
    assert timer['location']=='out_top_right' and timer['attach_to']=='root'
    for k,b in rects.items():
        if k.startswith('auras 플레이어 '):assert b[1]+b[3]<=player[1]-outside-icon+1e-6,(mode,k,b,player)
    span=4*icon+3*timer['totem_spacing']*icon/50
    totems=(player[0]+player[2]-span,player[1]-outside-icon,span,icon)
    hits=[k for k,r in rects.items() if overlaps(totems,r)]
    assert not hits,(mode,totems,hits)
    gap={'fhd':34,'qhd':38,'uhd':44}[mode]  # one frame gap (cast height + 4) between player, focus and target
    assert abs(focus[0]-(player[0]+player[2])-gap)<1e-6 and abs(target[0]-(focus[0]+focus[2])-gap)<1e-6,(mode,player,focus,target)
    print('PASS',mode,width,'V2 default: focus centred %.0f with equal side gaps, totem timer above the player (clear of every rectangle) under its auras, one aura table %s, target-pet chain under the target-pet'%(focus[0]+focus[2]/2,size))
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
    for label,s in (('V2',fresh),('V1',session(mode,height,width,request(fresh,mode+'-v1')))):
        p=s.sv('PitBull4DB')['profiles']['Default']
        texts=s.sv('PitBull4DB')['namespaces']['LuaTexts']['profiles']['Default']['layouts']
        assert p['dfLayoutV2'] is (label=='V2'),(mode,label)
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
        print('PASS',mode,label,'name text: player/target %.2f px (x %d/%d), pet/focus %d px, bar texts unchanged'%(NAME_FONT[mode]*main/companion,main,companion,NAME_FONT[mode]))
    # A profile written before this change (name size 1 on the player/target frames) gets the new size
    # through the layout switch (the <preset>-v2 / -v1 requests behind New/Old and /dfp preset + /dfp go).
    old_profile=carry(session(mode,height,width))
    for layout in ('보통','대상'):
        old_profile['PitBull4DB']['namespaces']['LuaTexts']['profiles']['Default']['layouts'][layout]['elements']['Lua:이름']['size']=1
    before=session(mode,height,width,old_profile)
    assert before.sv('PitBull4DB')['namespaces']['LuaTexts']['profiles']['Default']['layouts']['보통']['elements']['Lua:이름']['size']==1,mode
    after=session(mode,height,width,request(before,mode+'-v2'))
    got=after.sv('PitBull4DB')['namespaces']['LuaTexts']['profiles']['Default']['layouts']['보통']['elements']['Lua:이름']['size']
    assert abs(got-main/companion)<1e-6,(mode,got)
    print('PASS',mode,'existing profile: name size 1 -> %.3f after the %s-v2 request'%(got,mode))

# One player cast bar (Quartz) in Old and New: PitBull4's cast bar module and the player's cast texts are
# off in a fresh profile, and a profile that still has them on (an earlier build) gets them off through
# the layout switch (<preset>-v1 / -v2 requests behind the New/Old switch, also /dfp preset + /dfp go).
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
    for target in ('-v1','-v2'):
        after=session(mode,height,width,request(session(mode,height,width,old_profile),mode+target))
        assert cast_state(after)==(False,False,False,False),(mode,target,cast_state(after))
        q=after.sv('Quartz3DB')['namespaces']['Player']['profiles']['Default']
        if target=='-v2':
            tq=after.sv('Quartz3DB')['namespaces']['Target']['profiles']['Default']
            assert (q['point'],q['y'],q['w'],q['h'])==(tq['point'],tq['y'],tq['w'],tq['h']),(mode,q,tq)  # same row and width as the target bar
            assert (q['iconposition'],q['texture'])==(tq['iconposition'],tq['texture'])
    print('PASS',mode,'one player cast bar (Quartz): PitBull4 cast bar and cast texts off, also after the -v1/-v2 switch of an older profile')

# Re-apply after an update: at login a PitBull4 profile whose dfLayoutRevision is older than this build's
# revision of the version it is on gets that version's compare preset requested and the interface
# reloaded once (the New/Old switch path); after the reload one chat line says so. Same revision: nothing.
# In combat: deferred to PLAYER_REGEN_ENABLED. PitBull4's AceDB object is a stub over PitBull4DB.
PB4_DB_STUB="""
  local none=function() return function() end end
  PitBull4={IterateHeaders=none,IterateFrames=none,db=setmetatable({GetCurrentProfile=function() return "Default" end},{__index=function(_,k)
    if k=="profile" then return PitBull4DB and PitBull4DB.profiles and PitBull4DB.profiles.Default end end})}
"""
def with_pb4(combat=False):
    def hook(s):
        s.lua.execute(PB4_DB_STUB)
        if combat:s.g.TEST_combat=True
    return hook
def reloads(s):return s.g.TEST_reloads
def lines(s):return list(plain(s.g.TEST_prints).values())
NOTICE={'-v2':'New 배치를 이 판에 맞춰 다시 적용했습니다(PitBull4·Quartz·Grid2).','-v1':'Old 배치를 이 판에 맞춰 다시 적용했습니다(PitBull4·Quartz·Grid2).'}
for mode,width,height in [('fhd',1920,1080),('qhd',2560,1440),('uhd',3840,2160)]:
    current=carry(session(mode,height,width))
    same=session(mode,height,width,current,before_boot=with_pb4())
    assert same.sv('PitBull4DB')['profiles']['Default']['dfLayoutRevision']==same.core.Presets.layoutV2Revision
    assert reloads(same)==0 and not any('다시 적용' in l for l in lines(same)) and 'pending' not in same.sv('DevilForever_ProfilesDB'),(mode,lines(same))
    old_v1=carry(session(mode,height,width,request(session(mode,height,width),mode+'-v1')))
    assert old_v1['PitBull4DB']['profiles']['Default']['dfLayoutV2'] is False
    del old_v1['PitBull4DB']['profiles']['Default']['dfLayoutRevision']  # a collection Old profile from before revisions
    stale_v2=copy.deepcopy(current);stale_v2['PitBull4DB']['profiles']['Default']['dfLayoutRevision']=2
    for suffix,stale in (('-v2',stale_v2),('-v1',old_v1)):
        s=session(mode,height,width,stale,before_boot=with_pb4())
        assert reloads(s)==1,(mode,suffix,reloads(s),lines(s))
        pending=s.sv('DevilForever_ProfilesDB')['pending']
        assert (pending['action'],pending['name'],pending['armed'])==('preset',mode+suffix,True),(mode,suffix,pending)
        store=s.sv('DevilForever_CoreDB')['layoutRevision']
        target=s.core.Presets.layoutV2Revision if suffix=='-v2' else s.core.Presets.layoutV1Revision
        assert store['tried']=={'Default|'+suffix:target} and store['notice']==NOTICE[suffix],(mode,suffix,store)
        after=session(mode,height,width,carry(s),before_boot=with_pb4())
        pa=after.sv('PitBull4DB')['profiles']['Default']
        assert pa['dfLayoutRevision']==target and pa['dfLayoutV2'] is (suffix=='-v2'),(mode,suffix,pa.get('dfLayoutRevision'))
        assert reloads(after)==0 and [l for l in lines(after) if '다시 적용' in l]==['[DF 설정] '+NOTICE[suffix]],(mode,suffix,lines(after))
        assert 'notice' not in after.sv('DevilForever_CoreDB')['layoutRevision']
        again=session(mode,height,width,carry(after),before_boot=with_pb4())
        assert reloads(again)==0 and not any('다시 적용' in l for l in lines(again)),(mode,suffix)
    # a PitBull4 profile the collection never laid out (no dfLayoutV2 flag) is left as it is: no request,
    # no reload, no tried mark
    foreign=copy.deepcopy(current);fp=foreign['PitBull4DB']['profiles']['Default']
    del fp['dfLayoutV2'];del fp['dfLayoutRevision']
    s=session(mode,height,width,foreign,before_boot=with_pb4())
    assert reloads(s)==0 and 'pending' not in s.sv('DevilForever_ProfilesDB'),(mode,lines(s))
    assert 'dfLayoutV2' not in s.sv('PitBull4DB')['profiles']['Default'] and not s.sv('DevilForever_CoreDB').get('layoutRevision',{}).get('tried')
    assert not any('다시 적용' in l for l in lines(s))
    # one attempt per profile and revision: a profile still stale after the attempt is not reloaded again
    s=session(mode,height,width,stale_v2,before_boot=with_pb4())
    tried=carry(s);tried['DevilForever_ProfilesDB'].pop('pending',None);tried['DevilForever_CoreDB']['layoutRevision'].pop('notice',None)
    loop=session(mode,height,width,tried,before_boot=with_pb4())
    assert loop.sv('PitBull4DB')['profiles']['Default']['dfLayoutRevision']==2 and reloads(loop)==0,(mode,lines(loop))
    # combat at login: nothing until combat ends, then the same re-apply
    fight=session(mode,height,width,stale_v2,before_boot=with_pb4(combat=True))
    assert reloads(fight)==0 and 'pending' not in fight.sv('DevilForever_ProfilesDB'),(mode,lines(fight))
    fight.combat(False)
    assert reloads(fight)==1 and fight.sv('DevilForever_ProfilesDB')['pending']['name']==mode+'-v2',(mode,lines(fight))
    fight.combat(True);fight.combat(False)
    assert reloads(fight)==1
    assert not fight.errors(),fight.errors()
    print('PASS',mode,'re-apply after an update: older New/Old revision (collection profile) -> one request+reload and one chat line after it; same revision, a profile without the layout flag, a tried revision and combat -> nothing (combat: done at combat end)')

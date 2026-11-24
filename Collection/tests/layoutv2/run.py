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

def session(mode,height,width,saved=None,ui=1):
    factor=768/height
    g={'UIParent':{'GetEffectiveScale':lambda self:ui,'GetHeight':lambda self:768/ui},
       'PixelUtil':{'GetPixelToUIUnitFactor':lambda:factor},
       'ChatFontNormal':{'GetFont':lambda self:('font',14)}}
    s=Session(registry='generated',extra_files=(),saved=saved,globals_=g,collection_presets=True)
    s.lua.execute('function GetPhysicalScreenSize() return %d,%d end'% (width,height))
    s.lua.execute('TEST_meta.PitBull4={Version="v4.2.50-forever.1"};TEST_meta.Quartz={Version="3.8.0"}')
    if saved is None:
        s.g.DevilForever_CoreDB=s.lua.table_from({'preset':{'active':mode}},recursive=True)
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
    q=db['Quartz3DB']['namespaces']
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
          PitBull4.CastBar:OnEnable();assert(not f.CastBar)
          TEST_casting=true;PitBull4.CastBar:ForeverCastEvent('UNIT_SPELLCAST_START','player');f:UpdateLayout(false)
          assert(f.CastBar and f.CastBar.duration==TEST_duration)
          assert(f.CastBar.points[1][3]=='BOTTOMLEFT')
          assert(f.CastBar.points[1][5]==-cfg.dfOffset)
          assert(f.CastBar.points[2][5]==-cfg.dfOffset-cfg.dfHeight)
          TEST_casting=false;PitBull4.CastBar:ForeverCastEvent('UNIT_SPELLCAST_STOP','player');f:UpdateLayout(false)
          assert(not f.CastBar)
        """)
    for restore in (mode+'-v1',mode):
        back=session(mode,height,width,request(v2,restore),ui=.64)
        pback=back.sv('PitBull4DB')['profiles']['Default']
        assert not pback['dfLayoutV2'] and not pback['units']['대상의 소환수']['enabled']
        assert pback['units']['대상의 소환수']['layout']=='대상의대상'
        assert not back.sv('PitBull4DB')['namespaces']['CastBar']['profiles']['Default']['layouts']['보통']['dfOutside']
        assert back.sv('Quartz3DB')['namespaces']['Swing']['profiles']['Default']['swingposition']=='top'
        for name in bp['units']:
            if name!='custom':
                for key in ('anchor','relative_point','position_x','position_y','size_x','size_y'):
                    assert abs(pback['units'][name][key]-bp['units'][name][key])<1e-8 if isinstance(bp['units'][name][key],(int,float)) else pback['units'][name][key]==bp['units'][name][key]
        assert not back.errors(),back.errors()
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
      local status
      -- The status widget is the parent of the module's duration/remaining font strings.
      for i=1,20 do local key,value=debug.getupvalue(swing.PLAYER_SWING,i);if key=='swingstatusbar' then status=value end end
      assert(status)
      for _,kind in ipairs({Enum.PlayerSwingType.MainHand,Enum.PlayerSwingType.Ranged}) do
        TEST_clock=100;swing:PLAYER_SWING('PLAYER_SWING',4,kind)
        assert(status.value==0 and bar.shown and bar.OnUpdate)
        TEST_clock=102;bar.OnUpdate();assert(status.value==.5)
        swing:PLAYER_SWING('PLAYER_SWING',9,Enum.PlayerSwingType.OffHand);assert(status.value==.5)
        swing:PLAYER_SWING('PLAYER_SWING',{secret=true},kind);assert(status.value==.5)
        TEST_clock=104;bar.OnUpdate();assert(status.value==1 and not bar.shown and not bar.OnUpdate)
        swing:PLAYER_SWING('PLAYER_SWING',2,kind);assert(status.value==0 and bar.shown)
        swing:PLAYER_SWING('PLAYER_SWING',0,kind);assert(not bar.shown and not bar.OnUpdate and status.value==0)
      end
      swing:PLAYER_SWING('PLAYER_SWING',3,Enum.PlayerSwingType.MainHand)
      swing:OnDisable();assert(not bar.shown and status.value==0 and not bar.OnUpdate)
      swing:OnEnable();swing:PLAYER_SWING('PLAYER_SWING',3,Enum.PlayerSwingType.MainHand)
      assert(bar.shown and status.value==0)
      local db=swing.db.profile;db.dfFollowPlayer=false;db.swingposition='top';db.swinggap=-4;swing:ApplySettings()
      assert(bar.pos[1]=='BOTTOM' and bar.pos[3]=='TOP')
      TEST_clock=105.5;bar.OnUpdate();assert(status.value==.5)
    """)
    print('PASS',mode,width,'native Quartz/LibWindow three cast rectangles, shield/start/stop; Player scale follows Swing; MainHand/Ranged start/mid/end/restart/invalid/disable and V1 top')
print('PASS native Quartz Swing and cast consumers')

R=runpy.run_path(str(ROOT/'Collection/tests/pitbull4runtime/run.py'),run_name='aura_harness')
def merge(lua,target,src):
    for key,value in src.items():
        if isinstance(value,dict):
            if target[key] is None:target[key]=lua.table()
            merge(lua,target[key],value)
        else:target[key]=value

for mode,width,height,footY in [('fhd',1920,1080,548),('qhd',2560,1440,765),('uhd',3840,2160,1180),('uhd',3862,2160,1180)]:
    old=session(mode,height,width)
    src=session(mode,height,width,request(old,mode+'-v2'))
    profile=src.sv('PitBull4DB')['profiles']['Default']
    rect=rects(src,width,height,1)
    q=src.sv('Quartz3DB')['namespaces']['Player']['profiles']['Default']
    foot=(width/2-(q['w']+10)/2,footY,q['w']+10,q['h']+18)
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

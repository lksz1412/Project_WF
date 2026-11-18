import pathlib,json,tempfile,sys,math,shutil
sys.stdout.reconfigure(encoding='utf-8');root=pathlib.Path(r'D:\Projects\Project_WF');out=root/'Codex/results/layout-design';base=root/'SourceArchive/2022-11-19/extracted/Interface/addons';g=json.loads((out/'original-image-geometry.json').read_text(encoding='utf-8'));rg={x['id']:x for x in g['regions']}
T={'action_slot':80,'action_icon':64,'main_gap':3,'bank_gap':4,'floating_slot':68,'floating_gap':4,'key_font':22,'label_font':24,'status_font':22,'frame_border':4,'status_height':32,'utility_height':56,'utility_lower_gap':8,'utility_upper_gap':8,'main_rows':3,'main_columns':8,'bank_top_padding':8,'rail_height':32,'panel_bottom':32,'minimap_outer':328,'unit_width':512,'unit_height':116,'unit_bottom_offset_from_strip_top':176}
T['bank_bottom']=T['status_height']+T['utility_lower_gap']+T['utility_height']+T['utility_upper_gap'];T['bank_height']=3*T['action_slot']+2*T['bank_gap'];T['bank_width']=8*T['action_slot']+7*T['bank_gap'];T['panel_top']=T['bank_bottom']+T['bank_height']+T['bank_top_padding'];T['dock_height']=T['panel_top']+T['rail_height'];T['strip_width']=36*T['action_slot']+35*T['main_gap'];T['strip_y']=T['dock_height'];T['strip_top']=T['strip_y']+T['action_slot']
colors={'world':'#24272B','dock_bottom':'#050505','dock_top':'#151515','panel':'#101010','rail':'#202020','border':'#737373','text':'#F5F5F5','text_plate':'#101010','placeholder_icon':'#5F646B','health':'#B8B8B8','mana':'#294E8A','empty_slot':'#090909'}
assets={'button_frame':{'path':'Masque_Onyx/Textures/Frame-Classic.tga','alpha_bbox':[8,2,120,120],'draw':'crop_alpha_bbox_then_contain','status':'recovered_asset; renderer only; no currentMasque support claim'},'button_shadow':{'path':'Masque_Onyx/Textures/Shadow.tga','status':'available; optional decorative texture inside slotbounds'},'button_arrow':{'path':'Masque_Onyx/Textures/Arrow.tga','status':'available; no active/glow state inferred'},'border':{'path':'!DevilUI/media/border/Devil2.tga','draw':'WoW eight-segment edge texture reference; simple neutral border allowed if exact edge renderer absent, record limitation'},'statusbar':{'path':'!DevilUI/media/statusbar/Glamour7.tga','draw':'stretch inside proposed health/mana childrect'},'decor_left':{'path':'!DevilUI/media/background/demon.tga','alpha_bbox':[0,92,220,256],'draw':'crop_alpha_bbox_then_contain_bottom','status':'recovered_profile_reference; exact screenshot art match unverified'},'decor_right':{'path':'!DevilUI/media/background/angel.tga','alpha_bbox':[43,105,256,256],'draw':'crop_alpha_bbox_then_contain_bottom','status':'recovered_profile_reference; screenshot partiallyoccluded; no hidden reconstruction'}}
rect=[]
def R(i,kind,x,y,w,h,z=10,parent=None,interactive=False,visible=True,**kw):
 d={'id':i,'kind':kind,'role':kw.pop('role',kind),'x':x,'y':y,'w':w,'h':h,'z':z,'parent_id':parent,'interactive':interactive,'visible':visible,'evidence_category':'proposed_exact_target_pixels'};d.update(kw);rect.append(d);return d
R('world','background',0,0,3840,2160,0,color_token='world',text='')
R('dock','background',0,0,3840,T['dock_height'],1,gradient_bottom_token='dock_bottom',gradient_top_token='dock_top',alpha_bottom=1,alpha_top=.65)
R('rail','rail',0,T['panel_top'],3840,T['rail_height'],3,parent='dock',color_token='rail')
R('status','status_strip',8,0,3824,32,8,parent='dock',text='情報 / 정보',font_px=22,color_token='text',fill_token='text_plate',text_is_placeholder=True)
for i,x,w in [('left_panel',8,920),('middle_panel',928,912),('right_chat',2852,980)]:R(i,'framed_panel',x,32,w,328,5,parent='dock',border_asset='border',border_px=4,fill_token='panel',fill_alpha=.70,text='',role='unassigned dark panel' if i!='right_chat' else 'chat placeholder')
R('minimap','minimap_placeholder',2520,32,328,328,20,parent='dock',interactive=True,border_asset='border',border_px=4,text='미니맵',font_px=24,text_is_placeholder=True,terrain='neutral grid, no invented location')
R('minimap_title','label',2520,364,328,24,8,parent='rail',text='지역 표시',font_px=22,text_is_placeholder=True,color_token='text',plate_token='text_plate')
R('utility_row','container',1852,40,660,56,10,parent='dock',draw=False)
for j in range(11):R('utility_'+str(j+1),'utility_placeholder',1852+j*36,40,34,56,21,parent='utility_row',interactive=True,text='',no_function_assignment=True)
for j in range(5):R('bag_'+str(j+1),'bag_placeholder',2254+j*52,44,50,50,21,parent='utility_row',interactive=True,text='',no_function_assignment=True)
# Logical action slots retain all four observed grids, with proposed fixed sizes. No spell/key assignments.
def grid(id,x,y,cols,rows,size,gap,bars,source_id):
 w=cols*size+(cols-1)*gap;h=rows*size+(rows-1)*gap;R(id,'container',x,y,w,h,20,draw=False,source_region=source_id,columns=cols,rows=rows)
 obs=rg[source_id];occ=set(obs.get('occupied_slots_1based',[])) if rows==1 else {tuple(v) for v in obs.get('occupied_cells_1based',[])}
 for rt in range(rows):
  for c in range(cols):
   serial=rt*cols+c+1;filled=serial in occ if rows==1 else (rt+1,c+1) in occ
   if id=='strip_36':bar=bars[c//12];idx=c%12+1
   elif id=='bank_8x3':bar=bars[c//4];idx=(rows-1-rt)*4+c%4+1
   else:bar=bars[c//2];idx=rt*2+c%2+1
   R(id+'_slot_'+str(serial).zfill(2),'action_slot',x+c*(size+gap),y+(rows-1-rt)*(size+gap),size,size,30,parent=id,interactive=True,row_from_top=rt+1,column_from_left=c+1,source_bar_id=bar,source_slot_index_reference=idx,source_index_is_runtime_assignment=False,source_observed_icon=filled,content='abstract neutral icon placeholder' if filled else 'empty framed',frame_asset='button_frame',icon_inset=8 if size==80 else 7,key_label='키' if serial==1 else '',key_label_is_example=True,key_font_px=22,key_plate_token='text_plate',key_text_token='text')
grid('strip_36',428,T['strip_y'],36,1,80,3,[1,6,5],'main_action_row');grid('bank_8x3',1848,T['bank_bottom'],8,3,80,4,[3,4],'bottom_aux_bank');grid('floating_left',1144,1152,4,3,68,4,[9,7],'floating_left_bank');grid('floating_right',2404,1152,4,3,68,4,[8,10],'floating_right_bank')
unit_y=T['strip_top']+T['unit_bottom_offset_from_strip_top']
for i,x in [('player',1056),('target',2272)]:
 R(i,'unit_frame',x,unit_y,512,116,20,interactive=True,role='proposed player frame' if i=='player' else 'proposed target frame; not observed separately in screenshot',border_asset='border',border_px=4,text='플레이어' if i=='player' else '대상',font_px=24,text_is_placeholder=True,conditional_at_runtime='target exists' if i=='target' else 'player exists',outline='dashed proposal cue' if i=='target' else 'solid',source_unit_identity_verified=False)
 R(i+'_health','resource_bar',x+4,unit_y+36,504,76,21,parent=i,asset='statusbar',tint_token='health',text='체력',font_px=24,text_is_placeholder=True,plate_token='text_plate',text_token='text',value_is_live=False)
 R(i+'_mana','resource_bar',x+4,unit_y+4,504,28,21,parent=i,asset='statusbar',tint_token='mana',text='마나',font_px=24,text_is_placeholder=True,plate_token='text_plate',text_token='text',value_is_live=False)
R('decor_left','decor',250,380,176,160,40,asset='decor_left',input_passthrough=True)
R('decor_right','decor',3405,380,208,160,40,asset='decor_right',input_passthrough=True)
reserved=[{'id':'player_cast_reserved','x':1056,'y':608,'w':512,'h':28,'visible':False,'role':'castbar placement reservation; sourceQuartzloafmissing'},{'id':'target_cast_reserved','x':2272,'y':608,'w':512,'h':28,'visible':False,'role':'castbar reservation, duplicate owner not decided'},{'id':'shaman_optional_reserved','x':1780,'y':536,'w':280,'h':64,'visible':False,'role':'optional totem/proc area only; no new action/key allocation'}]
source_regions=[{'id':x['id'],'bbox_top_left_source_px':x['bbox'],'measurement_status':'approximate specialist observation','tolerance_px':x.get('tolerance_px'),'role_uncertainty':x.get('confidence')} for x in g['regions']]
spec={'schema':'devil-ui-layout/1','canvas':{'width':3840,'height':2160,'origin':'bottom-left','units':'fixed target raster pixels','raster_status':'working_assumption; user4Kconfirmed; exactOS/game raster unverified','game_ui_scale':None,'global_layout_scale':None,'proportional_scaling_prohibited':True},'source_reference':g['source'],'source_observations':source_regions,'proposal':{'method':'button outer size then rows/gaps then status/utility bottom clearances then dock/map/unit positions','not_game_pass':True,'preserve_all_observed_action_slots':84,'source_occupancy_is_not_user_content':True,'target_frame_is_new_layout_proposal_not_visible_source_fact':True},'tokens_px':T,'color_tokens':colors,'asset_base':str(base),'assets':assets,'font':{'preferred_file':str(root/'SourceArchive/2022-11-19/extracted/Fonts/2002.TTF'),'fallback_file':'C:/Windows/Fonts/malgun.ttf','status':'local existing files only; verify glyph bounds during offline rendering; no installation'},'rectangles':rect,'reserved_regions':reserved,'intentional_overlap_policy':{'backgrounds_and_ancestor_containers':'may underlay descendants; not treated as collisions','decor_right_vs_strip_36_slot_36':'8px horizontal overlap; noninteractive art only','decor_vs_dock_rail':'ends may cross decorative rail; all decor mousepass-through','all_other_interactive_rectangles':'no overlaps, including auxiliary/utility/bags'},'renderer_contract':{'output':'native3840x2160SVG/PNG or PNG per parent renderer brief; no HTML/game code','top_left_conversion':'output_top_y=2160-y-h; no other geometry scaling','coordinate_values':'use explicit rectangles, do not redesign/recenter grids','icons':'abstract neutral shapes only for observed occupied positions; no real spells, assets identifying spec or key mapping','text':'placeholder Korean labels only; key example is 키, not assigned binding','asset_padding':'use declaredalpha_bbox for existing texture, contain inside rect, no generated hidden decorative shape','partial_art':'source right ornament remains uncertainty; asset use is proposedreference, not recovered occluded shape','scope_omissions':['party/meter/broker/clippedhandle/topstatusicons not implemented in core layout preview','reservedcast/totem/proc not rendered as working features']},'game_validation_pending':['actual raster and effective UI scale mapping','button size/keylabel readability at user viewing distance','current addon owners/profile acceptance','health/mana/target and cast correctness','totem/paging/input','minimap clicks/tracking/persistence']}
# Full actual output geometry gate, not a shortened fixture.
ids=[x['id'] for x in rect];assert len(ids)==len(set(ids))
for x in rect:
 assert x['w']>0 and x['h']>0 and x['x']>=0 and x['y']>=0 and x['x']+x['w']<=3840 and x['y']+x['h']<=2160,x['id']
 if x['parent_id']:
  p=next(q for q in rect if q['id']==x['parent_id']);assert p['x']<=x['x'] and p['y']<=x['y'] and x['x']+x['w']<=p['x']+p['w'] and x['y']+x['h']<=p['y']+p['h'],('parent containment',x['id'])
ints=[x for x in rect if x['interactive']];coll=[]
for i,a in enumerate(ints):
 for b in ints[i+1:]:
  if a['parent_id']==b['id'] or b['parent_id']==a['id']:continue
  if min(a['x']+a['w'],b['x']+b['w'])>max(a['x'],b['x']) and min(a['y']+a['h'],b['y']+b['h'])>max(a['y'],b['y']):coll.append([a['id'],b['id']])
assert not coll,coll
slots=[x for x in rect if x['kind']=='action_slot'];assert len(slots)==84;assert sum(x['source_observed_icon'] for x in slots)==26
for k,v in assets.items():assert (base/v['path']).is_file(),k
assert pathlib.Path(spec['font']['preferred_file']).is_file()
def lum(h):
 cs=[int(h[i:i+2],16)/255 for i in (1,3,5)];cs=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in cs];return sum(v*w for v,w in zip(cs,(.2126,.7152,.0722)))
contrast=(lum(colors['text'])+.05)/(lum(colors['text_plate'])+.05);assert contrast>=4.5
p=out/'layout-spec.json';assert not p.exists();p.write_text(json.dumps(spec,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS rectangles='+str(len(rect))+' actions84 occupied_placeholders26 interactive_collisions0 bounds0 parent_violations0 assets7 font1');print('STACK bank_bottom104 + height248 =352; panel_top360 + rail32 =dock392; strip392+80=472; unit472+176=648');print('CONTRAST text_plate',round(contrast,2));print('SPEC',p)

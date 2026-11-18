import json,hashlib,re,struct,itertools,sys
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8')
R=Path('D:/Projects/Project_WF');C=R/'work/old-reference-collection-6jz2o93e';OLD=R/'work/old-reference-collection-0qlzzyxg';O=R/'Codex/results/old-reference/acquisition';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md'
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def dec(v):
 if isinstance(v,dict) and 'luaTableEntries' in v:return {x['key']:dec(x['value']) for x in v['luaTableEntries']}
 return v
def typed(v):
 if isinstance(v,dict):return {'luaTableEntries':[{'keyType':type(k).__name__,'key':k,'value':typed(x)} for k,x in v.items()]}
 return v
full=json.loads((C/'literal-tables-full-typed.json').read_text(encoding='utf-8'));assert len(full)==9;records=[];folder=O/'literal-settings';assert not folder.exists();folder.mkdir()
for source in full:
 data=dec(source['typedData']);spans=source['spans'];sid=source['source']['id'];selected={};index=[];media=[];layout=[]
 def walk(v,path):
  if isinstance(v,dict):
   for k,x in v.items():
    p=path+[str(k)]
    if str(k).casefold() in ('layout','activelayout'):layout.append({'path':p,'value':typed(x),'span':spans.get('/'.join(p))})
    if isinstance(x,str) and (re.search(r'(?i)(media|texture|font|border|background|skin|artwork)',str(k)) or re.search(r'[\\/]|\.(tga|blp|ttf|otf)$',x,re.I)):
     media.append({'path':p,'literal':x,'span':spans.get('/'.join(p))})
    walk(x,p)
 for root,d in data.items():
  if not isinstance(d,dict):continue
  relevant={}
  if 'profiles' in d:relevant['profiles']=d['profiles']
  if isinstance(d.get('global'),dict):relevant['global']={k:d['global'][k] for k in ('layouts','artwork','version') if k in d['global']}
  selected[root]=relevant
  profiles=d.get('profiles',{});assert isinstance(profiles,dict)
  for name,profile in profiles.items():
   path=[root,'profiles',str(name)];item={'profileName':name,'sourcePath':path,'span':spans.get('/'.join(path)),'profileKeySet':list(profile) if isinstance(profile,dict) else None}
   frames=profile.get('frames') if isinstance(profile,dict) else None
   if isinstance(frames,dict):item['frames']=[{'frameID':k,'frameIDType':type(k).__name__,'span':spans.get('/'.join(path+['frames',str(k)])),'fieldKeySet':list(v) if isinstance(v,dict) else None} for k,v in frames.items()];assert {x['frameID'] for x in item['frames']}==set(frames)
   index.append(item)
  layouts=d.get('global',{}).get('layouts',{}) if isinstance(d.get('global'),dict) else {}
  layoutIndex=[{'layoutName':name,'span':spans.get(root+'/global/layouts/'+str(name)),'panelNames':list(panels),'panelSpans':{str(k):spans.get(root+'/global/layouts/'+str(name)+'/'+str(k)) for k in panels}} for name,panels in layouts.items()]
  walk(relevant,[root])
  selected[root]=typed(relevant)
 # selected preserves whole profiles and global layouts/artwork, without account-character profileKeys mapping.
 payload={'source':source['source'],'selection':'Entire profiles subtree plus entire global/layouts,global/artwork,global/version if present. profileKeys mappings excluded; no profile/frame/layout subset chosen.','typedSettings':selected,'profileFrameIndex':index,'layoutIndex':layoutIndex,'activeLayoutLiterals':layout,'mediaLiterals':media,'fullTypedSourceCache':str(C/'literal-tables-full-typed.json'),'keyEncoding':'luaTableEntries preserves keyType/key/value, including integer/string distinction.'}
 for root,v in selected.items():
  roundtrip=dec(v);original=data[root]
  assert set(roundtrip.get('profiles',{}))==set(original.get('profiles',{}))
  assert roundtrip.get('profiles')==original.get('profiles')
  assert roundtrip.get('global',{}).get('layouts')==original.get('global',{}).get('layouts')
  assert roundtrip.get('global',{}).get('artwork')==original.get('global',{}).get('artwork')
 dest=folder/(sid+'.json');save(dest,payload);records.append({'id':sid,'dataPath':str(dest),'sourceSuffix':source['source']['sourceSuffix'],'sourceSHA256':source['source']['SHA256'],'sourceInventory':source['source']['inventoryPath'],'sourceInventoryIndex0':source['source']['inventoryIndex0'],'profiles':len(index),'frames':sum(len(x.get('frames',[])) for x in index),'layouts':len(layoutIndex),'panels':sum(len(x['panelNames']) for x in layoutIndex),'activeLayoutLiterals':len(layout),'mediaLiterals':len(media),'bytes':dest.stat().st_size})
# Static existing2022 paths by name only. No source interpretation or CRC calls.
base=R/'SourceArchive/2022-11-19/extracted/Interface/addons';devil=base/'!DevilUI';existing={'method':'Actual path existence/name-only lookup; no source execution or oldCRC rerun.','coreAndLoaders':[str(p) for p in devil.iterdir() if p.is_file() and p.suffix.lower() in ('.lua','.xml','.toc')],'profileDirectory':str(devil/'Profile'),'profileFiles':[str(p) for p in (devil/'Profile').iterdir() if p.is_file()],'chatNameMatches':[str(p) for p in (devil/'Profile').iterdir() if 'chat' in p.name.lower()],'configurationFiles':[str(p) for p in (base/'Devilconfig').iterdir() if p.is_file() and p.suffix.lower() in ('.lua','.xml','.toc')],'existingParser':str(R/'work/source-analysis-data-vbibwfzc/parse-profile-literals.py'),'priorFullTypedOrPlainData':str(R/'work/source-analysis-data-vbibwfzc/all-literal-profile-data.json'),'priorSelectedRecord':str(R/'Codex/results/source-analysis/profile-extract.json'),'priorExecutionLog':str(R/'Codex/results/handoffs/source-analysis/iter_1/work_log.md')};save(O/'existing-2022-static-paths.json',existing)
# Exactly11 assigned border files: original filenames/case preserved; header and exactbytes only.
a=json.loads((OLD/'archive-2009-members.json').read_text(encoding='utf-8'));b=json.loads((OLD/'alpha-nsis-members.json').read_text(encoding='utf-8'));assets=[]
for family,names,inv in [('2009',['Devil.tga','Devil2.tga','roth.tga'],a),('alpha',['Devil.tga','Devil2.tga','roth.tga','Devil3.tga'],b),('2022',['Devil.tga','Devil2.tga','roth.tga','Devil3.tga'],None)]:
 for name in names:
  if family=='2009':hits=[(i,x) for i,x in enumerate(inv) if x['filename']=='Interface/AddOns/mySharedMedia/border/'+name];assert len(hits)==1;i,x=hits[0];p=Path(x['target']);suffix=x['filename'];ip=str(OLD/'archive-2009-members.json')
  elif family=='alpha':hits=[(i,x) for i,x in enumerate(inv) if x['filename'].replace(chr(92),'/')=='Interface/addons/!DevilUI/media/border/'+name];assert len(hits)==1;i,x=hits[0];p=Path(x['extractedPath']);suffix=x['filename'];ip=str(OLD/'alpha-nsis-members.json')
  else:p=devil/'media/border'/name;suffix=str(p.relative_to(R));i=None;ip=None
  raw=p.read_bytes();assert len(raw)>=18;w,h=struct.unpack_from('<HH',raw,12);assets.append({'family':family,'filename':p.name,'sourceSuffix':suffix,'inventoryPath':ip,'inventoryIndex0':i,'bytes':len(raw),'SHA256':sha(p),'TGAheader':{'imageType':raw[2],'colorMapType':raw[1],'width':w,'height':h,'pixelDepth':raw[16],'descriptor':raw[17]},'observedImageContent':False})
comparisons=[{'leftFamily':x['family'],'leftFilename':x['filename'],'rightFamily':y['family'],'rightFilename':y['filename'],'byteIdentical':x['SHA256']==y['SHA256'],'headerDimensionsEqual':(x['TGAheader']['width'],x['TGAheader']['height'])==(y['TGAheader']['width'],y['TGAheader']['height'])} for x,y in itertools.combinations(assets,2)]
assert len(assets)==11 and len(comparisons)==55
save(O/'border-asset-byte-comparison.json',{'method':'SHA256 exactbytes and18byte TGAheader only. No image content, settings identity, publisher identity, or visual equivalence conclusion. Includes all55 unorderedpairs of11assignedassets.','assets':assets,'comparisons':comparisons})
summary={'expectedSources':9,'parsedFully':len(full),'selectedSources':records,'existing2022Paths':str(O/'existing-2022-static-paths.json'),'borderComparison':str(O/'border-asset-byte-comparison.json'),'parseOverview':str(O/'literal-table-parse-overview.json'),'fullTypedCache':str(C/'literal-tables-full-typed.json'),'selfCheck':'One actual9-source wholeprofile/layout/frame-key-set+typedroundtrip equality pass; sourcehash/lines in overview. Asset exact11set+55pair denominator pass. No Lua execution, installation, CRC rerun or meaning/visual judgement.'};save(O/'static-settings-ready.json',summary)
with L.open('a',encoding='utf-8') as f:f.write('\nStaticselection asset addendum impact: parentadded exactborder11file byte/header comparisons. Allactual assignedpaths unique; oldsource/CRC unchanged. Newliteral-settings9JSON consumes parsedfulltypedcache and returns every profile/frame/layout key set plus allprofile/global layout/artwork values, activelayout/media literals and spans; no meaning inference. Existing2022paths NAME/existenceonly. Actualwhole9 self-check typedroundtrip selected profiles/layouts/artwork equality and frame-ID set equality;asset11/55pair denominators PASS. Output static-settings-ready.json; '+json.dumps(records,ensure_ascii=False)+'\nExactcommands python -X utf8 '+str(C/'parse-assigned-tables.py')+' exit0; python -X utf8 '+str(C/'select-and-compare.py')+' exit0 reached. Fullreads parser80lines/priorlog actualtoolfull; additional JSON data schema and actualselectedsets queried mechanically. No sourcecode execution/cleanup/commit.\n')
print(json.dumps(summary,ensure_ascii=False,indent=2));print('BYTE_IDENTICAL_PAIRS',[(x['leftFamily'],x['leftFilename'],x['rightFamily'],x['rightFilename']) for x in comparisons if x['byteIdentical']])
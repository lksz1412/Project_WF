import json,re,hashlib,copy,tempfile,struct
from pathlib import Path
R=Path('D:/Projects/Project_WF');O=R/'Codex/results/old-reference/acquisition/r36/x2-selected-subset';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';info=json.loads((O/'x2-selected-literal-parse-overview.json').read_text(encoding='utf-8'));raw=Path(info['ignoredFullTypedCache']);full=json.loads(raw.read_text(encoding='utf-8'));inv=json.loads((O/'selected-member-inventory.json').read_text(encoding='utf-8'));rawhash=hashlib.sha256(raw.read_bytes()).hexdigest().upper()
def save(p,x,compact=False):Path(p).write_bytes(json.dumps(x,ensure_ascii=False,indent=None if compact else 2,separators=(',',':') if compact else None).encode('utf-8'))
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def dec(v):return {e['key']:dec(e['value']) for e in v['luaTableEntries']} if isinstance(v,dict) and 'luaTableEntries' in v else v
def leafcount(v):return sum(leafcount(x) for x in v.values()) if isinstance(v,dict) else 1
sources=[];excluded=[]
for item in full:
 d=dec(item['typedData']);spans=item['spans'];rec=copy.deepcopy(item['source']);local=[]
 def filt(v,path):
  if not isinstance(v,dict):return v
  out={}
  for k,x in v.items():
   pp=path+[str(k)]
   if k in ('profileKeys','SCMDataBase'):
    e={'sourceID':rec['id'],'path':pp,'entryCount':len(x) if isinstance(x,dict) else 1,'scalarLeafCount':leafcount(x),'reason':'identityselector-or-distribution-roster','sourceSHA256':rec['SHA256'],'sourceSpan':spans.get('/'.join(pp)),'rawIgnoredTypedCache':str(raw)};local.append(e);excluded.append(e)
   else:out[k]=filt(x,pp)
  return out
 selected=filt(d,[]);types=[]
 def plain(v,path):
  if not isinstance(v,dict):return v
  assert len({str(k) for k in v})==len(v)
  if any(not isinstance(k,str) for k in v):types.append({'path':path,'keys':[{'value':k,'type':type(k).__name__} for k in v]})
  return {str(k):plain(x,path+[str(k)]) for k,x in v.items()}
 converted=plain(selected,[])
 def restore(v,path):
  if not isinstance(v,dict):return v
  s=next((e for e in types if e['path']==path),None);m={str(e['value']):e['value'] for e in s['keys']} if s else {k:k for k in v};return {m[k]:restore(x,path+[k]) for k,x in v.items()}
 assert restore(converted,[])==selected
 queries=[]
 def walk(v,path):
  if not isinstance(v,dict):return
  assert 'profileKeys' not in v and 'SCMDataBase' not in v
  for k,x in v.items():
   pp=path+[str(k)]
   if not isinstance(x,dict) and re.search(r'(?i)(panel|layout|border|background|bg|texture|alpha|mouse|width|height|point|anchor|position|^x$|^y$|scale|row|column|padding|spacing|skin|font|hide|fade|edit|wheel|channel)',str(k)):queries.append({'path':pp,'value':x,'span':spans.get('/'.join(pp))})
   walk(x,pp)
 walk(selected,[]);rec['publishedCoverage']='filteredsettings subset of this fullyparsedselectedfile, not fullarchive';rec['excludedContainerCount']=len(local);sources.append({'source':rec,'settings':converted,'nonStringKeySchemas':types,'keyNameSelectedLeaves':queries,'excludedKeyPaths':local,'spanCache':str(raw)})
assert len(full)==len(sources)==20;variants=sorted({x['source']['variantLiteral'] for x in sources});assert variants==['SPECIAL','SPECIALW','STANDARD','STANDARDW'];assert all(sum(x['source']['variantLiteral']==v for x in sources)==5 for v in variants);assert sha(raw)==rawhash
contract={'sourceScope':'20 selectedSavedVariablesLua from EXACT46safe-subset of original4217. Wholearchive unsafe288 gate remainsBLOCKED.','variantNamesAreLiteralNotMerged':variants,'excludedContainers':len(excluded),'excludedEntries':sum(x['entryCount'] for x in excluded),'excludedKeyPaths':excluded,'rawIgnoredTypedCache':str(raw),'rawIgnoredTypedCacheSHA256':rawhash,'sourceProof':'All20 whole-token literal parsing passed; publicsettings intentionallyfiltered; retainedsubset typedrestore equals source values. No V42 grammar extension/no wholearchivecoverage/runtimeprofile claim.'};save(O/'x2-four-variant-settings-compact.json',{'deliveryContract':contract,'sources':sources},True);save(O/'x2-four-variant-exclusions.json',contract)
# Selected8 TGA bytes and raw18byteheader; no rendering/visualinterpretation.
prior=json.loads((R/'Codex/results/old-reference/acquisition/border-asset-byte-comparison.json').read_text(encoding='utf-8'));assets=[]
for i,e in enumerate(inv):
 if not e['filename'].lower().endswith('.tga'):continue
 p=Path(e['actualPath']);b=p.read_bytes();assert len(b)>=18;w,h=struct.unpack_from('<HH',b,12);name=p.name;assets.append({'selectedInventoryIndex0':i,'sourceSHA256':e['SHA256'],'filenameLiteral':name,'bytes':len(b),'headerWidth':w,'headerHeight':h,'headerDepth':b[16],'headerImageType':b[2],'sameBasenamePriorByteComparisons':[{'family':x['family'],'filename':x['filename'],'byteIdentical':e['SHA256']==x['SHA256']} for x in prior['assets'] if x['filename']==name],'imageObserved':False})
assert len(assets)==8;save(O/'selected-asset-byte-headers.json',{'scope':'Only8selectedTGA entries, hashes/headerfields, noimageview; samebasename comparison doesnotassert profile/sample identity.','assets':assets})
ready={'state':'exact46subset-and-filtered20file-data-ready','subsetGate':str(O/'X2_SUBSET_READY.json'),'selectedInventory':str(O/'selected-member-inventory.json'),'literalParseOverview':str(O/'x2-selected-literal-parse-overview.json'),'filteredFourVariantData':str(O/'x2-four-variant-settings-compact.json'),'exclusions':str(O/'x2-four-variant-exclusions.json'),'selectedAssetBytes':str(O/'selected-asset-byte-headers.json'),'counts':{'subsetExtractedFiles':46,'wholeArchiveListedFiles':4217,'wholeArchiveUnsafeNames':288,'selectedLuaFilesFullyParsed':20,'variants':4,'LuaFilesPerVariant':5,'excludedRosterContainers':len(excluded),'excludedRosterEntries':sum(x['entryCount'] for x in excluded),'selectedTGAHeaderRecords':8},'wholeArchiveState':'BLOCKED unchanged','sourceExecution':False,'newIntegrityTestRuns':0};save(O/'X2_SELECTED_DATA_READY.json',ready)
# Update currentconsumer only; historicalgates/artifacts unchanged.
parent=R/'Codex/results/old-reference/acquisition/r36/other-posts/OTHER_POSTS_READY.json';backup=Path(tempfile.mkdtemp(prefix='old-reference-r36-',dir=R/'work'))/(parent.name+'.before-subset-pointer');backup.write_bytes(parent.read_bytes());p=json.loads(parent.read_text(encoding='utf-8'));p['legacyX2SelectedSubset']=str(O/'X2_SELECTED_DATA_READY.json');p['legacyX2Status'].update(innerExtractionPerformed=True,innerExtractionScope='ONLY exact46safe-selectedsubset;fullarchiveblocked',fullInnerExtractionPerformed=False,subsetExtractedFiles=46);save(parent,p)
with L.open('a',encoding='utf-8') as f:f.write('\nX2subsetactual20Lua/4literalvariantsx5files fulltokenparse pass, no variantmerge. Publicfiltereddata excludes4SCMDataBaserosters totaling'+str(contract['excludedEntries'])+'entries; rawtypedcache/spans unchangedSHA, retainedwhole-subset typedroundtrip equality PASS. Actualselected8TGA rawheader/hashdata only, noimageview. NEW X2_SELECTED_DATA_READY +compact/exclusion/asset files. CurrentOTHER_POSTS_READY pointer/status updatedafterignoredbackup '+str(backup)+'; impactdataflow existingA1consumer nowsees subset46 notfullarchive. Allwholearchive4217/288 gate preservedBLOCKED, newtest0, no V42grammar expansion/sourceexecution/private-read/cleanup/Git. Command python -X utf8 '+str(R/'work/old-reference-r36-13d5mmwk/x2-filtered-data-ready.py')+' exit0.\n')
print(json.dumps(ready,ensure_ascii=False,indent=2));print('COMPACT_BYTES',(O/'x2-four-variant-settings-compact.json').stat().st_size)
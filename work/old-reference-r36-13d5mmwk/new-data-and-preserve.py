import ast,json,re,sys,hashlib,shutil,collections
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8');R=Path('D:/Projects/Project_WF');C=R/'work/old-reference-r36-13d5mmwk';O=R/'Codex/results/old-reference/acquisition/r36/other-posts';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';P=R/'work/source-analysis-data-vbibwfzc/parse-profile-literals.py'
def save(p,x,compact=False):Path(p).write_bytes(json.dumps(x,ensure_ascii=False,indent=None if compact else 2,separators=(',',':') if compact else None).encode('utf-8'))
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
# Persist successful newdownloads without redownloading or overwriting original data.
a=json.loads((O/'package-acquisition.json').read_text(encoding='utf-8'));copies=[]
for r in a:
 if r['provenance'].get('HTTP')!=200 or r['state']!='acquired-magic-verified':continue
 folder=R/('SourceArchive/post-'+str(r['postID'])+('-2008-11-02' if r['postID']==1932 else '-2015-03-04')+'/originals');folder.mkdir(parents=True,exist_ok=True);source=Path(r['provenance']['localpath']);target=folder/r['filename'];assert not target.exists()
 with source.open('rb') as s,target.open('xb') as d:shutil.copyfileobj(s,d)
 entry={'postID':r['postID'],'filename':r['filename'],'source':str(source),'preservedPath':str(target),'bytes':target.stat().st_size,'sourceSHA256':sha(source),'copySHA256':sha(target),'byteHashEqual':sha(source)==sha(target),'HTTPReceipt':r['provenance'],'URLbasis':r['URLbasis']};assert entry['byteHashEqual'];copies.append(entry)
save(O/'preserved-original-copies.json',copies)
# Exact evidence for 3167 physical fileheaders versus3166 listed entries.
h=json.loads((C/'idx1932-rar4-header-metadata.json').read_text(encoding='utf-8'));cnt=collections.Counter(x['rawFilenameHex'] for x in h);dups=[dict(x,filenameANSI=bytes.fromhex(x['rawFilenameHex']).split(bytes([0]))[0].decode('cp949')) for x in h if cnt[x['rawFilenameHex']]>1];headerProof={'physicalRARFileHeaderRecords':len(h),'headersPerPart':dict(collections.Counter(x['part'] for x in h)),'uniqueRawFilenameByteStrings':len(cnt),'listedEntries':3166,'listedRegularFiles':2407,'listedDirectories':759,'duplicateFilenameHeaderRecords':dups,'arithmetic':'1389+1778=3167;3167-(2-1)=3166;2407+759=3166','note':'Actual same rawfilename occurs once at part1offset5241818 withsplitAfter=true and once at part2offset20 withsplitBefore=true. No assumedduplicate from count alone.'};assert len(h)==3167 and len(cnt)==3166 and len(dups)==2;save(O/'rar-header-count-reconciliation.json',headerProof)
# Literalparser only, olddriver notexecuted.
tree=ast.parse(P.read_text(encoding='utf-8'));nodes=[n for n in tree.body if isinstance(n,(ast.FunctionDef,ast.ClassDef)) or isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='pat' for t in n.targets)];ns={'re':re};exec(compile(ast.Module(body=nodes,type_ignores=[]),str(P)+'#definitions-only','exec'),ns);Parser=ns['Parser']
lookup=[];requested=[]
for label,names in [('idx1932-rar',['Bartender4','eePanels2','kgPanels','Skinner','NeonChat','SisterChatMods']),('idx3461-sfx',['kgPanels','Dominos','Masque'])]:
 ip=C/(label+'-members.json');inv=json.loads(ip.read_text(encoding='utf-8'))
 for name in names:
  suffix=('SavedVariables/' if label=='idx1932-rar' else 'Interface/AddOns/!DevilUI/Profile/')+name+'.lua';hits=[(i,x) for i,x in enumerate(inv) if x['filename'].replace(chr(92),'/').endswith(suffix)]
  record={'id':label+'-'+name,'sourceSuffix':suffix,'inventoryPath':str(ip),'matches':len(hits)};requested.append(record)
  if len(hits)==1:i,e=hits[0];lookup.append(dict(record,inventoryIndex0=i,path=e['target']))
  elif len(hits)>1:record['state']='ambiguous-no-parse'
  else:record['state']='name-not-present-no-parse'
ip=R/'work/old-reference-r36-3ed3y_p1/forever-v42-members.json';inv=json.loads(ip.read_text(encoding='utf-8'))
for name in ['kgPanels','Dominos','Masque']:
 suffix='Interface/AddOns/!DevilUI/Profile/'+name+'.lua';hits=[(i,e) for i,e in enumerate(inv) if e['filename']==suffix];record={'id':'V42-'+name,'sourceSuffix':suffix,'inventoryPath':str(ip),'matches':len(hits)};requested.append(record)
 if len(hits)==1:i,e=hits[0];lookup.append(dict(record,inventoryIndex0=i,path=e['target']))
 else:record['state']='missing-or-ambiguous-no-parse'
results=[];full=[];compact=[]
for source in lookup:
 p=Path(source['path']);raw=p.read_bytes();rec={k:v for k,v in source.items() if k!='path'};rec.update(sourceSHA256=sha(p),sourceBytes=len(raw),state='not-parsed');text=None
 for enc in ['utf-8-sig','cp949']:
  try:text=raw.decode(enc);rec['encoding']=enc;break
  except UnicodeDecodeError:continue
 if text is None:rec['state']='decode-failed';results.append(rec);continue
 text=text.replace('\r\n','\n').replace('\r','\n');rec['sourceLines']=len(text.splitlines())
 try:
  if re.search(r'\[\s*(true|false)\s*\]\s*=',text):raise ValueError('boolean tablekey unsupported by reusedPython-dict parser, no lossyclaim')
  obj=Parser(text);data=obj.parse();assert obj.pos==len(obj.ts);rec.update(state='parsed-fully',literalTokens=len(obj.ts),consumedTokens=obj.pos,duplicateKeys=obj.dups,rootAssignments=list(data),rootSchemas=[{'name':k,'valueType':type(v).__name__,'topKeys':list(v) if isinstance(v,dict) else None,'span':obj.spans.get(k)} for k,v in data.items()])
  def typed(v):return {'luaTableEntries':[{'keyType':type(k).__name__,'key':k,'value':typed(x)} for k,x in v.items()]} if isinstance(v,dict) else v
  full.append({'source':rec,'typedData':typed(data),'spans':obj.spans})
  # Complete boundedfile data exceptcharacter/account profileKeys mapping, compact with explicitkeytype schema.
  selected={root:{k:v for k,v in d.items() if k!='profileKeys'} if isinstance(d,dict) else d for root,d in data.items()};types=[]
  def plain(v,path):
   if not isinstance(v,dict):return v
   assert len({str(k) for k in v})==len(v),'JSONkeycollision'
   if any(not isinstance(k,str) for k in v):types.append({'path':path,'keys':[{'value':k,'type':type(k).__name__} for k in v]})
   return {str(k):plain(x,path+[str(k)]) for k,x in v.items()}
  converted=plain(selected,[])
  def restore(v,path):
   if not isinstance(v,dict):return v
   schema=next((x for x in types if x['path']==path),None);mapping={str(x['value']):x['value'] for x in schema['keys']} if schema else {k:k for k in v};return {mapping[k]:restore(x,path+[k]) for k,x in v.items()}
  assert restore(converted,[])==selected
  query=[]
  def walk(v,path):
   if not isinstance(v,dict):return
   for k,x in v.items():
    pp=path+[str(k)]
    if not isinstance(x,dict) and re.search(r'(?i)(layout|panel|border|bg|background|texture|alpha|mouse|width|height|scale|point|anchor|position|^x$|^y$|row|column|padding|spacing|SkinID|skin)',str(k)):query.append({'path':pp,'value':x,'span':obj.spans.get('/'.join(pp))})
    walk(x,pp)
  walk(selected,[]);rec['queryLeafCount']=len(query);rec['profileSets']=[{'root':root,'names':list(d.get('profiles',{})),'count':len(d.get('profiles',{}))} for root,d in data.items() if isinstance(d,dict) and isinstance(d.get('profiles'),dict)];compact.append({'source':rec,'settings':converted,'nonStringKeySchemas':types,'keyNameSelectedLeaves':query,'spanCache':str(C/'new-selected-literal-full-typed.json'),'note':'Completeboundedfiledata exceptprofileKeys mapping. Keyname leafquery is mechanical, no meaning/appearance inference.'})
 except Exception as e:rec.update(state='not-literal-or-parser-boundary',error=str(e))
 results.append(rec)
save(C/'new-selected-literal-full-typed.json',full);save(O/'selected-new-literal-settings-compact.json',{'requested':requested,'sources':compact,'results':results,'method':'Reusedliteralparserdefinitions; completewhole-tokenconsumption and explicittypedkey restoration==entireselectedtree. No Lua/configcode execution.'},True)
# V42 four bordernames bytes/header compare only against earlier existingrecords.
prior=json.loads((R/'Codex/results/old-reference/acquisition/border-asset-byte-comparison.json').read_text(encoding='utf-8'));assets=[]
import struct
for name in ['Devil.tga','Devil2.tga','Devil3.tga','roth.tga']:
 suffix='Interface/AddOns/!DevilUI/media/border/'+name;hits=[(i,e) for i,e in enumerate(inv) if e['filename']==suffix]
 if not hits:assets.append({'filename':name,'state':'not-present'});continue
 assert len(hits)==1;i,e=hits[0];p=Path(e['target']);b=p.read_bytes();w,h=struct.unpack_from('<HH',b,12);assets.append({'filename':name,'state':'present','inventoryPath':str(ip),'inventoryIndex0':i,'sourceSuffix':suffix,'bytes':len(b),'SHA256':sha(p),'TGAheader':{'width':w,'height':h,'pixelDepth':b[16],'imageType':b[2]},'previousSameNameComparisons':[{'family':x['family'],'filename':x['filename'],'previousSHA256':x['SHA256'],'byteIdentical':sha(p)==x['SHA256']} for x in prior['assets'] if x['filename']==name]})
save(O/'v42-border-exact-byte-comparison.json',{'assets':assets,'priorRecords':str(R/'Codex/results/old-reference/acquisition/border-asset-byte-comparison.json'),'method':'ExactSHA andTGAheader only; oldfiles not re-read/CRCtested, priorhashrecords reused; no imageview/profileidentity conclusion.'})
# Small names-only payloads for A1, avoid publishing archiveplaceholder accountpaths in prose.
paths=[]
for label in ['idx1932-rar','idx3461-sfx']:
 ip2=C/(label+'-members.json');ii=json.loads(ip2.read_text(encoding='utf-8'));paths.append({'label':label,'root':str(C/('extracted-'+label)),'inventoryPath':str(ip2),'topDirectories':sorted({e['filename'].split(chr(92))[0] for e in ii}),'candidates':[{'inventoryIndex0':i,'sourceSuffix':e['filename'].split('SavedVariables'+chr(92))[-1] if 'SavedVariables'+chr(92) in e['filename'] else e['filename'],'isSavedVariablesSuffixOnly':'SavedVariables'+chr(92) in e['filename']} for i,e in enumerate(ii) if not e['isDirectory'] and re.search(r'(?i)(Devil|Bartender4|eePanels2|kgPanels|Skinner|NeonChat|SisterChatMods|Dominos|Masque|\.toc$)',e['filename'])]})
save(O/'core-chat-profile-name-paths.json',paths)
with L.open('a',encoding='utf-8') as f:f.write('\nRootadditionalownscope: durablecopies1932parts/3461ZIP -> freshSourceArchiveoriginals withsource/copySHAequality, noGET. RARheaderphysicalcount reconciliation actualduplicatehex pair recorded (Mapster/Libs/AceGUI-3.0/widgets/AceGUIWidget-ColorPicker.lua, part1offset5241818 splitAfter/part2offset20 splitBefore;1389+1778=3167,unique3166). Selectedliteralrequested12/existing11, missing1932kgPanelsnameexplicit, fulltokenparse results '+json.dumps([(r['id'],r['state'],r.get('sourceLines')) for r in results])+'; losslesskeyrestore selectedwhole-tree==originaldata(excludingprofileKeys) gatepass. V42fourborderheader/SHA againstpriorrecords only nooldCRC/imageview. Ownreadonlyinputparser75lines alreadyfullread retainedsamecontext. Command python -X utf8 '+str(C/'new-data-and-preserve.py')+' exit0 reached; outputpaths compactJSON/namepaths/rarreconciliation/copypaths.\n')
print('DATA_READY',len(requested),'requested',len(results),'existing',[(r['id'],r['state']) for r in results]);print('COPIES',[(x['filename'],x['preservedPath']) for x in copies]);print('COMPACT_BYTES',(O/'selected-new-literal-settings-compact.json').stat().st_size)
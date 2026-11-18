import sys,json,re,ast,hashlib,tempfile
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8');R=Path('D:/Projects/Project_WF');O=R/'Codex/results/old-reference/acquisition/r36/x2-selected-subset';C=Path(tempfile.mkdtemp(prefix='old-reference-r36-',dir=R/'work'));L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';P=R/'work/source-analysis-data-vbibwfzc/parse-profile-literals.py'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def save(p,x):Path(p).write_bytes(json.dumps(x,ensure_ascii=False,indent=2).encode('utf-8'))
t=ast.parse(P.read_text(encoding='utf-8'));nodes=[n for n in t.body if isinstance(n,(ast.FunctionDef,ast.ClassDef)) or isinstance(n,ast.Assign) and any(isinstance(v,ast.Name) and v.id=='pat' for v in n.targets)];ns={'re':re};exec(compile(ast.Module(body=nodes,type_ignores=[]),str(P)+'#definitions-only','exec'),ns);Parser=ns['Parser'];inv=json.loads((O/'selected-member-inventory.json').read_text(encoding='utf-8'));targets=[(i,e) for i,e in enumerate(inv) if chr(92)+'SavedVariables'+chr(92) in e['filename'] and e['filename'].endswith('.lua')];assert len(targets)==20
full=[];overview=[]
for i,e in targets:
 p=Path(e['actualPath']);parts=e['filename'].split(chr(92));variant=parts[parts.index('var')+1];name=parts[-1];source={'id':'X2-'+variant+'-'+name[:-4],'variantLiteral':variant,'sourceSuffix':'var/'+variant+'/SavedVariables/'+name,'selectedInventory':str(O/'selected-member-inventory.json'),'selectedInventoryIndex0':i,'sourceInventoryIndex0':e['sourceInventoryIndex0'],'sourceListLine':e['sourceListLine'],'SHA256':sha(p),'bytes':p.stat().st_size,'state':'not-parsed'};raw=p.read_bytes();text=None
 for enc in ['utf-8-sig','cp949']:
  try:text=raw.decode(enc);source['encoding']=enc;break
  except UnicodeDecodeError:continue
 if text is None:source['state']='decode-failed';overview.append(source);continue
 text=text.replace('\r\n','\n').replace('\r','\n');source['sourceLines']=len(text.splitlines())
 try:
  if re.search(r'\[\s*(true|false)\s*\]\s*=',text):raise ValueError('boolean tablekey unsupported by reusedparser, no lossyJSON')
  parser=Parser(text);data=parser.parse();assert parser.pos==len(parser.ts);source.update(state='parsed-fully',literalTokens=len(parser.ts),consumedTokens=parser.pos,duplicateKeys=parser.dups,rootAssignments=list(data));source['schemas']=[{'root':k,'type':type(v).__name__,'keyCount':len(v) if isinstance(v,dict) else None,'topKeys':list(v) if isinstance(v,dict) and k!='SCMDataBase' else None,'rosterTopKeysSuppressed':k=='SCMDataBase','span':parser.spans.get(k)} for k,v in data.items()]
  def typed(v):return {'luaTableEntries':[{'keyType':type(k).__name__,'key':k,'value':typed(x)} for k,x in v.items()]} if isinstance(v,dict) else v
  full.append({'source':source,'typedData':typed(data),'spans':parser.spans})
 except Exception as ex:source.update(state='parser-boundary',error=str(ex))
 overview.append(source);print(source['id'],source['state'],source.get('schemas'),flush=True)
save(C/'X2-20-selected-full-typed.json',full);save(O/'x2-selected-literal-parse-overview.json',{'selectedSubsetOnly':True,'wholeArchiveGate':'BLOCKED unsafe288/4217 unchanged','requestedSelectedLuaFiles':20,'actualVariantSet':sorted({x['variantLiteral'] for x in overview}),'results':overview,'ignoredFullTypedCache':str(C/'X2-20-selected-full-typed.json'),'parser':str(P),'parserSHA256':sha(P),'noLuaExecution':True});
with L.open('a',encoding='utf-8') as f:f.write('\nX2exact46subset datastage selectsONLYactual20SavedVariablesLua acrossfourvariantpaths byactualinventory. Existingliteralparser reusedunchanged; no V42grammar expansion. Rawtypedallsourcecache ignored '+str(C/'X2-20-selected-full-typed.json')+'; schematicresults '+json.dumps([(x['id'],x['state']) for x in overview])+'; not fullarchivecoverage or A1manualread. No archiveintegrityrerun/sourceexecution. Command python -X utf8 '+str(R/'work/old-reference-r36-13d5mmwk/parse-x2-selected20.py')+' exit0.\n')
print('X2_DATA_PARSE_READY',str(O/'x2-selected-literal-parse-overview.json'))
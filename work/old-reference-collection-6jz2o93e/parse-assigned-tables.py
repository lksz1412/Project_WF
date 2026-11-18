import ast,json,sys,hashlib,re,collections
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8')
R=Path('D:/Projects/Project_WF');C=R/'work/old-reference-collection-6jz2o93e';OLD=R/'work/old-reference-collection-0qlzzyxg';O=R/'Codex/results/old-reference/acquisition';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';parser=R/'work/source-analysis-data-vbibwfzc/parse-profile-literals.py'
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
# Reuse only already-read lexer regex and function/class definitions. Original driver is not imported or executed.
tree=ast.parse(parser.read_text(encoding='utf-8'));nodes=[]
for n in tree.body:
 if isinstance(n,(ast.FunctionDef,ast.ClassDef)):nodes.append(n)
 elif isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='pat' for t in n.targets):nodes.append(n)
ns={'re':re};exec(compile(ast.Module(body=nodes,type_ignores=[]),str(parser)+'#definitions-only','exec'),ns);Parser=ns['Parser']
with L.open('a',encoding='utf-8') as f:f.write('\n## Followup static literal-table parsing unit\nParent dispatch exact9 source tables: 2009 uniqueSavedVariables suffix kgPanels/Dominos/Skinner; Alpha STANDARD/SPECIAL !DevilUI/Profile/kgPanels/Dominos/Masque. Fullread reusedparser '+str(parser)+':1-'+str(len(parser.read_text(encoding='utf-8').splitlines()))+' and prior source-analysis/iter_1/work_log.md:1-'+str(len((R/'Codex/results/handoffs/source-analysis/iter_1/work_log.md').read_text(encoding='utf-8').splitlines()))+'. PriorJSON schema/counts queried programmatically. AST whitelist copies only parser definitions/pat into ownaccessory; original driver not run, no Lua code executed. Inputinventory -> exactsuffix setgate -> literalparser fullltoken consumption -> schema/selected spans/hash/full typedcache -> A1; NEWoutputs only, no priorcache/2022source writes or CRC. Full legacy names remain existinginventory references; publicsmallsource records use suffix+inventory index. Freshcache '+str(C)+'.\n')
a=json.loads((OLD/'archive-2009-members.json').read_text(encoding='utf-8'));b=json.loads((OLD/'alpha-nsis-members.json').read_text(encoding='utf-8'));targets=[]
for name in ['kgPanels','Dominos','Skinner']:
 hits=[(i,x) for i,x in enumerate(a) if x['filename'].replace(chr(92),'/').endswith('SavedVariables/'+name+'.lua')];assert len(hits)==1
 i,x=hits[0];targets.append({'id':'2009-'+name,'inventoryPath':str(OLD/'archive-2009-members.json'),'inventoryIndex0':i,'sourceSuffix':'SavedVariables/'+name+'.lua','path':x['target']})
for variant in ['STANDARD','SPECIAL']:
 for name in ['kgPanels','Dominos','Masque']:
  suffix='var/'+variant+'/Interface/AddOns/!DevilUI/Profile/'+name+'.lua';hits=[(i,x) for i,x in enumerate(b) if x['filename'].replace(chr(92),'/')==suffix];assert len(hits)==1
  i,x=hits[0];targets.append({'id':'alpha-'+variant+'-'+name,'inventoryPath':str(OLD/'alpha-nsis-members.json'),'inventoryIndex0':i,'sourceSuffix':suffix,'path':x['extractedPath']})
results=[];full=[]
for target in targets:
 p=Path(target['path']);raw=p.read_bytes();encoding=None;fail=[]
 for enc in ['utf-8-sig','cp949']:
  try:text=raw.decode(enc);encoding=enc;break
  except UnicodeDecodeError as ex:fail.append({'encoding':enc,'error':str(ex)})
 out={k:v for k,v in target.items() if k!='path'};out.update(SHA256=sha(p),sourceBytes=len(raw),encoding=encoding,decodeAttempts=fail)
 if encoding is None:out.update(state='decode-failed');results.append(out);continue
 text=text.replace('\r\n','\n').replace('\r','\n');out['sourceLines']=len(text.splitlines())
 try:
  parserObj=Parser(text);data=parserObj.parse();assert parserObj.pos==len(parserObj.ts)
  schemas=[]
  for root,d in data.items():
   info={'rootAssignment':root,'type':type(d).__name__,'rootSpan':parserObj.spans.get(root)}
   if isinstance(d,dict):
    info.update(topKeys=list(d),topKeyCount=len(d))
    for k in ['profiles','global','layouts','profileKeys']:
     if isinstance(d.get(k),dict):info[k+'Count']=len(d[k]);info[k+'Keys']=list(d[k])
   schemas.append(info)
  out.update(state='parsed-fully',literalTokens=len(parserObj.ts),consumedTokens=parserObj.pos,duplicates=parserObj.dups,schemas=schemas)
  # Lossless typed table encoding avoids changing numeric/string keys or conflating them.
  def typed(v):
   if isinstance(v,dict):return {'luaTableEntries':[{'keyType':type(k).__name__,'key':k,'value':typed(val)} for k,val in v.items()]}
   return v
  full.append({'source':out,'typedData':typed(data),'spans':parserObj.spans})
 except Exception as ex:out.update(state='not-literal-or-parser-failed',error=str(ex))
 results.append(out);print(json.dumps(out,ensure_ascii=False),flush=True)
save(C/'literal-tables-full-typed.json',full);save(O/'literal-table-parse-overview.json',{'parserSource':str(parser),'parserSHA256':sha(parser),'reuseMethod':'AST-selected Parser/unquote/pat definitions only; olddriver not run. No Lua execution.','expectedCount':9,'results':results,'fullTypedDataCache':str(C/'literal-tables-full-typed.json'),'numericKeyPolicy':'Lossless keyType+key table entries; preserve int/string identity.'})
print('PARSE_DONE',len(results),sum(x['state']=='parsed-fully' for x in results))
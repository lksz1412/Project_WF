import json,hashlib,copy,tempfile
from pathlib import Path
R=Path('D:/Projects/Project_WF');O=R/'Codex/results/old-reference/acquisition/r36/other-posts';C=Path(tempfile.mkdtemp(prefix='old-reference-r36-',dir=R/'work'));L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';rawcache=R/'work/old-reference-r36-13d5mmwk/new-selected-literal-full-typed.json';target=O/'selected-new-literal-settings-compact.json';ready=O/'OTHER_POSTS_READY.json'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def save(p,x,compact=False):Path(p).write_bytes(json.dumps(x,ensure_ascii=False,indent=None if compact else 2,separators=(',',':') if compact else None).encode('utf-8'))
for p in [target,ready]:
 b=C/(p.name+'.before-filter');b.write_bytes(p.read_bytes());assert sha(b)==sha(p)
rawhash=sha(rawcache);old=json.loads(target.read_text(encoding='utf-8'));full=json.loads(rawcache.read_text(encoding='utf-8'));excluded=[];newSources=[]
with L.open('a',encoding='utf-8') as f:f.write('\n## Rootrequested distributionidentityfilter repair\nFullread impactpolicy and workspace-gitsafety policy beforeexistingownoutput change; rootexplicitlydesignated compactfile/consumerrefresh, backups to ignoredfreshcache '+str(C)+'. No Gitoperations perdispatch.\n| Place | Required map type | Method | Impact | Reason |\n| compactsettingsJSON | Samekeys/terms | Python actualschema query SCMDataBase/profileKeys + rg literalfilename | together | Exclude roster mappings and metadata keysets |\n| OTHER_POSTS_READY.json | Consumer/pointer | JSONschema programmatic + rg exactpointer | together | Declare filteredcoverage/exclusionmanifest |\n| ignored fulltypedsource/cache | Inputproducer and twinfullcopy | existingactual8tabledata parsed, sourcehashspans preserved | checkonly | Whole-sourceparse/roundtrip proofs immutable |\n| old executable acquisition scripts | Callers/callees | rg pointer found new-data-and-preserve.py/other-posts-ready.py; scripts actualauthored/fullsource in samecontext | nochange historicalrecord | No rerun, no codecontractchange, oldexecutevidence retained |\n| Newfilter actual8datasetgate | Lockedcheck/runtime | Originaltypeddata -> filteredcompact -> typedrestore/equality; subtree absence +metadataabsence | together | Newprivacyboundary applies to real input not toyrecords |\n| ownlog/priorresults/archives | Record/twins | currentownership inventory | appendonly/checkonly | Keep history/rawdata/sourcebytehash/CRC unchanged |\n| ExternalA1report/masterrecords | Consumer outsideownership | Parentexplicit message + knownpointer | checkonly | Notify changedcoverage, do not editothers |\nNo repositorycode caller/callee, hidden twinartifact, or lockedtest modified. Newscript accessoryfunction only. No cleanup/delete.\n')
def dec(v):return {e['key']:dec(e['value']) for e in v['luaTableEntries']} if isinstance(v,dict) and 'luaTableEntries' in v else v
def leaves(v):return sum(leaves(x) for x in v.values()) if isinstance(v,dict) else 1
for item in full:
 data=dec(item['typedData']);rec=copy.deepcopy(item['source']);spans=item['spans'];sid=rec['id'];localExcluded=[]
 def filterTree(v,path):
  if not isinstance(v,dict):return v
  out={}
  for k,value in v.items():
   pp=path+[str(k)]
   if k in ('profileKeys','SCMDataBase'):
    e={'sourceID':sid,'path':pp,'reason':'character/account profileselector mapping' if k=='profileKeys' else 'distribution nickname/class database roster','entryCount':len(value) if isinstance(value,dict) else 1,'scalarLeafCount':leaves(value),'sourceSHA256':rec['sourceSHA256'],'sourceSpan':spans.get('/'.join(pp)),'ignoredRawTypedCache':str(rawcache)};excluded.append(e);localExcluded.append(e)
   else:out[k]=filterTree(value,pp)
  return out
 selected=filterTree(data,[]);types=[]
 def plain(v,path):
  if not isinstance(v,dict):return v
  assert len({str(k) for k in v})==len(v)
  if any(not isinstance(k,str) for k in v):types.append({'path':path,'keys':[{'value':k,'type':type(k).__name__} for k in v]})
  return {str(k):plain(x,path+[str(k)]) for k,x in v.items()}
 converted=plain(selected,[])
 def restore(v,path):
  if not isinstance(v,dict):return v
  s=next((q for q in types if q['path']==path),None);m={str(q['value']):q['value'] for q in s['keys']} if s else {k:k for k in v};return {m[k]:restore(x,path+[k]) for k,x in v.items()}
 assert restore(converted,[])==selected
 def assertFiltered(v):
  if isinstance(v,dict):
   assert 'profileKeys' not in v and 'SCMDataBase' not in v
   for x in v.values():assertFiltered(x)
 assertFiltered(converted)
 for schema in rec.get('rootSchemas',[]):
  if schema['name']=='SCMDataBase':schema['topKeys']=None;schema['publicKeySetState']='excluded-roster-keyset';schema['excludedEntryCount']=len(data['SCMDataBase'])
 query=[]
 def walk(v,path):
  if not isinstance(v,dict):return
  import re
  for k,value in v.items():
   pp=path+[str(k)]
   if not isinstance(value,dict) and re.search(r'(?i)(layout|panel|border|bg|background|texture|alpha|mouse|width|height|scale|point|anchor|position|^x$|^y$|row|column|padding|spacing|SkinID|skin)',str(k)):query.append({'path':pp,'value':value,'span':spans.get('/'.join(pp))})
   walk(value,pp)
 walk(selected,[]);rec['queryLeafCount']=len(query);rec['publishedCoverage']='filtered-settings-subset; whole-source literal parsing proof retained separately in ignoredcache';rec['excludedContainerCount']=len(localExcluded)
 newSources.append({'source':rec,'settings':converted,'nonStringKeySchemas':types,'keyNameSelectedLeaves':query,'excludedKeyPaths':localExcluded,'spanCache':str(rawcache),'note':'Complete source token-consumption proof is separate from this filtereddelivery. profileKeys/SCMDataBase identitycontainers omitted, including metadata rosterkeysets. Retainedvalues/keytypes equal source subset.'})
new=copy.deepcopy(old);new['sources']=newSources;byid={x['source']['id']:x['source'] for x in newSources};new['results']=[byid.get(x['id'],x) for x in old['results']];manifest={'state':'filtered-delivery-not-fullsource','sourceCount':len(newSources),'excludedContainerCount':len(excluded),'excludedEntryCount':sum(e['entryCount'] for e in excluded),'excludedScalarLeafCount':sum(e['scalarLeafCount'] for e in excluded),'excludedKeyPaths':excluded,'rawIgnoredTypedCache':str(rawcache),'rawIgnoredTypedCacheSHA256':rawhash,'originalCompactIgnoredBackup':str(C/(target.name+'.before-filter')),'originalCompactSHA256':sha(C/(target.name+'.before-filter')),'retainedDataGate':'All8 actualparsedsource tables filtered recursively; exacttypedrestore equality for every retained setting; no excludedcontainer in settings or query/schema keysets. Fullparse states unchanged;3V42boundaries remain.','sourceIdentityNotice':'These are distribution mappings; no claim of currentuser identity.'};new['deliveryContract']=manifest;new['method']='Nonexecutingwhole-source literalparser proof stored ignored. Public compactsettings intentionally excludes identity-bearing profileKeys and SCMDataBase roster containers plus metadata keysets; exactretainedsubset/typedkey restoration verified.';save(target,new,True);save(O/'selected-new-literal-exclusions.json',manifest)
# Only permitted consumer schema update; same payload path now explicitlyfiltered.
r=json.loads(ready.read_text(encoding='utf-8'));r['selectedLiteralDataCoverage']='filtered-settings-subset;8 whole-sourceparse successes recorded separately;3V42boundaries and1missing unchanged';r['selectedLiteralExclusions']=str(O/'selected-new-literal-exclusions.json');r['ignoredFullTypedSource']=str(rawcache);save(ready,r)
assert sha(rawcache)==rawhash;check=json.loads(target.read_text(encoding='utf-8'));assert len(check['sources'])==8 and len(check['results'])==11
for s in check['sources']:
 assertFiltered(s['settings'])
 for sc in s['source'].get('rootSchemas',[]):
  if sc['name']=='SCMDataBase':assert sc['topKeys'] is None
assert sum(x['state']=='not-literal-or-parser-boundary' for x in check['results'])==3
with L.open('a',encoding='utf-8') as f:f.write('Identityfilter actual8tables verification exit0: '+json.dumps({k:manifest[k] for k in ['excludedContainerCount','excludedEntryCount','excludedScalarLeafCount','rawIgnoredTypedCacheSHA256']})+'; oldwholetypedcache unchangedhash, sourcebytehash/token/spans unaffected. Publiccompact '+str(target.stat().st_size)+'B. CallerA1 must use deliveryContract/exclusions and never treat filteredsettings as whole-filecoverage. Backup oldcompact in ignoredcache, no priorrawsource/artifact deletion. Command python -X utf8 '+str(R/'work/old-reference-r36-13d5mmwk/filter-public-settings.py')+' exit0.\n')
print(json.dumps({'compact':str(target),'bytes':target.stat().st_size,'manifest':str(O/'selected-new-literal-exclusions.json'),'exclusions':[{k:e[k] for k in ['sourceID','path','entryCount','scalarLeafCount']} for e in excluded],'ignoredCache':str(C)},ensure_ascii=False,indent=2))
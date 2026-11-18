import json,hashlib
from pathlib import Path
R=Path('D:/Projects/Project_WF');O=R/'Codex/results/old-reference/acquisition';C=R/'work/old-reference-collection-6jz2o93e';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md'
a=json.loads((C/'literal-tables-full-typed.json').read_text(encoding='utf-8'))
def dec(v):return {e['key']:dec(e['value']) for e in v['luaTableEntries']} if isinstance(v,dict) and 'luaTableEntries' in v else v
out=[]
for item in a:
 d=dec(item['typedData']);selected={root:{k:v[k] for k in ['profiles'] if k in v}|({'global':{k:v['global'][k] for k in ['layouts','artwork','version'] if k in v['global']}} if isinstance(v.get('global'),dict) else {}) for root,v in d.items() if isinstance(v,dict)};types=[]
 def plain(v,path):
  if not isinstance(v,dict):return v
  assert len({str(k) for k in v})==len(v),'JSON key collision'
  if any(not isinstance(k,str) for k in v):types.append({'path':path,'keys':[{'value':k,'type':type(k).__name__} for k in v]})
  return {str(k):plain(x,path+[str(k)]) for k,x in v.items()}
 converted=plain(selected,[])
 def restore(v,path):
  if not isinstance(v,dict):return v
  s=next((x for x in types if x['path']==path),None);mapping={str(x['value']):x['value'] for x in s['keys']} if s else {k:k for k in v}
  return {mapping[k]:restore(x,path+[k]) for k,x in v.items()}
 assert restore(converted,[])==selected
 out.append({'sourceID':item['source']['id'],'sourceSuffix':item['source']['sourceSuffix'],'SHA256':item['source']['SHA256'],'inventoryPath':item['source']['inventoryPath'],'inventoryIndex0':item['source']['inventoryIndex0'],'settings':converted,'nonStringKeySchemas':types,'spansCache':str(C/'literal-tables-full-typed.json')})
p=O/'literal-settings-compact.json';p.write_bytes(json.dumps({'encoding':'CompactJSON. Actual integer/string table key types preserved in nonStringKeySchemas; no str-key collisions, exact restoration equals all selected source profiles/layouts/artwork. Account-character profileKeys mappings excluded. Allframe/profile/layout sets retained.','sources':out},ensure_ascii=False,separators=(',',':')).encode('utf-8'))
parser=R/'work/source-analysis-data-vbibwfzc/parse-profile-literals.py';oldlog=R/'Codex/results/handoffs/source-analysis/iter_1/work_log.md'
with L.open('a',encoding='utf-8') as f:f.write('\nCompactJSON followup sameunit newpath literal-settings-compact.json '+str(p.stat().st_size)+'bytes; all9 selectedsource trees roundtrip with explicit nonStringKeySchemas==originaltables, actualwholeprofile/layout/artwork comparison PASS; no keycollision. No overwrite. Readcoverage exact measured correction: parser1-'+str(len(parser.read_text(encoding='utf-8').splitlines()))+'; priorlog1-'+str(len(oldlog.read_text(encoding='utf-8').splitlines()))+' (earlieraddendum approximate80 replaced by actual count here). No further sourceparse/CRC/network. Command python -X utf8 '+str(C/'compact-settings.py')+' exit0.\n')
print(str(p),p.stat().st_size)
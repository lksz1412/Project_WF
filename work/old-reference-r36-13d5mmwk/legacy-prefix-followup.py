import sys,json,re,hashlib,subprocess,zipfile,stat,struct,ast,tempfile,shutil
from pathlib import Path,PureWindowsPath
from urllib.parse import quote
sys.stdout.reconfigure(encoding='utf-8');R=Path('D:/Projects/Project_WF');C=Path(tempfile.mkdtemp(prefix='old-reference-r36-',dir=R/'work'));O=R/'Codex/results/old-reference/acquisition/r36/legacy-prefix-fallback';O.mkdir(exist_ok=True);L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';(C/'downloads').mkdir()
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
for src,name in [(R/'work/old-reference-r36-3ed3y_p1/metadata-and-v42.py','safezip'),(R/'work/old-reference-r36-3ed3y_p1/historical-predicted.py','get')]:
 tree=ast.parse(src.read_text(encoding='utf-8'));exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name==name],type_ignores=[]),str(src)+'#own-definition-only','exec'))
rows=json.loads((R/'Codex/results/old-reference/acquisition/r36/idx-45-attachment-inventory.json').read_text(encoding='utf-8'))['rows'];source=json.loads((R/'Codex/results/old-reference/acquisition/r36/other-posts/idx-1932-attachment-metadata.json').read_text(encoding='utf-8'));prefix=source['setDownloadInfoLiterals'][0]['URL'].rsplit('/',1)[0]+'/';results=[]
for n,name in enumerate(['DevilUI-X2 R3.4.zip','DevilUI-X2_R1.zip','DevilUI 3.05.zip'],1):
 row=next(r for r in rows if r['filenameLiteral']==name);url=prefix+quote(name,safe='');p=C/'downloads'/name;r={'postID':45,'filename':name,'row':row,'URLbasis':'PREDICTED actualidx45filename appended to observedidx1932legacy/publicprefix; ONEGET perfilename, no olddateURL repeat','prefixSource':source['setDownloadInfoLiterals'][0],'provenance':get(url,p),'state':'failed'}
 if r['provenance'].get('HTTP')==200 and r['provenance'].get('isZIP'):
  r['state']='HTTP200-validZIP';r['archiveChecks']=safezip(p,'legacy-idx45-'+str(row['ordinal1']));durable=R/('SourceArchive/post-45-'+row['dateLiteral']+'/originals');durable.mkdir(parents=True,exist_ok=True);dest=durable/name;assert not dest.exists()
  with p.open('rb') as f,dest.open('xb') as w:shutil.copyfileobj(f,w)
  r['preservedCopy']={'path':str(dest),'sourceSHA256':sha(p),'copySHA256':sha(dest),'equal':sha(p)==sha(dest)};assert r['preservedCopy']['equal']
 results.append(r);save(O/'legacy-prefix-results.json',{'cache':str(C),'results':results});print('LEGACY_GET',name,r['provenance'].get('HTTP'),r['state'],flush=True)
 if r['provenance'].get('HTTP')!=404:break
with L.open('a',encoding='utf-8') as f:f.write('\nRootexplicitlyauthorized boundedlegacy-prefix counterpart followup after1932receipt. Observed1932prefix + exactactual45names, all URLs PREDICTED notliteral, primaryoneGET thenonlyif404 atmost2furtherGETs. No daterepeat/grid/fileID/auth. Freshcache '+str(C)+'; results '+json.dumps([{'filename':r['filename'],'HTTP':r['provenance'].get('HTTP'),'state':r['state'],'URL':r['provenance']['requestedURL']} for r in results])+'; successfulnewbinary preservednewSourceArchive/recordedcopyhash only. Command python -X utf8 '+str(R/'work/old-reference-r36-13d5mmwk/legacy-prefix-followup.py')+' exit0.\n')
print('LEGACY_DONE',str(O/'legacy-prefix-results.json'),flush=True)
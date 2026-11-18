import sys,json,re,hashlib,subprocess,zipfile,time,ast,struct,stat
from pathlib import Path,PureWindowsPath
from urllib.parse import quote
sys.stdout.reconfigure(encoding='utf-8')
R=Path('D:/Projects/Project_WF');C=R/'work/old-reference-r36-3ed3y_p1';O=R/'Codex/results/old-reference/acquisition/r36';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';(C/'downloads').mkdir(exist_ok=True)
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def log(t):
 with L.open('a',encoding='utf-8') as f:f.write(t+'\n')
# Reuse own validation function only; no old driver or previous checks executed.
t=ast.parse((C/'metadata-and-v42.py').read_text(encoding='utf-8'));exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name=='safezip'],type_ignores=[]),'<own-safezip-definition>','exec'))
def get(url,path):
 q=lambda s:"'"+str(s).replace("'","''")+"'";ps="$ErrorActionPreference='Stop';try{$r=Invoke-WebRequest -Uri "+q(url)+" -OutFile "+q(path)+" -PassThru -UseBasicParsing -TimeoutSec 45;@{HTTP=[int]$r.StatusCode;finalURL=$r.BaseResponse.ResponseUri.AbsoluteUri;contentType=[string]$r.Headers['Content-Type'];time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}catch{$c=$null;if($_.Exception.Response){$c=[int]$_.Exception.Response.StatusCode};@{HTTP=$c;error=$_.Exception.Message;time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}"
 cp=subprocess.run(['powershell','-NoProfile','-NonInteractive','-Command',ps],capture_output=True,text=True,encoding='utf-8',errors='replace')
 try:r=json.loads(cp.stdout.lstrip('\ufeff'))
 except Exception:r={'HTTP':None,'error':cp.stderr or cp.stdout}
 r.update(requestedURL=url,localpath=str(path),attempts=1,commandExitCode=cp.returncode)
 if path.exists():r.update(bytes=path.stat().st_size,SHA256=sha(path),first16Hex=path.read_bytes()[:16].hex(),isZIP=zipfile.is_zipfile(path))
 return r
m=json.loads((O/'FIRST_172_METADATA_READY.json').read_text(encoding='utf-8'));results=[]
for sel in m['selectedHistorical']:
 if sel['metadataState']!='consistent':results.append({'selection':sel,'state':'contradiction-stopped'});continue
 if sel['role'].startswith('fallback') and any(r.get('ZIPverified') and r['selection']['role'] in ('primary','earlier-comparison') for r in results):continue
 row=sel['row'];name=row['filenameLiteral'];date=row['dateLiteral'].replace('-','/');url='https://pds.inven.co.kr/upload/'+date+'/addon/'+quote(name,safe='');p=C/'downloads'/name;r={'selection':sel,'URLbasis':'PREDICTED based observed latest pds /upload/YYYY/MM/DD/addon/filename pattern + exact selected row date/name; not observed older literal','state':'predicted-not-yet-verified','provenance':get(url,p),'ZIPverified':False}
 if r['provenance'].get('HTTP')==200 and r['provenance'].get('isZIP'):
  r['ZIPverified']=True;r['state']='HTTP200-validZIP; exacthistoricalidentity-for-A1-verification';r['archiveChecks']=safezip(p,'historical-'+str(row['ordinal1']))
 else:r['state']='candidate-unavailable-or-notZIP'
 results.append(r);save(O/'historical-predicted-acquisition.json',results);print('PREDICTED_GET',name,r['provenance'].get('HTTP'),r['state'],flush=True)
 time.sleep(.3)
log('R36 historicalboundedGET exactrows -> predictedpdsURL ONEGETeach: '+json.dumps([{'filename':r.get('selection',{}).get('row',{}).get('filenameLiteral'),'url':r.get('provenance',{}).get('requestedURL'),'HTTP':r.get('provenance',{}).get('HTTP'),'state':r['state']} for r in results],ensure_ascii=False)+'. No latestAlphaURL mappedtoolderfiles. Exposedpublicpattern hypothesis explicitly PREDICTED untilactualHTTP/ZIP; successfulfileidentity still A1sourceinspection. Sourcebytes/cache preserved. Exactcommand python -X utf8 '+str(C/'historical-predicted.py')+' exit0 reached. Boundedfilename/forum/blogfallback remainsnext.')
print('PREDICTED_BATCH_DONE',flush=True)
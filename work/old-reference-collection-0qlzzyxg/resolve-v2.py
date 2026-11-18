import sys,json,re,hashlib,subprocess,time,copy,platform
from pathlib import Path
from urllib.parse import urlparse,urlunparse,urljoin
from datetime import datetime,timezone
from bs4 import BeautifulSoup
from PIL import Image
sys.stdout.reconfigure(encoding='utf-8')
ROOT=Path('D:/Projects/Project_WF');C=ROOT/'work/old-reference-collection-0qlzzyxg';O=ROOT/'Codex/results/old-reference/acquisition';L=ROOT/'Codex/results/handoffs/old-reference/acquisition/work_log.md'
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def log(t):
 with L.open('a',encoding='utf-8') as f:f.write(t+'\n')
log('## Supplemental mapping and file-URL correction impact\nInitial image manifest deliberately required viewer suffix to appear unchanged in thumbnail;43 actual thumb/n or s_ thumbnails unresolved. Actual DOM exposes upload origin and /upload/ prefix plus literal full viewImage path. Correct mapping derives only observed prefix + literal path; no filename replacement/inference. New images-v2/catalog-v2/posts-v2/provenance-v2/coverage-v2, original records preserved. Inputs actual58 associations; consumers A1/image-reader must use v2. No successful image or HTML GET repeated. File URLs additionally occur in script parent.setDownloadInfo literals, absent from anchor-only field; extract literals without evaluation and preserve script line. Image full-load check now verifies pixels can decode without displaying/interpreting. Existing34 text remains unchanged. Mandatory source reading plan130-160 reread to close output-truncation coverage.')
P=json.loads((O/'catalog.json').read_text(encoding='utf-8'));I=json.loads((O/'images.json').read_text(encoding='utf-8'));V=json.loads((O/'acquisition-provenance.json').read_text(encoding='utf-8'));fixprov=[]
def fetch(url,p):
 q=lambda s:"'"+str(s).replace("'","''")+"'"
 ps="$ErrorActionPreference='Stop';try{$r=Invoke-WebRequest -Uri "+q(url)+" -OutFile "+q(p)+" -PassThru -UseBasicParsing -TimeoutSec 45;@{HTTP=[int]$r.StatusCode;finalURL=$r.BaseResponse.ResponseUri.AbsoluteUri;contentType=[string]$r.Headers['Content-Type'];time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}catch{$c=$null;if($_.Exception.Response){$c=[int]$_.Exception.Response.StatusCode};@{HTTP=$c;error=$_.Exception.Message;time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}"
 for attempt in range(2):
  cp=subprocess.run(['powershell','-NoProfile','-NonInteractive','-Command',ps],capture_output=True,text=True,encoding='utf-8',errors='replace')
  try:r=json.loads(cp.stdout.lstrip('\ufeff'))
  except Exception:r={'HTTP':None,'error':cp.stderr or cp.stdout}
  if r.get('HTTP') in (429,503) and attempt==0:time.sleep(3);continue
  break
 r.update(sourceURL=url,localpath=str(p),state='acquired' if r.get('HTTP')==200 else 'failed',attempts=attempt+1,commandExitCode=cp.returncode)
 if p.exists():r.update(bytes=p.stat().st_size,SHA256=sha(p))
 fixprov.append(r);time.sleep(.2);return r
byurl={x['fullURL']:x for x in I if x.get('fullURL') and x.get('decodeStatus')=='verified'}
for x in I:
 if x.get('fullURL') is None:
  literal=re.search(r"viewImage\(\s*['\"]([^'\"]+)['\"]",x['viewerLiteral']);thumb=urlparse(x['thumbURL']);prefix=thumb.path.split('/upload/',1)
  if literal and len(prefix)==2 and thumb.hostname in ('upload.inven.co.kr','upload2.inven.co.kr','upload3.inven.co.kr'):
   suffix=literal.group(1)
   if not suffix.startswith(('/','\\')) and '..' not in suffix.split('/'):
    x['fullURL']=urlunparse((thumb.scheme,thumb.netloc,prefix[0]+'/upload/'+suffix,'','',''));x['mappingEvidence']={'observedThumbOrigin':thumb.scheme+'://'+thumb.netloc,'observedPathPrefix':prefix[0]+'/upload/','literalViewerPath':suffix};x['initialMappingState']='unresolved-preserved-in-images.json';x['error']=None
 if not x.get('fullURL'):continue
 u=x['fullURL']
 if x.get('decodeStatus')!='verified':
  if u in byurl:
   rr=byurl[u];x.update({k:rr.get(k) for k in ['localpath','HTTP','time','bytes','SHA256','width','height','imageFormat','contentType','error','finalURL','decodeStatus']})
  elif u=='https://upload.inven.co.kr/upload/2009/12/10/bbs/i27419179.jpg':
   pp=ROOT/'work/old-reference-entry-4dc60c8443794ba381f02df6f6156efa/sample-2958-original.jpg';meta=json.loads(pp.with_name('sample-2958-acquisition.json').read_text(encoding='utf-8-sig'));x.update(localpath=str(pp),HTTP=meta['status'],time=meta['acquired'],bytes=pp.stat().st_size,SHA256=sha(pp),state='reused',contentType='image/jpeg',error=None);fixprov.append({'sourceURL':u,'localpath':str(pp),'state':'reused','HTTP':meta['status'],'time':meta['acquired'],'bytes':pp.stat().st_size,'SHA256':sha(pp)})
  else:
   ext=Path(urlparse(u).path).suffix or '.img';p=C/('image-'+hashlib.sha256(u.encode()).hexdigest()[:20]+ext);rr=fetch(u,p);x.update(rr)
 try:
  with Image.open(x['localpath']) as im:x.update(width=im.width,height=im.height,imageFormat=im.format);im.load()
  x['decodeStatus']='verified-full-load';x['error']=None
 except Exception as ex:x.update(decodeStatus='failed',error=str(ex))
 byurl[u]=x
 print('IMAGE_READY',x['postID'],x['section'],x['DOMordinal'],x['decodeStatus'],flush=True)
 if x['postID'] in (11218,2958):save(O/('priority-'+str(x['postID'])+'-images-v2.json'),[r for r in I if r['postID']==x['postID']])
(O/'posts-v2').mkdir(exist_ok=True)
scriptURLs=[]
for p in P:
 p['images']=[x for x in I if x['postID']==p['postID']]
 f=p.get('iframes',{}).get('fileInfo',{});rawpath=f.get('provenance',{}).get('localpath')
 if rawpath:
  s=BeautifulSoup(Path(rawpath).read_text(encoding='utf-8-sig'),'html.parser');literals=[]
  for node in s.find_all('script'):
   text=node.get_text()
   for m in re.finditer(r"(?:https?:)?//[^\s'\"<>]+",text):
    url=m.group(0)
    if 'pds.inven.co.kr/' in url:literals.append({'url':urljoin(f['sourceURL'],url),'literal':url,'scriptText':text,'sourceLocation':{'path':rawpath,'line':node.sourceline,'selector':'script'},'executed':False})
  f['scriptPublicDownloadURLLiterals']=literals;f['literalPublicDownloadURLs']=list(dict.fromkeys(f.get('literalPublicDownloadURLs',[])+[a['url'] for a in literals]));scriptURLs.append({'postID':p['postID'],'literals':literals})
 # retain unabridged original article extract, replace image/iframe metadata with updated supplementary sections.
 original=(O/'posts'/f'idx-{p["postID"]}.md').read_text(encoding='utf-8')
 (O/'posts-v2'/f'idx-{p["postID"]}.md').write_text(original+'\n\n## Corrected authoritative image associations and literal file URLs\nInitial associations above are acquisition-stage history. Use this corrected manifest for image acquisition state; full body/notes unchanged.\n'+json.dumps({'images':p['images'],'fileInfo':f},ensure_ascii=False,indent=2),encoding='utf-8')
 save(O/f'idx-{p["postID"]}-v2.json',p)
save(O/'catalog-v2.json',P);save(O/'images-v2.json',I);save(O/'acquisition-provenance-v2.json',V+fixprov);save(O/'file-download-literals.json',scriptURLs)
D=json.loads((O/'coverage.json').read_text(encoding='utf-8'));D.update(imageDecodedRefs=sum(x.get('decodeStatus')=='verified-full-load' for x in I),imageUniqueHashes=len({x['SHA256'] for x in I if x.get('decodeStatus')=='verified-full-load'}),imageFailures=[x for x in I if x.get('decodeStatus')!='verified-full-load'],fetchFailures=[x for x in V+fixprov if x['state']=='failed'],authoritativeManifest='images-v2.json',authoritativeCatalog='catalog-v2.json',authoritativePosts='posts-v2/',correction='Observed thumbnail upload prefix + literal full viewer path. Original stage records retained.')
save(O/'coverage-v2.json',D)
save(O/'existing-2022-extraction-pointers.json',{'Interface':str(ROOT/'SourceArchive/2022-11-19/extracted/Interface'),'Fonts':str(ROOT/'SourceArchive/2022-11-19/extracted/Fonts'),'CRC':'prior result reused, not rerun'})
assert len(I)==58 and len(P)==34 and sum(len(p['images']) for p in P)==58
assert all(x.get('width',0)>0 and x.get('height',0)>0 for x in I if x.get('decodeStatus')=='verified-full-load')
log('Corrected actual34/58 associations self-check: '+json.dumps({k:D[k] for k in ['detailParsed','imageRefs','imageDecodedRefs','imageUniqueHashes']})+'. Source HTML not refetched, ZIP CRC not rerun. File-download-literals include script parent.setDownloadInfo URLs; never executed. Corrected manifest/catalog/posts are v2; initial records retained. Exit0.')
print('V2_DONE',json.dumps({k:D[k] for k in ['detailParsed','imageRefs','imageDecodedRefs','imageUniqueHashes']}),flush=True)
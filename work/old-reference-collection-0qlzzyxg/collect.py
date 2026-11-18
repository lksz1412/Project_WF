import os,sys,json,re,time,hashlib,subprocess,tempfile,platform,zipfile,stat,shutil,struct
from pathlib import Path,PureWindowsPath
from urllib.parse import urljoin,urlparse
from datetime import datetime,timezone
from bs4 import BeautifulSoup
import bs4,PIL
from PIL import Image
sys.stdout.reconfigure(encoding='utf-8')
ROOT=Path('D:/Projects/Project_WF'); CACHE=ROOT/'work/old-reference-collection-0qlzzyxg'; OUT=ROOT/'Codex/results/old-reference/acquisition'; LOG=ROOT/'Codex/results/handoffs/old-reference/acquisition/work_log.md'
OUT.mkdir(parents=True,exist_ok=True); (OUT/'posts').mkdir(exist_ok=True); LOG.parent.mkdir(parents=True,exist_ok=True)
BASE='https://wow.inven.co.kr/dataninfo/addonpds/'
ENTRY=ROOT/'work/old-reference-entry-4dc60c8443794ba381f02df6f6156efa'; PR=ROOT/'work/old-reference-priority-root-63f909c7c02c47729d89dba705cb4367'
EXPECTED=[13140,12993,11218,11361,12610,12124,12174,10341,9880,9789,3461,45,8906,8920,7618,7546,6405,4238,4019,4018,4012,2958,2582,2312,1932,1877,1865,1853,1403,1361,1121,1086,1008,546]
prov=[]; images=[]; posts=[]; rows=[]
def now():return datetime.now(timezone.utc).isoformat()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def log(s):
 with LOG.open('a',encoding='utf-8') as f:f.write(s+'\n')
def soup(p):return BeautifulSoup(Path(p).read_text(encoding='utf-8-sig'),'html.parser')
def loc(p,node,selector):return {'path':str(p),'selector':selector,'line':getattr(node,'sourceline',None)}
def reused(p,url,meta=None):
 r={'sourceURL':url,'finalURL':None,'HTTP':None,'time':None,'localpath':str(p),'bytes':Path(p).stat().st_size,'SHA256':sha(p),'state':'reused','metadata':meta,'encoding':'UTF-8 decoded saved text' if str(p).endswith('.html') else 'binary'}
 if meta:
  r['HTTP']=meta.get('status');r['time']=meta.get('time',meta.get('acquired_at'));r['finalURL']=meta.get('finalURL',meta.get('url',meta.get('source_url')))
 prov.append(r);return r
# One ordinary IWR per source, a bounded retry only for 429/503; no TLS changes.
def fetch(url,path,binary=False):
 path=Path(path)
 q=lambda s:"'"+str(s).replace("'","''")+"'"
 ps="$ErrorActionPreference='Stop';$u="+q(url)+";$p="+q(path)+";try {"
 if binary:ps+="$r=Invoke-WebRequest -Uri $u -OutFile $p -PassThru -UseBasicParsing -TimeoutSec 45;"
 else:ps+="$r=Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 45;[IO.File]::WriteAllText($p,$r.Content,[Text.UTF8Encoding]::new($false));"
 ps+="@{HTTP=[int]$r.StatusCode;finalURL=$r.BaseResponse.ResponseUri.AbsoluteUri;contentType=[string]$r.Headers['Content-Type'];time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress }catch{$c=$null;if($_.Exception.Response){$c=[int]$_.Exception.Response.StatusCode};@{HTTP=$c;error=$_.Exception.Message;time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}"
 for attempt in range(2):
  cp=subprocess.run(['powershell','-NoProfile','-NonInteractive','-Command',ps],capture_output=True,text=True,encoding='utf-8',errors='replace')
  try:r=json.loads(cp.stdout.lstrip('\ufeff'))
  except Exception:r={'HTTP':None,'error':cp.stderr or cp.stdout,'time':now()}
  if r.get('HTTP') in (429,503) and attempt==0:time.sleep(3);continue
  break
 r.update(sourceURL=url,localpath=str(path),state='acquired' if r.get('HTTP')==200 else 'failed',attempts=attempt+1,commandExitCode=cp.returncode,encoding='binary' if binary else 'IWR decoded to UTF-8')
 if path.exists():r.update(bytes=path.stat().st_size,SHA256=sha(path))
 prov.append(r);time.sleep(.2);return r
readpaths=['D:/Projects/AGENTS.md',str(ROOT/'Codex/results/handoffs/old-reference/acquisition/brief.md'),str(ROOT/'Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md'),str(ROOT/'Codex/results/REQUEST_LEDGER_phase1.3.md')]+['C:/Users/USER/.agents/skills/'+x for x in ['skill_LKS_original_file-reading/references/policies/feedback_full_file_read_required.md','skill_LKS_original_source-research/SKILL.md','skill_LKS_original_data-pipeline/SKILL.md','skill_LKS_original_secured-windows-tooling/SKILL.md','skill_LKS_original_communication-decisions/references/policies/feedback_confirmed_items_policy.md']]
log('# Mechanical acquisition work log\n'+now()+'\nConfiguration: dispatch bada-a4-helper gpt-6.1-sol/low; actual runtime model/effort/usage unobserved. No commit, source execution, image interpretation, cleanup, or new agents. Historical fixed-collection mode B, supplied two-page scope. Acquisition != A1 reading/image observation.\n## Mandatory reading coverage')
for p in readpaths:log(p+':1-'+str(len(Path(p).read_text(encoding='utf-8-sig').splitlines()))+' (actual tool full-read; initial truncated output re-read in separate calls/chunks)')
log('Project AGENTS missing at '+str(ROOT/'AGENTS.md')+'. Parent messages fully read: legacy ZIP raw names/flags; UTF-8 saved HTML; iframe selectors; bz tool permitted for static listing only before safe extraction. Python stdout -X utf8 used.\n## Input/consumer and impact map\nNew paths only: saved lists + reused details -> exact34 row validator -> detail/iframe/images -> catalog/posts/provenance -> A1 and image-reader. No pre-existing artifacts modified. Same-value universe mechanically matched all34; parsers consume actual UTF8 strings; image source producers are actual body/version/iframe tags; no twin copies modified; real34 gate required. Supplied2ZIP -> central directory/CRC/path validator -> new extraction root/inventory -> A1 static reading. Existing2022 only locate pointers; no CRC/extraction. Scripts accessory only, no source code execution.\nCommands: python -X utf8 '+str(CACHE/'collect.py')+'; internal powershell -NoProfile -NonInteractive Invoke-WebRequest ordinary GET; binary OutFile/PassThru, text WriteAllText UTF8. Runtime: '+platform.python_version()+' bs4 '+bs4.__version__+' Pillow '+PIL.__version__)
entrymeta=json.loads((ENTRY/'entry-fetch.json').read_text(encoding='utf-8-sig'));prioritymeta=json.loads((PR/'acquisition.json').read_text(encoding='utf-8-sig'))
for page,fn in enumerate(['list-first.html','list-page2.html'],1):
 p=ENTRY/fn;s=soup(p);t=s.select_one('table.list');assert t is not None
 reused(p,BASE+'list.php?searchField=subj_subt&searchString=devil'+('&page=2' if page==2 else ''),next((m for m in entrymeta if m.get('path','').replace('\\','/')==str(p).replace('\\','/')),None))
 ordinal=0
 for tr in t.find_all('tr'):
  a=next((a for a in tr.find_all('a') if re.search(r"addonMove\('detail.php',\s*'idx->(\d+)'",a.get('href',''))),None)
  if a is None:continue
  ordinal+=1; literal=a['href'];id=int(re.search(r"'idx->(\d+)'",literal).group(1))
  rows.append({'postID':id,'page':page,'rowOrdinal':ordinal,'title':a.get_text(' ',strip=True),'rowText':tr.get_text(' ',strip=True),'sourceAnchor':literal,'sourceLocation':loc(p,a,'table.list tr a[href]')})
assert [r['postID'] for r in rows]==EXPECTED, [r['postID'] for r in rows]
assert [sum(r['page']==p for r in rows) for p in (1,2)]==[20,14]
save(OUT/'list-rows.json',rows);log('Actual list gate PASS: 20+14 rows, exact ordered34 IDs; literal addonMove strings regex parsed, never evaluated.')
# Prior successful bytes are reused, not fetched.
reusedDetails={2958:ENTRY/'detail-2958.html',11218:PR/'detail-11218.html',13140:PR/'detail-13140.html'}
httpMeta={2958:next(x for x in entrymeta if x['name']=='detail-2958'),**{x['post_id']:x for x in prioritymeta}}
urlImageCache={}
def image_ref(id,section,ordinal,node,p,urlbase):
 thumb=urljoin(urlbase,node.get('src',''));a=node.find_parent('a');literal=(a.get('onclick','') if a else '') or node.get('onclick','');full=thumb;err=None
 m=re.search(r"viewImage\(\s*['\"]([^'\"]+)['\"]",literal)
 if m:
  suffix=m.group(1)
  if suffix in thumb:full=thumb[:thumb.index(suffix)]+suffix
  else:full=None;err='viewer path not present in observed thumbnail URL; unresolved'
 r={'postID':id,'section':section,'DOMordinal':ordinal,'thumbURL':thumb,'viewerLiteral':literal,'fullURL':full,'alt':node.get('alt'),'title':node.get('title'),'sourceLocation':loc(p,node,section+' img'),'error':err}
 if full:
  if full in urlImageCache:r.update(urlImageCache[full])
  elif id==2958 and full=='https://upload.inven.co.kr/upload/2009/12/10/bbs/i27419179.jpg':
   pp=ENTRY/'sample-2958-original.jpg';meta=json.loads((ENTRY/'sample-2958-acquisition.json').read_text(encoding='utf-8-sig'));rr=reused(pp,full,meta);r.update({k:rr.get(k) for k in ['localpath','HTTP','time','bytes','SHA256']});r['reuseMetadata']=meta
  else:
   ext=Path(urlparse(full).path).suffix.lower();ext=ext if re.fullmatch(r'\.[a-z0-9]{1,5}',ext) else '.img';pp=CACHE/('image-'+hashlib.sha256(full.encode()).hexdigest()[:20]+ext);rr=fetch(full,pp,True);r.update({k:rr.get(k) for k in ['localpath','HTTP','time','bytes','SHA256','contentType','error','finalURL']})
  if r.get('localpath'):
   try:
    with Image.open(r['localpath']) as im:r.update(width=im.width,height=im.height,imageFormat=im.format);im.verify()
    r['decodeStatus']='verified'
   except Exception as ex:r['decodeStatus']='failed';r['error']=str(ex)
  else:r['decodeStatus']='unresolved'
  urlImageCache[full]={k:r.get(k) for k in ['localpath','HTTP','time','bytes','SHA256','width','height','imageFormat','decodeStatus','contentType','error','finalURL']}
 else:r['decodeStatus']='unresolved'
 images.append(r);return r
for id in [45,11218,2958]+[i for i in EXPECTED if i not in (45,11218,2958)]:
 url=BASE+'detail.php?idx='+str(id)
 if id in reusedDetails:p=reusedDetails[id];dr=reused(p,url,httpMeta[id])
 elif id==45:p=CACHE/'detail-45.html';dr=reused(p,url,json.loads((CACHE/'detail-45-http.json').read_text(encoding='utf-8-sig')))
 else:p=CACHE/f'detail-{id}.html';dr=fetch(url,p)
 post={'postID':id,'url':url,'row':next(r for r in rows if r['postID']==id),'detailProvenance':dr,'acquisitionState':dr['state'],'A1read':False,'imageObserved':False,'sections':{},'iframes':{},'images':[]}
 if dr.get('HTTP')!=200 and dr['state']!='reused':posts.append(post);continue
 s=soup(p);head=s.select_one('#addonDetail .subject');post['title']=head.h3.get_text(' ',strip=True) if head and head.h3 else None
 meta=s.select_one('#addonDetail .info');post['metadataLiteral']=meta.get_text('\n',strip=True) if meta else None
 post['metadataRows']=[{'label':tr.th.get_text(' ',strip=True),'value':tr.td.get_text(' ',strip=True),'line':tr.sourceline} for tr in (meta.find_all('tr') if meta else []) if tr.th and tr.td]
 for sec in ('addonAddon','addonVersion'):
  node=s.select_one('#'+sec);frag=CACHE/f'idx-{id}-{sec}.html';txt=node.get_text('\n',strip=False) if node else None
  if node:frag.write_text(str(node),encoding='utf-8')
  post['sections'][sec]={'state':'missing' if node is None else ('empty' if not node.get_text(strip=True) and not node.find('img') else 'parsed'),'text':txt,'fragmentPath':str(frag) if node else None,'sourceLocation':loc(p,node,'#'+sec),'links':[{'href':a.get('href'),'text':a.get_text(' ',strip=True),'title':a.get('title')} for a in node.find_all('a')] if node else []}
  if node:
   for n,img in enumerate(node.find_all('img'),1):post['images'].append(image_ref(id,sec,n,img,p,url))
 # screenshots precede files; literal actual iframe src saved.
 for typ,selector,short in [('screenshot','screenshot','images'),('fileInfo','fileInfo','files')]:
  frame=s.find('iframe',id=selector)
  if not frame:post['iframes'][typ]={'state':'missing'};continue
  u=urljoin(url,frame.get('src',''));fp=CACHE/f'{short}-{id}.html'
  if id==2958:fp=ENTRY/f'{short}-2958.html';fr=reused(fp,u)
  elif id==45:fr=reused(fp,u,json.loads((CACHE/f'{short}-45-http.json').read_text(encoding='utf-8-sig')))
  else:fr=fetch(u,fp)
  fi={'sourceURL':u,'iframeLiteral':str(frame),'sourceLocation':loc(p,frame,'iframe#'+selector),'provenance':fr,'state':'failed'};post['iframes'][typ]=fi
  if fp.exists() and (fr.get('HTTP')==200 or fr['state']=='reused'):
   fs=soup(fp);node=fs.body;fi['state']='parsed';fi['text']=node.get_text('\n',strip=False) if node else '';fi['links']=[{'href':a.get('href'),'onclick':a.get('onclick'),'text':a.get_text(' ',strip=True),'line':a.sourceline} for a in fs.find_all('a')];fi['literalPublicDownloadURLs']=list(dict.fromkeys(urljoin(u,a.get('href')) for a in fs.find_all('a') if a.get('href','').startswith(('http://','https://','//'))))
   if typ=='fileInfo':
    fi['fileRows']=[{'text':tr.get_text(' ',strip=True),'cells':[td.get_text(' ',strip=True) for td in tr.find_all('td')],'line':tr.sourceline} for tr in fs.find_all('tr') if tr.find('td')]
   else:
    imgs=fs.select('#divImageList img');fi['imageCount']=len(imgs)
    for n,img in enumerate(imgs,1):post['images'].append(image_ref(id,'screenshot',n,img,fp,u))
 post['acquisitionState']='parsed';posts.append(post)
 md=['# idx '+str(id)+' — '+str(post['title']),'Mechanical extract; acquisition only, not A1 full-reading/image observation.', 'Source: '+url,'Raw: '+str(p),'SHA256: '+sha(p),'Metadata selector: #addonDetail .info',post['metadataLiteral'] or '[missing]']
 for sec in ('addonAddon','addonVersion'):
  x=post['sections'][sec];md+=['\n## '+sec,'Source '+json.dumps(x['sourceLocation'],ensure_ascii=False),'State '+x['state'],x['text'] or '', '\nLinks/images references:',json.dumps({'links':x['links'],'images':[im for im in post['images'] if im['section']==sec]},ensure_ascii=False,indent=2)]
 for typ in ('screenshot','fileInfo'):md+=['\n## '+typ,json.dumps(post['iframes'][typ],ensure_ascii=False,indent=2)]
 md+=['\n## Image associations',json.dumps(post['images'],ensure_ascii=False,indent=2)]
 (OUT/'posts'/f'idx-{id}.md').write_text('\n'.join(md),encoding='utf-8')
 save(OUT/f'idx-{id}.json',post)
 log(f'idx{id}: parsed actual sections and iframe records; image refs {len(post["images"])}. Extract at posts/idx-{id}.md; raw paths/line selectors in idx-{id}.json.')
 print('POST_READY',id,len(post['images']),flush=True)
 if id==45:
  refs=[im for im in post['images'] if im['section']=='screenshot'];ready={'postID':45,'sourceURL':url,'detailPath':str(p),'screenshotIframe':post['iframes']['screenshot'],'DOMorder':refs,'fourthEntry':refs[3] if len(refs)>=4 else None,'postExtract':str(OUT/'posts/idx-45.md'),'catalogPath':str(OUT/'idx-45.json'),'note':'Actual iframe DOM order; no content interpretation or Alpha fidelity claim.'};save(OUT/'PRIORITY_READY.json',ready);print('PRIORITY_READY',str(OUT/'PRIORITY_READY.json'),flush=True)
 if id in (45,11218,2958):save(OUT/'priority-images.json',images);save(OUT/'priority-provenance.json',prov)
 save(OUT/'catalog.json',posts);save(OUT/'images.json',images);save(OUT/'acquisition-provenance.json',prov)
# Exact literal attachment-name matching only.
matches=[]
for post in posts:
 for target in ('DevilUI6.1Alpha.zip','Devil_Blackt.zip'):
  rs=post.get('iframes',{}).get('fileInfo',{}).get('fileRows',[]);hit=[r for r in rs if r.get('cells') and r['cells'][0]==target]
  matches.append({'postID':post['postID'],'targetFilename':target,'literalMatches':hit,'state':'literal-match' if hit else 'no-literal-match','note':'Name match alone is not publisher identity or sample settings proof.'})
save(OUT/'attachment-filename-matches.json',matches)
coverage={'expectedPosts':34,'listCounts':[20,14],'listedIDs':[r['postID'] for r in rows],'detailParsed':sum(p['acquisitionState']=='parsed' for p in posts),'posts':[{'postID':p['postID'],'state':p['acquisitionState'],'sections':{k:v['state'] for k,v in p.get('sections',{}).items()},'iframes':{k:v['state'] for k,v in p.get('iframes',{}).items()},'imageRefs':len(p.get('images',[])),'A1read':False,'imageObserved':False} for p in posts],'imageRefs':len(images),'imageDecodedRefs':sum(i.get('decodeStatus')=='verified' for i in images),'imageUniqueHashes':len({i.get('SHA256') for i in images if i.get('decodeStatus')=='verified'}),'imageFailures':[i for i in images if i.get('decodeStatus')!='verified'],'fetchFailures':[r for r in prov if r['state']=='failed'],'A1readCount':None,'imageObservedCount':None,'cache':str(CACHE),'runtime':{'python':platform.python_version(),'bs4':bs4.__version__,'Pillow':PIL.__version__}}
save(OUT/'coverage.json',coverage)
(OUT/'index.md').write_text('# Mechanical source catalog\nAcquisition is not reading or image observation.\n\n'+'\n'.join(f'- idx{p["postID"]}: [{p.get("title", "failed")}]({p["url"]}) — [extract](posts/idx-{p["postID"]}.md), {len(p.get("images",[]))} image refs' for p in posts),encoding='utf-8')
print('COLLECTION_DONE',json.dumps({k:coverage[k] for k in ['detailParsed','imageRefs','imageDecodedRefs','imageUniqueHashes']}),flush=True)
# ZIP static inventory. Raw legacy cp437-decoded names preserved; raw central directory bytes hex retained.
checks=[]; inventories=[]
for label,source,expected in [('2009',ROOT/'SourceArchive/2009-12-10/originals/Devil_Blackt.zip','10FD89E6A27D63DC48217DE48B66E693885E2A46C49253688A13DCCE6E18A3DA'),('alpha',ROOT/'SourceArchive/user-provided-alpha/originals/DevilUI6.1Alpha.zip','1982B7B99F4F9CD58EED8ED505D2041FD526472D8F738A6671B90D6C5ABC473E')]:
 check={'label':label,'source':str(source),'sourceBytes':source.stat().st_size,'SHA256':sha(source),'expectedSHA256':expected,'hashMatch':sha(source)==expected,'CRCtestRuns':0,'unsafe':[],'extractionState':'not-started'};checks.append(check)
 if not check['hashMatch']:continue
 dest=CACHE/('extracted-'+label);dest.mkdir();seen=set();entries=[]
 with zipfile.ZipFile(source) as z:
  raw=source.read_bytes();offset=z.start_dir
  for info in z.infolist():
   assert raw[offset:offset+4]==b'PK\x01\x02';nl,el,cl=struct.unpack_from('<HHH',raw,offset+28);rawname=raw[offset+46:offset+46+nl];offset+=46+nl+el+cl
   name=info.filename;parts=name.replace('\\','/').split('/');why=[];pure=PureWindowsPath(name)
   if pure.is_absolute() or pure.drive or name.startswith(('/','\\')):why.append('absolute/drive/UNC')
   if any(x in ('.','..') for x in parts):why.append('dot/traversal')
   for part in parts:
    if not part:continue
    if re.search(r'[<>:"|?*\x00-\x1f]',part) or part.endswith((' ','.')) or re.fullmatch(r'(?i)(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?',part):why.append('unsafe NTFS name/stream')
   if stat.S_ISLNK(info.external_attr>>16) or (info.external_attr & 0x400):why.append('symlink/reparse')
   target=(dest/Path(*parts)).resolve();root=dest.resolve()
   if not target.is_relative_to(root):why.append('resolved outside root')
   key=str(target).casefold()
   if key in seen:why.append('case/path collision')
   seen.add(key)
   ent={'filename':name,'rawCentralFilenameHex':rawname.hex(),'flagBits':info.flag_bits,'filenameDecode':'utf-8' if info.flag_bits&0x800 else 'cp437 (zipfile default; no rename)','isDirectory':info.is_dir(),'compressedBytes':info.compress_size,'uncompressedBytes':info.file_size,'CRC32':f'{info.CRC:08X}','externalAttributes':info.external_attr,'target':str(target),'unsafeReasons':why};entries.append(ent)
   if why:check['unsafe'].append({'filename':name,'reasons':why})
  check.update(fileCount=sum(not e['isDirectory'] for e in entries),directoryCount=sum(e['isDirectory'] for e in entries),totalCompressedBytes=sum(e['compressedBytes'] for e in entries),totalUncompressedBytes=sum(e['uncompressedBytes'] for e in entries))
  bad=z.testzip();check['CRCtestRuns']=1;check['CRCbadMember']=bad;check['CRCstate']='passed' if bad is None else 'failed'
  if bad is None and not check['unsafe']:
   for info,e in zip(z.infolist(),entries):
    target=Path(e['target'])
    if info.is_dir():target.mkdir(parents=True,exist_ok=True);continue
    target.parent.mkdir(parents=True,exist_ok=True)
    data=z.read(info);e['memberSHA256']=hashlib.sha256(data).hexdigest().upper()
    with target.open('xb') as f:f.write(data)
    e['extractedSHA256']=sha(target);assert e['memberSHA256']==e['extractedSHA256']
   check.update(extractionState='passed',extractionRoot=str(dest),extractedFileCount=sum(p.is_file() for p in dest.rglob('*')),extractedBytes=sum(p.stat().st_size for p in dest.rglob('*') if p.is_file()))
   assert check['extractedFileCount']==check['fileCount'];assert check['extractedBytes']==check['totalUncompressedBytes']
  else:check['extractionState']='blocked-unsafe-or-CRC'
 inv=CACHE/f'archive-{label}-members.json';save(inv,entries)
 inventories.append({'label':label,'inventoryPath':str(inv),'entries':len(entries),'nameSearchOnly':[e['filename'] for e in entries if re.search(r'(?i)(devil|chat|layout|config|setting|core|texture|media|\.toc$)',e['filename'])]})
 log('ZIP '+label+': '+json.dumps(check,ensure_ascii=False));print('ZIP_DONE',label,check['extractionState'],flush=True)
save(OUT/'archive-inventory.json',inventories);save(OUT/'archive-checks.json',checks)
# Existing2022 locations only, no file content reads/CRC/reextraction.
paths=[str(p) for p in (ROOT/'SourceArchive/2022-11-19').iterdir()] if (ROOT/'SourceArchive/2022-11-19').exists() else []
save(OUT/'existing-2022-locations.json',{'directoryEntries':paths,'note':'Directory lookup only; existing2022 CRC/extraction never rerun.'})
# Mechanical self-check once on actual whole output.
assert len(posts)==34 and set(p['postID'] for p in posts)==set(EXPECTED)
assert sum(len(p.get('images',[])) for p in posts)==len(images)
assert len(json.loads((OUT/'images.json').read_text(encoding='utf-8')))==len(images)
assert all(Path(p).exists() for p in [str(OUT/'PRIORITY_READY.json')]+[str(OUT/'posts'/f'idx-{p["postID"]}.md') for p in posts if p['acquisitionState']=='parsed'])
log('## Self-check once\nActual34 ID set/20+14 inputs, all per-post image-association denominator reconciled, output JSON roundtrip and all parsed text paths exist: PASS. Archive CRC/path/member hash gates in archive-checks.json, failures retained. No image content observation. No A1 reading claim. No cleanup. Exit0 reached '+now())
print('ALL_DONE',str(OUT),flush=True)
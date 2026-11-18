import sys,json,re,hashlib,subprocess,time,zipfile,stat,struct
from pathlib import Path,PureWindowsPath
from xml.etree import ElementTree as ET
R=Path('D:/Projects/Project_WF');C=R/'work/clean-chat-step4-fx5q4nxu';O=R/'Codex/results/old-reference/clean-chat-acquisition';L=R/'Codex/results/handoffs/old-reference/acquisition-step4/work_log.md'
def save(p,x):Path(p).parent.mkdir(parents=True,exist_ok=True);Path(p).write_bytes(json.dumps(x,ensure_ascii=False,indent=2).encode('utf-8'))
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def log(t):
 with L.open('a',encoding='utf-8') as f:f.write(t+'\n')
def fetch(url,path,basis='actual-observed-link'):
 p=Path(path);assert not p.exists();q=lambda s:"'"+str(s).replace("'","''")+"'";ps="$ErrorActionPreference='Stop';try{$r=Invoke-WebRequest -Uri "+q(url)+" -OutFile "+q(p)+" -PassThru -UseBasicParsing -TimeoutSec 45;@{HTTP=[int]$r.StatusCode;finalURL=$r.BaseResponse.ResponseUri.AbsoluteUri;contentType=[string]$r.Headers['Content-Type'];time=(Get-Date).ToUniversalTime().ToString('o');rateRemaining=[string]$r.Headers['X-RateLimit-Remaining']}|ConvertTo-Json -Compress}catch{$c=$null;if($_.Exception.Response){$c=[int]$_.Exception.Response.StatusCode};@{HTTP=$c;error=$_.Exception.Message;time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}"
 cp=subprocess.run(['powershell','-NoProfile','-NonInteractive','-Command',ps],stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,encoding='utf-8',errors='replace')
 try:r=json.loads(cp.stdout.lstrip('\ufeff'))
 except Exception:r={'HTTP':None,'error':cp.stderr or cp.stdout}
 r.update(sourceURL=url,URLbasis=basis,localpath=str(p),attempts=1,commandExitCode=cp.returncode,state='acquired' if r.get('HTTP')==200 else 'failed')
 if p.exists():r.update(bytes=p.stat().st_size,SHA256=sha(p))
 log('GET '+json.dumps(r,ensure_ascii=False));time.sleep(.2);return r

def safezip(source,label):
 source=Path(source);dest=C/('extracted-'+label);assert not dest.exists();dest.mkdir();check={'source':str(source),'SHA256':sha(source),'bytes':source.stat().st_size,'label':label,'CRCtestRuns':0,'unsafe':[],'extractionState':'not-extracted'};members=[];seen=set()
 if not zipfile.is_zipfile(source):check['extractionState']='not-ZIP';return check
 with zipfile.ZipFile(source) as z:
  raw=source.read_bytes();pos=z.start_dir
  for info in z.infolist():
   assert raw[pos:pos+4]==b'PK\x01\x02';nl,el,cl=struct.unpack_from('<HHH',raw,pos+28);namehex=raw[pos+46:pos+46+nl].hex();pos+=46+nl+el+cl;name=info.filename;parts=name.replace(chr(92),'/').split('/');target=(dest/Path(*parts)).resolve();why=[];w=PureWindowsPath(name)
   if w.drive or w.is_absolute() or name.startswith(('/','\\')):why.append('absolute/drive/UNC')
   if any(p in ('.','..') for p in parts) or not target.is_relative_to(dest.resolve()):why.append('traversal/outside-root')
   if any(re.search(r'[<>:"|?*\x00-\x1f]',p) or p.endswith((' ','.')) or re.fullmatch(r'(?i)(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?',p) for p in parts if p):why.append('unsafe-NTFS/stream')
   if stat.S_ISLNK(info.external_attr>>16) or info.external_attr&0x400:why.append('symlink/reparse')
   key=str(target).casefold()
   if key in seen:why.append('case/path-collision')
   seen.add(key);e={'filename':name,'rawCentralFilenameHex':namehex,'flagBits':info.flag_bits,'externalAttributes':info.external_attr,'isDirectory':info.is_dir(),'uncompressedBytes':info.file_size,'compressedBytes':info.compress_size,'CRC32':f'{info.CRC:08X}','target':str(target),'unsafeReasons':why};members.append(e)
   if why:check['unsafe'].append({'filename':name,'reasons':why})
  bad=z.testzip();check.update(CRCtestRuns=1,CRCbadMember=bad,CRCstate='passed' if bad is None else 'failed',files=sum(not x['isDirectory'] for x in members),directories=sum(x['isDirectory'] for x in members),uncompressedBytes=sum(x['uncompressedBytes'] for x in members),compressedBytes=sum(x['compressedBytes'] for x in members))
  if bad is None and not check['unsafe']:
   for info,e in zip(z.infolist(),members):
    p=Path(e['target'])
    if info.is_dir():p.mkdir(parents=True,exist_ok=True);continue
    p.parent.mkdir(parents=True,exist_ok=True);b=z.read(info)
    with p.open('xb') as f:f.write(b)
    e['memberSHA256']=hashlib.sha256(b).hexdigest().upper();e['extractedSHA256']=sha(p);assert e['memberSHA256']==e['extractedSHA256']
   files=[p for p in dest.rglob('*') if p.is_file()];check.update(extractionState='passed',extractionRoot=str(dest),extractedFiles=len(files),extractedBytes=sum(p.stat().st_size for p in files),reparsePaths=[str(p) for p in dest.rglob('*') if p.is_symlink() or p.stat().st_file_attributes&stat.FILE_ATTRIBUTE_REPARSE_POINT]);assert check['extractedFiles']==check['files'] and check['extractedBytes']==check['uncompressedBytes'] and not check['reparsePaths']
  else:check['extractionState']='blocked-safety-or-CRC'
 inventory=C/(label+'-members.json');save(inventory,members);check['inventoryPath']=str(inventory);save(O/(label+'-archive-checks.json'),check);log('ZIP '+json.dumps({k:check.get(k) for k in ['label','CRCtestRuns','CRCstate','extractionState','files','extractedBytes','inventoryPath']}));return check

def catalog(check,label):
 if check.get('extractionState')!='passed':return None
 inv=json.loads(Path(check['inventoryPath']).read_text(encoding='utf-8'));records=[];tocs=[];readmes=[];xml=[]
 for e in inv:
  if e['isDirectory']:continue
  p=Path(e['target']);r={'filename':e['filename'],'path':str(p),'bytes':p.stat().st_size,'SHA256':e['extractedSHA256']};suffix=p.suffix.lower()
  if suffix in ('.lua','.xml','.toc','.md','.txt','.pkgmeta') or p.name in ('.pkgmeta','LICENSE'):
   try:text=p.read_text(encoding='utf-8-sig');r['encoding']='utf-8-sig';r['lines']=len(text.splitlines())
   except UnicodeDecodeError:text=None;r['encoding']='not-UTF8-no-interpretation'
   if suffix=='.toc' and text is not None:
    lines=text.splitlines();tocs.append(dict(r,metadata=[{'line':n,'literal':v} for n,v in enumerate(lines,1) if v.lstrip().startswith('##')],loadOrder=[{'line':n,'literal':v,'exists':(p.parent/v.strip().replace(chr(92),'/')).exists()} for n,v in enumerate(lines,1) if v.strip() and not v.lstrip().startswith('#')]))
   if suffix=='.xml' and text is not None:
    try:tree=ET.fromstring(text);xml.append(dict(r,references=[{'tag':n.tag,'file':n.attrib.get('file')} for n in tree.iter() if 'file' in n.attrib]))
    except ET.ParseError as ex:xml.append(dict(r,error=str(ex)))
   if re.search(r'(?i)^readme',p.name):readmes.append(dict(r,fullText=text))
  records.append(r)
 result={'label':label,'root':check['extractionRoot'],'inventoryPath':check['inventoryPath'],'files':records,'TOCs':tocs,'XMLloadReferences':xml,'READMEfullText':readmes,'configDefaultNameCandidates':[r for r in records if re.search(r'(?i)(config|option|default|setting|module)',r['filename'])],'noCodeExecuted':True,'noWholeCodeAuditClaim':True};save(O/(label+'-source-catalog.json'),result);return result
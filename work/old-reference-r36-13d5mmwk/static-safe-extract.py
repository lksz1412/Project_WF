import sys,json,re,subprocess,stat,struct,hashlib,collections
from pathlib import Path,PureWindowsPath
sys.stdout.reconfigure(encoding='utf-8')
C=Path('D:/Projects/Project_WF/work/old-reference-r36-13d5mmwk');O=Path('D:/Projects/Project_WF/Codex/results/old-reference/acquisition/r36/other-posts');L=Path('D:/Projects/Project_WF/Codex/results/handoffs/old-reference/acquisition/work_log.md');bz='C:/Program Files/Bandizip/bz.exe'
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
# Bounded legacyRAR4 header inspection: every block is advanced by declared header+packeddata lengths; unknown source types/hostOS stop extraction.
rarheaders=[];headerfail=[]
for part in [C/'downloads/devilbecustom91.part1.rar',C/'downloads/devilbecustom91.part2.rar']:
 b=part.read_bytes();pos=7;assert b[:7]==b'Rar!\x1a\x07\x00'
 while pos+7<=len(b):
  crc,kind,flags,size=struct.unpack_from('<HBHH',b,pos)
  if size<7 or pos+size>len(b):headerfail.append({'part':part.name,'offset':pos,'reason':'invalid-block-boundary'});break
  data=struct.unpack_from('<I',b,pos+7)[0] if flags&0x8000 else 0
  if kind not in (0x73,0x74,0x7b):headerfail.append({'part':part.name,'offset':pos,'reason':'unknown-header-type','headerType':kind})
  if kind==0x74:
   host=b[pos+15];attr=struct.unpack_from('<I',b,pos+28)[0];nameLength=struct.unpack_from('<H',b,pos+26)[0];start=40 if flags&0x100 else 32
   if flags&0x100:data+=struct.unpack_from('<I',b,pos+32)[0]<<32
   e={'part':part.name,'offset':pos,'headerSize':size,'flags':flags,'hostOS':host,'fileAttributes':attr,'rawFilenameHex':b[pos+start:pos+start+nameLength].hex(),'splitBefore':bool(flags&1),'splitAfter':bool(flags&2),'encrypted':bool(flags&4),'reparseAttribute':bool(attr&0x400)};rarheaders.append(e)
   if host!=2 or attr&0x400 or flags&4:headerfail.append({'part':part.name,'offset':pos,'reason':'not-plain-Windows-member-or-reparse-or-encrypted','header':e})
  pos+=size+data
 if pos!=len(b):headerfail.append({'part':part.name,'reason':'whole-volume-boundary-mismatch','endOffset':pos,'bytes':len(b)})
save(C/'idx1932-rar4-header-metadata.json',rarheaders)
checks=[];commands=json.loads((O/'static-list-integrity-commands.json').read_text(encoding='utf-8'))
for label,source in [('idx1932-rar',C/'downloads/devilbecustom91.part1.rar'),('idx3461-sfx',C/'extracted-idx-3461/Black Edition2_6.1 Alpha.exe')]:
 listing=next(x for x in commands if x['label']==label and x['operation']=='list');test=next(x for x in commands if x['label']==label and x['operation']=='integrity');check={'label':label,'source':str(source),'SHA256':sha(source),'sourceExecuted':False,'listExitCode':listing.get('exitCode'),'integrityTestExitCode':test.get('exitCode'),'integrityTestRuns':1,'unsafe':[],'state':'not-extracted'};checks.append(check)
 if listing.get('exitCode')!=0 or test.get('exitCode')!=0:check['state']='blocked-tool-gate';continue
 testText=Path(test['stdoutPath']).read_text(encoding='utf-8-sig');check['integrityAllOKLiteral']='All OK' in testText
 if not check['integrityAllOKLiteral']:check['state']='blocked-no-integrity-success';continue
 if label=='idx1932-rar':
  check.update(legacyHeaderMetadata=str(C/'idx1932-rar4-header-metadata.json'),legacyFileHeaders=len(rarheaders),legacyHostOSCounts=dict(collections.Counter(x['hostOS'] for x in rarheaders)),legacyReparseHeaders=sum(x['reparseAttribute'] for x in rarheaders),legacyHeaderFailures=headerfail)
  if headerfail:check['state']='blocked-legacy-header-gate';continue
 lines=Path(listing['stdoutPath']).read_text(encoding='utf-8-sig').splitlines();footer=next((re.search(r'(\d+) files, (\d+) folders',x) for x in reversed(lines) if re.search(r'(\d+) files, (\d+) folders',x)),None);assert footer;nf,nd=map(int,footer.groups());dest=C/('extracted-'+label);assert not dest.exists();dest.mkdir();rows=[];seen=set();rx=re.compile(r'^(\d{4}-\d{2}-\d{2})\s+(\d\d:\d\d:\d\d)\s+([A-Za-z_]{4})\s+(-?\d+)\s+(-?\d+)\s+(.+)$')
 for n,line in enumerate(lines,1):
  m=rx.match(line)
  if not m:continue
  date,tm,attr,size,comp,name=m.groups();parts=name.replace(chr(92),'/').split('/');target=(dest/Path(*parts)).resolve();why=[];win=PureWindowsPath(name)
  if win.drive or win.is_absolute() or name.startswith(('/','\\')):why.append('absolute/drive/UNC')
  if any(p in ('.','..') for p in parts):why.append('dot/traversal')
  if not target.is_relative_to(dest.resolve()):why.append('resolved-outside-root')
  if any(re.search(r'[<>:"|?*\x00-\x1f]',p) or p.endswith((' ','.')) or re.fullmatch(r'(?i)(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?',p) for p in parts if p):why.append('unsafe-NTFS-name/stream')
  if not re.fullmatch(r'[ADRH_]{4}',attr):why.append('unrecognized-link-or-other-attribute')
  key=str(target).casefold()
  if key in seen:why.append('case/path-collision')
  seen.add(key);e={'filename':name,'attributes':attr,'isDirectory':attr.startswith('D'),'listedUncompressedBytes':int(size),'listedCompressedBytes':int(comp),'listLine':n,'target':str(target),'unsafeReasons':why};rows.append(e)
  if why:check['unsafe'].append(e)
 check.update(listedFiles=nf,listedDirectories=nd,parsedRows=len(rows),listedByteTotal=sum(x['listedUncompressedBytes'] for x in rows if not x['isDirectory']))
 if len(rows)!=nf+nd or sum(not x['isDirectory'] for x in rows)!=nf or sum(x['isDirectory'] for x in rows)!=nd:check['state']='blocked-incomplete-list-parser'
 elif check['unsafe']:check['state']='blocked-unsafe-list'
 else:
  cmd=[bz,'x','-o:'+str(dest),'-consolemode:utf8',str(source)]
  try:
   cp=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,stdin=subprocess.DEVNULL,timeout=60);(C/(label+'-extract-stdout.txt')).write_bytes(cp.stdout);(C/(label+'-extract-stderr.txt')).write_bytes(cp.stderr);check.update(extractExitCode=cp.returncode,extractCommand=cmd,extractionRoot=str(dest));files=[p for p in dest.rglob('*') if p.is_file()];actual={str(p.relative_to(dest)).replace('/',chr(92)).casefold():p for p in files};expected={x['filename'].casefold():x for x in rows if not x['isDirectory']};check.update(extractedFiles=len(files),extractedBytes=sum(p.stat().st_size for p in files),missing=sorted(set(expected)-set(actual)),unexpected=sorted(set(actual)-set(expected)),postExtractionReparse=[str(p) for p in dest.rglob('*') if p.is_symlink() or p.stat().st_file_attributes&stat.FILE_ATTRIBUTE_REPARSE_POINT])
   for key,e in expected.items():
    if key in actual:e.update(extractedSHA256=sha(actual[key]),extractedBytes=actual[key].stat().st_size)
   knownSizes=all(e['listedUncompressedBytes']>=0 for e in rows if not e['isDirectory']);check['listedSizeAvailability']='known' if knownSizes else 'unknown(-1)';check['byteTotalsEqual']=check['extractedBytes']==check['listedByteTotal'] if knownSizes else None;check['perFileSizesEqual']=all(e.get('extractedBytes')==e['listedUncompressedBytes'] for e in rows if not e['isDirectory']) if knownSizes else None;check['state']='passed' if cp.returncode==0 and not check['missing'] and not check['unexpected'] and not check['postExtractionReparse'] and check['byteTotalsEqual'] is not False and check['perFileSizesEqual'] is not False else 'failed-postextract-gate'
  except subprocess.TimeoutExpired:check['state']='extract-timeout-stopped'
 inventory=C/(label+'-members.json');save(inventory,rows);check['inventoryPath']=str(inventory);check['nameOnlyCandidates']=[x['filename'] for x in rows if re.search(r'(?i)(devil|chat|Bartender|Skinner|kgPanels|Dominos|Masque|layout|profile|\.toc$)',x['filename'])];save(O/(label+'-static-extraction-checks.json'),check);print('STATIC_READY',label,{k:check.get(k) for k in ['state','extractionRoot','extractedFiles','extractedBytes','unsafe']},flush=True)
save(O/'static-extraction-summary.json',[{k:x.get(k) for k in ['label','state','extractionRoot','extractedFiles','extractedBytes','inventoryPath','integrityTestRuns','unsafe','byteTotalsEqual']} for x in checks])
with L.open('a',encoding='utf-8') as f:f.write('Otherposts multipartRAR+newBlackSFX staticgates: bz l/t eachsource once, exit0/AllOK, targetsourceEXE never executed. RAR4 whole-volume blockmetadata 3167fileheaders(1splitcontinuation), allhostOS2Windows, reparseattribute0/noencrypted/nootherheader-type; rawfilenames/flags in ignoredheaderinventory. Actualbzlist resolvedpath/NTFS/collision/attrs check and postextractreparse scan. Results '+json.dumps([{k:x.get(k) for k in ['label','state','extractedFiles','extractedBytes','byteTotalsEqual','perFileSizesEqual']} for x in checks])+'; NSISlistedsize-1 means nobyteequalityclaim, actualbytes/hashinventory recorded. Command python -X utf8 '+str(C/'static-safe-extract.py')+' exit0.\n')
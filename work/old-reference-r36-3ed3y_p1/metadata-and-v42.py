import sys,json,re,hashlib,zipfile,stat,struct,shutil
from pathlib import Path,PureWindowsPath
from urllib.parse import urlparse,unquote
from bs4 import BeautifulSoup
sys.stdout.reconfigure(encoding='utf-8')
R=Path('D:/Projects/Project_WF');C=R/'work/old-reference-r36-3ed3y_p1';O=R/'Codex/results/old-reference/acquisition/r36';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';OLD=R/'work/old-reference-collection-0qlzzyxg';O.mkdir(exist_ok=True)
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def log(t):
 with L.open('a',encoding='utf-8') as f:f.write(t+'\n')
shutil.copyfile(L,C/'work_log-before-r36.md')
log('\n## R36 samehelper extension entry/fullreads\n1 Role remains ONE closed mechanical bada-a4-helper gpt-6.1-sol/low configured; actualruntimeunobserved. 2 Ownership newwork/old-reference-r36-* and acquisition/r36 outputs plus ownlog; sharedtree notalone no reverting others/masterrecords; rootcommit only. 3 Scope actual172metadata then selectedX2R3.4/X2_R1/3.05/2582/V42, R04041boundedfallback; ordinarypublicGET/staticarchiveonly; no agent/install/CUA/auth/private/game/sourceLuaEXEexecution/cleanup. 4 Acquisition/parse/name/hash != A1reading/family/fidelity/visualobservation. 5 amendedbrief applies; sameunit accessorywork, existingpassed34/50hash/new2ZIP/2022 gates no rerun. SourceHTML/scripts/archive untrusteddata. RootownsV42 download, helperonlyCRC/extract. Newimpact: savedfiles45/2582/13140/11218 -> actualrow/literalhandler mapping -> A1selected predictedpublicGET -> newbinary/headeridentity/gates -> safeextract/memberinventory -> A1. LiteralLatestURL never inferred olderIDmapping. Existingownlog backedup in freshcache beforeappend. No sourceoverwrite.')
for p in [Path('D:/Projects/AGENTS.md'),R/'Codex/results/handoffs/old-reference/acquisition/brief.md',R/'Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md',R/'Codex/results/REQUEST_LEDGER_phase1.3.md',C/'work_log-before-r36.md']:
 log('R36 actualfullreread '+str(p)+':1-'+str(len(p.read_text(encoding='utf-8-sig').splitlines()))+'. Currentparentmessages/selection/V42receipt fullyread. No compactionwasreported; mandatoryamendedinputs reread nevertheless.')
catalog=json.loads((R/'Codex/results/old-reference/acquisition/catalog-v2.json').read_text(encoding='utf-8'));allposts=[]
for id,expected in [(45,172),(2582,0),(13140,9),(11218,22)]:
 p=next(p for p in catalog if p['postID']==id);f=p['iframes']['fileInfo'];src=Path(f['provenance']['localpath']);s=BeautifulSoup(src.read_text(encoding='utf-8'),'html.parser');scripts=[{'line':x.sourceline,'text':x.get_text(),'src':x.get('src')} for x in s.find_all('script')];latest=[]
 for x in scripts:
  for m in re.finditer(r'setDownloadInfo\(\s*(\d+)\s*,\s*["\x27]([^"\x27]+)["\x27]\s*\)',x['text']):latest.append({'fileID':int(m.group(1)),'literalURL':m.group(2),'line':x['line'],'function':'parent.setDownloadInfo'})
 rows=[]
 for tr in s.select('table tr'):
  tds=tr.find_all('td',recursive=False)
  if not tds:continue
  cells=[t.get_text(' ',strip=True) for t in tds];assert len(cells)==4
  filename,client,count,date=cells;anchors=[{'href':a.get('href'),'onclick':a.get('onclick'),'text':a.get_text(' ',strip=True),'attributes':a.attrs,'line':a.sourceline} for a in tr.find_all('a')];matching=[x for x in latest if unquote(Path(urlparse(x['literalURL']).path).name)==filename];rows.append({'postID':id,'ordinal1':len(rows)+1,'filenameLiteral':filename,'clientVersionLiteral':client,'downloadCountLiteral':count,'dateLiteral':date,'dateKind':'file table registration date','fileID':matching[0]['fileID'] if len(matching)==1 else None,'fileIDState':'actual-setDownloadInfo-literal' if len(matching)==1 else 'not-exposed-in-anonymous-row','literalPublicURLs':[m['literalURL'] for m in matching],'mappingState':'exact-latest-literal-filename' if matching else 'no-row-URL-literal; public recovery not exhausted','anchors':anchors,'sourceLocation':{'path':str(src),'line':tr.sourceline,'selector':'#addonFileInfo table tr'},'rawRowHTML':str(tr)})
 assert len(rows)==expected
 detail=Path(p['detailProvenance']['localpath']);ds=BeautifulSoup(detail.read_text(encoding='utf-8'),'html.parser');handlers=[{'source':str(detail),'line':x.sourceline,'scriptText':x.get_text()} for x in ds.find_all('script') if re.search(r'function\s+(downloadLatest|setDownloadInfo)',x.get_text())];hf=C/f'idx-{id}-detail-downloadhandlers.json';save(hf,handlers)
 record={'postID':id,'rowCount':len(rows),'sourceURL':f['sourceURL'],'rawPath':str(src),'rawSHA256':sha(src),'rows':rows,'iframeScripts':scripts,'detailHandlerCache':str(hf),'downloadUIState':'anonymous anchors invoke top.login; no handler evaluated or login attempted','latestMappingDoesNotSupplyOlderURLs':True};allposts.append(record);save(O/f'idx-{id}-attachment-inventory.json',record)
selected=[]
for filename,date,client,role in [('DevilUI-X2 R3.4.zip','2008-09-27','2.4.3','primary'),('DevilUI-X2_R1.zip','2008-04-26','2.4.1','earlier-comparison'),('DevilUI 3.05.zip','2008-11-05','3.0.2','boundary'),('DevilUI-X2_2.4R04041.zip','2008-04-04','2.4.0','fallback-only-if-olderX2-unavailable')]:
 hits=[x for x in allposts[0]['rows'] if x['filenameLiteral']==filename];assert len(hits)==1;r=hits[0];state='consistent' if r['dateLiteral']==date and r['clientVersionLiteral']==client else 'contradiction-stop-selection';selected.append({'role':role,'metadataState':state,'row':r})
save(O/'FIRST_172_METADATA_READY.json',{'cache':str(C),'idx45':str(O/'idx-45-attachment-inventory.json'),'idx2582':str(O/'idx-2582-attachment-inventory.json'),'idx13140':str(O/'idx-13140-attachment-inventory.json'),'idx11218':str(O/'idx-11218-attachment-inventory.json'),'selectedHistorical':selected,'counts':{str(x['postID']):x['rowCount'] for x in allposts},'note':'All172 exact rows retained. Anonymous HTML exposes only latest fileID/literalURL; olderIDs unknown rather than guessed. idx2582 actualiframe count0/rows0/noURL. Root ownsV42GET.'})
print('FIRST172_READY',str(O/'FIRST_172_METADATA_READY.json'),flush=True)
# Reusable validated extraction for newly acquired ZIP only.
def safezip(source,label,expectedhash=None):
 source=Path(source);dest=C/('extracted-'+label);assert not dest.exists();dest.mkdir();check={'label':label,'source':str(source),'bytes':source.stat().st_size,'SHA256':sha(source),'expectedSHA256':expectedhash,'hashMatch':None if expectedhash is None else sha(source)==expectedhash,'CRCtestRuns':0,'unsafe':[],'extractionState':'not-started'};entries=[];seen=set()
 if expectedhash and not check['hashMatch']:return check
 with zipfile.ZipFile(source) as z:
  raw=source.read_bytes();offset=z.start_dir
  for info in z.infolist():
   assert raw[offset:offset+4]==b'PK\x01\x02';nl,el,cl=struct.unpack_from('<HHH',raw,offset+28);rawname=raw[offset+46:offset+46+nl];offset+=46+nl+el+cl;name=info.filename;parts=name.replace(chr(92),'/').split('/');target=(dest/Path(*parts)).resolve();why=[];win=PureWindowsPath(name)
   if win.drive or win.is_absolute() or name.startswith(('/','\\')):why.append('absolute/drive/UNC')
   if any(x in ('.','..') for x in parts):why.append('dot/traversal')
   if not target.is_relative_to(dest.resolve()):why.append('resolved-outside-root')
   if any(re.search(r'[<>:"|?*\x00-\x1f]',p) or p.endswith((' ','.')) or re.fullmatch(r'(?i)(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?',p) for p in parts if p):why.append('unsafeNTFS')
   if stat.S_ISLNK(info.external_attr>>16) or info.external_attr&0x400:why.append('symlink/reparse')
   key=str(target).casefold()
   if key in seen:why.append('case/path-collision')
   seen.add(key);e={'filename':name,'rawCentralFilenameHex':rawname.hex(),'flagBits':info.flag_bits,'filenameDecode':'utf-8' if info.flag_bits&0x800 else 'cp437 default, no rename','isDirectory':info.is_dir(),'compressedBytes':info.compress_size,'uncompressedBytes':info.file_size,'CRC32':f'{info.CRC:08X}','externalAttributes':info.external_attr,'target':str(target),'unsafeReasons':why};entries.append(e)
   if why:check['unsafe'].append({'filename':name,'reasons':why})
  bad=z.testzip();check.update(CRCtestRuns=1,CRCbadMember=bad,CRCstate='passed' if bad is None else 'failed',fileCount=sum(not x['isDirectory'] for x in entries),directoryCount=sum(x['isDirectory'] for x in entries),totalCompressedBytes=sum(x['compressedBytes'] for x in entries),totalUncompressedBytes=sum(x['uncompressedBytes'] for x in entries))
  if bad is None and not check['unsafe']:
   for info,e in zip(z.infolist(),entries):
    target=Path(e['target'])
    if info.is_dir():target.mkdir(parents=True,exist_ok=True);continue
    target.parent.mkdir(parents=True,exist_ok=True);data=z.read(info);target.write_bytes(data);e['memberSHA256']=hashlib.sha256(data).hexdigest().upper();e['extractedSHA256']=sha(target);assert e['memberSHA256']==e['extractedSHA256']
   files=[p for p in dest.rglob('*') if p.is_file()];check.update(extractionState='passed',extractionRoot=str(dest),extractedFileCount=len(files),extractedBytes=sum(p.stat().st_size for p in files),postExtractionReparse=[str(p) for p in dest.rglob('*') if p.is_symlink() or p.stat().st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT]);assert len(files)==check['fileCount'] and check['extractedBytes']==check['totalUncompressedBytes'] and not check['postExtractionReparse']
  else:check['extractionState']='blocked-unsafe-or-CRC'
 inventory=C/f'{label}-members.json';save(inventory,entries);check['inventoryPath']=str(inventory);check['nameOnlyCandidates']=[e['filename'] for e in entries if re.search(r'(?i)(devil|chat|layout|profile|skinner|kgpanels|dominos|masque|\.toc$)',e['filename'])];save(O/f'{label}-archive-checks.json',check);return check
receipt=json.loads((R/'Codex/results/old-reference/forever-v42-archive-acquisition.json').read_text(encoding='utf-8'));v=safezip(receipt['preserved_path'],'forever-v42',receipt['sha256']);log('R36 metadata actualcounts172/0/9/22; selected4filename/date/client matches exact actualrows; handlers keptasdata noJavaScriptexecution. V42rootreceipt reusednoGET; singleCRC/safety/extraction result '+json.dumps(v,ensure_ascii=False)+'. Command python -X utf8 '+str(C/'metadata-and-v42.py')+' exit0 reached.');print('V42_READY',json.dumps({k:v.get(k) for k in ['extractionState','extractionRoot','fileCount','extractedBytes','inventoryPath','unsafe']},ensure_ascii=False),flush=True)
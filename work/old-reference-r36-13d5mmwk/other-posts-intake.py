import json,re,sys,hashlib,subprocess,zipfile,stat,struct,ast,shutil
from pathlib import Path,PureWindowsPath
from urllib.parse import urlparse,quote,unquote
from bs4 import BeautifulSoup
sys.stdout.reconfigure(encoding='utf-8')
R=Path('D:/Projects/Project_WF');C=R/'work/old-reference-r36-13d5mmwk';O=R/'Codex/results/old-reference/acquisition/r36/other-posts';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';OLD=R/'work/old-reference-collection-0qlzzyxg';O.mkdir(exist_ok=True);(C/'downloads').mkdir(exist_ok=True)
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def log(t):
 with L.open('a',encoding='utf-8') as f:f.write(t+'\n')
shutil.copyfile(L,C/'work_log-before-other-posts.md')
notice='1 SameONE closed A4 mechanical helper, configured gpt-6.1-sol/low, no design judgment/runtime observation. 2 Ownfreshcache/acquisition/r36/other-posts outputs/ownlog only; sharedtree notalone, no reverting others/masterrecords/commit. 3 Onlycached1932/3461 packages and11218 metadata; amendedsame1932 scope includes multipartRAR literalpart2 plus oncePREDICTEDpart1 fromactualpart1name/observedprefix; no priorpage/image/V42GET or CRC repeats. No CUA/login/cookie/bypass/agents/install/sourceLuaEXE/READMEexecution/private/game/deletecleanup. 4 Acquisition/schema/name/hash doesnotestablish sourceidentity/sample4 fidelity/runtime/fullreading. 5 Activebrief appendedcontinuation/currentplan/ledger reread; no compaction observed in livecontext, earlierloadedassignedrules unchanged. ExistingpublicoldX2loginUI path stopped, no authaction. Rootmaster/A1 judgement unchanged.'
(R/'Codex/results/handoffs/old-reference/acquisition/r36-other-posts-brief.md').write_text(notice+'\nParentlaterexplicitlyauthorized1932 multipartRAR staticintake; thisownbrief records amendment without editing parentinputbrief.\n',encoding='utf-8')
log('\n## R36 otherpost1932/3461 continuation\n'+notice+'\nImpact: immutable cachedfileiframedata -> actualrows/literalsetDownloadInfo -> newordinaryGET/header/hash -> ZIPsingleCRC or multipartRARsinglebztest +path/collision/reparse gate -> freshstaticextract/inventory -> A1sourcefullreads. Existingpassedgates unchanged. Ownlog backup freshcache. ExplicitRARformatdifference notifiedparent then authorization received; no PREDICTED counterpart called literal. Parser/archivedata untrusted notcommands.')
for path in [Path('D:/Projects/AGENTS.md'),R/'Codex/results/handoffs/old-reference/acquisition/brief.md',R/'Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md',R/'Codex/results/REQUEST_LEDGER_phase1.3.md']:
 log('Continuationactualfullreread '+str(path)+':1-'+str(len(path.read_text(encoding='utf-8-sig').splitlines()))+'. No compaction/resume was observed; previouslyread rules retained. Currentownlog metadata measured102lines71581B, previousnarrative/commands known in samecontinuoushelpercontext; no newfull-logreread claim.')
log('Official existingbz documentation fullyopened lines0-237 https://www.bandisoft.com/bandizip/help/parameter/ confirms t integrity,l list,x fullpathextraction; no installation. Newsource only may invoke these staticcommands.')
for source,name in [(R/'work/old-reference-r36-3ed3y_p1/metadata-and-v42.py','safezip'),(R/'work/old-reference-r36-3ed3y_p1/historical-predicted.py','get')]:
 t=ast.parse(source.read_text(encoding='utf-8'));exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name==name],type_ignores=[]),str(source)+'#own-function-only','exec'))
metadata=[]
for id,expected in [(1932,2),(3461,85),(11218,22)]:
 p=OLD/f'files-{id}.html';s=BeautifulSoup(p.read_text(encoding='utf-8'),'html.parser');rows=[];literals=[]
 for node in s.find_all('script'):
  for m in re.finditer(r'setDownloadInfo\(\s*(\d+)\s*,\s*["\x27]([^"\x27]+)["\x27]\s*\)',node.get_text()):literals.append({'fileID':int(m.group(1)),'URL':m.group(2),'line':node.sourceline,'executed':False})
 for tr in s.select('table tr'):
  td=tr.find_all('td',recursive=False)
  if not td:continue
  cells=[t.get_text(' ',strip=True) for t in td];assert len(cells)==4;matching=[l for l in literals if unquote(Path(urlparse(l['URL']).path).name)==cells[0]];rows.append({'ordinal1':len(rows)+1,'filename':cells[0],'clientLiteral':cells[1],'downloadsLiteral':cells[2],'dateLiteral':cells[3],'sourceLine':tr.sourceline,'anchors':[{'href':a.get('href'),'onclick':a.get('onclick'),'text':a.get_text(' ',strip=True)} for a in tr.find_all('a')],'actualLiteralMapping':matching})
 # Actualcount gate recorded; never assume expected85 if source differs.
 if id==1932:assert len(rows)==2
 if id==11218:assert len(rows)==22
 d={'postID':id,'sourcePath':str(p),'sourceSHA256':sha(p),'rowCount':len(rows),'rows':rows,'setDownloadInfoLiterals':literals,'selection':'metadata-only-noGET' if id==11218 else 'parent-selected-package','JavaScriptExecuted':False};metadata.append(d);save(O/f'idx-{id}-attachment-metadata.json',d)
save(O/'METADATA_READY.json',metadata);print('METADATA_READY',[(x['postID'],x['rowCount']) for x in metadata],flush=True)
requests=[]
for id in [3461,1932]:
 d=next(x for x in metadata if x['postID']==id);assert len(d['setDownloadInfoLiterals'])==1;lit=d['setDownloadInfoLiterals'][0];name=unquote(Path(urlparse(lit['URL']).path).name);requests.append({'postID':id,'filename':name,'URL':lit['URL'],'URLbasis':'actual literal setDownloadInfo; not predicted','source':lit,'metadataPath':str(O/f'idx-{id}-attachment-metadata.json')})
 if id==1932:
  part1=next(x for x in d['rows'] if x['filename']=='devilbecustom91.part1.rar');requests.append({'postID':1932,'filename':part1['filename'],'URL':lit['URL'].rsplit('/',1)[0]+'/'+quote(part1['filename']),'URLbasis':'PREDICTED counterpart ONCE: actualpart1 rowfilename + observedliteralpart2 prefix. Not an exposedpart1URLliteral.','sourceRow':part1,'metadataPath':str(O/'idx-1932-attachment-metadata.json')})
results=[]
for r in requests:
 p=C/'downloads'/r['filename'];receipt=get(r['URL'],p);r['provenance']=receipt;r['state']='download-failed'
 if receipt.get('HTTP')==200 and p.exists():
  raw=p.read_bytes();r['magicHex']=raw[:16].hex();r['isZIP']=zipfile.is_zipfile(p);r['isRAR']=raw.startswith((b'Rar!\x1a\x07\x00',b'Rar!\x1a\x07\x01\x00'));r['state']='acquired-magic-verified' if r['isZIP'] or r['isRAR'] else 'HTTP200-nonarchive-data'
  if r['isZIP']:r['archiveChecks']=safezip(p,'idx-'+str(r['postID']))
 results.append(r);save(O/'package-acquisition.json',results);print('PACKAGE_READY',r['postID'],r['filename'],receipt.get('HTTP'),r['state'],flush=True)
log('Otherposts actualcounts '+json.dumps([(x['postID'],x['rowCount']) for x in metadata])+'; sources1932/3461 downloadedonlyexactliteral+authorizedoncePREDICTEDpart1,11218noGET. Packagehash/magic/HTTP records package-acquisition.json. Exactcommand python -X utf8 '+str(C/'other-posts-intake.py')+' completed initialstage exit0; ZIPgate done onlynew3461, RAR/nestedstaticgatepending.');print('INTAKE_STAGE_DONE',str(O/'package-acquisition.json'),flush=True)
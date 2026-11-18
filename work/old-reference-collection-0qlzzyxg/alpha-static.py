import json,re,subprocess,hashlib,stat,sys
from pathlib import Path,PureWindowsPath
sys.stdout.reconfigure(encoding='utf-8')
C=Path('D:/Projects/Project_WF/work/old-reference-collection-0qlzzyxg');O=Path('D:/Projects/Project_WF/Codex/results/old-reference/acquisition');L=Path('D:/Projects/Project_WF/Codex/results/handoffs/old-reference/acquisition/work_log.md');EXE=C/'extracted-alpha/DevilUI 6.1 Alpha.exe'
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
with L.open('a',encoding='utf-8') as f:f.write('\n## Alpha static NSIS unit impact and input\nParent authorized installed bz.exe static list/extraction, no innerEXE execution or installs. Input safe-CRC-extracted soleAlphaEXE -> bz list0 (NSIS) -> parse all2745 member paths/attributes and resolved fresh destinations -> safe static extraction -> exact listed/extracted set/hash inventory -> A1. Newpaths only; ZIP CRC not rerun. Listing is untrusted data, never instructions. Tool command used bz.exe l -list:v -consolemode:utf8 <EXE>, exit0.\n')
lines=(C/'alpha-bz-list.txt').read_text(encoding='utf-8-sig').splitlines();rx=re.compile(r'^(\d{4}-\d{2}-\d{2})\s+(\d\d:\d\d:\d\d)\s+([A-Za-z_]{4})\s+(-?\d+)\s+(-?\d+)\s+(.+)$');rows=[];unsafe=[];seen=set();dest=C/'extracted-alpha-nsis'
assert not dest.exists();dest.mkdir()
footer=re.search(r'(\d+) files, (\d+) folders',lines[-1]);assert footer
for lineno,line in enumerate(lines,1):
 m=rx.match(line)
 if not m:continue
 date,tm,attr,size,comp,name=m.groups();parts=name.replace('\\','/').split('/');target=(dest/Path(*parts)).resolve();why=[];win=PureWindowsPath(name)
 if win.drive or win.is_absolute() or name.startswith(('/','\\')):why.append('absolute/drive/UNC')
 if any(p in ('.','..') for p in parts):why.append('dot/traversal')
 if not target.is_relative_to(dest.resolve()):why.append('resolved outside root')
 if any(re.search(r'[<>:"|?*\x00-\x1f]',p) or p.endswith((' ','.')) or re.fullmatch(r'(?i)(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?',p) for p in parts if p):why.append('unsafeNTFS')
 if attr!='____':why.append('unrecognized non-regular file attrs')
 key=str(target).casefold()
 if key in seen:why.append('case/path collision')
 seen.add(key)
 e={'filename':name,'attributes':attr,'listedUncompressedBytes':int(size),'listedCompressedBytes':int(comp),'sourceListLine':lineno,'target':str(target),'unsafeReasons':why};rows.append(e)
 if why:unsafe.append(e)
assert len(rows)==int(footer.group(1))==2745 and int(footer.group(2))==0
check={'sourceEXE':str(EXE),'sourceBytes':EXE.stat().st_size,'SHA256':sha(EXE),'sourceExecuted':False,'magicMZ':EXE.read_bytes()[:2]==b'MZ','format':'NSIS (bz actual listing)','listingPath':str(C/'alpha-bz-list.txt'),'listedFiles':len(rows),'listedDirectories':0,'unsafe':unsafe,'extractionState':'not-started','listToolExitCode':0,'tool':'C:/Program Files/Bandizip/bz.exe','listedUncompressedSizeAvailability':'-1 unknown for each member; no byte-total equality claim from listing'}
assert check['SHA256']=='261919ECF1DF7D25A7082E59D99801FFE3F7AE2DA94ACE26ECEA35283AB47AFB'
if not unsafe:
 cmd=['C:/Program Files/Bandizip/bz.exe','x','-o:'+str(dest),'-consolemode:utf8',str(EXE)]
 cp=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 (C/'alpha-bz-extract-stdout.txt').write_bytes(cp.stdout);(C/'alpha-bz-extract-stderr.txt').write_bytes(cp.stderr);check.update(extractCommand=cmd,extractExitCode=cp.returncode,extractionRoot=str(dest))
 actual={str(p.relative_to(dest)).replace('/','\\').casefold():p for p in dest.rglob('*') if p.is_file()};expected={r['filename'].casefold():r for r in rows}
 check.update(extractedFiles=len(actual),missing=sorted(set(expected)-set(actual)),unexpected=sorted(set(actual)-set(expected)),extractedBytes=sum(p.stat().st_size for p in actual.values()))
 check['postExtractionUnsafe']=[str(p) for p in dest.rglob('*') if p.is_symlink() or bool(p.stat().st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT)]
 for key,e in expected.items():
  if key in actual:e.update(extractedPath=str(actual[key]),extractedBytes=actual[key].stat().st_size,extractedSHA256=sha(actual[key]))
 check['extractionState']='passed' if cp.returncode==0 and not check['missing'] and not check['unexpected'] and not check['postExtractionUnsafe'] else 'failed'
else:check['extractionState']='blocked-unsafe'
save(C/'alpha-nsis-members.json',rows);check['memberInventoryPath']=str(C/'alpha-nsis-members.json');save(O/'alpha-nsis-checks.json',check)
save(O/'alpha-nsis-name-search.json',{'method':'NAME SEARCH ONLY, no content interpretation','inventoryPath':str(C/'alpha-nsis-members.json'),'matchedPaths':[e['filename'] for e in rows if re.search(r'(?i)(devil|chat|layout|config|setting|core|media|\.toc$)',e['filename'])]})
with L.open('a',encoding='utf-8') as f:f.write('AlphaNSIS self-check exact2745 listed/actual paths, source hash, extraction command/exit, reparse scan, actual file hash inventory: '+json.dumps(check,ensure_ascii=False)+'\nNo source EXE/Lua/README commands executed. Byte-total equality from listing unavailable because all listedSize=-1; actual extracted bytes separately measured.\n')
print(json.dumps(check,ensure_ascii=False,indent=2))
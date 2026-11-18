import json,subprocess,hashlib,sys
from pathlib import Path
from PIL import Image
sys.stdout.reconfigure(encoding='utf-8')
O=Path('D:/Projects/Project_WF/Codex/results/old-reference/acquisition');C=Path('D:/Projects/Project_WF/work/old-reference-collection-0qlzzyxg');L=Path('D:/Projects/Project_WF/Codex/results/handoffs/old-reference/acquisition/work_log.md')
refs=json.loads((O/'coverage-v2.json').read_text(encoding='utf-8'))['imageFailures'];out=[]
for ref in refs:
 u=ref['thumbURL'];p=C/('thumbnail-fallback-8906-'+str(ref['DOMordinal'])+Path(u).suffix)
 ps="$ErrorActionPreference='Stop';try{$r=Invoke-WebRequest -Uri '"+u+"' -OutFile '"+str(p)+"' -PassThru -UseBasicParsing -TimeoutSec 45;@{HTTP=[int]$r.StatusCode;finalURL=$r.BaseResponse.ResponseUri.AbsoluteUri;contentType=[string]$r.Headers['Content-Type'];time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}catch{@{HTTP=[int]$_.Exception.Response.StatusCode;error=$_.Exception.Message;time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}"
 cp=subprocess.run(['powershell','-NoProfile','-NonInteractive','-Command',ps],capture_output=True,text=True,encoding='utf-8',errors='replace');r=json.loads(cp.stdout.lstrip('\ufeff'));r.update(postID=8906,DOMordinal=ref['DOMordinal'],section='screenshot-thumbnail-fallback',sourceURL=u,localpath=str(p),originalURL=ref['fullURL'],originalHTTP=ref['HTTP'],sourceLocation=ref['sourceLocation'],commandExitCode=cp.returncode,note='Actual thumbnail src fallback only; original fullsource404 remains unresolved, not an equivalent original image.')
 if p.exists():
  r.update(bytes=p.stat().st_size,SHA256=hashlib.sha256(p.read_bytes()).hexdigest().upper())
  try:
   with Image.open(p) as im:r.update(width=im.width,height=im.height,imageFormat=im.format);im.load()
   r['decodeStatus']='verified-full-load'
  except Exception as ex:r.update(decodeStatus='failed',decodeError=str(ex))
 else:r['decodeStatus']='not-acquired'
 out.append(r)
(O/'thumbnail-fallbacks.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
with L.open('a',encoding='utf-8') as f:f.write('\n## Final actualsource fallback/self-check\nNew thumbnail-fallbacks.json only, actual idx8906 thumbnail src GET; no guessed URL/domain, no repeated fullimageGET; original58-ref/fullsourcefailure denominator unchanged. OriginalHTTP404 details remain acquisition-provenance-v2.json even decoder error names absent local file. '+json.dumps(out,ensure_ascii=False)+'\nCommands collect.py exit0; resolve-v2.py exit0; alpha-static.py exit0. No cleanup, commit, game/private data access, source EXE/Lua execution, or image interpretation.\n')
print(json.dumps(out,ensure_ascii=False,indent=2))
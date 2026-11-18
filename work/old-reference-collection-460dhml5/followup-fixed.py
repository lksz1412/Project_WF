import sys,json,hashlib,subprocess
from pathlib import Path
from urllib.parse import urlencode,urlparse
from bs4 import BeautifulSoup
from PIL import Image
sys.stdout.reconfigure(encoding='utf-8')
O=Path('D:/Projects/Project_WF/Codex/results/old-reference/acquisition');C=Path('D:\\Projects\\Project_WF\\work\\old-reference-collection-460dhml5');L=Path('D:/Projects/Project_WF/Codex/results/handoffs/old-reference/acquisition/work_log.md');D=O/'articles-compact-v2'
assert not D.exists();D.mkdir()
def sha(b):return hashlib.sha256(b).hexdigest().upper()
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def log(t):
 with L.open('a',encoding='utf-8') as f:f.write(t+'\n')
log('\n## Followup compact articles and bounded archival fallback\nParent same-helper followup authorizes newcompact34 fullarticle extraction and ONE Wayback availability lookup for EACH exact four observed missing original/thumbnail URLs from thumbnail-fallbacks.json. No other50hash GET, no CUA/install/account/bypass. Fresh cache '+str(C)+'. Existing artifacts unchanged; ownlog appended. Impact: actual rawdetailUTF8 -> same bs4 text extraction -> newcompact text/section-bytehash manifest -> A1 directreading. Archived availability JSON -> optional captured exactURL image static GET/decode/hash -> separatearchive record; does not silently change original404/observed coverage. No substantive analysis.')
posts=json.loads((O/'catalog-v2.json').read_text(encoding='utf-8'));records=[]
for p in posts:
 id=p['postID'];raw=Path(p['detailProvenance']['localpath']);html=raw.read_text(encoding='utf-8');s=BeautifulSoup(html,'html.parser');m=s.select_one('#addonDetail .info');metadata=m.get_text('\n',strip=True) if m else None;assert metadata==p['metadataLiteral']
 item={'postID':id,'sourceURL':p['url'],'rawHTML':str(raw),'rawHTMLSHA256':sha(raw.read_bytes()),'metadata':{'selector':'#addonDetail .info','line':m.sourceline if m else None},'databaseRecord':str(O/f'idx-{id}-v2.json'),'imageManifest':str(O/'images-v2.json'),'fileURLLiterals':str(O/'file-download-literals.json'),'sections':{}}
 text=['# idx '+str(id)+' — '+str(p.get('title')),'Source: '+p['url'],'Raw HTML: '+str(raw),'Raw SHA256: '+item['rawHTMLSHA256'],'Metadata selector: #addonDetail .info; raw line '+str(m.sourceline if m else None),'Attachments/links/image associations: '+item['databaseRecord'],'Public file URL script literals: '+item['fileURLLiterals'],'\n## Metadata literal\n',metadata or '']
 for sec in ('addonAddon','addonVersion'):
  node=s.select_one('#'+sec);t=node.get_text('\n',strip=False) if node else None;assert t==p['sections'][sec]['text'];fragment=Path(p['sections'][sec]['fragmentPath']);fs=BeautifulSoup(fragment.read_text(encoding='utf-8'),'html.parser').select_one('#'+sec);assert fs.get_text('\n',strip=False)==t
  side=D/f'idx-{id}-{sec}.txt';side.write_bytes((t or '').encode('utf-8'));assert side.read_bytes()==(t or '').encode('utf-8')
  item['sections'][sec]={'selector':'#'+sec,'rawLine':node.sourceline if node else None,'state':p['sections'][sec]['state'],'plainTextPath':str(side),'utf8Bytes':len(side.read_bytes()),'textSHA256':sha(side.read_bytes()),'catalogTextExact':True,'rawHTMLParsedTextExact':True,'savedFragmentParsedTextExact':True,'sidecarUTF8BytesExact':True}
  text+=['\n## '+sec,'Raw selector: #'+sec+'; raw line '+str(node.sourceline if node else None)+'; state '+p['sections'][sec]['state'],'Section exact UTF8 text: '+str(side),'\n'+(t or '')]
 dest=D/f'idx-{id}.md';dest.write_text('\n'.join(text),encoding='utf-8');item.update(articlePath=str(dest),articleLines=len(dest.read_text(encoding='utf-8').splitlines()),articleBytes=dest.stat().st_size);records.append(item)
save(O/'articles-compact-v2-manifest.json',{'count':len(records),'method':'BeautifulSoup UTF8-string html.parser; metadata get_text(newline,strip=True), body/version get_text(newline,strip=False). No summary/omission; exact raw-parser/catalog/fragment text and sidecarUTF8-byte comparisons. HTML markup preserved in rawsource; attachment/link/image metadata remains separate existingJSON.','posts':records})
assert len(records)==34 and all(all(v['sidecarUTF8BytesExact'] for v in r['sections'].values()) for r in records)
log('Compact34 wholeinput self-check once PASS: exactmetadata+body/version text matched catalog and actual rawHTML+savedfragments; each68 section sidecarUTF8 byte equality/hash. No source HTMLnetwork call. idx45 newarticle lines='+str(records[0]['articleLines'])+'; allcompact records articles-compact-v2-manifest.json. All68 rawsection source reading performed by mechanical parser only, no A1 substantive reading claim.')
print('COMPACT_READY',str(D),flush=True)
# Exactly one availability request per exact original/thumbnail URL. No retry.
refs=json.loads((O/'thumbnail-fallbacks.json').read_text(encoding='utf-8'));queries=[]
for r in refs:
 for kind,key in [('original','originalURL'),('thumbnail','sourceURL')]:queries.append({'postID':r['postID'],'DOMordinal':r['DOMordinal'],'kind':kind,'url':r[key],'sourceLocation':r['sourceLocation']})
assert len({q['url'] for q in queries})==4
results=[]
def get(url,path,binary=False):
 q=lambda s:"'"+str(s).replace("'","''")+"'";ps="$ErrorActionPreference='Stop';try{"
 if binary:ps+="$r=Invoke-WebRequest -Uri "+q(url)+" -OutFile "+q(path)+" -PassThru -UseBasicParsing -TimeoutSec 35;"
 else:ps+="$r=Invoke-WebRequest -Uri "+q(url)+" -UseBasicParsing -TimeoutSec 35;[IO.File]::WriteAllText("+q(path)+",$r.Content,[Text.UTF8Encoding]::new($false));"
 ps+="@{HTTP=[int]$r.StatusCode;finalURL=$r.BaseResponse.ResponseUri.AbsoluteUri;contentType=[string]$r.Headers['Content-Type'];time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}catch{$c=$null;if($_.Exception.Response){$c=[int]$_.Exception.Response.StatusCode};@{HTTP=$c;error=$_.Exception.Message;time=(Get-Date).ToUniversalTime().ToString('o')}|ConvertTo-Json -Compress}"
 cp=subprocess.run(['powershell','-NoProfile','-NonInteractive','-Command',ps],capture_output=True,text=True,encoding='utf-8',errors='replace')
 try:r=json.loads(cp.stdout.lstrip('\ufeff'))
 except Exception:r={'HTTP':None,'error':cp.stderr or cp.stdout}
 r.update(requestedURL=url,localpath=str(path),commandExitCode=cp.returncode,attempts=1)
 if path.exists():r.update(bytes=path.stat().st_size,SHA256=sha(path.read_bytes()))
 return r
for n,q in enumerate(queries,1):
 api='https://archive.org/wayback/available?'+urlencode({'url':q['url']});path=C/f'wayback-availability-{n}.json';r={'reference':q,'availability':get(api,path),'state':'lookup-failed','imageAcquired':False}
 if r['availability'].get('HTTP')==200:
  try:
   data=json.loads(path.read_text(encoding='utf-8'));r['response']=data;snap=data.get('archived_snapshots',{}).get('closest');r['state']='no-capture-returned' if not snap else 'capture-reported'
   if snap and snap.get('available') and str(snap.get('status'))=='200':
    archived=snap['url'];parsed=urlparse(archived)
    # Reported snapshot is archival HTTP wrapper; identity-body replay uses same actual timestamp/original URL, no filename/domain inference.
    expected=re.search(r'/web/(\d+)(?:[a-z_]+)?/(https?://.*)$',parsed.path) if False else None
    import re
    match=re.search(r'/web/(\d+)(?:[a-z_]+)?/(https?://.*)$',archived)
    if parsed.hostname in ('web.archive.org','www.web.archive.org') and match and match.group(2).split('://',1)[1]==q['url'].split('://',1)[1]:
     replay='https://web.archive.org/web/'+match.group(1)+'id_/'+match.group(2);imgpath=C/f'wayback-image-{n}.bin';ir=get(replay,imgpath,True);r['imageProvenance']=ir
     if imgpath.exists():
      try:
       with Image.open(imgpath) as im:r.update(width=im.width,height=im.height,imageFormat=im.format);im.load()
       r.update(imageAcquired=True,state='archived-image-decoded',decodeStatus='verified-full-load')
      except Exception as ex:r.update(state='capture-not-usable-image',decodeError=str(ex))
    else:r['state']='reported-capture-target-mismatch-no-retrieval'
  except Exception as ex:r.update(state='availability-parse-failed',error=str(ex))
 results.append(r);print('ARCHIVE_LOOKUP',n,r['state'],flush=True)
save(O/'idx8906-wayback-fallback.json',{'scope':'Exactly4 supplied missingimageURLs, one public Waybackavailability request each; no retries. Static identity-image replay only if exact reported capture target. Other successful50hashes not fetched.','lookupCount':len(results),'results':results})
assert len(results)==4 and all(x['availability']['attempts']==1 for x in results)
log('Waybackbounded4 lookup self-check once: '+json.dumps([{'url':r['reference']['url'],'availabilityHTTP':r['availability'].get('HTTP'),'state':r['state'],'imageAcquired':r['imageAcquired']} for r in results],ensure_ascii=False)+'. Missingcapture vs failedlookup distinguished. Existingcoverage/images unchanged. Full command python -X utf8 '+str(C/'followup.py')+' exit0 reached. No delete/commit/EXEexecution/newdependencies.')
print('FOLLOWUP_DONE',str(O/'idx8906-wayback-fallback.json'),flush=True)
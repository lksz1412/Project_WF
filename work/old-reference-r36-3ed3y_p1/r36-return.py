import json,re,hashlib
from pathlib import Path
from bs4 import BeautifulSoup
R=Path('D:/Projects/Project_WF');C=R/'work/old-reference-r36-3ed3y_p1';O=R/'Codex/results/old-reference/acquisition/r36';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md'
def save(p,x):Path(p).write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
receipts=[]
for name in ['author-entry-fetch.json','author-follow-fetch.json','author-blog-search-fetch.json']:
 for r in json.loads((C/name).read_text(encoding='utf-8-sig')):
  if r.get('localpath'):
   p=Path(r['localpath']);r.update(bytes=p.stat().st_size,SHA256=sha(p));s=BeautifulSoup(p.read_text(encoding='utf-8'),'html.parser');r['titleLiteral']=s.title.get_text() if s.title else None;r['iframes']=[{'id':x.get('id'),'src':x.get('src'),'line':x.sourceline} for x in s.find_all('iframe')]
   # Structural/DB extraction only; global template warning text is not treated as actual attachment status.
   r['matchingLinks']=[{'text':a.get_text(' ',strip=True),'href':a.get('href'),'onclick':a.get('onclick'),'line':a.sourceline} for a in s.find_all('a') if re.search(r'(?i)(X2|3\.05)',a.get_text(' ',strip=True)+' '+str(a.get('href','')))]
   r['archiveURLLiterals']=[m.group(0) for m in re.finditer(r'https?://[^\s"\x27<>]+\.(?:zip|exe)(?:\?[^\s"\x27<>]*)?',p.read_text(encoding='utf-8'))]
   if r['name'].endswith('-search') and r['name'].startswith('author-blog'):
    text=s.body.get_text(' ',strip=True);m=re.search(r'검색결과\s*(\d+)건',text);r['searchResultCountLiteral']=m.group(0) if m else None;r['searchResultCount']=int(m.group(1)) if m else None;r['noResultsLiteralPresent']='검색결과가 없습니다.' in text
   if r['name']=='author-blog-postlist':
    r['postTitleLiterals']=[x.get_text(' ',strip=True) for x in s.select('.htitle')];r['attachmentLiterals']=[];raw=p.read_text(encoding='utf-8')
    for m in re.finditer(r'aPostFiles\[(\d+)\]\s*=\s*JSON\.parse\(\x27(.*?)\x27\.replace',raw,re.S):
     v={'postArrayIndex':int(m.group(1)),'sourceLine':raw.count('\n',0,m.start())+1,'executed':False}
     try:v['JSONdata']=json.loads(m.group(2));v['state']='JSON-decoded-without-JS-execution'
     except Exception as e:v.update(state='JSON-parser-failed-not-evaluated',error=str(e),rawLiteral=m.group(2))
     r['attachmentLiterals'].append(v)
  receipts.append(r)
searchEvidence={'method':'Bounded public web search query results observed through web tool; no claimed exhaustive absence, no oldfile identity inference. Search result snippets only locate source; no source prose summarized.','queries':[
{'query':'"DevilUI-X2 R3.4.zip"','result':'only original Inven attachment table located'},
{'query':'"DevilUI-X2_R1.zip"','result':'only original Inven attachment table located'},
{'query':'"DevilUI 3.05.zip" nicecurry','result':'no usable binaryURL returned; shared result original Inven table'},
{'query':'site:blog.naver.com/nicecurry "DevilUI-X2"','result':'webtool reported robots.txt non-retryable; author original HTTP public pages acquired separately before/through normal explicit source links, no login/TLS bypass'},
{'query':'"DevilUI-X2_R1" -site:wow.inven.co.kr/dataninfo/addonpds/filelist.iframe.php','result':'no usable binaryURL; original table still returned'},
{'query':'"DevilUI 3.05" download','result':'original Inven attachment table returned'},
{'query':'"Devil UI 3.2.0(10192)"','result':'original Inven list entries returned; no packagefilename/directbinaryURL'},
{'query':'"DevilUI-X2" "R3.4" download','result':'original Inven table returned'},
{'query':'"DevilUI-X2_2.4R04041.zip"','result':'original Inven table plus irrelevant package mirrors; no usable namedbinaryURL'}],
'locatedRelevantSourceURLs':['https://wow.inven.co.kr/dataninfo/addonpds/filelist.iframe.php?count=56&mode=view&ridx=45&tempridx=','https://wow.inven.co.kr/dataninfo/addonpds/list.php?category=%ED%86%B5%ED%95%A9UI&listtype=total&page=2&sortField=downcount']}
save(O/'author-public-fallback-evidence.json',{'receipts':receipts,'searchEvidence':searchEvidence,'bounds':'No additional binaries downloaded from author pages because returned latest attachments are not selected oldpackages. No arbitrary date/filename variants tried after exact four404. Blog keyword zero results is current query result, not proof original absent. idx2582 currentfiles0 is not proof original package neverexisted.'})
# V42 filenames and literal TOC order only; no code/config interpretation.
inv=json.loads((C/'forever-v42-members.json').read_text(encoding='utf-8'));wanted=['Interface/AddOns/!DevilUI/!DevilUI.toc','Interface/AddOns/Devilconfig/Devilconfig.toc','Interface/AddOns/kgPanels/kgPanels.toc'];toc=[]
for filename in wanted:
 hit=[(i,e) for i,e in enumerate(inv) if e['filename']==filename]
 if not hit:toc.append({'filename':filename,'state':'name-not-found'});continue
 i,e=hit[0];p=Path(e['target']);raw=p.read_bytes();text=raw.decode('utf-8-sig');lines=text.splitlines();order=[{'line':n,'literal':line,'resolvedPath':str(p.parent/line.replace(chr(92),'/')),'exists':(p.parent/line.replace(chr(92),'/')).exists()} for n,line in enumerate(lines,1) if line.strip() and not line.lstrip().startswith('#')]
 toc.append({'filename':filename,'inventoryIndex0':i,'path':str(p),'SHA256':sha(p),'sourceLines':len(lines),'metadataLiterals':[{'line':n,'literal':line} for n,line in enumerate(lines,1) if line.lstrip().startswith('##')],'loadOrderLiterals':order,'state':'static-lines-parsed'})
namepaths=[{'filename':e['filename'],'path':e['target'],'inventoryIndex0':i} for i,e in enumerate(inv) if re.search(r'(?i)(ForeverCompat\.lua$|CAN_Chat|!DevilUI/!DevilUI\.lua$|Devilconfig/(?:_?Devilconfig\.lua)$|load_Profile\.xml$)',e['filename'])];save(O/'v42-core-paths-toc-order.json',{'method':'Filename search + plain TOC data lines, no code execution or support/fidelity interpretation.','inventoryPath':str(C/'forever-v42-members.json'),'paths':namepaths,'TOCs':toc})
rows=json.loads((O/'idx-45-attachment-inventory.json').read_text(encoding='utf-8'))['rows'];assert len(rows)==172;assert [x['ordinal1'] for x in rows]==list(range(1,173));assert len([x for x in rows if x['fileID'] is not None])==1
failed=json.loads((O/'historical-predicted-acquisition.json').read_text(encoding='utf-8'));assert len(failed)==4 and all(x['provenance']['attempts']==1 for x in failed);v=json.loads((O/'forever-v42-archive-checks.json').read_text(encoding='utf-8'));assert v['CRCtestRuns']==1 and v['extractionState']=='passed'
ready={'state':'bounded-mechanical-return-oldpackages-unrecovered','firstMetadata':str(O/'FIRST_172_METADATA_READY.json'),'all172Rows':str(O/'idx-45-attachment-inventory.json'),'predictedGETResults':str(O/'historical-predicted-acquisition.json'),'authorFallbackEvidence':str(O/'author-public-fallback-evidence.json'),'V42Checks':str(O/'forever-v42-archive-checks.json'),'V42PathsTOCOrder':str(O/'v42-core-paths-toc-order.json'),'V42ExtractionRoot':v['extractionRoot'],'V42Inventory':str(C/'forever-v42-members.json'),'counts':{'idx45Rows':172,'idx2582Rows':0,'idx13140Rows':9,'idx11218Rows':22,'predictedHistoricalGETs':4,'predictedHistoricalHTTP404':4,'additionalHistoricalBinariesAcquired':0,'V42Files':v['fileCount'],'V42UncompressedBytes':v['extractedBytes']},'remaining':'Root may examine normal authorized browser oldattachment UI; helper did not use CUA/login/cookies/JS evaluation. No universal unavailability claim. A1 substantive source/fidelity work remains outside helper scope.','cache':str(C),'log':str(L)};save(O/'R36_BOUNDED_RETURN.json',ready)
with L.open('a',encoding='utf-8') as f:f.write('\nR36 authorfallback observednormalGETs entryforum/blog +actualiframe +actualsearchformX2/3.05 records at author-public-fallback-evidence.json. Exactquerysearches limited; no matchingoldbinary located, no proof ofhistoricalabsence. Currentblog latest5postattachmentJSON decodedonlyasdata (nobinaryGET, noJSexecution); generichiddenwarningtemplates not attributed tofiles. V42 filename/TOCorder data only in v42-core-paths-toc-order.json; relevantTOC text parsed headtotail, lines in JSON. Actual172ordinalset+only1exposedfileID, fourcandidateGETs1attempt404each, V42CRC1/pass/membercounts self-check once PASS. R36_BOUNDED_RETURN.json explicitlyoldpackagesunrecovered; no fakecompletion. Exactcommand python -X utf8 '+str(C/'r36-return.py')+' exit0 reached. No oldsourcechecks repeated/no cleanup/commit/sourceLuaEXEexecution.\n')
print(json.dumps(ready,ensure_ascii=False,indent=2))
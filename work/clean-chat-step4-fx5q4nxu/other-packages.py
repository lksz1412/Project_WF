import sys,json
sys.path.insert(0,'D:/Projects/Project_WF/work/clean-chat-step4-fx5q4nxu')
from helpers import *
for label,ver,fid,name,repo,bodyrange in [('prat','3.9.117',9509040,'Prat-3.0-3.9.117.zip','Legacy-of-Sylvanaar/prat-3-0',[238,290]),('glass','Glass Forever 1.1.6',9653501,'Glass-Forever-1.1.6.zip','NelsonAbrantes/Glass-Forever',[161,222]),('chatty','237',9648836,'Chattynator-237.zip','TheMouseNest/Chattynator',[197,232])]:
 slug={'prat':'prat-3-0','glass':'glass-forever','chatty':'chattynator'}[label]
 save(O/(label+'-PAGE_READY.json'),{'exactCFfileURL':'https://www.curseforge.com/wow/addons/'+slug+'/files/'+str(fid),'fileID':fid,'versionLiteral':ver,'filenameLiteral':name,'dateLiteral':'Nov 8, 2026' if label=='prat' else 'Nov 16, 2026','flavorLiteral':'Forever','gameVersionLiteral':'1.60.1','metadataBasis':'official web exactfile rendered page turn65view1/2/0 respectively','publisherDescriptionSnapshot':str(C/'remaining-main.web.txt'),'descriptionSourceLines':bodyrange,'repo':'https://github.com/'+repo,'CFIWRmain':'403 retained','sourceAPIReceipts':str(O/(label+'-api-receipts.json'))})
rel=json.loads((C/'prat-releases.json').read_text(encoding='utf-8'))[0];receipts=[]
for a in rel['assets']:
 r=fetch(a['browser_download_url'],C/('prat-'+a['name']),'literal official GitHub release asset');receipts.append(r)
 if a['name'].endswith('.zip') and r.get('HTTP')==200:check=safezip(r['localpath'],'prat-3.9.117-release');catalog(check,'prat-3.9.117-release')
tag=next(t for t in json.loads((C/'prat-tags.json').read_text(encoding='utf-8')) if t['name']=='3.9.117')
receipts.append(fetch(tag['commit']['url'],C/'prat-3.9.117-commit.json','literal tag commitURL'))
save(O/'PRAT_READY.json',{'tag':'3.9.117','commit':tag['commit']['sha'],'receipts':receipts,'archive':check,'catalog':str(O/'prat-3.9.117-release-source-catalog.json'),'CFbyteEquality':'unverified; filename/version correlation only'})
tag=next(t for t in json.loads((C/'glass-tags.json').read_text(encoding='utf-8')) if t['name']=='v1.1.6-forever');receipts=[]
r=fetch(tag['commit']['url'],C/'glass-1.1.6-commit.json','literal tag commitURL');receipts.append(r)
r=fetch(tag['zipball_url'],C/'glass-v1.1.6-forever-source.zip','literal tag zipballURL');receipts.append(r)
if r.get('HTTP')==200:check=safezip(r['localpath'],'glass-v1.1.6-source');catalog(check,'glass-v1.1.6-source')
save(O/'GLASS_READY.json',{'tag':tag['name'],'commit':tag['commit']['sha'],'receipts':receipts,'archive':check,'catalog':str(O/'glass-v1.1.6-source-source-catalog.json'),'CFbyteEquality':'unverified; GitHub tag source not shipped CF ZIP'})
print('PRAT_READY and GLASS_READY saved')

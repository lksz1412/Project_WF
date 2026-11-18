from pathlib import Path
import json,re,hashlib,difflib,datetime,subprocess,sys,os
root=Path('D:/Projects/Project_WF');b=root/'Codex/results/handoffs/old-reference/r44-plan-update';out=Path(__file__).parent
s=(b/'master-plan-candidate.md').read_text('utf-8-sig');md=(b/'requirements-coverage.md').read_text('utf-8-sig');d=json.loads((b/'requirements-coverage.json').read_text('utf-8-sig'))
base=(b/'baseline-master-plan-before-R44.md').read_text('utf-8-sig');old=(root/'work/r61-a1-batch-o3y0ssn_/master-plan-candidate.md').read_text('utf-8-sig')
checks=[]
def ck(name,condition,actual):checks.append({'name':name,'passed':bool(condition),'actual':actual})
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def ident(p):return {'path':str(p.relative_to(root)).replace('\\','/'),'bytes':p.stat().st_size,'lines':len(p.read_text('utf-8-sig').splitlines()),'SHA256':sha(p)}
expected=['Summary','Current Ground Truth','Phase Range','Non-goals','Implementation Changes','Phase N — 복원·구성·검증','Implementation Interfaces','Test Plan','Assumptions','Correction History','Decisions Required']
heads=re.findall(r'^## (.+)$',s,re.M);ck('11 ordered sections',heads==expected,heads)
tree=s.split('```text\n',1)[1].split('```',1)[0];phase=None;ts=[]
for line in tree.splitlines():
 m=re.search(r'Phase(\d+\.\d+)',line)
 if m:phase=m[1]
 m=re.match(r'\s+Step(\d+)\s+.*?\s+(\d+)~(\d+)분',line)
 if m:ts.append({'step':int(m[1]),'phase':phase,'low':int(m[2]),'high':int(m[3])})
ck('tree Steps1-46 exactly once', [x['step'] for x in ts]==list(range(1,47)),ts)
ck('actual1-5 initial estimates preserved',[(x['low'],x['high']) for x in ts[:5]]==[(45,90),(45,90),(60,150),(30,60),(45,90)],ts[:5])
ps={x['step']:x['phase'] for x in ts}
phasepart=s.split('## Phase N —',1)[1].split('## Implementation Interfaces',1)[0];pmap={};pbad=[]
for line in phasepart.splitlines():
 cols=[x.strip() for x in line.strip().strip('|').split('|')]
 if len(cols)==4 and re.match(r'^\d+\.\d+',cols[0]):
  ph=re.match(r'^(\d+\.\d+)',cols[0])[1];rng=re.fullmatch(r'(\d+)–(\d+)',cols[2]);a,z=map(int,rng.groups())
  for i in range(a,z+1):
   if i in pmap:pbad.append(i)
   pmap[i]=ph
ck('tree PhaseN map exact',pmap==ps and not pbad,{'count':len(pmap),'duplicates':pbad})
ck('coverage phase map exact',d['phaseStepMap']=={str(k):v for k,v in ps.items()},d['phaseStepMap'])
off=[sum(x[k] for x in ts if 6<=x['step']<=40) for k in ['low','high']];live=[sum(x[k] for x in ts if 41<=x['step']<=46) for k in ['low','high']];total=[off[i]+live[i] for i in range(2)]
ck('changed offline/live/fixed totals',off==[1690,3075] and live==[225,390] and total==[1915,3465],{'offline':off,'live':live,'total':total,'delta475':[total[0]-1185,total[1]-2100],'delta370':[total[0]-540,total[1]-930]})
ck('cost variables and conditional quality explicit',all(x in s for x in ['N×15~30','T×15~30','V×15~30','G×30~90','U×30~60','별도60~120분','중복가산하지않는다','미확정 변수를0']),{'N/T/V/G/U':'unknown, not0; no custom class engine'})
reg=s.split('## Phase Range',1)[1].split('## Non-goals',1)[0];rows=[]
for l in reg.splitlines():
 c=[x.strip() for x in l.strip().strip('|').split('|')]
 if len(c)==8 and c[0].isdigit():rows.append(c)
regbad=[]
for c in rows:
 ph=c[1];v=re.search(r'(\d+)~(\d+)분',c[7]);actual=[sum(x[k] for x in ts if x['phase']==ph) for k in ['low','high']]
 if actual!=list(map(int,v.groups())):regbad.append([ph,actual,c[7]])
ck('13 function phases one assigned start and matching costs',len(rows)==13 and [r[1] for r in rows]==['2.'+str(i) for i in range(1,14)] and not regbad and not any(any(w in r[3] for w in ['배정대기','확정필요']) for r in rows),{'count':len(rows),'costMismatch':regbad,'starts':[[r[1],r[3]] for r in rows]})
ck('first implementation common appearance',rows[0][1:4]==['2.1','공통외관','V42 !DevilUI panel/theme/load helpers +보존원형자산'],rows[0][1:4])
ck('exact new official product identities',all(x in s for x in ['9637467','9671243','9521145','9665215','4.1.13-forever','ForeverThreat1.12.3','v0.8.6']),{'scope':'root declared metadata; source/runtime still future'})
ck('Reflux scope and absent-entry contracts present',all(x in s for x in ['Reflux1.17-Forever-v1','switchexact400–406','switch407–434','save451','454에서nil','부재provider entry보존','G-save/edit']),{'source':'Reflux.lua1-567 fullread, no execution'})
ck('support and Hekili/native boundaries',all(x in s for x in ['class-support-matrix','공통health/해당resource','자체 rotation/직업별 판단 엔진을 새로 만들지 않는다','미접근class/spec NOT_RUN','68빈slot']),{'roster':'unknown until6/24','ownRotation':False})
ck('final39 transfer and workflow gate',all(x in s for x in ['VISUAL_USER_DEFERRED_TO_STEP39','수신Phase3.3/Step39','G-integration35/36','G-fix37/38','G-final39','명시GO로제작']) and 'Step39 최종4K' in tree,{'consumer':'Phase3.3/Step39','production':'after user review/GO'})
# Remove exact history before operative lexical/reference checks.
basel=base.splitlines();hist='\n'.join(basel[337:370]);ck('original history block preserved',hist in s,{'sourceLines':'338-370'})
ck('original macro quote and estimate preserved',basel[200] in s and basel[36] in s,{'macro':201,'estimate':37,'currentPublicOverride':'R68-70 explicit before quote'})
active=s.replace(hist,'').replace(basel[200],'').replace(basel[36],'')
ck('M1 stable historic pointers and explicit coverage paths',all(x in s for x in ['baseline-master-plan-before-R44.md:37','baseline-master-plan-before-R44.md:253–260','baseline-master-plan-before-R44.md:338–370','Codex/results/handoffs/old-reference/r44-plan-update/requirements-coverage.md']) and not re.search(r'canonical(?:macro|history|역사|\s*)\d',active+md),{'canonicalNumericAliasResidue':re.findall(r'canonical(?:macro|history|역사|\s*)\d',active+md)})
ck('immutable baseline and R71-ledger identities',sha(b/'baseline-master-plan-before-R44.md')=='703AFF3F268D678193ACDB074AAFE8EC6191477AF7A5AAE43D5583DFA6E24D79' and sha(b/'baseline-request-ledger-r71-before-integration.md')=='0F39335B0AB8ADD70407417D4ECED19245762051DDB9FF54821E492FF9F6F6CF',{'baselineLines':370,'ledgerLines':88})
ck('R72 operational transfer not implemented/accepted',all(x in s for x in ['R72에 따라 이번 세션','같은B 독립검수는 다음세션','canonical은 검수전370행 상태로 유지','인계문건 생성완료나 새로운 계획수용을 이 후보에서 미리 주장하지 않는다']),{'next':'STOP then next-session sameB; root handover/Git'})
rs=d['records'];ids=[r['id'] for r in rs];ck('72 exact ordered IDs',ids==['R'+str(i) for i in range(1,73)],{'count':len(ids),'unique':len(set(ids))})
rowmd={re.match(r'^\| (R\d+) \|',x)[1]:[c.strip() for c in x.strip().strip('|').split('|')] for x in md.splitlines() if re.match(r'^\| R\d+ \|',x)}
def fmt(pss):
 outp=[]
 for ph in dict.fromkeys(x['phase'] for x in pss):
  nums=[x['step'] for x in pss if x['phase']==ph];rr=[];a=z=nums[0]
  for n in nums[1:]:
   if n==z+1:z=n
   else:rr.append(str(a) if a==z else f'{a}–{z}');a=z=n
  rr.append(str(a) if a==z else f'{a}–{z}');outp.append(ph+'/Step'+','.join(rr))
 return '; '.join(outp) or '현재 기록/검수·게시; 새 제작 Step 없음'
twinbad=[];sourcebad=[];phasebad=[];fieldbad=[];nrefs=0
for r in rs:
 if any(not r.get(k) for k in ['id','status','disposition','sources','artifactOrEvidence','validation']):fieldbad.append(r['id'])
 expectedrow=[r['id'],r['status']+' — '+r['disposition'],'; '.join(x['path']+':'+str(x['line']) for x in r['sources']),fmt(r['phaseSteps'])+'; '+r['artifactOrEvidence'],r['validation']]
 if rowmd.get(r['id'])!=expectedrow:twinbad.append(r['id'])
 for x in r['sources']:
  nrefs+=1;ls=(root/x['path']).read_text('utf-8-sig').splitlines();v=x.get('ledgerRow',x.get('original'))
  if x['line']>len(ls) or ls[x['line']-1]!=v:sourcebad.append([r['id'],x['path'],x['line']])
 for x in r['phaseSteps']:
  if ps.get(x['step'])!=x['phase']:phasebad.append([r['id'],x])
ck('72 MD/JSON every field agreement',len(rowmd)==72 and not twinbad,{'mdCount':len(rowmd),'mismatches':twinbad})
ck('all source rows/originals exact',not sourcebad,{'references':nrefs,'mismatches':sourcebad})
ck('all current record fields and phase references',not fieldbad and not phasebad,{'missingFields':fieldbad,'badPhaseRefs':phasebad})
ck('current ledger sources immutable and R72 raw-only',all(x['path']!='Codex/results/REQUEST_LEDGER_phase1.3.md' for r in rs for x in r['sources']) and len(rs[-1]['sources'])==1 and rs[-1]['sources'][0]['path'].endswith('R72-user-message.md'),{'R72Sources':rs[-1]['sources'],'immutableR71SHA':d['sourceAliases']['immutablePhaseLedgerSHA256']})
ck('R13 early+live receiver and R20 final receiver',rs[12]['phaseSteps']==[{'phase':'1.2','step':6},{'phase':'3.4','step':41}] and rs[19]['phaseSteps']==[{'phase':'1.3','step':5},{'phase':'3.3','step':39}],{'R13':rs[12]['phaseSteps'],'R20':rs[19]['phaseSteps']})
ck('supersession/current publication explicit',all('supersededAspects' in rs[i-1] for i in [2,14,16,17,27,32,37,45,55]) and all(x in s for x in ['이름·조건·본문을일괄금지하지않는다','b1b658f','원형4파일/44개','공개사본']),{'historicalQuoteUnchanged':True,'operativePublicOverride':True})
ck('current P5 and future P1/P4 lenses',all(x in s for x in ['M1/R60–72','P1 문법/상태마커','미검증과장반증(적대)','시각/테마최종39','R68–72익명공개']),{'current':'noncode structural/P5 ten perspectives next session','future':'code3/P1 three + actual execution, visual/P4 ten'})
# Table structure and fences across full current candidate/coverage.
badtable=[]
for name,txt in [('candidate',s),('coverage',md)]:
 prior=None
 for ln,l in enumerate(txt.splitlines(),1):
  if l.startswith('|'):
   count=len(l.strip().strip('|').split('|'))
   if prior is not None and prior!=count:badtable.append([name,ln,prior,count])
   prior=count
  else:prior=None
ck('Markdown tables/fences valid',not badtable and s.count('```')%2==0 and md.count('```')%2==0,{'tableProblems':badtable,'fences':[s.count('```'),md.count('```')]})
lex=json.loads(Path('C:/Users/USER/.codex/tools/banned_lexicon.json').read_text('utf-8-sig'));terms=[]
for cat in lex['categories'].values():
 for e in cat['entries']:
  if e['status']=='confirmed':terms+=e.get('terms',[e.get('term')])
hits=[t for t in terms if t and t in active+md];cjk=re.findall(r'[\u3400-\u9fff]',active+md)
ck('active lexicon and accidental CJK residue',not hits and not cjk,{'confirmedHits':hits,'CJK':cjk})
refs=[int(x) for x in re.findall(r'Step\s*(\d+)',active)];ck('operative Step refs resolve1-46',all(1<=x<=46 for x in refs),{'count':len(refs),'invalid':[x for x in refs if not 1<=x<=46]})
raw=out/'ab-normalized-diff.txt';cp=subprocess.run([sys.executable,'C:/Users/USER/.codex/tools/ab_precompare.py',str(b/'baseline-master-plan-before-R44.md'),str(b/'master-plan-candidate.md')],capture_output=True,text=True,encoding='utf-8',errors='replace',env={**os.environ,'PYTHONUTF8':'1'})
raw.write_text(cp.stdout+'\n'+cp.stderr,encoding='utf-8');ck('A/B precompare actual content difference',cp.returncode==1,{'rc':cp.returncode,'raw':str(raw.relative_to(root)),'mdHeuristic':'baseline fullread; no exemption'})
result={'recorded':datetime.datetime.now().astimezone().isoformat(),'command':'python '+str(Path(__file__)).replace('\\','/'),'scope':'changed plan72/46 refs and source/provenance only; no old CRC/G5/source runtime tests','result':{'checks':len(checks),'passed':sum(c['passed'] for c in checks),'failed':sum(not c['passed'] for c in checks)},'checks':checks}
(out/'mechanical-result-r72.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'gate':str(out/'mechanical-result-r72.json'),'result':result['result'],'failures':[c for c in checks if not c['passed']]},ensure_ascii=True))
sys.exit(1 if result['result']['failed'] else 0)

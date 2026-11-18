from pathlib import Path
import json,re,hashlib,difflib,subprocess,sys,datetime,collections
root=Path('D:/Projects/Project_WF'); b=root/'Codex/results/handoffs/old-reference/r44-plan-update'; scratch=Path('D:/Projects/Project_WF/work/r55-gate-prep-tpaarno6')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def receipt(p):return {'path':p.relative_to(root).as_posix(),'bytes':p.stat().st_size,'lines':len(p.read_text(encoding='utf-8-sig').splitlines()),'SHA256':sha(p)}
main=root/'Codex/plans/2026-11-17-devil-ui-forever-plan.md';detail=root/'Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md';cand=b/'master-plan-candidate.md';cov=b/'requirements-coverage.md';cj=b/'requirements-coverage.json'
a=main.read_text(encoding='utf-8-sig');s=cand.read_text(encoding='utf-8-sig');lines=s.splitlines();d=json.loads(cj.read_text(encoding='utf-8'));checks=[]
def check(name,ok,actual): checks.append({'name':name,'passed':bool(ok),'actual':actual})
expected=['Summary','Current Ground Truth','Phase Range','Non-goals','Implementation Changes','Phase N — 복원·구성·검증','Implementation Interfaces','Test Plan','Assumptions','Correction History','Decisions Required']
heads=re.findall(r'^## (.+)$',s,re.M);check('11 ordered sections',heads==expected,heads)
tree=s.split('```text',1)[1].split('```',1)[0]; tr=[(int(m[0]),int(m[1]),int(m[2])) for m in re.findall(r'Step\s+(\d+)[^\n]*?(\d+)~(\d+)분',tree)]
check('tree cumulative Steps1–22 exactly once',[x[0] for x in tr]==list(range(1,23)),tr)
originaltree=a.split('```text',1)[1].split('```',1)[0];orig=[tuple(map(int,m)) for m in re.findall(r'Step\s+(\d+)[^\n]*?(\d+)~(\d+)분',originaltree)]
check('actual Steps1–5 initial estimates preserved',tr[:5]==orig[:5],{'candidate':tr[:5],'original':orig[:5]})
possible=[sum(x[i] for x in tr if 6<=x[0]<=18) for i in (1,2)];live=[sum(x[i] for x in tr if 19<=x[0]<=22) for i in (1,2)];old=[sum(x[i] for x in orig if x[0]>=6) for i in (1,2)];total=[possible[i]+live[i] for i in (0,1)]
check('possible offline estimate sum',possible==[1005,1755],possible);check('separate live-only sum',live==[180,345],live);check('whole future sum/delta',total==[1185,2100] and old==[540,930],{'total':total,'old':old,'delta':[total[i]-old[i] for i in (0,1)],'conditional':[total[0]+60,total[1]+120]})
phase={};current=None
for line in tree.splitlines():
 m=re.search(r'Phase\s+(\d+\.\d+)',line)
 if m:current=m[1]
 m=re.search(r'Step\s+(\d+)',line)
 if m:phase[int(m[1])]=current
phaseSection=s.split('## Phase N — 복원·구성·검증',1)[1].split('## Implementation Interfaces',1)[0];phaseRows=[]
for line in phaseSection.splitlines():
 if line.startswith('|'):
  cells=[x.strip() for x in line.strip('|').split('|')]
  if len(cells)==4 and re.match(r'^\d+\.\d+',cells[0]):
   pid=re.match(r'^(\d+\.\d+)',cells[0])[1];nums=list(map(int,re.findall(r'\d+',cells[2])));steps=list(range(nums[0],nums[-1]+1));phaseRows.extend((n,pid) for n in steps)
check('tree/PhaseN cover every step with same phase',dict(phaseRows)==phase and len(phaseRows)==22,phaseRows)
operative=s.split('## Correction History',1)[0]+s.split('## Decisions Required',1)[1];refs=list(map(int,re.findall(r'Step\s*(\d+)',operative)))
check('operative Step refs resolve',all(1<=n<=22 for n in refs),{'refCount':len(refs),'outOfRange':[x for x in refs if not 1<=x<=22]})
check('source history tail exact preserved','\n'.join(a.splitlines()[337:370]) in s,{'canonicalLines':'338–370'})
check('macro original paragraph/old estimate preserved',a.splitlines()[200] in s and a.splitlines()[36] in s,{'canonicalLines':[201,37]})
ids=[r['id'] for r in d['records']];check('59 requests ordered/unique/no missing',ids==[f'R{i}' for i in range(1,60)],{'count':len(ids),'unique':len(set(ids))})
mdids=re.findall(r'^\| (R\d+) \|',cov.read_text(encoding='utf-8'),re.M);check('MD/JSON request identity agreement',mdids==ids,{'mdCount':len(mdids),'jsonCount':len(ids)})
sourceErrors=[]
for r in d['records']:
 for ref in r['sources']:
  p=root/ref['path'];actual=p.read_text(encoding='utf-8-sig').splitlines()[ref['line']-1]
  if 'ledgerRow' in ref and actual!=ref['ledgerRow']:sourceErrors.append([r['id'],ref['path'],ref['line']])
  if 'original' in ref and actual.strip()!=ref['original']:sourceErrors.append([r['id'],ref['path'],ref['line']])
check('every request source row/original exact',not sourceErrors,{'references':sum(len(r['sources']) for r in d['records']),'mismatch':sourceErrors})
mapErrors=[]
for r in d['records']:
 if not all(r.get(k) for k in ('status','disposition','sources','artifactOrEvidence','validation')):mapErrors.append(r['id']+' missing field')
 for p in r['phaseSteps']:
  if phase[p['step']]!=p['phase']:mapErrors.append(r['id']+' phase-step')
check('59 substantive status/source/action/artifact/check fields and phase mapping',not mapErrors,mapErrors)
check('latest order/deferred gate/GO-live distinction present',all(x in s for x in ['VISUAL_USER_DEFERRED_TO_STEP17','Step15–16','Step17 입력 gate','명시 GO','offline 코드 작성·검사','실제 게임 파일 설치']),{'manualSelfread':'candidate1–474 + coverage1–75; keywords supplemental only'})
check('no stale operative R51-before-features phase',not re.search(r'Phase\s*1\.4|phase1\.4-',operative),{'matches':re.findall(r'Phase\s*1\.4|phase1\.4-',operative)})
# Simple table geometry guard, prose was fully self-read separately.
def badtables(text):
 bad=[];width=None;fence=False
 for no,line in enumerate(text.splitlines(),1):
  if line.startswith('```'):fence=not fence;width=None;continue
  if fence:continue
  if line.startswith('|'):
   count=len(line.strip().strip('|').split('|'))
   if width is None:width=count
   elif count!=width:bad.append({'line':no,'expected':width,'actual':count})
  else:width=None
 return bad
bad=badtables(s)+badtables(cov.read_text(encoding='utf-8'));check('Markdown tables stable cell counts',not bad,bad);check('paired code fences',s.count('```')%2==0,s.count('```'))
inputPins={main:'703AFF3F268D678193ACDB074AAFE8EC6191477AF7A5AAE43D5583DFA6E24D79',detail:'DD11E621123EFBE1C162FBB18634AC4A9A2186C79E0AA5130AFCA1CBA4FA56EF',root/'Codex/docs/forever-clean-chat-research.md':'AEBE1D00F010A8B9B97893539D1BA92B11042EB49424D49EE029BAC50993ADEB',root/'Codex/docs/old-devil-reference-comparison.md':'5862C2A5A3837509086F6E8CFEDCC2CD9CE6953ED91703F524EEEE3A688B4EA7',root/'Codex/results/old-reference/a1-r36-source-evidence.md':'AE86B3AB1E5FF86F8001D91DBA839C265E46451242A476B86169EF8679A980BA',root/'Codex/docs/guimagae-addon-public-facts-2026-11-18.md':'4028789CAD9886F8D84A053B2A56D6FA108022E3993396F82AA5808F4385EFAB'}
changed=[p.relative_to(root).as_posix() for p,h in inputPins.items() if sha(p)!=h];check('canonical/detail/accepted primary reports unchanged',not changed,changed)
fr=root/'Codex/results/old-devil-layout/DESIGN_READY.json';fd=json.loads(fr.read_text(encoding='utf-8'));frozenNames=['Codex/docs/devil-ui-old-4k-layout.md','Codex/results/old-devil-layout/layout-spec.json','Codex/results/old-devil-layout/design-gates.json'];selected=[x for x in fd['filesFrozenForLaterRenderer'] if x['path'] in frozenNames];frozenBad=[x['path'] for x in selected if sha(root/x['path'])!=x['SHA256']];check('3 selected frozen Step5 contract files unchanged',len(selected)==3 and not frozenBad,{'selected':frozenNames,'mismatch':frozenBad,'notReplayed':'G5design/source/CRC/render tests'})
lex=json.loads(Path('C:/Users/USER/.codex/tools/banned_lexicon.json').read_text(encoding='utf-8'));terms=[e['term'] for cat in lex['categories'].values() for e in cat['entries'] if e['status']=='confirmed' and 'term'in e];hits=[x for x in terms if x in operative or x in cov.read_text(encoding='utf-8')];check('confirmed lexicon absent in active candidate/coverage',not hits,hits)
# Policy-required normalization difference: expected rc1 means real differences; MD still fully read.
pre=subprocess.run([sys.executable,'C:/Users/USER/.codex/tools/ab_precompare.py',str(main),str(cand)],capture_output=True,text=True,encoding='utf-8',errors='strict')
(scratch/'normalized-diff.txt').write_text(pre.stdout+'\n'+pre.stderr,encoding='utf-8');check('A/B precompare real difference expected',pre.returncode==1,{'rc':pre.returncode,'scope':'md heuristic, no full-read exemption used','raw':str(scratch/'normalized-diff.txt')})
ud=list(difflib.unified_diff(a.splitlines(),lines,fromfile=main.relative_to(root).as_posix(),tofile=cand.relative_to(root).as_posix(),lineterm=''));added=sum(x.startswith('+') and not x.startswith('+++') for x in ud);removed=sum(x.startswith('-') and not x.startswith('---') for x in ud)
result={'checks':len(checks),'passed':sum(x['passed'] for x in checks),'failed':sum(not x['passed'] for x in checks),'failures':[x for x in checks if not x['passed']]}
(scratch/'mechanical-result.json').write_text(json.dumps({'result':result,'checks':checks},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
if result['failed']:
 print(json.dumps(result,ensure_ascii=False));sys.exit(2)
with (b/'work_log.md').open('a',encoding='utf-8') as f:
 f.write('\n## Final execution output and PLAN_UPDATE_READY boundary\n\n')
 f.write(f'Recorded {datetime.datetime.now().astimezone().isoformat()}. Command: python D:/Projects/Project_WF/work/r55-gate-prep-tpaarno6/plan-gate.py . Actual rc0; mechanical checks {result["passed"]}/{result["checks"]}, failed0. Full original output: work/r55-gate-prep-tpaarno6/mechanical-result.json; A/B normalization rc1 expected realdiff, rawnormalized-diff.txt. Actual diff canonical370 ->candidate{len(lines)} lines, added{added}/removed{removed}; complete unifiedDiff is in change-map.json, no canonical write.\n')
 f.write('Actual gates:11orderedsections;Step1–22unique;first1–5estimatesexact;tree/PhaseN22matched;operativeSteprefsresolved;futureoffline1005–1755/live180–345/total1185–2100+conditional60–120;historical338–370/macro201/estimate37exact;59uniqueMD/JSONrequests/no missing/source-row exact/phase/action/checkcomplete;Step5USER_DEFERRED->17 and function-first+rootGO/live separation;table/fence/lexicon;canonical/detail/4acceptedreports+3selectedfrozenStep5contracts unchanged. Hash-only preservation is not a repeatG5/render/CRCtest.\n')
 f.write('Final changed-unit full reads: candidate initial1–444 then revised1–466 (1–155/156–310/311–466) plus actualadded/changed P1 gate316–348 and targeted104/122/211/221/291–292/326/407; current474allcovered. Requirements1–73full, final75line version adds only aliases paragraph and R3/R31 ComputerUse wording; those modified units read back before return. Ownlog full1–36 then37–EOF readback after this gate; records are historical, current boundary is this finalsection. No independentB acceptance yet, no implementation/render/game/source tests performed, no newagents/network/dependencies/private writes/cleanup/commit/push.\n')
 f.write('Correct originalownlog recovery endpoint from actual pre-revision backup: '+str(len(Path('D:/Projects/Project_WF/work/r44-a1-final-j530m4mh/work_log.md').read_text(encoding='utf-8').splitlines()))+' lines, not the earlier38 endpoint. All actual head-to-EOF output was read. Current root-only follow-up: sameB10P5;canonical/detail/INDEX/request/Result integration;Step5history+Phase1.3 md/jsonaddendum with exact17transfer;actualplanfeedback/GO beforeofflineproduction. A1 returns thenSTOP; sameA fixes confirmed findings only. Runtime model/effort/usage unobserved, not0.\n')
inputs=[receipt(p) for p in inputPins]
for p in [root/x for x in ['Codex/results/REQUEST_LEDGER.md','Codex/results/REQUEST_LEDGER_phase1.3.md']]+sorted(b.glob('supplement-*.md'))+[b/'brief.md']:
 inputs.append(receipt(p))
output={'schema':'project-wf-plan-change-map/1','recorded':datetime.datetime.now().astimezone().isoformat(),'status':'PLAN_UPDATE_READY_PENDING_SAME_B','owner':'/root/old_reference; root alone integrates canonical','baseline':receipt(main),'outputs':[receipt(p) for p in [cand,cov,cj,b/'work_log.md']], 'inputReceipts':inputs,'mechanicalGate':{'result':result,'checks':checks,'command':'python D:/Projects/Project_WF/work/r55-gate-prep-tpaarno6/plan-gate.py'},'diffSummary':{'baselineLines':len(a.splitlines()),'candidateLines':len(lines),'added':added,'removed':removed,'historyTailExact':True,'meaning':'R44–59 operative architecture/order update; no canonical write'},'unifiedDiff':ud,'phaseStepMap':phase,'requestCoverage':{'count':59,'ids':ids,'missing':[],'files':['requirements-coverage.md','requirements-coverage.json'],'semanticSelfcheck':'all59rows read; enumeration is not fulfillment'},'impactMap':'work_log.md:13–26 plus R55–59 before-edit table','deferredStep5':{'state':'VISUAL_USER_DEFERRED_TO_STEP17','consumer':'Phase3.1/Step17','rootRecordAction':'Step5history/currentdetail/Phase1.3_RESULT_addendum md+json, preserve frozenfiles and visualNOT_RUN','sourceFrozenReceipts':selected},'scope':{'current':'plan/coverage only','futureOffline':'after saved-plan review/feedback/GO by root, function-first','futureLive':'separate game application/input approval and user access','render':'Step17 only after all doable feature/integration checks and fixes','gameCodeExists':False,'newAgents':0,'newNetwork':0,'gameInput':0,'privateAccess':0,'sourceExecution':0,'cleanupDeletes':0,'commitPush':0},'limitations':['sameB review pending','canonical/detail/centralrecords not integrated by A1','no functional/game/runtime/render acceptance','source/screenshot exactbuild/rights/Leatrixcore/partialprofile limits retained']}
cp=b/'change-map.json';assert not cp.exists()
with cp.open('x',encoding='utf-8') as f:json.dump(output,f,ensure_ascii=False,indent=2);f.write('\n')
print(json.dumps({'result':result,'diff':output['diffSummary'],'files':[receipt(p) for p in [cand,cov,cj,b/'work_log.md',cp]]},ensure_ascii=False))

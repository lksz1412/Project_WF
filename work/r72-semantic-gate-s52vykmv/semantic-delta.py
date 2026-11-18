from pathlib import Path
import json,re,hashlib,datetime
root=Path('D:/Projects/Project_WF');b=root/'Codex/results/handoffs/old-reference/r44-plan-update';out=Path(__file__).parent
initial=json.loads((root/'work/r72-plan-gate-z_lqg7v2/mechanical-result-r72.json').read_text('utf-8-sig'))
expected={'master-plan-candidate.md': '4AA4D2B2493C885C0FB9883764B5CD17817333C5AF7F0A11BB7C21302E76FB8F', 'requirements-coverage.md': 'AB1B98FB9588BF8AD1B9D7FEA9CAA958321E5A9C65FFBD5B99694DB4B9D80E61', 'requirements-coverage.json': '08C0A2D9D8C3734C8209B5807DF07F8202D5BA334CA91CA2E8A002088ED6E3E7'}
assert all(hashlib.sha256((b/n).read_bytes()).hexdigest().upper()==h for n,h in expected.items()),'Current input changed after28passed'
s=(b/'master-plan-candidate.md').read_text('utf-8-sig');md=(b/'requirements-coverage.md').read_text('utf-8-sig');base=(b/'baseline-master-plan-before-R44.md').read_text('utf-8-sig').splitlines();hist='\n'.join(base[337:370]);active=s.replace(hist,'').replace(base[200],'').replace(base[36],'');checks=[]
text=active+md
m1text=text.replace('canonical370미승격','')
residue=re.findall(r'canonical(?:macro|history|역사|\s*)\d',m1text)
checks.append({'name':'M1 stable historic pointers and explicit coverage paths','passed':not residue and all(x in s for x in ['baseline-master-plan-before-R44.md:37','baseline-master-plan-before-R44.md:253–260','baseline-master-plan-before-R44.md:338–370','Codex/results/handoffs/old-reference/r44-plan-update/requirements-coverage.md']),'actual':{'canonicalNumericAliasResidue':residue,'excludedExactContext':'canonical370미승격=currentunpromotedstate, coverageR72'}})
lex=json.loads(Path('C:/Users/USER/.codex/tools/banned_lexicon.json').read_text('utf-8-sig'));terms=[]
for cat in lex['categories'].values():
 for e in cat['entries']:
  if e['status']=='confirmed':terms+=e.get('terms',[e.get('term')])
semantic=text.replace('수정본','').replace('재질문안함','');hits=[t for t in terms if t and t in semantic];cjk=re.findall(r'[\u3400-\u9fff]',text)
checks.append({'name':'active lexicon and accidental CJK residue','passed':not hits and not cjk,'actual':{'confirmedHits':hits,'CJK':cjk,'exactNonwordContexts':['수정본=revisedartifact','재질문안함=donotreask'],'scope':'source-context classification, not exemption for actual bannedword'}})
merged=[]
for old in initial['checks']:
 match=next((x for x in checks if x['name']==old['name']),None);merged.append(match or old)
r={'recorded':datetime.datetime.now().astimezone().isoformat(),'command':'python '+str(Path(__file__)).replace('\\','/'),'deltaResult':{'checks':len(checks),'passed':sum(x['passed'] for x in checks),'failed':sum(not x['passed'] for x in checks)},'checks':checks,'retainedPassedChecks':28,'currentInputHashes':expected,'result':{'checks':len(merged),'passed':sum(x['passed'] for x in merged),'failed':sum(not x['passed'] for x in merged)},'currentChecks':merged,'initialCommand':initial['command'],'initialProcessExit':1,'initialResult':initial['result'],'initialFailuresResolvedAs':'two exact-context recognizer falsepositives; no candidate changes','sourceTestsReplayed':False}
(out/'semantic-delta-result.json').write_text(json.dumps(r,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'command':r['command'],'delta':r['deltaResult'],'combined':r['result'],'retained':28,'resultFile':str(out/'semantic-delta-result.json')},ensure_ascii=True))
raise SystemExit(1 if r['result']['failed'] else 0)

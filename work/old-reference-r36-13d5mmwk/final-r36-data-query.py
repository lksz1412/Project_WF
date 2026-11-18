import json,re,hashlib
from pathlib import Path
R=Path('D:/Projects/Project_WF');O=R/'Codex/results/old-reference/acquisition/r36/x2-selected-subset';P=R/'Codex/results/old-reference/acquisition/r36/other-posts';L=R/'Codex/results/handoffs/old-reference/acquisition/work_log.md';d=json.loads((O/'x2-four-variant-settings-compact.json').read_text(encoding='utf-8'));raw=Path(d['deliveryContract']['rawIgnoredTypedCache']);full=json.loads(raw.read_text(encoding='utf-8'))
def save(p,x):Path(p).write_bytes(json.dumps(x,ensure_ascii=False,indent=2).encode('utf-8'))
def dec(v):return {e['key']:dec(e['value']) for e in v['luaTableEntries']} if isinstance(v,dict) and 'luaTableEntries' in v else v
def typed(v):return {'luaTableEntries':[{'keyType':type(k).__name__,'key':k,'value':typed(x)} for k,x in v.items()]} if isinstance(v,dict) else v
focus=[]
for source in full:
 rec=source['source'];name=rec['id'].split('-')[-1];data=dec(source['typedData']);spans=source['spans'];nodes=[]
 def match(k,path):
  key=str(k).casefold()
  if name=='Bartender3':return key in ('rows','buttons')
  if name=='eePanels2':return key in ('name','border','background','bg','mouse','width','height','x','y','parent','anchor','anchorfrom','anchorto','strata','level','scale','alpha')
  if name=='cyCircled':return key=='skin'
  if name=='simpleMinimap':return 'skins' in [str(p).casefold() for p in path] and key in ('skin','border','scale','radius','shape','mask')
  return False
 def walk(v,path):
  if not isinstance(v,dict):return
  for k,value in v.items():
   if k in ('profileKeys','SCMDataBase'):continue
   pp=path+[k]
   if match(k,path):nodes.append({'path':pp,'pathKeyTypes':[type(x).__name__ for x in pp],'valueLuaTyped':typed(value),'sourceSpan':spans.get('/'.join(map(str,pp)))});continue
   walk(value,pp)
 walk(data,[])
 for node in nodes:
  v=data
  for key in node['path']:v=v[key]
  assert dec(node['valueLuaTyped'])==v
 focus.append({'sourceID':rec['id'],'variantLiteral':rec['variantLiteral'],'sourceSuffix':rec['sourceSuffix'],'SHA256':rec['SHA256'],'selectedInventory':rec['selectedInventory'],'selectedInventoryIndex0':rec['selectedInventoryIndex0'],'nodes':nodes,'explicitRowsNodes':sum(str(x['path'][-1]).casefold()=='rows' for x in nodes) if name=='Bartender3' else None,'explicitButtonsNodes':sum(str(x['path'][-1]).casefold()=='buttons' for x in nodes) if name=='Bartender3' else None,'notes':'Only actualrequestedkeyname matches. Missing savedvariable field is not a default/runtime value claim; initializer code meaning remains A1. No roster/maps published.'})
save(O/'x2-requested-style-values.json',{'scope':'Requested panel names/border/background/mouse/geometry nodes; BT3 explicitRows/Buttons; cyCircled skin; simpleMinimap skins namespace explicitvalues. Fourvariants remain separate. SisterChatMods parseddata retained filteredcompact but no unrelated field in this focused query.','sources':focus,'rawIgnoredTypedCache':str(raw),'noSourceExecution':True,'wholeArchiveGate':'BLOCKED4217/unsafe288 unchanged'})
# Final wholeactualoutput/self-check, no archive integrity or network repetition.
subset=json.loads((O/'X2_SUBSET_READY.json').read_text(encoding='utf-8'));inventory=json.loads((O/'selected-member-inventory.json').read_text(encoding='utf-8'));assert subset['state']=='subset-only-passed' and len(inventory)==46 and all(Path(e['actualPath']).is_file() for e in inventory);assert len(d['sources'])==20 and set(d['deliveryContract']['variantNamesAreLiteralNotMerged'])=={'SPECIAL','SPECIALW','STANDARD','STANDARDW'};assert d['deliveryContract']['excludedEntries']==90
p=json.loads((P/'selected-new-literal-settings-compact.json').read_text(encoding='utf-8'));assert len(p['sources'])==8 and sum(r['state']=='not-literal-or-parser-boundary' for r in p['results'])==3
for source in p['sources']+d['sources']:
 def check(v):
  if isinstance(v,dict):
   assert 'profileKeys' not in v and 'SCMDataBase' not in v
   for x in v.values():check(x)
 check(source['settings'])
copies=json.loads((P/'preserved-original-copies.json').read_text(encoding='utf-8'));assert len(copies)==3 and all(e['byteHashEqual'] and Path(e['preservedPath']).is_file() for e in copies)
legacy=json.loads((R/'Codex/results/old-reference/acquisition/r36/legacy-prefix-fallback/legacy-prefix-results.json').read_text(encoding='utf-8'));assert len(legacy['results'])==1 and legacy['results'][0]['preservedCopy']['equal'];assert Path(legacy['results'][0]['preservedCopy']['path']).is_file();proof=json.loads((P/'rar-header-count-reconciliation.json').read_text(encoding='utf-8'));assert proof['physicalRARFileHeaderRecords']==3167 and proof['uniqueRawFilenameByteStrings']==3166
ready={'state':'mechanical-selected-package-bundle-complete-with-explicit-limits','downloadAndDurableCopyReceipts':str(P/'preserved-original-copies.json'),'legacyX2DownloadAndDurableCopy':str(R/'Codex/results/old-reference/acquisition/r36/legacy-prefix-fallback/legacy-prefix-results.json'),'otherPackageExtraction':str(P/'static-extraction-summary.json'),'RARHeaderProof':str(P/'rar-header-count-reconciliation.json'),'new8FilteredLiteralData':str(P/'selected-new-literal-settings-compact.json'),'new8Exclusions':str(P/'selected-new-literal-exclusions.json'),'V42BorderByteComparison':str(P/'v42-border-exact-byte-comparison.json'),'V42ParserBoundaries':[{'sourceID':x['id'],'sourceLines':x.get('sourceLines'),'error':x.get('error')} for x in p['results'] if x['state']=='not-literal-or-parser-boundary'],'X2Subset':str(O/'X2_SUBSET_READY.json'),'X2Actual46Inventory':str(O/'selected-member-inventory.json'),'X2Full20ParseProof':str(O/'x2-selected-literal-parse-overview.json'),'X2Filtered20Data':str(O/'x2-four-variant-settings-compact.json'),'X2Exclusions':str(O/'x2-four-variant-exclusions.json'),'X2RequestedStyleQuery':str(O/'x2-requested-style-values.json'),'X2Selected8AssetHeaders':str(O/'selected-asset-byte-headers.json'),'counts':{'durablyPreservedNewArchiveFiles':4,'idx1932ExtractedFiles':2407,'idx3461SFXExtractedFiles':2936,'X2WholeListedFiles':4217,'X2WholeUnsafeNames':288,'X2SelectedSubsetExtractedFiles':46,'X2SelectedLuaParsed':20,'otherNewLuaParsed':8,'V42WholeSourceParserBoundaries':3,'missingRequested1932kgPanelsName':1,'X2ExcludedRosterEntries':90,'otherNewExcludedIdentityEntries':326},'wholeX2Extraction':'BLOCKED unchanged; only exact46subset PASS','newIntegrityTestsDuringSubsetAndDataWork':0,'noFurtherPackagesOrProbes':True,'sourceLuaOrEXEExecution':False,'imageContentObservation':False,'selfCheck':'Actualsource/copyreceipt states+existingcopyfiles, exact46existence/no-extra gate, actual28filteredparsed source keycontainer absence, variantset/counts, retainedsubset roundtrips in perstagegates, exactRARheadercountproof reconciled. No old passedCRC or download rerun.'};save(R/'Codex/results/old-reference/acquisition/r36/R36_FINAL_MECHANICAL_RECEIPT.json',ready)
with L.open('a',encoding='utf-8') as f:f.write('\nFinalrequestedstylequery actual20sources onlyselectedpanel/barRowsButtons/skin/minimapnamespace key matches, eachnodevalue exactlysource data andspans, no defaults inferred. All4variant BT3explicitButtons absence/presence reported as actualnodecount only; A1owns initializer/defaultmeaning. Actualbundle finalselfcheck PASS per R36_FINAL_MECHANICAL_RECEIPT.json,28filteredliteral sources(no profileKeys/SCMDataBase), parsed20subset+8other,3V42whole-sourceboundaries explicit,4newdurablebinarycopies exist/hashreceipts equal, source/extraction/identity exclusions differentiated. No furtherpackages/probes/archiveintegritytests; X2whole4217/288 blocked, exact46subsetpassed. Command python -X utf8 '+str(R/'work/old-reference-r36-13d5mmwk/final-r36-data-query.py')+' exit0. Return to A1finalStep3gate; no analysis or masterrecord edits.\n')
print(str(R/'Codex/results/old-reference/acquisition/r36/R36_FINAL_MECHANICAL_RECEIPT.json'));print('STYLE_ROWS',[(x['sourceID'],len(x['nodes'])) for x in focus if x['nodes']])
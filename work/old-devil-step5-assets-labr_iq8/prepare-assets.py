import tempfile,json,hashlib,sys,platform,stat,datetime,shutil
from pathlib import Path
from PIL import Image,ImageFont,__version__ as pillow_version
from fontTools.ttLib import TTFont
import fontTools
r=Path('D:/Projects/Project_WF');out=r/'Codex/results/old-devil-layout/asset-preparation';handoff=r/'Codex/results/handoffs/old-reference/acquisition-step5';scratch=Path(tempfile.mkdtemp(prefix='old-devil-step5-assets-',dir=r/'work'))
assert not (out/'asset-inventory.json').exists() and not (out/'READY.json').exists() and not (handoff/'work_log.md').exists()
out.mkdir(parents=True,exist_ok=True);(out/'png').mkdir(exist_ok=True);(out/'original-fonts').mkdir(exist_ok=True)
roots=[r/'work/old-reference-r36-z41s_asv/selected-extracted/$HWNDPARENT/Interface/addons/Devil',r/'work/old-reference-r36-z41s_asv/selected-extracted/$HWNDPARENT/Interface/addons/SharedMedia/border',r/'work/old-reference-collection-0qlzzyxg/extracted-alpha-nsis/Interface/addons/!DevilUI/media',r/'work/old-reference-collection-0qlzzyxg/extracted-alpha-nsis/Interface/addons/Masque_Onyx',r/'work/old-reference-collection-0qlzzyxg/extracted-alpha-nsis/Fonts']
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def save(p,d):
 with p.open('x',encoding='utf-8') as f:json.dump(d,f,ensure_ascii=False,indent=2)
reads=[('D:/Projects/AGENTS.md',80),('C:/Users/USER/.codex/AGENTS.md',153),('C:/Users/USER/.agents/skills/skill_LKS_original_file-reading/SKILL.md',20),('C:/Users/USER/.agents/skills/skill_LKS_original_file-reading/references/policies/feedback_full_file_read_required.md',57),('C:/Users/USER/.agents/skills/skill_LKS_original_project-scaffold/references/policies/feedback_workspace_git_safety.md',None),('C:/Users/USER/.agents/skills/skill_LKS_original_change-control/references/policies/feedback_change_impact_analysis.md',None),('C:/Users/USER/.agents/skills/skill_LKS_original_multi-session-orchestration/SKILL.md',None),('C:/Users/USER/.agents/skills/skill_LKS_original_multi-session-orchestration/references/policies/feedback_session_division.md',None),('C:/Users/USER/.agents/skills/skill_LKS_original_multi-session-orchestration/references/model_effort_sample.md',None),('C:/Users/USER/.agents/skills/skill_LKS_original_communication-decisions/references/policies/feedback_flow_interruption.md',None),('C:/Users/USER/.agents/skills/skill_LKS_original_communication-decisions/references/policies/feedback_confirmed_items_policy.md',62),(str(handoff/'brief.md'),None)]
log=handoff/'work_log.md'
with log.open('x',encoding='utf-8') as f:
 f.write('# Step5 closed asset mechanical work log\n1 SAME A4 configured gpt-6.1-sol/low; runtime unobserved. 2 Own NEW asset-preparation and this log; shared tree, root Git/A1 design/reader appearance/A2 layout renderer. 3 Only exactfive roots inventory/PNG derivatives/font copies/metrics, no network/archive/CRC/source execution/install/private/game/cleanup/agents. 4 No appearance/runtime/license/koKR coverage claim from font bbox. 5 Required rules/brief read before work, no master6check.\nHelper3questions: judgment not required; accessory result; machine-verifiable. Four boundaries: lowerrole/closedmechanicaltarget/costonly/disjointwrites.\n')
 for p,n in reads:f.write('Read '+p+':1-'+str(n or len(Path(p).read_text(encoding='utf-8').splitlines()))+'; prior current-thread reads retained where no compaction. Orchestration output missingmiddle recovered106-141/136-196; sessiondivision middle31-59 recovered; flow15-31 recovered.\n')
 f.write('| Place | Type/search | Impact | Reason |\n|---|---|---|---|\n| Exactfive roots | producers, literal paths enumerated | read only | original byte identity |\n| New inventory/PNG/font metrics | consumers A1/reader/A2 | create only | mechanical accessory data |\n| Frozen R36/Step4 and prior catalogs | prior records/twins/locked gates | no writes | independent source data; no gate replay |\n| Calls/tests | own new script→installed Pillow/fontTools/hashlib | no source calls | no payload execution; selfcheck pixel/count/hash equality |\n')
rows=[];derivatives={};fonts=[];failures=[];before={};rootfacts=[];texts=['대화창 체력 마나 설정','1 2 3 4 Q E R F C-S-1']
for rootid,root in enumerate(roots,1):
 assert root.is_dir();files=sorted(p for p in root.rglob('*') if p.is_file());rootfacts.append({'rootID':rootid,'path':str(root),'filesEnumerated':len(files)})
 for p in files:
  assert not p.is_symlink() and not p.stat().st_file_attributes&stat.FILE_ATTRIBUTE_REPARSE_POINT
  digest=sha(p);before[str(p)]=digest;suffix=p.suffix.lower();row={'rootID':rootid,'sourcePath':str(p),'relativePath':p.relative_to(root).as_posix(),'bytes':p.stat().st_size,'SHA256before':digest,'suffix':suffix,'kind':'path-hash-metadata-only'}
  if suffix in ('.tga','.blp','.png'):
   row['kind']='image'
   try:
    with Image.open(p) as im:
     im.load();rgba=im.convert('RGBA');rawhash=hashlib.sha256(rgba.tobytes()).hexdigest().upper();row['image']={'PillowFormat':im.format,'mode':im.mode,'dimensions':list(im.size),'extrema':im.getextrema(),'alphaBBox':rgba.getchannel('A').getbbox(),'alphaExtrema':rgba.getchannel('A').getextrema(),'normalizedPixelMode':'RGBA','RGBApixelsSHA256':rawhash}
     if digest not in derivatives:
      derivative=out/'png'/(digest+'.png');assert not derivative.exists();rgba.save(derivative,format='PNG');derivatives[digest]={'sourceSHA256':digest,'path':str(derivative),'SHA256':sha(derivative),'bytes':derivative.stat().st_size,'dimensions':list(rgba.size),'RGBApixelsSHA256':rawhash,'sourcePaths':[],'conversion':'Pillow decoded pixels→RGBA PNG; no resize/crop/repaint'}
     derivatives[digest]['sourcePaths'].append(str(p));row['derivativePath']=derivatives[digest]['path']
   except Exception as e:row['imageFailure']=repr(e);failures.append({'sourcePath':str(p),'stage':'decode/PNG','error':repr(e)})
  elif suffix in ('.ttf','.otf'):
   row['kind']='font';copy=out/'original-fonts'/('root'+str(rootid)+'-'+p.name)
   if copy.exists():assert sha(copy)==digest
   else:
    with p.open('rb') as src,copy.open('xb') as dst:shutil.copyfileobj(src,dst)
   entry={'sourcePath':str(p),'copyPath':str(copy),'sourceSHA256':digest,'copySHA256':sha(copy),'copyEqual':sha(copy)==digest,'bytes':p.stat().st_size,'metrics':[],'coverageBasis':'fontTools Unicode cmap membership for exact requested text only; no global koKR/rendering claim'}
   try:
    with TTFont(str(p),lazy=True) as ft:
     cmap=ft.getBestCmap() or {};entry['unicodeCmapCount']=len(cmap);entry['requestedGlyphCoverage']=[{'text':t,'codepoints':[{'char':c,'codepoint':'U+'+format(ord(c),'04X'),'glyphName':cmap.get(ord(c)),'present':ord(c) in cmap} for c in dict.fromkeys(t)]} for t in texts]
    for size in [22,24,26,28,30]:
     font=ImageFont.truetype(str(p),size=size);entry['metrics'].append({'sizePx':size,'familyStyle':list(font.getname()),'textBBoxes':[{'text':t,'bbox':list(font.getbbox(t)),'advance':font.getlength(t)} for t in texts]})
   except Exception as e:entry['fontFailure']=repr(e);failures.append({'sourcePath':str(p),'stage':'font metadata/metrics','error':repr(e)})
   fonts.append(entry)
  elif suffix in ('.toc','.lua'):row['kind']='skin-load-source-path-metadata-only'
  row['SHA256after']=sha(p);row['sourceUnchanged']=row['SHA256after']==digest;rows.append(row)
# One mechanical self-check; no source parser, source execution, or archive gate replay.
checks={'sourceUnchanged':all(x['sourceUnchanged'] for x in rows),'fontCopiesEqual':all(x['copyEqual'] for x in fonts),'allFiveRootsEnumerated':len(rootfacts)==5,'derivativePixelsEqual':True,'derivativeSourcesComplete':sum(len(x['sourcePaths']) for x in derivatives.values())==sum('derivativePath' in x for x in rows)}
for x in derivatives.values():
 with Image.open(x['path']) as im:im.load();checks['derivativePixelsEqual'] &= list(im.size)==x['dimensions'] and hashlib.sha256(im.convert('RGBA').tobytes()).hexdigest().upper()==x['RGBApixelsSHA256']
assert all(checks.values())
manifest={'schema':'asset-preparation-v1','actualUTC':datetime.datetime.now(datetime.timezone.utc).isoformat(),'toolVersions':{'Python':platform.python_version(),'Pillow':pillow_version,'fontTools':fontTools.__version__},'roots':rootfacts,'sourceRows':rows,'uniqueHashes':sorted(set(x['SHA256before'] for x in rows)),'derivatives':list(derivatives.values()),'fonts':fonts,'failures':failures,'sourceBeforeAfterHashesEqual':checks['sourceUnchanged'],'selfCheck':{'runs':1,'checks':checks,'state':'passed'},'limits':['No appearance observation or full layout render','No runtime/license claim','Font cmap membership is limited to supplied test strings; bbox alone is not glyph coverage'],'scratchRoot':str(scratch)}
save(out/'asset-inventory.json',manifest)
ready={'state':'READY','manifest':str(out/'asset-inventory.json'),'manifestSHA256':sha(out/'asset-inventory.json'),'sourceRows':len(rows),'imageRows':sum(x['kind']=='image' for x in rows),'derivatives':len(derivatives),'fontRows':len(fonts),'uniqueSourceHashes':len(manifest['uniqueHashes']),'failures':len(failures),'executionState':'completed mechanical inventory/PNG/font metrics','selfCheckRuns':1,'selfCheckState':'passed','visualPASS':False,'fullLayoutRender':False,'PNGroot':str(out/'png'),'fontCopyRoot':str(out/'original-fonts')}
save(out/'READY.json',ready)
with log.open('a',encoding='utf-8') as f:f.write('Execution command: python -X utf8 <fresh scratch>/prepare-assets.py (accessory script saved in fresh scratch; no payload execution). Result rc0: '+json.dumps(ready,ensure_ascii=False)+'\nOne selfcheck: '+json.dumps(checks)+'; original sources unchanged, no network/CRC/extract. Stop writes.\n')
print(json.dumps(ready,ensure_ascii=False,indent=2));print('LOG',str(log),'SHA256',sha(log));print('READY_SHA256',sha(out/'READY.json'))

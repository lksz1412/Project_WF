import pathlib,json,sys,tempfile,shutil,re
sys.stdout.reconfigure(encoding='utf-8');r=pathlib.Path(r'D:\Projects\Project_WF');o=r/'Codex/results/source-analysis';back=pathlib.Path(tempfile.mkdtemp(prefix='source-analysis-record-backup-',dir=r/'work'))
p=o/'read-coverage.md';s=p.read_text(encoding='utf-8');shutil.copy2(p,back/p.name);s=s.replace('Reflux1–567','Reflux1–549').replace('Other17bundled profiles','The remaining10 of17existing bundled profiles').replace('Own work_log1–22 read during recovery and current output check.','Own work_log1–22 was read after creation; no own log existed at recovery entry.');p.write_text(s,encoding='utf-8')
p=o/'source-map.md';s=p.read_text(encoding='utf-8');shutil.copy2(p,back/p.name)
for old,new in [('nibProfileLoader.lua','nibProfileLoader/nibProfileLoader.lua'),('Devilconfig.lua','Devilconfig/Devilconfig.lua'),('Reflux.lua','Reflux/Reflux.lua'),('!DevilUI.toc','!DevilUI/!DevilUI.toc'),('load_Profile.xml','!DevilUI/load_Profile.xml'),('Profile/','!DevilUI/Profile/'),('Dominos.lua','Dominos/Dominos.lua'),('core/bindableButton.lua','Dominos/core/bindableButton.lua'),('SexyMap.lua232','SexyMap/SexyMap.lua232'),('kgPanels.lua365','kgPanels/kgPanels.lua365'),('Quartz.lua60','Quartz/Quartz.lua60'),('!DevilUI.lua34','!DevilUI/!DevilUI.lua34'),('minimap.lua7','!DevilUI/minimap.lua7'),('Quartz.toc6','Quartz/Quartz.toc6'),('SexyMap.toc19','SexyMap/SexyMap.toc19'),('kgPanels.toc9','kgPanels/kgPanels.toc9')]:s=s.replace(old,new)
# Correct path expansion only; base-relative Profile/Dominos became !DevilUI/Profile/Dominos/Dominos, avoid that unintended substring substitution.
s=s.replace('!DevilUI/Profile/Dominos/Dominos.lua','!DevilUI/Profile/Dominos.lua');p.write_text(s,encoding='utf-8')
for n in ('archive-inventory.json','profile-extract.json','layout-evidence.json','analysis-gates.json','acquisition.json'):
 d=json.loads((o/n).read_text(encoding='utf-8-sig'));assert d;print('JSON_OK',n)
e=json.loads((o/'layout-evidence.json').read_text(encoding='utf-8'));assert len(e['records'])==33
for x in e['records']:
 p=r/x['source'];ls=p.read_text(encoding='utf-8-sig').splitlines();lo,hi=x['lines'];assert 1<=lo<=hi<=len(ls)
print('EVIDENCE_SPANS_OK',len(e['records']))
report=r/'Codex/docs/original-source-analysis.md';s=report.read_text(encoding='utf-8-sig')
for word in ('수권','사소차','정본','문면','문안','전량','얕은 병합','발동'):assert word not in s,word
# Only explicit path-bearing citations are checked; bare numbers in the report refer to their surrounding source.
checks=[]
for path,lo,hi in re.findall(r'`([^`\s]+\.(?:lua|xml|toc)):(\d+)[–-](\d+)(?:[^`]*)`',s):
 p=r/'SourceArchive/2022-11-19/extracted/Interface/addons'/path
 assert p.is_file(),str(p);assert int(hi)<=len(p.read_text(encoding='utf-8-sig').splitlines()),(path,hi);checks.append(path)
print('REPORT_PATH_RANGE_OK',len(checks))
for n in ('source-map.md','read-coverage.md'):
 p=o/n;assert p.is_file() and p.stat().st_size>0
print('STATIC_OUTPUTS_OK; runtime_NOT_TESTED; independent_review_PENDING; no_source_execution')
print('LOCAL_BACKUP',back)

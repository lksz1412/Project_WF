import json,pathlib,sys
sys.stdout.reconfigure(encoding='utf-8')
p=pathlib.Path(r'D:\Projects\Project_WF\work\source-analysis-data-vbibwfzc\all-literal-profile-data.json')
a=json.loads(p.read_text(encoding='utf-8'))
for addon in ('Dominos','PitBull4','kgPanels','SexyMap','Masque','ChocolateBar'):
    root=list(a[addon]['data'])[0];d=a[addon]['data'][root]
    loaf=d.get('loaf') if addon=='SexyMap' else d['profiles']['loaf']
    print('\nADDON',addon,'LOAF',json.dumps(loaf,ensure_ascii=False,indent=2) if addon in ('PitBull4','SexyMap','Masque') else '')
    if addon=='Dominos':
        print('FRAMES',json.dumps(loaf['frames'],ensure_ascii=False,indent=2));print('AB',loaf['ab'])
    if addon=='kgPanels':
        print('LOAF_LAYOUT',loaf);g=d['global'];print('GLOBAL_KEYS',list(g));print('LAYOUT_NAMES',list(g.get('layouts',{})))
        target=g.get('layouts',{}).get(loaf['layout']);print('LAYOUT_DATA',json.dumps(target,ensure_ascii=False,indent=2));print('BACKGROUND',json.dumps(g.get('backgrounds'),ensure_ascii=False))
    if addon=='ChocolateBar':print('FONT',loaf.get('fontPath'),loaf.get('fontSize'));print('BAR_SETTINGS',json.dumps(loaf.get('barSettings'),ensure_ascii=False,indent=2));print('DUPS',a[addon]['duplicates'])

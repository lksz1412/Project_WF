import subprocess,json,sys,hashlib
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8')
C=Path('D:/Projects/Project_WF/work/old-reference-r36-13d5mmwk');O=Path('D:/Projects/Project_WF/Codex/results/old-reference/acquisition/r36/other-posts');bz='C:/Program Files/Bandizip/bz.exe';out=[]
for label,p in [('idx1932-rar',C/'downloads/devilbecustom91.part1.rar'),('idx3461-sfx',C/'extracted-idx-3461/Black Edition2_6.1 Alpha.exe')]:
 for operation,args in [('list',['l','-list:v','-consolemode:utf8']),('integrity',['t','-consolemode:utf8'])]:
  cmd=[bz]+args+[str(p)];r={'label':label,'operation':operation,'command':cmd,'sourceExecuted':False}
  try:
   cp=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,stdin=subprocess.DEVNULL,timeout=45);r['exitCode']=cp.returncode;r['stdoutPath']=str(C/(label+'-'+operation+'-stdout.txt'));r['stderrPath']=str(C/(label+'-'+operation+'-stderr.txt'));Path(r['stdoutPath']).write_bytes(cp.stdout);Path(r['stderrPath']).write_bytes(cp.stderr);print(label,operation,cp.returncode,cp.stdout.decode('utf-8-sig',errors='replace')[:160],flush=True)
  except subprocess.TimeoutExpired as e:r.update(state='timeout-stopped-no-input',timeoutSeconds=45);print(label,operation,'timeout',flush=True)
  out.append(r)
(O/'static-list-integrity-commands.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
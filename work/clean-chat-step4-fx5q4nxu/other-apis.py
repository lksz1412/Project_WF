import sys,json
sys.path.insert(0,'D:/Projects/Project_WF/work/clean-chat-step4-fx5q4nxu')
from helpers import *
log('Recovery fullreads: brief1-21; own log1-end; D Projects AGENTS1-80; global AGENTS1-153 (middle recovered46-96); prepared1-42; controls1-end; detail1-258 (middle146-221 recovered); ledger1-27; source-research1-155; windows1-73; reading1-20; full-file policy1-57; pipeline1-114; confirmed1-62; helpers and bcm-first1-end; impact1-end(tail recovered53-end); git-safety1-end. Passed BCM GET/CRC retained. No R36 writes.')
for label,repo in [('prat','Legacy-of-Sylvanaar/prat-3-0'),('glass','NelsonAbrantes/Glass-Forever'),('chatty','TheMouseNest/Chattynator')]:
 receipts=[]
 for kind,suffix in [('repo',''),('releases','/releases?per_page=5'),('tags','/tags?per_page=12')]:
  receipts.append(fetch('https://api.github.com/repos/'+repo+suffix,C/(label+'-'+kind+'.json'),'API endpoint derived from literal official CF linked GitHub repository'))
 save(O/(label+'-api-receipts.json'),receipts)
 print(label,[(r.get('HTTP'),r['localpath']) for r in receipts])

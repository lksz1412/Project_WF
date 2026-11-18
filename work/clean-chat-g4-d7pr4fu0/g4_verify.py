from pathlib import Path
import json,hashlib
from datetime import datetime
b=Path("D:/Projects/Project_WF"); out=b/"Codex/results/old-reference"
def read(n): return json.loads((out/n).read_text(encoding="utf-8"))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest().upper()
cov=read("clean-chat-code-read-coverage.json"); assert len(cov["files"])==46
for r in cov["files"]:
 p=Path(r["path"]); assert sha(p)==r["SHA256"]; assert len(p.read_text(encoding="utf-8-sig").splitlines())==r["lines"]; assert r["readFull"] and r["readRanges"]==[[1,r["lines"]]]; assert not r["sourceExecuted"]
req=read("clean-chat-requirements.json"); matrix=read("clean-chat-requirement-matrix.json"); assert len(req["requirements"])==len(matrix["rows"])==12
assert [r["id"] for r in req["requirements"]]==[r["id"] for r in matrix["rows"]]
for r in matrix["rows"]:
 assert set(r["cells"])=={"bcm","prat","glass","chatty"}
 for c in r["cells"].values(): assert c["state"] in req["allowedCellStates"] and c["evidence"] and c["findingAndLimit"] and c["runtime"]=="NOT_RUN"
runtime=read("clean-chat-runtime-gates.json"); assert len(runtime["gates"])==10 and all(x["actualResult"]=="NOT_RUN" for x in runtime["gates"])
cur=read("clean-chat-acquisition/CURRENT_ACQUISITION.json"); assert len(cur["products"])==4
assert {x["fileID"] for x in cur["products"]}=={9632459,9509040,9653501,9648836}
assert all(x["flavorLiteral"]=="Forever" and x["supportedVersionLiteral"]=="1.60.1" for x in cur["products"])
assert sum(x["sourceState"]=="acquired-static" for x in cur["products"])==3
assert [x["label"] for x in cur["products"] if x["sourceState"]!="acquired-static"]==["chatty"]
freeze=read("clean-chat-acquisition/FILES_FROZEN.json"); assert len(freeze["files"])==26
for r in freeze["files"]:
 p=Path(r["path"]); assert p.stat().st_size==r["bytes"] and sha(p)==r["SHA256"]
preservation=read("clean-chat-public-original-copies.json"); assert len(preservation["copies"])==3 and all(x["sourceCopyEqual"] for x in preservation["copies"])
assert preservation["CRC_GET_extractionRuns"]==0 and preservation["priorFrozen26AndManifestUnchanged"]
cdn=read("chatty-cdn-followup.json"); assert cdn["state"]=="bounded-unavailable" and cdn["newDownloadGETs"]==0
# Short literal pins cited by final source units; sources are data, never executed.
roots={"BCM":b/"work/clean-chat-step4-fx5q4nxu/extracted-bcm-v12.1.2-release/BasicChatMods","PRAT":b/"work/clean-chat-step4-fx5q4nxu/extracted-prat-3.9.117-release/Prat-3.0","GLASS":b/"work/clean-chat-step4-fx5q4nxu/extracted-glass-v1.1.6-source/NelsonAbrantes-Glass-Forever-b1c9309"}
probes=[("BCM","history.lua",6,6,"if bcmDB.BCM_History then"),("BCM","history.lua",61,61,"if true then"),("BCM","BasicCore.lua",129,130,"eB:SetAltArrowKeyMode(false)"),("BCM","editbox.lua",10,10,"chatStyle"),("PRAT","addon/addon.lua",74,74,"Prat.IsForever = WOW_PROJECT_ID"),("PRAT","addon/addon.lua",411,448,"RawHook"),("PRAT","modules/ChatTabs.lua",391,399,"displaymode"),("PRAT","modules/Editbox.lua",486,516,"SetBackdrop"),("PRAT","modules/Font.lua",262,281,"FCF_SetChatWindowFontSize"),("PRAT","modules/ChatFrames.lua",322,327,"SetResizeBounds"),("GLASS","Glass/Modules/UIManager.lua",560,568,"CreateSlidingMessageFramePool"),("GLASS","Glass/Modules/UIManager.lua",1042,1051,"HideChatFrame"),("GLASS","Glass/Modules/DefaultTabs.lua",61,81,"RemoveMessageGroup"),("GLASS","Glass/Modules/UIManager.lua",861,868,"chatStyle")]
for product,name,start,end,literal in probes:
 text=(roots[product]/name).read_text(encoding="utf-8-sig").splitlines(); assert literal in "\n".join(text[start-1:end]),(product,name,start,end,literal)
report=b/"Codex/docs/forever-clean-chat-research.md"; text=report.read_text(encoding="utf-8"); assert len(text.splitlines())==116
for word in ["기본 대화창 세 개","48칸","Prat","Glass","Chatty","미검증","미수행","TOC 세 개","독립 검수"]: assert word in text,word
prov=read("clean-chat-provenance.json"); assert len(prov["independentReviewFiles"])==45
artifacts=[report,out/"clean-chat-source-evidence.md",out/"clean-chat-code-read-coverage.json",out/"clean-chat-requirements.json",out/"clean-chat-requirement-matrix.json",out/"clean-chat-runtime-gates.json",out/"clean-chat-provenance.json",out/"clean-chat-public-original-copies.json",out/"chatty-cdn-followup.json",b/"Codex/results/handoffs/old-reference/iter_2/work_log.md",b/"Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md"]
gate={"recorded":datetime.now().astimezone().isoformat(),"state":"A1_READY_WITH_LIMITS_FOR_SAME_B","G4source":"passed-with-explicit-unavailable-and-unverified-boundaries","G4requirements":"48 evidence-classified cells complete; NOT runtime fulfillment","G4outcome":"bounded minimalnative-theme preference/Pratconditionalalternative/source limitations/futurechecks saved","sourceCoverageFiles":46,"officialSelectedFiles":39,"V42SelectedFiles":7,"independentReviewFiles":45,"exactForeverFiles":4,"staticPayloads":3,"unavailablePayloads":1,"frozenHelperRecordsChecked":26,"literalSourcePinsMatched":len(probes),"requirementRows":12,"matrixCells":48,"futureRuntimeGates":10,"runtime":"NOT_RUN","independentB":"PENDING","gameCodeOrInstallOrPrivateInput":False,"newGET_CRC_sourceExecution":0,"limits":["Chatty source/commit unavailable","CF/GitHub binary equality unverified","Leatrix monolithic core excluded; library lazydefinitions not activation proof","Unread vendor/Glass components/Prat extra modules unverified","Exact user filters/typing/3roles/combat/runtime unverified","New theme/current API implementation unverified; no gamecode","No Step5 layout/render on this dispatch"],"artifacts":[{"path":str(p),"lines":len(p.read_text(encoding="utf-8-sig").splitlines()),"bytes":p.stat().st_size,"SHA256":sha(p)} for p in artifacts]}
(out/"a1-step4-gate.json").write_text(json.dumps(gate,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print("G4 exit0: identities4, payloads3/unavailable1, selectedfiles46, frozen26, literalpins14, matrix12x4=48, futuregates10 NOT_RUN; independentB pending")
print("GATE_SHA256",sha(out/"a1-step4-gate.json"))

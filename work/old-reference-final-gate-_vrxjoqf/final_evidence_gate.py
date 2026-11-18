from pathlib import Path
import json, hashlib, re
from datetime import datetime
b=Path(r"D:/Projects/Project_WF")
a=b/"Codex/results/old-reference"
def j(v): return json.loads((a/v).read_text(encoding="utf-8-sig"))
def h(p): return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def pin(p): return {"path":str(p.relative_to(b)),"bytes":p.stat().st_size,"SHA256":h(p)}
freeze_path=a/"acquisition/r36/FILES_FROZEN.json"
freeze=j("acquisition/r36/FILES_FROZEN.json")
assert h(freeze_path)=="65556ABF27652A9B2C034A9713327E11BC04137E9610FBB5EE1019538AC07361"
assert freeze["state"]=="FILES_FROZEN" and len(freeze["artifacts"])==46
for rec in freeze["artifacts"]:
 p=Path(rec["path"])
 assert p.is_file() and p.stat().st_size==rec["bytes"] and h(p)==rec["SHA256"].upper(),str(p)
old=j("a1-step3-gate.json")
assert (old["postsRead"],old["imageReferences"],old["decodedReferences"],old["uniqueObservedHashes"])==(34,58,56,50)
mechanical=j("acquisition/r36/R36_FINAL_MECHANICAL_RECEIPT.json")
assert mechanical["publicSourcePackageCount"]==4 and mechanical["publicSourceFileCount"]==5
assert mechanical["sourceLuaOrEXEExecution"] is False
v=j("acquisition/r36/forever-v42-archive-checks.json")
assert v["extractionState"]=="passed" and v["extractedFileCount"]==1831
other=j("acquisition/r36/other-posts/static-extraction-summary.json")
assert [(x["state"],x["extractedFiles"]) for x in other]==[("passed",2407),("passed",2936)]
x=j("acquisition/r36/x2-selected-subset/X2_SUBSET_READY.json")
assert x["state"]=="subset-only-passed" and x["wholeArchiveState"]=="blocked-unsafe-list"
assert (x["selectedCount"],x["extractedFiles"],x["extractedBytes"])==(46,46,940901)
assert x["unsafeSelected"]==x["missing"]==x["unexpected"]==x["postExtractionReparse"]==[]
assert x["sourceExecuted"] is False and x["usedShell"] is False and x["newIntegrityTestRuns"]==0
code=j("a1-r36-code-read-coverage.json")
assert len(code["files"])==37 and all(r["readFull"] and r["lines"]>0 for r in code["files"])
other_data=j("acquisition/r36/other-posts/selected-new-literal-settings-compact.json")
assert len(other_data["sources"])==8
assert all(r["source"]["state"]=="parsed-fully" and r["source"]["literalTokens"]==r["source"]["consumedTokens"] and not r["source"]["duplicateKeys"] for r in other_data["sources"])
xd=j("acquisition/r36/x2-selected-subset/x2-selected-literal-parse-overview.json")
assert len(xd["results"])==20 and all(r["state"]=="parsed-fully" and r["literalTokens"]==r["consumedTokens"] and not r["duplicateKeys"] for r in xd["results"])
assert len(mechanical["V42ParserBoundaries"])==3
report=b/"Codex/docs/old-devil-reference-comparison.md"
evidence=a/"a1-r36-source-evidence.md"
plan=b/"Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md"
rt=report.read_text(encoding="utf-8-sig");pt=plan.read_text(encoding="utf-8-sig")
expected=["Summary","Current Ground Truth","Phase Range","Non-goals","Implementation Changes","Phase N — Phase 1.3 old reference and clean chat","Implementation Interfaces","Test Plan","Assumptions","Correction History","Decisions Required"]
assert re.findall(r"^## (.+)$",pt,re.M)==expected
assert len(rt.splitlines())==192 and len(evidence.read_text(encoding="utf-8-sig").splitlines())==118
for term in ["idx45의 실제 네 번째 샘플","미터기를 제외한","세 대화창","4K","13140","46개","288개","Step4는 아직 시작하지 않았다","독립 검수 대기","옛 숫자 ID의 일괄 복사","미검증"]: assert term in rt,term
lex=json.loads(Path(r"C:/Users/USER/.codex/tools/banned_lexicon.json").read_text(encoding="utf-8-sig"))
terms=[]
for c in lex["categories"].values():
 for z in c["entries"]:
  if z["status"]=="confirmed": terms += [z["term"]] if "term" in z else z["terms"]
assert not [z for z in terms if z in rt]
pins=[report,evidence,plan,a/"a1-static-source-evidence.md",a/"a1-r36-code-read-coverage.json",a/"a1-article-read-coverage.json",a/"image-observations/findings.md",a/"image-observations/coverage.json",a/"acquisition/r36/FILES_FROZEN.json",a/"acquisition/r36/R36_FINAL_MECHANICAL_RECEIPT.json"]
out={"recorded":datetime.now().astimezone().isoformat(),"scope":"Expanded Phase1.3 Step3 evidence/provenance/selfcheck only; B acceptance pending", "state":"READY_FOR_INDEPENDENT_REVIEW_WITH_BOUNDED_LIMITS", "inheritedPreR36Gate":pin(a/"a1-step3-gate.json"),"upstreamTestsRerun":False,"frozenA4ArtifactCount":46,"frozenA4ActualHashSizeMatches":46,"publicAdditionalPackages":4,"publicAdditionalOriginalFiles":5,"postsRead":34,"imageReferences":58,"decodedReferences":56,"uniqueObservedHashes":50,"unavailableImageReferences":2,"sourceFullReadR36Files":37,"fullyParsedLiteralGroups":{"original":9,"otherAdditional":8,"X2SelectedOnly":20},"V42WholeSourceParserBoundaries":3,"additionalExtractions":[{"source":"V42","files":1831,"bytes":52281213,"wholeExtraction":"passed"},{"source":"1932multipart","files":2407,"bytes":38791956,"wholeExtraction":"passed","listedByteEquality":True},{"source":"3461NSIS","files":2936,"bytes":40624475,"wholeExtraction":"passed","listedByteEquality":None},{"source":"X2NSIS","listedFiles":4217,"toolListedUnsafeNames":288,"wholeExtraction":"BLOCKED","selectedOnlyFiles":46,"selectedOnlyBytes":940901,"selectedExtraction":"passed","listedByteEquality":None}],"sourceOrInstallerExecution":False,"newCRCOrExtractionRunsByA1":0,"independentB":"pending; parent dispatches samePhase ten perspectives once","Step4":"not started; held for parent followup","Step5GameImplementation":"not authorized/not performed","limits":["idx8906 two samples unavailable and unobserved despite original/thumb/Wayback bounded attempts","X2 whole extraction remains blocked; only exact safe46 recovered; unsafe-name origin unverified","V42 three profile data files partially parsed; no final values or wholeprofile totals consumed","same-build/profile/render identity as idx45 sample4 unverified","currentPC native input/filter/combat/runtime and asset redistribution rights unverified","preserve three window roles, not historical numericIDs or channel choices"],"pinnedInputs":[pin(p) for p in pins],"actualCommand":"python -X utf8 "+str(Path(__file__)),"selfCheck":"actual frozen receipt/hash/size identity + current report/plan required clauses + saved parser-proof consistency; no upstream acquisition/image/CRC/parser/source runtime replay"}
gate=a/"a1-step3-expanded-gate.json"
assert not gate.exists(),"new final gate path already exists"
gate.write_text(json.dumps(out,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print("EXPANDED_STEP3_GATE_READY", "frozen46", "code37", "literal9+8+20", "limitsRetained",h(gate))
for p in [report,evidence,plan,gate]: print(json.dumps(pin(p),ensure_ascii=False))

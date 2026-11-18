"""Write Step history, Phase Result (md+json), ledger row and history note for a one-step settings Phase.
Usage: python3 close_settings_phase.py <phase> <step> <title> <json-file-with-fields>
JSON fields: done, basis, files, gates, next, summary, open, dq, cost, validation
"""
import json, sys, subprocess, pathlib
phase, step, title, spec = sys.argv[1], sys.argv[2], sys.argv[3], json.load(open(sys.argv[4], encoding="utf-8"))
root = pathlib.Path("/home/user/Project_WF")
ts = subprocess.run(["date", "+%Y-%m-%d %H:%M:%S %z"], capture_output=True, text=True, env={"TZ": "Asia/Seoul"}).stdout.strip()
(root / f"Claude/results/Step {step} — {title}.md").write_text(
    f"# Step {step} — {title} (Phase {phase})\n\nRecorded: {ts}\n\n## Done\n{spec['done']}\n\n## Basis\n{spec['basis']}\n\n## Files\n{spec['files']}\n\n## Gates\n{spec['gates']}\n\n## Next\n{spec['next']}\n", encoding="utf-8")
items = {"Summary": spec["summary"], "Step Range": f"Step {step}", "Inputs": "마스터 플랜 기능 표 행·judgment.md·manifest·upstream 시작 애드온",
         "Files Created": spec["files"], "Files Updated": "Registry.lua·TOC·설치 ZIP", "Read Coverage": spec["basis"],
         "Execution Evidence": f"Step {step} 이력·work_log 판정 줄", "Validation·Gate·Confirmed": spec["validation"],
         "Non-Changes": "시작 애드온 원본·References·Codex 무변경", "Open Issues": spec["open"], "Decision Queue": spec["dq"], "Next": spec["next"]}
name = f"PHASE_{phase}_{spec.get('slug','settings')}_RESULT"
(root / f"Claude/results/{name}.md").write_text(f"# PHASE {phase} — {title} RESULT\n\n" + "\n\n".join(f"## {k}\n\n{v}" for k, v in items.items()) + "\n", encoding="utf-8")
json.dump(items, open(root / f"Claude/results/{name}.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
with open(root / "Claude/results/PHASE_0-25_EXECUTION_LEDGER.md", "a", encoding="utf-8") as f:
    f.write(f"| {phase} | {step} | {step} | build | {title} | PASS | plan.md + phase{phase}-세부계획.md | {name}.md | {spec['files'].split(',')[0]} | {spec['validation']}; {spec['cost']} | {spec['gates'][:80]} | {int(step)+1} |\n")
with open(root / "Claude/plans/2026-11-18-devil-forever-addon-collection-plan_이력.md", "a", encoding="utf-8") as f:
    f.write(f"\n## Phase {phase} 끝 정리 ({ts})\n\n{spec['summary']} Result = `Claude/results/{name}.md`.\n")
print("closed", phase, step, name)

"""Run the eight review suites against a fresh copy of checked-out AddOns."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
from zipfile import ZipFile, ZIP_DEFLATED


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FIXTURES = HERE / "fixtures"
SUITES = {
    "core": 104,
    "chatsetup": 28,
    "statusstrip": 20,
    "pitbull4": 5,
    "castbars": 16,
    "fufdefaults": 22,
    "detailslayout": None,
    "performance": None,
}
BUILD_ONLY = {
    "core": {
        "genregistry_extra_applied_and_checked": "Registry generator validation is outside the shipped runtime suite.",
        "genregistry_output_matches_file": "Registry regeneration needs the complete upstream build inputs.",
        "genregistry_editable_frame_and_default_checked": "Registry generator validation is outside the shipped runtime suite.",
        "genregistry_t28_restore_options": "Registry generator validation is outside the shipped runtime suite.",
    },
    "pitbull4": {
        "patch_reproduces_the_copy": "Patch reproduction needs the complete original upstream tree and patch utility.",
    },
}
FINAL_MARKERS = {
    "detailslayout": "PASS actual slash->native Details scale/position restore: 6 preset/factor pairs;",
    "performance": "PASS performance regression gates (Lua stub calls only)",
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def write_json(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def prepare(output):
    provenance = json.loads((FIXTURES / "provenance.json").read_text(encoding="utf-8"))
    for record in provenance["files"]:
        data = (FIXTURES / record["path"]).read_bytes()
        if digest(data) != record["sha256"] or len(data) != record["bytes"]:
            raise ValueError("Fixture differs from recorded source: " + record["path"])

    snapshot = output / "snapshot"
    collection = snapshot / "Collection"
    shutil.copytree(ROOT / "Collection/AddOns", collection / "AddOns")
    shutil.copyfile(ROOT / "Collection/install.json", collection / "install.json")
    for suite in SUITES:
        target = collection / "tests" / suite
        target.mkdir(parents=True)
        shutil.copyfile(ROOT / "Collection/tests" / suite / "run.py", target / "run.py")
    shutil.copytree(ROOT / "Collection/tests/core/fixtures", collection / "tests/core/fixtures")

    fuf = collection / "tests/fufdefaults/run.py"
    original = 'os.path.join(REPO, "Collection", "upstream", "Forever_Unit_Frames-0.65.2", "ForeverUnitFrames", "Core")'
    replacement = 'os.path.join(REPO, "Collection", "AddOns", "ForeverUnitFrames", "Core")'
    text = fuf.read_text(encoding="utf-8")
    if text.count(original) != 1:
        raise ValueError("FUF source-path adaptation no longer matches the checked-out test")
    fuf.write_text(text.replace(original, replacement), encoding="utf-8")

    details = snapshot / "References/codex-appearance/10"
    details.mkdir(parents=True)
    for source in (FIXTURES / "details").glob("*.lua"):
        shutil.copyfile(source, details / source.name)

    baseline = output / "performance-baseline-0.1.1.zip"
    with ZipFile(baseline, "x", compression=ZIP_DEFLATED) as archive:
        for record in provenance["files"]:
            if record.get("source") == "DevilForever-0.1.1.zip":
                archive.writestr(record["member"], (FIXTURES / record["path"]).read_bytes())
    sources = []
    for path in sorted((collection / "AddOns").rglob("*")):
        if path.is_file():
            sources.append({"path": path.relative_to(snapshot).as_posix(),
                            "sha256": digest(path.read_bytes()), "bytes": path.stat().st_size})
    write_json(output / "tested-sources.json", sources)
    return snapshot, baseline, provenance


def run_suite(suite, expected, snapshot, baseline, output):
    entry = snapshot / "Collection/tests" / suite / "run.py"
    skipped = BUILD_ONLY.get(suite, {})
    if skipped:
        args = [str(HERE / "invoke_suite.py"), str(entry), json.dumps(sorted(skipped))]
        if suite == "pitbull4":
            args.append(str(FIXTURES / "pitbull4-upstream"))
    else:
        args = [str(entry)]
    if suite == "performance":
        args += ["--dominos-zip", str(baseline)]
    command = [sys.executable, "-B", "-I", "-X", "utf8", *args]
    try:
        result = subprocess.run(command, cwd=snapshot, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, encoding="utf-8", timeout=120)
        stdout, exit_code = result.stdout, result.returncode
    except subprocess.TimeoutExpired as error:
        raw = error.stdout or b""
        stdout = raw.decode("utf-8", "replace") if isinstance(raw, bytes) else raw
        stdout += "\nFAIL suite exceeded 120 seconds\n"
        exit_code = 124
    (output / (suite + ".log")).write_text(stdout, encoding="utf-8")
    match = re.search(r"cases=(\d+) passed=(\d+) failed=(\d+)", stdout)
    actual = tuple(map(int, match.groups())) if match else None
    complete = actual == (expected, expected, 0) if expected is not None else FINAL_MARKERS[suite] in stdout
    evidence = [line for line in stdout.splitlines() if line.startswith(("PASS ", "FAIL ", "Native FUF geometry:"))]
    passed = exit_code == 0 and complete
    print(f"{'PASS' if passed else 'FAIL'} {suite} exit={exit_code} counts={actual}", flush=True)
    return {"suite": suite, "passed": passed, "exit": exit_code, "counts": actual,
            "expectedCases": expected, "excludedBuildCases": skipped,
            "evidence": evidence, "log": suite + ".log"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path,
                        help="New directory outside the checkout. Existing directories are never reused.")
    args = parser.parse_args()
    output = args.output.expanduser().resolve()
    if output == ROOT or ROOT in output.parents:
        parser.error("--output must be outside this checkout")
    if output.exists():
        parser.error("--output already exists; choose a new directory")
    try:
        from lupa import lua51
        import lupa
    except ImportError:
        parser.error("Install the test dependency first: python -m pip install -r Review/0.1.4/tests/requirements.txt")
    lua51.LuaRuntime()
    output.mkdir(parents=True)
    snapshot, baseline, provenance = prepare(output)
    outcomes = [run_suite(suite, expected, snapshot, baseline, output) for suite, expected in SUITES.items()]
    report = {"python": sys.version, "lupa": lupa.__version__,
              "baselineArchive": provenance["baselineArchive"],
              "nativeSources": "Checked-out Collection/AddOns copied unchanged to output/snapshot/Collection/AddOns",
              "scratchTestAdaptations": ["FUF native source path changed to shipped AddOns/ForeverUnitFrames/Core"],
              "suites": outcomes, "passed": all(item["passed"] for item in outcomes)}
    write_json(output / "results.json", report)
    print(f"{'PASS' if report['passed'] else 'FAIL'} suites={sum(item['passed'] for item in outcomes)}/8 expected_counted_cases=195")
    print("Results: " + str(output / "results.json"))
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())

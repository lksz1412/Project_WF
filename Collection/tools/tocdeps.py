"""TOC dependency cross-check for a chosen set of addon folders.

Usage:
  python3 -I Collection/tools/tocdeps.py <dir> [...]          # addon folders or trees holding them
  python3 -I Collection/tools/tocdeps.py --role start [<dir> ...]  # add upstream dirs of manifest packages

For each addon folder the TOC(s) whose ``## Interface`` lists the target
interface (default 16001) are used; when none lists it, the plain
``<Folder>.toc`` is used and the folder is flagged. TOCs restricted away from
Forever by ``## AllowLoadGameType``/``## ExcludeLoadGameType`` are skipped when
another matching TOC exists; folders left with only such TOCs are flagged. Every name in
``Dependencies``/``RequiredDeps`` must be another folder in the set (names are
compared case-insensitively, as the client does). ``Blizzard_*`` names are
client-provided and reported separately. Missing ``OptionalDeps`` are listed
for information only. Exit code 1 when any required dependency is unresolved.
"""

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import toclib  # noqa: E402

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
MANIFEST = os.path.join(REPO, "Collection", "manifest.json")


def manifest_dirs(role):
    with open(MANIFEST, encoding="utf-8") as fh:
        manifest = json.load(fh)
    dirs = []
    for pkg in manifest["packages"]:
        if role in ("all", pkg["role"]) and pkg.get("upstream_dir"):
            dirs.append(os.path.join(REPO, pkg["upstream_dir"]))
    return dirs


def dep_name(dep):
    """Lower-cased folder name of a dependency entry, without ``[condition]`` prefix or suffix."""
    return toclib.split_conditions(dep)[0].strip().lower()


def analyse(roots, interface):
    folders = []
    for root in roots:
        folders.extend(toclib.find_addon_folders(root))
    by_name = {}
    duplicates = []
    for folder in folders:
        key = os.path.basename(folder).lower()
        if key in by_name and os.path.realpath(by_name[key]) != os.path.realpath(folder):
            duplicates.append([by_name[key], folder])
        by_name.setdefault(key, folder)
    report = {"interface": interface, "folders": len(by_name), "duplicates": duplicates,
              "no_interface_toc": [], "forever_load_no": [], "unresolved": [], "client_provided": [],
              "optional_missing": [], "load_on_demand": []}
    for key in sorted(by_name):
        folder = by_name[key]
        name = os.path.basename(folder)
        tocs, status = toclib.tocs_for_interface(folder, interface)
        if status == "no_interface":
            report["no_interface_toc"].append({"folder": name, "used": [n for n, _ in tocs]})
        elif status == "forever_load_no":
            report["forever_load_no"].append({"folder": name, "used": [n for n, _ in tocs],
                                              "game_types": [t["game_types"] for _, t in tocs]})
        for toc_name, toc in tocs:
            for dep in toclib.required_deps(toc):
                if dep_name(dep) in by_name:
                    continue
                item = {"folder": name, "toc": toc_name, "dependency": dep}
                if dep_name(dep).startswith("blizzard_"):
                    report["client_provided"].append(item)
                else:
                    report["unresolved"].append(item)
            for dep in toc.get("OptionalDeps") or []:
                if dep_name(dep) not in by_name:
                    report["optional_missing"].append({"folder": name, "toc": toc_name, "dependency": dep})
            if (toc.get("LoadOnDemand") or "").strip() == "1":
                report["load_on_demand"].append({"folder": name, "toc": toc_name})
    return report


def main():
    parser = argparse.ArgumentParser(description="TOC dependency cross-check")
    parser.add_argument("paths", nargs="*")
    parser.add_argument("--role", choices=["start", "comparison", "all"],
                        help="add the upstream dirs of manifest packages with this role")
    parser.add_argument("--interface", type=int, default=16001)
    parser.add_argument("--json", help="write the full report to this JSON file")
    args = parser.parse_args()
    roots = list(args.paths)
    if args.role:
        roots.extend(manifest_dirs(args.role))
    if not roots:
        parser.error("give addon folders or --role")
    for root in roots:
        if not os.path.isdir(root):
            parser.error("not a directory: %s" % root)
    report = analyse(roots, args.interface)
    for item in report["unresolved"]:
        print("UNRESOLVED %s (%s) needs %s" % (item["folder"], item["toc"], item["dependency"]))
    for item in report["client_provided"]:
        print("CLIENT %s (%s) needs %s" % (item["folder"], item["toc"], item["dependency"]))
    for item in report["no_interface_toc"]:
        print("NO_%d_TOC %s used %s" % (args.interface, item["folder"], ", ".join(item["used"])))
    for item in report["forever_load_no"]:
        print("FOREVER_LOAD_NO %s used %s" % (item["folder"], ", ".join(item["used"])))
    for pair in report["duplicates"]:
        print("DUPLICATE folder name: %s | %s" % (pair[0], pair[1]))
    for item in report["optional_missing"]:
        print("optional-missing %s (%s) -> %s" % (item["folder"], item["toc"], item["dependency"]))
    print("folders=%d unresolved=%d client_provided=%d optional_missing=%d no_interface_toc=%d "
          "forever_load_no=%d duplicates=%d load_on_demand=%d" % (
              report["folders"], len(report["unresolved"]), len(report["client_provided"]),
              len(report["optional_missing"]), len(report["no_interface_toc"]),
              len(report["forever_load_no"]),
              len(report["duplicates"]), len(report["load_on_demand"])))
    if args.json:
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(report, fh, indent=1, ensure_ascii=False)
            fh.write("\n")
    return 1 if report["unresolved"] else 0


if __name__ == "__main__":
    sys.exit(main())

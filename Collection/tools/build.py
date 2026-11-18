"""Build the install ZIP of the collection.

Usage:
  python3 -I Collection/tools/build.py [--select FOLDER ...] [--name NAME] [--out-dir DIR] [--dry-run]

Contents: every folder under ``Collection/AddOns/`` plus the upstream addon
folders named with ``--select`` (looked up in ``Collection/manifest.json``).
Archive layout: ``Interface/AddOns/<folder>/...``. Entries are sorted and carry
a fixed timestamp so the same inputs give the same bytes. A folder name that
appears twice (AddOns and upstream, or two packages) stops the build.
Symlinks in the inputs stop the build. Default output:
``outputs/collection/<NAME>.zip`` (NAME defaults to ``DevilForever-collection``).
"""

import argparse
import json
import os
import sys
import zipfile

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
ADDONS = os.path.join(REPO, "Collection", "AddOns")
MANIFEST = os.path.join(REPO, "Collection", "manifest.json")
DEFAULT_OUT = os.path.join(REPO, "outputs", "collection")
FIXED_TIME = (2026, 1, 1, 0, 0, 0)
SKIP_NAMES = {".gitkeep", ".DS_Store", "Thumbs.db"}


class BuildError(Exception):
    pass


def upstream_index():
    with open(MANIFEST, encoding="utf-8") as fh:
        manifest = json.load(fh)
    index = {}
    for pkg in manifest["packages"]:
        if not pkg.get("upstream_dir"):
            continue
        for addon in pkg.get("addons", []):
            path = os.path.join(REPO, pkg["upstream_dir"], addon["path"])
            index.setdefault(addon["folder"].lower(), []).append((addon["folder"], path, pkg["name"]))
    return index


def collect_sources(selected):
    sources = {}
    if os.path.isdir(ADDONS):
        for name in sorted(os.listdir(ADDONS)):
            full = os.path.join(ADDONS, name)
            if os.path.isdir(full) and name not in SKIP_NAMES:
                sources[name.lower()] = (name, full, "Collection/AddOns")
    if selected:
        index = upstream_index()
        for wanted in selected:
            hits = index.get(wanted.lower(), [])
            if not hits:
                raise BuildError("selected folder not in manifest: %s" % wanted)
            if len(hits) > 1:
                raise BuildError("folder %s exists in several packages: %s" % (
                    wanted, ", ".join(h[2] for h in hits)))
            folder, path, pkg = hits[0]
            if folder.lower() in sources:
                raise BuildError("folder %s given twice (%s and %s)" % (folder, sources[folder.lower()][2], pkg))
            if not os.path.isdir(path):
                raise BuildError("upstream folder missing, run extract.py: %s" % path)
            sources[folder.lower()] = (folder, path, "upstream:" + pkg)
    return [sources[k] for k in sorted(sources)]


def iter_files(folder):
    for dirpath, dirnames, filenames in os.walk(folder):
        dirnames.sort()
        for name in list(dirnames):
            if os.path.islink(os.path.join(dirpath, name)):
                raise BuildError("symlink in input: %s" % os.path.join(dirpath, name))
        for name in sorted(filenames):
            full = os.path.join(dirpath, name)
            if os.path.islink(full):
                raise BuildError("symlink in input: %s" % full)
            if name in SKIP_NAMES or name.startswith(".extract-source"):
                continue
            yield full


def plan_entries(sources):
    entries = []
    for folder, path, origin in sources:
        for full in iter_files(path):
            rel = os.path.relpath(full, path).replace(os.sep, "/")
            entries.append(("Interface/AddOns/%s/%s" % (folder, rel), full))
    entries.sort()
    return entries


def write_zip(entries, out_path):
    tmp_path = out_path + ".partial"
    with zipfile.ZipFile(tmp_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for arcname in ("Interface/", "Interface/AddOns/"):
            info = zipfile.ZipInfo(arcname, FIXED_TIME)
            info.external_attr = (0o40755 << 16) | 0x10
            zf.writestr(info, b"")
        for arcname, full in entries:
            info = zipfile.ZipInfo(arcname, FIXED_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            with open(full, "rb") as fh:
                zf.writestr(info, fh.read())
    os.replace(tmp_path, out_path)


def main():
    parser = argparse.ArgumentParser(description="Build the collection install ZIP")
    parser.add_argument("--select", nargs="*", default=[], help="upstream addon folder names to include")
    parser.add_argument("--name", default="DevilForever-collection")
    parser.add_argument("--out-dir", default=DEFAULT_OUT)
    parser.add_argument("--dry-run", action="store_true", help="list the plan, write nothing")
    args = parser.parse_args()
    try:
        sources = collect_sources(args.select)
        entries = plan_entries(sources)
    except BuildError as exc:
        print("ERROR " + str(exc))
        return 1
    for folder, path, origin in sources:
        print("folder %-28s from %s" % (folder, origin))
    out_path = os.path.join(args.out_dir, args.name + ".zip")
    if args.dry_run:
        print("dry-run folders=%d files=%d target=%s" % (len(sources), len(entries), out_path))
        return 0
    os.makedirs(args.out_dir, exist_ok=True)
    write_zip(entries, out_path)
    with zipfile.ZipFile(out_path) as zf:
        bad = zf.testzip()
        count = len(zf.infolist())
    if bad:
        print("ERROR zip test failed at %s" % bad)
        return 1
    print("built folders=%d files=%d zip_entries=%d -> %s" % (len(sources), len(entries), count, out_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())

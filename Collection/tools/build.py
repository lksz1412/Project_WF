"""Build the collection ZIPs.

Usage:
  python3 -I Collection/tools/build.py [--select FOLDER ...] [--name NAME] [--out-dir DIR] [--dry-run]
  python3 -I Collection/tools/build.py --install [--variant pitbull4|fuf] [--out-dir DIR] [--dry-run]

Verification ZIP (default mode): every folder under ``Collection/AddOns/``
plus the upstream addon folders named with ``--select`` (looked up in
``Collection/manifest.json``). Output ``outputs/collection/<NAME>.zip`` (NAME
defaults to ``DevilForever-collection``).

Install ZIP (``--install``): the folders that ``Collection/install.json`` ships
— its own folders and upstream folders (each looked up in the named manifest
package) plus those of one unit-frame variant (default: install.json
``unit_frames``). Every folder of ``Collection/AddOns/`` must be named in
install.json (in ``own`` or in a variant), so a new folder is not left out
silently. Output ``outputs/collection/<name>-<version>.zip`` (``-<variant>``
added for a variant other than the default); version must equal the Core TOC
``## Version``. Next to ``Interface/`` the archive holds ``DevilForever-install/``
with ``manifest.json`` (per folder: origin, package, version, kind, bundle,
source ZIP and its sha256, licence files, saved variables), the install notes
named by install.json, and ``SHA256SUMS.txt`` (sha256 of every other file of
the archive, paths from the archive root, ``sha256sum -c`` format).

Archive layout: ``Interface/AddOns/<folder>/...``. Entries are sorted and carry
a fixed timestamp so the same inputs give the same bytes. A folder name that
appears twice (AddOns and upstream, or two packages) stops the build.
Symlinks in the inputs stop the build.
"""

import argparse
import hashlib
import json
import os
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import genregistry  # noqa: E402
import toclib  # noqa: E402

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
ADDONS = os.path.join(REPO, "Collection", "AddOns")
MANIFEST = os.path.join(REPO, "Collection", "manifest.json")
INSTALL = os.path.join(REPO, "Collection", "install.json")
CORE_FOLDER = "!DevilForever_Core"
INSTALL_DIR = "DevilForever-install"
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


def load_json(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def install_selection(install, variant):
    """(own folder names, [(package, folder)]) that install.json ships with ``variant``."""
    variants = install.get("unit_frame_variants") or {}
    if variant not in variants:
        raise BuildError("unknown unit-frame variant %s (install.json has %s)" % (variant, ", ".join(sorted(variants))))
    own = list(install.get("own") or []) + list(variants[variant].get("own") or [])
    upstream = []
    for mapping in (install.get("upstream") or {}, variants[variant].get("upstream") or {}):
        for pkg in sorted(mapping):
            upstream.extend((pkg, folder) for folder in mapping[pkg])
    named = set(install.get("own") or [])
    for v in variants.values():
        named.update(v.get("own") or [])
    present = {n for n in os.listdir(ADDONS)
               if os.path.isdir(os.path.join(ADDONS, n)) and n not in SKIP_NAMES} if os.path.isdir(ADDONS) else set()
    for name in sorted(present - named):
        raise BuildError("Collection/AddOns/%s is not named in install.json (own or a unit-frame variant)" % name)
    for name in own:
        if name not in present:
            raise BuildError("install.json own folder missing in Collection/AddOns: %s" % name)
    return own, upstream


def install_sources(own, upstream):
    sources = {}
    for name in own:
        if name.lower() in sources:
            raise BuildError("folder %s given twice" % name)
        sources[name.lower()] = (name, os.path.join(ADDONS, name), "Collection/AddOns")
    index = upstream_index()
    for pkg, wanted in upstream:
        hits = [h for h in index.get(wanted.lower(), []) if h[2] == pkg]
        if not hits:
            raise BuildError("install.json: folder %s not in manifest package %s" % (wanted, pkg))
        folder, path, _pkg = hits[0]
        if folder.lower() in sources:
            raise BuildError("folder %s given twice (%s and %s)" % (folder, sources[folder.lower()][2], pkg))
        if not os.path.isdir(path):
            raise BuildError("upstream folder missing, run extract.py: %s" % path)
        sources[folder.lower()] = (folder, path, "upstream:" + pkg)
    return [sources[k] for k in sorted(sources)]


def core_version():
    tocs, _status = toclib.tocs_for_interface(os.path.join(ADDONS, CORE_FOLDER), 16001)
    return tocs[0][1].get("Version") if tocs else None


def upstream_version(pkg, addon):
    """Version as the source ZIP names it (``Hekili-v0.8.6-forever.zip`` -> ``v0.8.6-forever``).

    The ZIP name must start with the package name (spaces kept, turned into
    ``_`` or left out) and ``-``; otherwise the folder's 16001 TOC
    ``## Version`` is used, then the SOURCE.txt version.
    """
    stem = os.path.basename(pkg["source_zip"])
    stem = stem[:-4] if stem.lower().endswith(".zip") else stem
    name = pkg["name"]
    for prefix in (name, name.replace(" ", "_"), name.replace(" ", "")):
        if stem.lower().startswith(prefix.lower() + "-") and len(stem) > len(prefix) + 1:
            return stem[len(prefix) + 1:]
    for toc in addon.get("tocs") or []:
        if "16001" in [str(i) for i in toc.get("interface") or []] and toc.get("version"):
            return toc["version"].lstrip("#")
    return pkg["version"]


def install_manifest(install, variant, sources):
    """Deterministic install manifest (dict) for the shipped folders."""
    manifest = load_json(MANIFEST)
    packages = {p["name"]: p for p in manifest["packages"]}
    collection = {c["folder"]: c for c in manifest.get("collection") or []}
    registry = genregistry.build()["addons"]
    folders = []
    for folder, _path, origin in sources:
        reg = registry.get(folder)
        if reg is None:
            raise BuildError("shipped folder %s is not in the Core registry (run genregistry.py; "
                             "check install.json and registry_extra.json)" % folder)
        item = {"folder": folder, "bundle": reg.get("bundle"),
                "saved_variables": [{"name": sv["name"], "scope": sv["scope"]} for sv in reg.get("savedVariables") or []]}
        if origin == "Collection/AddOns":
            meta = collection.get(folder)
            if meta is None:
                raise BuildError("own folder %s missing in the manifest collection section" % folder)
            item.update({"origin": "collection", "kind": meta["kind"], "package": reg.get("package"),
                         "version": reg.get("version"), "phases": meta["phases"], "variant": meta.get("variant"),
                         "license_files": meta["license_files"]})
            if meta.get("base"):
                item["base"] = meta["base"]
        else:
            pkg = packages[origin.split(":", 1)[1]]
            addon = next(a for a in pkg["addons"] if a["folder"] == folder)
            item.update({"origin": "upstream", "kind": "unmodified", "package": pkg["name"],
                         "version": upstream_version(pkg, addon), "phases": sorted({f["phase"] for f in pkg["feature_phases"] if f["use"] == "start"}),
                         "source_zip": pkg["source_zip"], "source_sha256": pkg["sha256"],
                         "license_files": addon["license_files"]})
        folders.append({k: v for k, v in sorted(item.items()) if v is not None})
    return {
        "schema": "devil-forever-install-manifest/1",
        "name": install["name"],
        "version": install["version"],
        "interface": manifest.get("target_interface", 16001),
        "unit_frames": variant,
        "generated_by": "Collection/tools/build.py --install",
        "folders": folders,
    }


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


def write_zip(entries, out_path, extra=None, extra_dirs=()):
    """``entries`` = [(arcname, file path)]; ``extra`` = [(arcname, bytes)] written after them."""
    tmp_path = out_path + ".partial"
    with zipfile.ZipFile(tmp_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for arcname in ("Interface/", "Interface/AddOns/") + tuple(extra_dirs):
            info = zipfile.ZipInfo(arcname, FIXED_TIME)
            info.external_attr = (0o40755 << 16) | 0x10
            zf.writestr(info, b"")
        items = [(arcname, None, full) for arcname, full in entries] + [(a, d, None) for a, d in extra or []]
        for arcname, data, full in items:
            info = zipfile.ZipInfo(arcname, FIXED_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            if data is None:
                with open(full, "rb") as fh:
                    data = fh.read()
            zf.writestr(info, data)
    os.replace(tmp_path, out_path)


def install_extra(install, variant, sources, entries):
    """[(arcname, bytes)] of DevilForever-install/: manifest.json, notes, SHA256SUMS.txt (last)."""
    notes_path = os.path.join(REPO, install["notes"])
    if not os.path.isfile(notes_path):
        raise BuildError("install notes missing: %s" % install["notes"])
    manifest_bytes = (json.dumps(install_manifest(install, variant, sources), indent=1, ensure_ascii=False,
                                 sort_keys=True) + "\n").encode("utf-8")
    with open(notes_path, "rb") as fh:
        notes_bytes = fh.read()
    extra = [(INSTALL_DIR + "/manifest.json", manifest_bytes),
             (INSTALL_DIR + "/" + os.path.basename(notes_path), notes_bytes)]
    sums = []
    for arcname, full in entries:
        with open(full, "rb") as fh:
            sums.append((arcname, hashlib.sha256(fh.read()).hexdigest()))
    for arcname, data in extra:
        sums.append((arcname, hashlib.sha256(data).hexdigest()))
    text = "".join("%s  %s\n" % (digest, arcname) for arcname, digest in sorted(sums))
    extra.append((INSTALL_DIR + "/SHA256SUMS.txt", text.encode("utf-8")))
    return extra


def sha256_file(path):
    with open(path, "rb") as fh:
        return hashlib.sha256(fh.read()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description="Build the collection install ZIP")
    parser.add_argument("--select", nargs="*", default=[], help="upstream addon folder names to include")
    parser.add_argument("--name", help="verification ZIP name (default DevilForever-collection)")
    parser.add_argument("--out-dir", default=DEFAULT_OUT)
    parser.add_argument("--dry-run", action="store_true", help="list the plan, write nothing")
    parser.add_argument("--install", action="store_true", help="build the install ZIP from Collection/install.json")
    parser.add_argument("--variant", help="unit-frame variant for --install (default: install.json unit_frames)")
    args = parser.parse_args()
    extra = None
    extra_dirs = ()
    try:
        if args.install:
            if args.select or args.name:
                raise BuildError("--select and --name are not used with --install (install.json names the folders and the ZIP)")
            install = load_json(INSTALL)
            variant = args.variant or install["unit_frames"]
            if install["version"] != core_version():
                raise BuildError("install.json version %s differs from the Core TOC version %s"
                                 % (install["version"], core_version()))
            own, upstream = install_selection(install, variant)
            sources = install_sources(own, upstream)
            entries = plan_entries(sources)
            extra = install_extra(install, variant, sources, entries)
            extra_dirs = (INSTALL_DIR + "/",)
            name = "%s-%s" % (install["name"], install["version"])
            if variant != install["unit_frames"]:
                name += "-" + variant
        else:
            if args.variant:
                raise BuildError("--variant needs --install")
            sources = collect_sources(args.select)
            entries = plan_entries(sources)
            name = args.name or "DevilForever-collection"
    except BuildError as exc:
        print("ERROR " + str(exc))
        return 1
    for folder, path, origin in sources:
        print("folder %-28s from %s" % (folder, origin))
    out_path = os.path.join(args.out_dir, name + ".zip")
    if args.dry_run:
        print("dry-run folders=%d files=%d target=%s" % (len(sources), len(entries) + len(extra or []), out_path))
        return 0
    os.makedirs(args.out_dir, exist_ok=True)
    write_zip(entries, out_path, extra, extra_dirs)
    with zipfile.ZipFile(out_path) as zf:
        bad = zf.testzip()
        count = len(zf.infolist())
    if bad:
        print("ERROR zip test failed at %s" % bad)
        return 1
    print("built folders=%d files=%d zip_entries=%d sha256=%s -> %s" % (
        len(sources), len(entries) + len(extra or []), count, sha256_file(out_path), out_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())

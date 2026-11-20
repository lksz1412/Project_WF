"""Build the release ZIPs.

Usage:
  python3 -I Collection/tools/build.py [--install] [--variant pitbull4|fuf|one-session] [--out-dir DIR]
                                       [--dry-run] [--list-excluded]

The one build path: the folders that ``Collection/install.json`` ships — its
own folders and upstream folders, plus those of one unit-frame variant
(default: install.json ``unit_frames``) — all taken from ``Collection/AddOns/``
(``--install`` is accepted and means the same). Every folder of
``Collection/AddOns/`` must be named in install.json (own or upstream, base or
a variant), so a new folder is not left out silently. Each upstream folder must
be a manifest ``third_party`` folder of the package install.json names, and
before writing, ``patches.py verify`` must pass (unmodified folders equal the
extracted originals, patched folders equal upstream + patch; needs
``extract.py`` to have run).

Output ``outputs/collection/<name>-<version>.zip`` (``-<variant>`` added for a
variant other than the default); version must equal the Core TOC
``## Version``. Next to ``Interface/`` the archive holds ``DevilForever-install/``
with ``manifest.json`` (per folder: origin, package, version, kind — new/fork
for ours, unmodified/patched for upstream with the patch file —, bundle, source
ZIP and its sha256, licence files, saved variables), the install notes named by
install.json, and ``SHA256SUMS.txt`` (sha256 of every other file of the
archive, paths from the archive root, ``sha256sum -c`` format).

Only files the game can use are packed. Left out (``--list-excluded`` prints
them): ``.lua``/``.xml`` files that no TOC of their folder loads, directly or
through XML ``Script``/``Include`` lines (``[AllowLoad... x]``/``[ExcludeLoad... x]``
conditions are ignored, so a file loaded for any game type or locale is kept;
TOC path tokens such as ``[Family]`` match any name; ``Bindings.xml`` in a
folder root is loaded by the client and kept), the files in DEV_FILES, and a ``<name>_deck.tga`` whose sibling
``<name>_deck_reviewed.tga`` is in the same directory (the reviewed deck replaces
it; Composition.lua loads only the reviewed deck for those themes). Other
textures, fonts, sounds, licences and data files are kept.

Archive layout: ``Interface/AddOns/<folder>/...``. Entries are sorted and carry
a fixed timestamp so the same inputs give the same bytes. Symlinks in the
inputs stop the build.
"""

import argparse
import hashlib
import json
import os
import re
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import genregistry  # noqa: E402
import patches  # noqa: E402
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
# Development files inside shipped folders that the game never reads: (folder, path).
DEV_FILES = {(CORE_FOLDER, "registry_extra.json")}
CODE_EXT = (".lua", ".xml")
DECK_SUFFIX = "_deck.tga"
REVIEWED_SUFFIX = "_deck_reviewed.tga"
INCLUDE_RE = re.compile(r"""<(?:Script|Include)\b[^>]*?\bfile\s*=\s*["']([^"']+)["']""", re.I)
COMMENT_RE = re.compile(r"<!--.*?-->", re.S)
CONDITION_RE = re.compile(r"\[\s*(?:Allow|Exclude)Load\w*\s[^\]]*\]", re.I)
TOKEN_RE = re.compile(r"\\\[[^\]/]*\\\]")


class BuildError(Exception):
    pass


def load_json(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def present_folders():
    if not os.path.isdir(ADDONS):
        return set()
    return {n for n in os.listdir(ADDONS) if os.path.isdir(os.path.join(ADDONS, n)) and n not in SKIP_NAMES}


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
    named = set()
    for part in [install] + list(variants.values()):
        named.update(part.get("own") or [])
        for folders in (part.get("upstream") or {}).values():
            named.update(folders)
    present = present_folders()
    for name in sorted(present - named):
        raise BuildError("Collection/AddOns/%s is not named in install.json (own or upstream, base or a variant)" % name)
    for name in own + [f for _p, f in upstream]:
        if name not in present:
            raise BuildError("install.json folder missing in Collection/AddOns: %s" % name)
    return own, upstream


def install_sources(manifest, own, upstream):
    """[(folder, path, origin)] sorted by folder; origin "Collection/AddOns" or "upstream:<package>"."""
    third = {t["folder"]: t for t in manifest.get("third_party") or []}
    sources = {}
    for name in own:
        if name.lower() in sources:
            raise BuildError("folder %s given twice" % name)
        if name in third:
            raise BuildError("install.json own folder %s is a third-party folder of %s" % (name, third[name]["package"]))
        sources[name.lower()] = (name, os.path.join(ADDONS, name), "Collection/AddOns")
    for pkg, folder in upstream:
        item = third.get(folder)
        if item is None or item["package"] != pkg:
            raise BuildError("install.json: folder %s is not a manifest third_party folder of package %s" % (folder, pkg))
        if folder.lower() in sources:
            raise BuildError("folder %s given twice (%s and %s)" % (folder, sources[folder.lower()][2], pkg))
        sources[folder.lower()] = (folder, os.path.join(ADDONS, folder), "upstream:" + pkg)
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


def install_manifest(install, variant, sources, manifest):
    """Deterministic install manifest (dict) for the shipped folders."""
    packages = {p["name"]: p for p in manifest["packages"]}
    collection = {c["folder"]: c for c in manifest.get("collection") or []}
    third = {t["folder"]: t for t in manifest.get("third_party") or []}
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
            item.update({"origin": "upstream", "kind": third[folder]["state"], "package": pkg["name"],
                         "version": upstream_version(pkg, addon),
                         "phases": sorted({f["phase"] for f in pkg["feature_phases"] if f["use"] == "start"}),
                         "source_zip": pkg["source_zip"], "source_sha256": pkg["sha256"],
                         "patch": third[folder]["patch"], "license_files": addon["license_files"]})
        folders.append({k: v for k, v in sorted(item.items()) if v is not None})
    out = {
        "schema": "devil-forever-install-manifest/1",
        "name": install["name"],
        "version": install["version"],
        "interface": manifest.get("target_interface", 16001),
        "unit_frames": variant,
        "generated_by": "Collection/tools/build.py",
        "folders": folders,
    }
    review = (install.get("unit_frame_variants") or {}).get(variant, {}).get("review")
    if review is not None:
        out["review"] = review
    return out


def folder_files(folder):
    """{relative path with "/": absolute path} of a folder's regular files (SKIP_NAMES left out)."""
    found = {}
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
            found[os.path.relpath(full, folder).replace(os.sep, "/")] = full
    return found


def toc_entry_pattern(entry):
    """Regex for a TOC file line (lower-case path); ``[Token]`` parts match any name."""
    text = CONDITION_RE.sub(" ", entry).strip().replace("\\", "/").lower()
    return re.compile(TOKEN_RE.sub("[^/]*", re.escape(os.path.normpath(text).replace(os.sep, "/"))) + r"\Z")


def loaded_code(folder):
    """Lower-case relative paths of the code files a TOC of ``folder`` loads (XML includes followed)."""
    files = {rel.lower(): (rel, full) for rel, full in folder_files(folder).items()}
    loaded = set()
    pending = []
    for toc in toclib.own_tocs(folder):
        for raw in toclib.read_text(os.path.join(folder, toc)).splitlines():
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            pattern = toc_entry_pattern(line)
            pending.extend(k for k in files if pattern.match(k))
    while pending:
        key = pending.pop()
        if key in loaded:
            continue
        loaded.add(key)
        if key.endswith(".xml"):
            rel, full = files[key]
            base = os.path.dirname(rel)
            for ref in INCLUDE_RE.findall(COMMENT_RE.sub("", toclib.read_text(full))):
                target = os.path.normpath(os.path.join(base, ref.replace("\\", "/"))).replace(os.sep, "/").lower()
                if target in files:
                    pending.append(target)
    return loaded


def runtime_files(folder_name, folder):
    """(kept [(rel, path)], excluded [(rel, reason)]) of one shipped folder."""
    files = folder_files(folder)
    loaded = loaded_code(folder)
    kept, excluded = [], []
    for rel in sorted(files):
        low = rel.lower()
        if (folder_name, rel) in DEV_FILES:
            excluded.append((rel, "development file"))
        elif low.endswith(CODE_EXT) and low not in loaded and low != "bindings.xml":
            excluded.append((rel, "not loaded by any TOC"))
        elif low.endswith(DECK_SUFFIX) and rel[:-len(DECK_SUFFIX)] + REVIEWED_SUFFIX in files:
            excluded.append((rel, "replaced by " + os.path.basename(rel[:-len(DECK_SUFFIX)] + REVIEWED_SUFFIX)))
        else:
            kept.append((rel, files[rel]))
    return kept, excluded


def plan_entries(sources):
    entries, excluded = [], []
    for folder, path, _origin in sources:
        kept, dropped = runtime_files(folder, path)
        entries.extend(("Interface/AddOns/%s/%s" % (folder, rel), full) for rel, full in kept)
        excluded.extend(("%s/%s" % (folder, rel), reason) for rel, reason in dropped)
    entries.sort()
    if len({a.casefold() for a, _f in entries}) != len(entries):
        raise BuildError("two archive names differ only in letter case")
    return entries, excluded


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


def install_extra(install, variant, sources, entries, manifest):
    """[(arcname, bytes)] of DevilForever-install/: manifest.json, notes, SHA256SUMS.txt (last)."""
    notes_path = os.path.join(REPO, install["notes"])
    if not os.path.isfile(notes_path):
        raise BuildError("install notes missing: %s" % install["notes"])
    manifest_bytes = (json.dumps(install_manifest(install, variant, sources, manifest), indent=1, ensure_ascii=False,
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


def check_sources(manifest):
    lines = []
    if patches.verify(manifest, [], out=lines.append) != 0:
        raise BuildError("third-party folders differ from upstream + patches:\n  "
                         + "\n  ".join(l for l in lines if l.startswith(("FAIL", "ERROR"))))


def main():
    parser = argparse.ArgumentParser(description="Build the release ZIP from Collection/AddOns and install.json")
    parser.add_argument("--install", action="store_true", help="accepted; the release build is the only mode")
    parser.add_argument("--variant", help="unit-frame variant (default: install.json unit_frames)")
    parser.add_argument("--out-dir", default=DEFAULT_OUT)
    parser.add_argument("--dry-run", action="store_true", help="list the plan, write nothing")
    parser.add_argument("--list-excluded", action="store_true", help="print every file left out of the archive")
    args = parser.parse_args()
    try:
        install = load_json(INSTALL)
        manifest = load_json(MANIFEST)
        variant = args.variant or install["unit_frames"]
        if install["version"] != core_version():
            raise BuildError("install.json version %s differs from the Core TOC version %s"
                             % (install["version"], core_version()))
        own, upstream = install_selection(install, variant)
        sources = install_sources(manifest, own, upstream)
        check_sources(manifest)
        entries, excluded = plan_entries(sources)
        extra = install_extra(install, variant, sources, entries, manifest)
        name = "%s-%s" % (install["name"], install["version"])
        if variant != install["unit_frames"]:
            name += "-" + variant
    except (BuildError, patches.PatchError) as exc:
        print("ERROR " + str(exc))
        return 1
    for folder, _path, origin in sources:
        print("folder %-28s from %s" % (folder, origin))
    if args.list_excluded:
        for rel, reason in excluded:
            print("excluded %s (%s)" % (rel, reason))
    print("excluded files=%d" % len(excluded))
    out_path = os.path.join(args.out_dir, name + ".zip")
    if args.dry_run:
        print("dry-run folders=%d files=%d target=%s" % (len(sources), len(entries) + len(extra), out_path))
        return 0
    os.makedirs(args.out_dir, exist_ok=True)
    write_zip(entries, out_path, extra, (INSTALL_DIR + "/",))
    with zipfile.ZipFile(out_path) as zf:
        bad = zf.testzip()
        count = len(zf.infolist())
    if bad:
        print("ERROR zip test failed at %s" % bad)
        return 1
    print("built folders=%d files=%d zip_entries=%d sha256=%s -> %s" % (
        len(sources), len(entries) + len(extra), count, sha256_file(out_path), out_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())

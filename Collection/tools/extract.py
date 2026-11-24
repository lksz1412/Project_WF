"""Extract start + comparison addon ZIPs and write the Collection manifest.

Usage:  python3 -I Collection/tools/extract.py [--no-extract]

Inputs (read-only):
  References/forever-addons/<dir>/   13 start packages (ZIP + SOURCE.txt)
  References/addon-sources/<dir>/    comparison packages named in COMPARISON_NAMES,
                                     resolved through References/addon-sources/INDEX.md
Outputs:
  Collection/upstream/<dir>-<version>/   extracted ZIP contents (regenerable, git-ignored)
  Collection/manifest.json, Collection/manifest.md   (packages, our own Collection/AddOns/ folders
                                                     and the third-party folders shipped there)

Every ZIP's SHA256 must equal the SOURCE.txt value before it is extracted.
Members with absolute paths, drive letters, backslashes, ``..`` parts or
symlink mode bits are refused; nothing from an archive is executed.
Rerunning yields the same manifest (no timestamps, sorted output).
"""

import argparse
import hashlib
import json
import os
import re
import stat
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import toclib  # noqa: E402

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
REF = os.path.join(REPO, "References")
START_ROOT = os.path.join(REF, "forever-addons")
INDEX_MD = os.path.join(REF, "addon-sources", "INDEX.md")
COLLECTION = os.path.join(REPO, "Collection")
UPSTREAM = os.path.join(COLLECTION, "upstream")
MARKER = ".extract-source.json"
MAX_TOTAL_BYTES = 1 << 30
TARGET_INTERFACE = 16001

# Comparison packages named in the brief, as (name in the brief, row name in INDEX.md).
COMPARISON_NAMES = [
    ("Bartender4", "Bartender4"),
    ("Glass Forever", "Glass Forever"),
    ("Chattynator", "Chattynator"),
    ("BasicMinimap", "BasicMinimap"),
    ("PitBull4", "PitBull Unit Frames 4.0"),
    ("NugComboBar", "NugComboBar"),
    ("TellMeWhen", "TellMeWhen"),
    ("VuhDo", "VuhDo"),
    ("Skada", "Skada Damage Meter"),
    ("ThreatClassic2", "ThreatClassic2"),
    ("TipTac Reborn", "TipTac Reborn"),
    ("Bagnon", "Bagnon"),
    ("Baganator", "Baganator"),
    ("Platynator", "Platynator (Nameplates)"),
    ("Aurora", "Aurora"),
    ("Titan Panel", "Titan Panel"),
    ("Kaliel's Tracker", "Kaliel's Tracker"),
    ("Questie", "Questie"),
    ("Mapster", "Mapster"),
    ("Experience Forever", "Experience Forever"),
    ("ProfileManager", "ProfileManager"),
    ("Reflux", "Reflux"),
    ("Edit Mode Expanded", "Edit Mode Expanded"),
    ("BlizzMove", "BlizzMove"),
    ("Leatrix Plus", "Leatrix Plus"),
    ("XLoot", "XLoot"),
    ("BugSack", "BugSack"),
    ("BugGrabber", "BugGrabber"),
]

# Feature Phase table of the master plan
# (Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md:211-234),
# keyed by the package directory relative to References/.
# use: "start" = the Phase's start addon, "comparison" = 비교, "reference" = 참고,
# "dropped" = start addon of a Phase that was taken out (R100, R107).
# A package's role is "start" when any of its uses is "start".
FEATURE_PHASES = {
    "forever-addons/Masque": [(2, "start")],
    "forever-addons/Masque Onyx": [(2, "start")],
    "forever-addons/Dominos": [(3, "start"), (19, "comparison")],
    "addon-sources/bartender4": [(3, "comparison")],
    "forever-addons/Prat-3.0": [(4, "start")],
    "forever-addons/Glass Forever": [(4, "comparison")],
    "forever-addons/Chattynator": [(4, "comparison")],
    "forever-addons/SexyMap": [(5, "start")],
    "addon-sources/basic-minimap": [(5, "comparison")],
    "forever-addons/Forever Unit Frames": [(6, "start")],
    "addon-sources/pitbull-unit-frames-4-0": [(6, "comparison")],
    "addon-sources/nugie-combo-bar": [(6, "comparison")],
    "forever-addons/Quartz": [(7, "start")],
    "forever-addons/Hekili": [(8, "start")],
    "addon-sources/tellmewhen": [(8, "comparison")],
    "forever-addons/Grid2": [(9, "start")],
    "addon-sources/vuhdo": [(9, "comparison")],
    "forever-addons/Details": [(10, "start")],
    "addon-sources/skada": [(10, "comparison")],
    "forever-addons/ForeverThreat": [(10, "comparison"), (11, "dropped")],
    "addon-sources/threatclassic2": [(11, "comparison")],
    "addon-sources/tiptac-reborn": [(12, "dropped")],
    "addon-sources/bagnon": [(13, "dropped")],
    "addon-sources/baganator": [(13, "comparison")],
    "addon-sources/platynator": [(14, "dropped")],
    "addon-sources/aurora": [(15, "start")],
    "addon-sources/titan-panel": [(16, "dropped")],
    "addon-sources/kaliels-tracker": [(17, "dropped")],
    "addon-sources/questie": [(17, "reference")],
    "addon-sources/mapster": [(18, "dropped")],
    "addon-sources/experience-forever": [(19, "start")],
    "addon-sources/profilemanager": [(20, "start")],
    "addon-sources/reflux": [(20, "comparison")],
    "addon-sources/edit-mode-expanded": [(21, "comparison")],
    "addon-sources/blizzmove": [(21, "comparison")],
}

# Our own folders under Collection/AddOns/ (hand-kept; every folder there must
# be listed). phases = feature Phases the folder serves; variant = the Phase ID
# when it is not a plain number (Phase 6-rev); bundle = "required" (plan
# Implementation Changes, required bundle) or "individual"; kind = "new"
# (written for the collection) or "fork" (a start addon's original with our
# changes; base names the package in this manifest and the patch file).
COLLECTION_ADDONS = os.path.join(COLLECTION, "AddOns")
OWN_FOLDERS = {
    "!DevilForever_Core": {"phases": [2, 20, 22], "bundle": "required", "kind": "new"},
    "DevilForever_ChatSetup": {"phases": [4], "bundle": "individual", "kind": "new"},
    "DevilForever_FUFDefaults": {"phases": [6], "bundle": "individual", "kind": "new"},
    "DevilForever_Castbars": {"phases": [7], "bundle": "individual", "kind": "new"},
    "DevilForever_StatusStrip": {"phases": [16], "bundle": "individual", "kind": "new"},
    "DevilForever_Appearance": {"phases": [2, 22], "bundle": "required", "kind": "new"},
    "DevilForever_DetailsLayout": {"phases": [10], "bundle": "individual", "kind": "new"},
    "DevilForever_Skin_Dominos": {"phases": [3], "bundle": "individual", "kind": "new"},
    "DevilForever_Skin_Nameplates": {"phases": [14], "bundle": "individual", "kind": "new"},
    "DevilForever_Skin_NativeChat": {"phases": [4], "bundle": "individual", "kind": "new"},
    "DevilForever_Skin_StatusStrip": {"phases": [16], "bundle": "individual", "kind": "new"},
    "PitBull4": {"phases": [6], "variant": "6-rev", "bundle": "individual", "kind": "fork",
                 "base": {"package": "PitBull4", "patch": "Collection/patches/PitBull4.patch"}},
}

# Third-party folders under Collection/AddOns/ that differ from their upstream
# folder, per package (hand-kept). Their patch is ``patch_path(package)`` =
# the diff upstream -> shipped of these folders (Collection/tools/patches.py).
# Every other third-party folder there must be byte-identical to upstream.
PATCHED = {
    "Details": ["Details_TinyThreat"],
    "Experience Forever": ["ExperienceForever"],
    "Grid2": ["Grid2"],
    "ProfileManager": ["ProfileManager"],
    "Quartz": ["Quartz"],
    "SexyMap": ["SexyMap"],
}


def patch_path(package):
    """Repo-relative patch file of a package: spaces in the name become ``_``."""
    return "Collection/patches/%s.patch" % package.replace(" ", "_")

LICENSE_RE = re.compile(r"^(licen[cs]e|copying|unlicense)([._-].*)?$", re.IGNORECASE)
LIBSTUB_NEW_RE = re.compile(
    r"""LibStub\s*(?::|\.)\s*NewLibrary\s*\(\s*(?:LibStub\s*,\s*)?["']([^"']+)["']\s*,\s*([^)\n]+?)\s*\)"""
)
MAJOR_MINOR_RE = re.compile(
    r"""local\s+MAJOR(?:_VERSION)?\s*,\s*MINOR(?:_VERSION)?\s*=\s*["']([^"']+)["']\s*,\s*([^\n;]+)"""
)


class ExtractError(Exception):
    pass


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as fh:
        for block in iter(lambda: fh.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def read_source_txt(path):
    fields = {}
    for line in toclib.read_text(path).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        fields[key.strip()] = value.strip()
    return {
        "file_name": fields.get("파일명"),
        "version": fields.get("판(version)"),
        "file_id": fields.get("file ID"),
        "sha256": (fields.get("SHA256") or "").lower() or None,
        "page_url": fields.get("받은 페이지 URL"),
    }


def parse_index():
    """Map INDEX.md row name -> package directory relative to References/."""
    rows = {}
    link_re = re.compile(r"\]\(([^)]+)\)")
    for line in toclib.read_text(INDEX_MD).splitlines():
        if not line.startswith("| ") or line.startswith("| 애드온") or line.startswith("|---"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue
        match = link_re.search(cells[1])
        if not match:
            continue
        target = re.sub(r"%([0-9A-Fa-f]{2})", lambda m: chr(int(m.group(1), 16)), match.group(1))
        pkg_dir = os.path.normpath(os.path.join("addon-sources", os.path.dirname(target)))
        rows[cells[0]] = pkg_dir.replace(os.sep, "/")
    return rows


def safe_dir_name(text):
    return re.sub(r"[^A-Za-z0-9._+-]+", "_", text).strip("_")


def check_member(info):
    name = info.filename
    if "\\" in name:
        raise ExtractError("backslash in member name: %r" % name)
    if name.startswith("/") or re.match(r"^[A-Za-z]:", name):
        raise ExtractError("absolute member path: %r" % name)
    parts = [p for p in name.split("/") if p not in ("", ".")]
    if any(p == ".." for p in parts):
        raise ExtractError("parent reference in member path: %r" % name)
    mode = (info.external_attr >> 16) & 0xFFFF
    if mode and stat.S_ISLNK(mode):
        raise ExtractError("symlink member: %r" % name)
    return parts


def extract_zip(zip_path, sha256, dest):
    """Extract into ``dest``; skip when the marker records the same SHA256 and file list."""
    with zipfile.ZipFile(zip_path) as zf:
        infos = zf.infolist()
        members = []
        total = 0
        for info in infos:
            parts = check_member(info)
            if not parts:
                continue
            total += info.file_size
            members.append((info, parts))
        if total > MAX_TOTAL_BYTES:
            raise ExtractError("uncompressed size %d exceeds limit" % total)
        files = sorted("/".join(p) for i, p in members if not i.is_dir())
        marker_path = os.path.join(dest, MARKER)
        if os.path.isfile(marker_path):
            with open(marker_path, encoding="utf-8") as fh:
                marker = json.load(fh)
            if marker.get("sha256") == sha256 and marker.get("files") == files:
                return "kept", len(files)
        dest_real = os.path.realpath(dest)
        os.makedirs(dest_real, exist_ok=True)
        for info, parts in members:
            target = os.path.join(dest_real, *parts)
            if info.is_dir():
                os.makedirs(target, exist_ok=True)
                continue
            os.makedirs(os.path.dirname(target), exist_ok=True)
            if os.path.islink(target):
                raise ExtractError("existing symlink at target: %r" % target)
            real_parent = os.path.realpath(os.path.dirname(target))
            if os.path.commonpath([dest_real, real_parent]) != dest_real:
                raise ExtractError("member escapes destination: %r" % info.filename)
            with zf.open(info) as src, open(target, "wb") as out:
                while True:
                    block = src.read(1 << 20)
                    if not block:
                        break
                    out.write(block)
        with open(marker_path, "w", encoding="utf-8") as fh:
            json.dump({"sha256": sha256, "files": files}, fh, indent=1, ensure_ascii=False)
            fh.write("\n")
        return "extracted", len(files)


def lib_version(lib_dir):
    """Cheap LibStub major/minor lookup in the library's top-level Lua files."""
    for name in sorted(os.listdir(lib_dir)):
        if not name.lower().endswith(".lua"):
            continue
        path = os.path.join(lib_dir, name)
        if not os.path.isfile(path):
            continue
        text = toclib.read_text(path)
        match = LIBSTUB_NEW_RE.search(text) or MAJOR_MINOR_RE.search(text)
        if match:
            minor = match.group(2).strip()
            return {"major": match.group(1), "minor": minor, "file": name}
    return None


def embedded_libs(folder):
    libs = []
    for entry in sorted(os.listdir(folder)):
        full = os.path.join(folder, entry)
        if os.path.isdir(full) and entry.lower() in ("libs", "lib", "libraries"):
            for lib in sorted(os.listdir(full)):
                lib_full = os.path.join(full, lib)
                if not os.path.isdir(lib_full):
                    continue
                item = {"name": lib, "path": entry + "/" + lib}
                tocs = sorted(n for n in os.listdir(lib_full) if n.lower().endswith(".toc"))
                item["toc_files"] = tocs
                found = lib_version(lib_full)
                item["libstub"] = found
                libs.append(item)
    return libs


def license_files(root):
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            if LICENSE_RE.match(name):
                rel = os.path.relpath(os.path.join(dirpath, name), root)
                found.append(rel.replace(os.sep, "/"))
    return sorted(found)


def count_lua(folder):
    total = 0
    in_libs = 0
    for dirpath, dirnames, filenames in os.walk(folder):
        rel_parts = os.path.relpath(dirpath, folder).replace(os.sep, "/").split("/")
        under_libs = rel_parts[0].lower() in ("libs", "lib", "libraries")
        for name in filenames:
            if name.lower().endswith(".lua"):
                total += 1
                if under_libs:
                    in_libs += 1
    return total, in_libs


def describe_addon(folder, pkg_root):
    tocs = []
    for toc_name in toclib.own_tocs(folder):
        parsed = toclib.parse_toc(os.path.join(folder, toc_name))
        parsed["file"] = toc_name
        tocs.append(parsed)
    lua_total, lua_libs = count_lua(folder)
    has_target = any(TARGET_INTERFACE in toclib.interface_numbers(t) for t in tocs)
    has_loadable = any(TARGET_INTERFACE in toclib.interface_numbers(t) and t["forever_load"] != "no"
                       for t in tocs)
    return {
        "folder": os.path.basename(folder),
        "path": os.path.relpath(folder, pkg_root).replace(os.sep, "/"),
        "toc_files": [t["file"] for t in tocs],
        "tocs": [
            {
                "file": t["file"],
                "interface": t["Interface"],
                "version": t["Version"],
                "title": t["Title"],
                "dependencies": t["Dependencies"],
                "required_deps": t["RequiredDeps"],
                "optional_deps": t["OptionalDeps"],
                "saved_variables": t["SavedVariables"],
                "saved_variables_per_character": t["SavedVariablesPerCharacter"],
                "load_on_demand": t["LoadOnDemand"],
                "game_types": t["game_types"],
                "forever_load": t["forever_load"],
                "list_lines": t["list_lines"],
                "listed_file_lines": t["listed_file_lines"],
            }
            for t in tocs
        ],
        "has_interface_%d" % TARGET_INTERFACE: has_target,
        "has_forever_loadable_toc": has_loadable,
        "lua_files": lua_total,
        "lua_files_in_libs": lua_libs,
        "embedded_libs": embedded_libs(folder),
        "license_files": license_files(folder),
    }


def collect_packages():
    packages = []
    for name in sorted(os.listdir(START_ROOT)):
        pkg_dir = os.path.join(START_ROOT, name)
        if os.path.isfile(os.path.join(pkg_dir, "SOURCE.txt")):
            packages.append({"name": name, "ref_dir": "forever-addons/" + name})
    index = parse_index()
    missing = []
    start_dirs = {p["ref_dir"] for p in packages}
    for brief_name, index_name in COMPARISON_NAMES:
        ref_dir = index.get(index_name)
        if not ref_dir or not os.path.isfile(os.path.join(REF, ref_dir, "SOURCE.txt")):
            missing.append(brief_name)
            continue
        if ref_dir in start_dirs:
            continue
        packages.append({"name": brief_name, "ref_dir": ref_dir})
    for pkg in packages:
        pkg["source_dir"] = pkg["ref_dir"].split("/", 1)[0]
        uses = [use for _phase, use in FEATURE_PHASES.get(pkg["ref_dir"], [])]
        pkg["role"] = "start" if "start" in uses else "comparison"
    return packages, missing


def comparison_also_start(packages):
    """Brief-named comparison packages whose ZIP is already in References/forever-addons/."""
    index = parse_index()
    start_dirs = {p["ref_dir"] for p in packages if p["source_dir"] == "forever-addons"}
    return sorted(b for b, i in COMPARISON_NAMES if index.get(i) in start_dirs)


def existing_how_to_use():
    """how_to_use values of the current manifest.json, keyed by source_zip (kept on regeneration)."""
    path = os.path.join(COLLECTION, "manifest.json")
    if not os.path.isfile(path):
        return {}
    with open(path, encoding="utf-8") as fh:
        old = json.load(fh)
    return {p["source_zip"]: p.get("how_to_use") for p in old.get("packages", []) if p.get("source_zip")}


def addon_folders_present():
    return sorted(n for n in os.listdir(COLLECTION_ADDONS)
                  if os.path.isdir(os.path.join(COLLECTION_ADDONS, n)) and toclib.own_tocs(os.path.join(COLLECTION_ADDONS, n)))


def third_party_entries(packages, errors):
    """Manifest entries of the third-party folders shipped from Collection/AddOns/.

    A folder that is not in OWN_FOLDERS must be the folder of exactly one
    extracted package; state is "patched" when PATCHED names it for that
    package, otherwise "unmodified".
    """
    index = {}
    for pkg in packages:
        for addon in pkg.get("addons") or []:
            index.setdefault(addon["folder"], []).append((pkg, addon))
    for package, folders in sorted(PATCHED.items()):
        for folder in folders:
            if not any(p["name"] == package for p, _a in index.get(folder, [])):
                errors.append("PATCHED %s: folder %s is not a folder of that package" % (package, folder))
    out = []
    for name in addon_folders_present():
        if name in OWN_FOLDERS:
            continue
        hits = index.get(name, [])
        if len(hits) != 1:
            errors.append("Collection/AddOns/%s: not in OWN_FOLDERS and found in %d extracted packages"
                          % (name, len(hits)))
            continue
        pkg, addon = hits[0]
        patched = name in PATCHED.get(pkg["name"], [])
        patch = patch_path(pkg["name"]) if patched else None
        if patch and not os.path.isfile(os.path.join(REPO, patch)):
            errors.append("Collection/AddOns/%s: patch file missing %s" % (name, patch))
        out.append({
            "folder": name,
            "package": pkg["name"],
            "version": pkg["version"],
            "source_zip": pkg["source_zip"],
            "sha256": pkg["sha256"],
            "upstream_path": pkg["upstream_dir"] + "/" + addon["path"],
            "state": "patched" if patched else "unmodified",
            "patch": patch,
        })
    return out


def collection_entries(packages, errors):
    """Manifest entries of our own folders (Collection/AddOns/) from OWN_FOLDERS and their TOCs."""
    by_name = {p["name"]: p for p in packages}
    present = addon_folders_present()
    out = []
    for name in sorted(OWN_FOLDERS, key=str.lower):
        if name not in present:
            errors.append("OWN_FOLDERS %s: folder missing in Collection/AddOns" % name)
            continue
        meta = OWN_FOLDERS[name]
        entry = {
            "folder": name,
            "phases": list(meta["phases"]),
            "variant": meta.get("variant"),
            "bundle": meta["bundle"],
            "kind": meta["kind"],
            "base": None,
        }
        if meta["kind"] == "fork":
            base = meta["base"]
            pkg = by_name.get(base["package"])
            if pkg is None:
                errors.append("OWN_FOLDERS %s: base package %s not in the manifest" % (name, base["package"]))
                continue
            if not os.path.isfile(os.path.join(REPO, base["patch"])):
                errors.append("OWN_FOLDERS %s: patch file missing %s" % (name, base["patch"]))
            entry["base"] = {"package": pkg["name"], "version": pkg["version"], "source_zip": pkg["source_zip"],
                             "sha256": pkg["sha256"], "patch": base["patch"]}
        entry.update(describe_addon(os.path.join(COLLECTION_ADDONS, name), COLLECTION_ADDONS))
        entry["path"] = "Collection/AddOns/" + entry["path"]
        out.append(entry)
    return out


def build_manifest(do_extract):
    packages, missing = collect_packages()
    kept_how_to_use = existing_how_to_use()
    out = []
    errors = []
    for pkg in packages:
        ref_dir = os.path.join(REF, pkg["ref_dir"])
        source = read_source_txt(os.path.join(ref_dir, "SOURCE.txt"))
        zip_path = os.path.join(ref_dir, source["file_name"] or "")
        entry = {
            "name": pkg["name"],
            "role": pkg["role"],
            "source_dir": pkg["source_dir"],
            "feature_phases": [
                {"phase": ph, "use": use} for ph, use in FEATURE_PHASES.get(pkg["ref_dir"], [])
            ],
            "source_zip": os.path.relpath(zip_path, REPO).replace(os.sep, "/"),
            "source_page_url": source["page_url"],
            "sha256": source["sha256"],
            "version": source["version"],
            "file_id": source["file_id"],
        }
        entry["how_to_use"] = kept_how_to_use.get(entry["source_zip"])
        if not os.path.isfile(zip_path):
            errors.append("%s: zip not found %s" % (pkg["name"], entry["source_zip"]))
            continue
        actual = sha256_file(zip_path)
        entry["sha256_verified"] = actual == source["sha256"]
        if not entry["sha256_verified"]:
            errors.append("%s: sha256 mismatch (SOURCE %s, actual %s)" % (pkg["name"], source["sha256"], actual))
            out.append(entry)
            continue
        dir_name = safe_dir_name(os.path.basename(pkg["ref_dir"])) + "-" + safe_dir_name(source["version"] or "unknown")
        dest = os.path.join(UPSTREAM, dir_name)
        entry["upstream_dir"] = os.path.relpath(dest, REPO).replace(os.sep, "/")
        if do_extract:
            try:
                state, nfiles = extract_zip(zip_path, actual, dest)
            except (ExtractError, zipfile.BadZipFile) as exc:
                errors.append("%s: %s" % (pkg["name"], exc))
                out.append(entry)
                continue
            print("%-24s %-9s %5d files -> %s" % (pkg["name"], state, nfiles, entry["upstream_dir"]))
        if not os.path.isdir(dest):
            errors.append("%s: upstream dir missing (run without --no-extract)" % pkg["name"])
            out.append(entry)
            continue
        folders = toclib.find_addon_folders(dest)
        entry["addons"] = [describe_addon(f, dest) for f in folders]
        entry["license_files"] = license_files(dest)
        out.append(entry)
    manifest = {
        "schema": "devil-forever-collection-manifest/1",
        "target_interface": TARGET_INTERFACE,
        "generated_by": "Collection/tools/extract.py",
        "packages": out,
        "collection": collection_entries(out, errors),
        "third_party": third_party_entries(out, errors),
        "comparison_names_missing": missing,
        "comparison_names_in_start_set": comparison_also_start(packages),
    }
    return manifest, errors


def md_cell(value):
    if value is None:
        return "—"
    if isinstance(value, list):
        return ", ".join(value) if value else "—"
    return str(value).replace("|", "\\|")


def how_to_use_cell(value):
    if isinstance(value, dict):
        return md_cell(value.get("verdict"))
    return md_cell(value)


def deps_cell(toc):
    """Required deps per TOC line, each line's [allow|exclude game types] condition appended."""
    parts = []
    for field in ("Dependencies", "RequiredDeps"):
        for line in toc["list_lines"].get(field, []):
            if not line["items"]:
                continue
            text = ", ".join(line["items"])
            for cond in line["conditions"]:
                text += " [%s %s]" % (cond["kind"], ", ".join(cond["game_types"]))
            parts.append(text)
    return md_cell("; ".join(parts) if parts else None)


def write_markdown(manifest, path):
    lines = [
        "# Collection manifest (generated by `Collection/tools/extract.py` — do not edit by hand)",
        "",
        "Target client TOC Interface: %d. `how_to_use` = A1 judgment verdict (kept across regeneration); "
        "role = start when the package is a start addon of any feature Phase; use `dropped` = start addon of a "
        "Phase that was taken out (R100, R107)." % manifest["target_interface"],
        "",
        "## Packages",
        "",
        "| Package | Role | Source dir | Feature Phases | how_to_use | Version | File ID | SHA256 ok | Addon folders "
        "| Folders with %d | Folders with %d and forever_load≠no | License files |"
        % (manifest["target_interface"], manifest["target_interface"]),
        "|---|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    key = "has_interface_%d" % manifest["target_interface"]
    for p in manifest["packages"]:
        addons = p.get("addons", [])
        phases = ", ".join("%d %s" % (f["phase"], f["use"]) for f in p["feature_phases"]) or "—"
        lines.append("| %s | %s | %s | %s | %s | %s | %s | %s | %d | %d | %d | %s |" % (
            md_cell(p["name"]), p["role"], p["source_dir"], phases, how_to_use_cell(p.get("how_to_use")),
            md_cell(p["version"]), md_cell(p["file_id"]),
            "yes" if p.get("sha256_verified") else "NO", len(addons),
            sum(1 for a in addons if a.get(key)),
            sum(1 for a in addons if a.get("has_forever_loadable_toc")), md_cell(p.get("license_files")),
        ))
    lines += [
        "",
        "Comparison names not found: %s" % (md_cell(manifest["comparison_names_missing"])),
        "",
        "Comparison names whose ZIP is in References/forever-addons/: %s"
        % (md_cell(manifest["comparison_names_in_start_set"])),
        "",
        "## Addon folders",
        "",
        "forever_load: yes = no header game-type restriction or Allow lists forever/camelot; "
        "check = Allow lists mainline but not forever/camelot (Forever runs the Mainline UI — inferred, Codex checks); "
        "no = Exclude lists forever/camelot, or Allow lists none of forever/camelot/mainline "
        "(camelot = Forever is inferred, unverified). Deps show a line's load condition in brackets.",
        "",
        "| Package | Folder | TOC | Interface | Forever load | Version | Deps (required) | OptionalDeps | SavedVariables | SV per character | LoadOnDemand | Lua (libs) | Libs |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for p in manifest["packages"]:
        for a in p.get("addons", []):
            for i, t in enumerate(a["tocs"]):
                deps = deps_cell(t)
                lines.append("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                    md_cell(p["name"]) if i == 0 else "",
                    md_cell(a["folder"]) if i == 0 else "",
                    md_cell(t["file"]), md_cell(t["interface"]), t["forever_load"], md_cell(t["version"]),
                    deps, md_cell(t["optional_deps"]), md_cell(t["saved_variables"]),
                    md_cell(t["saved_variables_per_character"]), md_cell(t["load_on_demand"]),
                    "%d (%d)" % (a["lua_files"], a["lua_files_in_libs"]) if i == 0 else "",
                    md_cell([lib["name"] for lib in a["embedded_libs"]]) if i == 0 else "",
                ))
    lines += [
        "",
        "## Collection folders (ours, `Collection/AddOns/`)",
        "",
        "kind: new = written for the collection; fork = a start addon's original with our changes "
        "(base package, version and patch file in the Base column). Variant = Phase ID that is not a plain number.",
        "",
        "| Folder | Feature Phases | Variant | Bundle | Kind | Base | TOC | Interface | Version | Deps (required) "
        "| OptionalDeps | SavedVariables | SV per character | License files |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for a in manifest.get("collection", []):
        base = a.get("base")
        base_cell = "%s %s + %s" % (base["package"], base["version"], base["patch"]) if base else "—"
        for i, t in enumerate(a["tocs"]):
            first = i == 0
            lines.append("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                md_cell(a["folder"]) if first else "",
                ", ".join(str(ph) for ph in a["phases"]) if first else "",
                md_cell(a.get("variant")) if first else "",
                a["bundle"] if first else "", a["kind"] if first else "",
                md_cell(base_cell) if first else "",
                md_cell(t["file"]), md_cell(t["interface"]), md_cell(t["version"]), deps_cell(t),
                md_cell(t["optional_deps"]), md_cell(t["saved_variables"]),
                md_cell(t["saved_variables_per_character"]),
                md_cell(a["license_files"]) if first else "",
            ))
    lines += [
        "",
        "## Third-party folders shipped from `Collection/AddOns/`",
        "",
        "state: unmodified = bytes equal the upstream folder; patched = upstream folder + the package patch "
        "(diff upstream -> shipped, `Collection/tools/patches.py`).",
        "",
        "| Folder | Package | Version | State | Patch | Upstream path |",
        "|---|---|---|---|---|---|",
    ]
    for t in manifest.get("third_party", []):
        lines.append("| %s | %s | %s | %s | %s | %s |" % (
            md_cell(t["folder"]), md_cell(t["package"]), md_cell(t["version"]), t["state"],
            md_cell(t["patch"]), md_cell(t["upstream_path"])))
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--no-extract", action="store_true",
                        help="only rebuild the manifest from existing Collection/upstream/")
    args = parser.parse_args()
    manifest, errors = build_manifest(not args.no_extract)
    with open(os.path.join(COLLECTION, "manifest.json"), "w", encoding="utf-8", newline="\n") as fh:
        json.dump(manifest, fh, indent=2, ensure_ascii=False, sort_keys=False)
        fh.write("\n")
    write_markdown(manifest, os.path.join(COLLECTION, "manifest.md"))
    pkgs = manifest["packages"]
    folders = sum(len(p.get("addons", [])) for p in pkgs)
    print("packages=%d start=%d comparison=%d forever_addons=%d addon_sources=%d addon_folders=%d "
          "missing_names=%d how_to_use_filled=%d errors=%d" % (
              len(pkgs), sum(p["role"] == "start" for p in pkgs), sum(p["role"] == "comparison" for p in pkgs),
              sum(p["source_dir"] == "forever-addons" for p in pkgs),
              sum(p["source_dir"] == "addon-sources" for p in pkgs),
              folders, len(manifest["comparison_names_missing"]),
              sum(p.get("how_to_use") is not None for p in pkgs), len(errors)))
    for err in errors:
        print("ERROR " + err)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())

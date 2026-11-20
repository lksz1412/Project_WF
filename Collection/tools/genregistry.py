"""Generate ``!DevilForever_Core/Registry.lua`` from the manifest and the hand-kept extras.

Usage:
  python3 -I Collection/tools/genregistry.py            # write Registry.lua
  python3 -I Collection/tools/genregistry.py --check    # exit 1 when Registry.lua is out of date
  python3 -I Collection/tools/genregistry.py --out FILE # write somewhere else

Inputs:
  Collection/manifest.json                                   packages with role "start", the
                                                             "collection" section (our own folders)
                                                             and "third_party" (shipped upstream folders)
  Collection/install.json                                    which upstream folders ship
  Collection/AddOns/*/ (own TOC)                             our own addon folders
  Collection/AddOns/!DevilForever_Core/registry_extra.json   optional per-folder additions

A folder of a start package is registered only when install.json ships it
(base list or any unit-frame variant) or registry_extra.json names it (a
folder whose use is still pending, e.g. Aurora). Our own folders take
package, phases, variant, bundle and use ("new", or "modify" for a fork) from
the manifest "collection" section. A start-package folder shipped from
Collection/AddOns (manifest "third_party", unmodified or patched) takes its
TOC data from that shipped copy; other start-package folders from the manifest.

Per addon folder the registry holds: package, feature phases (and variant
when the Phase ID is not a plain number), bundle
("required" or "individual"), how the start addon is used, the TOC files the
Forever client is taken to load, saved variables with scope ("account" for
``SavedVariables``, "character" for ``SavedVariablesPerCharacter``) and split
("common" unless the extras say "class"), what a settings restore does with
each saved variable (restore/shape/keys, written only when the extras give
them; absent restore means "skip"), appearance frames, editable items and the
defaults file (path relative to the Core folder).

TOC choice per folder follows ``toclib.tocs_for_interface``: TOCs whose
Interface lists the target interface, best ``forever_load`` rank kept; when none
lists it, the plain ``<Folder>.toc``. Output is sorted, carries no timestamps,
and the same inputs give the same bytes.

registry_extra.json shape (every key optional):
  {"addons": {"<Folder>": {
      "bundle": "required" | "individual",
      "frames": [{"key": str, "frame": str, "tokens": {"<field>": "<token>"}}],
      "editable": [{"frame": str, "field": str, "kind": str,
                    "min": num, "max": num, "step": num, "default": any}],
      "saved_variables": {"<Name>": {"split": "common" | "class",
                                     "restore": "whole" | "keys" | "profile" | "skip",
                                     "shape": "plain" | "acedb",
                                     "keys": ["<top-level key>", ...]}},
      "defaults": "Defaults/<Folder>.lua"}}}
A folder in the extras that is not registered, a saved variable that the folder
does not declare, an unknown saved-variable option or value, split "class"
without restore "profile" and shape "acedb", restore "profile" without split
"class", restore "keys" without a non-empty list of key strings (or keys with
another restore), an unknown field or kind, an editable item whose frame is not
one of the folder's frame keys or whose default does not fit its kind and
min/max, or a defaults file that is missing from the Core folder or from the
Core TOC file list stops the generator.
"""

import argparse
import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import toclib  # noqa: E402

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
COLLECTION = os.path.join(REPO, "Collection")
MANIFEST = os.path.join(COLLECTION, "manifest.json")
INSTALL = os.path.join(COLLECTION, "install.json")
ADDONS = os.path.join(COLLECTION, "AddOns")
CORE_FOLDER = "!DevilForever_Core"
CORE_DIR = os.path.join(ADDONS, CORE_FOLDER)
EXTRA = os.path.join(CORE_DIR, "registry_extra.json")
OUTPUT = os.path.join(CORE_DIR, "Registry.lua")
SCHEMA = 1

# Feature phases whose packages form the required bundle (master plan
# Implementation Changes: common appearance, settings save/restore; the UI
# editor Phase 21 was taken out, R107).
REQUIRED_PHASES = {2, 20}
EDIT_FIELDS = ("position", "size", "font", "color", "rows", "spacing")
SPLITS = ("common", "class")
RESTORES = ("whole", "keys", "profile", "skip")
SHAPES = ("plain", "acedb")
SV_OPTIONS = ("split", "restore", "shape", "keys")
FOREVER_RANK = ("yes", "check", "no")


class RegistryError(Exception):
    pass


def load_json(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def choose_tocs(folder, tocs, interface):
    """Manifest-data twin of ``toclib.tocs_for_interface``: (chosen tocs, status)."""
    def lists(toc):
        return str(interface) in [str(x) for x in (toc.get("interface") or [])]

    hits = [t for t in tocs if lists(t)]
    if hits:
        for rank, status in (("yes", "matched"), ("check", "forever_load_check")):
            best = [t for t in hits if t.get("forever_load") == rank]
            if best:
                return best, status
        return hits, "forever_load_no"
    plain = [t for t in tocs if t["file"][:-4].lower() == folder.lower()]
    return (plain or tocs), "no_interface"


def saved_variables(tocs):
    out = []
    seen = set()
    for toc in tocs:
        for scope, key in (("account", "saved_variables"), ("character", "saved_variables_per_character")):
            for name in toc.get(key) or []:
                if name not in seen:
                    seen.add(name)
                    out.append({"name": name, "scope": scope, "split": "common"})
    return out


def worst_forever_load(tocs):
    ranks = [t.get("forever_load") or "yes" for t in tocs]
    return max(ranks, key=FOREVER_RANK.index) if ranks else "no"


def shipped_upstream_folders(install):
    """Lower-cased upstream folder names install.json ships in any unit-frame variant."""
    folders = set()
    lists = [install.get("upstream") or {}]
    for variant in (install.get("unit_frame_variants") or {}).values():
        lists.append(variant.get("upstream") or {})
    for mapping in lists:
        for names in mapping.values():
            folders.update(n.lower() for n in names)
    return folders


def shipped_tocs(folder):
    """Manifest-shaped TOC dicts of a folder's own TOCs under Collection/AddOns."""
    full = os.path.join(ADDONS, folder)
    out = []
    for name in toclib.own_tocs(full):
        toc = toclib.parse_toc(os.path.join(full, name))
        out.append({"file": name, "interface": toc["Interface"], "forever_load": toc["forever_load"],
                    "saved_variables": toc["SavedVariables"],
                    "saved_variables_per_character": toc["SavedVariablesPerCharacter"]})
    return out


def manifest_entries(manifest, keep):
    interface = manifest.get("target_interface", 16001)
    shipped = {t["folder"] for t in manifest.get("third_party") or []}
    entries = {}
    for pkg in manifest["packages"]:
        if pkg.get("role") != "start":
            continue
        phases = sorted({fp["phase"] for fp in pkg.get("feature_phases") or [] if fp.get("use") == "start"})
        how = pkg.get("how_to_use") or {}
        bundle = "required" if REQUIRED_PHASES & set(phases) else "individual"
        for addon in pkg.get("addons") or []:
            folder = addon["folder"]
            if folder.lower() not in keep:
                continue
            source = shipped_tocs(folder) if folder in shipped else addon.get("tocs") or []
            tocs, status = choose_tocs(folder, source, interface)
            if folder.lower() in {k.lower() for k in entries}:
                raise RegistryError("folder %s appears in two start packages" % folder)
            entries[folder] = {
                "package": pkg["name"],
                "version": pkg.get("version"),
                "phases": phases,
                "bundle": bundle,
                "use": how.get("verdict"),
                "tocs": [t["file"] for t in tocs],
                "tocStatus": status,
                "foreverLoad": worst_forever_load(tocs),
                "savedVariables": saved_variables(tocs),
                "frames": [],
                "editable": [],
                "defaults": None,
            }
    return interface, entries


def own_addon_entries(interface, collection, third_party=()):
    entries = {}
    if not os.path.isdir(ADDONS):
        return entries
    meta_by_folder = {c["folder"]: c for c in collection}
    upstream = {t["folder"] for t in third_party}
    for name in sorted(os.listdir(ADDONS)):
        full = os.path.join(ADDONS, name)
        if not os.path.isdir(full) or not toclib.own_tocs(full) or name in upstream:
            continue
        meta = meta_by_folder.get(name)
        if meta is None:
            raise RegistryError("folder %s is neither in the manifest collection nor third_party section "
                                "(add it to extract.py OWN_FOLDERS or the package, run extract.py --no-extract)"
                                % name)
        fork = meta.get("kind") == "fork"
        parsed, status = toclib.tocs_for_interface(full, interface)
        tocs = []
        for toc_name, toc in parsed:
            tocs.append({"file": toc_name, "forever_load": toc["forever_load"],
                         "saved_variables": toc.get("SavedVariables"),
                         "saved_variables_per_character": toc.get("SavedVariablesPerCharacter")})
        entries[name] = {
            "package": meta["base"]["package"] if fork else "DevilForever",
            "version": (parsed[0][1].get("Version") if parsed else None),
            "phases": list(meta.get("phases") or []),
            "variant": meta.get("variant"),
            "bundle": meta.get("bundle") or "individual",
            "use": "modify" if fork else "new",
            "tocs": [t["file"] for t in tocs],
            "tocStatus": status,
            "foreverLoad": worst_forever_load(tocs),
            "savedVariables": saved_variables(tocs),
            "frames": [],
            "editable": [],
            "defaults": None,
        }
    return entries


def core_toc_files():
    names = toclib.own_tocs(CORE_DIR) if os.path.isdir(CORE_DIR) else []
    listed = set()
    for name in names:
        for raw in toclib.read_text(os.path.join(CORE_DIR, name)).splitlines():
            line = raw.strip()
            if line and not line.startswith("#"):
                listed.add(line.replace("\\", "/"))
    return listed


def check_number(value, where):
    if not isinstance(value, (int, float)) or isinstance(value, bool):
        raise RegistryError("%s must be a number" % where)


def is_number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def in_range(value, item):
    return not (("min" in item and value < item["min"]) or ("max" in item and value > item["max"]))


def opt_string(value):
    return value is None or (isinstance(value, str) and value != "")


def valid_default(field, value, item):
    """Same shape rules as Edit.lua validators (position, size, font, color, rows, spacing)."""
    if field == "position":
        return (isinstance(value, dict) and isinstance(value.get("point"), str) and value["point"] != ""
                and opt_string(value.get("relativeTo")) and opt_string(value.get("relativePoint"))
                and is_number(value.get("x")) and is_number(value.get("y")))
    if field == "size":
        return (isinstance(value, dict) and is_number(value.get("width")) and is_number(value.get("height"))
                and value["width"] > 0 and value["height"] > 0
                and in_range(value["width"], item) and in_range(value["height"], item))
    if field == "font":
        if not isinstance(value, dict) or not any(k in value for k in ("path", "size", "flags")):
            return False
        size = value.get("size")
        if size is not None and (not is_number(size) or size <= 0 or not in_range(size, item)):
            return False
        flags = value.get("flags")
        return opt_string(value.get("path")) and (flags is None or isinstance(flags, str))
    if field == "color":
        if not isinstance(value, list) or len(value) not in (3, 4):
            return False
        return all(is_number(c) and 0 <= c <= 1 for c in value)
    if field == "rows":
        return is_number(value) and value >= 1 and int(value) == value and in_range(value, item)
    if field == "spacing":
        return is_number(value) and value >= 0 and in_range(value, item)
    return False


def apply_sv_options(folder, sv, opts):
    where = "registry_extra: %s %s" % (folder, sv["name"])
    unknown = sorted(set(opts) - set(SV_OPTIONS))
    if unknown:
        raise RegistryError("%s unknown option %s" % (where, ", ".join(unknown)))
    split = opts.get("split", "common")
    if split not in SPLITS:
        raise RegistryError("%s split must be common or class" % where)
    restore = opts.get("restore")
    shape = opts.get("shape")
    keys = opts.get("keys")
    if restore is not None and restore not in RESTORES:
        raise RegistryError("%s restore must be one of %s" % (where, ", ".join(RESTORES)))
    if shape is not None and shape not in SHAPES:
        raise RegistryError("%s shape must be plain or acedb" % where)
    if split == "class" and (restore != "profile" or shape != "acedb"):
        raise RegistryError("%s split class needs restore profile and shape acedb" % where)
    if restore == "profile" and split != "class":
        raise RegistryError("%s restore profile needs split class" % where)
    if restore == "keys":
        if (not isinstance(keys, list) or not keys
                or not all(isinstance(k, str) and k for k in keys) or len(set(keys)) != len(keys)):
            raise RegistryError("%s restore keys needs a non-empty list of distinct key strings" % where)
    elif keys is not None:
        raise RegistryError("%s keys only with restore keys" % where)
    if restore in ("whole", "keys", "profile") and shape is None:
        raise RegistryError("%s restore %s needs a shape" % (where, restore))
    sv["split"] = split
    for field, value in (("restore", restore), ("shape", shape), ("keys", keys)):
        if value is not None:
            sv[field] = list(value) if isinstance(value, list) else value


def apply_extra(entries, extra):
    by_lower = {k.lower(): k for k in entries}
    listed = None
    for folder_in, add in sorted((extra.get("addons") or {}).items()):
        folder = by_lower.get(folder_in.lower())
        if folder is None:
            raise RegistryError("registry_extra: folder %s is not registered" % folder_in)
        entry = entries[folder]
        if "bundle" in add:
            if add["bundle"] not in ("required", "individual"):
                raise RegistryError("registry_extra: %s bundle must be required or individual" % folder)
            entry["bundle"] = add["bundle"]
        keys = set()
        for item in add.get("frames") or []:
            if not isinstance(item.get("key"), str) or not item["key"]:
                raise RegistryError("registry_extra: %s frame without key" % folder)
            if item["key"] in keys:
                raise RegistryError("registry_extra: %s frame key %s twice" % (folder, item["key"]))
            keys.add(item["key"])
            tokens = item.get("tokens") or {}
            for field, token in tokens.items():
                if field not in EDIT_FIELDS or not isinstance(token, str):
                    raise RegistryError("registry_extra: %s frame %s token map %s" % (folder, item["key"], field))
            entry["frames"].append({"key": item["key"], "frame": item.get("frame"), "tokens": dict(tokens)})
        for item in add.get("editable") or []:
            where = "registry_extra: %s editable %s.%s" % (folder, item.get("frame"), item.get("field"))
            if item.get("field") not in EDIT_FIELDS:
                raise RegistryError(where + " unknown field")
            if item.get("kind", item["field"]) != item["field"]:
                raise RegistryError(where + " kind must equal field")
            for bound in ("min", "max", "step"):
                if bound in item:
                    check_number(item[bound], where + " " + bound)
            if "min" in item and "max" in item and item["min"] > item["max"]:
                raise RegistryError(where + " min > max")
            if item.get("frame") not in keys:
                raise RegistryError(where + " frame is not a frame key of this folder")
            if "default" in item and not valid_default(item["field"], item["default"], item):
                raise RegistryError(where + " default does not fit the kind or min/max")
            clean = {k: item[k] for k in ("frame", "field", "min", "max", "step", "default") if k in item}
            clean["kind"] = item["field"]
            entry["editable"].append(clean)
        names = {sv["name"]: sv for sv in entry["savedVariables"]}
        for name, opts in sorted((add.get("saved_variables") or {}).items()):
            if name not in names:
                raise RegistryError("registry_extra: %s does not declare saved variable %s" % (folder, name))
            apply_sv_options(folder, names[name], opts or {})
        if add.get("defaults"):
            rel = add["defaults"].replace("\\", "/")
            if rel.startswith("/") or ".." in rel.split("/"):
                raise RegistryError("registry_extra: %s defaults path must stay inside the Core folder" % folder)
            if not os.path.isfile(os.path.join(CORE_DIR, rel)):
                raise RegistryError("registry_extra: %s defaults file missing: %s" % (folder, rel))
            if listed is None:
                listed = core_toc_files()
            if rel not in listed:
                raise RegistryError("registry_extra: %s defaults file not in the Core TOC: %s" % (folder, rel))
            entry["defaults"] = rel


def build(manifest_path=MANIFEST, extra_path=EXTRA, install_path=INSTALL):
    manifest = load_json(manifest_path)
    extra = load_json(extra_path) if os.path.isfile(extra_path) else {}
    keep = shipped_upstream_folders(load_json(install_path))
    keep.update(k.lower() for k in (extra.get("addons") or {}))
    interface, entries = manifest_entries(manifest, keep)
    for name, entry in own_addon_entries(interface, manifest.get("collection") or [],
                                         manifest.get("third_party") or []).items():
        if name.lower() in {k.lower() for k in entries}:
            raise RegistryError("folder %s is both ours and a start package" % name)
        entries[name] = entry
    if extra:
        apply_extra(entries, extra)
    return {"schema": SCHEMA, "interface": interface, "order": sorted(entries, key=str.lower), "addons": entries}


def lua_string(text):
    out = ['"']
    for ch in text:
        code = ord(ch)
        if ch == "\\":
            out.append("\\\\")
        elif ch == '"':
            out.append('\\"')
        elif ch == "\n":
            out.append("\\n")
        elif code < 32 or code == 127:
            out.append("\\%03d" % code)
        else:
            out.append(ch)
    out.append('"')
    return "".join(out)


def lua_key(key):
    if isinstance(key, str) and key.isidentifier() and key.isascii():
        return key
    return "[%s]" % lua_string(str(key))


def lua_value(value, indent):
    pad = "  " * indent
    inner = "  " * (indent + 1)
    if value is None:
        return "nil"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, str):
        return lua_string(value)
    if isinstance(value, list):
        if not value:
            return "{}"
        return "{\n" + "".join("%s%s,\n" % (inner, lua_value(v, indent + 1)) for v in value) + pad + "}"
    if isinstance(value, dict):
        items = [(k, v) for k, v in value.items() if v is not None]
        if not items:
            return "{}"
        items.sort(key=lambda kv: str(kv[0]))
        return "{\n" + "".join("%s%s = %s,\n" % (inner, lua_key(k), lua_value(v, indent + 1))
                               for k, v in items) + pad + "}"
    raise RegistryError("cannot write %r as Lua" % (value,))


def render(registry):
    header = (
        "-- Generated by Collection/tools/genregistry.py from Collection/manifest.json and\n"
        "-- !DevilForever_Core/registry_extra.json. Do not edit by hand; run the generator.\n"
        "local _, Core = ...\n\n"
        "Core.Registry = ")
    return header + lua_value(registry, 0) + "\n"


def main():
    parser = argparse.ArgumentParser(description="Generate !DevilForever_Core/Registry.lua")
    parser.add_argument("--check", action="store_true", help="compare with the file on disk, write nothing")
    parser.add_argument("--out", default=OUTPUT)
    args = parser.parse_args()
    try:
        text = render(build())
    except RegistryError as exc:
        print("ERROR %s" % exc)
        return 2
    data = text.encode("utf-8")
    registry_size = len(data)
    if args.check:
        current = open(args.out, "rb").read() if os.path.isfile(args.out) else b""
        same = current == data
        print("check %s: %s (%d bytes)" % (os.path.relpath(args.out, REPO), "up to date" if same else "OUT OF DATE",
                                           registry_size))
        return 0 if same else 1
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, "wb") as fh:
        fh.write(data)
    print("wrote %s (%d bytes, sha256 %s)" % (os.path.relpath(args.out, REPO), registry_size,
                                               hashlib.sha256(data).hexdigest()))
    return 0


if __name__ == "__main__":
    sys.exit(main())

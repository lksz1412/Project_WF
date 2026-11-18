"""Shared helpers for the Collection tools: TOC parsing and addon-folder discovery.

A TOC file is the per-addon load list read by the WoW client. Metadata lines
have the form ``## Key: value``; keys are matched case-insensitively.
"""

import os
import re

TOC_FIELDS = {
    "interface": "Interface",
    "version": "Version",
    "title": "Title",
    "dependencies": "Dependencies",
    "requireddeps": "RequiredDeps",
    "optionaldeps": "OptionalDeps",
    "savedvariables": "SavedVariables",
    "savedvariablespercharacter": "SavedVariablesPerCharacter",
    "loadondemand": "LoadOnDemand",
    "allowloadgametype": "AllowLoadGameType",
    "excludeloadgametype": "ExcludeLoadGameType",
}

LIST_FIELDS = {
    "Interface",
    "Dependencies",
    "RequiredDeps",
    "OptionalDeps",
    "SavedVariables",
    "SavedVariablesPerCharacter",
    "AllowLoadGameType",
    "ExcludeLoadGameType",
}

# Game-type names taken to mean the Forever client. "camelot" = Forever is an
# inference from TOC naming (e.g. Details_Camelot.toc lists 16001), not verified.
FOREVER_GAME_TYPES = {"forever", "camelot"}

_META_RE = re.compile(r"^##\s*([^:]+?)\s*:\s*(.*?)\s*$")
_CONDITION_RE = re.compile(r"\[\s*(Allow|Exclude)LoadGameType\s+([^\]]*)\]", re.IGNORECASE)


def read_text(path):
    with open(path, "rb") as fh:
        data = fh.read()
    if data.startswith(b"\xef\xbb\xbf"):
        data = data[3:]
    return data.decode("utf-8", errors="replace")


def split_list(value):
    return [item.strip() for item in value.split(",") if item.strip()]


def split_conditions(value):
    """Split ``[Allow|ExcludeLoadGameType a, b]`` groups (prefix or suffix) off a value.

    Returns (rest, conditions) with conditions as [{"kind": "allow"|"exclude", "game_types": [...]}].
    """
    conditions = [
        {"kind": m.group(1).lower(), "game_types": [g.lower() for g in split_list(m.group(2))]}
        for m in _CONDITION_RE.finditer(value)
    ]
    return _CONDITION_RE.sub(" ", value).strip(), conditions


def forever_load(allow, exclude):
    """"yes"/"no" for the header game-type restriction (see FOREVER_GAME_TYPES)."""
    if exclude and FOREVER_GAME_TYPES & {g.lower() for g in exclude}:
        return "no"
    if allow is not None and not FOREVER_GAME_TYPES & {g.lower() for g in allow}:
        return "no"
    return "yes"


def parse_toc(path):
    """Return {field: value} for the fields in TOC_FIELDS plus derived keys.

    List fields become lists merged over every line that repeats the key, with
    ``[..LoadGameType ..]`` groups removed; scalar fields stay strings (last
    line wins); absent fields are None. ``list_lines`` keeps each list line's
    items and conditions; ``game_types`` is the header Allow/Exclude restriction
    and ``forever_load`` its verdict for the Forever client.
    """
    result = {name: None for name in TOC_FIELDS.values()}
    list_lines = {}
    listed_files = 0
    for raw in read_text(path).splitlines():
        line = raw.strip()
        if not line:
            continue
        match = _META_RE.match(line)
        if match:
            key = match.group(1).strip().lower()
            if key in TOC_FIELDS:
                name = TOC_FIELDS[key]
                value = match.group(2)
                if name in LIST_FIELDS:
                    rest, conditions = split_conditions(value)
                    items = split_list(rest)
                    merged = result[name] or []
                    for item in items:
                        if item not in merged:
                            merged.append(item)
                    result[name] = merged
                    list_lines.setdefault(name, []).append({"items": items, "conditions": conditions})
                else:
                    result[name] = value
            continue
        if line.startswith("#"):
            continue
        listed_files += 1
    allow = result.pop("AllowLoadGameType")
    exclude = result.pop("ExcludeLoadGameType")
    list_lines.pop("AllowLoadGameType", None)
    list_lines.pop("ExcludeLoadGameType", None)
    result["game_types"] = {"allow": allow, "exclude": exclude}
    result["forever_load"] = forever_load(allow, exclude)
    result["list_lines"] = list_lines
    result["listed_file_lines"] = listed_files
    return result


def required_deps(toc):
    deps = []
    for name in ("Dependencies", "RequiredDeps"):
        for dep in toc.get(name) or []:
            if dep not in deps:
                deps.append(dep)
    return deps


def toc_matches_folder(folder_name, toc_name):
    """True when ``toc_name`` is the folder's own TOC (``Folder.toc`` or a flavor variant).

    Flavor variants are ``Folder_<flavor>.toc`` and ``Folder-<flavor>.toc``.
    """
    stem = toc_name[:-4] if toc_name.lower().endswith(".toc") else toc_name
    folder = folder_name.lower()
    stem_l = stem.lower()
    if stem_l == folder:
        return True
    for sep in ("_", "-"):
        if stem_l.startswith(folder + sep) and len(stem_l) > len(folder) + 1:
            return True
    return False


def own_tocs(folder_path):
    folder_name = os.path.basename(os.path.normpath(folder_path))
    names = []
    for entry in sorted(os.listdir(folder_path)):
        full = os.path.join(folder_path, entry)
        if entry.lower().endswith(".toc") and os.path.isfile(full):
            if toc_matches_folder(folder_name, entry):
                names.append(entry)
    return names


def find_addon_folders(root):
    """Addon folders under ``root``: directories that hold their own TOC.

    The search descends until it finds such a folder and does not look inside
    it (embedded libraries under an addon are not addon folders). A bare
    ``root`` that is itself an addon folder is returned as is.
    """
    root = os.path.normpath(root)
    if os.path.isdir(root) and own_tocs(root):
        return [root]
    found = []
    for dirpath, dirnames, _files in os.walk(root):
        dirnames.sort()
        keep = []
        for name in dirnames:
            full = os.path.join(dirpath, name)
            if own_tocs(full):
                found.append(full)
            else:
                keep.append(name)
        dirnames[:] = keep
    return sorted(found)


def interface_numbers(toc):
    numbers = []
    for item in toc.get("Interface") or []:
        try:
            numbers.append(int(item))
        except ValueError:
            pass
    return numbers


def tocs_for_interface(folder_path, interface):
    """Parsed TOCs of a folder whose Interface lists ``interface``.

    Among those, TOCs with ``forever_load == "no"`` are dropped when another
    one remains. Returns (list of (toc_name, parsed), status) where status is
    "matched", "forever_load_no" (every matching TOC is restricted away from
    Forever; they are still returned) or "no_interface" (no TOC lists the
    interface; the fallback is the plain ``Folder.toc`` if present, otherwise
    every own TOC).
    """
    names = own_tocs(folder_path)
    parsed = [(n, parse_toc(os.path.join(folder_path, n))) for n in names]
    hits = [(n, t) for n, t in parsed if interface in interface_numbers(t)]
    if hits:
        loadable = [(n, t) for n, t in hits if t["forever_load"] != "no"]
        if loadable:
            return loadable, "matched"
        return hits, "forever_load_no"
    folder_name = os.path.basename(os.path.normpath(folder_path))
    plain = [(n, t) for n, t in parsed if n[:-4].lower() == folder_name.lower()]
    return (plain or parsed), "no_interface"

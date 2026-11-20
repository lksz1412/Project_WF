"""Static checks of the Forever copy of PitBull4 and of its Core defaults file.

Usage:  python3 -I Collection/tests/pitbull4/run.py

The PitBull4 copy (Collection/AddOns/PitBull4) is never run. The cases read its
TOC and XML loader files and its Lua sources as text: every file a 16001 TOC
loads exists, the module set of modules_Camelot.xml, version strings, and that
Collection/patches/PitBull4.patch applied to v4.2.50 (Collection/upstream,
copied to a temporary folder) gives the copy byte for byte. The Core defaults
file Defaults/PitBull4.lua is our own code: it is run in a Lua 5.1 runtime
(lupa) with a stand-in DevilForever_Core.Defaults:Register that records the
spec, and the spec is checked against the module ids, layouts and bars of the
copy. This does not emulate the game client.
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile
import traceback

try:
    import lupa
    from lupa import lua51
except ImportError as exc:  # pragma: no cover - environment check
    sys.stderr.write("lupa with Lua 5.1 is required (pip install lupa): %s\n" % exc)
    sys.exit(2)

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
COPY = os.path.join(REPO, "Collection", "AddOns", "PitBull4")
UPSTREAM = os.path.join(REPO, "Collection", "upstream", "pitbull-unit-frames-4-0-v4.2.50", "PitBull4")
PATCH = os.path.join(REPO, "Collection", "patches", "PitBull4.patch")
DEFAULTS = os.path.join(REPO, "Collection", "AddOns", "!DevilForever_Core", "Defaults", "PitBull4.lua")
VERSION = "v4.2.50-forever.1"

INCLUDE = re.compile(r'<(Script|Include)\s+file="([^"]+)"')
COMMENT = re.compile(r"<!--.*?-->", re.S)
NEW_MODULE = re.compile(r'PitBull4:NewModule\("([^"]+)"')


def read(path):
    with open(path, "rb") as fh:
        return fh.read().decode("utf-8")


def toc_header(path):
    fields = {}
    for line in read(path).splitlines():
        m = re.match(r"##\s*([^:]+):\s*(.*)", line)
        if m:
            fields[m.group(1).strip()] = m.group(2).strip()
    return fields


def toc_files(path):
    return [line.strip() for line in read(path).splitlines()
            if line.strip() and not line.strip().startswith("#")]


def resolve(base_dir, rel):
    return os.path.join(base_dir, *rel.replace("\\", "/").split("/"))


def walk_loader(path, seen, missing, lua_files):
    """Follow Script/Include lines of an XML file (comments dropped); collect Lua files."""
    if path in seen:
        return
    seen.add(path)
    if not os.path.isfile(path):
        missing.append(os.path.relpath(path, COPY))
        return
    if path.lower().endswith(".lua"):
        lua_files.append(path)
        return
    text = COMMENT.sub("", read(path))
    for _, rel in INCLUDE.findall(text):
        walk_loader(resolve(os.path.dirname(path), rel), seen, missing, lua_files)


def loaded_by(toc_name):
    seen, missing, lua_files = set(), [], []
    for rel in toc_files(os.path.join(COPY, toc_name)):
        walk_loader(resolve(COPY, rel), seen, missing, lua_files)
    return missing, lua_files


def module_ids(lua_files):
    ids = set()
    for path in lua_files:
        ids.update(NEW_MODULE.findall(read(path)))
    return ids


def defaults_spec():
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    lua.execute("TEST_cap = {}; DevilForever_Core = {Defaults = {Register = function(self, folder, spec) "
                "TEST_cap.folder = folder; TEST_cap.spec = spec end}}")
    chunk = lua.globals().loadstring(open(DEFAULTS, "rb").read(), b"@Defaults/PitBull4.lua")
    fn, err = chunk if isinstance(chunk, tuple) else (chunk, None)
    if fn is None:
        raise AssertionError("defaults file does not compile: %s" % err)
    fn()

    def py(v):
        if lua51.lua_type(v) == "table":
            return {k: py(x) for k, x in v.items()}
        return v
    cap = py(lua.globals().TEST_cap)
    return cap["folder"], cap["spec"]


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


@case
def forever_tocs_interface_and_version():
    for name in ("PitBull4_Camelot.toc", "PitBull4.toc"):
        h = toc_header(os.path.join(COPY, name))
        eq(h.get("Interface"), "16001", name + " Interface")
        eq(h.get("Version"), VERSION, name + " Version")
        eq(h.get("SavedVariables"), "PitBull4DB", name + " SavedVariables")
        eq(h.get("X-PitBull4-Manifest"), name, name + " manifest line (Compat.GetClientInfo)")
        eq(toc_files(os.path.join(COPY, name)), ["libs.xml", "load.xml", "modules_Camelot.xml"], name + " files")
    main = read(os.path.join(COPY, "Main.lua"))
    eq('PitBull4.version = "%s"' % VERSION in main, True, "Main.lua version string = TOC Version")
    for name in ("PitBull4_Cata.toc", "PitBull4_Mainline.toc", "PitBull4_Mists.toc", "PitBull4_TBC.toc"):
        eq(open(os.path.join(COPY, name), "rb").read(), open(os.path.join(UPSTREAM, name), "rb").read(),
           name + " kept as v4.2.50")


@case
def every_loaded_file_exists():
    for name in ("PitBull4_Camelot.toc", "PitBull4.toc", "PitBull4_Cata.toc", "PitBull4_Mainline.toc",
                 "PitBull4_Mists.toc", "PitBull4_TBC.toc"):
        missing, lua_files = loaded_by(name)
        eq(missing, [], name + " loader references that do not exist")
        eq(len(lua_files) > 50, True, name + " loads the addon's Lua files")
    _, lua_files = loaded_by("PitBull4_Camelot.toc")
    rel = [os.path.relpath(p, COPY).replace(os.sep, "/") for p in lua_files]
    eq(rel[0], "Compat.lua", "Compat.lua loads before the libraries")
    eq("SpecProfiles.lua" in rel, True, "SpecProfiles.lua loaded")
    eq(any("LibDualSpec" in p for p in rel), False, "LibDualSpec not loaded")
    for f in ("Modules/Aura/Forever.lua", "Modules/CastBar/Forever.lua", "Modules/LuaTexts/Forever.lua",
              "Options/NativeControls.lua"):
        eq(f in rel, True, f + " loaded on Forever")


@case
def camelot_module_set_and_class_resources():
    _, lua_files = loaded_by("PitBull4_Camelot.toc")
    ids = module_ids(lua_files)
    for needed in ("HealthBar", "PowerBar", "DruidManaBar", "ComboPoints", "HappinessIcon", "Totems",
                   "Aura", "LuaTexts", "CastBar", "Portrait"):
        eq(needed in ids, True, "module %s loaded on Forever" % needed)
    for absent in ("SoulShards", "Runes", "Chi", "HolyPower", "Essence", "ArcaneCharges", "EnergySpark",
                   "ManaSpark", "CastBarLatency"):
        eq(absent in ids, False, "module %s not loaded on Forever" % absent)


@case
def patch_reproduces_the_copy():
    with tempfile.TemporaryDirectory(prefix="pb4patch.") as tmp:
        target = os.path.join(tmp, "PitBull4")
        shutil.copytree(UPSTREAM, target)
        with open(PATCH, "rb") as fh:
            result = subprocess.run(["patch", "-p1", "--binary", "--quiet", "--batch"], cwd=tmp, stdin=fh,
                                    capture_output=True)
        eq(result.returncode, 0, "patch exit code (%s)" % result.stderr.decode("utf-8", "replace").strip())
        left, right = {}, {}
        for root, store in ((target, left), (COPY, right)):
            for d, _, files in os.walk(root):
                for f in files:
                    full = os.path.join(d, f)
                    with open(full, "rb") as fh:
                        store[os.path.relpath(full, root)] = fh.read()
    eq(sorted(left) == sorted(right), True, "same file list after patching")
    diff = [k for k in left if left[k] != right.get(k)]
    eq(diff, [], "files that differ after patching")


@case
def defaults_spec_matches_the_copy():
    folder, spec = defaults_spec()
    eq(folder, "PitBull4", "registered folder")
    eq(spec["version"], 1, "version")
    targets = [spec["targets"][i] for i in sorted(spec["targets"])]
    eq({(t["savedVariable"], t["shape"], t["profile"]) for t in targets}, {("PitBull4DB", "acedb", "Default")},
       "every target: PitBull4DB, AceDB, profile Default")
    main = targets[0]["values"]
    eq("namespace" in targets[0], False, "first target is the main profile")
    _, lua_files = loaded_by("PitBull4_Camelot.toc")
    ids = module_ids(lua_files)
    names = [t["namespace"] for t in targets[1:]]
    eq(sorted(set(names) - ids), [], "namespaces that are not module ids loaded on Forever")
    eq(len(names), len(set(names)), "one target per namespace")
    layouts = set(main["layouts"])
    eq(all(main["layouts"][n] == {"exists": True} for n in layouts), True, "layouts carry only exists")
    for kind in ("units", "groups"):
        for name, entry in main[kind].items():
            eq(entry.get("layout") in layouts, True, "%s %s names an existing layout" % (kind, name))
    eq(sorted(n for n, u in main["units"].items() if u.get("enabled")),
       sorted(["플레이어", "대상", "대상의 대상", "대상의 대상의 대상", "대상의 소환수", "주시 대상", "주시 대상의 대상",
               "플레이어의 소환수"]),
       "units that are on")
    eq({n: g["unit_group"] for n, g in main["groups"].items()},
       {"파티": "party", "파티원 대상": "partytarget", "파티원 소환수": "partypet"}, "party groups only, no raid group")
    eq((main["made_units"], main["made_groups"], main["group_anchors_updated"]), (True, True, True), "markers")
    appearance = {"position_x", "position_y", "anchor", "relative_point", "relative_to", "scale", "size_x", "size_y",
                  "bar_texture", "font", "font_size", "location", "size", "color", "texture", "vertical_spacing",
                  "horizontal_spacing", "minimapPos", "background_alpha"}

    def keys(t, out):
        for k, v in t.items():
            out.add(k)
            if isinstance(v, dict):
                keys(v, out)
        return out
    found = set()
    for t in targets:
        keys(t["values"], found)
    eq(sorted(found & appearance), [], "appearance keys in the defaults file")
    bars = {"HealthBar", "PowerBar", "CastBar"}
    texts = next(t["values"] for t in targets[1:] if t["namespace"] == "LuaTexts")
    for lay, entry in texts["layouts"].items():
        eq(entry["first"], False, "LuaTexts %s: PitBull4's default texts not added" % lay)
        for name, el in entry["elements"].items():
            eq(el.get("attach_to", "root") in bars | {"root"}, True, "LuaTexts %s/%s attaches to a loaded bar" % (lay, name))
            eq(isinstance(el["code"], str) and el["code"] != "", True, "LuaTexts %s/%s has code" % (lay, name))


@case
def normal_layout_names_match_localization():
    names = {}
    for f in sorted(os.listdir(os.path.join(COPY, "Localization"))):
        if not f.endswith(".lua"):
            continue
        m = re.search(r'^L\["Normal"\] = (.+?)\s*$', read(os.path.join(COPY, "Localization", f)), re.M)
        if m:
            value = m.group(1)
            names[f[:-4]] = "Normal" if value == "true" else value.strip('"')
    eq(len(names), 10, "L[\"Normal\"] in every PitBull4 locale file")
    src = read(DEFAULTS)
    table = re.search(r"local NORMAL_LAYOUT = \(\{(.*?)\}\)", src).group(1)
    listed = dict(re.findall(r'(\w+) = "([^"]+)"', table))
    eq(listed, {k: v for k, v in names.items() if v != "Normal"}, "defaults map = non-\"Normal\" translations")
    eq('or "Normal"' in src, True, "other locales fall back to Normal")


def main():
    passed, failed = 0, []
    for fn in CASES:
        try:
            fn()
            passed += 1
            print("PASS %s" % fn.__name__)
        except Exception:  # noqa: BLE001 - report every failing case
            failed.append(fn.__name__)
            print("FAIL %s" % fn.__name__)
            traceback.print_exc(limit=3)
    print("lupa=%s cases=%d passed=%d failed=%d" % (lupa.__version__, len(CASES), passed, len(failed)))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

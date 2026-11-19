"""Check the Core-to-Quartz handoff using each ZIP's Core, AceDB, and Quartz."""

import argparse
from copy import deepcopy
import json
from pathlib import Path, PurePosixPath
import runpy
import tempfile
from zipfile import ZipFile


TOOLS = Path(__file__).resolve().parent
ROOT = TOOLS.parents[2]
HARNESS = ROOT / "Collection/tests/core/run.py"
session_type = runpy.run_path(str(HARNESS))["Session"]
stub = (TOOLS / "quartz-aura-fixture.lua").read_text(encoding="utf-8")

client_api = """
function UnitFactionGroup() return "Alliance" end
function UnitRace() return "Human", "Human" end
function GetLocale() return "enUS" end
function GetCurrentRegion() return 1 end
function GetCurrentRegionName() return "US" end
strlenutf8 = string.len
strmatch = string.match
LibStub = nil
"""

# The shared fixture doubles the aura containers and AceAddon module activation.
# Register its stand-ins alongside the real AceDB in the same Lua state as Core.
stub = stub[:stub.index("function db:New")] + """
for key, fake in pairs({["AceLocale-3.0"]=locale, ["AceAddon-3.0"]=ace, ["LibSharedMedia-3.0"]=media}) do
  local lib = LibStub:NewLibrary(key, 1)
  for name, func in pairs(fake) do lib[name] = func end
end
""" + stub[stub.index('for _, name in ipairs({"Player", "Target", "Focus", "Pet"})'):]
stub = stub.replace("function init(on)", "function init(expected)")
stub = stub.replace('assert(setup:GetModuleEnabled("Buff") == true)\n  if not on then values.Buff = false end',
                    'assert(setup:GetModuleEnabled("Buff") == expected)')
stub = stub.replace("local values = setup.db.profile.modules\n  setmetatable(values, {__index = function(t) return rawget(t, \"*\") end})\n  ", "")
stub = stub.replace("setup:ApplySettings()\n  local listenerCount", "setup:OnEnable()\n  local listenerCount")
stub = stub.replace("if on then", "if expected then")

QUARTZ = "Interface/AddOns/Quartz/"
CORE = "Interface/AddOns/!DevilForever_Core/"
LIBS = ("libs/LibStub/LibStub.lua", "libs/CallbackHandler-1.0/CallbackHandler-1.0.lua",
        "libs/AceDB-3.0/AceDB-3.0.lua")
CASES = (
    ("fresh", None, False),
    ("existing-enabled", {"profiles": {"Default": {"modules": {"Buff": True}}}}, True),
    ("other-character-default", {"profileKeys": {"Other - Realm": "Default"}}, True),
    ("namespace-default", {"namespaces": {"Player": {"profiles": {"Default": {"x": 73}}}}}, True),
    ("new-default-beside-custom", {"profileKeys": {"Other - Realm": "Custom"},
                                   "namespaces": {"Player": {"profiles": {"Custom": {"x": 73}}}}}, False),
)

PROFILE_CASES = (
    ("fresh", None, False),
    ("existing-explicit", {"profiles": {"Default": {"modules": {"Buff": True, "Swing": False}}}}, True),
    ("existing-missing", {"profiles": {"Default": {"modules": {"Swing": False}}}}, True),
    ("custom", {"profileKeys": {"Hero - Realm": "Custom"},
                "profiles": {"Custom": {"modules": {"Buff": True}}}}, True),
    ("shared-combined", {"profileKeys": {"Other - Realm": "Default"},
                         "namespaces": {"Player": {"profiles": {"Default": {"x": 73}}}}}, True),
    ("shared-character", {"profileKeys": {"Other - Realm": "Default"}}, True),
    ("shared-namespace", {"namespaces": {"Player": {"profiles": {"Default": {"x": 73}}}}}, True),
    ("unrelated-character", {"profileKeys": {"Other - Realm": "Custom"}}, False),
    ("unrelated-namespace", {"namespaces": {"Player": {"profiles": {"Custom": {"x": 73}}}}}, False),
)


def verify_profiles(core):
    policy = (core / "Defaults/Quartz.lua").read_text(encoding="utf-8")
    marker = "      preserveSharedProfiles = true,\n"
    assert policy.count(marker) == 1
    profiles = 0
    for label, saved, keep in PROFILE_CASES:
        for enabled in ((True, False) if label.startswith("shared-") else (True,)):
            session = session_type(registry="shipped", extra_files=(), collection_presets=True,
                                   saved={"Quartz3DB": saved} if saved is not None else None)
            if not enabled:
                session.lua.execute(policy.replace(marker, "", 1))
            session.boot(after=["Quartz"])
            expected = deepcopy(saved) if saved is not None else {}
            applied = not (keep and enabled)
            if applied:
                expected["profiles"] = {"Default": {"modules": {"Buff": False}}}
            status = session.status("Quartz")
            state = "applied" if applied else "existing-profile-kept"
            assert not session.errors() and session.sv("Quartz3DB") == expected, (label, enabled)
            assert status["registered"] and status["loaded"], (label, enabled)
            assert status["targets"]["Quartz3DB"]["state"] == state, (label, enabled, state)
            profiles += 1
    return profiles


def inspect(archive, scratch):
    rows = []
    with ZipFile(archive) as payload:
        toc = payload.read(QUARTZ + "Quartz.toc").decode("utf-8-sig")
        assert "modules\\BuffContainer.lua [AllowLoadGameType mainline]" in toc
        files = [payload.read(QUARTZ + name).decode("utf-8-sig") for name in
                 (*LIBS, "Quartz.lua", "modules/BuffContainer.lua")]
        core = scratch / archive.stem
        core.mkdir()
        for path in payload.namelist():
            if path.startswith(CORE) and not path.endswith("/"):
                member = path.removeprefix(CORE)
                relative = PurePosixPath(member)
                if relative.is_absolute() or '..' in relative.parts or '\\' in member or ':' in member:
                    raise ValueError(f'Invalid Core archive path: {path!r}')
                target = core.joinpath(*relative.parts)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(payload.read(path))
        session_type.__init__.__globals__["CORE_DIR"] = str(core)
        profile_cases = verify_profiles(core)
        for label, saved, enabled in CASES:
            session = session_type(registry="shipped", extra_files=(), collection_presets=True,
                                   saved={"Quartz3DB": saved} if saved is not None else None)
            session.boot(after=["Quartz"])
            assert not session.errors()
            vm = session.lua
            vm.execute(client_api)
            for source in files[:len(LIBS)]:
                vm.execute(source)
            vm.execute(stub)
            for source in files[len(LIBS):]:
                vm.execute(source)
            try:
                data = dict(vm.globals().init(enabled).items())
            except Exception as exc:
                raise RuntimeError(f"{archive.name}: {label} did not activate the expected Quartz modules") from exc
            counts = data["targetTotal"] + data["focusTotal"]
            assert (counts, data["castModulesEnabled"]) == (41 if enabled else 0, 4), data
            rows.append(dict(variant=archive.stem, case=label, Buff=enabled,
                             auraRefreshRequests=counts, castModulesEnabled=data["castModulesEnabled"]))
    return rows, profile_cases


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archives", type=Path, help="Directory containing the three addon variants.")
    parser.add_argument("--report", type=Path, help="Write the Core-to-Quartz results to a new JSON file.")
    args = parser.parse_args()
    receipt = json.loads((TOOLS.parent / "trial-receipt.json").read_text(encoding="utf-8"))
    archives = [args.archives / row["zip"] for row in receipt["packages"]]
    with tempfile.TemporaryDirectory(prefix="packaged-quartz-") as scratch:
        reports = []
        profiles = 0
        for archive in archives:
            rows, cases = inspect(archive, Path(scratch))
            reports.extend(rows)
            profiles += cases
    if args.report:
        with args.report.open("x", encoding="utf-8") as result:
            json.dump({"luaCases": reports, "profileChecks": profiles, "realGameMeasured": False}, result, indent=2)
    print(f"PASS {profiles} packaged Quartz profile cases, including opt-out comparisons")
    print(f"PASS {len(reports)} packaged Core -> AceDB -> Quartz cases")

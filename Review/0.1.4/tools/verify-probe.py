"""Run the separate frame-time probe in Lua 5.1."""

import argparse
from pathlib import Path
from zipfile import ZipFile

from lupa.lua51 import LuaRuntime


REVIEW = Path(__file__).resolve().parents[1]
PROBE = "DevilForever_PerfProbe"
PATH = REVIEW / "diagnostics" / PROBE / "PerfProbe.lua"
SOURCE = PATH.read_text(encoding="utf-8")
STUB = """
SlashCmdList = {}
local frame
messages = {}
function print(message) messages[#messages + 1] = message end
function CreateFrame()
  frame = {visible = true, handlers = {}}
  function frame:Hide() self.visible = false end
  function frame:Show() self.visible = true end
  function frame:SetScript(event, callback) self.handlers[event] = callback end
  return frame
end
C_AddOns = {IsAddOnLoaded = function(name) return name == "!DevilForever_Core" or name == "Quartz" end}
function active() return frame.visible and frame.handlers.OnUpdate ~= nil end
function bound() return frame.handlers.OnUpdate ~= nil end
function tick(elapsed)
  local callback = frame.handlers.OnUpdate
  if frame.visible and callback then callback(frame, elapsed) end
end
"""


def client(settings=None):
    lua = LuaRuntime()
    lua.execute(STUB)
    if settings:
        lua.execute(settings)
    lua.execute(SOURCE)
    return lua, lua.globals()


def launch(g, text):
    g.SlashCmdList.DEVILFOREVERPERF(text)


def finish(g, count=20, dt=0.25):
    for _ in range(count):
        g.tick(dt)


def idle_without_bundle():
    lua, g = client("C_AddOns = nil")
    assert not g.active() and not g.bound()
    finish(g)
    launch(g, "report")
    assert "No completed sample" in g.messages[1]
    assert g.DevilForever_PerfProbeDB is None
    launch(g, "start game-default 5")
    g.tick(0.25)
    finish(g)
    run = g.DevilForever_PerfProbeDB.runs[1]
    assert not g.bound() and len(run.loaded) == 0 and run.frames == 20


def distribution_and_loaded_snapshot():
    lua, g = client()
    launch(g, "start kit-pitbull 5")
    g.tick(0.25)
    finish(g, 19)
    assert g.active()
    lua.execute("C_AddOns.IsAddOnLoaded = function() return false end")
    g.tick(0)
    g.tick(0.5)
    assert not g.active() and not g.bound()
    row = g.DevilForever_PerfProbeDB.runs[1]
    assert row.label == "kit-pitbull"
    assert row.frames == 20 and row.seconds == 5.25
    assert [row.medianMs, row.p95Ms, row.p99Ms, row.maxMs] == [250, 250, 500, 500]
    assert [row.loaded[i] for i in (1, 2)] == ["!DevilForever_Core", "Quartz"]
    launch(g, "report")
    assert "p95 250.00 ms" in g.messages[len(g.messages)]


def restart_and_cancel():
    lua, g = client()
    launch(g, "start first")
    finish(g, 8)
    launch(g, "start ignored 5")
    finish(g, 12)
    assert g.active() and g.DevilForever_PerfProbeDB is None
    launch(g, "cancel")
    assert not g.bound()
    launch(g, "start saved 5")
    g.tick(0.25)
    finish(g)
    assert g.DevilForever_PerfProbeDB.runs[1].label == "saved"


def malformed_commands():
    lua, g = client()
    for request in ("", "start", "start invalid%label", "start x 4", "start x 61", "start x 5 extra",
                    "start " + "s" * 33, "cancel extra", "report extra"):
        launch(g, request)
        assert not g.bound()
    assert g.DevilForever_PerfProbeDB is None


def frames_and_history_are_bounded():
    lua, g = client()
    launch(g, "start limited 60")
    g.tick(0.0005)
    finish(g, 65536, 0.0005)
    assert not g.bound()
    assert g.DevilForever_PerfProbeDB.runs[1].frames == 65536
    assert g.DevilForever_PerfProbeDB.runs[1].limited
    for i in range(13):
        launch(g, f"start r{i} 5")
        g.tick(0.25)
        finish(g)
    runs = g.DevilForever_PerfProbeDB.runs
    assert len(runs) == 12 and runs[1].label == "r1" and runs[12].label == "r12"


def history_reloaded_and_unrecognized_preserved():
    lua, g = client("""DevilForever_PerfProbeDB = {schema=1,runs={
      {label="earlier",frames=20,seconds=5,medianMs=250,p95Ms=250,p99Ms=250,maxMs=250}
    }}""")
    launch(g, "report")
    assert "earlier" in g.messages[1]
    assert not g.bound()
    lua, g = client("DevilForever_PerfProbeDB = {schema=88,sentinel=true}")
    launch(g, "start current 5")
    g.tick(0.25)
    finish(g)
    assert g.DevilForever_PerfProbeDB.schema == 88 and g.DevilForever_PerfProbeDB.sentinel
    launch(g, "report")
    assert "current" in g.messages[len(g.messages)]


def sample_boundary_and_even_median():
    lua, g = client()
    launch(g, "start boundary 5")
    g.tick(6)
    assert g.active() and g.DevilForever_PerfProbeDB is None
    for dt in (1, 1, 2, 2):
        g.tick(dt)
    row = g.DevilForever_PerfProbeDB.runs[1]
    assert (row.frames, row.seconds, row.medianMs, row.p95Ms, row.p99Ms) == (4, 6, 1500, 2000, 2000)
    assert not g.bound()
    launch(g, "report")
    assert "median 1500.00 ms" in g.messages[len(g.messages)]


def malformed_history_preserved():
    lua, g = client("DevilForever_PerfProbeDB = {schema=1,runs={{sentinel=true}}}")
    launch(g, "report")
    assert "No completed sample" in g.messages[1]
    assert g.DevilForever_PerfProbeDB.runs[1].sentinel and not g.bound()


cases = [idle_without_bundle, distribution_and_loaded_snapshot, restart_and_cancel, malformed_commands,
         frames_and_history_are_bounded, history_reloaded_and_unrecognized_preserved,
         sample_boundary_and_even_median, malformed_history_preserved]
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--zip", type=Path, help="Also compare source bytes with a packaged probe.")
    args = parser.parse_args()
    if args.zip:
        with ZipFile(args.zip) as bundle:
            for source in (PATH, PATH.with_name(PROBE + ".toc")):
                assert bundle.read(f"Interface/AddOns/{PROBE}/{source.name}") == source.read_bytes(), source.name
    for case in cases:
        case()
        print("PASS", case.__name__)

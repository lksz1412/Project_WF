"""Count calls per single shipped PitBull4 timer dispatch, with visible derived units."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

source = (Path(__file__).resolve().parents[3] / "Collection/AddOns/PitBull4/Main.lua").read_text(encoding="utf-8-sig")
source = chr(10).join(source.splitlines())
start = source.index("local timer = 0\nlocal wacky_update_rate")
end = source.index("-- Watch for custom anchors", start)
callback_source = source[start:end]
def run(frame_count, gaps):
    vm = LuaRuntime()
    vm.execute("""
timerFrame = {SetScript = function(self, name, callback) self[name] = callback end}
PitBull4 = {num_wacky_frames = ...}
wacky_frames, calls = {}, 0
function UnitGUID(unit) calls = calls + 1; return unit end
for i = 1, PitBull4.num_wacky_frames do
    local frame = {unit = "unit"..i, IsVisible = function() return true end, UpdateGUID = function() end}
    wacky_frames[frame] = true
end
""", frame_count)
    vm.execute(callback_source)
    results = []
    for delta in gaps:
        previous = vm.globals().calls
        vm.globals().timerFrame.OnUpdate(vm.globals().timerFrame, delta)
        results.append(vm.globals().calls - previous)
    return sum(results), max(results)
for gap in (1, 2):
    print("5 visible, one dispatch, elapsed", gap, "seconds, total and peak:", run(5, [gap]))
print("5 visible, 2 seconds spread over 120 frames, total and peak:",run(5, [1/60]*120))

"""First-start defaults of the collection that sit across Core and other addons.

Usage:  python3 -I Collection/tests/firststart/run.py

Reuses the Core test harness (Collection/tests/core/run.py: lupa Lua 5.1
runtime, client stubs, Core files in TOC order) for the SexyMap appearance
fragments, and reads shipped addon files as text for the Grid2 first-start
templates and the nameplate addon's TOC. Nothing of the game client is
emulated; upstream addon files are read, never executed.
"""

import os
import re
import runpy
import sys
import traceback

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ADDONS = os.path.join(REPO, "Collection", "AddOns")
FIXTURE_PRESETS = os.path.join(HERE, "fixtures", "Presets_Screens.lua")

core = runpy.run_path(os.path.join(REPO, "Collection", "tests", "core", "run.py"), run_name="core_harness")
Session, eq, ADDON, SEXYMAP_INIT = core["Session"], core["eq"], core["ADDON"], core["SEXYMAP_INIT"]
lupa = core["lupa"]

# A 1920x1080 screen at UI scale 0.64 (UIParent 768 high): Presets picks "fhd".
UI_SCALE = 0.64
PIXEL_FACTOR = 768 / 1080
SCREEN = {
    "UIParent": {"GetEffectiveScale": lambda self: UI_SCALE, "GetHeight": lambda self: 768},
    "PixelUtil": {"GetPixelToUIUnitFactor": lambda: PIXEL_FACTOR},
}
APPEARANCE_CORE = {"shape", "point", "relpoint", "x", "y", "scale"}


# SexyMap's Borders module setup at its ADDON_LOADED (Borders.lua:827-848): the
# borders table is made only when missing. A test stand-in run after SEXYMAP_INIT.
BORDERS_INIT = r"""
local key = UnitNameUnmodified("player") .. "-" .. GetRealmName()
local p = SexyMap2DB[key]
if type(p) == "string" then p = SexyMap2DB.global end
if type(p.borders) ~= "table" then
  p.borders = {hideBlizzard = true, borders = {}, applyPreset = "Blue Rune Circles",
    backdrop = {scale = 1, show = false, textureColor = {}, borderColor = {}, settings = {
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      insets = {left = 4, top = 4, right = 4, bottom = 4}, edgeSize = 16, tile = false}}}
end
"""
SV_CARRIED = ("SexyMap2DB", "DevilForever_CoreDB", "DevilForever_ProfilesDB", "Grid2DB", "PitBull4DB",
              "ForeverUnitFramesDB")


def carry(s, **changes):
    out = {n: s.sv(n) for n in SV_CARRIED if s.sv(n) is not None}
    out.update(changes)
    return out


def sexymap_session(saved=None, player=None, presets=True, login=True):
    """Core with the test presets, SexyMap's own first-load setup after Core's handler, then login."""
    s = Session(registry="generated", extra_files=(), saved=saved, player=player, globals_=SCREEN,
                preset_files=(FIXTURE_PRESETS,) if presets else ())
    s.lua.execute("function GetPhysicalScreenSize() return 1920, 1080 end")  # read by Presets at Core's ready step
    s.load_addon(ADDON)
    s.g.TEST_loaded["SexyMap"] = True
    s.fire("ADDON_LOADED", "SexyMap")
    s.lua.execute(SEXYMAP_INIT)
    s.lua.execute(BORDERS_INIT)
    if login:
        s.fire("PLAYER_LOGIN")
        s.fire("PLAYER_ENTERING_WORLD", True, False)
    return s


def fragment_states(s):
    states = core["to_py"](s.core.Presets.GetFragmentStatus(s.core.Presets))
    return {k: v["state"] for k, v in states.items() if str(v.get("key", "")).startswith("SexyMap2DB")}


def prints(s):
    return list(core["to_py"](s.g.TEST_prints).values())


def installed():
    """SV state of an install made before the appearance fragment: Hero's profile, Core's applied record."""
    return carry(sexymap_session(presets=False))


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


@case
def sexymap_appearance_fresh_install_from_active_preset():
    s = sexymap_session()
    eq(s.sv("DevilForever_CoreDB")["preset"]["active"], "fhd", "1080 high screen: fhd preset")
    p = s.sv("SexyMap2DB")["Hero-Realm"]
    effective = 192 / 140
    pixel = PIXEL_FACTOR / UI_SCALE
    eq({k: p["core"][k] for k in ("shape", "point", "relpoint")}, {"shape": 130871, "point": "TOPLEFT",
                                                                 "relpoint": "TOPLEFT"}, "shape and anchor")
    eq([round(p["core"][k], 6) for k in ("x", "y", "scale")],
       [round(1292 / effective, 6), round(-860 / effective, 6), round(effective * pixel, 6)], "fhd position and scale")
    eq((p["borders"]["hideBlizzard"], p["borders"]["applyPreset"]), (True, False), "borders merged into SexyMap's table")
    eq((p["core"]["rightClickToConfig"], p["buttons"]["visibilitySettings"]["TimeManagerClockButton"]),
       (False, "never"), "functional defaults still written")
    eq(fragment_states(s), {"fhd|1": "written"}, "the active preset's SexyMap fragment written")
    eq(s.sv("DevilForever_CoreDB")["preset"]["fragments"]["fhd"], {"SexyMap2DB@root:Hero-Realm": 1},
       "recorded per character profile key")
    presets = s.core.Presets
    eq({n: [f["profileKey"] for f in core["to_py"](presets.Get(presets, n))["fragments"].values()]
        for n in ("fhd", "qhd", "uhd")},
       {n: ["Hero-Realm"] for n in ("fhd", "qhd", "uhd")}, "every registered preset carries its own SexyMap fragment")
    eq(s.errors(), [], "no errors")


@case
def sexymap_existing_profile_without_appearance_unchanged_and_noticed():
    saved = installed()
    before = saved["SexyMap2DB"]
    eq(sorted(APPEARANCE_CORE & set(before["Hero-Realm"]["core"])), ["shape"], "premise: no position or scale")
    s = sexymap_session(saved=saved)
    eq(s.sv("SexyMap2DB"), before, "existing profile without point/scale keys left as it is")
    eq(s.status("SexyMap")["targets"]["SexyMap2DB"]["state"], "already", "Core's applied record, as a real install")
    eq(fragment_states(s), {"fhd|1": "kept"}, "appearance fragment kept back for an existing profile")
    notice = [l for l in prints(s) if "/dfp preset fhd" in l]
    eq(len(notice), 1, "one notice line with the /dfp preset hint")


@case
def sexymap_second_character_gets_its_own_appearance():
    first = sexymap_session()
    hero = first.sv("SexyMap2DB")["Hero-Realm"]
    s = sexymap_session(saved=carry(first), player={"name": "Alt"})
    db = s.sv("SexyMap2DB")
    eq(db["Hero-Realm"], hero, "the first character's profile untouched")
    alt = db["Alt-Realm"]
    eq((alt["core"]["shape"], alt["core"]["point"], alt["core"]["autoZoom"]), (130871, "TOPLEFT", 5),
       "appearance merged into the profile SexyMap made (its own keys kept)")
    eq(fragment_states(s), {"fhd|1": "written"}, "fresh per profile key")
    eq(sorted(s.sv("DevilForever_CoreDB")["preset"]["fragments"]["fhd"]),
       ["SexyMap2DB@root:Alt-Realm", "SexyMap2DB@root:Hero-Realm"], "one record per character")
    eq(s.errors(), [], "no errors")


def request_preset(saved, name="fhd", player=None):
    """A session that asks /dfp preset <name>, /dfp go; returns the saved variables for the next load."""
    s = sexymap_session(saved=saved, player=player)
    dfp = core["dfp"]
    dfp(s, "preset " + name)
    dfp(s, "go")
    return carry(s)


@case
def sexymap_request_keeps_global_choice():
    saved = installed()
    glob = {"core": dict(saved["SexyMap2DB"]["Hero-Realm"]["core"])}
    saved["SexyMap2DB"] = {"Hero-Realm": "global", "global": glob}
    nxt = request_preset(saved)
    nxt["SexyMap2DB"] = {"Hero-Realm": "global", "global": glob}
    s = sexymap_session(saved=nxt)
    db = s.sv("SexyMap2DB")
    eq(db["Hero-Realm"], "global", "the global choice is not replaced")
    eq(sorted(APPEARANCE_CORE - {"shape"} & set(db["global"]["core"])), [], "nothing written into the global profile")
    eq(fragment_states(s), {"fhd|1": "skipped"}, "requested fragment skipped")
    eq(s.errors(), [], "no errors (SexyMap's own core defaults intact)")


@case
def sexymap_request_into_profile_made_by_sexymap():
    first = sexymap_session(presets=False)
    saved = carry(first)
    nxt = request_preset(saved, player={"name": "Alt"})
    eq("Alt-Realm" in nxt["SexyMap2DB"], True, "premise: the asking session made Alt's profile")
    nxt["SexyMap2DB"].pop("Alt-Realm")
    s = sexymap_session(saved=nxt, player={"name": "Alt"})
    alt = s.sv("SexyMap2DB")["Alt-Realm"]
    eq((alt["core"]["autoZoom"], alt["core"]["shape"], alt["core"]["point"]), (5, 130871, "TOPLEFT"),
       "nil profile at the request load: SexyMap's own core made, then appearance merged")
    eq(fragment_states(s), {"fhd|1": "written"}, "requested fragment written")


@case
def sexymap_without_presets_registers_no_fragment():
    s = sexymap_session(presets=False)
    p = s.sv("SexyMap2DB")["Hero-Realm"]
    eq(sorted(APPEARANCE_CORE - {"shape"} & set(p["core"])), [], "no appearance without a registered preset")
    eq(fragment_states(s), {}, "no SexyMap fragment")
    eq(s.errors(), [], "no errors")


# Party frame owner (Party.lua) ----------------------------------------------------

GRID2_PARTY = {"party": "By Group", "arena": "By Group", "FrameDisplay": "Grouped"}
UNIT_PARTY = {"party": "None", "arena": "None", "FrameDisplay": "Raid"}
PB4_GROUP_NAMES = ("파티", "파티원 대상", "파티원 소환수")
# C_Timer.After collected and run by the test; a FUF stand-in whose "/fuf set party ..." commands
# store the value in the saved unit profile at once (FUF's own save follows a change by 0.5 s) while
# TEST_fufReady is true (FUF's Commands.IsReady), and nothing otherwise.
PARTY_STUBS = r"""
TEST_timers = {}
C_Timer = {After = function(delay, fn) TEST_timers[#TEST_timers + 1] = {delay, fn} end}
function TEST_runTimers()
  local due = TEST_timers
  TEST_timers = {}
  for _, t in ipairs(due) do t[2]() end
  return #due
end
TEST_fuf, TEST_fufReady = {}, true
SlashCmdList.FOREVERUNITFRAMES = function(msg)
  TEST_fuf[#TEST_fuf + 1] = msg
  if not TEST_fufReady then return end
  local db = ForeverUnitFramesDB
  db.profiles = db.profiles or {}
  db.profiles.Default = db.profiles.Default or {}
  local party = db.profiles.Default.party or {}
  db.profiles.Default.party = party
  if msg == "set party enabled off" then party.enabled = false
  elseif msg == "set party enabled on" then party.enabled = true
  elseif msg == "set party hideBlizzardFrame on" then party.hideBlizzardFrame = true end
end
function UnitFullName() return TEST_player.name, TEST_player.realm end
UnitName = UnitNameUnmodified
TEST_enabled = {}
C_AddOns.GetAddOnEnableState = function(name) return TEST_enabled[name] and 2 or 0 end
"""
FUF_AT_LOAD = r"""
if type(ForeverUnitFramesDB) ~= "table" then ForeverUnitFramesDB = {profiles = {Default = {}}, active = {}} end
"""


def party_session(after, saved=None, player=None, ready=True):
    s = Session(registry="generated", extra_files=(), saved=saved, player=player)
    s.lua.execute(PARTY_STUBS)
    s.g.TEST_fufReady = ready
    for name in after:
        s.g.TEST_enabled[name] = True  # every addon of the session is enabled for the character
    s.load_addon(ADDON)
    for name in after:
        s.load_addon(name)
        if name == "ForeverUnitFrames":
            s.lua.execute(FUF_AT_LOAD)  # FUF makes its saved variable at its own ADDON_LOADED
    s.fire("PLAYER_LOGIN")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    return s


def run_timers(s):
    return s.g.TEST_runTimers()


def grid2_party(s, profile="Hero - Realm"):
    p = s.sv("Grid2DB")["namespaces"]["Grid2Layout"]["profiles"][profile]
    return {"party": p["layouts"]["party"], "arena": p["layouts"]["arena"], "FrameDisplay": p["FrameDisplay"]}


def pb4_enabled(s, profile="Default"):
    groups = s.sv("PitBull4DB")["profiles"][profile]["groups"]
    return {n: groups[n].get("enabled") for n in PB4_GROUP_NAMES}


def fuf_calls(s):
    return list(core["to_py"](s.g.TEST_fuf).values())


def party_record(s):
    return (s.sv("DevilForever_CoreDB").get("party") or {}).get("owner") or {}


def party_state(s):
    return core["to_py"](s.core.Party.GetState(s.core.Party))


PB4_OFF = {n: False for n in PB4_GROUP_NAMES}
PB4_ON = {n: True for n in PB4_GROUP_NAMES}


@case
def party_fresh_pitbull4_install_records_grid2():
    for order in (["Grid2", "PitBull4"], ["PitBull4", "Grid2"]):
        s = party_session(order)
        eq((grid2_party(s), pb4_enabled(s)), (GRID2_PARTY, PB4_OFF), "%s first: Grid2 party, PitBull4 groups off" % order[0])
        eq(party_record(s), {"PitBull4/Default": "grid2"}, "owner recorded on the shared PitBull4 profile")
        eq(s.errors(), [], "no errors")


@case
def party_fresh_fuf_install_grid2_only_after_fuf():
    s = party_session(["ForeverUnitFrames", "Grid2"])
    eq(grid2_party(s), UNIT_PARTY, "Grid2 not ahead of FUF at login")
    eq((party_record(s), party_state(s)["state"]), ({"ForeverUnitFrames/Default": "grid2"}, "fuf-pending"), "recorded")
    eq(run_timers(s), 1, "FUF step after the login delay")
    eq(fuf_calls(s), ["set party hideBlizzardFrame on", "set party enabled off"], "FUF party off, Blizzard's hidden")
    eq(grid2_party(s), UNIT_PARTY, "Grid2 still waits for FUF's saved value")
    run_timers(s)
    eq((grid2_party(s), party_state(s)["state"]), (GRID2_PARTY, "applied"), "Grid2 after the read-back")


@case
def party_fuf_reload_before_command_reconciles_next_session():
    first = party_session(["ForeverUnitFrames", "Grid2"])  # /reload before the FUF step ran
    saved = carry(first)
    eq(grid2_party(first), UNIT_PARTY, "premise: no party on Grid2 yet")
    s = party_session(["ForeverUnitFrames", "Grid2"], saved=saved)
    eq(grid2_party(s), UNIT_PARTY, "next login: Grid2 still waits")
    run_timers(s)
    run_timers(s)
    eq((fuf_calls(s)[-1], grid2_party(s)), ("set party enabled off", GRID2_PARTY), "reconciled to Grid2 only")
    nr = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first), ready=False)
    run_timers(nr)
    run_timers(nr)
    eq((grid2_party(nr), party_state(nr)["state"]), (UNIT_PARTY, "fuf-pending"), "FUF not ready: Grid2 untouched, tried later")


@case
def party_command_applies_to_other_characters_at_login():
    base = party_session(["PitBull4"])  # earlier install without Grid2
    hero = party_session(["Grid2", "PitBull4"], saved=carry(base))
    eq((party_record(hero), grid2_party(hero), pb4_enabled(hero)), ({}, UNIT_PARTY, PB4_ON), "no record: nothing changed")
    alt0 = party_session(["Grid2", "PitBull4"], saved=carry(hero), player={"name": "Alt"})
    eq(grid2_party(alt0, "Alt - Realm"), UNIT_PARTY, "no record: a new Grid2 profile keeps the unit frames' party")
    lines = core["dfp"](hero, "party grid2")
    eq((grid2_party(hero), pb4_enabled(hero), party_record(hero)), (GRID2_PARTY, PB4_OFF, {"PitBull4/Default": "grid2"}),
       "Hero: both sides and the record")
    eq(core["has_line"](lines, "PitBull4/Default", "다음 접속"), True, "says other characters follow at their next login")
    eq(core["has_line"](lines, "/reload"), True, "says a reload shows it")
    saved = carry(hero)
    saved["Grid2DB"]["namespaces"]["Grid2Layout"]["profiles"]["Alt - Realm"] = \
        alt0.sv("Grid2DB")["namespaces"]["Grid2Layout"]["profiles"]["Alt - Realm"]
    saved["Grid2DB"]["profiles"]["Alt - Realm"] = alt0.sv("Grid2DB")["profiles"]["Alt - Realm"]
    alt = party_session(["Grid2", "PitBull4"], saved=saved, player={"name": "Alt"})
    eq(grid2_party(alt, "Alt - Realm"), GRID2_PARTY, "Alt's existing Grid2 profile follows the record at login")
    core["dfp"](alt, "party unitframes")
    back = party_session(["Grid2", "PitBull4"], saved=carry(alt))
    eq((grid2_party(back), pb4_enabled(back)), (UNIT_PARTY, PB4_ON), "and back: Hero reconciled at login")


@case
def party_command_fuf_waits_for_fuf():
    first = party_session(["ForeverUnitFrames"])
    s = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first))
    eq(party_record(s), {}, "existing FUF profile: no record")
    lines = core["dfp"](s, "party grid2")
    eq(core["has_line"](lines, "명령 보냄"), True, "command sent")
    eq(grid2_party(s), UNIT_PARTY, "Grid2 not yet")
    run_timers(s)
    eq(grid2_party(s), GRID2_PARTY, "Grid2 after FUF stored it")
    eq(core["has_line"](prints(s), "Forever Unit Frames 파티 끔 확인"), True, "outcome printed")
    nr = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first), ready=False)
    core["dfp"](nr, "party grid2")
    run_timers(nr)
    eq(grid2_party(nr), UNIT_PARTY, "FUF not ready: Grid2 untouched")
    eq(core["has_line"](prints(nr), "아직 저장하지 않음"), True, "says it was not applied")
    gone = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first))
    gone.lua.execute("SlashCmdList.FOREVERUNITFRAMES = nil")
    eq(core["dfp"](gone, "party grid2"), ["[DF 설정] 안 함: Forever Unit Frames: FUF 명령이 없음 — 바꾼 것 없음"],
       "no FUF handler: refused")
    eq(party_record(gone), {}, "no record made")


@case
def party_combat_and_two_unit_addons():
    base = party_session(["Grid2", "PitBull4"])
    s = party_session(["Grid2", "PitBull4"], saved=carry(base))
    before = (s.sv("Grid2DB"), s.sv("PitBull4DB"), party_record(s))
    s.combat(True)
    eq(core["dfp"](s, "party unitframes"), ["[DF 설정] 안 함: 전투 중 — 바꾼 것 없음"], "refused in combat")
    eq((s.sv("Grid2DB"), s.sv("PitBull4DB"), party_record(s)), before, "nothing written")
    fuf = party_session(["ForeverUnitFrames", "Grid2"])
    fuf.combat(True)
    run_timers(fuf)
    eq(fuf_calls(fuf), [], "FUF step waits for the end of combat")
    fuf.combat(False)
    run_timers(fuf)
    eq(fuf_calls(fuf)[-1], "set party enabled off", "sent after combat")
    both = party_session(["Grid2", "PitBull4", "ForeverUnitFrames"])
    eq((party_record(both), party_state(both)["state"], grid2_party(both)), ({}, "not-settled", UNIT_PARTY),
       "both unit-frame addons loaded: nothing")
    eq(core["has_line"](core["dfp"](both, "party grid2"), "함께 켜져"), True, "command refused")
    eq(core["has_line"](core["dfp"](s, "help"), "/dfp party"), True, "help names the command")
    eq(core["dfp"](s, "party raid"), ["[DF 설정] /dfp party [grid2|unitframes]"], "unknown word")


@case
def party_grid2_shared_default_profile_used():
    base = party_session(["Grid2", "PitBull4"])
    saved = carry(base)
    saved["Grid2DB"].setdefault("global", {})["defaultProfileName"] = "Shared"
    saved["Grid2DB"]["profileKeys"] = {}
    s = party_session(["Grid2", "PitBull4"], saved=saved, player={"name": "Alt"})
    core["dfp"](s, "party unitframes")
    eq(grid2_party(s, "Shared"), UNIT_PARTY, "written into the profile Grid2 uses (global.defaultProfileName)")
    eq(core["has_line"](core["dfp"](s, "party"), "Grid2 Shared: 파티 안 보임"), True, "/dfp party shows it")


@case
def party_login_reconciles_ownership_not_values():
    first = party_session(["Grid2", "PitBull4"])  # fresh install: record grid2
    saved = carry(first)
    lay = saved["Grid2DB"]["namespaces"]["Grid2Layout"]["profiles"]["Hero - Realm"]
    lay["layouts"]["party"], lay["FrameDisplay"] = "By Group & Role", "Always"  # user's choices in Grid2
    saved["PitBull4DB"]["profiles"]["Default"]["groups"]["파티원 소환수"]["enabled"] = True  # user re-enabled party pets
    s = party_session(["Grid2", "PitBull4"], saved=saved)
    eq((s.sv("Grid2DB"), s.sv("PitBull4DB")), (saved["Grid2DB"], saved["PitBull4DB"]),
       "Grid2 layout, window and PitBull4 party pets kept: ownership unchanged")
    # The main party group back on while the record says Grid2 is an ownership contradiction: reconciled.
    again = carry(s)
    again["PitBull4DB"]["profiles"]["Default"]["groups"]["파티"]["enabled"] = True
    r = party_session(["Grid2", "PitBull4"], saved=again)
    eq(pb4_enabled(r), PB4_OFF, "main party group on contradicts the record: party groups off together")
    eq(r.sv("Grid2DB"), again["Grid2DB"], "Grid2 already shows party: its user layout kept")


@case
def party_command_cancels_pending_fuf_step():
    s = party_session(["ForeverUnitFrames", "Grid2"])
    eq(party_state(s)["state"], "fuf-pending", "premise: automatic FUF step waiting")
    lines = core["dfp"](s, "party unitframes")
    eq(core["has_line"](lines, "파티 이미 켜짐"), True, "FUF already draws the party")
    run_timers(s)
    run_timers(s)
    eq(fuf_calls(s), [], "the pending automatic step did not run")
    eq((grid2_party(s), party_record(s)), (UNIT_PARTY, {"ForeverUnitFrames/Default": "unitframes"}), "command kept")


@case
def party_pending_notice_once_per_session():
    first = party_session(["ForeverUnitFrames", "Grid2"], ready=False)
    run_timers(first)
    run_timers(first)
    notice = [l for l in prints(first) if "기록과 아직 다름" in l]
    eq(len(notice), 1, "one chat line while FUF stays pending")
    eq("/dfp party grid2" in notice[0], True, "says what to do")
    s = party_session(["ForeverUnitFrames", "Grid2"], saved=carry(first), ready=False)
    s.combat(True)
    run_timers(s)
    s.combat(False)
    run_timers(s)
    run_timers(s)
    eq(len([l for l in prints(s) if "기록과 아직 다름" in l]), 1, "next session: one line again")


@case
def party_waits_for_unit_addon_via_legacy_enable_state():
    s = Session(registry="generated", extra_files=())
    s.lua.execute(PARTY_STUBS)
    s.lua.execute("C_AddOns.GetAddOnEnableState = nil; TEST_legacy = {}; "
                  "function GetAddOnEnableState(character, name) TEST_legacy[#TEST_legacy + 1] = character .. '|' .. name; "
                  "return (name == 'PitBull4' or name == 'Grid2') and 2 or 0 end")
    s.load_addon(ADDON)
    s.load_addon("Grid2")
    eq(party_record(s), {}, "Grid2 loaded, PitBull4 enabled but not loaded yet: waits")
    s.load_addon("PitBull4")
    s.fire("PLAYER_LOGIN")
    eq(party_record(s), {"PitBull4/Default": "grid2"}, "settled once PitBull4 loaded")
    eq("Hero|PitBull4" in list(core["to_py"](s.g.TEST_legacy).values()), True, "global API asked (character, name)")


def auto_lines(s):
    return [l for l in prints(s) if l.startswith("[DF 설정] 파티 프레임:")]


@case
def party_automatic_writes_named_once_per_session():
    first = party_session(["Grid2", "PitBull4"])  # fresh install: groups off + Grid2 aligned
    lines = auto_lines(first)
    eq(len(lines), 1, "fresh install: one line for all automatic writes")
    eq(all(p in lines[0] for p in ("PitBull4 Default 파티 그룹 끔", "창 Raid→Grouped", "/dfp party unitframes")), True,
       "names the PitBull4 groups, the Grid2 window and the command: " + lines[0])
    again = carry(first)
    again["PitBull4DB"]["profiles"]["Default"]["groups"]["파티"]["enabled"] = True  # user turned it back on
    r = party_session(["Grid2", "PitBull4"], saved=again)
    lines = auto_lines(r)
    eq((len(lines), "PitBull4 Default 파티 그룹 끔" in lines[0], "PitBull4/Default" in lines[0]), (1, True, True),
       "automatic revert: exactly one line naming it and the record")
    quiet = party_session(["Grid2", "PitBull4"], saved=carry(r))
    eq(auto_lines(quiet), [], "nothing written: no line")
    fuf = party_session(["ForeverUnitFrames", "Grid2"])
    run_timers(fuf)
    run_timers(fuf)
    lines = auto_lines(fuf)
    eq((len(lines), "Forever Unit Frames 파티 끔" in lines[0], "파티 칸 None→By Group" in lines[0]), (1, True, True),
       "FUF step: one line after the read-back, Grid2 values named")


@case
def party_command_lists_window_change():
    old = party_session(["Grid2", "PitBull4"])
    s = party_session(["Grid2", "PitBull4"], saved=carry(old))
    lines = core["dfp"](s, "party unitframes")
    eq(core["has_line"](lines, "Grid2 Hero - Realm: 파티 안 보임", "파티 칸 By Group→None", "창 Grouped→Raid"), True,
       "every changed Grid2 value, window included: %r" % lines)


GRID2_OPTIONS = os.path.join(ADDONS, "Grid2Options")


def statusmap_line(text, indicator):
    found = re.findall(r'^m\["%s"\]\s*=\s*\{(.*)\}\s*$' % re.escape(indicator), text, re.M)
    eq(len(found), 1, "one statusMap line for %s" % indicator)
    return found[0]


@case
def grid2_first_start_templates_carry_healer_indicators():
    with open(os.path.join(GRID2_OPTIONS, "Grid2Options.toc"), encoding="utf-8") as fh:
        toc = [line.strip().replace("\\", "/") for line in fh if line.strip().startswith("profiles")]
    eq(toc, ["profiles/ProfileClassic.lua", "profiles/ProfileModern.lua", "profiles/ProfileBlizzard.lua"],
       "the three selectable templates, Classic first (index 1)")
    with open(os.path.join(GRID2_OPTIONS, "GridProfiles.lua"), encoding="utf-8") as fh:
        dialog = fh.read()
    eq(dialog.count("self:SelectDialogGroup( 'Grid2ProfilesDialog', \"1\" )"), 2, "dialog preselects template 1")
    for rel in toc:
        with open(os.path.join(GRID2_OPTIONS, rel), encoding="utf-8") as fh:
            text = fh.read()
        eq('["debuffs-DispellableByMe"]=' in statusmap_line(text, "border"), True, rel + ": dispellable-debuff border")
        eq("range=" in statusmap_line(text, "alpha"), True, rel + ": out-of-range fade")
        eq('["heals-incoming"]=' in statusmap_line(text, "health-bar"), True, rel + ": incoming heals on the health bar")
    with open(os.path.join(ADDONS, "Grid2", "GridDefaultsRetail.lua"), encoding="utf-8") as fh:
        empty = fh.read()
    eq(("debuffs-DispellableByMe" in empty, "range=" in statusmap_line(empty, "alpha")), (False, True),
       "the Empty template: range fade only")


@case
def nameplate_addon_loads_no_probe():
    folder = os.path.join(ADDONS, "DevilForever_Skin_Nameplates")
    with open(os.path.join(folder, "DevilForever_Skin_Nameplates.toc"), encoding="utf-8") as fh:
        lines = [line.strip() for line in fh if line.strip()]
    eq([l for l in lines if not l.startswith("#")], ["NameplateProfiles.lua", "Appearance.lua"], "loaded files")
    eq([l for l in lines if l.startswith("## SavedVariables")], [], "no saved variable")
    s = Session(registry="generated", extra_files=()).boot()
    info = core["to_py"](s.core.GetAddonInfo(s.core, "DevilForever_Skin_Nameplates"))
    eq(info.get("savedVariables") or {}, {}, "registry names no saved variable for the folder")
    eq([os.path.isfile(os.path.join(folder, n)) for n in ("Probe.lua", "SessionProbe.lua")], [True, True],
       "probe files kept in the folder, not loaded")


@case
def orphan_prat_defaults_absent():
    core_dir = os.path.join(ADDONS, "!DevilForever_Core")
    eq(os.path.exists(os.path.join(core_dir, "Defaults", "Prat-3.0.lua")), False, "no Prat defaults file")
    with open(os.path.join(core_dir, "!DevilForever_Core.toc"), encoding="utf-8") as fh:
        eq("Prat" in fh.read(), False, "Core TOC loads no Prat file")


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

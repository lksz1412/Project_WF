-- Layout presets used by the preset tests (registry Registry_Profiles.lua). The
-- fragment list is read from the test global TEST_FRAGMENTS (nil = none).
local Presets = DevilForever_Core.Presets

Presets:Register({
  name = "uhd", screen = {3840, 2160}, uiScale = 0.64,
  edits = {["p.bar"] = {rows = 5, spacing = 6}},
  fragments = TEST_FRAGMENTS,
})

Presets:Register({
  name = "qhd", screen = {2560, 1440},
  edits = {["p.bar"] = {rows = 4}, ["p.chat"] = {rows = 3}},
})

-- Neutral material maps receive panel tint or the native functional bar color.

local art = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\alliance\\"

DevilForever_Core.Theme:RegisterSet("alliance", {
  ["color.panel.background"] = {0.073, 0.12, 0.22, 1},
  ["color.panel.border"] = {0.76, 0.62, 0.37, 1},
  ["color.divider"] = {0.52, 0.49, 0.4, 1},
  ["color.accent"] = {0.45, 0.59, 0.87, 1},
  ["color.text.normal"] = {0.93, 0.95, 0.98, 1},
  ["color.text.highlight"] = {1, 0.97, 0.87, 1},
  ["color.text.disabled"] = {0.69, 0.73, 0.8, 1},
  ["texture.panel"] = art .. "panel.tga",
  ["texture.divider"] = art .. "divider.tga",
  ["texture.ornament.left"] = art .. "left_cap.tga",
  ["texture.ornament.right"] = art .. "right_cap.tga",
  ["texture.statusbar"] = art .. "statusbar.tga",
  ["font.normal"] = STANDARD_TEXT_FONT,
  ["font.header"] = UNIT_NAME_FONT,
  ["font.number"] = STANDARD_TEXT_FONT,
  ["font.size.small"] = 22,
  ["font.size.normal"] = 28,
  ["font.size.header"] = 32,
  ["border.size"] = 1,
  ["spacing.default"] = 8,
})

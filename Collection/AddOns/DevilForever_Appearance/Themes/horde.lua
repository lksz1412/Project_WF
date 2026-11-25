-- Neutral material maps receive panel tint or the native functional bar color.

local art = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\horde\\"

DevilForever_Core.Theme:RegisterSet("horde", {
  ["color.panel.background"] = {0.2, 0.088, 0.073, 1},
  ["color.panel.border"] = {0.66, 0.27, 0.22, 1},
  ["color.divider"] = {0.43, 0.24, 0.19, 1},
  ["color.accent"] = {0.86, 0.34, 0.23, 1},
  ["color.text.normal"] = {0.96, 0.92, 0.86, 1},
  ["color.text.highlight"] = {1, 0.96, 0.88, 1},
  ["color.text.disabled"] = {0.73, 0.68, 0.63, 1},
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

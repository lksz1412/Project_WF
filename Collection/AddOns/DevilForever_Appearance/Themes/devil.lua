-- Neutral material maps receive panel tint or the native functional bar color.

local art = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\devil\\"

DevilForever_Core.Theme:RegisterSet("devil", {
  ["color.panel.background"] = {0.15, 0.105, 0.09, 1},
  ["color.panel.border"] = {0.58, 0.48, 0.4, 1},
  ["color.divider"] = {0.32, 0.28, 0.25, 1},
  ["color.accent"] = {0.75, 0.33, 0.19, 1},
  ["color.text.normal"] = {0.94, 0.91, 0.85, 1},
  ["color.text.highlight"] = {1, 0.96, 0.88, 1},
  ["color.text.disabled"] = {0.71, 0.68, 0.64, 1},
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

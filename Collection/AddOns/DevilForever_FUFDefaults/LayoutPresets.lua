local API = DevilForever_FUFDefaults

-- Physical pixels: width, height, centre x/y; native FUF positions use screen centre.
local presets = {
  fhd = {
    units = {
      player = {240, 48, -402, -104}, target = {340, 56, -452, -168},
      focus = {240, 40, -770, -108}, pet = {240, 32, -622, 74},
      targettarget = {160, 28, -190, -44}, targettargettarget = {140, 28, -30, -44},
      focustarget = {240, 28, -616, -22}, pettarget = {240, 24, -622, 108},
      boss = {300, 40, 790, 236}, party = {190, 48, -853, 218},
    },
    partyPet = {96, 24}, partyTarget = {120, 24, 120},
  },
  qhd = {
    units = {
      player = {280, 56, -450, -216}, target = {400, 64, -510, -292},
      focus = {280, 48, -866, -212}, pet = {280, 40, -884, -64},
      targettarget = {160, 32, -210, -160}, targettargettarget = {160, 32, -42, -160},
      focustarget = {260, 30, -876, -161}, pettarget = {280, 24, -884, -30},
      boss = {320, 48, 1040, 336}, party = {240, 56, -1128, 190},
    },
    partyPet = {120, 28}, partyTarget = {140, 28, 144},
  },
  uhd = {
    units = {
      player = {390, 72, -645, -396}, target = {554, 84, -727, -498},
      focus = {320, 56, -1180, -388}, pet = {360, 42, -1528, -455},
      targettarget = {190, 36, -345, -328}, targettargettarget = {190, 36, -147, -328},
      focustarget = {280, 32, -1200, -336}, pettarget = {360, 34, -1528, -407},
      boss = {340, 56, 1650, 416}, party = {300, 72, -1710, 218},
    },
    partyPet = {150, 36}, partyTarget = {190, 36, 174},
  },
}

local function convert(preset, pixel)
  local function rounded(value) return math.floor(value * pixel + 0.5) end
  local values = {}
  for role, rect in pairs(preset.units) do
    values[role] = {
      width = math.max(40, math.min(600, rounded(rect[1]))),
      height = math.max(8, math.min(200, rounded(rect[2]))),
      x = rounded(rect[3]), y = rounded(rect[4]),
      portraitMode = (role == "player" or role == "target") and "LEFT" or "OFF",
      footerHeight = 0, spacingTitle = 0, spacingPower = 0, spacingPortrait = 0, spacingDocked = 0,
    }
  end
  values.boss.bossSpacing = rounded(12)
  local party = values.party
  party.partyOrientation, party.partyGrowReverse = "VERTICAL", false
  party.partySpacing = rounded(12)
  party.partyPetLayout, party.partyPetSide = "BESIDE", "RIGHT"
  party.partyPetGap, party.partyPetsX, party.partyPetsY = rounded(12), 0, 0
  party.partyPetWidth = rounded(preset.partyPet[1])
  party.partyPetHeight = math.max(10, rounded(preset.partyPet[2]))
  party.partyTargetSide = "RIGHT"
  party.partyTargetWidth = math.max(40, rounded(preset.partyTarget[1]))
  party.partyTargetHeight = math.max(10, rounded(preset.partyTarget[2]))
  party.partyTargetX, party.partyTargetY = rounded(preset.partyTarget[3]), 0
  return values
end

API.LayoutPresets = {}
for name, data in pairs(presets) do
  local definition = data
  API.LayoutPresets[name] = function(pixel) return convert(definition, pixel) end
end

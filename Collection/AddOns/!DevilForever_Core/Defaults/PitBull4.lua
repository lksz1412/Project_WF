-- Functional defaults for PitBull4 (PitBull4DB, AceDB-3.0, account scope), taken from the
-- functional keys of the Devil profile "Wide" (R107 ①): which unit frames and party groups
-- exist and are on, which layout each uses, which modules and bars are on, aura counts and
-- filters, and the text scripts with the bar each belongs to.
--
-- Profile rule: PitBull4 calls AceDB:New("PitBull4DB", defaults, "Default"), so every character
-- without a profileKeys entry uses the shared profile "Default". Core writes only into a profile
-- that is new at its first look (see Defaults.lua): a first install, or a new character whose
-- profile does not exist yet; an existing profile (a spec profile or a user-chosen one included)
-- is left as it is.
-- Module settings are AceDB namespaces of the same saved variable (one target per namespace).
-- Timing: PitBull4 builds its AceDB in OnInitialize at its ADDON_LOADED, after Core's handler,
-- so on a first install Core creates PitBull4DB with these tables first. PitBull4 then finds no
-- global.config_version and runs its config upgrades once; group_anchors_updated keeps the
-- group-offset upgrade from rewriting group positions (that upgrade clears the flag).
-- Unit and group names are the koKR names of the Devil profile and every unit and group names
-- its layout, so the result does not depend on the client language. made_units/made_groups stop
-- PitBull4 from adding its own default frames (its Boss group included).
-- Not here (appearance, Codex): positions, anchors, scale, sizes, spacing, textures, fonts,
-- colours, backgrounds, borders, portraits, text locations and sizes, aura sizes and timers.
-- The layout PitBull4 names L["Normal"] is marked to exist, as its OnNewProfile does
-- (Main.lua OnNewProfile), because a profile Core creates does not pass through it.

local PROFILE = "Default"

-- L["Normal"] of PitBull4's Localization files; the other client languages use "Normal".
local NORMAL_LAYOUT = ({koKR = "보통", ruRU = "Нормальный", zhCN = "普通", zhTW = "普通"})[GetLocale and GetLocale() or ""]
  or "Normal"

local targets = {
  {
    savedVariable = "PitBull4DB",
    shape = "acedb",
    profile = PROFILE,
    values = {
      -- R61: class order for groups sorted by class = the nine Forever classes (classes.md)
      class_order = {"WARRIOR", "PALADIN", "PRIEST", "SHAMAN", "DRUID", "ROGUE", "MAGE", "WARLOCK", "HUNTER"},
      frame_snap = false,
      group_anchors_updated = true,
      -- party only (PitBull4 default show_when); raid frames are Grid2. Party.lua switches these
      -- groups off when Grid2 takes the party (both profiles new, or /dfp party grid2)
      groups = {
        ["파티"] = {
          enabled = true,
          exists = true,
          layout = "파티",
          unit_group = "party",
        },
        ["파티원 대상"] = {
          enabled = true,
          exists = true,
          layout = "대상의대상",
          unit_group = "partytarget",
        },
        ["파티원 소환수"] = {
          enabled = true,
          exists = true,
          layout = "대상의대상",
          unit_group = "partypet",
        },
      },
      layouts = {
        ["대상"] = {
          exists = true,
        },
        ["대상의대상"] = {
          exists = true,
        },
        ["보통"] = {
          exists = true,
        },
        ["파티"] = {
          exists = true,
        },
      },
      lock_movement = true,  -- frames do not move by dragging
      made_groups = true,
      made_units = true,
      minimap_icon = {
        hide = true,
      },
      -- R107 ①: the Devil unit frames; a unit without enabled = true stays off
      units = {
        ["대상"] = {
          enabled = true,
          layout = "대상",
          unit = "target",
        },
        ["대상의 대상"] = {
          enabled = true,
          layout = "대상의대상",
          unit = "targettarget",
        },
        ["대상의 대상의 대상"] = {
          enabled = true,
          layout = "대상의대상",
          unit = "targettargettarget",
        },
        ["주시 대상"] = {
          enabled = true,
          layout = "파티",
          unit = "focus",
        },
        ["주시 대상의 대상"] = {
          enabled = true,
          layout = "대상의대상",
          unit = "focustarget",
        },
        ["주시 대상의 대상의 대상"] = {
          layout = "대상의대상",
          unit = "focustargettarget",
        },
        ["플레이어"] = {
          enabled = true,
          layout = "보통",
          unit = "player",
        },
        ["플레이어의 소환수"] = {
          enabled = true,
          layout = "파티",
          unit = "pet",
        },
        ["플레이어의 소환수의 대상"] = {
          layout = "대상의대상",
          unit = "pettarget",
        },
      },
    },
  },
}

-- Module settings live in AceDB namespaces named after the module id.
local namespaces = {
  -- R107 ①: module switches of the Devil profile; a module or layout not named keeps PitBull4's default
  -- threat is Details!/TinyThreat (R107 ②)
  Aggro = {
    global = {
      enabled = false,
    },
  },
  Aura = {
    layouts = {
      ["대상"] = {
        enabled_weapons = false,
        highlight = false,
        max_buffs = 14,
        max_debuffs = 16,
      },
      ["대상의대상"] = {
        enabled = false,
      },
      ["보통"] = {
        enabled = false,
      },
      ["파티"] = {
        enabled_weapons = false,
        highlight = false,
        layout = {
          buff = {
            filter = "!C",
          },
        },
        max_buffs = 8,
        max_debuffs = 3,
      },
    },
  },
  BlankSpace = {
    global = {
      enabled = false,
    },
  },
  -- cast bars are Quartz (Phase 7)
  CastBar = {
    global = {
      enabled = false,
    },
    layouts = {
      ["대상"] = {
        enabled = false,
      },
      ["대상의대상"] = {
        enabled = false,
      },
      ["보통"] = {
        enabled = false,
      },
      ["파티"] = {
        enabled = false,
      },
    },
  },
  CombatFader = {
    global = {
      enabled = false,
    },
  },
  CombatIcon = {
    layouts = {
      ["대상의대상"] = {
        enabled = false,
      },
      ["파티"] = {
        enabled = false,
      },
    },
  },
  CombatText = {
    global = {
      enabled = false,
    },
  },
  ComboPoints = {
    layouts = {
      ["대상의대상"] = {
        enabled = false,
      },
      ["파티"] = {
        enabled = false,
      },
    },
  },
  ExperienceBar = {
    global = {
      enabled = false,
    },
  },
  -- the Blizzard cast bar is left to Quartz (Phase 7)
  HideBlizzard = {
    global = {
      castbar = false,
    },
  },
  Highlight = {
    global = {
      enabled = false,
    },
  },
  HostilityFader = {
    global = {
      enabled = false,
    },
  },
  LeaderIcon = {
    layouts = {
      ["대상"] = {
        enabled = false,
      },
      ["대상의대상"] = {
        enabled = false,
      },
    },
  },
  LuaTexts = {
    layouts = {
      ["대상"] = {
        elements = {
          ["Lua:마력"] = {
            attach_to = "PowerBar",
            code = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
            events = {
              UNIT_DISPLAYPOWER = true,
              UNIT_MAXPOWER = true,
              UNIT_POWER_FREQUENT = true,
            },
            exists = true,
          },
          ["Lua:백분율"] = {
            code = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
            enabled = false,
            events = {
              UNIT_AURA = true,
              UNIT_HEALTH = true,
              UNIT_MAXHEALTH = true,
            },
            exists = true,
          },
          ["Lua:생명력"] = {
            attach_to = "HealthBar",
            code = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
            events = {
              UNIT_AURA = true,
              UNIT_HEALTH = true,
              UNIT_MAXHEALTH = true,
            },
            exists = true,
          },
          ["Lua:이름"] = {
            code = "local r,g,b = ClassColor(unit)\nreturn '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
            events = {
              PLAYER_FLAGS_CHANGED = true,
              UNIT_NAME_UPDATE = true,
            },
            exists = true,
          },
          ["Lua:직업"] = {
            attach_to = "PowerBar",
            code = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
            events = {
              UNIT_AURA = true,
              UNIT_CLASSIFICATION_CHANGED = true,
              UNIT_LEVEL = true,
            },
            exists = true,
          },
        },
        first = false,
      },
      ["대상의대상"] = {
        elements = {
          ["Lua:이름"] = {
            attach_to = "HealthBar",
            code = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
            events = {
              PLAYER_FLAGS_CHANGED = true,
              UNIT_NAME_UPDATE = true,
            },
            exists = true,
          },
        },
        first = false,
      },
      ["보통"] = {
        elements = {
          ["Lua:마력"] = {
            attach_to = "PowerBar",
            code = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
            events = {
              UNIT_DISPLAYPOWER = true,
              UNIT_MAXPOWER = true,
              UNIT_POWER_FREQUENT = true,
            },
            exists = true,
          },
          ["Lua:백분율"] = {
            code = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
            enabled = false,
            events = {
              UNIT_AURA = true,
              UNIT_HEALTH = true,
              UNIT_MAXHEALTH = true,
            },
            exists = true,
          },
          ["Lua:생명력"] = {
            attach_to = "HealthBar",
            code = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
            events = {
              UNIT_AURA = true,
              UNIT_HEALTH = true,
              UNIT_MAXHEALTH = true,
            },
            exists = true,
          },
          ["Lua:이름"] = {
            code = "local r,g,b = ClassColor(unit)\nreturn '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
            events = {
              PLAYER_FLAGS_CHANGED = true,
              UNIT_NAME_UPDATE = true,
            },
            exists = true,
          },
          ["Lua:직업"] = {
            attach_to = "PowerBar",
            code = "local dr,dg,db = DifficultyColor(unit)\nreturn \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
            events = {
              UNIT_CLASSIFICATION_CHANGED = true,
              UNIT_LEVEL = true,
            },
            exists = true,
          },
        },
        first = false,
      },
      ["파티"] = {
        elements = {
          ["Lua:마력"] = {
            attach_to = "PowerBar",
            code = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
            events = {
              UNIT_DISPLAYPOWER = true,
              UNIT_MAXPOWER = true,
              UNIT_POWER_FREQUENT = true,
            },
            exists = true,
          },
          ["Lua:생명력"] = {
            attach_to = "HealthBar",
            code = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s || %s%%\",HP(unit),Percent(cur,max)",
            events = {
              UNIT_AURA = true,
              UNIT_HEALTH = true,
              UNIT_MAXHEALTH = true,
            },
            exists = true,
          },
          ["Lua:시전"] = {
            attach_to = "CastBar",
            code = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
            events = {
              UNIT_SPELLCAST_CHANNEL_START = true,
              UNIT_SPELLCAST_CHANNEL_STOP = true,
              UNIT_SPELLCAST_CHANNEL_UPDATE = true,
              UNIT_SPELLCAST_DELAYED = true,
              UNIT_SPELLCAST_FAILED = true,
              UNIT_SPELLCAST_INTERRUPTED = true,
              UNIT_SPELLCAST_START = true,
              UNIT_SPELLCAST_STOP = true,
            },
            exists = true,
          },
          ["Lua:이름"] = {
            code = "local r,g,b = ClassColor(unit)\nreturn '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
            events = {
              PLAYER_FLAGS_CHANGED = true,
              UNIT_LEVEL = true,
              UNIT_NAME_UPDATE = true,
            },
            exists = true,
          },
          ["Lua:직업"] = {
            attach_to = "PowerBar",
            code = "if UnitIsPlayer(unit) then\n  local cr,cg,cb = ClassColor(unit)\n  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\nend",
            exists = true,
          },
        },
        first = false,
      },
    },
  },
  PowerBar = {
    layouts = {
      ["대상의대상"] = {
        enabled = false,
      },
    },
  },
  PvPIcon = {
    layouts = {
      ["대상의대상"] = {
        enabled = false,
      },
    },
  },
  -- range fading off (Devil profile)
  RangeFader = {
    global = {
      enabled = false,
    },
  },
  ReputationBar = {
    global = {
      enabled = false,
    },
  },
  RestIcon = {
    layouts = {
      ["대상의대상"] = {
        enabled = false,
      },
      ["파티"] = {
        enabled = false,
      },
    },
  },
  RoleIcon = {
    global = {
      enabled = false,
    },
  },
  Sounds = {
    global = {
      enabled = false,
    },
  },
  ThreatBar = {
    global = {
      enabled = false,
    },
  },
  -- shaman totems are the Dominos totem bar (classes.md SHAMAN)
  Totems = {
    global = {
      enabled = false,
    },
  },
  -- incoming-heal bar off (Devil profile)
  VisualHeal = {
    global = {
      enabled = false,
    },
  },
  VoiceIcon = {
    global = {
      enabled = false,
    },
  },
}

targets[1].values.layouts[NORMAL_LAYOUT] = {exists = true}

local names = {}
for name in pairs(namespaces) do names[#names + 1] = name end
table.sort(names)
for _, name in ipairs(names) do
  targets[#targets + 1] = {savedVariable = "PitBull4DB", shape = "acedb", profile = PROFILE,
                           namespace = name, values = namespaces[name]}
end

DevilForever_Core.Defaults:Register("PitBull4", {version = 1, targets = targets})

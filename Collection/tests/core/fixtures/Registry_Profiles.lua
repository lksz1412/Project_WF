-- Registry used by the save/restore and preset tests instead of the generated one.
local _, Core = ...

Core.Registry = {
  schema = 1,
  interface = 16001,
  order = {"!DevilForever_Core", "PAce", "PChar", "PClass", "PFrames", "PKeys", "PPlain", "PSkip"},
  addons = {
    ["!DevilForever_Core"] = {version = "0.1.0", frames = {}, editable = {},
      savedVariables = {{name = "DevilForever_CoreDB", scope = "account", split = "common", restore = "whole", shape = "plain"},
                        {name = "DevilForever_ProfilesDB", scope = "account", split = "common"}}},
    PPlain = {version = "1.0", frames = {}, editable = {},
      savedVariables = {{name = "PPlainDB", scope = "account", split = "common", restore = "whole", shape = "plain"}}},
    PChar = {version = "1.0", frames = {}, editable = {},
      savedVariables = {{name = "PCharDB", scope = "character", split = "common", restore = "whole", shape = "plain"}}},
    PAce = {version = "2.0", frames = {}, editable = {}, defaults = "Defaults/PAce.lua",
      savedVariables = {{name = "PAceDB", scope = "account", split = "common", restore = "whole", shape = "acedb"}}},
    PKeys = {version = "1.0", frames = {}, editable = {},
      savedVariables = {{name = "PKeysDB", scope = "account", split = "common", restore = "keys", shape = "plain",
                         keys = {"settings", "profiles"}}}},
    PClass = {version = "3.0", frames = {}, editable = {},
      savedVariables = {{name = "PClassDB", scope = "account", split = "class", restore = "profile", shape = "acedb"}}},
    PSkip = {version = "1.0", frames = {}, editable = {},
      savedVariables = {{name = "PSkipDB", scope = "account", split = "common"}}},
    PFrames = {
      savedVariables = {},
      frames = {
        {key = "p.bar", frame = "PBarFrame", tokens = {}},
        {key = "p.chat", frame = "PChatFrame", tokens = {}},
      },
      editable = {
        {frame = "p.bar", field = "rows", kind = "rows", min = 1, max = 10, default = 2},
        {frame = "p.bar", field = "spacing", kind = "spacing", min = 0, max = 20},
        {frame = "p.chat", field = "rows", kind = "rows", min = 1, max = 10},
      },
    },
  },
}

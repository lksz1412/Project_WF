-- Registry used by the logic tests instead of the generated one.
local _, Core = ...

Core.Registry = {
  schema = 1,
  interface = 16001,
  order = {"TestAce", "TestAceChar", "TestChar", "TestFrames", "TestPlain"},
  addons = {
    TestPlain = {savedVariables = {{name = "TestPlainDB", scope = "account", split = "common"}},
                 frames = {}, editable = {}, defaults = "Defaults/Test.lua"},
    TestChar = {savedVariables = {{name = "TestCharDB", scope = "character", split = "class"}},
                frames = {}, editable = {}, defaults = "Defaults/Test.lua"},
    TestAce = {savedVariables = {{name = "TestAceDB", scope = "account", split = "common"}},
               frames = {}, editable = {}, defaults = "Defaults/Test.lua"},
    TestAceChar = {savedVariables = {{name = "TestAceCharDB", scope = "character", split = "common"},
                                     {name = "TestAceCharOtherDB", scope = "account", split = "common"}},
                   frames = {}, editable = {}, defaults = "Defaults/Test.lua"},
    TestFrames = {
      savedVariables = {},
      frames = {
        {key = "test.chat", frame = "ChatFrame1", tokens = {color = "color.accent"}},
        {key = "test.bar", frame = "TestBarFrame", tokens = {}},
      },
      editable = {
        {frame = "test.chat", field = "rows", kind = "rows", min = 1, max = 10, default = 5},
        {frame = "test.chat", field = "font", kind = "font", min = 8, max = 32},
        {frame = "test.chat", field = "size", kind = "size", min = 50, max = 2000},
      },
    },
  },
}

-- Example defaults file used by the logic tests. The version is read from the
-- test global TEST_DEFAULTS_VERSION so a test can raise it between sessions.
local Defaults = DevilForever_Core.Defaults
local version = TEST_DEFAULTS_VERSION or 1

Defaults:Register("TestPlain", {
  version = version,
  targets = {
    {savedVariable = "TestPlainDB", shape = "plain",
     values = {alpha = 1, beta = 2, nested = {gamma = 3, delta = {epsilon = 4}}, shape = {inner = true}}},
  },
})

Defaults:Register("TestChar", {
  version = version,
  targets = {{savedVariable = "TestCharDB", shape = "plain", values = {enabled = true}, createIfMissing = true}},
})

Defaults:Register("TestAce", {
  version = version,
  targets = {
    {savedVariable = "TestAceDB", shape = "acedb", profile = "$className", values = {scale = 1, bars = {count = 8}}},
    {savedVariable = "TestAceDB", shape = "acedb", namespace = "Module", profile = "$className", values = {on = false}},
  },
})

Defaults:Register("TestAceChar", {
  version = version,
  targets = {{savedVariable = "TestAceCharDB", shape = "acedb", values = {on = true}}},
})

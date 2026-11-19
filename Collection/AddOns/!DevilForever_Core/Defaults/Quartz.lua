return DevilForever_Core.Defaults:Register("Quartz", {
  version = 1,
  targets = {
    {
      savedVariable = "Quartz3DB",
      shape = "acedb",
      profile = "Default",
      preserveSharedProfiles = true,
      values = { modules = { Buff = false } },
    },
  },
})

-- Test presets with the collection's names and no values of their own, so a
-- file loaded after the preset files can add fragments to them.
for _, name in ipairs({"fhd", "qhd", "uhd"}) do
  DevilForever_Core.Presets:Register({name = name})
end

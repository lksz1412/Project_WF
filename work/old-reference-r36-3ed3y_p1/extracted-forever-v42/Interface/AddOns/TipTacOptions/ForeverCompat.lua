-- Forever has classic content and the modern tooltip / secret-value API.
local toc = select(4, GetBuildInfo())
local isForever = (toc >= 16000 and toc < 20000)
    or (WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)
if not isForever then return end
local lib = LibStub and LibStub("LibFroznFunctions-1.0", true)
if not lib then return end
local flavor = lib.isWoWFlavor
for key in pairs(flavor) do flavor[key] = false end
flavor.Forever = true
flavor.MN = true
local features = lib.hasWoWFlavor
features.unitCanBeSecretValue = true
features.GetMountFromSpellNotPossibleInCombat = true
features.aurasCooldownCountAndDebuffTypeNotAvailableInCombat = true
-- The retail inspected-specialization tree is not a compatible source for Forever talents.
features.talentsAvailableForInspectedUnit = false

-- Functional defaults for Musca Auras (folder WeakAuras; WeakAurasSaved, plain table, account scope).
--
-- Sounds off on a fresh install: Musca Auras keeps the account-wide mute in
-- WeakAurasSaved.soundsMuted (true, or nil when sounds play). Every aura sound
-- path reads it before playing: RegionPrototype.lua SoundPlayHelper (Play Sound
-- actions and conditions), BlizzardAuraDisplaySounds.lua UpdateSounds (sounds
-- registered with the game for Aura (Modern) auras) and WeakAuras.lua's
-- text-to-speech message action. The player turns sounds on again with
-- /wa mute or the "Mute" box in the /wa window; that stores nil, so the target
-- is fresh-only: a saved variable that exists already (an earlier install of
-- Musca Auras, or the player's own choice) is never written.

local Core = DevilForever_Core

Core.Defaults:Register("WeakAuras", {
  version = 1,
  targets = {
    {
      savedVariable = "WeakAurasSaved",
      shape = "plain",
      freshOnly = true,
      values = {
        soundsMuted = true,   -- R223: no aura sounds by default
      },
    },
  },
})

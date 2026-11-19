local themes = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\"
local media = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\Crests\\"

DevilForever_ChatCrests = {
  horde = {family = "horde", texture = media .. "horde.tga"},
  alliance = {family = "alliance", texture = media .. "alliance.tga"},
  human = {family = "alliance", texture = media .. "human.tga", composition = themes .. "human\\Composition\\", petEdge = themes .. "human\\PetEdge.tga"},
  dwarf = {family = "alliance", texture = media .. "dwarf.tga", composition = themes .. "dwarf\\Composition\\", petEdge = themes .. "dwarf\\PetEdge.tga"},
  gnome = {family = "alliance", texture = media .. "gnome.tga", composition = themes .. "gnome\\Composition\\", petEdge = themes .. "gnome\\PetEdge.tga"},
  nightelf = {family = "alliance", texture = media .. "nightelf.tga", composition = themes .. "nightelf\\Composition\\", petEdge = themes .. "nightelf\\PetEdge.tga"},
  orc = {family = "horde", texture = media .. "orc.tga", composition = themes .. "orc\\Composition\\", petEdge = themes .. "orc\\PetEdge.tga"},
  tauren = {family = "horde", texture = media .. "tauren.tga", composition = themes .. "tauren\\Composition\\", petEdge = themes .. "tauren\\PetEdge.tga"},
  troll = {family = "horde", texture = media .. "troll.tga", composition = themes .. "troll\\Composition\\", petEdge = themes .. "troll\\PetEdge.tga"},
  undead = {family = "horde", texture = media .. "undead.tga", composition = themes .. "undead\\Composition\\", petEdge = themes .. "undead\\PetEdge.tga"},
  skyborne = {family = "alliance", texture = media .. "skyborne.tga", composition = themes .. "skyborne\\Composition\\", petEdge = themes .. "skyborne\\PetEdge.tga"},
  ["skyborne-horde"] = {family = "horde", texture = media .. "skyborne.tga", composition = themes .. "skyborne-horde\\Composition\\", petEdge = themes .. "skyborne-horde\\PetEdge.tga"},
}

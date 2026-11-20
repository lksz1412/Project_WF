local def = (function()
-- Physical-pixel layout. uiScale is omitted until measured in the client.
return {
  ["name"] = "uhd",
  ["screen"] = {3840, 2160},
  ["metrics"] = {
    ["button"] = 80,
    ["icon"] = 64,
    ["padding"] = 8,
    ["gap"] = 2,
    ["menu"] = 36,
    ["chatFont"] = 28,
    ["keyFont"] = 24,
    ["smallFont"] = 22,
  },
  ["edits"] = {
    ["appearance.chat1"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 960,
        ["height"] = 304,
      },
      ["font"] = {
        ["size"] = 28,
      },
    },
    ["appearance.chat2"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 962,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 960,
        ["height"] = 304,
      },
      ["font"] = {
        ["size"] = 28,
      },
    },
    ["appearance.action"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1924,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 670,
        ["height"] = 304,
      },
    },
    ["appearance.minimap"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 2596,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 304,
        ["height"] = 304,
      },
    },
    ["appearance.chat3"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 2902,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 938,
        ["height"] = 304,
      },
      ["font"] = {
        ["size"] = 28,
      },
    },
    ["appearance.ribbon"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -1804,
      },
      ["size"] = {
        ["width"] = 3840,
        ["height"] = 16,
      },
    },
    ["appearance.upper"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 445,
        ["y"] = -1724,
      },
      ["size"] = {
        ["width"] = 2950,
        ["height"] = 80,
      },
    },
    ["appearance.aux"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 760,
        ["y"] = -1636,
      },
      ["size"] = {
        ["width"] = 654,
        ["height"] = 80,
      },
    },
    ["appearance.unitUpper"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1080,
        ["y"] = -1440,
      },
      ["size"] = {
        ["width"] = 390,
        ["height"] = 72,
      },
    },
    ["appearance.unitLower"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 916,
        ["y"] = -1536,
      },
      ["size"] = {
        ["width"] = 554,
        ["height"] = 84,
      },
    },
    ["appearance.ornamentLeft"] = {
      ["color"] = {1, 1, 1, 1},
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 229,
        ["y"] = -1548,
      },
      ["size"] = {
        ["width"] = 256,
        ["height"] = 256,
      },
    },
    ["appearance.ornamentRight"] = {
      ["color"] = {1, 1, 1, 1},
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 3348,
        ["y"] = -1548,
      },
      ["size"] = {
        ["width"] = 256,
        ["height"] = 256,
      },
    },
    ["appearance.status"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -2124,
      },
      ["size"] = {
        ["width"] = 3840,
        ["height"] = 28,
      },
    },
    ["appearance.seam1"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 960,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 304,
      },
    },
    ["appearance.seam2"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1922,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 304,
      },
    },
    ["appearance.seam3"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 2594,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 304,
      },
    },
    ["appearance.seam4"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 2900,
        ["y"] = -1820,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 304,
      },
    },
  },
}
end)()
def.fragments = {}
do
  local additional = (function()
-- Native nameplate targets and Core edit defaults.
local profile = {name="uhd",enemy={width=280,height=30,fontPx=28},friendly={width=280,height=30,fontPx=28},textureToken="texture.statusbar",fontToken="font.normal",preserveHealthThreatColors=true,preserveCastbar=true}
profile.edits = {}
for _, role in ipairs({"enemy", "friendly"}) do
  local values = profile[role]
  profile.edits["nameplates." .. role] = {size = {width = values.width, height = values.height},
    font = {size = values.fontPx}}
end
return profile
  end)()
  for key, edit in pairs(additional.edits) do
    def.edits[key] = edit
  end
end
do
  local additional = (function()
-- Physical pixel values. The skin applies scale locally.
return {["name"] = "uhd", ["screen"] = {3840, 2160}, ["edits"] = {["statusstrip.bar"] = {["position"] = {["point"] = "TOPLEFT", ["relativeTo"] = "UIParent", ["relativePoint"] = "TOPLEFT", ["x"] = 0, ["y"] = -2124}, ["size"] = {["width"] = 3840, ["height"] = 28}, ["font"] = {["size"] = 22}, ["spacing"] = 24}}}
  end)()
  for key, edit in pairs(additional.edits) do
    def.edits[key] = edit
  end
end
do
  local ok, proposal = pcall(function()
-- Appearance-only values. Native auto sizing and all geometry remain in charge.
return {fontName="Devil Forever devil",fontOutline="OUTLINE",barTexture="Devil Forever devil",repBarTexture="Devil Forever devil",petBarTexture="Devil Forever devil",baseColor={r=0.4,g=0.3,b=0.9,a=1},questColor={r=1,g=0.5,b=0,a=0.85},restedColor={r=0.2,g=0.5,b=1,a=0.4},petColor={r=0.1,g=0.8,b=0.2,a=1}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "ExperienceForever", savedVariable = "ExperienceForeverDB", addonVersion = "2.0.4", version = 1, section = "global", values = proposal }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:uhd", "experienceforever-global.fragment.uhd.lua: " .. tostring(proposal))
  end
end
do
  local additional = (function()
return {["name"] = "uhd", ["edits"] = {["dominos.bar1"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.bar2"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.bar3"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.bar4"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.bar5"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.bar6"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.bar7"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.stance"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.pet"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.possess"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}, ["dominos.totem"] = {["font"] = {["size"] = 24, ["flags"] = "OUTLINE"}}}}
  end)()
  for key, edit in pairs(additional.edits) do
    def.edits[key] = edit
  end
end
do
  local ok, proposal = pcall(function()
-- Saved Dominos geometry; native button dimensions and UIParent scale are read at registration.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
local width, height, left, right, top, bottom
if ActionButton1 then
  width, height = ActionButton1:GetSize()
  left, right, top, bottom = ActionButton1:GetHitRectInsets()
end
local hitWidth = width and width - left - right
local hitHeight = height and height - top - bottom
if not pixel or not hitWidth or not hitHeight or hitWidth <= 0 or hitHeight <= 0 then
  DevilForever_Core:Log("skip", "Dominos appearance", "native button or UI scale unavailable at preset registration")
  return {folder = "Dominos", savedVariable = "DominosDB", section = "profile", profile = "$className",
    addonVersion = "12.0.4", version = 1, values = {}}
end
local pixels = 80
-- Onyx uses a 40-unit Normal relative to Masque's 36-unit button.
-- Only 112 of the texture's 128 pixels carry alpha on either axis.
local coverage = (40 / 36) * (112 / 128)
local visualWidth, visualHeight = width * coverage, height * coverage
local frameScale = pixels * pixel / math.max(visualWidth, visualHeight)
local effective = frameScale / pixel
local pitch = (pixels + 2) / effective
local shiftX = left + (pixels / effective - width) / 2
local shiftY = -top - (pixels / effective - height) / 2
local fragment = {folder = "Dominos", savedVariable = "DominosDB", section = "profile", profile = "$className",
  addonVersion = "12.0.4", version = 1, values = {frames = {
    [1] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1932 / effective + shiftX, y = -1828 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [2] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 2260 / effective + shiftX, y = -1828 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [3] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 445 / effective + shiftX, y = -1724 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [4] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1429 / effective + shiftX, y = -1724 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [5] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 2413 / effective + shiftX, y = -1724 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [6] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 24 / effective + shiftX, y = -1168 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [7] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 3490 / effective + shiftX, y = -1168 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [8] = {hidden = true},
    ["class"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 760, y = -1636, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
    ["possess"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 2480, y = -1680, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
    ["totem"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 760, y = -1636, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
  }}}

-- Native pet row uses its own first slot, never the player ActionButton dimensions.
local function fitPet()
  local button = (PetActionBar and PetActionBar.actionButtons and PetActionBar.actionButtons[1]) or PetActionButton1
  local count = NUM_PET_ACTION_SLOTS
  if not button or type(button.GetSize) ~= "function" or type(button.GetHitRectInsets) ~= "function"
      or type(count) ~= "number" or count < 1 or count ~= math.floor(count) then
    DevilForever_Core:Log("skip", "Dominos pet appearance", "native pet slot/count unavailable")
    return
  end
  local width,height = button:GetSize()
  local left,right,top,bottom = button:GetHitRectInsets()
  if type(width) ~= "number" or type(height) ~= "number" or type(left) ~= "number"
      or type(right) ~= "number" or type(top) ~= "number" or type(bottom) ~= "number" then return end
  local hitWidth,hitHeight = width-left-right,height-top-bottom
  local side = math.min(34, (358-2*(count-1))/count)
  if width <= 0 or height <= 0 or hitWidth <= 0 or hitHeight <= 0 or side <= 0 then return end
  local visualWidth,visualHeight = width*coverage,height*coverage
  local scale = side*pixel/math.max(visualWidth,visualHeight)
  local effective = scale/pixel
  fragment.values.frames.pet = {point="TOPLEFT",relPoint="TOPLEFT",
    x=212/effective+left+(visualWidth-width)/2,
    y=-1564/effective-top-(visualHeight-height)/2,
    scale=scale,columns=count,spacing=visualWidth+2/effective-hitWidth,
    rowSpacing=hitWidth-hitHeight,rowOffset=0,padW=0,padH=0,anchor=false,
    isRightToLeft=false,isBottomToTop=false}
end
fitPet()

local function dimensions(buttons)
  local width,height,count=0,0,0
  for _,button in ipairs(buttons) do
    if button and type(button.GetSize)=="function" then
      local w,h=button:GetSize()
      w=math.max(w or 0,button.initialWidth or 0)
      h=math.max(h or 0,button.initialHeight or 0)
      if w>0 and h>0 then width=math.max(width,w);height=math.max(height,h);count=count+1 end
    end
  end
  return width*count,height,count
end
local function fit(id,buttons,x,y,width,height)
  local nativeWidth,nativeHeight,count=dimensions(buttons)
  if count==0 then
    DevilForever_Core:Log("skip","Dominos appearance",id .. " native toolbar dimensions unavailable")
    return
  end
  local ratio=math.min(width/nativeWidth,height/nativeHeight)
  fragment.values.frames[id]={point="TOPLEFT",relPoint="TOPLEFT",x=x/ratio,y=-y/ratio,
    scale=ratio*pixel,columns=count,spacing=0,rowSpacing=0,rowOffset=0,padW=0,padH=0,anchor=false}
end
local menu={}
if MicroMenu and type(MicroMenu.GenerateButtonInfos)=="function" then
  for _,info in ipairs(MicroMenu:GenerateButtonInfos()) do
    if info.button then menu[#menu+1]=info.button end
  end
end
local bags={}
for _,key in ipairs({"CharacterReagentBag0Slot","KeyRingButton","MainMenuBarBackpackButton"}) do
  if _G[key] then bags[#bags+1]=_G[key] end
end
for index=0,(NUM_BAG_SLOTS or 0)-1 do
  local button=_G["CharacterBag" .. index .. "Slot"]
  if button then bags[#bags+1]=button end
end
local x,y,width,height,gap=1932,2080,654,36,8
local queueWidth=height
local available=width-queueWidth-2*gap
local bagsWidth=available*0.42
local menuWidth=available-bagsWidth
fit("menu",menu,x,y,menuWidth,height)
fit("bags",bags,x+menuWidth+gap,y,bagsWidth,height)
fit("queue",QueueStatusButton and {QueueStatusButton} or {},x+width-queueWidth,y,queueWidth,height)
return fragment
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = proposal
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:uhd", "dominos-profile.fragment.uhd.lua: " .. tostring(proposal))
  end
end
do
  local ok, proposal = pcall(function()
-- Apply as a native profile proposal after UIParent/ChatFontNormal exist.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "Feature appearance", "physical pixel factor unavailable at proposal evaluation")
  return {}
end
local _, baseline = ChatFontNormal:GetFont()
if type(baseline) ~= "number" or baseline <= 0 then DevilForever_Core:Log("skip", "PitBull4 appearance", "font baseline unavailable"); return {} end
return {profile = {units = {
  ["플레이어"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=1080*pixel, position_y=-1440*pixel, scale=1, size_x=390/390, size_y=72/72, font_multiplier=1},
  ["대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=916*pixel, position_y=-1536*pixel, scale=1, size_x=554/554, size_y=84/84, font_multiplier=1},
  ["주시 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=580*pixel, position_y=-1440*pixel, scale=1, size_x=320/300, size_y=56/72, font_multiplier=1},
  ["플레이어의 소환수"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=212*pixel, position_y=-1514*pixel, scale=1, size_x=360/300, size_y=42/72, font_multiplier=1},
  ["대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=1480*pixel, position_y=-1390*pixel, scale=1, size_x=190/190, size_y=36/36, font_multiplier=1},
  ["대상의 소환수"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=718*pixel, position_y=-1540*pixel, scale=1, size_x=190/190, size_y=36/36, font_multiplier=1},
  ["대상의 대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=1678*pixel, position_y=-1390*pixel, scale=1, size_x=190/190, size_y=36/36, font_multiplier=1},
  ["주시 대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=580*pixel, position_y=-1400*pixel, scale=1, size_x=280/190, size_y=32/36, font_multiplier=1},
  ["플레이어의 소환수의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=212*pixel, position_y=-1470*pixel, scale=1, size_x=360/190, size_y=34/36, font_multiplier=1},
}, groups = {
  ["파티"]={anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=60*pixel,position_y=-700*pixel,scale=1,size_x=300/300,size_y=72/72,direction="down_right",vertical_spacing=12,horizontal_spacing=12},
  ["파티원 대상"]={anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=534*pixel,position_y=-700*pixel,scale=1,size_x=190/190,size_y=36/36,direction="down_right",vertical_spacing=48,horizontal_spacing=12},
  ["파티원 소환수"]={anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=372*pixel,position_y=-700*pixel,scale=1,size_x=150/190,size_y=36/36,direction="down_right",vertical_spacing=48,horizontal_spacing=12},
}, layouts = {
  ["보통"] = {size_x=390, size_y=72, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=22/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1, indicator_root_outside_margin=8},
  ["대상"] = {size_x=554, size_y=84, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=22/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1},
  ["파티"] = {size_x=300, size_y=72, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=22/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1},
  ["대상의대상"] = {size_x=190, size_y=36, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=22/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1},
}}, namespaces = {Totems = {layouts = {["보통"] = {attach_to="root", location="out_left_top", totem_direction="h", line_break=4, size=36/15, totem_spacing=6*50/36, text_size=18*50/(22*36)}}}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "PitBull4", savedVariable = "PitBull4DB", addonVersion = "v4.2.50-forever.1", version = 1, section = "profile", profile = "Default", values = proposal.profile }
    def.fragments[#def.fragments + 1] = { folder = "PitBull4", savedVariable = "PitBull4DB", addonVersion = "v4.2.50-forever.1", version = 1, section = "profile", profile = "Default", namespace = "Totems", values = proposal.namespaces.Totems }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:uhd", "pitbull4-profile.uhd.fragment.lua: " .. tostring(proposal))
  end
end
do
  local ok, proposal = pcall(function()
-- Native Quartz proposal; rectangles describe the full frame including backdrop.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "Feature appearance", "physical pixel factor unavailable at proposal evaluation")
  return {}
end
return {profile={backgroundcolor={0.035,0.035,0.04}, backgroundalpha=0.86, bordercolor={0.57,0.58,0.59},borderalpha=1}, namespaces={
  Player={point="TOPLEFT",x=1500*pixel,y=-1678*pixel,w=510,h=26,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=20,timefontsize=20,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Target={point="TOPLEFT",x=1500*pixel,y=-1440*pixel,w=380,h=22,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=20,timefontsize=20,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Focus={point="TOPLEFT",x=600*pixel,y=-1500*pixel,w=290,h=22,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=20,timefontsize=20,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Pet={point="TOPLEFT",x=212*pixel,y=-1604*pixel,w=350,h=18,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=20,timefontsize=20,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", values = proposal.profile }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Focus", values = proposal.namespaces["Focus"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Pet", values = proposal.namespaces["Pet"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Player", values = proposal.namespaces["Player"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Target", values = proposal.namespaces["Target"] }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:uhd", "quartz-profile.fragment.uhd.lua: " .. tostring(proposal))
  end
end
do
  local ok, proposal = pcall(function()
-- Native Hekili positions are UIParent CENTER offsets; its GetScale sizes classic frames.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "Feature appearance", "physical pixel factor unavailable at proposal evaluation")
  return {}
end
local native = PixelUtil and PixelUtil.GetNearestPixelSize and PixelUtil.GetNearestPixelSize(1,factor,1)
if type(native) ~= "number" or native <= 0 then DevilForever_Core:Log("skip", "Hekili appearance", "native pixel grid unavailable"); return {} end
return {profile={displays={
  Primary={x=(0.0)*pixel,y=(928.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=80*pixel/native-2,primaryHeight=80*pixel/native-2,zoom=16,queue={width=80*pixel/native-2,height=80*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  AOE={x=(-240.0)*pixel,y=(928.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=80*pixel/native-2,primaryHeight=80*pixel/native-2,zoom=16,queue={width=80*pixel/native-2,height=80*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Cooldowns={x=(240.0)*pixel,y=(928.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=80*pixel/native-2,primaryHeight=80*pixel/native-2,zoom=16,queue={width=80*pixel/native-2,height=80*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Defensives={x=(480.0)*pixel,y=(928.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=80*pixel/native-2,primaryHeight=80*pixel/native-2,zoom=16,queue={width=80*pixel/native-2,height=80*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Interrupts={x=(-480.0)*pixel,y=(928.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=80*pixel/native-2,primaryHeight=80*pixel/native-2,zoom=16,queue={width=80*pixel/native-2,height=80*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=22*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Hekili", savedVariable = "HekiliDB", addonVersion = "v0.8.6", version = 1, section = "profile", profile = "Default", values = proposal.profile }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:uhd", "hekili-profile.fragment.uhd.lua: " .. tostring(proposal))
  end
end
do
  local ok, proposal = pcall(function()
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "Feature appearance", "physical pixel factor unavailable at proposal evaluation")
  return {}
end
return {["namespaces"]={["Grid2Frame"]={["frameWidth"]=154,["frameHeight"]=56,["frameBorder"]=4,["frameBorderDistance"]=0,["frameBorderColor"]={["r"]=0.57,["g"]=0.58,["b"]=0.59,["a"]=1},["frameTexture"]="Devil Forever devil",["font"]="Devil Forever devil",["iconSize"]=28,["orientation"]="HORIZONTAL"},["Grid2Layout"]={["ScaleSize"]=pixel,["Padding"]=6,["Spacing"]=0,["horizontal"]=false,["anchor"]="TOPLEFT",["groupAnchor"]="TOPLEFT",["PosX"]=80*factor,["PosY"]=-240*factor,["BorderTexture"]="None",["BackgroundTexture"]="None"}},["indicators"]={["text-center"]={["font"]="Devil Forever devil",["fontSize"]=22},["icon-center"]={["size"]=26},["icon-left"]={["size"]=22},["icon-right"]={["size"]=22}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Grid2", savedVariable = "Grid2DB", addonVersion = "4.1.13", version = 1, section = "profile", profile = "$char", namespace = "Grid2Frame", values = proposal.namespaces["Grid2Frame"] }
    def.fragments[#def.fragments + 1] = { folder = "Grid2", savedVariable = "Grid2DB", addonVersion = "4.1.13", version = 1, section = "profile", profile = "$char", namespace = "Grid2Layout", values = proposal.namespaces["Grid2Layout"] }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:uhd", "grid2-profile.fragment.uhd.lua: " .. tostring(proposal))
  end
end
do
  local dominos = (function()
return {folder="Masque", savedVariable="MasqueDB", section="profile", profile="Default", addonVersion="12.1.8", version=1, values={Groups={Dominos={SkinID="Onyx",Inherit=false}}}}
  end)()
  local hekili = (function()
return {folder="Masque", savedVariable="MasqueDB", section="profile", profile="Default", addonVersion="12.1.8", version=1, values={Groups={Hekili={SkinID="Onyx",Inherit=false}}}}
  end)()
  for key, setting in pairs(hekili.values.Groups) do
    dominos.values.Groups[key] = setting
  end
  def.fragments[#def.fragments + 1] = dominos
end
DevilForever_Core.Presets:Register(def)

local def = (function()
-- Physical-pixel layout. uiScale is omitted until measured in the client.
return {
  ["name"] = "fhd",
  ["screen"] = {1920, 1080},
  ["metrics"] = {
    ["button"] = 48,
    ["icon"] = 36,
    ["padding"] = 6,
    ["gap"] = 2,
    ["menu"] = 26,
    ["chatFont"] = 18,
    ["keyFont"] = 16,
    ["smallFont"] = 16,
  },
  ["edits"] = {
    ["appearance.chat1"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 438,
        ["height"] = 192,
      },
      ["font"] = {
        ["size"] = 18,
      },
    },
    ["appearance.chat2"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 440,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 438,
        ["height"] = 192,
      },
      ["font"] = {
        ["size"] = 18,
      },
    },
    ["appearance.action"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 880,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 410,
        ["height"] = 192,
      },
    },
    ["appearance.minimap"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1292,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 192,
        ["height"] = 192,
      },
    },
    ["appearance.chat3"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1486,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 434,
        ["height"] = 192,
      },
      ["font"] = {
        ["size"] = 18,
      },
    },
    ["appearance.ribbon"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -850,
      },
      ["size"] = {
        ["width"] = 1920,
        ["height"] = 10,
      },
    },
    ["appearance.upper"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 61,
        ["y"] = -802,
      },
      ["size"] = {
        ["width"] = 1798,
        ["height"] = 48,
      },
    },
    ["appearance.aux"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 260,
        ["y"] = -748,
      },
      ["size"] = {
        ["width"] = 398,
        ["height"] = 48,
      },
    },
    ["appearance.unitUpper"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 438,
        ["y"] = -620,
      },
      ["size"] = {
        ["width"] = 240,
        ["height"] = 48,
      },
    },
    ["appearance.unitLower"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 338,
        ["y"] = -680,
      },
      ["size"] = {
        ["width"] = 340,
        ["height"] = 56,
      },
    },
    ["appearance.ornamentLeft"] = {
      ["color"] = {1, 1, 1, 1},
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 12,
        ["y"] = -706,
      },
      ["size"] = {
        ["width"] = 96,
        ["height"] = 96,
      },
    },
    ["appearance.ornamentRight"] = {
      ["color"] = {1, 1, 1, 1},
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1812,
        ["y"] = -706,
      },
      ["size"] = {
        ["width"] = 96,
        ["height"] = 96,
      },
    },
    ["appearance.status"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -1052,
      },
      ["size"] = {
        ["width"] = 1920,
        ["height"] = 22,
      },
    },
    ["appearance.seam1"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 438,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 192,
      },
    },
    ["appearance.seam2"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 878,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 192,
      },
    },
    ["appearance.seam3"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1290,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 192,
      },
    },
    ["appearance.seam4"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1484,
        ["y"] = -860,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 192,
      },
    },
  },
}
end)()
def.fragments = {}
do
  local additional = (function()
-- Native nameplate targets and Core edit defaults.
local profile = {name="fhd",enemy={width=180,height=20,fontPx=18},friendly={width=180,height=20,fontPx=18},textureToken="texture.statusbar",fontToken="font.normal",preserveHealthThreatColors=true,preserveCastbar=true}
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
return {["name"] = "fhd", ["screen"] = {1920, 1080}, ["edits"] = {["statusstrip.bar"] = {["position"] = {["point"] = "TOPLEFT", ["relativeTo"] = "UIParent", ["relativePoint"] = "TOPLEFT", ["x"] = 0, ["y"] = -1052}, ["size"] = {["width"] = 1920, ["height"] = 22}, ["font"] = {["size"] = 16}, ["spacing"] = 18}}}
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
    DevilForever_Core:Log("skip", "Preset:fhd", "experienceforever-global.fragment.fhd.lua: " .. tostring(proposal))
  end
end
do
  local additional = (function()
return {["name"] = "fhd", ["edits"] = {["dominos.bar1"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.bar2"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.bar3"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.bar4"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.bar5"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.bar6"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.bar7"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.stance"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.pet"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.possess"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}, ["dominos.totem"] = {["font"] = {["size"] = 16, ["flags"] = "OUTLINE"}}}}
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
local pixels = 48
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
    [1] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 886 / effective + shiftX, y = -866 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [2] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1086 / effective + shiftX, y = -866 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [3] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 61 / effective + shiftX, y = -802 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [4] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 661 / effective + shiftX, y = -802 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [5] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1261 / effective + shiftX, y = -802 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [6] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 12 / effective + shiftX, y = -444 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [7] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1710 / effective + shiftX, y = -444 / effective + shiftY, scale = frameScale, columns = 4, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [8] = {hidden = true},
    ["class"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 260, y = -748, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
    ["possess"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1350, y = -758, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
    ["totem"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 260, y = -748, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
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
  local side = math.min(22, (238-2*(count-1))/count)
  if width <= 0 or height <= 0 or hitWidth <= 0 or hitHeight <= 0 or side <= 0 then return end
  local visualWidth,visualHeight = width*coverage,height*coverage
  local scale = side*pixel/math.max(visualWidth,visualHeight)
  local effective = scale/pixel
  fragment.values.frames.pet = {point="TOPLEFT",relPoint="TOPLEFT",
    x=218/effective+left+(visualWidth-width)/2,
    y=-490/effective-top-(visualHeight-height)/2,
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
local x,y,width,height,gap=886,1020,398,26,6
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
    DevilForever_Core:Log("skip", "Preset:fhd", "dominos-profile.fragment.fhd.lua: " .. tostring(proposal))
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
  ["플레이어"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=438*pixel, position_y=-620*pixel, scale=1, size_x=240/240, size_y=48/48, font_multiplier=1},
  ["대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=338*pixel, position_y=-680*pixel, scale=1, size_x=340/340, size_y=56/56, font_multiplier=1},
  ["주시 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=70*pixel, position_y=-628*pixel, scale=1, size_x=240/190, size_y=40/48, font_multiplier=1},
  ["플레이어의 소환수"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=218*pixel, position_y=-450*pixel, scale=1, size_x=240/190, size_y=32/48, font_multiplier=1},
  ["대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=690*pixel, position_y=-570*pixel, scale=1, size_x=160/160, size_y=28/28, font_multiplier=1},
  ["대상의 소환수"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=170*pixel, position_y=-680*pixel, scale=1, size_x=160/160, size_y=28/28, font_multiplier=1},
  ["대상의 대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=860*pixel, position_y=-570*pixel, scale=1, size_x=140/160, size_y=28/28, font_multiplier=1},
  ["주시 대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=224*pixel, position_y=-548*pixel, scale=1, size_x=240/160, size_y=28/28, font_multiplier=1},
  ["플레이어의 소환수의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=218*pixel, position_y=-420*pixel, scale=1, size_x=240/160, size_y=24/28, font_multiplier=1},
}, groups = {
  ["파티"]={anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=12*pixel,position_y=-208*pixel,scale=1,size_x=190/190,size_y=48/48,direction="down_right",vertical_spacing=12,horizontal_spacing=12},
  ["파티원 대상"]={anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=322*pixel,position_y=-208*pixel,scale=1,size_x=120/160,size_y=24/28,direction="down_right",vertical_spacing=36,horizontal_spacing=12},
  ["파티원 소환수"]={anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=214*pixel,position_y=-208*pixel,scale=1,size_x=96/160,size_y=24/28,direction="down_right",vertical_spacing=36,horizontal_spacing=12},
}, layouts = {
  ["보통"] = {size_x=240, size_y=48, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=16/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1, indicator_root_outside_margin=6},
  ["대상"] = {size_x=340, size_y=56, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=16/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1},
  ["파티"] = {size_x=190, size_y=48, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=16/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1},
  ["대상의대상"] = {size_x=160, size_y=28, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=16/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1},
}}, namespaces = {Totems = {layouts = {["보통"] = {attach_to="root", location="out_left_top", totem_direction="h", line_break=4, size=24/15, totem_spacing=4*50/24, text_size=12*50/(16*24)}}}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "PitBull4", savedVariable = "PitBull4DB", addonVersion = "v4.2.50-forever.1", version = 1, section = "profile", profile = "Default", intoExisting = {"units", "groups"}, values = proposal.profile }
    def.fragments[#def.fragments + 1] = { folder = "PitBull4", savedVariable = "PitBull4DB", addonVersion = "v4.2.50-forever.1", version = 1, section = "profile", profile = "Default", namespace = "Totems", values = proposal.namespaces.Totems }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:fhd", "pitbull4-profile.fhd.fragment.lua: " .. tostring(proposal))
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
  Player={point="TOPLEFT",x=690*pixel,y=-756*pixel,w=290,h=18,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=16,timefontsize=16,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Target={point="TOPLEFT",x=690*pixel,y=-604*pixel,w=230,h=16,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=16,timefontsize=16,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Focus={point="TOPLEFT",x=224*pixel,y=-584*pixel,w=190,h=16,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=16,timefontsize=16,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Pet={point="TOPLEFT",x=218*pixel,y=-518*pixel,w=230,h=14,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=16,timefontsize=16,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", values = proposal.profile }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Focus", values = proposal.namespaces["Focus"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Pet", values = proposal.namespaces["Pet"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Player", values = proposal.namespaces["Player"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Target", values = proposal.namespaces["Target"] }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:fhd", "quartz-profile.fragment.fhd.lua: " .. tostring(proposal))
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
  Primary={x=(0.0)*pixel,y=(448.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=56*pixel/native-2,primaryHeight=56*pixel/native-2,zoom=16,queue={width=56*pixel/native-2,height=56*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  AOE={x=(-140.0)*pixel,y=(448.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=56*pixel/native-2,primaryHeight=56*pixel/native-2,zoom=16,queue={width=56*pixel/native-2,height=56*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Cooldowns={x=(140.0)*pixel,y=(448.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=56*pixel/native-2,primaryHeight=56*pixel/native-2,zoom=16,queue={width=56*pixel/native-2,height=56*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Defensives={x=(280.0)*pixel,y=(448.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=56*pixel/native-2,primaryHeight=56*pixel/native-2,zoom=16,queue={width=56*pixel/native-2,height=56*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Interrupts={x=(-280.0)*pixel,y=(448.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=56*pixel/native-2,primaryHeight=56*pixel/native-2,zoom=16,queue={width=56*pixel/native-2,height=56*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=16*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Hekili", savedVariable = "HekiliDB", addonVersion = "v0.8.6", version = 1, section = "profile", profile = "Default", values = proposal.profile }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:fhd", "hekili-profile.fragment.fhd.lua: " .. tostring(proposal))
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
return {["namespaces"]={["Grid2Frame"]={["frameWidth"]=96,["frameHeight"]=32,["frameBorder"]=2,["frameBorderDistance"]=0,["frameBorderColor"]={["r"]=0.57,["g"]=0.58,["b"]=0.59,["a"]=1},["frameTexture"]="Devil Forever devil",["font"]="Devil Forever devil",["iconSize"]=22,["orientation"]="HORIZONTAL"},["Grid2Layout"]={["ScaleSize"]=pixel,["Padding"]=4,["Spacing"]=0,["horizontal"]=false,["anchor"]="TOPLEFT",["groupAnchor"]="TOPLEFT",["PosX"]=24*factor,["PosY"]=-164*factor,["BorderTexture"]="None",["BackgroundTexture"]="None"}},["indicators"]={["text-center"]={["font"]="Devil Forever devil",["fontSize"]=16},["icon-center"]={["size"]=20},["icon-left"]={["size"]=16},["icon-right"]={["size"]=16}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Grid2", savedVariable = "Grid2DB", addonVersion = "4.1.13", version = 1, section = "profile", profile = "$char", namespace = "Grid2Frame", values = proposal.namespaces["Grid2Frame"] }
    def.fragments[#def.fragments + 1] = { folder = "Grid2", savedVariable = "Grid2DB", addonVersion = "4.1.13", version = 1, section = "profile", profile = "$char", namespace = "Grid2Layout", values = proposal.namespaces["Grid2Layout"] }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:fhd", "grid2-profile.fragment.fhd.lua: " .. tostring(proposal))
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

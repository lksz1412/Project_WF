local def = (function()
-- Physical-pixel layout. uiScale is omitted until measured in the client.
return {
  ["name"] = "qhd",
  ["screen"] = {2560, 1440},
  ["metrics"] = {
    ["button"] = 56,
    ["icon"] = 44,
    ["padding"] = 6,
    ["gap"] = 2,
    ["menu"] = 32,
    ["chatFont"] = 22,
    ["keyFont"] = 19,
    ["smallFont"] = 18,
  },
  ["edits"] = {
    ["appearance.chat1"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 620,
        ["height"] = 224,
      },
      ["font"] = {
        ["size"] = 22,
      },
    },
    ["appearance.chat2"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 622,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 620,
        ["height"] = 224,
      },
      ["font"] = {
        ["size"] = 22,
      },
    },
    ["appearance.action"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1244,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 474,
        ["height"] = 224,
      },
    },
    ["appearance.minimap"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1720,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 224,
        ["height"] = 224,
      },
    },
    ["appearance.chat3"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1946,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 614,
        ["height"] = 224,
      },
      ["font"] = {
        ["size"] = 22,
      },
    },
    ["appearance.ribbon"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -1174,
      },
      ["size"] = {
        ["width"] = 2560,
        ["height"] = 12,
      },
    },
    ["appearance.upper"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 237,
        ["y"] = -1118,
      },
      ["size"] = {
        ["width"] = 2086,
        ["height"] = 56,
      },
    },
    ["appearance.aux"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 474,
        ["y"] = -1056,
      },
      ["size"] = {
        ["width"] = 462,
        ["height"] = 56,
      },
    },
    ["appearance.unitUpper"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 690,
        ["y"] = -908,
      },
      ["size"] = {
        ["width"] = 280,
        ["height"] = 56,
      },
    },
    ["appearance.unitLower"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 570,
        ["y"] = -980,
      },
      ["size"] = {
        ["width"] = 400,
        ["height"] = 64,
      },
    },
    ["appearance.ornamentLeft"] = {
      ["color"] = {1, 1, 1, 1},
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 80,
        ["y"] = -998,
      },
      ["size"] = {
        ["width"] = 176,
        ["height"] = 176,
      },
    },
    ["appearance.ornamentRight"] = {
      ["color"] = {1, 1, 1, 1},
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 2304,
        ["y"] = -998,
      },
      ["size"] = {
        ["width"] = 176,
        ["height"] = 176,
      },
    },
    ["appearance.status"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 0,
        ["y"] = -1410,
      },
      ["size"] = {
        ["width"] = 2560,
        ["height"] = 24,
      },
    },
    ["appearance.seam1"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 620,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 224,
      },
    },
    ["appearance.seam2"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1242,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 224,
      },
    },
    ["appearance.seam3"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1718,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 224,
      },
    },
    ["appearance.seam4"] = {
      ["position"] = {
        ["point"] = "TOPLEFT",
        ["relativeTo"] = "DevilForever_AppearanceRoot",
        ["relativePoint"] = "TOPLEFT",
        ["x"] = 1944,
        ["y"] = -1186,
      },
      ["size"] = {
        ["width"] = 2,
        ["height"] = 224,
      },
    },
  },
}
end)()
def.fragments = {}
do
  local additional = (function()
-- Native nameplate targets and Core edit defaults.
local profile = {name="qhd",enemy={width=220,height=24,fontPx=22},friendly={width=220,height=24,fontPx=22},textureToken="texture.statusbar",fontToken="font.normal",preserveHealthThreatColors=true,preserveCastbar=true}
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
return {["name"] = "qhd", ["screen"] = {2560, 1440}, ["edits"] = {["statusstrip.bar"] = {["position"] = {["point"] = "TOPLEFT", ["relativeTo"] = "UIParent", ["relativePoint"] = "TOPLEFT", ["x"] = 0, ["y"] = -1410}, ["size"] = {["width"] = 2560, ["height"] = 24}, ["font"] = {["size"] = 18}, ["spacing"] = 18}}}
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
    DevilForever_Core:Log("skip", "Preset:qhd", "experienceforever-global.fragment.qhd.lua: " .. tostring(proposal))
  end
end
do
  local additional = (function()
return {["name"] = "qhd", ["edits"] = {["dominos.bar1"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.bar2"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.bar3"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.bar4"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.bar5"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.bar6"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.bar7"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.stance"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.pet"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.possess"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}, ["dominos.totem"] = {["font"] = {["size"] = 19, ["flags"] = "OUTLINE"}}}}
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
local pixels = 56
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
    [1] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 237 / effective + shiftX, y = -1118 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, rowOffset = 0, isRightToLeft = false, isBottomToTop = false, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [2] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 933 / effective + shiftX, y = -1118 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, rowOffset = 0, isRightToLeft = false, isBottomToTop = false, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [3] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1629 / effective + shiftX, y = -1118 / effective + shiftY, scale = frameScale, columns = 12, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, rowOffset = 0, isRightToLeft = false, isBottomToTop = false, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [4] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1250 / effective + shiftX, y = -1192 / effective + shiftY, scale = frameScale, columns = 8, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, rowOffset = 0, isRightToLeft = false, isBottomToTop = false, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false},
    [5] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1250 / effective + shiftX, y = -1250 / effective + shiftY, scale = frameScale, columns = 8, spacing = pitch - hitWidth, rowSpacing = hitWidth - hitHeight, rowOffset = 0, isRightToLeft = false, isBottomToTop = false, showEmptyButtons = true, padW = 0, padH = 0, anchor = false, hidden = false, dfTail = true},
    [6] = {hidden = true},
    [7] = {hidden = true},
    [8] = {hidden = true},
    ["class"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 474, y = -1056, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
    ["possess"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 1810, y = -1074, scale = pixel, spacing = 2, padW = 0, padH = 0, anchor = false},
    ["totem"] = {point = "TOPLEFT", relPoint = "TOPLEFT", x = 585*30/52, y = -1056*30/52, scale = pixel*52/30, spacing = 2, padW = 0, padH = 0, anchor = false},
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
  local side = math.min(26, (278-2*(count-1))/count)
  if width <= 0 or height <= 0 or hitWidth <= 0 or hitHeight <= 0 or side <= 0 then return end
  local visualWidth,visualHeight = width*coverage,height*coverage
  local scale = side*pixel/math.max(visualWidth,visualHeight)
  local effective = scale/pixel
  fragment.values.frames.pet = {point="TOPLEFT",relPoint="TOPLEFT",
    x=256/effective+left+(visualWidth-width)/2,
    y=-806/effective-top-(visualHeight-height)/2,
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
local x,y,width,height,gap=1250,1368,462,32,6
local queueWidth=height
local available=width-queueWidth-2*gap
local bagsWidth=available*0.42
local menuWidth=available-bagsWidth
fit("menu",menu,x,y,menuWidth,height)
fit("bags",bags,x+menuWidth+gap,y,bagsWidth,height)
fit("queue",QueueStatusButton and {QueueStatusButton} or {},x+width-queueWidth,y,queueWidth,height)
-- Snapshot only geometry owned by this preset; manual edits release runtime management.
local geometryKeys = {"point", "relPoint", "x", "y", "scale", "columns", "spacing", "rowSpacing",
  "rowOffset", "padW", "padH", "anchor", "isRightToLeft", "isBottomToTop"}
for _, values in pairs(fragment.values.frames) do
  if values.scale then
    values.dfPixel = pixel
    values.dfGeometry = {}
    for _, key in ipairs(geometryKeys) do values.dfGeometry[key] = values[key] end
  end
end
return fragment
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = proposal
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:qhd", "dominos-profile.fragment.qhd.lua: " .. tostring(proposal))
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
local proposal = {profile = {units = {
  ["플레이어"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=585*pixel, position_y=-897*pixel, scale=1, size_x=342/342, size_y=96/96, font_multiplier=1},
  ["대상"] = {anchor="TOPRIGHT", relative_point="TOPRIGHT", relative_to="0", position_x=-585*pixel, position_y=-897*pixel, scale=1, size_x=342/342, size_y=96/96, font_multiplier=1},
  ["주시 대상"] = {anchor="TOPRIGHT", relative_point="TOPRIGHT", relative_to="0", position_x=-691*pixel, position_y=-783*pixel, scale=1, size_x=1, size_y=1, font_multiplier=1, layout="소환수와 주시", dfCompanion=true},
  ["플레이어의 소환수"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=691*pixel, position_y=-783*pixel, scale=1, size_x=1, size_y=1, font_multiplier=1, layout="소환수와 주시", dfCompanion=true},
  ["대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPRIGHT", relative_to="0", position_x=-927*pixel, position_y=-1005*pixel, scale=1, size_x=166/160, size_y=39/32, font_multiplier=1},
  ["대상의 소환수"] = {anchor="TOPRIGHT", relative_point="TOPRIGHT", relative_to="0", position_x=-935*pixel, position_y=-936*pixel, scale=1, size_x=160/160, size_y=32/32, font_multiplier=1},
  ["대상의 대상의 대상"] = {anchor="TOPRIGHT", relative_point="TOPRIGHT", relative_to="0", position_x=-585*pixel, position_y=-1005*pixel, scale=1, size_x=166/160, size_y=39/32, font_multiplier=1},
  ["주시 대상의 대상"] = {anchor="TOPRIGHT", relative_point="TOPRIGHT", relative_to="0", position_x=-935*pixel, position_y=-783*pixel, scale=1, size_x=166/160, size_y=39/32, font_multiplier=1},
  ["플레이어의 소환수의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=935*pixel, position_y=-783*pixel, scale=1, size_x=166/160, size_y=39/32, font_multiplier=1},
  ["플레이어 아래 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=585*pixel, position_y=-1005*pixel, scale=1, size_x=166/160, size_y=39/32, font_multiplier=1, enabled=true, unit="target", layout="대상의대상"},
  ["플레이어 아래 대상의 대상"] = {anchor="TOPLEFT", relative_point="TOPLEFT", relative_to="0", position_x=761*pixel, position_y=-1005*pixel, scale=1, size_x=166/160, size_y=39/32, font_multiplier=1, enabled=true, unit="targettarget", layout="대상의대상"},
}, groups = {
  ["파티"]={enabled=true,exists=true,unit_group="party",dfPartyRole="party",layout="데빌 파티",include_player=false,units_per_column=4,sort_method="INDEX",sort_direction="ASC",group_by=false,group_filter=false,show_when={solo=false,party=true,raid=false,raid10=false,raid15=false,raid20=false,raid25=false,raid30=false,raid40=false},anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=34*pixel,position_y=-60*pixel,scale=1,size_x=284/284,size_y=70/70,direction="down_right",vertical_spacing=42,horizontal_spacing=8},
  ["파티원 대상"]={enabled=true,exists=true,unit_group="partytarget",dfPartyRole="partytarget",layout="대상의대상",include_player=false,units_per_column=4,sort_method="INDEX",sort_direction="ASC",group_by=false,group_filter=false,show_when={solo=false,party=true,raid=false,raid10=false,raid15=false,raid20=false,raid25=false,raid30=false,raid40=false},anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=326*pixel,position_y=-60*pixel,scale=1,size_x=142/160,size_y=28/32,direction="down_right",vertical_spacing=84,horizontal_spacing=8},
  ["파티원 대상의 대상"]={enabled=true,exists=true,unit_group="partytargettarget",dfPartyRole="partytargettarget",layout="대상의대상",include_player=false,units_per_column=4,sort_method="INDEX",sort_direction="ASC",group_by=false,group_filter=false,show_when={solo=false,party=true,raid=false,raid10=false,raid15=false,raid20=false,raid25=false,raid30=false,raid40=false},anchor="TOPLEFT",relative_point="TOPLEFT",relative_to="0",position_x=326*pixel,position_y=-92*pixel,scale=1,size_x=142/160,size_y=28/32,direction="down_right",vertical_spacing=84,horizontal_spacing=8},
  ["파티원 소환수"]={enabled=false,dfPartyRole="hidden"},
}, layouts = {
  ["보통"] = {size_x=342, size_y=96, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=18/baseline, bar_texture="Devil Forever PitBull Glamour7", bar_padding=1, bar_spacing=1, indicator_root_outside_margin=8},
  ["대상"] = {size_x=342, size_y=96, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=18/baseline, bar_texture="Devil Forever PitBull Glamour7", bar_padding=1, bar_spacing=1},
  ["파티"] = {size_x=240, size_y=56, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=18/baseline, bar_texture="Devil Forever devil", bar_padding=1, bar_spacing=1},
  ["데빌 파티"] = {exists=true,size_x=284,size_y=70,scale=pixel,strata="LOW",level=2,font="Devil Forever devil",font_size=18/baseline,bar_texture="Devil Forever PitBull Glamour7",bar_padding=1,bar_spacing=1,indicator_root_outside_margin=2},
  ["대상의대상"] = {size_x=160, size_y=32, scale=pixel, strata="LOW", level=2, font="Devil Forever devil", font_size=18/baseline, bar_texture="Devil Forever PitBull Glamour7", bar_padding=1, bar_spacing=1},
}}, namespaces = {Totems = {global={colors={main_background={0,0,0,0}}},layouts = {["보통"] = {hide_inactive=true,attach_to="root", location="out_right_bottom", totem_direction="h", line_break=4, size=28/15, totem_spacing=4*50/28, text_size=14*50/(18*28)}}}}}


proposal.namespaces.Portrait = {global={enabled=true}, layouts={
  ["보통"]={enabled=true,side="center",position=.5,bar_size=4,style="three_dimensional",fallback_style="two_dimensional",full_body=false,camera_distance=1},
  ["대상"]={enabled=true,side="center",position=.5,bar_size=4,style="three_dimensional",fallback_style="two_dimensional",full_body=false,camera_distance=1},
}}
proposal.namespaces.Border = {global={enabled=true},layouts={}}
for _, layout in ipairs({"보통", "대상", "대상의대상"}) do
  proposal.namespaces.Border.layouts[layout] = {enabled=true,always_show=true,above_overlay=true,size=16,padding=layout == "대상의대상" and 0 or 1,
    normal_texture="Devil Forever PitBull Devil",boss_texture="Devil Forever PitBull Devil",
    elite_texture="Devil Forever PitBull Devil",rare_texture="Devil Forever PitBull Devil",
    normal_color={1,1,1,.66}}
end
proposal.namespaces.Aura = {global={enabled=true}, layouts={}}
for _, layout in ipairs({"보통", "대상"}) do
  local buffCount = layout == "보통" and 6 or 14
  local debuffCount = layout == "보통" and 6 or 16
  local size, spacing = 27, 2
  local perRow = math.max(1, math.floor(342 / (size + spacing)))
  local buffRows = math.ceil((2 * buffCount + 2) / perRow)
  local function placement(y)
    return {anchor="TOPLEFT",side="TOP",growth="right_up",offset_x=0,offset_y=y,
      width_type="percent",width_percent=1,size=size,my_size=size,size_to_fit=false,
      sort=true,reverse=false,new_row_size=true,row_spacing=spacing,col_spacing=spacing,filter=""}
  end
  local buff = placement(5)
  local debuff = placement(5+buffRows*(size+spacing)+spacing)
  debuff.my_size = 43
  debuff.reverse = true
  proposal.namespaces.Aura.layouts[layout] = {enabled=true,enabled_buffs=true,enabled_debuffs=true,
    enabled_weapons=false,max_buffs=buffCount,max_debuffs=debuffCount,highlight_style="thinborder",
    cooldown_text={my_buffs=true,my_debuffs=true},layout={buff=buff,debuff=debuff}}
end
proposal.namespaces.LuaTexts = {global={enabled=true}, layouts={}}
for _, layout in ipairs({"보통", "대상"}) do
  local elements = {
    ["Lua:레벨"]={enabled=true,exists=true,attach_to="Portrait",location="center",position=1,size=.8,code="Outline() return Level(unit)",events={UNIT_LEVEL=true}},
    ["Lua:백분율"]={enabled=true,exists=true,attach_to="Portrait",location=layout == "보통" and "right" or "left",position=1,size=.8,code='Outline() return "%s%%",Percent(HP(unit),MaxHP(unit))',events={UNIT_HEALTH=true,UNIT_MAXHEALTH=true}},
    ["Lua:이름"]={enabled=true,exists=true,attach_to="Portrait",location="center",position=2,size=1,code="Outline() return Name(unit)",events={UNIT_NAME_UPDATE=true}},
    ["Lua:생명력"]={enabled=true,exists=true,attach_to="HealthBar",location=layout == "보통" and "left" or "right",position=1,size=.9,code='Outline() return "%s/%s",HP(unit),MaxHP(unit)',events={UNIT_HEALTH=true,UNIT_MAXHEALTH=true}},
    ["Lua:마력"]={enabled=true,exists=true,attach_to="PowerBar",location=layout == "보통" and "left" or "right",position=1,size=.75,code='Outline() return "%s/%s",Power(unit),MaxPower(unit)',events={UNIT_POWER_FREQUENT=true,UNIT_MAXPOWER=true,UNIT_DISPLAYPOWER=true}},
    ["Lua:직업"]={enabled=true,exists=true,attach_to="PowerBar",location=layout == "보통" and "right" or "left",position=1,size=.85,code='Outline() return "%s %s",Level(unit),Class(unit) or ""',events={UNIT_LEVEL=true,UNIT_CLASSIFICATION_CHANGED=true}},
  }
  proposal.namespaces.LuaTexts.layouts[layout] = {enabled=true,first=false,elements=elements}
end
proposal.namespaces.LuaTexts.layouts["대상의대상"] = {enabled=true,first=false,elements={
  ["Lua:이름"]={enabled=true,exists=true,attach_to="HealthBar",location="left",position=1,size=.75,
    code="Outline() return Name(unit)",events={UNIT_NAME_UPDATE=true}},
  ["Lua:생명력"]={enabled=true,exists=true,attach_to="HealthBar",location="right",position=1,size=.65,
    code='Outline() return "%s/%s",HP(unit),MaxHP(unit)',events={UNIT_HEALTH=true,UNIT_MAXHEALTH=true}},
}}

-- The party layout is independent of the focus and personal pet layout.
proposal.namespaces.Portrait.layouts["데빌 파티"] = {enabled=true,side="left",position=1,style="two_dimensional",fallback_style="two_dimensional",full_body=false}
proposal.namespaces.Border.layouts["데빌 파티"] = {enabled=true,always_show=true,above_overlay=true,size=16,padding=0,
  normal_texture="Devil Forever PitBull Devil",boss_texture="Devil Forever PitBull Devil",
  elite_texture="Devil Forever PitBull Devil",rare_texture="Devil Forever PitBull Devil",normal_color={1,1,1,.66}}
local function partyAura(offsetX, width)
  return {anchor="BOTTOMLEFT",side="BOTTOM",growth="right_down",offset_x=offsetX,offset_y=-2,
    width_type="fixed",width=width,size=18,my_size=18,size_to_fit=false,sort=true,reverse=false,
    new_row_size=false,row_spacing=2,col_spacing=2,filter=""}
end
proposal.namespaces.Aura.layouts["데빌 파티"] = {enabled=true,enabled_buffs=true,enabled_debuffs=true,enabled_weapons=false,
  max_buffs=8,max_debuffs=3,highlight=false,highlight_style="thinborder",layout={buff=partyAura(0,284),debuff=partyAura(292,142)}}
proposal.namespaces.LuaTexts.layouts["데빌 파티"] = {enabled=true,first=false,elements={
  ["Lua:이름"]={enabled=true,exists=true,attach_to="HealthBar",location="top_left",position=1,size=.9,code="Outline() return Name(unit)",events={UNIT_NAME_UPDATE=true}},
  ["Lua:생명력"]={enabled=true,exists=true,attach_to="HealthBar",location="bottom_right",position=1,size=.8,code='Outline() return "%s/%s",HP(unit),MaxHP(unit)',events={UNIT_HEALTH=true,UNIT_MAXHEALTH=true}},
  ["Lua:마력"]={enabled=true,exists=true,attach_to="PowerBar",location="right",position=1,size=.75,code='Outline() return "%s/%s",Power(unit),MaxPower(unit)',events={UNIT_POWER_FREQUENT=true,UNIT_MAXPOWER=true,UNIT_DISPLAYPOWER=true}},
  ["Lua:직업"]={enabled=true,exists=true,attach_to="PowerBar",location="left",position=1,size=.75,code='Outline() return "%s %s",Level(unit),Class(unit) or ""',events={UNIT_LEVEL=true,UNIT_CLASSIFICATION_CHANGED=true}},
}}
proposal.namespaces.HealthBar = {layouts={["데빌 파티"]={enabled=true,size=5,position=1,color_by_class=true,background_alpha=.5}}}
proposal.namespaces.PowerBar = {layouts={["데빌 파티"]={enabled=true,size=2,position=2,hide_no_mana=false,hide_no_power=false,background_alpha=.5}}}

proposal.namespaces.CastBar = {global={enabled=true},layouts={
  ["보통"]={enabled=true,side="center",position=3,size=8*20/(96-5-20),auto_hide=true,idle_background=false,show_icon=false},
  ["대상"]={enabled=false},["대상의대상"]={enabled=false},["파티"]={enabled=false},["데빌 파티"]={enabled=false},
}}
local castEvents = {UNIT_SPELLCAST_START=true,UNIT_SPELLCAST_STOP=true,UNIT_SPELLCAST_FAILED=true,
  UNIT_SPELLCAST_INTERRUPTED=true,UNIT_SPELLCAST_DELAYED=true,UNIT_SPELLCAST_CHANNEL_START=true,
  UNIT_SPELLCAST_CHANNEL_UPDATE=true,UNIT_SPELLCAST_CHANNEL_STOP=true}
local playerTexts = proposal.namespaces.LuaTexts.layouts["보통"].elements
playerTexts["Lua:시전"] = {enabled=true,exists=true,attach_to="CastBar",location="left",position=1,size=.75,
  code="local cast = CastData(unit) if cast then return cast.spell end",events=castEvents}
playerTexts["Lua:시전시간"] = {enabled=true,exists=true,attach_to="CastBar",location="right",position=1,size=.65,
  code='local cast = CastData(unit) if cast and cast.end_time then return "%.1f",cast.end_time-GetTime() end',events=castEvents}

proposal.profile.layouts["소환수와 주시"] = DevilForever_Core.CopyTable(proposal.profile.layouts["보통"])
proposal.profile.layouts["소환수와 주시"].exists = true
proposal.profile.layouts["소환수와 주시"].size_x, proposal.profile.layouts["소환수와 주시"].size_y = 236, 74
for _, namespace in ipairs({"Portrait", "Border", "LuaTexts"}) do
  proposal.namespaces[namespace].layouts["소환수와 주시"] = DevilForever_Core.CopyTable(proposal.namespaces[namespace].layouts["보통"])
end
local companionTexts = proposal.namespaces.LuaTexts.layouts["소환수와 주시"].elements
companionTexts["Lua:시전"], companionTexts["Lua:시전시간"] = nil, nil
proposal.namespaces.Aura.layouts["소환수와 주시"] = DevilForever_Core.CopyTable(proposal.namespaces.Aura.layouts["데빌 파티"])
proposal.namespaces.CastBar.layouts["소환수와 주시"] = {enabled=false}
proposal.profile.dfAuraGeometry = {
  ["플레이어"]={avoid_frame="PitBull4_Frames_플레이어의 소환수",side="left",width=98,size_ratio=.7},
  ["대상"]={avoid_frame="PitBull4_Frames_주시 대상",side="right",width=98,size_ratio=.7},
  ["플레이어의 소환수"]={above=true,width=236},["주시 대상"]={above=true,width=236},
}
proposal.profile.dfPixel = pixel
proposal.profile.dfGeometry = {}
local fields = {
  units = {"anchor", "relative_point", "relative_to", "position_x", "position_y", "scale", "size_x", "size_y"},
  groups = {"anchor", "relative_point", "relative_to", "position_x", "position_y", "scale", "size_x", "size_y", "direction", "vertical_spacing", "horizontal_spacing"},
  layouts = {"size_x", "size_y", "scale"},
}
for kind, keys in pairs(fields) do
  proposal.profile.dfGeometry[kind] = {}
  for name, values in pairs(proposal.profile[kind]) do
    if kind ~= "groups" or type(values.position_x) == "number" then
      local parts = {}
      for _, key in ipairs(keys) do parts[#parts + 1] = tostring(values[key]) end
      proposal.profile.dfGeometry[kind][name] = table.concat(parts, "|")
    end
  end
end
return proposal
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "PitBull4", savedVariable = "PitBull4DB", addonVersion = "v4.2.50-forever.1", version = 1, section = "profile", profile = "Default", intoExisting = {"units", "groups"}, values = proposal.profile }
    -- The later version shares the profile receipt and adds only these complete singleton rows.
    local addedUnits = {}
    for _, name in ipairs({"플레이어 아래 대상", "플레이어 아래 대상의 대상"}) do addedUnits[name] = proposal.profile.units[name] end
    def.fragments[#def.fragments + 1] = {folder="PitBull4",savedVariable="PitBull4DB",addonVersion="v4.2.50-forever.1",
      version=2,section="profile",profile="Default",values={units=addedUnits}}
    local addedGroups = {}
    for _, name in ipairs({"파티", "파티원 대상", "파티원 대상의 대상"}) do addedGroups[name] = proposal.profile.groups[name] end
    def.fragments[#def.fragments + 1] = {folder="PitBull4",savedVariable="PitBull4DB",addonVersion="v4.2.50-forever.1",
      version=3,section="profile",profile="Default",values={groups=addedGroups}}
    for _, namespace in ipairs({"Portrait", "Border", "Aura", "LuaTexts", "CastBar"}) do
      def.fragments[#def.fragments + 1] = {folder="PitBull4",savedVariable="PitBull4DB",addonVersion="v4.2.50-forever.1",
        version=1,section="profile",profile="Default",namespace=namespace,values=proposal.namespaces[namespace]}
    end
    def.fragments[#def.fragments + 1] = { folder = "PitBull4", savedVariable = "PitBull4DB", addonVersion = "v4.2.50-forever.1", version = 1, section = "profile", profile = "Default", namespace = "Totems", values = proposal.namespaces.Totems }
    for module, weight in pairs({HealthBar = 2.2, PowerBar = 1.8}) do
      def.fragments[#def.fragments + 1] = {folder = "PitBull4", savedVariable = "PitBull4DB",
        addonVersion = "v4.2.50-forever.1", version = 1, section = "profile", profile = "Default",
        namespace = module, values = {layouts = {["보통"] = {size = weight,position = module == "HealthBar" and 1 or 2}, ["대상"] = {size = weight,position = module == "HealthBar" and 1 or 2}, ["데빌 파티"] = proposal.namespaces[module].layouts["데빌 파티"], ["소환수와 주시"] = {size = weight,position = module == "HealthBar" and 1 or 2}}}}
    end
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:qhd", "pitbull4-profile.qhd.fragment.lua: " .. tostring(proposal))
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
local proposal = {profile={backgroundcolor={0.035,0.035,0.04}, backgroundalpha=0.86, bordercolor={0.57,0.58,0.59},borderalpha=1}, namespaces={
  Player={point="TOP",x=0,y=-907*pixel,w=332,h=24,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=18,timefontsize=18,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Target={point="TOPRIGHT",x=-585*pixel,y=-1054*pixel,w=332,h=24,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=18,timefontsize=18,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Focus={point="TOPRIGHT",x=-691*pixel,y=-862*pixel,w=226,h=21,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=18,timefontsize=18,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
  Pet={point="TOPLEFT",x=256*pixel,y=-834*pixel,w=270,h=14,scale=pixel,alpha=1,strata="LOW",texture="Devil Forever devil",font="Devil Forever devil",fontsize=18,timefontsize=18,border="Blizzard Tooltip",iconposition="left",icongap=2,noInterruptShield=true},
}}
local keys = {"point", "x", "y", "w", "h", "scale"}
for _, name in ipairs({"Player", "Target", "Focus"}) do
  local values = proposal.namespaces[name]
  values.dfPixel, values.dfGeometry = pixel, {}
  for _, key in ipairs(keys) do values.dfGeometry[key] = values[key] end
end
return proposal
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", values = proposal.profile }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Focus", values = proposal.namespaces["Focus"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Pet", values = proposal.namespaces["Pet"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Player", values = proposal.namespaces["Player"] }
    def.fragments[#def.fragments + 1] = { folder = "Quartz", savedVariable = "Quartz3DB", addonVersion = "3.8.0", version = 1, section = "profile", profile = "Default", namespace = "Target", values = proposal.namespaces["Target"] }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:qhd", "quartz-profile.fragment.qhd.lua: " .. tostring(proposal))
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
  Primary={x=(0.0)*pixel,y=(608.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=64*pixel/native-2,primaryHeight=64*pixel/native-2,zoom=16,queue={width=64*pixel/native-2,height=64*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  AOE={x=(-160.0)*pixel,y=(608.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=64*pixel/native-2,primaryHeight=64*pixel/native-2,zoom=16,queue={width=64*pixel/native-2,height=64*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Cooldowns={x=(160.0)*pixel,y=(608.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=64*pixel/native-2,primaryHeight=64*pixel/native-2,zoom=16,queue={width=64*pixel/native-2,height=64*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Defensives={x=(320.0)*pixel,y=(608.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=64*pixel/native-2,primaryHeight=64*pixel/native-2,zoom=16,queue={width=64*pixel/native-2,height=64*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
  Interrupts={x=(-320.0)*pixel,y=(608.0)*pixel,numIcons=1,frameStrata="LOW",classic={primaryWidth=64*pixel/native-2,primaryHeight=64*pixel/native-2,zoom=16,queue={width=64*pixel/native-2,height=64*pixel/native-2,spacing=6*pixel/native},keybindings={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},delays={font="Devil Forever devil",fontSize=18*pixel,fontStyle="OUTLINE"},border={thickness=1,color={0.57,0.58,0.59,1}}}},
}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Hekili", savedVariable = "HekiliDB", addonVersion = "v0.8.6", version = 1, section = "profile", profile = "Default", values = proposal.profile }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:qhd", "hekili-profile.fragment.qhd.lua: " .. tostring(proposal))
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
return {["namespaces"]={["Grid2Frame"]={["frameWidth"]=120,["frameHeight"]=44,["frameBorder"]=3,["frameBorderDistance"]=0,["frameBorderColor"]={["r"]=0.57,["g"]=0.58,["b"]=0.59,["a"]=1},["frameTexture"]="Devil Forever devil",["font"]="Devil Forever devil",["fontSize"]=14,["iconSize"]=24,["orientation"]="HORIZONTAL"},["Grid2Layout"]={["ScaleSize"]=pixel,["Padding"]=4,["Spacing"]=0,["horizontal"]=false,["anchor"]="TOPLEFT",["groupAnchor"]="TOPLEFT",["PosX"]=40*factor,["PosY"]=-164*factor,["BorderTexture"]="None",["BackgroundTexture"]="None"}},["indicators"]={["text-center"]={["font"]="Devil Forever devil",["fontSize"]=14},["icon-center"]={["size"]=22},["icon-left"]={["size"]=18},["icon-right"]={["size"]=18}}}
  end)
  if ok and type(proposal) == "table" and next(proposal) then
    def.fragments[#def.fragments + 1] = { folder = "Grid2", savedVariable = "Grid2DB", addonVersion = "4.1.13", version = 1, section = "profile", profile = "$char", namespace = "Grid2Frame", values = proposal.namespaces["Grid2Frame"] }
    def.fragments[#def.fragments + 1] = { folder = "Grid2", savedVariable = "Grid2DB", addonVersion = "4.1.13", version = 1, section = "profile", profile = "$char", namespace = "Grid2Layout", values = proposal.namespaces["Grid2Layout"] }
  elseif not ok then
    DevilForever_Core:Log("skip", "Preset:qhd", "grid2-profile.fragment.qhd.lua: " .. tostring(proposal))
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

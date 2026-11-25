local Core = DevilForever_Core
local unitFields = {"anchor", "relative_point", "relative_to", "position_x", "position_y", "scale", "size_x", "size_y"}
local layoutFields = {"size_x", "size_y", "scale"}
local layouts = {["보통"]=true,["대상"]=true,["대상의대상"]=true,["소환수와 주시"]=true,["소환수와 주시 아래"]=true,["주시"]=true}
local units = {
  ["플레이어"]="player",["대상"]="target",["플레이어의 소환수"]="pet",["주시 대상"]="focus",
  ["대상의 소환수"]="targetpet",["대상의 대상"]="targettarget",["대상의 대상의 대상"]="targettargettarget",
  ["플레이어 아래 대상"]="target",["플레이어 아래 대상의 대상"]="targettarget",
  ["플레이어의 소환수의 대상"]="pettarget",["플레이어의 소환수의 대상의 대상"]="pettargettarget",
  ["주시 대상의 대상"]="focustarget",["주시 대상의 대상의 대상"]="focustargettarget",
  ["대상의 소환수의 대상"]="targetpettarget",["대상의 소환수의 대상의 대상"]="targetpettargettarget",
}
-- totemY / totemButton: top and button side (pixels) of the preset's Dominos totem bar (Presets/<name>.lua
-- Dominos frames.totem: scale pixel * totemButton / 30 for 30-unit buttons).
-- petBar: the preset's Dominos pet bar (Presets/<name>.lua fitPet): top-left x/y, the largest button side
-- and the row length the buttons share (side = min(side, (span - 2 * (count - 1)) / count)).
local modes = {
  fhd={width=1920,height=1080,totemY=748,totemButton=44,petBar={x=218,y=490,side=22,span=238},castHeight=30,smallWidth=123,smallHeight=29},
  qhd={width=2560,height=1440,totemY=1056,totemButton=52,petBar={x=256,y=806,side=26,span=278},castHeight=34,smallWidth=166,smallHeight=39},
  uhd={width=3840,height=2160,totemY=1636,totemButton=72,petBar={x=212,y=1564,side=34,span=358},castHeight=40,smallWidth=251,smallHeight=58},
}
-- The Dominos totem bar: summon, four totems and recall (Dominos bars/totemBar/bar.lua), 2 units apart.
local TOTEM_BUTTONS, TOTEM_SPACING = 6, 2
-- Revision of the layout (the V2 layout, the only one) written into the PitBull4 profile
-- (dfLayoutRevision, with dfLayoutV2 = true). A collection profile below it, or one still on the earlier
-- second layout (dfLayoutV2 = false), gets this layout written by itself at the next load (Presets.lua,
-- layout catch-up).
Core.Presets.layoutV2Revision = 8
local function signature(row, fields)
  local parts = {}
  for _, key in ipairs(fields) do parts[#parts+1] = tostring(row[key]) end
  return table.concat(parts, "|")
end
local function fragment(namespace, values)
  return {folder="PitBull4",savedVariable="PitBull4DB",addonVersion="v4.2.50-forever.1",
    version=1,section="profile",profile="Default",namespace=namespace,values=values}
end
for name, m in pairs(modes) do
  local base = Core.Presets:Get(name)
  local layoutV2
  if base then
    do
      -- the layout-only preset <name>-v2 (the layout catch-up and /dfp preset <name>-v2 write it)
      local def = {name=name .. "-v2",layoutOnly=true,fragments={}}
      local root, spaces, quartz, grid, totemBar = nil, {}, {}, nil, nil
      for _, f in ipairs(base.fragments) do
        if f.folder == "PitBull4" and not f.namespace and f.values.layouts then root=Core.CopyTable(f.values) end
        if f.folder == "PitBull4" and f.namespace then
          local copy = Core.CopyTable(f)
          if copy.values.layouts then
            for layout in pairs(copy.values.layouts) do if not layouts[layout] then copy.values.layouts[layout]=nil end end
          end
          def.fragments[#def.fragments+1]=copy
          spaces[copy.namespace]=copy.values
        elseif f.folder == "Quartz" and (f.namespace == "Player" or f.namespace == "Target" or f.namespace == "Focus"
            or f.namespace == "Pet") then
          local copy=Core.CopyTable(f);quartz[copy.namespace]=copy.values
          def.fragments[#def.fragments+1]=copy
        elseif f.folder == "Dominos" and type(f.values.frames) == "table" and type(f.values.frames.totem) == "table" then
          -- the totem bar and the pet bar (moved under the player frame, below) and bars 4 and 5 (the
          -- action panel of the section structure)
          local frames={totem=Core.CopyTable(f.values.frames.totem)}
          for _, bar in ipairs({4, 5}) do
            if type(f.values.frames[bar]) == "table" then frames[bar]=Core.CopyTable(f.values.frames[bar]) end
          end
          if type(f.values.frames.pet) == "table" then frames.pet=Core.CopyTable(f.values.frames.pet) end
          totemBar={folder=f.folder,savedVariable=f.savedVariable,addonVersion=f.addonVersion,version=1,section=f.section,
            profile=f.profile,values={frames=frames}}
          def.fragments[#def.fragments+1]=totemBar
        elseif f.folder == "Grid2" and f.namespace == "Grid2Layout" then
          -- the window spot (left of the quest tracker)
          grid={folder=f.folder,savedVariable=f.savedVariable,addonVersion=f.addonVersion,version=1,section=f.section,
            profile=f.profile,namespace=f.namespace,values={anchor=f.values.anchor,PosX=f.values.PosX,PosY=f.values.PosY}}
          def.fragments[#def.fragments+1]=grid
        elseif f.folder == "Grid2" and f.namespace == "Grid2Frame" then
          -- cell size: the preset's square cells
          local cells={f.values.frameWidth,f.values.frameHeight}
          def.fragments[#def.fragments+1]={folder=f.folder,savedVariable=f.savedVariable,addonVersion=f.addonVersion,
            version=1,section=f.section,profile=f.profile,namespace=f.namespace,
            values={frameWidth=cells[1],frameHeight=cells[2]}}
        end
      end
      if root then
        root.groups=nil
        root.dfGeometry.groups={}
        for layout in pairs(root.layouts) do if not layouts[layout] then root.layouts[layout]=nil;root.dfGeometry.layouts[layout]=nil end end
        for label,row in pairs(root.units) do
          row.unit=units[label]
          row.layout=row.layout or (label == "플레이어" and "보통" or label == "대상" and "대상" or "대상의대상")
        end
        root.dfLayoutV2 = true
        local targetPet=root.units["대상의 소환수"]
        targetPet.layout="대상의대상";targetPet.dfCompanion=false
        spaces.CastBar.layouts["보통"].dfOutside=false
        root.dfAuraGeometry["대상의 소환수"]={above=false}
        root.dfLayoutRevision=Core.Presets.layoutV2Revision
        local timer=spaces.Totems.layouts["보통"]
        do
          local pixel=root.dfPixel
          local main, companion=root.layouts["보통"],root.layouts["소환수와 주시"]
          local w,h,cw,ch=main.size_x,main.size_y,companion.size_x,companion.size_y
          local icon=15*timer.size
          local outside=main.indicator_root_outside_margin or 0
          local gap=m.castHeight+4
          -- focus midway between player and target, the row centred on the screen, one frame gap between frames
          local xFocus=(m.width-cw)/2
          local xPlayer=xFocus-gap-w
          local xPet=xPlayer-gap-cw
          local xTarget=xFocus+cw+gap
          local xTargetPet=xTarget+w+gap
          local castY=m.totemY-8-m.castHeight
          local bottom=castY-16-m.smallHeight
          local lower=bottom+8
          local function place(label,x,y,width,height,layout)
            local row=root.units[label]
            row.anchor,row.relative_point,row.relative_to="TOPLEFT","TOP","0"
            row.position_x,row.position_y=(x-m.width/2)*pixel,-y*pixel
            local db=root.layouts[layout or row.layout or (label == "플레이어" and "보통" or "대상")]
            row.size_x,row.size_y=width/db.size_x,height/db.size_y
            row.scale=1
          end
          place("플레이어",xPlayer,bottom-h,w,h,"보통")
          place("대상",xTarget,bottom-h,w,h,"대상")
          place("플레이어의 소환수",xPet,bottom-ch,cw,ch)
          place("주시 대상",xFocus,bottom-ch,cw,ch)
          targetPet.enabled,targetPet.layout,targetPet.dfCompanion=true,"소환수와 주시",true
          place("대상의 소환수",xTargetPet,bottom-ch,cw,ch)
          place("플레이어 아래 대상",xPlayer,lower,m.smallWidth,m.smallHeight)
          place("플레이어 아래 대상의 대상",xPlayer+m.smallWidth+10,lower,m.smallWidth,m.smallHeight)
          place("대상의 대상",xTarget,lower,m.smallWidth,m.smallHeight,"대상의대상")
          place("대상의 대상의 대상",xTarget+m.smallWidth+10,lower,m.smallWidth,m.smallHeight,"대상의대상")
          local small=root.layouts["소환수와 주시 아래"]
          place("플레이어의 소환수의 대상",xPet,lower,small.size_x,small.size_y)
          place("플레이어의 소환수의 대상의 대상",xPet+small.size_x+10,lower,small.size_x,small.size_y)
          place("주시 대상의 대상의 대상",xFocus,lower,small.size_x,small.size_y)
          place("주시 대상의 대상",xFocus+small.size_x+10,lower,small.size_x,small.size_y)
          for index, label in ipairs({"대상의 소환수의 대상", "대상의 소환수의 대상의 대상"}) do
            root.units[label].enabled=true
            place(label,xTargetPet+(index-1)*(small.size_x+10),lower,small.size_x,small.size_y)
          end
          for label, width in pairs({["플레이어"]=w,["대상"]=w,["플레이어의 소환수"]=cw,["주시 대상"]=cw,["대상의 소환수"]=cw}) do
            root.dfAuraGeometry[label]={above=true,width=width}
          end
          -- the totem bar and the pet bar share the row under the player frame (a class has one or the
          -- other), each ending at the player frame's right edge; the totem timer left of the totem bar
          local button=m.totemButton
          local totemWidth=TOTEM_BUTTONS*button+(TOTEM_BUTTONS-1)*TOTEM_SPACING*button/30
          local totemX=xPlayer+w-totemWidth
          local petBar=totemBar and totemBar.values.frames.pet
          if petBar and type(petBar.scale) == "number" and type(petBar.columns) == "number" and petBar.columns >= 1 then
            local count=petBar.columns
            local side=math.min(m.petBar.side,(m.petBar.span-2*(count-1))/count)
            local length=count*side+2*(count-1)
            local effective=petBar.scale/pixel
            local x,y=xPlayer+w-length,m.totemY+(button-side)/2
            petBar.x=petBar.x+(x-m.petBar.x)/effective-(m.width/2)/effective
            petBar.y=petBar.y-(y-m.petBar.y)/effective
            petBar.point,petBar.relPoint="TOPLEFT","TOP"
            if type(petBar.dfGeometry) == "table" then
              for _, key in ipairs({"point","relPoint","x","y"}) do petBar.dfGeometry[key]=petBar[key] end
            end
          end
          if totemBar then
            local totem=totemBar.values.frames.totem
            -- from the screen's top centre like the unit frames, so a wider screen keeps it under the player
            totem.point,totem.relPoint="TOPLEFT","TOP"
            totem.x,totem.y=(totemX-m.width/2)*30/button,-m.totemY*30/button
            -- the runtime rescale signature (DevilForever_Skin_Dominos) follows the new spot
            if type(totem.dfGeometry) == "table" then
              for _, key in ipairs({"point","relPoint","x","y"}) do totem.dfGeometry[key]=totem[key] end
            end
          end
          timer.location="out_bottom_left"
          timer.dfOffsetX=totemX-8-(4*icon+3*timer.totem_spacing*icon/50)-(xPlayer-outside)
          timer.dfOffsetY=m.totemY+(button-icon)/2-(bottom+outside)
          -- every cast bar (player, target, focus, pet) sits in the cast row under its frame, as wide as the frame
          for module, x in pairs({Player=xPlayer,Target=xTarget,Focus=xFocus,Pet=xPet}) do
            local q=quartz[module]
            if q then
              local wide=(module == "Player" or module == "Target") and w or cw
              q.point,q.y="TOP",-castY*pixel
              q.x=(x+wide/2-m.width/2)*pixel
              q.w,q.h=wide-10,m.castHeight-10
            end
          end
        end
        for label,row in pairs(root.units) do root.dfGeometry.units[label]=signature(row,unitFields) end
        for layout,row in pairs(root.layouts) do root.dfGeometry.layouts[layout]=signature(row,layoutFields) end
        local f=fragment(nil,root);f.alignPixel=true;f.replace={"dfAuraGeometry"}
        table.insert(def.fragments,1,f)
        for module, q in pairs(quartz) do
          -- Pet has no run-time rescale (Defaults/Quartz.lua), so no geometry signature
          if module ~= "Pet" then
            q.dfGeometry={}
            for _, key in ipairs({"point","x","y","w","h","scale"}) do q.dfGeometry[key]=q[key] end
          end
        end
        def.fragments[#def.fragments+1]={folder="Quartz",savedVariable="Quartz3DB",addonVersion="3.8.0",version=1,
          section="profile",profile="Default",namespace="Swing",values={swingposition="bottom",swinggap=4,swingheight=4}}
        Core.Presets:Register(def)
        layoutV2 = def
      end
    end
    -- The base preset writes this layout: its fragments follow the base ones at versions above them, so a
    -- fresh profile and a /dfp preset request end with it.
    if layoutV2 then
      for _, f in ipairs(layoutV2.fragments) do
        local copy = Core.CopyTable(f)
        copy.version = copy.version + 10
        base.fragments[#base.fragments+1] = copy
      end
      Core.Presets:Register(base)
    end
  end
end

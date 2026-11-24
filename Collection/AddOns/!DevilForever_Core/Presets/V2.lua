local Core = DevilForever_Core
local unitFields = {"anchor", "relative_point", "relative_to", "position_x", "position_y", "scale", "size_x", "size_y"}
local layoutFields = {"size_x", "size_y", "scale"}
local layouts = {["보통"]=true,["대상"]=true,["대상의대상"]=true,["소환수와 주시"]=true,["소환수와 주시 아래"]=true}
local units = {
  ["플레이어"]="player",["대상"]="target",["플레이어의 소환수"]="pet",["주시 대상"]="focus",
  ["대상의 소환수"]="targetpet",["대상의 대상"]="targettarget",["대상의 대상의 대상"]="targettargettarget",
  ["플레이어 아래 대상"]="target",["플레이어 아래 대상의 대상"]="targettarget",
  ["플레이어의 소환수의 대상"]="pettarget",["플레이어의 소환수의 대상의 대상"]="pettargettarget",
  ["주시 대상의 대상"]="focustarget",["주시 대상의 대상의 대상"]="focustargettarget",
}
local modes = {
  fhd={width=1920,totemY=748,castHeight=30,smallWidth=123,smallHeight=29,footY=548},
  qhd={width=2560,totemY=1056,castHeight=34,smallWidth=166,smallHeight=39,footY=765},
  uhd={width=3840,totemY=1636,castHeight=40,smallWidth=251,smallHeight=58,footY=1180},
}
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
  if base then
    for _, f in ipairs(base.fragments) do
      if f.folder == "PitBull4" and not f.namespace and f.values.layouts then
        f.values.dfLayoutV2=false
        f.values.units["대상의 소환수"].layout="대상의대상"
        f.values.units["대상의 소환수"].dfCompanion=false
        f.values.dfAuraGeometry["플레이어"].above=false
        f.values.dfAuraGeometry["대상"].above=false
        f.values.dfAuraGeometry["대상의 소환수"]={above=false}
        f.values.dfAuraGeometry["주시 대상"].top_margin=0
      elseif f.folder == "PitBull4" and f.namespace == "CastBar" then
        f.values.layouts["보통"].dfOutside=false
      end
    end
    base.fragments[#base.fragments+1]={folder="Quartz",savedVariable="Quartz3DB",addonVersion="3.8.0",version=1,
      section="profile",profile="Default",namespace="Swing",values={swingposition="top",swinggap=-4,swingheight=4}}
    Core.Presets:Register(base)
    for _, version in ipairs({1,2}) do
      local def = {name=name .. "-v" .. version,layoutOnly=true,fragments={}}
      local root, spaces, quartz = nil, {}, {}
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
        root.dfLayoutV2 = version == 2
        local targetPet=root.units["대상의 소환수"]
        targetPet.layout="대상의대상";targetPet.dfCompanion=false
        spaces.CastBar.layouts["보통"].dfOutside=false
        root.dfAuraGeometry["플레이어"].above=false
        root.dfAuraGeometry["대상"].above=false
        root.dfAuraGeometry["대상의 소환수"]={above=false}
        if version == 2 then
          local pixel=root.dfPixel
          local main, companion=root.layouts["보통"],root.layouts["소환수와 주시"]
          local w,h,cw,ch=main.size_x,main.size_y,companion.size_x,companion.size_y
          local timer=spaces.Totems.layouts["보통"]
          local icon=15*timer.size
          local timerWidth=4*icon+3*timer.totem_spacing*icon/50
          local timerGap=math.ceil(timerWidth+16)
          local gap=m.castHeight+4
          local total=2*w+3*cw+3*gap+timerGap
          local left=(m.width-total)/2
          local xPet=left
          local xPlayer=xPet+cw+gap
          local xFocus=xPlayer+w+timerGap
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
          local cast=spaces.CastBar.layouts["보통"]
          cast.dfOutside,cast.dfOffset,cast.dfHeight=true,castY-bottom,m.castHeight
          for label, width in pairs({["플레이어"]=w,["대상"]=w,["플레이어의 소환수"]=cw,["주시 대상"]=cw,["대상의 소환수"]=cw}) do
            root.dfAuraGeometry[label]={above=true,width=width}
          end
          for module, x in pairs({Target=xTarget,Focus=xFocus,Pet=xPet}) do
            local q=quartz[module]
            if q then
              q.point,q.y="TOP",-castY*pixel
              q.x=(x+(module == "Target" and w or cw)/2-m.width/2)*pixel
              q.w,q.h=(module == "Target" and w or cw)-10,m.castHeight-10
            end
          end
          quartz.Player.y=-m.footY*pixel
          root.dfAuraGeometry["주시 대상"].top_margin=math.max(2,bottom-ch-m.footY+8)
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
          section="profile",profile="Default",namespace="Swing",values={swingposition=version == 2 and "bottom" or "top",swinggap=version == 2 and 4 or -4,swingheight=4}}
        Core.Presets:Register(def)
      end
    end
  end
end

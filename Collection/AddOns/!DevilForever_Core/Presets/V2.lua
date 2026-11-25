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
-- oldCells: Grid2 cell width and height of the Old (V1) layout; New uses the preset's square cells.
local modes = {
  fhd={width=1920,height=1080,totemY=748,castHeight=30,smallWidth=123,smallHeight=29,oldCells={96,32}},
  qhd={width=2560,height=1440,totemY=1056,castHeight=34,smallWidth=166,smallHeight=39,oldCells={120,44}},
  uhd={width=3840,height=2160,totemY=1636,castHeight=40,smallWidth=251,smallHeight=58,oldCells={154,56}},
}
-- Revisions of the New (V2) and Old (V1) layouts written into the PitBull4 profile (dfLayoutRevision);
-- the version switcher shows New only for a profile that holds the V2 revision. A profile holding an
-- older revision of its version gets that version re-applied once at login (below).
Core.Presets.layoutV2Revision = 3
Core.Presets.layoutV1Revision = 1
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
      local root, spaces, quartz, grid = nil, {}, {}, nil
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
        elseif f.folder == "Grid2" and f.namespace == "Grid2Layout" then
          -- the window spot is the same in both layouts (left of the quest tracker)
          grid={folder=f.folder,savedVariable=f.savedVariable,addonVersion=f.addonVersion,version=1,section=f.section,
            profile=f.profile,namespace=f.namespace,values={anchor=f.values.anchor,PosX=f.values.PosX,PosY=f.values.PosY}}
          def.fragments[#def.fragments+1]=grid
        elseif f.folder == "Grid2" and f.namespace == "Grid2Frame" then
          -- cell size: New = the preset's square cells, Old = the V1 cells
          local cells=version == 2 and {f.values.frameWidth,f.values.frameHeight} or m.oldCells
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
        root.dfLayoutV2 = version == 2
        local targetPet=root.units["대상의 소환수"]
        targetPet.layout="대상의대상";targetPet.dfCompanion=false
        spaces.CastBar.layouts["보통"].dfOutside=false
        root.dfAuraGeometry["플레이어"].above=false
        root.dfAuraGeometry["대상"].above=false
        root.dfAuraGeometry["대상의 소환수"]={above=false}
        root.dfLayoutRevision=version == 2 and Core.Presets.layoutV2Revision or Core.Presets.layoutV1Revision
        if version == 2 then
          local pixel=root.dfPixel
          local main, companion=root.layouts["보통"],root.layouts["소환수와 주시"]
          local w,h,cw,ch=main.size_x,main.size_y,companion.size_x,companion.size_y
          -- the player's totem timer (four totem slots) sits above the player frame, right-aligned,
          -- between the frame and its aura rows (raised by top_margin below)
          local timer=spaces.Totems.layouts["보통"]
          timer.location="out_top_right"
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
          root.dfAuraGeometry["플레이어"].top_margin=math.ceil(outside+icon+4)
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
          section="profile",profile="Default",namespace="Swing",values={swingposition=version == 2 and "bottom" or "top",swinggap=version == 2 and 4 or -4,swingheight=4}}
        Core.Presets:Register(def)
        if version == 2 then layoutV2 = def end
      end
    end
    -- New (V2) is the default layout of the base preset, Old (V1) stays as <name>-v1: the V2 fragments
    -- follow the base ones at versions above them, so a fresh profile and a /dfp preset request end with V2.
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

-- Re-apply after an update: a PitBull4 profile whose layout revision is older than this package's
-- revision of the version it is on (New = dfLayoutV2) gets that version's compare preset applied once,
-- the same way the status strip's New/Old switch does (Presets:Restore then Profiles:Go, which reloads
-- the interface). Out of combat only; one attempt per profile and revision; one chat line after reload.
local reapply = CreateFrame("Frame")
local function profileState()
  local addon = _G.PitBull4
  local db = type(addon) == "table" and addon.db
  local profile = type(db) == "table" and db.profile
  if type(profile) ~= "table" then return end
  local ok, key = pcall(function() return db:GetCurrentProfile() end)
  key = ok and type(key) == "string" and key or "Default"
  -- dfLayoutV2 is written by every collection layout (true = New, false = Old); a profile without it
  -- was never laid out by the collection and is left as it is
  if type(profile.dfLayoutV2) ~= "boolean" then return end
  local new = profile.dfLayoutV2
  local stored = type(profile.dfLayoutRevision) == "number" and profile.dfLayoutRevision or 0
  return key, new, stored, new and Core.Presets.layoutV2Revision or Core.Presets.layoutV1Revision
end
function Core.Presets:ReapplyOutdatedLayout()
  if Core.InCombat() then reapply:RegisterEvent("PLAYER_REGEN_ENABLED"); return false, "combat" end
  local active = self:GetActive()
  local key, new, stored, target = profileState()
  if not active or not key or stored >= target then return false, "current" end
  local suffix = new and "-v2" or "-v1"
  if not self:IsRegistered(active .. suffix) then return false, "no compare preset" end
  local tried = Core:DBTable("layoutRevision", "tried")
  local mark = key .. "|" .. suffix
  if tried[mark] == target then return false, "tried" end
  tried[mark] = target
  local ok, lines = self:Restore(active .. suffix)
  if not ok then
    for _, line in ipairs(type(lines) == "table" and lines or {lines}) do Core.Profiles:Print(line) end
    return false, "restore"
  end
  Core:DBTable("layoutRevision").notice = (new and "New" or "Old") .. " 배치를 이 판에 맞춰 다시 적용했습니다(PitBull4·Quartz·Grid2)."
  local went, why = Core.Profiles:Go()
  if not went then
    Core:DBTable("layoutRevision").notice = nil
    Core.Profiles:Print("안 함: " .. tostring(why))
    return false, "go"
  end
  return true
end
reapply:RegisterEvent("PLAYER_ENTERING_WORLD")
reapply:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    local store = Core:DBTable("layoutRevision")
    if store.notice then Core.Profiles:Print(store.notice); store.notice = nil end
  else
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(1, function() Core.Presets:ReapplyOutdatedLayout() end)
  else
    Core.Presets:ReapplyOutdatedLayout()
  end
end)

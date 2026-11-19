local Core = DevilForever_Core
local Layout = {}
DevilForever_DetailsLayout = Layout

local layouts = {
  fhd = {{1320, 466, 372, 168}, {1320, 650, 372, 106}},
  qhd = {{1946, 780, 330, 180}, {1946, 972, 330, 100}},
  uhd = {{2902, 1280, 460, 260}, {2902, 1552, 460, 136}},
}
local baseline
local anchorPoints = {TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true,
  RIGHT = true, BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true}

local function finite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function positive(value)
  return finite(value) and value > 0
end

local function say(message)
  if Core.Profiles and Core.Profiles.Print then Core.Profiles:Print(message)
  else print("DevilForever Details: " .. message) end
end

local function ready()
  if InCombatLockdown() then return nil, "전투 중: 바꾼 것 없음" end
  if not Details or not Details.__initialized or Details.initializing or Details.AnnounceStartup then
    return nil, "Details 초기화가 아직 끝나지 않음"
  end
  if Details.chat_tab_embed and Details.chat_tab_embed.enabled then return nil, "채팅에 포함된 Details 배치는 보존함" end
  if not _detalhes_database or type(_detalhes_database.active_profile) ~= "string"
      or _detalhes_database.active_profile == "" then return nil, "Details 기존 프로필이 준비되지 않음" end
  local instances = {}
  for id = 1, 2 do
    local instance = Details:GetInstance(id)
    if not instance or type(instance.IsStarted) ~= "function" or not instance:IsStarted() then
      return nil, "기존 Details 창 " .. id .. " 이 준비되지 않음: 자동 생성하지 않음"
    end
    if instance.mostrando ~= "normal" or type(instance.snap) ~= "table" or next(instance.snap) then
      return nil, "창 " .. id .. " 의 solo/묶음 배치는 보존함"
    end
    for _, key in ipairs({"baseframe", "rowframe", "windowSwitchButton", "windowBackgroundDisplay"}) do
      local frame = instance[key]
      if not frame or (frame.IsProtected and frame:IsProtected()) then return nil, "창 " .. id .. " 의 프레임이 준비되지 않음" end
    end
    if instance.baseframe:GetParent() ~= UIParent then return nil, "다른 화면에 포함된 창 " .. id .. " 은 보존함" end
    for _, key in ipairs({"RestorePositionFromPositionTable", "RestoreMainWindowPosition", "SetWindowScale"}) do
      if type(instance[key]) ~= "function" then return nil, "Details 위치 API 없음: " .. key end
    end
    if type(instance.libwindow) ~= "table" or type(instance.posicao) ~= "table"
        or type(instance.posicao.normal) ~= "table" then return nil, "창 위치 설정이 준비되지 않음" end
    local normal, libwindow = instance.posicao.normal, instance.libwindow
    if not positive(normal.w) or not positive(normal.h) or not positive(instance.window_scale) then
      return nil, "창 " .. id .. " 의 기존 폭/높이/배율을 안전하게 복원할 수 없음"
    end
    if libwindow.x and not Details.instances_no_libwindow then
      if not finite(libwindow.x) or (libwindow.y ~= nil and not finite(libwindow.y))
          or (libwindow.scale ~= nil and not positive(libwindow.scale))
          or (libwindow.y ~= nil and libwindow.point and not anchorPoints[libwindow.point]) then
        return nil, "창 " .. id .. " 의 기존 LibWindow 위치를 안전하게 복원할 수 없음"
      end
    elseif not finite(normal.x) or not finite(normal.y) then
      return nil, "창 " .. id .. " 의 기존 legacy 위치를 안전하게 복원할 수 없음"
    end
    instances[id] = instance
  end
  return instances
end

local function profileIdentity()
  local name = Details:GetCurrentProfileName()
  return name, Details:GetProfile(name, false)
end

local function snapshot(instances)
  local name, profile = profileIdentity()
  local result = {name = name, profile = profile, instances = {}}
  for id, instance in ipairs(instances) do
    result.instances[id] = {instance = instance,
      libwindow = Core.CopyTable(instance.libwindow), normal = Core.CopyTable(instance.posicao.normal), scale = instance.window_scale}
  end
  return result
end

local function sameProfile(saved, instances)
  local name, profile = profileIdentity()
  if name ~= saved.name or profile ~= saved.profile then return false end
  for id, instance in ipairs(instances) do if instance ~= saved.instances[id].instance then return false end end
  return true
end

local function replace(target, source)
  for key in pairs(target) do target[key] = nil end
  for key, value in pairs(source) do target[key] = value end
end

local function restore(saved, instances)
  for id, instance in ipairs(instances) do
    local value = saved.instances[id]
    instance:SetWindowScale(value.scale, false)
    replace(instance.libwindow, value.libwindow)
    replace(instance.posicao.normal, value.normal)
    instance:RestoreMainWindowPosition()
  end
end

function Layout:Apply(name)
  name = name or Core.Presets:GetActive()
  local definition = layouts[name]
  if not definition then return false, "fhd/qhd/uhd 프리셋만 지원함" end
  local width, height = GetPhysicalScreenSize()
  if not positive(width) or not positive(height) then return false, "실제 화면 크기를 확인할 수 없음" end
  for _, rect in ipairs(definition) do
    if not finite(rect[1]) or not finite(rect[2]) or rect[1] < 0 or rect[2] < 0
        or not positive(rect[3]) or not positive(rect[4]) or rect[1] + rect[3] > width or rect[2] + rect[4] > height then
      return false, "요청한 창 좌표가 실제 화면 경계를 벗어남: " .. name
    end
  end
  local instances, reason = ready()
  if not instances then return false, reason end
  local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
  if not positive(pixel) then return false, "물리 픽셀 환산값 없음" end
  if baseline and not sameProfile(baseline, instances) then return false, "프로필/창이 바뀜: 최초 복원본을 보존하므로 재적용하지 않음" end
  local before = snapshot(instances)
  if type(before.profile) ~= "table" then return false, "Details 기존 프로필이 준비되지 않음" end
  local ok, err = pcall(function()
    for id, instance in ipairs(instances) do
      local rect = definition[id]
      local position = {pos_table = true, point = "TOPLEFT", x = rect[1] * pixel, y = -rect[2] * pixel,
        scale = pixel, x_legacy = (rect[1] + rect[3] / 2 - width / 2) * pixel,
        y_legacy = (height / 2 - rect[2] - rect[4] / 2) * pixel, w = rect[3], h = rect[4]}
      instance:SetWindowScale(pixel, false)
      instance:RestorePositionFromPositionTable(position)
    end
  end)
  if not ok then
    local restored, restoreError = pcall(restore, before, instances)
    if not restored then baseline = baseline or before end
    return false, "적용 오류: " .. tostring(err) .. (restored and " (직전 위치 복원함)" or ("; 복원 오류: " .. tostring(restoreError)))
  end
  baseline = baseline or before
  return true, "Details 기존 창 1/2 위치 적용: " .. name .. " — 같은 세션 원복: /dfdetails restore"
end

function Layout:Restore()
  if not baseline then return false, "이 세션의 적용 전 복원본 없음" end
  local instances, reason = ready()
  if not instances then return false, reason end
  if not sameProfile(baseline, instances) then return false, "프로필/창이 바뀜: 다른 개인 설정에 원복하지 않음" end
  local ok, err = pcall(restore, baseline, instances)
  if not ok then return false, "원복 오류: " .. tostring(err) end
  baseline = nil
  return true, "Details 창 1/2의 적용 전 위치를 복원함"
end

function Layout:Run(message)
  local words = {}
  for word in tostring(message or ""):gmatch("%S+") do words[#words + 1] = word end
  local action = words[1] or "status"
  local ok, detail
  if action == "apply" and #words <= 2 then ok, detail = self:Apply(words[2])
  elseif action == "restore" and #words == 1 then ok, detail = self:Restore()
  elseif action == "status" and #words <= 1 then
    local instances, reason = ready()
    detail = instances and ("기존 창 1/2 준비됨 · 활성 프리셋 " .. tostring(Core.Presets:GetActive())
      .. (baseline and " · 세션 복원본 있음" or " · 바꾼 것 없음")) or reason
    ok = true
  else detail = "/dfdetails status | apply [fhd|qhd|uhd] | restore" end
  say((ok and "" or "안 함: ") .. detail)
  return ok, detail
end

if type(SlashCmdList) == "table" then
  SLASH_DFDETAILSLAYOUT1 = "/dfdetails"
  SlashCmdList.DFDETAILSLAYOUT = function(message) return Layout:Run(message) end
end

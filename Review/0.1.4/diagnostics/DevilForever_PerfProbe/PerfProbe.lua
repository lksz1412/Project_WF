local frame = CreateFrame("Frame")
local maxFrames = 65536
local maxRuns = 12
local active, latest
local addons = {"!DevilForever_Core", "Dominos", "PitBull4", "ForeverUnitFrames",
                "Quartz", "Grid2", "Hekili", "Details"}

frame:Hide()

local function say(text)
  print("Devil Forever frame time: " .. text)
end

local function history(create)
  local db = DevilForever_PerfProbeDB
  if db == nil and create then
    db = {schema = 1, runs = {}}
    DevilForever_PerfProbeDB = db
  end
  if type(db) == "table" and db.schema == 1 and type(db.runs) == "table" then
    return db.runs
  end
end

local function loadedAddons()
  local loaded = {}
  local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded
  if type(isLoaded) == "function" then
    for _, name in ipairs(addons) do
      if isLoaded(name) then loaded[#loaded + 1] = name end
    end
  end
  return loaded
end

local function report(result)
  say(string.format("%s | %d frames in %.2fs | median %.2f ms | p95 %.2f ms | p99 %.2f ms | max %.2f ms%s",
    result.label, result.frames, result.seconds, result.medianMs, result.p95Ms,
    result.p99Ms, result.maxMs, result.limited and " | sample limit reached" or ""))
end

local function canReport(result)
  return type(result) == "table" and type(result.label) == "string"
    and type(result.frames) == "number" and type(result.seconds) == "number"
    and type(result.medianMs) == "number" and type(result.p95Ms) == "number"
    and type(result.p99Ms) == "number" and type(result.maxMs) == "number"
end

local function stop()
  frame:SetScript("OnUpdate", nil)
  frame:Hide()
  active = nil
end

local function finish(run, limited)
  stop()
  local samples = run.samples
  local count = #samples
  table.sort(samples)
  local middle = (count + 1) / 2
  latest = {
    label = run.label,
    frames = count,
    seconds = run.elapsed,
    targetSeconds = run.target,
    medianMs = 500 * (samples[math.floor(middle)] + samples[math.ceil(middle)]),
    p95Ms = 1000 * samples[math.ceil(count * 0.95)],
    p99Ms = 1000 * samples[math.ceil(count * 0.99)],
    maxMs = 1000 * samples[count],
    limited = limited,
    loaded = run.loaded,
  }
  local runs = history(true)
  if runs then
    while #runs >= maxRuns do table.remove(runs, 1) end
    runs[#runs + 1] = latest
  end
  report(latest)
end

local function sample(_, elapsed)
  if elapsed <= 0 then return end
  local run = active
  local samples = run.samples
  samples[#samples + 1] = elapsed
  run.elapsed = run.elapsed + elapsed
  if run.elapsed >= run.target then
    finish(run, false)
  elseif #samples >= maxFrames then
    finish(run, true)
  end
end

local function beginSampling()
  frame:SetScript("OnUpdate", sample)
end

local function usage()
  say("/dfperf start <label> [5-60 seconds] | /dfperf report | /dfperf cancel")
end

local function command(message)
  local action, args = message:match("^%s*(%S*)%s*(.-)%s*$")
  if action == "start" then
    local label, seconds = args:match("^([%w_-]+)%s*(%d*)$")
    local target = seconds == "" and 30 or tonumber(seconds)
    if not label or #label > 32 or not target or target < 5 or target > 60 then return usage() end
    if active then return say("A sample is running. Cancel it before starting another.") end
    active = {label = label, target = target, elapsed = 0, samples = {}, loaded = loadedAddons()}
    frame:SetScript("OnUpdate", beginSampling)
    frame:Show()
    say(string.format("Recording %s for %ds.", label, target))
  elseif action == "cancel" and args == "" then
    if not active then return say("No sample is running.") end
    stop()
    say("Sample canceled.")
  elseif action == "report" and args == "" then
    local runs = history(false)
    local result = latest or (runs and runs[#runs])
    if canReport(result) then return report(result) end
    say("No completed sample.")
  else
    usage()
  end
end

SLASH_DEVILFOREVERPERF1 = "/dfperf"
SlashCmdList.DEVILFOREVERPERF = command

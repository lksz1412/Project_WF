--[[----------------CONFIG---------------------
NOTE: databrokers will always update in real time, this is just configuring the tooltip

wantAlphaSorting
	false: sorts addon list by usage (descending) 
	true: sorts addon list in alphabetical order
	
wantColoring
	true: colors addon names AND memusage 
	false: just colors memusage and applies them to colors labeled in toc
	
UPDATEPERIOD
	number (seconds) that your data broker AND tooltip will be updated IMPORTANT!!!! ANYTHING UNDER 2 will likely effect performance!

MEMTHRESH
	number (kb) that will limit addon visibility, anything less than this number will NOT show in tooltip
	
colorgradient
	number that corresponds to the top "red" value of your addon usage..used for gradience and Tekkub color gradient function

maxaddons	
	max number of addons that will be displayed in tooltip. NOTE: if you are using alphabetical sorting it will NOT display all addons and will 
	cut off based on this number.  Keep default value of 100 if you do not want that to happen	
]]

local wantAlphaSorting = true 
local wantColoring = false
local UPDATEPERIOD = 2 
local MEMTHRESH = 50
local colorgradient = 50 
local maxaddons = 100 
------------------END of CONFIG---------------

if not LibStub then error("shPerformance requires LibStub") end

local prevmem, tipshownMem, tipshownLatency = collectgarbage("count")
local format, modf, floor, GetNetStats, GetFramerate, collectgarbage, lower = format, math.modf, floor, GetNetStats, GetFramerate, collectgarbage, lower
local UpdateAddOnMemoryUsage, GetAddOnMemoryUsage, GetAddOnInfo, select, sort = UpdateAddOnMemoryUsage, GetAddOnMemoryUsage, GetAddOnInfo, select, sort
local IsAddOnLoaded, ipairs, insert, print = IsAddOnLoaded, ipairs, table.insert, print
local GameTooltip, AddLine, AddDoubleLine = GameTooltip, AddLine, AddDoubleLine


local fpsIcon = "Interface\\AddOns\\shPerformance\\media\\fpsicon"
local msIcon = "Interface\\AddOns\\shPerformance\\media\\msicon"

---------------------
--> FUNCTIONS
---------------------

--INIT
local addons = {}  --main table to manipulate
local gFrame = CreateFrame("frame")
gFrame:RegisterEvent("PLAYER_LOGIN")
gFrame:SetScript("OnEvent", function()	
	-->main table
	for i=1,GetNumAddOns(), 1 do
		local tester = GetAddOnEnableState(nil,i) -- Thanks Memnoch! select(4,GetAddOnInfo(i))		
		if tester >= 1 then -->check to see if addon is even enabled 
			local name = select(1, GetAddOnInfo(i))		
			insert(addons, name)
		end 
	end	
	sort(addons, function(a,b) return a and b and a:lower() < b:lower() end)	
	collectgarbage("collect") 
end)

-->sort based on usage (will check to see what usage in tooltip updater)
local usageSort =  function (a,b) 
	return GetAddOnMemoryUsage(a) > GetAddOnMemoryUsage(b)
end

-->Format Mem with stylez
local formatMem = function(mem, x)
	if x then
		if mem > 1024 then return format("%.2f |cffE8D200mb|r", mem/1024)
		else return format("%.1f |cffE8D200kb|r", mem) end
	else
		if mem > 1024 then return format("%.2f mb", mem/1024)
		else return format("%.1f kb", mem) end
	end
end

-->TEKKUB created function for color gradience, awesome!--
local ColorGradient = function(perc, r1, g1, b1, r2, g2, b2, r3, g3, b3)
	if perc >= 1 then return r3, g3, b3 elseif perc <= 0 then return r1, g1, b1 end
	local segment, relperc = modf(perc*2)
	if segment == 1 then r1, g1, b1, r2, g2, b2 = r2, g2, b2, r3, g3, b3 end
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

-->tooltip anchor
local UIParent = UIParent
local GetTipAnchor = function(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

----------------------
--> MODULES AND FRAMES
----------------------
local ffps = CreateFrame("frame")
local flatency = CreateFrame("frame")
local lib = LibStub:GetLibrary("LibDataBroker-1.1")
local datafps = lib:NewDataObject("shFps", { type = "data source", text = "Initializing...fps", icon = fpsIcon }) 
local datalatency = lib:NewDataObject("shLatency", { type = "data source", text = "Initializing...ms", icon = msIcon }) 

----------------------
--> ONUPDATE HANDLERS
----------------------

-->shFps OnUpdate script
local elapsedFpsController = -10
ffps:SetScript("OnUpdate", function(self, t)
	elapsedFpsController = elapsedFpsController - t
	if elapsedFpsController < 0 then 
		if tipshownMem and not IsAddOnLoaded("shMem") then datafps.OnEnter(tipshownMem) end
		local fps = GetFramerate()
		local r, g, b = ColorGradient(fps/75, 1,0,0, 1,1,0, 0,1,0)
		datafps.text = format("|cff%02x%02x%02x%.0f|r |cffE8D200fps|r", r*255, g*255, b*255, fps)
		elapsedFpsController = UPDATEPERIOD
	end
end)

-->shLatency OnUpdate script
local elapsedLatencyController = -10
flatency:SetScript("OnUpdate", function(self, t)
	elapsedLatencyController = elapsedLatencyController - t
	if elapsedLatencyController < 0 then
		if tipshownLatency then datalatency.OnEnter(tipshownLatency) end
		local _, _, lh, lw = GetNetStats()
		local r, g, b = ColorGradient(((lh+lw)/2)/1000, 0,1,0, 1,1,0, 1,0,0)
		datalatency.text = format("|cff%02x%02x%02x%.0f/%.0f(w)|r |cffE8D200ms|r", r*255, g*255, b*255, lh, lw)
		elapsedLatencyController = UPDATEPERIOD + 20 --> blizzard set high update rate on this
	end
end)

----------------------
--> ONLEAVE FUNCTIONS
----------------------
local GameTooltip = GameTooltip
if not IsAddOnLoaded("shMem") then
	function datafps.OnLeave()
		GameTooltip:SetClampedToScreen(true)
		GameTooltip:Hide()
		tipshownMem = nil
	end
end

function datalatency.OnLeave() 
	GameTooltip:SetClampedToScreen(true)
	GameTooltip:Hide()
	tipshownLatency = nil
end

----------------------
--> ONENTER FUNCTIONS
----------------------
function datalatency.OnEnter(self)
	tipshownLatency = self
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(GetTipAnchor(self))
	GameTooltip:ClearLines()
	
	GameTooltip:AddLine("|cff0062ffsh|r|cff0DEB11Latency|r")
	GameTooltip:AddLine("[Bandwidth/Latency]")
	GameTooltip:AddLine(format("|cffc3771aDataBroker|r based addon to show your network latency (ms)\nupdated every |cff06DDFA%s second(s)|r!\n", 30))
	
	local binz, boutz, l, w = GetNetStats()
	local rin, gin, bins = ColorGradient(binz/20, 0,1,0, 1,1,0, 1,0,0)
	local rout, gout, bout = ColorGradient(boutz/5, 0,1,0, 1,1,0, 1,0,0)
	local r, g, b = ColorGradient(((l+w)/2)/1000, 0,1,0, 1,1,0, 1,0,0)
	
	GameTooltip:AddDoubleLine("|cff42AAFFHOME|r |cffFFFFFFRealm|r |cff0deb11(latency)|r:", format("%.0f ms", l), nil, nil, nil, r, g, b)
	GameTooltip:AddDoubleLine("|cffDCFF42WORLD|r |cffFFFFFFServer|r |cff0deb11(latency)|r:", format("%.0f ms", w), nil, nil, nil, r, g, b)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("|cff06ddfaIncoming bandwidth|r |cff0deb11(download)|r usage:", format("%.2f kb/sec", binz), nil, nil, nil, rin, gin, bins)
	GameTooltip:AddDoubleLine("|cff06ddfaOutgoing bandwidth|r |cff0deb11(upload)|r usage:", format("%.2f kb/sec", boutz), nil, nil, nil, rout, gout, bout)	
	--GameTooltip:AddLine("\n|cffC3771ALatency|r |cff06ddfa(def)|r: Latency (or delay) is an expression of how long it\ntakes for a packet of data to get from one point to another")
	elapsedLatencyController = -10
	GameTooltip:Show()
end

if not IsAddOnLoaded("shMem") then
	function datafps.OnEnter(self)
		tipshownMem = self
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(GetTipAnchor(self))
		GameTooltip:ClearLines()
		
		GameTooltip:AddLine("|cff0062ffsh|r|cff0DEB11Performance|r")
		GameTooltip:AddLine("[Memory]")
		
		GameTooltip:AddLine(format("|cffc3771aDataBroker|r based addon to show your addon memory\nand fps updated every |cff06DDFA%s second(s)|r!\n", UPDATEPERIOD))
		
		GameTooltip:AddDoubleLine("# | |cffC3771AAddon|r |cff06ddfaName|r", format("|cffC3771AMemory|r above (|cff06ddfa%s kb|r)", MEMTHRESH))
		GameTooltip:AddDoubleLine("|cffffffff------------|r", "|cffffffff------------|r")
		
		local counter = 0 -- for numbering (listing) and coloring
		local addonmem = 0
		local hidden, hiddenmem, shownmem = 0, 0, 0
		
		if wantAlphaSorting == false then
			sort(addons, usageSort) -->sort numerically by usage (descending) if desired
		end
		
		UpdateAddOnMemoryUsage()		
		for i, v in ipairs(addons) do
			local newname
			local mem = GetAddOnMemoryUsage(v)
			local r, g, b = ColorGradient((mem - MEMTHRESH)/1024, 0,1,0, 1,1,0, 1,0,0)
			addonmem = addonmem + mem
			if mem > MEMTHRESH  and maxaddons > counter then
				counter = counter + 1
				hidden = #addons - counter
				shownmem = shownmem + mem
				newname = select(2,GetAddOnInfo(v))
				local memstr = formatMem(mem) 
				if wantColoring then
					if counter < 10 then GameTooltip:AddDoubleLine(format("  |cffDAB024%.0f)|r %s", counter, newname), memstr, r, g, b, r, g, b)  
					else GameTooltip:AddDoubleLine(format("|cffDAB024%.0f)|r %s", counter, newname), memstr, r, g, b, r, g, b) end
				else
					if counter < 10 then GameTooltip:AddDoubleLine(format("  |cffDAB024%.0f)|r %s", counter, newname), memstr, 1, 1, 1, r, g, b)  
					else GameTooltip:AddDoubleLine(format("|cffDAB024%.0f)|r %s", counter, newname), memstr, 1, 1, 1, r, g, b) end
				end 
			end
		end
		
		GameTooltip:AddDoubleLine("|cffffffff------------|r", " ")
		
		hiddenmem = addonmem - shownmem
		local r, g, b = ColorGradient(addonmem/(colorgradient*1024), 0,1,0, 1,1,0, 1,0,0)
		GameTooltip:AddDoubleLine(format("|cff06DDFA[%d] hidden addons|r |cff0deb11(memory < %d kb)|r:", hidden, MEMTHRESH), formatMem(hiddenmem), nil, nil, nil, r1, g1, b1)
		GameTooltip:AddDoubleLine(" ", "|cffffffff------------|r")
		
		r, g, b = ColorGradient(addonmem/(colorgradient*1024), 0,1,0, 1,1,0, 1,0,0)
		local memstr = formatMem(addonmem) 
		GameTooltip:AddDoubleLine(" ", format("|cffC3771ATOTAL USER ADDON|r |cffffffffmemory usage:|r  %s", memstr), nil, nil, nil, r,g,b)
		GameTooltip:AddDoubleLine(" ", " ")		
			
		local mem = collectgarbage("count")
		local deltamem = mem - prevmem
		prevmem = mem
		
		r, g, b = ColorGradient(mem/((colorgradient+20)*1024), 0,1,0, 1,1,0, 1,0,0)
		GameTooltip:AddDoubleLine("|cffC3771ADefault Blizzard UI|r memory usage:", format("%s", formatMem(mem-addonmem)), nil, nil, nil, r,g,b)
			
		r, g, b = ColorGradient(mem/((colorgradient+40)*1024), 0,1,0, 1,1,0, 1,0,0)
		GameTooltip:AddDoubleLine("|cff06DDFATOTAL UI|r memory usage:", format("%s", formatMem(mem)), nil,nil,nil, r,g,b)
			
		GameTooltip:AddDoubleLine("|cffffffff------------|r", "|cffffffff------------|r")
		
		r, g, b = ColorGradient(deltamem/15, 0,1,0, 1,1,0, 1,0,0)
		GameTooltip:AddDoubleLine("|cffc3771aGarbage|r churn", format("%.2f kb/sec", deltamem), nil,nil,nil, r,g,b)
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Click to force |cffc3771agarbage collection|r and to |cff06ddfaupdate|r tooltip!")
		
		elapsedFpsController = -10
		GameTooltip:Show()
	end

	function datafps.OnClick(self)
		datafps.OnEnter(self) -->updates tooltip		
		local collected, deltamem = 0, 0
		collected = collectgarbage('count')
		collectgarbage("collect")
		UpdateAddOnMemoryUsage()
		deltamem = collected - collectgarbage('count')				
		print(format("|cff0DEB11shPerformance|r - |cffC3771AGarbage|r Collected: |cff06ddfa%s|r", formatMem(deltamem, true)))
	end
end
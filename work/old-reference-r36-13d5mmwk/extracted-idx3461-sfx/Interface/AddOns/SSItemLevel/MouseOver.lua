local addonName, ns = ...
local _G = _G
local SSItemLevel = SSItemLevel or ns.SSItemLevel

if not SSItemLevel then return end

local gtt = GameTooltip;

local ITEMLEVEL_PREFIX = "아이템 레벨:|cffffffff"

-- Option Constants
local CACHE_SIZE = 25;		-- Change cache size here (Default 25)
local INSPECT_DELAY = .2;	-- The time delay for the scheduled inspection
local INSPECT_FREQ = 2;		-- How often after an inspection are we allowed to inspect again?
local INSPECT_TIME = .5;

-- Variables
local frame = CreateFrame("Frame","SSItemLevelTooltip");
frame:RegisterEvent("UNIT_INVENTORY_CHANGED");
frame:RegisterEvent("PLAYER_LOGIN")

frame:Hide()
local Inspect_Ready = nil
local updateElapsed = INSPECT_TIME
local readCount = 0
local cache = {};
local current = {};
-- Time of the last inspect reuqest. Init this to zero, just to make sure. This is a global so other addons could use this variable as well
lastInspectRequest = 0;

-- Helper function to determine if an "Inspect Frame" is open. Native Inspect as well as Examiner is supported.
local function IsInspectFrameOpen() return (InspectFrame and InspectFrame:IsShown()) or (Examiner and Examiner:IsShown()); end

-- Allow these to be accessed externally from other addons
frame.cache = cache;
frame.current = current;

local function SSItemLevelTooltip_Init()
	-- 옵션 초기화
	if (not SSItemLevelOpt) then
		SSItemLevelOpt = {}
		SSItemLevelOpt["enable"]= true
		SSItemLevelOpt["count"]	= 2
		SSItemLevelOpt["CacheSize"]	= CACHE_SIZE
	end
	local panel = CreateFrame("Frame", addonName.."Option")
	panel.name = addonName

	local function createCheckButton(parent, name, text, checked, fun)
		local check = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
		_G[check:GetName() .. "Text"]:SetText(text)
		_G[check:GetName() .. "Text"]:ClearAllPoints()
		_G[check:GetName() .. "Text"]:SetPoint("LEFT", check, "RIGHT", 3, 1)
		check:SetChecked(checked)
		check:SetScript("OnClick", fun)

		return check
	end

	local function createSlider(parent, name, text, tip, w, h, min, max, v, vs)
		local s = CreateFrame("slider", name, parent, "OptionsSliderTemplate")
		s:EnableMouseWheel(true)
		s.tooltipText = tip
		s:SetSize(w,h)
		s:SetMinMaxValues(min, max)
		s:SetValueStep(vs)
		s:SetValue(v)
		_G[s:GetName().."Text"]:SetText(text)
		_G[s:GetName().."Low"]:SetText(min)
		_G[s:GetName().."High"]:SetText(max)

		return s
	end

	panel:SetScript("OnShow", function(self)
		local t1 = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		t1:SetJustifyH("LEFT")
		t1:SetJustifyV("TOP")
		t1:SetPoint("TOPLEFT", 16, -16)
		t1:SetText(self.name)

		local t2 = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		t2:SetJustifyH("LEFT")
		t2:SetJustifyV("TOP")
		t2:SetHeight(43)
		t2:SetPoint("TOPLEFT", t1, "BOTTOMLEFT", 0, -8)
		t2:SetPoint("RIGHT", self, "RIGHT", -32, 0)
		t2:SetNonSpaceWrap(true)
		t2:SetFormattedText( "Notes: %s\nAuthor: %s\nVersion: %s",
				GetAddOnMetadata(addonName, "Notes"),
				GetAddOnMetadata(addonName, "Author"),
				GetAddOnMetadata(addonName, "Version"))

		local checkEnable= createCheckButton(self, self:GetName().."Enable", "툴팁에 아이템 평균 레벨 표기.", SSItemLevelOpt["enable"],
		function(self)
			SSItemLevelOpt["enable"] = self:GetChecked()
		end)
		checkEnable:SetPoint("TOPLEFT", t2, "BOTTOMLEFT", -2, -12)

		local ssn = createSlider(	self,
									self:GetName().."Count",
									format("%s %d", "|c00FFFFAA다시 읽기 횟수",(SSItemLevelOpt["count"] and SSItemLevelOpt["count"] or 3)),
									nil,
									180,
									15,
									1,
									5,
									(SSItemLevelOpt["count"] and SSItemLevelOpt["count"] + 1 or 3),
									1)
		ssn:SetPoint("TOPLEFT", checkEnable, "BOTTOMLEFT", 6, -24)
		ssn:SetScript("OnValueChanged", function(self, value)
			SSItemLevelOpt["count"] =  value - 1
			_G[ssn:GetName().."Text"]:SetText(format("%s %d", "|c00FFFFAA다시 읽기 횟수",SSItemLevelOpt["count"]))
		end)

		local ssc = createSlider(	self,
									self:GetName().."Cache",
									format("%s %d", "|c00FFFFAA케시 크기",(SSItemLevelOpt["CacheSize"] and SSItemLevelOpt["CacheSize"] or CACHE_SIZE)),
									nil,
									180,
									15,
									0,
									50,
									(SSItemLevelOpt["CacheSize"] and SSItemLevelOpt["CacheSize"] or CACHE_SIZE),
									1)

		ssc:SetPoint("LEFT", ssn, "RIGHT", 50, 0)
		ssc:SetScript("OnValueChanged", function(self, value)
			SSItemLevelOpt["CacheSize"] =  value
			_G[ssc:GetName().."Text"]:SetText(format("%s %d", "|c00FFFFAA케시 크기",SSItemLevelOpt["CacheSize"]))
		end)


		self:SetScript("OnShow", nil)
	end)
	InterfaceOptions_AddCategory(panel)
end

local function GetGearScore(unit)
	local count, tot, txt = #SSItemLevel.itemslots, 0
	local level = UnitLevel(unit)
	for slot,n in pairs(SSItemLevel.itemslots) do
		local id = GetInventorySlotInfo(n)
		local link = GetInventoryItemLink(unit, id)
		txt = nil
		if link and link ~= "" then
			local ilevel = SSItemLevel:GetItemLevel(unit, link, level, id)
			if (ilevel and ilevel > 0) then
				tot = tot + ilevel
			end
		elseif (n == "SecondaryHandSlot") then
			link = GetInventoryItemLink(unit, 16) -- 주장비
			if (link and link ~= "" and ("INVTYPE_2HWEAPON" == itemEquipLoc or "INVTYPE_RANGED" == itemEquipLoc or "INVTYPE_RANGEDRIGHT")) then
				count = count - 1
			end
		end
	end
	return tot/count
end

local function UpdateItemLevel(isInspect)
	local tot = GetGearScore(current.unit)
	current.format = format("%s %.2f", ITEMLEVEL_PREFIX, tot);
	local cacheUpdate = nil
	-- Set the tips line output, for inspect, only update if the tip is still showing a unit!
	if (not isInspect) then
		gtt:AddLine(current.format);
		cacheUpdate = true
	elseif (gtt:GetUnit()) then
		if readCount > SSItemLevelOpt["count"] then
			for i = 2, gtt:NumLines() do
				if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..ITEMLEVEL_PREFIX)) then
					_G["GameTooltipTextLeft"..i]:SetText(current.format);
					-- Do not call Show() if the tip is fading out, this only works with TipTac, if TipTacTalents are used alone, it might still bug the fadeout
					if (not gtt.fadeOut) then
						gtt:Show();
					end
					break;
				end
			end
			Inspect_Ready = nil
			cacheUpdate = true
		else
			for i = 2, gtt:NumLines() do
				if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..ITEMLEVEL_PREFIX)) then
					_G["GameTooltipTextLeft"..i]:SetText(_G["GameTooltipTextLeft"..i]:GetText()..".");
					-- Do not call Show() if the tip is fading out, this only works with TipTac, if TipTacTalents are used alone, it might still bug the fadeout
					if (not gtt.fadeOut) then
						gtt:Show();
					end
					return;
				end
			end
		end
	end

	-- Organise Cache
	if cacheUpdate then
		local cacheSize = SSItemLevelOpt["CacheSize"] or CACHE_SIZE;
		for i = #cache, 1, -1 do
			if (current.name == cache[i].name) then
				tremove(cache,i);
				break;
			end
		end
		if (#cache > cacheSize) then
			tremove(cache,1);
		end
		-- Cache the new entry
		if (cacheSize > 0) then
			cache[#cache + 1] = CopyTable(current);
		end
	end

end

-- OnEvent
frame:SetScript("OnEvent",function(self,event,guid)
	if event == "INSPECT_READY" then
		self:UnregisterEvent(event);
		if (guid == current.guid) then
			Inspect_Ready = true;
			updateElapsed = 0;
			readCount = 0;
			UpdateItemLevel(1)
			readCount = readCount + 1;
		end
	elseif (event == "UNIT_INVENTORY_CHANGED") then
		if ( not current.unit or UnitGUID(guid) ~= current.guid ) then
			for i = #cache, 1, -1 do
				if (current.guid == cache[i].guid) then
					tremove(cache,i);
					return
				end
			end
		end
	elseif (event == "PLAYER_LOGIN") then
		self:UnregisterEvent("PLAYER_LOGIN")
		SSItemLevelTooltip_Init()
		SSItemLevelTooltip_Init = nil
	end
end);

-- OnUpdate
frame:SetScript("OnUpdate",function(self,elapsed)
	self.nextUpdate = (self.nextUpdate - elapsed);
	if (self.nextUpdate <= 0) then
		self:Hide();
		-- Make sure the mouseover unit is still our unit
		-- Check IsInspectFrameOpen() again: Since if the user right-clicks a unit frame, and clicks inspect, it could cause TTT to schedule an inspect, while the inspection window is open
		if (UnitGUID("mouseover") == current.guid) and (not IsInspectFrameOpen()) then
			lastInspectRequest = GetTime();
			self:RegisterEvent("INSPECT_READY");
			NotifyInspect(current.unit);
		end
	end
end);


-- HOOK: OnTooltipSetUnit
gtt:HookScript("OnTooltipSetUnit",function(self,...)
	-- Abort any delayed inspect in progress
	frame:Hide();
	Inspect_Ready = nil;
	-- 여기에 사용여부 옵션을 달아서..첵크 하자..
	if not SSItemLevelOpt["enable"] then return end


	-- Get the unit -- Check the UnitFrame unit if this tip is from a concated unit, such as "targettarget".
	local _, unit = self:GetUnit();
	if (not unit) then
		local mFocus = GetMouseFocus();
		if (mFocus) and (mFocus.unit) then
			unit = mFocus.unit;
		end
	end
	-- No Unit or not a Player
	if (not unit) or (not UnitIsPlayer(unit)) then
		return;
	end

	-- Wipe Current Record
	wipe(current);
	current.unit = unit;
	current.name = UnitName(unit);
	current.guid = UnitGUID(unit);

	-- Show Cached Talents, If Available
	local cacheLoaded = false;
	for _, entry in ipairs(cache) do
		if (current.name == entry.name) then
			self:AddLine(entry.format);
			current.format = entry.format;
			cacheLoaded = true;
			return;
		end
	end
	-- No need for inspection on the player
	if (UnitIsUnit(unit,"player")) then
		UpdateItemLevel();
		return;
	end
	-- Queue an inspect request
	if (CanInspect(unit)) and (not IsInspectFrameOpen()) then
		frame:UnregisterEvent("INSPECT_READY")
		local lastInspectTime = (GetTime() - lastInspectRequest);
		frame.nextUpdate = (lastInspectTime > INSPECT_FREQ) and INSPECT_DELAY or (INSPECT_FREQ - lastInspectTime + INSPECT_DELAY);
		frame:Show();
		if (not cacheLoaded) then
			self:AddLine(ITEMLEVEL_PREFIX.." ");
		end
	end
end)

gtt:HookScript("OnUpdate", function(self,elapsed,...)
	if not Inspect_Ready then return end
	updateElapsed = updateElapsed - elapsed
	if updateElapsed <= 0 then
		updateElapsed = INSPECT_TIME;
		UpdateItemLevel(1);
		readCount = readCount + 1;
	end
end)


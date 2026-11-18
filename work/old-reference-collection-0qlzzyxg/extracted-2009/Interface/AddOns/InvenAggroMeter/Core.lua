InvenAggroMeter = CreateFrame("Frame")
InvenAggroMeter:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local _G = getfenv(0)
local pairs = _G.pairs
local format = _G.format
local tinsert = _G.table.insert
local CopyTable = _G.CopyTable
local sort = _G.table.sort
local min = _G.min
local max = _G.max
local select = _G.select
local random = _G.random
local GetTime = _G.GetTime
local UnitName = _G.UnitName
local UnitExists = _G.UnitExists
local UnitIsUnit = _G.UnitIsUnit
local UnitCanAttack = _G.UnitCanAttack
local UnitIsPlusMob = _G.UnitIsPlusMob
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsFriend = _G.UnitIsFriend
local UnitPlayerControlled = _G.UnitPlayerControlled
local GetNumRaidMembers = _G.GetNumRaidMembers
local GetNumPartyMembers = _G.GetNumPartyMembers
local UnitThreatSituation = _G.UnitThreatSituation
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitGUID = _G.UnitGUID
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitAffectingCombat = _G.UnitAffectingCombat
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTexture = _G.GetSpellTexture
local UnitAura = _G.UnitAura
local GetShapeshiftForm = _G.GetShapeshiftForm
local GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo
local UnitIsVisible = _G.UnitIsVisible
local IsInInstance = _G.IsInInstance
local UnitIsNear = function(unit) return UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) end
local mob, m1, m2, run, playerID, n, tankingUnit, unitName, hasPet, maxThreat, mobGUID, prevMobGUID, prevThreat, guid
local list, isTanking, state, scaledPercent, rawPercent, threatValue, threatPercent, updateThreat, status, targettarget, ckunit, ckclass, temp, start, endl
local threat, threatPercent = {}, {}
local SM = LibStub("LibSharedMedia-3.0")
local Broker = LibStub("LibDataBroker-1.1")
local MapButton = LibStub("LibMapButton-1.1")

SLASH_INVENAGGROMETER1 = "/iam"
SLASH_INVENAGGROMETER2 = "/인벤어그로"
SLASH_INVENAGGROMETER3 = "/invenaggro"
SLASH_INVENAGGROMETER4 = "/invenaggrometer"

local defaultOption = {
	shown = true,
	useSolo = true,
	lock = false,
	updateDelay = 0.25,
	list = 10,
	grow = true,
	pos = {},
	width = 200,
	height = 171,
	autoSizing = false,
	barHeight = 16,
	scale = 1,
	texture = "Minimalist",
	autoHide = false,
	backdropColor = { 0, 0, 0, 0.6 },
	titleColor = { 0, 0, 0, 0.8 },
	itsyou = "하이라이트",
	hideThreat = false,
	hideTPS = false,
	warn = true,
	warnPercent = 80,
	warnInstance = true,
	shake = true,
	flash = true,
	text = true,
	sound = "고블린 2",
	WARRIOR = true,
	ROGUE = true,
	PRIEST = true,
	MAGE = true,
	WARLOCK = true,
	HUNTER = true,
	DRUID = true,
	SHAMAN = true,
	PALADIN = true,
	DEATHKNIGHT = true,
	PET = true,
}

local oldThreatTable, oldThreatStoreTime = {}, {}

local tablePool = {}
setmetatable(tablePool, {__mode = "kv"})

local function newTable()
	local t = next(tablePool) or {}
	tablePool[t] = nil
	return t
end

local function delTable(t)
	if type(t) == "table" then
		for k, v in pairs(t) do
			if type(v) == "table" then
				delTable(v)
			end
			t[k] = nil
		end
		t[true] = true
		t[true] = nil
		setmetatable(t, nil)
		tablePool[t] = true
	end
end

local function clearTable(t)
	if type(t) == "table" then
		for k, v in pairs(t) do
			t[k] = nil
		end
		t[true] = true
		t[true] = nil
		setmetatable(t, nil)
	end
end

function InvenAggroMeter:OnInit()
	if self.init then return end
	self.init = true
	self.member = {}
	local seed = {}
	self.classList = {}
	self.classColor = {}
	for class, color in pairs(RAID_CLASS_COLORS) do
		seed[class] = random(100)
		tinsert(self.classList, class)
		self.classColor[class] = { color.r, color.g, color.b }
	end
	sort(self.classList, function(a, b) return seed[a] > seed[b] end)
	self.randomThreat = random(50, 200) / 100
	SM:Register("statusbar", "Minimalist", "Interface\\AddOns\\InvenAggroMeter\\Texture\\Minimalist")
	SM:Register("statusbar", "Smooth", "Interface\\AddOns\\InvenAggroMeter\\Texture\\Smooth")
	SM:Register("statusbar", "Smooth v2", "Interface\\AddOns\\InvenAggroMeter\\Texture\\Smoothv2")
	SM:Register("statusbar", "BantoBar", "Interface\\AddOns\\InvenAggroMeter\\Texture\\BantoBar")

	SM:Register("sound", "Explosion", "Sound\\Doodad\\Hellfire_Raid_FX_Explosion05.wav")
	SM:Register("sound", "Wham!", "Sound\\Doodad\\PVP_Lordaeron_Door_Open.wav")
	SM:Register("sound", "Simon Chime", "Sound\\Doodad\\SimonGame_LargeBlueTree.wav")
	SM:Register("sound", "War Drums", "Sound\\Event Sounds\\Event_wardrum_ogre.wav")
	SM:Register("sound", "Cheer", "Sound\\Event Sounds\\OgreEventCheerUnique.wav")
	SM:Register("sound", "Humm", "Sound\\Spells\\SimonGame_Visual_GameStart.wav")
	SM:Register("sound", "Fel Portal", "Sound\\Spells\\Sunwell_Fel_PortalStand.wav")
	SM:Register("sound", "Fel Nova", "Sound\\Spells\\SeepingGaseous_Fel_Nova.wav")
	SM:Register("sound", "쑨", "Sound\\Creature\\CThun\\CThunYouWillDIe.wav")
	SM:Register("sound", "모로스", "Sound\\Creature\\Moroes\\MoroesSlay03.wav")
	SM:Register("sound", "일리단", "Sound\\Creature\\Illidan\\BLACK_Illidan_04.wav")
	SM:Register("sound", "킬제덴 1", "Sound\\Creature\\KilJaeden\\KILJAEDEN01.wav")
	SM:Register("sound", "킬제덴 2", "Sound\\Creature\\KilJaeden\\KILJAEDEN02.wav")
	SM:Register("sound", "킬제덴 3", "Sound\\Creature\\KilJaeden\\KILJAEDEN03.wav")
	SM:Register("sound", "대모 샤라즈", "Sound\\Creature\\MotherShahraz\\BLCKTMPLE_MothrSha_Aggro01.wav")
	SM:Register("sound", "고블린 1", "Sound\\Creature\\GoblinMaleGruffNPC\\GoblinMaleGruffNPCFarewell01.wav")
	SM:Register("sound", "고블린 2", "Sound\\Creature\\GoblinMaleGruffNPC\\GoblinMaleGruffNPCPissed04.wav")
	SM:Register("sound", "벨라스트라즈", "Sound\\Creature\\Vaelastrasz\\VaelastraszSlay.wav")

	self.title = format("IAM v%s", GetAddOnMetadata("InvenAggroMeter", "Version"))
	self.website = GetAddOnMetadata("InvenAggroMeter", "X-Website")
	self.icon = "Interface\\AddOns\\InvenAggroMeter\\Texture\\icon.tga"

	local optf = CreateFrame("Frame", "InvenAggroMeterOptionFrame", InterfaceOptionsFramePanelContainer)
	optf:Hide()
	optf.name = "인벤 어그로 미터기"
	optf:SetScript("OnShow", function()
		LoadAddOn("InvenAggroMeter_Options")
		InvenAggroMeter:CreateOptionFrame()
		InvenAggroMeter:ReflashOption()
	end)
	InterfaceOptions_AddCategory(optf)
end

function InvenAggroMeter:UnitIsMob(unit)
	return UnitExists(unit) and UnitCanAttack("player", unit) and not UnitIsDeadOrGhost(unit) and (not UnitIsPlayer(unit) and not UnitPlayerControlled(unit))
end

function InvenAggroMeter:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if not self.init then
		self:OnInit()
	end
	if self.enable then return end
	if select(2, GetAddOnInfo("BlueBlizz")) then
		if InvenAggroMeterDB == nil or InvenAggroMeterDB.BlueLayout == nil then
			InvenAggroMeterDB = {
				BlueLayout = true, grow = false, WARRIOR = true, warn = true, shown = true, barHeight = 18,
				hidePercent = false, hideThreat = false, lock = true, PET = true, DRUID = true, sound = "Done",
				text = true, WARLOCK = true, height = 133.8560896067074,
				minimapButton = { show = true, radius = 80, angle = 285.8301661750185, dragable = false, rounding = 10 },
				pos = { 605.52391166982, 86.62573595494465 },
				backdropColor = { 0.09019607843137255, 0.09019607843137255, 0.392156862745098, 0.3899999856948853 },
				autoSizing = true, scale = 0.8100000000000001, flash = true, updateDelay = 0.25,
				useSolo = false, autoHide = true, shake = true, texture = "Minimalist", DEATHKNIGHT = true,
				itsyou = "하이라이트", list = 10, SHAMAN = true, HUNTER = true, width = 165.5232978431478,
				ROGUE = true, PRIEST = true, MAGE = true, warnPercent = 80, warnInstance = true, PALADIN = true,
				titleColor = { 1, 0, 0, 0.6400000154972076 }, hideTPS = false,
			}
		end
	else
		InvenAggroMeterDB = InvenAggroMeterDB or CopyTable(defaultOption)
	end
	if not InvenAggroMeterDB.backdropColor then
		InvenAggroMeterDB = CopyTable(defaultOption)
	end
	SlashCmdList["INVENAGGROMETER"] = self.OnClick
	MapButton:CreateButton(InvenAggroMeter, "InvenAggroMeterMapButton", self.icon, 200, InvenAggroMeterDB.minimapButton)
	Broker:NewDataObject("InvenAggroMeter", {
		type = "launcher",
		text = "IAM",
		OnClick = self.OnClick,
		icon = self.icon,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			InvenAggroMeter:OnTooltip(tooltip)
		end,
	})
	self.playerguid = UnitGUID("player")
	self.playerClass = select(2, UnitClass("player"))
	if self.playerClass == "WARRIOR" then
		self.tankingAura = GetSpellInfo(71)
	elseif self.playerClass == "DRUID" then
		if GetSpellTexture(GetSpellInfo(9634)) then
			self.tankingAura = GetSpellInfo(9634)
		else
			self.tankingAura = GetSpellInfo(5487)
		end
	elseif self.playerClass == "PALADIN" then
		self.tankingAura = GetSpellInfo(25780)
	elseif self.playerClass == "DEATHKNIGHT" then
		self.tankingAura = GetSpellInfo(48263)
	end
	self.enable = true
	self.nextWarnTime = 0
	self.updateTimer = 0
	self:CreateFrame()
	self:SetScript("OnUpdate", self.SetTitle)
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.timer = GetTime()
	m1, m2 = GetNumRaidMembers(), GetNumPartyMembers()
	--self:CreateOptionFrame()
	self:CheckMemberList()
	self.ShowNumBar = 0
	self:SetAutoHide()
end

function InvenAggroMeter:OnClick()
	if not InvenAggroMeter.optionPanel then
		InvenAggroMeterOptionFrame:GetScript("OnShow")()
	end
	if InvenAggroMeter.optionPanel then
		for i = 1, #InvenAggroMeter.optionPanel do
			if InterfaceOptionsFramePanelContainer.displayedPanel == InvenAggroMeter.optionPanel[i] then
				InterfaceOptionsFrameOkay_OnClick()
				return
			end
		end
		InterfaceOptionsFrame_OpenToCategory(InvenAggroMeter.optionPanel[2])
		InterfaceOptionsFrame_OpenToCategory(InvenAggroMeter.optionPanel[1])
	end
end

function InvenAggroMeter:OnTooltip(tooltip)
	tooltip = tooltip or GameTooltip
	tooltip:AddLine(InvenAggroMeter.title)
	tooltip:AddLine("|cffffffff"..InvenAggroMeter.website.."|r")
	tooltip:AddLine("|cffffff00클릭: 설정창 열기|r")
end

function InvenAggroMeter:PLAYER_REGEN_ENABLED()
	self.incombat = false
	self.nextWarnTime = 0
	if self.shakeFrame then
		self.shakeFrame:GetScript("OnHide")(self.shakeFrame)
	end
	if self.flashFrame then
		self.flashFrame:Hide()
	end
	if not self.testBar then
		self:HideBars()
	end
	self:PLAYER_TARGET_CHANGED()
	self:ClearData()
	InvenAggroMeterFrame.title:SetTextColor(1, 1, 1)
	self:SetAutoHide()
end

function InvenAggroMeter:PLAYER_REGEN_DISABLED()
	self.incombat = true
	self.testBar = nil
	self:PLAYER_TARGET_CHANGED()
end

function InvenAggroMeter:PLAYER_TARGET_CHANGED()
	if self.incombat then
		if self:GetScript("OnUpdate") ~= self.OnUpdate then
			self:SetScript("OnUpdate", self.OnUpdate)
		end
	elseif UnitExists("target") then
		self:SetScript("OnUpdate", self.OnUpdate2)
	else
		self:SetScript("OnUpdate", nil)
	end
end

function InvenAggroMeter:PARTY_MEMBERS_CHANGED()
	self:CheckMemberList()
end

function InvenAggroMeter:RAID_ROSTER_UPDATE()
	self:CheckMemberList()
end

function InvenAggroMeter:IsTanker()
	if self.tankingAura then
		if (GetShapeshiftForm() > 0 and select(2, GetShapeshiftFormInfo(GetShapeshiftForm())) == self.tankingAura) or UnitAura("player", self.tankingAura) then
			return true
		end
	end
	return false
end

function InvenAggroMeter:CheckMemberList()
	m1, m2 = GetNumRaidMembers(), GetNumPartyMembers()
	threat, threatPercent = {}, {}
	self.member = {}
	self.numMember = 0
	if InvenAggroMeterDB.shown then
		if m1 > 0 then
			for i = 1, m1 do
				ckunit = ("raid%d"):format(i)
				ckclass = select(2, UnitClass(ckunit)) or "*"
				if InvenAggroMeterDB[ckclass] then
					self.numMember = self.numMember + 1
					self.member[ckunit] = true
					if InvenAggroMeterDB.PET and (ckclass == "HUNTER" or ckclass == "WARLOCK") then
						self.numMember = self.numMember + 1
						self.member[("raidpet%d"):format(i)] = true
					end
				end
			end
		elseif m2 > 0 then
			if InvenAggroMeterDB[self.playerClass] then
				self.numMember = 1
				self.member["player"] = true
			end
			if InvenAggroMeterDB.PET and (self.playerClass == "HUNTER" or self.playerClass == "WARLOCK") then
				self.numMember = self.numMember + 1
				 self.member["pet"] = true
			end
			for i = 1, m2 do
				ckunit = ("party%d"):format(i)
				ckclass = select(2, UnitClass(ckunit)) or "*"
				if InvenAggroMeterDB[ckclass] then
					self.numMember = self.numMember + 1
					self.member[ckunit] = true
					if InvenAggroMeterDB.PET and (ckclass == "HUNTER" or ckclass == "WARLOCK") then
						self.numMember = self.numMember + 1
						self.member[("partypet%d"):format(i)] = true
					end
				end
			end
		else
			if InvenAggroMeterDB[self.playerClass] then
				self.numMember = 1
				self.member["player"] = true
			end
			if InvenAggroMeterDB.PET and (self.playerClass == "HUNTER" or self.playerClass == "WARLOCK") then
				self.numMember = self.numMember + 1
				 self.member["pet"] = true
			end
		end
	end
end

function InvenAggroMeter:GetIsVisible()
	if InvenAggroMeterDB.shown then
		if m1 == 0 and m2 == 0 and not InvenAggroMeterDB.useSolo and not UnitExists("pet") then
			return false
		end
		return true
	else
		return false
	end
end

function InvenAggroMeter:IsSolo()
	if InvenAggroMeterDB.PET and UnitIsNear("pet") then
		return false
	elseif m1 == 0 and m2 == 0 then
		return true
	else
		return false
	end
end

function InvenAggroMeter:SetOnUpdate(v)
	self:SetAutoHide()
	if self.testBar then
		self:ToggleTestBar()
	end
end

function InvenAggroMeter:AddThreat(t)
	if t then
		tinsert(oldThreatTable, newTable())
		tinsert(oldThreatStoreTime, self.timer)
		for guid, value in pairs(t) do
			oldThreatTable[#oldThreatTable][guid] = value
		end
	else
		clearTable(oldThreatTable)
		clearTable(oldThreatStoreTime)
		oldThreatTable = newTable()
		oldThreatStoreTime = newTable()
	end
end

function InvenAggroMeter:GetTPS(guid)
	if guid and mob then
		if #oldThreatTable > 0 and (self.timer - 10) > oldThreatStoreTime[1] then
			if #oldThreatTable == 1 then
				return 0
			end
			if oldThreatTable[1][guid] and oldThreatTable[2][guid] and oldThreatTable[#oldThreatTable][guid] then
				return (oldThreatTable[#oldThreatTable][guid] - ((oldThreatTable[2][guid] - oldThreatTable[1][guid]) * ((self.timer - 10 - oldThreatStoreTime[1]) / (oldThreatStoreTime[2] - oldThreatStoreTime[1])) + oldThreatTable[1][guid])) / 1000
			end
		end
	end
end

function InvenAggroMeter:ClearData()
	prevThreat = 0
	clearTable(threat)
	clearTable(scaledPercent)
	threatPercent = newTable()
	scaledPercent = newTable()
	self:AddThreat()
end

function InvenAggroMeter:OnUpdate2(timer)
	self.updateTimer = self.updateTimer + timer
	if self.updateTimer >= InvenAggroMeterDB.updateDelay then
		self:SetTitle()
	end
end

function InvenAggroMeter:OnUpdate(timer)
	self.updateTimer = self.updateTimer + timer
	if self.incombat and self.updateTimer >= InvenAggroMeterDB.updateDelay then
		self.timer = GetTime()
		self.updateTimer = 0
		mob = self:SetTitle()
		list = self:GetIsVisible() and newTable() or nil
		updateThreat = false
		InvenAggroMeterFrame.player = nil
		if list and mob then
			mobGUID = UnitGUID(mob)
			if prevMobGUID ~= mobGUID then
				prevMobGUID = mobGUID
				self:ClearData()
			end
			tankingUnit = nil
			targettarget = UnitIsFriend("player", "targettarget") and not UnitIsDeadOrGhost("targettarget") and "targettarget"
			if not InvenAggroMeterDB.PET and not UnitIsPlayer(targettarget) then
				targettarget = nil
			end
			for unit in pairs(self.member) do
				if UnitExists(unit) then
					guid = UnitGUID(unit)
					isTanking, status, scaledPercent, _, threatValue = UnitDetailedThreatSituation(unit, mob)
					scaledPercent = scaledPercent or 0
					if UnitIsUnit(unit, "player") then
						InvenAggroMeterFrame.player = unit
						InvenAggroMeterFrame.hasAggro = status or 0
						if status and status > 0 then
							InvenAggroMeterFrame.title:SetTextColor(GetThreatStatusColor(status))
						else
							InvenAggroMeterFrame.title:SetTextColor(1, 1, 1)
						end
					end
					if targettarget and UnitIsUnit(unit, targettarget) then
						targettarget = nil
					end
					if isTanking then
						tankingUnit = guid
					end
					if threatValue then
						if threat[guid] ~= threatValue then
							threat[guid] = threatValue
							updateThreat = true
						end
						threatPercent[guid] = scaledPercent
						tinsert(list, unit)
					elseif threat[guid] then
						 threat[guid] = nil
						 threatPercent[guid] = nil
						 updateThreat = true
					end
				elseif threat[guid] then
					threat[guid] = nil
					threatPercent[guid] = nil
					updateThreat = true
				end
			end
			if #list == 0 and UnitIsUnit("player", "targettarget") then
				isTanking = InvenAggroMeterFrame.player
				guid = UnitGUID("player")
				threat[guid] = threat[guid] or 0
				threatPercent[guid] = 100
				list = { "player" }
				updateThreat = true
			elseif targettarget then
				isTanking, status, scaledPercent, _, threatValue = UnitDetailedThreatSituation(targettarget, mob)
				guid = UnitGUID(targettarget)
				if isTanking then
					tankingUnit = targettarget
					if threatValue then
						if threat[guid] ~= threatValue then
							threat[guid] = threatValue
							updateThreat = true
						end
						threatPercent[guid] = 100
						tinsert(list, targettarget)
					end
				else
					threat[targettarget] = nil
					threatPercent[targettarget] = nil
					updateThreat = true
				end
			end
		end
		if list then
			self.testBar = nil
			InvenAggroMeterFrame:Show()
			while oldThreatStoreTime[2] and (self.timer - 10) > oldThreatStoreTime[2] do
				delTable(tremove(oldThreatTable, 1))
				tremove(oldThreatStoreTime, 1)
			end
			self:AddThreat(threat)
			if #list > 0 then
				if updateThreat then
					InvenAggroMeterFrame.threat1Prev = InvenAggroMeterFrame.threat1Max
					InvenAggroMeterFrame.threat1Max = 0
					if not list[2] then
						guid = UnitGUID(list[1])
						self:SetBar(1, list[1], threatPercent[guid], threat[guid], self:GetTPS(guid), guid)
						self:HideBars(2)
						if InvenAggroMeterFrame.player == list[1] then
							self:SetItsYou(1)
						else
							self:SetItsYou()
						end
					else
						if InvenAggroMeterFrame.player and InvenAggroMeterDB.warn and threatPercent[self.playerguid] and InvenAggroMeterDB.warnPercent <= threatPercent[self.playerguid] and not self:IsTanker() then
							if threatPercent[self.playerguid] > prevThreat then
								self:Warn()
							end
						end
						prevThreat = threatPercent[self.playerguid] or 0
						endl = #list
						for i = 1, endl do
							start = i + 1
							for j = start, endl do
								if (threatPercent[UnitGUID(list[i])] or 0) < (threatPercent[UnitGUID(list[j])] or 0) then
									temp = list[i]
									list[i] = list[j]
									list[j] = temp
								end
							end
						end
						n = min(#list, InvenAggroMeterDB.list)
						self:SetItsYou()
						for i = 1, n do
							guid = UnitGUID(list[i])
							self:SetBar(i, list[i], threatPercent[guid], threat[guid], self:GetTPS(guid), guid)
							if InvenAggroMeterFrame.player == list[i] then
								self:SetItsYou(i)
							end
						end
						self:HideBars(n + 1)
					end
					if InvenAggroMeterFrame.threat1Prev ~= InvenAggroMeterFrame.threat1Max then
						self:AutoSizingThreatText()
					end
				else
					self:UpdateTPS()
				end
			else
				self:HideBars()
				if InvenAggroMeterDB.autoHide then
					InvenAggroMeterFrame:Hide()
				end
			end
		else
			self:AddThreat()
			InvenAggroMeterFrame:Hide()
		end
	end
	clearTable(list)
end

function InvenAggroMeter:Warn(force)
	if self.nextWarnTime <= GetTime() or force then
		if not force and InvenAggroMeterDB.warnInstance and not IsInInstance() then return end
		self.nextWarnTime = force and 0 or (GetTime() + 10)
		if InvenAggroMeterDB.shake then
			self:Shake()
		end
		if InvenAggroMeterDB.flash then
			self:Flash()
		end
		if InvenAggroMeterDB.text then
			self:Text()
		end
		if InvenAggroMeterDB.sound ~= "None" then
			PlaySoundFile(SM:Fetch("sound", InvenAggroMeterDB.sound))
		end
	end
end

function InvenAggroMeter:Shake()
	if WorldFrame:IsProtected() and InCombatLockdown() then return end
	if not self.shakeFrame then
		self.shakeFrame = CreateFrame("Frame", nil, UIParent)
		self.shakeFrame:Hide()
		self.shakeFrame.points = {}
		for i = 1, WorldFrame:GetNumPoints() do
			tinsert(self.shakeFrame.points, { WorldFrame:GetPoint(i) })
		end
		self.shakeFrame:SetScript("OnHide", function(self)
			if not(WorldFrame:IsProtected() and InCombatLockdown()) then
				WorldFrame:ClearAllPoints()
				for i = 1, #self.points do
					WorldFrame:SetPoint(unpack(self.points[i]))
				end
			end
		end)
		self.shakeFrame:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			if self.elapsed > 0.8 or (WorldFrame:IsProtected() and InCombatLockdown()) then
				self:Hide()
			else
				self.x = random(-5, 5)
				self.y = random(-5, 5)
				WorldFrame:ClearAllPoints()
				for i = 1, #self.points do
					local v = self.points[i]
					WorldFrame:SetPoint(v[1], v[2], v[3], v[4] + self.x, v[5] + self.y)
				end
			end
		end)
	end
	self.shakeFrame.elapsed = 0
	self.shakeFrame:Show()
end

function InvenAggroMeter:Flash()
	if not self.flashFrame then
		self.flashFrame = CreateFrame("Button")
		self.flashFrame:EnableMouse(nil)
		self.flashFrame:SetToplevel(true)
		self.flashFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		self.flashFrame:SetAllPoints(UIParent)
		self.flashFrame:SetNormalTexture("Interface\\FullScreenTextures\\OutOfControl")
		self.flashFrame:GetNormalTexture():SetBlendMode("ADD")
		self.flashFrame:Hide()
		self.flashFrame:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			if self.elapsed > 2.6 then
				self:Hide()
			else
				self.alpha = self.elapsed % 1.3
				if self.alpha < 0.15 then
					self:SetAlpha(self.alpha / 0.15)
				elseif self.alpha < 0.9 then
					self:SetAlpha(1 - (self.alpha - 0.15) / 0.6)
				else
					self:SetAlpha(0)
				end
			end
		end)
	end
	self.flashFrame.elapsed = 0
	self.flashFrame:SetAlpha(0)
	self.flashFrame:Show()
end

function InvenAggroMeter:Text()
	if not self.textFrame then
		self.textFrame = CreateFrame("Frame", nil, UIParent)
		self.textFrame.posY = 200
		self.textFrame:EnableMouse(nil)
		self.textFrame:SetClampedToScreen(true)
		self.textFrame:SetToplevel(true)
		self.textFrame:SetFrameStrata("HIGH")
		self.textFrame:SetPoint("TOP", UIParent, "TOP", 0, -self.textFrame.posY)
		self.textFrame:SetWidth(1)
		self.textFrame:SetHeight(1)
		self.textFrame:Hide()
		self.textFrame.text = self.textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		self.textFrame.text:SetText("위협 수준 경고")
		self.textFrame.text:SetPoint("CENTER", self.textFrame, "CENTER")
		self.textFrame:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			if self.elapsed > 2 then
				self:Hide()
			else
				if self.elapsed > 1 then
					self.text:SetTextColor(1, 2 - self.elapsed, 0)
				else
					self.text:SetTextColor(1, self.elapsed, 0)
				end
				self:ClearAllPoints()
				self:SetPoint("TOP", UIParent, "TOP", random(-1, 1), -self.posY + random(-1, 1))
			end
		end)
	end
	self.textFrame.elapsed = 0
	self.textFrame:Show()
end

InvenAggroMeter:RegisterEvent("PLAYER_ENTERING_WORLD")
InvenAggroMeter:OnInit()
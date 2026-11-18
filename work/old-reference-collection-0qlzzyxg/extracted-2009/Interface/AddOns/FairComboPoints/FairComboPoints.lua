------------------------------
--      Are you local?      --
------------------------------
local AceDBOptions = LibStub("AceDBOptions-3.0")
local class = select(2, UnitClass("player"))
--[[
if class == "ROGUE" or class == "DRUID" then
	class = nil
else
	DisableAddOn("FairComboPoints")
	ChatFrame1:AddMessage("FairComboPoints: ".. _G["ADDON_DISABLED"])
	return
end
--]]
local FCP = _G.CreateFrame("Frame", "FairComboPoints", UIParent)
local GetComboPoints = _G.GetComboPoints
local font = nil
local db
local player = "player"

FCP:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
FCP:RegisterEvent("PLAYER_LOGIN")
FCP:RegisterEvent("ADDON_LOADED")
local FCPcomboBG
local FCPcombo = {}
local FCPcombo2 = {}
local FCPtex2 = {}
local FCPtex = {}
local FCPshine = {}
local FCP_Spellname
local FCP_Spellname2
local FCP_Points
local FCP2_Spellname
local FCP2_Spellname2
local FCP2_Points
FCP:Hide()

local FCP2 = CreateFrame("Frame", nil , UIparent)
local FCP2tx,FCPtex2BG
FCP2tx = FCP2:CreateTexture(nil,"OVERLAY")
FCP2tx:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\cp7")
FCP2tx:SetTexCoord(0,1.0,0,1.0)
FCP2tx:SetAllPoints(FCP2)
FCP2:SetFrameStrata("BACKGROUND")
FCP2:SetClampedToScreen(true)
FCP2:SetPoint("CENTER",UIParent, "CENTER")
FCP2:SetWidth(80)
FCP2:SetHeight(80)
FCP2:Hide()

for i= 1,5 do
	FCPcombo[i] = CreateFrame("Frame", "Fcombo"..i, UIParent)
	FCPtex[i] = FCPcombo[i]:CreateTexture(nil,"OVERLAY")
	FCPtex[i]:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\cp"..i)
	FCPtex[i]:SetTexCoord(0,1.0,0,1.0)
	FCPtex[i]:SetAllPoints(FCPcombo[i])
	FCPcombo[i]:SetFrameStrata("BACKGROUND")
	FCPcombo[i]:SetClampedToScreen(true)
	FCPcombo[i]:SetPoint("CENTER", UIParent, "CENTER")
	FCPcombo[i]:SetWidth(50)
	FCPcombo[i]:SetHeight(50)
	FCPcombo[i]:Hide()
	FCPshine[i]=getglobal("FCP_FL"..i)
	FCPshine[i]:SetWidth(120)
	FCPshine[i]:SetHeight(120)
end
local	FCPslash = CreateFrame("Frame", "FCPshash", UIParent)
	FCPslashtex = FCPslash:CreateTexture(nil,"BACKGROUND")
	FCPslashtex:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\slash")
	FCPslashtex:SetTexCoord(0,1.0,0,1.0)
	--FCPslashtex:SetVertexColor(1,0,0)
	FCPslashtex:SetAllPoints(FCPslash)
	FCPslashtex:SetTexCoordModifiesRect(true) 
	FCPslash:SetFrameStrata("LOW")
	FCPslash:SetClampedToScreen(true)
	FCPslash:SetPoint("CENTER", UIParent, "CENTER")
	FCPslash:SetWidth(512)
	FCPslash:SetHeight(512)
	FCPslash.tex = FCPslashtex
	FCPslash:Hide()

local	FCPslash2 = CreateFrame("Frame", "FCPslash", UIParent)
	FCPslashtex2 = FCPslash2:CreateTexture(nil,"BACKGROUND")
	FCPslashtex2:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\slash")
	FCPslashtex2:SetTexCoord(1,0,0,1.0)
	--FCPslashtex2:SetVertexColor(1,0,0)
	FCPslashtex2:SetAllPoints(FCPslash2)
	FCPslashtex2:SetTexCoordModifiesRect(true) 
	FCPslash2:SetFrameStrata("LOW")
	FCPslash2:SetClampedToScreen(true)
	FCPslash2:SetPoint("CENTER", UIParent, "CENTER")
	FCPslash2:SetWidth(512)
	FCPslash2:SetHeight(512)
	FCPslash2.tex = FCPslashtex2
	FCPslash2:Hide()

	FCPcomboBG = CreateFrame("Frame", "Fcombobg", UIparent)
	FCPtexBG = FCPcomboBG:CreateTexture(nil,"BACKGROUND")
	FCPtexBG:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\bg")
	FCPtexBG:SetTexCoord(0,1.0,0,1.0)
	FCPtexBG:SetAllPoints(FCPcomboBG)
	FCPtex2BG = FCPcomboBG:CreateTexture(nil,"BACKGROUND")
	FCPcomboBG:SetFrameStrata("BACKGROUND")
	FCPcomboBG:SetClampedToScreen(true)
	FCPcomboBG:SetPoint("CENTER", UIParent, "CENTER")
	FCPcomboBG:SetWidth(180)
	FCPcomboBG:SetHeight(180)
	FCPcomboBG:Hide()

	FCPcombo2BG = CreateFrame("Frame","FCPcombo2BG", UIparent)
	FCPcombo2BG:SetClampedToScreen(true)
	FCPcombo2BG:SetPoint("CENTER",FCPcomboBG, "CENTER")
	FCPtex2BG = FCPcombo2BG:CreateTexture(nil,"BACKGROUND")
	FCPtex2BG:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\finish")
	FCPtex2BG:SetTexCoord(0,1.0,0,1.0)
	FCPtex2BG:SetAllPoints(FCPcombo2BG)
	FCPtex2BG:SetVertexColor(1,0.2,0,1)
	FCPcombo2BG:SetFrameStrata("BACKGROUND")
	FCPcombo2BG:SetWidth(200)
	FCPcombo2BG:SetHeight(200)
	FCPcombo2BG:Hide()

	FCPcombo2[1] = CreateFrame("Frame", "Fcombo2", UIparent)
	FCPtex2[1] = FCPcombo2[1]:CreateTexture(nil,"BACKGROUND")
	FCPtex2[1]:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\cp_1")
	FCPtex2[1]:SetTexCoord(0,1.0,0,1.0)
	FCPtex2[1]:SetAllPoints(FCPcombo2[1])
	FCPcombo2[1]:SetFrameStrata("LOW")
	FCPcombo2[1]:SetClampedToScreen(true)
	FCPcombo2[1]:SetPoint("CENTER", FCPcomboBG, "CENTER")
	FCPcombo2[1]:SetWidth(225)
	FCPcombo2[1]:SetHeight(225)
	FCPcombo2[1]:Hide()
-----------------------------
-- FCP_combo2 making      --
----------------------------
local function CreateFCP2Frame(number,loc,size)
local i = number
	FCPcombo2[i] = CreateFrame("Frame", "Fcombo2"..i,FCPcomboBG)
	FCPtex2[i] = FCPcombo2[i]:CreateTexture(nil,"LOW")
	FCPtex2[i]:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\cp_2")
	FCPtex2[i]:SetTexCoord(0,1.0,0,1.0)
	FCPtex2[i]:SetAllPoints(FCPcombo2[i])
	FCPcombo2[i]:SetFrameStrata("LOW")
	FCPcombo2[i]:SetClampedToScreen(true)
	FCPcombo2[i]:SetPoint("CENTER", FCPcomboBG, "CENTER", loc, 0)
	FCPcombo2[i]:SetWidth(size)
	FCPcombo2[i]:SetHeight(size)
	FCPcombo2[i]:Hide()
	return FCPcombo2[i]
end
function FCP:CreateMyBuffIcon(Buffname)
--local FCPmyBuff.Buffname =  CreateFrame("Frame", nil, UIParent)

end
------------------------------
--           Config         --
------------------------------

local fcpOptions
local function getOptions()
	local validate = {}
	if not fcpOptions then
		local L = _G.LibStub("AceLocale-3.0"):GetLocale("FairComboPoints", true)
		fcpOptions = {
			name = "FairComboPoints",
			childGroups = "tab", type = "group",
			args = {
				main = {
					name = _G["MISCELLANEOUS"],
					order = 1, type = "group",
					args = {
						intro = {
							name = L["desc"],
							order = 1, type = "description",
						},
						spacer = {
							name = "",
							order = 2, type = "header",
						},
						lock = {
							name = _G["LOCK"], desc = L["Lock the points frame in its current location."],
							order = 3, type = "toggle",
							get = function() return db.lock end,
							set = function(_, state) db.lock = state
								if not state then
									for i=1,5 do
									FCPcombo[i]:SetAlpha(1.0)
									FCPcombo[i]:Show()
									end
									FCP:Show()
									FCP2:Show()
									FCPcomboBG:Show()
									FCP:SetBackdropColor(1,1,1,1)
									state = true
								else
									for i=1,5 do
									FCPcombo[i]:Hide()
									end	
									FCP:Hide()
									FCP2:Hide()
									FCPcomboBG:Hide()
									FCPshine[1]:SetPoint("CENTER", UIParent, "CENTER", db.x1 , db.y1)
									FCPshine[2]:SetPoint("CENTER", UIParent, "CENTER", db.x2 , db.y2)
									FCPshine[3]:SetPoint("CENTER", UIParent, "CENTER", db.x3 , db.y3)
									FCPshine[4]:SetPoint("CENTER", UIParent, "CENTER", db.x4 , db.y4)
									FCPshine[5]:SetPoint("CENTER", UIParent, "CENTER", db.x5 , db.y5)
									FCP:SetBackdropColor(1,1,1,0)
									state = nil
								end
								FCP:EnableMouse(state)
								FCP:SetMovable(state)
								FCP2:EnableMouse(state)
								FCP2:SetMovable(state)
								FCPcomboBG:EnableMouse(state)
								FCPcomboBG:SetMovable(state)
								for i=1,5 do
								FCPcombo[i]:EnableMouse(state)
								FCPcombo[i]:SetMovable(state)
								end
							end,
						},
						selfcast = {
							name = L['SELFCAST'], desc = L["Only See My Debuff"],
							order = 4, type = "toggle",
							get = function() return db.selfcast end,
							set = function(_, state) db.selfcast = state 
								if not state then 
									state = true
								else
									state = nil
								end
							end,
						},
					},
				},
				color = {
					name = _G["COLOR"],
					order = 2, type = "group",
					args = {
						desc = {
							name = L["Apply the color you wish to use for your Combo Points."],
							order = 1, type = "description",
						},
						spacer = {
							name = "",
							order = 2, type = "header",
						},
						colorone = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 1),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["COLOR"], 1),
							order = 3, type = "color", width = "full",
							get = function() return db.colorone.r, db.colorone.g, db.colorone.b end,
							set = function(_, r, g, b) db.colorone.r = r db.colorone.g = g db.colorone.b = b end,
						},
						colortwo = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 2),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["COLOR"], 2),
							order = 4, type = "color", width = "full",
							get = function() return db.colortwo.r, db.colortwo.g, db.colortwo.b end,
							set = function(_, r, g, b) db.colortwo.r = r db.colortwo.g = g db.colortwo.b = b end,
						},
						colorthree = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 3),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["COLOR"], 3),
							order = 5, type = "color", width = "full",
							get = function() return db.colorthree.r, db.colorthree.g, db.colorthree.b end,
							set = function(_, r, g, b) db.colorthree.r = r db.colorthree.g = g db.colorthree.b = b end,
						},
						colorfour = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 4),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["COLOR"], 4),
							order = 6, type = "color", width = "full",
							get = function() return db.colorfour.r, db.colorfour.g, db.colorfour.b end,
							set = function(_, r, g, b) db.colorfour.r = r db.colorfour.g = g db.colorfour.b = b end,
						},
						colorfive = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 5),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["COLOR"], 5),
							order = 7, type = "color", width = "full",
							get = function() return db.colorfive.r, db.colorfive.g, db.colorfive.b end,
							set = function(_, r, g, b) db.colorfive.r = r db.colorfive.g = g db.colorfive.b = b end,
						},
						colorsix = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 6),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["COLOR"], 6),
							order = 8, type = "color", width = "full",
							get = function() return db.colorsix.r, db.colorsix.g, db.colorsix.b end,
							set = function(_, r, g, b) db.colorsix.r = r db.colorsix.g = g db.colorsix.b = b end,
						},
						colorseven = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 7),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["COLOR"], 7),
							order = 9, type = "color", width = "full",
							get = function() return db.colorseven.r, db.colorseven.g, db.colorseven.b end,
							set = function(_, r, g, b) db.colorseven.r = r db.colorseven.g = g db.colorseven.b = b end,
						},
					},
				},
				size = {
					name = _G["FONT_SIZE"],
					order = 3, type = "group",
					args = {
						desc = {
							name = L["Apply the size you wish to use for your Combo Points."],
							order = 1, type = "description",
						},
						spacer = {
							name = "",
							order = 2, type = "header",
						},
						sizeone = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 1),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 1),
							order = 3, type = "range", width = "full",
							min = 20, max = 250, step = 1,
							get = function() 
								FCPcombo[1]:SetWidth(db.size.one)
								FCPcombo[1]:SetHeight(db.size.one)
								FCPshine[1]:SetWidth(db.size.one*2)
								FCPshine[1]:SetHeight(db.size.one*2)
							return db.size.one end,
							set = function(_, v) db.size.one = v end,
						},
						sizetwo = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 2),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 2),
							order = 4, type = "range", width = "full",
							min = 20, max = 250, step = 1,
							get = function() 
								FCPcombo[2]:SetWidth(db.size.two)
								FCPcombo[2]:SetHeight(db.size.two)
								FCPshine[2]:SetWidth(db.size.two*2)
								FCPshine[2]:SetHeight(db.size.two*2)
							return db.size.two end,
							set = function(_, v) db.size.two = v end,
						},
						sizethree = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 3),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 3),
							order = 5, type = "range", width = "full",
							min = 20, max = 250, step = 1,
							get = function() 
								FCPcombo[3]:SetWidth(db.size.three)
								FCPcombo[3]:SetHeight(db.size.three)
								FCPshine[3]:SetWidth(db.size.three*2)
								FCPshine[3]:SetHeight(db.size.three*2)
							return db.size.three end,
							set = function(_, v) db.size.three = v end,
						},
						sizefour = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 4),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 4),
							order = 6, type = "range", width = "full",
							min = 20, max = 250, step = 1,
							get = function() 
								FCPcombo[4]:SetWidth(db.size.four)
								FCPcombo[4]:SetHeight(db.size.four)
								FCPshine[4]:SetWidth(db.size.four*2)
								FCPshine[4]:SetHeight(db.size.four*2)
							return db.size.four end,
							set = function(_, v) db.size.four = v end,
						},
						sizefive = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 5),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 5),
							order = 7, type = "range", width = "full",
							min = 20, max = 250, step = 1,
							get = function()
								FCPcombo[5]:SetWidth(db.size.five)
								FCPcombo[5]:SetHeight(db.size.five)
								FCPshine[5]:SetWidth(db.size.five*2)
								FCPshine[5]:SetHeight(db.size.five*2)
							return db.size.five end,
							set = function(_, v) db.size.five = v end,
						},
						sizesix = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 6),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 6),
							order = 8, type = "range", width = "full",
							min = 20, max = 250, step = 1,
							get = function()
								FCP:SetWidth(db.size.six)
								FCP:SetHeight(db.size.six)
							return db.size.six end,
							set = function(_, v) db.size.six = v end,
						},
						sizeseven = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 7),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 7),
							order = 9, type = "range", width = "full",
							min = 20, max = 250, step = 1,
							get = function()
								FCP2:SetWidth(db.size.seven)
								FCP2:SetHeight(db.size.seven)
							return db.size.seven end,
							set = function(_, v) db.size.seven = v end,
						},
						sizeeight = {
							name = format(_G["COMBAT_TEXT_COMBO_POINTS"], 8),
							desc = format(L["Apply the %s you wish to use for Combo Point %d."], _G["FONT_SIZE"], 8),
							order = 10, type = "range", width = "full",
							min = 40, max = 300, step = 1,
							get = function()
								FCPcomboBG:SetWidth(db.size.eight)
								FCPcomboBG:SetHeight(db.size.eight)
								FCPcombo2[1]:SetWidth(db.size.eight)
								FCPcombo2[1]:SetHeight(db.size.eight)
								FCP2Frameset()
							return db.size.eight end,
							set = function(_, v) db.size.eight = v end,
						},
					},
				},

			Extras = {
				type = 'group',
				name = L['Extras'],
				desc = L['Other abilities'],
				order = 10,
				args = {
					Add = {
						type = 'input',
						name = L['Add a custom timer'],
						get = function() return "" end,
						set = function(_, value) db.Custom[value] = value db.Abilities[value] = true validate[value] = value 
						
						FCP_Spellname = nil
						FCP_Spellname2 = nil
						FCP_Points = nil
						FCP2_Spellname = nil
						FCP2_Spellname2 = nil
						FCP2_Points = nil
						end,
						usage = L['<Spell Name in games locale>']
						},
					Remove = {
						type = 'multiselect',
						name = L['Remove a custom timer'],
						get = function() return false end,
						set = function(_, key) db.Custom[key] = nil db.Abilities[key] = nil validate[key] = nil 
						FCP_Spellname = nil
						FCP_Spellname2 = nil
						FCP_Points = nil
						FCP2_Spellname = nil
						FCP2_Spellname2 = nil
						FCP2_Points = nil
						end,
						values = db.Custom,
						},
					},
				},
			},
		}
	end
	return fcpOptions
end

------------------------------
--      Initialization      --
------------------------------
function FCP:ADDON_LOADED(msg)
	if msg == "FairComboPoints" then
		self:UnregisterEvent("ADDON_LOADED")
		  -- Detect In-Fight / In-Meele-Combat
		local defaults = {
			profile = {
				y5 = -141.7144306293694,
				x5 = 118.8570252542145,
				y7 = -84.11416027116231,
				y3 = -142.8573485819373,
				x3 = 5.714175903354771,
				y1 = -145.1427346398069,
				x1 = -105.1425856279,
				lock = true,
				point6 = "CENTER",
				y = -195.4283894814182,
				x = 60.57135860411268,
				relativePoint6 = "CENTER",
				y4 = -123.4283731744548,
				x6 = -25.60000944679259,
				y6 = -128.0000719755626,
				x4 = 59.4286385843418,
				x2 = -52.57105889337151,
				y2 = -125.7142630612627,
				x7 = 2.92576360343405,
				point7 = "CENTER",
				relativePoint7 = "CENTER",
				selfcast = true,
				Abilities = {},
				Custom = {},
				shadow = true,
				outline = "NONE",
				font = "Friz Quadrata TT",
				size = { one = 55, two = 55, three = 55, four = 55, five = 80,six = 80,seven = 80,eight =180},
				colorone = { r = 1, g = 1, b = 1 },
				colortwo = { r = 1, g = 0.9, b = 0.5 },
				colorthree = { r = 1, g = 0.8, b = 0.2 },
				colorfour = { r = 1, g = 0.6, b = 0.3 },
				colorfive = { r = 1, g = 0.45, b = 0.15 },
				colorsix = { r = 1, g = 0, b = 0 },
				colorseven = {r=1,g=0,b=0},
			}
		}

		_G.LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("FairComboPoints", getOptions)
		_G.LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FairComboPoints", "FairComboPoints")

		self.db = _G.LibStub("AceDB-3.0"):New("FairComboPointsDB", defaults)
		db = self.db.profile
		getOptions().args.profile = AceDBOptions:GetOptionsTable(self.db)

		_G.SlashCmdList["FAIRCOMBOPOINTS_MAIN"] = function()
			InterfaceOptionsFrame_OpenToCategory("FairComboPoints")
		end
		_G.SLASH_FAIRCOMBOPOINTS_MAIN1 = "/fcp"
		_G.SLASH_FAIRCOMBOPOINTS_MAIN2 = "/faircombopoints"
		self.ADDON_LOADED = nil
	end
end

------------------------------
--       Frame Setup        --
------------------------------

function FCP:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")

	FCPtx = FCP:CreateTexture(nil,"OVERLAY")
	FCPtx:SetTexture("Interface\\AddOns\\FairComboPoints\\Texture\\cp6")
	FCPtx:SetTexCoord(0,1.0,0,1.0)
	FCPtx:SetAllPoints(FCP)

	self:SetFrameStrata("BACKGROUND")
	self:SetClampedToScreen(true)
	self:SetPoint("CENTER", UIParent, "CENTER")
	self:SetBackdropColor(1,1,1,0)
	self:SetWidth(50)
	self:SetHeight(50)
	self:Hide()
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function() this:StartMoving() end)
	self:SetScript("OnDragStop", function() this:StopMovingOrSizing()
	end)
	self:SetScript("OnEvent", function(self, event, ...) self:Update(...) end)
	FCP2:SetPoint("CENTER", UIParent, "CENTER")

---------------------------start------
	local theWorldframe = getglobal("UIParent");
	local screenW = (theWorldframe:GetRight() - theWorldframe:GetLeft()) / 2;
	local screenH = (theWorldframe:GetTop() - theWorldframe:GetBottom()) / 2;


	FCP:SetWidth(db.size.five)
	FCP:SetHeight(db.size.five)
	FCP:RegisterForDrag("LeftButton")
	FCP:SetScript("OnDragStart", function() this:StartMoving() end)
	FCP:SetScript("OnDragStop", function() this:StopMovingOrSizing()
		db.x = FCP:GetLeft() + (FCP:GetRight() - FCP:GetLeft()) / 2 - screenW ;
		db.y = FCP:GetBottom() + (FCP:GetTop() - FCP:GetBottom()) / 2 - screenH;
	end)
	if not db.lock then
		FCP:Show()
		FCP:EnableMouse(true)
		FCP:SetMovable(true)
	end

	if db.x then
		FCP:ClearAllPoints()
		FCP:SetPoint("CENTER", UIParent, "CENTER", db.x , db.y)
	end

	FCP2:SetWidth(db.size.seven)
	FCP2:SetHeight(db.size.seven)
	FCP2:RegisterForDrag("LeftButton")
	FCP2:SetScript("OnDragStart", function() this:StartMoving() end)
	--[[FCP2:SetScript("OnDragStop", function() this:StopMovingOrSizing() 
		db.x6 = FCP2:GetLeft() + (FCP2:GetRight() - FCP2:GetLeft()) / 2 - screenW ;
		db.y6 = FCP2:GetBottom() + (FCP2:GetTop() - FCP2:GetBottom()) / 2 - screenH;
		SendChatMessage(db.x6..","..db.y6)
	end)--]]
	FCP2:SetScript("OnDragStop", function() this:StopMovingOrSizing() 
	local relativeTo
	db.point6, db.relativeTo, db.relativePoint6,db.x6, db.y6 =FCP2:GetPoint()
	end)

	if not db.lock then
		FCP2:Show()
		FCP2:EnableMouse(true)
		FCP2:SetMovable(true)
	end

	if db.x6 then
		FCP2:ClearAllPoints()
		if db.point6 then
		FCP2:SetPoint(db.point6, UIParent, db.relativePoint6, db.x6 , db.y6)
		else
		FCP2:SetPoint("CENTER",UIParent,"CENTER",db.x6,db.y6)
		end
	end



	FCPcombo[1]:SetWidth(db.size.one)
	FCPcombo[1]:SetHeight(db.size.one)
	FCPcombo[1]:RegisterForDrag("LeftButton")
	FCPcombo[1]:SetScript("OnDragStart", function() this:StartMoving() end)
	FCPcombo[1]:SetScript("OnDragStop", function() this:StopMovingOrSizing()
		db.x1 = FCPcombo[1]:GetLeft() + (FCPcombo[1]:GetRight() - FCPcombo[1]:GetLeft()) / 2 - screenW ;
		db.y1 = FCPcombo[1]:GetBottom() + (FCPcombo[1]:GetTop() - FCPcombo[1]:GetBottom()) / 2 - screenH;
	end)
	if not db.lock then
		FCPcombo[1]:Show()
		FCPcombo[1]:EnableMouse(true)
		FCPcombo[1]:SetMovable(true)
	end

	if db.x1 then
		FCPcombo[1]:ClearAllPoints()
		FCPcombo[1]:SetPoint("CENTER", UIParent, "CENTER", db.x1 , db.y1)
	end

	FCPcombo[2]:SetWidth(db.size.two)
	FCPcombo[2]:SetHeight(db.size.two)
	FCPcombo[2]:RegisterForDrag("LeftButton")
	FCPcombo[2]:SetScript("OnDragStart", function() this:StartMoving() end)
	FCPcombo[2]:SetScript("OnDragStop", function() this:StopMovingOrSizing()
		db.x2 = FCPcombo[2]:GetLeft() + (FCPcombo[2]:GetRight() - FCPcombo[2]:GetLeft()) / 2 - screenW ;
		db.y2 = FCPcombo[2]:GetBottom() + (FCPcombo[2]:GetTop() - FCPcombo[2]:GetBottom()) / 2 - screenH;
	end)
	if not db.lock then
		FCPcombo[2]:Show()
		FCPcombo[2]:EnableMouse(true)
		FCPcombo[2]:SetMovable(true)
	end

	if db.x2 then
		FCPcombo[2]:ClearAllPoints()
		FCPcombo[2]:SetPoint("CENTER", UIParent, "CENTER", db.x2, db.y2)
	end

	FCPcombo[3]:SetWidth(db.size.three)
	FCPcombo[3]:SetHeight(db.size.three)
	FCPcombo[3]:RegisterForDrag("LeftButton")
	FCPcombo[3]:SetScript("OnDragStart", function() this:StartMoving() end)
	FCPcombo[3]:SetScript("OnDragStop", function() this:StopMovingOrSizing()
		db.x3 = FCPcombo[3]:GetLeft() + (FCPcombo[3]:GetRight() - FCPcombo[3]:GetLeft()) / 2 - screenW ;
		db.y3 = FCPcombo[3]:GetBottom() + (FCPcombo[3]:GetTop() - FCPcombo[3]:GetBottom()) / 2 - screenH;
	end)
	if not db.lock then
		FCPcombo[3]:Show()
		FCPcombo[3]:EnableMouse(true)
		FCPcombo[3]:SetMovable(true)
	end

	if db.x3 then
		FCPcombo[3]:ClearAllPoints()
		FCPcombo[3]:SetPoint("CENTER", UIParent, "CENTER", db.x3, db.y3)
	end

	FCPcombo[4]:SetWidth(db.size.four)
	FCPcombo[4]:SetHeight(db.size.four)
	FCPcombo[4]:RegisterForDrag("LeftButton")
	FCPcombo[4]:SetScript("OnDragStart", function() this:StartMoving() end)
	FCPcombo[4]:SetScript("OnDragStop", function() this:StopMovingOrSizing()
		db.x4 = FCPcombo[4]:GetLeft() + (FCPcombo[4]:GetRight() - FCPcombo[4]:GetLeft()) / 2 - screenW ;
		db.y4 = FCPcombo[4]:GetBottom() + (FCPcombo[4]:GetTop() - FCPcombo[4]:GetBottom()) / 2 - screenH;
	end)
	if not db.lock then
		FCPcombo[4]:Show()
		FCPcombo[4]:EnableMouse(true)
		FCPcombo[4]:SetMovable(true)
	end

	if db.x4 then
		FCPcombo[4]:ClearAllPoints()
		FCPcombo[4]:SetPoint("CENTER", UIParent, "CENTER", db.x4, db.y4)
	end

	FCPcombo[5]:SetWidth(db.size.five)
	FCPcombo[5]:SetHeight(db.size.five)
	FCPcombo[5]:RegisterForDrag("LeftButton")
	FCPcombo[5]:SetScript("OnDragStart", function() this:StartMoving() end)
	FCPcombo[5]:SetScript("OnDragStop", function() this:StopMovingOrSizing()
		db.x5 = FCPcombo[5]:GetLeft() + (FCPcombo[5]:GetRight() - FCPcombo[5]:GetLeft()) / 2 - screenW ;
		db.y5 = FCPcombo[5]:GetBottom() + (FCPcombo[5]:GetTop() - FCPcombo[5]:GetBottom()) / 2 - screenH;
	end)
	if not db.lock then
		FCPcombo[5]:Show()
		FCPcombo[5]:EnableMouse(true)
		FCPcombo[5]:SetMovable(true)
	end

	if db.x5 then
		FCPcombo[5]:ClearAllPoints()
		FCPcombo[5]:SetPoint("CENTER", UIParent, "CENTER", db.x5, db.y5)
	end


	FCPcomboBG:SetWidth(db.size.eight)
	FCPcomboBG:SetHeight(db.size.eight)
	FCPcombo2[1]:SetWidth(db.size.eight)
	FCPcombo2[1]:SetHeight(db.size.eight)
	FCPcomboBG:RegisterForDrag("LeftButton")
	FCPcomboBG:SetScript("OnDragStart", function() this:StartMoving() end)
	FCPcomboBG:SetScript("OnDragStop", function() this:StopMovingOrSizing() 
	local relativeTo
	db.point7, relativeTo, db.relativePoint7,db.x7, db.y7 =FCPcomboBG:GetPoint()
	end)
	if not db.lock then
		FCPcomboBG:Show()
		FCPcomboBG:EnableMouse(true)
		FCPcomboBG:SetMovable(true)
	end

	if db.x7 then
		FCPcomboBG:ClearAllPoints()
		if db.point7 then
		FCPcomboBG:SetPoint(db.point7, UIParent, db.relativePoint7, db.x7 , db.y7)
		else
		FCPcomboBG:SetPoint("CENTER",UIParent,"CENTER",db.x7,db.y7)
		FCPcombo2BG:SetPoint("CENTER",UIParent,"CENTER",db.x7,db.y7)
		end
	end

	FCP2Frameset()

	FCPshine[1]:SetPoint("CENTER", UIParent, "CENTER", db.x1 , db.y1)
	FCPshine[2]:SetPoint("CENTER", UIParent, "CENTER", db.x2 , db.y2)
	FCPshine[3]:SetPoint("CENTER", UIParent, "CENTER", db.x3 , db.y3)
	FCPshine[4]:SetPoint("CENTER", UIParent, "CENTER", db.x4 , db.y4)
	FCPshine[5]:SetPoint("CENTER", UIParent, "CENTER", db.x5 , db.y5)
------end
	self:RegisterEvent("UNIT_COMBO_POINTS")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.PLAYER_LOGIN = nil
end
----------------------------
--Fair--
----------------------------
function FCP2Frameset()
	FCPcombo2[2] = CreateFCP2Frame(2,-db.size.eight/13,db.size.eight*4/5)
	FCPcombo2[3] = CreateFCP2Frame(3,db.size.eight/13,db.size.eight*4/5)
	FCPcombo2[4] = CreateFCP2Frame(4,-db.size.eight/7,db.size.eight*3/5)
	FCPcombo2[5] = CreateFCP2Frame(5,db.size.eight/7,db.size.eight*3/5)
end

function UpdateColor(r,g,b)
		for i=1,5 do
		FCPtex[i]:SetVertexColor(r,g,b)
		end
end
------------------------------
--       Point Update       --
------------------------------

---유닛의 버프를 체크하여 값과 콤보수를 돌려줌. 쌓일수없는거면 count 0 반환

function checkAuraName(Unit,Auraname)
local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable
if Unit == "player" then
	for i=1,40 do
	name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff("player", i)
		if Auraname == name then
		return name,count
		end
	end
elseif Unit == "target" then
	if UnitIsFriend("target", "player") then
		for i=1,40 do
		name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff("target", i)
			if Auraname == name then
				if not db.selfcast then
				return name,count
				elseif isMine then
				return name,count
				end
			end
		end
	else
		for i=1,40 do
		name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", i)
			if Auraname == name then
				if not db.selfcast then
				return name,count
				elseif isMine then
				return name,count
				end
			end
		end
	end
end
end
--------------------실질적인 콤보와 이벤트 처리 부분--


function FCP:Update(...)
	--only return if there is a unit and it's not player
	--since PTC doesn't pass a unit
	local points,points2,name,count,name1,count1,name2,count2,name2nd,name2nd1,name2nd2,count2nd,count2nd1,count2nd2
	local temp,temp2
	local c_max,name_2


	if event == "UNIT_COMBO_POINTS" or event == "PLAYER_TARGET_CHANGED" then
	--points = GetComboPoints(player)
	points = GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player", "target")
		if UnitHasVehicleUI("player") then
		points2 = GetComboPoints("vehicle" , "vehicle")
		end
	end
	if arg7 then
	temp,temp2 = strsplit("-",arg7) 
		if temp then
		arg7 = temp
		end
	end
if (arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_APPLIED_DOSE" or arg2 == "SPELL_AURA_REFRESH" or arg2=="SPELL_AURA_REMOVED" or arg2=="SPELL_AURA_REMOVED_DOSE" or arg2 == "SPELL_AURA_BROKEN")and(arg7 == UnitName("player")or arg7 == UnitName("target")) or event == "PLAYER_TARGET_CHANGED" then

		for v in pairs(db.Custom) do
			 c_max,name_2  = strsplit("@", db.Custom[v])
			if c_max and arg10 and name_2==arg10 then temp = arg10 end
		end
	
		if event == "PLAYER_TARGET_CHANGED" then
				local startTime = GetTime()
				FCP:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide(self,startTime,6) end)
				FCP2:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide(self,startTime,7) end)
				points2 = 0
				if FCP_Spellname then 
				name1,count1 = checkAuraName("player",FCP_Spellname)
					if not count1 then
					name1,count1 = checkAuraName("target",FCP_Spellname)
					end
				end
				if FCP_Spellname2 then
				name2,count2 = checkAuraName("player",FCP_Spellname2)
					if not count2 then
					name2,count2 = checkAuraName("target",FCP_Spellname2)
					end
				end
				if FCP2_Spellname then 
				name2nd1,count2nd1 = checkAuraName("player",FCP2_Spellname)
					if not count2nd1 then
					name2nd1,count2nd1 = checkAuraName("target",FCP2_Spellname)
					end
				end
				if FCP2_Spellname2 then
				name2nd2,count2nd2 = checkAuraName("player",FCP2_Spellname2)
					if not count2nd2 then
					name2nd2,count2nd2 = checkAuraName("target",FCP2_Spellname2)
					end
				end

			end
--arg4, db.selfcast
		if arg10 and temp and arg10 == temp then
			if arg7 ==  UnitName("player") then
			name2nd,count2nd = checkAuraName("player",arg10)
			elseif arg7 ==  UnitName("target") then
			name2nd,count2nd = checkAuraName("target",arg10)
			end
			if arg2=="SPELL_AURA_REMOVED" or arg2 == "SPELL_AURA_BROKEN" then
			if arg10 == FCP2_Spellname then
				local startTime = GetTime()
				FCP2:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide(self,startTime,7) end)
			elseif arg10 ==FCP2_Spellname2 then
				count2nd = nil
				points2 = 0
				FCP_Points2 = 0
				end
			end
		else

		if arg7 ==  UnitName("player") then
			name,count = checkAuraName("player",arg10)
		elseif arg7 ==  UnitName("target") then
			name,count = checkAuraName("target",arg10)
		end
--[[
  현재 이벤트 정상작동 안함 (와우 자체 버그)
		if arg2=="SPELL_AURA_REMOVED_DOSE" then
			if arg7 ==  UnitName("player") then
				name,count = checkAuraName("player",arg10)
				SendChatMessage(arg10)
			elseif arg7 ==  UnitName("target") then
				name,count = checkAuraName("target",arg10)
			end
		end
--]]
		if arg2=="SPELL_AURA_REMOVED" or arg2 == "SPELL_AURA_BROKEN" then
			if arg10 == FCP_Spellname then
				local startTime = GetTime()
				FCP:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide(self,startTime,6) end)
			elseif arg10 ==FCP_Spellname2 then
				count = nil
				points = 0
				FCP_Points = 0
			end

		end

	end
end
	--get current points
	if db.Custom and name or name1 or name2 then
		for v in pairs(db.Custom) do
			if(name == db.Custom[v])or(name1==db.Custom[v])or(name2==db.Custom[v]) then
							if  count1 or count ==0 then
								if count==0 then
								FCP_Spellname = name
								elseif count1 then
								FCP_Spellname = name1
								end
								local color = db.colorsix
								FCPtx:SetVertexColor(color.r,color.g,color.b)
								FCP:SetScript("OnUpdate", function() end)
								Fair_normalsize()
								FCP:Show()
								FCP:SetAlpha(1)
								--	UIFrameFlash(FCPshine[5],0.0, 0.7, 0.7, false,0, 0)
								local startTime = GetTime()
								FCP:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation5(self,startTime,db.size.six) end)
							end
							if count ~=0 and count or count2 then
									if count2 then
										points = count2
										FCP_Points = count2
										FCP_Spellname2 = name2
									elseif count then 
										points = count
										FCP_Points = count
										FCP_Spellname2 = name
									end
							end
			end
		end
	elseif arg7 ==  UnitName("player") or arg7 ==  UnitName("target") then
	if FCP_Spellname2 then
				temp,temp2 = checkAuraName("player",FCP_Spellname2)
				if not temp2 then
				temp,temp2 = checkAuraName("target",FCP_Spellname2)
				end
			if FCP_Points and temp2 and FCP_Points~=temp2 then
			name2 = temp
			points = temp2
			FCP_Points = temp2
			end

	end
end


	for i=1,5 do
		local j
		if FCPcombo[i].shown == true then
		j = i
			if points and points<j then
			local startTime = GetTime()
			FCPcombo[i]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide(self,startTime,i) end)
			end
		end
	end

if points and points>5 then
points = 5
end
------------------------2번째 콤보 표시 위한부분 시작
	if db.Custom and name2nd or name2nd1 or name2nd2 then
		for v in pairs(db.Custom) do
			 c_max,name_2  = strsplit("@", db.Custom[v])
			if(name2nd == name_2)or(name2nd1==name_2)or(name2nd2==name_2) then
							if  count2nd1 or count2nd ==0 then
								if count2nd==0 then
								FCP2_Spellname = name2nd
								elseif count2nd1 then
								FCP2_Spellname = name2nd1
								end
								local color = db.colorseven
								FCP2tx:SetVertexColor(color.r,color.g,color.b)
								FCP2:SetScript("OnUpdate", function() end)
								Fair_normalsize()
								FCP2:Show()
								FCP2:SetAlpha(1)
								local startTime = GetTime()
								FCP2:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation5(self,startTime,db.size.seven) end)
							end
							if count2nd ~=0 and count2nd or count2nd2 then
									if count2nd2 then
										points2 = count2nd2
										FCP2_Points = count2nd2
										FCP2_Spellname2 = name2nd2
									elseif count2nd then 
										points2 = count2nd
										FCP2_Points = count2nd
										FCP2_Spellname2 = name2nd
									end
							end
			end
		end
	elseif arg7 ==  UnitName("player") or arg7 ==  UnitName("target") then
	if FCP2_Spellname2 then
				temp,temp2 = checkAuraName("player",FCP2_Spellname2)
				if not temp2 then
				temp,temp2 = checkAuraName("target",FCP2_Spellname2)
				end
			if FCP2_Points and temp2 and FCP2_Points~=temp2 then
			name2nd2 = temp
			points2 = temp2
			FCP2_Points = temp2
			end

	end
end

	for i=1,5 do
		local j
		if FCPcombo2[i] and FCPcombo2[i].shown then
		j = i
			if points2 and points2<j then
			local startTime = GetTime()
			FCPcombo2[i]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide2(self,startTime,i) end)
			end
		end
	end
if points2 and points2>5 then
points2 = 5
end
--------------------------------------------끝------
	temp = arg2
	if points == 0 then
			local startTime = GetTime()
			for i=1,5 do
			FCPcombo[i]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide(self,startTime,i) end)
			end
	elseif points == 1 then
		local color = db.colorone
		FCPtex[1]:SetVertexColor(color.r,color.g,color.b)
		FCPcombo[1]:Show()
		UIFrameFlash(FCPshine[1],0.0, 0.7, 0.7, false,0, 0)
		local startTime = GetTime()
		FCPcombo[1]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation(self,startTime,db.size.one) end)
	elseif points == 2 then
		local color = db.colortwo
		FCPtex[2]:SetVertexColor(color.r,color.g,color.b)
		for i=1,2 do
		FCPcombo[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo[i]:Show()
		FCPcombo[i]:SetAlpha(1)
		UIFrameFlash(FCPshine[i],0.0, 0.7, 0.7, false,0, 0)
		end
		local startTime = GetTime()
		FCPcombo[2]:SetScript("OnUpdate",  function(self, elapsed) Fair_StartAni(self,startTime,db.size.two,temp) end)
	elseif points == 3 then
		local color = db.colorthree
		FCPtex[3]:SetVertexColor(color.r,color.g,color.b)
		for i=1,3 do
		FCPcombo[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo[i]:Show()
		FCPcombo[i]:SetAlpha(1)
		UIFrameFlash(FCPshine[i],0.0, 0.7, 0.7, false,0, 0)
		end
		local startTime = GetTime()
		FCPcombo[3]:SetScript("OnUpdate",  function(self, elapsed) Fair_StartAni(self,startTime,db.size.three,temp) end)
	elseif points == 4 then
		local color = db.colorfour
		FCPtex[4]:SetVertexColor(color.r,color.g,color.b)
		for i=1,4 do
		FCPcombo[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo[i]:Show()
		FCPcombo[i]:SetAlpha(1)
		UIFrameFlash(FCPshine[i],0.0, 0.7, 0.7, false,0, 0)
		end
		local startTime = GetTime()
		FCPcombo[4]:SetScript("OnUpdate",  function(self, elapsed) Fair_StartAni(self,startTime,db.size.four,temp) end)
	elseif points == 5 then
		local color = db.colorfive
		FCPtex[5]:SetVertexColor(color.r,color.g,color.b)
		for i=1,5 do
		FCPcombo[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo[i]:Show()
		FCPcombo[i]:SetAlpha(1)
		UIFrameFlash(FCPshine[i],0.0, 0.7, 0.7, false,0, 0)
		end
		local startTime = GetTime()
		FCPcombo[5]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation5(self,startTime,db.size.five) end)
	end
-------------------2번째 콤보부분 애니메이션 시작-------------------------
	if points2 == 0 then
	if FCPcomboBG:IsShown() then
			UIFrameFlash(FCPcomboBG,0.0, 1.0, 1.0, false,0, 0)
	end
			local startTime = GetTime()
			for i=1,5 do
			FCPcombo2[i]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation_Hide2(self,startTime,i) end)
			end
	elseif temp == "SPELL_AURA_REFRESH" and points2 then
		FCPcombo2BG:SetHeight(db.size.eight)
		FCPcombo2BG:SetWidth(db.size.eight)
		UIFrameFlash(FCPcombo2BG,0.0, 1.0, 1.0, false,0, 0)
		for i = 1,points2 do
		FCPcombo2[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		local startTime = GetTime()
		FCPcombo2[i]:SetScript("OnUpdate",  function(self, elapsed)  Fair_Animation2(self,startTime,i) end)
		end
	elseif points2 == 1 then
		--local color = db.colorone
		--FCPtex[1]:SetVertexColor(color.r,color.g,color.b)
		FCPcombo2[1]:Show()
		FCPcomboBG:Show()
		local startTime = GetTime()
		FCPcombo2[1]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation2(self,startTime,points2) end)
	elseif points2 == 2 then
		FCPcomboBG:Show()
		for i=1,points2 do
		FCPcombo2[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo2[i]:Show()
		FCPcombo2[i]:SetAlpha(1)

		end
		local startTime = GetTime()
		FCPcombo2[2]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation2(self,startTime,points2) end)
	elseif points2 == 3 then
		FCPcomboBG:Show()
		for i=1,3 do
		FCPcombo2[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo2[i]:Show()
		FCPcombo2[i]:SetAlpha(1)
		end
		local startTime = GetTime()
		FCPcombo2[3]:SetScript("OnUpdate",  function(self, elapsed) Fair_Animation2(self,startTime,points2) end)
	elseif points2 == 4 then
		FCPcomboBG:Show()
		for i=1,4 do
		FCPcombo2[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo2[i]:Show()
		FCPcombo2[i]:SetAlpha(1)
		end
		local startTime = GetTime()
		FCPcombo2[4]:SetScript("OnUpdate",  function(self, elapsed)  Fair_Animation2(self,startTime,points2) end)
	elseif points2 == 5 then
		FCPcomboBG:Show()
		local startTime = GetTime()
		for i=1,5 do
		FCPcombo2[i]:SetScript("OnUpdate", function() end)
		Fair_normalsize()
		FCPcombo2[i]:Show()
		FCPcombo2[i]:SetAlpha(1)
		FCPcombo2[i]:SetScript("OnUpdate",  function(self, elapsed)  Fair_Animation2(self,startTime,i) end)
		end
	end
	--display points
    if (arg2=="SPELL_DAMAGE" and arg4==UnitName("player") and arg7 == UnitName("target") ) then
      -- Use the following line in game version 3.0 or higher, for previous versions use the line after
      local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)
		if (arg10=="질풍의 공격" and amount > 1) then 
		local starttime = GetTime()
		local num = FCPslash.count
		if not FCPslash.count then
		FCPslash:Show()
		FCPslash:SetScript("OnUpdate", function(self,elapsed) Fair_SlashAni(self,starttime,critical,num) end)
		FCPslash.count = true
--		UIFrameFlash(FCPslash,0.0, 0.7, 0.7, false,0, 0)
		else
		FCPslash2:Show()
		FCPslash2:SetScript("OnUpdate", function(self,elapsed) Fair_SlashAni(self,starttime,critical,num) end)
		FCPslash.count = nil
--		UIFrameFlash(FCPslash2,0.0, 0.7, 0.7, false,0, 0)
		end
		end
	end
end

function Fair_SlashAni(self,starttime,critical,num)
 	local elapsed = GetTime() - starttime
	local fadeInTime =0.3
	local x
	if num then x = 1 else x = 1.5 end
	if ( elapsed < fadeInTime*x ) then
		local alpha = (elapsed / fadeInTime)
		self:SetAlpha(x+0.3-alpha)
--		self.tex:SetVertexColor(1.0,alpha,alpha)
		if num then
		self.tex:SetTexCoord(0,alpha,0,1)
		self.tex:SetVertexColor(1.0,alpha-0.3,alpha-0.3)
		else
		self.tex:SetTexCoord(1,1.7-alpha,0,1)
		self.tex:SetVertexColor(1.0,alpha-1.7,alpha-1.7)
		end
		if critical then
		self.tex:SetVertexColor(1.0,1-alpha,1-alpha)
		end
		return
	else
		self:SetAlpha(1.0)
		--UIFrameFlash(self,0.0, 0.2, 0.2, false,0, 0)
		self:Hide()
		self:SetScript("OnUpdate", function() end)
	end
end


function Fair_normalsize()
		FCPcombo[1]:SetWidth(db.size.one)
		FCPcombo[1]:SetHeight(db.size.one)
		FCPcombo[2]:SetWidth(db.size.two)
		FCPcombo[2]:SetHeight(db.size.two)
		FCPcombo[3]:SetWidth(db.size.three)
		FCPcombo[3]:SetHeight(db.size.three)
		FCPcombo[4]:SetWidth(db.size.four)
		FCPcombo[4]:SetHeight(db.size.four)
		FCPcombo[5]:SetWidth(db.size.five)
		FCPcombo[5]:SetHeight(db.size.five)
		FCP:SetWidth(db.size.six)
		FCP:SetHeight(db.size.six)
		FCP2:SetWidth(db.size.seven)
		FCP2:SetHeight(db.size.seven)
		for i=1,5 do
			if FCPtex2[i] then
			FCPtex2[i]:SetVertexColor(1.0,1.0,1.0,1.0)
			FCPtex2[i]:SetTexCoord(0,1,0,1)
			end
		end

end



function Fair_StartAni(self,startTime,Ani_size,event)
	if event =="SPELL_AURA_REFRESH" then
		Fair_Animation5(self,startTime,Ani_size)
	else
		Fair_Animation(self,startTime,Ani_size)
	end
end	

function Fair_Animation(self,startTime,Ani_size)
	self.shown = true
	local elapsed = GetTime() - startTime
	local fadeInTime = 0.3
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
		self:SetAlpha(alpha)
		local size = Ani_size*2.0 - Ani_size*1.0*alpha
		self:SetWidth(size)
		self:SetHeight(size)
		return
	else
    		self:SetWidth(Ani_size)
		self:SetHeight(Ani_size)
		self:SetScript("OnUpdate", function() end)
	end
end
function Fair_Animation5(self,startTime,Ani_size)
	self.shown=true
	local elapsed = GetTime() - startTime
	local fadeInTime = 0.1
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
		self:SetAlpha(alpha)
		local size = Ani_size*2.0 - Ani_size*1.0*alpha
		self:SetWidth(size)
		self:SetHeight(size)
		return
	elseif( elapsed< fadeInTime+0.2) then
		local size = math.sin(elapsed/fadeInTime * 90) * 10 + Ani_size
 		self:SetWidth(size)
		self:SetHeight(size)
	else
    		self:SetWidth(Ani_size)
		self:SetHeight(Ani_size)
		self:SetScript("OnUpdate", function() end)
	end

end

function Fair_Animation_Hide(self,startTime,number)
	self.shown = false
	if number == 1 then
		Ani_size = db.size.one
	elseif number == 2 then
		Ani_size = db.size.two
	elseif number == 3 then
		Ani_size = db.size.three
	elseif number == 4 then
		Ani_size = db.size.four
	elseif number == 5 then
		Ani_size = db.size.five
	elseif number == 6 then
		Ani_size = db.size.six
	elseif number ==7 then
		Ani_size = db.size.seven
	end

	local elapsed = GetTime() - startTime
	local fadeInTime = 0.3
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
		self:SetAlpha(1.0-alpha)
		local size = Ani_size*alpha*2
		self:SetWidth(size)
		self:SetHeight(size)
		return
	else
		self:SetWidth(Ani_size)
		self:SetHeight(Ani_size)
		self:SetAlpha(1.0)
		self:Hide()
		self:SetScript("OnUpdate", function() end)
	end

end
function Fair_Animation2(self,startTime,i)
	self.shown = true
	local elapsed = GetTime() - startTime
	local fadeInTime = 0.3
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
--		self:SetAlpha(alpha)
		FCPtex2[i]:SetVertexColor(1.0,alpha*2-1.0,alpha*2-1.0)
		FCPtex2[i]:SetTexCoord(0,1,  1-alpha^2,alpha)
		return
	else
		FCPtex2[i]:SetTexCoord(0,1,  0,1)
		self:SetScript("OnUpdate", function() end)
	end
end

function Fair_Animation_Hide2(self,startTime,number)
	self.shown = false
	local elapsed = GetTime() - startTime
	local fadeInTime = 0.5
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
	--        FCPtex2[number]:SetHeight((1 -alpha)* Ani_size)
		self:SetAlpha(1.0-alpha)
		FCPtex2[number]:SetTexCoord(0,1,  -sqrt(alpha),1-alpha)
		FCPtex2[number]:SetVertexColor(1.0,1-alpha,1-alpha)
		return
	else
		self:SetAlpha(1.0)
		self:Hide()
		self:SetScript("OnUpdate", function() end)
	end

end
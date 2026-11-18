--[[
Author: Fairlady
FairComboPoints2  - Combo Points and Buff/Debuff display addon
$Date: 2010-10-15 21:58:13 +0000 (Fri, 15 Sep 2010) $
$Revision: 001 $
Project Version: 1.0.0
contact: cikandin@gmail.com
]]

local FairComboPoints2 = LibStub("AceAddon-3.0"):NewAddon("FairComboPoints2", "AceConsole-3.0")
local basepath = [[Interface\Addons\FairComboPoints2\Icons\]]
FairComboPoints2:SetDefaultModuleState(false)

function FairComboPoints2:OnInitialize()
	local defaults = {
		profile = {
			modules = {
				['**'] = {
					enabled = true,
					--text options

					--graphics options
					orientation = "h",
					icon = "star",
					colors = {
						['**'] = {1, 1, 1},
						[5] = {1, 1, 1},
					},
					graphicsAlpha = 1,
					numberAlpha = 1,
					spacing = 5,
					scale = 1,
					numberscale =0.6,
					strata = "HIGH",
					numberstrata = "HIGH",
					graphicsPos = {},
					numberPos = {},
					disableGraphics = false,
					disableNumber = false,
				},
				['Deadly Poison'] = {
					colors = {
						[1] = {0, 1, 0},
						[2] = {0, 1, 0},
						[3] = {0, 1, 0},
						[4] = {0, 1, 0},
						[5] = {0, 0.5, 0},
					},
				},
			},
			locked = false,
			custom = {},
			others = {
				iconPos = {},
				aura = {},
				scale = 1,
				orientation = "c",
				alpha = 1,
			},
			self = {
				iconPos = {},
				aura = {},
				scale = 1,
				orientation = "c",
				alpha = 1,
			},
		}
	}

	self.db = LibStub("AceDB-3.0"):New("FCP2DB2", defaults, "Default")
--	self.db.RegisterCallback(self, "OnProfileReset", "Reset")
--	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
--	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self:RegisterChatCommand("fcp2", "OpenConfig", true, true)

	for index,value in pairs(self.db.profile.custom) do
		local modName = value
		local customModule = self:NewModule(value, "AceConsole-3.0", "AceEvent-3.0")
		customModule.abbrev = value
		customModule.MAX_POINTS = 5
		customModule.displayName = value
		customModule.custom = true
	end
	LoadAddOn("FairComboPoints2_Options")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FairComboPoints2", "FairComboPoints2")
end

function FairComboPoints2:OnEnable()
	for name, module in self:IterateModules() do
		if self.db.profile.modules[name].enabled then
			module:Enable()
		end
	end
end

function FairComboPoints2:Reset()

end

function FairComboPoints2:Refresh()
	for name, module in self:IterateModules() do
		if module:IsEnabled() then
			self:UpdateSettings(name, module)
			local db = self.db.profile.modules[name]
			module.graphics:ClearAllPoints()
			if db.graphicsPos.x then
				module.graphics:SetPoint(db.graphicsPos.point, UIParent, db.graphicsPos.anchor, db.graphicsPos.x, db.graphicsPos.y)
			else
				module.graphics:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			end

			if db.numberPos.x then
				module.number:SetPoint(db.numberPos.point, UIParent, db.numberPos.anchor, db.numberPos.x, db.numberPos.y)
			else
				module.number:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			end

			if self.db.profile.locked then

				module.graphics:SetBackdropColor(1,1,1,0)
				module.graphics:EnableMouse(false)
				module.graphics:SetMovable(false)
				module.graphics.points[1]:Hide()
				module.graphics.points[2]:Hide()

				module.number:SetBackdropColor(1,1,1,0)
				module.number:EnableMouse(false)
				module.number:SetMovable(false)
				module.number.points[1]:Hide()
				module.number.points[2]:Hide()
				module.number.combo:Hide()
				module.number.combo_ani:Hide()

			else
				module.graphics:SetBackdropColor(1,1,1,1)
				module.graphics:EnableMouse(true)
				module.graphics:SetMovable(true)
				module.graphics.points[1]:Show()
				module.graphics.points[2]:Show()

				module.number:SetBackdropColor(1,1,1,1)
				module.number:EnableMouse(true)
				module.number:SetMovable(true)
				module.number.points[1]:Show()
				module.number.combo:Show()
			end
		end
	end
end

function FairComboPoints2:UpdateSettings(name)
	local db = self.db.profile.modules[name]
	local module = self:GetModule(name)
	--graphics
	if not db.disableGraphics then
		--change icon textures
		--update icon Alpha
		for i = 1, module.MAX_POINTS do
			module.graphics.points[i].icon:SetTexture(basepath..db.icon)
			module.graphics.points[i]:SetAlpha(db.graphicsAlpha)
			module.graphics.points[i]:SetWidth(25*db.scale)
			module.graphics.points[i]:SetHeight(25*db.scale)
			module.graphics.points[i]:ClearAllPoints()
		end

		--adjust container scale
		if db.orientation == "v" then
			module.graphics:SetHeight(145*db.scale)
			module.graphics:SetWidth(25*db.scale)
		else
			module.graphics:SetWidth(145*db.scale)
			module.graphics:SetHeight(25*db.scale)
		end

		--adjust for orientation changes (this updates spacing too)
		local offset = db.spacing*db.scale
		if db.orientation == "v" then
			module.graphics.points[1]:SetPoint("BOTTOM", module.graphics, "BOTTOM", 0, 0)
			for i = 2, module.MAX_POINTS do
				module.graphics.points[i]:SetPoint("BOTTOM", module.graphics.points[i-1], "TOP", 0, offset)
			end
		else
			module.graphics.points[1]:SetPoint("LEFT", module.graphics, "LEFT", 0, 0)
			for i = 2, module.MAX_POINTS do
				module.graphics.points[i]:SetPoint("LEFT", module.graphics.points[i-1], "RIGHT", offset, 0)
			end
		end

		--update strata
		module.graphics:SetFrameStrata(db.strata)
	end

	--numbers
	if not db.disableNumber then
		--change icon textures
		--update icon Alpha
		for i = 1, module.MAX_POINTS do
			module.number.points[i]:SetAlpha(db.numberAlpha)
			module.number.combo:SetAlpha(db.numberAlpha)
			module.number.combo_ani:SetAlpha(db.numberAlpha)
			module.number.points[i].icon:SetTexture(basepath.."number_"..i)
			module.number.points[i]:SetWidth(128*db.numberscale)
			module.number.points[i]:SetHeight(128*db.numberscale)
			module.number.points[i]:ClearAllPoints()
			module.number.points[i].icon:SetVertexColor(unpack(db.colors["number"..i]))
		end
		module.number.effect[10].texture:SetVertexColor(unpack(db.colors["number"..module.MAX_POINTS]))
		--adjust container scale
		module.number:SetWidth(100*db.numberscale)
		module.number:SetHeight(100*db.numberscale)

		--adjust for orientation changes (this updates spacing too)
		for i = 1, module.MAX_POINTS do
			module.number.points[i]:SetPoint("CENTER", module.number, "CENTER", 0, 0)
		end
		module.number.combo:SetPoint("LEFT", module.number, "LEFT", 70*db.numberscale, 10*db.numberscale)
		module.number.combo:SetHeight(128*db.numberscale)
		module.number.combo:SetWidth(128*db.numberscale)
		module.number.combo_ani:SetPoint("LEFT", module.number, "LEFT", 140*db.numberscale, 10*db.numberscale)

		module.number.combo_ani:SetHeight(128*db.numberscale)
		module.number.combo_ani:SetWidth(128*db.numberscale)

		for i = 1,16,1 do
			module.number.effect[i]:SetHeight(256*db.numberscale)
			module.number.effect[i]:SetWidth(256*db.numberscale)
		end
		module.number.effect[12]:SetPoint("LEFT", module.number.effect[10], "LEFT", 5*db.numberscale, 12*db.numberscale)
		--update strata
		module.number:SetFrameStrata(db.numberstrata)
	end
end

function FairComboPoints2:OpenConfig()
	LoadAddOn("FairComboPoints2_Options")
	LibStub("AceConfigDialog-3.0"):Open("FairComboPoints2")
end
--color unpack
function FairComboPoints2:GetColorByPoints(module, points)
	return unpack(self.db.profile.modules[module].colors[points])
end

local bg = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",}

function FairComboPoints2:MakeGraphicsFrame(module, num)
	local g = CreateFrame("FRAME", module.."graphics", UIParent)
	local db = self.db.profile.modules[module]
	g:SetBackdrop(bg)
	g:SetFrameStrata(db.strata)
	g:SetClampedToScreen(true)
	if db.graphicsPos.x then
		g:SetPoint(db.graphicsPos.point, UIParent, db.graphicsPos.anchor, db.graphicsPos.x, db.graphicsPos.y)
	else
		g:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end

	g:SetBackdropColor(1,1,1,0)

	if db.orientation == "v" then
		g:SetHeight(145*db.scale)
		g:SetWidth(25*db.scale)
	else
		g:SetWidth(145*db.scale)
		g:SetHeight(25*db.scale)
	end

	g:RegisterForDrag("LeftButton")
	g:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
	g:SetScript("OnDragStop", function(frame)
		frame:StopMovingOrSizing()
		local point, _, anchor, x, y = frame:GetPoint()
		db.graphicsPos.x = math.floor(x)
		db.graphicsPos.y = math.floor(y)
		db.graphicsPos.anchor = anchor
		db.graphicsPos.point = point
	end)
	g.text = g:CreateFontString(nil,"BACKGROUND")
	g.text:SetFont("Interface\\AddOns\\FairComboPoints2\\Fonts\\k_Damage.TTF",15,"OUTLINE")
	g.text:SetText(module)
	g.text:SetPoint("TOP",g,"BOTTOM",0,0)
	g.points = {}
	for i = 1, num do
		g.points[i] = CreateFrame("FRAME", nil, g)
		g.points[i].icon = g.points[i]:CreateTexture(nil, "ARTWORK")
		g.points[i].icon:SetAllPoints(g.points[i])
		g.points[i].icon:SetTexture(basepath..db.icon)
		g.points[i].icon:SetVertexColor(unpack(db.colors[1]))
		g.points[i].icon:SetBlendMode("BLEND")
		g.points[i].blink = g.points[i]:CreateTexture(nil, "OVERLAY")
		g.points[i].blink:SetPoint("CENTER", g.points[i], "CENTER", 0, 0)
		g.points[i].blink:SetTexture(basepath.."blink")
		g.points[i].blink:SetBlendMode("ADD")
		g.points[i].blink:SetHeight(50*db.scale)
		g.points[i].blink:SetWidth(50*db.scale)
		g.points[i].blink:Hide()
		g.points[i]:SetAlpha(db.graphicsAlpha)
		g.points[i]:SetHeight(25*db.scale)
		g.points[i]:SetWidth(25*db.scale)
		g.points[i]:Hide()
	end

	if not self.db.profile.locked then
		g:SetBackdropColor(1,1,1,1)
		g:EnableMouse(true)
		g:SetMovable(true)
		g.points[1]:Show()
		g.points[2]:Show()
		g.text:Show()
	else
		g:EnableMouse(false)
		g:SetMovable(false)
		g.text:Hide()
	end

	local offset = db.spacing*db.scale
	if db.orientation == "v" then
		g.points[1]:SetPoint("BOTTOM", g, "BOTTOM", 0, 0)
		for i = 2, num do
			g.points[i]:SetPoint("BOTTOM", g.points[i-1], "TOP", 0, offset)
		end
	else
		g.points[1]:SetPoint("LEFT", g, "LEFT", 0, 0)
		for i = 2, num do
			g.points[i]:SetPoint("LEFT", g.points[i-1], "RIGHT", offset, 0)
		end
	end

	if db.disableGraphics then
		g:Hide()
	end

	return g
end

--create number frame
function FairComboPoints2:MakeNumberFrame(module, num)
	local h = CreateFrame("FRAME", module.."number", UIParent)
	local db = self.db.profile.modules[module]
	h:SetBackdrop(bg)
	h:SetFrameStrata(db.numberstrata)
	h:SetClampedToScreen(true)
	if db.numberPos.x then
		h:SetPoint(db.numberPos.point, UIParent, db.numberPos.anchor, db.numberPos.x, db.numberPos.y)
	else
		h:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end

	h:SetBackdropColor(1,1,1,0)

	h:SetWidth(100*db.numberscale)
	h:SetHeight(100*db.numberscale)

	h:RegisterForDrag("LeftButton")
	h:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
	h:SetScript("OnDragStop", function(frame)
		frame:StopMovingOrSizing()
		local point, _, anchor, x, y = frame:GetPoint()
		db.numberPos.x = math.floor(x)
		db.numberPos.y = math.floor(y)
		db.numberPos.anchor = anchor
		db.numberPos.point = point
	end)
	h.text = h:CreateFontString(nil,"BACKGROUND")
	h.text:SetFont("Interface\\AddOns\\FairComboPoints2\\Fonts\\k_Damage.TTF",15,"OUTLINE")
	h.text:SetText(module)
	h.text:SetPoint("TOP",h,"BOTTOM",0,0)
	h.points = {}
	for i = 1, num do
		h.points[i] = CreateFrame("FRAME", nil, h)
		h.points[i].icon = h.points[i]:CreateTexture(nil, "OVERLAY")
		h.points[i].icon:SetAllPoints(h.points[i])
		h.points[i].icon:SetTexture(basepath.."number_"..i)
		h.points[i].icon:SetVertexColor(unpack(db.colors["number"..i]))
		h.points[i]:SetAlpha(db.numberAlpha)
		h.points[i]:SetHeight(128*db.numberscale)
		h.points[i]:SetWidth(128*db.numberscale)
		h.points[i]:Hide()
	end

	h.combo = CreateFrame("FRAME",nil,h)
	h.combo:SetPoint("LEFT", h, "LEFT", 70*db.numberscale, 10*db.numberscale)
	h.combo.texture = h.combo:CreateTexture(nil,"OVERLAY")
	h.combo.texture:SetAllPoints(h.combo)
	h.combo.texture:SetTexture(basepath.."combo")
	h.combo:SetAlpha(db.numberAlpha)
	h.combo:SetHeight(128*db.numberscale)
	h.combo:SetWidth(128*db.numberscale)
	h.combo:Hide()

	h.combo_ani = CreateFrame("FRAME",nil,h)
	h.combo_ani:SetPoint("LEFT", h, "LEFT", 140*db.numberscale, 10*db.numberscale)
	h.combo_ani.texture = h.combo_ani:CreateTexture(nil,"OVERLAY")
	h.combo_ani.texture:SetAllPoints(h.combo_ani)
	h.combo_ani.texture:SetTexture(basepath.."combo")
	h.combo_ani:SetAlpha(db.numberAlpha)
	h.combo_ani:SetHeight(128*db.numberscale)
	h.combo_ani:SetWidth(128*db.numberscale)
	h.combo_ani:Hide()


	h.effect = {}
	for i = 1,16,1 do
		h.effect[i] = CreateFrame("FRAME",nil,h)
		--	h.effect[i]:SetPoint("LEFT", h, "LEFT", 0, 0)
		h.effect[i].texture = h.effect[i]:CreateTexture(nil,"OVERLAY")
		h.effect[i].texture:SetAllPoints(h.effect[i])
		h.effect[i].texture:SetTexture(basepath.."effect5")
		h.effect[i].texture:SetBlendMode("ADD")
		h.effect[i]:SetHeight(256*db.numberscale)
		h.effect[i]:SetWidth(256*db.numberscale)
		h.effect[i]:SetFrameStrata("MEDIUM")
		h.effect[i]:Hide()
	end

	h.effect[1]:SetPoint("LEFT", h, "LEFT", -25*db.numberscale, -10*db.numberscale)
	h.effect[1].texture:SetTexture(basepath.."effect5")
	h.effect[1]:SetWidth(256*db.numberscale*1.2)

	h.effect[2]:SetPoint("LEFT", h, "LEFT", -25*db.numberscale, -15*db.numberscale)
	h.effect[2].texture:SetTexture(basepath.."effect6")

	h.effect[3]:SetPoint("TOP", h, "TOP", 15*db.numberscale, 60*db.numberscale)
	h.effect[3].texture:SetTexture(basepath.."effect7")

	h.effect[4]:SetPoint("TOP", h, "TOP", 15*db.numberscale, 60*db.numberscale)
	h.effect[4].texture:SetTexture(basepath.."effect8")

	h.effect[5]:SetPoint("LEFT", h, "LEFT", -25*db.numberscale, 15*db.numberscale)
	h.effect[5].texture:SetTexture(basepath.."effect9")
	h.effect[5]:SetWidth(256*db.numberscale*1.4)

	h.effect[6]:SetAllPoints(h.effect[5])
	h.effect[6].texture:SetTexture(basepath.."effect10")

	h.effect[7]:SetPoint("TOP", h, "TOP", 20*db.numberscale, 40*db.numberscale)
	h.effect[7].texture:SetTexture(basepath.."effect11")

	h.effect[8]:SetAllPoints(h.effect[7])
	h.effect[8].texture:SetTexture(basepath.."effect12")

	h.effect[9]:SetPoint("CENTER", h, "CENTER", 0, 0)
	h.effect[9].texture:SetTexture(basepath.."effect3")

	h.effect[10]:SetPoint("CENTER", h, "CENTER", 70*db.numberscale, -8*db.numberscale)
	h.effect[10].texture:SetTexture(basepath.."max")
	h.effect[10].texture:SetBlendMode("BLEND")
	h.effect[10].texture:SetVertexColor(unpack(db.colors["number"..self:GetModule(module).MAX_POINTS]))

	h.effect[11]:SetAllPoints(h.effect[10])
	h.effect[11].texture:SetTexture(basepath.."max1")
	h.effect[11]:SetFrameStrata("HIGH")

	h.effect[12]:SetFrameStrata("LOW")
	h.effect[12]:SetPoint("LEFT", h.effect[10], "LEFT", 5*db.numberscale, 12*db.numberscale)
	h.effect[12].texture:SetTexture(basepath.."max_b")

	h.effect[13]:SetFrameStrata("LOW")
	h.effect[13]:SetPoint("LEFT", h.effect[10], "CENTER",50*db.numberscale,20*db.numberscale)
	h.effect[13].texture:SetTexture(basepath.."wing")
	h.effect[13]:SetHeight(128*db.numberscale)
	h.effect[13]:SetWidth(128*db.numberscale)

	h.effect[14]:SetPoint("CENTER", h, "CENTER", 65*db.numberscale, -18*db.numberscale)
	h.effect[14].texture:SetTexture(basepath.."back")
	h.effect[14]:SetFrameStrata("LOW")

	h.effect[15]:SetPoint("CENTER", h, "CENTER", 0, 0)
	h.effect[15].texture:SetTexture(basepath.."cir")
	h.effect[15]:SetWidth(256*db.numberscale*0.3)
	h.effect[15]:SetHeight(256*db.numberscale*0.3)

	h.effect[16]:SetFrameStrata("LOW")
	h.effect[16]:SetPoint("RIGHT", h.effect[10], "CENTER",-50*db.numberscale,20*db.numberscale)
	h.effect[16].texture:SetTexture(basepath.."wing")
	h.effect[16].texture:SetTexCoord(1,0,  0,1)
	h.effect[16]:SetHeight(128*db.numberscale)
	h.effect[16]:SetWidth(128*db.numberscale)

	--
	if not self.db.profile.locked then
		h:SetBackdropColor(1,1,1,1)
		h:EnableMouse(true)
		h:SetMovable(true)
		h.points[1]:Show()
		h.text:Show()
		h.combo:Show()
	else
		h.points[1]:Hide()
		h.combo:Hide()
		h.text:Hide()
		h:EnableMouse(false)
		h:SetMovable(false)
	end
	for i = 1, num do
		h.points[i]:SetPoint("CENTER", h, "CENTER", 0, 0)
	end

	if db.disableNumber then
		h:Hide()
	end

	return h
end

--create custom Timer

function FairComboPoints2:MakeIconFrame(name,db)
local f
	f = CreateFrame("FRAME",name, UIParent)
	f:SetBackdrop(bg)
	f:SetClampedToScreen(true)
	if db.iconPos.x then
		f:SetPoint(db.iconPos.point, UIParent, db.iconPos.anchor, db.iconPos.x, db.iconPos.y)
	else
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
	f:SetBackdropColor(1,1,1,0)
	f.text = f:CreateFontString(nil,"BACKGROUND")
	f.text:SetFont("Interface\\AddOns\\FairComboPoints2\\Fonts\\k_Damage.TTF",13,"OUTLINE")
	f.text:SetText(name)
	f.text:SetPoint("TOP",f,"BOTTOM",0,0)
	f:SetWidth(30*db.scale)
	f:SetHeight(30*db.scale)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
	f:SetScript("OnDragStop", function(frame)
		frame:StopMovingOrSizing()
		local point, _, anchor, x, y = frame:GetPoint()
		db.iconPos.x = math.floor(x)
		db.iconPos.y = math.floor(y)
		db.iconPos.anchor = anchor
		db.iconPos.point = point
	end)

	if not self.db.profile.locked then
		f:SetBackdropColor(1,1,1,1)
		f:EnableMouse(true)
		f:SetMovable(true)
		f.text:Show()
	else
		f:EnableMouse(false)
		f:SetMovable(false)
		f.text:Hide()
	end
	return f

end
--
local FCP2_Current = {}
function FairComboPoints2:CreateBuffIcon(k,f,db)
	local _, _, spellicon = GetSpellInfo(k)
	local frame
	for k,v in ipairs(FCP2_Current) do
		if not FCP2_Current[k]:IsShown() then
			frame = FCP2_Current[k]
			frame:SetParent(f)
			break
		end
	end
	if not frame then
		frame = CreateFrame("FRAME", nil, f)
		tinsert(FCP2_Current,frame)
	end
	frame:SetPoint("CENTER",f,"CENTER",0,0)
	frame:SetFrameStrata("BACKGROUND")
	frame.icon = frame.icon or frame:CreateTexture(nil, "BACKGROUND")
	frame.icon:SetAllPoints(frame)
	frame.icon:SetTexture(spellicon)
	frame.bg = frame.bg or frame:CreateTexture(nil, "BORDER")
	frame.bg:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.bg:SetTexture(basepath.."background")
	frame.bg:SetHeight(64*db.scale*0.75)
	frame.bg:SetWidth(64*db.scale*0.75)
	frame.bg:SetVertexColor(1,1,1)
	frame.glow = frame.glow or CreateFrame("FRAME",nil, frame)
	frame.glow:SetFrameStrata("BACKGROUND")
	frame.glow:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.glow:SetHeight(75*db.scale*0.75)
	frame.glow:SetWidth(75*db.scale*0.75)
	frame.glow.tex = frame.glow.tex or frame.glow:CreateTexture(nil,"ARTWORK")
	frame.glow.tex:SetTexture(basepath.."glow")
	frame.glow.tex:SetAllPoints(frame.glow)
	frame.glow:Hide()

	frame.text = frame.text or frame:CreateFontString(nil,"OVERLAY")
	frame.text:SetFont("Interface\\AddOns\\FairComboPoints2\\Fonts\\k_Damage.TTF",13,"OUTLINE")
	frame.text:SetPoint("CENTER",frame,"CENTER",0,0)
	frame.text:SetText("")
	frame.text:Hide()

	frame.timeframe = frame.timeframe or CreateFrame("FRAME",nil, frame)
	frame.timeframe:SetFrameStrata("LOW")
	frame.timeframe:SetAllPoints(frame)
	frame.time = frame.time or frame.timeframe:CreateFontString(nil,"OVERLAY")
	frame.time:SetFont("Interface\\AddOns\\FairComboPoints2\\Fonts\\k_Damage.TTF",12,"OUTLINE")
	frame.time:SetPoint("TOP",frame.timeframe,"BOTTOM",0,5)
	frame.time:SetText("")
	frame.time:Hide()
	frame:SetAlpha(db.alpha)
	frame:SetHeight(30*db.scale)
	frame:SetWidth(30*db.scale)
	frame.anchorframe = frame
	frame.anchorpoint = "CENTER"
	frame.anchorposx = 0
	frame.anchorposy = 0
	frame.size = 64*db.scale*0.75
	frame.alpha = 0.5
	frame.framelevel = 2
	frame.scale = 1
	frame.segments_used = 4
	frame.start_segment = 4
	frame.fill_direction = 0
	frame.texture = basepath.."ring1"
	frame.color = {r = 255/255, g = 255/255, b = 255/255, a = 1}
	frame.blendmode = "ADD"
	frame.segmentsize = 32*db.scale*0.75
	frame.outer_radius = 100/4*db.scale*0.75
	frame.inner_radius = 80/4*db.scale*0.75
	frame.ring = frame.ring or self:create_segments(frame,frame)
	--ring spark
	frame.sp = {}
	frame.sp.anchorframe = frame
	frame.sp.active = 1
	frame.sp.color = {r =1, g =1, b = 1, a = 1}
	frame.sp.alpha = 1
	frame.sp.framelevel = 5
	frame.sp.scale = 1
	frame.sp.size = ((100-80)*db.scale/1.5)
	frame.sp.radius = ((100+80)/2*db.scale/4*0.72)
	frame.sp.shiftradian = math.rad(90)
	frame.sp.blendmode = "ADD"
	frame.sp.texture = basepath.."spark1"
	frame.spark = frame.spark or self:create_spark(frame.sp)
	frame.spark:Show()
	frame:Hide()
	return frame
end
-- Animations
function FairComboPoints2:FireAnimation(points,module)
	local db = self.db.profile.modules[module]
	local module = self:GetModule(module)
	local startTime = GetTime()
	local width = 256 * db.numberscale
	local height = 256 * db.numberscale
	if points == module.MAX_POINTS then
		module.number.combo:Hide()
		module.number.combo_ani:Hide()
		module.number.effect[10]:Show()
		module.number.effect[10]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation5(self,startTime,width,module.number.effect[11],0.1,db.numberscale) end)
		module.number.effect[12]:Show()
		module.number.effect[12]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation2(self,startTime,width,0.3) end)
	elseif points == 1 then
		module.number.effect[5]:Show()
		module.number.effect[5]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation(self,startTime+0.1,width,module.number.effect[6],0.2) end)
	elseif points == 2 then
		module.number.effect[3]:Show()
		module.number.effect[3]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation_V(self,startTime+0.1,height,module.number.effect[4],0.3) end)
		module.number.effect[5]:Show()
		module.number.effect[5]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation(self,startTime,width,module.number.effect[6],0.2) end)
	elseif points == 3 then
		module.number.effect[7]:Show()
		module.number.effect[7]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation_V(self,startTime+0.25,height,module.number.effect[8],0.2) end)
		module.number.effect[3]:Show()
		module.number.effect[3]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation_V(self,startTime,height,module.number.effect[4],0.3) end)
		module.number.effect[5]:Show()
		module.number.effect[5]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation(self,startTime,width,module.number.effect[6],0.2) end)
	elseif points == 4 then
		module.number.effect[7]:Show()
		module.number.effect[7]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation_V(self,startTime+0.25,height,module.number.effect[8],0.2) end)
		module.number.effect[3]:Show()
		module.number.effect[3]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation_V(self,startTime,height,module.number.effect[4],0.3) end)
		module.number.effect[1]:Show()
		module.number.effect[1]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation(self,startTime,width,module.number.effect[2],0.2) end)
		module.number.effect[5]:Show()
		module.number.effect[5]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation(self,startTime+0.1,width,module.number.effect[6],0.2) end)
	else
		module.number.effect[7]:Show()
		module.number.effect[7]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation_V(self,startTime+0.25,height,module.number.effect[8],0.2) end)
		module.number.effect[3]:Show()
		module.number.effect[3]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation_V(self,startTime,height,module.number.effect[4],0.3) end)
		module.number.effect[1]:Show()
		module.number.effect[1]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation(self,startTime,width,module.number.effect[2],0.2) end)
		module.number.effect[5]:Show()
		module.number.effect[5]:SetScript("OnUpdate",  function(self, elapsed) FairComboPoints2:Fair_Animation(self,startTime+0.1,width,module.number.effect[6],0.2) end)
	end
end


function FairComboPoints2:Fair_Animation5(self,startTime,width,frame,fadeInTime,numberscale)
	local elapsed = GetTime() - startTime
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
		self:SetAlpha(alpha)
		local size = 256*numberscale*4.0 - 256*numberscale*3.0*alpha
		self:SetWidth(size)
		self:SetHeight(size)
		return
	elseif( elapsed< fadeInTime+0.2) then
		--UIFrameFlash(frame,0, 0.5, 0.5, false,0, 0)
		local size = math.sin(elapsed/fadeInTime * 90) * 10 + 256*numberscale
 		self:SetWidth(size)
		self:SetHeight(size)
	else
    	self:SetWidth(256*numberscale)
		self:SetHeight(256*numberscale)
		self:SetScript("OnUpdate", nil)
	end

end


function FairComboPoints2:Fair_Animation(self,startTime,width,frame,fadeInTime)
	self:Show()
	local elapsed = GetTime() - startTime
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
	--	self:SetAlpha(1-alpha^2)
		self.texture:SetVertexColor(1.0,alpha*2-1.0,alpha*2-1.0)
		self.texture:SetTexCoord(0,alpha,0,1)
		self:SetWidth(width*alpha)
		return
	else
		if frame then
			--UIFrameFlash(frame,0.0, 0.2, 0.2, false,0, 0)
		end
		self.texture:SetTexCoord(0,1,  0,1)
		self:SetScript("OnUpdate", nil)
		self:SetWidth(width)
		self:Hide()
	end
end
function FairComboPoints2:Fair_Animation2(self,startTime,width,fadeInTime)
	self:Show()
	local elapsed = GetTime() - startTime
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
		self.texture:SetTexCoord(0,alpha,0,1)
		self:SetWidth(width*alpha)
		return
	else
		self.texture:SetTexCoord(0,1,  0,1)
		self:SetScript("OnUpdate", nil)
		self:SetWidth(width)
	end
end
function FairComboPoints2:Fair_Animation_V(self,startTime,height,frame,fadeInTime)
	self:Show()
	local elapsed = GetTime() - startTime
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
--		self:SetAlpha(1-alpha^2)
--		self.texture:SetVertexColor(1.0,1,alpha/5*3-0.4)
		self.texture:SetTexCoord(0,1,0,alpha)
		self:SetHeight(height*alpha)
		return
	else
		--UIFrameFlash(frame,0.0, 0.1, 0.1, false,0, 0)
		self.texture:SetTexCoord(0,1,  0,1)
		self:SetScript("OnUpdate", nil)
		self:SetHeight(height)
		self:Hide()
	end
end

function FairComboPoints2:EffectAnimation(frame)
	frame:Show()
	frame:SetAlpha(0.3)
	local scale_ani = frame:CreateAnimationGroup()
	local a1 = scale_ani:CreateAnimation("Alpha")
   	a1:SetChange(-0.3)
    a1:SetDuration(0.4)

	local a2 = scale_ani:CreateAnimation("Scale")
    a2:SetScale(0.25, 1.5)
    a2:SetDuration(0.4)
    a2:SetSmoothing("OUT")
    scale_ani:Play()
    scale_ani:SetScript("OnFinished",function()
		frame:SetAlpha(0)
		frame:SetScale(1,1)
	end)
end

function FairComboPoints2:RepeatAnimation(frame)
	local repeat_ani = frame:CreateAnimationGroup()

	local a4 = repeat_ani:CreateAnimation("Alpha")
   	a4:SetChange(-0.5)
    a4:SetDuration(1)

	local a2 = repeat_ani:CreateAnimation("Scale")
    a2:SetScale(0.7, 0.7)
    a2:SetDuration(1)
    a2:SetSmoothing("OUT")
    repeat_ani:SetLooping("BOUNCE")
    repeat_ani:Play()
--  scale_ani:SetScript("OnFinished",nil)
end

function FairComboPoints2:ScaleAnimation(frame,startTime,size)
	frame:Show()
	local fadeInTime = 0.3
	local elapsed = GetTime() - startTime
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
		frame:SetWidth(size*(1-alpha)*4)
		frame:SetHeight(size*(1-alpha)*4)
		frame:SetAlpha(alpha)
		return
	else
		frame:SetWidth(size)
		frame:SetHeight(size)
		frame:SetAlpha(1)
		frame:SetScript("OnUpdate", nil)
	end
end

function FairComboPoints2:RotateAnimation(frame)
	frame:SetAlpha(1)
	frame:Show()
	local rotate_ani = frame:CreateAnimationGroup()

	 local a1 = rotate_ani:CreateAnimation("Alpha")
   	a1:SetChange(-1)
    a1:SetDuration(0.4)

	local a2 = rotate_ani:CreateAnimation("Rotation")
	a2:SetDegrees(90)
    a2:SetDuration(0.4)
    a2:SetSmoothing("OUT")
    rotate_ani:Play()
    rotate_ani:SetScript("OnFinished",function()
		frame:Hide()
		frame:SetAlpha(0)
	end)
end
function FairComboPoints2:NumberSlideAnimation(frame,frame2,module)
	local slide_ani = frame:CreateAnimationGroup()
	local c1 = slide_ani:CreateAnimation("Translation")
	c1:SetOffset(-50*self.db.profile.modules[module].numberscale,0)
	c1:SetDuration(0.3)
	c1:SetSmoothing("OUT")

	local c2 = slide_ani:CreateAnimation("Alpha")
	c2:SetChange(1)
	c2:SetDuration(0.3)
	if not slide_ani:IsPlaying() then
		frame:Show()
		frame:SetAlpha(0)
		frame2:Hide()
		slide_ani:Play()
	end
	slide_ani:SetScript("OnFinished",function() frame2:Show() end)
end


function FairComboPoints2:NumberSlideOutAnimation(frame,module)
	frame:Show()
	local slideout_ani = frame:CreateAnimationGroup()
	local c1 = slideout_ani:CreateAnimation("Translation")
	c1:SetOffset(50*self.db.profile.modules[module].numberscale,0)
	c1:SetDuration(0.3)
	c1:SetSmoothing("OUT")

	local c2 = slideout_ani:CreateAnimation("Alpha")
	c2:SetChange(-1)
	c2:SetDuration(0.3)
	if not slideout_ani:IsPlaying() then
		slideout_ani:Play()
	end
	if not isPlayed then
		slideout_ani:SetScript("OnFinished",function() frame:Hide() end)
	end
end

function  FairComboPoints2:Fair_Animation_Hide(frame,startTime,fadeInTime,module,Ani_size)
	local numberalpha = self.db.profile.modules[module].numberAlpha
	local elapsed = GetTime() - startTime
	local fadeInTime = 0.3
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime)
		frame:SetAlpha(1.0-alpha)
		local size = Ani_size*alpha*3
		frame:SetWidth(size)
		frame:SetHeight(size)
		return
	else
		frame:SetWidth(Ani_size)
		frame:SetHeight(Ani_size)
		frame:SetAlpha(numberalpha)
		frame:SetScript("OnUpdate", nil)
		frame:Hide()
	end
end


function  FairComboPoints2:Fair_Animation_Hide2(frame,fadeInTime,module)
	local hide_ani = frame:CreateAnimationGroup()
	local alpha = self.db.profile.modules[module].numberAlpha
	local h1 = hide_ani:CreateAnimation("Alpha")
   	h1:SetChange(-alpha)
    h1:SetDuration(fadeInTime)

	local h2 = hide_ani:CreateAnimation("Scale")
    h2:SetScale(3,3)
    h2:SetDuration(fadeInTime)
    h2:SetSmoothing("OUT")
    hide_ani:Play()
    hide_ani:SetScript("OnFinished",function()
		frame:Hide()
	end)
end

function FairComboPoints2:MoveAnimation(frame,x,y,x2,y2,scale)
	local ani = frame:CreateAnimationGroup()
	local a1,a2
	if x or y then
		a1 = ani:CreateAnimation("Translation")
		a1:SetOffset(x*0.7,y*0.7)
		a1:SetDuration(0.3)
		a1:SetSmoothing("OUT")
	end
	if scale then
		frame:SetScale(scale)
		a2 = ani:CreateAnimation("Scale")
		a2:SetScale(1/scale,1/scale)
		a2:SetDuration(0.3)
		a2:SetSmoothing("OUT")
	end
	if not ani:IsPlaying() then
		ani:Play()
	end
   	ani:SetScript("OnFinished",function() frame:SetPoint("CENTER",frame:GetParent(),"CENTER",x2,y2) end)
end
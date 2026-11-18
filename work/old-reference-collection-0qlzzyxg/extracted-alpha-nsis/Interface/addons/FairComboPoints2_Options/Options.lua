local _
--[[
Author: Fairlady
FairComboPoints2  - Combo Points and Buff/Debuff display addon
$Date: 2010-10-15 21:58:13 +0000 (Fri, 15 Sep 2010) $
$Revision: 001 $
Project Version: 1.0.0
contact: cikandin@gmail.com
]]

local core = LibStub("AceAddon-3.0"):GetAddon("FairComboPoints2")
local L = LibStub("AceLocale-3.0"):GetLocale("FairComboPoints2")
local format = string.format

--option article

local stratas = {["FULLSCREEN"] = "Fullscreen", ["HIGH"] = "High", ["MEDIUM"] = "Medium", ["LOW"] = "Low", ["BACKGROUND"] = "Background",}
local symbols = {
	star = L["Star"],
	circle = L["Circle"],
	skull = L["Skull"],
}
local orientations =  {h = L["Horizontal"], v = L["Vertical"],}
local directions = {l = L["Left"], r = L["Right"],t =L["Top"],b =L["Bottom"],c=L["Center"],cv=L["CenterVertical"]}
local opts = {
	type = 'group',
	args = {},
}
local CUSTOM = LibStub("AceAddon-3.0"):GetAddon("FCP2_CUSTOM",true)
	--make main options
	opts.args["core"] = {
	type = "group",
	name = L["Core"],
	order = 1,
	args = {
		locked = {
			type = "toggle",
			name = L["Lock"],
			desc = L["Lock all the frames."],
			descStyle = "inline",
			width = "full",
			order = 1,
			get = function() return core.db.profile.locked end,
			set = function()
				core.db.profile.locked = not core.db.profile.locked
				if not core.db.profile.locked then
					local frame = _G["FCP2SelfBuff"]
					local frame2 = _G["FCP2TargetBuff"]
					if frame then
						frame:SetBackdropColor(1,1,1,1)
						frame:EnableMouse(true)
						frame:SetMovable(true)
						frame.text:Show()
					end
					if frame2 then
						frame2:SetBackdropColor(1,1,1,1)
						frame2:EnableMouse(true)
						frame2:SetMovable(true)
						frame2.text:Show()
					end
				else
					local frame = _G["FCP2SelfBuff"]
					local frame2 = _G["FCP2TargetBuff"]
					if frame then
						frame:SetBackdropColor(1,1,1,0)
						frame:EnableMouse(false)
						frame:SetMovable(false)
						frame.text:Hide()
					end
					if frame2 then
						frame2:SetBackdropColor(1,1,1,0)
						frame2:EnableMouse(false)
						frame2:SetMovable(false)
						frame2.text:Hide()
					end
				end
				for name, module in core:IterateModules() do
					if module:IsEnabled() then
						if not core.db.profile.locked then
							if module.number then
								module.graphics:SetBackdropColor(1,1,1,1)
								module.graphics:EnableMouse(true)
								module.graphics:SetMovable(true)
								module.graphics.points[1]:Show()
								module.graphics.points[2]:Show()
								module.graphics.text:Show()
								module.number:SetBackdropColor(1,1,1,1)
								module.number:EnableMouse(true)
								module.number:SetMovable(true)
								module.number.points[1]:Show()
								module.number.combo:Show()
								module.number.text:Show()
							end
						else
							if module.number then
								module.graphics:EnableMouse(false)
								module.graphics:SetMovable(false)
								module.graphics:SetBackdropColor(1,1,1,0)
								module.graphics.points[1]:Hide()
								module.graphics.points[2]:Hide()
								module.graphics.text:Hide()
								module.number:SetBackdropColor(1,1,1,0)
								module.number:EnableMouse(false)
								module.number:SetMovable(false)
								module.number.points[1]:Hide()
								module.number.combo:Hide()
								module.number.text:Hide()
							end
						end
					end
				end
			end,
		},
	},
}
--create custom buff module
if CUSTOM then
	opts.args.core.args.Add = {
		type = 'input',
		name = L['Add a custom Module'],
		desc = L['Put in Here Module Name']	,
		arg = "Module",
		order = 8,
		get = function() return "" end,
		set = function(tmp, value) core.db.profile.custom[value] = value
			local customModule
			if core:GetModule(value,true) then
				customModule = core:GetModule(value)
			else
				customModule = core:NewModule(value, "AceConsole-3.0", "AceEvent-3.0")
			end
			customModule.abbrev = value
			customModule.MAX_POINTS = 5
			customModule.displayName = value
			customModule.custom = true
			customModule.delete = false
			CUSTOM:OnInitialize()
			customModule:Enable()
			core:createoptions()
		end,
	}
	opts.args.core.args.Remove = {
		type = 'multiselect',
		name = L['Remove a custom Module'],
		order = 10,
		get = function() return false end,
		set = function(tmp, key) core.db.profile.custom[key] = nil
			local customModule = core:GetModule(key)
			customModule.graphics:Hide()
			customModule.number:Hide()
			customModule.delete = true
			core.db.profile.modules[key] = nil
			opts.args[key] = nil
			opts.args.core.args[key.."toggle"] = nil
			opts.args.core.args[key.."count"]  = nil
			customModule:Disable()
			core:createoptions()
		end,
		values = core.db.profile.custom,
	}
end

--
--create other's custom buff/debuff timer
local OTHERS = LibStub("AceAddon-3.0"):GetAddon("FCP2_OTHERS",true)
if OTHERS then
	opts.args["others"] = {
		type = "group",
		name = L["Add a Target Timer"],
		order = 90,
		args = {
			Add = {
				type = 'input',
				name = L['Add a custom Module'],
				desc = L['Put in Here Module Name']	,
				arg = "OTHERS",
				order = 1,
				get = function() return "" end,
				set = function(tmp, value) core.db.profile.others.aura[value] = value
				end,
			},
			Remove = {
				type = 'multiselect',
				name = L['Remove a custom Module'],
				order = 2,
				get = function() return false end,
				set = function(tmp, key) core.db.profile.others.aura[key] = nil
				end,
				values = core.db.profile.others.aura,
			},
			timer = {
				type = "toggle",
				name = L["Show Timer Always"],
				desc = L["Toggle Show Timer Always"],
				get = function() return core.db.profile.others.timer end,
				set = function(tmp, v) core.db.profile.others.timer= v end,
				order = 3,
			},
			scale = {
				type = 'range',
				name = L["Scale"],
				desc = L["Set the scale of the icons."],
				get = function() return core.db.profile.others.scale end,
				set = function(tmp,v) core.db.profile.others.scale = v end,
				min = 0.1,
				max = 3.5,
				step = 0.01,
				order = 5,
			},
			orientation = {
				type = "select",
				name = L["Orientation"],
				desc = L["Select the orientation of the graphical display (horizontal or vertical)."],
				get = function() return core.db.profile.others.orientation end,
				set = function(tmp, v) core.db.profile.others.orientation= v end,
				values = directions,
				order = 10,
			},
		},
	}
	opts.args["self"] = {
		type = "group",
		name = L["Add a Self Timer"],
		order = 91,
		args = {
			Add = {
				type = 'input',
				name = L['Add a custom Module'],
				desc = L['Put in Here Module Name']	,
				arg = "OTHERS",
				order = 1,
				get = function() return "" end,
				set = function(tmp, value) core.db.profile.self.aura[value] = value
				end,
			},
			-- desc = {
				-- type = 'description',
				-- name = L["If you want to add Cooldown Reset skill, You can input like Reset Proc name@Resetted Skill name "],
				-- order = 2,
			-- },
			Remove = {
				type = 'multiselect',
				name = L['Remove a custom Module'],
				order = 3,
				get = function() return false end,
				set = function(tmp, key) core.db.profile.self.aura[key] = nil
				end,
				values = core.db.profile.self.aura,
			},
			timer = {
				type = "toggle",
				name = L["Show Timer Always"],
				desc = L["Toggle Show Timer Always"],
				get = function() return core.db.profile.self.timer end,
				set = function(tmp, v) core.db.profile.self.timer= v end,
				order = 4,
			},
			scale = {
				type = 'range',
				name = L["Scale"],
				desc = L["Set the scale of the icons."],
				get = function() return core.db.profile.self.scale end,
				set = function(tmp,v) core.db.profile.self.scale = v end,
				min = 0.1,
				max = 3.5,
				step = 0.01,
				order = 5,
			},
			orientation = {
				type = "select",
				name = L["Orientation"],
				desc = L["Select the orientation of the graphical display (horizontal or vertical)."],
				get = function() return core.db.profile.self.orientation end,
				set = function(tmp, v) core.db.profile.self.orientation= v end,
				values = directions,
				order = 10,
			},
		},
	}
end
--
function core:createoptions()
	if CUSTOM then
		for index, value in pairs(core.db.profile.custom) do
			if not core:GetModule(value).delete then
				opts.args.core.args[index.."count"] = {
					type = 'range',
					name = format(L["%s MAX Points"],index),
					desc = L["Set the Stack of Buff/Debuff."],
					arg = "count",
					order = 9,
					get = function() return core.db.profile.modules[value].MAX_POINTS end,
					set = function(tmp,v)
						core:GetModule(value).MAX_POINTS = v
						core.db.profile.modules[value].MAX_POINTS = v
					end,
					min = 3,
					max = 10,
					step = 1,
				}
			end
		end
	end
	--create enable/disable eachmodule
	for name, module in core:IterateModules() do
		if not module.delete then
				opts.args.core.args[name.."toggle"] = {
				type = "toggle",
				name = format(L["%s Module enabled"], module.displayName),
				desc = format(L["Select whether or not the %s module is enabled."], module.displayName),
				descStyle = "inline",
				width = "full",
				order = 2,
				get = function()
					return core.db.profile.modules[name].enabled
				end,
				set = function(info, value)
					core.db.profile.modules[name].enabled = value
					if value then
						module:Enable()
					else
						module:Disable()
					end
				end,
			}
		end
	end

	--
	local handlers = {}
	local i = 2

	for name, module in core:IterateModules() do
		handlers[name] = {
			Get = function(self, info, ...)
				if info.type == "color" then
					if info.arg == "textColor" then
						return unpack(core.db.profile.modules[name][info.arg])
					else
						return unpack(core.db.profile.modules[name].colors[info.arg])
					end
				else
					return core.db.profile.modules[name][info.arg]
				end
			end,
			Set = function(self, info, ...)
				if info.type == "color" then
					if info.arg == "textColor" then
						local color = core.db.profile.modules[name][info.arg]
						color[1], color[2], color[3] = ...
					else
						local color = core.db.profile.modules[name].colors[info.arg]
						color[1], color[2], color[3] = ...
					end
				else
					core.db.profile.modules[name][info.arg] = ...
				end
				core:UpdateSettings(name)
			end,
		}
		if not module.delete then
			opts.args[name] = {
				type = "group",
				name = module.displayName,
				handler = handlers[name],
				disabled = function() return not core.db.profile.modules[name].enabled end,
				order = i,
--
				args = {
					disablegraphics = {
						type = "toggle",
						name = L["Disable Graphics"],
						desc = L["Select whether or not to show this module's graphics."],
						descStyle = "inline",
						width = "full",
						arg = "disableGraphics",
						get = "Get",
						set = function(info, value)
							core.db.profile.modules[name].disableGraphics = value
							if value then
								module.graphics:Hide()
							else
								module.graphics:Show()
							end
						end,
						order = 1,
					},
					disablenumber = {
						type = "toggle",
						name = L["Disable Number"],
						desc = L["Select whether or not to show combo by number."],
						descStyle = "inline",
						width = "full",
						arg = "disableNumber",
						get = "Get",
						set = function(info, value)
							core.db.profile.modules[name].disableNumber = value
							if value then
								module.number:Hide()
							else
								module.number:Show()
							end
						end,
						order = 3,
					},
					graphics = {
						type = "group",
						name = L["%s Graphics"]:format(module.displayName),
						inline = true,
						order = 3,
						disabled = function() return core.db.profile.modules[name].disableGraphics end,
						args = {
							oneColor = {
								type = 'color',
								name = format(L["%d |4Point:Points;"], 1),
								desc = format(L["Set the color to be used when you have %d |4point:points;."], 1),
								arg = 1,
								get = "Get",
								set = "Set",
								order = 1,
							},
							icon = {
								type = "select",
								name = L["Icon"],
								desc = L["Select the icon to be used for these graphics."],
								arg = "icon",
								get = "Get",
								set = "Set",
								values = symbols,
								order = 106,
							},
							orientation = {
								type = "select",
								name = L["Orientation"],
								desc = L["Select the orientation of the graphical display (horizontal or vertical)."],
								arg = "orientation",
								get = "Get",
								set = "Set",
								values = orientations,
								order = 107,
							},
							strata = {
								type = 'select',
								name = L["Graphics Strata"],
								desc = L["Set the strata level of the graphics frame."],
								get = "Get",
								set = "Set",
								arg = "strata",
								values = stratas,
								order = 108,
							},
							alpha = {
								type = 'range',
								name = L["Icon Alpha"],
								desc = L["Set the alpha of the icons."],
								arg = "graphicsAlpha",
								get = "Get",
								set = "Set",
								min = 0.0,
								max = 1.0,
								step = 0.01,
								order = 109,
							},
							scale = {
								type = 'range',
								name = L["Scale"],
								desc = L["Set the scale of the icons."],
								arg = "scale",
								get = "Get",
								set = "Set",
								min = 0.1,
								max = 3.5,
								step = 0.01,
								order = 110,
							},
							spacing = {
								type = 'range',
								name = L["Icon Spacing"],
								desc = L["Set the spacing between the icons."],
								arg = "spacing",
								get = "Get",
								set = "Set",
								min = -2,
								max = 10,
								step = 1,
								order = 111,
							},
						},
					},
					number = {
						type = "group",
						name = L["%s Number"]:format(module.displayName),
						inline = true,
						order = 4,
						disabled = function() return core.db.profile.modules[name].disableNumber end,
						args = {
							oneColor = {
								type = 'color',
								name = format(L["%d |4Point:Points;"], 1),
								desc = format(L["Set the color to be used when you have %d |4point:points;."], 1),
								arg = "number"..1,
								get = "Get",
								set = "Set",
								order = 1,
							},
							strata = {
								type = 'select',
								name = L["Graphics Strata"],
								desc = L["Set the strata level of the graphics frame."],
								get = "Get",
								set = "Set",
								arg = "numberstrata",
								values = stratas,
								order = 108,
							},
							alpha = {
								type = 'range',
								name = L["Icon Alpha"],
								desc = L["Set the alpha of the icons."],
								arg = "numberAlpha",
								get = "Get",
								set = "Set",
								min = 0.0,
								max = 1.0,
								step = 0.01,
								order = 109,
							},
							scale = {
								type = 'range',
								name = L["Scale"],
								desc = L["Set the scale of the icons."],
								arg = "numberscale",
								get = "Get",
								set = "Set",
								min = 0.1,
								max = 3.5,
								step = 0.01,
								order = 110,
							},
						},
					},
				},
			}
--
			for j = 2, module.MAX_POINTS do
				opts.args[name].args.graphics.args["color"..j] = {
					type = 'color',
					name = format(L["%d |4Point:Points;"], j),
					desc = format(L["Set the color to be used when you have %d |4point:points;."], j),
					arg = j,
					get = "Get",
					set = "Set",
					order = j,
				}
			end

			for j = 2, module.MAX_POINTS do
				opts.args[name].args.number.args["color"..j] = {
					type = 'color',
					name = format(L["%d |4Point:Points;"], j),
					desc = format(L["Set the color to be used when you have %d |4point:points;."], j),
					arg = "number"..j,
					get = "Get",
					set = "Set",
					order = j,
				}
			end
			i = i + 1
		end
	end

	--add profile controls
	opts.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(core.db)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("FairComboPoints2", opts)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("FairComboPoints2", 800, 500)
end

core:createoptions()
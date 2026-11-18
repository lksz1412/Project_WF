function CML:LoadOptions()
	local L = CML.L
	local db = CML.db.profile
	local tmp

	local string_format = string.format
	local string_sub = string.sub
	local tonumber = tonumber

	local Dewdrop = AceLibrary:HasInstance("Dewdrop-2.0") and AceLibrary("Dewdrop-2.0")
	local Waterfall = AceLibrary:HasInstance("Waterfall-1.0") and AceLibrary("Waterfall-1.0")
	local SharedMedia = LibStub and LibStub:GetLibrary("LibSharedMedia-2.0", true)

	self.options = {
		type = "group",
		args = {
			color = {
				name = L["Color"],
				desc = L["Color options"],
				type = "group",
				args = {
					clock = {
						name = L["Clock"],
						desc = L["Color for the clock text"],
						type = "color",
						get = function()
							tmp = db.colorClock
							return tonumber(string_sub(tmp, 1, 2), 16) / 255, tonumber(string_sub(tmp, 3, 4), 16) / 255, tonumber(string_sub(tmp, 5, 6), 16) / 255
						end,
						set = function(r, g, b)
							db.colorClock = string_format("%02x%02x%02x", r * 255, g * 255, b * 255)
							self:UpdateColors()
						end
					},
					stats = {
						name = L["Stats"],
						desc = L["Color for the stats text"],
						type = "color",
						get = function()
							tmp = db.colorStats
							return tonumber(string_sub(tmp, 1, 2), 16) / 255, tonumber(string_sub(tmp, 3, 4), 16) / 255, tonumber(string_sub(tmp, 5, 6), 16) / 255
						end,
						set = function(r, g, b)
							db.colorStats = string_format("%02x%02x%02x", r * 255, g * 255, b * 255)
							self:UpdateColors()
						end
					},
					separators = {
						name = L["Separators"],
						desc = L["Color for the separators between stats"],
						type = "color",
						get = function()
							tmp = db.colorOther
							return tonumber(string_sub(tmp, 1, 2), 16) / 255, tonumber(string_sub(tmp, 3, 4), 16) / 255, tonumber(string_sub(tmp, 5, 6), 16) / 255
						end,
						set = function(r, g, b)
							db.colorOther = string_format("%02x%02x%02x", r * 255, g * 255, b * 255)
							self:UpdateColors()
						end
					}
				}
			},
			display = {
				name = L["Display"],
				desc = L["Miscellaneous display options"],
				type = "group",
				args = {
					align = {
						name = L["Horizontal Alignment"],
						desc = L["The horizontal alignment of the text."],
						type = "text",
						validate = {
							["CENTER"] = L["Center"],
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"]
						},
						get = function() return db.align end,
						set = function(v)
							db.align = v
							self:UpdatePosition()
						end
					},
					grow = {
						name = L["Growth Direction"],
						desc = L["The vertical direction to stack the text."],
						type = "text",
						validate = {
							["DOWN"] = L["Downward"],
							["UP"] = L["Upward"]
						},
						get = function() return db.grow end,
						set = function(v)
							db.grow = v
							self:UpdatePosition()
						end
					},
					fps = {
						name = L["Show Framerate"],
						desc = L["Include current framerate in the display."],
						type = "toggle",
						get = function() return db.fps end,
						set = function(v)
							db.fps = v
							self:UpdateScheduledEvents()
							self:UpdatePosition()
						end
					}
				}
			},
			font = {
				name = L["Font"],
				desc = L["Font options"],
				type = "group",
				args = {
					outline = {
						name = L["Outline"],
						desc = L["Show an outline around the text"],
						type = "text",
						validate = {
							["NONE"] = L["None"],
							["OUTLINE"] = L["Thin"],
							["THICKOUTLINE"] = L["Thick"]
						},
						get = function() return db.fontOutline end,
						set = function(v)
							db.fontOutline = v
							self:UpdateFonts()
						end
					},
					shadow = {
						name = L["Shadow"],
						desc = L["Show a shadow on the text"],
						type = "toggle",
						get = function() return db.fontShadow end,
						set = function(v)
							db.fontShadow = v
							self:UpdateFonts()
						end
					},
					size = {
						name = L["Size"],
						desc = L["Font size options"],
						type = "group",
						args = {
							clock = {
								name = L["Clock"],
								desc = L["Font size for the clock text"],
								type = "range",
								min = 8,
								max = 32,
								step = 1,
								bigStep = 4,
								get = function() return db.fontSizeClock end,
								set = function(v)
									db.fontSizeClock = v
									self:UpdateFonts()
								end
							},
							stats = {
								name = L["Stats"],
								desc = L["Font size for the stats text"],
								type = "range",
								min = 8,
								max = 32,
								step = 1,
								bigStep = 4,
								get = function() return db.fontSizeStats end,
								set = function(v)
									db.fontSizeStats = v
									self:UpdateFonts()
								end
							}
						}
					}
				}
			},
			frame = {
				name = L["Position"],
				desc = L["Frame position options"],
				type = "group",
				args = {
					pos = {
						name = L["Anchor Point"],
						desc = L["Anchor the frame to this point of the screen"],
						type = "text",
						validate = {
							["BOTTOM"] = L["Bottom Edge"],
							["BOTTOMLEFT"] = L["Bottom Left Corner"],
							["BOTTOMRIGHT"] = L["Bottom Right Corner"],
							["CENTER"] = L["Center"],
							["LEFT"] = L["Left Edge"],
							["TOP"] = L["Top Edge"],
							["TOPLEFT"] = L["Top Left Corner"],
							["TOPRIGHT"] = L["Top Right Corner"],
							["RIGHT"] = L["Right Edge"],
						},
						get = function() return db.pos end,
						set = function(v)
							db.pos = v
							self:UpdatePosition()
						end
					},
					X = {
						name = L["X Offset"],
						desc = L["Horizontal distance to place the frame relative to its anchor point"],
						type = "range",
						min = -800,
						max = 1600,
						step = 1,
						bigStep = 10,
						get = function() return db.posX end,
						set = function(v)
							db.posX = v
							self:UpdatePosition()
						end
					},
					Y = {
						name = L["Y Offset"],
						desc = L["Vertical distance to place the frame relative to its anchor point"],
						type = "range",
						min = -600,
						max = 1200,
						step = 1,
						bigStep = 10,
						get = function() return db.posY end,
						set = function(v)
							db.posY = v
							self:UpdatePosition()
						end
					}
				}
			},
		}
	}

	if SharedMedia then
		self.options.args.font.args.face = {
			name = L["Typeface"],
			desc = L["Typeface to use"],
			type = "text",
			validate = SharedMedia:List("font"),
			get = function() return db.fontFace end,
			set = function(v)
				db.fontFace = v
				self:UpdateFonts()
			end
		}
	end

	self:RegisterChatCommand("/cml", self.options, "CML")

	if Dewdrop then
		self.options.args.menu = {
			name = L["Dropdown Menu"],
			desc = L["Open a dropdown configuration menu"],
			type = "execute",
			guiHidden = true,
			wfHidden = true,
			func = function() Dewdrop:Open("CML", "children", function() Dewdrop:FeedAceOptionsTable(self.options) end) end
		}
	end

	if Waterfall then
		Waterfall:Register("CML", "aceOptions", self.options, "title", "CML", "treeLevels", 2, "colorR", 0.0, "colorG", 0.86, "colorB", 0.73)
		self.options.args.options = {
			name = L["GUI Menu"],
			desc = L["Open a GUI configuration window"],
			type = "execute",
			guiHidden = true,
			wfHidden = true,
			func = function() Waterfall:Open("CML") end
		}
	end
end
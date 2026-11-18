
ElkBuffBarsDB = {
	["profiles"] = {
		["Default"] = {
			["hidetrackingframe"] = false,
			["detachedTooltip"] = {
			},
			["showIcon"] = true,
			["showText"] = false,
			["bargroups"] = {
				{
					["id"] = 1,
					["barspacing"] = 0,
					["sorting"] = "timeleft",
					["anchortext"] = "BUFFS & TRACKING",
					["x"] = 1254.296752929688,
					["y"] = 1193.828247070313,
					["filter"] = {
						["type"] = {
							["BUFF"] = true,
						},
					},
					["target"] = "player",
					["bars"] = {
						["textBR"] = false,
						["textTRfont"] = "Friz Quadrata TT",
						["tooltipanchor"] = "default",
						["textBRfontsize"] = 14,
						["icon"] = "LEFT",
						["abbreviate_name"] = 0,
						["bgbar"] = true,
						["iconcount"] = true,
						["textTLalign"] = "LEFT",
						["textBLcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["textTR"] = "TIMELEFT",
						["bar"] = true,
						["textBL"] = false,
						["textBRfont"] = "Friz Quadrata TT",
						["textTL"] = "NAMERANKCOUNT",
						["barcolor"] = {
							0.3254901960784314, -- [1]
							0.3764705882352941, -- [2]
							0.4196078431372549, -- [3]
							1, -- [4]
						},
						["textTLfont"] = "Friz Quadrata TT",
						["iconcountfont"] = "Arial Narrow",
						["height"] = 20,
						["textTLcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["iconcountanchor"] = "CENTER",
						["textTRfontsize"] = 14,
						["timelessfull"] = false,
						["textTRcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["barright"] = false,
						["textTLfontsize"] = 14,
						["bartexture"] = "Minimalist",
						["textBLfont"] = "Friz Quadrata TT",
						["iconcountcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["alpha"] = 1,
						["iconcountfontsize"] = 14,
						["debufftypecolor"] = true,
						["textBLfontsize"] = 14,
						["width"] = 240,
						["textBRcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["timeformat"] = "CONDENSED",
						["padding"] = 1,
						["textBLalign"] = "LEFT",
						["barbgcolor"] = {
							0, -- [1]
							0, -- [2]
							0, -- [3]
							0.3899999856948853, -- [4]
						},
					},
					["growup"] = false,
					["anchorshown"] = false,
				}, -- [1]
				{
					["id"] = 2,
					["barspacing"] = 0,
					["sorting"] = "timeleft",
					["stickto"] = 1,
					["anchortext"] = "DEBUFFS",
					["growup"] = false,
					["filter"] = {
						["type"] = {
							["DEBUFF"] = true,
						},
					},
					["target"] = "player",
					["bars"] = {
						["textBR"] = false,
						["textTRfont"] = "Friz Quadrata TT",
						["tooltipanchor"] = "default",
						["textBRfontsize"] = 14,
						["icon"] = "LEFT",
						["abbreviate_name"] = 0,
						["bgbar"] = true,
						["iconcount"] = true,
						["textTLalign"] = "LEFT",
						["textBLcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["textTR"] = "TIMELEFT",
						["bar"] = true,
						["textBL"] = false,
						["textBRfont"] = "Friz Quadrata TT",
						["textTL"] = "NAMERANKCOUNT",
						["barcolor"] = {
							1, -- [1]
							0.1176470588235294, -- [2]
							0, -- [3]
							0.800000011920929, -- [4]
						},
						["textTLfont"] = "Friz Quadrata TT",
						["iconcountfont"] = "Arial Narrow",
						["height"] = 20,
						["textTLcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["iconcountanchor"] = "CENTER",
						["textTRfontsize"] = 14,
						["timelessfull"] = false,
						["textTRcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["barright"] = false,
						["textTLfontsize"] = 14,
						["bartexture"] = "Minimalist",
						["textBLfont"] = "Friz Quadrata TT",
						["iconcountcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["alpha"] = 1,
						["iconcountfontsize"] = 14,
						["debufftypecolor"] = true,
						["textBLfontsize"] = 14,
						["width"] = 260,
						["textBRcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["timeformat"] = "CONDENSED",
						["padding"] = 1,
						["textBLalign"] = "LEFT",
						["barbgcolor"] = {
							1, -- [1]
							0, -- [2]
							0, -- [3]
							0.3, -- [4]
						},
					},
					["stickside"] = "RIGHT",
					["anchorshown"] = false,
				}, -- [2]
				{
					["id"] = 3,
					["barspacing"] = 0,
					["sorting"] = "timeleft",
					["stickto"] = 2,
					["anchortext"] = "TENCH",
					["growup"] = false,
					["filter"] = {
						["type"] = {
							["TENCH"] = true,
						},
					},
					["target"] = "player",
					["bars"] = {
						["textBR"] = false,
						["textTRfont"] = "Friz Quadrata TT",
						["tooltipanchor"] = "default",
						["textBRfontsize"] = 14,
						["icon"] = "LEFT",
						["abbreviate_name"] = 0,
						["bgbar"] = true,
						["iconcount"] = true,
						["textTLalign"] = "LEFT",
						["textBLcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["textTR"] = "TIMELEFT",
						["bar"] = true,
						["textBL"] = false,
						["textBRfont"] = "Friz Quadrata TT",
						["textTL"] = "NAMERANKCOUNT",
						["barcolor"] = {
							0.5, -- [1]
							0, -- [2]
							0.5, -- [3]
							0.8, -- [4]
						},
						["textTLfont"] = "Friz Quadrata TT",
						["iconcountfont"] = "Arial Narrow",
						["height"] = 20,
						["textTLcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["iconcountanchor"] = "CENTER",
						["textTRfontsize"] = 14,
						["timelessfull"] = false,
						["textTRcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["barright"] = false,
						["textTLfontsize"] = 14,
						["bartexture"] = "Minimalist",
						["textBLfont"] = "Friz Quadrata TT",
						["iconcountcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["alpha"] = 1,
						["iconcountfontsize"] = 14,
						["debufftypecolor"] = true,
						["textBLfontsize"] = 14,
						["width"] = 260,
						["textBRcolor"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["timeformat"] = "CONDENSED",
						["padding"] = 1,
						["textBLalign"] = "LEFT",
						["barbgcolor"] = {
							0.5, -- [1]
							0, -- [2]
							0.5, -- [3]
							0.3, -- [4]
						},
					},
					["stickside"] = "",
					["anchorshown"] = false,
				}, -- [3]
			},
		},
	},
	["account"] = {
		["maxcharges"] = {
			["TENCH"] = {
			},
			["DEBUFF"] = {
			},
			["BUFF"] = {
				["수호자 "] = 4,
			},
		},
		["maxtimes"] = {
			["TENCH"] = {
			},
			["DEBUFF"] = {
			},
			["BUFF"] = {
				["무리의 우두머리 "] = 0,
				["가시 7 레벨"] = 3600,
				["수호자 "] = 0,
				["야생의 징표 8 레벨"] = 1800.001,
				["광포한 곰 변신 변신"] = 0,
				["명예 점수 없음 "] = 30,
			},
		},
		["build"] = "9056",
	},
}

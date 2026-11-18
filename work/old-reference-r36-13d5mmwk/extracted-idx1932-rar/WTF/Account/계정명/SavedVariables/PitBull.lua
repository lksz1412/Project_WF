
PitBullDB = {
	["namespaces"] = {
		["BarFader"] = {
			["profiles"] = {
				["Default"] = {
					["groups"] = {
						["target"] = {
							["disableHealth"] = false,
							["disablePower"] = false,
							["ignore"] = false,
							["smooth"] = true,
							["fade"] = true,
						},
						["player"] = {
							["smooth"] = true,
							["fade"] = true,
						},
						["pet"] = {
							["fade"] = false,
						},
					},
					["fadetime"] = 0.2,
				},
				["char/Buserker - 에이그윈"] = {
					["color"] = {
						0, -- [1]
						0.8, -- [2]
						0, -- [3]
						0.5, -- [4]
					},
					["groups"] = {
					},
					["fadetime"] = 0.5,
				},
			},
		},
		["Highlight"] = {
			["profiles"] = {
				["Default"] = {
					["target"] = {
						["showTarget"] = true,
						["hidden"] = true,
					},
					["player"] = {
						["showTarget"] = false,
					},
				},
			},
		},
		["AltAura"] = {
			["profiles"] = {
				["Default"] = {
					["pet"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["zoomAura"] = false,
					["targettarget"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["partypet"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["maintank"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["player"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["maintanktarget"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["focus"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["target"] = {
						["grow"] = 1,
						["frameHighlight"] = "All Debuffs",
						["debuffsize"] = 18,
						["buffsize"] = 22,
						["highlightStyle"] = "thinborder",
					},
					["raid"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
					["colors"] = {
						["buffs"] = {
							["nil"] = {
								0.01568627450980392, -- [1]
								0.01568627450980392, -- [2]
								0.0196078431372549, -- [3]
							},
							["Own"] = {
								[2] = 0.9921568627450981,
								[3] = 0.4235294117647059,
							},
						},
					},
					["party"] = {
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["hidden"] = true,
					},
				},
			},
		},
		["Spark"] = {
			["profiles"] = {
				["Default"] = {
					["color"] = {
						0.996078431372549, -- [1]
						0.996078431372549, -- [2]
						0.996078431372549, -- [3]
						0.300000011920929, -- [4]
					},
				},
				["char/Buserker - 에이그윈"] = {
					["color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						0.3, -- [4]
					},
					["enable"] = true,
				},
			},
		},
		["Layout-MetaLayout"] = {
			["profiles"] = {
				["Default"] = {
					["targettarget"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
					},
					["partypet"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
						},
					},
					["pet"] = {
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
							["Class"] = true,
							["Experience"] = true,
						},
						["texts"] = {
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["custom"] = "",
								["position"] = "frame-outright",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["custom"] = "",
								["position"] = "repBar-center",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "powerBar-left",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["custom"] = "",
								["position"] = "expBar-center",
								["style"] = "Standard",
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["style"] = "Custom",
								["position"] = "frame-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Name]",
								["position"] = "healthBar-left",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["custom"] = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
								["position"] = "healthBar-right",
								["style"] = "Absolute and Percent",
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["custom"] = "[CurMP]/[MaxMP]",
								["position"] = "powerBar-right",
								["style"] = "Absolute",
								["size"] = 1,
							},
						},
					},
					["party"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
						},
						["texts"] = {
							["Name"] = {
								["custom"] = "[Name:ClassColor] [AFKDND:Angle]",
								["style"] = "Class Colored",
							},
						},
					},
					["maintanktarget"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
					},
					["focus"] = {
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Name"] = true,
						},
					},
					["target"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
						["auraSide"] = "bottom",
						["heights"] = {
							["powerBar"] = 6,
							["healthBar"] = 8,
						},
						["texts"] = {
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["custom"] = "",
								["position"] = "frame-outright",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["custom"] = "",
								["position"] = "repBar-center",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "powerBar-right",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["custom"] = "",
								["position"] = "expBar-center",
								["style"] = "Standard",
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["style"] = "Custom",
								["position"] = "frame-outbottomleft",
								["custom"] = "",
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Name]",
								["position"] = "frame-outtopleft",
								["style"] = "Standard",
								["size"] = 2,
							},
							["Health"] = {
								["styleType"] = "health",
								["custom"] = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
								["position"] = "healthBar-right",
								["style"] = "Absolute and Percent",
								["size"] = 1.25,
							},
							["Power"] = {
								["styleType"] = "power",
								["custom"] = "[CurMP]/[MaxMP]",
								["position"] = "powerBar-left",
								["style"] = "Absolute",
								["size"] = 1,
							},
						},
					},
					["raid"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
						},
						["texts"] = {
							["Name"] = {
								["custom"] = "[Name:ClassColor] [AFKDND:Angle]",
								["style"] = "Class Colored",
							},
							["Health"] = {
								["custom"] = "[Status:SureHP:Short:PercentHP:Percent]",
								["style"] = "Absolute Short",
							},
						},
					},
					["maintank"] = {
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
							["Class"] = true,
							["Name"] = true,
						},
					},
					["player"] = {
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
							["Reputation"] = true,
							["Experience"] = true,
						},
						["heights"] = {
							["healthBar"] = 12,
						},
						["texts"] = {
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["custom"] = "",
								["position"] = "frame-outright",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["custom"] = "",
								["position"] = "repBar-center",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "powerBar-left",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["custom"] = "",
								["position"] = "expBar-center",
								["style"] = "Standard",
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["style"] = "Custom",
								["position"] = "frame-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Name]",
								["position"] = "healthBar-left",
								["style"] = "Standard",
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["custom"] = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
								["position"] = "healthBar-right",
								["style"] = "Absolute and Percent",
								["size"] = 1.25,
							},
							["Power"] = {
								["styleType"] = "power",
								["custom"] = "[~HasNoMP?FractionalMP]",
								["position"] = "powerBar-right",
								["style"] = "Absolute",
								["size"] = 1,
							},
						},
					},
				},
			},
		},
		["Layout-ABF"] = {
			["profiles"] = {
				["Default"] = {
					["mainassisttarget"] = {
						["classTextCustom"] = "",
						["classTextStyle"] = "Hide",
						["powerBarHeight"] = 1,
						["healthTextCustom"] = "[Status:PercentHP:Percent]",
						["powerTextStyle"] = "Hide",
						["powerTextCustom"] = "",
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
						["healthTextStyle"] = "Percent",
					},
					["pet"] = {
						["auraSide"] = "top",
						["shownTexts"] = {
							["Threat"] = true,
							["Experience"] = true,
							["Power"] = true,
							["Class"] = true,
							["Name"] = true,
							["Health"] = true,
						},
						["texts"] = {
							["Threat"] = {
								["styleType"] = "threat",
								["style"] = "Absolute Short",
								["position"] = "threatBar-right",
								["custom"] = "[Threat]/[MaxThreat]",
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["style"] = "Absolute",
								["position"] = "powerBar-right",
								["custom"] = "[CurMP]/[MaxMP]",
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["style"] = "Standard",
								["position"] = "powerBar-left",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["style"] = "Standard",
								["position"] = "healthBar-left",
								["custom"] = "[Name]",
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["position"] = "healthBar-right",
								["custom"] = "[CurHP]/[MaxHP]",
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["style"] = "Standard",
								["position"] = "frame-outright",
								["custom"] = "",
								["size"] = 1,
							},
						},
					},
					["partytarget"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
					},
					["targettarget"] = {
						["healthTextStyle"] = "Absolute Short",
						["auraSide"] = "top",
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
						["healthTextCustom"] = "[Status:SureHP:Short:PercentHP:Percent]",
					},
					["pettarget"] = {
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
					},
					["partypet"] = {
						["shownTexts"] = {
							["Threat"] = true,
							["Name"] = true,
							["Power"] = true,
							["Class"] = true,
							["Health"] = true,
						},
					},
					["maintank"] = {
						["classTextCustom"] = "",
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
							["Class"] = true,
							["Name"] = true,
						},
						["powerTextCustom"] = "",
						["threatTextCustom"] = "",
						["healthTextStyle"] = "Mini",
						["classTextStyle"] = "Hide",
						["healthTextCustom"] = "[CurHP:VeryShort]",
						["powerTextStyle"] = "Hide",
						["threatTextStyle"] = "Hide",
						["powerBarHeight"] = 1,
					},
					["party"] = {
						["shownTexts"] = {
							["Threat"] = true,
							["Name"] = true,
							["Power"] = true,
							["Class"] = true,
							["Health"] = true,
						},
						["auraSide"] = "top",
						["heights"] = {
							["healthBar"] = 6,
						},
						["texts"] = {
							["Class"] = {
								["size"] = 0.8500000000000001,
							},
							["Power"] = {
								["size"] = 0.9,
							},
						},
					},
					["mainassist"] = {
						["threatTextStyle"] = "Hide",
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
							["Class"] = true,
							["Name"] = true,
						},
						["powerTextCustom"] = "",
						["threatTextCustom"] = "",
						["healthTextStyle"] = "Mini",
						["healthTextCustom"] = "[CurHP:VeryShort]",
						["powerBarHeight"] = 1,
						["powerTextStyle"] = "Hide",
						["nameTextCustom"] = "[Name] [AFKDND:Angle]",
					},
					["focus"] = {
						["shownTexts"] = {
							["Threat"] = true,
							["Name"] = true,
							["Power"] = true,
							["Class"] = true,
							["Health"] = true,
						},
					},
					["target"] = {
						["shownTexts"] = {
							["Health"] = true,
							["Power"] = true,
							["Class"] = true,
							["Name"] = true,
							["Combo"] = true,
						},
						["nameTextSize"] = 2.05,
						["heights"] = {
							["powerBar"] = 6,
							["healthBar"] = 10,
							["blankSpace"] = 1,
						},
						["classTextPosition"] = "powerBar-right",
						["showBlankSpace"] = true,
						["nameTextCustom"] = "[Name:ClassColor] [AFKDND:Angle]",
						["powerTextSize"] = 1.25,
						["powerBarHeight"] = 2,
						["healthTextSize"] = 1.7,
						["auraSide"] = "bottom",
						["healthTextStyle"] = "Absolute and Percent",
						["texts"] = {
							["Threat"] = {
								["styleType"] = "threat",
								["style"] = "Absolute Short",
								["position"] = "threatBar-right",
								["custom"] = "[Threat]/[MaxThreat]",
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["style"] = "Absolute",
								["position"] = "powerBar-left",
								["custom"] = "[CurMP]/[MaxMP]",
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["style"] = "Standard",
								["position"] = "powerBar-right",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["style"] = "Standard",
								["position"] = "frame-outtopleft",
								["custom"] = "[Name] [AFKDND:Angle]",
								["size"] = 1.65,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["position"] = "healthBar-right",
								["custom"] = "[CurHP]/[MaxHP]",
								["size"] = 1.5,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["style"] = "Standard",
								["position"] = "frame-outright",
								["custom"] = "",
								["size"] = 1,
							},
						},
						["powerTextPosition"] = "powerBar-left",
						["healthTextCustom"] = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
						["healthBarHeight"] = 12,
						["nameTextStyle"] = "Class Colored",
						["nameTextPosition"] = "frame-topleft",
						["classTextSize"] = 1.3,
					},
					["raid"] = {
						["classTextCustom"] = "",
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
							["Class"] = true,
							["Name"] = true,
						},
						["powerTextCustom"] = "",
						["threatTextCustom"] = "",
						["healthTextStyle"] = "Mini",
						["classTextStyle"] = "Hide",
						["healthTextCustom"] = "[CurHP:VeryShort]",
						["powerTextStyle"] = "Hide",
						["threatTextStyle"] = "Hide",
						["powerBarHeight"] = 1,
					},
					["maintanktarget"] = {
						["classTextCustom"] = "",
						["classTextStyle"] = "Hide",
						["powerBarHeight"] = 1,
						["healthTextCustom"] = "[Status:PercentHP:Percent]",
						["powerTextStyle"] = "Hide",
						["powerTextCustom"] = "",
						["shownTexts"] = {
							["Name"] = true,
							["Class"] = true,
							["Health"] = true,
							["Power"] = true,
						},
						["healthTextStyle"] = "Percent",
					},
					["player"] = {
						["classTextCustom"] = "",
						["powerBarHeight"] = 2,
						["healthTextPosition"] = "healthBar-left",
						["texts"] = {
							["Threat"] = {
								["styleType"] = "threat",
								["style"] = "Absolute Short",
								["position"] = "threatBar-right",
								["custom"] = "[Threat]/[MaxThreat]",
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["style"] = "Absolute",
								["position"] = "powerBar-right",
								["custom"] = "[CurMP]/[MaxMP]",
								["size"] = 0.8,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["style"] = "Custom",
								["position"] = "healthBar-right",
								["custom"] = "[Level]",
								["size"] = 1.6,
							},
							["Name"] = {
								["styleType"] = "name",
								["style"] = "Standard",
								["position"] = "powerBar-left",
								["custom"] = "[Name]",
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["style"] = "Absolute and Percent",
								["position"] = "healthBar-left",
								["custom"] = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
								["size"] = 1.5,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["style"] = "Standard",
								["position"] = "frame-outright",
								["custom"] = "",
								["size"] = 1,
							},
						},
						["shownTexts"] = {
							["Threat"] = true,
							["Health"] = true,
							["Power"] = true,
							["Reputation"] = true,
							["Class"] = true,
							["Experience"] = true,
						},
						["healthTextStyle"] = "Absolute and Percent",
						["classTextStyle"] = "Hide",
						["heights"] = {
							["healthBar"] = 12,
						},
						["healthTextCustom"] = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
						["healthBarHeight"] = 12,
						["nameTextStyle"] = "Hide",
						["healthTextSize"] = 1.65,
						["nameTextCustom"] = "",
					},
				},
			},
		},
		["MasterLooterIcon"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["player"] = {
						["disable"] = false,
					},
				},
				["Default"] = {
					["raid"] = {
						["disable"] = true,
					},
				},
			},
		},
		["Health"] = {
			["profiles"] = {
				["Default"] = {
					["mainassisttarget"] = {
						["hostilityColorNPCs"] = true,
						["classColor"] = false,
						["hostilityColor"] = true,
					},
					["mainassist"] = {
						["classColor"] = false,
						["customColors"] = {
							0.4, -- [1]
							0.4, -- [2]
							0.7019607843137254, -- [3]
						},
						["customColor"] = true,
					},
					["maintank"] = {
						["classColor"] = false,
						["customColors"] = {
							0.4, -- [1]
							0.4, -- [2]
							0.7019607843137254, -- [3]
						},
						["customColor"] = true,
					},
					["maintanktarget"] = {
						["hostilityColorNPCs"] = true,
						["classColor"] = false,
						["hostilityColor"] = true,
					},
					["raid"] = {
						["classColor"] = false,
						["customColors"] = {
							0.4, -- [1]
							0.4, -- [2]
							0.7019607843137254, -- [3]
						},
						["customColor"] = true,
					},
				},
			},
		},
		["CombatText"] = {
			["profiles"] = {
				["Default"] = {
					["groups"] = {
						["player"] = {
							["fontheight"] = 16,
						},
						["focus"] = {
							["ignore"] = true,
						},
						["target"] = {
							["fontheight"] = 16,
						},
						["maintank"] = {
							["ignore"] = true,
						},
						["partypet"] = {
							["ignore"] = true,
						},
					},
				},
				["char/Buserker - 에이그윈"] = {
					["groups"] = {
						["target"] = {
							["fontheight"] = 13,
						},
						["player"] = {
							["fontheight"] = 13,
						},
					},
				},
			},
		},
		["ReadyCheckIcon"] = {
			["profiles"] = {
				["Default"] = {
					["maintank"] = {
						["disable"] = true,
					},
					["targettargettarget"] = {
						["disable"] = true,
					},
					["focus"] = {
						["disable"] = true,
					},
					["partytarget"] = {
						["disable"] = true,
					},
					["focustarget"] = {
						["disable"] = true,
					},
					["targettarget"] = {
						["disable"] = true,
					},
					["maintanktarget"] = {
						["disable"] = true,
					},
				},
			},
		},
		["MetaLayout"] = {
			["profiles"] = {
				["Default"] = {
					["targettargettarget"] = {
						["bars"] = {
							["healthBar"] = {
								["height"] = 12,
							},
							["powerBar"] = {
								["height"] = 2,
							},
						},
						["texts"] = {
							["Power"] = {
								["custom"] = "[if HasMP then FractionalMP]",
								["hidden"] = true,
							},
							["Class"] = {
								["custom"] = "[Classification] [Level:DifficultyColor] [(if (IsPlayer or (IsEnemy and not IsPet)) then Class):ClassColor] [DruidForm:Paren] [SmartRace]",
								["hidden"] = true,
							},
							["Cast"] = {
								["custom"] = "[Alpha((-CastStopDuration or 0) + 1) CastStopMessage or (CastName ' ' CastTarget:Paren)]",
								["hidden"] = true,
							},
							["Name"] = {
								["custom"] = "[Name] [(AFK or DND):Angle]",
								["position"] = "healthBar-center",
							},
							["Health"] = {
								["custom"] = "[Status or (if IsFriend then MissingHP:Hide(0):Short:Color('ff7f7f') else FractionalHP(known=true):Short or PercentHP:Percent)]",
								["hidden"] = true,
							},
							["CastTime"] = {
								["custom"] = "[if not CastStopDuration then Concatenate('+', CastDelay:Round(1):Hide(0)):Red ' ' [CastEndDuration >= 0 ? '%.1f':Format(CastEndDuration)]]",
								["hidden"] = true,
							},
						},
					},
					["partytarget"] = {
						["bars"] = {
							["healthBar"] = {
								["height"] = 6,
							},
							["powerBar"] = {
								["height"] = 1,
							},
						},
						["texts"] = {
							["Threat"] = {
								["hidden"] = true,
							},
							["Power"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Health"] = {
								["custom"] = "[IsFriend?Status:MissingHP:HideZero:Short:Color(ff7f7f)!Status:SmartHP:Short]",
								["position"] = "frame-intopright",
								["hidden"] = true,
							},
							["combatText"] = {
								["position"] = "frame-inbottom",
							},
							["Name"] = {
								["custom"] = "[Name:ClassColor] [(AFK or DND):Angle]",
								["position"] = "healthBar-right",
								["style"] = "Custom",
								["size"] = 1.2,
							},
						},
					},
					["focustarget"] = {
						["bars"] = {
							["healthBar"] = {
								["height"] = 12,
							},
							["powerBar"] = {
								["height"] = 3,
							},
						},
						["texts"] = {
							["Power"] = {
								["hidden"] = true,
							},
							["CastTime"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Cast"] = {
								["hidden"] = true,
							},
							["Name"] = {
								["custom"] = "[IsFriend ? Name:White] [IsEnemy ? Name:Red]",
								["position"] = "healthBar-center",
								["style"] = "Custom",
								["size"] = 1.2,
							},
							["combatText"] = {
								["position"] = "frame-intop",
							},
							["Health"] = {
								["hidden"] = true,
							},
						},
					},
					["pet"] = {
						["auraSide"] = "top",
						["bars"] = {
							["healthBar"] = {
								["height"] = 12,
							},
							["blankSpace"] = {
								["height"] = 5,
							},
						},
						["icons"] = {
							["happinessIcon"] = {
								["size"] = 1.5,
								["position"] = "frame-outleft",
							},
						},
						["texts"] = {
							["퍼센트"] = {
								["styleType"] = "health",
								["custom"] = "[IsFriend?Status:MissingHP:HideZero:Short:Color(ff7f7f)!Status:SmartHP:Short]",
								["position"] = "healthBar-right",
								["style"] = "Smart",
								["hidden"] = false,
								["size"] = 1,
							},
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["hidden"] = true,
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["custom"] = "[CurMP]/[MaxMP]",
								["position"] = "powerBar-right",
								["style"] = "Absolute",
								["hidden"] = true,
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["hidden"] = true,
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "powerBar-left",
								["style"] = "Standard",
								["hidden"] = true,
								["size"] = 1,
							},
							["DruidMana"] = {
								["styleType"] = "druidMana",
								["custom"] = "[~IsMana ? FractionalDruidMP]",
								["position"] = "druidManaBar-right",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1,
							},
							["Cast"] = {
								["styleType"] = "cast",
								["custom"] = "[CastName] [CastTarget:Paren]",
								["position"] = "castBar-left",
								["style"] = "Standard Name",
								["hidden"] = true,
								["size"] = 1,
							},
							["CastTime"] = {
								["styleType"] = "cast",
								["custom"] = "[CastDelay:Round] [CastEndTime:Sub([CurrentTime]):Round:HideLess(0)]",
								["position"] = "castBar-right",
								["style"] = "Standard Time",
								["hidden"] = true,
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Name] [(AFK or DND):Angle]",
								["position"] = "healthBar-left",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1.1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = true,
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["style"] = "Standard",
								["position"] = "frame-outright",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Level"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [(if (IsPlayer or (IsEnemy and not IsPet)) then Class):ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "frame-center",
								["style"] = "Standard",
								["hidden"] = true,
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Custom",
								["position"] = "healthBar-right",
								["custom"] = "[IsMouseOver?HappyNum][IsMouseOver?PercentXP:Percent:Paren]",
								["hidden"] = false,
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["custom"] = "[CurHP]/[MaxHP]",
								["position"] = "frame-center",
								["hidden"] = true,
								["size"] = 1,
							},
						},
					},
					["partypet"] = {
						["bars"] = {
							["powerBar"] = {
								["height"] = 1,
							},
						},
						["texts"] = {
							["Threat"] = {
								["hidden"] = true,
							},
							["Power"] = {
								["hidden"] = true,
							},
							["CastTime"] = {
								["custom"] = "[if not CastStopDuration then Concatenate('+', CastDelay:Round(1):Hide(0)):Red ' ' [CastEndDuration >= 0 ? '%.1f':Format(CastEndDuration)]]",
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Cast"] = {
								["custom"] = "[Alpha((-CastStopDuration or 0) + 1) CastStopMessage or (CastName ' ' CastTarget:Paren)]",
							},
							["Health"] = {
								["position"] = "healthBar-left",
								["hidden"] = true,
							},
							["combatText"] = {
								["position"] = "frame-inbottom",
							},
							["Name"] = {
								["custom"] = "[Name:ClassColor] [(AFK or DND):Angle]",
								["position"] = "healthBar-right",
								["style"] = "Custom",
								["size"] = 1.2,
							},
						},
					},
					["party"] = {
						["debuffSide"] = "topright",
						["bars"] = {
							["healthBar"] = {
								["position"] = 3,
								["height"] = 6,
							},
							["portrait"] = {
								["side"] = "right",
							},
							["expBar"] = {
								["position"] = 6,
							},
							["blankSpace"] = {
								["position"] = 2,
								["height"] = 1,
							},
							["threatBar"] = {
								["position"] = 8,
							},
							["druidManaBar"] = {
								["position"] = 5,
							},
							["powerBar"] = {
								["position"] = 4,
								["height"] = 1,
							},
							["repBar"] = {
								["position"] = 7,
							},
						},
						["texts"] = {
							["Threat"] = {
								["hidden"] = true,
							},
							["Power"] = {
								["custom"] = "[if IsMouseOver then\n    FractionalMP\nend]",
								["position"] = "frame-outbottomleft",
								["style"] = "Custom",
							},
							["CastTime"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["position"] = "frame-outleft",
								["hidden"] = true,
							},
							["Cast"] = {
								["hidden"] = true,
							},
							["Name"] = {
								["custom"] = "[Level] [Name:ClassColor] [(AFK or DND):Angle]",
								["position"] = "healthBar-right",
								["style"] = "Long",
								["size"] = 1.2,
							},
							["combatText"] = {
								["position"] = "frame-inbottom",
							},
							["Health"] = {
								["custom"] = "[Status or FractionalHP(known=true) or PercentHP:Percent]",
								["position"] = "healthBar-left",
								["style"] = "Absolute",
							},
						},
					},
					["player"] = {
						["debuffSide"] = "top",
						["bars"] = {
							["healthBar"] = {
								["height"] = 12,
							},
							["portrait"] = {
								["height"] = 12,
							},
							["blankSpace"] = {
								["position"] = 3,
								["height"] = 1,
							},
							["powerBar"] = {
								["position"] = 6,
								["height"] = 3,
							},
							["repBar"] = {
								["position"] = 8,
							},
						},
						["buffSide"] = "top",
						["icons"] = {
							["restIcon"] = {
								["position"] = "frame-edgetopright",
							},
							["totemTimersFrame"] = {
								["position"] = "frame-outleft",
							},
							["raidTargetIcon"] = {
								["size"] = 1.5,
							},
							["readyCheckIcon"] = {
								["position"] = "frame-edgebottomleft",
							},
							["combatIcon"] = {
								["position"] = "frame-edgebottomright",
							},
						},
						["texts"] = {
							["퍼센트"] = {
								["styleType"] = "health",
								["custom"] = "[Status:PercentHP:Percent]",
								["position"] = "frame-inbottomright",
								["style"] = "Percent",
								["hidden"] = true,
								["size"] = 1,
							},
							["Threat"] = {
								["styleType"] = "threat",
								["style"] = "Absolute Short",
								["position"] = "healthBar-center",
								["custom"] = "[Threat]/[MaxThreat]",
								["hidden"] = true,
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["Health"] = {
									["style"] = "Informational",
								},
								["position"] = "frame-outbottomright",
								["custom"] = "[if HasMP then FractionalMP]",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1.1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["hidden"] = true,
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["style"] = "Custom",
								["position"] = "frame-outbottomleft",
								["custom"] = "[Level] [PvPRank] [Name:ClassColor DruidForm:Paren]  [RaidGroup:Paren]",
								["hidden"] = false,
								["size"] = 1.5,
							},
							["DruidMana"] = {
								["styleType"] = "druidMana",
								["custom"] = "[~IsMana ? FractionalDruidMP]",
								["position"] = "druidManaBar-right",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1,
							},
							["Cast"] = {
								["styleType"] = "cast",
								["custom"] = "[Alpha((-CastStopDuration or 0) + 1) CastStopMessage or (CastName ' ' CastTarget:Paren)]",
								["position"] = "healthBar-left",
								["style"] = "Standard Name",
								["hidden"] = true,
								["size"] = 1,
							},
							["CastTime"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [(if (IsPlayer or (IsEnemy and not IsPet)) then Class):ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "castBar-right",
								["style"] = "Standard",
								["hidden"] = true,
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Level] [Name:ClassColor] [AFKDND:Angle]",
								["position"] = "frame-outbottom",
								["style"] = "Long",
								["hidden"] = true,
								["size"] = 1.65,
							},
							["combatText"] = {
								["styleType"] = "none",
								["style"] = "Custom",
								["position"] = "frame-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["custom"] = "",
								["position"] = "hide",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1,
							},
							["Level"] = {
								["styleType"] = "name",
								["style"] = "Long w/ Druid form",
								["position"] = "frame-outleft",
								["custom"] = "[Level] [Name:ClassColor] [DruidForm:Paren] [(AFK or DND):Angle]",
								["hidden"] = true,
								["size"] = 1.8,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["hidden"] = true,
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["custom"] = "[Status or FractionalHP(known=true) or PercentHP:Percent]",
								["position"] = "healthBar-right",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1.2,
							},
						},
					},
					["maintanktarget"] = {
						["bars"] = {
							["powerBar"] = {
								["height"] = 2,
							},
						},
						["texts"] = {
							["Threat"] = {
								["hidden"] = true,
							},
							["Power"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Name"] = {
								["custom"] = "[Name:ClassColor] [AFKDND:Angle]",
								["position"] = "frame-intopleft",
								["style"] = "Class Colored",
								["size"] = 1.2,
							},
							["combatText"] = {
								["position"] = "frame-inbottom",
							},
							["Health"] = {
								["custom"] = "[Status:SureHP:PercentHP:Percent]",
								["position"] = "frame-inright",
								["style"] = "Absolute",
								["hidden"] = true,
							},
						},
					},
					["focus"] = {
						["auraSide"] = "top",
						["bars"] = {
							["portrait"] = {
								["side"] = "right",
							},
							["healthBar"] = {
								["height"] = 12,
							},
							["powerBar"] = {
								["height"] = 3,
							},
						},
						["icons"] = {
							["raidTargetIcon"] = {
								["position"] = "frame-edgetopleft",
								["size"] = 1.5,
							},
						},
						["texts"] = {
							["Threat"] = {
								["hidden"] = true,
							},
							["Combo"] = {
								["position"] = "frame-outlefttop",
							},
							["CastTime"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Cast"] = {
								["hidden"] = true,
							},
							["Name"] = {
								["custom"] = "[(AFK or DND):Angle] [IsFriend ? Name:White] [IsEnemy ? Name:Red] [Level:DifficultyColor]",
								["position"] = "healthBar-right",
								["style"] = "Custom",
								["size"] = 1.25,
							},
							["combatText"] = {
								["position"] = "frame-outbottom",
							},
							["Level"] = {
								["position"] = "frame-intop",
							},
							["Health"] = {
								["custom"] = "[Status or (IsFriend ? FractionalHP) (IsEnemy ? FractionalHP:Red)] [PercentHP:Percent]",
								["position"] = "healthBar-left",
								["style"] = "Custom",
							},
							["Power"] = {
								["hidden"] = true,
							},
						},
					},
					["target"] = {
						["comboSide"] = "outright",
						["buffSide"] = "top",
						["debuffSide"] = "top",
						["bars"] = {
							["healthBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 1,
								["height"] = 12,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["portrait"] = {
								["deficit"] = false,
								["position"] = 4,
								["height"] = 8,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["castBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 8,
								["height"] = 2,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["powerBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 6,
								["height"] = 3,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["expBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 5,
								["height"] = 2,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["blankSpace"] = {
								["position"] = 3,
								["deficit"] = false,
								["side"] = "center",
								["reverse"] = false,
								["height"] = 1,
								["hidden"] = true,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["threatBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 7,
								["height"] = 2,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["druidManaBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 2,
								["height"] = 1,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["fullBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 9,
								["height"] = 5,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
							["repBar"] = {
								["deficit"] = false,
								["side"] = "center",
								["position"] = 10,
								["height"] = 2,
								["reverse"] = false,
								["alpha"] = 1,
								["bgAlpha"] = 1,
							},
						},
						["auraSide"] = "top",
						["icons"] = {
							["raidTargetIcon"] = {
								["position"] = "frame-edgetopleft",
								["size"] = 1.5,
							},
						},
						["texts"] = {
							["퍼센트"] = {
								["styleType"] = "health",
								["custom"] = "[Status or (FractionalHP:Short ' || ' PercentHP:Percent)]",
								["position"] = "powerBar-left",
								["style"] = "Absolute and Percent",
								["hidden"] = true,
								["size"] = 1.15,
							},
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["hidden"] = false,
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["Health"] = {
									["style"] = "Informational",
								},
								["position"] = "frame-outbottomleft",
								["style"] = "Absolute",
								["custom"] = "[if HasMP then FractionalMP]",
								["hidden"] = false,
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[SmartRace] [(if TalentSpec then\n    TalentTree\nend) Classification (if IsPlayer then\n    Class\nend):White]",
								["position"] = "healthBar-right",
								["style"] = "Custom",
								["hidden"] = false,
								["size"] = 1.2,
							},
							["DruidMana"] = {
								["styleType"] = "druidMana",
								["custom"] = "[~IsMana ? FractionalDruidMP]",
								["position"] = "druidManaBar-right",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1,
							},
							["Cast"] = {
								["styleType"] = "none",
								["custom"] = "[TalentSpec ? Text([TalentTree] ([TalentSpec]))]",
								["position"] = "frame-outbottom",
								["style"] = "Custom",
								["hidden"] = true,
								["size"] = 1.15,
							},
							["CastTime"] = {
								["styleType"] = "cast",
								["custom"] = "[CastDelay:Round] [CastEndTime:Sub([CurrentTime]):Round:HideLess(0)]",
								["position"] = "castBar-right",
								["style"] = "Standard Time",
								["hidden"] = true,
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[(IsFriend ? Name:ClassColor) (IsEnemy ? Name:Red) (AFK or DND):Angle] [Level:DifficultyColor]",
								["position"] = "frame-outbottomright",
								["style"] = "Custom",
								["hidden"] = false,
								["size"] = 1.5,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-intopleft",
								["style"] = "Custom",
								["hidden"] = false,
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["custom"] = "[Combos:Hide(0)]",
								["position"] = "frame-outrighttop",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1.25,
							},
							["Level"] = {
								["styleType"] = "name",
								["style"] = "Custom",
								["position"] = "healthBar-outleft",
								["custom"] = "[Classification] [SmartRace]",
								["hidden"] = true,
								["size"] = 1.1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["custom"] = "[Status or (IsFriend ? FractionalHP) (IsEnemy ? FractionalHP:Red)] [PercentHP:Percent]",
								["position"] = "healthBar-left",
								["style"] = "Custom",
								["hidden"] = false,
								["size"] = 1.2,
							},
						},
					},
					["raid"] = {
						["debuffSide"] = "bottomright",
						["buffSide"] = "topright",
						["bars"] = {
							["healthBar"] = {
								["height"] = 7,
							},
							["powerBar"] = {
								["height"] = 1,
							},
						},
						["texts"] = {
							["퍼센트"] = {
								["position"] = "healthBar-right",
							},
							["Threat"] = {
								["hidden"] = true,
							},
							["Power"] = {
								["position"] = "frame-inbottomright",
								["hidden"] = true,
							},
							["CastTime"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Cast"] = {
								["hidden"] = true,
							},
							["Name"] = {
								["custom"] = "[Name:ClassColor] [(AFK or DND):Angle]",
								["position"] = "healthBar-center",
								["style"] = "Class Colored",
								["size"] = 1.25,
							},
							["combatText"] = {
								["position"] = "frame-inright",
							},
							["Health"] = {
								["custom"] = "[Status or (if IsFriend then MissingHP:Hide(0):Short:Color('ff7f7f') else FractionalHP(known=true):Short or PercentHP:Percent)]",
								["position"] = "frame-center",
								["hidden"] = true,
							},
						},
					},
					["targettarget"] = {
						["bars"] = {
							["healthBar"] = {
								["height"] = 12,
							},
							["powerBar"] = {
								["height"] = 2,
							},
						},
						["texts"] = {
							["Power"] = {
								["hidden"] = true,
							},
							["CastTime"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Cast"] = {
								["hidden"] = true,
							},
							["Health"] = {
								["position"] = "frame-inright",
								["hidden"] = true,
							},
							["combatText"] = {
								["position"] = "frame-intop",
							},
							["Level"] = {
								["position"] = "frame-inbottom",
							},
							["Name"] = {
								["style"] = "Custom",
								["position"] = "healthBar-center",
								["custom"] = "[IsFriend ? Name:White] [IsEnemy ? Name:Red]",
								["size"] = 1.2,
							},
						},
					},
					["maintank"] = {
						["bars"] = {
							["powerBar"] = {
								["height"] = 2,
							},
						},
						["texts"] = {
							["Threat"] = {
								["hidden"] = true,
							},
							["Power"] = {
								["hidden"] = true,
							},
							["Class"] = {
								["hidden"] = true,
							},
							["Health"] = {
								["custom"] = "[Status:SureHP:PercentHP:Percent]",
								["position"] = "frame-inright",
								["style"] = "Absolute",
								["hidden"] = true,
							},
							["combatText"] = {
								["position"] = "frame-inbottom",
							},
							["Name"] = {
								["style"] = "Class Colored",
								["position"] = "frame-intopleft",
								["custom"] = "[Name:ClassColor] [AFKDND:Angle]",
								["size"] = 1.2,
							},
						},
					},
				},
				["char/Buserker - 에이그윈"] = {
					["target"] = {
						["comboSide"] = "inbottomright",
						["druidManaBarHeight"] = 0.25,
						["bars"] = {
							["healthBar"] = {
								["height"] = 5,
								["position"] = 2,
							},
							["castBar"] = {
								["height"] = 2,
								["position"] = 8,
							},
							["portrait"] = {
								["height"] = 2,
								["side"] = "right",
								["position"] = 1,
							},
							["expBar"] = {
								["height"] = 2,
								["position"] = 4,
							},
							["blankSpace"] = {
								["height"] = 2,
								["hidden"] = true,
								["position"] = 7,
							},
							["threatBar"] = {
								["height"] = 2,
								["position"] = 6,
							},
							["powerBar"] = {
								["height"] = 4,
								["position"] = 3,
							},
							["fullBar"] = {
								["height"] = 5,
								["position"] = 9,
							},
							["repBar"] = {
								["height"] = 2,
								["position"] = 5,
							},
						},
						["debuffSide"] = "right",
						["buffSide"] = "bottom",
						["auraSide"] = "right",
						["icons"] = {
							["restIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgebottomleft",
							},
							["masterIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopleft",
							},
							["leaderIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopleft",
							},
							["pvpIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopright",
							},
							["raidTargetIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetop",
							},
							["voiceIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopright",
							},
							["combatIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgebottomleft",
							},
						},
						["texts"] = {
							["퍼센트"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = true,
								["size"] = 1,
							},
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["hidden"] = false,
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["custom"] = "[CurMP]/[MaxMP]",
								["position"] = "powerBar-right",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "powerBar-left",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = false,
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Name]",
								["position"] = "healthBar-left",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1,
							},
							["Level"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = true,
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["style"] = "Standard",
								["position"] = "frame-outright",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["style"] = "Informational",
								["position"] = "healthBar-right",
								["custom"] = "[CurHP]/[MaxHP]",
								["hidden"] = false,
								["size"] = 1,
							},
						},
					},
					["player"] = {
						["druidManaBarHeight"] = 0.25,
						["buffSide"] = "bottom",
						["debuffSide"] = "right",
						["auraSide"] = "bottom",
						["bars"] = {
							["healthBar"] = {
								["height"] = 5,
								["position"] = 2,
							},
							["castBar"] = {
								["height"] = 2,
								["position"] = 8,
							},
							["portrait"] = {
								["height"] = 2,
								["side"] = "left",
								["position"] = 1,
							},
							["expBar"] = {
								["height"] = 2,
								["position"] = 4,
							},
							["blankSpace"] = {
								["height"] = 2,
								["hidden"] = true,
								["position"] = 7,
							},
							["threatBar"] = {
								["height"] = 2,
								["position"] = 6,
							},
							["powerBar"] = {
								["height"] = 4,
								["position"] = 3,
							},
							["fullBar"] = {
								["height"] = 5,
								["position"] = 9,
							},
							["repBar"] = {
								["height"] = 2,
								["position"] = 5,
							},
						},
						["icons"] = {
							["restIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgebottomleft",
							},
							["masterIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopleft",
							},
							["leaderIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopleft",
							},
							["pvpIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopright",
							},
							["raidTargetIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetop",
							},
							["voiceIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopright",
							},
							["combatIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgebottomleft",
							},
						},
						["texts"] = {
							["퍼센트"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = true,
								["size"] = 1,
							},
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["hidden"] = false,
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["custom"] = "[CurMP]/[MaxMP]",
								["position"] = "powerBar-right",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "powerBar-left",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = false,
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Name]",
								["position"] = "healthBar-left",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1,
							},
							["Level"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = true,
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["style"] = "Standard",
								["position"] = "frame-outright",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["style"] = "Informational",
								["position"] = "healthBar-right",
								["custom"] = "[CurHP]/[MaxHP]",
								["hidden"] = false,
								["size"] = 1,
							},
						},
					},
					["pet"] = {
						["druidManaBarHeight"] = 0.25,
						["buffSide"] = "bottom",
						["debuffSide"] = "right",
						["auraSide"] = "bottom",
						["bars"] = {
							["healthBar"] = {
								["height"] = 5,
								["position"] = 2,
							},
							["castBar"] = {
								["height"] = 2,
								["position"] = 8,
							},
							["portrait"] = {
								["height"] = 2,
								["side"] = "left",
								["position"] = 1,
							},
							["expBar"] = {
								["height"] = 2,
								["position"] = 4,
							},
							["blankSpace"] = {
								["height"] = 2,
								["hidden"] = true,
								["position"] = 7,
							},
							["threatBar"] = {
								["height"] = 2,
								["position"] = 6,
							},
							["powerBar"] = {
								["height"] = 4,
								["position"] = 3,
							},
							["fullBar"] = {
								["height"] = 5,
								["position"] = 9,
							},
							["repBar"] = {
								["height"] = 2,
								["position"] = 5,
							},
						},
						["icons"] = {
							["restIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgebottomleft",
							},
							["masterIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopleft",
							},
							["leaderIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopleft",
							},
							["pvpIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopright",
							},
							["raidTargetIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetop",
							},
							["voiceIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgetopright",
							},
							["combatIcon"] = {
								["size"] = 1,
								["position"] = "frame-edgebottomleft",
							},
						},
						["texts"] = {
							["Threat"] = {
								["styleType"] = "threat",
								["custom"] = "[Threat]/[MaxThreat]",
								["position"] = "threatBar-right",
								["style"] = "Absolute Short",
								["hidden"] = false,
								["size"] = 1,
							},
							["Power"] = {
								["styleType"] = "power",
								["custom"] = "[CurMP]/[MaxMP]",
								["position"] = "powerBar-right",
								["style"] = "Absolute",
								["hidden"] = false,
								["size"] = 1,
							},
							["Reputation"] = {
								["styleType"] = "reputation",
								["style"] = "Standard",
								["position"] = "repBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Class"] = {
								["styleType"] = "class",
								["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
								["position"] = "powerBar-left",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1,
							},
							["Experience"] = {
								["styleType"] = "experience",
								["style"] = "Standard",
								["position"] = "expBar-center",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["combatText"] = {
								["styleType"] = "none",
								["custom"] = "",
								["position"] = "frame-center",
								["style"] = "Custom",
								["hidden"] = false,
								["size"] = 1,
							},
							["Name"] = {
								["styleType"] = "name",
								["custom"] = "[Name]",
								["position"] = "healthBar-left",
								["style"] = "Standard",
								["hidden"] = false,
								["size"] = 1,
							},
							["Combo"] = {
								["styleType"] = "combo",
								["style"] = "Standard",
								["position"] = "frame-outright",
								["custom"] = "",
								["hidden"] = false,
								["size"] = 1,
							},
							["Health"] = {
								["styleType"] = "health",
								["style"] = "Informational",
								["position"] = "healthBar-right",
								["custom"] = "[CurHP]/[MaxHP]",
								["hidden"] = false,
								["size"] = 1,
							},
						},
					},
				},
			},
		},
		["Portrait"] = {
			["profiles"] = {
				["Default"] = {
					["targettargettarget"] = {
						["hidden"] = true,
					},
					["partytarget"] = {
						["hidden"] = true,
					},
					["focustarget"] = {
						["hidden"] = true,
					},
					["pet"] = {
						["style"] = "2D",
						["hidden"] = true,
					},
					["partypet"] = {
						["hidden"] = true,
					},
					["targettarget"] = {
						["hidden"] = true,
					},
					["party"] = {
						["style"] = "2D",
						["hidden"] = false,
					},
					["maintanktarget"] = {
						["hidden"] = true,
					},
					["focus"] = {
						["style"] = "2D",
						["hidden"] = false,
					},
					["target"] = {
						["style"] = "2D",
						["hidden"] = false,
					},
					["raid"] = {
						["hidden"] = true,
					},
					["player"] = {
						["style"] = "2D",
						["hidden"] = false,
					},
					["maintank"] = {
						["hidden"] = true,
					},
				},
				["char/Buserker - 에이그윈"] = {
					["target"] = {
						["fallbackClass"] = "Class",
						["style"] = "3D",
						["fallback2D"] = "2D",
						["fullBody"] = false,
						["fallback3D"] = "3D",
					},
					["player"] = {
						["fallbackClass"] = "Class",
						["style"] = "3D",
						["fallback2D"] = "2D",
						["fullBody"] = false,
						["fallback3D"] = "3D",
					},
				},
			},
		},
		["ExperienceBar"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["restColors"] = {
						1, -- [1]
						0, -- [2]
						1, -- [3]
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
					["colors"] = {
						0, -- [1]
						0, -- [2]
						1, -- [3]
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
					["target"] = {
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
					["bgColors"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
					["player"] = {
						["deficit"] = false,
						["ignore"] = true,
						["reverse"] = false,
					},
				},
				["Default"] = {
					["pet"] = {
						["ignore"] = true,
					},
				},
			},
		},
		["RangeCheck"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["interval"] = 0.7,
					["opacity"] = 0.6,
					["groups"] = {
						["target"] = {
							["ignore"] = true,
						},
						["player"] = {
							["ignore"] = true,
						},
						["targettargettarget"] = {
							["ignore"] = true,
						},
						["targettarget"] = {
							["ignore"] = true,
						},
					},
					["enabled"] = true,
				},
				["Default"] = {
					["enabled"] = false,
					["opacity"] = 0.4,
					["groups"] = {
						["target"] = {
							["ignore"] = false,
						},
					},
				},
			},
		},
		["CastBar"] = {
			["profiles"] = {
				["Default"] = {
					["spelltextcolor"] = {
						0.7098039215686275, -- [1]
						0.7098039215686275, -- [2]
						0.7098039215686275, -- [3]
					},
					["backgroundcolor"] = {
						0.5019607843137255, -- [1]
						0.5019607843137255, -- [2]
						0.5019607843137255, -- [3]
					},
					["groups"] = {
						["raid"] = {
							["ignore"] = true,
						},
						["player"] = {
							["ignore"] = true,
						},
						["maintanktarget"] = {
							["ignore"] = true,
						},
						["focus"] = {
							["ignore"] = true,
						},
						["target"] = {
							["ignore"] = true,
						},
						["maintank"] = {
							["ignore"] = true,
						},
						["pet"] = {
							["ignore"] = true,
						},
						["party"] = {
							["ignore"] = true,
						},
					},
					["timetextcolor"] = {
						0.7098039215686275, -- [1]
						0.7098039215686275, -- [2]
						0.7098039215686275, -- [3]
					},
				},
				["char/Buserker - 에이그윈"] = {
					["spelltextcolor"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
					["timetextcolor"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
					["castingcolor"] = {
						1, -- [1]
						0.7, -- [2]
						0, -- [3]
					},
					["completecolor"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
					},
					["groups"] = {
						["target"] = {
							["showIcon"] = true,
							["ignore"] = false,
						},
						["player"] = {
							["showIcon"] = true,
							["ignore"] = false,
						},
						["targettargettarget"] = {
							["showIcon"] = true,
							["ignore"] = true,
						},
						["partypettarget"] = {
							["showIcon"] = true,
							["ignore"] = true,
						},
						["partytarget"] = {
							["showIcon"] = true,
							["ignore"] = true,
						},
						["focustarget"] = {
							["showIcon"] = true,
							["ignore"] = true,
						},
						["targettarget"] = {
							["showIcon"] = true,
							["ignore"] = true,
						},
						["raidtarget"] = {
							["showIcon"] = true,
							["ignore"] = true,
						},
					},
					["channelingcolor"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
					},
					["backgroundcolor"] = {
						0.5, -- [1]
						0.5, -- [2]
						0.5, -- [3]
						0.8, -- [4]
					},
					["failcolor"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
					},
				},
			},
		},
		["Aura"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["player"] = {
						["grow"] = -1,
						["highlight"] = {
							["Buffs"] = true,
							["Debuffs"] = true,
						},
						["flip"] = false,
						["maxdebuffs"] = 6,
						["buffFilterSelection"] = {
						},
						["sort"] = true,
						["buffsize"] = 16,
						["buffFilter"] = true,
						["snap"] = true,
						["frameHighlight"] = "Cureable by me",
						["hiddenDebuffs"] = false,
						["debuffsize"] = 16,
						["hidden"] = false,
						["split"] = false,
						["hiddenWeaponBuffs"] = false,
						["debuffdirection"] = "Right then Down",
						["hiddenBuffs"] = false,
						["buffdirection"] = "Right then Down",
						["highlightType"] = {
							["Buffs"] = true,
							["Debuffs"] = true,
						},
						["highlightStyle"] = "border",
						["maxbuffs"] = 6,
						["debuffFilter"] = true,
					},
					["cooldownText"] = false,
					["zoomAura"] = true,
					["weaponBuffSpellIcon"] = true,
					["target"] = {
						["grow"] = -1,
						["highlight"] = {
							["Buffs"] = true,
							["Debuffs"] = true,
						},
						["split"] = false,
						["maxdebuffs"] = 40,
						["hiddenWeaponBuffs"] = false,
						["sort"] = true,
						["buffsize"] = 16,
						["hiddenDebuffs"] = false,
						["snap"] = true,
						["frameHighlight"] = "Never",
						["buffFilterSelection"] = {
						},
						["debuffFilter"] = false,
						["hidden"] = false,
						["hiddenBuffs"] = false,
						["debuffsize"] = 16,
						["debuffdirection"] = "Right then Down",
						["flip"] = false,
						["buffdirection"] = "Right then Down",
						["highlightType"] = {
							["Buffs"] = true,
							["Debuffs"] = true,
						},
						["highlightStyle"] = "border",
						["buffFilter"] = false,
						["maxbuffs"] = 40,
					},
					["cooldownTextAlpha"] = 0.5,
					["cooldown"] = true,
					["colors"] = {
						["grow"] = -1,
						["debuffs"] = {
							["nil"] = {
								1, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["Curse"] = {
								5, -- [1]
								0, -- [2]
								5, -- [3]
								1, -- [4]
							},
							["Poison"] = {
								0, -- [1]
								1, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["Magic"] = {
								0, -- [1]
								0, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["Disease"] = {
								0.55, -- [1]
								0.15, -- [2]
								0, -- [3]
								1, -- [4]
							},
						},
						["highlight"] = {
							["Buffs"] = true,
							["Debuffs"] = true,
						},
						["split"] = false,
						["maxdebuffs"] = 6,
						["buffFilterSelection"] = {
						},
						["sort"] = true,
						["weaponBuffItemQuality"] = true,
						["buffsize"] = 16,
						["buffFilter"] = true,
						["snap"] = true,
						["highlightStyle"] = "border",
						["frameHighlight"] = "Cureable by me",
						["hiddenDebuffs"] = false,
						["hiddenBuffs"] = false,
						["hidden"] = false,
						["debuffFilter"] = true,
						["debuffsize"] = 16,
						["debuffdirection"] = "Right then Down",
						["flip"] = false,
						["buffdirection"] = "Right then Down",
						["highlightType"] = {
							["Buffs"] = true,
							["Debuffs"] = true,
						},
						["buffs"] = {
							["nil"] = {
								0, -- [1]
								1, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["Own"] = {
								1, -- [1]
								1, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["Weapon"] = {
								1, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
						},
						["maxbuffs"] = 6,
						["hiddenWeaponBuffs"] = false,
					},
				},
				["Default"] = {
					["mainassisttarget"] = {
						["hidden"] = true,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
					},
					["targettargettarget"] = {
						["hidden"] = true,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
					},
					["partytarget"] = {
						["frameHighlight"] = "Never",
						["hidden"] = true,
						["maxbuffs"] = 2,
						["hiddenBuffs"] = true,
						["maxdebuffs"] = 2,
						["sort"] = false,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
						["snap"] = false,
					},
					["focus"] = {
						["grow"] = 1,
						["debuffsize"] = 22,
						["buffsize"] = 22,
						["snap"] = false,
						["maxdebuffs"] = 12,
						["sort"] = false,
						["debuffFilter"] = false,
						["auraSide"] = "top",
						["highlightStyle"] = "thinborder",
						["buffFilter"] = false,
						["maxbuffs"] = 12,
					},
					["pettarget"] = {
						["highlightStyle"] = "thinborder",
					},
					["colors"] = {
						["buffs"] = {
							[4] = 0.5,
							["nil"] = {
								nil, -- [1]
								0, -- [2]
							},
						},
						["debuffs"] = {
							["Curse"] = {
								0.9725490196078431, -- [1]
								0.6745098039215687, -- [2]
								1, -- [3]
							},
							["Magic"] = {
								0.396078431372549, -- [1]
								0.4666666666666667, -- [2]
							},
						},
					},
					["mainassisttargettarget"] = {
						["highlightStyle"] = "thinborder",
					},
					["party"] = {
						["grow"] = 1,
						["flip"] = true,
						["debuffsize"] = 18,
						["frameHighlight"] = "All Debuffs",
						["debuffdirection"] = "Down then Left",
						["buffdirection"] = "Left then Down",
						["buffFilter"] = false,
						["maxdebuffs"] = 4,
						["sort"] = false,
						["aura2OffsetY"] = 2,
						["debuffSide"] = "left",
						["buffFilterSelection"] = {
							["저주 증폭"] = false,
							["포세이큰의 의지"] = false,
							["암흑계 수호"] = false,
							["악마 감지"] = false,
							["어둠의 무아지경"] = false,
							["시체먹기"] = false,
							["공포마 소환"] = false,
							["악의 제물"] = false,
							["악마의 지식"] = false,
							["망상"] = false,
							["악마의 피부"] = false,
							["은빛날개 깃발"] = false,
							["영혼의 고리"] = false,
							["지옥마 소환"] = false,
							["악마의 갑옷"] = false,
							["반발력"] = false,
							["악령술의 대가"] = false,
							["악마의 광기"] = false,
							["황천의 폭풍 깃발"] = false,
							["희생"] = false,
							["마의 갑옷"] = false,
							["마의 지배"] = false,
							["황천의 보호"] = false,
						},
						["maxbuffs"] = 15,
						["snap"] = false,
						["frame2Width"] = 50,
						["highlightStyle"] = "thinborder",
						["debuffFilter"] = false,
						["frameWidth"] = 240,
					},
					["mainassist"] = {
						["hidden"] = true,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
					},
					["partypettarget"] = {
						["highlightStyle"] = "thinborder",
					},
					["target"] = {
						["grow"] = 1,
						["debuffsize"] = 22,
						["buffsize"] = 22,
						["debuffdirection"] = "Right then Up",
						["buffdirection"] = "Right then Up",
						["maxbuffs"] = 24,
						["sort"] = false,
						["maxdebuffs"] = 36,
						["auraSide"] = "top",
						["highlightStyle"] = "thinborder",
					},
					["raid"] = {
						["debuffsize"] = 14,
						["frame2Width"] = 50,
						["debuffdirection"] = "Down then Right",
						["snap"] = false,
						["hiddenBuffs"] = true,
						["split"] = true,
						["aura2OffsetY"] = 46,
						["debuffSide"] = "bottom",
						["buffSide"] = "right",
						["maxdebuffs"] = 2,
						["aura2OffsetX"] = 1,
						["highlightStyle"] = "thinborder",
						["maxbuffs"] = 3,
					},
					["raidtarget"] = {
						["highlightStyle"] = "thinborder",
					},
					["maintanktargettarget"] = {
						["highlightStyle"] = "thinborder",
					},
					["mouseover"] = {
						["highlightStyle"] = "thinborder",
					},
					["maintanktarget"] = {
						["hidden"] = true,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
					},
					["pet"] = {
						["maxbuffs"] = 4,
						["maxdebuffs"] = 4,
						["highlightStyle"] = "thinborder",
					},
					["focustarget"] = {
						["debuffsize"] = 18,
						["buffsize"] = 14,
						["auraOffsetY"] = -5,
						["hidden"] = true,
						["maxbuffs"] = 4,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["invert"] = false,
						["maxdebuffs"] = 4,
						["highlightStyle"] = "thinborder",
						["auraSide"] = "right",
						["frameWidth"] = 100,
					},
					["targettarget"] = {
						["hidden"] = true,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
					},
					["partypet"] = {
						["hidden"] = true,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
					},
					["mouseovertarget"] = {
						["highlightStyle"] = "thinborder",
					},
					["player"] = {
						["grow"] = 1,
						["debuffsize"] = 20,
						["buffsize"] = 20,
						["hidden"] = true,
						["debuffdirection"] = "Right then Up",
						["buffdirection"] = "Right then Up",
						["maxbuffs"] = 40,
						["hiddenBuffs"] = true,
						["split"] = true,
						["maxdebuffs"] = 40,
						["hiddenDebuffs"] = true,
						["hiddenWeaponBuffs"] = true,
						["highlightStyle"] = "thinborder",
						["snap"] = false,
					},
					["zoomAura"] = false,
					["maintank"] = {
						["hidden"] = true,
						["hiddenBuffs"] = true,
						["hiddenDebuffs"] = true,
						["highlightStyle"] = "thinborder",
					},
					["focustargettarget"] = {
						["highlightStyle"] = "thinborder",
					},
					["raidpet"] = {
						["highlightStyle"] = "thinborder",
					},
				},
			},
		},
		["PvPIcon"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["groups"] = {
						["target"] = {
						},
						["player"] = {
						},
					},
				},
				["Default"] = {
					["groups"] = {
						["party"] = {
							["ignore"] = true,
						},
						["raid"] = {
							["ignore"] = true,
						},
						["pet"] = {
							["ignore"] = true,
						},
						["target"] = {
							["ignore"] = true,
						},
						["maintank"] = {
							["ignore"] = true,
						},
						["targettarget"] = {
							["ignore"] = true,
						},
						["partypet"] = {
							["ignore"] = true,
						},
					},
				},
			},
		},
		["PowerBar"] = {
			["profiles"] = {
				["Default"] = {
					["mainassisttarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["targettargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["partytarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["hidden"] = true,
					},
					["mainassisttargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["party"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["maintanktargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["partypettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["target"] = {
						["customBGColor"] = true,
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
						},
					},
					["raid"] = {
						["hideNoMana"] = false,
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["raidtarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["mainassist"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["focus"] = {
						["customBGColor"] = true,
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["maintanktarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["hidden"] = true,
					},
					["focustarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["hidden"] = true,
					},
					["targettarget"] = {
						["customBGColor"] = true,
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["partypet"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["mouseovertarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["player"] = {
						["customBGColor"] = true,
						["customColors"] = {
							["rage"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["focus"] = {
								[3] = 0.9098039215686274,
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["customColor"] = true,
					},
					["mouseover"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["pet"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["pettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["maintank"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["hidden"] = true,
					},
					["focustargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
					["raidpet"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
								1, -- [4]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
					},
				},
				["char/Buserker - 에이그윈"] = {
					["player"] = {
						["customBGColor"] = false,
						["hideNoMana"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["deficit"] = false,
						["reverse"] = false,
						["customColors"] = {
							["rage"] = {
								0.9019607843137255, -- [1]
								0.1019607843137255, -- [2]
								0.1019607843137255, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focus"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["energy"] = {
								0.9411764705882353, -- [1]
								0.8235294117647058, -- [2]
								0.2392156862745098, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["colorByClass"] = false,
						["hideNoPower"] = false,
					},
					["targettargettarget"] = {
						["customBGColor"] = false,
						["hideNoMana"] = false,
						["hidden"] = true,
						["customColor"] = false,
						["deficit"] = false,
						["reverse"] = false,
						["customColors"] = {
							["rage"] = {
								0.9019607843137255, -- [1]
								0.1019607843137255, -- [2]
								0.1019607843137255, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focus"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["energy"] = {
								0.9411764705882353, -- [1]
								0.8235294117647058, -- [2]
								0.2392156862745098, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["colorByClass"] = false,
						["hideNoPower"] = false,
					},
					["target"] = {
						["customBGColor"] = false,
						["hideNoMana"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["deficit"] = false,
						["reverse"] = false,
						["customColors"] = {
							["rage"] = {
								0.9019607843137255, -- [1]
								0.1019607843137255, -- [2]
								0.1019607843137255, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focus"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["energy"] = {
								0.9411764705882353, -- [1]
								0.8235294117647058, -- [2]
								0.2392156862745098, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["colorByClass"] = false,
						["hideNoPower"] = false,
					},
					["raid"] = {
						["customBGColor"] = false,
						["hideNoMana"] = true,
						["hidden"] = false,
						["customColor"] = false,
						["deficit"] = false,
						["reverse"] = false,
						["customColors"] = {
							["rage"] = {
								0.9019607843137255, -- [1]
								0.1019607843137255, -- [2]
								0.1019607843137255, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focus"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["energy"] = {
								0.9411764705882353, -- [1]
								0.8235294117647058, -- [2]
								0.2392156862745098, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["colorByClass"] = false,
						["hideNoPower"] = false,
					},
					["targettarget"] = {
						["customBGColor"] = false,
						["hideNoMana"] = false,
						["hidden"] = true,
						["customColor"] = false,
						["deficit"] = false,
						["reverse"] = false,
						["customColors"] = {
							["rage"] = {
								0.9019607843137255, -- [1]
								0.1019607843137255, -- [2]
								0.1019607843137255, -- [3]
							},
							["rageBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focusBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["focus"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["manaBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
							["mana"] = {
								0.792156862745098, -- [1]
								0.8549019607843137, -- [2]
								0.9098039215686274, -- [3]
							},
							["energy"] = {
								0.9411764705882353, -- [1]
								0.8235294117647058, -- [2]
								0.2392156862745098, -- [3]
							},
							["energyBG"] = {
								0.04313725490196078, -- [1]
								0.04313725490196078, -- [2]
								0.04313725490196078, -- [3]
							},
						},
						["colorByClass"] = false,
						["hideNoPower"] = false,
					},
				},
			},
		},
		["HideBlizzard"] = {
			["profiles"] = {
				["Default"] = {
					["aura"] = true,
				},
			},
		},
		["ReputationBar"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["customBGColor"] = false,
					["ignore"] = true,
					["deficit"] = false,
					["reverse"] = false,
					["autoHide"] = false,
					["customColors"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
					["customBGColors"] = {
						0.04313725490196078, -- [1]
						0.04313725490196078, -- [2]
						0.04313725490196078, -- [3]
					},
					["backgroundColor"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["customColor"] = false,
				},
			},
		},
		["HealthBar"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["targettargettarget"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["partytarget"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["focustarget"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["pet"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["classColorPvP"] = false,
						["hostilityColor"] = false,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["happinessColor"] = true,
						["reverse"] = false,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["player"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = false,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["focus"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["target"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["targettarget"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["partypettarget"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
					["raidtarget"] = {
						["customBGColor"] = false,
						["hostilityColorNPCs"] = false,
						["hidden"] = false,
						["customColor"] = false,
						["classColor"] = true,
						["deficit"] = false,
						["hostilityColor"] = true,
						["customColors"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = false,
						["reverse"] = false,
					},
				},
				["Default"] = {
					["mainassisttarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["hostilityColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["targettargettarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["partytarget"] = {
						["customBGColor"] = true,
						["classColorPvP"] = true,
						["hostilityColor"] = false,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColor"] = false,
					},
					["mainassisttargettarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["hostilityColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["party"] = {
						["customBGColor"] = true,
						["classColor"] = false,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["maintanktarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["hostilityColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["partypettarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["target"] = {
						["customBGColor"] = true,
						["hostilityColor"] = false,
						["classColorPvP"] = true,
					},
					["raid"] = {
						["customBGColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["raidtarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["maintanktargettarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["hostilityColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["raidpet"] = {
						["customBGColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["focus"] = {
						["customBGColor"] = true,
						["hostilityColor"] = false,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["focustarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["pet"] = {
						["customBGColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["partypet"] = {
						["customBGColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["mouseovertarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["player"] = {
						["customBGColor"] = true,
						["classColor"] = false,
						["customColors"] = {
							0.1843137254901961, -- [1]
							0.1764705882352941, -- [2]
							0.1764705882352941, -- [3]
						},
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["mouseover"] = {
						["customBGColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["targettarget"] = {
						["customBGColor"] = true,
						["hostilityColor"] = false,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["pettarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["hostilityColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["maintank"] = {
						["customBGColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
					["focustargettarget"] = {
						["customBGColor"] = true,
						["hostilityColorNPCs"] = true,
						["hostilityColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
						["classColorPvP"] = true,
					},
					["mainassist"] = {
						["customBGColor"] = true,
						["customBGColors"] = {
							0.04313725490196078, -- [1]
							0.04313725490196078, -- [2]
							0.04313725490196078, -- [3]
						},
					},
				},
			},
		},
		["VoiceIcon"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["groups"] = {
						["target"] = {
							["disable"] = false,
						},
						["player"] = {
							["disable"] = false,
						},
					},
				},
			},
		},
		["VisualHeal"] = {
			["profiles"] = {
				["Default"] = {
					["groups"] = {
						["target"] = {
							["enabled"] = false,
						},
						["player"] = {
							["enabled"] = false,
						},
						["party"] = {
							["enabled"] = false,
						},
					},
					["autoLuminance"] = false,
				},
			},
		},
		["LeaderIcon"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["player"] = {
						["disable"] = false,
					},
				},
				["Default"] = {
					["raid"] = {
						["disable"] = true,
					},
				},
			},
		},
		["CombatFader"] = {
			["profiles"] = {
				["Default"] = {
					["groups"] = {
						["targettarget"] = {
							["outAlpha"] = 0.75,
						},
						["player"] = {
							["outAlpha"] = 0.5,
						},
						["pet"] = {
							["outAlpha"] = 0.5,
						},
						["focus"] = {
							["outAlpha"] = 0.6000000000000001,
						},
					},
				},
				["char/Buserker - 에이그윈"] = {
					["groups"] = {
						["target"] = {
							["outAlpha"] = 0.5,
							["notFullAlpha"] = 0.75,
							["hasTargetAlpha"] = 0.75,
							["inAlpha"] = 1,
							["disable"] = false,
						},
						["player"] = {
							["outAlpha"] = 0.25,
							["notFullAlpha"] = 0.75,
							["hasTargetAlpha"] = 0.75,
							["inAlpha"] = 1,
							["disable"] = false,
						},
						["party"] = {
							["outAlpha"] = 0.25,
							["notFullAlpha"] = 0.75,
							["hasTargetAlpha"] = 0.75,
							["inAlpha"] = 1,
							["disable"] = false,
						},
					},
					["fadetime"] = 5,
				},
			},
		},
		["Banzai"] = {
			["profiles"] = {
				["Default"] = {
					["color"] = {
						0.6352941176470588, -- [1]
					},
					["groups"] = {
						["party"] = {
							["ignore"] = false,
						},
						["raid"] = {
							["ignore"] = false,
						},
						["focus"] = {
							["ignore"] = true,
						},
					},
				},
				["char/Buserker - 에이그윈"] = {
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["groups"] = {
						["target"] = {
							["ignore"] = true,
						},
						["player"] = {
						},
						["targettargettarget"] = {
							["ignore"] = true,
						},
						["targettarget"] = {
							["ignore"] = true,
						},
					},
				},
			},
		},
		["RaidTargetIcon"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["target"] = {
						["disable"] = false,
					},
					["player"] = {
						["disable"] = false,
					},
				},
				["Default"] = {
					["partypet"] = {
						["disable"] = true,
					},
				},
			},
		},
		["Power"] = {
			["profiles"] = {
				["Default"] = {
					["mainassisttarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["colorByClass"] = true,
					},
					["targettargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["partytarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["mainassisttargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["party"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["hidden"] = true,
					},
					["mainassist"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["partypettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["target"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["raid"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["colorByClass"] = true,
						["hideNoMana"] = false,
					},
					["raidtarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["focus"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["hidden"] = true,
					},
					["raidpet"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["maintanktarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["colorByClass"] = true,
					},
					["focustarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["mouseover"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["partypet"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["hidden"] = true,
					},
					["mouseovertarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["player"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["pettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["pet"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["hidden"] = true,
					},
					["targettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["maintank"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
						["colorByClass"] = true,
					},
					["focustargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
					["maintanktargettarget"] = {
						["customColors"] = {
							["rage"] = {
								0.8862745098039215, -- [1]
								0.1764705882352941, -- [2]
								0.2941176470588235, -- [3]
							},
							["mana"] = {
								0.1882352941176471, -- [1]
								0.4431372549019608, -- [2]
								0.7490196078431373, -- [3]
							},
							["energy"] = {
								1, -- [1]
								0.8627450980392157, -- [2]
								0.09803921568627451, -- [3]
							},
							["focus"] = {
								1, -- [1]
								0.8235294117647058, -- [2]
								0, -- [3]
							},
						},
					},
				},
			},
		},
		["ThreatBar"] = {
			["profiles"] = {
				["Default"] = {
					["pet"] = {
						["ignore"] = true,
					},
					["player"] = {
						["ignore"] = true,
					},
					["colors"] = {
						0.9490196078431372, -- [1]
						0.1882352941176471, -- [2]
						0.2862745098039216, -- [3]
					},
					["maintank"] = {
						["ignore"] = true,
					},
				},
				["char/Buserker - 에이그윈"] = {
					["target"] = {
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
					["bgColors"] = {
						0.25, -- [1]
						0, -- [2]
						0, -- [3]
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
					["colors"] = {
						0.75, -- [1]
						0, -- [2]
						0, -- [3]
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
					["player"] = {
						["deficit"] = false,
						["ignore"] = false,
						["reverse"] = false,
					},
				},
			},
		},
		["CombatIcon"] = {
			["profiles"] = {
				["char/Buserker - 에이그윈"] = {
					["groups"] = {
						["target"] = {
							["disable"] = false,
						},
						["player"] = {
							["disable"] = false,
						},
						["party"] = {
							["disable"] = false,
						},
					},
				},
				["Default"] = {
					["groups"] = {
						["party"] = {
							["disable"] = true,
						},
					},
				},
			},
		},
		["ComboPoints"] = {
			["profiles"] = {
				["Default"] = {
					["texture"] = "bar",
				},
			},
		},
		["TotemTimers"] = {
			["profiles"] = {
				["Default"] = {
					["hideinactive"] = true,
					["timertextscale"] = 1,
					["totemspacing"] = 2,
					["iconbordercolor"] = {
						1, -- [1]
						0.2666666666666667, -- [2]
						1, -- [3]
						1, -- [4]
					},
					["timertextcolor"] = {
						[3] = 1,
					},
					["mainbgcolor"] = {
						nil, -- [1]
						nil, -- [2]
						nil, -- [3]
						0, -- [4]
					},
					["timertextside"] = "bottomoutside",
					["totemsize"] = 36,
				},
			},
		},
	},
	["disabledModules"] = {
		["Default"] = {
			["ReputationBar"] = true,
			["BarFader"] = true,
			["Portrait"] = false,
			["ExperienceBar"] = true,
			["RangeCheck"] = true,
			["VoiceIcon"] = true,
			["VisualHeal"] = true,
			["CombatFader"] = true,
			["EstimatedHeals"] = true,
			["CastBar"] = true,
			["CombatText"] = true,
			["ThreatBar"] = true,
			["PvPIcon"] = true,
			["InteractLines"] = true,
			["Banzai"] = true,
		},
	},
	["profiles"] = {
		["char/Buserker - 에이그윈"] = {
		},
		["Default"] = {
			["clusters"] = {
				["partytarget"] = {
					["y"] = -322.2719116210938,
					["x"] = 444.524169921875,
				},
				["raidMAINTANK"] = {
					["y"] = -92.5592041015625,
					["x"] = 358.88916015625,
				},
				["raid5"] = {
					["y"] = -164.2066650390625,
					["x"] = -397.9406433105469,
				},
				["raid8"] = {
					["y"] = 16.87371826171875,
					["x"] = -552.1032562255859,
				},
				["raid6"] = {
					["y"] = 16.87359619140625,
					["x"] = -707.9096145629883,
				},
				["raid7"] = {
					["y"] = 16.873779296875,
					["x"] = -630.4925384521484,
				},
				["party"] = {
					["y"] = -331.5228271484375,
					["x"] = 621.0494384765625,
				},
				["raid4"] = {
					["y"] = -164.2072448730469,
					["x"] = -475.293701171875,
				},
				["raidMAINTANKtarget"] = {
					["y"] = -93.0863037109375,
					["x"] = 444.9854736328125,
				},
				["raid3"] = {
					["y"] = -164.1361083984375,
					["x"] = -552.78076171875,
				},
				["raid1"] = {
					["y"] = -164.0639953613281,
					["x"] = -707.7074089050293,
				},
				["raidMAINASSIST"] = {
					["y"] = 544.26904296875,
					["x"] = -845.4458084106445,
				},
				["partypet"] = {
					["y"] = -347.2781372070313,
					["x"] = 444.4051513671875,
				},
				["raid"] = {
					["y"] = 591.9706420898438,
					["x"] = -676.0013809204102,
				},
				["raid2"] = {
					["y"] = -164.1354370117188,
					["x"] = -630.2910308837891,
				},
				["raidMAINASSISTtarget"] = {
					["y"] = 544.268798828125,
					["x"] = -740.0337982177734,
				},
			},
			["groups"] = {
				["mainassisttarget"] = {
					["direction"] = "up",
					["scale"] = 0.95,
					["hidden"] = true,
					["width"] = 120,
					["spacing"] = 5,
					["height"] = 20,
				},
				["targettargettarget"] = {
					["width"] = 65,
					["height"] = 25,
				},
				["partytarget"] = {
					["width"] = 100,
					["direction"] = "up",
					["spacing"] = 38,
					["height"] = 24,
				},
				["mainassisttargettarget"] = {
					["hidden"] = true,
				},
				["party"] = {
					["direction"] = "up",
					["width"] = 240,
					["hidePartyInRaid"] = false,
					["spacing"] = 28,
					["height"] = 34,
					["hspacing"] = 160,
				},
				["maintanktargettarget"] = {
					["hidden"] = true,
				},
				["focus"] = {
					["width"] = 266,
					["height"] = 34,
				},
				["target"] = {
					["width"] = 266,
					["height"] = 34,
				},
				["raid"] = {
					["nameSort"] = false,
					["hidden"] = true,
					["width"] = 72,
					["spacing"] = 4,
					["height"] = 30,
				},
				["mainassist"] = {
					["direction"] = "up",
					["scale"] = 0.95,
					["hidden"] = true,
					["width"] = 90,
					["spacing"] = 5,
					["height"] = 20,
				},
				["focustarget"] = {
					["hidden"] = true,
					["width"] = 70,
					["height"] = 25,
				},
				["pet"] = {
					["width"] = 140,
					["height"] = 25,
				},
				["partypet"] = {
					["width"] = 100,
					["spacing"] = 42,
					["height"] = 20,
					["direction"] = "up",
					["hspacing"] = 20,
				},
				["player"] = {
					["width"] = 266,
					["height"] = 34,
				},
				["pettarget"] = {
					["hidden"] = true,
				},
				["maintanktarget"] = {
					["direction"] = "up",
					["hidden"] = true,
					["width"] = 84,
					["spacing"] = 0,
					["height"] = 28,
				},
				["maintank"] = {
					["direction"] = "up",
					["hidden"] = true,
					["width"] = 84,
					["spacing"] = 0,
					["height"] = 28,
				},
				["targettarget"] = {
					["width"] = 65,
					["height"] = 25,
				},
			},
			["detachedTooltip"] = {
			},
			["settings"] = {
				["strata"] = "BACKGROUND",
				["font"] = "기본 글꼴",
				["fontsize"] = 10,
				["locked"] = true,
				["colors"] = {
					["HUNTER"] = {
						0.8509803921568627, -- [1]
						0.9647058823529412, -- [2]
						0.6862745098039216, -- [3]
					},
					["WARRIOR"] = {
						0.7568627450980392, -- [1]
						0.6235294117647059, -- [2]
						0.4901960784313725, -- [3]
					},
					["PALADIN"] = {
						0.984313725490196, -- [1]
						0.7529411764705882, -- [2]
						0.8823529411764706, -- [3]
					},
					["MAGE"] = {
						0.5843137254901961, -- [1]
						0.8235294117647058, -- [2]
						0.9529411764705882, -- [3]
					},
					["DRUID"] = {
						0.9882352941176471, -- [1]
						0.7568627450980392, -- [2]
						0.4509803921568628, -- [3]
					},
					["petHappy"] = {
						0.6549019607843137, -- [1]
						0.8862745098039215, -- [2]
						0.3333333333333333, -- [3]
					},
					["tapped"] = {
						0.7019607843137254, -- [1]
						0.7019607843137254, -- [2]
						0.7019607843137254, -- [3]
					},
					["WARLOCK"] = {
						0.8313725490196079, -- [1]
						0.7333333333333333, -- [2]
						0.9450980392156863, -- [3]
					},
					["petNeutral"] = {
						[3] = 0.5215686274509804,
					},
					["energy"] = {
						0.9607843137254902, -- [1]
						0.8862745098039215, -- [2]
						0.4980392156862745, -- [3]
					},
					["inCombat"] = {
						0.7019607843137254, -- [1]
						0.2313725490196079, -- [2]
						0.2862745098039216, -- [3]
					},
					["maxHP"] = {
						0.2588235294117647, -- [1]
						0.3176470588235294, -- [2]
						0.3411764705882353, -- [3]
					},
					["neutral"] = {
						0.8470588235294118, -- [1]
						0.8470588235294118, -- [2]
						0.392156862745098, -- [3]
					},
					["mana"] = {
						0.7725490196078432, -- [1]
						0.8313725490196079, -- [2]
						0.9882352941176471, -- [3]
					},
					["elite"] = {
						0.6431372549019608, -- [1]
						0.6588235294117647, -- [2]
						0.1607843137254902, -- [3]
					},
					["resting"] = {
						0.9372549019607843, -- [1]
						[3] = 0.4235294117647059,
					},
					["hostile"] = {
						0.803921568627451, -- [1]
						0.0392156862745098, -- [2]
						0.0392156862745098, -- [3]
					},
					["focus"] = {
						0.792156862745098, -- [1]
						0.8549019607843137, -- [2]
						1, -- [3]
					},
					["dead"] = {
						0.1294117647058823, -- [1]
						0.1411764705882353, -- [2]
						0.1490196078431373, -- [3]
					},
					["rage"] = {
						0.9019607843137255, -- [1]
						0.1019607843137255, -- [2]
						0.1019607843137255, -- [3]
					},
					["civilian"] = {
						0.1843137254901961, -- [1]
						0.1764705882352941, -- [2]
						0.1764705882352941, -- [3]
					},
					["frameBG"] = {
						nil, -- [1]
						nil, -- [2]
						nil, -- [3]
						0.5999999642372131, -- [4]
					},
					["friendly"] = {
						0.6549019607843137, -- [1]
						0.8470588235294118, -- [2]
						0.5529411764705883, -- [3]
					},
					["PRIEST"] = {
						0.9921568627450981, -- [1]
						0.9921568627450981, -- [2]
					},
					["ROGUE"] = {
						0.996078431372549, -- [1]
						0.9568627450980393, -- [2]
						0.6039215686274509, -- [3]
					},
					["frameBorder"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						0.5999999642372131, -- [4]
					},
					["unknown"] = {
						0.8352941176470589, -- [1]
						0.9529411764705882, -- [2]
						0.9921568627450981, -- [3]
					},
					["SHAMAN"] = {
						0.3019607843137255, -- [1]
						0.4705882352941176, -- [2]
						0.8588235294117647, -- [3]
					},
				},
				["texture"] = "Minimalist",
			},
			["units"] = {
				["player"] = {
					["y"] = -314.0004577636719,
					["x"] = -171.9999389648438,
				},
				["targettargettarget"] = {
					["y"] = -254.296875,
					["x"] = -1.17193603515625,
				},
				["focus"] = {
					["y"] = -124,
					["x"] = 172,
				},
				["target"] = {
					["y"] = -314.0000610351563,
					["x"] = 172,
				},
				["focustarget"] = {
					["y"] = -123.4680786132813,
					["x"] = -2.42059326171875,
				},
				["pet"] = {
					["y"] = -367,
					["x"] = -235,
				},
				["targettarget"] = {
					["y"] = -319.0000610351563,
				},
			},
		},
	},
	["account"] = {
		["customLayouts"] = {
			["TapTarget"] = {
				["name"] = "TapTarget",
				["pbRevision"] = 42341,
				["bars"] = {
					["castBar"] = {
						["position"] = 8,
					},
					["portrait"] = {
						["side"] = "right",
						["position"] = 1,
					},
					["expBar"] = {
						["position"] = 4,
					},
					["blankSpace"] = {
						["hidden"] = true,
						["position"] = 7,
					},
					["threatBar"] = {
						["position"] = 6,
					},
					["healthBar"] = {
						["height"] = 12,
						["position"] = 2,
					},
					["powerBar"] = {
						["height"] = 6,
						["position"] = 3,
					},
					["repBar"] = {
						["position"] = 5,
					},
				},
				["icons"] = {
					["restIcon"] = {
						["position"] = "frame-edgebottomleft",
					},
					["masterIcon"] = {
						["position"] = "frame-edgetopleft",
					},
					["leaderIcon"] = {
						["position"] = "frame-edgetopleft",
					},
					["pvpIcon"] = {
						["position"] = "frame-edgetopright",
					},
					["raidTargetIcon"] = {
						["position"] = "frame-edgetop",
					},
					["combatIcon"] = {
						["position"] = "frame-edgebottomleft",
					},
				},
				["texts"] = {
					["combatText"] = {
						["position"] = "frame-center",
					},
					["Threat"] = {
						["styleType"] = "threat",
						["style"] = "Absolute Short",
						["custom"] = "[Threat]/[MaxThreat]",
						["position"] = "threatBar-right",
					},
					["Name"] = {
						["styleType"] = "name",
						["style"] = "Standard",
						["position"] = "frame-outleftbottom",
						["custom"] = "[Name]",
						["size"] = 1.65,
					},
					["Combo"] = {
						["styleType"] = "combo",
						["style"] = "Standard",
						["position"] = "frame-outright",
					},
					["Reputation"] = {
						["styleType"] = "reputation",
						["style"] = "Standard",
						["position"] = "repBar-center",
					},
					["Class"] = {
						["styleType"] = "class",
						["style"] = "Standard",
						["custom"] = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
						["position"] = "frame-outlefttop",
					},
					["Experience"] = {
						["styleType"] = "experience",
						["style"] = "Standard",
						["position"] = "expBar-center",
					},
					["Health"] = {
						["styleType"] = "health",
						["style"] = "Absolute and Percent",
						["position"] = "frame-intopright",
						["custom"] = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
						["size"] = 1.15,
					},
				},
			},
			["Tapplayer"] = {
				["name"] = "Tapplayer",
				["pbRevision"] = 42341,
				["bars"] = {
					["castBar"] = {
						["position"] = 8,
					},
					["healthBar"] = {
						["height"] = 12,
						["position"] = 2,
					},
					["expBar"] = {
						["position"] = 4,
					},
					["blankSpace"] = {
						["hidden"] = true,
						["position"] = 7,
					},
					["threatBar"] = {
						["position"] = 6,
					},
					["portrait"] = {
						["side"] = "left",
						["position"] = 1,
					},
					["powerBar"] = {
						["height"] = 5,
						["position"] = 3,
					},
					["repBar"] = {
						["position"] = 5,
					},
				},
				["icons"] = {
					["restIcon"] = {
						["position"] = "frame-edgebottomleft",
					},
					["masterIcon"] = {
						["position"] = "frame-edgetopleft",
					},
					["leaderIcon"] = {
						["position"] = "frame-edgetopleft",
					},
					["pvpIcon"] = {
						["position"] = "frame-edgetopright",
					},
					["raidTargetIcon"] = {
						["position"] = "frame-edgetop",
					},
					["combatIcon"] = {
						["position"] = "frame-edgebottomleft",
					},
				},
				["texts"] = {
					["Threat"] = {
						["styleType"] = "threat",
						["custom"] = "[Threat]/[MaxThreat]",
						["style"] = "Absolute Short",
						["position"] = "threatBar-right",
					},
					["Health"] = {
						["styleType"] = "health",
						["custom"] = "[Status:SureHP:PercentHP:Percent]",
						["position"] = "frame-inbottomright",
						["style"] = "Absolute",
						["size"] = 1.35,
					},
					["combatText"] = {
						["position"] = "frame-center",
					},
					["Reputation"] = {
						["styleType"] = "reputation",
						["style"] = "Standard",
						["position"] = "repBar-center",
					},
					["Combo"] = {
						["styleType"] = "combo",
						["style"] = "Standard",
						["position"] = "frame-outright",
					},
					["Experience"] = {
						["styleType"] = "experience",
						["style"] = "Standard",
						["position"] = "expBar-center",
					},
					["Power"] = {
						["styleType"] = "power",
						["style"] = "Absolute",
						["position"] = "frame-inbottomleft",
						["custom"] = "[CurMP]/[MaxMP]",
						["size"] = 1.35,
					},
				},
			},
		},
		["firstTimeWoW21"] = true,
	},
}

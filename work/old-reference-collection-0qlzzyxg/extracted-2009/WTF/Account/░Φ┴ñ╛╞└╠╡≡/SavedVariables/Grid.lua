
GridDB = {
	["namespaces"] = {
		["GridFrame"] = {
			["profiles"] = {
				["Default"] = {
					["fontSize"] = 12,
					["statusmap"] = {
						["side3"] = {
						},
						["icontop"] = {
						},
						["iconleft"] = {
						},
						["iconbottom"] = {
						},
						["icon"] = {
							["alert_RaidDebuff"] = true,
						},
						["text2"] = {
							["buff_재생"] = true,
							["unit_health"] = false,
							["buff_회복"] = true,
							["unit_healthDeficit"] = false,
							["buff_소생"] = true,
							["buff_신의권능:보호막"] = true,
						},
						["manabar"] = {
							["unit_mana"] = true,
						},
						["text"] = {
							["alert_offline"] = false,
							["unit_healthDeficit"] = false,
							["alert_heals"] = false,
							["alert_death"] = false,
							["alert_feignDeath"] = false,
						},
						["side2"] = {
						},
						["iconright"] = {
						},
						["side1"] = {
							["player_target"] = true,
						},
						["side4"] = {
						},
					},
					["iconBorderSize"] = 2,
					["iconSize"] = 20,
					["texture"] = "Minimalist",
					["invertBarColor"] = true,
					["frameHeight"] = 48,
					["enableText2"] = true,
					["font"] = "기본 글꼴",
					["healingBar_intensity"] = 0.1,
					["frameWidth"] = 48,
					["cornerSize"] = 8,
				},
			},
		},
		["GridClickSets"] = {
			["profiles"] = {
				["Default"] = {
					["set"] = {
						["1"] = {
							[""] = {
								["type"] = "target",
							},
						},
						["3"] = {
							[""] = {
								["type"] = "spellId:4987",
							},
						},
					},
				},
			},
		},
		["GridStatusMana"] = {
			["profiles"] = {
				["Default"] = {
					["alert_lowMana"] = {
						["enable"] = false,
					},
				},
			},
		},
		["GridMBStatus"] = {
			["profiles"] = {
				["Default"] = {
					["size"] = 15,
				},
			},
		},
		["GridStatusRaidDebuff"] = {
			["profiles"] = {
				["Default"] = {
					["debuff_option"] = {
						["불뱀 제단"] = {
						},
						["영원의 눈"] = {
						},
						["사령관의 시험장"] = {
						},
						["울두아르"] = {
							[63042] = true,
							[63050] = true,
						},
						["태양샘 고원"] = {
						},
						["하이잘 정상"] = {
						},
						["십자군의 시험장"] = {
							[67223] = true,
							[67176] = true,
						},
						["흑요석 성소"] = {
						},
						["카라잔"] = {
						},
						["폭풍우 요새"] = {
						},
						["검은 사원"] = {
						},
						["낙스라마스"] = {
							[28084] = true,
							[27819] = true,
							[28059] = true,
							[29310] = true,
						},
						["줄아만"] = {
						},
					},
					["isFirst"] = false,
				},
			},
		},
		["GridMBFrame"] = {
			["profiles"] = {
				["Default"] = {
					["size"] = 0.15,
				},
			},
		},
		["GridStatusRange"] = {
			["profiles"] = {
				["Default"] = {
					["alert_range_45"] = {
						["color"] = {
							["a"] = 0.1818181818181818,
							["b"] = 0.35,
							["g"] = 0.9,
							["r"] = 0.45,
						},
						["priority"] = 36,
						["enable"] = true,
						["text"] = "45 미터",
						["range"] = false,
						["desc"] = "45 미터 이상",
					},
					["alert_range_10"] = {
						["color"] = {
							["a"] = 0.8181818181818181,
							["b"] = 0.3,
							["g"] = 0.2,
							["r"] = 0.1,
						},
						["priority"] = 8,
						["enable"] = false,
						["text"] = "10 미터",
						["range"] = false,
						["desc"] = "10 미터 이상",
					},
					["alert_range_38"] = {
						["enable"] = false,
						["text"] = "38 미터",
						["color"] = {
							["a"] = 0.3090909090909091,
							["r"] = 0.38,
							["g"] = 0.76,
							["b"] = 0.14,
						},
						["priority"] = 84,
						["range"] = false,
						["desc"] = "38 미터 이상",
					},
					["alert_range_25"] = {
						["color"] = {
							["a"] = 0.5454545454545454,
							["b"] = 0.75,
							["g"] = 0.5,
							["r"] = 0.25,
						},
						["priority"] = 82,
						["enable"] = true,
						["text"] = "25 미터",
						["range"] = false,
						["desc"] = "25 미터 이상",
					},
					["alert_range_20"] = {
						["color"] = {
							["a"] = 0.6363636363636364,
							["b"] = 0.6,
							["g"] = 0.4,
							["r"] = 0.2,
						},
						["priority"] = 16,
						["enable"] = false,
						["text"] = "20 미터",
						["range"] = false,
						["desc"] = "20 미터 이상",
					},
					["frequency"] = 0.4,
					["alert_range_40"] = {
						["color"] = {
							["a"] = 0.2727272727272727,
							["b"] = 0.2,
							["g"] = 0.8,
							["r"] = 0.4,
						},
						["priority"] = 40,
						["enable"] = true,
						["text"] = "40 미터",
						["range"] = false,
						["desc"] = "40 미터 이상",
					},
					["alert_range_28"] = {
						["color"] = {
							["a"] = 0.490909090909091,
							["b"] = 0.84,
							["g"] = 0.5600000000000001,
							["r"] = 0.28,
						},
						["priority"] = 22,
						["enable"] = true,
						["text"] = "28 미터",
						["range"] = false,
						["desc"] = "28 미터 이상",
					},
					["alert_range_30"] = {
						["color"] = {
							["a"] = 0.4545454545454546,
							["b"] = 0.9,
							["g"] = 0.6,
							["r"] = 0.3,
						},
						["priority"] = 24,
						["enable"] = false,
						["text"] = "30 미터",
						["range"] = false,
						["desc"] = "30 미터 이상",
					},
					["alert_range_100"] = {
						["color"] = {
							["a"] = 0.1090909090909091,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["priority"] = 80,
						["enable"] = false,
						["text"] = "100 미터",
						["range"] = false,
						["desc"] = "100 미터 이상",
					},
				},
			},
		},
		["GridStatus"] = {
			["profiles"] = {
				["Default"] = {
					["colors"] = {
						["HUNTER"] = {
							["a"] = 1,
							["b"] = 0.45,
							["g"] = 0.83,
							["r"] = 0.67,
						},
						["PALADIN"] = {
							["a"] = 1,
							["b"] = 0.73,
							["g"] = 0.55,
							["r"] = 0.96,
						},
						["DRUID"] = {
							["a"] = 1,
							["b"] = 0.04,
							["g"] = 0.49,
							["r"] = 1,
						},
						["DEATHKNIGHT"] = {
							["r"] = 0.77,
							["g"] = 0.12,
							["b"] = 0.23,
						},
						["MAGE"] = {
							["a"] = 1,
							["b"] = 0.94,
							["g"] = 0.8,
							["r"] = 0.41,
						},
						["ROGUE"] = {
							["a"] = 1,
							["b"] = 0.41,
							["g"] = 0.96,
							["r"] = 1,
						},
						["SHAMAN"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 0.35,
							["r"] = 0.14,
						},
						["PRIEST"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["WARLOCK"] = {
							["a"] = 1,
							["b"] = 0.79,
							["g"] = 0.51,
							["r"] = 0.58,
						},
						["WARRIOR"] = {
							["a"] = 1,
							["b"] = 0.43,
							["g"] = 0.61,
							["r"] = 0.78,
						},
					},
				},
			},
		},
		["GridCooldownText"] = {
			["profiles"] = {
				["Default"] = {
					["FontSize"] = 11,
					["Font"] = "기본 글꼴",
				},
			},
		},
		["GridStatusHealth"] = {
			["profiles"] = {
				["Default"] = {
					["unit_healthDeficit"] = {
						["useClassColors"] = false,
						["color"] = {
							["b"] = 0,
							["g"] = 0.1058823529411765,
						},
						["priority"] = 40,
						["enable"] = false,
					},
					["alert_lowHealth"] = {
						["enable"] = false,
					},
					["alert_death"] = {
						["priority"] = 1,
					},
					["unit_health"] = {
						["deadAsFullHealth"] = false,
					},
				},
			},
		},
		["GridStatusHeals"] = {
			["profiles"] = {
				["Default"] = {
					["alert_heals"] = {
						["enable"] = false,
					},
				},
			},
		},
		["GridLayout"] = {
			["profiles"] = {
				["Default"] = {
					["anchorRel"] = "TOPLEFT",
					["BorderB"] = 0.5019607843137255,
					["layouts"] = {
						["party"] = "없음",
						["solo"] = "없음",
						["raid"] = "25인 공격대",
					},
					["BackgroundB"] = 0,
					["FrameDisplay"] = "Raid",
					["BorderA"] = 0,
					["BorderR"] = 0.5019607843137255,
					["PosX"] = 1139.069529764935,
					["BackgroundG"] = 0,
					["PosY"] = -330.3901304640473,
					["layout"] = "없음",
					["BackgroundA"] = 0,
					["BorderG"] = 0.5019607843137255,
					["BackgroundR"] = 0,
					["Padding"] = 0,
					["Spacing"] = 4,
					["borderTexture"] = "None",
				},
			},
		},
	},
	["profiles"] = {
		["Default"] = {
			["minimapPosition"] = 216.402470349694,
			["detachedTooltip"] = {
				["fontSizePercent"] = 1,
			},
			["showText"] = false,
		},
	},
}

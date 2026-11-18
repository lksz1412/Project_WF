PitBull4DB = {
	["namespaces"] = {
		["Aggro"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Aura"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["colors"] = {
							["enemy"] = {
								["Magic"] = {
									[1] = 0.047058823529411799,
									[2] = 0.36078431372549002,
								},
							},
							["friend"] = {
								["my"] = {
									[1] = 0.36470588235294099,
									[3] = 0.25882352941176501,
								},
								["other"] = {
									[1] = 0.28235294117647097,
									[2] = 0.76078431372549005,
									[3] = 1,
								},
							},
							["weapon"] = {
								["quality_color"] = false,
								["weapon"] = {
									[1] = 0.97254901960784301,
									[2] = 1,
									[3] = 0.23529411764705899,
								},
							},
						},
					},
					["layouts"] = {
						["대상"] = {
							["cooldown"] = {
								["my_buffs"] = false,
								["my_debuffs"] = false,
								["weapon_buffs"] = false,
							},
							["cooldown_text"] = {
								["my_buffs"] = true,
								["my_debuffs"] = true,
								["weapon_buffs"] = true,
							},
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_filters_color_by_type"] = {
								[1] = false,
							},
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["my_size"] = 20,
									["offset_y"] = -4,
									["size"] = 20,
									["width"] = 400,
									["width_type"] = "fixed",
								},
								["debuff"] = {
									["anchor"] = "BOTTOMLEFT",
									["frame_level"] = 1,
									["growth"] = "right_down",
									["my_size"] = 32,
									["new_row_size"] = true,
									["offset_y"] = -28,
									["row_spacing"] = 2,
									["size"] = 20,
									["width"] = 400,
									["width_percent"] = 1,
									["width_type"] = "fixed",
								},
							},
							["max_buffs"] = 14,
							["max_debuffs"] = 16,
							["texts"] = {
								["my_debuffs"] = {
									["cooldown_text"] = {
										["color_by_time"] = true,
										["font"] = "데미지 글꼴",
										["size"] = 1,
									},
									["count"] = {
										["font"] = "굵은 글꼴",
									},
								},
							},
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["filter"] = "!C",
									["my_size"] = 14,
									["offset_x"] = -2,
									["offset_y"] = -4,
									["size"] = 14,
									["width"] = 135,
									["width_percent"] = 1,
								},
								["debuff"] = {
									["my_size"] = 14,
									["offset_x"] = 2,
									["offset_y"] = -4,
									["size"] = 14,
									["width_percent"] = 0.55000000000000004,
								},
							},
							["max_buffs"] = 8,
							["max_debuffs"] = 3,
						},
					},
				},
				["Wide_B"] = {
					["global"] = {
						["colors"] = {
							["enemy"] = {
								["Magic"] = {
									[1] = 0.047058823529411799,
									[2] = 0.36078431372549002,
								},
							},
							["friend"] = {
								["my"] = {
									[1] = 0.36470588235294099,
									[3] = 0.25882352941176501,
								},
								["other"] = {
									[1] = 0.28235294117647097,
									[2] = 0.76078431372549005,
									[3] = 1,
								},
							},
							["weapon"] = {
								["quality_color"] = false,
								["weapon"] = {
									[1] = 0.97254901960784301,
									[2] = 1,
									[3] = 0.23529411764705899,
								},
							},
						},
					},
					["layouts"] = {
						["대상"] = {
							["cooldown"] = {
								["my_buffs"] = false,
								["my_debuffs"] = false,
								["weapon_buffs"] = false,
							},
							["cooldown_text"] = {
								["my_buffs"] = true,
								["my_debuffs"] = true,
								["weapon_buffs"] = true,
							},
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_filters_color_by_type"] = {
								[1] = false,
							},
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["my_size"] = 20,
									["offset_y"] = -4,
									["size"] = 20,
									["width"] = 400,
									["width_type"] = "fixed",
								},
								["debuff"] = {
									["anchor"] = "BOTTOMLEFT",
									["frame_level"] = 1,
									["growth"] = "right_down",
									["my_size"] = 32,
									["new_row_size"] = true,
									["offset_y"] = -28,
									["row_spacing"] = 2,
									["size"] = 20,
									["width"] = 400,
									["width_percent"] = 1,
									["width_type"] = "fixed",
								},
							},
							["max_buffs"] = 14,
							["max_debuffs"] = 16,
							["texts"] = {
								["my_debuffs"] = {
									["cooldown_text"] = {
										["color_by_time"] = true,
										["font"] = "데미지 글꼴",
										["size"] = 1,
									},
									["count"] = {
										["font"] = "굵은 글꼴",
									},
								},
							},
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["filter"] = "!C",
									["my_size"] = 14,
									["offset_x"] = -2,
									["offset_y"] = -4,
									["size"] = 14,
									["width"] = 135,
									["width_percent"] = 1,
								},
								["debuff"] = {
									["my_size"] = 14,
									["offset_x"] = 2,
									["offset_y"] = -4,
									["size"] = 14,
									["width_percent"] = 0.55000000000000004,
								},
							},
							["max_buffs"] = 8,
							["max_debuffs"] = 3,
						},
					},
				},
				["Wide_P"] = {
					["global"] = {
						["colors"] = {
							["enemy"] = {
								["Magic"] = {
									[1] = 0.047058823529411799,
									[2] = 0.36078431372549002,
								},
							},
							["friend"] = {
								["my"] = {
									[1] = 0.36470588235294099,
									[3] = 0.25882352941176501,
								},
								["other"] = {
									[1] = 0.28235294117647097,
									[2] = 0.76078431372549005,
									[3] = 1,
								},
							},
							["weapon"] = {
								["quality_color"] = false,
								["weapon"] = {
									[1] = 0.97254901960784301,
									[2] = 1,
									[3] = 0.23529411764705899,
								},
							},
						},
					},
					["layouts"] = {
						["대상"] = {
							["cooldown"] = {
								["my_buffs"] = false,
								["my_debuffs"] = false,
								["weapon_buffs"] = false,
							},
							["cooldown_text"] = {
								["my_buffs"] = true,
								["my_debuffs"] = true,
								["weapon_buffs"] = true,
							},
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_filters_color_by_type"] = {
								[1] = false,
							},
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["growth"] = "right_up",
									["my_size"] = 20,
									["offset_x"] = 15,
									["offset_y"] = -25,
									["side"] = "LEFT",
									["size"] = 20,
									["width"] = 400,
									["width_type"] = "fixed",
								},
								["debuff"] = {
									["anchor"] = "TOPLEFT",
									["frame_level"] = 1,
									["growth"] = "right_up",
									["my_size"] = 32,
									["new_row_size"] = true,
									["offset_y"] = 20,
									["row_spacing"] = 2,
									["side"] = "TOP",
									["size"] = 20,
									["width"] = 400,
									["width_percent"] = 1,
									["width_type"] = "fixed",
								},
							},
							["max_buffs"] = 14,
							["max_debuffs"] = 16,
							["texts"] = {
								["my_debuffs"] = {
									["cooldown_text"] = {
										["color_by_time"] = true,
										["font"] = "데미지 글꼴",
										["size"] = 1,
									},
									["count"] = {
										["font"] = "굵은 글꼴",
									},
								},
							},
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["layout"] = {
								["buff"] = {
									["offset_y"] = -5,
								},
							},
						},
						["파티"] = {
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["filter"] = "!C",
									["my_size"] = 14,
									["offset_x"] = -2,
									["offset_y"] = -4,
									["size"] = 14,
									["width"] = 135,
									["width_percent"] = 1,
								},
								["debuff"] = {
									["my_size"] = 14,
									["offset_x"] = 2,
									["offset_y"] = -4,
									["size"] = 14,
									["width_percent"] = 0.55000000000000004,
								},
							},
							["max_buffs"] = 8,
							["max_debuffs"] = 3,
						},
					},
				},
				["Wide_T"] = {
					["global"] = {
						["colors"] = {
							["enemy"] = {
								["Magic"] = {
									[1] = 0.047058823529411799,
									[2] = 0.36078431372549002,
								},
							},
							["friend"] = {
								["my"] = {
									[1] = 0.36470588235294099,
									[3] = 0.25882352941176501,
								},
								["other"] = {
									[1] = 0.28235294117647097,
									[2] = 0.76078431372549005,
									[3] = 1,
								},
							},
							["weapon"] = {
								["quality_color"] = false,
								["weapon"] = {
									[1] = 0.97254901960784301,
									[2] = 1,
									[3] = 0.23529411764705899,
								},
							},
						},
					},
					["layouts"] = {
						["대상"] = {
							["cooldown"] = {
								["my_buffs"] = false,
								["my_debuffs"] = false,
								["weapon_buffs"] = false,
							},
							["cooldown_text"] = {
								["my_buffs"] = true,
								["my_debuffs"] = true,
								["weapon_buffs"] = true,
							},
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_filters_color_by_type"] = {
								[1] = false,
							},
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["growth"] = "right_up",
									["my_size"] = 15,
									["offset_x"] = 15,
									["offset_y"] = -15,
									["side"] = "LEFT",
									["size"] = 15,
									["width"] = 400,
									["width_type"] = "fixed",
								},
								["debuff"] = {
									["anchor"] = "TOPLEFT",
									["frame_level"] = 1,
									["growth"] = "right_up",
									["my_size"] = 32,
									["new_row_size"] = true,
									["offset_y"] = 5,
									["row_spacing"] = 2,
									["side"] = "TOP",
									["size"] = 15,
									["width"] = 400,
									["width_percent"] = 1,
									["width_type"] = "fixed",
								},
							},
							["max_buffs"] = 14,
							["max_debuffs"] = 16,
							["texts"] = {
								["my_debuffs"] = {
									["cooldown_text"] = {
										["color_by_time"] = true,
										["font"] = "데미지 글꼴",
										["size"] = 1,
									},
									["count"] = {
										["font"] = "굵은 글꼴",
									},
								},
							},
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["layout"] = {
								["buff"] = {
									["offset_y"] = -5,
								},
							},
						},
						["파티"] = {
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["filter"] = "!C",
									["my_size"] = 14,
									["offset_x"] = -2,
									["offset_y"] = -4,
									["size"] = 14,
									["width"] = 135,
									["width_percent"] = 1,
								},
								["debuff"] = {
									["my_size"] = 14,
									["offset_x"] = 2,
									["offset_y"] = -4,
									["size"] = 14,
									["width_percent"] = 0.55000000000000004,
								},
							},
							["max_buffs"] = 8,
							["max_debuffs"] = 3,
						},
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["colors"] = {
							["enemy"] = {
								["Magic"] = {
									[1] = 0.047058823529411799,
									[2] = 0.36078431372549002,
								},
							},
							["friend"] = {
								["my"] = {
									[1] = 0.36470588235294099,
									[3] = 0.25882352941176501,
								},
								["other"] = {
									[1] = 0.28235294117647097,
									[2] = 0.76078431372549005,
									[3] = 1,
								},
							},
							["weapon"] = {
								["quality_color"] = false,
								["weapon"] = {
									[1] = 0.97254901960784301,
									[2] = 1,
									[3] = 0.23529411764705899,
								},
							},
						},
					},
					["layouts"] = {
						["대상"] = {
							["cooldown"] = {
								["my_buffs"] = false,
								["my_debuffs"] = false,
								["weapon_buffs"] = false,
							},
							["cooldown_text"] = {
								["my_buffs"] = true,
								["my_debuffs"] = true,
								["weapon_buffs"] = true,
							},
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_filters_color_by_type"] = {
								[1] = false,
							},
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["growth"] = "right_up",
									["my_size"] = 20,
									["offset_x"] = 15,
									["offset_y"] = -25,
									["side"] = "LEFT",
									["size"] = 20,
									["width"] = 400,
									["width_type"] = "fixed",
								},
								["debuff"] = {
									["anchor"] = "TOPLEFT",
									["frame_level"] = 1,
									["growth"] = "right_up",
									["my_size"] = 20,
									["new_row_size"] = true,
									["offset_x"] = -5,
									["offset_y"] = 8,
									["row_spacing"] = 2,
									["side"] = "TOP",
									["size"] = 18,
									["width"] = 400,
									["width_percent"] = 1,
									["width_type"] = "fixed",
								},
							},
							["max_buffs"] = 14,
							["max_debuffs"] = 16,
							["texts"] = {
								["my_debuffs"] = {
									["cooldown_text"] = {
										["color_by_time"] = true,
										["font"] = "데미지 글꼴",
										["size"] = 1,
									},
									["count"] = {
										["font"] = "굵은 글꼴",
									},
								},
							},
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["layout"] = {
								["buff"] = {
									["offset_y"] = -5,
								},
							},
						},
						["파티"] = {
							["enabled_weapons"] = false,
							["highlight"] = false,
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["filter"] = "!C",
									["my_size"] = 14,
									["offset_x"] = -2,
									["offset_y"] = -4,
									["size"] = 14,
									["width"] = 135,
									["width_percent"] = 1,
								},
								["debuff"] = {
									["my_size"] = 14,
									["offset_x"] = 2,
									["offset_y"] = -4,
									["size"] = 14,
									["width_percent"] = 0.55000000000000004,
								},
							},
							["max_buffs"] = 8,
							["max_debuffs"] = 3,
						},
					},
				},
			},
		},
		["Background"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["대상의대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["보통"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["파티"] = {
							["color"] = {
								[4] = 1,
							},
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["대상의대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["보통"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["파티"] = {
							["color"] = {
								[4] = 1,
							},
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["대상의대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["보통"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["파티"] = {
							["color"] = {
								[4] = 1,
							},
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["대상의대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["보통"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["파티"] = {
							["color"] = {
								[4] = 1,
							},
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["대상의대상"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["보통"] = {
							["color"] = {
								[4] = 1,
							},
						},
						["파티"] = {
							["color"] = {
								[4] = 1,
							},
						},
					},
				},
			},
		},
		["BattlePet"] = {
			["profiles"] = {},
		},
		["BlankSpace"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
				},
			},
		},
		["Border"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["대상의대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["보통"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["파티"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["대상의대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["보통"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["파티"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["대상의대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["보통"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["파티"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["대상의대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["보통"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["파티"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["대상의대상"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["보통"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
						["파티"] = {
							["boss_texture"] = "Devil",
							["elite_color"] = {
								[2] = 0.70588235294117696,
								[3] = 0.188235294117647,
								[4] = 0.68000000715255704,
							},
							["elite_texture"] = "Devil",
							["normal_color"] = {
								[4] = 0.65999999642372098,
							},
							["normal_texture"] = "Devil",
							["rare_color"] = {
								[1] = 0.25882352941176501,
								[2] = 0.72941176470588198,
								[3] = 1,
								[4] = 0.75,
							},
							["rare_texture"] = "Devil",
							["size"] = 12,
						},
					},
				},
			},
		},
		["CastBar"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["대상의대상"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["대상"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["대상의대상"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["hostility_color_npcs"] = true,
							["size"] = 2,
							["texture"] = "Minimalist",
						},
						["대상의대상"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["hostility_color_npcs"] = true,
							["size"] = 2,
							["texture"] = "Minimalist",
						},
						["대상의대상"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["hostility_color_npcs"] = true,
							["size"] = 2,
							["texture"] = "Minimalist",
						},
						["대상의대상"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["auto_hide"] = true,
							["background_alpha"] = 0.5,
							["enabled"] = false,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
					},
				},
			},
		},
		["CastBarLatency"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Chi"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["inactive_color"] = {
								[1] = 1,
								[2] = 1,
								[3] = 1,
								[4] = 1,
							},
							["location"] = "left",
							["size"] = 1.25,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["inactive_color"] = {
								[1] = 1,
								[2] = 1,
								[3] = 1,
								[4] = 1,
							},
							["location"] = "left",
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["CombatFader"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CombatIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000100000000001,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.0000100000000001,
						},
						["보통"] = {
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
						["파티"] = {
							["enabled"] = false,
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000100000000001,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.0000100000000001,
						},
						["보통"] = {
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
						["파티"] = {
							["enabled"] = false,
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000100000000001,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.0000100000000001,
						},
						["보통"] = {
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
						["파티"] = {
							["enabled"] = false,
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["location"] = "edge_top_right",
							["position"] = 1.0000100000000001,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.0000100000000001,
						},
						["보통"] = {
							["location"] = "edge_top_left",
							["position"] = 1.0000100000000001,
						},
						["파티"] = {
							["enabled"] = false,
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000199999999999,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.0000100000000001,
						},
						["보통"] = {
							["location"] = "edge_bottom_right",
							["position"] = 1.0000100000000001,
						},
						["파티"] = {
							["enabled"] = false,
							["location"] = "edge_bottom_right",
							["position"] = 1.0000199999999999,
						},
					},
				},
			},
		},
		["CombatText"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000100000000001,
						},
						["대상의대상"] = {
							["position"] = 1.0000100000000001,
						},
					},
				},
			},
		},
		["ComboPoints"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["대상의대상"] = {
							["attach_to"] = "Portrait",
							["enabled"] = false,
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["보통"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["size"] = 1,
						},
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["대상의대상"] = {
							["attach_to"] = "Portrait",
							["enabled"] = false,
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["보통"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["size"] = 1,
						},
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["대상의대상"] = {
							["attach_to"] = "Portrait",
							["enabled"] = false,
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["보통"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["size"] = 1,
						},
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["대상의대상"] = {
							["attach_to"] = "Portrait",
							["enabled"] = false,
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["보통"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["size"] = 1,
						},
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["대상의대상"] = {
							["attach_to"] = "Portrait",
							["enabled"] = false,
							["location"] = "bottom",
							["position"] = 1.00003,
							["spacing"] = 0,
						},
						["보통"] = {
							["attach_to"] = "Portrait",
							["location"] = "bottom",
							["position"] = 1.00003,
							["size"] = 1,
						},
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
					},
				},
			},
		},
		["DogTagTexts"] = {
			["profiles"] = {
				["Wide_P"] = {
					["layouts"] = {
						["Normal"] = {
							["elements"] = {
								["Lua:Alternate power"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Cast"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:Cast time"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Class"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:Demonic fury"] = {
									["attach_to"] = "DemonicFury",
									["code"] = "return \"%s/%s\",Power(unit,SPELL_POWER_DEMONIC_FURY),MaxPower(unit,SPELL_POWER_DEMONIC_FURY)\
",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Druid mana"] = {
									["attach_to"] = "DruidManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Eclipse"] = {
									["attach_to"] = "Eclipse",
									["code"] = "return math.abs(Power(unit,SPELL_POWER_ECLIPSE))\
",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Experience"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Health"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Name"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:PVPTimer"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:Power"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Reputation"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, min , max, value, id = GetWatchedFactionInfo()\
if IsMouseOver() then\
  return name or ConfigMode() \
else\
  local fs_id, fs_rep, _, _, _, _, _, fs_threshold, next_fs_threshold = GetFriendshipReputation(id)\
  if fs_id then\
    if next_fs_threshold then\
      min, max, value = fs_threshold, next_fs_threshold, fs_rep\
    else\
      min, max, value = 0, 1, 1\
    end\
  end\
  local bar_cur,bar_max = value-min,max-min\
  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Threat"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["대상"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_right",
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_right",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
return \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
									["events"] = {
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s || %s%%\",HP(unit),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.84999999999999998,
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "if UnitIsPlayer(unit) then\
  local cr,cg,cb = ClassColor(unit)\
  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\
end",
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["Normal"] = {
							["elements"] = {
								["Lua:Alternate power"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Cast"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:Cast time"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Class"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:Demonic fury"] = {
									["attach_to"] = "DemonicFury",
									["code"] = "return \"%s/%s\",Power(unit,SPELL_POWER_DEMONIC_FURY),MaxPower(unit,SPELL_POWER_DEMONIC_FURY)\
",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Druid mana"] = {
									["attach_to"] = "DruidManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Eclipse"] = {
									["attach_to"] = "Eclipse",
									["code"] = "return math.abs(Power(unit,SPELL_POWER_ECLIPSE))\
",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Experience"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Health"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Name"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:PVPTimer"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:Power"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Reputation"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, min , max, value, id = GetWatchedFactionInfo()\
if IsMouseOver() then\
  return name or ConfigMode() \
else\
  local fs_id, fs_rep, _, _, _, _, _, fs_threshold, next_fs_threshold = GetFriendshipReputation(id)\
  if fs_id then\
    if next_fs_threshold then\
      min, max, value = fs_threshold, next_fs_threshold, fs_rep\
    else\
      min, max, value = 0, 1, 1\
    end\
  end\
  local bar_cur,bar_max = value-min,max-min\
  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Threat"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["대상"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_right",
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_right",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
return \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
									["events"] = {
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s || %s%%\",HP(unit),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.84999999999999998,
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "if UnitIsPlayer(unit) then\
  local cr,cg,cb = ClassColor(unit)\
  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\
end",
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["Normal"] = {
							["elements"] = {
								["Lua:Alternate power"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Cast"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:Cast time"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Class"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:Demonic fury"] = {
									["attach_to"] = "DemonicFury",
									["code"] = "return \"%s/%s\",Power(unit,SPELL_POWER_DEMONIC_FURY),MaxPower(unit,SPELL_POWER_DEMONIC_FURY)\
",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Druid mana"] = {
									["attach_to"] = "DruidManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Eclipse"] = {
									["attach_to"] = "Eclipse",
									["code"] = "return math.abs(Power(unit,SPELL_POWER_ECLIPSE))\
",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Experience"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Health"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Name"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:PVPTimer"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:Power"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:Reputation"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, min , max, value, id = GetWatchedFactionInfo()\
if IsMouseOver() then\
  return name or ConfigMode() \
else\
  local fs_id, fs_rep, _, _, _, _, _, fs_threshold, next_fs_threshold = GetFriendshipReputation(id)\
  if fs_id then\
    if next_fs_threshold then\
      min, max, value = fs_threshold, next_fs_threshold, fs_rep\
    else\
      min, max, value = 0, 1, 1\
    end\
  end\
  local bar_cur,bar_max = value-min,max-min\
  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:Threat"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["대상"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_right",
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_right",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
return \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
									["events"] = {
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s || %s%%\",HP(unit),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.84999999999999998,
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "if UnitIsPlayer(unit) then\
  local cr,cg,cb = ClassColor(unit)\
  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\
end",
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
					},
				},
			},
		},
		["Eclipse"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_bottom_right",
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_bottom_right",
						},
					},
				},
			},
		},
		["ExperienceBar"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["HappinessIcon"] = {
			["profiles"] = {
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["location"] = "edge_left",
						},
						["파티"] = {
							["location"] = "edge_top_left",
							["position"] = 1.0000100000000001,
						},
					},
				},
			},
		},
		["HealthBar"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["color_pvp_by_class"] = true,
							["size"] = 5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["color_pvp_by_class"] = true,
							["size"] = 5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["color_pvp_by_class"] = true,
							["size"] = 5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
							["position"] = 1.0000100000000001,
							["size"] = 5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["color_by_class"] = true,
							["color_pvp_by_class"] = true,
							["size"] = 5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
							["color_by_class"] = true,
							["position"] = 1.0000100000000001,
							["size"] = 5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
							["color_pvp_by_class"] = true,
							["size"] = 5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
							["position"] = 1.0000100000000001,
							["size"] = 5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
					},
				},
			},
		},
		["HideBlizzard"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["castbar"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["castbar"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["castbar"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["castbar"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["castbar"] = false,
					},
				},
			},
		},
		["Highlight"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["HolyPower"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["inactive_color"] = {
								[1] = 0,
								[2] = 0,
								[3] = 0,
								[4] = 0,
							},
							["location"] = "left",
							["size"] = 1.25,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["inactive_color"] = {
								[1] = 0,
								[2] = 0,
								[3] = 0,
								[4] = 0,
							},
							["location"] = "left",
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["HostilityFader"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["LeaderIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["position"] = 1.00003,
						},
					},
				},
			},
		},
		["LuaTexts"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["enabled"] = false,
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_right",
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["enabled"] = false,
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_right",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
return \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
									["events"] = {
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s || %s%%\",HP(unit),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.84999999999999998,
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "if UnitIsPlayer(unit) then\
  local cr,cg,cb = ClassColor(unit)\
  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\
end",
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["enabled"] = false,
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_left",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_right",
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["enabled"] = false,
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["font"] = "데미지 글꼴",
									["location"] = "out_top_right",
									["position"] = 1.0000100000000001,
									["size"] = 0.84999999999999998,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
return \"%s/%s\",HP(unit),MaxHP(unit)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
									["size"] = 1.3500000000000001,
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
return \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
									["events"] = {
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.84999999999999998,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.75,
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s || %s%%\",HP(unit),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
									["size"] = 0.84999999999999998,
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell \
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
								["Lua:이름"] = {
									["code"] = "local r,g,b = ClassColor(unit)\
return '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "out_top_left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "if UnitIsPlayer(unit) then\
  local cr,cg,cb = ClassColor(unit)\
  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\
end",
									["exists"] = true,
									["location"] = "left",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:PVP 타이머"] = {
									["code"] = "if unit == \"player\" then\
  local pvp = PVPDuration()\
  if pvp then\
    return \"|cffff0000%s|r\",FormatDuration(pvp)\
  end\
end",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "out_right_top",
								},
								["Lua:경험치"] = {
									["attach_to"] = "ExperienceBar",
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\
if rest then\
  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\
else\
  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["PLAYER_XP_UPDATE"] = true,
										["UNIT_PET_EXPERIENCE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:드루이드 마나"] = {
									["attach_to"] = "AltManaBar",
									["code"] = "if UnitPowerType(unit) ~= 0 then\
  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\
end",
									["events"] = {
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:마력"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local max = MaxPower(unit)\
if max > 0 then\
  return \"%s/%s\",Power(unit),max\
end",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:보조 마력"] = {
									["attach_to"] = "AltPowerBar",
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\
if max > 0 then\
  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:생명력"] = {
									["attach_to"] = "HealthBar",
									["code"] = "local s = Status(unit)\
if s then\
  return s\
end\
local cur, max = HP(unit), MaxHP(unit)\
return \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:시전"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\
  local stop_time,stop_duration = cast_data.stop_time\
  if stop_time then\
    stop_duration = GetTime() - stop_time\
  end\
  Alpha(-(stop_duration or 0) + 1)\
  if stop_message then\
    return stop_message\
  elseif target then\
    return \"%s (%s)\",spell,target\
  else\
    return spell\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:시전 시간"] = {
									["attach_to"] = "CastBar",
									["code"] = "local cast_data = CastData(unit)\
if cast_data then\
  if not cast_data.stop_time then\
    local delay,end_time = cast_data.delay, cast_data.end_time\
    local duration\
    if end_time then\
      duration = end_time - GetTime()\
    end\
    if delay and delay ~= 0 then\
      local delay_sign = '+'\
      if delay < 0 then\
        delay_sign = ''\
      end\
      if duration and duration >= 0 then\
        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\
      else\
        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\
      end\
    elseif duration and duration >= 0 then\
      return \"%.1f\",duration\
    end\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
									},
									["exists"] = true,
									["location"] = "right",
								},
								["Lua:위협 수준"] = {
									["attach_to"] = "ThreatBar",
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\
if unit_a and unit_b then\
  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\
  if percent and percent ~= 0 then\
    return \"%s%%\",Round(percent,1)\
  end\
end\
return ConfigMode()",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:유물력"] = {
									["attach_to"] = "ArtifactPowerBar",
									["code"] = "local cur,max,points = ArtifactPower()\
if max > 0 then\
  if points > 0 then\
    return \"%s/%s (%d)\",cur,max,points\
  end\
  return \"%s/%s\",cur,max\
end\
return ConfigMode()",
									["events"] = {
										["ARTIFACT_XP_UPDATE"] = true,
										["AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED"] = true,
										["AZERITE_ITEM_EXPERIENCE_CHANGED"] = true,
										["AZERITE_ITEM_POWER_LEVEL_CHANGED"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
								["Lua:이름"] = {
									["attach_to"] = "HealthBar",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:직업"] = {
									["attach_to"] = "PowerBar",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\
local form = DruidForm(unit)\
local classification = Classification(unit)\
if UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\
  local cr,cg,cb = ClassColor(unit)\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\
  end\
else\
  if form then\
    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\
  else\
    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\
  end\
end",
									["events"] = {
										["UNIT_AURA"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["exists"] = true,
									["location"] = "left",
								},
								["Lua:평판"] = {
									["attach_to"] = "ReputationBar",
									["code"] = "local name, _, _, max, cur = WatchedFactionInfo()\
if not name then return ConfigMode() end\
if IsMouseOver() then\
  return name\
else\
  return \"%d/%d (%s%%)\",cur,max,Percent(cur,max)\
end",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["location"] = "center",
								},
							},
							["first"] = false,
						},
					},
				},
			},
		},
		["MasterLooterIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["PhaseIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["position"] = 1.0000100000000001,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["보통"] = {
							["position"] = 1.0000100000000001,
						},
					},
				},
			},
		},
		["Portrait"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["side"] = "right",
						},
						["대상의대상"] = {
							["fallback_style"] = "two_dimensional",
							["side"] = "right",
						},
						["보통"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["position"] = 1.0000100000000001,
							["style"] = "two_dimensional",
						},
						["파티"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["style"] = "two_dimensional",
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["side"] = "right",
						},
						["대상의대상"] = {
							["fallback_style"] = "two_dimensional",
							["side"] = "right",
						},
						["보통"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["position"] = 1.0000100000000001,
							["style"] = "two_dimensional",
						},
						["파티"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["style"] = "two_dimensional",
						},
					},
				},
			},
		},
		["PowerBar"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["enabled"] = false,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["enabled"] = false,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["enabled"] = false,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["enabled"] = false,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["background_alpha"] = 0.5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["enabled"] = false,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
						},
						["파티"] = {
							["background_alpha"] = 0.5,
						},
					},
				},
			},
		},
		["PvPIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["QuestIcon"] = {
			["profiles"] = {},
		},
		["RaidTargetIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["size"] = 1.3,
						},
						["보통"] = {
							["size"] = 1.25,
						},
						["파티"] = {
							["size"] = 1.25,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["size"] = 1.3,
						},
						["보통"] = {
							["size"] = 1.25,
						},
						["파티"] = {
							["size"] = 1.25,
						},
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["대상"] = {
							["size"] = 1.3,
						},
						["보통"] = {
							["size"] = 1.25,
						},
						["파티"] = {
							["size"] = 1.25,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["대상"] = {
							["size"] = 1.3,
						},
						["보통"] = {
							["size"] = 1.25,
						},
						["파티"] = {
							["size"] = 1.25,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["size"] = 1.3,
						},
						["보통"] = {
							["size"] = 1.25,
						},
						["파티"] = {
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["RangeFader"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ReadyCheckIcon"] = {
			["profiles"] = {
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000100000000001,
						},
						["파티"] = {
							["position"] = 1.0000100000000001,
						},
					},
				},
			},
		},
		["ReputationBar"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RestIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000199999999999,
							["size"] = 1.25,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00003,
							["size"] = 1.25,
						},
						["보통"] = {
							["position"] = 1.0000100000000001,
							["size"] = 1.25,
						},
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.0000100000000001,
							["size"] = 1.25,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000199999999999,
							["size"] = 1.25,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00003,
							["size"] = 1.25,
						},
						["보통"] = {
							["position"] = 1.0000100000000001,
							["size"] = 1.25,
						},
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.0000100000000001,
							["size"] = 1.25,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["대상"] = {
							["position"] = 1.0000100000000001,
						},
						["파티"] = {
							["position"] = 1.0000100000000001,
						},
					},
				},
			},
		},
		["RoleIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["파티"] = {
							["position"] = 1.0000199999999999,
						},
					},
				},
			},
		},
		["Runes"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["layouts"] = {
						["보통"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_T"] = {
					["layouts"] = {
						["보통"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide_WH"] = {
					["layouts"] = {
						["보통"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["ShadowOrbs"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["inactive_color"] = {
								[1] = 0,
								[2] = 0,
								[3] = 0,
								[4] = 1,
							},
							["location"] = "left",
							["size"] = 1.25,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["inactive_color"] = {
								[1] = 0,
								[2] = 0,
								[3] = 0,
								[4] = 1,
							},
							["location"] = "left",
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["SoulShards"] = {
			["profiles"] = {
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["location"] = "left",
							["size"] = 1,
						},
					},
				},
				["Wide_B"] = {
					["layouts"] = {
						["보통"] = {
							["attach_to"] = "HealthBar",
							["background_color"] = {
								[4] = 0,
							},
							["location"] = "left",
							["size"] = 1,
						},
					},
				},
			},
		},
		["Sounds"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ThreatBar"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Totems"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["VisualHeal"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_P"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_T"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_WH"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["VoiceIcon"] = {
			["profiles"] = {
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide_B"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
	},
	["profiles"] = {
		["Wide"] = {
			["class_order"] = {
				[1] = "WARRIOR",
				[2] = "PALADIN",
				[3] = "PRIEST",
				[4] = "SHAMAN",
				[5] = "DRUID",
				[6] = "ROGUE",
				[7] = "MAGE",
				[8] = "WARLOCK",
				[9] = "HUNTER",
			},
			["colors"] = {
				["power"] = {
					["ENERGY"] = {
						[2] = 0.97254901960784301,
						[3] = 0.59607843137254901,
					},
					["MANA"] = {
						[1] = 0.37254901960784298,
						[2] = 0.52549019607843095,
					},
				},
			},
			["frame_snap"] = false,
			["groups"] = {
				["파티"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "파티",
					["position_x"] = 25.238095238095411,
					["position_y"] = 340,
					["relative_point"] = "LEFT",
					["vertical_spacing"] = 40,
				},
				["파티원 대상"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 205.23809523809541,
					["position_y"] = 340,
					["relative_point"] = "LEFT",
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partytarget",
					["vertical_spacing"] = 69,
				},
				["파티원 소환수"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 205.23809523809541,
					["position_y"] = 310,
					["relative_point"] = "LEFT",
					["scale"] = 0.84999999999999998,
					["size_y"] = 0.75,
					["unit_group"] = "partypet",
					["vertical_spacing"] = 75,
				},
			},
			["layouts"] = {
				["대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["level"] = 25,
					["size_x"] = 240,
				},
				["대상의대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["size_x"] = 100,
					["size_y"] = 25,
				},
				["보통"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 240,
				},
				["파티"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 160,
					["size_y"] = 40,
				},
			},
			["lock_movement"] = true,
			["made_groups"] = true,
			["made_units"] = true,
			["minimap_icon"] = {
				["hide"] = true,
				["minimapPos"] = 273.50954102693998,
			},
			["units"] = {
				["대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상",
					["position_x"] = 305.23809523809541,
					["position_y"] = 470,
					["relative_point"] = "LEFT",
					["unit"] = "target",
				},
				["대상의 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 575.23809523809541,
					["position_y"] = 490,
					["relative_point"] = "LEFT",
					["unit"] = "targettarget",
				},
				["대상의 대상의 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 575.23809523809541,
					["position_y"] = 450,
					["relative_point"] = "LEFT",
					["unit"] = "targettargettarget",
				},
				["주시 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "파티",
					["position_x"] = 395.23809523809541,
					["position_y"] = 330,
					["relative_point"] = "LEFT",
					["unit"] = "focus",
				},
				["주시 대상의 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 580.23809523809541,
					["position_y"] = 340,
					["relative_point"] = "LEFT",
					["scale"] = 0.90000000000000002,
					["unit"] = "focustarget",
				},
				["주시 대상의 대상의 대상"] = {
					["layout"] = "대상의대상",
					["position_x"] = -116,
					["position_y"] = 256,
					["scale"] = 0.90000000000000002,
					["unit"] = "focustargettarget",
				},
				["플레이어"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["position_x"] = 29.941449119931349,
					["position_y"] = 470,
					["relative_point"] = "LEFT",
					["unit"] = "player",
				},
				["플레이어의 소환수"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "파티",
					["position_x"] = 53.238095238095411,
					["position_y"] = 400,
					["relative_point"] = "LEFT",
					["scale"] = 0.90000000000000002,
					["unit"] = "pet",
				},
				["플레이어의 소환수의 대상"] = {
					["layout"] = "대상의대상",
					["position_x"] = -432,
					["position_y"] = 352,
					["scale"] = 0.75,
					["unit"] = "pettarget",
				},
			},
		},
		["Wide_B"] = {
			["class_order"] = {
				[1] = "WARRIOR",
				[2] = "PALADIN",
				[3] = "PRIEST",
				[4] = "SHAMAN",
				[5] = "DRUID",
				[6] = "ROGUE",
				[7] = "MAGE",
				[8] = "WARLOCK",
				[9] = "HUNTER",
			},
			["colors"] = {
				["power"] = {
					["ENERGY"] = {
						[2] = 0.97254901960784301,
						[3] = 0.59607843137254901,
					},
					["MANA"] = {
						[1] = 0.37254901960784298,
						[2] = 0.52549019607843095,
					},
				},
			},
			["frame_snap"] = false,
			["groups"] = {
				["파티"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "파티",
					["position_x"] = 25.238095238095411,
					["position_y"] = 340,
					["relative_point"] = "LEFT",
					["vertical_spacing"] = 40,
				},
				["파티원 대상"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 205.23809523809541,
					["position_y"] = 340,
					["relative_point"] = "LEFT",
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partytarget",
					["vertical_spacing"] = 69,
				},
				["파티원 소환수"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 205.23809523809541,
					["position_y"] = 310,
					["relative_point"] = "LEFT",
					["scale"] = 0.84999999999999998,
					["size_y"] = 0.75,
					["unit_group"] = "partypet",
					["vertical_spacing"] = 75,
				},
			},
			["layouts"] = {
				["대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["level"] = 25,
					["size_x"] = 240,
				},
				["대상의대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["size_x"] = 100,
					["size_y"] = 25,
				},
				["보통"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 240,
				},
				["파티"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 160,
					["size_y"] = 40,
				},
			},
			["lock_movement"] = true,
			["made_groups"] = true,
			["made_units"] = true,
			["minimap_icon"] = {
				["hide"] = true,
				["minimapPos"] = 273.50954102693998,
			},
			["units"] = {
				["대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상",
					["position_x"] = 305.23809523809541,
					["position_y"] = 470,
					["relative_point"] = "LEFT",
					["unit"] = "target",
				},
				["대상의 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 575.23809523809541,
					["position_y"] = 490,
					["relative_point"] = "LEFT",
					["unit"] = "targettarget",
				},
				["대상의 대상의 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 575.23809523809541,
					["position_y"] = 450,
					["relative_point"] = "LEFT",
					["unit"] = "targettargettarget",
				},
				["주시 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "파티",
					["position_x"] = 395.23809523809541,
					["position_y"] = 330,
					["relative_point"] = "LEFT",
					["unit"] = "focus",
				},
				["주시 대상의 대상"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 667.57120989353143,
					["position_y"] = 247.955628687846,
					["relative_point"] = "LEFT",
					["scale"] = 0.90000000000000002,
					["unit"] = "focustarget",
				},
				["주시 대상의 대상의 대상"] = {
					["layout"] = "대상의대상",
					["position_x"] = -116,
					["position_y"] = 256,
					["scale"] = 0.90000000000000002,
					["unit"] = "focustargettarget",
				},
				["플레이어"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["position_x"] = 29.941449119931349,
					["position_y"] = 470,
					["relative_point"] = "LEFT",
					["unit"] = "player",
				},
				["플레이어의 소환수"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "파티",
					["position_x"] = 53.238095238095411,
					["position_y"] = 400,
					["relative_point"] = "LEFT",
					["scale"] = 0.90000000000000002,
					["unit"] = "pet",
				},
				["플레이어의 소환수의 대상"] = {
					["layout"] = "대상의대상",
					["position_x"] = -432,
					["position_y"] = 352,
					["scale"] = 0.75,
					["unit"] = "pettarget",
				},
			},
		},
		["Wide_P"] = {
			["class_order"] = {
				[1] = "WARRIOR",
				[2] = "PALADIN",
				[3] = "PRIEST",
				[4] = "SHAMAN",
				[5] = "DRUID",
				[6] = "ROGUE",
				[7] = "MAGE",
				[8] = "WARLOCK",
				[9] = "HUNTER",
			},
			["colors"] = {
				["power"] = {
					["ENERGY"] = {
						[2] = 0.97254901960784301,
						[3] = 0.59607843137254901,
					},
					["MANA"] = {
						[1] = 0.37254901960784298,
						[2] = 0.52549019607843095,
					},
				},
			},
			["frame_snap"] = false,
			["groups"] = {
				["파티"] = {
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "파티",
					["position_x"] = -890.62203756593226,
					["position_y"] = 352.59999753166142,
					["scale"] = 0.84999999999999998,
					["vertical_spacing"] = 69,
				},
				["파티원 대상"] = {
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = -712.75545169107022,
					["position_y"] = 350.46669659084478,
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partytarget",
					["vertical_spacing"] = 83,
				},
				["파티원 소환수"] = {
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = -712.75545169107022,
					["position_y"] = 323.8888900374489,
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partypet",
					["vertical_spacing"] = 83,
				},
			},
			["layouts"] = {
				["대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["level"] = 25,
					["scale"] = 0.90000000000000002,
					["size_x"] = 280,
				},
				["대상의대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["scale"] = 0.90000000000000002,
					["size_x"] = 100,
					["size_y"] = 25,
				},
				["보통"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["scale"] = 0.90000000000000002,
					["size_x"] = 280,
				},
				["파티"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["scale"] = 0.90000000000000002,
					["size_y"] = 40,
				},
			},
			["lock_movement"] = true,
			["made_groups"] = true,
			["made_units"] = true,
			["minimap_icon"] = {
				["hide"] = true,
				["minimapPos"] = 273.50954102693998,
			},
			["units"] = {
				["대상"] = {
					["enabled"] = true,
					["layout"] = "대상",
					["position_x"] = 340,
					["position_y"] = -175,
					["unit"] = "target",
				},
				["대상의 대상"] = {
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 265,
					["position_y"] = -255,
					["unit"] = "targettarget",
				},
				["대상의 대상의 대상"] = {
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 390,
					["position_y"] = -255,
					["unit"] = "targettargettarget",
				},
				["주시 대상"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["position_x"] = 160,
					["position_y"] = -550,
					["relative_point"] = "TOPLEFT",
					["unit"] = "focus",
				},
				["주시 대상의 대상"] = {
					["unit"] = "focustarget",
				},
				["주시 대상의 대상의 대상"] = {
					["unit"] = "focustargettarget",
				},
				["플레이어"] = {
					["enabled"] = true,
					["position_x"] = -340,
					["position_y"] = -175,
					["unit"] = "player",
				},
				["플레이어의 소환수"] = {
					["enabled"] = true,
					["layout"] = "파티",
					["position_x"] = -806.64236647851794,
					["position_y"] = 404.8003380669204,
					["scale"] = 0.90000000000000002,
					["unit"] = "pet",
				},
				["플레이어의 소환수의 대상"] = {
					["layout"] = "대상의대상",
					["position_x"] = -432,
					["position_y"] = 352,
					["scale"] = 0.75,
					["unit"] = "pettarget",
				},
			},
		},
		["Wide_T"] = {
			["class_order"] = {
				[1] = "WARRIOR",
				[2] = "PALADIN",
				[3] = "PRIEST",
				[4] = "SHAMAN",
				[5] = "DRUID",
				[6] = "ROGUE",
				[7] = "MAGE",
				[8] = "WARLOCK",
				[9] = "HUNTER",
			},
			["colors"] = {
				["power"] = {
					["ENERGY"] = {
						[2] = 0.97254901960784301,
						[3] = 0.59607843137254901,
					},
					["MANA"] = {
						[1] = 0.37254901960784298,
						[2] = 0.52549019607843095,
					},
				},
			},
			["frame_snap"] = false,
			["groups"] = {
				["파티"] = {
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "파티",
					["position_x"] = -660,
					["position_y"] = 270,
					["scale"] = 0.84999999999999998,
					["vertical_spacing"] = 69,
				},
				["파티원 대상"] = {
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = -480,
					["position_y"] = 270,
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partytarget",
					["vertical_spacing"] = 83,
				},
				["파티원 소환수"] = {
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = -480,
					["position_y"] = 160,
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partypet",
					["vertical_spacing"] = 83,
				},
			},
			["layouts"] = {
				["대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["level"] = 25,
					["size_x"] = 160,
					["size_y"] = 50,
				},
				["대상의대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["scale"] = 0.90000000000000002,
					["size_x"] = 80,
					["size_y"] = 25,
				},
				["보통"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 160,
					["size_y"] = 50,
				},
				["파티"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["scale"] = 0.90000000000000002,
					["size_y"] = 40,
				},
			},
			["lock_movement"] = true,
			["made_groups"] = true,
			["made_units"] = true,
			["minimap_icon"] = {
				["hide"] = true,
				["minimapPos"] = 273.50954102693998,
			},
			["units"] = {
				["대상"] = {
					["enabled"] = true,
					["layout"] = "대상",
					["position_x"] = 245,
					["position_y"] = -120,
					["unit"] = "target",
				},
				["대상의 대상"] = {
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 200,
					["position_y"] = -60,
					["unit"] = "targettarget",
				},
				["대상의 대상의 대상"] = {
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 305,
					["position_y"] = -60,
					["unit"] = "targettargettarget",
				},
				["주시 대상"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["position_x"] = 20,
					["position_y"] = -510,
					["relative_point"] = "TOPLEFT",
					["unit"] = "focus",
				},
				["주시 대상의 대상"] = {
					["unit"] = "focustarget",
				},
				["주시 대상의 대상의 대상"] = {
					["unit"] = "focustargettarget",
				},
				["플레이어"] = {
					["enabled"] = true,
					["position_x"] = -245,
					["position_y"] = -120,
					["unit"] = "player",
				},
				["플레이어의 소환수"] = {
					["enabled"] = true,
					["layout"] = "파티",
					["position_x"] = -245,
					["position_y"] = -50,
					["scale"] = 0.90000000000000002,
					["unit"] = "pet",
				},
				["플레이어의 소환수의 대상"] = {
					["layout"] = "대상의대상",
					["position_x"] = -432,
					["position_y"] = 352,
					["scale"] = 0.75,
					["unit"] = "pettarget",
				},
			},
		},
		["Wide_WH"] = {
			["class_order"] = {
				[1] = "WARRIOR",
				[2] = "PALADIN",
				[3] = "PRIEST",
				[4] = "SHAMAN",
				[5] = "DRUID",
				[6] = "ROGUE",
				[7] = "MAGE",
				[8] = "WARLOCK",
				[9] = "HUNTER",
			},
			["colors"] = {
				["power"] = {
					["ENERGY"] = {
						[2] = 0.97254901960784301,
						[3] = 0.59607843137254901,
					},
					["MANA"] = {
						[1] = 0.37254901960784298,
						[2] = 0.52549019607843095,
					},
				},
			},
			["groups"] = {
				["파티"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "파티",
					["position_x"] = 84.616057672163151,
					["position_y"] = 352.59999753166142,
					["relative_point"] = "LEFT",
					["scale"] = 0.84999999999999998,
					["vertical_spacing"] = 69,
				},
				["파티원 대상"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 262.48264354702519,
					["position_y"] = 350.46669659084478,
					["relative_point"] = "LEFT",
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partytarget",
					["vertical_spacing"] = 83,
				},
				["파티원 소환수"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["exists"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 262.48264354702519,
					["position_y"] = 323.8888900374489,
					["relative_point"] = "LEFT",
					["scale"] = 0.84999999999999998,
					["unit_group"] = "partypet",
					["vertical_spacing"] = 83,
				},
			},
			["layouts"] = {
				["대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["level"] = 25,
					["scale"] = 0.90000000000000002,
					["size_x"] = 280,
				},
				["대상의대상"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["scale"] = 0.90000000000000002,
					["size_x"] = 100,
					["size_y"] = 25,
				},
				["보통"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["scale"] = 0.90000000000000002,
					["size_x"] = 280,
				},
				["파티"] = {
					["bar_padding"] = 1,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
					["scale"] = 0.90000000000000002,
					["size_y"] = 40,
				},
			},
			["lock_movement"] = true,
			["made_groups"] = true,
			["made_units"] = true,
			["minimap_icon"] = {
				["hide"] = true,
				["minimapPos"] = 273.50954102693998,
			},
			["units"] = {
				["대상"] = {
					["enabled"] = true,
					["layout"] = "대상",
					["position_x"] = 340,
					["position_y"] = -175,
					["unit"] = "target",
				},
				["대상의 대상"] = {
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 265,
					["position_y"] = -255,
					["unit"] = "targettarget",
				},
				["대상의 대상의 대상"] = {
					["enabled"] = true,
					["layout"] = "대상의대상",
					["position_x"] = 390,
					["position_y"] = -255,
					["unit"] = "targettargettarget",
				},
				["주시 대상"] = {
					["anchor"] = "TOPLEFT",
					["enabled"] = true,
					["position_x"] = 160,
					["position_y"] = -550,
					["relative_point"] = "TOPLEFT",
					["unit"] = "focus",
				},
				["주시 대상의 대상"] = {
					["unit"] = "focustarget",
				},
				["주시 대상의 대상의 대상"] = {
					["unit"] = "focustargettarget",
				},
				["플레이어"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["position_x"] = 509.23809523809541,
					["position_y"] = -175,
					["relative_point"] = "LEFT",
					["unit"] = "player",
				},
				["플레이어의 소환수"] = {
					["anchor"] = "LEFT",
					["enabled"] = true,
					["layout"] = "파티",
					["position_x"] = 509.23809523809541,
					["position_y"] = -107.4703622750265,
					["relative_point"] = "LEFT",
					["scale"] = 0.90000000000000002,
					["unit"] = "pet",
				},
				["플레이어의 소환수의 대상"] = {
					["layout"] = "대상의대상",
					["position_x"] = -432,
					["position_y"] = 352,
					["scale"] = 0.75,
					["unit"] = "pettarget",
				},
			},
		},
	},
}

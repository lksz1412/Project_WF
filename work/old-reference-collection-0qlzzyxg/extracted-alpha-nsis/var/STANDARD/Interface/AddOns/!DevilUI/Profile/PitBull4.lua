
PitBull4DB = {
	["namespaces"] = {
		["Highlight"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["LibDualSpec-1.0"] = {
		},
		["RangeFader"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CastBarLatency"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["PhaseIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["position"] = 1.00001,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["position"] = 1.00001,
						},
					},
				},
			},
		},
		["CombatIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00001,
							["location"] = "edge_bottom_right",
						},
						["보통"] = {
							["position"] = 1.00001,
							["location"] = "edge_bottom_right",
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00001,
						},
						["대상"] = {
							["position"] = 1.00001,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["location"] = "edge_bottom_right",
							["position"] = 1.00001,
						},
						["대상"] = {
							["position"] = 1.00001,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00001,
						},
						["보통"] = {
							["location"] = "edge_bottom_right",
							["position"] = 1.00001,
						},
					},
				},
			},
		},
		["RoleIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["LuaTexts"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["first"] = false,
							["elements"] = {
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["exists"] = true,
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
								},
							},
						},
						["보통"] = {
							["first"] = false,
							["elements"] = {
								["Lua:생명력"] = {
									["exists"] = true,
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["font"] = "데미지 글꼴",
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["position"] = 1.00001,
									["location"] = "out_top_right",
									["exists"] = true,
									["size"] = 0.8500000000000001,
								},
								["Lua:이름"] = {
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "local r,g,b = ClassColor(unit)\nreturn '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "out_top_left",
									["size"] = 1.35,
								},
								["Lua:직업"] = {
									["events"] = {
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nreturn \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
									["location"] = "left",
									["exists"] = true,
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:마력"] = {
									["events"] = {
										["UNIT_MAXENERGY"] = true,
										["UNIT_MANA"] = true,
										["UNIT_RAGE"] = true,
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXFOCUS"] = true,
										["UNIT_FOCUS"] = true,
										["UNIT_MAXMANA"] = true,
										["UNIT_ENERGY"] = true,
										["UNIT_RUNIC_POWER"] = true,
										["UNIT_MAXRAGE"] = true,
										["UNIT_MAXRUNIC_POWER"] = true,
									},
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["exists"] = true,
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
							},
						},
						["파티"] = {
							["first"] = false,
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s || %s%%\",HP(unit),Percent(cur,max)",
									["location"] = "right",
									["exists"] = true,
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:시전"] = {
									["events"] = {
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["exists"] = true,
									["attach_to"] = "CastBar",
									["size"] = 0.75,
								},
								["Lua:직업"] = {
									["exists"] = true,
									["code"] = "if UnitIsPlayer(unit) then\n  local cr,cg,cb = ClassColor(unit)\n  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\nend",
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
								["Lua:이름"] = {
									["events"] = {
										["UNIT_LEVEL"] = true,
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["code"] = "local r,g,b = ClassColor(unit)\nreturn '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "out_top_left",
								},
								["Lua:마력"] = {
									["events"] = {
										["UNIT_MAXENERGY"] = true,
										["UNIT_MANA"] = true,
										["UNIT_RAGE"] = true,
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXFOCUS"] = true,
										["UNIT_FOCUS"] = true,
										["UNIT_MAXMANA"] = true,
										["UNIT_ENERGY"] = true,
										["UNIT_RUNIC_POWER"] = true,
										["UNIT_MAXRAGE"] = true,
										["UNIT_MAXRUNIC_POWER"] = true,
									},
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["exists"] = true,
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
							},
						},
						["대상"] = {
							["first"] = false,
							["elements"] = {
								["Lua:생명력"] = {
									["exists"] = true,
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
								},
								["Lua:백분율"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["font"] = "데미지 글꼴",
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["position"] = 1.00001,
									["location"] = "out_top_left",
									["exists"] = true,
									["size"] = 0.8500000000000001,
								},
								["Lua:이름"] = {
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "local r,g,b = ClassColor(unit)\nreturn '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "out_top_right",
									["size"] = 1.35,
								},
								["Lua:직업"] = {
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["location"] = "left",
									["exists"] = true,
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:마력"] = {
									["events"] = {
										["UNIT_MAXENERGY"] = true,
										["UNIT_MANA"] = true,
										["UNIT_RAGE"] = true,
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_MAXFOCUS"] = true,
										["UNIT_FOCUS"] = true,
										["UNIT_MAXMANA"] = true,
										["UNIT_ENERGY"] = true,
										["UNIT_RUNIC_POWER"] = true,
										["UNIT_MAXRAGE"] = true,
										["UNIT_MAXRUNIC_POWER"] = true,
									},
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["exists"] = true,
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
							},
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["elements"] = {
								["Lua:이름"] = {
									["exists"] = true,
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
								},
							},
							["first"] = false,
						},
						["대상"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:백분율"] = {
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["location"] = "out_top_left",
									["position"] = 1.00001,
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["size"] = 0.8500000000000001,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "local r,g,b = ClassColor(unit)\nreturn '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "out_top_right",
									["exists"] = true,
									["size"] = 1.35,
								},
								["Lua:직업"] = {
									["exists"] = true,
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["location"] = "left",
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:마력"] = {
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["events"] = {
										["UNIT_MAXENERGY"] = true,
										["UNIT_MANA"] = true,
										["UNIT_RAGE"] = true,
										["UNIT_ENERGY"] = true,
										["UNIT_MAXFOCUS"] = true,
										["UNIT_FOCUS"] = true,
										["UNIT_MAXMANA"] = true,
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_RUNIC_POWER"] = true,
										["UNIT_MAXRAGE"] = true,
										["UNIT_MAXRUNIC_POWER"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
						["파티"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s || %s%%\",HP(unit),Percent(cur,max)",
									["location"] = "right",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:이름"] = {
									["location"] = "out_top_left",
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "local r,g,b = ClassColor(unit)\nreturn '%s |cff%02x%02x%02x%s|r %s%s%s',Level(unit),r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
								},
								["Lua:직업"] = {
									["exists"] = true,
									["code"] = "if UnitIsPlayer(unit) then\n  local cr,cg,cb = ClassColor(unit)\n  return \"|cff%02x%02x%02x%s|r\",cr,cg,cb,Class(unit)\nend",
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
								["Lua:시전"] = {
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["events"] = {
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
									},
									["attach_to"] = "CastBar",
									["size"] = 0.75,
								},
								["Lua:마력"] = {
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["events"] = {
										["UNIT_MAXENERGY"] = true,
										["UNIT_MANA"] = true,
										["UNIT_RAGE"] = true,
										["UNIT_ENERGY"] = true,
										["UNIT_MAXFOCUS"] = true,
										["UNIT_FOCUS"] = true,
										["UNIT_MAXMANA"] = true,
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_RUNIC_POWER"] = true,
										["UNIT_MAXRAGE"] = true,
										["UNIT_MAXRUNIC_POWER"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:백분율"] = {
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["location"] = "out_top_right",
									["position"] = 1.00001,
									["events"] = {
										["UNIT_MAXHEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTH"] = true,
									},
									["size"] = 0.8500000000000001,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "local r,g,b = ClassColor(unit)\nreturn '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "out_top_left",
									["exists"] = true,
									["size"] = 1.35,
								},
								["Lua:직업"] = {
									["exists"] = true,
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nreturn \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
									["location"] = "left",
									["events"] = {
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_LEVEL"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:마력"] = {
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["events"] = {
										["UNIT_MAXENERGY"] = true,
										["UNIT_MANA"] = true,
										["UNIT_RAGE"] = true,
										["UNIT_ENERGY"] = true,
										["UNIT_MAXFOCUS"] = true,
										["UNIT_FOCUS"] = true,
										["UNIT_MAXMANA"] = true,
										["UNIT_DISPLAYPOWER"] = true,
										["UNIT_RUNIC_POWER"] = true,
										["UNIT_MAXRAGE"] = true,
										["UNIT_MAXRUNIC_POWER"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
					},
				},
			},
		},
		["SoulShards"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "left",
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0, -- [4]
							},
							["attach_to"] = "HealthBar",
							["size"] = 1,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "left",
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0, -- [4]
							},
							["attach_to"] = "HealthBar",
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["HostilityFader"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["MasterLooterIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["CombatText"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
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
							["inactive_color"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["location"] = "left",
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0, -- [4]
							},
							["attach_to"] = "HealthBar",
							["size"] = 1.25,
						},
					},
				},
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "left",
							["attach_to"] = "HealthBar",
							["size"] = 1.100000023841858,
						},
					},
				},
			},
		},
		["ReadyCheckIcon"] = {
		},
		["Border"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["elite_texture"] = "Devil",
							["normal_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
						["보통"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["elite_texture"] = "Devil",
							["normal_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
						["대상의대상"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["elite_texture"] = "Devil",
							["normal_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
						["대상"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["elite_texture"] = "Devil",
							["normal_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["normal_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["elite_texture"] = "Devil",
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
						["대상"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["normal_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["elite_texture"] = "Devil",
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
						["대상의대상"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["normal_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["elite_texture"] = "Devil",
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
						["보통"] = {
							["boss_texture"] = "Devil",
							["rare_texture"] = "Devil",
							["elite_texture"] = "Devil",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.6599999964237213, -- [4]
							},
							["rare_color"] = {
								0.2588235294117647, -- [1]
								0.7294117647058823, -- [2]
								1, -- [3]
								0.75, -- [4]
							},
							["normal_texture"] = "Devil",
							["elite_color"] = {
								nil, -- [1]
								0.7058823529411764, -- [2]
								0.1882352941176471, -- [3]
								0.6800000071525574, -- [4]
							},
							["size"] = 12,
						},
					},
				},
			},
		},
		["Totems"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ShadowOrbs"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["inactive_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["location"] = "left",
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0, -- [4]
							},
							["attach_to"] = "HealthBar",
							["size"] = 1,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["inactive_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["location"] = "left",
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0, -- [4]
							},
							["attach_to"] = "HealthBar",
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["Portrait"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = true,
							["style"] = "two_dimensional",
							["fallback_style"] = "two_dimensional",
						},
						["보통"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["position"] = 1.00001,
						},
						["대상의대상"] = {
							["side"] = "right",
							["fallback_style"] = "two_dimensional",
						},
						["대상"] = {
							["enabled"] = true,
							["side"] = "right",
							["fallback_style"] = "two_dimensional",
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = true,
							["style"] = "two_dimensional",
							["fallback_style"] = "two_dimensional",
						},
						["대상"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["side"] = "right",
						},
						["대상의대상"] = {
							["side"] = "right",
							["fallback_style"] = "two_dimensional",
						},
						["보통"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["position"] = 1.00001,
						},
					},
				},
			},
		},
		["ExperienceBar"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RaidTargetIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["size"] = 1.25,
						},
						["보통"] = {
							["size"] = 1.25,
						},
						["대상"] = {
							["size"] = 1.3,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["size"] = 1.25,
						},
						["대상"] = {
							["size"] = 1.3,
						},
						["보통"] = {
							["size"] = 1.25,
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
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_bottom_right",
						},
					},
				},
			},
		},
		["Aggro"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RestIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00001,
							["size"] = 1.25,
						},
						["보통"] = {
							["position"] = 1.00001,
							["size"] = 1.25,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00003,
							["size"] = 1.25,
						},
						["대상"] = {
							["position"] = 1.00002,
							["size"] = 1.25,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["size"] = 1.25,
							["position"] = 1.00001,
						},
						["대상"] = {
							["size"] = 1.25,
							["position"] = 1.00002,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["size"] = 1.25,
							["position"] = 1.00003,
						},
						["보통"] = {
							["size"] = 1.25,
							["position"] = 1.00001,
						},
					},
				},
			},
		},
		["Sounds"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["BurningEmbers"] = {
		},
		["DruidManaBar"] = {
		},
		["Aura"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["highlight"] = false,
							["enabled_weapons"] = false,
							["max_debuffs"] = 3,
							["layout"] = {
								["debuff"] = {
									["width_percent"] = 0.55,
									["my_size"] = 14,
									["offset_y"] = -4,
									["size"] = 14,
									["offset_x"] = 2,
								},
								["buff"] = {
									["width_percent"] = 1,
									["my_size"] = 14,
									["offset_y"] = -4,
									["size"] = 14,
									["width"] = 135,
									["offset_x"] = -2,
									["filter"] = "!C",
								},
							},
							["max_buffs"] = 8,
							["highlight_style"] = "thinborder",
						},
						["보통"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["cooldown_text"] = {
								["weapon_buffs"] = true,
								["my_buffs"] = true,
								["my_debuffs"] = true,
							},
							["highlight"] = false,
							["highlight_filters_color_by_type"] = {
								false, -- [1]
							},
							["enabled_weapons"] = false,
							["max_debuffs"] = 16,
							["max_buffs"] = 14,
							["layout"] = {
								["debuff"] = {
									["width_percent"] = 1,
									["my_size"] = 32,
									["offset_y"] = -28,
									["anchor"] = "BOTTOMLEFT",
									["size"] = 20,
									["frame_level"] = 1,
									["growth"] = "right_down",
									["width"] = 400,
									["row_spacing"] = 2,
									["new_row_size"] = true,
									["width_type"] = "fixed",
								},
								["buff"] = {
									["my_size"] = 20,
									["offset_y"] = -4,
									["size"] = 20,
									["width"] = 400,
									["width_type"] = "fixed",
								},
							},
							["highlight_style"] = "thinborder",
							["cooldown"] = {
								["weapon_buffs"] = false,
								["my_buffs"] = false,
								["my_debuffs"] = false,
							},
							["texts"] = {
								["my_debuffs"] = {
									["count"] = {
										["font"] = "굵은 글꼴",
									},
									["cooldown_text"] = {
										["color_by_time"] = true,
										["font"] = "데미지 글꼴",
										["size"] = 1,
									},
								},
							},
						},
					},
					["global"] = {
						["colors"] = {
							["enemy"] = {
								["Magic"] = {
									0.04705882352941176, -- [1]
									0.3607843137254902, -- [2]
								},
							},
							["friend"] = {
								["other"] = {
									0.2823529411764706, -- [1]
									0.7607843137254902, -- [2]
									1, -- [3]
								},
								["my"] = {
									0.3647058823529412, -- [1]
									[3] = 0.2588235294117647,
								},
							},
							["weapon"] = {
								["quality_color"] = false,
								["weapon"] = {
									0.9725490196078431, -- [1]
									1, -- [2]
									0.2352941176470588, -- [3]
								},
							},
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["highlight"] = false,
							["max_buffs"] = 8,
							["highlight_style"] = "thinborder",
							["layout"] = {
								["buff"] = {
									["filter"] = "!C",
									["offset_y"] = -4,
									["width_percent"] = 1,
									["offset_x"] = -2,
									["width"] = 135,
									["size"] = 14,
									["my_size"] = 14,
								},
								["debuff"] = {
									["offset_y"] = -4,
									["width_percent"] = 0.55,
									["offset_x"] = 2,
									["size"] = 14,
									["my_size"] = 14,
								},
							},
							["max_debuffs"] = 3,
							["enabled_weapons"] = false,
						},
						["대상"] = {
							["cooldown_text"] = {
								["my_debuffs"] = true,
								["weapon_buffs"] = true,
								["my_buffs"] = true,
							},
							["highlight"] = false,
							["highlight_filters_color_by_type"] = {
								false, -- [1]
							},
							["layout"] = {
								["buff"] = {
									["offset_y"] = -4,
									["width_type"] = "fixed",
									["width"] = 400,
									["size"] = 20,
									["my_size"] = 20,
								},
								["debuff"] = {
									["width_percent"] = 1,
									["frame_level"] = 1,
									["my_size"] = 32,
									["width_type"] = "fixed",
									["row_spacing"] = 2,
									["offset_y"] = -28,
									["new_row_size"] = true,
									["anchor"] = "BOTTOMLEFT",
									["width"] = 400,
									["growth"] = "right_down",
									["size"] = 20,
								},
							},
							["enabled_weapons"] = false,
							["max_debuffs"] = 16,
							["max_buffs"] = 14,
							["highlight_style"] = "thinborder",
							["cooldown"] = {
								["my_debuffs"] = false,
								["weapon_buffs"] = false,
								["my_buffs"] = false,
							},
							["texts"] = {
								["my_debuffs"] = {
									["count"] = {
										["font"] = "굵은 글꼴",
									},
									["cooldown_text"] = {
										["color_by_time"] = true,
										["font"] = "데미지 글꼴",
										["size"] = 1,
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
					},
					["global"] = {
						["colors"] = {
							["weapon"] = {
								["weapon"] = {
									0.9725490196078431, -- [1]
									1, -- [2]
									0.2352941176470588, -- [3]
								},
								["quality_color"] = false,
							},
							["friend"] = {
								["other"] = {
									0.2823529411764706, -- [1]
									0.7607843137254902, -- [2]
									1, -- [3]
								},
								["my"] = {
									0.3647058823529412, -- [1]
									[3] = 0.2588235294117647,
								},
							},
							["enemy"] = {
								["Magic"] = {
									0.04705882352941176, -- [1]
									0.3607843137254902, -- [2]
								},
							},
						},
					},
				},
			},
		},
		["Runes"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["PvPIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["PowerBar"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["background_alpha"] = 0.5,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["enabled"] = false,
						},
						["대상"] = {
							["background_alpha"] = 0.5,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["background_alpha"] = 0.5,
						},
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
					},
				},
			},
		},
		["HideBlizzard"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["castbar"] = false,
						["boss"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["boss"] = false,
						["castbar"] = false,
					},
				},
			},
		},
		["ReputationBar"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CombatFader"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["HealthBar"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["보통"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
							["color_pvp_by_class"] = true,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["대상"] = {
							["color_pvp_by_class"] = true,
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
						["보통"] = {
							["position"] = 1.00001,
							["background_alpha"] = 0.5,
							["size"] = 5,
						},
					},
				},
			},
		},
		["CastBar"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["background_alpha"] = 0.5,
							["auto_hide"] = true,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["대상"] = {
							["enabled"] = false,
							["background_alpha"] = 0.5,
							["auto_hide"] = true,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["대상의대상"] = {
							["enabled"] = false,
							["background_alpha"] = 0.5,
							["auto_hide"] = true,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["enabled"] = false,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["background_alpha"] = 0.5,
							["auto_hide"] = true,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["대상"] = {
							["enabled"] = false,
							["background_alpha"] = 0.5,
							["auto_hide"] = true,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["대상의대상"] = {
							["enabled"] = false,
							["background_alpha"] = 0.5,
							["auto_hide"] = true,
							["show_icon"] = false,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["enabled"] = false,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["VoiceIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["QuestIcon"] = {
		},
		["VisualHeal"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Background"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["보통"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["대상의대상"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["대상"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["대상"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["대상의대상"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["보통"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
					},
				},
			},
		},
		["DemonicFury"] = {
		},
		["BattlePet"] = {
		},
		["AltPowerBar"] = {
		},
		["BlankSpace"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
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
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
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
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ThreatBar"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ComboPoints"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
						["보통"] = {
							["attach_to"] = "Portrait",
							["position"] = 1.00003,
							["location"] = "bottom",
							["size"] = 1,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["attach_to"] = "Portrait",
							["position"] = 1.00003,
							["location"] = "bottom",
							["spacing"] = 0,
						},
						["대상"] = {
							["attach_to"] = "Portrait",
							["spacing"] = 0,
							["location"] = "bottom",
							["position"] = 1.00003,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
						["대상"] = {
							["location"] = "bottom",
							["position"] = 1.00003,
							["attach_to"] = "Portrait",
							["spacing"] = 0,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00003,
							["location"] = "bottom",
							["attach_to"] = "Portrait",
							["spacing"] = 0,
						},
						["보통"] = {
							["location"] = "bottom",
							["size"] = 1,
							["attach_to"] = "Portrait",
							["position"] = 1.00003,
						},
					},
				},
			},
		},
		["HolyPower"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0, -- [4]
							},
							["location"] = "left",
							["inactive_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								0, -- [4]
							},
							["attach_to"] = "HealthBar",
							["size"] = 0.8500000238418579,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["inactive_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								0, -- [4]
							},
							["location"] = "left",
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0, -- [4]
							},
							["attach_to"] = "HealthBar",
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["LeaderIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
	},
	["profileKeys"] = {
	},
	["global"] = {
		["config_version"] = 2,
	},
	["profiles"] = {
		["Normal"] = {
			["class_order"] = {
				"WARRIOR", -- [1]
				"DEATHKNIGHT", -- [2]
				"PALADIN", -- [3]
				"PRIEST", -- [4]
				"SHAMAN", -- [5]
				"DRUID", -- [6]
				"ROGUE", -- [7]
				"MAGE", -- [8]
				"WARLOCK", -- [9]
				"HUNTER", -- [10]
				"MONK", -- [11]
			},
			["layouts"] = {
				["파티"] = {
					["bar_spacing"] = 1,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 160,
					["size_y"] = 40,
					["exists"] = true,
					["bar_padding"] = 1,
					["bar_texture"] = "Glamour7",
				},
				["보통"] = {
					["bar_spacing"] = 1,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 240,
					["exists"] = true,
					["bar_padding"] = 1,
					["bar_texture"] = "Glamour7",
				},
				["대상의대상"] = {
					["bar_spacing"] = 1,
					["size_x"] = 100,
					["size_y"] = 25,
					["exists"] = true,
					["bar_padding"] = 1,
					["bar_texture"] = "Glamour7",
				},
				["대상"] = {
					["bar_spacing"] = 1,
					["level"] = 25,
					["indicator_root_outside_margin"] = 2,
					["size_x"] = 240,
					["exists"] = true,
					["bar_padding"] = 1,
					["bar_texture"] = "Glamour7",
				},
			},
			["made_groups"] = true,
			["units"] = {
				["targettargettarget"] = {
					["position_x"] = 520,
					["position_y"] = -85,
					["layout"] = "대상의대상",
				},
				["focustarget"] = {
					["position_x"] = 420,
					["scale"] = 0.9,
					["position_y"] = -210,
					["layout"] = "대상의대상",
				},
				["targettarget"] = {
					["position_x"] = 520,
					["position_y"] = -50,
					["layout"] = "대상의대상",
				},
				["player"] = {
					["position_x"] = 10,
					["position_y"] = -50,
				},
				["focus"] = {
					["position_x"] = 350,
					["position_y"] = -240,
					["layout"] = "파티",
				},
				["target"] = {
					["position_x"] = 270,
					["position_y"] = -50,
					["layout"] = "대상",
				},
				["pet"] = {
					["position_x"] = 10,
					["scale"] = 0.9,
					["position_y"] = -135,
					["layout"] = "파티",
				},
				["focustargettarget"] = {
					["enabled"] = false,
					["position_x"] = -116,
					["scale"] = 0.9,
					["position_y"] = 256,
					["layout"] = "대상의대상",
				},
				["pettarget"] = {
					["enabled"] = false,
					["position_x"] = -432,
					["scale"] = 0.75,
					["position_y"] = 352,
					["layout"] = "대상의대상",
				},
			},
			["minimap_icon"] = {
				["minimapPos"] = 273.5095410269403,
				["hide"] = true,
			},
			["groups"] = {
				["파티"] = {
					["vertical_spacing"] = 40,
					["position_x"] = 110,
					["enabled"] = true,
					["layout"] = "파티",
					["exists"] = true,
					["position_y"] = -240,
				},
				["파티원 대상"] = {
					["vertical_spacing"] = 69,
					["position_x"] = 240,
					["scale"] = 0.8500000000000001,
					["enabled"] = true,
					["layout"] = "대상의대상",
					["unit_group"] = "partytarget",
					["exists"] = true,
					["position_y"] = -230,
				},
				["파티원 소환수"] = {
					["vertical_spacing"] = 75,
					["position_x"] = 240,
					["scale"] = 0.8500000000000001,
					["enabled"] = true,
					["size_y"] = 0.75,
					["layout"] = "대상의대상",
					["unit_group"] = "partypet",
					["exists"] = true,
					["position_y"] = -255,
				},
			},
			["lock_movement"] = true,
			["colors"] = {
				["power"] = {
					["ENERGY"] = {
						nil, -- [1]
						0.9725490196078431, -- [2]
						0.596078431372549, -- [3]
					},
					["MANA"] = {
						0.3725490196078432, -- [1]
						0.5254901960784314, -- [2]
					},
				},
			},
		},
		["Wide"] = {
			["colors"] = {
				["power"] = {
					["MANA"] = {
						0.3725490196078432, -- [1]
						0.5254901960784314, -- [2]
					},
					["ENERGY"] = {
						nil, -- [1]
						0.9725490196078431, -- [2]
						0.596078431372549, -- [3]
					},
				},
			},
			["lock_movement"] = true,
			["groups"] = {
				["파티원 대상"] = {
					["vertical_spacing"] = 69,
					["exists"] = true,
					["position_x"] = 280,
					["position_y"] = -230,
					["scale"] = 0.8500000000000001,
					["layout"] = "대상의대상",
					["enabled"] = true,
					["unit_group"] = "partytarget",
				},
				["파티원 소환수"] = {
					["vertical_spacing"] = 75,
					["position_x"] = 280,
					["scale"] = 0.8500000000000001,
					["size_y"] = 0.75,
					["unit_group"] = "partypet",
					["exists"] = true,
					["position_y"] = -255,
					["layout"] = "대상의대상",
					["enabled"] = true,
				},
				["파티"] = {
					["vertical_spacing"] = 40,
					["position_x"] = 130,
					["position_y"] = -240,
					["layout"] = "파티",
					["exists"] = true,
					["enabled"] = true,
				},
			},
			["class_order"] = {
				"WARRIOR", -- [1]
				"DEATHKNIGHT", -- [2]
				"PALADIN", -- [3]
				"PRIEST", -- [4]
				"SHAMAN", -- [5]
				"DRUID", -- [6]
				"ROGUE", -- [7]
				"MAGE", -- [8]
				"WARLOCK", -- [9]
				"HUNTER", -- [10]
				"MONK", -- [11]
			},
			["layouts"] = {
				["파티"] = {
					["exists"] = true,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["size_y"] = 40,
					["bar_padding"] = 1,
					["indicator_root_outside_margin"] = 2,
				},
				["대상"] = {
					["bar_texture"] = "Glamour7",
					["size_x"] = 280,
					["bar_spacing"] = 1,
					["bar_padding"] = 1,
					["level"] = 25,
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
				},
				["대상의대상"] = {
					["size_x"] = 100,
					["bar_spacing"] = 1,
					["exists"] = true,
					["size_y"] = 25,
					["bar_padding"] = 1,
					["bar_texture"] = "Glamour7",
				},
				["보통"] = {
					["size_x"] = 280,
					["bar_spacing"] = 1,
					["bar_texture"] = "Glamour7",
					["bar_padding"] = 1,
					["exists"] = true,
					["indicator_root_outside_margin"] = 2,
				},
			},
			["minimap_icon"] = {
				["minimapPos"] = 273.5095410269403,
				["hide"] = true,
			},
			["made_groups"] = true,
			["units"] = {
				["targettargettarget"] = {
					["layout"] = "대상의대상",
					["position_x"] = 610,
					["position_y"] = -85,
				},
				["focustarget"] = {
					["scale"] = 0.9,
					["layout"] = "대상의대상",
					["position_x"] = 510,
					["position_y"] = -210,
				},
				["targettarget"] = {
					["layout"] = "대상의대상",
					["position_x"] = 610,
					["position_y"] = -50,
				},
				["player"] = {
					["position_x"] = 10,
					["position_y"] = -50,
				},
				["focus"] = {
					["layout"] = "파티",
					["position_x"] = 400,
					["position_y"] = -240,
				},
				["target"] = {
					["layout"] = "대상",
					["position_x"] = 320,
					["position_y"] = -50,
				},
				["pettarget"] = {
					["enabled"] = false,
					["position_x"] = -432,
					["position_y"] = 352,
					["scale"] = 0.75,
					["layout"] = "대상의대상",
				},
				["focustargettarget"] = {
					["enabled"] = false,
					["position_x"] = -116,
					["position_y"] = 256,
					["scale"] = 0.9,
					["layout"] = "대상의대상",
				},
				["pet"] = {
					["scale"] = 0.9,
					["layout"] = "파티",
					["position_x"] = 10,
					["position_y"] = -135,
				},
			},
		},
	},
}

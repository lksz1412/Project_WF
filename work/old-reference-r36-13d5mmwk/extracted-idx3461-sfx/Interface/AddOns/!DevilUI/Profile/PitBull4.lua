
PitBull4DB = {
	["namespaces"] = {
		["LeaderIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["size"] = 0.75,
						},
						["보통"] = {
							["location"] = "edge_top_right",
							["size"] = 0.75,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["size"] = 0.75,
						},
						["보통"] = {
							["location"] = "edge_top_right",
							["size"] = 0.75,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["size"] = 0.75,
						},
						["보통"] = {
							["location"] = "edge_top_right",
							["size"] = 0.75,
						},
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CastBarLatency"] = {
		},
		["PhaseIcon"] = {
		},
		["HappinessIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["location"] = "out_right",
							["size"] = 1.25,
						},
						["보통"] = {
							["location"] = "out_right",
							["attach_to"] = "HealthBar",
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["location"] = "out_right",
							["size"] = 1.25,
						},
						["보통"] = {
							["location"] = "out_right",
							["attach_to"] = "HealthBar",
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["location"] = "out_right",
							["size"] = 1.25,
						},
						["보통"] = {
							["location"] = "out_right",
							["attach_to"] = "HealthBar",
						},
					},
				},
			},
		},
		["ComboPoints"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["location"] = "left",
							["attach_to"] = "BlankSpace;기본값",
							["size"] = 0.5,
						},
						["보통"] = {
							["location"] = "left",
							["position"] = 1.00001,
							["attach_to"] = "BlankSpace;기본값",
							["size"] = 0.5,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["location"] = "left",
							["attach_to"] = "BlankSpace;기본값",
							["size"] = 0.5,
						},
						["보통"] = {
							["location"] = "left",
							["attach_to"] = "BlankSpace;기본값",
							["size"] = 0.5,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["attach_to"] = "BlankSpace;기본값",
							["location"] = "left",
							["size"] = 0.5,
						},
						["보통"] = {
							["attach_to"] = "BlankSpace;기본값",
							["location"] = "left",
							["size"] = 0.5,
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
				["WideX"] = {
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
							["elements"] = {
								["Lua:이름"] = {
									["exists"] = true,
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "center",
									["position"] = 1.00001,
									["attach_to"] = "HealthBar",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
								},
								["Lua:퍼센트"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "center",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["attach_to"] = "BlankSpace;기본값",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
									["location"] = "right",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:시전 시간"] = {
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:퍼센트"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "left",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
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
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:직업"] = {
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["location"] = "out_right",
									["attach_to"] = "BlankSpace;기본값",
									["exists"] = true,
								},
								["Lua:이름"] = {
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["position"] = 1.00001,
									["location"] = "out_right",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["attach_to"] = "HealthBar",
									["size"] = 1.5,
								},
								["Lua:마력"] = {
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["position"] = 1.00001,
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
									["attach_to"] = "BlankSpace;기본값",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["first"] = false,
							["elements"] = {
								["Lua:이름"] = {
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["position"] = 1.00001,
									["location"] = "center",
									["exists"] = true,
									["attach_to"] = "HealthBar",
								},
								["Lua:퍼센트"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["attach_to"] = "BlankSpace;기본값",
									["font"] = "데미지 글꼴",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["position"] = 1.00002,
									["location"] = "center",
									["exists"] = true,
									["size"] = 0.75,
								},
							},
						},
						["보통"] = {
							["first"] = false,
							["elements"] = {
								["Lua:생명력"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
									["attach_to"] = "HealthBar",
									["font"] = "데미지 글꼴",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["location"] = "right",
									["exists"] = true,
									["size"] = 0.8500000000000001,
								},
								["Lua:시전 시간"] = {
									["exists"] = true,
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
								},
								["Lua:마력"] = {
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["attach_to"] = "BlankSpace;기본값",
									["font"] = "데미지 글꼴",
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
									["position"] = 1.00001,
									["location"] = "right",
									["exists"] = true,
									["size"] = 0.75,
								},
								["Lua:시전"] = {
									["exists"] = true,
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
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["attach_to"] = "CastBar",
								},
								["Lua:직업"] = {
									["exists"] = true,
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["location"] = "out_right",
									["attach_to"] = "BlankSpace;기본값",
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "out_right",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["attach_to"] = "HealthBar",
									["size"] = 1.5,
								},
								["Lua:퍼센트"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["attach_to"] = "HealthBar",
									["font"] = "데미지 글꼴",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["position"] = 1.00002,
									["location"] = "left",
									["exists"] = true,
									["size"] = 0.8500000000000001,
								},
							},
						},
					},
				},
				["Default"] = {
					["layouts"] = {
						["보통"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
								},
								["Lua:드루이드 마나"] = {
									["exists"] = true,
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
								},
								["Lua:마력"] = {
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["attach_to"] = "PowerBar",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
								},
								["Lua:시전 시간"] = {
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
								},
								["Lua:위협"] = {
									["exists"] = true,
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
								},
								["Lua:이름"] = {
									["exists"] = true,
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["attach_to"] = "HealthBar",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
								},
								["Lua:평판"] = {
									["exists"] = true,
									["code"] = "local name,_,min,max,value = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
								},
								["Lua:경험치"] = {
									["exists"] = true,
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
								},
								["Lua:직업"] = {
									["exists"] = true,
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
								},
								["Lua:시전"] = {
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["attach_to"] = "CastBar",
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
								},
								["Lua:PVP 타이머"] = {
									["location"] = "out_right_top",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
								},
							},
							["first"] = false,
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
									["location"] = "center",
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["attach_to"] = "HealthBar",
									["position"] = 1.00001,
								},
								["Lua:퍼센트"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "center",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["attach_to"] = "BlankSpace;기본값",
									["size"] = 0.75,
								},
							},
							["first"] = false,
						},
						["보통"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s/%s\",HP(unit),MaxHP(unit)",
									["location"] = "right",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
								},
								["Lua:시전 시간"] = {
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:마력"] = {
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["position"] = 1.00001,
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
									["attach_to"] = "BlankSpace;기본값",
									["size"] = 0.75,
								},
								["Lua:시전"] = {
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
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:직업"] = {
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["location"] = "out_right",
									["attach_to"] = "BlankSpace;기본값",
									["exists"] = true,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "out_right",
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["attach_to"] = "HealthBar",
									["size"] = 1.5,
								},
								["Lua:퍼센트"] = {
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["font"] = "데미지 글꼴",
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "left",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
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
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
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
				["WideX"] = {
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
							["size"] = 0.65,
						},
						["보통"] = {
							["location"] = "edge_top_right",
							["size"] = 0.65,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["size"] = 0.65,
						},
						["보통"] = {
							["location"] = "edge_top_right",
							["size"] = 0.65,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["size"] = 0.65,
						},
						["보통"] = {
							["location"] = "edge_top_right",
							["size"] = 0.65,
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Border"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["boss_texture"] = "Devil2",
							["rare_texture"] = "Devil3",
							["padding"] = 2,
							["elite_texture"] = "Devil2",
							["rare_color"] = {
								0.3725490196078432, -- [1]
								1, -- [2]
								0, -- [3]
							},
							["normal_texture"] = "Devil2",
							["elite_color"] = {
								0, -- [1]
								[3] = 0.9882352941176471,
							},
							["size"] = 10,
						},
						["보통"] = {
							["boss_texture"] = "Devil2",
							["rare_texture"] = "Devil3",
							["padding"] = 2,
							["elite_texture"] = "Devil2",
							["rare_color"] = {
								0.3725490196078432, -- [1]
								1, -- [2]
								0, -- [3]
							},
							["normal_texture"] = "Devil2",
							["elite_color"] = {
								0, -- [1]
								[3] = 0.9882352941176471,
							},
							["size"] = 10,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["boss_texture"] = "Devil2",
							["rare_texture"] = "Devil3",
							["padding"] = 2,
							["normal_texture"] = "Devil2",
							["rare_color"] = {
								0.3725490196078432, -- [1]
								1, -- [2]
								0, -- [3]
							},
							["elite_texture"] = "Devil2",
							["elite_color"] = {
								0, -- [1]
								[3] = 0.9882352941176471,
							},
							["size"] = 10,
						},
						["보통"] = {
							["boss_texture"] = "Devil2",
							["rare_texture"] = "Devil3",
							["padding"] = 2,
							["normal_texture"] = "Devil2",
							["rare_color"] = {
								0.3725490196078432, -- [1]
								1, -- [2]
								0, -- [3]
							},
							["elite_texture"] = "Devil2",
							["elite_color"] = {
								0, -- [1]
								[3] = 0.9882352941176471,
							},
							["size"] = 10,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["boss_texture"] = "Devil2",
							["rare_texture"] = "Devil3",
							["rare_color"] = {
								0.3725490196078432, -- [1]
								1, -- [2]
								0, -- [3]
							},
							["elite_texture"] = "Devil2",
							["normal_texture"] = "Devil2",
							["padding"] = 2,
							["elite_color"] = {
								0, -- [1]
								[3] = 0.9882352941176471,
							},
							["size"] = 10,
						},
						["보통"] = {
							["boss_texture"] = "Devil2",
							["rare_texture"] = "Devil3",
							["rare_color"] = {
								0.3725490196078432, -- [1]
								1, -- [2]
								0, -- [3]
							},
							["elite_texture"] = "Devil2",
							["normal_texture"] = "Devil2",
							["padding"] = 2,
							["elite_color"] = {
								0, -- [1]
								[3] = 0.9882352941176471,
							},
							["size"] = 10,
						},
					},
				},
			},
		},
		["ReadyCheckIcon"] = {
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CombatIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["location"] = "edge_top_left",
							["position"] = 1.00001,
						},
						["보통"] = {
							["location"] = "edge_top_left",
							["position"] = 1.00002,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["location"] = "edge_top_left",
							["position"] = 1.00001,
						},
						["보통"] = {
							["location"] = "edge_top_left",
							["position"] = 1.00002,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00001,
							["location"] = "edge_top_left",
						},
						["보통"] = {
							["position"] = 1.00002,
							["location"] = "edge_top_left",
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
				["WideX"] = {
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
							["location"] = "out_left",
							["vertical"] = true,
							["background_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.3400000333786011, -- [4]
							},
							["size"] = 1.25,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["Portrait"] = {
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RaidTargetIcon"] = {
		},
		["Eclipse"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["orientation"] = "VERTICAL",
							["location"] = "out_left",
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["orientation"] = "VERTICAL",
							["location"] = "out_left",
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["보통"] = {
							["orientation"] = "VERTICAL",
							["location"] = "out_left",
						},
					},
				},
			},
		},
		["CastBar"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["auto_hide"] = true,
							["enabled"] = false,
							["position"] = 5,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["auto_hide"] = true,
							["enabled"] = false,
							["position"] = 5,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["auto_hide"] = true,
							["enabled"] = false,
							["position"] = 5,
						},
					},
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
								0.8500000089406967, -- [4]
							},
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
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
								0.8500000089406967, -- [4]
							},
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
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
								0.8500000089406967, -- [4]
							},
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["BurningEmbers"] = {
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Aura"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["layout"] = {
								["buff"] = {
									["my_size"] = 19,
									["size"] = 19,
									["offset_y"] = -3,
									["filter"] = "!C",
								},
								["debuff"] = {
									["my_size"] = 19,
									["size"] = 19,
									["offset_y"] = -3,
									["filter"] = "!E",
								},
							},
						},
						["보통"] = {
							["highlight"] = false,
							["layout"] = {
								["buff"] = {
									["offset_y"] = -3,
									["width_percent"] = 1,
									["anchor"] = "BOTTOMRIGHT",
									["growth"] = "left_down",
									["new_row_size"] = true,
								},
								["debuff"] = {
									["offset_y"] = -3,
									["width_percent"] = 1,
									["anchor"] = "BOTTOMLEFT",
									["new_row_size"] = true,
									["growth"] = "right_down",
									["width"] = 165,
								},
							},
							["max_debuffs"] = 10,
							["max_buffs"] = 10,
							["cooldown"] = {
								["other_debuffs"] = false,
								["weapon_buffs"] = false,
								["my_buffs"] = false,
								["other_buffs"] = false,
								["my_debuffs"] = false,
							},
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["layout"] = {
								["debuff"] = {
									["my_size"] = 19,
									["size"] = 19,
									["offset_y"] = -3,
									["filter"] = "!E",
								},
								["buff"] = {
									["my_size"] = 19,
									["size"] = 19,
									["offset_y"] = -3,
									["filter"] = "!C",
								},
							},
						},
						["보통"] = {
							["highlight"] = false,
							["layout"] = {
								["debuff"] = {
									["offset_y"] = -3,
									["width_percent"] = 1,
									["anchor"] = "BOTTOMLEFT",
									["growth"] = "right_down",
									["new_row_size"] = true,
								},
								["buff"] = {
									["offset_y"] = -3,
									["width_percent"] = 1,
									["anchor"] = "BOTTOMRIGHT",
									["growth"] = "left_down",
									["new_row_size"] = true,
								},
							},
							["max_debuffs"] = 12,
							["max_buffs"] = 12,
							["cooldown"] = {
								["other_debuffs"] = false,
								["weapon_buffs"] = false,
								["my_buffs"] = false,
								["other_buffs"] = false,
								["my_debuffs"] = false,
							},
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["layout"] = {
								["debuff"] = {
									["my_size"] = 19,
									["offset_y"] = -3,
									["size"] = 19,
									["filter"] = "!E",
								},
								["buff"] = {
									["my_size"] = 19,
									["offset_y"] = -3,
									["size"] = 19,
									["filter"] = "!C",
								},
							},
						},
						["보통"] = {
							["highlight"] = false,
							["max_debuffs"] = 12,
							["max_buffs"] = 12,
							["cooldown"] = {
								["other_debuffs"] = false,
								["weapon_buffs"] = false,
								["my_buffs"] = false,
								["other_buffs"] = false,
								["my_debuffs"] = false,
							},
							["layout"] = {
								["debuff"] = {
									["width_percent"] = 1,
									["offset_y"] = -3,
									["anchor"] = "BOTTOMLEFT",
									["growth"] = "right_down",
									["new_row_size"] = true,
								},
								["buff"] = {
									["width_percent"] = 1,
									["offset_y"] = -3,
									["anchor"] = "BOTTOMRIGHT",
									["growth"] = "left_down",
									["new_row_size"] = true,
								},
							},
						},
					},
				},
			},
		},
		["CombatFader"] = {
		},
		["DruidManaBar"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["hide_if_full"] = true,
							["position"] = 3,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["hide_if_full"] = true,
							["position"] = 3,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["보통"] = {
							["hide_if_full"] = true,
							["position"] = 3,
						},
					},
				},
			},
		},
		["PowerBar"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["texture"] = "Minimalist",
							["size"] = 1,
						},
						["보통"] = {
							["texture"] = "Minimalist",
							["size"] = 1,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["size"] = 1,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["size"] = 1,
							["texture"] = "Minimalist",
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["size"] = 1,
							["texture"] = "Minimalist",
						},
						["보통"] = {
							["size"] = 1,
							["texture"] = "Minimalist",
						},
					},
				},
			},
		},
		["HideBlizzard"] = {
			["profiles"] = {
				["Normal"] = {
					["global"] = {
						["boss"] = false,
					},
				},
				["Wide"] = {
					["global"] = {
						["boss"] = false,
					},
				},
				["WideX"] = {
					["global"] = {
						["boss"] = false,
					},
				},
			},
		},
		["RestIcon"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["location"] = "edge_top_right",
						},
						["보통"] = {
							["location"] = "edge_top_left",
							["position"] = 1.00001,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["location"] = "edge_top_right",
						},
						["보통"] = {
							["location"] = "edge_top_left",
							["position"] = 1.00001,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = false,
							["location"] = "edge_top_right",
						},
						["보통"] = {
							["position"] = 1.00001,
							["location"] = "edge_top_left",
						},
					},
				},
			},
		},
		["PvPIcon"] = {
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
				["WideX"] = {
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
						["대상의대상"] = {
							["color_by_class"] = false,
							["hostility_color"] = false,
							["custom_background"] = {
								0.3254901960784314, -- [1]
								0.03529411764705882, -- [2]
								0.05882352941176471, -- [3]
								1, -- [4]
							},
							["background_alpha"] = 0.5,
							["hostility_color_npcs"] = false,
							["size"] = 8,
						},
						["보통"] = {
							["color_by_class"] = false,
							["hostility_color"] = false,
							["custom_background"] = {
								0.4980392156862745, -- [1]
								0.05490196078431373, -- [2]
								0.09019607843137255, -- [3]
								1, -- [4]
							},
							["background_alpha"] = 0.5,
							["hostility_color_npcs"] = false,
							["size"] = 8,
						},
					},
					["global"] = {
						["colors"] = {
							["min_health"] = {
								nil, -- [1]
								0.5176470588235294, -- [2]
								0.09019607843137255, -- [3]
							},
							["half_health"] = {
								0.8352941176470589, -- [1]
								0.9254901960784314, -- [2]
								0.1764705882352941, -- [3]
							},
							["max_health"] = {
								0.1058823529411765, -- [1]
								0.1568627450980392, -- [2]
								0.1882352941176471, -- [3]
							},
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["color_by_class"] = false,
							["background_alpha"] = 0.5,
							["custom_background"] = {
								0.3254901960784314, -- [1]
								0.03529411764705882, -- [2]
								0.05882352941176471, -- [3]
								1, -- [4]
							},
							["hostility_color"] = false,
							["hostility_color_npcs"] = false,
							["size"] = 8,
						},
						["보통"] = {
							["color_by_class"] = false,
							["background_alpha"] = 0.5,
							["custom_background"] = {
								0.4980392156862745, -- [1]
								0.05490196078431373, -- [2]
								0.09019607843137255, -- [3]
								1, -- [4]
							},
							["hostility_color"] = false,
							["hostility_color_npcs"] = false,
							["size"] = 8,
						},
					},
					["global"] = {
						["colors"] = {
							["half_health"] = {
								0.8352941176470589, -- [1]
								0.9254901960784314, -- [2]
								0.1764705882352941, -- [3]
							},
							["min_health"] = {
								nil, -- [1]
								0.5176470588235294, -- [2]
								0.09019607843137255, -- [3]
							},
							["max_health"] = {
								0.1058823529411765, -- [1]
								0.1568627450980392, -- [2]
								0.1882352941176471, -- [3]
							},
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["color_by_class"] = false,
							["hostility_color"] = false,
							["custom_background"] = {
								0.3254901960784314, -- [1]
								0.03529411764705882, -- [2]
								0.05882352941176471, -- [3]
								1, -- [4]
							},
							["size"] = 8,
							["hostility_color_npcs"] = false,
							["background_alpha"] = 0.5,
						},
						["보통"] = {
							["color_by_class"] = false,
							["hostility_color"] = false,
							["custom_background"] = {
								0.4980392156862745, -- [1]
								0.05490196078431373, -- [2]
								0.09019607843137255, -- [3]
								1, -- [4]
							},
							["size"] = 8,
							["hostility_color_npcs"] = false,
							["background_alpha"] = 0.5,
						},
					},
					["global"] = {
						["colors"] = {
							["half_health"] = {
								0.8352941176470589, -- [1]
								0.9254901960784314, -- [2]
								0.1764705882352941, -- [3]
							},
							["min_health"] = {
								nil, -- [1]
								0.5176470588235294, -- [2]
								0.09019607843137255, -- [3]
							},
							["max_health"] = {
								0.1058823529411765, -- [1]
								0.1568627450980392, -- [2]
								0.1882352941176471, -- [3]
							},
						},
					},
				},
			},
		},
		["QuestIcon"] = {
		},
		["ManaSpark"] = {
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
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
						["대상의대상"] = {
							["enabled"] = true,
							["first"] = false,
							["elements"] = {
								["기본값"] = {
									["color_by_class"] = true,
									["hostility_color"] = true,
									["position"] = 10.00001,
									["hostility_color_npcs"] = true,
									["exists"] = true,
									["size"] = 3,
								},
							},
						},
						["보통"] = {
							["enabled"] = true,
							["first"] = false,
							["elements"] = {
								["기본값"] = {
									["color_by_class"] = true,
									["hostility_color"] = true,
									["position"] = 4,
									["hostility_color_npcs"] = true,
									["exists"] = true,
									["size"] = 3,
								},
							},
						},
					},
				},
				["Default"] = {
					["layouts"] = {
						["보통"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = true,
							["first"] = false,
							["elements"] = {
								["기본값"] = {
									["color_by_class"] = true,
									["hostility_color"] = true,
									["position"] = 10.00001,
									["hostility_color_npcs"] = true,
									["exists"] = true,
									["size"] = 3,
								},
							},
						},
						["보통"] = {
							["enabled"] = true,
							["first"] = false,
							["elements"] = {
								["기본값"] = {
									["color_by_class"] = true,
									["hostility_color"] = true,
									["position"] = 4,
									["hostility_color_npcs"] = true,
									["exists"] = true,
									["size"] = 3,
								},
							},
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["대상의대상"] = {
							["enabled"] = true,
							["first"] = false,
							["elements"] = {
								["기본값"] = {
									["color_by_class"] = true,
									["hostility_color"] = true,
									["hostility_color_npcs"] = true,
									["exists"] = true,
									["position"] = 10.00001,
									["size"] = 3,
								},
							},
						},
						["보통"] = {
							["enabled"] = true,
							["first"] = false,
							["elements"] = {
								["기본값"] = {
									["color_by_class"] = true,
									["hostility_color"] = true,
									["hostility_color_npcs"] = true,
									["exists"] = true,
									["position"] = 4,
									["size"] = 3,
								},
							},
						},
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
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
				["WideX"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["HolyPower"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
			},
		},
		["Chi"] = {
			["profiles"] = {
				["Normal"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["size"] = 1.25,
						},
					},
				},
				["Wide"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
						},
					},
				},
				["WideX"] = {
					["layouts"] = {
						["보통"] = {
							["location"] = "out_left",
							["vertical"] = true,
							["size"] = 1.25,
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
			["minimap_icon"] = {
				["hide"] = true,
			},
			["made_groups"] = true,
			["colors"] = {
				["reaction"] = {
					{
						nil, -- [1]
						0.08627450980392157, -- [2]
						0.1058823529411765, -- [3]
					}, -- [1]
					{
						nil, -- [1]
						0.05882352941176471, -- [2]
						0.07058823529411765, -- [3]
					}, -- [2]
					{
						0.7490196078431373, -- [1]
						0.09019607843137255, -- [2]
						0.06666666666666667, -- [3]
					}, -- [3]
					[5] = {
						0.2901960784313725, -- [1]
						0.5490196078431373, -- [2]
						0.7725490196078432, -- [3]
					},
				},
				["power"] = {
					["MANA"] = {
						0.4784313725490196, -- [1]
						0.8392156862745098, -- [2]
					},
					["POWER_TYPE_STEAM"] = {
						0.9490196078431372, -- [1]
						0.9490196078431372, -- [2]
						0.9490196078431372, -- [3]
					},
					["ENERGY"] = {
						nil, -- [1]
						0.6705882352941176, -- [2]
						0.3333333333333333, -- [3]
					},
					["RAGE"] = {
						nil, -- [1]
						0.4117647058823529, -- [2]
						0.4235294117647059, -- [3]
					},
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
				["대상의대상"] = {
					["size_x"] = 100,
					["bar_spacing"] = 1,
					["exists"] = true,
					["size_y"] = 36,
					["bar_padding"] = 1,
					["bar_texture"] = "Minimalist",
				},
				["보통"] = {
					["indicator_bar_outside_margin"] = 8,
					["size_x"] = 220,
					["bar_spacing"] = 1,
					["exists"] = true,
					["size_y"] = 44,
					["bar_padding"] = 1,
					["bar_texture"] = "Minimalist",
				},
			},
			["groups"] = {
				["파티"] = {
					["enabled"] = true,
					["direction"] = "up_left",
					["position_x"] = 550,
					["scale"] = 0.75,
					["exists"] = true,
					["position_y"] = -150,
					["sort_direction"] = "DESC",
					["horizontal_mirror"] = true,
					["show_when"] = {
						["raid"] = true,
					},
				},
			},
			["lock_movement"] = true,
			["units"] = {
				["targettargettarget"] = {
					["enabled"] = false,
					["layout"] = "대상의대상",
					["position_y"] = -80,
				},
				["focustarget"] = {
					["layout"] = "대상의대상",
					["position_x"] = 582,
					["position_y"] = -225,
				},
				["targettarget"] = {
					["position_y"] = -200,
					["layout"] = "대상의대상",
				},
				["player"] = {
					["position_x"] = -240,
					["horizontal_mirror"] = true,
					["position_y"] = -200,
				},
				["focus"] = {
					["scale"] = 0.9,
					["position_x"] = 535,
					["horizontal_mirror"] = true,
					["position_y"] = -270,
				},
				["target"] = {
					["position_x"] = 240,
					["position_y"] = -200,
				},
				["pettarget"] = {
					["enabled"] = false,
				},
				["focustargettarget"] = {
					["enabled"] = false,
				},
				["pet"] = {
					["layout"] = "대상의대상",
					["position_x"] = -300,
					["position_y"] = -268,
				},
			},
		},
		["WideX"] = {
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
				["대상의대상"] = {
					["bar_spacing"] = 1,
					["size_x"] = 120,
					["size_y"] = 36,
					["exists"] = true,
					["bar_padding"] = 1,
					["bar_texture"] = "Minimalist",
				},
				["보통"] = {
					["bar_spacing"] = 1,
					["indicator_bar_outside_margin"] = 8,
					["size_x"] = 240,
					["size_y"] = 44,
					["exists"] = true,
					["bar_padding"] = 1,
					["bar_texture"] = "Minimalist",
				},
			},
			["lock_movement"] = true,
			["units"] = {
				["targettargettarget"] = {
					["enabled"] = false,
					["position_y"] = -80,
					["layout"] = "대상의대상",
				},
				["focustarget"] = {
					["position_x"] = 284,
					["scale"] = 0.9,
					["position_y"] = -80,
					["layout"] = "대상의대상",
				},
				["targettarget"] = {
					["position_y"] = -306,
					["layout"] = "대상의대상",
				},
				["player"] = {
					["position_x"] = -290,
					["position_y"] = -306,
					["horizontal_mirror"] = true,
				},
				["focus"] = {
					["position_x"] = 318,
					["scale"] = 0.75,
					["position_y"] = -120,
				},
				["target"] = {
					["position_x"] = 290,
					["position_y"] = -306,
				},
				["pet"] = {
					["position_x"] = -350,
					["position_y"] = -372,
					["layout"] = "대상의대상",
				},
				["focustargettarget"] = {
					["enabled"] = false,
				},
				["pettarget"] = {
					["enabled"] = false,
				},
			},
			["colors"] = {
				["reaction"] = {
					{
						nil, -- [1]
						0.08627450980392157, -- [2]
						0.1058823529411765, -- [3]
					}, -- [1]
					{
						nil, -- [1]
						0.05882352941176471, -- [2]
						0.07058823529411765, -- [3]
					}, -- [2]
					{
						0.7490196078431373, -- [1]
						0.09019607843137255, -- [2]
						0.06666666666666667, -- [3]
					}, -- [3]
					[5] = {
						0.2901960784313725, -- [1]
						0.5490196078431373, -- [2]
						0.7725490196078432, -- [3]
					},
				},
				["power"] = {
					["POWER_TYPE_STEAM"] = {
						0.9490196078431372, -- [1]
						0.9490196078431372, -- [2]
						0.9490196078431372, -- [3]
					},
					["ENERGY"] = {
						nil, -- [1]
						0.6705882352941176, -- [2]
						0.3333333333333333, -- [3]
					},
					["MANA"] = {
						0.4784313725490196, -- [1]
						0.8392156862745098, -- [2]
					},
					["RAGE"] = {
						nil, -- [1]
						0.4117647058823529, -- [2]
						0.4235294117647059, -- [3]
					},
				},
			},
			["groups"] = {
				["파티"] = {
					["direction"] = "up_left",
					["position_x"] = 790,
					["scale"] = 0.9,
					["enabled"] = true,
					["exists"] = true,
					["position_y"] = -185,
					["sort_direction"] = "DESC",
					["horizontal_mirror"] = true,
					["show_when"] = {
						["raid"] = true,
					},
				},
			},
			["made_groups"] = true,
			["minimap_icon"] = {
				["hide"] = true,
			},
		},
		["Default"] = {
			["groups"] = {
				["파티"] = {
					["enabled"] = true,
					["exists"] = true,
				},
				["파티원 소환수"] = {
					["enabled"] = true,
					["exists"] = true,
					["unit_group"] = "partypet",
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
				["보통"] = {
					["exists"] = true,
				},
			},
			["made_groups"] = true,
			["units"] = {
				["player"] = {
				},
				["targettargettarget"] = {
				},
				["focus"] = {
				},
				["target"] = {
				},
				["focustarget"] = {
				},
				["pet"] = {
				},
			},
		},
		["Wide"] = {
			["colors"] = {
				["reaction"] = {
					{
						nil, -- [1]
						0.08627450980392157, -- [2]
						0.1058823529411765, -- [3]
					}, -- [1]
					{
						nil, -- [1]
						0.05882352941176471, -- [2]
						0.07058823529411765, -- [3]
					}, -- [2]
					{
						0.7490196078431373, -- [1]
						0.09019607843137255, -- [2]
						0.06666666666666667, -- [3]
					}, -- [3]
					[5] = {
						0.2901960784313725, -- [1]
						0.5490196078431373, -- [2]
						0.7725490196078432, -- [3]
					},
				},
				["power"] = {
					["MANA"] = {
						0.4784313725490196, -- [1]
						0.8392156862745098, -- [2]
					},
					["POWER_TYPE_STEAM"] = {
						0.9490196078431372, -- [1]
						0.9490196078431372, -- [2]
						0.9490196078431372, -- [3]
					},
					["ENERGY"] = {
						nil, -- [1]
						0.6705882352941176, -- [2]
						0.3333333333333333, -- [3]
					},
					["RAGE"] = {
						nil, -- [1]
						0.4117647058823529, -- [2]
						0.4235294117647059, -- [3]
					},
				},
			},
			["lock_movement"] = true,
			["minimap_icon"] = {
				["hide"] = true,
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
				["대상의대상"] = {
					["size_x"] = 120,
					["bar_spacing"] = 1,
					["exists"] = true,
					["size_y"] = 36,
					["bar_padding"] = 1,
					["bar_texture"] = "Minimalist",
				},
				["보통"] = {
					["indicator_bar_outside_margin"] = 8,
					["size_x"] = 240,
					["bar_spacing"] = 1,
					["exists"] = true,
					["size_y"] = 44,
					["bar_padding"] = 1,
					["bar_texture"] = "Minimalist",
				},
			},
			["groups"] = {
				["파티"] = {
					["enabled"] = true,
					["direction"] = "up_left",
					["horizontal_mirror"] = true,
					["scale"] = 0.9,
					["exists"] = true,
					["position_y"] = -185,
					["sort_direction"] = "DESC",
					["position_x"] = 705,
					["show_when"] = {
						["raid"] = true,
					},
				},
			},
			["made_groups"] = true,
			["units"] = {
				["targettargettarget"] = {
					["enabled"] = false,
					["layout"] = "대상의대상",
					["position_y"] = -80,
				},
				["focustarget"] = {
					["scale"] = 0.9,
					["layout"] = "대상의대상",
					["position_x"] = 284,
					["position_y"] = -80,
				},
				["targettarget"] = {
					["position_y"] = -306,
					["layout"] = "대상의대상",
				},
				["player"] = {
					["horizontal_mirror"] = true,
					["position_x"] = -290,
					["position_y"] = -306,
				},
				["focus"] = {
					["scale"] = 0.75,
					["position_x"] = 318,
					["position_y"] = -120,
				},
				["target"] = {
					["position_x"] = 290,
					["position_y"] = -306,
				},
				["pet"] = {
					["layout"] = "대상의대상",
					["position_x"] = -350,
					["position_y"] = -372,
				},
				["focustargettarget"] = {
					["enabled"] = false,
				},
				["pettarget"] = {
					["enabled"] = false,
				},
			},
		},
	},
}

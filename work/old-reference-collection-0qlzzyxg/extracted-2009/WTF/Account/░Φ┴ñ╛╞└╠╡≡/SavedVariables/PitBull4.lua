
PitBull4DB = {
	["namespaces"] = {
		["Highlight"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["color"] = {
								0.3764705882352941, -- [1]
								0.3764705882352941, -- [2]
								0.3764705882352941, -- [3]
							},
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
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
		["RangeFader"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CastBarLatency"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
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
		["HappinessIcon"] = {
			["profileKeys"] = {
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
						["주시대상"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
						["대상"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
						["파티의소환수"] = {
							["enabled"] = false,
							["position"] = 1.00003,
						},
						["소환수"] = {
							["location"] = "out_left_bottom",
							["size"] = 1.5,
							["position"] = 1.00001,
						},
						["보통"] = {
							["enabled"] = false,
							["position"] = 1.00001,
						},
					},
				},
			},
		},
		["CombatIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["position"] = 1.00001,
						},
						["주시대상"] = {
							["position"] = 1.00001,
						},
						["대상"] = {
							["position"] = 1.00001,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00001,
						},
						["파티의소환수"] = {
							["enabled"] = false,
							["position"] = 1.00001,
						},
						["소환수"] = {
							["enabled"] = false,
							["location"] = "edge_bottom_right",
						},
						["보통"] = {
							["location"] = "edge_bottom_right",
						},
					},
				},
			},
		},
		["DogTagTexts"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["first"] = false,
							["elements"] = {
								["마력"] = {
									["exists"] = true,
									["code"] = "[if IsMouseOver then\n    FractionalMP\nend]",
									["location"] = "out_bottom_left",
									["size"] = 0.8500000000000001,
								},
								["이름"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "[Level] [Name:ClassColor] [(AFK or DND):Angle]",
									["attach_to"] = "HealthBar",
									["size"] = 0.9,
								},
								["생명력"] = {
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "left",
									["code"] = "[Status or FractionalHP(known=true):Short or PercentHP:Percent]",
									["attach_to"] = "HealthBar",
									["size"] = 0.8,
								},
							},
						},
						["주시대상"] = {
							["first"] = false,
							["elements"] = {
								["주문이름"] = {
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "center",
									["code"] = "[Alpha((-CastStopDuration or 0) + 1) CastStopMessage or (CastName ' ' CastTarget:Paren)]",
									["attach_to"] = "CastBar",
								},
								["마력"] = {
									["exists"] = true,
									["code"] = "[if HasMP then FractionalMP]",
									["location"] = "out_bottom_left",
									["size"] = 0.8500000000000001,
								},
								["이름"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "out_bottom_right",
									["code"] = "[(IsFriend ? Name:ClassColor) (IsEnemy ? Name:Red) (AFK or DND):Angle] [Level:DifficultyColor]",
									["size"] = 1.2,
								},
								["생명력"] = {
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "left",
									["code"] = "[Status or FractionalHP(known=true)] [PercentHP:Hide(0):Hide(100):Percent]",
									["attach_to"] = "HealthBar",
									["size"] = 0.9,
								},
							},
						},
						["대상"] = {
							["first"] = false,
							["elements"] = {
								["이름"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "out_bottom_right",
									["code"] = "[(IsFriend ? Name:ClassColor) (IsEnemy ? Name:Red) (AFK or DND):Angle] [Level:DifficultyColor]",
									["size"] = 1.2,
								},
								["마력"] = {
									["exists"] = true,
									["code"] = "[if HasMP then FractionalMP]",
									["location"] = "out_bottom_left",
									["size"] = 0.8500000000000001,
								},
								["생명력"] = {
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "left",
									["code"] = "[Status or FractionalHP(known=true)] [PercentHP:Hide(0):Hide(100):Percent]",
									["attach_to"] = "HealthBar",
									["size"] = 0.9,
								},
								["직업"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "[SmartRace] [Classification (if IsPlayer then\n    Class\nend):White]",
									["attach_to"] = "HealthBar",
									["size"] = 0.8,
								},
							},
						},
						["대상의대상"] = {
							["first"] = false,
							["elements"] = {
								["이름"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "center",
									["code"] = "[IsFriend ? Name:White] [IsEnemy ? Name:Red]",
									["attach_to"] = "HealthBar",
									["size"] = 0.9,
								},
							},
						},
						["소환수"] = {
							["first"] = false,
							["elements"] = {
								["경험치"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "center",
									["code"] = "[if IsMouseOver then\n    FractionalXP ' ' PercentXP:Percent:Paren ' ' Concatenate('R: ', PercentRestXP:Hide(0):Percent)\nend]",
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000000000001,
								},
								["생명력"] = {
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "right",
									["code"] = "[PercentHP:Hide(0):Hide(100):Percent]",
									["attach_to"] = "HealthBar",
									["size"] = 0.75,
								},
								["이름"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "left",
									["code"] = "[Name] [(AFK or DND):Angle]",
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000000000001,
								},
							},
						},
						["파티의소환수"] = {
							["first"] = false,
							["elements"] = {
								["이름"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "[IsFriend ? Name:White] [IsEnemy ? Name:Red]",
									["attach_to"] = "HealthBar",
									["size"] = 0.9,
								},
							},
						},
						["보통"] = {
							["first"] = false,
							["elements"] = {
								["마력"] = {
									["exists"] = true,
									["code"] = "[if HasMP then FractionalMP]",
									["location"] = "out_bottom_right",
									["size"] = 0.8500000000000001,
								},
								["생명력"] = {
									["exists"] = true,
									["code"] = "[Status or FractionalHP(known=true)] [PercentHP:Hide(0):Hide(100):Percent]",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["size"] = 0.9,
								},
								["이름"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "out_bottom_left",
									["code"] = "[Level] [PvPRank] [Name:ClassColor DruidForm:Paren]  [RaidGroup:Paren]",
									["size"] = 1.2,
								},
							},
						},
					},
					["global"] = {
						["enabled"] = true,
					},
				},
			},
		},
		["LuaTexts"] = {
			["profileKeys"] = {
				["엔카마치 - 우서"] = "Default",
				["Enkai - 우서"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
					["layouts"] = {
						["소환수"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTHMAX"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:드루이드 마나"] = {
									["events"] = {
										["UNIT_MANA"] = true,
										["UNIT_MAXMANA"] = true,
									},
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["exists"] = true,
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
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:시전 시간"] = {
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
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:위협"] = {
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
									["exists"] = true,
								},
								["Lua:경험치"] = {
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
									["exists"] = true,
								},
								["Lua:평판"] = {
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["code"] = "local name,_,min,max,value = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
									["exists"] = true,
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
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:PVP 타이머"] = {
									["location"] = "out_right_top",
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
								},
							},
							["first"] = false,
						},
						["주시대상"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTHMAX"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:드루이드 마나"] = {
									["events"] = {
										["UNIT_MANA"] = true,
										["UNIT_MAXMANA"] = true,
									},
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["exists"] = true,
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
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:시전 시간"] = {
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
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:위협"] = {
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
									["exists"] = true,
								},
								["Lua:경험치"] = {
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
									["exists"] = true,
								},
								["Lua:평판"] = {
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["code"] = "local name,_,min,max,value = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
									["exists"] = true,
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
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:PVP 타이머"] = {
									["location"] = "out_right_top",
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
								},
							},
							["first"] = false,
						},
						["대상"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTHMAX"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:드루이드 마나"] = {
									["events"] = {
										["UNIT_MANA"] = true,
										["UNIT_MAXMANA"] = true,
									},
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["exists"] = true,
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
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:시전 시간"] = {
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
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:위협"] = {
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
									["exists"] = true,
								},
								["Lua:경험치"] = {
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
									["exists"] = true,
								},
								["Lua:평판"] = {
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["code"] = "local name,_,min,max,value = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
									["exists"] = true,
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
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:PVP 타이머"] = {
									["location"] = "out_right_top",
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
								},
							},
							["first"] = false,
						},
						["대상의대상"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTHMAX"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:드루이드 마나"] = {
									["events"] = {
										["UNIT_MANA"] = true,
										["UNIT_MAXMANA"] = true,
									},
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["exists"] = true,
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
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:시전 시간"] = {
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
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:위협"] = {
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
									["exists"] = true,
								},
								["Lua:경험치"] = {
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
									["exists"] = true,
								},
								["Lua:평판"] = {
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["code"] = "local name,_,min,max,value = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
									["exists"] = true,
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
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:PVP 타이머"] = {
									["location"] = "out_right_top",
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
								},
							},
							["first"] = false,
						},
						["파티의소환수"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTHMAX"] = true,
									},
								},
								["Lua:드루이드 마나"] = {
									["exists"] = true,
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["events"] = {
										["UNIT_MAXMANA"] = true,
										["UNIT_MANA"] = true,
									},
								},
								["Lua:마력"] = {
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["attach_to"] = "PowerBar",
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
								},
								["Lua:시전 시간"] = {
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
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
						["파티"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTHMAX"] = true,
									},
								},
								["Lua:드루이드 마나"] = {
									["exists"] = true,
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["events"] = {
										["UNIT_MAXMANA"] = true,
										["UNIT_MANA"] = true,
									},
								},
								["Lua:마력"] = {
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  return \"%s/%s\",Power(unit),max\nend",
									["location"] = "right",
									["attach_to"] = "PowerBar",
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
								},
								["Lua:시전 시간"] = {
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
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
						["보통"] = {
							["elements"] = {
								["Lua:생명력"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_HEALTHMAX"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nlocal cur, max = HP(unit), MaxHP(unit)\nreturn \"%s/%s || %s%%\",Short(cur,true),Short(max,true),Percent(cur,max)",
									["location"] = "right",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:드루이드 마나"] = {
									["events"] = {
										["UNIT_MANA"] = true,
										["UNIT_MAXMANA"] = true,
									},
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
									["exists"] = true,
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
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:시전 시간"] = {
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
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
									["exists"] = true,
								},
								["Lua:위협"] = {
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
									["exists"] = true,
								},
								["Lua:경험치"] = {
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
									["exists"] = true,
								},
								["Lua:평판"] = {
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["code"] = "local name,_,min,max,value = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
									["exists"] = true,
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
									["location"] = "left",
									["attach_to"] = "PowerBar",
									["exists"] = true,
								},
								["Lua:이름"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "return '%s %s%s%s',Name(unit),Angle(AFK(unit) or DND(unit))",
									["location"] = "left",
									["attach_to"] = "HealthBar",
									["exists"] = true,
								},
								["Lua:PVP 타이머"] = {
									["location"] = "out_right_top",
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
								},
							},
							["first"] = false,
						},
					},
				},
			},
		},
		["HostilityFader"] = {
			["profiles"] = {
				["Default"] = {
				},
			},
		},
		["MasterLooterIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["소환수"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["CombatText"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
							["location"] = "right",
							["attach_to"] = "HealthBar",
							["position"] = 1.00001,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
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
		["ReadyCheckIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["position"] = 1.00004,
						},
						["주시대상"] = {
							["enabled"] = false,
							["position"] = 1.00004,
						},
						["대상"] = {
							["enabled"] = false,
							["position"] = 1.00004,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00004,
						},
						["파티의소환수"] = {
							["enabled"] = false,
							["position"] = 1.00004,
						},
						["소환수"] = {
							["enabled"] = false,
							["position"] = 1.00002,
						},
						["보통"] = {
							["enabled"] = false,
							["position"] = 1.00002,
						},
					},
				},
			},
		},
		["Totems"] = {
			["profileKeys"] = {
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["플레이어"] = {
							["location"] = "out_left",
							["timer_text_side"] = "topoutside",
						},
						["소환수"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["파티"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["location"] = "out_left",
						},
					},
				},
			},
		},
		["Portrait"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = true,
							["side"] = "right",
							["style"] = "two_dimensional",
							["position"] = 1.00001,
							["fallback_style"] = "two_dimensional",
						},
						["주시대상"] = {
							["enabled"] = true,
							["side"] = "right",
							["style"] = "two_dimensional",
							["position"] = 1.00001,
							["fallback_style"] = "two_dimensional",
						},
						["대상"] = {
							["enabled"] = true,
							["side"] = "right",
							["style"] = "two_dimensional",
							["position"] = 1.00001,
							["fallback_style"] = "two_dimensional",
						},
						["대상의대상"] = {
							["side"] = "right",
							["style"] = "two_dimensional",
							["position"] = 1.00001,
							["fallback_style"] = "two_dimensional",
						},
						["파티의소환수"] = {
							["side"] = "right",
							["style"] = "two_dimensional",
							["position"] = 1.00001,
							["fallback_style"] = "two_dimensional",
						},
						["소환수"] = {
							["fallback_style"] = "two_dimensional",
							["style"] = "two_dimensional",
							["position"] = 1.00001,
						},
						["보통"] = {
							["enabled"] = true,
							["fallback_style"] = "two_dimensional",
							["style"] = "two_dimensional",
							["position"] = 1.00001,
						},
					},
				},
			},
		},
		["Banzai"] = {
			["profileKeys"] = {
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
						},
						["플레이어"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RaidTargetIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["주시대상"] = {
							["size"] = 1.5,
						},
						["대상"] = {
							["size"] = 1.5,
						},
					},
				},
			},
		},
		["Sounds"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Aura"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["max_debuffs"] = 3,
							["max_buffs"] = 9,
							["layout"] = {
								["debuff"] = {
									["width_percent"] = 0.26,
									["size_to_fit"] = false,
									["my_size"] = 18,
									["offset_y"] = -1,
									["anchor"] = "BOTTOMLEFT",
									["size"] = 18,
									["growth"] = "right_down",
									["filter"] = "!E",
								},
								["buff"] = {
									["width_percent"] = 0.8200000000000001,
									["size_to_fit"] = false,
									["my_size"] = 18,
									["offset_y"] = -1,
									["anchor"] = "BOTTOMRIGHT",
									["size"] = 18,
									["width"] = 400,
									["growth"] = "left_down",
									["filter"] = "!C",
								},
							},
							["highlight_style"] = "thinborder",
							["cooldown"] = {
								["other_debuffs"] = false,
								["weapon_buffs"] = false,
								["other_buffs"] = false,
							},
						},
						["주시대상"] = {
							["layout"] = {
								["debuff"] = {
									["width_percent"] = 0.51,
									["my_size"] = 22,
									["offset_y"] = 2,
									["anchor"] = "TOPLEFT",
									["size"] = 22,
									["side"] = "TOP",
									["growth"] = "right_up",
								},
								["buff"] = {
									["my_size"] = 22,
									["offset_y"] = 2,
									["anchor"] = "TOPRIGHT",
									["size"] = 22,
									["side"] = "TOP",
									["width"] = 400,
									["growth"] = "left_up",
								},
							},
							["highlight_style"] = "thinborder",
						},
						["대상"] = {
							["cooldown_text"] = {
								["weapon_buffs"] = true,
								["my_debuffs"] = true,
								["my_buffs"] = true,
							},
							["max_debuffs"] = 36,
							["max_buffs"] = 20,
							["layout"] = {
								["buff"] = {
									["width_percent"] = 1,
									["my_size"] = 20,
									["offset_y"] = -25,
									["anchor"] = "BOTTOMRIGHT",
									["size"] = 20,
									["growth"] = "left_down",
									["width"] = 400,
									["width_type"] = "fixed",
								},
								["debuff"] = {
									["width_percent"] = 1,
									["my_size"] = 26,
									["offset_y"] = 2,
									["anchor"] = "TOPLEFT",
									["size"] = 24,
									["side"] = "TOP",
									["growth"] = "right_up",
								},
							},
							["highlight_style"] = "thinborder",
							["cooldown"] = {
								["weapon_buffs"] = false,
								["my_buffs"] = false,
								["my_debuffs"] = false,
							},
						},
						["대상의대상"] = {
							["enabled"] = false,
							["layout"] = {
								["debuff"] = {
									["anchor"] = "TOPLEFT",
									["side"] = "TOP",
								},
								["buff"] = {
									["anchor"] = "TOPRIGHT",
									["side"] = "TOP",
								},
							},
						},
						["파티의소환수"] = {
							["enabled"] = false,
							["layout"] = {
								["buff"] = {
									["anchor"] = "TOPRIGHT",
									["side"] = "TOP",
								},
								["debuff"] = {
									["anchor"] = "TOPLEFT",
									["side"] = "TOP",
								},
							},
						},
						["소환수"] = {
							["max_debuffs"] = 4,
							["max_buffs"] = 4,
							["layout"] = {
								["buff"] = {
									["my_size"] = 14,
									["offset_y"] = 2,
									["anchor"] = "TOPRIGHT",
									["size"] = 14,
									["side"] = "RIGHT",
									["offset_x"] = 1,
									["filter"] = "!C",
								},
								["debuff"] = {
									["my_size"] = 14,
									["offset_y"] = -1,
									["size"] = 14,
									["side"] = "RIGHT",
									["growth"] = "right_down",
									["offset_x"] = 1,
									["filter"] = "!E",
								},
							},
							["highlight_style"] = "thinborder",
							["cooldown"] = {
								["other_debuffs"] = false,
								["weapon_buffs"] = false,
								["other_buffs"] = false,
							},
						},
						["보통"] = {
							["enabled"] = false,
						},
					},
					["global"] = {
						["colors"] = {
							["friend"] = {
								["my"] = {
									0.1882352941176471, -- [1]
									0.9019607843137255, -- [2]
									1, -- [3]
								},
								["other"] = {
									0.9803921568627451, -- [1]
									1, -- [2]
									0.3019607843137255, -- [3]
								},
							},
						},
					},
				},
			},
		},
		["RestIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["position"] = 1.00001,
							["location"] = "edge_top_right",
						},
						["주시대상"] = {
							["position"] = 1.00001,
							["location"] = "edge_top_right",
						},
						["대상"] = {
							["position"] = 1.00001,
							["location"] = "edge_top_right",
						},
						["대상의대상"] = {
							["position"] = 1.00001,
							["location"] = "edge_top_right",
						},
						["파티의소환수"] = {
							["position"] = 1.00001,
							["location"] = "edge_top_right",
						},
						["소환수"] = {
							["enabled"] = false,
							["position"] = 1.00001,
							["location"] = "edge_top_right",
						},
						["보통"] = {
							["position"] = 1.00001,
							["location"] = "edge_top_right",
						},
					},
				},
			},
		},
		["Background"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["주시대상"] = {
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
						["파티의소환수"] = {
							["color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								1, -- [4]
							},
						},
						["소환수"] = {
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
		["PowerBar"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["background_alpha"] = 0.5,
						},
						["주시대상"] = {
							["background_alpha"] = 0.5,
						},
						["대상"] = {
							["background_alpha"] = 0.5,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["background_alpha"] = 0,
						},
						["파티의소환수"] = {
							["enabled"] = false,
							["background_alpha"] = 0,
						},
						["소환수"] = {
							["background_alpha"] = 0.5,
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
				["Default"] = {
					["global"] = {
						["aura"] = true,
					},
				},
			},
		},
		["Runes"] = {
			["profileKeys"] = {
				["엔카마치 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
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
		["ComboPoints"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
							["attach_to"] = "HealthBar",
							["spacing"] = 0,
							["location"] = "right",
							["size"] = 0.8500000000000001,
						},
						["주시대상"] = {
							["attach_to"] = "HealthBar",
							["spacing"] = 0,
							["location"] = "right",
							["size"] = 0.8500000000000001,
						},
						["대상"] = {
							["attach_to"] = "PowerBar",
							["spacing"] = 0,
							["location"] = "right",
							["size"] = 0.8500000000000001,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["attach_to"] = "HealthBar",
							["spacing"] = 0,
							["location"] = "right",
							["size"] = 0.8500000000000001,
						},
						["파티의소환수"] = {
							["enabled"] = false,
							["attach_to"] = "HealthBar",
							["spacing"] = 0,
							["location"] = "right",
							["size"] = 0.8500000000000001,
						},
						["소환수"] = {
							["enabled"] = false,
							["side"] = "left",
						},
						["보통"] = {
							["enabled"] = false,
							["side"] = "left",
						},
					},
				},
			},
		},
		["HealthBar"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["hostility_color_npcs"] = false,
							["background_alpha"] = 0.5,
							["hostility_color"] = false,
							["size"] = 12,
						},
						["주시대상"] = {
							["color_by_class"] = false,
							["hostility_color_npcs"] = false,
							["background_alpha"] = 0.5,
							["hostility_color"] = false,
							["size"] = 12,
						},
						["대상"] = {
							["color_pvp_by_class"] = true,
							["hostility_color_npcs"] = false,
							["background_alpha"] = 0.5,
							["size"] = 12,
						},
						["대상의대상"] = {
							["background_alpha"] = 0.5,
							["size"] = 12,
						},
						["파티의소환수"] = {
							["color_by_class"] = false,
							["hostility_color_npcs"] = false,
							["background_alpha"] = 0,
							["hostility_color"] = false,
							["size"] = 12,
						},
						["소환수"] = {
							["color_by_class"] = false,
							["hostility_color_npcs"] = false,
							["background_alpha"] = 0.5,
							["hostility_color"] = false,
							["size"] = 12,
						},
						["보통"] = {
							["color_by_class"] = false,
							["hostility_color_npcs"] = false,
							["hostility_color"] = false,
							["background_alpha"] = 0.5,
							["size"] = 12,
						},
					},
					["global"] = {
						["colors"] = {
							["max_health"] = {
								0.1803921568627451, -- [1]
								0.2313725490196079, -- [2]
								0.3372549019607843, -- [3]
							},
							["dead"] = {
								1, -- [1]
								0.04313725490196078, -- [2]
								0, -- [3]
							},
						},
					},
				},
			},
		},
		["ExperienceBar"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
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
		["ManaSpark"] = {
			["profileKeys"] = {
				["악마추적자 - 에이그윈"] = "Default",
				["Enkai - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
				},
			},
		},
		["VoiceIcon"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
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
		["VisualHeal"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ReputationBar"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["CombatFader"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CastBar"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["auto_hide"] = true,
							["show_icon"] = false,
							["background_alpha"] = 0.5,
							["size"] = 2,
						},
						["주시대상"] = {
							["auto_hide"] = true,
							["show_icon"] = false,
							["background_alpha"] = 0.5,
							["size"] = 2,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["background_alpha"] = 0.5,
							["auto_hide"] = true,
							["show_icon"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
						},
						["보통"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["PvPIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["position"] = 1.00002,
							["location"] = "edge_bottom_right",
						},
						["주시대상"] = {
							["position"] = 1.00002,
							["location"] = "edge_bottom_right",
						},
						["대상"] = {
							["position"] = 1.00002,
							["location"] = "edge_bottom_right",
						},
						["대상의대상"] = {
							["enabled"] = false,
							["position"] = 1.00002,
							["location"] = "edge_bottom_right",
						},
						["파티의소환수"] = {
							["enabled"] = false,
							["position"] = 1.00002,
							["location"] = "edge_bottom_right",
						},
						["소환수"] = {
							["enabled"] = false,
							["position"] = 1.00002,
							["location"] = "edge_bottom_left",
						},
						["보통"] = {
							["position"] = 1.00002,
							["location"] = "edge_bottom_left",
						},
					},
				},
			},
		},
		["BlankSpace"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["주시대상"] = {
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
						["대상의대상"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["소환수"] = {
							["elements"] = {
								["기본값"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["파티의소환수"] = {
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
					},
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ThreatBar"] = {
			["profileKeys"] = {
				["Enkai - 우서"] = "Default",
				["엔카마치 - 우서"] = "Default",
				["챈트마스터 - 에이그윈"] = "Default",
				["악마추적자 - 에이그윈"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티"] = {
							["enabled"] = false,
						},
						["주시대상"] = {
							["enabled"] = false,
						},
						["대상"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["소환수"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
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
		["LeaderIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["소환수"] = {
							["enabled"] = false,
						},
						["대상의대상"] = {
							["enabled"] = false,
						},
						["파티의소환수"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["Border"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["파티의소환수"] = {
							["enabled"] = false,
							["rare_texture"] = "None",
							["elite_texture"] = "None",
						},
						["주시대상"] = {
							["rare_texture"] = "Skinner EditBox/ScrollBar Border",
							["rare_color"] = {
								0.9294117647058824, -- [1]
								1, -- [2]
								0.9137254901960784, -- [3]
								0.4900000095367432, -- [4]
							},
							["elite_texture"] = "Skinner EditBox/ScrollBar Border",
							["padding"] = 4,
							["elite_color"] = {
								nil, -- [1]
								0.580392156862745, -- [2]
								0.2352941176470588, -- [3]
								0.4900000095367432, -- [4]
							},
							["size"] = 18,
						},
						["대상"] = {
							["rare_texture"] = "Skinner EditBox/ScrollBar Border",
							["rare_color"] = {
								0.9215686274509803, -- [1]
								1, -- [2]
								0.9294117647058824, -- [3]
								0.4900000095367432, -- [4]
							},
							["elite_texture"] = "Skinner EditBox/ScrollBar Border",
							["padding"] = 4,
							["elite_color"] = {
								nil, -- [1]
								0.6392156862745098, -- [2]
								0.2666666666666667, -- [3]
								0.5200000107288361, -- [4]
							},
							["size"] = 18,
						},
						["대상의대상"] = {
							["enabled"] = false,
							["rare_texture"] = "None",
							["elite_texture"] = "None",
						},
						["파티"] = {
							["enabled"] = false,
							["rare_texture"] = "DevilSquare",
							["elite_texture"] = "DevilSquare",
							["padding"] = 1,
							["size"] = 7,
						},
						["소환수"] = {
							["enabled"] = false,
							["padding"] = 1,
							["size"] = 7,
						},
						["보통"] = {
							["enabled"] = false,
							["rare_color"] = {
								0.1294117647058823, -- [1]
								0.9529411764705882, -- [2]
								1, -- [3]
								0.8100000023841858, -- [4]
							},
							["normal_texture"] = "DevilSquare",
							["normal_color"] = {
								nil, -- [1]
								nil, -- [2]
								nil, -- [3]
								0.7900000065565109, -- [4]
							},
							["elite_color"] = {
								nil, -- [1]
								0.4509803921568628, -- [2]
								nil, -- [3]
								0.7900000065565109, -- [4]
							},
							["size"] = 10,
						},
					},
				},
			},
		},
		["Aggro"] = {
			["profileKeys"] = {
				["엔카마치 - 우서"] = "Default",
				["Enkai - 우서"] = "Default",
				["돌쇠와마님 - 우서"] = "Default",
				["엔카이얀 - 우서"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
	},
	["profileKeys"] = {
		["Enkai - 우서"] = "Default",
		["엔카마치 - 우서"] = "Default",
		["돌쇠와마님 - 우서"] = "Default",
		["초코칸 - 우서"] = "Default",
		["엔카이얀 - 우서"] = "Default",
	},
	["profiles"] = {
		["Default"] = {
			["minimap_icon"] = {
				["minimapPos"] = 340.9108023154146,
				["hide"] = true,
			},
			["colors"] = {
				["reaction"] = {
					nil, -- [1]
					{
						nil, -- [1]
						0, -- [2]
						0.01568627450980392, -- [3]
					}, -- [2]
					nil, -- [3]
					nil, -- [4]
					{
						0.2470588235294118, -- [1]
						0.7686274509803921, -- [2]
						0.9254901960784314, -- [3]
					}, -- [5]
					{
						nil, -- [1]
						0.8588235294117647, -- [2]
						0.1568627450980392, -- [3]
					}, -- [6]
					{
						nil, -- [1]
						0.8509803921568627, -- [2]
						0.1411764705882353, -- [3]
					}, -- [7]
					{
						nil, -- [1]
						0.8431372549019608, -- [2]
						0.1411764705882353, -- [3]
					}, -- [8]
				},
				["power"] = {
					["MANA"] = {
						0.3686274509803922, -- [1]
						0.6549019607843137, -- [2]
					},
				},
			},
			["made_groups"] = true,
			["layouts"] = {
				["파티"] = {
					["size_x"] = 240,
					["size_y"] = 36,
					["bar_texture"] = "Minimalist",
				},
				["주시대상"] = {
					["size_x"] = 300,
					["size_y"] = 40,
					["bar_texture"] = "Minimalist",
				},
				["대상"] = {
					["size_x"] = 305,
					["size_y"] = 40,
					["bar_texture"] = "Minimalist",
				},
				["대상의대상"] = {
					["size_x"] = 120,
					["size_y"] = 30,
					["bar_texture"] = "Minimalist",
				},
				["파티의소환수"] = {
					["size_x"] = 120,
					["size_y"] = 30,
					["bar_texture"] = "Minimalist",
				},
				["소환수"] = {
					["size_x"] = 140,
					["size_y"] = 30,
					["bar_texture"] = "Minimalist",
				},
				["보통"] = {
					["size_x"] = 300,
					["size_y"] = 40,
					["bar_texture"] = "Minimalist",
				},
			},
			["groups"] = {
				["파티원 소환수"] = {
					["vertical_spacing"] = 37,
					["direction"] = "up_right",
					["position_x"] = 757,
					["enabled"] = true,
					["size_x"] = 0.95,
					["size_y"] = 0.8,
					["unit_group"] = "partypet",
					["layout"] = "파티의소환수",
					["position_y"] = -339.9361999030132,
				},
				["파티원 대상"] = {
					["vertical_spacing"] = 31,
					["direction"] = "up_right",
					["position_x"] = 756.7576718002003,
					["enabled"] = true,
					["size_x"] = 0.95,
					["unit_group"] = "partypet",
					["layout"] = "파티의소환수",
					["position_y"] = -311.8651398166853,
				},
				["파티"] = {
					["vertical_spacing"] = 25,
					["direction"] = "up_right",
					["position_x"] = 935.2444364416178,
					["enabled"] = true,
					["layout"] = "파티",
					["position_y"] = -315.726863280436,
				},
			},
			["lock_movement"] = true,
			["units"] = {
				["targettargettarget"] = {
					["enabled"] = false,
					["position_y"] = -280.0000103810415,
					["layout"] = "대상의대상",
				},
				["focustarget"] = {
					["position_x"] = 465,
					["position_y"] = -152,
					["layout"] = "대상의대상",
				},
				["pet"] = {
					["position_x"] = -330,
					["position_y"] = -365,
					["layout"] = "소환수",
				},
				["player"] = {
					["position_x"] = -250,
					["position_y"] = -306,
				},
				["focus"] = {
					["position_x"] = 250,
					["position_y"] = -156,
					["layout"] = "주시대상",
				},
				["target"] = {
					["position_x"] = 250,
					["position_y"] = -306,
					["layout"] = "대상",
				},
				["targettarget"] = {
					["position_y"] = -310,
					["layout"] = "대상의대상",
				},
				["focustargettarget"] = {
					["enabled"] = false,
					["layout"] = "대상의대상",
				},
				["pettarget"] = {
					["enabled"] = false,
					["layout"] = "파티",
				},
			},
		},
	},
}

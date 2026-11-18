
smmConfig = {
	["namespaces"] = {
		["pings"] = {
			["profiles"] = {
				["Default"] = {
					["position"] = 1,
					["scale"] = 0.8500000000000001,
				},
			},
		},
		["movers"] = {
			["profiles"] = {
				["Default"] = {
					["enabled"] = true,
					["framePos"] = {
						["QuestTimerFrame"] = {
							105.8600311279297, -- [1]
							1133.171630859375, -- [2]
						},
						["DurabilityFrame"] = {
							1448.904418945313, -- [1]
							229.0158996582031, -- [2]
						},
						["CaptureMover"] = {
							742.4847412109375, -- [1]
							1112.296752929688, -- [2]
						},
						["QuestWatchFrame"] = {
							97.89102935791016, -- [1]
							1018.547546386719, -- [2]
						},
					},
				},
			},
		},
		["skins"] = {
			["profiles"] = {
				["Default"] = {
					["border"] = false,
					["skin"] = 2,
				},
			},
		},
	},
	["profiles"] = {
		["Default"] = {
			["strata"] = 2,
			["mapPosition"] = {
				589.3429946396573, -- [1]
				61.48553573506615, -- [2]
			},
			["scale"] = 1.05,
			["lockdown"] = true,
			["show"] = {
				["zoom"] = false,
				["time"] = false,
				["map"] = false,
			},
			["lock"] = true,
			["locationShow"] = false,
			["buttonPos"] = {
				["mail"] = 18.40575174816669,
				["track"] = 138.399490247151,
				["bgs"] = 214.8882152838733,
			},
			["radius"] = -18,
		},
	},
	["disabledModules"] = {
		["Default"] = {
			["skins"] = false,
			["movers"] = false,
			["gui"] = false,
		},
	},
}

if IsAddOnLoaded("cyCircled") then
	local addonName = "BlueTrinket"
	cyCircled_BlueTrinket = cyCircled:NewModule(addonName)
	local cyCircledStyle = 4

	function cyCircled_BlueTrinket:AddonLoaded()
		cyCircled_BlueTrinket.db = cyCircled:AcquireDBNamespace(addonName)
		cyCircled:RegisterDefaults(addonName, "profile", {
			["apply"] = true,
		})
		cyCircled_BlueTrinket:SetupElements()
		cyCircled_BlueTrinket:OnEnable()
	end

	function cyCircled_BlueTrinket:GetElements()
		return { ["apply"] = "스킨 적용" }
	end

	function cyCircled_BlueTrinket:SetupElements()
		cyCircled_BlueTrinket.elements = {
			["apply"] = {
				args = {
					button = { width = 35, height = 35, },
					ft = false,
					hotkey = false,
				},
				elements = {},
			},
		}
		for i = 1, 30 do
			tinsert(cyCircled_BlueTrinket.elements["apply"].elements, format("BlueTrinketButton%d", i))
		end
	end
elseif IsAddOnLoaded("Tools") and IsAddOnLoaded("ToolsButtonTexture") then
	local v = {}
	for i = 1, #(ToolsCommonButton.value) do
		v[i] = ToolsCommonButton.value[i][1]
	end

	local function getSkinNum(skinName)
		for i = 1, #(v) do
			if skinName == v[i] then
				return i
			end
		end
		return 1
	end

	function BlueTrinket.AddSkinMenu()
		BlueTrinket.menu.args.skin = {
			name = "스킨(Tools)",
			type = "text",
			desc = "버튼의 스킨을 설정합니다.",
			order = 2,
			validate = v,
			get = function() return BlueTrinket.db.profile.toolskin end,
			set = function(value)
				BlueTrinket.db.profile.toolskin = value
				BlueTrinket.ApplySkin()
			end,
		}
	end

	function BlueTrinket.ApplySkin(frame)
		local t = getSkinNum(BlueTrinket.db.profile.toolskin)
		if frame then
			ToolsCommonButton:SetButtonTexture(frame, t)
		else
			for i = 1, 30 do
				frame = getglobal("BlueTrinketButton"..i)
				if frame then
					ToolsCommonButton:SetButtonTexture(frame, t)
				else
					break
				end
			end
		end
	end
end
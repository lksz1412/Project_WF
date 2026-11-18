--[[

	Roll Window Fix - version 1.1 (2/4/10)
	Faucette(Roxanna) - Dalaran (US)

	Change Log
	==========
	1.1   - Fixed a logic issue when scaling frame a second time (such as after the player changed the UI scale)
				- Updated ToC for 3.3 (errorously used 3.2 interface number in initial release)

	1.0		- Initial Release
	==========

]]--

local RWF_GroupLootFrame_OnShow = function(self, ...)
	if math.abs(self:GetEffectiveScale() - 1) > 0.01 then -- Roll Window is not full size
		self:SetScale(1 / self:GetParent():GetEffectiveScale()) -- Rescale the frame to be full size
	end
	if self.OldOnShow then -- If the frame had another OnShow script before...
		self:OldOnShow(...)  --   Call the function
	end
end

GroupLootFrame1.OldOnShow = GroupLootFrame1:GetScript("OnShow") -- Theoretically these are all the same function,
GroupLootFrame2.OldOnShow = GroupLootFrame2:GetScript("OnShow") --   but if another addon loads first,
GroupLootFrame3.OldOnShow = GroupLootFrame3:GetScript("OnShow") --     it could change each of these to have their own,
GroupLootFrame4.OldOnShow = GroupLootFrame4:GetScript("OnShow") --       so I grab each frame's individually.

GroupLootFrame1:SetScript("OnShow", RWF_GroupLootFrame_OnShow) -- Change each
GroupLootFrame2:SetScript("OnShow", RWF_GroupLootFrame_OnShow) --   frame's OnShow
GroupLootFrame3:SetScript("OnShow", RWF_GroupLootFrame_OnShow) --     script to
GroupLootFrame4:SetScript("OnShow", RWF_GroupLootFrame_OnShow) --       my function.

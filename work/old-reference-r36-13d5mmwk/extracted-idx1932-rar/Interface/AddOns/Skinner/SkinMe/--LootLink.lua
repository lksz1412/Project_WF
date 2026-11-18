
function Skinner:LootLink() 

	self:removeRegions(LootLinkFrame, {2, 3, 4, 5})

	LootLinkFrame:SetWidth(LootLinkFrame:GetWidth() - 30)
	LootLinkFrame:SetHeight(LootLinkFrame:GetHeight() - 70)

	self:moveObject(LootLinkFrameCloseButton, "+", 15, nil, nil)
	self:moveObject(LootLinkTitleText, "+", 15, nil, nil)

	self:removeRegions(LootLinkListScrollFrame)
	self:skinScrollBar(LootLinkListScrollFrame)

	self:skinTooltip(LootLinkTooltip)
	self:skinTooltip(LLHiddenTooltip)

	self:applySkin(LootLinkFrame, {2, 3, 4, 5})
	self:applySkin(LootLinkSearchFrame)

end

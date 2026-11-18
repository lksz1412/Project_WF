local _G = getfenv(0)

function Skinner:SM_ImprovedHandle() 
	if not self.db.profile.AuctionFrame or self.initialized.AuctionUI then return end
	self.initialized.AuctionUI = true
	
-->>-- Tabs
	if self.db.profile.TexturedTab then
		self:SecureHook("AuctionFrameTab_OnClick", function(index)
-- 	   		self:Debug("AuctionFrameTab_OnClick: [%s]", index)
			for i = 1, AuctionFrame.numTabs do
				local tabName = _G["AuctionFrameTab"..i]
				if i == AuctionFrame.selectedTab then
					self:setActiveTab(tabName)
				else
					self:setInactiveTab(tabName)
				end
			end
			end)
	end
	-- hide filter texture when filter is clicked
	self:SecureHook("FilterButton_SetType", function(button, type, text, isLast)
		_G[button:GetName().."NormalTexture"]:SetAlpha(0)
		end)

	self:keepFontStrings(AuctionFrame)
	AuctionFrame:SetHeight(AuctionFrame:GetHeight() - 6)

	self:moveObject(AuctionFrameCloseButton, "-", 4, "+", 8)

-->>--	All Tabs
	for i = 1, AuctionFrame.numTabs do
		local tabName = _G["AuctionFrameTab"..i]
		self:keepRegions(tabName, {7, 8}) -- N.B. region 7 is the Text, 8 is the highlight
		if self.db.profile.TexturedTab then self:applySkin(tabName, nil, 0)
		else self:storeAndSkin(ftype, tabName) end
		if i == 1 then
			self:moveObject(tabName, nil, nil, "-", 4)
			if self.db.profile.TexturedTab then self:setActiveTab(tabName) end
		else
			self:moveObject(tabName, "+", 3, nil, nil)
			if self.db.profile.TexturedTab then self:setInactiveTab(tabName) end
		end
	end

	self:moveObject(AuctionFrameMoneyFrame, nil, nil, "-", 6)

-->>--	Browse Frame
	self:moveObject(BrowseTitle, nil, nil, "+", 6)

	self:removeRegions(BrowseFilterScrollFrame)
	self:skinScrollBar(BrowseFilterScrollFrame)
	self:removeRegions(BrowseScrollFrame)
	self:skinScrollBar(BrowseScrollFrame)

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		self:keepRegions(_G["AuctionFilterButton"..i], {3, 4}) -- N.B. region 3 is the highlight, 4 is the text
		self:storeAndSkin(ftype, _G["AuctionFilterButton"..i])
	end

	self:skinDropDown(BrowseDropDown)
	self:moveObject(BrowseDropDownName, "+", 40, nil, nil)

	for k, v in pairs({ BrowseQualitySort, BrowseLevelSort, BrowseDurationSort,	BrowseHighBidderSort, BrowseCurrentBidSort }) do
		self:keepFontStrings(v)
		self:storeAndSkin(ftype, v)
	end

	for k, v in pairs({ "BrowseName", "BrowseMinLevel", "BrowseMaxLevel" }) do
		self:skinEditBox(_G[v], {9})
		self:moveObject(_G[v], "-", 10, "+", (k ~= 3 and 3 or 0))
		_G[v]:SetWidth(_G[v]:GetWidth() + 4)
	end

	self:skinMoneyFrame(BrowseBidPrice)

-->>--	Bid Frame
	self:moveObject(BidTitle, nil, nil, "+", 6)

	self:removeRegions(BidScrollFrame)
	self:skinScrollBar(BidScrollFrame)

	for k, v in pairs({ _G["BidQualitySort"], BidLevelSort, BidDurationSort, BidBuyoutSort, BidStatusSort, BidBidSort }) do
		self:keepFontStrings(v)
		self:storeAndSkin(ftype, v)
	end

	self:skinMoneyFrame(BidBidPrice)

-->>--	Auctions Frame
	self:moveObject(AuctionsTitle, nil, nil, "+", 6)
	self:storeAndSkin(ftype, AuctionsItemButton)
	self:removeRegions(AuctionsScrollFrame)
	self:skinScrollBar(AuctionsScrollFrame)

	for k, v in pairs({ AuctionsQualitySort, AuctionsDurationSort, AuctionsHighBidderSort, AuctionsBidSort }) do
		self:keepFontStrings(v)
		self:storeAndSkin(ftype, v)
	end

	self:skinMoneyFrame(StartPrice)
	self:skinMoneyFrame(BuyoutPrice)

	self:storeAndSkin(ftype, AuctionFrame)

-->>--	AuctionDressUp Frame
	self:keepRegions(AuctionDressUpFrame, {3, 4}) --N.B. regions 3 & 4 are the background
	AuctionDressUpFrame:SetWidth(AuctionDressUpFrame:GetWidth() - 6)
	AuctionDressUpFrame:SetHeight(AuctionDressUpFrame:GetHeight() - 13)
	self:moveObject(AuctionDressUpBackgroundTop, nil, nil, "+", 8)

	AuctionDressUpModelRotateLeftButton:Hide()
	AuctionDressUpModelRotateRightButton:Hide()
	self:makeMFRotatable(AuctionDressUpModel)

	self:keepRegions(AuctionDressUpFrameCloseButton, {1}) -- N.B. region 1 is the button artwork
	self:storeAndSkin(ftype, AuctionDressUpFrame)

end

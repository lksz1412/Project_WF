-- Recipe Filtering Code from SM_ImprovedHandle (http://wow.somegate.com/topic.php?topic_uid=106895)
--------------------------------------------------------------------------------
local ITEM_SPELL_KNOWN = ITEM_SPELL_KNOWN;


function CatRecipe_OnLoad()
	this:RegisterEvent("ADDON_LOADED");
	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", CatRecipe_Merchant);
end


function CatRecipe_OnEvent()
	if (arg1 == "Blizzard_AuctionUI") then
		this:UnregisterEvent("ADDON_LOADED");
		hooksecurefunc("AuctionFrameBrowse_Update", CatRecipe_Auction);
	end
end


function CatRecipe_Merchant()
	local numItems = GetMerchantNumItems();
	local tt = "";
	local x;
	local maximum = 10;
	if ((MerchantFrame.page * 10) > numItems) then
		maximum =  numItems - ((MerchantFrame.page-1) * 10);
	end
	for i=1, maximum do
		local PageID = (MerchantFrame.page - 1) * 10
		local ItemID = PageID + i;
		CatRecipeTooltip:SetOwner(UIParent, "ANCHOR_NONE");
		CatRecipeTooltip:SetMerchantItem(ItemID);
		local lines = CatRecipeTooltip:NumLines();
		if (lines > 5) then lines = 5; end
		tt = "";
		for x=2, lines do
			tt = tt.."\n"..getglobal("CatRecipeTooltipTextLeft"..x):GetText();
		end
		if strfind(tt, ITEM_SPELL_KNOWN) then
			local itemButton = getglobal("MerchantItem"..i.."ItemButton");
			local merchantButton = getglobal("MerchantItem"..i);
			SetItemButtonNameFrameVertexColor(merchantButton, 0, 0, 1);
			SetItemButtonSlotVertexColor(merchantButton, 0, 0, 1);
			SetItemButtonTextureVertexColor(itemButton, 0, 0, 1);
			SetItemButtonNormalTextureVertexColor(itemButton, 0, 0, 1);
		end
	end
end


function CatRecipe_Auction()
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame);
	local index;
	local tt = "";
	for i=1, NUM_BROWSE_TO_DISPLAY do
		index = offset + i;
		CatRecipeTooltip:SetOwner(UIParent, "ANCHOR_NONE");
		CatRecipeTooltip:SetAuctionItem("list", index);
		local lines = CatRecipeTooltip:NumLines();
		if (lines > 5) then lines = 5; end
		tt = "";
		for x=2, lines do
			tt = tt.."\n"..getglobal("CatRecipeTooltipTextLeft".. x):GetText();
		end
		if strfind(tt, ITEM_SPELL_KNOWN) then
			ItemIconTexture = getglobal("BrowseButton"..i.."ItemIconTexture");
			ItemIconTexture:SetVertexColor(0, 0, 1);
		end
	end
end
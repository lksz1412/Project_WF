--[[
List of button attributes
======================================================
info.text = [STRING]  --  The text of the button
info.value = [ANYTHING]  --  The value that UIDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
info.func = [function()]  --  The function that is called when you click the button
info.checked = [nil, 1]  --  Check the button
info.isTitle = [nil, 1]  --  If it's a title the button is disabled and the font color is set to yellow
info.disabled = [nil, 1]  --  Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
info.hasArrow = [nil, 1]  --  Show the expand arrow for multilevel menus
info.hasColorSwatch = [nil, 1]  --  Show color swatch or not, for color selection
info.r = [1 - 255]  --  Red color value of the color swatch
info.g = [1 - 255]  --  Green color value of the color swatch
info.b = [1 - 255]  --  Blue color value of the color swatch
info.textR = [1 - 255]  --  Red color value of the button text
info.textG = [1 - 255]  --  Green color value of the button text
info.textB = [1 - 255]  --  Blue color value of the button text
info.swatchFunc = [function()]  --  Function called by the color picker on color change
info.hasOpacity = [nil, 1]  --  Show the opacity slider on the colorpicker frame
info.opacity = [0.0 - 1.0]  --  Percentatge of the opacity, 1.0 is fully shown, 0 is transparent
info.opacityFunc = [function()]  --  Function called by the opacity slider when you change its value
info.cancelFunc = [function(previousValues)] -- Function called by the colorpicker when you click the cancel button (it takes the previous values as its argument)
info.notClickable = [nil, 1]  --  Disable the button and color the font white
info.notCheckable = [nil, 1]  --  Shrink the size of the buttons and don't display a check box
info.owner = [Frame]  --  Dropdown frame that "owns" the current dropdownlist
info.keepShownOnClick = [nil, 1]  --  Don't hide the dropdownlist after a button is clicked
info.tooltipTitle = [nil, STRING] -- Title of the tooltip shown on mouseover
info.tooltipText = [nil, STRING] -- Text of the tooltip shown on mouseover
info.justifyH = [nil, "CENTER"] -- Justify button text
info.arg1 = [ANYTHING] -- This is the first argument used by info.func
info.arg2 = [ANYTHING] -- This is the second argument used by info.func
info.textHeight = [NUMBER] -- font height for button text
]]


--NDFAV_CATEGORY_HEIGHT = 20;
--NDFAV_ITEM_BUTTON_HEIGHT = 30;
--NDFAV_ITEMS_SHOWN = 14;

NDFAV_ADDMETHOD_HELPTEXT = "1. |cff00ff00NuguDrop|r 브라우저에서 추가 (|cffffff00우클릭|r)|n2. |cff00ff00Examiner|r 훔쳐보기창에서 추가 (|cff00ffff좌클릭|r)|n3. |cff00ff00SuperInspect|r 훔쳐보기창에서 추가 (|cffffff00우클릭|r)|n4. |cff00ff00Saeris LootLink|r 창에서 추가 (|cffffff00우클릭|r)|n5. |cff00ff00하늘아리 LootLink|r 창에서 추가 (|cffffff00우클릭|r)|n6. |cff00ff00LudWig|r 창에서 추가 (|cff00ffffAlt+클릭|r)|n7. |cff00ff00ItemSync|r 창에서 추가 (|cffffff00우클릭|r)"

ND_FavMenu_List = {
	[1]={["전사(방어)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","방패","도끼","도검", "둔기","원거리","보석","기타"}},
	[2]={["전사(무분)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","방패","도끼","도검", "둔기","원거리","보석","기타"}},
	[3]={["성기사(신성)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","성서","보석","기타"}},
	[4]={["성기사(보호)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","성서","보석","기타"}},
	[5]={["성기사(징벌)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","성서","보석","기타"}},
	[6]={["주술사(고양)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","토템","보석","기타"}},
	[7]={["주술사(정기)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","토템","보석","기타"}},
	[8]={["주술사(복원)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","토템","보석","기타"}},
	[9]={["사냥꾼"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","활","총","탄력도","보석","기타"}},
	[10]={["도적"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","단검", "도검", "둔기", "장착무기","투척","보석","기타"}},
	[11]={["드루이드(야성)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","우상","보석","기타"}},
	[12]={["드루이드(조화)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","우상","보석","기타"}},
	[13]={["드루이드(회복)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","우상","보석","기타"}},
	[14]={["흑마법사"]={"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","암흑데미지","기타"}},
	[15]={["마법사"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","화염데미지","냉기데미지","기타"}},
	[16]={["사제(신수)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","기타"}},
	[17]={["사제(암흑)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","암흑데미지","기타"}},
	[18]={["기타"] = {"1순위", "2순위", "특이한 템들"}},
}

NDFavorites_Class = {"전사(방어)", "전사(무분)", "성기사(신성)", "성기사(보호)", "성기사(징벌)","주술사(고양)", "주술사(정기)", "주술사(복원)", "사냥꾼", "도적","드루이드(야성)", "드루이드(조화)", "드루이드(회복)", "흑마법사", "마법사", "사제(신수)", "사제(암흑)", "기타"};

NDFavorites_default = {
	["전사(방어)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","방패","도끼","도검", "둔기","원거리","보석","기타"},
	["전사(무분)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","방패","도끼","도검", "둔기","원거리","보석","기타"},
	["성기사(신성)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","성서","보석","기타"},
	["성기사(보호)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","성서","보석","기타"},
	["성기사(징벌)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","성서","보석","기타"},
	["주술사(고양)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","토템","보석","기타"},
	["주술사(정기)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","토템","보석","기타"},
	["주술사(복원)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","방패","토템","보석","기타"},
	["사냥꾼"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","활","총","탄력도","보석","기타"},
	["도적"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","단검", "도검", "둔기", "장착무기","투척","보석","기타"},
	["드루이드(야성)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","우상","보석","기타"},
	["드루이드(조화)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","우상","보석","기타"},
	["드루이드(회복)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","우상","보석","기타"},
	["흑마법사"]={"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","암흑데미지","기타"},
	["마법사"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","화염데미지","냉기데미지","기타"},
	["사제(신수)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","기타"},
	["사제(암흑)"] = {"머리","목","어깨","망토","가슴","손목","장갑","허리","다리","발","반지","장신구","무기","보조장비","마법봉","보석","암흑데미지","기타"},
	["기타"] = {"1순위", "2순위", "특이한 템들"},
}

function ND_Favorites()
	ND_Fav_CheckUpdate();
	-- 나중에 수정을...
	ND_FavList_Init();
	PlaySound("igMainMenuOpen");
	if NDFavoritesTitleFrame:IsVisible() then
		HideUIPanel(NDFavoritesTitleFrame);
		HideUIPanel(NDFavoritesFrame);
	else
		ShowUIPanel(NDFavoritesTitleFrame);
		ShowUIPanel(NDFavoritesFrame);
		ND_FavList_Generator();
		tinsert(UISpecialFrames,"NDFavoritesTitleFrame");
	end
	NDFav_ItemList_SelectClassText:Show()
end

function ND_Fav_CheckUpdate()
	if not NDFavorites then
		NDFavorites = {};
		ND_FavList_Init();
	else
		local NDVer = tonumber(GetAddOnMetadata("NuguDrop", "Versions"))
--NuguDrop_Print("NDVER : "..NDVer)
		if (NDVer > 3.7) and (not NDFavorites["전사(방어)"]) then
			if NDFavorites["전사"] then
				NDFavorites["전사(방어)"] = {};
				NDFavorites["전사(무분)"] = {};
				NDFavorites["전사(방어)"] = NDFavorites["전사"];
				NDFavorites["전사"] = nil
			end
			if NDFavorites["성기사"] then
				NDFavorites["성기사(신성)"] = {};
				NDFavorites["성기사(징벌)"] = {};
				NDFavorites["성기사(보호)"] = {};
				NDFavorites["성기사(신성)"] = NDFavorites["성기사"];
				NDFavorites["성기사"] = nil
			end
			if NDFavorites["주술사"] then
				NDFavorites["주술사(고양)"] = {};
				NDFavorites["주술사(정기)"] = {};
				NDFavorites["주술사(복원)"] = {};
				NDFavorites["주술사(복원)"] = NDFavorites["주술사"];
				NDFavorites["주술사"] = nil
			end
			if NDFavorites["드루이드"] then
				NDFavorites["드루이드(야성)"] = {};
				NDFavorites["드루이드(조화)"] = {};
				NDFavorites["드루이드(회복)"] = {};
				NDFavorites["드루이드(야성)"] = NDFavorites["드루이드"];
				NDFavorites["드루이드"] = nil
			end
			if NDFavorites["사제"] then
				NDFavorites["사제(신수)"] = {};
				NDFavorites["사제(암흑)"] = {};
				NDFavorites["사제(신수)"] = NDFavorites["사제"];
				NDFavorites["사제"] = nil
			end
		end
	end
	return
end

function ND_FavList_Init()
	for _, cl in ipairs(NDFavorites_Class) do
		if not NDFavorites[cl] then
			NDFavorites[cl] = {};
		end
--		for i = 1, table.getn(NDFavorites_default[cl]) do
		for i = 1, #NDFavorites_default[cl] do
			local ca = NDFavorites_default[cl][i];
			if not NDFavorites[cl][ca] then
				NDFavorites[cl][ca] = {};
			end
		end
	end
end

function ND_FavList_Flush()
	if NDFavoritesFrame:IsVisible() and prevBtnCount then
		for i = 1, prevBtnCount do
			if (getglobal("NDFav_CategoryButton"..i)) then
				getglobal("NDFav_CategoryButton"..i):UnlockHighlight();
				getglobal("NDFav_CategoryButton"..i):Hide();
			end
		end
	end
end

function ND_FavList_Generator()
	if (not NuguDropOption["lastseen"]) then
		NuguDropOption["lastseen"] = 1;
	end
	local lastframe = "ND_Class"..NuguDropOption.lastseen.."0"
	getglobal(lastframe):SetBackdropColor(1, 0, 0, 1);

	local cl = NDFavorites_Class[NuguDropOption.lastseen];
	--NuguDrop_Print("-class- "..cl);
	--for ca, tbl in pairs(NDFavorites[cl]) do
	--NuguDrop_Print("--- ca : "..ca);
	--end
	local i = 1;
	for n = 1, #NDFavorites_default[cl] do
		local ca = NDFavorites_default[cl][i];
		--NuguDrop_Print("--- ca : "..ca);

		if (getglobal("NDFav_CategoryButton"..i) == nil) then
			CreateFrame("button", "NDFav_CategoryButton"..i, NDFav_Category_ItemList, "NDFav_CategoryButton_Template");
			CreateFrame("button", "NDFav_CategoryButton"..i.."_Delete", NDFav_Category_ItemList, "NDFav_CategoryButton_Delete_Template");
			CreateFrame("button", "NDFav_CategoryButton"..i.."_Modify", NDFav_Category_ItemList, "NDFav_CategoryButton_Modify_Template");
		end
		if i == 1 then
			getglobal("NDFav_CategoryButton"..i):SetPoint("TOPLEFT",0,-5);
			getglobal("NDFav_CategoryButton"..i.."_Delete"):SetPoint("TOPLEFT",112,-5);
			getglobal("NDFav_CategoryButton"..i.."_Modify"):SetPoint("TOPLEFT",100,-5);
		else
			getglobal("NDFav_CategoryButton"..i):SetPoint("TOPLEFT","NDFav_CategoryButton"..(i-1),"BOTTOMLEFT", 0, -3);
			getglobal("NDFav_CategoryButton"..i.."_Delete"):SetPoint("TOPLEFT","NDFav_CategoryButton"..(i-1).."_Delete","BOTTOMLEFT", 0, -9);
			getglobal("NDFav_CategoryButton"..i.."_Modify"):SetPoint("TOPLEFT","NDFav_CategoryButton"..(i-1).."_Modify","BOTTOMLEFT", 0, -9);
		end
--		local button = "NDFav_CategoryButton"..i
--		local buttontext = getglobal("NDFav_CategoryButton"..i.."Text")
		getglobal("NDFav_CategoryButton"..i.."Text"):SetText(ca);
		getglobal("NDFav_CategoryButton"..i.."Text"):SetTextColor(1, 1, 0);
		--buttontext:SetHighlightTextColor(1, 0, 0, 1)

		local j = 0;
		for k, v in pairs(NDFavorites[cl][ca]) do
			j = j + 1;
		end
		--NuguDrop_Print("--- j : "..j);
		if j > 0 then
			getglobal("NDFav_CategoryButton"..i.."Sum"):SetText(j);

			getglobal("NDFav_CategoryButton"..i.."Sum"):SetTextColor(0, 1, 0);
		else
			getglobal("NDFav_CategoryButton"..i.."Sum"):SetText("");
		end
		getglobal("NDFav_CategoryButton"..i):Enable();
		getglobal("NDFav_CategoryButton"..i.."_Delete"):Enable();
		getglobal("NDFav_CategoryButton"..i.."_Modify"):Enable();
		getglobal("NDFav_CategoryButton"..i):Show();
		getglobal("NDFav_CategoryButton"..i.."_Delete"):Hide();
		getglobal("NDFav_CategoryButton"..i.."_Modify"):Hide();
		i = i + 1;
	end
	prevBtnCount = i;

	local ND_titlestr = "|cffff1111◀|r |cffffff11"..getglobal("NDClass"..NuguDropOption["lastseen"]):GetText().."|r |cffff1111▶|r"
	NDFavoritesTitleFrameClass:SetText(ND_titlestr)

--NuguDrop_Print("--- prevItemBtnCount : "..prevItemBtnCount);
	if prevItemBtnCount then
		NDFav_ItemList_Flush()
		NDFavoritesFrame:SetHeight(516)
	end
	NDFav_ItemList_NoItemsText:Hide()
	NDFav_ItemList_AddItemsText:Hide()
	NDFav_ItemList_AddMethodText:Hide()
	NDFav_ItemList_DeleteItemsText:Hide()
	NDFav_ItemList_DeleteMethodText:Hide();
	NDFav_ItemList_SelectClassText:Show()
end

-- newFrame = CreateFrame("frameType", "frameName", parentFrame[, "inheritsFrame"]);
-- Region:SetPoint("point","relativeFrame" or relativeObject,"relativePoint"[, xOfs, yOfs])

--function ND_Fav_Category_Update()
--end

function ND_Fav_Category_OnClick(button)
--	NuguDrop_Print("|cff00ffff ND_Fav_Category_OnClick ▶ |r"..button);

	if prevButton then
		getglobal(prevButton):UnlockHighlight();
		getglobal(prevButton.."_Delete"):UnlockHighlight();
		getglobal(prevButton.."_Delete"):Hide();
		getglobal(prevButton.."_Modify"):UnlockHighlight();
		getglobal(prevButton.."_Modify"):Hide();
	end
	prevButton = button;
	getglobal(button):LockHighlight();
	getglobal(prevButton.."_Delete"):Show();
	getglobal(prevButton.."_Modify"):Show();

	if prevItemBtnCount then
		NDFav_ItemList_Flush()
	end

	NDFav_cl = NDFavorites_Class[NuguDropOption.lastseen];
	NDFav_ca = getglobal(button.."Text"):GetText();
--	NuguDrop_Print("--- NDFav_cl : "..NDFav_cl.." / NDFav_ca : "..NDFav_ca);
	local i = 0;
	itemlist = {};
	for k, v in pairs(NDFavorites[NDFav_cl][NDFav_ca]) do
		table.insert(itemlist, k);
		i = i + 1;
	end
--	NuguDrop_Print("i = "..i);

	NDFav_ItemList_SelectClassText:Hide()
	if i == 0 then
		NDFav_ItemList_NoItemsText:Show();
		NDFav_ItemList_AddItemsText:Show();
		NDFav_ItemList_AddMethodText:Show();
		NDFav_ItemList_DeleteItemsText:Show();
		NDFav_ItemList_DeleteMethodText:Show();
	else
		NDFav_ItemList_NoItemsText:Hide()
		NDFav_ItemList_AddItemsText:Hide()
		NDFav_ItemList_AddMethodText:Hide()
		NDFav_ItemList_DeleteItemsText:Hide()
		NDFav_ItemList_DeleteMethodText:Hide();

		local ls = table.getn(itemlist);
		if ls > 14 then
--			NuguDrop_Print("itemlist[k] = "..table.getn(itemlist).."개의 아이템이 현재 등록되어 있습니다.");
--			NuguDrop_Print("itemlist Size 30증가 요망");
			NDFavoritesFrame:SetHeight((ls-14)*35 + 516)
		else
			NDFavoritesFrame:SetHeight(516)
		end
--		for n = 1, table.getn(itemlist) do
--			NuguDrop_Print("itemlist["..n.."] = "..itemlist[n]);
--		end
		NDFav_ItemList_Generator(itemlist);
	end
	if getglobal(button.."Sum") and (table.getn(itemlist) > 0) then
		getglobal(button.."Sum"):SetText(table.getn(itemlist));
		getglobal(button.."Sum"):SetTextColor(0, 1, 0);
	else
		getglobal(button.."Sum"):SetText("");
	end
end

function ND_Fav_Category_Delete_OnClick(button)
	NDFav_cl = NDFavorites_Class[NuguDropOption.lastseen];
	local tmp = string.gsub(button, "NDFav_CategoryButton(%d+)_Delete", "%1");
	NDFav_ca = getglobal("NDFav_CategoryButton"..tmp.."Text"):GetText();
--	NuguDrop_Print("Delete-- NDFav_cl : "..NDFav_cl.." / NDFav_ca"..NDFav_ca);
end

function ND_Fav_Category_Modify_OnClick(button)
	NDFav_cl = NDFavorites_Class[NuguDropOption.lastseen];
	local tmp = string.gsub(button, "NDFav_CategoryButton(%d+)_Modify", "%1");
	NDFav_ca = getglobal("NDFav_CategoryButton"..tmp.."Text"):GetText();
--	NuguDrop_Print("Modify-- NDFav_cl : "..NDFav_cl.." / NDFav_ca"..NDFav_ca);
end

function NDFav_ItemList_Flush()
	if NDFavoritesFrame:IsVisible() and prevItemBtnCount then
		for i = 1, prevItemBtnCount do
			if (getglobal("NDFav_ItemButton"..i)) then
				getglobal("NDFav_ItemButton"..i):UnlockHighlight();
				getglobal("NDFav_ItemButton"..i):Hide();
			end
		end
	end
end

function NDFav_ItemList_Generator(itemlist)

--	local i = 1;
	for i = 1, table.getn(itemlist) do
		if (getglobal("NDFav_ItemButton"..i) == nil) then
			CreateFrame("button", "NDFav_ItemButton"..i, NDFav_Category_ItemList, "NDFav_ItemButton_Template");
		end
		if i == 1 then
			getglobal("NDFav_ItemButton"..i):SetPoint("TOPLEFT","NDFav_CategoryButton1","TOPRIGHT",29,0);
		else
			getglobal("NDFav_ItemButton"..i):SetPoint("TOPLEFT","NDFav_ItemButton"..(i-1),"BOTTOMLEFT", 0, -5);
		end

		local name, link, quality, itemlevel, minlevel, class, subclass, maxStack, equipType, texture = GetItemInfo(itemlist[i]);
		local color = ITEM_QUALITY_COLORS[quality];

		buttonName = "NDFav_ItemButton"..i;
		getglobal(buttonName):SetID(i);
		itemName = getglobal(buttonName.."Name");
		if name then
			itemName:SetText(name);
		else
--			NuguDrop_Print("NDFavorites[NDFav_cl][NDFav_ca][itemlist[i]]name : "..NDFavorites[NDFav_cl][NDFav_ca][itemlist[i]]["name"]);
			itemName:SetText(NDFavorites[NDFav_cl][NDFav_ca][itemlist[i]]["name"]);
		end

		if color then
			itemName:SetVertexColor(color.r, color.g, color.b);
		else
			itemName:SetVertexColor(1, 1, 1);
		end

--		itemID = getglobal(buttonName.."ID");
--		itemID:SetText(itemlist[i]);
--		NuguDrop_Print("itemlist["..i.."]"..itemlist[i]);
		if minlevel then
			if ( minlevel > UnitLevel("player") ) then
				getglobal(buttonName.."Level"):SetText((RED_FONT_COLOR_CODE.."%3d"..FONT_COLOR_CODE_CLOSE.."/%3d"):format(minlevel, itemlevel));
			else
				getglobal(buttonName.."Level"):SetText(("%3d/%3d"):format(minlevel, itemlevel));
			end
		else
			getglobal(buttonName.."Level"):SetText("");
		end

		if (not texture or texture == "") then
			texture = "Interface\\Icons\\INV_Misc_QuestionMark";
		end
		iconTexture = getglobal(buttonName.."ItemIconTexture");
		iconTexture:SetTexture(texture);

		getglobal("NDFav_ItemButton"..i):Enable();
		getglobal("NDFav_ItemButton"..i):Show();
--		i = i + 1;
	end
	prevItemBtnCount = table.getn(itemlist);


--	CreateFrame("ScrollFrame", "NDFav_Category_ItemListScrollFrame", NDFav_Category_ItemList, "FauxScrollFrameTemplate");
----	CreateFrame("ScrollFrame", "NDFav_Category_ItemListScrollFrame", NDFavoritesFrame, "FauxScrollFrameTemplate");
----	NDFav_Category_ItemListScrollFrame:SetPoint("TOPLEFT", "NDFavoritesFrame", "TOPLEFT", 5, -15);
--	NDFav_Category_ItemListScrollFrame:SetPoint("TOPLEFT", "NDFav_ItemButton1", "TOPLEFT", 0, 0);
--	NDFav_Category_ItemListScrollFrame:SetWidth(NDFav_ItemButton1:GetWidth() - 5);
----	NDFav_Category_ItemListScrollFrame:SetWidth(287);
--	NDFav_Category_ItemListScrollFrame:SetHeight((NDFav_ItemButton1:GetHeight() + 5) * NDFAV_ITEMS_SHOWN - 5);
----	NDFav_Category_ItemListScrollFrame:SetHeight(375);
----	NDFav_Category_ItemListScrollFrame:SetBackdropColor(1, 0, 0, 0.7);
--	NDFav_Category_ItemListScrollFrame:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(NDFAV_ITEM_BUTTON_HEIGHT, ND_Fav_ItemList_Update); end);

end


-- function FauxScrollFrame_OnVerticalScroll(itemHeight, updateFunction)
-- function FauxScrollFrame_Update(frame, numItems, numToDisplay, valueStep, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth )

--function ND_Fav_ItemList_Update()
--	NuguDrop_Print("|cff00ffff ▶▶▶ND_Fav_ItemList_Update |r");
--	local itemIndex;
--	local button;
--	FauxScrollFrame_Update(NDFav_Category_ItemListScrollFrame, table.getn(itemlist), 13, NDFAV_ITEM_BUTTON_HEIGHT);
--	for i = 1, 10 do
--		local itemIndex = i + FauxScrollFrame_GetOffset(NDFav_Category_ItemListScrollFrame);
--		button = getglobal("NDFav_ItemButton"..i);
--		if (itemIndex <= table.getn(itemlist)) then
--			NuguDrop_Print("▶▶▶");
--			button:Show();
--		else
--			button:Hide();
--		end
--	end
--end


--	NDFav_ItemButton_OnEnter(this:GetID() + FauxScrollFrame_GetOffset(NDFav_ItemList_BrowseScrollFrame));

function NDFav_ItemButton_OnEnter(id, button)
--	NuguDrop_Print("|cff00ffff itemID ▶ |r"..itemlist[id].." / "..button)
	local name, link = GetItemInfo(itemlist[id]);
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	if link then
		GameTooltip:SetHyperlink(link)
		if ( IsControlKeyDown() ) then
			ShowInspectCursor()
		else
			ResetCursor()
		end
	else
	-- 가상 툴팁 표시
		GameTooltip:AddLine(ND_UKNOWN_TITLE, 1, 0, 0);
		GameTooltip:AddLine(ND_UKNOWN_DESC, NuguDropColor.r, NuguDropColor.g, NuguDropColor.b);
		GameTooltip:AddLine(ND_UKNOWN_WARN);
		GameTooltip:Show();
	end
end

function NDFav_ItemButton_OnClick(id, button, extra)
	local name, link = GetItemInfo(itemlist[id]);
	local NDF_Itemname = NDFavorites[NDFav_cl][NDFav_ca][itemlist[id]]["name"]
	if link then
		if ( extra == "LeftButton" ) then
--			NDFav_moving_name = name;
--
--			local cursorX, cursorY = GetCursorPosition();
--			getglobal(button):SetFrameStrata("DIALOG");
--			getglobal(button):StartMoving();
--			getglobal(button):ClearAllPoints();
--			getglobal(button):SetPoint("TOP", nil, "BOTTOMLEFT", cursorX*GetScreenWidthScale(), cursorY*GetScreenHeightScale());
		else
			if ( IsControlKeyDown()  ) then
				DressUpItemLink(link);
			elseif ( IsShiftKeyDown() ) then
				ChatFrameEditBox:Show();
				ChatFrameEditBox:Insert(link);
			elseif (IsAltKeyDown()) then
				NDFav_Remove_ItemID = ND_getIdFromLink(link);
	--			NDFav_Remove_Class = NDFav_cl;
	--			NDFav_Remove_Category = NDFav_ca;
				StaticPopup_Show("NUGUDROP_CONFIRM_REMOVEITEM", link);
			else
				local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]");
				ChatFrame_OnHyperlinkShow(itemString, link);
			end
			NDFav_ItemList_Generator(itemlist);
			NDFav_ItemButton_OnEnter(id, button);
		end
	else
		NDFav_moving_name = nil;
	-- 서버 조회 시도
		local itemID = tonumber(itemlist[id]);
		if itemID then
			GameTooltip:SetHyperlink("item:"..itemID..":0:0:0:0:0:0:0");
			GameTooltip:Show();
			GameTooltip:Hide();

			local itemName, link, itemRarity = GetItemInfo(itemID);

			if link then
				button:SetText(link);
			end
			if not link then
				getglobal(button.."Name"):SetText("|cffff0000"..NDF_Itemname.."|r-|cffffff00서버조회|r");
			end
		end
	end
end

StaticPopupDialogs["NUGUDROP_CONFIRM_REMOVEITEM"] = {
	text = "즐겨찾기에서 \"%s\" 아이템을 삭제하시겠습니까?",
	button1 = YES,
	button2 = NO,
	OnAccept = (function()
--		NuguDrop_Print("NDFav_Remove_ItemID "..NDFav_Remove_ItemID)
		NDFavorites[NDFav_cl][NDFav_ca][NDFav_Remove_ItemID] = nil
		ND_Fav_Category_OnClick(prevButton)
	end),
	timeout = 0,
	exclusive = 0,
	whileDead = 1,
	showAlert = 1
};

function ND_Favorites_ShowMenu(itemname, itemID)
	UIDropDownMenu_Initialize(ND_DropDownMenu, ND_DropDownMenuOption_Initialize, "MENU");
	ToggleDropDownMenu(1, nil, ND_DropDownMenu, "cursor", 0, 0);
	Favitemname = itemname;
	FavitemID = itemID;
end

function ND_FavAdd()
	local cl = this.value.class;
	local ca = this.value.category;
	if FavitemID then
		local _, link = GetItemInfo(tonumber(FavitemID));
		if link then
			NuguDrop_Print("|cff00ff00 "..cl.." / "..ca.." / "..link.."|r 추가");
		else
			NuguDrop_Print("|cff00ff00 "..cl.." / "..ca.." / "..Favitemname.." ("..FavitemID..")|r 추가");
--		NuguDrop_Print("|cff00ff00 링크가 존재하지 않습니다.|r");
--		return false;
		end
		if not NDFavorites then
			NDFavorites = {};
		end
		if not NDFavorites[cl] then
			NDFavorites[cl] = {};
		end
		if not NDFavorites[cl][ca] then
			NDFavorites[cl][ca] = {};
		end
		if not NDFavorites[cl][ca][FavitemID] then
			NDFavorites[cl][ca][FavitemID] = {};
		end
		NDFavorites[cl][ca][FavitemID]["name"] = Favitemname;
		HideDropDownMenu(1);
		if prevButton then
			ND_Fav_Category_OnClick(prevButton);
		end
		if NDFavoritesFrame:IsVisible() then
			local cl2 = NDFavorites_Class[NuguDropOption.lastseen];
			if cl == cl2 then
	--			NuguDrop_Print("- 현재 보고 있는 분류임 (아이템 갯수 갱신)-")
				for n = 1, table.getn(NDFavorites[cl]) do
					if ca == NDFavorites[cl][n] then
						if getglobal("NDFav_CategoryButton"..n.."Sum") then
							local j = 0
							for k, v in pairs(NDFavorites[cl][ca]) do
								j = j + 1;
							end
							if j > 0 then
								getglobal("NDFav_CategoryButton"..n.."Sum"):SetText(j);
								getglobal("NDFav_CategoryButton"..n.."Sum"):SetTextColor(0, 1, 0);
							else
								getglobal("NDFav_CategoryButton"..n.."Sum"):SetText("");
							end
						end
					end
				end
			end
		end
	else
		NuguDrop_Print("|cff00ff00 아이템ID가 존재하지 않습니다.|r");
	end
end

function ND_DropDownMenuOption_Initialize(frame, level)
	level = tonumber(level) or 1;
	local info = UIDropDownMenu_CreateInfo();

	if (level == 1) then
		info.notCheckable = true;

		info.text = "|cffffff00즐겨찾기 추가|r";
		info.notClickable = true;
		UIDropDownMenu_AddButton(info, level);
		info.text = "";
		UIDropDownMenu_AddButton(info, level);
		info.notClickable = false;

		for idx, favlist in ipairs(ND_FavMenu_List) do
			class = next(favlist);

			info.text = class;
			info.hasArrow = class ~= "";
			info.disabled = class == "";
			info.func = nil;

			info.value = {
				["class"] = class,
				["category"] = ND_FavMenu_List[idx][class],
			};
			UIDropDownMenu_AddButton(info, level);
		end
	end

	if (level == 2) then
		local class_Key = UIDROPDOWNMENU_MENU_VALUE["class"];

		category = UIDROPDOWNMENU_MENU_VALUE["category"];
		info.func = ND_FavAdd;

		for i=1, table.getn(category) do
			local category_selected = category[i];
			info.text = category_selected;
			info.value = {
				["class"] = class_Key,
				["category"] = category_selected,
			};
			UIDropDownMenu_AddButton(info, level);
		end
	end
end

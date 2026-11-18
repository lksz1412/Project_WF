WotMCP = {
	version = 1,
	List = {}, -- numerically indexed list of addons in the scrollframe
	AddOnsEnabled = nil, -- OnShow becomes a table indexed by addons enabled
	AddOnsThatHaveDependencies = {}, -- indexed by addons with dependancies, tables of those dependants
	AddOnsThatAreDependants = {}, -- indexed by dependants
}

-- SavedVariablesPerCharacter
WotMCPSettings = {
	AddOnsExpanded = {}, -- indexed by addons that are expanded in the scrollframe
}

function WotMCP:OnLoad()
	self.name = "WotMCP"
	self.okay = WotMCP.ApplyChanges
	self.cancel = WotMCP.CancelButton
	InterfaceOptions_AddCategory(self)
	getglobal(self:GetName().."Version"):SetText("version "..WotMCP.version)
end 

function WotMCP:OnShow()
	if not WotMCP.AddOnsEnabled then
		-- AddOnsEnabled contains checkbox status for all addons, initially whether enabled
		WotMCP.AddOnsEnabled = {}
		for i=1,GetNumAddOns() do
			if select(7,GetAddOnInfo(i))=="INSECURE" and select(4,GetAddOnInfo(i)) then
				WotMCP.AddOnsEnabled[(GetAddOnInfo(i))] = 1
			end
		end
	end
	if not WotMCPList1 then
		WotMCP:BuildScrollFrame(self) -- generate scrollframe list and anchor scrollframe
		WotMCP:ExploreDependencies() -- populate dependancy tables
	end
	WotMCP:UpdateList()
end

function WotMCP:BuildScrollFrame(self)
	local button
	for i=1,16 do
		button = CreateFrame("Button","WotMCPList"..i,WotMCPScrollFrameBackdrop,"WotMCPListTemplate")
		button:SetPoint("TOPLEFT",i==1 and "WotMCPFrameDesc" or "WotMCPList"..(i-1),"BOTTOMLEFT")
	end
	WotMCPScrollFrame:SetPoint("TOPLEFT",WotMCPList1,"TOPLEFT",0,-2)
	WotMCPScrollFrame:SetPoint("BOTTOMRIGHT",WotMCPList16,"BOTTOMRIGHT",-2,1)
	WotMCPScrollFrameBackdrop:SetPoint("TOPLEFT",WotMCPList1,"TOPLEFT",-6,6)
	WotMCPScrollFrameBackdrop:SetPoint("BOTTOMRIGHT",WotMCPList16,"BOTTOMRIGHT",28,-6)
	if GetBuildInfo()~="2.4.3" then
		WotMCPList1:SetPoint("TOPLEFT",WotMCPFrameDesc,"BOTTOMLEFT",16,-8)
	end
end

--[[ Options frame buttons ]]

function WotMCP:Reload()
	WotMCP:ApplyChanges()
	ReloadUI()
end

function WotMCP:ApplyChanges()
	if WotMCP.AddOnsEnabled then
		local addon
		for i=1,GetNumAddOns() do
			if select(7,GetAddOnInfo(i))=="INSECURE" then
				addon = select(1,GetAddOnInfo(i))
				if WotMCP.AddOnsEnabled[addon] then
					EnableAddOn(addon)
				else
					DisableAddOn(addon)
				end
			end
		end
	end
end

function WotMCP:CancelButton()
	WotMCP.AddOnsEnabled = nil
end

--[[ Dependencies ]]

function WotMCP:PopulateDependencies(dependant,...)
	local addon
	local dependencies = WotMCP.AddOnsThatHaveDependencies
	for i=1,#(...) do
		addon = select(i,...)
		if addon then
			if not dependencies[addon] then
				dependencies[addon] = {}
			end
			table.insert(dependencies[addon],dependant)
			WotMCP.AddOnsThatAreDependants[dependant] = 1
		end
	end
end

function WotMCP:AreDependenciesEnabled(...)
	local addon
	for i=1,#(...) do
		addon = select(i,...)
		if addon then
			if not WotMCP.AddOnsEnabled[addon] then
				return nil
			end
		end
	end
	return 1
end

function WotMCP:HasDependencies(addon)
	if WotMCP.AddOnsThatHaveDependencies[addon] and #(WotMCP.AddOnsThatHaveDependencies[addon]) then
		return 1
	end
end

function WotMCP:IsADependant(addon)
	if WotMCP.AddOnsThatAreDependants[addon] then
		return 1
	end
end

function WotMCP:ExploreDependencies()
	local addon
	for i=1,GetNumAddOns() do
		addon = GetAddOnInfo(i)
		if GetAddOnDependencies(addon) then
			WotMCP:PopulateDependencies(addon,GetAddOnDependencies(addon))
		end
	end
end

--[[ ScrollFrame stuff ]]

function WotMCP:UpdateList()
	local list = WotMCP.List
	for i=1,#(list) do
		list[i] = nil
	end
	local addon
	for i=1,GetNumAddOns() do
		if select(7,GetAddOnInfo(i))=="INSECURE" then
			addon = GetAddOnInfo(i)
			if not WotMCP:IsADependant(addon) then
				table.insert(list,addon)
				if WotMCPSettings.AddOnsExpanded[addon] and WotMCP:HasDependencies(addon) then
					local dependencies = WotMCP.AddOnsThatHaveDependencies
					for i=1,#(dependencies[addon]) do
						table.insert(list,dependencies[addon][i])
					end
				end
			end
		end
	end
	WotMCP:ScrollFrameUpdate()
end

function WotMCP:ScrollFrameUpdate()
	local idx, addon, button
	local offset = FauxScrollFrame_GetOffset(WotMCPScrollFrame)
	local list = WotMCP.List
	FauxScrollFrame_Update(WotMCPScrollFrame,#(list),16,20)
	for i=1,16 do
		idx = offset + i
		if idx<=#(list) then
			addon = list[idx]
			getglobal("WotMCPList"..i.."CheckButton"):SetChecked(WotMCP.AddOnsEnabled[addon])
			getglobal("WotMCPList"..i.."Name"):SetText((select(2,GetAddOnInfo(addon))))
			getglobal("WotMCPList"..i.."Name"):SetWidth(280)
			button = getglobal("WotMCPList"..i.."Toggle")
			if WotMCP:HasDependencies(addon) then
				if WotMCPSettings.AddOnsExpanded[addon] then
					button:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
					button:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN")
				else
					button:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP")
					button:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN")
				end
				button:Show()
			else
				button:Hide()
				if WotMCP:IsADependant(addon) then
					getglobal("WotMCPList"..i.."Name"):SetWidth(268)
				end
			end
			local r,g,b = .95,.95,.95
			if not WotMCP.AddOnsEnabled[addon] or (WotMCP:IsADependant(addon) and not WotMCP:AreDependenciesEnabled(GetAddOnDependencies(addon))) then
				r,g,b = .65,.65,.65
			end
			getglobal("WotMCPList"..i.."Name"):SetTextColor(r,g,b,1)
			getglobal("WotMCPList"..i):Show()
		else
			getglobal("WotMCPList"..i):Hide()
		end
	end
end

function WotMCP:GetAddOnNameFromControl(frame)
	return WotMCP.List[FauxScrollFrame_GetOffset(WotMCPScrollFrame)+tonumber(string.match(frame:GetName(),"WotMCPList(%d+)"))]
end

function WotMCP:ToggleOnClick()
	local addon = WotMCP:GetAddOnNameFromControl(self)
	local expanded = WotMCPSettings.AddOnsExpanded
	if expanded[addon] then
		expanded[addon] = nil
	else
		expanded[addon] = 1
	end
	PlaySound(expanded[addon] and "igMainMenuOptionCheckBoxOff" or "igMainMenuOptionCheckBoxOn")
	WotMCP:UpdateList()
end

function WotMCP:CheckButtonOnClick()
	local addon = WotMCP:GetAddOnNameFromControl(self)
	local isChecked = self:GetChecked()
	PlaySound(isChecked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
	WotMCP.AddOnsEnabled[addon] = isChecked
	WotMCP:ScrollFrameUpdate()
end

function WotMCP:DependenciesTooltipLine(...)
	if select(1,...) then
		local dependencyName,dependencyTitle
		local txt = "|cFFEEEEEEDependencies: "
		for i=1,#(...) do
			dependencyName = select(i,...)
			if dependencyName then
				dependencyTitle = select(2,GetAddOnInfo(dependencyName))
				if not dependencyTitle then
					txt=txt.."|cFFFF0000"..dependencyName.."(Not Installed)|cFFEEEEEE, "
				elseif not WotMCP.AddOnsEnabled[dependencyName] then
					txt=txt.."|cFFFF0000"..dependencyTitle.."|cFFEEEEEE, "
				else
					txt=txt..dependencyTitle..", "
				end
			end
		end
		txt = string.gsub(txt,", $","")
		return txt
	else
		return nil
	end
end

function WotMCP:CheckButtonOnEnter()
	local addon = WotMCP:GetAddOnNameFromControl(self)
	local _,title,notes = GetAddOnInfo(addon)
	GameTooltip:SetOwner(self,"ANCHOR_LEFT")
	GameTooltip:AddLine(title)
	GameTooltip:AddLine(notes,.9375,.9375,.9375,1)
	GameTooltip:AddLine(WotMCP:DependenciesTooltipLine(GetAddOnDependencies(addon)))
	GameTooltip:Show()
end
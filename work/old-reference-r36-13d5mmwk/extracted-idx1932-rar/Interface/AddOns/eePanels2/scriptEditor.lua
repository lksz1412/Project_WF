local L				= AceLibrary("AceLocale-2.2"):new("eePanels2")
local dewdrop		= AceLibrary:HasInstance("Dewdrop-2.0") and AceLibrary("Dewdrop-2.0")

local editor		= nil
local panel			= nil
local scriptIndex	= nil


--[[
-- Saves a panel's script
--]]
function eePanels2:SavePanelScript()
	-- Replace 'THIS' with the actual panel name
	local scriptName = string.gsub(editor.editName:GetText(), "THIS", panel.frame:GetName())
	local scriptCode = string.gsub(editor.editCode:GetText(), "THIS", panel.frame:GetName())

	if panel ~= nil then
		-- Insert script
		if scriptIndex == nil then
			table.insert( panel.scripts, {name=scriptName, code=scriptCode} )
		-- Update script
		else
			panel.scripts[scriptIndex] = {name=scriptName, code=scriptCode}
		end
		
		-- Run script, update menu
		eePanels2:ChangeScript(panel)
		eePanels2:CreateMenus()
	end
end


--[[
-- Display the sript editor panel for a specific panel's script
-- Ghetto singleton so that only one editor is ever made/displayed
--]]
function eePanels2:DisplayScriptEditor(p,i)
	if editor == nil then
		editor = eePanels2:CreateScriptEditor()
	end
	-- Store script info in local vars
	panel = p
	scriptIndex = i
	
	local title
	-- Get script info from database
	if i ~= nil then
		editor.editName:SetText(panel.scripts[scriptIndex].name)
		editor.editCode:SetText(panel.scripts[scriptIndex].code)
		title = L["ExistingScript"]..scriptIndex
	-- New script settings
	else
		editor.editName:SetText("ScriptName")
		editor.editCode:SetText("-- Put your script here")
		title = L["NewScript"]
	end
	editor.text:SetText(panel.frame:GetName()..title)
	
	-- Show script editor
	if dewdrop then dewdrop:Close() end
	editor:Show()
end


--[[
-- Create a panel that allows the user to enter script code
--]]
function eePanels2:CreateScriptEditor()
	local backdrop = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 8,
		tile = false,
		tileSize = 0,
		insets = {left = 3, right = 3, top = 3, bottom = 3},
	}

	-- Create main frame
	local ed = CreateFrame("Frame", "eePanelScriptEditor")
	ed:EnableMouse(true)
	ed:SetResizable(true)
	ed:SetMovable(true)
	ed:SetClampedToScreen(true)
	ed:SetWidth(300)
	ed:SetHeight(40)
	ed:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
	ed:SetBackdropColor(.1,.1,.1,.1)
	ed:SetBackdrop(backdrop)
	ed:RegisterForDrag("LeftButton")
	ed:SetScript("OnDragStart", function() ed:StartMoving() end)
	ed:SetScript("OnDragStop", function() ed:StopMovingOrSizing() end)
	
	-- Create text to show the panel and script we're adding/editing
	ed.text = ed:CreateFontString(nil, "ART")
	ed.text:SetFontObject(GameFontNormal)
	ed.text:SetPoint("CENTER", ed, "CENTER", 0, 0)
	
	-- Create middle panel
	ed.middle = CreateFrame("Frame", "eePanelScriptEditorMiddle", ed)
	ed.middle:SetPoint("TOP", ed, "BOTTOM")
	ed.middle:SetWidth(300)
	ed.middle:SetHeight(370)
	ed.middle:SetBackdropColor(.1,.1,.1,.1)
	ed.middle:SetBackdrop(backdrop)
	
	-- Create edit box for script name
	ed.editName = CreateFrame("EditBox", "eePanelScriptEditorNameEditBox", ed.middle)
	ed.editName:SetMultiLine(false)
	ed.editName:SetPoint("TOP", ed.middle, "TOP")
	ed.editName:SetTextInsets(5,5,15,5)
	ed.editName:SetWidth(300)
	ed.editName:SetHeight(50)
	ed.editName:SetFontObject(GameFontHighlightSmall)
	ed.editName:SetScript("OnEscapePressed", function() ed.editName:ClearFocus() ed:Hide() end)
	
	-- Display text above script name/script code areas
	ed.nameText = ed.middle:CreateFontString(nil, "ART")
	ed.nameText:SetFontObject(GameFontNormal)
	ed.nameText:SetPoint("TOPLEFT", ed.middle, "TOPLEFT", 5, -5)
	ed.nameText:SetText( L["NameScript"] )
	ed.codeText = ed.middle:CreateFontString(nil, "ART")
	ed.codeText:SetFontObject(GameFontNormal)
	ed.codeText:SetPoint("TOPLEFT", ed.middle, "TOPLEFT", 5, -40)
	ed.codeText:SetText( L["CodeScript"] )
	
	-- Create scroll frame
	ed.scroller = CreateFrame("ScrollFrame", "eePanelScriptEditorScrollFrame", ed.middle, "UIPanelScrollFrameTemplate" )
	ed.scroller:SetPoint("TOP", ed.editName, "BOTTOM",0,-10)
	ed.scroller:SetWidth(300)
	ed.scroller:SetHeight(310)
	
	-- Create edit box for script code
	ed.editCode = CreateFrame("EditBox", "eePanelScriptEditorCodeEditBox", ed.scroller)
	ed.editCode:SetMultiLine(true)
	ed.editCode:SetPoint("TOP", ed.scroller, "TOP")
	ed.editCode:SetPoint("BOTTOM", ed.scroller, "BOTTOM")
	ed.editCode:SetTextInsets(5,5,0,0)
	ed.editCode:SetWidth(300)
	ed.editCode:SetHeight(310)
	ed.editCode:SetFontObject(GameFontHighlightSmall)
	ed.editCode:SetScript("OnTextChanged", function() ed.scroller:UpdateScrollChildRect() end)
	ed.editCode:SetScript("OnEscapePressed", function() ed.editCode:ClearFocus() ed:Hide() end)
	-- Attach edit box to the scroll frame
	ed.scroller:SetScrollChild(ed.editCode)

	-- Create button panel
	ed.buttonPanel = CreateFrame("Frame", "eePanelScriptEditorButtonPanel", ed)
	ed.buttonPanel:SetWidth(300)
	ed.buttonPanel:SetHeight(40)
	ed.buttonPanel:SetPoint("TOP", ed.scroller, "BOTTOM",0,0)
	ed.buttonPanel:SetBackdropColor(.1,.1,.1,.1)
	ed.buttonPanel:SetBackdrop(backdrop)
	
	-- Create ok button
	ed.okButton = CreateFrame("Button", "eePanelScriptEditorOKButton", ed)
	ed.okButton:SetWidth(100)
	ed.okButton:SetHeight(20)
	ed.okButton:SetPoint("LEFT",ed.buttonPanel,"LEFT",22,0)
	ed.okButton:SetText("OK")
	ed.okButton:SetBackdrop(backdrop)
	ed.okButton:SetTextFontObject(GameFontHighlightSmall)
	ed.okButton:SetScript("OnClick", function() eePanels2:SavePanelScript() ed.editCode:ClearFocus() ed:Hide() end)
	
	-- Create cancel button
	ed.cancelButton = CreateFrame("Button", "eePanelScriptEditorCancelButton", ed)
	ed.cancelButton:SetWidth(100)
	ed.cancelButton:SetHeight(20)
	ed.cancelButton:SetPoint("RIGHT",ed.buttonPanel,"RIGHT",-22,0)
	ed.cancelButton:SetText("Cancel")
	ed.cancelButton:SetBackdrop(backdrop)
	ed.cancelButton:SetTextFontObject(GameFontHighlightSmall)
	ed.cancelButton:SetScript("OnClick", function() ed.editCode:ClearFocus() ed:Hide() end)
	
	-- Return the frame
	return ed
end

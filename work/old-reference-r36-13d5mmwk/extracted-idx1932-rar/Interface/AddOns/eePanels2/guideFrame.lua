local L  		= AceLibrary("AceLocale-2.2"):new("eePanels2")
local dewdrop	= AceLibrary:HasInstance("Dewdrop-2.0") and AceLibrary("Dewdrop-2.0")


--[[
-- Displays a guideFrame to move a panel by mouse
--]]
function eePanels2:CreateGuideFrame(panel,i) 
	-- If the guideFrame exists, just show it
	if panel.guideFrame then
		panel.guideFrame.text:SetText( L["eePanel"]..i..": "..panel.name )
		panel.guideFrame:Show()
		
	-- Otherwise, create a new guideFrame
	else
		panel.guideFrame = CreateFrame("Frame", "eePanelGuideFrame"..i, panel.frame)
		panel.guideFrame:EnableMouse(true)
		panel.guideFrame:SetResizable(true)
		panel.guideFrame:SetMovable(true)
		panel.guideFrame:SetMinResize(22,22)
		panel.guideFrame:SetFrameStrata("HIGH")
		panel.guideFrame:SetAllPoints(panel.frame)
		panel.guideFrame:SetBackdropColor(1,1,1,0)
		panel.guideFrame.isResizing = false;
		panel.guideFrame.isMoving = false
		panel.guideFrame.index = i
		
		-- Match guide frame's anchor to it's panel's anchor
		--panel.guideFrame:SetPoint(panel.anchorFrom, panel.anchor, panel.anchorTo, panel.x, panel.y)
		
		-- Create a texture to display a special highlight color when we mouse-over this frame
		panel.guideFrame.texture = panel.guideFrame:CreateTexture(nil, "HIGHLIGHT")
		panel.guideFrame.texture:SetAllPoints(panel.guideFrame)
		panel.guideFrame.texture:SetTexture(eePanels2:GetHightlightColor(panel))
		panel.guideFrame.texture:SetAlpha(.3)

		-- Display the frame number on top of our texture when we mouseOver
		panel.guideFrame.text = panel.guideFrame:CreateFontString(nil, "HIGHLIGHT")
		panel.guideFrame.text:SetFontObject(GameFontHighlightSmall)
		panel.guideFrame.text:SetPoint("CENTER", panel.guideFrame, "CENTER", 0, 0)
		panel.guideFrame.text:SetText( L["eePanel"]..i..": "..panel.name )

		-- Resize mouse-drag image
		resizeTexture = panel.guideFrame:CreateTexture(nil, "HIGHLIGHT")
		resizeTexture:SetHeight(16)
		resizeTexture:SetWidth(16)
		resizeTexture:SetTexture("Interface\\Addons\\eePanels2\\resize.tga")
		resizeTexture:SetPoint("BOTTOMRIGHT",-2,2)
		
		-- Set scripts to let us move while dragging
		panel.guideFrame:SetScript("OnMouseDown",function() eePanels2:MouseDownListener(this) end)
		panel.guideFrame:SetScript("OnMouseUp",function() eePanels2:MouseUpListener(this) end)
		
		-- Store a backreference to the panel so we can access the saved varaibles of the panel every guide frame is attached to
		panel.guideFrame.backRef = panel
	end
end



--[[
-- Listen for mouse-clicks on the guide frame
--]]
function eePanels2:MouseDownListener(self)
	-- On right-clicks, display a dewdrop menu for the frame
	if arg1 == "RightButton" and dewdrop then
		eePanels2:ShowPanelMenu(self, self.index)
		
	-- On left-clicks, listen for mouse-dragging
	elseif arg1 == "LeftButton" then
		
		-- Set vars to figure out if the mouse is in the resize area or not
		local screenX, screenY = GetCursorPosition()
		local panelX = self:GetRight()
		local panelY = self:GetBottom()

		-- Adjust for screen scale
		local scale = self:GetEffectiveScale()
		panelX = panelX * scale
		panelY = panelY * scale
		
		-- Set bounds for lower-right hand corner
		local check1 = screenX <= panelX + 14
		local check2 = screenX >= panelX - 14
		local check3 = screenY <= panelY + 14
		local check4 = screenY >= panelY - 14
		
		-- Start resizing
		if check1 and check2 and check3 and check4 then
			-- Set a variable so we know when we're resizing
			self.isResizing = true
			-- Attach an OnUpdate call which fires every repaint while we're resizing
			self:SetScript("OnUpdate", function() eePanels2:ResizeListener(self) end)
			-- System call
			self:StartSizing("BOTTOMRIGHT")
			
		-- Start moving
		else
			-- Set a variable so we know when we're moving
			self.isMoving = true
			-- Attach an OnUpdate call which fires every repaint while we're moving
			self:SetScript("OnUpdate", function() eePanels2:MoveListener(self) end)
			-- System call
			self:StartMoving()
		end
	end
	
end



--[[
-- Gets the mouse-over highlight color to use based on the panel's parent
--]]
function eePanels2:GetHightlightColor(panel)
	-- Blue-green hover color
	if panel.parent == "UIParent" then
		return 0,1,1
	-- Yellow highlight otherwise (to signify we're not allowing mouse-move)
	else
		return 1,1,0
	end
end



--[[
-- Listens for mouse-click release over the guide frame
--]]
function eePanels2:MouseUpListener(self)
	-- Stop moving or resizing
	self:StopMovingOrSizing()
	-- Remove the move/resize listeners
	self:SetScript("OnUpdate", nil)
	
	-- Finish resize
	if self.isResizing then
		self.isResizing = false
		-- Change panel's width/height in database to the guideFrame's size
		for i in pairs(eePanels2.db.profile.panels) do
			if eePanels2.db.profile.panels[i].guideFrame == self then
				-- Update panel's dimensions
				eePanels2.db.profile.panels[i].width = self:GetWidth()
				eePanels2.db.profile.panels[i].height = self:GetHeight()
				-- Update panel's location (important because anchor-type affects resize direction)
				local x,y = eePanels2:TranslateCoords(self)
				eePanels2.db.profile.panels[i].x = x
				eePanels2.db.profile.panels[i].y = y
			end
		end

	-- Finish move
	elseif self.isMoving then
		self.isMoving = false
		-- Change panel's x,y coords in database to the guideFrame's coords
		for i in pairs(eePanels2.db.profile.panels) do
			if eePanels2.db.profile.panels[i].guideFrame == self then
				-- Update panel's location
				local x,y = eePanels2:TranslateCoords(self)
				eePanels2.db.profile.panels[i].x = x
				eePanels2.db.profile.panels[i].y = y
			end
		end
	end
	
end



--[[
-- Listens for guide frame movement
--]]
function eePanels2:MoveListener(self)
	-- Update the panel to match the guide frame's location (but don't save to database until we're finished)
	local x,y = eePanels2:TranslateCoords(self)
	self.backRef.frame:ClearAllPoints()
	self.backRef.frame:SetPoint(self.backRef.anchorFrom, self.backRef.anchor, self.backRef.anchorTo, x, y)
end



--[[
-- Listen for guide frame resize
--]]
function eePanels2:ResizeListener(self)
	-- Update the panel to match the guide frame's size (but don't save to database until we're finished)
	self.backRef.frame:SetWidth(self:GetWidth())
	self.backRef.frame:SetHeight(self:GetHeight())
	-- Update panel's location (important because anchor-type affects resize direction)
	local x,y = eePanels2:TranslateCoords(self)
	self.backRef.frame:ClearAllPoints()
	self.backRef.frame:SetPoint(self.backRef.anchorFrom, self.backRef.anchor, self.backRef.anchorTo, x, y)
end



--[[
-- Translate the current coordinates of the guide frame to coordinates relative to its panel based on the panels anchoring
--]]
function eePanels2:TranslateCoords(self)
	local anchorFrom,anchor,anchorTo,_,_ = self.backRef.frame:GetPoint()
	local x1,x2,x3,x4 = 0,0,0,0
	
	-- Could trim this down more in a separate function, but inlining it is probably faster then two extra function calls
	if anchorFrom == "TOP" 				then y1 = self:GetTop() x1 = self:GetLeft()+(self:GetWidth()/2) 
	elseif anchorFrom == "BOTTOM" 		then y1 = self:GetBottom() x1 = self:GetLeft()+(self:GetWidth()/2) 
	elseif anchorFrom == "LEFT"			then y1 = self:GetBottom()+(self:GetHeight()/2) x1 = self:GetLeft() 
	elseif anchorFrom == "RIGHT"		then y1 = self:GetBottom()+(self:GetHeight()/2) x1 = self:GetRight() 
	elseif anchorFrom == "TOPLEFT"		then y1 = self:GetTop() x1 = self:GetLeft() 
	elseif anchorFrom == "BOTTOMLEFT"	then y1 = self:GetBottom() x1 = self:GetLeft() 
	elseif anchorFrom == "TOPRIGHT"		then y1 = self:GetTop() x1 = self:GetRight() 
	elseif anchorFrom == "BOTTOMRIGHT"	then y1 = self:GetBottom() x1 = self:GetBottom() 
	elseif anchorFrom == "CENTER"		then y1 = self:GetBottom()+(self:GetHeight()/2) x1 = self:GetLeft()+(self:GetWidth()/2) end

	if anchorTo == "TOP" 				then y2 = anchor:GetTop() x2 = anchor:GetLeft()+(anchor:GetWidth()/2) 
	elseif anchorTo == "BOTTOM"			then y2 = anchor:GetBottom() x2 = anchor:GetLeft()+(anchor:GetWidth()/2) 
	elseif anchorTo == "LEFT"			then y2 = anchor:GetBottom()+(anchor:GetHeight()/2) x2 = anchor:GetLeft() 
	elseif anchorTo == "RIGHT"			then y2 = anchor:GetBottom()+(anchor:GetHeight()/2) x2 = anchor:GetRight() 
	elseif anchorTo == "TOPLEFT"		then y2 = anchor:GetTop() x2 = anchor:GetLeft() 
	elseif anchorTo == "BOTTOMLEFT"		then y2 = anchor:GetBottom() x2 = anchor:GetLeft() 
	elseif anchorTo == "TOPRIGHT"		then y2 = anchor:GetTop() x2 = anchor:GetRight() 
	elseif anchorTo == "BOTTOMRIGHT"	then y2 = anchor:GetBottom() x2 = anchor:GetBottom() 
	elseif anchorTo == "CENTER"			then y2 = anchor:GetBottom()+(anchor:GetHeight()/2) x2 = anchor:GetLeft()+(anchor:GetWidth()/2) end
	
	return x1-x2, y1-y2
end

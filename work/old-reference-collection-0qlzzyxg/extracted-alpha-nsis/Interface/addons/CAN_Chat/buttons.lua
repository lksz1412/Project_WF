local hideButton = function(button)
	button:SetScript("OnShow", button.Hide)
	button:Hide()
end

local updateBottomButton = function(frame)
	local button = frame.buttonFrame.bottomButton

	if frame:AtBottom() then
		button:Hide()
	else
		button:Show()
	end
end

local bottomButtonClick = function(button)
	PlaySound("igChatBottom")

	local frame = button:GetParent()
	frame:ScrollToBottom()

	updateBottomButton(frame)
end

hideButton(ChatFrameMenuButton)

hideButton(FriendsMicroButton)

--hideNavigationButtons
for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame" .. i]
	frame:SetClampedToScreen(false)	-- 채팅창 화면에 붙이기
	frame:SetFading(false);			-- 채팅창 fade block
	frame:HookScript("OnShow", updateBottomButton)

	local fbf = frame.buttonFrame
	fbf:DisableDrawLayer('BACKGROUND')
	fbf:DisableDrawLayer('BORDER')
	local bottom = fbf.bottomButton
	bottom:SetParent(frame)
	bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	bottom:SetScript("OnClick", bottomButtonClick)
	bottom:SetAlpha(0.6)
	hideButton(fbf.upButton)
	hideButton(fbf.downButton)
	hideButton(fbf.minimizeButton)
	updateBottomButton(frame)
end

--Imroved scrolling
hooksecurefunc('FloatingChatFrame_OnMouseScroll', function(self, dir)
	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollUp()
			self:ScrollUp()
		end
	elseif dir < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollDown()
			self:ScrollDown()
		end
	end
	updateBottomButton(self)
end)
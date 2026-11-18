local runePowerStatusBar;
local runePowerStatusBarDark;
local runePowerStatusBarText;
local checked;

--Readability == win
local RUNETYPEC_BLOOD = 1;
local RUNETYPEC_UNHOLY = 2;
local RUNETYPEC_FROST = 3;
local RUNETYPEC_DEATH = 4;

local runeY = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0
}

local runeX = {
	[1] = 10,
	[2] = 50,
	[3] = 170,
	[4] = 210,
	[5] = 90,
	[6] = 130,
}

local runeDir = {
	[1] = 50,
	[2] = 50,
	[3] = 50,
	[4] = 50,
	[5] = 50,
	[6] = 50
}

RunePack_Saved = {
	anchor = "CENTER",
	parent = "UIParent",
	rel = "BOTTOM",
	x = 0;
	y = 326;
	scale = 4.6;
	Locked = true;
	HideRp = false;
	BgOpacity = 0;
	OocOpacity = 15;
};


function RuneButtonC_OnLoad (self)
	RuneFrameC_AddRune(RuneFrameC, self);
	
	self.rune = getglobal(self:GetName().."Rune");
	self.border = getglobal(self:GetName().."Border");
	self.bg = getglobal(self:GetName().."BG");

	RuneButtonC_Update(self);
	
  RuneFrame:Hide(); --hide default runeframe
  
	self:SetScript("OnUpdate", RuneButtonC_OnUpdate);

	self:SetFrameLevel( self:GetFrameLevel() + 2*self:GetID() );
	self.border:SetFrameLevel( self:GetFrameLevel() + 1 );
end


function RuneButtonC_OnUpdate (self, elapsed)

	local start, duration, r = GetRuneCooldown(self:GetID());

	if (r) then
	  self:SetAlpha(1);
		self:SetPoint("TOPLEFT", "RuneFrameC", "TOPLEFT", runeX[self:GetID()], runeY[self:GetID()] );
	else
		local remain = (duration - GetTime() + start) / duration;
		if ( remain < 0) then
		  self:SetAlpha(1); 
			self:SetPoint("TOPLEFT", "RuneFrameC", "TOPLEFT", runeX[self:GetID()], runeY[self:GetID()] );
		else
		  self:SetAlpha(.5);
			self:SetPoint("TOPLEFT", "RuneFrameC", "TOPLEFT", runeX[self:GetID()], runeY[self:GetID()] + remain*(runeDir[self:GetID()]) );
		end
	end
end


function RuneButtonC_Update (self, rune)

local runeType = GetRuneType(self:GetID());

	if (runeType == RUNETYPEC_BLOOD) then
		self.rune:SetTexture("Interface\\AddOns\\RunePack\\textures\\blood.tga");
		self.rune:SetWidth(50);
		self.rune:SetHeight(50);

	elseif (runeType == RUNETYPEC_UNHOLY) then
		self.rune:SetTexture("Interface\\AddOns\\RunePack\\textures\\unholy.tga");
		self.rune:SetWidth(50);
		self.rune:SetHeight(50);

	elseif (runeType == RUNETYPEC_FROST) then
		self.rune:SetTexture("Interface\\AddOns\\RunePack\\textures\\frost.tga");
		self.rune:SetWidth(50);
		self.rune:SetHeight(50);

	elseif (runeType == RUNETYPEC_DEATH) then
		self.rune:SetTexture("Interface\\AddOns\\RunePack\\textures\\death.tga");
		self.rune:SetWidth(50);
		self.rune:SetHeight(50);

	end
	
	
end


function RuneFrameC_OnLoad (self)

	-- Disable rune frame if not a death knight.
	local _, class = UnitClass("player");
	
	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide();
	end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("RUNE_TYPE_UPDATE");
	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("RUNE_REGEN_UPDATE");

	self:RegisterEvent("VARIABLES_LOADED");
--	DEFAULT_CHAT_FRAME:AddMessage("RunePack activated! All options are now in the Interface Addons menu.");

	self:SetScript("OnEvent", RuneFrameC_OnEvent);
	self:SetScript("OnUpdate", RuneFrameC_OnUpdate);
	
	self.runes = {};

  runePowerStatusBar = CreateFrame("Frame", "RpText", RuneFrameC); --just an anchor for the text at this point

	runePowerStatusBarText = runePowerStatusBar:CreateFontString(nil, 'OVERLAY');
	runePowerStatusBarText:ClearAllPoints();
	runePowerStatusBarText:SetFont("Fonts\\K_Damage.TTF", 16, "THICKOUTLINE"); --you can change the first argument to a custom font
	runePowerStatusBarText:SetTextColor(1,1,0); --yellow
	runePowerStatusBarText:SetJustifyH("CENTER");
	runePowerStatusBarText:SetWidth(90);
	runePowerStatusBarText:SetHeight(40);
	runePowerStatusBarText:SetPoint("LEFT", RuneFrameC, "LEFT", -64, 10 );
	
	RuneFrameC:SetPoint(RunePack_Saved.anchor,RunePack_Saved.parent,RunePack_Saved.rel,RunePack_Saved.x,RunePack_Saved.y);
	
end
	

function RuneFrameC_OnUpdate(self)

	local power = UnitMana("player");

--	if ( power > 89) then
--    runePowerStatusBarText:SetText( power );
--	  runePowerStatusBarText:SetTextColor(1,0,0); --red
	  --elseif ( power > 59) then --uncomment for color change at feedback requested levels
	  --runePowerStatusBarText:SetText( power );
    --runePowerStatusBarText:SetTextColor(0,1,1); --cyan
	if ( power > 39) then
    runePowerStatusBarText:SetText( power );
    runePowerStatusBarText:SetTextColor(0,1,0); --green
    --elseif ( power > 19) then --uncomment for color change at feedback requested levels
    --runePowerStatusBarText:SetText( power );
    --runePowerStatusBarText:SetTextColor(1,.55,0); --orange
  elseif ( power > 0) then
    runePowerStatusBarText:SetText( power );
    runePowerStatusBarText:SetTextColor(1,1,0); --yellow
	else
      runePowerStatusBarText:SetText( nil );
	end
  
	RuneFrameC_AlphaOoc_update(self)
	
end


function RuneFrameC_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		for rune in next, self.runes do
			RuneButtonC_Update(self.runes[rune], rune);
		end

	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		for rune in next, self.runes do
			RuneButtonC_Update(self.runes[rune], rune);
		end

	elseif ( event == "VARIABLES_LOADED" ) then
	  RunePackOptionsPanel_CancelOrLoad()
	end
end


function RuneFrameC_AddRune (runeFrameC, rune)
	tinsert(runeFrameC.runes, rune);
end


function RuneFrameC_OnDragStart()
	RuneFrameC:StartMoving();
end


function RuneFrameC_OnDragStop()
	RunePack_Saved.anchor = "CENTER";
	RunePack_Saved.parent = "UIParent";
	RunePack_Saved.rel = "BOTTOMLEFT";
	RunePack_Saved.x,RunePack_Saved.y = RuneFrameC:GetCenter();
	RuneFrameC:StopMovingOrSizing();
end

--
-- GUI Functions
--

-- This function is run on pressing the Ok or Close Buttons.
--   Sets the Status of the Saved Variables to the new settings
--
function RunePackOptionsPanel_Close()
	RunePack_Saved.scale = RunePackOptions_Scale:GetValue();
	RunePack_Saved.BgOpacity = RunePackOptions_Alpha:GetValue();
	RunePack_Saved.OocOpacity = RunePackOptions_AlphaOoc:GetValue();
	
	if ( RunePackOptions_Locked:GetChecked()==1 )then
	  RunePack_Saved.Locked = true;
	else
	  RunePack_Saved.Locked =  false;
	end
	
	if ( RunePackOptions_HideRp:GetChecked()==1 ) then
	  RunePack_Saved.HideRp = true;
	else
	  RunePack_Saved.HideRp = false;
	end
end


-- This function is run on pressing the Cancel Button or from the VARIABLES LOADED event function.
--   Sets the status of the Check Boxes to the Values of the Saved Variables.
--
function RunePackOptionsPanel_CancelOrLoad()
  --GUI
	RunePackOptions_Locked:SetChecked(RunePack_Saved.Locked);
	RunePackOptions_HideRp:SetChecked(RunePack_Saved.HideRp);
	RunePackOptions_Scale:SetValue(RunePack_Saved.scale);
	RunePackOptions_Alpha:SetValue(RunePack_Saved.BgOpacity);
	RunePackOptions_AlphaOoc:SetValue(RunePack_Saved.OocOpacity);
	
	--Addon Frames
	RuneFrameC:ClearAllPoints();
	RuneFrameC:SetPoint(RunePack_Saved.anchor,RunePack_Saved.parent,RunePack_Saved.rel,RunePack_Saved.x,RunePack_Saved.y);
	RuneFrameC:SetScale(RunePack_Saved.scale/5);
	RuneFrameC_Locked_OnClick(RunePack_Saved.Locked);
	RuneFrameC_HideRp_OnClick(RunePack_Saved.HideRp);
  RuneFrameBack:SetAlpha(RunePack_Saved.BgOpacity/100);
	alphaOocParam = RunePack_Saved.OocOpacity/100;
	
end


-- The GUI OnLoad function.
--
function RunePackOptionsPanel_OnLoad(panel)
	-- Set the Text for the Check boxes.
	--
	RunePackOptions_LockedText:SetText("Locked");
	RunePackOptions_HideRpText:SetText("Hide Runic Power");
	-- Set the values from the saved file
	-- now done from VARIABLES_LOADED
  -- RunePackOptionsPanel_CancelOrLoad()
    
	-- Set the name for the Category for the Panel
	--
	panel.name = "RunePack";

	-- When the player clicks okay, set the Saved Variables to the current Check Box setting
	--
	panel.okay = function (self) RunePackOptionsPanel_Close(); end;

	-- When the player clicks cancel, set the Check Box status to the Saved Variables.
	panel.cancel = function (self)  RunePackOptionsPanel_CancelOrLoad();  end;

	-- Add the panel to the Interface Options
	--
	InterfaceOptions_AddCategory(panel);
end

function RuneFrameC_Locked_OnClick(self)
  if ( self==true or self==false ) then
    --from saved
    checked = self;
  else
    --from ui
    if ( self:GetChecked()==1 ) then
      checked = true;
    else
      checked = false;
    end
  end
    
  if ( checked ) then
    RuneFrameC_Drag:Hide();
		RuneFrameC_Drag:SetMovable(false);
		RuneFrameC_Drag:RegisterForDrag(nil);
		RuneFrameC_Drag:SetScript('OnDragStart', nil );
		RuneFrameC:SetClampedToScreen(true);
--		DEFAULT_CHAT_FRAME:AddMessage("RunePack locked.");
  else
    RuneFrameC_Drag:Show();
		RuneFrameC_Drag:SetMovable(true);
		RuneFrameC_Drag:RegisterForDrag('LeftButton');
		RuneFrameC_Drag:SetScript('OnDragStart', RuneFrameC_OnDragStart );
		RuneFrameC_Drag:SetScript('OnDragStop', RuneFrameC_OnDragStop );
		RuneFrameC:SetClampedToScreen(true);
		DEFAULT_CHAT_FRAME:AddMessage("RunePack unlocked.");
  end
  
end

function RuneFrameC_HideRp_OnClick(self)
  if ( self==true or self==false ) then
    --from saved
    checked = self;
  else
    --from ui
    if ( self:GetChecked()==1 ) then
      checked = true;
    else
      checked = false;
    end
  end
--[[  
  if ( checked ) then
    RpText:Hide();
    DEFAULT_CHAT_FRAME:AddMessage("Runic power hidden.");
  else
    RpText:Show();
    DEFAULT_CHAT_FRAME:AddMessage("Runic power shown.");
  end
]]--  
end

function RuneFrameC_Scale_OnValueChanged(self)

  local scaleParam = self:GetValue()/5;
	RuneFrameC:SetScale(scaleParam);

end

function RuneFrameBack_Alpha_OnValueChanged(self)
  local alphaParam = self:GetValue()/100;
  RuneFrameBack:SetAlpha(alphaParam);
end

function RuneFrameC_AlphaOoc_value(self)
  alphaOocParam = self:GetValue()/100;
end

function RuneFrameC_AlphaOoc_update(frame)
  local inCombat = UnitAffectingCombat("player");
  if ( inCombat == 1 ) then
    frame:SetAlpha(1);
  else
    frame:SetAlpha(alphaOocParam);
  end
end

SLASH_RUNEPACK1 = "/RunePack";
SLASH_RUNEPACK2 = "/Runepack";
SLASH_RUNEPACK3 = "/runepack";

SlashCmdList["RUNEPACK"] = RunePack_SlashCommand;

function RunePack_SlashCommand()
	  InterfaceOptionsFrame_OpenToCategory("RunePack");
end
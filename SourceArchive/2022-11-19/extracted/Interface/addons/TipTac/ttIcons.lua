local gtt = GameTooltip;

-- TipTac refs
local tt = TipTac;
local cfg;

-- element registration
local ttIcons = tt:RegisterElement({},"Icons");

--ttIcons.icons = {};

--------------------------------------------------------------------------------------------------------
--                                                Misc                                                --
--------------------------------------------------------------------------------------------------------

function ttIcons:SetIcon(icon,u)
	if (not UnitExists(u.token)) then
		return;
	end

	local raidIconIndex = GetRaidTargetIndex(u.token);

	if (cfg.iconRaid) and (raidIconIndex) then
		icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
		-- 크기 변경 추가 : Start
			icon:SetWidth(cfg.iconSize - 5);
			icon:SetHeight(cfg.iconSize - 5);
		-- 크기 변경 추가 : End
		SetRaidTargetIconTexture(icon,raidIconIndex);
	elseif (cfg.iconFaction) and (UnitIsPVPFreeForAll(u.token)) then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		-- 크기 변경 추가 : Start
			icon:SetWidth(cfg.iconSize + 5);
			icon:SetHeight(cfg.iconSize + 5);
		-- 크기 변경 추가 : End
		icon:SetTexCoord(0,0.62,0,0.62);
	elseif (cfg.iconFaction) and (UnitIsPVP(u.token)) and (UnitFactionGroup(u.token)) then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..UnitFactionGroup(u.token));
		-- 크기 변경 추가 : Start
			icon:SetWidth(cfg.iconSize + 5);
			icon:SetHeight(cfg.iconSize + 5);
		-- 크기 변경 추가 : End
		icon:SetTexCoord(0,0.62,0,0.62);
	elseif (cfg.iconCombat) and (UnitAffectingCombat(u.token)) then
		icon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon");
		-- 크기 변경 추가 : Start
			icon:SetWidth(cfg.iconSize + 5);
			icon:SetHeight(cfg.iconSize + 5);
		-- 크기 변경 추가 : End
		icon:SetTexCoord(0.5,1,0,0.5);
	elseif (u.isPlayer) and (cfg.iconClass) then
		local texCoord = CLASS_ICON_TCOORDS[u.classFile];
		if (texCoord) then
			icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
			-- 크기 변경 추가 : Start
				icon:SetWidth(cfg.iconSize + 5);
				icon:SetHeight(cfg.iconSize + 5);
			-- 크기 변경 추가 : End
			icon:SetTexCoord(unpack(texCoord));
		end	
	else
		return false;
	end

	return true;
end

--------------------------------------------------------------------------------------------------------
--                                           Element Events                                           --
--------------------------------------------------------------------------------------------------------

function ttIcons:OnLoad()
	cfg = TipTac_Config;
end

function ttIcons:OnApplyConfig(cfg)
	self.wantIcon = (cfg.iconRaid or cfg.iconFaction or cfg.iconCombat or cfg.iconClass or cfg.raceIcon or cfg.clasIcon or cfg.crtIcon);--self.wantIcon = (cfg.iconRaid or cfg.iconFaction or cfg.iconCombat or cfg.iconClass);

	if (self.wantIcon) then
		if (not self.icon) then
			self.icon = gtt:CreateTexture(nil,"ARTWORK"); -- BACKGROUND -> ARTWORK로 변경 (정예 프레임과 겹치지 않도록 변경)
		end
		self.icon:SetSize(cfg.iconSize,cfg.iconSize);
		self.icon:ClearAllPoints();
		self.icon:SetPoint(tt.MirrorAnchors[cfg.iconAnchor],gtt,cfg.iconAnchor);
	elseif (self.icon) then
		self.icon:Hide();
	end
end

function ttIcons:OnPostStyleTip(tip,first)
	if (self.wantIcon) then
		self.icon:SetShown(self:SetIcon(self.icon,tip.ttUnit));
	end
end

function ttIcons:OnCleared(tip)
	if (self.icon) and (gtt == tip) then
		self.icon:Hide();
	end
-- 정예 프레임, 종족 아이콘, 직업 아이콘, 속성 아이콘 초기화 기능 추가 : Start
-- 정예 프레임 초기화
	if (eliteFrame) then	
		eliteFrame:Hide();
	end

-- 종족 아이콘 초기화
	if (uri) then	
		uri:Hide();
	end

-- 직업 아이콘 초기화
	if (uci) then	
		uci:Hide();
	end

-- 속성 아이콘 초기화
	if (ci) then	
		ci:Hide();
	end
-- 정예 프레임, 종족 아이콘, 직업 아이콘, 속성 아이콘 초기화 기능 추가 : End
end
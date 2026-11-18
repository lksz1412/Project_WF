
function BlinkWhoLink_SetItemRef(link, text, button)
	if ( strsub(link, 1, 6) == "player" ) then
		local namelink = strsub(link, 8);
		local name, lineid = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then

			if ( button == "RightButton" ) then
				FriendsFrame_ShowDropdown(name, 1, lineid);
				return;
			elseif ( IsAltKeyDown() ) then 
				InviteUnit(name);
				return;
			elseif ( IsControlKeyDown() and IsAddOnLoaded("BlinkMailer") ) then
				if ( BlinkMailer_AddUser ) then
					BlinkMailer_AddUser(name);
				end
				return;
			end
			if ( not BlinkWhoLinkDB and IsShiftKeyDown() ) or ( BlinkWhoLinkDB and not IsShiftKeyDown() ) then
				local staticPopup;
				staticPopup = StaticPopup_Visible("ADD_IGNORE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_MUTE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_FRIEND");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_GUILDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_TEAMMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_RAIDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("CHANNEL_INVITE");
				if ( staticPopup ) then
					getglobal(staticPopup.."EditBox"):SetText(name);
					return;
				end
				if ( ChatFrameEditBox:IsVisible() ) then
					ChatFrameEditBox:Insert(name);
				elseif ( HelpFrameOpenTicketText:IsVisible() ) then
					HelpFrameOpenTicketText:Insert(name);
				else
					ChatFrame_SendTell(name); -- SendWho("n-"..name);
				end
			else
				SendWho(WHO_TAG_NAME..name); -- ChatFrame_SendTell(name);
			end
		end
		return;
	elseif ( strsub(link, 1, 7) == "channel" ) then
		if ( IsModifiedClick("CHATLINK") ) then
			ToggleFriendsFrame(4);
		elseif ( button == "LeftButton" ) then
			local chan = strsub(link, 9);
			local channum = tonumber(chan)
			if ( (not channum) or GetChannelName(channum)~=0 ) then
				--Open chat for channel
				ChatFrame_OpenChat("/"..chan, DEFAULT_CHAT_FRAME);
			end
		end
		return;
	end

	if ( IsModifiedClick() ) then
		HandleModifiedItemClick(text);
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:SetHyperlink(link);
	end
end

function BlinkWhoLink_Toggle()
	if ( BlinkWhoLinkDB ~= 1 ) then
		BlinkWhoLinkDB = 1
	else
		BlinkWhoLinkDB = nil
	end
end

function BlinkWhoLink_BlinkGUIRegister()
	if ( not Blink_AddAddon ) then
		return;
	end
	Blink_AddAddon("WhoLink",BLINK_CATEGORY_CHAT,{
		{
			["HEADER"] = {
				text = "블링크의 WhoLink",
			}
		},
		{
			["CHECKBOX"] = {
				text = "클릭 <-> 쉬프트+클릭 전환",
				tooltip = "플레이어 이름을 클릭하는것과 쉬프트+클릭하는것을 서로 바꿉니다.",
				set = function (value)
					BlinkWhoLink_Toggle()
				end,
				get = function ()
					if ( BlinkWhoLinkDB == 1 ) then
						return nil;
					else
						return 1;
					end
				end,
			},
		},
		{
			["TEXT"] = {
				text = "채팅창에서 플레이어의 이름을 클릭 = 플레이어 정보보기",
				tooltip = "플레이어의 이름, 레벨, 지역정보를 채팅창 또는 누구창에 표시합니다.",
			}
		},
		{
			["TEXT"] = {
				text = "채팅창에서 플레이어의 이름을 알트+클릭 = 파티초대",
				tooltip = "선택한 플레이어를 파티 또는 공격대에 초대합니다.",
			}
		},
		{
			["TEXT"] = {
				text = "채팅창에서 플레이어의 이름을 쉬프트+클릭 = 귓속말",
				tooltip = "선택한 플레이어에게 귓속말 채팅입력창을 보여줍니다.",
			}
		},
	})

	if ( IsAddOnLoaded("BlinkMailer") ) then
		Blink_AddAddon("WhoLink",BLINK_CATEGORY_CHAT,{
			{
				["TEXT"] = {
					text = "채팅창에서 플레이어의 이름을 컨트롤+클릭 = 편리한 우편함에 이름등록",
					tooltip = "선택한 플레이어의 이름을 편리한 우편함(BlinkMailer)에 등록합니다.",
				}
			},
		})
	end
end
local lOriginal_SetItemRef = SetItemRef;
SetItemRef = BlinkWhoLink_SetItemRef;

BlinkWhoLink_BlinkGUIRegister();

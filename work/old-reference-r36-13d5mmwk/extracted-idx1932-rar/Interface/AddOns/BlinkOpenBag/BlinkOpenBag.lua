--[[///////////////////////////////////////////////////////////////////////////

  Mod Name : Blink Open Bag v2.0
  Author   : Blink
  Date     : 2005/01/16
  LastUpdate : 2008/10/16

/////////////////////////////////////////////////////////////////////////////]]

local frame

local function frameOnEvent(self, event, ...)
	if self[event] and type(self[event])=='function' then
		self[event](self, ...)
	end
end

frame = CreateFrame("Frame")
frame:RegisterEvent("AUCTION_HOUSE_SHOW")
frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("BANKFRAME_CLOSED")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("MAIL_SHOW")
frame:RegisterEvent("MAIL_CLOSED")
frame:RegisterEvent("TRADE_SHOW")
frame:RegisterEvent("TRADE_CLOSED")
frame:RegisterEvent("GUILDBANKFRAME_OPENED")
frame:RegisterEvent("GUILDBANKFRAME_CLOSED")
frame:SetScript("OnEvent", frameOnEvent)

function frame:AUCTION_HOUSE_SHOW()
	--BlinkOpenBag_OpenBagAll()
	OpenAllBags()
end
function frame:AUCTION_HOUSE_CLOSED()
	--BlinkOpenBag_CloseBagAll()
	CloseAllBags()
end

frame.BANKFRAME_OPENED = frame.AUCTION_HOUSE_SHOW
frame.MERCHANT_SHOW = frame.AUCTION_HOUSE_SHOW
frame.MAIL_SHOW = frame.AUCTION_HOUSE_SHOW
frame.TRADE_SHOW = frame.AUCTION_HOUSE_SHOW
frame.GUILDBANKFRAME_OPENED = frame.AUCTION_HOUSE_SHOW

frame.BANKFRAME_CLOSED = frame.AUCTION_HOUSE_CLOSED
frame.MERCHANT_CLOSED = frame.AUCTION_HOUSE_CLOSED
frame.MAIL_CLOSED = frame.AUCTION_HOUSE_CLOSED
frame.TRADE_CLOSED = frame.AUCTION_HOUSE_CLOSED
frame.GUILDBANKFRAME_CLOSED = frame.AUCTION_HOUSE_CLOSED


function BlinkOpenBag_OpenBagAll()
	if( OpenAllInOneInventoryFrame )then
		OpenAllInOneInventoryFrame();
	else
		OpenBackpack();
		OpenBag(1);
		OpenBag(2);
		OpenBag(3);
		OpenBag(4);
		if ( BankFrame:IsShown() ) then
			OpenBag(5);
			OpenBag(6);
			OpenBag(7);
			OpenBag(8);
			OpenBag(9);
			OpenBag(10);
			OpenBag(11);
		end
		if ( IsOptionFrameOpen() ) then
			return;
		end
-- 열쇠고리는 열리지 않게 한다.. 은근히 귀찮더라구요;;ㅋ
--		local shownContainerID = IsBagOpen(KEYRING_CONTAINER);
--		if ( not shownContainerID ) then
--			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), GetKeyRingSize(), KEYRING_CONTAINER);
--
--			-- Stop keyring button pulse
--			SetButtonPulse(KeyRingButton, 0, 1);
--		end
	end
end

function BlinkOpenBag_CloseBagAll()
	if( CloseAllInOneInventoryFrame )then
		CloseAllInOneInventoryFrame();
	else
		CloseAllBags();
		if ( IsOptionFrameOpen() ) then
			return;
		end
		local shownContainerID = IsBagOpen(KEYRING_CONTAINER);
		if ( shownContainerID ) then
			getglobal("ContainerFrame"..shownContainerID):Hide();
		end
	end
end

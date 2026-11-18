---------------------------------------------------------------------------
-- short channelnames --
---------------------------------------------------------------------------
local gsub = _G.string.gsub

for i = 1, NUM_CHAT_WINDOWS do
	if ( i ~= 2 ) then
		local f = _G["ChatFrame"..i]
		local am = f.AddMessage
		f.AddMessage = function(frame, text, ...)
			return am(frame, text:gsub('|h%[(%d+)%. .-%]|h', '|h[%1]|h'), ...)
		end
	end
end






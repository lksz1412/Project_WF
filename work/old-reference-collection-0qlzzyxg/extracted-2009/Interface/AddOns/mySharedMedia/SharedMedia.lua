-- tab size is 4
-- registrations for media from the client itself belongs in LibSharedMedia-3.0

if not SharedMedia then return end
local revision = tonumber(string.sub("$Revision: 76383 $", 12, -3))
SharedMedia.revision = (revision > SharedMedia.revision) and revision or SharedMedia.revision

-- -----
-- BACKGROUND
-- -----


-- -----
--  BORDER
-- ----
SharedMedia:Register("border", "RothSquare", [[Interface\Addons\mySharedMedia\border\roth.tga]])
SharedMedia:Register("border", "DevilSquare", [[Interface\Addons\mySharedMedia\border\devil.tga]])
SharedMedia:Register("border", "Devil2Square", [[Interface\Addons\mySharedMedia\border\devil2.tga]])

-- -----
--   FONT
-- -----
SharedMedia:Register("font", "데미지 글꼴", [[Interface\Addons\mySharedMedia\fonts\K_Damage.TTF]])

-- -----
--   SOUND
-- -----


-- -----
--   STATUSBAR
-- -----
SharedMedia:Register("statusbar", "FairAqua", [[Interface\Addons\mySharedMedia\statusbar\FairAqua.tga]])
SharedMedia:Register("statusbar", "FairLady", [[Interface\Addons\mySharedMedia\statusbar\FairLady.tga]])
SharedMedia:Register("statusbar", "Glamour7",	[[Interface\Addons\mySharedMedia\statusbar\Glamour7]])
SharedMedia:Register("statusbar", "Minimalist",	 [[Interface\Addons\mySharedMedia\statusbar\Minimalist]])
SharedMedia:Register("statusbar", "Smooth", [[Interface\Addons\mySharedMedia\statusbar\Smooth]])
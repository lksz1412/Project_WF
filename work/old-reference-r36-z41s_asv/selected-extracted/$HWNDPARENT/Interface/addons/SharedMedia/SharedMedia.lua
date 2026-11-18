-- tab size is 4
-- registrations for media from the client itself belongs in LibSharedMedia-3.0

if not SharedMedia then return end
local revision = tonumber(string.sub("$Revision: 70014 $", 12, -3))
SharedMedia.revision = (revision > SharedMedia.revision) and revision or SharedMedia.revision

-- -----
-- BACKGROUND
-- -----
SharedMedia:Register("background", "Moo", [[Interface\Addons\SharedMedia\background\moo.tga]])

-- -----
--  BORDER
-- ----
SharedMedia:Register("border", "RothSquare", [[Interface\Addons\SharedMedia\border\roth.tga]])
SharedMedia:Register("border", "DevilSquare", [[Interface\Addons\SharedMedia\border\devil.tga]])
SharedMedia:Register("border", "Devil2Square", [[Interface\Addons\SharedMedia\border\devil2.tga]])

-- -----
--   FONT
-- -----
SharedMedia:Register("font", "데미지 글꼴", [[Interface\Addons\SharedMedia\fonts\K_Damage.TTF]])

-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
SharedMedia:Register("statusbar", "Glamour7",	[[Interface\Addons\SharedMedia\statusbar\Glamour7]])
SharedMedia:Register("statusbar", "Minimalist",	 [[Interface\Addons\SharedMedia\statusbar\Minimalist]])
SharedMedia:Register("statusbar", "Smooth", [[Interface\Addons\SharedMedia\statusbar\Smooth]])
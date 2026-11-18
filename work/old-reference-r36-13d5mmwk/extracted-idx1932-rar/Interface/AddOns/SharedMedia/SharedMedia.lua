-- tab size is 4
-- registrations for media from the client itself belongs in LibSharedMedia-3.0

if not SharedMedia then return end
local revision = tonumber(string.sub("$Revision: 75843 $", 12, -3))
SharedMedia.revision = (revision > SharedMedia.revision) and revision or SharedMedia.revision

-- -----
-- BACKGROUND
-- -----


-- -----
--  BORDER
-- ----


-- -----
--   FONT
-- -----
SharedMedia:Register("font", "데미지 글꼴",					[[Interface\Addons\SharedMedia\fonts\K_Damage.TTF]])

-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
SharedMedia:Register("statusbar", "Minimalist",			[[Interface\Addons\SharedMedia\statusbar\Minimalist]])
SharedMedia:Register("statusbar", "Smooth",				[[Interface\Addons\SharedMedia\statusbar\Smooth]])
SharedMedia:Register("statusbar", "Smooth v2",			[[Interface\Addons\SharedMedia\statusbar\Smoothv2]])
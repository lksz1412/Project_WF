-- Existing windows only; no modes, attributes or plugin selection.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "Feature appearance", "physical pixel factor unavailable at proposal evaluation")
  return {}
end
return {[1]={["window_scale"]=pixel,["libwindow"]={["point"]="TOPLEFT",["x"]=1946*pixel,["y"]=-780*pixel,["scale"]=pixel},["posicao"]={["normal"]={["x"]=831.0*pixel,["y"]=-150.0*pixel,["w"]=330,["h"]=180}},["bg_alpha"]=0.9,["bg_r"]=0.035,["bg_g"]=0.035,["bg_b"]=0.04,["backdrop_texture"]="Devil Forever devil",["titlebar_shown"]=true,["titlebar_height"]=26,["titlebar_texture"]="Devil Forever devil",["titlebar_texture_color"]={0.035,0.035,0.04,0.95},["fullborder_shown"]=true,["fullborder_size"]=1,["fullborder_color"]={0.57,0.58,0.59,1},["row_info"]={["height"]=24,["font_size"]=18,["font_face"]="Devil Forever devil",["font_face_file"]=STANDARD_TEXT_FONT,["texture"]="Devil Forever devil",["space"]={["left"]=3,["right"]=-5,["between"]=2}}},[2]={["window_scale"]=pixel,["libwindow"]={["point"]="TOPLEFT",["x"]=1946*pixel,["y"]=-972*pixel,["scale"]=pixel},["posicao"]={["normal"]={["x"]=831.0*pixel,["y"]=-302.0*pixel,["w"]=330,["h"]=100}},["bg_alpha"]=0.9,["bg_r"]=0.035,["bg_g"]=0.035,["bg_b"]=0.04,["backdrop_texture"]="Devil Forever devil",["titlebar_shown"]=true,["titlebar_height"]=26,["titlebar_texture"]="Devil Forever devil",["titlebar_texture_color"]={0.035,0.035,0.04,0.95},["fullborder_shown"]=true,["fullborder_size"]=1,["fullborder_color"]={0.57,0.58,0.59,1},["row_info"]={["height"]=24,["font_size"]=18,["font_face"]="Devil Forever devil",["font_face_file"]=STANDARD_TEXT_FONT,["texture"]="Devil Forever devil",["space"]={["left"]=3,["right"]=-5,["between"]=2}}}}

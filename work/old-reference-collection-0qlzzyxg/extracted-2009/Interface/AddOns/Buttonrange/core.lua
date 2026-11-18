-- change the following values to define your out of range color (r, g, b)
local oor = { 0.8, 0, 0 }; 
-- don't change anything below
local Button_OnUpdate = function(self, elapsed)
	if ( self.rangeTimer == TOOLTIP_UPDATE_TIME ) then
		local range = false;
		if ( IsActionInRange(self.action) == 0 ) then
			getglobal(self:GetName().."Icon"):SetVertexColor(unpack(oor));
			getglobal(self:GetName().."NormalTexture"):SetVertexColor(unpack(oor));
			range = true;
		end;
		if ( self.range ~= range and range == false ) then
			ActionButton_UpdateUsable(self);
		end;
		self.range = range;
	end;
end;
hooksecurefunc("ActionButton_OnUpdate",Button_OnUpdate);
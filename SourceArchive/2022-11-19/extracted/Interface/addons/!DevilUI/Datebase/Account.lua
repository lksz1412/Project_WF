local A, L, M = select( 2, ... ):Unpack()

local AccountDataBase = {}
local AccountDataBase = {
	['General'] = {
		['UIScale'] = 0.71,
		['AutoUIScale'] = true,
		['IsGuided'] = false,
	},

	['Gold'] = {},
}

A['DataBase_SetupAccount'] = function()
	for a, b in pairs( AccountDataBase ) do
		if( type( b ) ~= 'table' ) then
			if( aCoreDB[a] == nil ) then
				aCoreDB[a] = b
			end
		else
			if( aCoreDB[a] == nil ) then
				aCoreDB[a] = {}
			end

			for k, v in pairs( b ) do
				if( aCoreDB[a][k] == nil ) then
					aCoreDB[a][k] = v
				end
			end
		end
	end
end

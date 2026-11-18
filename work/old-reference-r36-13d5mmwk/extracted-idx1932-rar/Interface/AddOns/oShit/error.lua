--[[-------------------------------------------------------------------------
  Copyright (c) 2007, Trond A Ekseth
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of oShit nor the names of its contributors
        may be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]

local oShit = {}
local argstostring = function(v, ...) if select('#', ...) == 0 then return v end return v.._tostring(...) end
local print = function(...) ChatFrame1:AddMessage("|cff33ff99oShit:|r "..argstostring(...)) end

seterrorhandler(function(error)
	local stack = debugstack():match".-\n(.*)":gsub("\n$", "") -- remove oShit's part of it and strip the ending newline.
	table.insert(oShit, stack)

	print(("(%d): %s"):format(#oShit, error))
end)

SlashCmdList['OSHIT_ERROR'] = function(s)
	local error = oShit[tonumber(s)]
	local t = #oShit

	if(error) then
		print(("(%d): %s"):format(tonumber(s), error))
	elseif(t ~= 0) then
		print(("(%d): %s"):format(t, oShit[t]))
	else
		print"Yatta, no errors! Kyu~n."
	end
end
SLASH_OSHIT_ERROR1 = '/oshit'
SLASH_OSHIT_ERROR2 = '/ohshit'

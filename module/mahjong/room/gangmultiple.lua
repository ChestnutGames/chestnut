local opcode = require "opcode"
local gangtype = require "gangtype"

local _M = {}

_M[gangtype.bugang] = 1
_M[gangtype.zhigang] = 2
_M[gangtype.angang] = 2

local function multiple(code, ... )
	-- body
	if _M[code] then
		return _M[code]
	else
		assert(false)
	end
end

return multiple
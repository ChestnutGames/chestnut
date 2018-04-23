local skynet = require "skynet"
local log = require "chestnut.skynet.log"

function guid( ... )
	-- body
	local addr = skynet.uniqueservice("guid")
	local id = skynet.call(addr, "lua")
	return id
end

return guid
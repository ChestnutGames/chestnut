-- if client for this node has 
local skynet = require "skynet"
local snowflake = require "chestnut.snowflake"

local worker       = skynet.getenv("worker")
-- local cross_worker = skynet.getenv("cross_worker")

skynet.start(function ()
	-- body
	local g = snowflake.init(worker)
	skynet.dispatch("lua", function(_,_, ...)
		-- body
		assert(g)
		local id = snowflake.next_id(g)
		skynet.retpack(id)
	end)

end)
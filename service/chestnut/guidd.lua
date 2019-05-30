-- if client for this node has 
local skynet = require "skynet"
local snowflake = require "chestnut.snowflake"
local service = require "service"

local worker       = skynet.getenv("worker")
-- local cross_worker = skynet.getenv("cross_worker")
local CMD = {}

function CMD.start( ... )
	-- body
	snowflake.init(worker)
end

function CMD.init_data( ... )
	-- body
	return true
end

function CMD.sayhi( ... )
	-- body
	return true
end

function CMD.close()
	snowflake.exit()
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

service.init {
	command = CMD
}
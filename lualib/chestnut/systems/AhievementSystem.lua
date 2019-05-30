local client = require "client"
local CMD = require("chestnut.agent.cmd")

local cls = {}

function cls:on_data_init(dbData)
	-- body
	assert(dbData ~= nil)
	assert(dbData.db_users ~= nil)
	assert(#dbData.db_users == 1)

	return true
end

function cls:on_data_save(dbData, ... )
	-- body
	assert(dbData ~= nil)

	return true
end

function cls:on_enter()
end

function cls:afk()
end

function cls:hello( ... )
	-- body
end

local REQUEST = client.request()

function REQUEST:mm(msg)
end

function CMD:aa(msg)
	local obj = objmgr.get(uid)
end

return cls
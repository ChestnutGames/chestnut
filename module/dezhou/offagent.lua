local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
-- local sd = require "skynet.sharedata"
local log = require "chestnut.skynet.log"
local json = require "rapidjson"

local NORET = {}
local CMD = {}

function CMD.start()
	-- body
	return true
end

function CMD.init_data()
	-- body
	return true
end

function CMD.sayhi()
	-- body
	-- 初始化各种全服信息
end

-- channel msg, not return
function CMD.save_data()
	-- body
end

function CMD.close()
	-- body
	return true
end

function CMD.kill()
	-- body
	skynet.exit()
end

function CMD.write_offuser_room(uid)
	-- body
	local offuser = {
		uid = uid,
		roomid = 0,
		created = 0,
		joined = 0
	}
	return skynet.call('.DB', "lua", 'write_offuser_room', offuser)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function (_, _, cmd, ... )
		-- body
		local f = CMD[cmd]
		local r = f(...)
		if r ~= NORET then
			if r ~= nil then
				skynet.retpack(r)
			else
				log.error("affagent cmd = %s no ret", cmd)
			end
		end
	end)
	skynet.register ".OFFAGENT"
end)
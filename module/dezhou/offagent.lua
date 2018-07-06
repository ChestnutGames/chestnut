local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
-- local sd = require "skynet.sharedata"
local log = require "chestnut.skynet.log"
local json = require "rapidjson"
local traceback = debug.traceback
local assert = assert

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
		created = 0,
		joined = 0,
		update_at=os.time(),
		mode = 0
	}
	return skynet.call('.DB', "lua", 'write_offuser_room', offuser)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function (_, _, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local ok, err = xpcall(f, traceback, ...)
		if ok then
			if err ~= NORET then
				if err ~= nil then
					skynet.retpack(err)
				else
					log.error("affagent cmd = %s no ret", cmd)
				end
			end
		else
			log.error(err)
		end
	end)
	skynet.register ".OFFAGENT"
end)
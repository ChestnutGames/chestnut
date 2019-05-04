local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local mc = require "skynet.multicast"
local traceback = debug.traceback

local service = {}

function service.init(mod)
    
    local funcs = mod.command
    local channel_id = mod.channel_id
    
    local channel = mc.new {
		channel = channel_id,
		dispatch = function (_, _, cmd, ...)
            -- body
            local f = assert(funcs[cmd])
            local ok, err = xpcall(f, traceback, ...)
            if not ok then
                log.error("agent cmd [%s] error = [%s]", cmd, err)
            end
		end
	}
	channel:subscribe()
end

return service

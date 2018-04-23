package.path = "./module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local sd = require "skynet.sharedata"
local log = require "chestnut.skynet.log"
local dbmonitor = require "dbmonitor"
local const = require "const"
local NORET = {}


local CMD = {}

function CMD.start( ... )
	-- body
	-- 更新数据
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, cmd, ...)
		log.info("game cmd = %s", cmd)
		local f = CMD[cmd]
		local r = f(...)
		if r ~= NORET then
			skynet.retpack(r)
		end
	end)
	-- skynet.fork(update_db)
	skynet.register "game"
end)

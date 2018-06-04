package.path = "./module/dezhou/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local builder = require "skynet.datasheet.builder"
local log = require "chestnut.skynet.log"
local AppConfig = require "AppConfig"
local NORET = {}


local CMD = {}

function CMD.start( ... )
	-- body
	-- 更新数据
	local config = AppConfig.new()
	if config:LoadFile() then
		for k,v in pairs(config.config) do
			builder.new(k, v)
		end
		return true
	end
	return false
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
		local f = assert(CMD[cmd])
		local r = f(...)
		if r ~= NORET then
			skynet.retpack(r)
		end
	end)
	skynet.register "sdata"
end)

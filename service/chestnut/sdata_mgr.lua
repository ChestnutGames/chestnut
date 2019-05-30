local skynet = require "skynet"
local builder = require "skynet.datasheet.builder"
local log = require "chestnut.skynet.log"
local AppConfig = require "chestnut.sdata.AppConfig"
local service = require("service")

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

function CMD.init_data()
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

service.init {
	command = CMD
}

-- if client for this node has 
local skynet = require "skynet"
local snowflake = require "chestnut.snowflake"
local service = require "service"
local host = require 'xlog.host'
local tableDump = require 'luaTableDump'

local cfg = {...}
local logger
local CMD = {}

local function loop()
	while true do
		logger:flush()
		skynet.sleep(100 * 2)
	end
end

function CMD.append(data)
	-- body
	local time   =  assert(data.time)
	local level  =  assert(data.level)
	local server =  assert(data.server)
	local file   =  assert(data.file)
	local line   =  assert(data.line)
	local tmp    =  ''
	if type(data.fields) == 'table' then
		for k,v in pairs(data.fields) do
			tmp = tmp .. string.format( "[%s = %s]", tostring(k), tostring(v))
		end
	end
	local msg    = assert(data.msg)
	local fs = string.format("[time = %s][level = %s][server = %s][file = %s][line = %s]%s[msg = %s]", time, level, server, file, line, tmp, msg)
	logger:append(fs)
end

service.init {
	init = function ()
		-- print(tableDump(cfg))
		logger = host(cfg[1], tonumber(cfg[2]), tonumber(cfg[3]))
		skynet.fork(loop)
	end,
	command = CMD
}
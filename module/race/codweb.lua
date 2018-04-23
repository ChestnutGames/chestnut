local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local log = require "skynet.log"

local servers = {}

local CMD = {}

function CMD.start( ... )
	-- body

	local xlogger = skynet.launch("xlogger")

	-- read
	local game = skynet.uniqueservice("game")
	skynet.call(game, "lua", "start")
	table.insert(servers, game)

	local chat = skynet.uniqueservice("chatd")
	skynet.call(chat, "lua", "start")
	table.insert(servers, chat)
	
	local sid_mgr = skynet.uniqueservice("sid_mgr")
	skynet.call(sid_mgr, "lua", "start")
	table.insert(servers, sid_mgr)

	local agent_mgr = skynet.uniqueservice("agent_mgr")
	skynet.call(agent_mgr, "lua", "start", 2)
	table.insert(servers, agent_mgr)

	local room_mgr = skynet.uniqueservice("room_mgr")
	skynet.call(room_mgr, "lua", "start")
	table.insert(servers, room_mgr)

	local match = skynet.newservice("match")
	skynet.call(match, "lua", "start")
	table.insert(servers, match)

	local signupd = skynet.newservice("signupd")
	skynet.call(signupd, "lua", "start")

	local gated = skynet.newservice("gated")
	skynet.call(gated, "lua", "start")

	skynet.newservice("web/simpleweb")
	
	return true
end

function CMD.close( ... )
	-- body
	for _,v in ipairs(servers) do
		skynet.call(v, "lua", "close")
	end
end

function CMD.kill( ... )
	-- body
	for _,v in ipairs(servers) do
		skynet.call(v, "lua", "close")
	end
	
	skynet.abort()
end

skynet.start( function () 
	skynet.dispatch("lua" , function( _, source, command, ... )
		local f = assert(CMD[command])
		local r = f(source, ...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".CODWEB"
end)

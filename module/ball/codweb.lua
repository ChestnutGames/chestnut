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
	local share = skynet.uniqueservice("share")
	skynet.call(share, "lua", "start")
	table.insert(servers, share)

	local chat = skynet.uniqueservice("chatd")
	skynet.call(chat, "lua", "start")
	table.insert(servers, chat)
	
	local handle = skynet.uniqueservice("sid_mgr")
	skynet.call(handle, "lua", "start")
	table.insert(servers, handle)

	local agent_mgr = skynet.uniqueservice("agent_mgr")
	skynet.call(agent_mgr, "lua", "start", 2)
	table.insert(servers, agent_mgr)

	local room_mgr = skynet.uniqueservice("room_mgr")
	skynet.call(room_mgr, "lua", "start")
	table.insert(servers, room_mgr)

	local match = skynet.newservice("match")
	skynet.call(match, "lua", "start")
	table.insert(servers, match)

	local udpmgr = skynet.newservice("udpserver_mgr")
	skynet.call(udpmgr, "lua", "start")
	table.insert(servers, udpmgr)

	-- add 
	local signupd = skynet.newservice("signupd")
	skynet.call(signupd, "lua", "start")
	
	local logind = skynet.getenv("logind")
	if logind then
		local addr = skynet.newservice("logind/logind")
	end     

	local logind_name = skynet.getenv("logind_name")
	local server_name = skynet.getenv("gated_name")
	local max_client = skynet.getenv("maxclient")
	local address, port = string.match(skynet.getenv("gated"), "([%d.]+)%:(%d+)")
	local gated = skynet.newservice("gated/gated")
	skynet.call(gated, "lua", "open", { 
		address = address or "0.0.0.0",
		port = port,
		maxclient = tonumber(max_client),
		servername = server_name,
		--nodelay = true,
	})
	
	return true
end

function CMD.kill( ... )
	-- body
	for i,v in ipairs(servers) do
		-- print(v)
		-- print(skynet.queryservice(v))
		-- log.info(skynet.queryservice(false, v))
		skynet.call(v, "lua", "close")
	end
	-- skynet.exit()
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

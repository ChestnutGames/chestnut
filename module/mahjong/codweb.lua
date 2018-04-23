local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"

local channel
local services = {}
local init_data_servers = {}
local sayhi_servers = {}


local CMD = {}

function CMD.start( ... )
	-- body
	local ok = false

	skynet.launch("xloggerd")
	log.info("xloggerd start ... ")

	skynet.uniqueservice("redis")

	-- read config
	local game = skynet.uniqueservice("game")
	skynet.call(game, "lua", "start", channel.channel)

	local room_mgr = skynet.uniqueservice("room_mgr")
	skynet.call(room_mgr, "lua", "start", channel.channel)
	table.insert(services, room_mgr)
	table.insert(init_data_servers, room_mgr)
	table.insert(sayhi_servers, room_mgr)

	local sid_mgr = skynet.uniqueservice("sid_mgr")
	skynet.call(sid_mgr, "lua", "start", channel.channel)
	table.insert(services, sid_mgr)

	local radiocenter = skynet.uniqueservice("radiocenter")
	skynet.call(radiocenter, "lua", "start", channel.channel)
	table.insert(services, radiocenter)

	local chat = skynet.uniqueservice("chatd")
	skynet.call(chat, "lua", "start", channel.channel)
	table.insert(services, chatd)

	local sysemaild = skynet.uniqueservice("sysemail/mail_mgr")
	skynet.call(sysemaild, "lua", "start", channel.channel)
	table.insert(services, sysemaild)
	table.insert(init_data_servers, sysemaild)

	local record_mgr = skynet.uniqueservice("record/record_mgr")
	skynet.call(record_mgr, "lua", "start", channel.channel)
	table.insert(services, record_mgr)
	table.insert(init_data_servers, record_mgr)

	local agent_mgr = skynet.uniqueservice("agent_mgr")
	skynet.call(agent_mgr, "lua", "start", channel.channel, 5)
	table.insert(services, agent_mgr)

	-- three service
	local signupd = skynet.getenv("signupd")
	if signupd  then
		local addr = skynet.newservice("wx_signupd")
		skynet.call(addr, "lua", "start")
	end

	local logind = skynet.getenv("logind") or "0.0.0.0:3002"
	local addr = skynet.newservice("logind/logind", logind)
	skynet.name(".LOGIND", addr)
	
	local gated = skynet.getenv("gated") or "0.0.0.0:3301"
	local address, port = string.match(gated, "([%d.]+)%:(%d+)")
	local gated_name = skynet.getenv("gated_name") or "sample"
	local max_client = skynet.getenv("maxclient") or 1024
	local gated = skynet.uniqueservice("gated/gated")
	skynet.call(gated, "lua", "open", { 
		address = address or "0.0.0.0",
		port = port,
		maxclient = tonumber(max_client),
		servername = gated_name,
		--nodelay = true,
	})
	return true
end

function CMD.init_data()
	-- body
	for _,v in pairs(init_data_servers) do
		skynet.call(v, "lua", "init_data")
	end
	skynet.timeout(100, function ( ... )
		-- body
		while true do
			channel:publish("save_data")
			skynet.sleep(100)
		end
	end)
	log.info("init_data over.")
	return true
end

function CMD.sayhi( ... )
	-- body
	for _,v in pairs(sayhi_servers) do
		skynet.call(v, "lua", "sayhi")
	end
	log.info("sayhi over.")
	return true
end

function CMD.kill( ... )
	-- body
	for _,v in pairs(servers) do
		skynet.call(v, "lua", "close")
	end

	-- skynet.exit()
	skynet.abort()
end

skynet.start( function ()
	channel = mc.new()
	skynet.dispatch("lua" , function( _, source, cmd, ... )
		local f = assert(CMD[cmd])
		local r = f(source, ...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".CODWEB"
end)

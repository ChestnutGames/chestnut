local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local service = require "service"

local channel
local services = {}
local init_data_servers = {}
local sayhi_servers = {}

local CMD = {}

function CMD.start()
	-- body
	local ok = false

	-- logger
	skynet.launch("xloggerd")
	log.info("xloggerd start ... ")

	-- db
	skynet.uniqueservice("db/db")

	-- config
	local sdata = skynet.uniqueservice("chestnut/sdata")
	ok = skynet.call(sdata, "lua", "start")
	if not ok then
		log.error("call sdata failture.")
		skynet.exit()
	else
		log.info("sdata load success.")
	end

	-- global service
	local sid_mgr = skynet.uniqueservice("chestnut/sid_mgr")
	skynet.call(sid_mgr, "lua", "start", channel.channel)
	table.insert(services, sid_mgr)
	log.info("sid_mgr start success.")

	local room_mgr = skynet.uniqueservice("chestnut/room_mgr")
	skynet.call(room_mgr, "lua", "start", channel.channel)
	table.insert(services, room_mgr)
	table.insert(init_data_servers, room_mgr)
	table.insert(sayhi_servers, room_mgr)
	log.info("room_mgr start success.")

	local radiocenter = skynet.uniqueservice("chestnut/radiocenter")
	skynet.call(radiocenter, "lua", "start", channel.channel)
	table.insert(services, radiocenter)
	log.info("radiocenter start success.")

	local chat = skynet.uniqueservice("chatd")
	skynet.call(chat, "lua", "start", channel.channel)
	table.insert(services, chat)
	log.info("chat start success.")

	local sysemaild = skynet.uniqueservice("chestnut/mail_mgr")
	skynet.call(sysemaild, "lua", "start", channel.channel)
	table.insert(services, sysemaild)
	table.insert(init_data_servers, sysemaild)
	log.info("sysemaild start success.")

	local record_mgr = skynet.uniqueservice("chestnut/record_mgr")
	skynet.call(record_mgr, "lua", "start", channel.channel)
	table.insert(services, record_mgr)
	table.insert(init_data_servers, record_mgr)
	log.info("record_mgr start success.")

	local offagent = skynet.uniqueservice("chestnut/offagent")
	skynet.call(offagent, "lua", "start", channel.channel)
	table.insert(services, offagent)
	log.info("offagent start success.")

	local agent_mgr = skynet.uniqueservice("chestnut/agent_mgr")
	skynet.call(agent_mgr, "lua", "start", channel.channel, 5)
	table.insert(services, agent_mgr)
	log.info("agent_mgr start success.")

	local loginType = skynet.getenv 'login_type'
	if loginType == 'so' then
		local gated = skynet.getenv("gated") or "0.0.0.0:3301"
		local address, port = string.match(gated, "([%d.]+)%:(%d+)")
		local gated_name = skynet.getenv("gated_name") or "sample"
		local max_client = skynet.getenv("maxclient") or 1024
		local gate = skynet.uniqueservice("gated/gated")
		skynet.call(gate, "lua", "open", {
			address = address or "0.0.0.0",
			port = port,
			maxclient = tonumber(max_client),
			servername = gated_name,
			--nodelay = true,
		})

		local udpgated = skynet.getenv("udpgated")
		if udpgated then
			-- local address, port = string.match(udpgated, "([%d.]+)%:(%d+)")
			-- local gated_name = skynet.getenv("gated_name") or "sample"
			-- local max_client = skynet.getenv("maxclient") or 1024
			local udpgate = skynet.uniqueservice("rudpserver_mgr")
			skynet.call(udpgate, "lua", "start")
		end
	else 
		local wsgated = skynet.uniqueservice('wsgated')
		skynet.call(wsgated, "lua", "start")
		log.info("wsgated start success.")
	end

	skynet.error(login_type)
	return true
end

function CMD.init_data()
	-- body
	for _,v in pairs(init_data_servers) do
		skynet.call(v, "lua", "init_data")
		log.info("init data success.")
	end
	log.info("init_data over.")
	return true
end

function CMD.sayhi()
	-- body
	for _,v in pairs(sayhi_servers) do
		skynet.call(v, "lua", "sayhi")
	end
	log.info("sayhi over.")
	-- begin to save data
	skynet.timeout(100 * 60, function ()
		-- body
		while true do
			channel:publish("save_data")
			skynet.sleep(100)
		end
	end)
	return true
end

function CMD.kill()
	-- body
	for _,v in pairs(services) do
		skynet.call(v, "lua", "close")
	end
	log.info('kill services')
	-- skynet.exit()
	-- skynet.abort()
end

service.init {
	name = ".CODWEB",
	command = CMD
}

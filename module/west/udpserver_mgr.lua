local skynet = require "skynet"
require "skynet.manager"
local queue = require "chestnut.queue"
local udpserver = require "udpserver"

local gate_max = 10
local q

local CMD = {}

function CMD.start( ... )
	-- body
	local host = skynet.getenv "udp_host"
	local port = skynet.getenv "udp_port"
	q = queue()
	for i=1,gate_max do
		local xport = port + i
		local udpgate = skynet.newservice("udpserver")
		skynet.call(udpgate, "lua", "start", host, xport)
		q:enqueue(udpgate)
	end
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

function CMD.enter(uid, addr, ... )
	-- body
	local udpgate = q:dequeue()
	local res = skynet.call(udpgate, "lua", "register", addr, uid)
	res.gate = udpgate
	res.uid = uid
	q:enqueue(udpgate)
	return res
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".UDPSERVER_MGR"
end)
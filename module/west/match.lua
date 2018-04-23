local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local queue = require "chestnut.queue"
local errorcode = require "errorcode"

local mode = {
	MODE1 = 1
}

local modeq = {}
local users = {}

local CMD = {}

function CMD.start( ... )
	-- body
	for _,v in pairs(mode) do
		modeq[v] = queue()
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

function CMD.afk(uid, ... )
	-- body
	local u = users[uid]
	if u then
		u.online = false
	end
end

function CMD.logout(uid, ... )
	-- body
	local u = users[uid]
	if u then
		u.logout = true
	end
end

function CMD.enter(uid, secret, agent, mode, ... )
	-- body
	print("match enter")
	assert(uid and agent and mode)
	local u = users[uid]
	if u then
		if u.room then
			return { errorcode = errorcode.FAIL }
		end
		u.agent = agent
		u.mode = mode
		u.room = nil
	else
		u = {
			uid = uid,
			secret = secret,
			agent = agent,
			mode = mode,
			room = nil
		}
		users[uid] = u
	end

	print("match enter 1")
	local q = modeq[mode]
	assert(q)
	q:enqueue(u)

	if #q >= 1 then
		local id = skynet.call(".ROOM_MGR", "lua", "enter")
		local addr = skynet.call(".ROOM_MGR", "lua", "apply", id)
		local room = {
			id = id,
			addr = addr
		}
		skynet.call(addr, "lua", "start", mode)
		for i=1,1 do
			local u = q:dequeue()
			u.room = room
			local conf = skynet.call(".UDPSERVER_MGR", "lua", "enter", u.secret, addr)
			conf.uid = u.uid
			skynet.call(addr, "lua", "match", conf)	
			skynet.send(u.agent, "lua", "match", { roomid=id, udphost = conf.udphost, udpport = conf.udpport, session = conf.session })
		end
	end

	print("match enter 2")
	local res = { errorcode = errorcode.SUCCESS }
	return res
end

function CMD.exchange(roomid, ... )
	-- body
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
	skynet.register ".MATCH"
end)
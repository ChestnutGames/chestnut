local skynet = require "skynet"
require "skynet.manager"

local users = {}
local rooms = {}
local CMD = {}

function CMD.start( ... )
	-- body
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
end

function CMD.checkin(uid, agent)
	-- body
	local u = {
		uid = uid,
		agent = agent,
	}
	users[uid] = u
end

function CMD.afk(uid)
	-- body
	assert(users[uid])
	users[uid] = nil
end

function CMD.room_checkin(room_id, addr, users, ... )
	-- body
	if not rooms[room_id] then
		rooms[room_id] = {}
	end
	rooms[room_id].addr  = addr
	rooms[room_id].users = users
end

function CMD.room_afk(room_id)
	-- body
end

function CMD.say(from, to, word)
	if rooms[to] then
		local room = rooms[to]
		for _,v in pairs(room) do
			if users[v] then
				skynet.send(users[v].agent, "lua", "say", from, word)
			end
		end
	elseif users[to] then
		skynet.send(users[to].agent, "lua", "say", from, word)
	end
end

skynet.start(function ()
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		local f = CMD[cmd]
		if f then
			local r = f(subcmd, ...)
			if r ~= nil then
				skynet.retpack(r)
			end
		end
	end)
	skynet.register ".CHAT"
end)
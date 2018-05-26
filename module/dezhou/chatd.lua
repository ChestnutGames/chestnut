local skynet = require "skynet"
require "skynet.manager"

local users = {}          -- 全服聊天
local rooms = {}          -- 房间聊天
local CMD = {}

function CMD.start()
	-- body
	return true
end

function CMD.close()
	-- body
	return true
end

function CMD.kill()
	-- body
	skynet.exit()
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

function CMD.room_create(room_id, addr)
	-- body
	if not rooms[room_id] then
		rooms[room_id] = {}
	end
	rooms[room_id].addr  = addr
	rooms[room_id].users = {}
	return true
end

function CMD.room_join(room_id, uid, agent)
	-- body
	local room = rooms[room_id]
	room.users[uid] = { uid = uid, agent = agent, online = true }
	return true
end

function CMD.room_rejoin(room_id, uid)
	-- body
	local room = rooms[room_id]
	local user = room.users[uid]
	user.online = true
	return true
end

function CMD.room_afk(room_id, uid)
	-- body
	local room = rooms[room_id]
	local user = room.users[uid]
	user.online = false
	return true
end

function CMD.room_leave(room_id, uid)
	-- body
	local room = rooms[room_id]
	room.users[uid] = nil
	return true
end

function CMD.room_recycle(room_id)
	-- body
	rooms[room_id] = nil
	return true
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
	skynet.register ".CHATD"
end)
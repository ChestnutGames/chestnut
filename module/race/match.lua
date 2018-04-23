local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local queue = require "chestnut.queue"
local errorcode = require "errorcode"

local mode = {
	MODE_ONE = 1
}

local MAX_ROOM_NUM = 2

local users = {}
local modeq = {}
local modec = {}

local CMD = {}

function CMD.start( ... )
	-- body

	for _,v in pairs(mode) do
		modeq[v] = queue()
		modec[v] = 0
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

-- enrol and match
function CMD.enter(uid, agent, mode, ... )
	-- body
	assert(uid and agent and mode)
	local u = users[uid]
	if u then
		if u.room then
			local res = {}
			res.errorcode = 10001 -- has
			return res
		else
			u.agent = agent
			u.mode = mode
		end
	else
		u = {
			uid = uid,
			agent = agent,
			mode = mode,
			room = nil
		}
		users[uid] = u
	end

	local q = modeq[mode]
	assert(q)

	q:enqueue(u)

	if #q >= MAX_ROOM_NUM then
		local id = skynet.call(".ROOM_MGR", "lua", "enter")
		local addr = skynet.call(".ROOM_MGR", "lua", "apply", id)
		local room = {
			id = id,
			addr = addr
		}

		local p = {}
		for i=1,MAX_ROOM_NUM do
			local u = q:dequeue()
			u.room = room
			table.insert(p, u)
		end

		skynet.call(addr, "lua", "start", p, mode)
	end
	
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.waitTime  = 1
	res.peopleCount = modec[mode]
	return res
end

function CMD.exchange(roomid, ... )
	-- body
end

function CMD.enrolstate( ... )
	-- body
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = CMD[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".MATCH"
end)
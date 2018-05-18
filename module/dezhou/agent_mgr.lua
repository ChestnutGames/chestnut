local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local skynet_queue = require "skynet.queue"
local queue = require "chestnut.queue"
local util = require "chestnut.time_utils"

local NORET = {}
local cs = skynet_queue()
local leisure_agent = queue()
local users = {}
local channel

local function new_agent( ... )
	-- body
	local addr = skynet.newservice("agent/agent")
	return addr
end

local function enqueue(agent, ... )
	-- body
	leisure_agent:enqueue(agent)
end

local function dequeue( ... )
	-- body
	if #leisure_agent > 0 then
		return leisure_agent:dequeue()
	else
		return new_agent()
	end
end

local CMD = {}

function CMD.start(channel_id, init_agent_num, ... )
	-- body
	assert(init_agent_num > 1)
	for _=1,init_agent_num do
		local agent = new_agent()
		enqueue(agent)
	end
	channel = assert(channel_id)
	return true
end

function CMD.init_data()
	-- body
end

function CMD.save_data()
	-- body
	for _,v in pairs(users) do
		local ok = skynet.call(v.agent, "lua", "save_data")
		if not ok then
			log.error("call save_data failed.")
		end
	end
	return NORET
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.enter(uid)
	-- body
	assert(uid)
	local u = users[uid]
	assert(not u)
	if u and u.addr then
		if u.cancel then
			u.cancel()
		end
		local ok = skynet.call(u.addr, "lua", "start", false )
		assert(ok)
		return u.addr
	else
		local addr = cs(dequeue)
		local ok = skynet.call(addr, "lua", "start", true, channel)
		assert(ok)
		users[uid] = { uid = uid, addr = addr, cancel = nil }
		return addr
	end
end

-- 次方法实现有问题，暂时不理
function CMD.exit(uid)
	-- body
	assert(uid)
	local u = users[uid]
	if u then
		local cancel = util.set_timeout(100 * 60 * 60, function ( ... )
			-- body
			cs(enqueue, u.addr)
			users[uid] = nil		
		end)
		u.cancel = cancel
		return true
	end
	return false
end

function CMD.exit_at_once(uid, ... )
	-- body
	local u = users[uid]
	assert(u)
	cs(enqueue, u.addr)
	users[uid] = nil
	return true
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, cmd, ...)
		local f = CMD[cmd]
		local r = f( ... )
		if r ~= NORET then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".AGENT_MGR"
end)

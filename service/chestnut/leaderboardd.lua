local skynet = require "skynet"
local log = require "log"
local service = require "service"
local assert = assert

local users = {}
local ld 

local function comp(_1, _2, ... )
	-- body
	if _1.key > _2.key then
		return 1
	elseif _1.key == _2.key then
		return 0
	elseif _1.key == _2.key then
		return -1
	end
end

local function comp_u(u1, u2, ... )
	-- body
	return comp(u1.key, u2.key)
end

local CMD = {}

function CMD.start(channel_id, init_agent_num)
	-- body
	assert(init_agent_num > 1)
	for _=1,init_agent_num do
		local agent = {}
		local addr = skynet.newservice("chestnut/agent")
		agent.addr = addr
		enqueue(agent)
	end
	for _,v in pairs(leisure_agent) do
		local ok = skynet.call(v.addr, "lua", "start", channel_id)
		assert(ok)
	end
	return true
end

function CMD.init_data()
	-- body
	return true
end

function CMD.sayhi()
	-- body
end

function CMD.save_data()
	-- body
end

function CMD.close()
	-- body
	-- 存在线数据
	for _,v in pairs(users) do
		skynet.call(v.addr, 'lua', 'close')
	end
	return true
end

function CMD.kill()
	-- body
	skynet.exit()
end

-- 访问数据
function CMD.login(uid, agent, key, ... )
	-- body
	local u = users[uid]
	if u then
		u.agent = agent
		u.key = key
	else
		u = {
			uid = uid,
			agent = agent,
			key = key
		}
		users[uid] = u
		ld:push(u)
	end
end

function CMD.push(uid, key)
	-- body
	local u = users[uid]
	if u then
		u.key = key
	else
		assert(false)
	end
	ld:sort()
	return ld:bsearch(u)
end

function CMD.bsearch(uid, ... )
	-- body
	local u = users[uid]
	return ld:bsearch(u)
end

function CMD.range(start, stop)
	-- body
	return ld:range(start, stop)
end

function CMD.nearby(rank)
	-- body
	return ld:nearby(rank)
end

service.init {
	name = '.LEADERBOARD',
	command = CMD
}

local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"

local CMD = {}

------------------------------------------
-- 服务事件
function CMD:start(channel_id)
	-- body
	return self:start(channel_id)
end

function CMD:init_data()
	-- body
	return self:init_data()
end

function CMD:sayhi(host)
	-- body
	return self:sayhi(host)
end

function CMD:save_data()
	-- body
	self:save_data()
end

function CMD:close()
	-- body
	-- will be kill
	return self:close()
end

function CMD:kill()
	-- body
	assert(self)
	skynet.exit()
end

-- end
------------------------------------------

------------------------------------------
-- 房间协议
-- call by room_mgr
function CMD:create(uid, args)
	-- body
	return self:create(uid, args)
end

-- call by agent
function CMD:on_join(agent)
	-- body
	local res = self:join(agent.uid, agent.agent, agent.name, agent.sex)
	return res
end

-- call by agent
function CMD:join(args)
	-- body
	assert(self)
	assert(args.errorcode == 0)
	return servicecode.NORET
end

-- call by agent
function CMD:on_rejoin(args)
	-- body
	return self:rejoin(args.uid, args.agent)
end

-- call by agent
function CMD:rejoin(args)
	-- body
	assert(self)
	assert(args.errorcode == 0)
	return servicecode.NORET
end

-- call by agent
function CMD:on_leave(uid)
	-- body
	return self:leave(uid)
end

-- call by agent
function CMD:leave(args)
	-- body
	assert(self)
	assert(args.servicecode == servicecode.SUCCESS)
	return servicecode.NORET
end

-- call by agent
function CMD:afk(uid)
	-- body
	return self:afk(uid)
end

-- call by room_mgr
function CMD:recycle(args)
	-- body
	return self:recycle(args)
end

-- 结束协议
------------------------------------------


------------------------------------------
-- 大佬2请求协议
function CMD:on_ready(args)
	-- body
	return self:ready(args.idx)
end

function CMD:on_lead(args)
	-- body
	return self:lead(args.idx, args.card, args.isHoldcard)
end

function CMD:on_call(args)
	-- body
	return self:call(args.op)
end

function CMD:on_step(args)
	-- body
	local ok, res = xpcall(self.step, debug.msgh, self, args.idx)
	if not ok then
		log.error(res)
		local res = {}
		res.servicecode = servicecode.SERVER_ERROR
		return res
	else
		return res
	end
end

function CMD:on_restart(args)
	-- body
	self:restart(args.idx)
	local res = {}
	res.servicecode = servicecode.SUCCESS
	return res
end

-- 结束协议
------------------------------------------

------------------------------------------
-- 大佬2响应协议
function CMD:take_turn(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:call(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:shuffle(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:lead(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:deal(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:ready(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:over(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:restart(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:take_restart(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:settle(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:final_settle(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

function CMD:roomover(args)
	-- body
	assert(self and args)
	return servicecode.NORET
end

-- 大佬2响应协议over
------------------------------------------


return CMD
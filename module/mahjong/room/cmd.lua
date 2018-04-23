local skynet = require "skynet"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"
local context = require "rcontext"

local CMD = {}

function CMD:start(channel_id, uid, args)
	-- body
	local channel = mc.new {
		channel = channel_id,
		dispatch = function (_, _, cmd, ...)
			-- body
			local f = assert(CMD[cmd])
			local r = f( ... )
			if r ~= servicecode.NORET then
				-- if r ~= nil then
				-- 	skynet.retpack(r)
				-- else
					log.error("subscribe cmd = %s not return", cmd)
				-- end
			end
		end
	}
	channel:subscribe()
	return self:start(uid, args)
end

function CMD:init_data()
	-- body
	return self:init_data()
end

function CMD:save_data( ... )
	-- body
end

function CMD:close( ... )
	-- body
	-- will be kill
	return self:close()
end

function CMD:kill( ... )
	-- body
	skynet.exit()
end

function CMD:afk(uid)
	-- body
	return self:afk(uid)
end

function CMD:on_join(agent, ... )
	-- body
	local res = self:join(agent.uid, agent.agent, agent.name, agent.sex)
	return res
end

function CMD:join(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return errorcode.NORET
end

function CMD:on_rejoin(uid)
	-- body

end

function CMD:on_leave(args, ... )
	-- body
	return self:leave(args.idx)
end

function CMD:leave(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function CMD:on_ready(args, ... )
	-- body
	return self:ready(args.idx)
end

function CMD:ready(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:take_turn(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:peng(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:gang(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:hu(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:call(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:shuffle(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:dice(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:lead(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:deal(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:over(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:restart(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:take_restart(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:rchat(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:take_xuanpao(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:xuanpao( ... )
	-- body
	return errorcode.NORET
end

function CMD:take_xuanque(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:xuanque(args, ... )
	-- body
	return errorcode.NORET
end

function CMD:settle( ... )
	-- body
	return errorcode.NORET
end

function CMD:final_settle( ... )
	-- body
	return errorcode.NORET
end

function CMD:roomover( ... )
	-- body
	return errorcode.NORET
end

function CMD:on_lead(args, ... )
	-- body
	return self:lead(args.idx, args.card, args.isHoldcard)
end

function CMD:on_call(args, ... )
	-- body
	return self:call(args.op)
end

function CMD:on_step(args, ... )
	-- body
	local ok, res = xpcall(context.step, debug.msgh, self, args.idx)
	if not ok then
		log.error(res)
		local res = {}
		res.errorcode = errorcode.SERVER_ERROR
		return res
	else
		return res
	end
end

function CMD:on_restart(args, ... )
	-- body
	self:restart(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_rchat(args, ... )
	-- body
	self:chat(args)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_xuanpao(args, ... )
	-- body
	return self:xuanpao(args)
end

function CMD:on_xuanque(args, ... )
	-- body
	return self:xuanque(args)
end

return CMD
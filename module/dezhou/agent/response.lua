local skynet = require "skynet"

local RESPONSE = {}

function RESPONSE:handshake(args)
	-- body
	assert(self)
	assert(args.errorcode == 0)
end

function RESPONSE:join(args)
	-- body
	assert(self)
	local room = self:get_room()
	skynet.send(room, "lua", "join", args)
end

function RESPONSE:leave(args, ... )
	-- body
	assert(self)
end

------------------------------------------
-- 麻将响应模块
function RESPONSE:take_turn(args)
	-- body
	self.systems.room:forward_room_rsp("take_turn", args)
end

function RESPONSE:deal(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("deal", args, ...)
end

function RESPONSE:ready(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("ready", args, ...)
end

function RESPONSE:peng(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("peng", self, args, ...)
end

function RESPONSE:gang(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("gang", args, ...)
end

function RESPONSE:hu(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("hu", args, ...)
end

function RESPONSE:call(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("call", args, ...)
end

function RESPONSE:shuffle(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("shuffle", args, ...)
end

function RESPONSE:dice(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("dice", args, ...)
end

function RESPONSE:lead(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("lead", args, ...)
end


function RESPONSE:over(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("over", args)
end

function RESPONSE:restart(args, ... )
	-- body
end

function RESPONSE:rchat(args, ... )
	-- body
end

function RESPONSE:take_restart(args, ... )
		-- body
end	

function RESPONSE:take_xuanpao(args, ... )
	-- body
end

function RESPONSE:take_xuanque(args, ... )
	-- body
end

function RESPONSE:xuanque(args, ... )
	-- body
end

function RESPONSE:xuanpao(args, ... )
	-- body
end

function RESPONSE:settle(args, ... )
	-- body
end

function RESPONSE:final_settle(args, ... )
	-- body
end

function RESPONSE:roomover(args, ... )
	-- body
end

-- 麻将响应模块over
------------------------------------------

------------------------------------------
-- 大佬2响应模块

function RESPONSE:big2take_turn(args)
	-- body
	self.systems.room:forward_room_rsp("take_turn", args)
end

function RESPONSE:big2shuffle(args)
	-- body
	self.systems.room:forward_room_rsp("shuffle", args)
end

function RESPONSE:big2lead(args)
	-- body
	self.systems.room:forward_room_rsp("lead", args)
end

function RESPONSE:big2deal(args)
	-- body
	self.systems.room:forward_room_rsp("deal", args)
end

function RESPONSE:big2ready(args)
	-- body
	self.systems.room:forward_room_rsp("ready", args)
end

function RESPONSE:big2over(args)
	-- body
	self.systems.room:forward_room_rsp("over", args)
end

function RESPONSE:big2restart(args)
	-- body
	self.systems.room:forward_room_rsp("restart", args)
end

function RESPONSE:big2settle(args)
	-- body
	self.systems.room:forward_room_rsp("settle", args)
end

function RESPONSE:big2final_settle(args)
	-- body
	self.systems.room:forward_room_rsp("final_settle", args)
end

function RESPONSE:big2match(args)
	-- body
	assert(self)
	assert(args)
	-- self.systems.room:forward_room_rsp("match", args)
end

function RESPONSE:big2rejoin(args)
	-- body
	self.systems.room:forward_room_rsp("rejoin", args)
end

function RESPONSE:big2join(args)
	-- body
	self.systems.room:forward_room_rsp("join", args)
end

function RESPONSE:big2leave(args)
	-- body
	self.systems.room:forward_room_rsp("leave", args)
end

function RESPONSE:big2take_ready(args)
	-- body
	self.systems.room:forward_room_rsp("take_ready", args)
end

-- 大佬2响应模块
------------------------------------------

return RESPONSE
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
end

-----------------------forward room ----------------------------------
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

function RESPONSE:take_turn(args, ... )
	-- body
	local M = self.modules['room']
	M:forward_room_rsp("take_turn", args, ...)
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

return RESPONSE
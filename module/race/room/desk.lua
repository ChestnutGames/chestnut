 local skynet = require "skynet"

local cls = class("desk")

cls.state = {
	READY = 0,
	BET   = 1,
	RACE  = 2,
	SETTLE = 3,
}

function cls:ctor(ctx, id, ... )
	-- body
	self._ctx = ctx
	self._id = id
	self._state = cls.state.READY
	self._horses = {}
	local horse_mgr = self._ctx:get_horse_mgr()
	for i=1,5 do
		local h = horse_mgr:create_horse()
		table.insert(self._horses, h)
	end
	self._racelen = 1000
	
	return self
end

function cls:start( ... )
	-- body
end

function cls:update(delta, ... )
	-- body
	if self._state == cls.state.RACE then
	end
end

function cls:add_horse(obj, ... )
	-- body
	assert(obj)
	self._horses[obj:get_idx()] = obj
end

function cls:enter_state(state, ... )
	-- body
	local old = self._state
	if old == state then
		return
	else
		if state == cls.state.BET then
		elseif state == cls.state.RACE then

		end
	end
end

function cls:leave_state(state, ... )
	-- body

end



return cls
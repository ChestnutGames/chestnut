local queue = require "queue"
local horse = require "room.horse"
local cls = class("horse_mgr")

function cls:ctor( ... )
	-- body
	self._idx  = 1
	self._pool = queue()
	return self
end

function cls:create_horse( ... )
	-- body
	if #self._pool > 0 then
		local obj = self._pool:dequeue()
		return obj
	else
		local obj = horse.new(self._idx)
		self._idx = self._idx + 1
		return obj
	end
end

function cls:release_horse(obj, ... )
	-- body
	self._pool:enqueue(obj)
end

return cls
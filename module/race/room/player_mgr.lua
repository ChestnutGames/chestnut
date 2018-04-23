
local queue = require "queue"
local player = require "room.player"
local cls = class("player_mgr")

function cls:ctor( ... )
	-- body
	self._idx = 1
	self._pool = queue()
	return self
end

function cls:create_player( ... )
	-- body
	if #self._pool > 0 then
		local obj = self._pool:dequeue()
		return obj
	else
		local obj = player.new(self._idx)
		self._idx = self._idx + 1
		return obj
	end
end

function cls:release_player(obj, ... )
	-- body
	self._pool:enqueue(obj)
end

return cls
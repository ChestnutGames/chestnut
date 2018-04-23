local player = require "room.player"
local horseattr = require "configs.horse"
local assert = assert

local cls = class("horse")

function cls:ctor(id, ... )
	-- body
	assert(id)
	self._id = id
	self._pos = 0
	self._bet = {}
	self._attr = {}
	for k,_ in pairs(horseattr) do
		self._attr[k] = 0
	end
end

function cls:update( ... )
	-- body

end

function cls:get_pos( ... )
	-- body
	return self._pos
end

function cls:buy(obj, bet, ... )
	-- body
	if self._bet[obj] ~= nil then
		local b = self._bet[obj]
		b = b + bet
		self._bet[obj] = b
	else
		self._bet[obj] = bet
	end
end

function cls:ready( ... )
	-- body
	self._val = 12
	self._pos = 0
end

return cls

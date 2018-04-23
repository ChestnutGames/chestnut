local skynet = require "skynet"
local log = require "skynet.log"

local cls = class("player")

function cls:ctor(idx, ... )
	-- body
	assert(idx)
	self._idx = idx
	self._uid = nil
	self._agent = nil
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:set_uid(value, ... )
	-- body
	self._uid = value
end

function cls:get_agent( ... )
	-- body
	return self._agent
end

function cls:set_agent(value, ... )
	-- body
	self._agent = value
end

return cls
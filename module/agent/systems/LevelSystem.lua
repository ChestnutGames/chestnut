-- local log = require "chestnut.skynet.log"
local UserComponent = require "components.UserComponent"

local cls = class('level')

function cls:ctor(context)
	-- body
	self.agentContext = context
	self.agentSystems = nil
	self.context = nil
end

function cls:_get_my_entity()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	return entity
end

function cls:set_context(context)
	-- body
	self.context = context
end

function cls:set_agent_systems(systems)
	-- body
	self.agentSystems = systems
end

function cls:on_data_init()
	-- body
	assert(self)
end

function cls:addExp(exp)
	-- body
	assert(self)
	assert(exp)
end

return cls
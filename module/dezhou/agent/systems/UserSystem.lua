local log = require "chestnut.skynet.log"
local UserComponent = require "components.UserComponent"

local CLS_NAME = "user"

local cls = class(CLS_NAME)

function cls:ctor(context)
	-- body
	self.agentContext = context
	self.agentSystems = nil
	self.context = nil
	self.entity = nil
end

function cls:_get_my_entity()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	return entity
end

function cls:set_context(context, ... )
	-- body
	self.context = context
end

function cls:set_agent_systems(systems, ... )
	-- body
	self.agentSystems = systems
end

function cls:on_data_init()
	-- body
	assert(self)
end

function cls:first()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)

	local res = {}
	res.errorcode = 0
	res.nickname  = assert(entity.user.nickname)
	return res
end

return cls
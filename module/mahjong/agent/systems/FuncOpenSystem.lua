local log = require "chestnut.skynet.log"
local UserComponent = require "components.UserComponent"

local CLS_NAME = "func_open"

local cls = class(CLS_NAME)

function cls:ctor(context, ... )
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

function cls:user_born( ... )
	-- body
	self.agentSystems.package:on_func_open()
end

function cls:on_func_open( ... )
	-- body
end

return cls
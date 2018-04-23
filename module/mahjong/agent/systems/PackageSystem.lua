local log = require "chestnut.skynet.log"
local errorcode = require "errorcode"
local UserComponent = require "components.UserComponent"
local PackageType = require "def.PackageType"

local CLS_NAME = "package"

local cls = class(CLS_NAME)

function cls:ctor(context, ... )
	-- body
	self.agentContext = context
	self.agentSystems = nil
	self.context = nil
end

function cls:_get_my_entity( ... )
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	return entity
end

function cls:_increase(pt, id, num)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = assert(entity.package.packages[pt])
	if not package[id] then
		package[id] = { id = id, num = 0 }
	end
	package[id].num = package[id].num + num
end

function cls:_decrease(pt, id, num)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = assert(entity.package.packages[pt])
	if not package[id] then
		package[id] = { id = id, num = 0 }
	end
	package[id].num = package[id].num - num
	assert(package[id] >= 0)
	return true
end

function cls:set_context(context, ... )
	-- body
	self.context = context
end

function cls:set_agent_systems(systems, ... )
	-- body
	self.agentSystems = systems
end

function cls:on_func_open( ... )
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	entity.package.packages = {}
	entity.package.packages[PackageType.COMMON] = {}
	entity.package.packages[PackageType.COMMON][4] = { id = 4, num = 13 }
end

function cls:check_consume_rcard(value)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = entity.package.packages[PackageType.COMMON]
	assert(package)
	local item = package[4]
	if item.num < value then
		return false
	end
	return true
end

function cls:consume_rcard(value)
	-- body
	if not self:check_consume_rcard(value) then
		return false
	end
	return self:_decrease(PackageType.COMMON, 4, value)
end

function cls:rcard_num()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = entity.package.packages[PackageType.COMMON]
	assert(package)
	local item = package[4]
	if not item then
		item = { id = 4, num = 0 }
		package[4] = item
	end
	return item.num
end


return cls
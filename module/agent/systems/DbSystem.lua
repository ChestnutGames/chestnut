local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local UserComponent = require "components.UserComponent"
local unpack_components = require "db.unpack_components"
local pack_components = require "db.pack_components"
local assert = assert

local cls = class("db")

function cls:ctor(context)
	-- body
	self.agentContext = assert(context)
	self.context = nil
	self.agentSystems = nil
	return self
end

function cls:set_agent_systems(agentSystems)
	-- body
	self.agentSystems = agentSystems
end

function cls:set_context(context)
	-- body
	self.context = context
end

function cls:load_cache_to_data()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	log.info("uid(%d) load_cache_to_data", uid)
	local res = skynet.call(".DB", "lua", "read_user", uid)
	unpack_components.unpack_user_component(entity.user, res.db_users[1])
	unpack_components.unpack_package_component(entity.package, res.db_user_package)
	unpack_components.unpack_funcopen_component(entity.funcopen, res.db_user_funcopen)
	return true
end

function cls:save_user(uid, entity)
	-- body
	assert(self)
	assert(uid and entity)
	local data = {}
	data.db_user = pack_components.pack_user_component(entity.user)
	data.db_user_package = pack_components.pack_package_component(entity.package, uid)
	data.db_user_funcopen = pack_components.pack_funcopen_component(entity.funcopen, uid)
	skynet.call(".DB", "lua", "write_user", data)
	return true
end

function cls:save_data_to_cache()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	assert(self:save_user(uid, entity))
	return true
end

return cls
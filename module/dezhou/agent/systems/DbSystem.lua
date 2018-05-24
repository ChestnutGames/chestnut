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
	return self
end

function cls:_on_user_born()
	-- body
	self.agentSystems.func_open:user_born()
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
	if #res.db_user_rooms == 1 then
		unpack_components.unpack_room_component(entity.room, res.db_user_rooms[1])
	end
	return true
end

function cls:save_user(uid, entity)
	-- body
	assert(self)
	assert(uid and entity)
	local data = {}
	local ok, seg
	ok, seg = pack_components.pack_user_component(entity.user)
	if ok then
		data.db_user = seg
	else
		log.error("pack_user_component failtrue.")
		return false
	end
	ok, seg = pack_components.pack_room_component(entity.room, uid)
	if ok then
		data.db_user_room = seg
	else
		log.error("pack_room_component failtrue.")
		return false
	end
	-- ok, seg = pack_components.pack_package_component(entity.package)
	-- if ok then
	-- 	data.package = seg
	-- else
	-- 	log.error("pack_package_component failtrue.")
	-- 	return false
	-- end
	skynet.call(".DB", "lua", "write_user", data)
	return true
end

function cls:save_data_to_cache()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	-- assert(self:save_account(uid, entity))
	assert(self:save_user(uid, entity))
	return true
end

return cls
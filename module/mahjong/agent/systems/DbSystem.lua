local util = require "chestnut.time"
local redis = require "chestnut.redis"
local log = require "chestnut.skynet.log"
local json = require "rapidjson"
local UserComponent = require "components.UserComponent"
local unpack_components = require "db.unpack_components"
local pack_components = require "db.pack_components"
local assert = assert

local cls = class("db")

function cls:ctor(context, ... )
	-- body
	self.agentContext = assert(context)
	self.agentSystems = nil
	self.context = nil
	return self
end

function cls:_on_user_born( ... )
	-- body
	self.agentSystems.func_open:user_born()
end

function cls:set_context(context, ... )
	-- body
	self.context = context
end

function cls:set_agent_systems(systems, ... )
	-- body
	self.agentSystems = systems
end

function cls:load_account(uid, entity, ... )
	-- body
	assert(uid and entity)
	local val = redis:get(string.format("tb_account:%d", uid))
	if type(val) ~= "string" then
		log.error("val is not string.")
		return false
	end
	if #val <= 0 then
		log.error("length of val less than 0.")
		return false
	end
	local data = json.decode(val)
	if not data then
		log.error("decode failtrue.")
		return false
	end
	if not unpack_components.unpack_account_component(entity.account, data) then
		log.error("unpack_user_component failtrue.")
		return false
	end
	return true
end

function cls:load_user(uid, entity)
	-- body
	assert(uid and entity)
	local val = redis:get(string.format("tb_user:%d", uid))
	if type(val) ~= "string" then
		log.error("val is not string.")
		return false
	end
	if #val <= 0 then
		log.error("length of val less than 0.")
		return false
	end
	log.info(val)
	local data = json.decode(val)
	if not data then
		log.error("load_cache_to_data failtrue.")
		return true
	end
	if data.user then
		if not unpack_components.unpack_user_component(entity.user, data.user) then
			log.error("unpack_user_component failtrue.")
			return false
		end
	end
	if data.package then
		if not unpack_components.unpack_package_component(entity.package, data.package) then
			log.error("unpack_package_component failtrue")
			return false
		end
	end
	if data.room then
		if not unpack_components.unpack_room_component(entity.room, data.room) then
			log.error("unpack_room_component failtrue.")
			return false
		end
		assert(entity.room.isCreated ~= nil)
		assert(entity.room.joined ~= nil)
		assert(entity.room.id ~= nil)
	else
		log.info("uid(%d) load_user room is nil", uid)
	end
	return true
end

function cls:load_cache_to_data( ... )
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	log.info("uid(%d) load_cache_to_data", uid)
	assert(self:load_account(uid, entity))
	if entity.account.login_times == 0 then
		entity.account.login_times = entity.account.login_times + 1
		self:_on_user_born()
		return true
	else
		entity.account.login_times = entity.account.login_times + 1
	end
	assert(self:load_user(uid, entity))
	return true
end

function cls:save_account(uid, entity)
	-- body
	assert(uid and entity)
	local ok, seg = pack_components.pack_account_component(entity.account)
	if ok then
		local val = json.encode(seg)
		-- log.info("save_account [%s]", val)
		redis:set(string.format("tb_account:%d", uid), val)
	else
		log.error("pack_account_component failtrue.")
		return false
	end
	return true
end

function cls:save_user(uid, entity)
	-- body
	assert(uid and entity)
	local data = {}
	local ok, seg
	ok, seg = pack_components.pack_user_component(entity.user)
	if ok then
		data.user = seg
	else
		log.error("pack_user_component failtrue.")
		return false
	end
	ok, seg = pack_components.pack_room_component(entity.room)
	if ok then
		data.room = seg
	else
		log.error("pack_room_component failtrue.")
		return false
	end
	ok, seg = pack_components.pack_package_component(entity.package)
	if ok then
		data.package = seg
	else
		log.error("pack_package_component failtrue.")
		return false
	end
	redis:set(string.format("tb_user:%d", uid), json.encode(data))
	return true
end

function cls:save_data_to_cache()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	assert(self:save_account(uid, entity))
	assert(self:save_user(uid, entity))
	return true
end

return cls
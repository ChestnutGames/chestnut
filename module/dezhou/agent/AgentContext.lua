-- local skynet = require "skynet"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local context = require "chestnut.context"
local servicecode = require "chestnut.servicecode"
local AgentSystems = require "AgentSystems"
local EntitasContext = require "entitas.Context"
local Matcher = require "entitas.Matcher"
local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"
local RoomComponent = require "components.RoomComponent"
local UserComponent = require "components.UserComponent"
local DbComponent = require "components.DbComponent"
local AccountComponent = require "components.AccountComponent"
local InboxComponent = require "components.InboxComponent"
local OutboxComponent = require "components.OutboxComponent"
local PackageComponent = require "components.PackageComponent"
local CMD = require "cmd"
local assert = assert

local cls = class("AgentContext", context)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self, ...)
	self.context = EntitasContext.new()
	self.systems = AgentSystems.new(self)
	self.systems:set_context(self.context)
	self.systems:set_agent_systems(self.systems)
	local userGroup = self.context:get_group(Matcher({ UserComponent }))
	local uid_primary_index = PrimaryEntityIndex.new(UserComponent, userGroup, 'uid')
	self.context:add_entity_index(uid_primary_index)
	self.reload = false
	self.initdataed = false
	self.channel = nil
	self.channelSubscribed = false
	return self
end

function cls:start(reload, channel_id, ... )
	-- body
	if not cls.super.start(self, reload, channel_id, ... ) then
		return false
	end
	self.reload = reload
	if self.reload then
		-- subscribe channel
		local channel = mc.new {
		channel = channel_id,
		dispatch = function (_, source, cmd, ...)
			-- body
				local f = assert(CMD[cmd])
				local ok, err = pcall(f, self, source, ... )
				if not ok then
					log.error("subscribe cmd = %s, error =[%s]", cmd, err)
				end
			end
		}
		channel:subscribe()
		self.channelSubscribed = true
		self.channel = channel
	end
	return true
end

function cls:init_data(uid)
	-- body
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if not entity then
		-- 加入所有的组件
		entity = self.context:create_entity()
		entity:add(AccountComponent, uid)
		entity:add(UserComponent, uid)
		entity:add(DbComponent)
		entity:add(InboxComponent)
		entity:add(OutboxComponent)
		entity:add(PackageComponent, {})
		entity:add(RoomComponent, 0, 0, false, false, false)
	end

	local ok, err = pcall(self.systems.db.load_cache_to_data, self.systems.db)
	if not ok then
		log.error(err)
		return servicecode.LOGIN_AGENT_LOAD_ERR
	end
	self.initdataed = true
end

function cls:save_data()
	-- body
	if self.logined and self.initdataed then
		local ok, err = pcall(self.systems.db.save_data_to_cache, self.systems.db)
		if not ok then
			log.error(err)
		end
	end
	return servicecode.NORET
end

function cls:close( ... )
	-- body
	return cls.super.close(self, ... )
end

function cls:login(gate, uid, subid, secret)
	local ok = cls.super.login(self, gate, uid, subid, secret)
	if not ok then
		return servicecode.FAIL
	end
	if self.reload then
		self:init_data(uid)
	end
	return servicecode.SUCCESS
end

function cls:logout( ... )
	-- body
	self.initdataed = false
	if self.channelSubscribed then
		self.channelSubscribed = false
		self.channel:unsubscribe()
	end
	self:save_data()
	return cls.super.logout(self, ... )
end

function cls:auth(args)
	-- body
	if not self.channelSubscribed then
		self.channelSubscribed = true
		self.channel:subscribe()
	end
	return cls.super.auth(self, args)
end

function cls:afk()
	-- body
	log.info("uid(%d) systems begin-------------------------------------afk", self.uid)
	local traceback = debug.traceback
	local ok, err = xpcall(self.systems.afk, traceback, self.systems)
	if not ok then
		log.error(err)
	end
	log.info("uid(%d) systems end-------------------------------------afk", self.uid)
	if self.channelSubscribed then
		self.channelSubscribed = false
		self.channel:unsubscribe()
	end
	self:save_data()
	return cls.super.afk(self)
end

function cls:inituser()
	-- body
	local res = {}
	if not cls.super.inituser(self) then
		res.errorcode = 1
		return res
	end
	local ok, err = pcall(self.systems.initialize, self.systems)
	if not ok then
		log.error(err)
		res.errorcode = 1
		return res
	end
	log.info("uid(%d) inituser success.", self.uid)
	res.errorcode = 0
	return res
end

return cls
local skynet = require "skynet"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local context = require "chestnut.context"
local servicecode = require "chestnut.servicecode"
local AgentSystems = require "AgentSystems"
local EntitasContext = require "entitas.Context"
local Matcher = require "entitas.Matcher"
local PrimaryEntityIndex = require "entitas.PrimaryEntityIndex"

local CMD = require "cmd"
local assert = assert
local traceback = debug.traceback

local cls = class("AgentContext", context)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self, ...)
	self.systems = AgentSystems.new(self)
	self.systems:set_agent_systems(self.systems)
	self.reload = false
	self.channel = nil
	self.channelSubscribed = false
	return self
end

function cls:start(channel_id, ... )
	-- body
	if not cls.super.start(self, channel_id, ... ) then
		return false
	end
	-- subscribe channel
	local channel = mc.new {
		channel = channel_id,
		dispatch = function (_, _, cmd, ...)
			-- body
			local f = assert(CMD[cmd])
			local ok, err = pcall(f, self, ... )
			if not ok then
				log.error("subscribe cmd = %s, error =[%s]", cmd, err)
			end
		end
	}
	-- channel:subscribe()
	-- self.channelSubscribed = true
	self.channel = channel
	return true
end

function cls:sayhi(reload)
	-- body
	self.reload = reload
	return true
end

function cls:init_data(uid)
	-- body
	local uid = self.uid
	log.info("uid(%d) load_cache_to_data", uid)
	local res = skynet.call(".DB", "lua", "read_user", uid)
	-- init user
	local ok, err = xpcall(self.systems.on_data_init, traceback, self.systems, res)
	if not ok then
		log.error(err)
		return servicecode.LOGIN_AGENT_LOAD_ERR
	end
	local ok, err = xpcall(self.systems.initialize, traceback, self.systems, res)
	if not ok then
		log.error(err)
		return servicecode.LOGIN_AGENT_LOAD_ERR
	end
	return servicecode.SUCCESS
end

function cls:save_data()
	-- body
	local data = {}
	local ok, err = xpcall(self.systems.on_data_save, traceback, self.systems, data)
	if not ok then
		log.error(err)
	else
		skynet.call(".DB", "lua", "write_user", data)
	end
	return servicecode.NORET
end

function cls:close( ... )
	-- body
	self:save_data()
	return cls.super.close(self, ... )
end

function cls:login(gate, uid, subid, secret)
	local ok = cls.super.login(self, gate, uid, subid, secret)
	if not ok then
		return servicecode.FAIL
	end
	if self.logined and self.reload then
		self:init_data(uid)
	end
	return servicecode.SUCCESS
end

function cls:logout( ... )
	-- body
	if self.logined then
		if self.authed then
			self:afk()
		end
		return cls.super.logout(self, ... )
	else
		return servicecode.FAIL
	end
end

function cls:auth(args)
	-- body
	if not self.channelSubscribed then
		log.info("uid(%d) subscribe channel_id", self.uid)
		self.channelSubscribed = true
		self.channel:subscribe()
	end
	return cls.super.auth(self, args)
end

function cls:afk()
	-- body
	if self.authed then
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
	else
		return servicecode.NOT_AUTHED
	end
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
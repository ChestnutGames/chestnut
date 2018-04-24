local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local errorcode = require "errorcode"
local RoomComponent = require "components.RoomComponent"
local UserComponent = require "components.UserComponent"

local cls = class("room")

function cls:ctor(context, ... )
	-- body
	self.agentContext = context
	self.agentSystems = nil
	self.context = nil
	return self
end

function cls:set_agent_systems(systems, ... )
	-- body
	self.agentSystems = systems
end

function cls:set_context(context, ... )
	-- body
	self.context = context
end

function cls:initialize()
	-- body
	if false then
		local uid  = self.agentContext.uid
		local index = self.context:get_entity_index(UserComponent)
		local entity = index:get_entity(uid)
		if entity.room.joined then
			local res = skynet.call(".ROOM_MGR", "lua", "apply", entity.room.id)
			if res.errorcode ~= 0 then
				return res
			else
				entity.room.addr = res.addr
				local ok = skynet.call(entity.room.addr, "lua", "auth", uid)
				if not ok then
					log.error("auth not ")
				end
			end
		end
	end
	return true
end

function cls:afk( ... )
	-- body
	local uid     = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if entity.room.joined then
		local ok = skynet.call(entity.room.addr, "lua", "on_leave", uid)
		assert(ok)
		entity.room.online = false
		entity.room.addr = 0
	end
end

function cls:on_func_open( ... )
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	entity.room.isCreated = false
	entity.room.id = 0
	entity.room.addr = 0
	entity.room.joined = false
	entity.room.play = false
end

function cls:room_info()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)

	log.info("room roomid = %d", entity.room.id)
	local res = {}
	res.errorcode = 0
	res.isCreated = entity.room.isCreated
	res.roomid    = entity.room.id
	return res
end

function cls:create(args)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)

	local room = entity:get(RoomComponent)
	if room.isCreated then
		local res = {}
		res.errorcode = 10
		return res
	end

	local agent = skynet.self()
	local res = skynet.call(".ROOM_MGR", "lua", "create", uid, agent, args)
	if res.errorcode == 0 then
		room.isCreated = true
		room.id        = res.roomid
	end
	return res
end

function cls:join(args)
	-- body
	local uid   = self.agentContext.uid
	local agent = skynet.self()
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)

	local xargs = {
		uid   = uid,
		agent = agent,
		name  = assert(entity.account.nickname),
		sex   = assert(entity.account.sex)
	}
	local res = skynet.call(".ROOM_MGR", "lua", "apply", args.roomid)
	if res.errorcode ~= 0 then
		return res
	else
		res = skynet.call(res.addr, "lua", "on_join", xargs)
		if res.errorcode == 0 then
			log.info("join room SUCCESS.")
			entity.room.addr = res.addr
			entity.room.joined = true
		else
			log.info('join room FAIL.')
		end
		return res
	end
end

function cls:leave(args, ... )
	-- body
	local res = {}
	if self.joined then
		res = skynet.call(addr, "lua", "on_leave", args)
		if res.errorcode == errorcode.SUCCESS then
			self.joined = false
		end
		return res
	else
		res.errorcode = errorcode.NOEXiST_ROOMID
		return res
	end
end

function cls:forward_room(name, args, ... )
	-- body
	if self.joined then
		local command = "on_"..name
		local addr = self.addr
		log.info("route request command %s agent to room", command)
		return skynet.call(addr, "lua", command, args)
	else
		local res = {}
		res.errorcode = errorcode.FAIL
		return res
	end
end

function cls:forward_room_rsp(name, args, ... )
	-- body
	if self.joined then
		local command = name
		local addr = self.addr
		log.info("route response command %s agent to room", command)
		skynet.send(addr, "lua", command, args)
	end
end

return cls
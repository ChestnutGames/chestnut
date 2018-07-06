local skynet = require "skynet"
local ds = require "skynet.datasheet"
local log = require "chestnut.skynet.log"
local RoomComponent = require "components.RoomComponent"
local UserComponent = require "components.UserComponent"

local cls = class("room")

function cls:ctor(context)
	-- body
	self.agentContext = context
	self.context = nil
	return self
end

function cls:set_context(context)
	-- body
	self.context = context
end

------------------------------------------
-- event
function cls:on_data_init()
	-- body
	assert(self)
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if (entity.room.createAt == nil) or
		entity.room.createAt == 0 then
		entity.room.isCreated = false
		entity.room.joined = false
		entity.room.id = 0
		entity.room.addr = 0
		entity.room.mode = 0                     -- 这个字段没有用
		entity.room.createAt = os.time()
		entity.room.updateAt = os.time()
	end
end

function cls:on_func_open()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	entity.room.isCreated = false
	entity.room.joined = false
	entity.room.id = 0
	entity.room.addr = 0
	entity.room.mode = 0                     -- 这个字段没有用
	entity.room.createAt = os.time()
	entity.room.updateAt = os.time()
end

function cls:afk()
	-- body
	log.info("RoomSystem call afk")
	local uid   = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if entity.room.joined then
		local ok = skynet.call(entity.room.addr, "lua", "on_afk", uid)
		assert(ok)
		entity.room.addr = 0
	end
end

function cls:initialize()
	-- body
	assert(self)
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
-- event
------------------------------------------


function cls:room_info()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)

	local res = {}
	res.errorcode = 0
	res.isCreated = entity.room.isCreated
	res.joined    = entity.room.joined
	res.roomid    = entity.room.id
	return res
end

function cls:match(args)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)

	local res = {}
	-- p匹配
	if entity.room.matching then
		res.errorcode = 18
		return res
	end
	if entity.room.joined then
		res.errorcode = 15
		return res
	end
	local agent = skynet.self()
	res = skynet.call(".ROOM_MGR", "lua", "match", uid, agent, args.mode)
	log.info('match %d', args.mode)
	if res.errorcode == 0 then
		entity.room.matching = false
	end
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
	if self.isCreated then
		if entity.room.id ~= args.roomid then
			return { errorcode = 1 }
		end
	end

	local xargs = {
		uid   = uid,
		agent = agent,
		name  = assert(entity.user.nickname),
		sex   = assert(entity.user.sex)
	}
	local res = skynet.call(".ROOM_MGR", "lua", "apply", args.roomid)
	if res.errorcode ~= 0 then
		return res
	else
		local response = skynet.call(res.addr, "lua", "on_join", xargs)
		if response.errorcode == 0 then
			log.info("join room SUCCESS.")
			entity.room.id = args.roomid
			entity.room.addr = res.addr
			entity.room.joined = true
			entity.room.online = true
			entity.room.mode = assert(response.mode)
		else
			log.info('join room FAIL.')
		end
		return response
	end
end

function cls:rejoin()
	-- body
	local uid   = self.agentContext.uid
	local agent = skynet.self()
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if not entity.room.joined then
		return { errorcode = 1 }
	end

	local xargs = {
		uid   = uid,
		agent = agent,
		name  = assert(entity.user.nickname),
		sex   = assert(entity.user.sex)
	}
	local res = skynet.call(".ROOM_MGR", "lua", "apply", entity.room.id)
	if res.errorcode ~= 0 then
		return res
	else
		local response = skynet.call(res.addr, "lua", "on_rejoin", xargs)
		if response.errorcode == 0 then
			entity.room.addr   = res.addr
			entity.room.joined = true
			entity.room.online = true
		else
			log.info('join room FAIL.')
		end
		return response
	end
end

-- called by room
-- called by client
function cls:leave()
	-- body
	log.info('RoomSystem leave')
	local uid   = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if entity.room.joined then
		local res = skynet.call(entity.room.addr, 'lua', 'on_leave', uid)
		log.info('call room leave')
		if res.errorcode == 0 then
			entity.room.isCreated = false
			entity.room.joined = false
			entity.room.id = 0
			entity.room.mode = 0
		else
			log.error('uid(%d) leave failture.', uid)
		end
	end
	return true
end

-- called by room
function cls:roomover()
	-- body
	local uid   = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	entity.room.roomid = 0
	entity.room.joined = false
	entity.room.isCreated = false
	return true
end

function cls:forward_room(name, args)
	-- body
	local uid   = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if entity.room.joined then
		local cmd = "on_"..name
		local addr = entity.room.addr
		log.info("route request command %s agent to room", cmd)
		return skynet.call(addr, "lua", cmd, args)
	else
		local res = {}
		res.errorcode = 15
		return res
	end
end

function cls:forward_room_rsp(name, args)
	-- body
	local uid   = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	if entity.room.joined then
		local cmd = name
		local addr = entity.room.addr
		log.info("route response command %s agent to room", cmd)
		skynet.send(addr, "lua", cmd, args)
	end
end

return cls
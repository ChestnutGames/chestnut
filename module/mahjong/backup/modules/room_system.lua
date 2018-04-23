local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local errorcode = require "errorcode"

local cls = class("room")

function cls:ctor(context, ... )
	-- body
	cls.super.ctor(self, context)
	
	self.isCreated = false  -- 是否创建了一个房间
	self.rule = 0           -- 此房间规则
	self.finishedJu = 0     -- 次房间已经完成的局数

	self.id = 0
	self.addr = 0
	self.joined = false
	return self
end

function cls:load_cache_to_data( ... )
	-- body
	-- TODO: 这里需要加载数据
end

function cls:login( ... )
	-- body
	-- 每次登陆需要重置一些数据
	self.id = 0
	self.addr = 0
	self.joined = false
end

function cls:logout( ... )
	-- body
	if self.joined then
		local uid = self.context.uid
		local subid = self.context.subid

		skynet.call(self.addr, "lua", "on_leave", uid, subid)
		self.joined = false
	end
end

function cls:auth(args, ... )
	-- body
	if self.joined then
		local uid     = self.context.uid
		local subid   = self.context.subid
		local fd      = assert(args.client)

		skynet.call(self.addr, "lua", "auth", uid, subid, fd)
	end
end

function cls:afk( ... )
	-- body
	if self.joined then
		local uid = self.context.uid
		local subid = self.context.subid		

		skynet.call(self.addr, "lua", "afk", uid, subid)		
	end
end

function cls:create(args, ... )
	-- body
	if self.joined then
		local res = {}
		res.errorcode = errorcode.FAIL
		return res
	end


	local uid = self.context.uid
	local agent = skynet.self()
	local res = skynet.call(".ROOM_MGR", "lua", "create", uid, agent, args)
	return res
end

function cls:join(args, ... )
	-- body
	local res = {}
	local uid = self.context.uid
	local subid = self.context.subid
	local agent = skynet.self()

	local user = self.context.modules['user']
	local name = assert(user.t.nickname)
	local sex  = user.t.sex
	local agent = {
		uid = uid,
		sid = subid,
		agent = agent,
		name = name,
		sex = sex
	}
	local addr = skynet.call(".ROOM_MGR", "lua", "apply", args.roomid)
	if addr == 0 then
		res.errorcode = errorcode.NOEXiST_ROOMID
		return res
	else
		local res = skynet.call(addr, "lua", "on_join", agent)
		if res.errorcode == errorcode.SUCCESS then
			self.addr = addr
			self.id = args.roomid
			self.joined = true
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
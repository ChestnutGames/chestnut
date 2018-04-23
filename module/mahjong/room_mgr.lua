package.path = "./module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local redis = require "chestnut.redis"
local AppConfig = require "AppConfig"
local json = require "rapidjson"

local channel_id
local NORET = {}
local users = {}   -- 玩家信息
local rooms = {}   -- 正在打牌的
local pool = {}    -- 闲置的桌子
local config
local MAX_ROOM_NUM = 4
local id = 1              -- [1, MAX_ROOM_NUM]
local num = 0      -- 正在打牌的桌子

-- @breif 生成房间id，
-- @return 0,成功, 13 超过最大房间数
local function next_id()
	-- body
	if num >= MAX_ROOM_NUM then
		return 13
	else
		while rooms[id] do
			id = id + 1
			if id > MAX_ROOM_NUM then
				id = 1
			end
		end
		return 0, id
	end
end

local CMD = {}

function CMD.start(chan_id)
	-- body
	if not config:LoadFile() then
		return false
	end
	if not config:CheckConfig() then
		return false
	end
	-- 初始一些配置
	MAX_ROOM_NUM = tonumber(config.config.consts[2]['Value'])
	assert(MAX_ROOM_NUM > 1)

	local channel = mc.new {
		channel = chan_id,
		dispatch = function (_, _, cmd, ...)
			-- body
			local f = assert(CMD[cmd])
			local r = f( ... )
			if r ~= NORET then
				if r ~= nil then
					skynet.retpack(r)
				else
					log.error("subscribe cmd = %s not return", cmd)
				end
			end
		end
	}
	channel:subscribe()
	channel_id = chan_id

	-- 初始所有桌子
	for i=1,MAX_ROOM_NUM do
		local addr = skynet.newservice("room/room", i)
		pool[i] = { id = i, addr = addr }
	end
	return true
end

function CMD.init_data()
	-- body
	local pack = redis:get("tb_room_mgr")
	if pack then
		log.info("pack = [%s]", pack)
		local data = json.decode(pack)
		for k,v in pairs(data.users) do
			local db_user = {}
			db_user.uid = assert(v.uid)
			db_user.roomid = assert(v.roomid)
			users[tonumber(k)] = db_user
		end
		for k,v in pairs(data.rooms) do
			local db_room = {}
			db_room.id = assert(v.id)
			db_room.host = assert(v.host)
			rooms[tonumber(k)] = db_room
		end
	end
	-- 打开所有房间
	for k,v in pairs(rooms) do
		local room = {}
		if pool[k] then
			room = pool[k]
			pool[k] = nil
		else
			local addr = skynet.newservice("room/room", k)
			room = { id = k, addr = addr }
		end
		assert(room.id == k)
		local ok = skynet.call(room.addr, "lua", "start", channel_id, v.host, v.rule)
		if not ok then
			log.error("start room id = %d failed.", k)
		else
			ok = skynet.call(room.addr, "lua", "init_data")
			assert(ok)
			v.id   = assert(room.id)
			v.addr = assert(room.addr)
			num = num + 1
			if k > id then
				id = k
			end
		end
	end
	return true
end

function CMD.sayhi()
	-- body
	return true
end

function CMD.save_data()
	-- body
	local db_users = {}
	local db_rooms = {}
	for k,v in pairs(users) do
		local db_user = {}
		db_user.uid = assert(v.uid)
		db_user.roomid = assert(v.roomid)
		db_users[string.format("%d", k)] = db_user
	end
	for k,v in pairs(rooms) do
		local db_room = {}
		db_room.id = assert(v.id)
		db_room.host = assert(v.host)
		db_rooms[string.format("%d", k)] = db_room
	end
	local data = {}
	data.users = db_users
	data.rooms = db_rooms
	local pack = json.encode(data)
	redis:set("tb_room_mgr", pack)
	return NORET
end

function CMD.close()
	-- body
	CMD.save_data()
	return true
end

function CMD.kill()
	-- body
	skynet.exit()
end

function CMD.checkin(uid, agent)
	-- body
end

function CMD.afk(uid, ... )
	-- body
	assert(users[uid])
	users[uid] = nil
end

function CMD.enqueue_agent(source, uid, rule, mode, scene, ... )
	-- body
	log.info("enqueue_agent")
	local rt = ((scene & 0xff << 16) | (mode & 0xff << 8) | (rule & 0xff))
	local agent = {
		agent = source,
		uid = uid,
		sid = sid,
		rt = rt,
		rule = rule,
		mode = mode,
		scene = scene,
	}
	users[uid] = agent
	mgr:enqueue_agent(rt, agent)

	if mgr:get_agent_queue_sz(rt) >= 3 then
		log.info("room number more than 3")
		local room = mgr:dequeue_room()
		for i=1,3 do
			local u = mgr:dequeue_agent(rt)
			skynet.send(u.agent, "lua", "enter_room", room.id)
			users[u.uid] = nil
		end	
	end
	return noret
end

function CMD.dequeue_agent(source, uid, ... )
	-- body
	assert(uid)
	local u = users[uid]
	if u then
		mgr:remove_agent(u)
		users[uid] = nil
	end
end

function CMD.create(uid, agent, args)
	-- body
	log.info("ROOM_MGR create")
	local u = users[uid]
	if u then
		local res = {}
		res.errorcode = 10
		return res
		-- TODO: 如果玩家已经创建了房间，那么是不应该能无限次创建的
		-- skynet.call(u.room.addr, "lua", "close")
		-- mgr:enqueue_room(u.room)

		-- local room = mgr:dequeue_room()
		-- room.creator = uid

		-- local res = skynet.call(room.addr, "lua", "start", uid, args)
		-- u.room = room
		-- u.agent = agent

		-- log.info("create room ok")
		-- return res
	else
		local res = {}
		local errorcode, roomid = next_id()
		if errorcode ~= 0 then
			res.errorcode = errorcode
			return res
		end
		assert(roomid >= 1 and roomid <= MAX_ROOM_NUM)
		local room = assert(pool[roomid])

		res = skynet.call(room.addr, "lua", "start", channel_id, uid, args)
		if res.errorcode ~= 0 then
			return res
		else
			u = {}
			u.uid = uid
			u.roomid = room.id
			u.agent = agent
			users[uid] = u

			-- room
			pool[roomid] = nil
			room.rule = args
			room.host = uid
			rooms[roomid] = room
			num = num + 1

			log.info("create room ok")
			return res
		end
	end
end

function CMD.apply(roomid)
	-- body
	log.info("apply roomid: %d, return room addr", roomid)
	local room = rooms[roomid]
	if room then
		return { errorcode = 0, addr = room.addr }
	else
		return { errorcode = 14 }
	end
end

function CMD.dissolve(source, roomid, ... )
	-- body
	local room = mgr:get(roomid)
	local res = skynet.call(room.addr, "lua", "close")
end

-- only
function CMD.radio()
	-- body
end

-- room exit
function CMD.enqueue_room(roomid)
	-- body
	local room = mgr:get(roomid)
	mgr:enqueue_room(room)
	return true
end

skynet.start(function ()
	-- body
	config = AppConfig.new()
	skynet.dispatch("lua", function ( _, _, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local r = f( ... )
		if r ~= NORET then
			if r ~= nil then
				skynet.retpack(r)
			else
				log.error("ROOM_MGR cmd = %d  not return", cmd)
			end
		end
	end)
	skynet.register ".ROOM_MGR"
end)
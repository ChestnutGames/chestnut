package.path = "./module/dezhou/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local ds = require "skynet.datasheet"
local log = require "chestnut.skynet.log"
local queue = require "chestnut.queue"
local json = require "rapidjson"
local traceback = debug.traceback
local assert = assert

local NORET = {}
local users = {}   -- 玩家信息,玩家创建的房间
local rooms = {}   -- 正在打牌的
local num = 0      -- 正在打牌的桌子数
local pool = {}    -- 闲置的大佬2桌子
local q = queue()  -- 排队的队列
local bank = 101010
local MAX_ROOM_NUM = 4
local id = bank + 1

-- @breif 生成房间id，
-- @return 0,成功, 13 超过最大房间数
local function next_id()
	-- body
	if num >= MAX_ROOM_NUM then
		return 13
	else
		while rooms[id] do
			id = id + 1
			if id > bank + MAX_ROOM_NUM then
				id = bank + 1
			end
		end
		return 0, id
	end
end


local CMD = {}

function CMD.start(channel_id)
	-- body
	local channel = mc.new {
		channel = channel_id,
		dispatch = function (_, _, cmd, ...)
			-- body
			local f = assert(CMD[cmd])
			local ok, err = pcall(f, ... )
			if not ok then
				log.error(err)
			end
		end
	}
	channel:subscribe()

	-- 初始一些配置
	MAX_ROOM_NUM = tonumber(ds.query('consts')['2']['Value'])
	assert(MAX_ROOM_NUM > 1)
	log.info('MAX_ROOM_NUM ==> %d', MAX_ROOM_NUM)

	-- 初始所有桌子
	for i=1,MAX_ROOM_NUM do
		local roomid = bank + i
		local addr = skynet.newservice("big2room/room", roomid)
		skynet.call(addr, "lua", "start", channel_id)
		pool[roomid] = { id = roomid, addr = addr }
	end
	return true
end

function CMD.init_data()
	-- body
	local pack = skynet.call('.DB', "lua", "read_room_mgr")
	if pack then
		for _,db_user in pairs(pack.db_users) do
			if db_user.roomid ~= 0 then
				local user = {}
				user.uid = assert(db_user.uid)
				user.roomid = assert(db_user.roomid)
				users[tonumber(user.uid)] = user
			end
		end
		for _,db_room in pairs(pack.db_rooms) do
			if db_room.host ~= 0 then
				local room = {}
				room.id = assert(db_room.id)
				room.host = assert(db_room.host)
				room.users = {}
				local xusers = json.decode(db_room.users)
				for k,v in pairs(xusers) do
					local user = {}
					user.uid = assert(v.uid)
					user.idx = assert(v.idx)
					user.chip = assert(v.chip)
					room.users[tonumber(k)] = user
				end
				room.ju = assert(db_room.ju)
				rooms[tonumber(room.id)] = room
			end
		end
	end
	-- 初始所有房间数据,当前房间是没有addr
	-- for k,_ in pairs(rooms) do
	-- 	local room = pool[k]
	-- 	local ok = skynet.call(room.addr, "lua", "init_data")
	-- 	assert(ok)
	-- end
	return true
end

function CMD.sayhi()
	-- body
	-- 验证mgr数据与room数据的一致
	for k,v in pairs(rooms) do
		if v.ju < 1 then
			local room = pool[k]
			local ok = skynet.call(room.addr, "lua", "sayhi", v.host, assert(v.users))
			if ok then
				v.addr = room.addr
				pool[k] = nil
				num = num + 1
				if k > id then
					id = k
				end
				skynet.call('.CHATD', 'lua', 'room_create', v.id, v.addr)
				skynet.call('.CHATD', 'lua', 'room_init_users', v.id, v.users)
			else
				log.error("room data wrong.")
			end
		else
			-- 此房间应该解散，修改离线用户数据
			users[v.host] = nil
			for i,uid in ipairs(v.users) do
				skynet.call('.OFFAGENT', "lua", "write_offuser_room", uid)
			end
			rooms[k] = nil
		end
	end
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
		local xusers = {}
		for k,v in pairs(v.users) do
			local user = {}
			user.uid = assert(v.uid)
			user.idx = assert(v.idx)
			user.chip = assert(v.chip)
			xusers[tostring(k)] = user
		end
		db_room.users = json.encode(xusers)
		db_room.ju = v.ju
		db_rooms[string.format("%d", k)] = db_room
	end
	local data = {}
	data.db_users = db_users
	data.db_rooms = db_rooms
	skynet.call(".DB", "lua", "write_room_mgr", data)

	-- 清除已经解散的数据
	for k,v in pairs(users) do
		if v.roomid == 0 then
			users[k] = nil
		end
	end
	for k,v in pairs(rooms) do
		if v.host == 0 then
			pool[k] = v
			rooms[k] = nil
		end
	end
	return NORET
end

function CMD.close()
	-- body
	-- 房间内的数据是不用存的
	CMD.save_data()
	return true
end

function CMD.kill()
	-- body
	skynet.exit()
end

------------------------------------------
-- 匹赔
function CMD.enqueue_agent(uid, agent, rule, mode, scene, ... )
	-- body
	log.info("enqueue_agent")
	local rt = ((scene & 0xff << 16) | (mode & 0xff << 8) | (rule & 0xff))
	local user = {
		agent = agent,
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

function CMD.dequeue_agent(uid)
	-- body
	assert(uid)
	local u = users[uid]
	if u then
		mgr:remove_agent(u)
		users[uid] = nil
	end
end

------------------------------------------
-- 打开房间
function CMD.create(uid, agent, args)
	-- body
	log.info("ROOM_MGR create")
	local u = users[uid]
	if u then
		local res = {}
		res.errorcode = 10
		return res
	else
		local res = {}
		local errorcode, roomid = next_id()
		if errorcode ~= 0 then
			res.errorcode = errorcode
			return res
		end
		assert(roomid >= bank + 1 and roomid <= bank + MAX_ROOM_NUM)
		local room = assert(pool[roomid])

		res = skynet.call(room.addr, "lua", "create", uid, args)
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
			room.ju = 0
			room.users = {}
			rooms[roomid] = room
			num = num + 1

			log.info("create room ok")
			return res
		end
	end
end

-- 查询房间地址
function CMD.apply(roomid)
	-- body
	assert(roomid)
	log.info("apply roomid: %d, return room addr", roomid)
	local room = rooms[roomid]
	if room then
		return { errorcode = 0, addr = room.addr }
	else
		return { errorcode = 14 }
	end
end

-- 解散房间 call by room
function CMD.dissolve(roomid)
	-- body
	local room = assert(rooms[roomid])
	skynet.call(room.addr, 'lua', 'recycle')
	local user = users[room.host]
	user.roomid = 0
	room.host = 0
	return NORET
end

------------------------------------------
-- 房间
function CMD.room_join(roomid, uid, agent, idx, chip)
	-- body
	assert(roomid and uid and agent and idx and chip)
	local room = rooms[roomid]
	room.users[uid] = { uid=uid, agent=agent, idx=idx, chip=chip }
	return true
end

function CMD.room_rejoin(roomid, uid, agent)
	-- body
	assert(roomid and uid and agent)
	local room = assert(rooms[roomid])
	local user = room.users[uid]
	user.agent = agent
	return true
end

function CMD.room_afk(roomid, uid)
	-- body
	assert(roomid and uid)
	local room = rooms[roomid]
	local user = room.users[uid]
	user.agent = nil
	return true
end

function CMD.room_leave(roomid, uid)
	-- body
	assert(roomid and uid)
	local room = rooms[roomid]
	room.users[uid] = nil
	return true
end

function CMD.room_check_nextju(roomid)
	-- body
	assert(roomid)
	local room = assert(rooms[roomid])
	if room.ju >= 1 then
		return false
	end
	return true
end

function CMD.room_incre_ju(roomid)
	-- body
	assert(roomid)
	local room = assert(rooms[roomid])
	if room.ju >= 1 then
		return false
	end
	room.ju = room.ju + 1
	return true
end

function CMD.room_is_1stju(roomid)
	-- body
	assert(roomid)
	local room = assert(rooms[roomid])
	if room.ju == 0 then
		return true
	end
	return false
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function ( _, _, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local ok, err = xpcall(f, traceback, ...)
		if ok then
			if err ~= NORET then
				if err ~= nil then
					skynet.retpack(err)
				else
					log.error("ROOM_MGR cmd = %s not return", cmd)
				end
			end
		end
	end)
	skynet.register ".ROOM_MGR"
end)
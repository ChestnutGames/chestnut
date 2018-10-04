local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
-- local sd = require "skynet.sharedata"
local log = require "chestnut.skynet.log"
local zset = require "chestnut.zset"
local redis = require "chestnut.redis"
local json = require "rapidjson"
local traceback = debug.traceback
local assert = assert

local NORET = {}
local users = {}
local rooms = {}
local zs = zset.new()


local CMD = {}

function CMD.start(channel_id)
	-- body
	local channel = mc.new {
		channel = channel_id,
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
	return true
end

function CMD.init_data()
	-- body
	-- local pack = redis:get("tb_sysmail")
	-- if pack then
	-- 	local data = json.decode(pack)
	-- 	for k,v in pairs(data.mails) do
	-- 		local db_mail = {}
	-- 		db_mail.id          = assert(v.id)
	-- 		db_mail.sender      = assert(v.sender)
	-- 		db_mail.to          = assert(v.to)
	-- 		db_mail.create_time = assert(v.create_time)
	-- 		db_mail.title       = assert(v.title)
	-- 		db_mail.content     = assert(v.content)
	-- 		db_mail.appendix    = assert(v.appendix)
	-- 		zs:add(tonumber(k), db_mail)
	-- 	end
	-- end
	log.info("mail_mgr init_data over.")
	return true
end

function CMD.sayhi()
	-- body
	-- 初始化各种全服信息
end

-- channel msg, not return
function CMD.save_data()
	-- body
	if zs:count() > 0 then
		local db_mails = {}
		local t = zs:range(1, zs:count())
		for k,v in pairs(t) do
			local db_mail = {}
			db_mail.id          = assert(v.id)
			db_mail.sender      = assert(v.sender)
			db_mail.to          = assert(v.to)
			db_mail.create_time = assert(v.create_time)
			db_mail.title       = assert(v.title)
			db_mail.content     = assert(v.content)
			db_mail.appendix    = assert(v.appendix)
			db_mails[string.format("%d", k)] = db_mail
		end
		local data = {}
		data.mails = db_mails
		local pack = json.encode(data)
		redis:set("tb_sysmail", pack)
	end
	return NORET
end

function CMD.close( ... )
	-- body
	CMD.save_data()
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

-- 各种全服服务初始
function CMD.init_rooms(rooms, ... )
	-- body
	rooms = rooms
end

-- 用户初始
function CMD.poll(uid, agent, max_id, ... )
	-- body
	assert(users[uid] == nil)
	local u = { uid = uid, agent = agent }
	users[uid] = u

	-- 取自己的并且超过max_id
	if zs:count() > 0 then
		local t = zs:range(1, zs:count())
		local res = {}
		for _,v in ipairs(t) do
			if v.id > max_id then
				table.insert(res, v)
			end
		end
		return res
	else
		return {}
	end
end

function CMD.afk(uid, ... )
	-- body
	assert(users[uid])
	users[uid] = nil
end

function CMD.new_mail(title, content, appendix, to, ... )
	-- body
	local now = skynet.time()
	local mail = {}
	mail.id          = guid()
	mail.sender      = 1
	mail.to          = to
	mail.create_time = now
	mail.title       = title
	mail.content     = content
	mail.appendix    = appendix
	zs:add(mail.id, mail)
	assert(to >= 0)
	if to == 0 then
		-- 所有人
		for _,v in pairs(users) do
			skynet.send(v.agent, "lua", "new_mail", mail)
		end
	elseif rooms[to] then
		local room = rooms[to]
		for _,v in pairs(room) do
			if users[v] then
				skynet.send(v.agent, "lua", "new_mail", mail)
			end
		end
	elseif users[to] then
		if users[to] then
			local u = users[to]
			skynet.send(u.agent, "lua", "new_mail", mail)
		end
	end
	return NORET
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function (_, _, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local ok, err = xpcall(f, traceback, ...)
		if ok then
			if err ~= NORET then
				if err ~= nil then
					skynet.retpack(err)
				else
					log.error("sysemaild cmd = %s no ret", cmd)
				end
			end
		else
			log.error(err)
		end
	end)
	skynet.register ".SYSEMAIL"
end)
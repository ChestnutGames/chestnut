local skynet = require "skynet"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local redis = require "chestnut.redis"
local json = require "rapidjson"
local service = require "service"
local savedata = require "savedata"
local traceback = debug.traceback
local assert = assert

local NORET = {}
local refreshs = {}
local config

local CMD = {}
local SUB = {}

function SUB.save_data()
end

function CMD.start(channel_id)
	-- body
	savedata.init {
		channel_id = channel_id,
		command = SUB
	}
	return true
end

function CMD.init_data()
	-- body
	local pack = redis:get("tb_refresh")
	if pack then
		local data = json.decode(pack)
		for k,v in pairs(data.refreshs) do
			users[tonumber(k)] = v
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
	-- local xusers = {}
	-- local xrooms = {}
	-- for k,v in pairs(users) do
	-- 	xusers[string.format("%d", k)] = v
	-- end
	-- for k,v in pairs(rooms) do
	-- 	xrooms[string.format("%d", k)] = v
	-- end
	-- local data = {}
	-- data.users = xusers
	-- data.rooms = xrooms
	-- local pack = json.encode(data)
	-- redis:set("tb_room", pack)
	return true
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

------------------------------------------
-- 游戏设计
function CMD.checkin(uid, agent)
	-- body
end

function CMD.afk(uid, ... )
	-- body
	assert(users[uid])
	users[uid] = nil
end

service.init {
	name = '.REFRESH_MGR',
	command = CMD
}

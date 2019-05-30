local skynet = require "skynet"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local redis = require "chestnut.redis"
local json = require "rapidjson"
local service = require "service"
local savedata = require "savedata"
local traceback = debug.traceback
local assert = assert

local refreshs = {}
local channel


local function save_data()
end

local function save_data_loop()
	while true do
		skynet.sleep(100 * 10)
		channel:publish('save_data')
	end
end

local CMD = {}

function CMD.start()
	-- body
	channel = mc.new()
	return true
end

function CMD.init_data()
	-- body
	return true
end

function CMD.sayhi()
	-- body
	skynet.fork(save_data_loop)
	return true
end

function CMD.close()
	-- body
	save_data()
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

function CMD.get_channel_id( ... )
	-- body
	return channel.channel
end

service.init {
	name = '.REFRESH_MGR',
	command = CMD
}

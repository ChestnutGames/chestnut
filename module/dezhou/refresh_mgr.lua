package.path = "./module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local redis = require "chestnut.redis"
local AppConfig = require "AppConfig"
local json = require "rapidjson"

local NORET = {}
local refreshs = {}
local config

local CMD = {}

function CMD.start(channel_id)
	-- body
	if not config:LoadFile() then
		return false
	end
	if not config:CheckConfig() then
		return false
	end
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

function CMD.checkin(uid, agent)
	-- body
end

function CMD.afk(uid, ... )
	-- body
	assert(users[uid])
	users[uid] = nil
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
				log.error("REFRESH_MGR cmd = %d  not return", cmd)
			end
		end
	end)
	skynet.register ".REFRESH_MGR"
end)
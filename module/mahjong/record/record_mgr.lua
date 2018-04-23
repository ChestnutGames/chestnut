package.path = "./../../module/mahjong/lualib/?.lua;./../../module/mahjong/record/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local sd = require "skynet.sharedata"
local mc = require "skynet.multicast"
local log = require "chestnut.skynet.log"
local zset = require "chestnut.zset"
local util = require "chestnut.time"
local redis = require "chestnut.redis"
local guid = require "chestnut.guid"
local const = require "const"
local dbmonitor = require "dbmonitor"
local json = require "rapidjson"

local NORET = {}
local records = {}

local CMD = {}

function CMD.start(channel_id)
	-- body
	assert(channel_id)
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

function CMD.init_data( ... )
	-- body
	-- local pack = redis:get("tb_record")
	-- if pack then
	-- 	local data = json.decode(pack)
	-- 	for k,v in pairs(data.records) do
	-- 		records[tonumber(k)] = v
	-- 	end
	-- end
	return true
end

function CMD.sayhi( ... )
	-- body
end

function CMD.save_data()
	-- body
	-- local db_records = {}
	-- for k,v in pairs(records) do
	-- 	local db_record = {}
	-- 	xrecords[string.format("%d", k)] = v
	-- end
	-- local data = {}
	-- data.records = xrecords
	-- local pack = json.encode(data)
	-- redis:set("tb_record", pack)
	return NORET
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.load( ... )
	-- body
	local idx =  db:get(string.format("tb_count:%d:uid", const.RECORD_ID))
	idx = math.tointeger(idx)
	if idx > 1 then
		local keys = db:zrange('tb_record', 0, -1)
		for k,v in pairs(keys) do
			zs:add(k, v)
		end

		for _,id in pairs(keys) do
			local vals = db:hgetall(string.format('tb_record:%s', id))
			local t = {}
			for i=1,#vals,2 do
				local k = vals[i]
				local v = vals[i + 1]
				t[k] = v
			end
			sd.new(string.format('tb_record:%s', id), t)
			-- t = sd.query(string.format('tg_sysmail:%s', id))
		end	
	end
end

function CMD.register(content, ... )
	-- body
	local id =  db:incr(string.format("tb_count:%d:uid", const.RECORD_ID))
	dbmonitor.cache_update(string.format("tb_count:%d:uid", const.RECORD_ID))

	-- sd.new
	local r = mgr:create(internal_id)
	mgr:add(r)
	r:insert_db()
end

function CMD.save_record(players, start_time, close_time, content, ... )
	-- body
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function (_, _, cmd, ...)
		-- body
		log.info("cmd = %s begin.", cmd)
		local f = assert(CMD[cmd])
		local traceback = debug.traceback
		local ok, err = xpcall(f, traceback, ...)
		if ok then
			if err ~= NORET then
				if err ~= nil then
					skynet.retpack(err)
					log.info("cmd = %s end.", cmd)
				else
					log.error("cmd = %s not return", cmd)
				end
			end
		else
			log.error(err)
		end
	end)
	skynet.register ".RECORD_MGR"
end)
package.path = "../../db/?.lua;" .. package.path
local skynet = require "skynet"
local mc = require "skynet.multicast"
local mysql = require "skynet.db.mysql"
local redis = require "skynet.db.redis"
local log = require "skynet.log"
local queue = require "chestnut.queue"
local util = require "util"


local mode = ...

if mode == "agent" then

local dbconf
local db
local cache
local readq = queue()
local write

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local function connect_mysql(conf)
	local function on_connect( db )
		db:query( "set charset utf8" )
	end
	local c = {
		host = conf.host or "192.168.1.116",
		port = conf.port or 3306,
		database = conf.database or "project",
		user = conf.user or "root",
		password = conf.password or "yulei",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect,
	}
	return mysql.connect(c)
end

local function disconnect_mysql( ... )
	-- body
	if db then
		db:disconnect()
	end
end

local QUERY = {}

function QUERY.select(table_name, sql)
	-- body
	if name == "master" then
		local db = nil
		if #readq > 0 then
			db = assert(readq:dequeue())
		else
			assert(false)
			db = skynet.newservice("db", "slave")
			skynet.call(db, "lua", "start", dbconf)
		end
		local res = skynet.call(db, "lua", "query", "select", table_name, sql)
		readq:enqueue(db)
		return res
	elseif name == "slave" then
		local res = db:query(sql)
		dump(res)	
		return res
	end
end

function QUERY.update(table_name, sql)
	-- body
	if name == "master" then
		skynet.send(write, "lua", "query", "update", table_name, sql)
	elseif name == "slave" then
		local res = db:query(sql)
		dump(res)
	end
end

function QUERY.insert(table_name, sql, ... )
	-- body
	local res = db:query(sql)
	dump(res)
end

skynet.start(function ( _, _, cmd, ... )
	-- body
	local f = QUERY[cmd]
	local r = f( ... )
	if r ~= nil then
		skynet.retpack(r)
	end
end)

else

skynet.start(function ()
	local agent = {}
	for i= 1, 20 do
		agent[i] = skynet.newservice(SERVICE_NAME, "agent")
	end
	local balance = 1	
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		local r = skynet.call(agent[balance], "lua", m, cmd, ...)
		if r ~= nil then
			skynet.retpack(r)
		end
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
	skynet.register ".DB"
	
end)

end
package.path = "./module/dezhou/db/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local mysql = require "skynet.db.mysql"
local log = require "chestnut.skynet.log"
local db_read = require "db_read"
local db_write = require "db_write"

local mode = ...

if mode == "agent" then

local db
local test = 1

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

local function connect_mysql()
	local function on_connect( db )
		db:query( "set charset utf8" )
	end
	local c = {
		host = skynet.getenv("db_host") or "127.0.0.1",
		port = skynet.getenv("db_port") or 3306,
		database = skynet.getenv("db_database") or "user",
		user = skynet.getenv("db_user") or "root",
		password = skynet.getenv("db_password") or "123456",
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

function QUERY.close()
	-- body
	disconnect_mysql()
end

function QUERY.kill()
	-- body
	skynet.exit()
end

----------------------------------------------------------read
function QUERY.read_sysmail()
	-- body
	local res = db_read.read_sysmail(db)
	dump(res)
	return res
end

function QUERY.read_room_mgr_users()
	-- body
	local res = db_read.read_room_mgr_users(db)
	dump(res)
	return res
end

function QUERY.read_room_mgr_rooms()
	-- body
	local res = db_read.read_room_mgr_rooms(db)
	dump(res)
	return res
end

function QUERY.read_account_by_username(username, password)
	-- body
	local res = {}
	local accounts = db_read.read_account_by_username(db, username, password)
	log.info(dump(accounts))
	if #accounts == 1 then
		local users = db_read.read_user_by_uid(db, accounts[1].uid)
		res.accounts = accounts
		res.users = users
	end
	return res
end


function QUERY.read_user(uid)
	-- body
	local res = {}
	res.db_users = db_read.read_user_by_uid(db, uid)
	return res
end

----------------------------------------------------------write
function QUERY.write_user(data)
	-- body
	local res = db_write.write_user(db, data.db_user)
	-- log.info(dump(res))
	return res
end

-------------------------------------------------------------end

skynet.start(function ()
	-- body
	db = connect_mysql()
	skynet.dispatch( "lua" , function( _, _, cmd, ... )
		local f = assert(QUERY[cmd])
		local ok, err = pcall(f, ...)
		if ok then
			skynet.retpack(err)
		else
			log.error(err)
		end
	end)
end)

else

skynet.start(function ()
	local agent = {}
	for i= 1, 20 do
		agent[i] = skynet.newservice(SERVICE_NAME, "agent")
	end
	local balance = 1
	skynet.dispatch( "lua" , function( _, _, ... )
		local r = skynet.call(agent[balance], "lua", ... )
		assert(r)
		skynet.retpack(r)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
	skynet.register ".DB"
end)

end
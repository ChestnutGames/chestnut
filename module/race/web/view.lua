local skynet = require "skynet"
local log = require "skynet.log"
local json = require "chestnut.cjson"


local pcall = skynet.pcall
local template = {}
local string_split = string.split

local gated = "." .. skynet.getenv "gated_name"

local VIEW = {}

function VIEW.login(args, ... )
	-- body
	log.info("login")
	local query = json.decode(args.query)
	local res = skynet.call(gated, "lua", "login", query)
	assert(type(res) == "table")
	return json.encode(res)
end

function VIEW.handshake(args, ... )
	-- body
	log.info("handshake")
	local query = json.decode(args.query)
	local res = skynet.call(gated, "lua", "handshake", query)
	assert(type(res) == "table")
	return json.encode(res)
end

function VIEW.userinfo( ... )
	-- body
	local query = json.decode(args.query)
	local res = skynet.call(gated, "lua", "userinfo", query)
	assert(type(res) == "table")
	return json.encode(res)
end

return VIEW

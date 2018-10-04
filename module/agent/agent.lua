package.path = "./module/agent/?.lua;./module/lualib/?.lua;"..package.path
local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"
local context = require "AgentContext"
local REQUEST = require "request"
local RESPONSE = require "response"
local CMD = require "cmd"
local traceback = debug.traceback
local assert = assert

local ctx

local function request(name, args, response)
	log.info("agent request [%s]", name)
    local f = REQUEST[name]
    if f then
		local traceback = debug.traceback
	    local ok, result = xpcall(f, traceback, ctx, args)
	    if ok then
			if result then
				return response(result)
			else
				log.error("agent request [%s] result is nil", name)
			end
	    else
			log.error("agent request [%s], error = [%s]", name, result)
	    end
	else
		log.error("agent request [%s] is nil", name)
	end
end

local function response(session, args)
	-- body
	local name = ctx:get_name_by_session(session)
	-- log.info("agent response [%s]", name)
    local f = RESPONSE[name]
    if f then
		local ok, result = pcall(f, ctx, args)
	    if not ok then
			log.error(result)
	    end
    else
		log.error("agent response [%s] is nil.", name)
    end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz > 0 then
			local host = ctx.host
			return host:dispatch(msg, sz)
		else
			assert(false)
		end
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			local traceback = debug.traceback
			local ok, result = xpcall(request, traceback, ...)
			if ok then
				if result then
					ctx:send_package_gate("push_client", result)
				end
			else
				log.error("agent dispatch error:")
				log.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false)
		end
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd])
		local ok, err = xpcall(f, traceback, ctx, ...)
		if ok then
			if err ~= servicecode.NORET then
				if err ~= nil then
					skynet.retpack(err)
				else
					log.error("agent cmd [%s] result is nil", cmd)
				end
			end
		else
			log.error("agent cmd [%s] error = [%s]", cmd, err)
		end
	end)
	-- slot 1,2 set at main.lua
	ctx = context.new()
end)

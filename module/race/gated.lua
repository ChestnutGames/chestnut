local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local errorcode = require "errorcode"
local sessions = {}
local session = 1

local CMD = {}

function CMD.start( ... )
	-- body
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.register(agent, session, ... )
	-- body
	local u = {}
	u.session = session
	u.agent = agent
	sessions[session] = u

	return true
end

function CMD.login(req, ... )
	-- body
	local res = skynet.call(".SIGNUPD", "lua", "signup", "sample1", req.username)
	if res.code == 200 then
		session = session + 1
		if session > 100000000 then
			session = 1
		end
		local agent = skynet.call(".AGENT_MGR", "lua", "enter", res.uid)
		skynet.call(agent, "lua", "login", skynet.self(), uid, session, "secret")
		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.session = session
		return res
	else
		local res = {}
		res.errorcode = errorcode.FAIL
		res.session = session
		return res
	end
end

function CMD.handshake(req, ... )
	-- body
	local session = req.header.session
	if session and session > 0 then
		local u = sessions[session]
		local agent = u.agent
		local payload = skynet.call(agent, "lua", "handshake", req.payload)
		local res = {}
		res.header = {}
		res.header.session = session
		res.payload = payload
		return res
	else
		local res = {}
		res.header = {}
		res.header.session = session
		res.payload = {}
		res.payload.errorcode = errorcode.FAIL
		return res	
	end
end

function CMD.userinfo(req, ... )
	-- body
	local session = req.header.session
	if session and session > 0 then
		local u = sessions[session]
		local agent = u.agent
		local payload = skynet.call(agent, "lua", "userinfo", req.payload)
		local res = {}
		res.header = {}
		res.header.session = session
		res.payload = payload
		return res
	else
		local res = {}
		res.header = {}
		res.header.session = session
		res.payload = {}
		res.payload.errorcode = errorcode.FAIL
		return res	
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	
	local name = skynet.getenv "gated_name"
	skynet.register("." .. name)
end)

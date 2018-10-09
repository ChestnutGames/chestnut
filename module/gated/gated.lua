package.path = "./module/gated/?.lua;" .. package.path
local msgserver = require "msgserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"

local loginservice = ".LOGIND"
local servername


local server = {}
local users = {}
local username_map = {}
local internal_id = 0
local forwarding  = {}	-- agent -> connection

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(source, uid, secret, ...)
	if users[uid] then
		error(string.format("%s is already login", uid))
	end

	internal_id = internal_id + 1
	local id = internal_id	-- don't use internal_id directly
	local username = msgserver.username(uid, id, servername)
	log.info("gated username: %s, uid: %s", username, uid)

	-- you can use a pool to alloc new agent
	-- local agent = skynet.newservice "agent"
	
	local agent = skynet.call(".AGENT_MGR", "lua", "enter", uid)
	local u = {
		username = username,
		agent = agent,
		uid = uid,
		subid = id,
		online = false,
	}

	-- trash subid (no used)
	local err = skynet.call(agent, "lua", "login", skynet.self(), uid, id, secret)
	if err == servicecode.SUCCESS then
		log.info("gated call login err = %d", err)
		users[uid] = u
		username_map[username] = u

		msgserver.login(username, secret)

		-- you should return unique subid
		local res = {}
		res.errorcode = err
		res.subid = id
		return res
	else
		log.info("gated call login err = %d", err)
		local res = {}
		res.errorcode = err
		res.subid = 0
		return res
	end
end

-- call by agent
function server.logout_handler(source, uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		msgserver.logout(u.username)
		users[uid] = nil
		username_map[u.username] = nil
		log.info("call login logout")
		local err = skynet.call(loginservice, "lua", "logout", uid, subid)
		if err ~= servicecode.SUCCESS then
			log.error("logind service logout failture.")
		else
			log.info("logind service logout ok.")
		end
		return err
	else
		log.error("gated service not contains uid(%d)", uid)
		return servicecode.FAIL
	end
end

-- call by login server
function server.kick_handler(source, uid, subid)
	local u = users[uid]
	if u then
		if not u.online then
			log.info("uid = %d offline.", uid)
		end
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		-- pcall(skynet.call, u.agent.handle, "lua", "logout")
		log.info("uid(%d) kick agent, call agent logout", uid)
		local ok = skynet.call(u.agent, "lua", "logout")
		if not ok then
			log.error("gated pcall agent kick error.")
			return false
		else
			return ok
		end
	else
		log.error("uid = %d not existence.")
		return false
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username, fd)
	local u = username_map[username]
	if u then
		if u.online then
			skynet.call(u.agent, "lua", "afk")
			u.online = false
		else
			log.error('disconnet when onlien is false')
		end
	end
end

-- call by self
function server.start_handler(username, fd, ... )
	-- body
	local u = username_map[username]
	if u then
		if u.online == nil or u.online == false then
			local agent = u.agent
			if agent then
				local conf = {
					client = fd,
				}
				log.info("start_handler")
				skynet.call(agent, "lua", "auth", conf)
				u.online = true
			end
		else
			log.error('online is true, start auth ...')
		end
	end
end

-- call by self
function server.msg_handler(username, msg, sz,... )
	-- body
	local u = username_map[username]
	if u then
		if u.online then
			local agent = u.agent
			if agent then
				skynet.redirect(agent, skynet.self(), "client", 0, msg, sz)
			else
				log.error("not find agent")
			end
		end
	end
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	local u = username_map[username]
	return skynet.tostring(skynet.rawcall(u.agent, "client", msg))
end

-- call by self (when gate open)
function server.register_handler(name)
	skynet.error(string.format("reister gate server: %s", name))
	servername = name
	local gated = skynet.getenv "gated"
	skynet.call(loginservice, "lua", "register_gate", servername, skynet.self(), gated)
end

msgserver.start(server)

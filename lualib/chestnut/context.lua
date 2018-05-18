local skynet = require "skynet"
local socket = require "skynet.socket"
local log = require "chestnut.skynet.log"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local servicecode = require "chestnut.servicecode"
local assert = assert

local string_pack = string.pack
local max = 2 ^ 16 - 1

local cls = class("context")

function cls:ctor()
	-- body
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))

	self.host = host
	self._send_request = send_request
	self.response_session = 0
	self.response_session_name = {}

	-- will been used
	-- self.version = 0
	-- self.index = 0

	self.fd = false
	self.gate   = nil
	self.watchdog = nil
	self.uid    = nil
	self.subid  = nil
	self.secret = nil

	self.logined = false
	self.authed = false

	return self
end

function cls:get_fd()
	-- body
	return self.fd
end

function cls:set_fd(fd)
	-- body
	self.fd = fd
end

-- function cls:get_version( ... )
-- 	-- body
-- 	return self.version
-- end

-- function cls:set_version(v, ... )
-- 	-- body
-- 	self.version = v
-- end

-- function cls:get_index( ... )
-- 	-- body
-- 	return self._index
-- end

-- function cls:set_index(idx, ... )
-- 	-- body
-- 	self.index = idx
-- end

function cls:get_uid()
	-- body
	return self.uid
end

function cls:get_subid()
	-- body
	return self.subid
end

function cls:get_secret()
	-- body
	return self.secret
end

function cls:send_package_id(id, pack)
	-- body
	assert(self)
	assert(id and pack)
	local package = string_pack(">s2", pack)
	socket.write(id, package)
end

function cls:send_package(pack)
	-- body
	local fd = assert(self.fd)
	local package = string_pack(">s2", pack)
	socket.write(fd, package)
end

function cls:send_request_id(id, name, args)
	-- body
	if not self.logined or not self.authed then
		return
	end
	assert(id and name)
	self.response_session = self.response_session + 1 % max
	self.response_session_name[self.response_session] = name
	local request = self._send_request(name, args, self.response_session)
	self:send_package_id(id, request)
end

function cls:send_package_gate(name, args)
	-- body
	skynet.send(self.gate, "lua", name, self.fd, args)
end

function cls:send_request_gate(name, args)
	-- body
	if not self.logined or not self.authed then
		return
	end
	assert(name)
	self.response_session = self.response_session + 1 % max
	self.response_session_name[self.response_session] = name
	local request = self._send_request(name, args, self.response_session)
	skynet.send(self.gate, "lua", "push_client", self.fd, request)
end

function cls:send_request(name, args)
	-- body
	if not self.logined or not self.authed then
		return
	end
	local fd = assert(self.fd)
	self:send_request_id(fd, name, args)
end

function cls:get_name_by_session(session)
	-- body
	return self.response_session_name[session]
end

function cls:start()
	-- body
	self.logined = false
	self.authed = false
	return true
end

function cls:close()
	-- body
	assert(self)
	return true
end

function cls:reset()
	-- body
	assert(self)
end

function cls:login(gate, uid, subid, secret)
	assert(gate and uid and subid and secret)
	assert(not self.logined)
	self.gate = gate
	self.uid = uid
	self.subid = subid
	self.secret = secret
	self.logined = true
	return true
end

function cls:auth(args)
	-- body
	assert(not self.authed)
	self.fd  = assert(args.client)
	self.authed = true
	return servicecode.SUCCESS
end

function cls:afk()
	-- body
	assert(self.authed)
	self.authed = false
	return servicecode.SUCCESS
end

function cls:logout()
	-- body
	assert(self.logined)
	assert(self.gate)
	log.info("call gate logout")
	local ok = skynet.call(self.gate, "lua", "logout", self.uid, self.subid)
	if not ok then
		log.error("uid(%d) logout failture.", self.uid)
		return false
	end

	ok = skynet.call(".AGENT_MGR", "lua", "exit_at_once", self.uid)
	if not ok then
		log.error("call agent_mgr exit_at_once failture.")
		return false
	end
	if self.authed then
		self.authed = false
	end
	self.logined = false
	log.info("uid(%d) logout", self.uid)
	return true
end

function cls:inituser()
	-- body
	assert(self)
	return true
end

return cls
local skynet = require "skynet"
local errorcode = require "errorcode"
local log = require "chestnut.skynet.log"
local pcall = pcall

local REQUEST = {}

function REQUEST:handshake(args, ... )
	-- body
	self:send_request("handshake")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:logout( ... )
	-- body
	self:logout()
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:inituser()
	-- body
	return self:inituser()
end

function REQUEST:create(args, ... )
	-- body
	local M = self.systems.room
	return M:create(args)
end

function REQUEST:join(args)
	-- body
	local M = self.systems.room
	return M:join(args)
end

function REQUEST:rejoin()
	-- body
	return self.systems.room:rejoin()
end

function REQUEST:leave(args, ... )
	-- body
	local M = self.systems.room
	return M:leave(args)
end

function REQUEST:first(args)
	-- body
	local ok, err = pcall(self.systems.user.first, self.systems.user, args)
	if ok then
		return err
	else
		log.error("uid(%d) REQUEST = [first], error = [%s]", self.uid, err)
		local res = {}
		res.errorcode = 1
		return res
	end
end

function REQUEST:room_info(args)
	-- body
	local ok, err = pcall(self.systems.room.room_info, self.systems.room, args)
	if ok then
		return err
	else
		log.error("uid(%d) REQUEST = [room_info], error = [%s]", self.uid, err)
		local res = {}
		res.errorcode = 1
		return res
	end
end

function REQUEST:checkindaily(args, ... )
	-- body
	local res = {}
	local cds, day = util.cd_sec()
	if u.checkin_lday.value == cds then
		res.errorcode = errorcode.FAIL
		return res
	else
		local cnt = self._user.checkin_count.value
		cnt = cnt + 1
		self._user:set_checkin_count(cnt)
		self._user:update_db("tg_users", 7)
		local mcnt = set._user.checkin_mcount.value
		mcnt = mcnt + 1
		self._user:set_checkin_mcount(mcnt)
		self._user:update_db("tg_users", 8)
	end
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:toast1(args, msg, sz, ... )
	-- body
	return skynet.call(".ONLINE_MGR", "lua", "toast1", args)
end

function REQUEST:toast2(args, msg, sz, ... )
	-- body
	return skynet.call(".ONLINE_MGR", "lua", "toast2", args)
end

function REQUEST:fetchinbox(args, ... )
	-- body
	local M = self.modules.inbox
	return M:fetch(args)
end

function REQUEST:syncsysmail(args, ... )
	-- body
	return self._sysinbox:sync(args)
end

function REQUEST:viewedsysmail(args, ... )
	-- body
	local entity = self:get_entity()
	local sysinbox = entity:get_component("sysinbox")
	return sysinbox:viewed(args)
end

function REQUEST:records(args, ... )
	-- body
	-- local M = self.modules.recordmgr
	-- return M:records(args)
end

----------------------room----------------------------------
function REQUEST:ready(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("ready", args, ...)
end

function REQUEST:lead(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("lead", args, ...)
end

function REQUEST:call(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("call", args, ...)
end

function REQUEST:shuffle(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("shuffle", args, ...)
end

function REQUEST:dice(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("dice", args, ...)
end

function REQUEST:step(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("step", args, ...)
end

function REQUEST:restart(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("restart", args, ...)
end

function REQUEST:rchat(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("rchat", args, ...)
end

function REQUEST:xuanpao(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("xuanpao", args, ...)
end

function REQUEST:xuanque(args, ... )
	-- body
	local M = self.systems.room
	return M:forward_room("xuanque", args, ...)
end

return REQUEST
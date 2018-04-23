local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"
local errorcode = require "errorcode"

local CMD = {}

function CMD:start(_, reload, ... )
	-- body
	return self:start(reload, ... )
end

function CMD:close(source, ... )
	-- body
	self:close()
	return true
end

function CMD:kill(source, ... )
	-- body
	skynet.exit()
	return noret
end

-- called by gated
function CMD:login(source, gate, uid, subid, secret, ... )
	-- body
	local ok, err = xpcall(self.login, debug.msgh, self, gate, uid, subid, secret)
	if not ok then
		skynet.call(".AGENT_MGR", "lua", "exit_at_once", uid)
		return servicecode.LOGIN_AGENT_ERR
	end
	if err ~= servicecode.SUCCESS then	
		ok = skynet.call(".AGENT_MGR", "lua", "exit_at_once", uid)
		if not ok then
			log.error("call AGENT_MGR exit_at_once failture.")
		end
		return err
	end
	return err
end

-- prohibit mult landing
function CMD:logout(source)
	-- body
	return self:logout()
end

-- begain to wait for client
function CMD:auth(source, conf)
	self:auth(conf)
	return servicecode.SUCCESS
end

-- others serverce disconnect
function CMD:afk(source)
	-- body
	return self:afk()
end

function CMD:save_data()
	-- body
	local ok, err = pcall(self.save_data, self)
	if ok then
		return err
	else
		log.error(err)
		return servicecode.NORET
	end
end


----------------------------called by room------------------
function CMD:info(source, ... )
	-- body
	return { name="xiaomiao"}
end

function CMD:alter_rcard(source, args, ... )
	-- body
	local M = self.modules['user']
	return M:alter_rcard(args)
end

function CMD:room_over(source, ... )
	-- body
	self:set_room(nil)
end

function CMD:record(source, recordid, names, ... )
	-- body
	local r = self._recordmgr:create(recordid, names)
	self._recordmgr:add(r)
	r:insert_db()
end


----------------------------called by room------------------
function CMD:online(source, args, ... )
	-- body
	self:send_request("online", args)
	return errorcode.NORET
end

function CMD:offline(source, args, ... )
	-- body
	self:send_request("offline", args)
	return errorcode.NORET
end

function CMD:join(source, args, ... )
	-- body
	self:send_request("join", args)
	return errorcode.NORET
end

function CMD:leave(source, args, ... )
	-- body
	self:send_request("leave", args)
	return errorcode.NORET
end

function CMD:ready(source, args, ... )
	-- body
	self:send_request("ready", args)
	return errorcode.NORET
end

function CMD:deal(source, args, ... )
	-- body
	self:send_request("deal", args)
	return errorcode.NORET
end

function CMD:take_turn(source, args, ... )
	-- body
	self:send_request("take_turn", args)
	return errorcode.NORET
end

function CMD:peng(source, args, ... )
	-- body
	self:send_request("peng", args)
	return errorcode.NORET
end

function CMD:gang(source, args, ... )
	-- body
	self:send_request("gang", args)
	return errorcode.NORET
end

function CMD:hu(source, args, ... )
	-- body
	self:send_request("hu", args)
	return errorcode.NORET
end

function CMD:mcall(source, args, ... )
	-- body
	self:send_request("mcall", args)
	return errorcode.NORET
end

function CMD:ocall(source, args, ... )
	-- body
	self:send_request("ocall", args)
	return errorcode.NORET
end

function CMD:shuffle(source, args, ... )
	-- body
	self:send_request("shuffle", args)
	return errorcode.NORET
end

function CMD:dice(source, args, ... )
	-- body
	self:send_request("dice", args)
	return errorcode.NORET
end

function CMD:lead(source, args, ... )
	-- body
	self:send_request("lead", args)
	return errorcode.NORET
end

function CMD:over(source, args, ... )
	-- body
	self:send_request("over", args)
	return errorcode.NORET
end

function CMD:restart(source, args, ... )
	-- body
	self:send_request("restart", args)
	return errorcode.NORET
end

function CMD:take_restart(source, args, ... )
	-- body
	self:send_request("take_restart", args)
	return errorcode.NORET
end

function CMD:rchat(source, args, ... )
	-- body
	self:send_request("rchat", args)
	return errorcode.NORET
end

function CMD:take_xuanpao(source, args, ... )
	-- body
	self:send_request("take_xuanpao", args)
	return errorcode.NORET
end

function CMD:take_xuanque(source, args, ... )
	-- body
	self:send_request("take_xuanque", args)
	return errorcode.NORET
end

function CMD:xuanque(source, args, ... )
	-- body
	self:send_request("xuanque", args)
	return errorcode.NORET
end

function CMD:xuanpao(source, args, ... )
	-- body
	self:send_request("xuanpao", args)
	return errorcode.NORET
end

function CMD:settle(source, args, ... )
	-- body
	self:send_request("settle", args)
	return errorcode.NORET
end

function CMD:final_settle(source, args, ... )
	-- body
	self:send_request("final_settle", args)
	return errorcode.NORET
end

function CMD:roomover(source, args, ... )
	-- body
	self:send_request("roomover", args)
	return errorcode.NORET
end

return CMD
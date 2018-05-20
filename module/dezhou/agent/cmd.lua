local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"
local debug = debug

local CMD = {}

function CMD:start(reload, ... )
	-- body
	return self:start(reload, ... )
end

function CMD:close()
	-- body
	return self:close()
end

function CMD:kill()
	-- body
	assert(self)
	skynet.exit()
	return servicecode.NORET
end

-- called by gated
function CMD:login(gate, uid, subid, secret)
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
function CMD:logout()
	-- body
	return self:logout()
end

-- begain to wait for client
function CMD:auth(conf)
	return self:auth(conf)
end

-- others serverce disconnect
function CMD:afk()
	-- body
	return self:afk()
end

function CMD:save_data()
	-- body
	local ok, err = pcall(self.save_data, self)
	if not ok then
		log.error(err)
	end
end

----------------------------called by room------------------
function CMD:test()
	-- body
	assert(self)
	log.info('---------------------test')
end

function CMD:info()
	-- body
	assert(self)
	return { name="xiaomiao"}
end

function CMD:alter_rcard(args)
	-- body
	local M = self.modules['user']
	return M:alter_rcard(args)
end

function CMD:room_over()
	-- body
	self:set_room(nil)
end

function CMD:record(recordid, names)
	-- body
	local r = self._recordmgr:create(recordid, names)
	self._recordmgr:add(r)
	r:insert_db()
end

------------------------------------------
-- 协议代理
-- 下面全是协议代理
-- 一般系统代理
function CMD:online(args)
	-- body
	self:send_request("online", args)
	return servicecode.NORET
end

function CMD:offline(args)
	-- body
	self:send_request("offline", args)
	return servicecode.NORET
end

function CMD:join(args, ... )
	-- body
	self:send_request("join", args)
	return servicecode.NORET
end

function CMD:leave(args, ... )
	-- body
	self:send_request("leave", args)
	return servicecode.NORET
end

function CMD:ready(args, ... )
	-- body
	self:send_request("ready", args)
	return servicecode.NORET
end

function CMD:deal(args, ... )
	-- body
	self:send_request("deal", args)
	return servicecode.NORET
end

------------------------------------------
-- 麻将协议代理
function CMD:take_turn(args)
	-- body
	self:send_request("take_turn", args)
	return servicecode.NORET
end

function CMD:peng(args)
	-- body
	self:send_request("peng", args)
	return servicecode.NORET
end

function CMD:gang(args)
	-- body
	self:send_request("gang", args)
	return servicecode.NORET
end

function CMD:hu(args)
	-- body
	self:send_request("hu", args)
	return servicecode.NORET
end

function CMD:ocall(args)
	-- body
	self:send_request("ocall", args)
	return servicecode.NORET
end

function CMD:shuffle(args)
	-- body
	self:send_request("shuffle", args)
	return servicecode.NORET
end

function CMD:dice(args)
	-- body
	self:send_request("dice", args)
	return servicecode.NORET
end

function CMD:lead(args)
	-- body
	self:send_request("lead", args)
	return servicecode.NORET
end

function CMD:over(args)
	-- body
	self:send_request("over", args)
	return servicecode.NORET
end

function CMD:restart(args)
	-- body
	self:send_request("restart", args)
	return servicecode.NORET
end

function CMD:take_restart(args)
	-- body
	self:send_request("take_restart", args)
	return servicecode.NORET
end

-- function CMD:rchat(args)
-- 	-- body
-- 	self:send_request("rchat", args)
-- 	return servicecode.NORET
-- end

function CMD:take_xuanpao(args)
	-- body
	self:send_request("take_xuanpao", args)
	return servicecode.NORET
end

function CMD:xuanpao(args)
	-- body
	self:send_request("xuanpao", args)
	return servicecode.NORET
end

function CMD:take_xuanque(args)
	-- body
	self:send_request("take_xuanque", args)
	return servicecode.NORET
end

function CMD:xuanque(args)
	-- body
	self:send_request("xuanque", args)
	return servicecode.NORET
end

function CMD:settle(args)
	-- body
	self:send_request("settle", args)
	return servicecode.NORET
end

function CMD:final_settle(args)
	-- body
	self:send_request("final_settle", args)
	return servicecode.NORET
end

function CMD:mcall(args)
	-- body
	self:send_request("mcall", args)
	return servicecode.NORET
end

function CMD:take_card(args)
	-- body
end

function CMD:roomover(args)
	-- body
	self:send_request("roomover", args)
	return servicecode.NORET
end

------------------------------------------
-- 大佬2协议发送代理

function CMD:big2take_turn(args)
	-- body
	self:send_request_gate("big2take_turn", args)
	return servicecode.NORET
end

function CMD:big2call(args)
	-- body
	self:send_request_gate("big2call", args)
	return servicecode.NORET
end

function CMD:big2shuffle(args)
	-- body
	self:send_request_gate("big2shuffle", args)
	return servicecode.NORET
end

function CMD:big2lead(args)
	-- body
	self:send_request_gate("big2lead", args)
	return servicecode.NORET
end

function CMD:big2deal(args)
	-- body
	self:send_request_gate("big2deal", args)
	return servicecode.NORET
end

function CMD:big2ready(args)
	-- body
	self:send_request_gate("big2ready", args)
	return servicecode.NORET
end

function CMD:big2over(args)
	-- body
	self:send_request_gate("big2ready", args)
	return servicecode.NORET
end

function CMD:big2restart(args)
	-- body
	self:send_request_gate("big2restart", args)
	return servicecode.NORET
end

function CMD:big2take_restart(args)
	-- body
	self:send_request_gate("big2take_restart", args)
	return servicecode.NORET
end

function CMD:big2settle(args)
	-- body
	self:send_request_gate("big2settle", args)
	return servicecode.NORET
end

function CMD:big2final_settle(args)
	-- body
	self:send_request_gate("big2final_settle", args)
	return servicecode.NORET
end

return CMD
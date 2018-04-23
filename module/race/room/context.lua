local skynet = require "skynet"
local context = require "context"
local errorcode = require "errorcode"
local horse_mgr = require "room.horse_mgr"
local player_mgr = require "room.player_mgr"
local desk = require "room.desk"
local gamemode = require "configs.gamemode"

local cls = class("context")

cls.MAX_DESK_NUM = 5

function cls:ctor(id, ... )
	-- body
	self._id = id
	self._horse_mgr = horse_mgr.new()
	self._player_mgr = player_mgr.new()
	self._uplayers = {}
	self._uplayers_sz = 0

	self._desks = {}
	for i=1,cls.MAX_DESK_NUM do
		local d = desk.new(self, i)
		table.insert(self._desks, d)
	end

	skynet.fork(function ( ... )
		-- body
		self:update()
		skynet.sleep(100)
	end)
end

function cls:push_client(name, args, ... )
	-- body
	for _,v in pairs(self._playeres) do
		local agent = v:get_agent()
		skynet.send(agent, "lua", name, args)
	end
end

function cls:get_horse_mgr( ... )
	-- body
	return self._horse_mgr
end

-- event
function cls:start(args, mode, ... )
	-- body
	for _,v in pairs(args) do
		local uid = v.uid
		local agent = 1
	end
	local x = 1
	self._gate = gate
	self._max_number = max
	-- load map id
	
	return true
end

function cls:close( ... )
	-- body
	for _,user in pairs(users) do
		gate.req.unregister(user.session)
	end
	return true
end

function cls:update(delta, k, ... )
	-- body
	for i=1,cls.MAX_DESK_NUM do
		self._desks[i]:update()
	end
end

-- protocol
function cls:join(uid, agent, ... )
	-- body
	assert(uid and agent)
	local obj = self._player_mgr:create_player()
	obj:set_uid(uid)
	obj:set_agent(agent)
	self._uplayers[uid] = obj
	self._uplayers_sz = self._uplayers_sz + 1

	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function cls:leave(uid, ... )
	-- body
	assert(uid)
	if self._uplayers_sz > 0 then
		local obj = self._uplayers[uid]
		if obj then
			self._uplayers[uid] = nil
			self._players_sz = self._players_sz - 1
			local res = {}
			res.errorcode = errorcode.SUCCESS
			return res
		end
	end
	local res = {}
	res.errorcode = errorcode.FAIL
	return res
end



function cls:addsp(session, player, ... )
	-- body
	self._splayers[session] = player
	self._splayers_sz = self._splayers_sz + 1
end

function cls:remove(session, ... )
	-- body
	assert(session)
	if self._splayers[session] then
		self._splayers[session] = nil
		self._splayers_sz = self._splayers_sz -1
	end
end

function cls:getsp(session, ... )
	-- body
	return self._splayers[session]
end

function cls:getsp_sz( ... )
	-- body
	return self._splayers_sz
end

function cls:addup(uid, player, ... )
	-- body
	self._uplayers[uid] = player
	self._uplayers_sz = self._uplayers_sz + 1
end

function cls:removeup(uid, ... )
	-- body
	assert(uid)
	if self._uplayers[uid] then
		self._uplayers[uid] = nil
		self._uplayers_sz = self._uplayers_sz + 1
	end
end

function cls:getup(uid, ... )
	-- body
	return self._uplayers[uid]
end

function cls:getup_sz( ... )
	-- body
	return self._uplayers_sz
end



function cls:broadcast_die(args, ... )
	-- body
	for k,v in pairs(self._session_players) do
		local agent = v:get_agent()
		agent.post.die(args)
	end
end

function cls:is_maxnum( ... )
	-- body
	return (self._players_sz >= self._max_number)
end

function cls:set_stime(v, ... )
	-- body
	self._stime = v
end

function cls:get_stime( ... )
	-- body
	return self._stime
end

return cls
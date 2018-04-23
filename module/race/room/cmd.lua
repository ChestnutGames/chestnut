local skynet = require "skynet"
local player_mgr = require "player_mgr"

local CMD = {}

function CMD:start(args, ... )
	-- body
	self:start(gate, max)

	return true
end

function CMD:close( ... )
	-- body
	
	return true
end

function CMD:kill( ... )
	-- body
	skynet.exit()
end

function CMD:join(uid, agent)
	return self:join(uid, agent)
end

function CMD:leave(session)
	local gate = ctx:get_gate()
	skynet.call(gate, "lua", "unregister", session)

	return true
	
	-- local scene = ctx:get_scene()
	-- local session_players = ctx:get_players()
	-- local player = session_players[session]
	-- local balls = player:get_balls()
	-- for k,v in pairs(balls) do
	-- 	scene:leave(v:get_id())
	-- end
	-- for k,v in pairs(session_players) do
	-- 	if k ~= session then
	-- 		local agent = v.agent
	-- 		agent.post.leave({ session = session })
	-- 	end
	-- end
	-- gate.req.unregister(session)
	-- ctx:remove(session)
end

function CMD:query(session)
	local user = users[session]
	-- todo: we can do more
	if user then
		return user.agent.handle
	end
end

return _M
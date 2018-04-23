local skynet = require "skynet"
local errorcode = require "errorcode"
local M = require "module"

local cls = class("user", M)

function cls:ctor(env, ... )
	-- body
	cls.super.ctor(self, env)

end

function cls:enrol(payload, ... )
	-- body
	return skynet.call(".MATCH", "lua", "enrol", payload.modetype)
end

return cls
package.path = "./module/ballroom/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local crypt = require "skynet.crypt"
local log = require "chestnut.skynet.log"

local context = require "ballroom.context"
local CMD = require "ballroom.cmd"

-- context variable
local id = tonumber( ... )
local ctx

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		local r = f(ctx, subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)

	ctx = context.new(id)
	
	-- local aoi = skynet.newservice("aoi")
	-- local battle = skynet.launch("battle")

	-- ctx:set_aoi(aoi)
	-- ctx:set_battle(battle)
end)


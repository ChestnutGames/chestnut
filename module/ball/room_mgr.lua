local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local queue = require "chestnut.queue"


local index = 0
local q
local rooms = {}

local function incre_room( ... )
	-- body
	local size = 10
	for i=1,size do
		local id = index + i
		local addr = skynet.newservice("room/room", id)
		rooms[id] = { addr=addr, id=id}
		q:enqueue(id)
	end
	index = index + size
end

local CMD = {}

function CMD.start( ... )
	-- body
	q = queue()
	incre_room()
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
end

function CMD.enter( ... )
	-- body
	if #q > 0 then
		return q:dequeue()
	else
		incre_room()
		return q:dequeue()
	end
end

function CMD.exit(id, ... )
	-- body
	q:enqueue(id)
end

function CMD.apply(id, ... )
	-- body
	assert(id)
	local r = rooms[id]
	if r then
		return assert(r.addr)
	else
		log.error("not exist")
		return 0
	end
end

-- todo : close room ?

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = CMD[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".ROOM_MGR"
end)


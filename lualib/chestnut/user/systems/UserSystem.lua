local log = require "chestnut.skynet.log"

local CLS_NAME = "user"

local cls = class(CLS_NAME)

function cls:ctor(context)
	-- body
	self.agentContext = context
	self.agentSystems = nil
	self.dbAccount = {}
	self.dbUser = {}
end

function cls:set_agent_systems(systems, ... )
	-- body
	self.agentSystems = systems
end

function cls:on_data_init(dbData)
	
end

function cls:on_data_save(dbData, ... )
	
end

function cls:first()
	-- body

	local res = {}
	res.errorcode = 0
	res.nickname  = assert(self.dbUser.nickname)
	return res
end

return cls
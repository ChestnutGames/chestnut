local cls = class("ahievement")

function cls:ctor(context, ... )
	-- body
	cls.super.ctor(self, context)
end

function cls:set_agent_systems(systems, ... )
	-- body
	self.agentSystems = systems
end

function cls:on_data_init(dbData)
	-- body
	assert(dbData ~= nil)
	assert(dbData.db_users ~= nil)
	assert(#dbData.db_users == 1)

	return true
end

function cls:on_data_save(dbData, ... )
	-- body
	assert(dbData ~= nil)

	return true
end

return cls
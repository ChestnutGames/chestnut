
local cls = class("task")

function cls:ctor(context, ... )
	-- body
	cls.super.ctor(self, context)
	self.agentContext = context
	self.agentSystems = nil
	self.dbTask = nil
	
	return self
end


return cls
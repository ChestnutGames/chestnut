
local cls = class("task")

function cls:ctor(context, ... )
	-- body
	cls.super.ctor(self, context)
	
	return self
end


return cls
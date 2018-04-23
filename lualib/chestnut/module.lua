local cls = class("module")

function cls:ctor(context, ... )
	-- body
	assert(context)
	self.context = context
	return self
end

function cls:start( ... )
	-- body
end

function cls:clean( ... )
	-- body
end

function cls:reset( ... )
	-- body
end

function cls:login( ... ) 
end

function cls:logout( ... )
	-- body
end

function cls:auth( ... )
	-- body
end

function cls:afk( ... )
	-- body
end

function cls:load_cache_to_data( ... )
	-- body
end

function cls:inituser( ... )
	-- body
end

return cls
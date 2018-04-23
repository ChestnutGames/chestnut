local util = require "chestnut.time"

local cls = class("db")

function cls:ctor(context, ... )
	-- body
	cls.super.ctor(self, context)

	self.db = nil

	return self
end

function cls:start( ... )
	-- body
	self.db = util.connect_redis()
end

function cls:close( ... )
	-- body
	self.db:disconnect()
end

return cls
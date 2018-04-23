local log = require "chestnut.skynet.log"
local query = require "chestnut.query"
local errorcode = require "errorcode"
local dbmonitor = require "dbmonitor"

local CLS_NAME = "user"

local cls = class(CLS_NAME)

function cls:ctor(context, ... )
	-- body
	cls.super.ctor(self, context)
	self._tname = "tb_user"

	self.t = {}
end

function cls:set_uid(value, ... )
	-- body
	self.uid:set_value(value)
end

function cls:set_nameid(value, ... )
	-- body
	self.name:set_value(value)
end

function cls:set_age(value, ... )
	-- body
	self.age:set_value(value)
end

function cls:set_gold(value, ... )
	-- body
	self.gold:set_value(value)
end

function cls:set_diamond(value, ... )
	-- body
	self.diamond:set_value(value)
end

function cls:set_checkin_month(value, ... )
	-- body
	self.checkin_month:set_value(value)
end

function cls:set_checkin_count(value, ... )
	-- body
	self.checkin_count:set_value(value)
end

function cls:set_checkin_mcount(value, ... )
	-- body
	self.checkin_mcount:set_value(value)
end

function cls:set_checkin_lday(value, ... )
	-- body
	self.checkin_lday:set_value(value)
end

function cls:set_rcard(value, ... )
	-- body
	self.rcard:set_value(value)
end

function cls:set_name(value, ... )
	-- body
	self.name = value
end

function cls:load_cache_to_data( ... )
	-- body
	local db            = self.context.modules.db.db
	local uid           = self.context.uid

	local r = {}
	r.rcard             = math.tointeger(db:get(string.format("tb_user:%d:rcard", uid)))
	r.sex               = math.tointeger(db:get(string.format("tb_user:%d:sex", uid)))
	r.nickname          = db:get(string.format("tb_user:%d:nickname", uid))
	r.province          = db:get(string.format("tb_user:%d:province", uid))
	r.city              = db:get(string.format("tb_user:%d:city",     uid))
	r.country           = db:get(string.format("tb_user:%d:country",  uid))
	r.headimg           = db:get(string.format("tb_user:%d:headimg",  uid))
	r.nameid            = db:get(string.format("tb_user:%d:nameid",   uid))
	self.t = r
end

function cls:first(args, ... )
	-- body
	local r = self.t

	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.name   = r.nickname
	res.nameid = r.nameid
	res.rcard  = r.rcard
	res.sex    = r.sex

	log.info("name = %s", res.name)
	log.info("nameid = %s", res.nameid)
	log.info("rcard = %d", res.rcard)
	log.info("sex = %d", res.sex)
	return res
end

function cls:alter_rcard(value, ... )
	-- body
	assert(value == -1)
	self.t.rcard = self.t.rcard + value
	return true
end

return cls
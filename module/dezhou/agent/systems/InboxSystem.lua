local skynet = require "skynet"
local sd = require "skynet.sharedata"
local snowflake = require "chestnut.snowflake"
local log = require "chestnut.skynet.log"
local zset = require "chestnut.zset"
local query = require "chestnut.query"
local sysmaild = require "sysmaild"

local CLS_NAME = "inbox"

local cls = class(CLS_NAME)

function cls:ctor(context, ... )
	-- body
	cls.super.ctor(self, context)

	self._tname = "tb_user_inbox"
	self._mk = {}
	self._mkzs = zset.new()
	self._vals = {}
	return self
end

function cls:login( ... )
	-- body

end

function cls:load_cache_to_data( ... )
	local db = self.context.modules.db.db
	local uid = self.context.uid

	local keys = db:zrange(string.format('tb_user_inbox:%d', uid), 0, -1)
	if keys then
		for _,id in pairs(keys) do
			local key = string.format("%s:%d:%d", self._tname, uid, id)
			local val = db:hgetall(key)
			self._mk[math.tointeger(val.id)] = val
		end
	end
end

function cls:inituser( ... )
	-- body
	self:send_inbox_list()
end

function cls:add(mail, ... )
	-- body
	table.insert(self._data, mail)
	self._count = self._count + 1
	self._mk[mail.mailid.value] = mail
	self._mkzs:add(1, string.format("%d", mail.id.value))
end

function cls:poll( ... )
	-- body
	skynet.fork(function ( ... )
		-- body
		-- local res
		-- if self._count > 0 then
		-- 	res = sysmaild.poll(self._mkzs:range(self._mkzs:count() - 1, self._mkzs:count())[1])	
		-- else
		-- 	res = sysmaild.poll(0)
		-- end

		-- log.info("sysinbox poll %d", #res)
		-- for _,mailid in pairs(res) do
		-- 	local i = sysmail.new(self._env, self._dbctx, self)

		-- 	i.id.value = snowflake.next_id()
		-- 	i.uid.value = self._env._suid
		-- 	i.mailid.value = math.tointeger(mailid)
		-- 	i.viewed.value = 0
		-- 	i:insert_cache()

		-- 	self:add(i)
		-- end
	end)
end

function cls:send_inbox_list( ... )
	-- body
	local l = {}
	for _,v in pairs(self._mk) do
		if v.viewed.value == 0 then
			local mail = {}
			mail.id       = v.mailid
			mail.viewed   = v.viewed
			mail.title    = t.title
			mail.content  = t.content
			mail.datetime = t.datetime
			table.insert(l, mail)
		end
	end

	local args = {}
	args.l = l
	self.context:send_request("inbox", args)
end

function cls:send_inbox(id, ... )
	-- body
	local v = assert(self._mk[id])
	local l = {}
	local mail = {}
	mail.id       = v.mailid
	mail.viewed   = v.viewed
	mail.title    = t.title
	mail.content  = t.content
	mail.datetime = t.datetime
	table.insert(l, mail)
	local args = {}
	args.l = l
	self.context:send_request("inbox", args)
end

function cls:fetch(args, ... )
	-- body
	log.info("sysinbox fetch")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.inbox = {}
	for k,v in pairs(self._mk) do
		if v.viewed.value == 0 then
			local mail = {}
			mail.id = v.mailid.value
			mail.viewed = v.viewed.value
			local t = sd.query(string.format("%s:%d", self._tname, v.mailid))
			mail.title    = t.title
			mail.content  = t.content
			mail.datetime = t.datetime
			table.insert(res.inbox, mail)
		end
	end
	return res
end

function cls:sync(args, ... )
	-- body
	log.info("sysinbox sync")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.inbox = {}
	for k,v in pairs(self._data) do
		if v.viewed.value == 0 then
			local mail = {}
			mail.id = v.mailid.value
			mail.datetime = v.datetime.value
			mail.viewed = v.viewed.value
			local t = sd.query(string.format("tg_sysmail:%d", v.mailid.value))
			mail.title   = t.title
			mail.content = t.content
			table.insert(res.inbox, mail)
		end
	end
	return res
end

function cls:viewed(args, ... )
	-- body
	local mail = self._mk[args.mailid]
	mail:set_viewed(1)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

return cls
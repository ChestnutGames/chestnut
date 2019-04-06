local ds = require "skynet.datasheet"
local log = require "chestnut.skynet.log"

local CLS_NAME = "func_open"

local cls = class(CLS_NAME)

function cls:ctor(context)
	-- body
	self.agentContext = context
	self.agentSystems = nil
	self.dbFuncopen = {}
end

function cls:set_agent_systems(systems)
	-- body
	self.agentSystems = systems
end

function cls:on_data_init(dbData)
	-- body
	assert(dbData ~= nil)
	assert(dbData.db_user_funcopens ~= nil and #dbData.db_user_funcopens > 0)
	assert(component and seg)
	local funcs = {}
	for _,db_item in pairs(seg) do
		local item = {}
		item.id = assert(db_item.id)
		item.open = assert(db_item.open)
		item.createAt = assert(db_item.create_at)
		item.updateAt = assert(db_item.update_at)
		funcs[tonumber(item.id)] = item
	end

	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local funcopen = ds.query('funcopen')
	for _,v in pairs(funcopen) do
		if not entity.funcopen.funcs[v.id] then
			local item = {}
			item.id   = assert(v.id)
			item.open = 0
			item.createAt = os.time()
			item.updateAt = os.time()
			entity.funcopen.funcs[item.id] = item
		end
	end

	-- 检查应该开启而没有开启的
	self:on_level_open()
end

function cls:on_data_save(dbData, ... )
	-- body
	assert(dbData ~= nil)

	-- save user
	dbData.db_user_funcopens = {}
	for _,item in pairs(self.dbFuncopen) do
		-- print(k, item)
		local db_item = {}
		db_item.uid = assert(self.agentContext.uid)
		db_item.id  = assert(item.id)
		db_item.open = assert(item.open)
		db_item.create_at = assert(item.createAt)
		db_item.update_at = os.time()
		table.insert(dbData.db_user_funcopens, db_item)
	end
	return true
end

function cls:on_level_open()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local funcopen = ds.query('funcopen')
	for _,v in pairs(funcopen) do
		if v.opentype == 1 then
			local id = assert(v.id)
			local func = entity.funcopen.funcs[id]
			if func.open == 0 then
				if entity.user.level >= v.level then
					self:on_func_open(id)
					func.open = 1
				end
			end
		end
	end
end

function cls:on_func_open(id)
	-- body
	if id == 1 then
		self.agentSystems.package:on_func_open()
	elseif id == 2 then
		self.agentSystems.room:on_func_open()
	end
end

function cls:is_open(id)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local funcs = entity.funcopen.funcs
	local func = funcs[id]
	if func and (func.open == 1) then
		return true
	else
		return false
	end
end

return cls
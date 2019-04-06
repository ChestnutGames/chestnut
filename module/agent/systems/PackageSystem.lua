local log = require "chestnut.skynet.log"
local UserComponent = require "components.UserComponent"
local PackageType = require "def.PackageType"
local ds = require "skynet.datasheet"

local CLS_NAME = "package"

local cls = class(CLS_NAME)

function cls:ctor(context)
	-- body
	self.agentContext = context
	self.agentSystems = nil
	self.dbPackages = {}
end

function cls:_increase(pt, id, num)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = assert(entity.package.packages[pt])
	if not package[id] then
		package[id] = { id = id, num = 0, createAt=os.time(), updateAt=os.time() }
	end
	package[id].num = package[id].num + num
	-- 增加道具
	local item = { id=id, num=num }
	self.agentContext:send_request("add_item", { i = item })
	return true
end

function cls:_decrease(pt, id, num)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = assert(entity.package.packages[pt])
	if not package[id] then
		package[id] = { id = id, num = 0, createAt=os.time(), updateAt=os.time() }
	end
	local item = package[id]
	if item.num >= num then
		item.num = item.num - num
		local item = { id=id, num=num }
		self.agentContext:send_request("sub_item", { i = item })
	else
		log.error('not enought item, num is %d, need %d', item.num, num)
		return false
	end
	return true
end

function cls:set_agent_systems(systems)
	-- body
	self.agentSystems = systems
end

function cls:on_data_init(dbData)
	-- body
	local package = {}
	for _,db_item in pairs(seg) do
		local item = {}
		item.id = assert(db_item.id)
		item.num = assert(db_item.num)
		item.createAt = assert(db_item.create_at)
		item.updateAt = assert(db_item.update_at)
		package[tonumber(item.id)] = item
	end
	self.dbPackages[PackageType.COMMON] = package
end

function cls:on_data_save(dbData, ... )
	-- body
	assert(dbData ~= nil)
	local seg = self.dbPackages[PackageType.COMMON]
	local package = {}
	for _,db_item in pairs(seg) do
		local item = {}
		item.id = assert(db_item.id)
		item.num = assert(db_item.num)
		item.createAt = assert(db_item.create_at)
		item.updateAt = assert(db_item.update_at)
		package[tonumber(item.id)] = item
	end
	dbData.db_user_package = package
end

function cls:on_func_open()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	entity.package.packages = {}
	entity.package.packages[PackageType.COMMON] = {}
	entity.package.packages[PackageType.COMMON][1] = { id=1, num=113, createAt=os.time(), updateAt=os.time() }   -- 砖石
	entity.package.packages[PackageType.COMMON][2] = { id=2, num=113, createAt=os.time(), updateAt=os.time() }   -- 金币
	entity.package.packages[PackageType.COMMON][3] = { id=3, num=1, createAt=os.time(), updateAt=os.time() }     -- 经验
	entity.package.packages[PackageType.COMMON][4] = { id=4, num=100, createAt=os.time(), updateAt=os.time() }   -- 门票
end

function cls:check_consume(id, value)
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local itemConfig = ds.query('item')[string.format("%d", id)]
	local package = entity.package.packages[itemConfig.type]
	assert(package)
	local item = package[id]
	if item.num < value then
		return false
	end
	return true
end

function cls:consume(id, value)
	-- body
	if not self:check_consume(id, value) then
		return false
	end
	local itemConfig = ds.query('item')[string.format("%d", id)]
	return self:_decrease(itemConfig.type, id, value)
end

function cls:rcard_num()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = entity.package.packages[PackageType.COMMON]
	assert(package)
	local item = package[4]
	if not item then
		item = { id = 4, num = 0 }
		package[4] = item
	end
	return item.num
end

function cls:package_info()
	-- body
	local uid = self.agentContext.uid
	local index = self.context:get_entity_index(UserComponent)
	local entity = index:get_entity(uid)
	local package = entity.package.packages[PackageType.COMMON]
	assert(package)
	local all = {}
	for _,v in pairs(package) do
		local item = { id=v.id, num=v.num}
		table.insert(all, item)
	end
	local res = {
		errorcode = 0,
		all = all
	}
	return res
end

return cls
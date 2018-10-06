local assert = assert
local PackageType = require "def.PackageType"
local _M = {}

function _M.pack_account_component(component)
	-- body
	assert(component.uid ~= nil)
	-- assert(component.age ~= nil)
	assert(component.sex ~= nil)
	assert(component.nickname ~= nil)
	assert(component.province ~= nil)
	assert(component.city     ~= nil)
	assert(component.country  ~= nil)
	assert(component.headimg  ~= nil)
	assert(component.create_time ~= nil)
	assert(component.login_times ~= nil)
	local seg = {}
	seg.uid      = component.uid
	-- seg.age      = component.age
	seg.sex      = component.sex
	seg.nickname = component.nickname
	seg.province = component.province
	seg.city     = component.city
	seg.country  = component.country
	seg.headimg  = component.headimg
	seg.create_time = component.create_time
	seg.login_times = component.login_times
	return seg
end

function _M.pack_user_component(component)
	-- body
	assert(component.uid ~= nil)
	local db_user = {}
	db_user.uid            = component.uid
	db_user.sex            = component.sex
	db_user.nickname       = component.nickname
	db_user.province       = component.province
	db_user.city           = component.city
	db_user.country        = component.country
	db_user.headimg        = component.headimg
	db_user.openid         = component.openid
	db_user.nameid         = component.nameid
	db_user.create_at      = component.createAt
	db_user.update_at = component.updateAt
	db_user.login_at  = component.loginAt
	db_user.new_user  = component.newUser
	db_user.level     = component.level
	return db_user
end

function _M.pack_package_component(component, uid)
	-- body
	local db_package = {}
	local package = assert(component.packages[PackageType.COMMON])
	for _,item in pairs(package) do
		local db_item = {}
		db_item.uid = assert(uid)
		db_item.id  = assert(item.id)
		db_item.num = assert(item.num)
		db_item.create_at = assert(item.createAt)
		db_item.update_at = os.time()
		table.insert(db_package, db_item)
	end
	return db_package
end

function _M.pack_room_component(component, uid)
	-- body
	assert(component.isCreated ~= nil)
	assert(component.joined ~= nil)
	assert(component.id ~= nil)
	assert(uid)
	local db_user_room = {}
	db_user_room.uid = uid
	db_user_room.created   = component.isCreated and 1 or 0
	db_user_room.roomid    = component.id
	db_user_room.joined    = component.joined and 1 or 0
	db_user_room.mode      = assert(component.mode)
	db_user_room.create_at = assert(component.createAt)
	db_user_room.update_at = assert(component.updateAt)
	return db_user_room
end

function _M.pack_funcopen_component(component, uid)
	-- body
	local db_funcopens = {}
	local funcs = assert(component.funcs)
	for k,item in pairs(funcs) do
		-- print(k, item)
		local db_item = {}
		db_item.uid = assert(uid)
		db_item.id  = assert(item.id)
		db_item.open = assert(item.open)
		db_item.create_at = assert(item.createAt)
		db_item.update_at = os.time()
		table.insert(db_funcopens, db_item)
	end
	return db_funcopens
end

return _M
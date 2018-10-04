-- local log = require "chestnut.skynet.log"
local PackageType = require "def.PackageType"
local assert = assert
local _M = {}

function _M.unpack_account_component(component, seg)
	-- body
	assert(component and seg)
	component.uid = seg.uid
	component.gold = seg.gold
	component.diamond = seg.diamond
	component.checkin_month = seg.checkin_month
	component.checkin_count = seg.checkin_count
	component.checkin_mcount = seg.checkin_mcount
	component.checkin_lday = seg.checkin_lday
	component.rcard = seg.rcard
	component.sex = seg.sex
	component.nickname = seg.nickname
	component.province = seg.province
	component.city     = seg.city
	component.country  = seg.country
	component.headimg  = seg.headimg
	component.openid   = seg.openid
	component.nameid   = seg.nameid
	component.create_time = seg.create_time
	component.login_times = seg.login_times
	return true
end

function _M.unpack_user_component(component, seg)
	-- body
	assert(component and seg)
	component.uid      = seg.uid
	component.sex      = assert(seg.sex)
	component.nickname = assert(seg.nickname)
	component.province = assert(seg.province)
	component.city     = assert(seg.city)
	component.country  = seg.country
	component.headimg  = seg.headimg
	component.openid   = seg.openid
	component.nameid   = seg.nameid
	component.createAt = seg.create_at
	component.updateAt = assert(seg.update_at)
	component.loginAt  = assert(seg.login_at)
	component.newUser  = assert(seg.new_user)
	component.level    = assert(seg.level)
	return true
end

function _M.unpack_package_component(component, seg)
	-- body
	assert(component and seg)
	local package = {}
	for _,db_item in pairs(seg) do
		local item = {}
		item.id = assert(db_item.id)
		item.num = assert(db_item.num)
		item.createAt = assert(db_item.create_at)
		item.updateAt = assert(db_item.update_at)
		package[tonumber(item.id)] = item
	end
	component.packages[PackageType.COMMON] = package
	return true
end

function _M.unpack_room_component(component, seg)
	-- body
	assert(component)
	assert(seg)
	component.isCreated = (assert(seg.created) == 1) and true or false
	component.joined    = (assert(seg.joined) == 1) and true or false
	component.id        = assert(seg.roomid)
	component.mode      = assert(seg.mode)
	component.createAt  = assert(seg.create_at)
	component.updateAt  = assert(seg.update_at)
	return true
end

function _M.unpack_funcopen_component(component, seg)
	-- body
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
	component.funcs = funcs
	return true
end

return _M
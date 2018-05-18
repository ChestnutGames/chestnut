local assert = assert
local _M = {}

function _M.pack_account_component(component, ... )
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
	return true, seg
end

function _M.pack_user_component(component, ... )
	-- body
	assert(component.uid ~= nil)
	local seg = {}
	seg.uid      = component.uid
	seg.gold     = component.gold
	seg.diamond  = component.diamond
	seg.checkin_month = component.checkin_month
	seg.checkin_count = component.checkin_count
	seg.checkin_mcount = component.checkin_mcount
	seg.checkin_lday = component.checkin_lday
	seg.rcard = component.rcard
	seg.sex = component.sex
	seg.nickname = component.nickname
	seg.province = component.province
	seg.city = component.city
	seg.country = component.country
	seg.headimg = component.headimg
	seg.openid = component.openid
	seg.nameid = component.nameid
	return true, seg
end

function _M.pack_package_component(component, ... )
	-- body
	local db_packages = {}
	for k,package in pairs(component.packages) do
		db_package = {}
		for k,v in pairs(package) do
			db_package[string.format("%d", k)] = v
		end
		db_packages[string.format("%d", k)] = db_package
	end
	local seg = {}
	seg.packages = db_packages
	return true, seg
end

function _M.pack_room_component(component, ... )
	-- body
	assert(component.isCreated ~= nil)
	assert(component.joined ~= nil)
	assert(component.id ~= nil)
	local seg = {}
	seg.isCreated = component.isCreated
	seg.id        =	component.id
	seg.joined    = component.joined
	return true, seg
end

return _M
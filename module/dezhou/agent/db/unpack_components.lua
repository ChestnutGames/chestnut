-- local log = require "chestnut.skynet.log"
local assert = assert
local _M = {}

function _M.unpack_account_component(component, seg, ... )
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

function _M.unpack_user_component(component, seg, ... )
	-- body
	assert(component and seg)
	component.uid      = seg.uid
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

function _M.unpack_package_component(component, seg, ... )
	-- body
	assert(component and seg)
	local db_packages = {}
	for k,package in pairs(seg.packages) do
		local db_package = {}
		for k,v in pairs(package) do
			db_package[tonumber(k)] = v
		end
		db_packages[tonumber(k)] = db_package
	end
	component.packages = db_packages
	return true
end

function _M.unpack_room_component(component, seg, ... )
	-- body
	assert(component and seg)
	if seg.isCreated == nil then
		seg.isCreated = false
	end
	if seg.joined == nil then
		seg.joined = false
	end
	if seg.id == nil then
		seg.id = 0
	end
	component.isCreated = seg.isCreated
	component.joined = seg.joined
	component.id = seg.id
	return true
end



return _M
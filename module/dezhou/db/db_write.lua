local log = require "chestnut.skynet.log"
local string_format = string.format
local _M = {}

function _M:write_user(db_user)
	local sql = string_format([==[CALL
		sp_user_insert_or_update (%d, %d, %d, %d, %d, %d, %d, %d, %d, '%s', '%s', '%s', '%s', '%s', '%s', '%s');]==],
		db_user.uid, db_user.gold, db_user.diamond, db_user.checkin_month, db_user.checkin_count,
		db_user.checkin_mcount, db_user.checkin_lday,
		db_user.rcard, db_user.sex, db_user.nickname, db_user.province,
		db_user.city, db_user.country, db_user.headimg, db_user.openid, db_user.nameid)
	-- log.info(sql)
	local res = self.db:query(sql)
	if res.errno then
		log.info(self.dump(res))
	end
	return res
end

function _M:write_room_mgr_users(db_users)
	-- body
	for _,db_user in pairs(db_users) do
		local sql = string_format([==[CALL
		sp_room_mgr_users_insert_or_update(%d, %d);]==],
		db_user.uid, db_user.roomid)
		-- log.info(sql)
		local res = self.db:query(sql)
		if res.errno then
			log.info(self.dump(res))
		end
	end
	return true
end

function _M:write_room_mgr_rooms(db_rooms)
	-- body
	for _,db_room in pairs(db_rooms) do
		local sql = string_format([==[CALL
		sp_room_mgr_rooms_insert_or_update(%d, %d);]==],
		db_room.id, db_room.host)
		-- log.info(sql)
		local res = self.db:query(sql)
		if res.errno then
			log.info(self.dump(res))
		end
	end
	return true
end

function _M:write_room_users(db_users)
	-- body
	for _,db_user in pairs(db_users) do
		local sql = string_format([==[CALL
		sp_room_users_insert_or_update(%d, %d, %d);]==],
		db_user.uid, db_user.roomid, db_user.state)
		-- log.info(sql)
		local res = self.db:query(sql)
		if res.errno then
			log.info(self.dump(res))
		end
	end
	return true
end

function _M:write_room(db_room)
	-- body
	local sql = string_format([==[CALL
	sp_room_insert_or_update(%d, %d, %d);]==],
	db_room.id, db_room.host)
	-- log.info(sql)
	local res = self.db:query(sql)
	if res.errno then
		log.info(self.dump(res))
	end
	return true
end

return _M
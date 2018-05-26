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

function _M:write_user_room(db_user_room)
	-- body
	local sql = string_format([==[CALL
	sp_user_room_insert_or_update(%d, %d, %d, %d);]==],
	db_user_room.uid, db_user_room.roomid, db_user_room.created, db_user_room.joined)
	-- log.info(sql)
	local res = self.db:query(sql)
	if res.errno then
		log.info(self.dump(res))
	end
	return true
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
		sp_room_mgr_rooms_insert_or_update(%d, %d, '%s', %d);]==],
		db_room.id, db_room.host, db_room.users, db_room.ju)
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
		sp_room_users_insert_or_update(%d, %d, '%s', %d, %d);]==],
		db_user.uid, db_user.roomid, db_user.state, db_user.idx, db_user.chip)
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
	sp_room_insert_or_update(%d, %d, %d, %d, %d, %d, '%s', '%s');]==],
	db_room.id, db_room.host, db_room.open, db_room.firstidx, db_room.curidx, db_room.ju, db_room.state, db_room.laststate)
	-- log.info(sql)
	local res = self.db:query(sql)
	if res.errno then
		log.info(self.dump(res))
	end
	return true
end

------------------------------------------
-- 离线用户数据
function _M:write_offuser_room_created(db_user_room)
	-- body
	local sql = string_format([==[CALL
	sp_offuser_room_update_created(%d, %d);]==],
	db_user_room.uid, db_user_room.roomid, db_user_room.created, db_user_room.joined)
	-- log.info(sql)
	local res = self.db:query(sql)
	if res.errno then
		log.info(self.dump(res))
	end
	return true
end

return _M
local log = require "chestnut.skynet.log"
local string_format = string.format
local _M = {}

function _M.write_user(db, db_user)
	local sql = string_format([==[CALL
		sp_user_insert_or_update (%d, %d, %d, %d, %d, %d, %d, %d, %d, '%s', '%s', '%s', '%s', '%s', '%s', '%s');]==],
		db_user.uid, db_user.gold, db_user.diamond, db_user.checkin_month, db_user.checkin_count,
		db_user.checkin_mcount, db_user.checkin_lday,
		db_user.rcard, db_user.sex, db_user.nickname, db_user.province,
		db_user.city, db_user.country, db_user.headimg, db_user.openid, db_user.nameid)
	-- log.info(sql)
	local res = db:query(sql)
	return res
end

return _M
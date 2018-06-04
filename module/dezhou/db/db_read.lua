local log = require "chestnut.skynet.log"
local string_format = string.format

local _M = {}

function _M:read_sysmail()
	-- body
	local res = self.db:query('SELECT * FROM tb_sysmail;')
	return res
end

function _M:read_room_mgr_users()
	-- body
	local res = self.db:query("CALL sp_room_mgr_users_select();")
	if res.mulitresultset then
		return res[1];
	end
	return res
end

function _M:read_room_mgr_rooms()
	-- body
	local res = self.db:query('CALL sp_room_mgr_rooms_select();')
	if res.mulitresultset then
		return res[1];
	end
	return res
end

function _M:read_account_by_username(username, password)
	-- body
	local res = self.db:query(string.format("CALL sp_account_select('%s', '%s');", username, password))
	if res.mulitresultset then
		return res[1]
	else
		log.error(self.dump(res))
		return {}
	end
end

function _M:read_room(id)
	-- body
	local res = self.db:query(string_format("CALL sp_room_select(%d);", id))
	-- log.info(self.dump(res))
	if res.mulitresultset then
		return res[1]
	else
		log.error(self.dump(res))
		return {}
	end
end

function _M:read_room_users(id)
	-- body
	local res = self.db:query(string_format("CALL sp_room_users_select(%d);", id))
	-- log.info(self.dump(res))
	if res.mulitresultset then
		return res[1]
	else
		log.error(self.dump(res))
		return {}
	end
end

------------------------------------------
-- about user
function _M:read_user_by_uid(uid)
	-- body
	local res = self.db:query(string_format("CALL sp_user_select(%d);", uid))
	if res.mulitresultset then
		return res[1]
	end
	return res
end

function _M:read_user_room(uid)
	-- body
	local res = self.db:query(string_format("CALL sp_user_room_select(%d);", uid))
	-- log.info(self.dump(res))
	if res.mulitresultset then
		return res[1]
	else
		log.error(self.dump(res))
	end
	return res
end

function _M:read_user_package(uid)
	-- body
	local res = self.db:query(string_format("CALL sp_user_package_select(%d);", uid))
	-- log.info(self.dump(res))
	if res.mulitresultset then
		return res[1]
	else
		log.error(self.dump(res))
	end
	return res
end

function _M:read_user_funcopen(uid)
	-- body
	local res = self.db:query(string_format("CALL sp_user_funcopen_select(%d);", uid))
	-- log.info(self.dump(res))
	if res.mulitresultset then
		return res[1]
	else
		log.error(self.dump(res))
	end
	return res
end

return _M
local string_format = string.format

local _M = {}

function _M.read_sysmail(db)
	-- body
	local res = db:query('SELECT * FROM tb_sysmail;')
	return res
end

function _M.read_room_mgr_users(db)
	-- body
	local res = db:query('SELECT * FROM tb_room_mgr_users;')
	return res
end

function _M.read_room_mgr_rooms(db)
	-- body
	local res = db:query('SELECT * FROM tb_room_mgr_rooms;')
	return res
end

function _M.read_account_by_username(db, username, password)
	-- body
	local res = db:query(string.format("CALL sp_account_select('%s', '%s');", username, password))
	if res.mulitresultset then
		return res[1]
	end
	return res
end

function _M.read_user_by_uid(db, uid)
	-- body
	local res = db:query(string_format("CALL sp_user_select(%d);", uid))
	if res.mulitresultset then
		return res[1]
	end
	return res
end

return _M
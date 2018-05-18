local skynet = require "skynet"
require "skynet.manager"
local crypt = require "skynet.crypt"
local log = require "chestnut.skynet.log"
local httpsc = require "chestnut.https.httpc"
local guid = require "chestnut.guid"

local server_win = { ["sample1"] = true }
local server_adr = { ["sample"]  = true }
local appid  = "wx3207f9d59a3e3144"
local secret = "d4b630461cbb9ebb342a8794471095cd"

local signupd_name = skynet.getenv "signupd_name"

local function gen_uid()
	-- body
	return guid()
end

local function new_user(uid, sex, nickname, province, city, country, headimg, openid)
	-- body
	assert(uid and sex and nickname and province and city and country and headimg)
	local user = {}
	user.uid = uid
	user.sex            = sex
	user.nickname       = nickname
	user.province       = province
	user.city           = city
	user.country        = country
	user.headimg        = headimg
	user.openid         = openid
	user.create_time    = skynet.time()
	user.login_times    = 0

	local data = json.encode(user)
	db:set(string.format("tb_account:%d", uid), data)
end

local function new_unionid(unionid, uid)
	-- body
	assert(unionid and uid)
	db:set(string.format("tb_openid:%s:openid", unionid), unionid)
	db:set(string.format("tb_openid:%s:uid", unionid), uid)
end

local function auth_win_myself(username, password)
	-- body
	local res = skynet.call(".DB", "lua", "read_account_by_username", username, password)
	if #res.accounts == 1 then
		local uid = res.accounts[1].uid
		if #res.users <= 0 then
			local sex = 1
			local r = math.random(1, 10)
			if r > 5 then
				sex = 1
			else
				sex = 0
			end

			local db_user = {}
			db_user.uid = uid
			db_user.gold = 10
			db_user.diamond = 10
			db_user.checkin_month = 0
			db_user.checkin_count = 0
			db_user.checkin_mcount = 0
			db_user.checkin_lday = 0
			db_user.rcard = 0
			db_user.sex = sex
			db_user.nickname = "username"
			db_user.province = "Beijing"
			db_user.city = "Beijing"
			db_user.country = "CN"
			db_user.headimg = ""
			db_user.openid = 0
			db_user.nameid = 0
			skynet.call(".DB", "lua", "write_user", db_user)
		end
		return uid
	else
		-- 创建新账号和新用户信息
		local uid = gen_uid()          -- integer
		log.info(string.format("new user uid = %d", uid))

		local nickname = "hell"
		local province = 'Beijing'
		local city     = "Beijing"
		local country  = "CN"
		local headimg  = "xx"
		new_unionid(unionid, uid)
		new_user(uid, sex, nickname, province, city, country, headimg, unionid)

		return uid
	end
end

local function auth_android_wx(code, ... )
	-- body
	httpc.dns()
	httpc.timeout = 1000 -- set timeout 1 second
	local respheader = {}
	local url = "/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code"
	url = string.format(url, appid, secret, code)
	
	local ok, body, code = skynet.call(".https_client", "lua", "get", "api.weixin.qq.com", url)
	if not ok then
		local res = {}
		res.code = 201
		res.uid  = 0
		return res
	end
		
	local res = json.decode(body)
	local access_token  = res["access_token"]
	local expires_in    = res["expires_in"]
	local refresh_token = res["refresh_token"]
	local openid        = res["openid"]
	local scope         = res["scope"]
	local unionid       = res["unionid"]
	log.info("access_token = " .. access_token)
	log.info("openid = " .. openid)

	local uid = db:get(string.format("tb_openid:%s:uid", unionid))
	if uid and uid > 0 then
		return uid
	else
		url = "https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s"
		url = string.format(url, access_token, openid)
		local ok, body, code = skynet.call(".https_client", "lua", "get", "api.weixin.qq.com", url)
		if not ok then
			error("access api.weixin.qq.com wrong")
		end

		local res = json.decode(body)
		local nickname   = res["nickname"]
		local sex        = res["sex"]
		local province   = res["province"]
		local city       = res["city"]
		local country    = res["country"]
		local headimgurl = res["headimgurl"]
		url = string.sub(headimgurl, 19)
		log.info(url)
		local statuscode, body = httpc.get("wx.qlogo.cn", url, respheader)
		local headimg = crypt.base64encode(body)

		local uid = gen_uid()
		local nameid = gen_nameid()

		new_unionid(unionid, uid)
		new_nameid(nameid, uid)
		new_user(uid, sex, nickname, province, city, country, headimg, unionid, uid)

		return uid
	end
end

local CMD = {}

function CMD.start( ... )
	-- body
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.signup(server, code, ... )
	-- body
	if server_adr[server] then
		local ok, err = pcall(auth_android_wx, code)
		if ok then
			local res = {}
			res.code = 200
			res.uid = err
			return res
		else
			log.err(err)
			local res = {}
			res.code = 501
			return res
		end
	elseif server_win[server] then
		local ok, err = pcall(auth_win_myself, code, ...)
		if ok then
			local res = {}
			res.code = 200
			res.uid = err
			return res
		else
			log.error("auth_win_myself error is [%s]", err)
			local res = {}
			res.code = 501
			return res
		end
	end
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, _, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local r = f( ... )
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register("." .. signupd_name)
end)
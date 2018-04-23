package.path = "./module/mahjong/agent_robot/?.lua;./module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local log = require "chestnut.skynet.log"

local username = 'hello'
local server = 'sample1'
local password = 'Password'
local index = 1
local secret

local function writeline(fd, text)
	socket.write(fd, text .. "\n")
end

local function send_request(v, session)
	local size = #v + 4
	local package = string.pack(">I2", size)..v..string.pack(">I4", session)
	socket.send(fd, package)
	return v, session
end

local function recv_response(v)
	local size = #v - 5
	local content, ok, session = string.unpack("c"..tostring(size).."B>I4", v)
	return ok ~=0 , content, session
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local readpackage = unpack_f(unpack_package)

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local CMD = {}

function CMD.login( ... )
	-- body
	log.info('agent_robot start')
	local id = socket.open("127.0.0.1", 3002)
	socket.block(id)
	local line = socket.readline(id)
	local challenge = crypt.base64decode(line)
	local clientkey = crypt.randomkey()
	writeline(id, crypt.base64encode(crypt.dhexchange(clientkey)))
	socket.block(id)
	line = socket.readline(id)
	log.info(line);
	secret = crypt.dhsecret(crypt.base64decode(line), clientkey)
	local hmac = crypt.hmac64(challenge, secret)
	writeline(id, crypt.base64encode(hmac))
	local token = string.format("%s@%s:%s",
			crypt.base64encode(username),
			crypt.base64encode(server),
			crypt.base64encode(password))
	local etoke = crypt.desencode(secret, token)
	writeline(id, crypt.base64encode(etoke))
	socket.block(id);
	line = socket.readline(id)
	log.info(line)
	local code = tonumber(string.sub(line, 1, 4))
	if code == 200 then
		local xline = crypt.base64decode(string.sub(line, 5))
		local _1 = string.find(xline, '#')
		local _2 = string.find(xline, '@', _1+1)
		local uid = tonumber(string.sub(xline, 1, _1-1))
		local subid = tonumber(string.sub(xline, _1+1, _2-1))
		log.info('%d:%d', uid, subid)
		socket.close(id)
	end
	log.info('agent_robot end')
	return true
end

function CMD.auth( ... )
	-- body
	local fd = assert(socket.connect("127.0.0.1", 3301))
	local last = ""
	local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(user), crypt.base64encode(server),crypt.base64encode(subid) , index)
    local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)
    send_package(fd, handshake..":"..crypt.base64encode(hmac))
    print(readpackage())
	print("===>",send_request("handshake",0))	-- request again (use last session 0, so the request message is fake)
	socket.close(fd)
end

function CMD.handshake( ... )
	-- body
end

-- local function request(name, args, response, msg, sz)
-- 	log.info("agent request [%s]", name)
--     local f = REQUEST[name]
--     if not f then
--     	log.info("request [%s] not found.", name)
--     end
--     local ok, result = xpcall(f, debug.msgh, ctx, args, msg, sz)
--     if ok then
--     	if result then
--     		return response(result)
--     	end
--     end
-- end

-- local function response(session, args, msg, sz)
-- 	-- body
-- 	local name = ctx:get_name_by_session(session)
-- 	-- log.info("agent response [%s]", name)
--     local f = RESPONSE[name]
--     if not f then
--     	log.info("response [%s] not found.", name)
--     end
--     local ok, result = pcall(f, ctx, args)
--     if not ok then
--     	log.error(result)
--     end
-- end

-- skynet.register_protocol {
-- 	name = "client",
-- 	id = skynet.PTYPE_CLIENT,
-- 	unpack = function (msg, sz)
-- 		if sz > 0 then
-- 			local host = ctx.host
-- 			return host:dispatch(msg, sz)
-- 		else 
-- 			assert(false)
-- 		end
-- 	end,
-- 	dispatch = function (session, source, type, ...)	
-- 		if type == "REQUEST" then
-- 			local ok, result = xpcall(request, debug.msgh, ...)
-- 			if ok then
-- 				if result then
-- 					ctx:send_package(result)
-- 				end
-- 			end
-- 		elseif type == "RESPONSE" then
-- 			pcall(response, ...)
-- 		else
-- 			assert(false, result)
-- 		end
-- 	end
-- }

skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd])
		local ok, err = pcall(f, ...)
		if ok then
			skynet.retpack(err)
		end
	end)
	-- slot 1,2 set at main.lua
end)

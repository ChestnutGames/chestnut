local skynet = require "skynet"
local log = require "skynet.log"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"
local handler = require "web.handler"


local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

local function route( id, code, url, method, header, body )
	-- body
	if code ~= 200 then
		response(id, code)
		return
	end
	local path, query = urllib.parse(url)
	if method == "GET" then
		local ok, statuscode, headerd, bodyfunc = handler.handle_static(code, path, header)
		if ok then
			for k,v in pairs(header) do
				headerd[k] = v
			end
			response(id, statuscode, bodyfunc, headerd)
			return
		else
			ok, statuscode, headerd, bodyfunc = handler.handle_get(code, path, query, header)
			if ok then
				for k,v in pairs(header) do
					headerd[k] = v
				end
				response(id, statuscode, bodyfunc, headerd)
				return
			else
				bodyfunc = "404 Page"
				response(id, 404, bodyfunc, header)
				return
			end
		end
	elseif method == "POST" then
		local ok, statuscode, headerd, bodyfunc = handler.handle_file(code, path, header)
		if ok then
			for k,v in pairs(header) do
				headerd[k] = v
			end
			response(id, statuscode, bodyfunc, headerd)
			return
		else
			ok, statuscode, headerd, bodyfunc = handler.handle_post(code, path, header, body)
			if ok then
				response(id, statuscode, bodyfunc)
				return
			else
				bodyfunc = "404 Page"
				response(id, 404, bodyfunc)
				return
			end
		end
	end
end 

return { route = route }
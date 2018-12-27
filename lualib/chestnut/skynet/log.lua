local skynet = require "skynet"
local logger = require "xlog.core"
local debug = debug
local string_format = string.format
local skynet_error = skynet.error
local daemon = skynet.getenv("daemon")
local test = true

local _M = {}

function _M.debug(fmt, ...)
	local err = string_format(fmt, ...)
	local info = debug.getinfo(2)
	local msg = string.format("[debug][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, err)

	if test or daemon then
		logger.debug(msg)
	else
		skynet_error(msg)	
	end
end

function _M.info(fmt, ...)
	local err = string_format(fmt, ...)
	local info = debug.getinfo(2)
	local msg = string.format("[info][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, err)

	if test or daemon then
		logger.info(msg)
	else
		skynet_error(msg)
	end
end

function _M.warning(fmt, ...)
	local err = string_format(fmt, ...)
	local info = debug.getinfo(2)
	local msg = string.format("[warning][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, err)

	if test or daemon then
		logger.warning(msg)
	else
		skynet_error(msg)
	end
end

function _M.error(fmt, ...)
	local err = string_format(fmt, ...)
	local info = debug.getinfo(2)
	local msg = string.format("[error][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, err)
	
	if test or daemon then
		logger.error(msg)
	else
		skynet_error(msg)
	end
end

function _M.fatal(fmt, ...)
	local err = string.format(fmt, ...)
	local info = debug.getinfo(2)
	local msg = string.format("[fatal][%s][%s][%s:%d] %s", os.date(), SERVICE_NAME, info.short_src, info.currentline, err)

	if test or daemon then
		logger.fatal(msg)
	else
		skynet_error(msg)
	end
end

return _M

local skynet = require "skynet"
require "skynet.manager"
-- local array = require "chestnut.array"

skynet.start(function ( ... )
	-- body
	skynet.launch("xloggerd")
	-- log.info("xloggerd start ... ")

	-- skynet.newservice("test_chestnut_redis")
	-- skynet.newservice("test_chestnut_array")
	skynet.newservice("test_chestnut_vector")
end)
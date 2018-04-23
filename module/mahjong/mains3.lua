local skynet = require "skynet"
local log = require "skynet.log"

local servers = {}

skynet.start(function()
	
	repeat 
		local conf = {
			db_host = skynet.getenv("db_host") or "192.168.1.116",
			db_port = skynet.getenv("db_port") or 3306,
			db_database = skynet.getenv("db_database") or "user",
			db_user = skynet.getenv("db_user") or "root",
			db_password = skynet.getenv("db_password") or "yulei",
			cache_host = skynet.getenv("cache_host") or "192.168.1.116",
			cache_port = skynet.getenv("cache_port") or 6379
		}
		
		local addr = skynet.uniqueservice("db", "master")
		assert(skynet.call(addr, "lua", "start", conf))
		table.insert(servers, addr)
	until true

	local dbmonitor = skynet.uniqueservice("dbmonitord")
	skynet.call(dbmonitor, "lua", "start")
	
	log.info("host s3 successful .")
	skynet.exit()
end)

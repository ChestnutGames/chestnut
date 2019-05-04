local skynet = require "skynet"
require "skynet.manager"
local log = require "chestnut.skynet.log"
local cluster = require "skynet.cluster"

skynet.start(function()

	-- log

	-- local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)

	skynet.uniqueservice("protoloader")

	local gm = skynet.getenv 'gm'
	local logind = skynet.getenv 'logind'
	local game1 = skynet.getenv 'game1'
	cluster.reload({
		gm = gm,
		logind = logind,
		game1 = game1
	})
	cluster.open 'game1'

	local codweb = skynet.uniqueservice("life_mgr")
	local ok = skynet.call(codweb, "lua", "start")
	if not ok then
		log.error("start codweb faile, kill server.")
		assert(skynet.call(codweb, "lua", "kill"))
		log.error("start codweb faile, kill main.")
		skynet.abort()
	else

		skynet.call(codweb, "lua", "init_data")
		skynet.call(codweb, "lua", "sayhi")

		log.info("host successful --------------------------------------------")

		-- MOCK
		-- local agent_robot = skynet.uniqueservice("agent_robot/agent")
		-- skynet.call(agent_robot, "lua", "login")
		-- skynet.call(agent_robot, "lua", 'auth')
		skynet.exit()
	end
end)

local skynet = require "skynet"
local snowflake = require "chestnut.snowflake"


function guid( ... )
	-- body
	return snowflake.next_id()
end

return guid
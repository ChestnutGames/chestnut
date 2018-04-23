local skynet = require "skynet"
local array = require "chestnut.array"

skynet.start(function ( ... )
	-- body
	local a = array(6)()
	a[1] = 'hell'
	a[2] = {}
	for k,v in pairs(a) do
		print(k,v)
	end
	print(#a)
end)
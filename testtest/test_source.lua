local skynet = require "skynet"
local zset = require 'zset'

skynet.start(function ( ... )
    -- body
    skynet.dispatch('lua', function(source, session, ...)
        print(source)
        print(session)
    end)
end)
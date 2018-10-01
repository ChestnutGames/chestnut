local basefd = io.open('base.sproto', 'r')
local basec2sfd = io.open('base.c2s.sproto', 'r')
local bases2cfd = io.open('base.s2c.sproto', 'r')
local pokerfd = io.open('poker.sproto', 'r')
local pokerc2sfd = io.open('poker.c2s.sproto', 'r')
local pokers2cfd = io.open('poker.s2c.sproto', 'r')

local base = basefd:read('a')
local basec2s = basec2sfd:read('a')
local bases2c = bases2cfd:read('a')

local poker = pokerfd:read('a')
local pokerc2s = pokerc2sfd:read('a')
local pokers2c = pokers2cfd:read('a')

basefd:close()
basec2sfd:close()
bases2cfd:close()

pokerfd:close()
pokerc2sfd:close()
pokers2cfd:close()

local c2s = base .. poker .. basec2s .. pokerc2s
local s2c = base .. poker .. basec2s .. pokerc2s

local c2sfd = io.open('c2s.sproto', 'w+')
local s2cfd = io.open('s2c.sproto', 'w+')

c2sfd:write(c2s)
s2cfd:write(s2c)

c2sfd:close()
s2cfd:close()

local skynet = require "skynet"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"
local context = require "AgentContext"
local REQUEST = require "request"
local RESPONSE = require "response"
local CMD = require "cmd"
local traceback = debug.traceback
local assert = assert
local login_type = skynet.getenv 'login_type'
local client = require("client")
local service = require("service")


local client_mod = {}
client_mod.request = REQUEST
client_mod.response = RESPONSE

client.init(client_mod)

local mod = {}
mod.require = {}
mod.init = function ( ... )
	-- body
end
mod.command = CMD
service.init(mod)


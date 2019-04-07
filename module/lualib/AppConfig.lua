
local cls = class("AppConfig")

function cls:ctor()
	-- body
	self.config = {}
	self.dataset = {}
end

function cls:LoadFile()
	-- body
	local card = require "configs.cardConfig"
	local consts = require "configs.constsConfig"
	local desk = require "configs.deskConfig"
	local errorcode = require "configs.errorcodeConfig"
	local funcopen = require "configs.funcopenConfig"
	local hand = require "configs.handConfig"
	local hutype = require "configs.hutypeConfig"
	local item = require "configs.itemConfig"
	local language = require "configs.languageConfig"
	local notice = require "configs.noticeConfig"
	local play = require "configs.playConfig"
	-- local refresh = require "configs.refresh"
	local roommode = require "configs.roommodeConfig"

	self.config['card'] = card
	self.config['consts'] = consts
	self.config['desk'] = desk
	self.config['errorcode'] = errorcode
	self.config['funcopen'] = funcopen
	self.config['hand'] = hand
	self.config['hutype'] = hutype
	self.config['item'] = item
	self.config['language'] = language
	self.config['notice'] = notice
	self.config['play'] = play
	-- self.config['refresh'] = refresh
	self.config['roommode'] = roommode

	return true
end

function cls:CheckConfig()
	-- body
	assert(self)
	return true
end

function cls:CheckCard()
	-- body
end

return cls


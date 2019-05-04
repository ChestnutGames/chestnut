
local cls = class("AppConfig")

function cls:ctor()
	-- body
	self.config = {}
	self.dataset = {}
end

function cls:LoadFile()
	-- body
	local card = require "chestnut.sdata.configs.cardConfig"
	local consts = require "chestnut.sdata.configs.constsConfig"
	local desk = require "chestnut.sdata.configs.deskConfig"
	local errorcode = require "chestnut.sdata.configs.errorcodeConfig"
	local funcopen = require "chestnut.sdata.configs.funcopenConfig"
	local hand = require "chestnut.sdata.configs.handConfig"
	local hutype = require "chestnut.sdata.configs.hutypeConfig"
	local item = require "chestnut.sdata.configs.itemConfig"
	local language = require "chestnut.sdata.configs.languageConfig"
	local notice = require "chestnut.sdata.configs.noticeConfig"
	local play = require "chestnut.sdata.configs.playConfig"
	-- local refresh = require "configs.refresh"
	local roommode = require "chestnut.sdata.configs.roommodeConfig"

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


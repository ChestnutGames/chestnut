-- local log = require "chestnut.skynet.log"
local UserComponent = require "components.UserComponent"

local cls = class('level')

function cls:ctor(context)
	-- body
	self.agentContext = context
	self.agentSystems = nil
end

function cls:set_agent_systems(systems)
	-- body
	self.agentSystems = systems
end

function cls:on_data_init(dbData)
	-- body
	assert(self)
end

function cls:on_data_save(dbData, ... )
	-- body
	assert(dbData ~= nil)
	dbData.db_user = {}
	dbData.db_user.uid      = self.dbAccount.uid
	-- seg.age      = component.age
	dbData.db_user.sex      = self.dbAccount.sex
	dbData.db_user.nickname = self.dbAccount.nickname
	dbData.db_user.province = self.dbAccount.province
	dbData.db_user.city     = self.dbAccount.city
	dbData.db_user.country  = self.dbAccount.country
	dbData.db_user.headimg  = self.dbAccount.headimg
	dbData.db_.create_time  = self.dbAccount.create_time
	seg.login_times         = self.dbAccount.login_times

	-- save user
	dbData.db_user = {}
	dbData.db_user.uid            = self.dbUser.uid
	dbData.db_user.sex            = self.dbUser.sex
	dbData.db_user.nickname       = self.dbUser.nickname
	dbData.db_user.province       = self.dbUser.province
	dbData.db_user.city           = self.dbUser.city
	dbData.db_user.country        = self.dbUser.country
	dbData.db_user.headimg        = self.dbUser.headimg
	dbData.db_user.openid         = self.dbUser.openid
	dbData.db_user.nameid         = self.dbUser.nameid
	dbData.db_user.create_at      = self.dbUser.createAt
	dbData.db_user.update_at 	  = component.updateAt
	dbData.db_user.login_at       = component.loginAt
	dbData.db_user.new_user       = component.newUser
	dbData.db_user.level          = component.level
end

function cls:add_exp(exp)
	-- body
	assert(self)
	assert(exp)
end

return cls
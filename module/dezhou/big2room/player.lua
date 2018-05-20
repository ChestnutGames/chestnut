local log = require "chestnut.skynet.log"
local util = require "chestnut.time_utils"
local vector = require "chestnut.sortedvector"
local fsm = require "chestnut.fsm"

local state = {}
state.NONE           = "NONE"
state.WAIT_JOIN      = "WAIT_JOIN"
state.JOIN           = "JOIN"
state.WAIT_READY     = "WAIT_READY"
state.READY          = "READY"
state.WAIT_SHUFFLE   = "WAIT_SHUFFLE"
state.SHUFFLE        = "SHUFFLE"
state.WAIT_DEAL      = "WAIT_DEAL"
state.DEAL       	 = "DEAL"
state.WATCH          = "WATCH"          -- 观看状态，此时没有关于他的事物
state.PASS           = "PASS"           -- 当你选择PASS,会进此状态，会
state.WAIT_TURN      = "WAIT_TURN"      -- 轮到你做出选择
-- state.TURN       = 15   -- 此状态可能不会出现
state.WAIT_LEAD      = "WAIT_LEAD"
state.LEAD           = "LEAD"
state.WAIT_CALL      = "WAIT_CALL"
state.CALL           = "CALL"
state.WAIT_OVER      = "WAIT_OVER"
state.OVER           = "OVER"
state.WAIT_SETTLE    = "WAIT_SETTLE"
state.SETTLE         = "SETTLE"
state.WAIT_RESTART   = "WAIT_RESTART"
-- state.RESTART    = 27

local cls = class("player")

cls.state = state

function cls:ctor(env, uid, agent)
	-- body
	assert(env and uid and agent)
	self.env    = env
	self.uid    = uid
	self.idx    = 0      -- players index
	self.agent  = agent  -- agent
	self.name   = ""
	self.sex    = 0      -- 0 nv
	self.chip   = 1000
	self.fen    = 0
	self.online = false  -- user in game
	self.robot  = false  -- user

	-- play
	self.cards  = vector()
	self.colorcards = {}
	self.pass = false

	self._cancelcd = nil
	self._chipli = {}   -- { code,dian,chip}

	local alert = fsm.create({
		initial = state.NONE,
		events = {
			{name = "waitJoin",         from = state.NONE,    to = state.WAIT_JOIN},
		    {name = "join",             from = state.START,   to = state.JOIN},
		    {name = "ready",            from = state.WAIT_READY,    to = state.READY},
		    {name = "shuffle",          from = state.READY,   to = state.SHUFFLE},
		    {name = "deal",             from = state.SHUFFLE, to = state.DEAL},
		    {name = "firstTurn",        from = state.DEAL,    to = state.TURN},
		    {name = "turnAfterLead",    from = state.LEAD,    to = state.TURN},
		    {name = "turnAfterPass",    from = state.CALL,    to = state.TURN},
		    {name = "call",             from = state.TURN,    to = state.CALL},
		    {name = "lead",             from = state.TURN,    to = state.LEAD},
		    {name = "over",             from = state.LEAD,    to = state.OVER},
		    {name = "settle",           from = state.OVER,    to = state.SETTLE},
		    {name = "restart",          from = state.SETTLE,    to = state.RESTART},
		},
		callbacks = {
		    -- on_panic = function(self, event, from, to, msg) print('panic! ' .. msg)  end,
		    -- on_clear = function(self, event, from, to, msg) print('phew... ' .. msg) end
		}
	})
	self.alert = alert
	return self
end

function cls:is_none()
	-- body
	return (self.uid == 0)
end

function cls:get_cards_value()
	-- body
	local cards = {}
	for i,card in ipairs(self.cards) do
		local v = card:get_value()
		cards[i] = v
	end
	return cards
end

function cls:clear()
	-- body
	self.cards  = vector()
	self.colorcards = {}
end

function cls:print_cards()
	-- body
	log.info("player %d begin print cards", self._idx)
	local len = #self._cards
	for i=1,len do
		log.info(self._cards[i]:describe())
	end
	log.info("player %d end print cards", self._idx)
end

------------------------------------------
-- 发牌的时候直接插入
function cls:insert(card)
	-- body
	assert(card)
	local len = #self._cards
	for i=1,len do
		if self._cards[i]:mt(card) then
			for j=len,i,-1 do
				self._cards[j + 1] = self._cards[j]
				self._cards[j + 1]:set_pos(j + 1)
			end
			self._cards[i] = card
			self._cards[i]:set_pos(i)
			return i
		end
	end
	self._cards[len+1] = card
	self._cards[len+1]:set_pos(len + 1)
	return len + 1
end

function cls:insert_with_pos(card)
	-- body
	assert(self and card)
end

function cls:remove(card, ... )
	-- body
	return self:remove_pos(card._pos)
end

function cls:pack_cards()
	-- body
	local ccs = {}
	for _,card in pairs(self._cards) do
		local cc = { pos = card:get_pos(), value = card:get_value() }
		table.insert(ccs, cc)
	end
	return ccs
end

-- end
------------------------------------------

------------------------------------------
-- 开始处理出牌
function cls:append_lead(card, ... )
	-- body
	assert(card)
	table.insert(self._leadcards, card)
	local len = #self._leadcards
	card:set_pos(len)
	card:set_que(card.type.NONE)
end

function cls:remove_lead_tail(card, ... )
	-- body
	assert(card)
	local len = #self._leadcards
	assert(self._leadcards[len]:get_value() == card:get_value())
	self._leadcards[len] = nil
end

function cls:lead(c, isHoldcard, ... )
	-- body
	assert(self._state == state.WAIT_TURN)
	assert(c)
	if isHoldcard then
		if self._holdcard:get_value() == c then
			local card = self._holdcard
			self:append_lead(card)
			self._holdcard = nil
			return true, card
		else
			return false
		end
	else
		local card
		local len = #self._cards
		for i=1,len do
			if self._cards[i]:get_value() == c then
				card = self._cards[i]
				self:append_lead(card)
				self:remove(card)

				assert(self._holdcard)
				if self._holdcard then
					self:insert(self._holdcard)
					self._holdcard = nil
				end
				break
			end
		end
		if card then
			self:print_cards()
			return true, card
		else
			return false
		end
	end
end

function cls:pack_leadcards()
	-- body
	local ccs = {}
	for _,card in pairs(self._leadcards) do
		local cc = { pos = card:get_pos(), value = card:get_value() }
		table.insert(ccs, cc)
	end
	return ccs
end

-- 开始处理出牌over
------------------------------------------

------------------------------------------
-- 开始处理出牌

function cls:timeout(ti, ... )
	-- body
	self._cancelcd = util.set_timeout(ti, function ( ... )
		-- body
		return
		
		-- if self._state == state.WAIT_TURN then
		-- 	assert(self._holdcard)
		-- 	self._env:lead(self._idx, self._holdcard:get_value())
		-- elseif self._state == state.MCALL then
		-- 	local args = {}
		-- 	args.idx = self._idx
		-- 	args.opcode = opcode.guo
		-- 	self._env:timeout_call(args)
		-- elseif self._state == state.OCALL then
		-- 	local args = {}
		-- 	args.idx = self._idx
		-- 	args.opcode = opcode.guo
		-- 	self._env:timeout_call(args)
		-- elseif self._state == state.WAIT_TAKE_XUANQUE then
		-- 	local args = {}
		-- 	args.idx = self._idx
		-- 	args.que = card.type.DOT
		-- 	self._env:timeout_xuanque(args)
		-- end
	end)
	assert(self._cancelcd)
end

function cls:cancel_timeout( ... )
	-- body
	self._cancelcd()
end

-- restart
function cls:take_restart( ... )
	-- body
	self:clear()
end

function cls:settle(chip, ... )
	-- body
	self._chip = self._chip + chip
	return self._chip
end

function cls:record_settle(node, ... )
	-- body
	table.insert(self._chipli, node)
end


return cls
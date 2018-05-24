local log = require "chestnut.skynet.log"
local util = require "chestnut.time_utils"
local vector = require "chestnut.sortedvector"
local fsm = require "chestnut.fsm"

local state = {}
state.NONE           = "none"
state.WAIT_JOIN      = "wait_join"
state.JOIN           = "join"
state.WAIT_READY     = "wait_ready"
state.READY          = "ready"
state.WAIT_SHUFFLE   = "wait_shuffle"
state.SHUFFLE        = "shuffle"
state.WAIT_DEAL      = "wait_deal"      -- 以上状态都没有用
state.DEAL       	 = "deal"
state.WATCH          = "watch"          -- 观看状态，此时没有关于他的事物
state.WAIT_TURN      = "wait_turn"      -- 轮到你做出选择
-- state.TURN       = 15   -- 此状态可能不会出现
state.WAIT_LEAD      = "wait_lead"
state.LEAD           = "lead"
state.WAIT_CALL      = "wait_call"
state.CALL           = "call"
state.WAIT_OVER      = "wait_over"
state.OVER           = "over"
state.WAIT_SETTLE    = "wait_settle"
state.SETTLE         = "settle"
state.WAIT_RESTART   = "wait_restart"
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
	self.cards  = vector(function (l, r)
		-- body
		return l:mt(r)
	end)()
	self.colorcards = {}
	self.pass = false

	self._cancelcd = nil
	self._chipli = {}   -- { code,dian,chip}

	self.alert = nil
	self:init_alert(state.NONE)
	return self
end

function cls:is_none()
	-- body
	return (self.uid == 0)
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

function cls:init_alert(initial_state)
	-- body
	local alert = fsm.create({
		initial = initial_state,
		events = {
			{name = "ev_wait_join",     from = state.NONE,    to = state.WAIT_JOIN},
		    {name = "ev_join",          from = state.WAIT_JOIN,   to = state.JOIN},
		    {name = "ev_wait_ready",    from = state.NONE,    to = state.WAIT_READY},
		    {name = "ev_ready",         from = state.WAIT_READY,     to = state.READY},
		    {name = "ev_wait_deal",     from = state.NONE,          to = state.WAIT_DEAL},
		    {name = "ev_deal",          from = state.WAIT_DEAL,      to = state.DEAL},
		    {name = "ev_watch_after_deal",         from = state.DEAL,    to = state.WATCH},
		    {name = "ev_watch_after_lead",         from = state.LEAD,    to = state.WATCH},
		    {name = "ev_watch_after_call",         from = state.CALL,    to = state.WATCH},
		    {name = "ev_wait_turn_after_deal",     from = state.DEAL,    to = state.WAIT_TURN},
		    {name = "ev_wait_turn_after_lead",     from = state.LEAD,    to = state.WAIT_TURN},
		    {name = "ev_wait_turn_after_call",     from = state.CALL,    to = state.WAIT_TURN},
		    {name = "ev_wait_lead_after_watch",         from = state.WATCH,    to = state.WAIT_LEAD},
		    {name = "ev_wait_lead_after_wait_turn",     from = state.WAIT_TURN,    to = state.WAIT_LEAD},
		    {name = "ev_wait_call_after_watch",         from = state.WATCH,    to = state.WAIT_CALL},
		    {name = "ev_wait_call_after_wait_turn",     from = state.WAIT_TURN,    to = state.WAIT_CALL},

		    {name = "ev_lead",             from = state.WAIT_LEAD,    to = state.LEAD},
		    {name = "ev_call",             from = state.WAIT_CALL,    to = state.CALL},
		    {name = "ev_wait_over",        from = state.LEAD,         to = state.WAIT_OVER},
		    {name = "ev_over",             from = state.WAIT_OVER,    to = state.OVER},
		    {name = "ev_settle",           from = state.OVER,    to = state.SETTLE},
		    {name = "ev_restart",          from = state.SETTLE,    to = state.RESTART},
		},
		callbacks = {
		    on_ready = function(self, event, from, to, obj, msg) assert(obj) obj:on_state(event, from, to, msg) end,
		    on_deal = function(self, event, from, to, obj, msg) assert(obj) obj:on_state(event, from, to, msg) end,
		    on_lead = function(self, event, from, to, obj, msg) assert(obj) obj:on_state(event, from, to, msg) end,
		    on_call = function(self, event, from, to, obj, msg) assert(obj) obj:on_state(event, from, to, msg) end,
		    -- on_clear = function(self, event, from, to, msg) print('phew... ' .. msg) end
		}
	})
	self.alert = alert
end

function cls:on_state(event, from, to)
	-- body
	if to == state.READY then
	elseif to == state.SHUFFLE then
	elseif to == state.DEAL then
		log.info('player : deal')
		self.env:on_next_state()
	elseif to == state.TURN then
		self:take_turn()
	elseif to == state.LEAD then
		self:take_lead()
	elseif to == state.CALL then
		self:take_call()
	elseif to == state.OVER then
		self:take_over()
	end
end

------------------------------------------
-- 发牌的时候直接插入
function cls:insert(card)
	-- body
	assert(card)
	self.cards:push(card)
end

function cls:remove(card)
	-- body
	return self:remove_pos(card._pos)
end

function cls:pack_cards()
	-- body
	local ccs = {}
	for _,card in pairs(self.cards) do
		local cc = { pos = card.pos, value = card.value }
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
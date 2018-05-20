local skynet = require "skynet"
local mc = require "skynet.multicast"
-- local ds = require "skynet.datasheet"
local log = require "chestnut.skynet.log"
local servicecode = require "chestnut.servicecode"
local fsm = require "chestnut.fsm"
local opcode = require "opcode"
local Card = require "card"
local Player = require "player"

local state = {}
state.NONE       = "none"      -- 最初的状态
state.START      = "start"
state.CREATE     = "create"
state.JOIN       = "join"      -- 此状态下会等待玩家加入
state.READY      = "ready"     -- 此状态下等待玩家准备
state.SHUFFLE    = "shuffle"   -- 此状态下洗牌
state.DEAL       = "deal"      -- 此状态发牌
state.TURN       = "turn"      -- 轮谁出牌
state.LEAD       = "lead"      -- 玩家出牌，客户端都表现完后转移状态
state.CALL       = "call"      -- 只有pass命令
state.OVER       = "over"      -- 结束
state.SETTLE     = "settle"    -- 结算
state.RESTART    = "restart"   -- 重新开始

local cls = class("RoomContext")

function cls:ctor()
	-- body

	-- players
	self.players = {}
	for i=1,4 do
		local tmp = Player.new(self, 0, 0)
		tmp.idx = i
		self.players[i] = tmp
	end

	-- rule
	self.channel = nil
	self.id = 0
	self.open = false
	self.host = nil
	self.max = 4          -- 玩家数
	self.joined = 0
	self.online = 0
	self.maxju = 0        -- 玩的局数
	self.uplayers = {}

	-- play
	self._cards = {}         -- 洗牌
	self._cardssz = 52
	self._kcards = {}
	self:init_cards()

	self.firstidx = 0           -- 拿牌头家
	self.curidx = 0             -- 玩家索引，当前轮到谁

	self.countdown = 20         -- 轮到玩家出牌或者选择的时候的倒计时
	self._ju = 0                -- ju 最开始是0
	self._overtimer = nil

	-- 记录所有数据
	self._stime = 0
	self._record = {}

	local alert = fsm.create({
		initial = state.NONE,
		events = {
			{name = "ev_start",        from = state.NONE,    to = state.START},
		    {name = "ev_join",         from = state.START,   to = state.JOIN},
		    {name = "ev_ready",        from = state.JOIN,    to = state.READY},
		    {name = "ev_shuffle",      from = state.READY,   to = state.SHUFFLE},
		    {name = "ev_deal",         from = state.SHUFFLE, to = state.DEAL},
		    {name = "ev_first_turn",    from = state.DEAL,    to = state.TURN},
		    {name = "ev_turn_after_lead",    from = state.LEAD,    to = state.TURN},
		    {name = "ev_turn_after_pass",    from = state.CALL,    to = state.TURN},
		    {name = "ev_call",             from = state.TURN,    to = state.CALL},
		    {name = "ev_lead",             from = state.TURN,    to = state.LEAD},
		    {name = "ev_over",             from = state.LEAD,    to = state.OVER},
		    {name = "ev_settle",           from = state.OVER,    to = state.SETTLE},
		    {name = "ev_restart",          from = state.SETTLE,    to = state.RESTART},
		},
		callbacks = {
		    on_ready = function(self, event, from, to, obj, msg) obj:on_state(event, from, to, msg) end,
		    on_shuffle = function(self, event, from, to, obj, msg) obj:on_state(event, from, to, msg) end,
		    on_deal = function(self, event, from, to, obj, msg) obj:on_state(event, from, to, msg) end,
		    on_turn = function(self, event, from, to, obj, msg) obj:on_state(event, from, to, msg) end,
		    on_call = function(self, event, from, to, obj, msg) obj:on_state(event, from, to, msg) end,
			on_lead = function(self, event, from, to, obj, msg) obj:on_state(event, from, to, msg) end,
			on_over = function(self, event, from, to, obj, msg) obj:on_state(event, from, to, msg) end,
		}
	})
	self.alert = alert
	return self
end

function cls:set_id(value)
	-- body
	self.id = value
end

function cls:clear()
	-- body
	self._countdown = 20 -- s

	self._state = state.NONE
	self._lastfirsthu  = 0    -- last,make next zhuangjia

	self._lastidx  = 0    -- last time lead from who
	self._lastcard = nil    -- last time lead card

	self._firsttake = 0
	self._firstidx  = 0    -- zhuangjia
	self._curtake   = 0
	self._curidx    = 0      -- player
	self._curcard = nil

	self._takeround = 1
	self._takepoint = 0

	self._call = {}
	self._callcounter = 0
end

function cls:find_noone()
	-- body
	if self._joined >= self._max then
		return nil
	end
	for i=1,self.max do
		if self.players[i].uid == 0 then
			return self.players[i]
		end
	end
end

function cls:get_player_by_uid(uid)
	-- body
	assert(uid)
	return self.uplayers[uid]
end

function cls:init_cards()
	-- body
	for i=1,4 do
		for j=1,13 do
			local cc = Card.new(i, j, 0)
			table.insert(self._cards, cc)         -- 用于洗牌
			self._kcards[cc.value] = cc     -- 用于查找
		end
	end
end

function cls:clear_state(state, ... )
	-- body
	assert(state)
	for i=1,4 do
		self._players[i]._state = state
	end
end

function cls:is_next_state(state)
	-- body
	for i=1,self.max do
		local p = assert(self.players[i])
		if not p.alert.is(state) then
			return false
		end
	end
	return true
end

function cls:push_client(name, args)
	-- body
	for i=1,self.max do
		local p = self._players[i]
		if not p:is_none() then
			if p.online then
				log.info("push protocol %s to idx %d.", name, i)
				skynet.send(p.agent, "lua", name, args)
			end
		end
	end
end

function cls:push_client_idx(idx, name, args)
	-- body
	assert(idx and name and args)
	local p = self._players[idx]
	if not p:is_none() and p.online then
		log.info("push protocol %s to idx %d.", name, idx)
		skynet.send(p.agent, "lua", name, args)
	end
end

function cls:push_client_except_idx(idx, name, args)
	-- body
	for i=1,self.max do
		if idx ~= i then
			local p = self._players[i]
			if not p:is_none() and p.online then
				log.info("push protocol %s to idx %d.", name, i)
				skynet.send(p.agent, "lua", name, args)
			end
		end
	end
end

function cls:record(protocol, args, ... )
	-- body
	local tnode = {}
	tnode.protocol = protocol
	tnode.pt = (skynet.now() - self._stime)
	tnode.args = args
	table.insert(self._record, tnode)
end

-- 此函数只检测不同地方玩法的由胡的人数觉定是否结束
function cls:check_over()
	-- body
	if self.alert.is(state.LEAD) then
		local p = self.players[self.turn]
		if #p.cards == 0 then
			self:take_over()
		end
	end
end

function cls:transfer_player_state(event)
	-- body
	for i=1,self.max do
		local p = assert(self.players[i])
		p.alert[event](p)
	end
end

function cls:on_state(event, from, to)
	-- body
	if to == state.READY then
	elseif to == state.SHUFFLE then
		self:transfer_player_state("wait_shuffle")
	elseif to == state.DEAL then
		self:take_deal()
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

function cls:next_idx()
	-- body
	self.curidx = self.curidx + 1
	if self.curidx > self.max then
		self.curidx = 1
	end
end

function cls:next_idx_wait_turn()
	-- body
	self.curidx = self.curidx + 1
	if self.curidx > self.max then
		self.curidx = 1
	end
	local p = self.players[self.curidx]
	p.alert.wait_turn()
end

function cls:incre_joined()
	-- body
	self.joined = self.joined + 1
	assert(self.joined <= self.max)
end

function cls:decre_joined()
	-- body
	self.joined = self.joined - 1
	assert(self.joined >= 0)
end

function cls:incre_online()
	-- body
	self.online = self.online + 1
	assert(self.online <= self.max)
end

function cls:decre_online()
	-- body
	self.online = self.online - 1
	assert(self.online >= 0)
end

------------------------------------------
-- 服务事件
function cls:start(channel_id)
	-- body
	assert(self)
	local CMD = require "CMD"
	local channel = mc.new {
		channel = channel_id,
		dispatch = function (_, _, cmd, ...)
			-- body
			local f = assert(CMD[cmd])
			local ok, result = pcall(f, self, ... )
			if not ok then
				log.error(result)
			end
		end
	}
	self.channel = channel
	-- channel:subscribe()
	return true
end

function cls:init_data()
	-- body
	local pack = skynet.call(".DB", "lua", "read_room", self.id)
	if pack then
		local db_room = pack.db_room
		local open = db_room.open
		if not open then
			return true
		end
		-- self._id = db_room.id
	 --    self._host = db_room.host
	 --    self._open = db_room.open
	 --    self._local = db_room['local']
	 --    self._overtype = db_room.overtype
	 --    self._maxmultiple = db_room.maxmultiple
	 --    self._hujiaozhuanyi = db_room.hujiaozhuanyi
	 --    self._zimo = db_room.zimo
	 --    self._dianganghua = db_room.dianganghua
	 --    self._daiyaojiu = db_room.daiyaojiu
	 --    self._duanyaojiu = db_room.duanyaojiu
	 --    self._jiangdui = db_room.jiangdui
	 --    self._tiandihu = db_room.tiandihu
	 --    self._maxju = db_room.maxju

	 --    -- gameplay data
	 --    self._state = db_room.state
	 --    self._laststate = db_room.last_state
	 --    self._firsttake = db_room.firsttake
	 --    self._firstidx = db_room.firstidx
	 --    self._curtake = db_room.curtake
	 --    self._curidx = db_room.curidx
	 --    self._lastidx = db_room.lastidx
		-- if db_room.lastcard then
		-- 	self._lastcard = self._kcards[db_room.lastcard]
		-- end
	 --    self._firsthu = db_room.firsthu
	 --    self._hucount = db_room.hucount
	 --    self._ju = db_room.ju

		-- for _,db_user in pairs(data.users) do
		-- 	local player = self._players[db_user.idx]
		-- 	player._uid = db_user.uid
		-- 	player._idx = db_user.idx
		-- 	player._chip = db_user.chip
		-- 	player._state = db_user.state
		-- 	player._laststate = db_user.last_state
		-- 	player._que = db_user.que
		-- 	player._takecardsidx = db_user.takecardsidx
		-- 	player._takecardscnt = db_user.takecardscnt
		-- 	player._takecardslen = db_user.takecardslen
		-- 	for k,v in pairs(db_user.takecards) do
		-- 		local cc = self._kcards[v]
		-- 		cc:set_pos(tonumber(k))
		-- 		player:insert_take_cards_with_pos(cc)
		-- 	end
		-- 	for k,v in pairs(db_user.cards) do
		-- 		local cc = self._kcards[v]
		-- 		cc:set_pos(tonumber(k))
		-- 		player:insert_take_cards_with_pos(cc)
		-- 	end
		-- 	for k,v in pairs(db_user.leadcards) do
		-- 		-- local cc = self._kcards[v]
		-- 		-- cc:set_pos(tonumber(k))
		-- 	end
		-- 	for k,v in pairs(db_user.putcards) do
		-- 		-- local cc = self._kcards[v]
		-- 		-- cc:set_pos(tonumber(k))
		-- 	end
		-- 	player._putidx = db_user.putidx
		-- 	player._holdcard = self._kcards[db_user.holdcard]
		-- 	for k,v in pairs(db_user.hucards) do
		-- 		print(k,v)
		-- 	end
		-- end
	end
	return true
end

function cls:sayhi()
	-- body
	assert(self)
	return true
end

function cls:save_data()
	-- body
	if not self._open then
		-- log.info("roomid = %d, save_data self._open is false", self._id)
		return
	end
	-- local db_users = {}
	-- local db_room = {}
	-- for k,v in pairs(self._players) do
	-- 	if v._uid > 0 then      -- > 0 才是有人加入
	-- 		local db_user = {}
	-- 		db_user.uid = assert(v._uid)
	-- 		db_user.idx = assert(v._idx)
	-- 		db_user.chip = assert(v._chip)
	-- 		db_user.state = assert(v._state)
	-- 		db_user.last_state   = assert(v._laststate)
	-- 		db_user.que          = assert(v._que)
	-- 		db_user.takecardsidx = assert(v._takecardsidx)
	-- 		db_user.takecardscnt = assert(v._takecardscnt)
	-- 		db_user.takecardslen = assert(v._takecardslen)
	-- 		db_user.takecards = {}
	-- 		for pos,card in pairs(v._takecards) do
	-- 			db_user.takecards[string.format("%d", pos)] = card:get_value()
	-- 		end
	-- 		db_user.cards = {}
	-- 		for pos,card in pairs(v._cards) do
	-- 			db_user.cards[string.format("%d", pos)] = card:get_value()
	-- 		end
	-- 		db_user.leadcards = {}
	-- 		for pos,card in pairs(v._leadcards) do
	-- 			db_user.leadcards[string.format("%d", pos)] = card:get_value()
	-- 		end
	-- 		db_user.putcards = {}
	-- 		for pos,card in pairs(v._putcards) do
	-- 			db_user.putcards[string.format("%d", pos)] = card:get_value()
	-- 		end
	-- 		db_user.putidx = assert(v._putidx)
	-- 		if v._holdcard then
	-- 			db_user.holdcard = assert(v._holdcard:get_value())
	-- 		end
	-- 		db_user.hucards = {}
	-- 		for pos,card in pairs(v._hucards) do
	-- 			db_user.hucards[string.format("%d", pos)] = card:get_value()
	-- 		end
	-- 		db_users[string.format("%d", k)] = db_user
	-- 	end
	-- end
	-- db_room.open = assert(self._open)
	-- db_room.id = assert(self._id)
	-- db_room.host = assert(self._host)
	-- db_room['local'] = self._local
	-- db_room.overtype = self._overtype
	-- db_room.maxmultiple = self._maxmultiple
	-- db_room.hujiaozhuanyi = self._hujiaozhuanyi
	-- db_room.zimo = self._zimo
	-- db_room.dianganghua = self._dianganghua
	-- db_room.daiyaojiu = self._daiyaojiu
	-- db_room.duanyaojiu = self._duanyaojiu
	-- db_room.jiangdui = self._jiangdui
	-- db_room.tiandihu = self._tiandihu
	-- db_room.maxju = self._maxju

	-- -- gameplay data
	-- db_room.state      = assert(self._state)
	-- db_room.last_state = assert(self._laststate)
	-- db_room.firsttake  = assert(self._firsttake)
	-- db_room.firstidx   = assert(self._firstidx)
	-- db_room.curtake    = assert(self._curtake)
	-- db_room.curidx     = assert(self._curidx)
	-- db_room.lastidx    = assert(self._lastidx)
	-- if self._lastcard then
	-- 	db_room.lastcard = self._lastcard:get_value()
	-- end
	-- db_room.firsthu = self._firsthu
	-- db_room.hucount = self._hucount
	-- db_room.ju = self._ju

	-- local data = {}
	-- data.users = db_users
	-- data.room = db_room
	-- local pack = json.encode(data)
	-- redis:set(string.format("tb_room:%d", self._id), pack)
end

function cls:close()
	-- body
	assert(self)
	-- self._open = false
	return true
end

function cls:afk(uid)
	-- body
	log.info('roomid = %d, uid(%d) afk', self._id, uid)
	local p = self:get_player_by_uid(uid)
	assert(p)
	p:set_online(false)
	self:decre_online()
	self._state = state.JOIN

	local args = {}
	args.idx = p:get_idx()
	self:push_client_except_idx(p:get_idx(), "offline", args)
	return true
end

------------------------------------------
-- 协议
function cls:create(uid, args)
	-- body
	assert(uid)
	assert(args)
	self.host = uid
	self.open = true

	-- clear player
	for i=1,self.max do
		local p = self.players[i]
		assert(p:is_none())
		assert(not p.online)
	end
	self.joined = 0
	self.online = 0

	self:clear()

	self._stime = 0
	self._record = {}
	self._ju = 0

	log.info("room create success.")
	local res = {}
	res.errorcode = 0
	res.roomid = self.id
	res.room_max = self.max
	return res
end

function cls:join(uid, agent, name, sex)
	-- body
	assert(uid and agent and name and sex)
	local res = {}
	if self._state ~= state.JOIN then
		res.errorcode = 15
		return res
	end

	if self._joined >= self._max then
		res.errorcode = 16
		return res
	end

	-- 原来肯定是不存在此用户
	local p = self:get_player_by_uid(uid)
	assert(p == nil)

	local me = assert(self:find_noone())
	me.uid = uid
	me.agent = agent
	me.name = name
	me.sex = sex
	me.online = true
	self:incre_joined()
	self:incre_online()

	-- 返回给当前用户的信息
	local p = {
		idx   =  me.idx,
		cards = {},
		lead = {}
	}

	local res = {}
	res.errorcode = 0
	res.roomid = self.id
	res.room_max = self.max
	res.me = p
	res.ps = {}
	for _,v in ipairs(self.players) do
		if not v:is_none() and v.uid ~= uid then
			local p = {
				idx   =  v.idx,
				cards = {},
				lead  = {}
			}
			table.insert(res.ps, p)
		end
	end
	skynet.retpack(res)

	local args = {}
	args.p = p
	self:push_client_except_idx(me:get_idx(), "join", args)

	if self._joined >= self._max then
		self.alert.ready(self)
		self._state = state.READY
		self:clear_state(player.state.WAIT_READY)
	end
	return servicecode.NORET
end

function cls:rejoin(uid, agent)
	-- body
	assert(uid and agent)
	local res = { errorcode = 0 }
	local me = self:get_player_by_uid(uid)
	if me == nil then
		res.errorcode = 17
		return res
	end

	assert(not me:get_online())
	me:set_agent(agent)
	me:set_online(true)
	self._online = self._online + 1

	-- sync
	local p = {
		idx   =  me._idx,
		chip  =  me._chip,
		sex   =  me._sex,
		name  =  me._name,
		state =  me._state,
		last_state   = me._laststate,
		que          = me._que,
		takecardsidx = me._takecardsidx,
		takecardscnt = me._takecardscnt,
		takecardslen = me._takecardslen,
		takecards    = me:pack_takecards(),
		cards        = me:pack_cards(),
		leadcards    = me:pack_leadcards(),
		putcards     = me:pack_putcards(),
		putidx       = me._putidx,
		hold_card    = me:pack_holdcard(),
		hucards      = me:pack_hucards()
	}

	res.errorcode = 0
	res.roomid = self._id
	res.room_max = self._max
	res.me = p
	res.ps = {}
	for _,v in ipairs(self._players) do
		if not v:get_noone() and v:get_uid() ~= uid then
			local p = {
				idx   =  v._idx,
				chip  =  v._chip,
				sex   =  v._sex,
				name  =  v._name,
				state =  v._state,
				last_state   = v._laststate,
				que          = v._que,
				takecardsidx = v._takecardsidx,
				takecardscnt = v._takecardscnt,
				takecardslen = v._takecardslen,
				takecards    = v:pack_takecards(),
				cards        = v:pack_cards(),
				leadcards    = v:pack_leadcards(),
				putcards     = v:pack_putcards(),
				putidx       = v._putidx,
				hold_card    = v:pack_holdcard(),
				hucards      = v:pack_hucards()
			}
			table.insert(res.ps, p)
		end
	end
	skynet.retpack(res)

	local args = {}
	args.p = p
	self:push_client_except_idx(me:get_idx(), "rejoin", args)
	return servicecode.NORET
end

function cls:leave(uid)
	-- body
	local p = self:get_player_by_uid(uid)
	assert(p)
	local idx = p:get_idx()
	p:set_online(false)
	p:set_uid(0)
	self:decre_online()
	self:decre_joined()
	self._state = state.JOIN
	local res = {}
	res.errorcode = 0
	skynet.retpack(res)

	local args = {}
	args.idx = idx
	self:push_client_except_idx(idx, "leave", args)
	return servicecode.NORET
end

------------------------------------------
-- 大佬2协议
function cls:step(idx)
	-- body
	assert(idx)
	local res = {}
	if not self.open then
		res.errorcode = 1
		return res
	end
	if idx < 1 or idx > self.max then
		res.errorcode = 1
		return res
	end
	-- 检测此玩家是否
	local p = self.players[idx]
	if p:is_none() then
		res.errorcode = 1
		return res
	end
	if self.alert.is(state.JOIN) then
		log.warning("step wrong state JOIN")
		res.errorcode = 1
		return res
	elseif self.alert.is(state.READY) then
		log.warning("step wrong state READY")
		res.errorcode = 1
		return res
	elseif self.alert.is(state.SHUFFLE) then
		log.warning("step wrong state SHUFFLE")
		res.errorcode = 1
		return res
	elseif self._state == state.DEAL then
		res.errorcode = 0
		skynet.retpack(res)
		-- 此玩家发牌完成
		p.alert.deal()
	elseif self._state == state.LEAD then
		res.errorcode = 0
		skynet.retpack(res)
		p.alert.lead()
	elseif self._state == state.CALL then
		res.errorcode = 0
		skynet.retpack(res)
		p.alert.call()
	elseif self._state == state.OVER then
		res.errorcode = 0
		skynet.retpack(res)
		p.alert.over()
	end
	return servicecode.NORET
end

function cls:ready(idx)
	-- body
	local res = {}
	if not self.open then
		res.errorcode = 1
		return res
	end
	if not self.alert.is(state.READY) then
		res.errorcode = errorcode.WRONG_STATE
		res.idx = idx
		return res
	end
	local p = self.players[idx]
	if p == nil then
		res.errorcode = errorcode.FAIL 
		return res
	end
	if not p.alert.is(player.state.WAIT_READY) then
		res.errorcode = errorcode.WRONG_STATE
		res.idx = idx
		return res
	end
	-- 转移状态
	p.alert.ready()
	res.errorcode = 0
	res.idx = idx
	skynet.retpack(res)

	if self:is_next_state(player.state.READY) then
		self:take_shuffle()
	end
	return servicecode.NORET
end

function cls:lead(idx, leadtype, cards)
	-- body
	assert(idx)
	local res = {}
	if not self.open then
		res.errorcode = 1
		return res
	end
	if idx < 1 or idx > self.max then
		res.errorcode = 1
		return res
	end
	-- 检测此玩家是否
	local p = self.players[idx]
	if p:is_none() then
		res.errorcode = 1
		return res
	end
	local errorcode = p:lead(leadtype, cards)
	if errorcode == 0 then
		res.errorcode = errorcode
		skynet.retpack(res)
		self:take_lead()
		return servicecode.NORET
	else
		res.errorcode = errorcode
		return res
	end
end

function cls:call(idx, opcode)
	-- body
	local res = {}
	if not self.open then
		res.errorcode = 1
		return res
	end
	assert(opcode)
	local p = self.players[idx]
	p.pass = true

	res.errorcode = 0
	skynet.retpack(res)

	self:take_call()
	return servicecode.NORET
end

function cls:timeout_call(opinfo, ... )
	-- body
	self:call(opinfo)
end

function cls:restart(idx, ... )
	-- body
	if self._state == state.FINAL_SETTLE then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_RESTART) then
			self:take_restart()
		else
			local args = {}
			args.idx = idx
			self:push_client("restart", args)
		end
	end
end

function cls:timeout_restart(idx, ... )
	-- body
end

-- turn state
function cls:take_shuffle()
	-- body
	assert(self.alert.is(state.READY))
	self.alert.shuffle(self)

	-- 开始洗牌后才开始计算消耗品
	self._ju = self._ju + 1
	if self._ju == 1 then
		-- send agent
		local p = self:get_player_by_uid(self._host)
		local addr = p:get_agent()
		local ok = skynet.call(addr, "lua", "alter_rcard", -1)
		assert(ok)
	end

	-- 记录所有消息
	self._stime = skynet.now()
	self._record = {}

	-- record 
	local args = {}
	for i=1,self._max do
		local p = {}
		p.idx = self._players[i]:get_idx()
		p.uid = self._players[i]:get_uid()
		table.insert(args, p)
	end
	self:record("players", args)

	if self._ju == 1 then
		self._firstidx = self:get_player_by_uid(self._host):get_idx()
	else
		self._firstidx = self._lastfirsthu
	end
	self._curidx = self._firstidx

	for i=1,self._cardssz do
		self._cards[i]:clear()
	end

	-- 洗牌算法
	assert(#self._cards == 108)
	for i=107,1,-1 do
		local swp = math.floor(math.random(1, 1000)) % 108 + 1
		while swp == i do
			swp = math.floor(math.random(1, 1000)) % 108 + 1
		end
		local tmp = assert(self._cards[i])
		self._cards[i] = assert(self._cards[swp], swp)
		self._cards[swp] = tmp
	end
	assert(#self._cards == 108)

	self:record("shuffle", args)
	self:push_client("shuffle", args)
end

function cls:take_deal()
	-- body
	-- 发牌
	self:transfer_player_state(Player.state.WAIT_DEAL)
	for i=1,4 do
		for j=1,4 do
			local p = self._players[self._curidx]
			if i == 4 then
				local ok, card = self:take_card()
				assert(ok)
				p:insert(card)
			else
				for i=1,4 do
					local ok, card = self:take_card()
					assert(ok)
					p:insert(card)	
				end
			end
			self._curidx = self:next_idx()
		end
	end

	for i=1,self._max do
		self._players[i]:print_cards()
	end

	-- take first card
	local ok, card = self:take_card()
	assert(ok and self._curidx == self._firstidx)
	self._players[self._curidx]:take_turn_card(card)

	local p1 = self._players[1]:get_cards_value()
	local p2 = self._players[2]:get_cards_value()
	local p3 = self._players[3]:get_cards_value()
	local p4 = self._players[4]:get_cards_value()

	local args = {}
	args.firstidx  = self._firstidx
	args.firsttake = self._firsttake
	args.p1 = p1
	args.p2 = p2
	args.p3 = p3
	args.p4 = p4
	args.card = self._curcard:get_value()

	self:record("deal", args)
	self:push_client("deal", args)
end

-- 当前用户需要出牌，可能摸了一个牌，也可能是其他
function cls:take_turn()
	-- body
	self:next_idx_wait_turn()

	-- 暂时取消倒计时
	-- local card = self._players[self._curidx]:take_turn_after_peng()
	-- assert(self._players[self._curidx]._holdcard)
	-- self._players[self._curidx]:timeout(self._countdown * 100)

	local args = {}
	args.your_turn = self.curidx
	args.countdown = self.countdown
	-- self:record("take_turn", args)
	self:push_client("take_turn", args)
end

function cls:take_lead()
	-- body
	assert(self.alert.is(state.TURN))
	self.alert.lead()
	local p = assert(self.players[self.curidx])
	assert(p)
	local args = {}
	args.idx = self.curidx
	args.leadtype = 0
	args.cards = {}
	self:push_client("big2lead", args)
end

function cls:take_call()
	-- body
	assert(self.alert.is(state.CALL))
	local p = assert(self.players[self.curidx])
	assert(p)
	local args = {}
	args.idx = self.curidx
	self:push_client("big2call", args)
end

function cls:take_over()
	-- body
	self._state = state.OVER
	self:clear_state(player.state.WAIT_OVER)

	-- 检查没有胡玩家的是否有叫，
	-- 1. 没有叫并且刚过，退税
	-- 2. 没有叫给有叫的赔

	local settles = {}
	local wuhu = 0
	for i=1,self._max do
		if not self._players[i]:hashu() then
			wuhu = wuhu + 1
		end
	end
	if wuhu > 1 then
		-- check hua zhu
		local huazhus = {}
		local wudajiaos = {}
		local dajiaos = {}
		for i=1,self._max do
			if self._players[i]:hashu() then
			else
				if self._players[i]:check_que() then
					local res = self._players[i]:check_jiao()
					res.idx = i
					if res.code ~= hutype.NONE then
						table.insert(dajiaos, res)
					else
						table.insert(wudajiaos, res)
					end
				else
					table.insert(huazhus, { idx = i })
				end
			end
		end
		-- tuisui
		if #huazhus > 0 then
			for k,v in pairs(huazhus) do
				local settle = {}
				self._players[v.idx]:tuisui(settle)
				table.insert(settles, settle)
			end
		end

		if #dajiaos == wuhu then
		elseif #dajiaos > 0 then

			for k,v in pairs(dajiaos) do
				local settle = {}

				local base = self._humultiple(v.code, jiaotype.PINGFANG, v.gang)
				local total = 0
				local lose = {}
				local win = {}

				table.insert(win, v.idx)
				for k,h in pairs(wudajiaos) do
					total = total + base
					table.insert(lose, h.idx)

					local litem = {}
					litem.idx  = h.idx
					litem.chip = -base
					litem.left = self._players[litem.idx]:settle(litem.chip)

					litem.win  = win
					litem.lose = lose
					litem.gang = opcode.none
					litem.hucode = v.code
					litem.hujiao = jiaotype.PINGFANG
					litem.hugang = v.gang
					litem.huazhu = 0
					litem.dajiao = 1
					litem.tuisui = 0

					self:insert_settle(settle, litem.idx, litem)
					self._players[litem.idx]:record_settle(litem)
				end
				for k,h in pairs(huazhus) do						
					total = total + base
					table.insert(lose, h.idx)

					local litem = {}
					litem.idx = h.idx
					litem.chip = -base
					litem.left = self._players[litem.idx]:settle(litem.chip)

					litem.win = win
					litem.lose = lose
					litem.gang = opcode.none
					litem.hucode = v.code
					litem.hujiao = hutype.PINGFANG
					litem.hugang = v.gang
					litem.huazhu = 1
					litem.dajiao = 0
					litem.tuisui = 0

					self:insert_settle(settle, litem.idx, litem)
					self._players[h.idx]:record_settle(litem)
				end	

				local witem = {}
				witem.idx = v.idx
				witem.chip = total
				witem.left = self._players[v.idx]:settle(witem.chip)

				witem.win  = win
				witem.lose = lose
				witem.gang = opcode.none
				witem.hucode = v.code
				witem.hujiao = jiaotype.PINGFANG
				witem.hugang = v.gang

				witem.huazhu = 0
				witem.dajiao = 1
				witem.tuisui = 0
				self:insert_settle(settle, witem.idx, witem)
				self._players[v.idx]:record_settle(witem)
			end
		end
	end

	self:record("over")
	self:push_client("over")
end

function cls:take_settle( ... )
	-- body
	self._state = state.SETTLE
	self:clear_state(player.state.WAIT_SETTLE)

	
	local args = {}
	args.settles = settles

	self:record("settle", args)
	self:push_client("settle", args)
end

function cls:take_final_settle( ... )
	-- body
	self._state = state.FINAL_SETTLE
	self:clear_state(player.state.FINAL_SETTLE)

	local over = false
	if self._ju == self._maxju then
		-- over
		over = true
		skynet.send(".ROOM_MGR", "lua", "enqueue_room", self._id)
		for i=1,self._max do
			local addr = self._players[i]:get_agent()
			skynet.send(addr, "lua", "room_over")
		end
	end

	local args = {}
	args.p1 = self._players[1]._chipli
	args.p2 = self._players[2]._chipli
	args.p3 = self._players[3]._chipli
	args.p4 = self._players[4]._chipli
	args.settles = settles
	args.over = over

	self:record("final_settle", args)
	local recordid = skynet.call(".RECORD_MGR", "lua", "register", cjson.encode(self._record))
	self._record = {}
	local names = {}
	for i=1,self._max do
		table.insert(names, self._players[i]:get_name())
	end
	for i=1,self._max do
		local addr = self._players[i]:get_agent()
		skynet.send(addr, "lua", "record", recordid, names)
	end

	self:push_client("final_settle", args)
end

function cls:take_restart()
	-- body
	self._state = state.RESTART
	self:clear_state(player.state.WAIT_RESTART)

	self:clear()

	for i=1,self._max do
		self._players[i]:take_restart()
	end

	self:push_client("take_restart")
end

function cls:take_roomover( ... )
	-- body
end

function cls:insert_settle(settle, idx, item, ... )
	-- body
	assert(settle and idx and item)
	assert(idx > 0 and idx <= self._max)
	if idx == 1 then
		assert(settle.p1 == nil)
		settle.p1 = item
	elseif idx == 2 then
		assert(settle.p2 == nil)
		settle.p2 = item
	elseif idx == 3 then
		assert(settle.p3 == nil)
		settle.p3 = item
	elseif idx == 4 then
		assert(settle.p4 == nil)
		settle.p4 = item
	else
		assert(false)
	end
end

return cls

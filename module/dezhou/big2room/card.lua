-- local log = require "log"
local assert = assert

local TYPE_SHIFT = 8
local NUM_SHIFT = 4
local IDX_SHIFT = 0

local cls = class("card")

cls.type = {}
cls.type.NONE = 0
cls.type.CLUBS    = 1       -- 梅花
cls.type.DIANMOND = 2       -- 方块
cls.type.HEART    = 3       -- 红心
cls.type.SPADE    = 4       -- 黑桃


function cls:ctor(t, num, idx)
	-- body
	-- log.info("t:%d, num:%d, idx:%d", t, num, idx)
	assert(t and num)
	self.type = t
	self.num  = num
	self.idx  = 0
	self.value = ((t & 0xff) << TYPE_SHIFT) | ((num & 0x0f) << NUM_SHIFT) | ((idx & 0x0f) << IDX_SHIFT)
	self.pos = 0
	self._que  = 0
	self._master = false  -- 判断是否已经被分配
	self._bright = false  -- 判断是否已经被选中

	return self
end

-- position
function cls:get_pos()
	-- body
	return self._pos
end

function cls:set_pos(pos, ... )
	-- body
	self._pos = pos
end

function cls:set_master(m, ... )
	-- body
	self._master = m
end

function cls:get_master( ... )
	-- body
	return self._master
end

function cls:set_bright(flag, ... )
	-- body
	self._bright = flag
end

function cls:get_bright( ... )
	-- body
	return self._bright
end

function cls:clear()
	-- body
	self._que = 0
	self._pos = 0         -- deal
	self._master = false  -- deal
	self._bright = false  -- selection
end

-- 比较单牌,这里只比较数字
function cls:mt(o, ... )
	-- body
	if self._que == o._que then
		return self._value > o._value
	else
		return self._que > o._que
	end
end

function cls:eq(o, ... )
	-- body
	if self._type == o._type and self._num == o._num then
		return true
	else
		return false
	end
end

function cls:lt(o, ... )
	-- body
	return self._value < o._value
end

function cls:describe( ... )
	-- body
	local res = ""
	if self._type == cls.type.CRAK then
		res = res .. "crak "
	elseif self._type == cls.type.BAM then
		res = res .. "bam "
	elseif self._type == cls.type.DOT then
		res = res .. "dot "
	end

	res = res .. string.format("%d,", self._num)
	res = res .. string.format("pos: %d", self._pos)

	return res
end

return cls
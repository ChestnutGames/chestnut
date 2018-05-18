local MakeComponent = require "entitas.MakeComponent"

return MakeComponent("room",
	"id",                         -- 创建的id
	"addr",                       -- 临时地址
	"isCreated",                  -- 是否创建了
	"joined",                     -- 是否加入
	"online",                      -- 是否在线
	"matching"                     -- 匹配中
)
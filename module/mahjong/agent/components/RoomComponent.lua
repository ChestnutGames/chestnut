local MakeComponent = require "entitas.MakeComponent"

return MakeComponent("room",
	"isCreated",                  -- 是否创建了
	"id",                         -- 创建的id
	"joined",                     -- 是否加入
	"online"
)
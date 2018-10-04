local AhievementSystem = require "systems.AhievementSystem"
local DbSystem = require "systems.DbSystem"
local FuncOpenSystem = require "systems.FuncOpenSystem"
local LevelSystem = require "systems.LevelSystem"
local PackageSystem = require "systems.PackageSystem"
local RoomSystem = require "systems.RoomSystem"
local UserSystem = require "systems.UserSystem"


local table_insert = table.insert

local Processors = class("Processors")

function Processors:ctor(agentContext)

    self._set_context_processors = {}
    self._set_systems_processors = {}
    self._initialize_processors = {}
    self._execute_processors = {}
    self._cleanup_processors = {}
    self._tear_down_processors = {}
    self._afk_processors = {}
    self._data_init_processors = {}

    self.agentContext = agentContext
    self.user = UserSystem.new(agentContext)
    self.room = RoomSystem.new(agentContext)
    self.db = DbSystem.new(agentContext)
    self.package = PackageSystem.new(agentContext)
    self.funcopen = FuncOpenSystem.new(agentContext)


    self:add(self.user)
    self:add(self.room)
    self:add(self.db)
    self:add(self.package)
    self:add(self.funcopen)
end

function Processors:add(processor)
    if processor.set_context then
        table_insert(self._set_context_processors, processor)
    end

    if processor.set_agent_systems then
        table_insert(self._set_systems_processors, processor)
    end

    if processor.initialize then
        table_insert(self._initialize_processors, processor)
    end

    if processor.execute then
        table_insert(self._execute_processors, processor)
    end

    if processor.cleanup then
        table_insert(self._cleanup_processors, processor)
    end

    if processor.tear_down then
        table_insert(self._tear_down_processors, processor)
    end

    if processor.afk then
        table_insert(self._afk_processors, processor)
    end

    if processor.on_data_init then
        table_insert(self._data_init_processors, processor)
    end
end

function Processors:set_context(context, ... )
    -- body
    for _, processor in pairs(self._set_context_processors) do
        processor:set_context(context)
    end
end

function Processors:set_agent_systems(systems, ... )
    -- body
    for _, processor in pairs(self._set_systems_processors) do
        processor:set_agent_systems(systems)
    end
end

function Processors:initialize()
    for _, processor in pairs(self._initialize_processors) do
        processor:initialize()
    end
end

function Processors:execute()
    for _, processor in pairs(self._execute_processors) do
        processor:execute()
    end
end

function Processors:cleanup()
    for _, processor in pairs(self._cleanup_processors) do
        processor:cleanup()
    end
end

function Processors:tear_down()
    for _, processor in pairs(self._tear_down_processors) do
        processor:tear_down()
    end
end

function Processors:activate_reactive_processors()
    for _, processor in pairs(self._execute_processors) do
        if isinstance(processor, ReactiveProcessor) then
            processor:activate()
        end

        if isinstance(processor, Processors) then
            processor:activate_reactive_processors()
        end
    end
end

function Processors:deactivate_reactive_processors()
    for _, processor in pairs(self._execute_processors) do
        if isinstance(processor, ReactiveProcessor) then
            processor:deactivate()
        end

        if isinstance(processor, Processors) then
            processor:deactivate_reactive_processors()
        end
    end
end

function Processors:clear_reactive_processors()
    for _, processor in pairs(self._execute_processors) do
        if isinstance(processor, ReactiveProcessor) then
            processor:clear()
        end

        if isinstance(processor, Processors) then
            processor:clear_reactive_processors()
        end
    end
end

function Processors:afk( ... )
    -- body
    for _, processor in pairs(self._afk_processors) do
        processor:afk()
    end
end

function Processors:on_data_init()
    for _, processor in pairs(self._data_init_processors) do
        processor:on_data_init()
    end
end

return Processors
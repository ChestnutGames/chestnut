local AhievementSystem = require "chestnut.systems.AhievementSystem"
local FuncOpenSystem = require "chestnut.systems.FuncOpenSystem"
local LevelSystem = require "chestnut.systems.LevelSystem"
local PackageSystem = require "chestnut.systems.PackageSystem"
local RoomSystem = require "chestnut.systems.RoomSystem"
local UserSystem = require "chestnut.systems.UserSystem"
local log = require "chestnut.skynet.log"

local traceback = debug.traceback
local table_insert = table.insert

local Processors = {}

function Processors:on_data_init(dbData)
    for _, processor in pairs(self._data_init_processors) do
        local ok, err = xpcall(processor.on_data_init, traceback, processor, dbData)
        if not ok then
            log.error(err)
        end
    end
end

function Processors:on_data_save(dbData)
    -- body
    for _, processor in pairs(self._data_save_processors) do
        local ok, err = xpcall(processor.on_data_save, traceback, processor, dbData)
        if not ok then
            log.error(err)
        end
    end
end

function Processors:on_enter()
    for _, processor in pairs(self._initialize_processors) do
        processor:initialize()
    end
end

function Processors:on_exit()
    for _, processor in pairs(self._execute_processors) do
        processor:execute()
    end
end

function Processors:on_new_day()
    for _, processor in pairs(self._cleanup_processors) do
        processor:cleanup()
    end
end

return Processors
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local Overlay = require("game_manager.overlays.Overlay")
local EventBus = require("EventBus")
local gui = require("game_manager.gui.my_levels_game_end")
local GameEndOverlay = require("game_manager.overlays.GameEndOverlay")

local MyLevelsGameEndOverlay = {}
MyLevelsGameEndOverlay.__index = MyLevelsGameEndOverlay
setmetatable(MyLevelsGameEndOverlay, GameEndOverlay)

function MyLevelsGameEndOverlay:new(wrapped, timer_overlay, base_scene, pause_overlay, quit, register_time, best_time)
    local obj = GameEndOverlay:new(wrapped, timer_overlay, base_scene, pause_overlay)

    obj.quit = quit
    obj.register_time = register_time
    obj.best_time = best_time

    setmetatable(obj, MyLevelsGameEndOverlay)

    return obj
end

function MyLevelsGameEndOverlay:on_game_end(base_scene)
    if base_scene ~= self.base_scene then return end
    self.register_time(self.timer_overlay:get_time())
    GameEndOverlay.on_game_end(self, base_scene)
end

function MyLevelsGameEndOverlay:get_gui()
    return gui({
        quit = function()
            self:restart()
            self.quit()
        end,
        restart = function()
            self:restart()
        end
    }, self.timer_overlay:get_time(), self.best_time())
end

return MyLevelsGameEndOverlay
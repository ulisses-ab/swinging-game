local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local Overlay = require("game_manager.overlays.Overlay")
local EventBus = require("EventBus")
local gui = require("game_manager.gui.game_end")
local GameEndOverlay = require("game_manager.overlays.GameEndOverlay")

local CampaignGameEndOverlay = {}
CampaignGameEndOverlay.__index = CampaignGameEndOverlay
setmetatable(CampaignGameEndOverlay, GameEndOverlay)

function CampaignGameEndOverlay:new(wrapped, timer_overlay, base_scene, pause_overlay, quit, next_level, star_times, register_time, best_time)
    local obj = GameEndOverlay:new(wrapped, timer_overlay, base_scene, pause_overlay)

    obj.quit = quit
    obj.next = next_level
    obj.star_times = star_times
    obj.register_time = register_time
    obj.best_time = best_time

    setmetatable(obj, CampaignGameEndOverlay)

    return obj
end

function CampaignGameEndOverlay:on_game_end(base_scene)
    if base_scene ~= self.base_scene then return end
    self.register_time(self.timer_overlay:get_time())
    GameEndOverlay.on_game_end(self, base_scene)
end

function CampaignGameEndOverlay:get_gui()
    return gui({
        quit = function()
            self:restart()
            self.quit()
        end,
        restart = function()
            self:restart()
        end,
        next = self.next
    }, self.timer_overlay:get_time(), self.star_times, self.best_time())
end

return CampaignGameEndOverlay
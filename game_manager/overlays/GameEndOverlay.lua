local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local Overlay = require("game_manager.overlays.Overlay")
local EventBus = require("EventBus")
local gui = require("game_manager.gui.game_end")
local Player = require("game_objects.Player")

local GameEndOverlay = {}
GameEndOverlay.__index = GameEndOverlay
setmetatable(GameEndOverlay, Overlay)

function GameEndOverlay:new(wrapped, timer_overlay, base_scene, pause_overlay)
    local obj = Overlay:new(wrapped)

    obj.timer_overlay = timer_overlay
    obj.base_scene = base_scene
    obj.font = love.graphics.newFont("assets/fonts/default.ttf", 32)
    obj.timer = 5
    obj.FREEZE_START = 3.2
    obj.game_has_ended = false
    obj.freeze_started = false
    obj.pause_overlay = pause_overlay

    EventBus:listen("GameEnded", function(...) obj:on_game_end(...) end)

    setmetatable(obj, self)

    return obj
end

function GameEndOverlay:on_game_end(base_scene)
    if not base_scene == self.base_scene then return end
    
    self.timer = 0
    self.game_has_ended = true

    Player.allow_respawn = false

    if self.pause_overlay then
        self.pause_overlay.active = false
    end
end

function GameEndOverlay:update(dt)
    self.timer = self.timer + dt

    if self.timer > self.FREEZE_START and self.game_has_ended and not self.freeze_started then
        self:on_freeze_start()
    end

    Overlay.update(self, dt)
end

function GameEndOverlay:on_freeze_start()
    self.freeze_started = true

    self.gui = self:get_gui()

    self:add_updatable(self.gui)
    self:remove_updatable(self.wrapped)
end

function GameEndOverlay:draw()
    self.wrapped:draw()

    if self.freeze_started then
        love.graphics.setColor(0, 0, 0, 0.92)
        util.draw_clear()
        love.graphics.setColor(1,1,1,1)
        self.gui:draw()
    end
end

function GameEndOverlay:restart()
    self.game_has_ended = false
    self.freeze_started = false

    self:add_updatable(self.wrapped)
    self:remove_updatable(self.gui)

    Player.allow_respawn = true
    self.base_scene:get_player():respawn()

    if self.pause_overlay then
        self.pause_overlay.active = true
    end
end

return GameEndOverlay
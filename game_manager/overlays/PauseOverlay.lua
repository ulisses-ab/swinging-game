local Scene = require("Scene")
local Vec2 = require("Vec2")
local gui = require("game_manager.gui.paused")
local util = require("util")
local Overlay = require("game_manager.overlays.Overlay")

local PauseOverlay = {}
PauseOverlay.__index = PauseOverlay
setmetatable(PauseOverlay, Overlay)

function PauseOverlay:new(wrapped, quit, countdown_overlay, text)
    local obj = Overlay:new(wrapped)

    obj.countdown_overlay = countdown_overlay
    obj.paused = false
    obj.gui = gui({
        continue = function()
            obj:unpause()
        end,
        quit = quit
    }, text)
    obj.active = true

    return setmetatable(obj, self)
end

function PauseOverlay:unpause()
    self.paused = false

    if self.countdown_overlay then
        self.countdown_overlay:start_countdown(3)
    end

    self:add_updatable(self.wrapped)
    self:remove_updatable(self.gui)
end

function PauseOverlay:pause()
    self.paused = true

    self:add_updatable(self.gui)
    self:remove_updatable(self.wrapped)
end

function PauseOverlay:draw()
    self.wrapped:draw()

    if self.paused then 
        love.graphics.setColor(0, 0, 0, 0.92)
        util.draw_clear()
        self.gui:draw()
    end
end

function PauseOverlay:keypressed(key)
    if key == "escape" and self.active then
        if self.paused then
            self:unpause()
        else
            self:pause()
        end
    end

    if not self.paused then
        Overlay.keypressed(self, key)
    end
end

return PauseOverlay
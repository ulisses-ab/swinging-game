local Scene = require("Scene")
local Vec2 = require("Vec2")
local gui_generator = require("game_manager.gui.paused")
local util = require("util")
local Overlay = require("game_manager.overlays.Overlay")

local PauseOverlay = {}
PauseOverlay.__index = PauseOverlay
setmetatable(PauseOverlay, Overlay)

function PauseOverlay:new(wrapped, quit)
    local obj = Overlay:new(wrapped)

    obj.paused = false
    obj.gui = gui_generator({
        continue = function()
            obj:unpause()
        end,
        quit = quit
    })

    return setmetatable(obj, self)
end

function PauseOverlay:unpause()
    self.paused = false

    if self.wrapped.start_countdown then
        self.wrapped:start_countdown(3)
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
    if key == "escape" then
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
local Scene = require("Scene")
local Vec2 = require("Vec2")
local gui_generator = require("game_manager.gui.paused")
local util = require("util")

local PauseOverlay = {}
PauseOverlay.__index = PauseOverlay

function PauseOverlay:new(wrapped, quit)
    local obj = Overlay:new(wrapped)

    obj.paused = false
    obj.gui = gui_generator({
        continue = function()
            self:unpause()
        end,
        quit = function()
            self.quit()
        end
    })

    return setmetatable(obj, self)
end

function PauseOverlay:unpause()
    self.paused = false

    if self.wrapped.start_countdown then
        self.wrapped.start_countdown(3)
    end

    self:add_updatable(self.scene)
    self:remove_updatable(self.gui)
end

function PauseOverlay:pause()
    self.paused = true

    self:add_updatable(self.gui)
    self:remove_updatable(self.scene)
end

function PauseOverlay:draw()
    self.scene:draw()

    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.95)
        love.graphics.rectangle("fill", -sw/2, -sh/2, sw, sh)
        love.graphics.setColor(1,1,1,1)
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
        self.scene:keypressed(key)
    end
end

return PauseOverlay
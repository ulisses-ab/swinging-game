local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")

local CountdownOverlay = {}
CountdownOverlay.__index = CountdownOverlay
setmetatable(CountdownOverlay, Overlay)

function CountdownOverlay:new(wrapped)
    local obj = Overlay:new(wrapped)

    obj.timer = 0
    obj.font = love.graphics.newFont("assets/fonts/default.ttf", 100)

    return setmetatable(obj, CountdownOverlay)
end

function CountdownOverlay:update(dt)
    self.timer = self.timer - dt

    if self.timer < 0 then
        self.updates_active = true
    end

    Overlay.update(self, dt)
end

function CountdownOverlay:draw()
    self.wrapped:draw()

    if self.timer > 0 then
        self:draw_countdown()
    end
end

function CountdownOverlay:draw_countdown()
    love.graphics.setColor(0, 0, 0, 0.2)
    util.draw_clear()
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(self.font)
    love.graphics.printf(
        math.ceil(self.timer),
        -50,
        -50,
        100,
        "center"
    )
end

function CountdownOverlay:start_countdown(time)
    time = time or 3

    self.timer = time
    self.updates_active = false
end

return CountdownOverlay
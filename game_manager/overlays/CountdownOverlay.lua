local Overlay = require("Overlay")
local Scene = require("Scene")

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
    self.timer = self.timer + dt

    if self.timer < 0 then
        self.updates_active = true
    end
end

function CountdownOverlay:draw()
    self.scene:draw()

    love.graphics.clear(0, 0, 0, 0.2)
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(self.font)
    love.graphics.printf(
        math.ceil(self.timer)+1,
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
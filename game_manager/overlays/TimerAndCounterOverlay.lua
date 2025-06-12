local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local Overlay = require("game_manager.overlays.Overlay")
local EventBus = require("EventBus")

local TimerAndCounterOverlay = {}
TimerAndCounterOverlay.__index = TimerAndCounterOverlay
setmetatable(TimerAndCounterOverlay, Overlay)

function TimerAndCounterOverlay:new(wrapped, base_scene)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene
    obj.font = love.graphics.newFont("assets/fonts/default.ttf", 32)
    obj.timer = 0
    obj.dead_counter = 0

    EventBus:listen("PlayerRespawn", function()
       obj:reset() 
    end)

    return setmetatable(obj, self)
end

function TimerAndCounterOverlay:reset()
    self.timer = 0
end

function TimerAndCounterOverlay:update(dt)
    Overlay.update(self, dt)

    if self.base_scene:count_live_enemies() > 0 then
        self.timer = self.timer + dt
    end
end

function TimerAndCounterOverlay:draw()
    Overlay.draw(self)

    love.graphics.setFont(self.font)
    self:draw_timer()
    self:draw_counter()
end

function TimerAndCounterOverlay:draw_timer()
    love.graphics.printf(
        util.format_time(self.timer),
        -800,
        -320,
        780, --width
        "right"
    )
end

function TimerAndCounterOverlay:draw_counter()
    love.graphics.setColor(1,0,0)
    love.graphics.printf(
        self.base_scene:count_dead_enemies() .. "/" .. self.base_scene:count_enemies(),
        20,
        -320,
        780, --width
        "left"
    )
    love.graphics.setColor(1,1,1)
end

function TimerAndCounterOverlay:get_time()
    return self.timer
end

return TimerAndCounterOverlay
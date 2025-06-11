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

    EventBus:listen("EnemyDeath", function()
        obj:on_enemy_death()
    end)

    return setmetatable(obj, self)
end

function TimerAndCounterOverlay:on_enemy_death()
    self.dead_counter = self.dead_counter + 1
end

function TimerAndCounterOverlay:reset()
    self.timer = 0
    self.dead_counter = 0
end

function TimerAndCounterOverlay:update(dt)
    Overlay.update(self, dt)

    if self.dead_counter ~= #self.base_scene.obj_by_type["Enemy"] then
        self.timer = self.timer + dt
    end
end

function TimerAndCounterOverlay:draw()
    Overlay.draw(self)

    love.graphics.setFont(self.font)
    self:draw_timer()
    self:draw_counter()
end

local function format_time(time)
    local minutes = math.floor(time / 60)
    local seconds = math.floor(time % 60)
    local centiseconds = math.floor((time * 100) % 100)

    if minutes == 0 then
        return string.format("%d.%02d", seconds, centiseconds)
    end

    return string.format("%d:%02d.%02d", minutes, seconds, centiseconds)
end

function TimerAndCounterOverlay:draw_timer()
    love.graphics.printf(
        format_time(self.timer),
        -800,
        -320,
        780, --width
        "right"
    )
end

function TimerAndCounterOverlay:draw_counter()
    love.graphics.setColor(1,0,0)
    love.graphics.printf(
        self.dead_counter .. "/" .. #self.base_scene.obj_by_type["Enemy"],
        20,
        -320,
        780, --width
        "left"
    )
    love.graphics.setColor(1,1,1)
end

return TimerAndCounterOverlay
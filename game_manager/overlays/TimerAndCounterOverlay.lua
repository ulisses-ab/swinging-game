local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")

local TimerAndCounterOverlay = {}
TimerAndCounterOverlay.__index = TimerAndCounterOverlay

function TimerAndCounterOverlay:new(wrapped, base_scene)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene

    return setmetatable(obj, self)
end

function TimerAndCounterOverlay:draw()
    self.scene:draw()

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
    love.graphics.setFont(timer_font)
    love.graphics.printf(
        format_time(self.game_timer),
        -800,
        -320,
        780, --width
        "right"
    )
end

local function count_dead_enemies(scene)
    local count = 0

    for _, enemy in ipairs(scene.obj_by_type["Enemy"]) do
        if enemy.dead then
            count = count + 1
        end
    end

    return count
end

function TimerAndCounterOverlay:draw_counter()
    love.graphics.setColor(1,0,0)
    love.graphics.printf(
        count_dead_enemies(self.base_scene) .. "/" .. #self.base_scene.obj_by_type["Enemy"],
        20,
        -320,
        780, --width
        "left"
    )
    love.graphics.setColor(1,1,1)
end

return TimerAndCounterOverlay
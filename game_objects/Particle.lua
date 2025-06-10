local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")

local Particle = {}
Particle.__index = Particle
setmetatable(Particle, GameObject)

Particle.type = "Particle"

function Particle:new(position, size, velocity, config)
    local obj = GameObject:new(position, velocity)

    obj.rotation = 0
    obj.rotation_speed = config.rotation_speed or 0.8
    obj.timer = 0
    obj.z = 0.5

    obj.width = size
    obj.height = size

    config = config or {}

    obj.lifetime = config.lifetime or 4
    obj.color = config.color or {r = 1, g = 0, b = 0, a = 0.5}
    obj.fadeout_time = config.fadeout_time or 1

    obj.acceleration = Vec2:new(0, 4000)

    return setmetatable(obj, self)
end

function Particle:update(dt)
    GameObject.update(self, dt)
    self.rotation = self.rotation + dt * self.rotation_speed
    self.timer = self.timer + dt

    if self.timer > self.lifetime then
        self.scene:remove(self)
    end
end

function Particle:draw()
    local fadeout_start = math.max(self.lifetime - self.fadeout_time, 0)
    local alpha = self.timer < fadeout_start and 1 or (self.timer - fadeout_start) / self.fadeout_time

    local c = self.color
    love.graphics.setColor(c.r, c.g, c.b, c.a or 1 * alpha)
    util.draw_rotated_rectangle("fill", self.position.x, self.position.y, self.width, self.height, self.rotation)
    love.graphics.setColor(1,1,1,1)
end


return Particle

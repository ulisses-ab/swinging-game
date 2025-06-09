local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")
local Particle = require("game_objects.Particle")

local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, GameObject)

Enemy.type = "Enemy"

function Enemy:new(position)
    local obj = GameObject:new(position)

    obj.width = 25
    obj.height = 25
    obj.rotation = 0
    obj.ROTATION_SPEED = 0.8
    obj.dead = false
    obj.attack_reach = 140
    obj.z = 0.5
    obj.dead_timer = 0
    obj.DEATH_DURATION = 1

    return setmetatable(obj, self)
end

function Enemy:from_persistance_object(obj)
    return Enemy:new(Vec2:new(obj.x, obj.y))
end

function Enemy:frozen_update(dt)
    self.rotation = self.rotation + self.ROTATION_SPEED * dt
end

function Enemy:update(dt)
    self.dead_timer = self.dead_timer + dt
    if self.dead then return end

    GameObject.update(self, dt)
end

function Enemy:draw()
    if self.dead and self.dead_timer > self.DEATH_DURATION then return end

    local alpha = 1
    if self.dead then
        local t = self.dead_timer / self.DEATH_DURATION
        love.graphics.setColor(1, 0, 0, 0.5)
        util.draw_ring(self.position.x, self.position.y, t * 5500, math.max(t*5500-100, 0))

        alpha = 0
    end

    local square_size_1 = 4*self.width
    love.graphics.setColor(1, 0, 0, 0.5 * alpha)
    util.draw_rotated_rectangle("fill", self.position.x, self.position.y, square_size_1, square_size_1, self.rotation)


    local square_size_2 = 2*self.width
    love.graphics.setColor(1, 0, 0, 0.5 * alpha)
    util.draw_rotated_rectangle("fill", self.position.x, self.position.y, square_size_2, square_size_2, self.rotation)


    love.graphics.setColor(1, 0, 0, 1 * alpha)
    GameObject.draw(self)
    love.graphics.setColor(1, 1, 1)
end

function Enemy:die()
    self.dead = true
    self.dead_timer = 0

    local PARTICLE_NUM = 22

    for i = 1, PARTICLE_NUM do
        local angle = math.random() * 2 * math.pi
        local velocity = Vec2:new(math.cos(angle), math.sin(angle)):mul(math.random(300, 1500))
        local size = math.random(10, 22)
        local particle = Particle:new(self.position:copy(), size, velocity, {})
        self.add_object(particle)
    end
end

function Enemy:respawn()
    self.dead = false
    self.dead_timer = 0
end

return Enemy

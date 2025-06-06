local GameObject = require("game_objects.GameObject")
local Vec2 = require("Vec2")
local util = require("util")

local Bullet = {}
Bullet.__index = Bullet
setmetatable(Bullet, GameObject)

function Bullet:new(position, velocity, destroy)
    local obj = GameObject:new(position, velocity)

    obj.acceleration = Vec2:new(0, 4000)
    
    obj.lifetime = 5

    obj.width = 9
    obj.height = 9

    obj.destroy = destroy

    return setmetatable(obj, self)
end

function Bullet:update(dt) 
    GameObject.update(self, dt)

    self.lifetime = self.lifetime - dt

    if self.lifetime <= 0 then
        self.destroy(self)
        return
    end
end

function Bullet:draw() 
    love.graphics.circle("fill", self.position.x, self.position.y, 9)
end

return Bullet
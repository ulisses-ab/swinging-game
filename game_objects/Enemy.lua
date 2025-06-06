local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")

local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, GameObject)

Enemy.type = "Enemy"

function Enemy:new(position)
    local obj = GameObject:new(position)

    return setmetatable(obj, self)
end

function Enemy:from_persistance_object(obj)
    return Enemy:new(Vec2:new(obj.x, obj.y))
end
function Enemy:update(dt)
    GameObject.update(self, dt)
end

function Enemy:draw()
    love.graphics.setColor(1, 0, 0)
    GameObject.draw(self)
    love.graphics.setColor(1, 1, 1)
end

return Enemy

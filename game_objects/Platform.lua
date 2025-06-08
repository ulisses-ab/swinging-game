local GameObject = require("game_objects.GameObject")
local Vec2 = require("Vec2")

local Platform = {}
Platform.__index = Platform
setmetatable(Platform, GameObject)

Platform.type = "Platform"

function Platform:new(position, width)
    local obj = GameObject:new(position)

    obj.width = width or 300
    obj.height = 12

    return setmetatable(obj, self)
end

function Platform:persistance_object()
    obj = {
        width = self.width,
        x = self.position.x,
        y = self.position.y,
        type = self.type,
    }

    return obj
end

function Platform:from_persistance_object(obj)
    return Platform:new(
        Vec2:new(obj.x, obj.y),
        obj.width
    )
end

function Platform:draw() 
    love.graphics.setColor(0.5, 0.5, 0.5)

    local fade_iterations = 4
     
    for i = 0, fade_iterations do
        local alpha = 1 - (i / fade_iterations)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.rectangle("fill", self.position.x - self.width/2, self.position.y - self.height/2 + (self.height / fade_iterations) * i, self.width, self.height / fade_iterations)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Platform:is_above(point, margin)
    margin = margin or 0

    return 
        point.y <= self.position.y - self.height/2 - 10 and
        point.x >= self.position.x - margin - self.width / 2 and point.x <= self.position.x + margin + self.width / 2
end

function Platform:is_right_above(point, margin)
    margin = margin or 0

    return 
        point.y >= self.position.y - self.height/2 - 10 and point.y < self.position.y - self.height/2 + 4 and
        point.x >= self.position.x - margin - self.width / 2 and point.x <= self.position.x + margin + self.width / 2
end

function Platform:is_below(point, margin)
    margin = margin or 0
    
    return 
        point.y > self.position.y - self.height/2 - 10 and
        point.x >= self.position.x - margin - self.width / 2 and point.x <= self.position.x + margin + self.width / 2
end


return Platform
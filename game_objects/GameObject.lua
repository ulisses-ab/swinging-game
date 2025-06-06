local Vec2 = require("Vec2")

local GameObject = {}
GameObject.__index = GameObject

GameObject.type = "GameObject"

function GameObject:new(position, velocity, acceleration)
    local obj = setmetatable({
        z = 0,
        position = position,
        velocity = velocity or Vec2:new(0, 0),
        acceleration = acceleration or Vec2:new(0, 0),
        acceleration_on = true,
        last_position = position:copy(),
        width = 10,
        height = 10,
    }, self)

    return obj
end

function GameObject:center_to_bottom_vec()
    return Vec2:new(0, self.height / 2)
end

function GameObject:get_bounding_box()
    return {
        position = Vec2:new(self.position.x - self.width / 2, self.position.y - self.height / 2),
        size = Vec2:new(self.width, self.height)
    }
end

function GameObject:persistance_object()
    obj = {
        x = self.position.x,
        y = self.position.y,
        type = self.type,
    }

    return obj
end

function GameObject:from_persistance_object(obj)
    return GameObject:new(Vec2:new(obj.x, obj.y), obj.velocity, obj.acceleration)
end

function GameObject:disable_acceleration()
    self.acceleration_on = false
end

function GameObject:enable_acceleration()
    self.acceleration_on = true
end

function GameObject:update(dt)
    self.last_position = self.position:copy()

    self:move(self.velocity:mul(dt)) 

    if self.acceleration_on then
        self:accelerate(self.acceleration:mul(dt)) 
    end
end

function GameObject:move(displacement) 
    self.position = self.position:add(displacement)
end

function GameObject:accelerate(velocity_change)
    self.velocity = self.velocity:add(velocity_change)
end

function GameObject:draw() 
    love.graphics.rectangle("fill", self.position.x-self.width/2, self.position.y-self.height/2, self.width, self.height)
end

return GameObject
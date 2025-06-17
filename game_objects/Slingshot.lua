local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")

local Slingshot = {}
Slingshot.__index = Slingshot
setmetatable(Slingshot, GameObject)

Slingshot.type = "Slingshot"

function Slingshot:new(position, strength, up_range, down_range, left_range, right_range)
    local obj = GameObject:new(position)

    strength = strength or 20000

    up_range = up_range or 100
    down_range = down_range or 100
    left_range = left_range or 100
    right_range = right_range or 100

    obj.width = 12
    obj.height = 12

    obj.rect_displacement = Vec2:new(-left_range, -up_range)
    obj.rect_size = Vec2:new(left_range+right_range, up_range+down_range)
    obj.strength = strength or 20000

    return setmetatable(obj, self)
end

function Slingshot:persistance_object()
    obj = {
        up_range = self:up_range(),
        down_range = self:down_range(),
        left_range = self:left_range(),
        right_range = self:right_range(),
        strength = self.strength,
        x = self.position.x,
        y = self.position.y,
        type = self.type,
    }

    return obj
end

function Slingshot:from_persistance_object(obj)
    return Slingshot:new(
        Vec2:new(obj.x, obj.y),
        obj.strength,
        obj.up_range,
        obj.down_range,
        obj.left_range,
        obj.right_range
    )
end

function Slingshot:up_range()
    return -self.rect_displacement.y
end

function Slingshot:down_range()
    return self.rect_size.y - self:up_range()
end

function Slingshot:left_range()
    return -self.rect_displacement.x
end

function Slingshot:right_range()
    return self.rect_size.x - self:left_range()
end

function Slingshot:set_up_range(r)
    local dr = r - self:up_range()

    self.rect_displacement.y = self.rect_displacement.y - dr
    self.rect_size.y = self.rect_size.y + dr
end

function Slingshot:set_down_range(r)
    local dr = r - self:down_range()

    self.rect_size.y = self.rect_size.y + dr
end

function Slingshot:set_left_range(r)
    local dr = r - self:left_range()

    self.rect_displacement.x = self.rect_displacement.x - dr
    self.rect_size.x = self.rect_size.x + dr
end

function Slingshot:set_right_range(r)
    local dr = r - self:right_range()

    self.rect_size.x = self.rect_size.x + dr
end


function Slingshot:rect_position()
    return self.position:add(self.rect_displacement)
end

function Slingshot:draw() 
    GameObject.draw(self)

    local rect_pos = self:rect_position()
    love.graphics.rectangle("line", rect_pos.x, rect_pos.y, self.rect_size.x, self.rect_size.y)
end

return Slingshot
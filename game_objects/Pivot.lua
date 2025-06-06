local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")

local Pivot = {}
Pivot.__index = Pivot
setmetatable(Pivot, GameObject)

Pivot.type = "Pivot"

function Pivot:new(position, is_rigid, range)
    local obj = GameObject:new(position)

    obj.is_rigid = is_rigid or false
    obj.range = range or 300

    return setmetatable(obj, self)
end

function Pivot:persistance_object()
    obj = {
        is_rigid = self.is_rigid,
        range = self.range,
        x = self.position.x,
        y = self.position.y,
        type = self.type,
    }

    return obj
end

function Pivot:from_persistance_object(obj)
    return Pivot:new(
        Vec2:new(obj.x, obj.y),
        obj.is_rigid,
        obj.range
    )
end

function Pivot:draw() 
    GameObject.draw(self)
    love.graphics.circle("line", self.position.x, self.position.y, self.range)
end

return Pivot
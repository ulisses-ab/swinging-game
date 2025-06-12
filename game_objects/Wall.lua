local GameObject = require("game_objects.GameObject")
local Platform = require("game_objects.Platform")
local util = require("util")
local Vec2 = require("Vec2")

local Wall = {}
Wall.__index = Wall
setmetatable(Wall, Platform)

Wall.type = "Wall"

function Wall:new(position, width, height)
    local obj = Platform:new(position, width or 50)

    obj.height = height or 50

    return setmetatable(obj, self)
end

function Wall:persistance_object()
    obj = {
        x = self.position.x,
        y = self.position.y,
        width = self.width,
        height = self.height,
        type = self.type,
    }

    return obj
end

function Wall:from_persistance_object(obj)
    return Wall:new(
        Vec2:new(obj.x, obj.y),
        obj.width,
        obj.height
    )
end

function Wall:draw()
    GameObject.draw(self)
end

return Wall

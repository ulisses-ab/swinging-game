local util = require("util")
local Vec2 = require("Vec2")
local GameObject = require("game_objects.GameObject")
local util = require("util")
local sounds = require("sounds")

local WallBehavior = {}
WallBehavior.__index = WallBehavior

WallBehavior.fall_sound = sounds.platform_fall

function WallBehavior:new(owner)
    local obj = {
        owner = owner,
        get_walls = nil,
    }

    return setmetatable(obj, self)
end

function WallBehavior:is_x_outside(wall, x)
    return math.abs(wall.position.x - x) >= self.owner.width / 2 + wall.width / 2 - 2
end

function WallBehavior:is_y_outside(wall, y)
    return math.abs(wall.position.y - y) >= self.owner.height / 2 + wall.height / 2 - 2
end

function WallBehavior:is_outside(wall, pos)
    return 
        self:is_x_outside(wall, pos.x) or
        self:is_y_outside(wall, pos.y)
end

function WallBehavior:set_get_walls(get_walls)
    self.get_walls = get_walls
end

function WallBehavior:update(dt)
    for _, wall in ipairs(self:get_walls()) do
        local owner = self.owner 
        local displacement = owner.position:sub(wall.position)

        if not self:is_outside(wall, owner.position) then
            if self:is_x_outside(wall, owner.last_position.x) then
                displacement.x = util.sign(displacement.x) * (wall.width / 2 + owner.width / 2)
                owner.velocity.x = 0
            else
                displacement.y = util.sign(displacement.y) * (wall.height / 2 + owner.height / 2)
                owner.velocity.y = 0
            end

            owner.position = wall.position:add(displacement)
        end

        if not self:is_outside(wall, owner:next_position(dt)) then
            if self:is_x_outside(wall, owner.position.x) then
                owner.velocity.x = 0
            else
                owner.velocity.y = 0
            end
        end
    end
end

return WallBehavior
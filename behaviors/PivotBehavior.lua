local util = require("util")
local Vec2 = require("Vec2")
local GameObject = require("game_objects.GameObject")
local sounds = require("sounds")

local PivotBehavior = {}
PivotBehavior.__index = PivotBehavior

local attach_sound = sounds.pivot_attach

function PivotBehavior:new(owner, draw_line)
    local obj = {
        owner = owner,
        near_pivot = nil,
        attached_pivot = nil,
        attachment_radius = 0,
        draw_line = draw_line,
        tangential_velocity = 0,
    }

    return setmetatable(obj, self)
end

function PivotBehavior:is_attached()
    return self.attached_pivot ~= nil
end

function PivotBehavior:set_near_pivot(pivot)
    self.near_pivot = pivot

    if util.input:is_down("space") then
        self:try_attaching()
    end
end

function PivotBehavior:reset_near_pivot()
    self.near_pivot = nil
end

function PivotBehavior:try_attaching()
    if not self.near_pivot or self:is_attached() then
        return
    end

    self.attached_pivot = self.near_pivot
    self.attachment_radius = math.min(self:displacement():length(), self.near_pivot.range)

    attach_sound:stop()
    attach_sound:play()

    self.tangential_velocity = self:get_tangential_velocity()
end

function PivotBehavior:get_tangential_velocity()
    return self.owner.velocity:cross(self:displacement():normalize())
end

function PivotBehavior:displacement()
    return self.owner.position:sub(self.attached_pivot.position)
end 

function PivotBehavior:try_detaching()
    if self:is_attached() then
        self.owner.velocity = self:get_cartesian_velocity()
    end

    self.attached_pivot = nil
end

function PivotBehavior:update(dt) 
    self:check_collision()

    if self:is_attached() then
        self:update_when_attached(dt)
    end
end

function PivotBehavior:update_when_attached(dt)
    self:accelerate(self.owner.acceleration:mul(dt))

    self.owner.position = self.attached_pivot.position:add(self:displacement():rotate(-self.tangential_velocity * dt / self.attachment_radius))

    self:add_damping(dt)
end

function PivotBehavior:get_cartesian_velocity()
    return self:displacement():normalize():orthogonal():mul(self.tangential_velocity*-1)
end

function PivotBehavior:add_damping(dt)
    local DAMPING_COEFFICIENT = 0.25

    self.tangential_velocity = self.tangential_velocity - self.tangential_velocity * DAMPING_COEFFICIENT * dt
end

function PivotBehavior:accelerate(velocity_change)
    local change = velocity_change:cross(self:displacement():normalize())
    self.tangential_velocity = self.tangential_velocity + change
end

function PivotBehavior:draw()
    if not self:is_attached() then
        return
    end
    
    self.draw_line(self.owner.position, self.attached_pivot.position)
end

function PivotBehavior:check_collision()
    local player = self.owner

    for _, pivot in ipairs(player.scene.obj_by_type["Pivot"]) do
        if util.circular_collision(player.position, pivot.position, pivot.range + 10) then
            self:set_near_pivot(pivot)
            return
        end
    end

    self:reset_near_pivot()
end

return PivotBehavior
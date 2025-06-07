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
        draw_line = draw_line
    }

    return setmetatable(obj, self)
end

function PivotBehavior:is_attached()
    return self.attached_pivot ~= nil
end

function PivotBehavior:set_near_pivot(pivot)
    self.near_pivot = pivot
end

function PivotBehavior:reset_near_pivot()
    self.near_pivot = nil
end

function PivotBehavior:try_attaching()
    if not self.near_pivot then
        return
    end

    local pivot_displacement = self.owner.position:sub(self.near_pivot.position)

    self.attachment_radius = math.min(pivot_displacement:length(), self.near_pivot.range)
    self.attached_pivot = self.near_pivot

    attach_sound:stop()
    attach_sound:play()
end

function PivotBehavior:try_detaching()
    self.attached_pivot = nil
end

function PivotBehavior:is_rope_extended()
    if not self:is_attached() then 
        return false
    end

    local pivot_displacement = self.owner.position:sub(self.attached_pivot.position)
    return self.attached_pivot.is_rigid or self.attachment_radius - pivot_displacement:length() < 2
end

function PivotBehavior:update(dt) 
    if not self:is_attached() then
        return
    end

    local pivot_displacement = self.owner.position:sub(self.attached_pivot.position)

    if not self.attached_pivot.is_rigid and self.attachment_radius - pivot_displacement:length() > 5 then
        return
    end

    local inward_velocity_module = self.owner.velocity:dot(pivot_displacement) < 0 and self.owner.velocity:project(pivot_displacement):length() or 0
    local tangetial_velocity_module = self.owner.velocity:orthogonal_projection(pivot_displacement):length()
    local pivot_distance = pivot_displacement:length()
    local correction_module = pivot_distance - self.attachment_radius
    local correction = pivot_displacement:normalize():mul(-correction_module)

    if self.attached_pivot.is_rigid or inward_velocity_module == 0 then
        self.owner:move(correction)
    end

    local new_velocity = self.owner.velocity:orthogonal_projection(pivot_displacement):normalize():mul(tangetial_velocity_module)

    if not self.attached_pivot.is_rigid then
        new_velocity = new_velocity:add(pivot_displacement:normalize():mul(-inward_velocity_module))
    end

    self.owner.velocity = new_velocity
end

function PivotBehavior:accelerate_clockwise(velocity_change)
    if not self:is_attached() then
        return
    end

    local pivot_displacement = self.owner.position:sub(self.attached_pivot.position)

    self.owner.velocity = self.owner.velocity:add(pivot_displacement:orthogonal():normalize():mul(velocity_change))
end

function PivotBehavior:accelerate_counterclockwise(velocity_change)
    self:accelerate_clockwise(-velocity_change)
end

function PivotBehavior:is_above()
    if not self:is_attached() then
        return false
    end

    local pivot_displacement = self.owner.position:sub(self.attached_pivot.position)
    return pivot_displacement.y < 0
end

function PivotBehavior:is_on_right()
    if not self:is_attached() then
        return false
    end

    local pivot_displacement = self.owner.position:sub(self.attached_pivot.position)
    return pivot_displacement.x > 0
end

function PivotBehavior:draw()
    if not self:is_attached() then
        return
    end
    
    self.draw_line(self.owner.position, self.attached_pivot.position)
end

return PivotBehavior
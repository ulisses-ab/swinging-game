local util = require("util")
local Vec2 = require("Vec2")
local GameObject = require("game_objects.GameObject")
local sounds = require("sounds")

local SlingshotBehavior = {}
SlingshotBehavior.__index = SlingshotBehavior


local attach_sound = sounds.slingshot_attach

function SlingshotBehavior:new(owner, draw_line)
    local obj = {
        owner = owner,
        near_slingshot = nil,
        attached_slingshot = nil,
        draw_line = draw_line
    }

    obj.dampening_factor = 2

    return setmetatable(obj, self)
end

function SlingshotBehavior:is_attached()
    return self.attached_slingshot ~= nil
end

function SlingshotBehavior:set_near_slingshot(slingshot)
    self.near_slingshot = slingshot
end

function SlingshotBehavior:reset_near_slingshot()
    self.near_slingshot = nil
end

function SlingshotBehavior:try_attaching()
    if not self.near_slingshot then
        return
    end

    self.attached_slingshot = self.near_slingshot
    self.owner:disable_acceleration()
    self.owner.velocity = Vec2:new(0, 0)

    attach_sound:stop()
    attach_sound:play()
end

function SlingshotBehavior:try_detaching()
    self.attached_slingshot = nil
    self.owner:enable_acceleration()
end

function SlingshotBehavior:update(dt)
    if not self:is_attached() then
        return
    end
    
    local slingshot_displacement = self.owner.position:sub(self.attached_slingshot.position)

    local MIN_DISTANCE_THRESHOLD = 20
    local pull_strength = 1
    if slingshot_displacement:length() < MIN_DISTANCE_THRESHOLD then
        pull_strength = slingshot_displacement:length() / MIN_DISTANCE_THRESHOLD
    end

    local slingshot_acceleration = slingshot_displacement:normalize():mul(pull_strength):mul(-self.attached_slingshot.strength)
    velocity_change = slingshot_acceleration:mul(dt)

    self.owner.velocity = self.owner.velocity:add(velocity_change)
    self.owner.velocity = self.owner.velocity:sub(self.owner.velocity:mul(dt):mul(self.dampening_factor))
end

function SlingshotBehavior:draw()
    if not self:is_attached() then
        return
    end

    self.draw_line(self.owner.position, self.attached_slingshot.position)
end


return SlingshotBehavior
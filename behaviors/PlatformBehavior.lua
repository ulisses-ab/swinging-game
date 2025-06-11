local util = require("util")
local Vec2 = require("Vec2")
local GameObject = require("game_objects.GameObject")
local util = require("util")
local sounds = require("sounds")

local PlatformBehavior = {}
PlatformBehavior.__index = PlatformBehavior

PlatformBehavior.fall_sound = sounds.platform_fall

function PlatformBehavior:new(owner)
    local obj = {
        owner = owner,
        platform = nil,
        on_land = nil,
        just_reset = nil,
        reset_timer = 0,
    }

    return setmetatable(obj, self)
end

function PlatformBehavior:is_on_platform()
    return self.platform ~= nil
end

function PlatformBehavior:try_going_down()
    if not self.platform then return end
    if self.platform.type == "Wall" then return end

    self:reset_platform()
end

function PlatformBehavior:set_platform(platform)
    if self:is_on_platform() then return end
    if self.just_reset == platform and self.reset_timer < 0.03 then return end
    if not self.owner.controller:set_platform(platform) then return end

    self.platform = platform
    self.owner.velocity.y = 0
    self.owner.position.y = self.platform.position.y - self.platform.height / 2 - self.owner.height / 2


    if self.on_land then
        self.on_land()
    end

    self.fall_sound:stop()
    self.fall_sound:play()
end

function PlatformBehavior:reset_platform()
    self.just_reset = self.platform
    self.reset_timer = 0

    self.platform = nil
end

function PlatformBehavior:update(dt)
    self.reset_timer = self.reset_timer + dt

    self:check_collision()

    if not self:is_on_platform() then
        return
    end

    self.owner.velocity.y = 0
    self.owner.position.y = self.platform.position.y - self.platform.height / 2 - self.owner.height / 2

    if not self.platform:is_above(self.owner.position, self.owner.width / 2) then
        self:reset_platform()
    end
end

function PlatformBehavior:check_collision()
    for _, platform in ipairs(self.owner.scene.obj_by_type["Platform"]) do
        if self:collides(platform) then
            self:set_platform(platform)
            return
        end
    end

    for _, wall in ipairs(self.owner.scene.obj_by_type["Wall"]) do
        if self:collides(wall) then
            self:set_platform(wall)
            return
        end
    end
end

function PlatformBehavior:collides(platform)
    local player = self.owner

    return
        (platform:is_above(player.last_position:add(player:center_to_bottom_vec()), player.width / 2 - 2) and
        platform:is_below(player.position:add(player:center_to_bottom_vec()), player.width / 2 - 2)) or
        (platform:is_right_above(player.position:add(player:center_to_bottom_vec()), player.width / 2 - 2) and
        player.velocity.y > 0)
end

return PlatformBehavior
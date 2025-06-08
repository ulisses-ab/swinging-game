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
        just_went_doown = nil
    }

    return setmetatable(obj, self)
end

function PlatformBehavior:is_on_platform()
    return self.platform ~= nil
end

function PlatformBehavior:try_going_down()
    self.just_went_doown = self.plataform
    self:reset_platform()
end

function PlatformBehavior:set_platform(platform)
    if self.just_went_doown == platform then
        return
    end

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
    self.platform = nil
end

function PlatformBehavior:update(dt)
    if not self:is_on_platform() then
        return
    end

    self.owner.velocity.y = 0
    self.owner.position.y = self.platform.position.y - self.platform.height / 2 - self.owner.height / 2

    if not self.platform:is_above(self.owner.position, self.owner.width / 2) then
        self:reset_platform()
    end
end

return PlatformBehavior
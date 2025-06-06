local util = require("util")
local Vec2 = require("Vec2")
local GameObject = require("game_objects.GameObject")
local util = require("util")

local PlatformBehavior = {}
PlatformBehavior.__index = PlatformBehavior

function PlatformBehavior:new(owner)
    local obj = {
        owner = owner,
        platform = nil,
        on_land = nil
    }

    obj.go_down_timer = 10
    obj.GO_DOWN_DURATION = 0.05

    return setmetatable(obj, self)
end

function PlatformBehavior:is_on_platform()
    return self.platform ~= nil
end

function PlatformBehavior:try_going_down()
    self.go_down_timer = 0
    self:reset_platform()
end

function PlatformBehavior:set_platform(platform)
    if self.go_down_timer < self.GO_DOWN_DURATION then
        return
    end

    self.platform = platform
    self.owner.velocity.y = 0
    self.owner.position.y = self.platform.position.y - self.platform.height / 2 - self.owner.height / 2

    if self.on_land then
        self.on_land()
    end
end

function PlatformBehavior:reset_platform()
    self.platform = nil
end

function PlatformBehavior:update(dt)
    self.go_down_timer = self.go_down_timer + dt

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
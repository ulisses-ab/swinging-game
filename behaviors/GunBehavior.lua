local util = require("util")
local Vec2 = require("Vec2")
local GameObject = require("game_objects.GameObject")
local util = require("util")

local GunBehavior = {}
GunBehavior.__index = GunBehavior

function GunBehavior:new(owner)
    local obj = {
        owner = owner,
        spawn_bullet = function() end,
        load_timer = 0,
        is_loading = false,
        MAX_LOADING_TIME = 0.7,
        MIN_LOADING_TIME = 0.2,
        VELOCITY_COEFFICIENT = 4000
    }

    self.BULLET_VELOCITY = 2000

    return setmetatable(obj, self)
end

function GunBehavior:update(dt)
    self.load_timer = math.min(self.load_timer + dt, self.MAX_LOADING_TIME)
end

function GunBehavior:release()
    self.is_loading = false

    if self.load_timer < self.MIN_LOADING_TIME then
        return
    end

    local mx, my = self.owner:get_mouse_position()
    local mouse_pos = Vec2:new(mx, my)

    local direction = mouse_pos:sub(self.owner.position):normalize()

    self.spawn_bullet(self.owner.position, direction:mul(self.load_timer * self.VELOCITY_COEFFICIENT))
end

function GunBehavior:load()
    self.load_timer = 0
    self.is_loading = true
end

function GunBehavior:draw()
    if self.is_loading then
        local MAX_RECT_HEIGHT = 50
        local MIN_SHOOTING_HEIGHT = MAX_RECT_HEIGHT * self.MIN_LOADING_TIME / self.MAX_LOADING_TIME
        local rect_height = MAX_RECT_HEIGHT * self.load_timer / self.MAX_LOADING_TIME

        love.graphics.rectangle("fill", self.owner.position.x + 30, self.owner.position.y - rect_height, 10, rect_height)
        love.graphics.rectangle("line", self.owner.position.x + 30, self.owner.position.y - MAX_RECT_HEIGHT, 10, MAX_RECT_HEIGHT)
        love.graphics.rectangle("line", self.owner.position.x + 30, self.owner.position.y - MIN_SHOOTING_HEIGHT, 10, MIN_SHOOTING_HEIGHT)
    end
end

return GunBehavior
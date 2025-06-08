local util = require("util")
local Vec2 = require("Vec2")
local GameObject = require("game_objects.GameObject")

local SwordBehavior = {}
SwordBehavior.__index = SwordBehavior

function SwordBehavior:new(owner)
    local obj = {
        owner = owner,
        attack_timer = 10,
        attack_angle = nil,
        ATTACK_DURATION = 0.1,
        ATTACK_AMPLITUDE = 1.6,
        ATTACK_LENGTH = 10,
        COOLDOWN_TIME = 1
    }

    return setmetatable(obj, self)
end

function SwordBehavior:update(dt)
    self.attack_timer = self.attack_timer + dt
end

function SwordBehavior:try_attack()
    if self.attack_timer < self.COOLDOWN_TIME then
        return
    end

    self.attack_timer = 0

    local mx, my = self.owner:get_mouse_position()
    local mouse_pos = Vec2:new(mx, my)

    self.attack_angle = mouse_pos:sub(self.owner.position):normalize():angle()
end

function SwordBehavior:draw()
    if self.attack_timer > self.ATTACK_DURATION then
        return
    end

    local angle = self.attack_angle + (self.attack_timer / self.ATTACK_DURATION) * self.ATTACK_AMPLITUDE - self.ATTACK_AMPLITUDE / 2

    local x, y = self.owner.position.x, self.owner.position.y
    local length = self.ATTACK_LENGTH + 100
    local width = 4

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    love.graphics.rectangle("fill", 0, -width / 2, length, width)
    love.graphics.pop()
end

return SwordBehavior
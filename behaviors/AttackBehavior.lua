local util = require("util")
local Vec2 = require("Vec2")
local sounds = require("sounds")

local AttackBehavior = {}
AttackBehavior.__index = AttackBehavior

function AttackBehavior:new(owner)
    local obj = {
        owner = owner,
        attack_timer = 10,
        get_enemies = nil,
        ATTACK_REACH = 70,
        ATTACK_DURATION = 0.25,
        attack_start = nil,
        attack_path = nil,
    }

    return setmetatable(obj, self)
end

function AttackBehavior:set_get_enemies(get_enemies)
    self.get_enemies = get_enemies
end

function AttackBehavior:update(dt)
    self.attack_timer = self.attack_timer + dt
end

function AttackBehavior:draw()
    if not self:is_attacking() then return end

    local t = self.attack_timer / self.ATTACK_DURATION
    local progress = t < 0.5 and util.ease_in_out(t*2) or 1
    local alpha = t < 0.5 and 1 or 1 - 2*(t-0.5)

    local slash_start = self.attack_start
    local slash_end = self.attack_start:add(self.attack_path:mul(progress))

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setLineWidth(12)
    love.graphics.setBlendMode("add")
    love.graphics.line(slash_start.x, slash_start.y, slash_end.x, slash_end.y)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
end

function AttackBehavior:is_attacking()
    return self.attack_timer < self.ATTACK_DURATION
end

function AttackBehavior:attack()
    local enemies = self.get_enemies()

    for i, enemy in ipairs(enemies) do
        if util.circular_collision(self.owner.position, enemy.position, enemy.attack_reach) then
            self:attack_enemy(enemy)
        end
    end 
end

function AttackBehavior:attack_enemy(enemy)
    self.attack_timer = 0

    local displacement = self.owner.position:sub(enemy.position)

    local length = 100

    sounds.slash:stop()
    sounds.slash:play()

    enemy:die()
    local start_displacement = displacement:orthogonal():normalize():mul(math.random() > 0.5 and length or -length)

    self.attack_start = enemy.position:add(start_displacement)
    self.attack_path = start_displacement:mul(-2)
end

function AttackBehavior:reset()
    self.attack_timer = 10
end

return AttackBehavior
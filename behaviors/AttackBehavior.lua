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
        end_animation_timer = 20,
        end_animation_duration = 2.4,
        time_rate = util.time_rate
    }

    return setmetatable(obj, self)
end

function AttackBehavior:update(dt)
    self.attack_timer = self.attack_timer + dt
    self.end_animation_timer = self.end_animation_timer + dt / util.time_rate

    if self.end_animation_timer < self.end_animation_duration then
        local progress = self.end_animation_timer / self.end_animation_duration
        local t = progress * progress
        local MIN_TIME_RATE = 0.001
        local current_time_rate = util.lerp(MIN_TIME_RATE, self.time_rate, t)

        sounds.slash:setPitch(math.max(0.1, t))
        sounds.slash:setVolume(0.6 + (1 - t) * 0.4)

        util.time_rate = current_time_rate

        local SHAKE_MAGNITUDE = 20
        util.camera_shake.x = math.random(-1,1) * SHAKE_MAGNITUDE * (1 - progress)
        util.camera_shake.y = math.random(-1,1) * SHAKE_MAGNITUDE * (1 - progress)
    end
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
    --love.graphics.line(slash_start.x, slash_start.y, slash_end.x, slash_end.y)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(util.global_line_width)
end

function AttackBehavior:is_attacking()
    return self.attack_timer < self.ATTACK_DURATION
end

function AttackBehavior:attack()
    for i, enemy in ipairs(self.owner.scene.obj_by_type["Enemy"]) do
        if util.circular_collision(self.owner.position, enemy.position, enemy.attack_reach) and not enemy.dead then
            self:attack_enemy(enemy)
        end
    end 
end

function AttackBehavior:attack_enemy(enemy)
    self.attack_timer = 0

    if #self.owner.scene.obj_by_type["Enemy"] - self.owner.scene:count_dead_enemies() == 1 then
        self.end_animation_timer = 0
        self.time_rate = util.time_rate
    end

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
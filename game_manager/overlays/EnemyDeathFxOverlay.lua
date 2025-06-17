local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local EventBus = require("EventBus")
local util = require("util")
local sounds = require("sounds")

local EnemyDeathFxOverlay = {}
EnemyDeathFxOverlay.__index = EnemyDeathFxOverlay
setmetatable(EnemyDeathFxOverlay, Overlay)

function EnemyDeathFxOverlay:new(wrapped, base_scene)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene
    obj.duration = 2.4
    obj.timer = 0

    EventBus:listen("EnemyDeath", function(...)
        obj:on_enemy_death(...)
    end)

    return setmetatable(obj, EnemyDeathFxOverlay)
end

local function count_live_enemies(scene)
    local count = 0

    for _, enemy in ipairs(scene.obj_by_type["Enemy"]) do
        if not enemy.dead then
            count = count + 1
        end
    end

    return count
end

function EnemyDeathFxOverlay:on_enemy_death()
    if count_live_enemies(self.base_scene) == 0 then
        self:on_last_enemy_death()
    end
end

function EnemyDeathFxOverlay:update(dt)
    self.timer = self.timer - dt

    if self.timer > 0 then
        self:update_animation(dt)
    else
        sounds.slash:setPitch(1)
    end

    Overlay.update(self, dt*self.time_rate)
end

function EnemyDeathFxOverlay:update_animation(dt)
    if self.timer < 0 then
        self.camera_translate.x = 0
        self.camera_translate.y = 0
        return
    end

    local progress = 1 - self.timer / self.duration
    local t = progress * progress
    local MIN_TIME_RATE = 0.001
    local current_time_rate = util.lerp(MIN_TIME_RATE, 1, t)

    sounds.slash:setPitch(math.max(0.1, t))
    sounds.slash:setVolume(0.6 + (1 - t) * 0.4)

    self.time_rate = current_time_rate

    local SHAKE_MAGNITUDE = 20
    self.camera_translate.x = math.random(-1,1) * SHAKE_MAGNITUDE * (1 - progress)
    self.camera_translate.y = math.random(-1,1) * SHAKE_MAGNITUDE * (1 - progress)
end

function EnemyDeathFxOverlay:on_last_enemy_death(enemy)
    self.timer = self.duration
end

return EnemyDeathFxOverlay
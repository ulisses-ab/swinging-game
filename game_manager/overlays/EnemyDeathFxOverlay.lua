local Overlay = require("Overlay")
local Scene = require("Scene")
local EventBus = require("EventBus")

local EnemyDeathFxOverlay = {}
EnemyDeathFxOverlay.__index = EnemyDeathFxOverlay
setmetatable(EnemyDeathFxOverlay, Overlay)

function EnemyDeathFxOverlay:new(wrapped, base_scene)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene

    obj.duration = 2.4
    obj.timer = 0

    EventBus:listen("LastEnemyDeath", function(...)
        self:on_last_enemy_death(...)
    end)

    return setmetatable(obj, EnemyDeathFxOverlay)
end

function EnemyDeathFxOverlay:update(dt)
    self.timer = self.timer + dt

    if self.timer > 0 then
        self:update_animation(dt)
    else 

    ed

    Updater.update(self, dt)
end

function EnemyDeathFxOverlay:update_animation(dt)
    if self.timer < 0 then
        self.scene.camera_translate.x = 0
        self.scene.camera_translate.y = 0
        return
    end

    local progress = 1 - self.timer / self.duration
    local t = progress * progress
    local MIN_TIME_RATE = 0.001
    local current_time_rate = util.lerp(MIN_TIME_RATE, util.default_time_rate, t)

    sounds.slash:setPitch(math.max(0.1, t))
    sounds.slash:setVolume(0.6 + (1 - t) * 0.4)

    self.scene.time_rate = current_time_rate

    local SHAKE_MAGNITUDE = 20
    self.scene.camera_translate.x = math.random(-1,1) * SHAKE_MAGNITUDE * (1 - progress)
    self.scene.camera_translate.y = math.random(-1,1) * SHAKE_MAGNITUDE * (1 - progress)
end

function EnemyDeathFxOverlay:on_last_enemy_death(enemy)
    self.timer = self.duration
end

return EnemyDeathFxOverlay
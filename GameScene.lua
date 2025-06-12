local Scene = require("Scene")
local EventBus = require("EventBus")

local GameScene = {}
GameScene.__index = GameScene
setmetatable(GameScene, Scene)

function GameScene:new(wrapped)
    local obj = Scene:new()

    EventBus:listen("EnemyDeath", function() obj:on_enemy_death() end)

    return setmetatable(obj, GameScene)
end

function GameScene:on_enemy_death()
    if self:count_live_enemies() == 0 then
        EventBus:emit("GameEnded", self)
    end
end

function GameScene:count_enemies()
    return #self.obj_by_type["Enemy"]
end

function GameScene:count_dead_enemies()
    local count = 0

    for _, enemy in ipairs(self.obj_by_type["Enemy"]) do
        if enemy.dead then
            count = count + 1
        end
    end

    return count
end

function GameScene:count_live_enemies()
    return self:count_enemies() - self:count_dead_enemies()
end

function GameScene:get_player()
    return self.obj_by_type["Player"][1]
end

return GameScene
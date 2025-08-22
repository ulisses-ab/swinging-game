local Scene = require("Scene")
local EventBus = require("EventBus")

local GameScene = {}
GameScene.__index = GameScene
setmetatable(GameScene, Scene)

function GameScene:new(wrapped)
    local obj = Scene:new()

    obj.allow_respawn = true

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

function GameScene:lowest_point()
    local lowest_point = 0

    for _, object in ipairs(self.objects) do
        local bottom

        if object.type == "Player" or object.type == "Particle" then
            goto continue
        elseif object.type == "Slingshot" then
            bottom = object.position.y + object:down_range()
        elseif object.type == "Pivot" then
            bottom = object.position.y + object.range
        else 
            bottom = object.position.y + object.height/2
        end

        lowest_point = math.max(bottom, lowest_point)

        ::continue::
    end

    return lowest_point
end

return GameScene